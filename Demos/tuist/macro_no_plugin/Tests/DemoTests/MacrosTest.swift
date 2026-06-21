import Testing
@testable import Demo

@Test
func testOwnersOfBarFromMacro() {
    #expect(["bar-devs"] == BAR_FILE_OWNERS)
}

@Test
func testOwnersOfFooFromMacro() {
    #expect(["foo-devs"] == FOO_FILE_OWNERS)
}

@Test
func testOwnersOfEnumFromMacro() {
    #expect(["team/enum-devs"] == ENUM_FILE_OWNERS)
}
