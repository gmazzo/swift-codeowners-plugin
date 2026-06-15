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
        of node: some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let location = context.location(of: node, at: .beforeLeadingTrivia, filePathMode: .filePath) else {
            throw CodeOwnersMacroError(message: "Can't find current file location")
        }
        let filePath = location.file.trimmedDescription
        let file = try JSONDecoder().decode(String.self, from: filePath.data(using: .utf8)!)
        
        let owners = resolver.codeOwnersOf(Path(file))
        return ExprSyntax(literal: owners)
    }
    
}

private struct CodeOwnersMacroError : Error {
    let message: String
}
