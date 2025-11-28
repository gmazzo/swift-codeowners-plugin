import Testing
import PathKit
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import CodeOwnersResolver
@testable import CodeOwnersMacro

@Suite("#codeOwners macro test")
struct CodeOwnersMacrosTest {
    
    class CodeOwnersMacroTestImpl : CodeOwnersMacroBase {
        nonisolated(unsafe) static let resolver = {
            try! resolveCodeOwners(
                fileContent: """
                    /foo/   @foo-devs
                    /bar/   @bar-devs
                    """,
                root: ".",
                renames: []
            )
        }()
    }
    
    @Test(arguments: [
        ("foo/Foo.swift", ["foo-devs"]),
        ("bar/Bar.swift", ["bar-devs"]),
        ("another.swift", nil),
    ])
    func expansionYieldsOwners(params: (file: String, expectedOwners: [String]?)) throws {
        let ownersLiteral = params.expectedOwners?.map { "\"\($0)\"" }.joined(separator: ", ")
        
        assertMacroExpansion(
          """
          let CODEOWNERS: [String] = #codeOwners
          """,
          expandedSource: """
            let CODEOWNERS: [String] = \(ownersLiteral.map { "[\($0)]" } ?? "nil")
            """,
          macroSpecs: [ "codeOwners" : MacroSpec(type: CodeOwnersMacroTestImpl.self) ],
          testFileName: params.file
        ) {
            Issue.record(
                "\($0.message)",
                sourceLocation:
                    SourceLocation(
                        fileID: $0.location.fileID,
                        filePath: $0.location.filePath,
                        line: $0.location.line,
                        column: $0.location.column
                    )
            )
        }
    }
    
}
