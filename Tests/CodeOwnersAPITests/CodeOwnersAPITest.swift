import Foundation
import Testing
@testable import CodeOwnersAPI

@Suite("CodeOwners API")
struct CodeOwnersAPITest {
    
    struct Params : Sendable {
        let expected: CodeOwners?
        let input: Sendable?
    }
    
    @Test(.serialized, arguments: [
        Params(expected: nil, input: nil),
        Params(expected: nil, input: URL.self),
        Params(expected: nil, input: URL(string: "https://google.com")),
        Params(expected: [ "foo" ], input: TestStruct.self),
        Params(expected: [ "foo" ], input: TestStruct()),
        Params(expected: [ "foo" ], input: TestStruct.Inner.self),
        Params(expected: [ "foo" ], input: TestStruct.Inner()),
        Params(expected: [ "foo", "bar" ], input: TestEnum.self),
        Params(expected: [ "foo", "bar" ], input: TestEnum.AAA),
        Params(expected: [ "foo", "bar" ], input: TestEnum.BBB),
        Params(expected: [ "baz" ], input: TestClass.self),
        Params(expected: [ "baz" ], input: TestClass()),
        Params(expected: [ "baz" ], input: TestClass.Inner.self),
        Params(expected: [ "baz" ], input: TestClass.Inner()),
    ])
    func codeOwnersOfResolution(params: Params) {
        let owners = codeOwnersOf(params.input)
        
        #expect(params.expected == owners)
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
final class TestClass : Sendable {
    final class Inner : Sendable {}
    func doBlock<T>(block: () -> T) -> T { block() }
}

// this will be the a generated class by the plugin
class _CodeOwners : CodeOwnersMappingProvider {
    nonisolated(unsafe) static var codeOwners: [Substring : CodeOwners]? = [
        "TestStruct" : [ "foo" ],
        "TestEnum" : [ "foo", "bar" ],
        "TestClass" : [ "baz" ],
    ]
}
