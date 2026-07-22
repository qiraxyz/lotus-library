# Lotus Library

A modern, dependency-free Roblox Luau GUI framework for client-side menus. Lotus uses precise dark surfaces, restrained accent color, compact typography, soft elevation, animated controls, and deterministic cleanup in one portable file.

The framework is maintained as separated source files, while consumers only need one generated file:

```text
dist/lotus-library.lua
```

## Features

- Modern Linear-inspired UI with subtle elevation and smooth tweened feedback
- Custom window title, subtitle, sidebar title, navigation title, and brand glyph
- Sidebar navigation with selectable tabs
- Custom titled sections
- Buttons, toggles, sliders, and progress bars
- Automatic or manually controlled load screen
- Toast notifications
- Window dragging, minimizing, closing, and `RightShift` visibility toggle
- Mouse and touch support for dragging and sliders
- `Signal` and `Maid` primitives for events and deterministic cleanup
- Theme overrides plus eight named dark and light presets
- No external runtime dependencies or network calls in the distribution
- One-file production output with modular source code

## What's new in v1.1

- Refined window chrome, navigation, cards, buttons, toggles, sliders, progress bars, loader, and notifications
- Added subtle window elevation and clearer hover/active hierarchy
- Expanded the theme contract with `SurfaceMuted`, `BorderStrong`, `SubtleText`, `AccentSoft`, `Warning`, and `Shadow`
- Added `Graphite`, `Ocean`, `Emerald`, `Amber`, and `Light` alongside the existing presets
- Added named theme resolution through `Lotus.ResolveTheme`, `Lotus.SetTheme("Name")`, and `Theme = "Name"`

## Install

### Roblox Studio / ModuleScript

1. Create a `ModuleScript` in `ReplicatedStorage` named exactly `lotus-library`.
2. Paste all of `dist/lotus-library.lua` into it.
3. Require it from a `LocalScript`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lotus = require(ReplicatedStorage:WaitForChild("lotus-library"))
```

Lotus creates client UI and must normally be required from a `LocalScript`. A custom GUI parent can be passed with `Parent`.

### Single-file remote loading

Load the published distribution in an environment that supports HTTP source loading:

```lua
local Lotus = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/qiraxyz/lotus-library/refs/tags/v1.1.0/dist/lotus-library.lua"
))()
```

The Lotus distribution itself does not call `HttpGet`, `loadstring`, or any executor-only API.

> **Trust boundary:** downloading and executing remote source grants that artifact permission to run client code. Review it first. The example is pinned to the v1.1 release tag; use a full commit SHA when strict immutability is required. The bundled `script-test/executor.lua` prefers the local v1.1 candidate and rejects a remote response with the wrong version.

For pre-release executor testing, copy `script-test/lotus-library.lua` into the executor workspace as `lotus-library.lua`, then run `script-test/executor.lua`. The remote fallback becomes available after the `v1.1.0` tag is published.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lotus = require(ReplicatedStorage:WaitForChild("lotus-library"))

local window = Lotus.new({
    Title = "Lotus Menu",
    Subtitle = "Universal interface",
    SidebarTitle = "LOTUS",
    NavTitle = "Menu",
    BrandGlyph = "L",
    ToggleKey = Enum.KeyCode.RightShift,
    Theme = "Midnight",
    Size = UDim2.fromOffset(720, 460),
    Loading = {
        Enabled = true,
        Title = "Lotus Library",
        Text = "Preparing controls…",
        Duration = 1.2,
        Auto = true,
    },
})

local mainTab = window:AddTab({
    Name = "Main",
    Icon = "◆",
})

local playerSection = mainTab:AddSection({
    Title = "Player",
})

playerSection:AddButton({
    Title = "Run action",
    Description = "Calls your function safely",
    ButtonText = "Execute",
    Callback = function(button)
        print("Button clicked", button)
        window:Notify({
            Title = "Lotus",
            Description = "The action completed.",
            Duration = 3,
        })
    end,
})

local enabledToggle = playerSection:AddToggle({
    Title = "Enabled",
    Description = "Turns the feature on or off",
    Default = false,
    Callback = function(value, toggle)
        print("Enabled:", value, toggle)
    end,
})

local speedSlider = playerSection:AddSlider({
    Title = "Speed",
    Description = "Choose a numeric value",
    Min = 0,
    Max = 100,
    Default = 25,
    Step = 5,
    Suffix = "%",
    Callback = function(value, slider)
        print("Speed:", value, slider)
    end,
})

local progress = playerSection:AddProgress({
    Title = "Task progress",
    Description = "Updated from your code",
    Min = 0,
    Max = 100,
    Value = 40,
})

progress:Set(75)
enabledToggle:Set(true)
speedSlider:Set(50)
```

