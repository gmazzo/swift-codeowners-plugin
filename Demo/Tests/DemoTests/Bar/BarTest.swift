import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func testOwnersOfBar() {
    #expect(["bar-devs"] == codeOwnersOf(Bar.self))
    #expect(["bar-devs"] == codeOwnersOf(Bar()))
}

@Test
func testOwnersOfCallStackBar() {
    let owners = codeOwnersOfCallStack(symbols: Bar().callStack())

    #if os(Linux)
    // Linux does not include method names in call stacks
    #expect(owners == nil)
    #else
    #expect(owners == ["bar-devs"])
    #endif
}
