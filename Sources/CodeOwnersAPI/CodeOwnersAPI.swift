import Foundation

nonisolated(unsafe) private let nsClassNameRegEx = /(\w+)\.(\w+)/

public typealias CodeOwners = [String] // order is important for attribution

public protocol CodeOwnersMappingProvider  {
    static var codeOwners: [Substring: CodeOwners]? { get }
}

public func codeOwnersOf(_ of: Any.Type?) -> CodeOwners? {
    guard let of else { return nil }
    // this is a critical assumption (hack) that works under the assumption that the the outcome of
    // String(reflecting: type) will be in the format of `ModuleName.TypeName`
    // if this changes in future Swift versions, this code and the whole solution will break
    let className = "\(String(reflecting: of))"
    return codeOwnersOf(nsClassName: className)
}

public func codeOwnersOf(nsClassName: String) -> CodeOwners? {
    for match in nsClassName.matches(of: nsClassNameRegEx) {
        let (moduleName, typeName) = (match.1, match.2)
        let provider = resolve(moduleName)
        if let owners = provider?[typeName] { return owners }
    }
    return nil
}

#if os(Linux)
@available(*, deprecated, message: "Call stacks are not fully supported on Linux")
#endif
public func codeOwnersFromCallStack(symbols: [String] = Thread.callStackSymbols, demangle: Bool = true) -> CodeOwners? {
    for symbol in symbols {
        guard let className = classNameFromSymbol(symbol, demangle) else { continue }
        if let owners = codeOwnersOf(nsClassName: "\(className)") { return owners }
    }
    return nil
}

private func resolve(_ moduleName: Substring) -> [Substring: CodeOwners]? {
    let provider = NSClassFromString("\(moduleName)._CodeOwners") as? CodeOwnersMappingProvider.Type
    return provider?.codeOwners
}
