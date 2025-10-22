import Foundation

nonisolated(unsafe) private var ownersCache: [String: Cached] = [:]
private let writeLock = NSLock()

private struct Cached {
    let owners: Set<String>?
}

public protocol CodeOwnersProvider {
    static var codeOwners: Set<String> { get }
}

public func codeOwnersOf(_ obj: Any) -> Set<String>? {
    let typeName = "\(String(reflecting: type(of: obj)))".deletingSuffix(".Type")
    if let cached = ownersCache[typeName] {
        return cached.owners
    }
    
    let owners = (NSClassFromString("\(typeName)_CodeOwners") as? CodeOwnersProvider.Type)?.codeOwners
    writeLock.withLock {
        ownersCache[typeName] = Cached(owners: owners)
    }
    return owners
}

private extension String {
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
    
}
