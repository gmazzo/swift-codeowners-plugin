import Foundation

nonisolated(unsafe) private var ownersCache: [Substring: CodeOwnersMappingProvider.Type] = [:]
private let writeLock = NSLock()

public protocol CodeOwnersMappingProvider  {
    static var codeOwners: [Substring: Set<String>]? { get }
}

private class Missing : CodeOwnersMappingProvider {
    static let codeOwners: [Substring: Set<String>]? = nil
}

public func codeOwnersOf(_ obj: Any) -> Set<String>? {
    let parts = "\(String(reflecting: type(of: obj)))".split(separator: ".", maxSplits: 3)
    if parts.count < 2 { return nil }
    
    let (moduleName, typeName) = (parts[0], parts[1])
    let provider = resolve(moduleName)
    return provider?[typeName]
}

private func resolve(_ moduleName: Substring) -> [Substring: Set<String>]? {
    if let cached = ownersCache[moduleName] { return cached.codeOwners }
    
    let provider = (NSClassFromString("\(moduleName)._CodeOwners") as? CodeOwnersMappingProvider.Type) ?? Missing.self
    writeLock.withLock { ownersCache[moduleName] = provider }
    return provider.codeOwners
}
