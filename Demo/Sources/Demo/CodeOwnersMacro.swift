@freestanding(expression)
public macro codeOwners() -> Set<String>? = #externalMacro(module: "Macros", type: "CodeOwnersMacro")
