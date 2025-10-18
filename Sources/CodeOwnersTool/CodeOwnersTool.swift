import Foundation
import ArgumentParser
import CodeOwners
import SwiftParser

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

    func run() throws {
        let fm = FileManager.default

        if (sources.isEmpty) {
            fatalError("No source files provided.")
        }
        if (!fm.fileExists(atPath: codeOwnersFile.path)) {
            fatalError("CODEOWNERS file not found at path: \(codeOwnersFile.path).")
        }

        let codeOwnersContent = try String(contentsOf: codeOwnersFile, encoding: .utf8)
        let codeOwners = CodeOwners.parse(file: codeOwnersContent)

        var content =
            """
            import CodeOwnersCore

            """

        try fm.walkFiles(at: sources) { source in
            let relativePath = source.relativePathTo(codeOwnersRoot)
            let owners = codeOwners.codeOwner(pattern: relativePath)?.owners.map(asLiteral).joined(separator: ", ")

            for typeName in try collectTypes(from: source) {
                content +=
                    """

                    extension \(typeName) : HasCodeOwners {
                        static let codeOwners: Set<String> = [\(owners ?? "")]
                        var codeOwners: Set<String> { get { return \(typeName).codeOwners } }
                    }

                    """
            }
        }

        try fm.createDirectory(at: outputFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try content.write(to: outputFile, atomically: true, encoding: .utf8)
    }
    
    private func asLiteral(owner: Owner) -> String {
        switch owner {
            case .user(let userId):
                switch userId {
                case .userName(let name): return "\"\(name)\""
                case .email(let email): return "\"\(email)\""
                }
            case .team(let teamId):
                return "\"\(teamId.organization)/\(teamId.name)\""
            }
    }

    private func collectTypes(from source: URL) throws -> [String] {
        let swiftFileContent = try String(contentsOf: source, encoding: .utf8)
        let swiftFile = Parser.parse(source: swiftFileContent)
        let collector = TypesCollector(viewMode: .sourceAccurate)
        collector.walk(swiftFile)
        return collector.types
    }

}
