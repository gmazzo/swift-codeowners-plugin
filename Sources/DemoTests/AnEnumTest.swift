import XCTest
@testable import Demo

class AnEnumTest: XCTestCase {

    func testOwnersOfAnEnum() {
        XCTAssertEqual(["team/enum-experts"], AnEnum.codeOwners)
        XCTAssertEqual(["team/enum-experts"], AnEnum.AAA.codeOwners)
        XCTAssertEqual(["team/enum-experts"], AnEnum.BBB.codeOwners)
        XCTAssertEqual(["team/enum-experts"], AnEnum.CCC.codeOwners)
    }

}
