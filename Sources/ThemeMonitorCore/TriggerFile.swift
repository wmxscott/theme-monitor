import Foundation

public struct TriggerFile: Sendable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    /// `$XDG_DATA_HOME/theme-monitor/theme-change.trigger`, falling back to
    /// `~/.local/share` when `XDG_DATA_HOME` is unset or not absolute.
    public static func defaultURL(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        home: URL = FileManager.default.homeDirectoryForCurrentUser
    ) -> URL {
        let dataHome: URL
        if let xdg = environment["XDG_DATA_HOME"], xdg.hasPrefix("/") {
            dataHome = URL(fileURLWithPath: xdg, isDirectory: true)
        } else {
            dataHome = home.appendingPathComponent(".local/share", isDirectory: true)
        }
        return dataHome.appendingPathComponent("theme-monitor/theme-change.trigger")
    }

    /// Writes the appearance in place. An atomic write (temp file + rename)
    /// would replace the inode and silently detach watchers on the file.
    public func write(_ appearance: Appearance) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try appearance.rawValue.write(to: url, atomically: false, encoding: .utf8)
    }
}
