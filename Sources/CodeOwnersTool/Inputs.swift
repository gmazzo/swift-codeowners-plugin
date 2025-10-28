import Foundation

struct Inputs : Sendable {
    let codeOwnersRoot: URL
    let codeOwnersFile: URL?
    let settingsFile: URL?

    var files: [URL] { return [codeOwnersFile, settingsFile].compactMap { $0 } }
    
    struct Resolved : Sendable {
        let codeOwnersRoot: URL
        let codeOwnersFile: URL
        var renames: [RenameRule] = []
        var verbose: Bool = false
        var quiet: Bool = false
    }
}

struct RenameRule : Sendable {
    let regex: String
    let replacement: String
    
    init(regex: String, replacement: String) {
        _ = try! Regex(regex) // makes sure it's valid
        self.regex = regex
        self.replacement = replacement
    }
}

struct SettingsFile : Decodable, Equatable {
    let codeowners: CodeOwners?
    let renames: [String: String]?
    let verbose: Bool?
    let quiet: Bool?
    
    struct CodeOwners : Decodable, Equatable {
        let root: String?
        let file: String?

        var rootURL: URL? { return root.map { URL(filePath: $0) } }
        var fileURL: URL? { return file.map { URL(filePath: $0) } }
    }
}

extension Inputs {
    
    static func lookupAlways(atRoot: URL? = nil) -> Inputs {
        let root = atRoot ?? FileManager.default.currentDirectory
        return lookup(atRoot: root) ?? Inputs(
            codeOwnersRoot: root,
            codeOwnersFile: defaultCodeOwnersFile(atRoot: root),
            settingsFile: nil
        )
    }
    
    static func lookup(atRoot: URL? = nil) -> Inputs? {
        let fm = FileManager.default
        let root = atRoot ?? FileManager.default.currentDirectory
        
        for root in ([ root, gitRoot(root) ].compactMap { $0 }) {
            let codeownersFile = fm.findFile(at: root, "CODEOWNERS", ".github/CODEOWNERS", ".gitlab/CODEOWNERS", "docs/CODEOWNERS")
            let settingsFile = fm.findFile(at: root, ".codeowners-tool.json")
            let inputs = Inputs(codeOwnersRoot: root, codeOwnersFile: codeownersFile, settingsFile: settingsFile)
            
            if !inputs.files.isEmpty {
                return inputs
            }
        }
        return nil
    }
    
    func resolve() throws -> Resolved {
        let fm = FileManager.default
        
        guard let settingsFile = settingsFile, fm.fileExists(atPath: settingsFile.path) else {
            return Resolved(
                codeOwnersRoot: codeOwnersRoot,
                codeOwnersFile: codeOwnersFile ?? defaultCodeOwnersFile(atRoot: codeOwnersRoot)
            )
        }
        
        let data = try Data(contentsOf: settingsFile)
        let settings = try JSONDecoder().decode(SettingsFile.self, from: data)
        let root = settings.codeowners?.rootURL ?? codeOwnersRoot
        let renames = settings.renames?.map { (regex, replace) in RenameRule(regex: regex, replacement: replace) }
        return Resolved(
            codeOwnersRoot: root,
            codeOwnersFile: settings.codeowners?.fileURL ?? codeOwnersFile ?? defaultCodeOwnersFile(atRoot: root),
            renames: renames ?? [],
            verbose: settings.verbose ?? false,
            quiet: settings.quiet ?? false
        )
    }
    
}

private func gitRoot(_ atRoot: URL) -> URL? {
    let pipe = Pipe()
    
    let process = Process()
    process.executableURL = URL(filePath: "git")
    process.currentDirectoryURL = atRoot
    process.arguments = ["rev-parse", "--show-toplevel"]
    process.standardOutput = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        let response = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        if let path = response?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
            return URL(filePath: path)
        }
    } catch {
    }
    return nil
}

private func defaultCodeOwnersFile(atRoot: URL) -> URL {
    return atRoot.appendingPathComponent("CODEOWNERS")
}

extension FileManager {
    
    var currentDirectory: URL { return URL(filePath: FileManager.default.currentDirectoryPath) }
    
    func findFile(at dir: URL, _ candidateNames: String...) -> URL? {
        for candidate in candidateNames {
            let file = dir.appendingPathComponent(candidate)
            
            if fileExists(atPath: file.path) {
                return file
            }
        }
        return nil
    }
    
}
