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
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Enable hybrid attribution approach (static for final types, and dynamic for classes and generic structs.")
    var hybridAttribution: Bool = defaults.hybridAttribution

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
        
        let ownership = await processSources(resolver)
        let content = generateContent(ownership)
        try outputFile.parent().mkpath()
        try outputFile.write(content)
        
        if (!quiet) {
            let count = ownership.finalTypes.count + ownership.extensionTypes.count + ownership.extensibleTypes.count
            
            print("Generated CodeOwners attribution for \(count) types at: \(outputFile)")
        }
    }
    
    private func processSources(_ resolver: CodeOwnersResolver) async -> Ownership {
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
            
            var ownership = Ownership()
            for await result in (group.compactMap { $0 }) {
                computeOwnership(result.finalTypes, result.owners, &ownership.finalTypes)
                computeOwnership(result.extensibleTypes, result.owners, &ownership.extensibleTypes)
                computeOwnership(result.extensionTypes, result.owners, &ownership.extensionTypes)
            }
            return ownership
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
        return FileResult(
            finalTypes: collector.finalTypes,
            extensibleTypes: collector.extensibleTypes,
            extensionTypes: collector.extensionTypes,
            owners: owners
        )
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
    
    private func computeOwnership(_ types: Set<Substring>, _ owners: [String], _ into: inout [Substring: [String]]) {
        for typeName in types {
            into[typeName] = (into[typeName] ?? []) + owners
        }
    }
    
    private func generateContent(_ ownership: Ownership) -> String {
        var content = """
        import CodeOwnersAPI
        
        """
        
        if !ownership.extensibleTypes.isEmpty {
            content += """
            
            internal class _CodeOwners : CodeOwnersMappingProvider {
                static let codeOwners: [Substring: CodeOwners]? = [
            
            """
            generateMappingContent(ownership.extensibleTypes, ownership.extensionTypes, &content)
            if (!hybridAttribution) {
                generateMappingContent(ownership.finalTypes, ownership.extensionTypes, &content)
            }
            content += """
                ]
            }
            
            """
        }
        if (hybridAttribution) {
            generateStaticContent(ownership.finalTypes, ownership.extensionTypes, &content)
        }
        
        return content
    }
    
    private func generateMappingContent(_ types: [Substring: [String]], _ extensionTypes: [Substring: [String]], _ into: inout String) {
        for typeName in types.keys.sorted() {
            let owners = ownersLiteral(
                main: types[typeName],
                fromExtension: extensionTypes[typeName]
            )
            
            into += "        \"\(typeName)\": [\(owners)],\n"
        }
    }
    
    private func generateStaticContent(_ types: [Substring: [String]], _ extensionTypes: [Substring: [String]], _ into: inout String) {
        for typeName in types.keys.sorted() {
            let owners = ownersLiteral(
                main: types[typeName],
                fromExtension: extensionTypes[typeName]
            )
            
            into += """
            
            extension \(typeName) : HasCodeOwners {
                 public static let codeOwners: CodeOwners = [\(owners)]
            }
            
            """
        }
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

private func ownersLiteral(main: [String]?, fromExtension: [String]?) -> String {
    ((main ?? []) + (fromExtension ?? []))
        .distinct()
        .map { "\"\($0)\"" }
        .joined(separator: ", ")
}

private struct FileResult : Sendable {
    let finalTypes: Set<Substring>
    let extensibleTypes: Set<Substring>
    let extensionTypes: Set<Substring>
    let owners: [String]
}

private struct Ownership {
    var finalTypes: [Substring: [String]] = [:]
    var extensibleTypes: [Substring: [String]] = [:]
    var extensionTypes: [Substring: [String]] = [:]
}
