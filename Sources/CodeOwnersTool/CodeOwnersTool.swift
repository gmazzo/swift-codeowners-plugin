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
    var codeOwnersRoot: URL =
        FileManager.default.gitRoot ?? FileManager.default.pwd

    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: URL =
        FileManager.default.findCodeOwnersFile(atRoot: FileManager.default.gitRoot ?? FileManager.default.pwd)

    @Option(name: .shortAndLong, help: "Output directory where the generated files are written.")
    var outputDirectory: URL =
        FileManager.default.pwd.appendingPathComponent("GeneratedSources")

    func run() throws {
        let fm = FileManager.default

        if (sources.isEmpty) {
            fatalError("No source files provided.")
        }
        if (!fm.fileExists(atPath: codeOwnersFile.path)) {
            fatalError("CODEOWNERS file not found at path: \(codeOwnersFile.path).")
        }

        let codeOwners = CodeOwners.parse(file: codeOwnersFile.path)

        try fm.deleteRecursively(at: outputDirectory)
        try fm.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        try fm.walkFiles(at: sources) { source in
            let relativePath = source.relativePathTo(codeOwnersRoot)
            let owners = codeOwners.codeOwner(pattern: relativePath)?.owners
                .map { "\"\($0)\"" }
                .joined(separator: ", ")

            let content = collectTypes(from: source).map { typeName in
                """
                extension \(typeName) : HasCodeOwners {
                    var codeOwners: Set<String> = [\(owners ?? "")]
                }
                """
            }.joined(separator: "\n\n")

            let baseName = source.deletingPathExtension().lastPathComponent
            let file = outputDirectory.appendingPathComponent("\(baseName)+CodeOwners.swift")
            try content.write(to: file, atomically: true, encoding: .utf8)
        }
    }

    private func collectTypes(from source: URL) -> [String] {
        let swiftFile = Parser.parse(source: source.absoluteString)
        let collector = TypesCollector(viewMode: .sourceAccurate)
        collector.walk(swiftFile)
        return collector.types
    }

}
