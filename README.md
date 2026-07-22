# Lotus Library

A modern, dependency-free Roblox Luau GUI framework for client-side menus. Lotus has a load screen, animated progress bars, sidebar navigation, tabs, sections, buttons, toggles, sliders, notifications, draggable windows, custom titles, themes, and deterministic cleanup.

The framework is maintained as separated source files, while consumers only need one generated file:

```text
dist/lotus-library.lua
```

## Features

- Modern dark UI with smooth tweened feedback
- Custom window title, subtitle, sidebar title, navigation title, and brand glyph
- Sidebar navigation with selectable tabs
- Custom titled sections
- Buttons, toggles, sliders, and progress bars
- Automatic or manually controlled load screen
- Toast notifications
- Window dragging, minimizing, closing, and `RightShift` visibility toggle
- Mouse and touch support for dragging and sliders
- `Signal` and `Maid` primitives for events and deterministic cleanup
- Theme overrides plus Default, Midnight, and Rose presets
- No external runtime dependencies or network calls in the distribution
- One-file production output with modular source code

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

Host `dist/lotus-library.lua` at your own URL, then load that single file in an environment that supports HTTP source loading:

```lua
local Lotus = loadstring(game:HttpGet("https://your-domain.example/lotus-library.lua"))()
```

The Lotus distribution itself does not call `HttpGet`, `loadstring`, or any executor-only API.

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
| `SidebarWidth` | number | `184` | Sidebar width in pixels |
| `ToggleKey` | Enum.KeyCode or false | `RightShift` | Show/hide hotkey; use `false` to disable |
| `Theme` | table | active theme | Per-window color overrides |
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

Set a global theme for windows created afterward:

```lua
Lotus.SetTheme({
    Accent = Color3.fromRGB(34, 211, 238),
    AccentHover = Color3.fromRGB(103, 232, 249),
})
```

Use a preset per window:

```lua
local window = Lotus.new({
    Theme = Lotus.Themes.Midnight,
})
```

Available color keys:

`Background`, `Surface`, `SurfaceAlt`, `SurfaceHover`, `Border`, `Text`, `MutedText`, `Accent`, `AccentHover`, `AccentText`, `Success`, `Danger`, and `Overlay`.

`Lotus.SetTheme` affects future windows. Pass `Theme` to customize a specific new window.

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
