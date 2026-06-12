import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfGenericStruct() {
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(GenericStruct<Any>.self))
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(GenericStruct(value: "aValue")))
}

@Test
func ownersOfGenericClass() {
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(GenericClass<Any>.self))
    #expect(["demo-devs", "baz-devs"] == codeOwnersOf(GenericClass(value: "aValue")))
}
