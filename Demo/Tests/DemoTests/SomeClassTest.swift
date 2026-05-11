import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfSomeClass() {
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(SomeClassImpl.self))
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(SomeClassImpl()))
}