A complete copy-paste example is available at `examples/basic.client.lua`.

## Window API

### `Lotus.new(config)` / `Lotus.CreateWindow(config)`

Creates and returns a window.

| Config key | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | string | `"Lotus Menu"` | Main navbar title |
| `Subtitle` | string | `"Ready"` | Text below the main title |
| `SidebarTitle` | string | title or `"LOTUS"` | Sidebar brand title |
| `NavTitle` | string | `"Navigation"` | Sidebar navigation heading |
| `BrandGlyph` | string | `"L"` | Text inside the accent brand mark |
| `GuiName` | string | `"LotusLibrary"` | Generated `ScreenGui` name |
| `Parent` | Instance | local `PlayerGui` | Explicit UI parent |
| `SingleInstance` | boolean | `true` | Replaces a GUI with the same name |
| `DisplayOrder` | number | `50` | `ScreenGui.DisplayOrder` |
| `Position` | UDim2 | centered | Initial window position |
| `Size` | UDim2 | `720 x 460` | Initial window size |
| `SidebarWidth` | number | `188` | Sidebar width in pixels |
| `ToggleKey` | Enum.KeyCode or false | `RightShift` | Show/hide hotkey; use `false` to disable |
| `Theme` | string/table | active theme | Preset name or per-window color overrides |
| `Loading` | boolean/table | enabled | Load screen settings |

Methods:

```lua
window:AddTab(options)                   -- returns Tab
window:SelectTab(tabOrName)              -- returns selected Tab
window:SetTitle(title, optionalSubtitle)
window:SetSidebarTitle(title, optionalNavTitle)
window:SetVisible(boolean)
window:SetMinimized(boolean)
window:SetLoadingProgress(0To100, optionalText)
window:FinishLoading()
window:Notify(options)                   -- returns notification Frame
window:Destroy()
```

`window.VisibilityChanged` is a Lotus signal with `:Connect`, `:Once`, and `:Wait`.

## Load screen

Automatic loading is enabled by default. Disable it with:

```lua
local window = Lotus.new({ Loading = false })
```

Manual mode:

```lua
local window = Lotus.new({
    Loading = {
        Auto = false,
        Title = "Loading",
        Text = "Starting…",
    },
})

window:SetLoadingProgress(25, "Loading settings…")
window:SetLoadingProgress(70, "Creating controls…")
window:SetLoadingProgress(100, "Ready")
window:FinishLoading()
```

## Tabs and sections

```lua
local tab = window:AddTab({ Name = "Settings", Icon = "⚙" })
-- String shorthand is also valid:
local otherTab = window:AddTab("Other")

local section = tab:AddSection({ Title = "Interface" })
local compactSection = tab:AddSection("Compact section")

tab:SetTitle("Preferences")
tab:Select()
section:SetTitle("Appearance")
```

## Controls

### Button

```lua
local button = section:AddButton({
    Title = "Save",
    Description = "Save current settings",
    ButtonText = "Save",
    Callback = function(control) end,
})

button:SetText("Saved")
button:Fire()
button:SetVisible(false)
button:Destroy()
```

### Toggle

```lua
local toggle = section:AddToggle({
    Title = "Auto mode",
    Default = true,
    Callback = function(value, control) end,
})

toggle:Set(false)        -- updates UI and calls Callback
toggle:Set(true, true)   -- silent: does not call Callback
print(toggle:Get())

toggle.Changed:Connect(function(value)
    print(value)
end)
```

### Slider

```lua
local slider = section:AddSlider({
    Title = "Volume",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Step = 0.05,
    Suffix = "",
    Callback = function(value, control) end,
})

slider:Set(0.75)
slider:Set(0.25, true) -- silent callback
print(slider:Get())
```

