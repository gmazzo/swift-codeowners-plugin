import Testing
@testable import Demo

@Test
func ownersOfAnEnum() {
    #expect(["team/enum-experts"] == AnEnum.codeOwners)
    #expect(["team/enum-experts"] == AnEnum.AAA.codeOwners)
    #expect(["team/enum-experts"] == AnEnum.BBB.codeOwners)
    #expect(["team/enum-experts"] == AnEnum.CCC.codeOwners)
}
