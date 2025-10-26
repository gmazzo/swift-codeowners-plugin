import Testing
import Foundation
@testable import CodeOwnersResolver

@Suite("Inputs tests")
struct InputsTest {
    
    @Test("SettingsFile can be parsed", arguments: [
        ("{}", SettingsFile(
            codeowners: nil,
            renames: nil,
            verbose: nil,
            quiet: nil
        )),
        ("""
        {
            "codeowners": {
                "root": "aRoot",
                "file": "aFile"
            },
            "renames": {
                "foo": "bar",
            },
            "quiet": true,
            "verbose": true
        }
        """, SettingsFile(
            codeowners: SettingsFile.CodeOwners(
                root: "aRoot",
                file: "aFile"
            ),
            renames: [ "foo" : "bar" ],
            verbose: true,
            quiet: true
        )),
    ])
    func decodeJSON(params: (json: String, expected: SettingsFile)) throws {
        let actual = try JSONDecoder().decode(SettingsFile.self, from: params.json.data(using: .utf8)!)
        
        #expect(actual == params.expected)
    }
    
}
