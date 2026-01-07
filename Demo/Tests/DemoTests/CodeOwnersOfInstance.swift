import CodeOwnersAPI

/**
 Helper function to extend `codeOwnersOf`function to instances for the scope of the Demo tests only.
 This is intentionally not part of the public API to emphasize the static nature of CodeOwner's and you should always try to use `Type`s for it
 */
func codeOwnersOf<Type>(_ instance: Type?) -> CodeOwners? {
    let type = type(of: instance)
    return CodeOwnersAPI.codeOwnersOf(type)
}
