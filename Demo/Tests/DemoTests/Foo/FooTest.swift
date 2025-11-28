import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func testOwnersOfFooFieldFromMacro() {
    #expect(["foo-devs"] == FOO_FILE_OWNERS)
}

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

@Test
func ownersOfGenericFoo() {
    #expect(["foo-devs"] == codeOwnersOf(GenericFooStruct.self))
    #expect(["foo-devs"] == codeOwnersOf(GenericFooStruct(generic: GenericStruct(value: Foo()))))
}

@Test
func ownersOfGenericFooClass() {
    #expect(["foo-devs"] == codeOwnersOf(GenericFooClass.self))
    #expect(["foo-devs"] == codeOwnersOf(GenericFooClass(value: Foo())))
}
