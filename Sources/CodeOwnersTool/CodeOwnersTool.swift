import Foundation

@main
class CodeOwnersTool {

    static func main() throws {
        let args = CommandLine.arguments
        guard let outputIndex = args.firstIndex(of: "--output"), outputIndex + 1 < args.count else {
            fatalError("Missing --output argument")
        }
        let outputDir = args[outputIndex + 1]
        let inputFiles = Array(args[1..<outputIndex])

        let macro = "static let fileName: String = #file\n"

        for file in inputFiles {
            let content = try String(contentsOfFile: file, encoding: .utf8)
            let newContent = macro + content
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            let outputPath = URL(fileURLWithPath: outputDir).appendingPathComponent(fileName).path
            try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
            try newContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
        }
    }

}
