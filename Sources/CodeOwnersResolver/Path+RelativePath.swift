import PathKit

public extension Path {

    // from https://stackoverflow.com/a/48360631/1007772
    func relativePathTo(_ base: Path) -> String {
        // Remove/replace "." and "..", make paths absolute:
        let destComponents = self.url.standardized.pathComponents
        let baseComponents = base.url.standardized.pathComponents
        
        // Find number of common path components:
        var i = 0
        while i < destComponents.count && i < baseComponents.count && destComponents[i] == baseComponents[i] {
            i += 1
        }
        
        // Build relative path:
        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

}
