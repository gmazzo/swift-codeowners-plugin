import Testing
import Foundation
@testable import CodeOwnersTool

private let Default = "<#default#>"

@Suite("CodeOwners Tool") struct CodeOwnersToolTest {

    @Test("command produces expected output")
    func commandProducesExpectedOutput() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("CodeOwnersToolTests")

        try prepareScenario(tempDirectory)
        defer { try? FileManager.default.deleteRecursively(at: tempDirectory) }
        let expectedOutput = tempDirectory.appendingPathComponent("GeneratedSources/_CodeOwners.swift")

        let tool = try CodeOwnersTool.parse([
            tempDirectory.appendingPathComponent("Sources").path, "-v",
            "-r", tempDirectory.path,
            "-c", tempDirectory.appendingPathComponent("CODEOWNERS").path,
            "-o", expectedOutput.path
        ])
        try tool.run()

        let content = try String(contentsOf: expectedOutput, encoding: .utf8)
        #expect(content ==
           """
           import CodeOwnersAPI

           internal class _CodeOwners : CodeOwnersMappingProvider {
               static let codeOwners: [Substring: Set<String>]? = [
                   "Bar": ["bar-devs"],
                   "Foo": ["foo-devs"],
                   "topLevelFunc": ["toplevel-dev"],
               ]
           }

           """)
    }

    private func prepareScenario(_ tempDirectory: URL) throws {
        let sources = tempDirectory.appendingPathComponent("Sources")

        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        try "struct Foo {}".write(to: sources.appendingPathComponent("Foo.swift"), atomically: true, encoding: .utf8)
        try "class Bar {}".write(to: sources.appendingPathComponent("Bar.swift"), atomically: true, encoding: .utf8)
        try "func topLevelFunc {}".write(to: sources.appendingPathComponent("TopLevelFunc.swift"), atomically: true, encoding: .utf8)
        try """
            Foo*                @foo-devs
            Bar*                @bar-devs
            TopLevelFunc.swift  @toplevel-dev
            """.write(to: tempDirectory.appendingPathComponent("CODEOWNERS"), atomically: true, encoding: .utf8)
    }

}
