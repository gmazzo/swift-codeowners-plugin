import Testing
import PathKit
@testable import CodeOwnersTool

private let Default = "<#default#>"

@Suite("CodeOwners Tool") struct CodeOwnersToolTest {
    
    struct Params : Hashable {
        let args: [String]
        let ownersBar: String?
        let ownersFoo: String?
    }

    @Test("command produces expected output", arguments: [
        Params(args: [], ownersBar: nil, ownersFoo: nil),
        Params(args: ["--rename=devs=custom"], ownersBar: "bar-custom", ownersFoo: "foo-custom"),
        Params(args: ["--rename=o-dev="], ownersBar: nil, ownersFoo: "fos"),
    ])
    func commandProducesExpectedOutput(params: Params) async throws {
        let tempDirectory = Path.temporary + "CodeOwnersToolTests_\(params.hashValue)"

        try prepareScenario(tempDirectory)
        defer { try? tempDirectory.delete() }
        let expectedOutput = tempDirectory + "GeneratedSources/_CodeOwners.swift"

        let tool = try CodeOwnersTool.parse([
            (tempDirectory + "Sources").string, "-v",
            "-r", tempDirectory.string,
            "-c", (tempDirectory + "CODEOWNERS").string,
            "-o", expectedOutput.string
        ] + params.args)
        try await tool.run()

        let content = try expectedOutput.read(.utf8)
        #expect(content ==
           """
           import CodeOwnersAPI

           internal class _CodeOwners : CodeOwnersMappingProvider {
               static let codeOwners: [Substring: CodeOwners]? = [
                   "Bar": ["\(params.ownersBar ?? "bar-devs")"],
                   "Foo": ["\(params.ownersFoo ?? "foo-devs")", "baz-owners"],
                   "topLevelFunc": ["toplevel-dev"],
               ]
           }

           """)
    }

    private func prepareScenario(_ tempDirectory: Path) throws {
        let sources = tempDirectory + "Sources"

        try sources.mkpath()
        try (sources + "Foo.swift").write("struct Foo {}")
        try (sources + "Baz.swift").write("extension Foo {}")
        try (sources + "Bar.swift").write("class Bar {}")
        try (sources + "TopLevelFunc.swift").write("func topLevelFunc {}")
        try (tempDirectory + "CODEOWNERS").write("""
            Foo*                @foo-devs
            Bar*                @bar-devs
            Baz*                @baz-owners
            TopLevelFunc.swift  @toplevel-dev
            """
        )
    }

}
