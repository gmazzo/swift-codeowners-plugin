import Foundation

private let queue = DispatchQueue(label: "CodeOwners cache", attributes: .concurrent)
nonisolated(unsafe) private var ownersCache: [Substring: [Substring: CodeOwners]] = [:]
nonisolated(unsafe) private let nsClassNameRegEx = /(\w+)\.(\w+)/

public typealias CodeOwners = [String] // order is important for attribution

public protocol CodeOwnersMappingProvider  {
    static var codeOwners: [Substring: CodeOwners]? { get }
}

private class Missing : CodeOwnersMappingProvider {
    static let codeOwners: [Substring: CodeOwners]? = nil
}

public func codeOwnersOf(_ of: Any?) -> CodeOwners? {
    if of == nil { return nil }
    let type = of as? AnyClass ?? type(of: of!)
    return codeOwnersOf(nsClassName: "\(String(reflecting: type))")
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
    if let cached = queue.sync(execute: { ownersCache[moduleName] }) {
        return cached
    }
    
    let provider = (NSClassFromString("\(moduleName)._CodeOwners") as? CodeOwnersMappingProvider.Type) ?? Missing.self
    let mappings = provider.codeOwners
    queue.async { ownersCache[moduleName] = mappings }
    return mappings
}
