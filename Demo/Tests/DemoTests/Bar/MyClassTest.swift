import Testing
import CodeOwnersCore
@testable import Demo

@Test
func testOwnersOfMyClass() {
    #expect(["bar-devs", "foo-devs"] == codeOwnersOf(MyClass.self))
    #expect(["bar-devs", "foo-devs"] == codeOwnersOf(MyClass()))
}
