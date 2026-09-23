import Foundation
import Testing

@testable import ThemeMonitorCore

@Suite struct AppearanceMonitorTests {
    @Test func reportsTheInitialAppearanceOnStart() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Dark", forKey: Appearance.interfaceStyleKey)
        var reported: [Appearance] = []
        let monitor = AppearanceMonitor(defaults: scratch.defaults) { reported.append($0) }

        monitor.start()
        defer { monitor.stop() }

        #expect(reported == [.dark])
    }

    @Test func reportsEachChangeThroughKVO() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        var reported: [Appearance] = []
        let monitor = AppearanceMonitor(defaults: scratch.defaults) { reported.append($0) }

        monitor.start()
        defer { monitor.stop() }
        scratch.defaults.set("Dark", forKey: Appearance.interfaceStyleKey)
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)

        #expect(reported == [.light, .dark, .light])
        #expect(monitor.current == .light)
    }

    @Test func ignoresWritesThatDoNotChangeTheAppearance() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        var reported: [Appearance] = []
        let monitor = AppearanceMonitor(defaults: scratch.defaults) { reported.append($0) }

        monitor.start()
        defer { monitor.stop() }
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        scratch.defaults.set("Anything", forKey: Appearance.interfaceStyleKey)

        #expect(reported == [.light])
    }

    @Test func stopsReportingAfterStop() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        var reported: [Appearance] = []
        let monitor = AppearanceMonitor(defaults: scratch.defaults) { reported.append($0) }

        monitor.start()
        monitor.stop()
        scratch.defaults.set("Dark", forKey: Appearance.interfaceStyleKey)

        #expect(reported == [.light])
    }

    @Test func startAndStopAreIdempotent() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        var reported: [Appearance] = []
        let monitor = AppearanceMonitor(defaults: scratch.defaults) { reported.append($0) }

        monitor.start()
        monitor.start()
        monitor.stop()
        monitor.stop()

        #expect(reported == [.light])
    }
}
