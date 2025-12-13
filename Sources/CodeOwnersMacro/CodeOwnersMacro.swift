import Foundation
import PathKit
import SwiftSyntax
import SwiftSyntaxMacros
import CodeOwnersResolver

public protocol CodeOwnersMacroBase: ExpressionMacro {
    static var resolver: CodeOwnersResolver { get }
}

extension CodeOwnersMacroBase {
    
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let file = context.location(of: node, at: .afterLeadingTrivia, filePathMode: .filePath)?.file else {
            throw CodeOwnersMacroError(message: "Can't find current file location")
        }
        
        let filePath = Path(stringLiteral: file.description)
        let owners = resolver.codeOwnersOf(filePath)
        return ExprSyntax(literal: owners)
    }
    
}

private struct CodeOwnersMacroError : Error {
    let message: String
}
