import Foundation
import CodeOwnersAPI

struct Bar {

    func doSomething() {
        print("Doing something with Bar")
    }

    func callStack() -> [String] {
        return Thread.callStackSymbols
    }

}

struct BarWithMyProtocol : MyProtocol {

    func myAction() {
        print("Action performed by BarWithMyProtocol")
    }

}

class BarExtendingFoo: Foo {}

private struct PrivateBar {}

struct GenericBarStruct {
    let generic: GenericStruct<Bar>
}

class GenericBarClass : GenericClass<Bar> {}
