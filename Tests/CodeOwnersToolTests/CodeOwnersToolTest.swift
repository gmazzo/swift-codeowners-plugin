import XCTest
import ArgumentParser
@testable import CodeOwnersTool

final class CodeOwnersToolTests: XCTestCase {

    private let tempDirectory =
        FileManager.default.temporaryDirectory.appendingPathComponent("CodeOwnersToolTests")

    func testCommandProducesExpectedOutout() async throws {
        try prepareScenario()
        defer { try? FileManager.default.deleteRecursively(at: tempDirectory) }
        let expectedOutput = tempDirectory.appendingPathComponent("GeneratedSources/_CodeOwners.swift")
        
        let tool = try CodeOwnersTool.parse([
            tempDirectory.appendingPathComponent("Sources").path,
            "-r", tempDirectory.path,
            "-c", tempDirectory.appendingPathComponent("CODEOWNERS").path,
            "-o", expectedOutput.path
        ])

        try tool.run()
        
        let content = try String(contentsOf: expectedOutput, encoding: .utf8)
        XCTAssertEqual("""
        import CodeOwnersCore

        extension Bar : HasCodeOwners {
            static let codeOwners: Set<String> = ["bar-devs"]
            var codeOwners: Set<String> { get { return Bar.codeOwners } }
        }

        extension Foo : HasCodeOwners {
            static let codeOwners: Set<String> = ["foo-devs"]
            var codeOwners: Set<String> { get { return Foo.codeOwners } }
        }

        """, content)
    }

    private func prepareScenario() throws {
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
