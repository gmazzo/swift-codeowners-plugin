import PathKit
import ArgumentParser

#if $RetroactiveAttribute
extension Path: @retroactive ExpressibleByArgument {}
#else
extension Path: ExpressibleByArgument {}
#endif

public extension Path {

    init(argument: String) {
        self.init(argument)
    }

}
