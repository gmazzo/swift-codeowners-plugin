![GitHub](https://img.shields.io/github/license/gmazzo/swift-codeowners-plugin)
[![SPM](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fgmazzo%2Fswift-codeowners-plugin%2Freleases%2Flatest&query=tag_name&logo=https%3A%2F%2Fswiftpackageregistry.com%2Fandroid-icon-192x192.png&label=SPM&color=%23f05138)](https://swiftpackageregistry.com/gmazzo/swift-codeowners-plugin)
[![Build Status](https://github.com/gmazzo/swift-codeowners-plugin/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/gmazzo/swift-codeowners-plugin/actions/workflows/ci-cd.yaml)
[![Coverage](https://codecov.io/gh/gmazzo/swift-codeowners-plugin/branch/main/graph/badge.svg?token=ExYkP1Q9oE)](https://codecov.io/gh/gmazzo/swift-codeowners-plugin)
[![Users](https://img.shields.io/badge/users_by-Sourcegraph-purple)](https://sourcegraph.com/search?q=content:gmazzo/swift-codeowners-plugin+-repo:github.com/gmazzo/swift-codeowners-plugin)

[![Contributors](https://contrib.rocks/image?repo=gmazzo/swift-codeowners-plugin)](https://github.com/gmazzo/swift-codeowners-plugin/graphs/contributors)

# swift-codeowners-plugin

A Swift compiler plugin to propagate CODEOWNERS attribution to Swift types

# Usage

Setup the compiler plugin and the runtime library in your project: 
In your `Package.swift` add the plugin dependency:

```swift
let package = Package(
    name: "MyProject",
    dependencies: [
        .package(url: "https://github.com/gmazzo/swift-codeowners-plugin", from: "x.y.z"),
    ],
    targets: [
        .target(
            name: "MyProjectTarget", 
            dependencies: [
                .product(name: "CodeOwnersAPI", package: "swift-codeowners-plugin")
            ],
            plugins: [
                .plugin(name: "CodeOwnersPlugin", package: "swift-codeowners-plugin")
            ]
        )
    ]
)
```

Then you can use the `codeOwnersOf` function on any `struct`, `class` or `enum` to query their owners at runtime:

```swift
struct MyType {
    func printOwner() {
        print("This type is owned by \(codeOwnersOf(self))") // or
        print("This type is owned by \(codeOwnersOf(MyType.self))") // or
        print("This type is owned by \(codeOwnersOf(MyType()))") // or
    }
}
```

# The CODEOWNERS file

The expected format is the same
as [GitHub's](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-syntax)
and it can be located at any of the following paths:

- `$rootDir/CODEOWNERS`
- `$rootDir/.github/CODEOWNERS`
- `$rootDir/.gitlab/CODEOWNERS`
- `$rootDir/docs/CODEOWNERS`

Where `rootDir` is either project's or GIT's root directory
