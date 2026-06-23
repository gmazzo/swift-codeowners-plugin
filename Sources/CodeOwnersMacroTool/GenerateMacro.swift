import Foundation

func generateMacro(
    codeOwnersRoot: URL,
    codeOwnersFile: URL,
    renames: [String: String],
    outputMacroFile: URL,
    verbose: Bool
) throws {
    let codeOwnersContent = try String(contentsOf: codeOwnersFile, encoding: .utf8)
    let renamesContent = renames
        .map { (regex, replacement) in "\n       #\"\(regex)=\(replacement)\"#" }
        .joined(separator: ", ")
    
    let content = """
    import CodeOwnersMacroBase
    import CodeOwnersResolver
    
    class CodeOwnersMacro : CodeOwnersMacroBase {
        
        static let fileContent = #\"""
                \(codeOwnersContent.replacingOccurrences(of: "\n", with: "\n            "))
                \"""#
    
        static let root = #"\(codeOwnersRoot.relativePath)"#
    
        static let renames: [RenameRule] = [\(renamesContent) 
        ]
    
        static let verbose = \(verbose)
    
    }
    """
    
    let fm = FileManager.default
    try fm.createDirectory(at: outputMacroFile.deletingLastPathComponent(), withIntermediateDirectories: true)
    try content.write(to: outputMacroFile, atomically: true, encoding: .utf8)
}
