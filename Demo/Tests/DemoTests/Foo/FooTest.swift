import Testing
import CodeOwnersCore
@testable import Demo

@Test
func ownersOfFoo() {
    #expect(["foo-devs"] == codeOwnersOf(Foo.self))
    #expect(["foo-devs"] == codeOwnersOf(Foo()))
}
