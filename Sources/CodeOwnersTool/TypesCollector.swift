import SwiftSyntax

class TypesCollector: SyntaxVisitor {
    var types: Set<String> = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        types.insert(node.name.text)
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        types.insert(node.name.text)
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        types.insert(node.name.text)
        return .skipChildren
    }

}
