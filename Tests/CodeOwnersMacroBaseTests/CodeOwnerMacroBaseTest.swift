import Testing
import PathKit
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import CodeOwnersResolver
@testable import CodeOwnersMacroBase

@Suite("#codeOwners macro test", .serialized)
struct CodeOwnersMacrosTest {
    
    class CodeOwnersMacroTestImpl : CodeOwnersMacroBase {
        
        static let fileContent = """
            /foo/   @foo-devs
            /bar/   @bar-devs
            """
        
        static let relativePath = "."
        
        static let verbose = true
        
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
          diagnostics: [ .init(
            message: """
                CodeOwners resolution: \(params.expectedOwners?.description ?? "<not matched>") (for: \(params.file))
                  root: .
                """,
            line: 1,
            column: 28,
            severity: .note
          ) ],
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
