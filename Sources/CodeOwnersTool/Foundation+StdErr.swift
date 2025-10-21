import Foundation

struct StandardError: TextOutputStream, Sendable {
    private static let handle = FileHandle.standardError

    public func write(_ string: String) {
        Self.handle.write(Data(string.utf8))
    }
}

nonisolated(unsafe) var stdErr = StandardError()
