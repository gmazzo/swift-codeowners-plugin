import Foundation
import PathKit
import ArgumentParser

#if $RetroactiveAttribute
extension Path: @retroactive Decodable {}
#else
extension Path: Decodable {}
#endif

public extension Path {

    init(_ url: URL) {
        self.init(url.path())
    }
    
    init(from decoder: any Decoder) throws {
        try self.init(String(from: decoder))
    }
    
}
