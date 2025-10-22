import Foundation
import ArgumentParser
import CodeOwners
import SwiftParser

let toolDefaults: (root: URL, codeOwnersFile: URL) = findCodeOwnersFile()

@main
struct CodeOwnersTool: AsyncParsableCommand {

    static let configuration: CommandConfiguration = .init(
        commandName: "swift-codeowners",
        abstract: "Generates code ownership information into Swift files"
    )

    @Argument(help: "The Swift source files to process")
    var sources: [URL]

    @Option(name: [.long, .customShort("r")], help: "The root directory where the CODEOWNERS file patterns are based from.")
    var codeOwnersRoot: URL = toolDefaults.root

    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: URL = toolDefaults.codeOwnersFile

    @Option(name: .shortAndLong, help: "The path to store the generated output CodeOwners attribution file")
    var outputFile: URL =
        FileManager.default.pwd.appendingPathComponent("GeneratedSources/CodeOwners.swift")

    @Flag(name: .shortAndLong, help: "Enable verbose output for debugging purposes.")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Suppress non-error output.")
    var quiet: Bool = false

    func run() throws {
        let fm = FileManager.default

        if (quiet && verbose) {
            print("Cannot use --quiet and --verbose flags together.", to: &stdErr)
            return
        }
        if (sources.isEmpty) {
            print("No source files provided.", to: &stdErr)
            return
        }
        if (!fm.fileExists(atPath: codeOwnersFile.path)) {
            print("CODEOWNERS file not found at path: \(codeOwnersFile.path).", to: &stdErr)
            return
        }

        let codeOwnersContent = try String(contentsOf: codeOwnersFile, encoding: .utf8)
        let codeOwners = CodeOwners.parse(file: codeOwnersContent)

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
    
    private func asLiteral(owner: Owner) -> String {
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
        let collector = TypesCollector(viewMode: .sourceAccurate)
        collector.walk(swiftFile)
        return collector.rootTypes
    }
    
    private func generateContent(_ mappings: [Substring: Set<String>]) -> String {
        var content = """
            import CodeOwnersAPI

            internal class _CodeOwners : CodeOwnersMappingProvider {
                static let codeOwners: [Substring: Set<String>]? = [
            
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

private func findCodeOwnersFile() -> (root: URL, codeOwnersFile: URL) {
    let fm = FileManager.default
    let pwd = fm.pwd
    let roots = [ pwd, fm.gitRoot ].compactMap { $0 }
    let candidates = [
        "CODEOWNERS",
        ".github/CODEOWNERS",
        ".gitlab/CODEOWNERS",
        "docs/CODEOWNERS",
    ]

    return roots
    .flatMap { root in candidates.map { path in (root: root, codeOwnersFile: root.appendingPathComponent(path)) } }
    .filter { fm.fileExists(atPath: $0.codeOwnersFile.path) }
    .first ?? (root: pwd, codeOwnersFile: pwd.appendingPathComponent("CODEOWNERS"))
}
