import SwiftSyntax

class TypesCollector: SyntaxVisitor {
    var types: Set<String> = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
   }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.name.text, node.modifiers)
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        return visit(node.extendedType.trimmedDescription, node.modifiers)
    }
    
    private func visit(_ name: String, _ modifiers: DeclModifierListSyntax) -> SyntaxVisitorContinueKind {
        if !modifiers.contains(where: { $0.name.text == "private" }) {
            types.insert(name)
        }
        return .skipChildren
    }

}
