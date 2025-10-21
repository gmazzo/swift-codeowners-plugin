import Testing
import Foundation
@testable import CodeOwnersTool

private let Default = "<#default#>"

@Suite("CodeOwners Tool") struct CodeOwnersToolTest {

    struct Params : Hashable {
        var customProtocol: String? = Default
        var customImport: String? = Default
    }

    @Test("command produces expected output", arguments: [
        Params(),
        Params(customProtocol: "MyProtocol", customImport: "MyModule"),
        Params(customImport: "MyModule"),
        Params(customProtocol: "MyProtocol"),
        Params(customProtocol: nil, customImport: nil),
    ])
    func commandProducesExpectedOutput(params: Params) async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CodeOwnersToolTests_\(params.hashValue)")

        try prepareScenario(tempDirectory)
        defer { try? FileManager.default.deleteRecursively(at: tempDirectory) }
        let expectedOutput = tempDirectory.appendingPathComponent("GeneratedSources/_CodeOwners.swift")

        var args = [
            tempDirectory.appendingPathComponent("Sources").path, "-v",
            "-r", tempDirectory.path,
            "-c", tempDirectory.appendingPathComponent("CODEOWNERS").path,
            "-o", expectedOutput.path
        ]
        if params.customProtocol != Default {
            args += params.customProtocol.map { ["--protocol", $0] } ?? ["--no-protocol"]
        }
        if params.customImport != Default {
            args += params.customImport.map { ["--import", $0] } ?? ["--no-import"]
        }

        let tool = try CodeOwnersTool.parse(args)
        try tool.run()

        let importValue = params.customImport.map { "import \($0 == Default ? "CodeOwnersCore" : $0)\n" } ?? ""
        let protocolValue = params.customProtocol.map { " : \($0 == Default ? "HasCodeOwners" : $0)" } ?? ""

        let content = try String(contentsOf: expectedOutput, encoding: .utf8)
        #expect(content == """
                           \(importValue)
                           extension Bar\(protocolValue) {
                               static let codeOwners: Set<String> = ["bar-devs"]
                               var codeOwners: Set<String> { get { return Bar.codeOwners } }
                           }

                           extension Foo\(protocolValue) {
                               static let codeOwners: Set<String> = ["foo-devs"]
                               var codeOwners: Set<String> { get { return Foo.codeOwners } }
                           }

                           """)
    }

    private func prepareScenario(_ tempDirectory: URL) throws {
        let sources = tempDirectory.appendingPathComponent("Sources")

        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        try "struct Foo {}".write(to: sources.appendingPathComponent("Foo.swift"), atomically: true, encoding: .utf8)
        try "class Bar {}".write(to: sources.appendingPathComponent("Bar.swift"), atomically: true, encoding: .utf8)
        try """
            Foo*   @foo-devs
            Bar*   @bar-devs
            """.write(to: tempDirectory.appendingPathComponent("CODEOWNERS"), atomically: true, encoding: .utf8)
    }

}
