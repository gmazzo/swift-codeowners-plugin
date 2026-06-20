import Foundation

// Due SPM Plugin limitations, plugins cannot share code by having a `library` dependency nor 3rd party ones.
// Therefore, this file is added to `CodeOwnersPlugin` and `CodeOwnersMacroPlugin` as a symbolic link, but it can't be
// migrated to `PathKit` since we can't import the dependency for plugins.

public struct Inputs : Sendable {
    public let codeOwnersRoot: URL
    public let codeOwnersFile: URL?
    public let settingsFile: URL?

    public var files: [URL] { return [codeOwnersFile, settingsFile].compactMap { $0 } }
    
    public struct Resolved : Sendable {
        public let codeOwnersRoot: URL
        public let codeOwnersFile: URL
        public var renames: [RenameRule] = []
        public var verbose: Bool = false
        public var quiet: Bool = false
    }
}

public struct RenameRule : Sendable, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = String
    
    public let regex: String
    public let replacement: String
    
    public init(regex: String, replacement: String) {
        _ = try! Regex(regex) // makes sure it's valid
        self.regex = regex
        self.replacement = replacement
    }
    
    public init(arrayLiteral elements: String...) {
        precondition(elements.count == 2)
        self.init(regex: elements[0], replacement: elements[1])
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
    }
}

public extension Inputs {
    
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
        let settingsDir = settingsFile.deletingLastPathComponent()
        let root = settings.codeowners?.root.map(settingsDir.resolve) ?? codeOwnersRoot
        let renames = settings.renames?.map { (regex, replace) in RenameRule(regex: regex, replacement: replace) }
        return Resolved(
            codeOwnersRoot: root,
            codeOwnersFile: settings.codeowners?.file.map(settingsDir.resolve) ?? codeOwnersFile ?? defaultCodeOwnersFile(atRoot: root),
            renames: renames ?? [],
            verbose: settings.verbose ?? false,
            quiet: settings.quiet ?? false
        )
    }
    
}

extension [RenameRule] {
    
    public func asDict() -> [String: String] {
        return self.reduce(into: [:]) { $0[$1.regex] = $1.replacement }
    }
    
}

private extension URL {
    
    func resolve(_ path: String) -> URL {
        self.appendingPathComponent(path).standardized
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
    
    public var currentDirectory: URL { return URL(filePath: FileManager.default.currentDirectoryPath) }
    
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
