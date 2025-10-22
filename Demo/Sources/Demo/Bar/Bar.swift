struct Bar {

    func doSomething() {
        print("Doing something with Bar")
    }

}

struct BarWithMyProtocol : MyProtocol {

    func myAction() {
        print("Action performed by BarWithMyProtocol")
    }

}

class BarExtendingFoo: Foo {}

private struct PrivateBar {}
