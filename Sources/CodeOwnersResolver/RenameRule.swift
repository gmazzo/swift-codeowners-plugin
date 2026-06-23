public struct RenameRule : Sendable, ExpressibleByStringLiteral {
    public let regex: String
    public let replacement: String
    
    public init(regex: String, replacement: String) {
        _ = try! Regex(regex) // makes sure it's valid
        self.regex = regex
        self.replacement = replacement
    }
    
    public init?(_ value: String) {
        let parts = value.split(separator: "=", maxSplits: 2)
        guard parts.count == 2 || value.last == "=" else { return nil }
        
        self.init(regex: "\(parts[0])", replacement: parts.count == 2 ? "\(parts[1])" : "")
    }
    
    public init(stringLiteral value: String) {
        self.init(value)!
    }
}
