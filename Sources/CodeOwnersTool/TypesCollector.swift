import SwiftSyntax

class TypesCollector: SyntaxVisitor {
    var types: [String] = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        types.append(node.name.text)
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        types.append(node.name.text)
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        types.append(node.name.text)
        return .skipChildren
    }

}
