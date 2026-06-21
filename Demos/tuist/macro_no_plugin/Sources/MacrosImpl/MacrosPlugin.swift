import SwiftCompilerPlugin
import SwiftSyntaxMacros
import CodeOwnersMacroBase
import CodeOwnersResolver

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [CodeOwnersMacro.self]
}

class CodeOwnersMacro: CodeOwnersMacroBase {

    static let fileContent = CODEOWNERS_CONTENT

    static let root = CODEOWNERS_ROOT

    static let renames: [RenameRule] = [
        ["experts", "devs"],
        ["foo\\w+/bar", "bar"]
    ]

    static let verbose = true

}
