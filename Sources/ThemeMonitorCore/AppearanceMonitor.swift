import Foundation

/// Reports the current appearance once on `start()`, then again on every change.
///
/// Observes `AppleInterfaceStyle` through key-value observing on the global
/// defaults. `NSApp.effectiveAppearance` is not used: it stops updating for
/// non-GUI processes on macOS 26 and later.
public final class AppearanceMonitor: NSObject {
    public private(set) var current: Appearance

    private let defaults: UserDefaults
    private let onChange: (Appearance) -> Void
    private var observing = false

    public init(defaults: UserDefaults = .global, onChange: @escaping (Appearance) -> Void) {
        self.defaults = defaults
        self.onChange = onChange
        self.current = Appearance.current(in: defaults)
        super.init()
    }

    deinit {
        stop()
    }

    public func start() {
        guard !observing else { return }
        observing = true
        current = Appearance.current(in: defaults)
        onChange(current)
        defaults.addObserver(self, forKeyPath: Appearance.interfaceStyleKey, options: [.new], context: nil)
    }

    public func stop() {
        guard observing else { return }
        observing = false
        defaults.removeObserver(self, forKeyPath: Appearance.interfaceStyleKey)
    }

    override public func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard keyPath == Appearance.interfaceStyleKey else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        refresh()
    }

    /// Re-reads the appearance and reports it only if it changed. KVO can fire
    /// for writes that leave the value the same.
    func refresh() {
        let latest = Appearance.current(in: defaults)
        guard latest != current else { return }
        current = latest
        onChange(latest)
    }
}
