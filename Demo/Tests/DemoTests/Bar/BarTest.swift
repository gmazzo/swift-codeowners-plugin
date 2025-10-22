import Testing
import CodeOwnersCore
@testable import Demo

@Test
func testOwnersOfBar() {
    #expect(["bar-devs"] == codeOwnersOf(Bar.self))
    #expect(["bar-devs"] == codeOwnersOf(Bar()))
}
