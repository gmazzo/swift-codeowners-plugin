import SwiftSyntax

class TypesCollector: SyntaxVisitor {
    var rootTypes: Set<Substring> = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        return node.parent?.kind != .memberBlockItem ? visit(node.name.text, node.modifiers) : .skipChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.extendedType.trimmedDescription, node.modifiers)
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren // protocols by itself can't be instantiated
    }
    
    private func visit(_ name: String, _ modifiers: DeclModifierListSyntax) -> SyntaxVisitorContinueKind {
        if !modifiers.contains(where: { $0.name.text == "private" }) {
            let parts = name.split(separator: ".", maxSplits: 2) // we only care about the top level type
            
            rootTypes.insert(parts[0])
        }
        return .skipChildren
    }

}
