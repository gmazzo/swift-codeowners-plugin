import Foundation

let settings = readSettings()

struct Settings : Decodable, Equatable {
    var codeowners: CodeOwners?
    var renames: [String: String]?
    var quiet: Bool?
    var verbose: Bool?
    
    struct CodeOwners : Decodable, Equatable {
        var root: String?
        var file: String?
    }
}

private func readSettings(pwd: URL = FileManager.default.pwd) -> Settings {
    lazy var defaultLocation: Settings.CodeOwners = { findCodeOwnersFile(pwd) }()
    
    let file = pwd.appending(component: ".codeowners-tool.json")
    if !FileManager.default.fileExists(atPath: file.path) { return Settings(codeowners: defaultLocation) }
    
    let data = try! Data(contentsOf: file)
    var settings = try! JSONDecoder().decode(Settings.self, from: data)
    settings.codeowners = Settings.CodeOwners(
        root: settings.codeowners?.root ?? defaultLocation.root,
        file: settings.codeowners?.file ?? defaultLocation.file
    )
    return settings
}
    
private func findCodeOwnersFile(_ pwd: URL) -> Settings.CodeOwners {
    let fm = FileManager.default
    let roots = [ pwd, fm.gitRoot ].compactMap { $0 }
    let candidates = [
        "CODEOWNERS",
        ".github/CODEOWNERS",
        ".gitlab/CODEOWNERS",
        "docs/CODEOWNERS",
    ]

    let (root, file) = roots
        .flatMap { root in candidates.map { path in (root, root.appendingPathComponent(path)) } }
        .filter { (_, file) in fm.fileExists(atPath: file.path) }
        .first ?? (pwd, pwd.appendingPathComponent("CODEOWNERS"))
    
    return Settings.CodeOwners(root: root.relativePath, file: file.relativePath)
}
