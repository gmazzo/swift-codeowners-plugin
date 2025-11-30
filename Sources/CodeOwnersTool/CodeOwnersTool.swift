import ArgumentParser
import CodeOwners
import CodeOwnersResolver
import SwiftParser
import PathKit

private typealias FileResult = (rootTypes: Set<Substring>, extensionTypes: Set<Substring>, owners: [String])
private typealias TypeOwnership = (main: [String], fromExtension: [String])

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
    
    func run() async throws {
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
        
        let mappings = await processSources(resolver)
        let content = generateContent(mappings)
        try outputFile.parent().mkpath()
        try outputFile.write(content)
        
        if (!quiet) {
            print("Generated CodeOwners attribution for \(mappings.count) types at: \(outputFile)")
        }
    }
    
    private func processSources(_ resolver: CodeOwnersResolver) async -> [Substring: TypeOwnership] {
        await withTaskGroup(of: FileResult?.self) { group in
            for source in sources {
                if (source.isDirectory) {
                    if let sourceFiles = try? source.recursiveChildren() {
                        for sourceFile in sourceFiles {
                            group.addTask { processFile(resolver, sourceFile) }
                        }
                    }
                    
                } else {
                    group.addTask { processFile(resolver, source) }
                }
                
            }
            
            var mappings: [Substring: TypeOwnership] = [:]
            for await (rootTypes, extensionTypes, owners) in (group.compactMap { $0 }) {
                for typeName in rootTypes {
                    let current = mappings[typeName] ?? ([], [])
                    
                    mappings[typeName] = (current.main + owners, current.fromExtension)
                }
                for typeName in extensionTypes {
                    let current = mappings[typeName] ?? ([], [])
                    
                    mappings[typeName] = (current.main, current.fromExtension + owners)
                }
            }
            return mappings
        }
    }
    
    private func processFile(_ resolver: CodeOwnersResolver, _ sourceFile: Path) -> FileResult? {
        if (!quiet && !sourceFile.exists) {
            stdErr.write("Skipping input source because does not exists: \(sourceFile)")
            return nil
        }
        
        if sourceFile.extension != "swift" { return nil }
        if verbose { print("Processing source file: \(sourceFile)") }
        
        guard let owners: [String] = resolver.codeOwnersOf(sourceFile) else { return nil }
        guard let collector = collectTypes(from: sourceFile) else { return nil }
        return (collector.rootTypes, collector.extensionTypes, owners)
    }

    private func collectTypes(from sourceFile: Path) -> TypesCollector? {
        do {
            let swiftFileContent = try sourceFile.read(.utf8)
            let swiftFile = Parser.parse(source: swiftFileContent)
            let collector = TypesCollector(viewMode: .fixedUp)
            collector.walk(swiftFile)
            return collector
            
        } catch {
            print("warning: Failed to process source file '\(sourceFile)': \(error)", to: &stdErr)
            return nil
        }
    }
    
    private func generateContent(_ mappings: [Substring: TypeOwnership]) -> String {
        if mappings.isEmpty { return "" }
        
        var content = """
        import CodeOwnersAPI
        
        internal class _CodeOwners : CodeOwnersMappingProvider {
            static let codeOwners: [Substring: CodeOwners]? = [
        
        """
        for typeName in mappings.keys.sorted() {
            let ownershipInfo = mappings[typeName]!
            let owners = (ownershipInfo.main + ownershipInfo.fromExtension)
                .distinct()
                .map { "\"\($0)\"" }
                .joined(separator: ", ")
            
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
