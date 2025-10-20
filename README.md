![GitHub](https://img.shields.io/github/license/gmazzo/swift-codeowners-plugin)
[![SPM](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fgmazzo%2Fswift-codeowners-plugin%2Freleases%2Flatest&query=tag_name&logo=https%3A%2F%2Fswiftpackageregistry.com%2Fandroid-icon-192x192.png&label=SPM&color=%23f05138)](https://swiftpackageregistry.com/gmazzo/swift-codeowners-plugin)
[![Build Status](https://github.com/gmazzo/swift-codeowners-plugin/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/gmazzo/swift-codeowners-plugin/actions/workflows/ci-cd.yaml)
[![Coverage](https://codecov.io/gh/gmazzo/swift-codeowners-plugin/branch/main/graph/badge.svg?token=ExYkP1Q9oE)](https://codecov.io/gh/gmazzo/swift-codeowners-plugin)
[![Users](https://img.shields.io/badge/users_by-Sourcegraph-purple)](https://sourcegraph.com/search?q=content:gmazzo/swift-codeowners-plugin+-repo:github.com/gmazzo/swift-codeowners-plugin)

[![Contributors](https://contrib.rocks/image?repo=gmazzo/swift-codeowners-plugin)](https://github.com/gmazzo/swift-codeowners-plugin/graphs/contributors)

# swift-codeowners-plugin
A Swift compiler plugin to propagate CODEOWNERS attribution to Swift types

## Usage
First setup it up with your package manager:

### With [Swift Package Manager](https://github.com/apple/swift-package-manager)
Setup the compiler plugin and the runtime library in your project: 
In your `Package.swift` add the plugin dependency:

```swift
let package = Package(
    name: "MyProject",
    dependencies: [
        .package(url: "https://github.com/gmazzo/swift-codeowners-plugin", from: "x.y.z"), // check latest version
    ],
    targets: [
        .target(
            name: "MyProjectTarget", 
            dependencies: [
                .product(name: "CodeOwnersCore", package: "swift-codeowners-plugin")
            ],
            plugins: [
                .plugin(name: "CodeOwnersPlugin", package: "swift-codeowners-plugin")
            ]
        )
    ]
)
```

### With [CocoaPods](https://github.com/CocoaPods/CocoaPods)

Add the `Core` dependency in your `.podspec` file:
```ruby
pod 'CodeOwnersPlugin/Core', '~> x.y.z', :source => 'https://github.com/gmazzo/swift-codeowners-plugin.git'

post_install do |installer|
  codeownersGenerate(installer)
end

def codeowners_generate(installer)
  development_pods_names = installer.sandbox.development_pods.keys
  tool_path = installer.sandbox.pod_dir('CodeOwnersPlugin/Core')

  file = installer.pods_project.new_file('$DERIVED_SOURCES_DIR/CodeOwners.swift')

  phase = installer.pods_project.new(Project::Object::PBXShellScriptBuildPhase)
  phase.name = 'CodeOwners attribution'
  phase.shell_script = "#{tool_path}/.build/release/CodeOwnersTool \"$PODS_TARGET_SRCROOT\" --output-file \"$DERIVED_SOURCES_DIR/CodeOwners.swift\""
  phase.input_paths = ['$PODS_TARGET_SRCROOT']
  phase.output_paths = ['$DERIVED_SOURCES_DIR/CodeOwners.swift']

  installer.pods_project.targets.each do |target|
    next unless target.is_a?(Project::Object::PBXNativeTarget)
    next unless development_pods_names.include?(target.name)

    target.build_phases.insert(0, phase)
    target.add_file_references([file])
  end
end
```

> [!NOTE]
> The CodeOwners tool will to be built locally as part of the pod installation process.
> Make sure you have `swift` command line tools installed.

### Reading CodeOwners with the runtime API
After setting up the plugin to decorate you code, any `struct`, `class` or `enum` will implement `HasCodeOwners` protocol
exposing a `codeOwners` property:
```swift
struct MyType {
    func printOwner() {
        print("This type is owned by \(self.codeOwners)")
    }
}
```

> [!NOTE]
> Types and instances will have the same `codeOwners` value.
> i.e. `MyType.codeOwners` and `MyType().codeOwners` will return the same result.

# The CODEOWNERS file

The expected format is the same
as [GitHub's](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#codeowners-syntax)
and it can be located at any of the following paths:

- `$rootDir/CODEOWNERS`
- `$rootDir/.github/CODEOWNERS`
- `$rootDir/.gitlab/CODEOWNERS`
- `$rootDir/docs/CODEOWNERS`

Where `rootDir` is either project's or GIT's root directory
