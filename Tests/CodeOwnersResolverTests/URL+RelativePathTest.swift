import Testing
import Foundation
@testable import CodeOwnersResolver

@Test("URL+relativePathTo", arguments: [
    (target: "/usr/X11/agent/47.gz", base: "/usr/X11", expected: "agent/47.gz"),
    (target: "/usr/share/man/meltdown.1", base: "/usr/share/cups", expected: "../man/meltdown.1"),
    (target: "/var/logs/x/y/z/log.txt", base: "/var/logs", expected: "x/y/z/log.txt"),
    (target: "/usr/embedded.jpg", base: "/usr/main.html", expected: "../embedded.jpg"),
    (target: "/usr/embedded.jpg", base: "/usr", expected: "embedded.jpg"),
    (target: "~/Downloads/resources", base: "~/", expected: "Downloads/resources"),
    (target: "~/Downloads/embedded.jpg", base: "~/Downloads/main.html", expected: "../embedded.jpg"),
    (target: "/private/var/logs/x/y/z/log.txt", base: "/var/logs", expected: "../../private/var/logs/x/y/z/log.txt"),
    (target: "file:///private/tmp/foo/Foo.swift", base: "file:///private/tmp/", expected: "foo/Foo.swift")
])
func URL_relativePathTo(target: String, base: String, expected: String) {
    let targetURL = URL(filePath: target)
    let baseURL = URL(filePath: base)
    let actual = targetURL.relativePathTo(baseURL)

    #expect(expected == actual)
}
