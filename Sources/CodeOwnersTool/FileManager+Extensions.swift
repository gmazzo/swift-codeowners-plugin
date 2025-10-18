import Foundation

extension FileManager {

    var pwd: URL {
        get {
            return URL(fileURLWithPath: currentDirectoryPath)
        }
    }

    func walkFiles(at: [URL], onEach: (_ file: URL) throws -> Void) throws {
        for url in at {
            try walkFiles(at: url, onEach: onEach)
        }
    }

    func walkFiles(at: URL, onEach: (_ file: URL) throws -> Void) throws {
        let isDir = (try at.resourceValues(forKeys: [.isDirectoryKey])).isDirectory ?? false

        if (isDir) {
            guard let enumerator = enumerator(at: at, includingPropertiesForKeys: nil) else {
                return
            }
            for file in enumerator {
                try walkFiles(at: file as! URL, onEach: onEach)
            }
        } else {
            try onEach(at)
        }
    }

    func deleteRecursively(at: URL) throws {
        try walkFiles(at: at) { file in
            try FileManager.default.removeItem(at: file)
        }
    }

    var gitRoot: URL? {
        get {
            let pipe = Pipe()

            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.currentDirectoryURL = pwd
            process.arguments = ["git", "rev-parse", "--show-toplevel"]
            process.standardOutput = pipe

            do {
                try process.run()
                process.waitUntilExit()
                let response = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
                if let path = response?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
                    return URL(fileURLWithPath: path)
                }
            } catch {
            }
            return nil
        }
    }

}
