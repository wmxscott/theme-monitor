// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "theme-monitor",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "theme-monitor", targets: ["theme-monitor"])
    ],
    targets: [
        .target(name: "ThemeMonitorCore"),
        .executableTarget(name: "theme-monitor", dependencies: ["ThemeMonitorCore"]),
        .testTarget(name: "ThemeMonitorCoreTests", dependencies: ["ThemeMonitorCore"]),
    ]
)
