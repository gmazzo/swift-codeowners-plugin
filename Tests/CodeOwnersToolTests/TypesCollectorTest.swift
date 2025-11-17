import Testing
import SwiftParser
@testable import CodeOwnersTool

@Suite("TypesCollector test")
struct TypesCollectorTest {
    
    @Test
    func detectsTypesCorrectly() async throws {
        let swiftFile = Parser.parse(source: swiftFileContent)
        let collector = TypesCollector(viewMode: .fixedUp)
        collector.walk(swiftFile)
        
        #expect(collector.finalTypes == [ "Foo", "Bar", "MyEnum", "FooWithGeneric" ])
        #expect(collector.extensibleTypes == [ "Baz", "GenericStruct", "GenericClass" ])
        #expect(collector.extensionTypes == [ "Foo", "GenericStruct", "MyEnum" ])
    }
    
    private let swiftFileContent = """
    
    protocol MyProtocol {}
    
    struct Foo {
        class FooBar {}
    }
    
    class Bar {
        struct BarFoo {}
    }
    
    class Baz : Foo.FooBar(), MyProtocol {}
    
    enum MyEnum : MyProtocol {}
    
    enum ParametrizedEnum<Type> {}
    
    @available(iOS 16.2, *)
    struct iOS16Struct {}
    
    @available(*, deprecated)
    struct DeprecatedStruct {}
    
    struct FooWithGeneric {
        let generic: GenericStruct<String>
    }
    
    struct GenericStruct<Type> {
        let value: Type
    }

    class GenericClass<Type> {
        let value: Type
        
        init(value: Type) {
            self.value = value
        }
    }
    
    extension Foo {}
    extension GenericStruct {}
    extension MyEnum {}
    
    """
    
}

