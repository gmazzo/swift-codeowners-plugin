import Macros
import Foundation
import CodeOwnersAPI

let FOO_FILE_OWNERS = #codeOwners

class Foo {

    func doSomething() {
        print("Doing something with Foo")
    }

    func callStack() -> [String] {
        return Thread.callStackSymbols
    }

}

class FooWithMyProtocol : MyProtocol {

    func myAction() {
        print("Action performed by FooWithMyProtocol")
    }

}

private class PrivateFoo {}

struct GenericFooStruct {
    let generic: GenericStruct<Foo>
}

class GenericFooClass : GenericClass<Foo> {}
