# theme-monitor

[![CI](https://github.com/wmxscott/theme-monitor/actions/workflows/ci.yml/badge.svg)](https://github.com/wmxscott/theme-monitor/actions/workflows/ci.yml)

A tiny macOS background service that writes the system appearance, `light` or `dark`, to a file the moment it changes.

Terminal programs have no clean way to follow macOS dark mode. They can shell out to `defaults read -g AppleInterfaceStyle` every time they need to know, or poll it on a timer. theme-monitor listens for the change instead and keeps one small file up to date. Your editor, prompt, pager or script can read that file cheaply, or watch it and switch themes as soon as the system does.

```console
$ cat ~/.local/share/theme-monitor/theme-change.trigger
dark
```

## Install

### Homebrew

```sh
brew install wmxscott/tap/theme-monitor
brew services start theme-monitor
```

`brew services` starts it now and at every login. It restarts automatically if it ever exits.

### From source

Needs macOS 13 or later and a Swift 6 toolchain (Xcode or the Command Line Tools).

```sh
git clone https://github.com/wmxscott/theme-monitor.git
cd theme-monitor
swift build --configuration release
install -d ~/.local/bin
install "$(swift build --configuration release --show-bin-path)/theme-monitor" ~/.local/bin/
```

To run it at login, load the example launch agent. It expects the binary in `~/.local/bin`:

```sh
cp contrib/io.github.wmxscott.theme-monitor.plist ~/Library/LaunchAgents/
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/io.github.wmxscott.theme-monitor.plist
```

To remove it again:

```sh
launchctl bootout "gui/$(id -u)/io.github.wmxscott.theme-monitor"
rm ~/Library/LaunchAgents/io.github.wmxscott.theme-monitor.plist ~/.local/bin/theme-monitor
```

## Usage

```
theme-monitor [--file <path>]
theme-monitor --print | --version | --help
```

| Option | |
|---|---|
| *(none)* | Write the appearance to the trigger file, then keep running and rewrite it on every change |
| `--file <path>` | Write to `<path>` instead of the default location |
| `--print` | Print the current appearance and exit, without touching any file |
| `-V`, `--version` | Print the version |
| `-h`, `--help` | Print usage |

## The trigger file

The file is the whole interface, so its behaviour is fixed:

- **Location:** `$XDG_DATA_HOME/theme-monitor/theme-change.trigger`, or `~/.local/share/theme-monitor/theme-change.trigger` when `XDG_DATA_HOME` is unset. launchd services don't inherit your shell's environment, so with Homebrew or the example launch agent it's always the `~/.local/share` path unless you pass `--file`.
- **Contents:** exactly `light` or `dark`. No trailing newline, nothing else.
- **When it's written:** once at startup, then only when the appearance actually changes.
- **How it's written:** in place, keeping the same file. Tools that watch the file itself, not just its directory, keep receiving events. The parent directory is created if it's missing.

The file is left in place when theme-monitor stops. It then holds the last appearance it saw, which may be out of date.

## Reacting to changes

### Read it once

For anything that starts fresh each time, like a shell prompt, a pager wrapper or a script, read the file when it runs:

```sh
theme="$(cat ~/.local/share/theme-monitor/theme-change.trigger 2>/dev/null || echo light)"
```

### Neovim

Watch the file and set `background` whenever it changes:

```lua
local trigger = vim.fn.expand("~/.local/share/theme-monitor/theme-change.trigger")

local function apply()
  local file = io.open(trigger)
  if not file then
    return
  end
  local mode = file:read("*l")
  file:close()
  if mode == "light" or mode == "dark" then
    vim.o.background = mode
  end
end

apply()

local watcher = vim.uv.new_fs_event()
watcher:start(vim.fs.dirname(trigger), {}, vim.schedule_wrap(function(err, name)
  if not err and name == vim.fs.basename(trigger) then
    apply()
  end
end))
```

Colour schemes that define separate light and dark palettes switch on the change to `background`.

### Anything else

Any file watcher works. With [fswatch](https://github.com/emcrisostomo/fswatch):

```sh
fswatch -0 ~/.local/share/theme-monitor/theme-change.trigger | while read -r -d '' _; do
  echo "appearance is now $(cat ~/.local/share/theme-monitor/theme-change.trigger)"
done
```

## How it works

macOS records dark mode in the global preference `AppleInterfaceStyle`: it's `Dark` in dark mode and absent in light mode, and Auto mode updates it as the day goes on. theme-monitor observes that key with key-value observing, so it wakes only when the value changes and uses no CPU in between. When the appearance differs from the last one it wrote, it rewrites the file.

It deliberately doesn't use `NSApp.effectiveAppearance`. On macOS 26 and later that value stops updating for processes without a window, so a background service watching it would miss every change after the first.

## Troubleshooting

- **Is it running?** `brew services info theme-monitor`, or for the example launch agent, `launchctl print "gui/$(id -u)/io.github.wmxscott.theme-monitor"`.
- **What does it see?** `theme-monitor --print` shows the appearance it would write.
- **The file never changes:** check the path your tool reads matches where the service writes. A service started by launchd uses `~/.local/share` even if your shell sets `XDG_DATA_HOME`.
- **Logs:** Homebrew sends output to `$(brew --prefix)/var/log/theme-monitor.log`. theme-monitor only writes there when it fails to write the file.

## Development

```sh
swift build
swift test                                          # needs Xcode, not just the Command Line Tools
swift format lint --strict --recursive Sources Tests Package.swift
```

`swift test` uses Swift Testing, whose macros ship with Xcode. With only the Command Line Tools installed, `swift build` works but the tests don't compile.

The code is split so the parts worth testing don't depend on the real system setting:

| File | Does |
|---|---|
| `Appearance.swift` | Maps `AppleInterfaceStyle` to `light` / `dark` |
| `TriggerFile.swift` | Resolves the default path and writes the file in place |
| `AppearanceMonitor.swift` | Observes a `UserDefaults` and reports changes |
| `Command.swift` | Parses arguments |
| `main.swift` | Wires them to the real global preferences |

The tests point `AppearanceMonitor` at a throwaway `UserDefaults` suite, so they exercise real key-value observing without changing your appearance.

## License

[MIT](LICENSE)
