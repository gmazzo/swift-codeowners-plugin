import Testing
import PathKit
@testable import CodeOwnersTool

private let Default = "<#default#>"

@Suite("CodeOwners Tool")
struct CodeOwnersToolTest {
    
    struct Params : Hashable {
        let args: [String]
        let hybrid: Bool
        let ownersBar: String?
        let ownersFoo: String?
        
        init(args: [String], hybrid: Bool = true, ownersBar: String? = nil, ownersFoo: String? = nil) {
            self.args = args
            self.hybrid = hybrid
            self.ownersBar = ownersBar
            self.ownersFoo = ownersFoo
        }
    }

    @Test("command produces expected output", arguments: [
        Params(args: []),
        Params(args: ["--hybrid-attribution"]),
        Params(args: ["--no-hybrid-attribution"], hybrid: false),
        Params(args: ["--rename=o-dev="], ownersFoo: "fos"),
        Params(args: ["--rename=devs=custom"], ownersBar: "bar-custom", ownersFoo: "foo-custom"),
        Params(args: ["--no-hybrid-attribution", "--rename=devs=custom"], hybrid: false, ownersBar: "bar-custom", ownersFoo: "foo-custom"),
    ])
    func commandProducesExpectedOutput(params: Params) async throws {
        let tempDirectory = Path.temporary + "CodeOwnersToolTests_\(params.hashValue)"

        try prepareScenario(tempDirectory)
        defer { try? tempDirectory.delete() }
        let actualOutput = tempDirectory + "GeneratedSources/_CodeOwners.swift"

        let tool = try CodeOwnersTool.parse([
            (tempDirectory + "Sources").string, "-v",
            "-r", tempDirectory.string,
            "-c", (tempDirectory + "CODEOWNERS").string,
            "-o", actualOutput.string
        ] + params.args)
        try await tool.run()

        let expectedContent = params.hybrid ?
           """
           import CodeOwnersAPI

           internal class _CodeOwners : CodeOwnersMappingProvider {
               static let codeOwners: [Substring: CodeOwners]? = [
                   "topLevelFunc": ["toplevel-dev"],
               ]
           }
           
           extension Bar : HasCodeOwners {
                public static let codeOwners: CodeOwners = ["\(params.ownersBar ?? "bar-devs")"]
           }
           
           extension Foo : HasCodeOwners {
                public static let codeOwners: CodeOwners = ["\(params.ownersFoo ?? "foo-devs")"]
           }

           """ :
           """
           import CodeOwnersAPI

           internal class _CodeOwners : CodeOwnersMappingProvider {
               static let codeOwners: [Substring: CodeOwners]? = [
                   "topLevelFunc": ["toplevel-dev"],
                   "Bar": ["\(params.ownersBar ?? "bar-devs")"],
                   "Foo": ["\(params.ownersFoo ?? "foo-devs")"],
               ]
           }

           """
        
        let actualContent = try actualOutput.read(.utf8)
        #expect(expectedContent == actualContent)
    }

    private func prepareScenario(_ tempDirectory: Path) throws {
        let sources = tempDirectory + "Sources"

        try sources.mkpath()
        try (sources + "Foo.swift").write("struct Foo {}")
        try (sources + "Bar.swift").write("class Bar {}")
        try (sources + "TopLevelFunc.swift").write("func topLevelFunc {}")
        try (tempDirectory + "CODEOWNERS").write("""
            Foo*                @foo-devs
            Bar*                @bar-devs
            TopLevelFunc.swift  @toplevel-dev
            """
        )
    }

}
