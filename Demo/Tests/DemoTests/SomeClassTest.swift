import XCTest
@testable import Demo

class SomeClassTest: XCTestCase {

    func testOwnersOfSomeClass() {
        XCTAssertEqual(["demo-devs"], SomeClassImpl.codeOwners)
        XCTAssertEqual(["demo-devs"], SomeClassImpl().codeOwners)
    }

}
