import PathKit
import CodeOwners

public struct CodeOwnersResolver {
    fileprivate let root: Path
    fileprivate let entries: CodeOwners
    
    public func codeOwnersOf(_ file: Path) -> [String]? {
        guard let relativePath = file.relativePathTo(root) else { return nil }
        guard let owners = entries.codeOwner(pattern: relativePath)?.owners else { return nil }
        return owners.map(asLiteral)
    }
}

public func resolveCodeOwners(file: Path, root: Path, renames: [RenameRule] = []) throws -> CodeOwnersResolver {
    return try resolveCodeOwners(fileContent: file.read(.utf8), root: root, renames: renames)
}

public func resolveCodeOwners(fileContent: String, root: Path, renames: [RenameRule] = []) throws -> CodeOwnersResolver {
    let parsed = CodeOwners.parse(file: fileContent)
    if renames.isEmpty { return CodeOwnersResolver(root: root, entries: parsed) }
    
    let renamesRegex = try renames.map { (try Regex($0.regex), $0.replacement )}
    let renamedLines = parsed.lines.map { line in
        switch line {
        case .codeOwner(let codeOwner):
            let renamedOwners = codeOwner.owners.map { owner in
                var literal = asLiteral(owner)
                for (rename, replacement) in renamesRegex {
                    literal = literal.replacing(rename, with: replacement)
                }
                return Owner.user(UserIdentifier.userName(literal)) // we really don't care on the kind of owner
            }
            
            return CodeOwnerLine.codeOwner(CodeOwner(pattern: codeOwner.pattern, owners: renamedOwners))
            
        default:
            return line
        }
    }
    return CodeOwnersResolver(root: root, entries: CodeOwners(lines: renamedLines))
}

private func asLiteral(_ owner: Owner) -> String {
    switch owner {
    case .user(let userId):
        switch userId {
        case .userName(let name): return "\(name)"
        case .email(let email): return "\(email)"
    }
    case .team(let teamId):
        return "\(teamId.organization)/\(teamId.name)"
    }
}
