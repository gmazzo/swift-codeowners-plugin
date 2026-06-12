import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfAnEnum() {
    #expect(["team/enum-devs"] == codeOwnersOf(AnEnum.self))
    #expect(["team/enum-devs"] == codeOwnersOf(AnEnum.AAA))
    #expect(["team/enum-devs"] == codeOwnersOf(AnEnum.BBB))
    #expect(["team/enum-devs"] == codeOwnersOf(AnEnum.CCC))
}
