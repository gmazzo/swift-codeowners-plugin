import Foundation
import ArgumentParser

#if $RetroactiveAttribute
extension URL: @retroactive ExpressibleByArgument {}
#else
extension URL: ExpressibleByArgument {}
#endif

extension URL {

    public init?(argument: String) { self.init(fileURLWithPath: argument) }

    func relativePathTo(_ other: URL) -> String {
        let fromComponents = self.standardized.pathComponents
        let toComponents = other.standardized.pathComponents

        var index = 0
        while index < fromComponents.count &&
              index < toComponents.count &&
              fromComponents[index] == toComponents[index] {
            index += 1
        }

        var relativeComponents: [String] = []

        for _ in index..<toComponents.count {
            relativeComponents.append("..")
        }

        relativeComponents.append(contentsOf: fromComponents[index...])

        return relativeComponents.joined(separator: "/")
    }

}
