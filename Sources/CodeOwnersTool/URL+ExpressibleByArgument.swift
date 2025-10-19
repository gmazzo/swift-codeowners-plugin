import Foundation
import ArgumentParser

#if $RetroactiveAttribute
extension URL: @retroactive ExpressibleByArgument {}
#else
extension URL: ExpressibleByArgument {}
#endif

extension URL {

    public init?(argument: String) { self.init(fileURLWithPath: argument) }

}
