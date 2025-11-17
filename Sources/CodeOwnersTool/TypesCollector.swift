import SwiftSyntax

class TypesCollector: SyntaxVisitor {
    var finalTypes: Set<Substring> = []
    var extensibleTypes: Set<Substring> = []
    var extensionTypes: Set<Substring> = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        !node.isGeneric ? visit(node, &finalTypes) : visit(node, &extensibleTypes)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        node.inheritanceClause == nil && !node.isGeneric ? visit(node, &finalTypes) : visit(node, &extensibleTypes)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        !node.isGeneric ? visit(node, &finalTypes) : visit(node, &extensibleTypes)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        node.isTopLevel ? visit(node, &extensibleTypes) : .skipChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        visit(node.extendedType.trimmedDescription, node, &extensionTypes)
    }
    
    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        .skipChildren // protocols by itself can't be instantiated
    }

    private func visit<Node : WithModifiersSyntax>(_ node: Node, _ into: inout Set<Substring>) -> SyntaxVisitorContinueKind where Node : NamedDeclSyntax {
        visit(node.name.text, node, &into)
    }

    private func visit<Node : WithModifiersSyntax>(_ name: String, _ node: Node, _ into: inout Set<Substring>) -> SyntaxVisitorContinueKind {
        if !node.isPrivate {
            let parts = name.split(separator: ".", maxSplits: 2) // we only care about the top level type
            
            into.insert(parts[0])
        }
        return .skipChildren
    }

}

private extension WithGenericParametersSyntax {

    var isGeneric: Bool { get { genericParameterClause != nil } }

}

private extension FunctionDeclSyntax {

    var isTopLevel: Bool { get { parent?.kind != .memberBlockItem } }

}

private extension WithModifiersSyntax {

    private func contains(_ modifier: String) -> Bool {
        return modifiers.contains(where: { $0.name.text == modifier })
    }

    var isPrivate: Bool { get { contains("private" ) } }

}
