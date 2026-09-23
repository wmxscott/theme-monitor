import Foundation
import Testing

@testable import ThemeMonitorCore

@Suite struct CommandTests {
    @Test func noArgumentsRunsWithTheDefaultFile() throws {
        #expect(try Command.parse([]) == .run(file: nil))
    }

    @Test func fileOverridesTheOutputPath() throws {
        #expect(try Command.parse(["--file", "/tmp/x"]) == .run(file: URL(fileURLWithPath: "/tmp/x")))
    }

    @Test func fileExpandsATilde() throws {
        let expected = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("x").path
        #expect(try Command.parse(["--file", "~/x"]) == .run(file: URL(fileURLWithPath: expected)))
    }

    @Test(arguments: [
        (["--print"], Command.printCurrent),
        (["--version"], .version),
        (["-V"], .version),
        (["--help"], .help),
        (["-h"], .help),
        (["--file", "/tmp/x", "--print"], .printCurrent),
    ])
    func parsesFlags(arguments: [String], expected: Command) throws {
        #expect(try Command.parse(arguments) == expected)
    }

    @Test(arguments: [["--file"], ["--file", ""], ["--file", "--print"]])
    func fileWithoutAPathIsAnError(arguments: [String]) {
        #expect(throws: Command.UsageError(description: "--file needs a path")) {
            try Command.parse(arguments)
        }
    }

    @Test func unknownArgumentsAreAnError() {
        #expect(throws: Command.UsageError(description: "unknown argument '--nope'")) {
            try Command.parse(["--nope"])
        }
    }

    @Test func versionIsSemantic() {
        #expect(ThemeMonitor.version.split(separator: ".").count == 3)
    }
}
