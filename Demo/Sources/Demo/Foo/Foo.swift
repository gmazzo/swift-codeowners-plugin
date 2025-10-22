class Foo {

    func doSomething() {
        print("Doing something with Foo")
    }

}

class FooWithMyProtocol : MyProtocol {

    func myAction() {
        print("Action performed by FooWithMyProtocol")
    }

}

private class PrivateFoo {}
