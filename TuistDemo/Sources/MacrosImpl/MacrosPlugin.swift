import SwiftCompilerPlugin
import SwiftSyntaxMacros
import SwiftSyntax

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [CodeOwnersMacro.self]
}
