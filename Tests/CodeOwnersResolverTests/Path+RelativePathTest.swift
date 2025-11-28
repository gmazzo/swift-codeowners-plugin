import Testing
@preconcurrency import PathKit
@testable import CodeOwnersResolver

@Test("Path+relativePathTo", arguments: [
    (target: "foo/bar.txt", base: ".", expected: "foo/bar.txt"),
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
func URL_relativePathTo(target: Path, base: Path, expected: String) {
    let actual = target.relativePathTo(base)

    #expect(expected == actual)
}
