import Foundation

nonisolated(unsafe) private let classNameRegEx = /(?:^| )(\w+\.\w+)(?: |\.|\(|$)/
nonisolated(unsafe) private let symbolRegEx = /\b(?:\$s\w+)+\b/

private typealias DemangleProc =
    @convention(c) (_ name: UnsafePointer<UInt8>?, _ length: Int, _ buffer: UnsafeMutablePointer<UInt8>?, _ bufferSize: UnsafeMutablePointer<Int>?, _ flags: UInt32) -> UnsafeMutablePointer<Int8>?

private let demangleProc: DemangleProc? = resolveDemangleProc()

private func resolveDemangleProc() -> DemangleProc? {
  guard let lib = dlopen(nil, RTLD_NOW) else { return nil }
  guard let symbol = dlsym(lib, "swift_demangle") else { return nil }
  return unsafeBitCast(symbol, to: DemangleProc.self)
}

internal func swiftDemangle(_ mangledName: String) -> String? {
  guard let proc = demangleProc else { return nil }
  guard let string = proc(mangledName, mangledName.count, nil, nil, 0) else { return nil }
  defer { string.deallocate() }
  return String(cString: string)
}

internal func classNameFromSymbol(_ symbol: String, _ demangle: Bool) -> Substring? {
    var method = symbol
    while(true) {
        guard let match = method.firstMatch(of: symbolRegEx), match.count != method.count else { break }
        method = "\(match.0)"
        if (demangle) { method = swiftDemangle(method) ?? method }
    }
    let className = method.firstMatch(of: classNameRegEx)?.1
    return className
}
