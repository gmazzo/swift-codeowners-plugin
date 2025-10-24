struct Settings : Decodable {
    let codeowners: CodeOwners?
    let renames: [String: String]?
    let quiet: Bool?
    let verbose: Bool?
    
    struct CodeOwners : Decodable {
        let root: String?
        let file: String?
    }
}
