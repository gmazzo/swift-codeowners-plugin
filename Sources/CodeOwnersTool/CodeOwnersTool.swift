import Foundation
import ArgumentParser
import CodeOwners
import SwiftParser

private let defaults = try! Inputs.lookupAlways().resolve()

@main
struct CodeOwnersTool: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "swift-codeowners",
        abstract: "Generates code ownership information into Swift files"
    )
    
    @Argument(help: "The Swift source files to process")
    var sources: [URL]
    
    @Option(name: [.long, .customShort("r")], help: "The root directory where the CODEOWNERS file patterns are based from.")
    var codeOwnersRoot: URL = defaults.codeOwnersRoot
    
    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: URL = defaults.codeOwnersFile
    
    @Option(name: .shortAndLong, help: "The path to store the generated output CodeOwners attribution file")
    var outputFile: URL = FileManager.default.currentDirectory.appendingPathComponent("GeneratedSources/CodeOwners.swift")
    
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
        
        let fm = FileManager.default
        if (!fm.fileExists(atPath: codeOwnersFile.path)) {
            print("CODEOWNERS file not found at path: \(codeOwnersFile.path).", to: &stdErr)
            return
        }
        
        let codeOwners = try parseCodeOwners(codeOwnersFile)
        
        var mappings: [Substring: Set<String>] = [:]
        
        try fm.walkFiles(at: sources) { source in
            if source.pathExtension != "swift" { return }
            if verbose { print("Processing source file: \(source.path)") }
            
            guard let relativePath = source.relativePathTo(codeOwnersRoot) else { return }
            guard let owners = codeOwners.codeOwner(pattern: relativePath)?.owners.map(asLiteral) else { return }
            
            do {
                for typeName in try collectTypes(from: source) {
                    mappings[typeName] = (mappings[typeName] ?? []).union(owners)
                }
            } catch {
                print("warning: Failed to process source file '\(relativePath)': \(error)", to: &stdErr)
            }
        }
        
        let content = generateContent(mappings)
        try fm.createDirectory(at: outputFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try content.write(to: outputFile, atomically: true, encoding: .utf8)
        
        if (!quiet) {
            print("Generated CodeOwners attribution for \(mappings.count) types at: \(outputFile.path)")
        }
    }
    
    private func parseCodeOwners(_ codeOwnersFile: URL) throws -> CodeOwners {
        let content = try String(contentsOf: codeOwnersFile, encoding: .utf8)
        let parsed = CodeOwners.parse(file: content)
        if renames.isEmpty { return parsed }
        
        let renamedLines = parsed.lines.map { line in
            switch line {
            case .codeOwner(let codeOwner):
                let renamedOwners = codeOwner.owners.map { owner in
                    var literal = asLiteral(owner)
                    for rename in renames {
                        literal = literal.replacing(rename.regex, with: rename.replacement)
                    }
                    return Owner.user(UserIdentifier.userName(literal)) // we really don't care on the kind of owner
                }
                
                return CodeOwnerLine.codeOwner(CodeOwner(pattern: codeOwner.pattern, owners: renamedOwners))
                
            default:
                return line
            }
        }
        return CodeOwners(lines: renamedLines)
    }
    
    private func asLiteral(_ owner: Owner) -> String {
        switch owner {
        case .user(let userId):
            switch userId {
            case .userName(let name): return "\(name)"
            case .email(let email): return "\(email)"
            }
        case .team(let teamId):
            return "\(teamId.organization)/\(teamId.name)"
        }
    }
    
    private func collectTypes(from source: URL) throws -> Set<Substring> {
        let swiftFileContent = try String(contentsOf: source, encoding: .utf8)
        let swiftFile = Parser.parse(source: swiftFileContent)
        let collector = TypesCollector(viewMode: .fixedUp)
        collector.walk(swiftFile)
        return collector.rootTypes
    }
    
    private func generateContent(_ mappings: [Substring: Set<String>]) -> String {
        if mappings.isEmpty { return "" }
        
        var content = """
        import CodeOwnersAPI
        
        internal class _CodeOwners : CodeOwnersMappingProvider {
            static let codeOwners: [Substring: CodeOwners]? = [
        
        """
        for typeName in mappings.keys.sorted() {
            let owners = mappings[typeName]!.sorted().map { "\"\($0)\"" }.joined(separator: ", ")
            
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
