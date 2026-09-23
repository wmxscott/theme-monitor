import Foundation
import Testing

@testable import ThemeMonitorCore

@Suite struct AppearanceTests {
    @Test func darkStyleMapsToDark() {
        #expect(Appearance(interfaceStyle: "Dark") == .dark)
    }

    @Test(arguments: [nil, "Light", "dark", "", "Auto"] as [String?])
    func anythingElseMapsToLight(style: String?) {
        #expect(Appearance(interfaceStyle: style) == .light)
    }

    @Test func rawValuesAreTheFileContract() {
        #expect(Appearance.allCases.map(\.rawValue) == ["light", "dark"])
    }

    @Test func readsTheInterfaceStyleKey() throws {
        let scratch = try ScratchDefaults()
        scratch.defaults.set("Dark", forKey: Appearance.interfaceStyleKey)
        #expect(Appearance.current(in: scratch.defaults) == .dark)
        scratch.defaults.set("Light", forKey: Appearance.interfaceStyleKey)
        #expect(Appearance.current(in: scratch.defaults) == .light)
    }
}
