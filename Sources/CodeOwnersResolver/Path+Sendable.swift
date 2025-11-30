import PathKit

#if $RetroactiveAttribute
extension Path: @retroactive @unchecked Sendable {}
#else
extension Path: Sendable {}
#endif
