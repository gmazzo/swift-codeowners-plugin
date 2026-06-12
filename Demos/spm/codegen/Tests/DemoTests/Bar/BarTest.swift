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
    let owners = codeOwnersFromCallStack(symbols: Bar().callStack())

    #if os(Linux)
    // Linux does not include method names in call stacks
    #expect(owners == nil)
    #else
    #expect(owners == ["bar-devs"])
    #endif
}

@Test
func ownersOfGenericBarStruct() {
    #expect(["bar-devs"] == codeOwnersOf(GenericBarStruct.self))
    #expect(["bar-devs"] == codeOwnersOf(GenericBarStruct(generic: GenericStruct(value: Bar()))))
}

@Test
func ownersOfGenericBarClass() {
    #expect(["bar-devs"] == codeOwnersOf(GenericBarClass.self))
    #expect(["bar-devs"] == codeOwnersOf(GenericBarClass(value: Bar())))
}
