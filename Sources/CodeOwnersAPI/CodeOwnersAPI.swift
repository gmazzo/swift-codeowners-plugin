import Foundation

nonisolated(unsafe) private var ownersCache: [Substring: CodeOwnersMappingProvider.Type] = [:]
private let writeLock = NSLock()

public typealias CodeOwners = Set<String>

public protocol CodeOwnersMappingProvider  {
    static var codeOwners: [Substring: CodeOwners]? { get }
}

private class Missing : CodeOwnersMappingProvider {
    static let codeOwners: [Substring: CodeOwners]? = nil
}

public func codeOwnersOf(_ of: Any?) -> CodeOwners? {
    if of == nil { return nil }
    let type = type(of: of!)
    return codeOwnersOf(nsClassName: "\(String(reflecting: type))")
}

public func codeOwnersOf(nsClassName: String) -> CodeOwners? {
    let parts = nsClassName.split(separator: ".", maxSplits: 3)
    if parts.count < 2 { return nil }
    
    let (moduleName, typeName) = (parts[0], parts[1])
    let provider = resolve(moduleName)
    return provider?[typeName]
}

#if os(Linux)
@available(*, deprecated, message: "Call stacks are not fully supported on Linux")
#endif
public func codeOwnersOfCallStack(symbols: [String] = Thread.callStackSymbols, demangle: Bool = true) -> CodeOwners? {
    for symbol in symbols {
        guard let className = classNameFromSymbol(symbol, demangle) else { continue }
        if let owners = codeOwnersOf(nsClassName: "\(className)") { return owners }
    }
    return nil
}

private func resolve(_ moduleName: Substring) -> [Substring: CodeOwners]? {
    if let cached = ownersCache[moduleName] { return cached.codeOwners }
    
    let provider = (NSClassFromString("\(moduleName)._CodeOwners") as? CodeOwnersMappingProvider.Type) ?? Missing.self
    writeLock.withLock { ownersCache[moduleName] = provider }
    return provider.codeOwners
}
