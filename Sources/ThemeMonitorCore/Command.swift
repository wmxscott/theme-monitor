import Foundation

public enum ThemeMonitor {
    public static let version = "1.0.0"
}

public enum Command: Equatable, Sendable {
    case run(file: URL?)
    case printCurrent
    case version
    case help

    public static let usage = """
        Usage: theme-monitor [--file <path>]
               theme-monitor --print | --version | --help

        Writes the macOS appearance ("light" or "dark") to a file, once at startup
        and again on every change, then keeps running.

        Options:
          --file <path>   Write here instead of the default:
                          $XDG_DATA_HOME/theme-monitor/theme-change.trigger
                          (~/.local/share/... when XDG_DATA_HOME is unset)
          --print         Print the current appearance and exit
          -V, --version   Print the version and exit
          -h, --help      Print this help and exit
        """

    public struct UsageError: Error, Equatable, CustomStringConvertible {
        public let description: String
    }

    public static func parse(_ arguments: [String]) throws -> Command {
        var file: URL?
        var iterator = arguments.makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "-h", "--help":
                return .help
            case "-V", "--version":
                return .version
            case "--print":
                return .printCurrent
            case "--file":
                guard let path = iterator.next(), !path.isEmpty, !path.hasPrefix("-") else {
                    throw UsageError(description: "--file needs a path")
                }
                file = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
            default:
                throw UsageError(description: "unknown argument '\(argument)'")
            }
        }
        return .run(file: file)
    }
}
