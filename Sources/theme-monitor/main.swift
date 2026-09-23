import Foundation
import ThemeMonitorCore

func fail(_ message: String, code: Int32) -> Never {
    FileHandle.standardError.write(Data("theme-monitor: \(message)\n".utf8))
    exit(code)
}

let command: Command
do {
    command = try Command.parse(Array(CommandLine.arguments.dropFirst()))
} catch {
    fail("\(error)\n\n\(Command.usage)", code: 64)
}

switch command {
case .help:
    print(Command.usage)
case .version:
    print("theme-monitor \(ThemeMonitor.version)")
case .printCurrent:
    print(Appearance.current(in: .global).rawValue)
case .run(let file):
    let trigger = TriggerFile(url: file ?? TriggerFile.defaultURL())
    let monitor = AppearanceMonitor { appearance in
        do {
            try trigger.write(appearance)
        } catch {
            FileHandle.standardError.write(
                Data("theme-monitor: failed to write \(trigger.url.path): \(error)\n".utf8))
        }
    }
    monitor.start()
    withExtendedLifetime(monitor) {
        RunLoop.main.run()
    }
}
