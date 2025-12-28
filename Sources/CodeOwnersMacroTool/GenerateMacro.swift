import Foundation

func generateMacro(
    codeOwnersRoot: URL,
    codeOwnersFile: URL,
    renames: [String: String],
    outputMacroFile: URL
) throws {
    let codeOwnersContent = try String(contentsOf: codeOwnersFile, encoding: .utf8)
    let renamesContent = renames
        .map { (regex, replacement) in "\n                RenameRule(regex: #\"\(regex)\"#, replacement: #\"\(replacement)\"#)" }
        .joined(separator: ", ")
    
    let content = """
    import PathKit
    import CodeOwnersResolver
    import CodeOwnersMacro
    
    class CodeOwnersMacro : CodeOwnersMacroBase {
        static let resolver = {
            try! resolveCodeOwners(
                fileContent:
                #\"""
                \(codeOwnersContent.replacingOccurrences(of: "\n", with: "\n            "))
                \"""#,
                root: #"\(codeOwnersRoot.relativePath)"#,
                renames: [ \(renamesContent) 
                ]
            )
        }()
    }
    """
    
    let fm = FileManager.default
    try fm.createDirectory(at: outputMacroFile.deletingLastPathComponent(), withIntermediateDirectories: true)
    try content.write(to: outputMacroFile, atomically: true, encoding: .utf8)
}
