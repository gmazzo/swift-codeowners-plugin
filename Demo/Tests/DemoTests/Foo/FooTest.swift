import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfFoo() {
    #expect(["foo-devs"] == codeOwnersOf(Foo.self))
    #expect(["foo-devs"] == codeOwnersOf(Foo()))
}

@Test
func testOwnersOfCallStackInFoo() {
    let owners = codeOwnersFromCallStack(symbols: Foo().callStack())

    #if os(Linux)
    // Linux does not include method names in call stacks
    #expect(owners == nil)
    #else
    #expect(owners == ["foo-devs"])
    #endif
}
