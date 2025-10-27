import Foundation

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

func readSettings(atRoot: URL, evenIfMissing: Bool = false) throws -> Settings? {
    lazy var defaultFile: URL? = { findCodeOwnersFile(atRoot: atRoot) }()
    
    let configFile = atRoot.appendingPathComponent(".codeowners-tool.json")
    if !FileManager.default.fileExists(atPath: configFile.path) {
        if (!evenIfMissing && defaultFile == nil) { return nil }
        
        return Settings(codeowners: Settings.CodeOwners(
            root: atRoot.relativePath,
            file: (defaultFile ?? atRoot.defaultCodeOwnersFile)?.relativePath
        ))
    }
    
    let data = try Data(contentsOf: configFile)
    var settings = try JSONDecoder().decode(Settings.self, from: data)
    settings.codeowners = Settings.CodeOwners(
        root: settings.codeowners?.root ?? atRoot.relativePath,
        file: settings.codeowners?.file ?? (defaultFile ?? atRoot.defaultCodeOwnersFile)?.relativePath
    )
    return settings
}

private func findCodeOwnersFile(atRoot: URL) -> URL? {
    let fm = FileManager.default
    
    for candidate in [ "CODEOWNERS", ".github/CODEOWNERS", ".gitlab/CODEOWNERS", "docs/CODEOWNERS" ] {
        let file = atRoot.appendingPathComponent(candidate)
        
        if fm.fileExists(atPath: file.path) {
            return file
        }
    }
    return nil
}

extension URL {
    
    var defaultCodeOwnersFile: URL {
        get { self.appendingPathComponent("CODEOWNERS") }
    }
    
}
