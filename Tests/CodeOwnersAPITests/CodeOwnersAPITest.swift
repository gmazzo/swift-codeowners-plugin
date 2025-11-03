import Foundation
import Testing
@testable import CodeOwnersAPI

@Suite("CodeOwners API")
struct CodeOwnersAPITest {
    
    @Test
    func codeOwnersOfNil() {
        #expect(nil == codeOwnersOf(nil))
    }
    
    @Test
    func codeOwnersOfFoundationClass() {
        #expect(nil == codeOwnersOf(URL(string: "http://google.com")))
    }
    
    @Test
    func codeOwnersOfTestStruct() {
        #expect([ "foo" ] == codeOwnersOf(TestStruct.self))
        #expect([ "foo" ] == codeOwnersOf(TestStruct()))
        #expect([ "foo" ] == codeOwnersOf(TestStruct.Inner.self))
        #expect([ "foo" ] == codeOwnersOf(TestStruct.Inner()))
    }
    
    @Test
    func codeOwnersOfTestEnum() {
        #expect([ "foo", "bar" ] == codeOwnersOf(TestEnum.self))
        #expect([ "foo", "bar" ] == codeOwnersOf(TestEnum.AAA))
        #expect([ "foo", "bar" ] == codeOwnersOf(TestEnum.BBB))
    }
    
    @Test
    func codeOwnersOfTestClass() {
        #expect([ "baz" ] == codeOwnersOf(TestClass.self))
        #expect([ "baz" ] == codeOwnersOf(TestClass()))
        #expect([ "baz" ] == codeOwnersOf(TestClass.Inner.self))
        #expect([ "baz" ] == codeOwnersOf(TestClass.Inner()))
    }
    
    @Test
    func codeOwnersFromCallStackUnknown() {
        let stack = DispatchQueue.main.sync { Thread.callStackSymbols }
        
        #expect(nil == codeOwnersFromCallStack(symbols: stack))
    }
    
    @Test
    func codeOwnersFromCallStackKnown() {
        let stack = DispatchQueue.main.sync { TestClass().doBlock { Thread.callStackSymbols } }
        #if os(Linux)
        // Call stacks are not fully supported on Linux
        let expected: CodeOwners? = nil
        #else
        let expected: CodeOwners? = [ "baz" ]
        #endif
        
        #expect(expected == codeOwnersFromCallStack(symbols: stack))
    }
    
}

struct TestStruct { struct Inner {} }
enum TestEnum { case AAA; case BBB }
final class TestClass {
    final class Inner {}
    func doBlock<T>(block: () -> T) -> T { block() }
}

class _CodeOwners : CodeOwnersMappingProvider {
    nonisolated(unsafe) static var codeOwners: [Substring : CodeOwners]? = [
        "TestStruct" : [ "foo" ],
        "TestEnum" : [ "foo", "bar" ],
        "TestClass" : [ "baz" ],
    ]
}
