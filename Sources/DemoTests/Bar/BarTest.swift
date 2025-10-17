import XCTest
@testable import Demo

class BarTest: XCTestCase {

    func testOwnersOfBar() {
        XCTAssertEqual(["bar-devs"], Bar.codeOwners)
        XCTAssertEqual(["bar-devs"], Bar().codeOwners)
    }

}
