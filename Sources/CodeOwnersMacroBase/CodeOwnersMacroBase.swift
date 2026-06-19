import Foundation
import PathKit
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import CodeOwnersResolver

public protocol CodeOwnersMacroBase: ExpressionMacro {
    static var resolver: CodeOwnersResolver { get }
    static var verbose: Bool { get }
}

extension CodeOwnersMacroBase {
    
    public static func expansion(
        of node: some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let location = context.location(of: node, at: .beforeLeadingTrivia, filePathMode: .filePath) else {
            throw CodeOwnersMacroError(message: "Can't find current file location")
        }
        let filePath = location.file.trimmedDescription
        let file = try JSONDecoder().decode(String.self, from: filePath.data(using: .utf8)!)
        let path = Path(file)
        let owners = resolver.codeOwnersOf(path)
        
        if (verbose) {
            let relativePath = path.relativePathTo(resolver.root) ?? file
            
            context.diagnose(Diagnostic(node: node, message: Message(
                message: """
                    CodeOwners resolution: \(owners?.description ?? "<not matched>") (for: \(relativePath))
                      root: \(resolver.root)
                    """,
                diagnosticID: MessageID(domain: "CodeOwnersMacro", id: "ResolvedCodeOwners"),
                severity: .note
            )))
        }
        
        return ExprSyntax(literal: owners)
    }
    
}

private struct CodeOwnersMacroError : Error {
    let message: String
}

private struct Message : DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}
