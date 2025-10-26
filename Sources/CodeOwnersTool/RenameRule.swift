import Foundation
import ArgumentParser

struct RenameRule: ExpressibleByArgument {
    let regex: Regex<Substring>
    let replacement: Substring
    
    init?(argument: String) {
        let parts = argument.split(separator: "=", maxSplits: 2)
        guard parts.count == 2 || argument.last == "=" else { return nil }
        self.regex = try! Regex("\(parts[0])")
        self.replacement = parts.count == 2 ? parts[1] : ""
    }

}
