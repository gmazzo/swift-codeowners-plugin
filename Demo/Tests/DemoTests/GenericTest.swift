import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfGenericStruct() {
    #expect(["demo-devs"] == codeOwnersOf(GenericStruct<Any>.self))
    #expect(["demo-devs"] == codeOwnersOf(GenericStruct(value: "aValue")))
}

@Test
func ownersOfGenericClass() {
    #expect(["demo-devs"] == codeOwnersOf(GenericClass<Any>.self))
    #expect(["demo-devs"] == codeOwnersOf(GenericClass(value: "aValue")))
}
