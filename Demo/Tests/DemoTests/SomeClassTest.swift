import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfSomeClass() {
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(SomeClassImpl.self))
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(SomeClassImpl()))
}
