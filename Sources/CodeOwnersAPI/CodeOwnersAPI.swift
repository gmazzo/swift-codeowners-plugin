import Foundation

nonisolated(unsafe) private let nsClassNameRegEx = /(\w+)\.(\w+)/

public typealias CodeOwners = [String] // order is important for attribution

public protocol HasCodeOwners  {
    static var codeOwners: CodeOwners { get }
}

public protocol CodeOwnersMappingProvider  {
    static var codeOwners: [Substring: CodeOwners]? { get }
}

public func codeOwnersOf(_ of: Any?) -> CodeOwners? {
    guard let of else { return nil }
    if let owners = resolveFromWithCodeOwnersProtocol(of) { return owners }
    
    let type = of as? AnyClass ?? type(of: of)
    if let owners = resolveFromWithCodeOwnersProtocol(type) { return owners }
    
    // this is a critical assumption (hack) that works under the assumption that the the outcome of
    // String(reflecting: type) will be in the format of `ModuleName.TypeName`
    // if this changes in future Swift versions, this code and the whole solution will break
    let nsClassName = "\(String(reflecting: type))"
    return codeOwnersOf(nsClassName, lookUpForClass: false)
}

public func codeOwnersOf(nsClassName: String) -> CodeOwners? {
    return codeOwnersOf(nsClassName, lookUpForClass: true)
}

private func codeOwnersOf(_ nsClassName: String, lookUpForClass: Bool) -> CodeOwners? {
    for match in nsClassName.matches(of: nsClassNameRegEx) {
        let (moduleName, typeName) = (match.1, match.2)
        
        if lookUpForClass, let nsClass = NSClassFromString("\(moduleName).\(typeName)") {
            if let owners = resolveFromWithCodeOwnersProtocol(nsClass) { return owners }
        }
        
        let provider = resolveMappings(moduleName)
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

private func resolveFromWithCodeOwnersProtocol(_ objOrType: Any?) -> CodeOwners? {
    return (objOrType as? HasCodeOwners.Type)?.codeOwners
}

private func resolveMappings(_ moduleName: Substring) -> [Substring: CodeOwners]? {
    let provider = NSClassFromString("\(moduleName)._CodeOwners") as? CodeOwnersMappingProvider.Type
    return provider?.codeOwners
}
