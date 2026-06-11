import Testing
@testable import Framework

@Suite("FrameworkTest")
struct nameFrameworkTest {
    
    @Test func ownersFieldOfMyStruct() async throws {
        #expect(MyStruct.owners == ["anOwner"])
    }
    
}
