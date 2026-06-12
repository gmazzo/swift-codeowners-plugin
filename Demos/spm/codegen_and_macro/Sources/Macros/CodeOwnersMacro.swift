@freestanding(expression)
public macro codeOwners() -> [String]? = #externalMacro(module: "MacrosImpl", type: "CodeOwnersMacro")
