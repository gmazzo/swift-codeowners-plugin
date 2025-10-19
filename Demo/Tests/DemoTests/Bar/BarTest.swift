import Testing
@testable import Demo

@Test
func testOwnersOfBar() {
    #expect(["bar-devs"] == Bar.codeOwners)
    #expect(["bar-devs"] == Bar().codeOwners)
}