### Progress bar

```lua
local progress = section:AddProgress({
    Title = "Download",
    Min = 0,
    Max = 100,
    Value = 0,
    Color = Color3.fromRGB(56, 189, 148),
})

progress:Set(50)
progress:Set(75, "3 / 4")
print(progress:Get())
```

Every control supports `:SetVisible(boolean)` and `:Destroy()`.

## Notifications

```lua
window:Notify({
    Title = "Saved",
    Description = "Your settings were stored.",
    Duration = 3,
    Color = Color3.fromRGB(56, 189, 148),
})
```

String shorthand is supported: `window:Notify("Saved")`.

## Themes

Pass a preset name directly when creating a window:

```lua
local window = Lotus.new({
    Theme = "Ocean",
})
```

Built-in presets:

| Preset | Appearance |
| --- | --- |
| `Default` | Near-black surfaces with restrained indigo accents |
| `Midnight` | Deep navy surfaces with vivid periwinkle accents |
| `Rose` | Warm black surfaces with rose-pink accents |
| `Graphite` | Neutral monochrome surfaces and silver accents |
| `Ocean` | Blue-black surfaces with sky-blue accents |
| `Emerald` | Green-black surfaces with emerald accents |
| `Amber` | Warm brown-black surfaces with amber accents |
| `Light` | Soft gray canvas, white surfaces, and indigo accents |

Preset tables remain available as `Lotus.Themes.Default`, `Lotus.Themes.Ocean`, and so on. `Lotus.ResolveTheme(nameOrTable)` returns a safe copy of a complete resolved theme.

Set the global default for windows created afterward:

```lua
Lotus.SetTheme("Graphite")

-- Table overrides are still supported.
Lotus.SetTheme({
    Accent = Color3.fromRGB(34, 211, 238),
    AccentHover = Color3.fromRGB(103, 232, 249),
})
```

### Theme tokens

| Group | Keys |
| --- | --- |
| Surfaces | `Background`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `SurfaceMuted` |
| Borders and depth | `Border`, `BorderStrong`, `Overlay`, `Shadow` |
| Typography | `Text`, `MutedText`, `SubtleText` |
| Accent | `Accent`, `AccentHover`, `AccentSoft`, `AccentText` |
| Status | `Success`, `Warning`, `Danger` |

Tables passed to `Lotus.SetTheme` inherit missing keys from `Default`; per-window override tables inherit from the active global theme. `Lotus.SetTheme` affects future windows only, while `Theme` customizes one new window.

## Project structure

```text
lotus-library/
├─ src/
│  ├─ Components/
│  │  ├─ Base.lua
│  │  ├─ Button.lua
│  │  ├─ Toggle.lua
│  │  ├─ Slider.lua
│  │  └─ Progress.lua
│  ├─ Util/
│  │  ├─ Maid.lua
│  │  ├─ Signal.lua
│  │  └─ Tween.lua
│  ├─ Prelude.lua
│  ├─ Theme.lua
│  ├─ Section.lua
│  ├─ Tab.lua
│  ├─ Window.lua
│  └─ init.lua
├─ scripts/build.py
├─ tests/test_build.py
├─ examples/basic.client.lua
├─ script-test/executor.lua
├─ lotus.project.json
└─ dist/lotus-library.lua
```

The ordered module manifest is `lotus.project.json`. Source fragments are bundled in that exact order and surrounded by region markers for debugging.

## Development

Requirements: Python 3.9+.

Build the one-file distribution:

```bash
python scripts/build.py
```

Verify that the checked-in distribution is current:

```bash
python scripts/build.py --check
```

Run tests:

```bash
python -m unittest tests/test_build.py -v
```

Never edit `dist/lotus-library.lua` directly. Edit `src/`, run the build, and verify the output.

## Runtime scope

Lotus is a UI framework. It does not include game-specific automation, remotes, movement changes, or bypass logic. Feature behavior belongs in callbacks supplied by the consuming script. Use it only where you have authorization and follow Roblox's rules and the rules of the experience.

## License

MIT. See `LICENSE`.
