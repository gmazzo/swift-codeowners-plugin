import Testing
@testable import Demo

@Test
func ownersOfFoo() {
    #expect(["foo-devs"] == Foo.codeOwners)
    #expect(["foo-devs"] == Foo().codeOwners)
}
