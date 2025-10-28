import Foundation
import ArgumentParser

extension RenameRule: ExpressibleByArgument {
    
    public init?(argument: String) {
        let parts = argument.split(separator: "=", maxSplits: 2)
        guard parts.count == 2 || argument.last == "=" else { return nil }
        
        self.init(regex: "\(parts[0])", replacement: parts.count == 2 ? "\(parts[1])" : "")
    }

}
