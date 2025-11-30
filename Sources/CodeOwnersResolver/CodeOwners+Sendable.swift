import CodeOwners

#if $RetroactiveAttribute
extension CodeOwners: @retroactive @unchecked Sendable {}
#else
extension CodeOwners: @unchecked Sendable {}
#endif
