import Foundation
import Testing
@testable import CodeOwnersAPI

@Suite("Demangler Helper")
struct DemangleHelperTest {
    
    @Test(arguments: [
        ("$s18CodeOwnersAPITests18SwiftDemanglerTestV22testMethodsFromSymbolsyyYaKFTY0_", "(1) suspend resume partial function for CodeOwnersAPITests.SwiftDemanglerTest.testMethodsFromSymbols() async throws -> ()"),
        ("$s18CodeOwnersAPITests18SwiftDemanglerTestV04$s18ab10APITests18deF45V22testMethodsFromSymbols0F0fMp_8a4b88380fMu_33_0EE505EB9DC91E1406680357BE7F0856LLyyYaYbKFZTQ5_", "(6) await resume partial function for static CodeOwnersAPITests.SwiftDemanglerTest.($s18CodeOwnersAPITests18SwiftDemanglerTestV22testMethodsFromSymbols0F0fMp_8a4b88380fMu_ in _0EE505EB9DC91E1406680357BE7F0856)@Sendable () async throws -> ()"),
        ("$s9DemoTests24testOwnersOfCallStackBaryyFShySSGSgyXEfu1_", "implicit closure #3 () -> Swift.Optional<Swift.Set<Swift.String>> in DemoTests.testOwnersOfCallStackBar() -> ()"),
        ("$s9DemoTests24testOwnersOfCallStackBaryyFSbShySSGSg_ADyXEtXEfU0_", "closure #2 (Swift.Optional<Swift.Set<Swift.String>>, () -> Swift.Optional<Swift.Set<Swift.String>>) -> Swift.Bool in DemoTests.testOwnersOfCallStackBar() -> ()")
    ])
    func swiftDemangle_output(args: (input: String, expects: String)) {
        let demangled = swiftDemangle(args.input)
        
        #expect(args.expects == demangled)
    }
    
    @Test(arguments: [
        (false, "(1) suspend resume partial function for CodeOwnersAPITests.SwiftDemanglerTest.testMethodsFromSymbols() async throws -> ()", "CodeOwnersAPITests.SwiftDemanglerTest"),
        (true, "0   CodeOwnersAPITests                  0x000000010135af3c $s18CodeOwnersAPITests18SwiftDemanglerTestV22testMethodsFromSymbolsyyYaKFTY0_ + 316", "CodeOwnersAPITests.SwiftDemanglerTest"),
        (true, "2   libTesting.dylib                    0x00000001050f6aa8 $sq_Igr_q_Iegr_r1_lTRTA + 20", nil),
        (true, "3   libTesting.dylib                    0x00000001050cbe14 $s7Testing19_callBinaryOperator33_FFD698C5E0FC3C0CA30B382AE6D7F227LLyq0_6result_q_Sg3rhstx_q0_x_q_yXEtXEq_yXEtr1_lFq0_q_ycXEfU_q_yXEfU_ + 208", nil),
        (true, "6   Demo ProjectPackageTests            0x0000000105034f30 $s9DemoTests24testOwnersOfCallStackBaryyF + 732", "DemoTests.testOwnersOfCallStackBar"),
        (true, "0   Demo ProjectPackageTests            0x0000000105030178 $s4Demo3BarV9callStackSaySSGyF + 68", "Demo.Bar"),
    ])
    func classNameFromSymbol_output(args: (demangle: Bool, input: String, expected: Substring?)) {
        let className = classNameFromSymbol(args.input, args.demangle)
        
        #expect(args.expected == className)
    }

}
