import Testing
@testable import Demo

@Test
func testOwnersOfMyClass() {
    #expect(["bar-devs", "foo-devs"] == MyClass.codeOwners)
    #expect(["bar-devs", "foo-devs"] == MyClass().codeOwners)
}
