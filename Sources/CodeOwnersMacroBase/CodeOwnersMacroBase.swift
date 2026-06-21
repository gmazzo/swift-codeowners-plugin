import Foundation
import PathKit
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import CodeOwnersResolver

public protocol CodeOwnersMacroBase: ExpressionMacro {
    static var fileContent: String { get }
    static var root: String { get }
    static var renames: [RenameRule] { get }
    static var verbose: Bool { get }
}

public extension CodeOwnersMacroBase {
    
    static var renames: [RenameRule] { [] }
    
    static var verbose: Bool { false }
    
}

nonisolated(unsafe) private var resolverCache: [String: CodeOwnersResolver] = [:]

extension CodeOwnersMacroBase {

    public static func expansion(
        of node: some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let resolver = try resolver()
        let location = try resolveFilePath(of: node, in: context)
        
        let owners = resolver.codeOwnersOf(location)
        
        if (verbose) {
            let relativePath = location.relativePathTo(resolver.root)
            
            context.diagnose(Diagnostic(node: node, message: CodeOwnersMacroError(
                """
                CodeOwners resolution: \(owners?.description ?? "<not matched>") (for: \(relativePath))
                  root: \(resolver.root)
                """,
                "ResolvedCodeOwners",
                .note
            )))
        }
        
        return ExprSyntax(literal: owners)
    }
    
    private static func resolver() throws -> CodeOwnersResolver {
        let cacheKey = "\(type(of: Self.self))"
        if let resolver = resolverCache[cacheKey] { return resolver }
        
        let resolver = try resolveCodeOwners(
            fileContent: self.fileContent,
            root: Path(self.root),
            renames: self.renames
        )
        resolverCache[cacheKey] = resolver
        return resolver
    }
    
    private static func resolveFilePath(
        of node: some SyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> Path {
        guard let location = context.location(of: node, at: .beforeLeadingTrivia, filePathMode: .filePath) else {
            throw CodeOwnersMacroError("Can't find current file location", "UnknownFilePath")
        }
        
        let file = location.file.trimmedDescription
        let unwrapped = file[file.index(file.startIndex, offsetBy: 1) ..< file.index(file.endIndex, offsetBy: -1)]
        return Path("\(unwrapped)")
    }
    
}

private struct CodeOwnersMacroError : Error, DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
    
    init(_ message: String, _ messageId: String, _ severity: DiagnosticSeverity = .error) {
        self.message = message
        self.diagnosticID = MessageID(domain: "CodeOwnersMacro", id: messageId)
        self.severity = severity
    }
    
}
