import Testing
import Foundation
@testable import CodeOwnersTool

@Suite("Settings tests")
struct SettingsTest {
    @Test(arguments: [
        ("{}", Settings()),
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
        """, Settings(
            codeowners: Settings.CodeOwners(
                root: "aRoot",
                file: "aFile"
            ),
            renames: [ "foo" : "bar" ],
            quiet: true,
            verbose: true
        )),
    ])
    func decodeJSON(params: (json: String, expected: Settings)) throws {
        let actual = try JSONDecoder().decode(Settings.self, from: params.json.data(using: .utf8)!)
        
        #expect(actual == params.expected)
    }
}
