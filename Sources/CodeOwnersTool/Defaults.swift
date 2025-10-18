import Foundation

let toolDefaults: (root: URL, codeOwnersFile: URL) = findCodeOwnersFile()

private func findCodeOwnersFile() -> (root: URL, codeOwnersFile: URL) {
    let fm = FileManager.default
    let pwd = fm.pwd
    let roots = [ pwd, fm.gitRoot ].compactMap { $0 }
    let candidates = [
        "CODEOWNERS",
        ".github/CODEOWNERS",
        ".gitlab/CODEOWNERS",
        "docs/CODEOWNERS",
    ]
    
    return roots
        .flatMap { root in candidates.map { path in (root: root, codeOwnersFile: root.appendingPathComponent(path)) } }
        .filter { fm.fileExists(atPath: $0.codeOwnersFile.path) }
        .first ?? (root: pwd, codeOwnersFile: pwd.appendingPathComponent("CODEOWNERS"))
}
