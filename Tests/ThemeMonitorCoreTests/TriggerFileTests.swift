import Foundation
import Testing

@testable import ThemeMonitorCore

@Suite struct TriggerFileTests {
    let home = URL(fileURLWithPath: "/Users/someone", isDirectory: true)

    @Test func defaultsToLocalShare() {
        let url = TriggerFile.defaultURL(environment: [:], home: home)
        #expect(url.path == "/Users/someone/.local/share/theme-monitor/theme-change.trigger")
    }

    @Test func honoursAbsoluteXDGDataHome() {
        let url = TriggerFile.defaultURL(environment: ["XDG_DATA_HOME": "/tmp/data"], home: home)
        #expect(url.path == "/tmp/data/theme-monitor/theme-change.trigger")
    }

    @Test(arguments: ["relative/data", ""])
    func ignoresNonAbsoluteXDGDataHome(value: String) {
        let url = TriggerFile.defaultURL(environment: ["XDG_DATA_HOME": value], home: home)
        #expect(url.path == "/Users/someone/.local/share/theme-monitor/theme-change.trigger")
    }

    @Test func createsMissingDirectories() throws {
        let scratch = try ScratchDirectory()
        let file = TriggerFile(url: scratch.url.appendingPathComponent("a/b/theme-change.trigger"))
        try file.write(.dark)
        #expect(try String(contentsOf: file.url, encoding: .utf8) == "dark")
    }

    @Test func writesTheBareWordWithoutANewline() throws {
        let scratch = try ScratchDirectory()
        let file = TriggerFile(url: scratch.url.appendingPathComponent("theme-change.trigger"))
        for appearance in Appearance.allCases {
            try file.write(appearance)
            #expect(try Data(contentsOf: file.url) == Data(appearance.rawValue.utf8))
        }
    }

    @Test func shorterValueTruncatesTheLongerOne() throws {
        let scratch = try ScratchDirectory()
        let file = TriggerFile(url: scratch.url.appendingPathComponent("theme-change.trigger"))
        try file.write(.light)
        try file.write(.dark)
        #expect(try String(contentsOf: file.url, encoding: .utf8) == "dark")
    }

    @Test func rewritesInPlaceKeepingTheInode() throws {
        let scratch = try ScratchDirectory()
        let file = TriggerFile(url: scratch.url.appendingPathComponent("theme-change.trigger"))
        try file.write(.light)
        let before = try inode(of: file.url)
        try file.write(.dark)
        try file.write(.light)
        #expect(try inode(of: file.url) == before)
    }

    private func inode(of url: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return try #require(attributes[.systemFileNumber] as? UInt64)
    }
}
