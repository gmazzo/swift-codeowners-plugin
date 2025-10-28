import Foundation

extension FileManager {

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

}
