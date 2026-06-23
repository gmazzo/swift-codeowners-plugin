import ArgumentParser

extension RenameRule: ExpressibleByArgument {
    
    public init?(argument: String) {
        self.init(argument)
    }

}
