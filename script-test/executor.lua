-- Lotus Library executor example
-- Re-running this script replaces the previous Lotus window.
-- Prefers the local candidate bundle and falls back to the pinned v1.1 release.

local EXPECTED_VERSION = "1.1.0"
local LOCAL_LIBRARY_PATH = "script-test/lotus-library.lua"
local EXECUTOR_LIBRARY_PATH = "lotus-library.lua"
local LOTUS_URL = "https://raw.githubusercontent.com/qiraxyz/lotus-library/refs/tags/v1.1.0/dist/lotus-library.lua"

local function getLibrarySource()
	if type(isfile) == "function" and type(readfile) == "function" and isfile(LOCAL_LIBRARY_PATH) then
		return readfile(LOCAL_LIBRARY_PATH), LOCAL_LIBRARY_PATH
	end
	if type(isfile) == "function" and type(readfile) == "function" and isfile(EXECUTOR_LIBRARY_PATH) then
		return readfile(EXECUTOR_LIBRARY_PATH), EXECUTOR_LIBRARY_PATH
	end

	local success, source = pcall(function()
		return game:HttpGet(LOTUS_URL)
	end)
	if not success then
		error("Failed to download Lotus Library: " .. tostring(source))
	end
	return source, LOTUS_URL
end

local function loadLotus()
	if type(loadstring) ~= "function" then
		error("This executor does not provide loadstring.")
	end

	local source, sourceName = getLibrarySource()
	local chunk, compileError = loadstring(source)

	if not chunk then
		error("Failed to compile Lotus Library from " .. sourceName .. ": " .. tostring(compileError))
	end

	local success, library = pcall(chunk)
	if not success then
		error("Failed to run Lotus Library: " .. tostring(library))
	end
	if type(library) ~= "table" or type(library.new) ~= "function" then
		error("The loaded source did not return a valid Lotus Library table.")
	end
	if library.Version ~= EXPECTED_VERSION then
		error(
			"Expected Lotus v"
				.. EXPECTED_VERSION
				.. ", but "
				.. sourceName
				.. " returned v"
				.. tostring(library.Version)
				.. ". Use the bundled script-test/lotus-library.lua or publish v1.1 before remote testing."
		)
	end
	if type(library.ResolveTheme) ~= "function" then
		error("The loaded Lotus build does not support named themes.")
	end

	return library
end

local Lotus = loadLotus()

local window = Lotus.new({
	Title = "Lotus Executor Test",
	Subtitle = "Modern UI v" .. tostring(Lotus.Version),
	SidebarTitle = "LOTUS",
	NavTitle = "Test Menu",
	BrandGlyph = "L",
	GuiName = "LotusExecutorTest",
	SingleInstance = true,
	Theme = "Default",
	ToggleKey = Enum.KeyCode.RightShift,
	Loading = {
		Title = "Lotus Library",
		Text = "Loading executor test...",
		Duration = 1,
	},
})

local homeTab = window:AddTab({
	Name = "Home",
	Icon = "◆",
})

local settingsTab = window:AddTab({
	Name = "Settings",
	Icon = "⚙",
})

local themesTab = window:AddTab({
	Name = "Themes",
	Icon = "✦",
})

local actions = homeTab:AddSection("Actions")

actions:AddButton({
	Title = "Test notification",
	Description = "Shows a Lotus notification.",
	ButtonText = "Show",
	Callback = function()
		window:Notify({
			Title = "Lotus loaded",
			Description = "The candidate library is working correctly.",
			Duration = 3,
		})
	end,
})

local controls = homeTab:AddSection("Controls")

local enabledToggle = controls:AddToggle({
	Title = "Example toggle",
	Description = "Tests boolean state and callbacks.",
	Default = false,
	Callback = function(value)
		print("[Lotus Test] Toggle:", value)
	end,
})

local progress = controls:AddProgress({
	Title = "Example progress",
	Description = "Linked to the slider below.",
	Value = 50,
})

local amountSlider = controls:AddSlider({
	Title = "Progress amount",
	Description = "Drag to update the progress bar.",
	Min = 0,
	Max = 100,
	Default = 50,
	Step = 5,
	Suffix = "%",
	Callback = function(value)
		progress:Set(value)
	end,
})

local interface = settingsTab:AddSection("Interface")

interface:AddButton({
	Title = "Reset controls",
	Description = "Restores the default test values.",
	ButtonText = "Reset",
	Callback = function()
		enabledToggle:Set(false)
		amountSlider:Set(50)
		window:Notify({
			Title = "Controls reset",
			Description = "Toggle and slider restored to defaults.",
			Duration = 2,
		})
	end,
})

interface:AddButton({
	Title = "Minimize window",
	Description = "Use the title-bar button to expand it again.",
	ButtonText = "Minimize",
	Callback = function()
		window:SetMinimized(true)
	end,
})

interface:AddButton({
	Title = "Destroy interface",
	Description = "Removes the test UI completely.",
	ButtonText = "Destroy",
	Callback = function()
		window:Destroy()
	end,
})

local themeGallery = themesTab:AddSection("Theme gallery")
local themeNames = {
	"Default",
	"Midnight",
	"Rose",
	"Graphite",
	"Ocean",
	"Emerald",
	"Amber",
	"Light",
}

for _, themeName in ipairs(themeNames) do
	themeGallery:AddButton({
		Title = themeName,
		Description = 'Create a window with Theme = "' .. themeName .. '".',
		ButtonText = "Preview",
		Callback = function()
			local theme = Lotus.ResolveTheme(themeName)
			window:Notify({
				Title = themeName .. " theme",
				Description = "Accent preview. Set this theme when creating your window.",
				Color = theme.Accent,
				Duration = 3,
			})
		end,
	})
end

window:Notify({
	Title = "Ready",
	Description = "Press RightShift to toggle. Open Themes to preview all presets.",
	Duration = 4,
})
