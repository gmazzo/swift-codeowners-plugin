import Testing
import CodeOwnersCore
@testable import Demo

@Test
func ownersOfSomeClass() {
    #expect(["demo-devs"] == codeOwnersOf(SomeClassImpl.self))
    #expect(["demo-devs"] == codeOwnersOf(SomeClassImpl()))
}
