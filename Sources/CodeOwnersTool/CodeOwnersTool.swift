import PathKit
import ArgumentParser
import CodeOwners
import CodeOwnersResolver
import SwiftParser
import PathKit

private let defaults = try! Inputs.lookupAlways().resolve()

@main
struct CodeOwnersTool: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "swift-codeowners",
        abstract: "Generates code ownership information into Swift files"
    )
    
    @Argument(help: "The Swift source files to process")
    var sources: [Path]
    
    @Option(name: [.long, .customShort("r")], help: "The root directory where the CODEOWNERS file patterns are based from.")
    var codeOwnersRoot: Path = Path(defaults.codeOwnersRoot)
    
    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: Path = Path(defaults.codeOwnersFile)
    
    @Option(name: .shortAndLong, help: "The path to store the generated output CodeOwners attribution file")
    var outputFile: Path = Path.current + "GeneratedSources/CodeOwners.swift"
    
    @Option(name: [.customLong("rename")], help: "Regex pattern to rename ownership names, in <regex>=<replacement> format)")
    var renames: [RenameRule] = defaults.renames
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Enable verbose output for debugging purposes.")
    var verbose: Bool = defaults.verbose
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Suppress non-error output.")
    var quiet: Bool = defaults.quiet
    
    func run() throws {
        if (quiet && verbose) {
            print("Cannot use --quiet and --verbose flags together.", to: &stdErr)
            return
        }
        if (sources.isEmpty) {
            print("No source files provided.", to: &stdErr)
            return
        }
        
        if (!codeOwnersFile.isFile) {
            print("CODEOWNERS file not found: \(codeOwnersFile).", to: &stdErr)
            return
        }
        
        let resolver = try resolveCodeOwners(
            file: codeOwnersFile,
            root: codeOwnersRoot,
            renames: renames
        )
        
        var mappings: [Substring: [String]] = [:]
        
        for sourceFile in try sources.flatMap({ $0.isDirectory ? try $0.recursiveChildren() : [$0] }) {
            if (!quiet && !sourceFile.exists) { stdErr.write("Skipping input source because does not exists: \(sourceFile)"); continue }
            if sourceFile.extension != "swift" { continue }
            if verbose { print("Processing source file: \(sourceFile)") }
            
            guard let owners = resolver.codeOwnersOf(sourceFile) else { continue }
            
            do {
                for typeName in try collectTypes(from: sourceFile) {
                    mappings[typeName] = (mappings[typeName] ?? []) + owners
                }

            } catch {
                print("warning: Failed to process source file '\(sourceFile)': \(error)", to: &stdErr)
            }
        }
        
        let content = generateContent(mappings)
        try outputFile.parent().mkpath()
        try outputFile.write(content)
        
        if (!quiet) {
            print("Generated CodeOwners attribution for \(mappings.count) types at: \(outputFile)")
        }
    }

    private func collectTypes(from source: Path) throws -> Set<Substring> {
        let swiftFileContent = try source.read(.utf8)
        let swiftFile = Parser.parse(source: swiftFileContent)
        let collector = TypesCollector(viewMode: .fixedUp)
        collector.walk(swiftFile)
        return collector.rootTypes
    }
    
    private func generateContent(_ mappings: [Substring: [String]]) -> String {
        if mappings.isEmpty { return "" }
        
        var content = """
        import CodeOwnersAPI
        
        internal class _CodeOwners : CodeOwnersMappingProvider {
            static let codeOwners: [Substring: CodeOwners]? = [
        
        """
        for typeName in mappings.keys.sorted() {
            let owners = mappings[typeName]!.distinct().map { "\"\($0)\"" }.joined(separator: ", ")
            
            content += "        \"\(typeName)\": [\(owners)],\n"
        }
        content += """
        ]
    }
    
    """
        return content
    }
}

private func asRenameRule(regex: String, replace: String) -> RenameRule {
    let argument = "\(regex)=\(replace)"
    if let rule = RenameRule(argument: argument) { return rule }
    fatalError("Rename rule should be in the <regex>=<replacement> format: \(argument)")
}

private extension Sequence where Iterator.Element: Hashable {
  func distinct() -> [Iterator.Element] {
    var seen: Set<Iterator.Element> = []
    return filter { seen.insert($0).inserted }
  }
}
