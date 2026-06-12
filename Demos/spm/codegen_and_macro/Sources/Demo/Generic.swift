struct GenericStruct<Type> {
    let value: Type
}

class GenericClass<Type> {
    let value: Type
    
    init(value: Type) {
        self.value = value
    }
}
