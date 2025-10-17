import XCTest
@testable import Demo

class SomeClassTest: XCTestCase {

    func testOwnersOfFoo() {
        XCTAssertEqual(["demo-devs"], Foo().codeOwners())
    }

    func testOwnersOfBar() {
        XCTAssertEqual(["demo-devs"], Bar().codeOwners())
    }

}
