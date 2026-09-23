import Foundation

public enum Appearance: String, Sendable, CaseIterable {
    case light
    case dark

    /// The global defaults key macOS sets to `"Dark"` in dark mode and removes in light mode.
    public static let interfaceStyleKey = "AppleInterfaceStyle"

    public init(interfaceStyle: String?) {
        self = interfaceStyle == "Dark" ? .dark : .light
    }

    public static func current(in defaults: UserDefaults) -> Appearance {
        Appearance(interfaceStyle: defaults.string(forKey: interfaceStyleKey))
    }
}

extension UserDefaults {
    /// The global domain, where macOS keeps `AppleInterfaceStyle`.
    public static var global: UserDefaults {
        UserDefaults(suiteName: ".GlobalPreferences")!
    }
}
