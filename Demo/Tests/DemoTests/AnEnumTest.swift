import Testing
import CodeOwnersAPI
@testable import Demo

@Test
func ownersOfAnEnum() {
    #expect(["team/enum-experts"] == codeOwnersOf(AnEnum.self))
    #expect(["team/enum-experts"] == codeOwnersOf(AnEnum.AAA))
    #expect(["team/enum-experts"] == codeOwnersOf(AnEnum.BBB))
    #expect(["team/enum-experts"] == codeOwnersOf(AnEnum.CCC))
}
