import Foundation
import Testing

/// A throwaway defaults suite, removed on deinit. Suites fall back to the
/// global domain, so tests set `AppleInterfaceStyle` explicitly rather than
/// relying on it being absent.
final class ScratchDefaults {
    let name = "theme-monitor.tests.\(UUID().uuidString)"
    let defaults: UserDefaults

    init() throws {
        defaults = try #require(UserDefaults(suiteName: name))
    }

    deinit {
        defaults.removePersistentDomain(forName: name)
    }
}

/// A temporary directory, removed on deinit.
final class ScratchDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("theme-monitor-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}
