import Foundation
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
        guard let location = context.location(of: node, at: .beforeLeadingTrivia, filePathMode: .filePath) else {
            throw CodeOwnersMacroError(message: "Can't find current file location")
        }
        let filePathLiteral = location.file.trimmedDescription
        let filePath = try JSONDecoder().decode(String.self, from: filePathLiteral.data(using: .utf8)!)
        let file = URL(filePath: filePath)
        
        let owners = resolver.codeOwnersOf(file)
        return ExprSyntax(literal: owners)
    }
    
}

private struct CodeOwnersMacroError : Error {
    let message: String
}
