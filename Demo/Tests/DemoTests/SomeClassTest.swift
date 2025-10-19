import Testing
@testable import Demo

@Test
func ownersOfSomeClass() {
    #expect(["demo-devs"] == SomeClassImpl.codeOwners)
    #expect(["demo-devs"] == SomeClassImpl().codeOwners)
}
