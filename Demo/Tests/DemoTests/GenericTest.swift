import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfGenericStruct() {
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(GenericStruct<Any>.self))
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(GenericStruct(value: "aValue")))
}

@Test
func ownersOfGenericClass() {
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(GenericClass<Any>.self))
    #expect(["baz-devs", "demo-devs"] == codeOwnersOf(GenericClass(value: "aValue")))
}
