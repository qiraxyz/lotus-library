local Button = setmetatable({}, ComponentBase)
Button.__index = Button

function Button.new(section, rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = section._window._theme
	local card = makeCard(section, options.Description and 58 or 50)
	local self = setmetatable({}, Button):_initialize(card)
	self._callback = options.Callback
	makeControlText(card, options, 126, theme)

	local action = create("TextButton", {
		Name = "Action",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(options.ButtonWidth or 96, 32),
		AutoButtonColor = false,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamSemibold,
		Text = options.ButtonText or "Run",
		TextColor3 = theme.AccentText,
		TextSize = 12,
		Parent = card,
	})
	corner(action, 8)
	self._maid:Give(Motion.press(action))
	self._maid:Give(action.MouseEnter:Connect(function()
		Motion.tween(action, Motion.Fast, { BackgroundColor3 = theme.AccentHover })
	end))
	self._maid:Give(action.MouseLeave:Connect(function()
		Motion.tween(action, Motion.Fast, { BackgroundColor3 = theme.Accent })
	end))
	self._maid:Give(action.Activated:Connect(function()
		safeCall(self._callback, self)
	end))
	self.Button = action
	return self
end

function Button:SetText(text)
	self.Button.Text = tostring(text)
	return self
end

function Button:Fire()
	safeCall(self._callback, self)
	return self
end
