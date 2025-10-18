import XCTest
@testable import Demo

class FooTest: XCTestCase {

    func testOwnersOfFoo() {
        XCTAssertEqual(["foo-devs"], Foo.codeOwners)
        XCTAssertEqual(["foo-devs"], Foo().codeOwners)
    }

}
