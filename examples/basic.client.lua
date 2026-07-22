local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lotus = require(ReplicatedStorage:WaitForChild("lotus-library"))

local window = Lotus.new({
	Title = "Lotus Menu",
	Subtitle = "Production UI example",
	SidebarTitle = "LOTUS",
	NavTitle = "Features",
	BrandGlyph = "L",
	ToggleKey = Enum.KeyCode.RightShift,
	Theme = "Midnight",
	Loading = {
		Title = "Lotus Library",
		Text = "Building interface…",
		Duration = 1.15,
	},
})

local home = window:AddTab({ Name = "Home", Icon = "◆" })
local settings = window:AddTab({ Name = "Settings", Icon = "⚙" })

local actions = home:AddSection("Actions")
actions:AddButton({
	Title = "Show notification",
	Description = "Demonstrates the toast component",
	ButtonText = "Show",
	Callback = function()
		window:Notify({
			Title = "Lotus is ready",
			Description = "All components loaded successfully.",
			Duration = 3,
		})
	end,
})

local state = home:AddSection("State")
local featureToggle = state:AddToggle({
	Title = "Example feature",
	Description = "Stores a boolean state",
	Default = false,
	Callback = function(value)
		print("Example feature:", value)
	end,
})

local amountSlider = state:AddSlider({
	Title = "Amount",
	Description = "Mouse and touch compatible",
	Min = 0,
	Max = 100,
	Default = 35,
	Step = 5,
	Suffix = "%",
	Callback = function(value)
		print("Amount:", value)
	end,
})

local progress = state:AddProgress({
	Title = "Progress",
	Description = "Controlled from your script",
	Value = 35,
})

amountSlider.Changed:Connect(function(value)
	progress:Set(value)
end)

local interface = settings:AddSection("Interface")
interface:AddButton({
	Title = "Rename window",
	ButtonText = "Rename",
	Callback = function()
		window:SetTitle("Custom Lotus Title", "Changed at runtime")
		window:SetSidebarTitle("CUSTOM", "Navigation")
	end,
})

interface:AddButton({
	Title = "Reset controls",
	ButtonText = "Reset",
	Callback = function()
		featureToggle:Set(false)
		amountSlider:Set(35)
	end,
})
