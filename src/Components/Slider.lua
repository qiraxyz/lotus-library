local Slider = setmetatable({}, ComponentBase)
Slider.__index = Slider

function Slider.new(section, rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = section._window._theme
	local card = makeCard(section, options.Description and 82 or 70)
	local self = setmetatable({}, Slider):_initialize(card)
	self.Minimum = tonumber(options.Min) or 0
	self.Maximum = tonumber(options.Max) or 100
	assert(self.Maximum > self.Minimum, "Slider Max must be greater than Min")
	self.Step = tonumber(options.Step) or 1
	self.Suffix = options.Suffix or ""
	self.Value = nil
	self.Changed = Signal.new()
	self._maid:Give(self.Changed)
	self._callback = options.Callback
	makeControlText(card, options, 94, theme)

	local valueLabel = create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 10),
		Size = UDim2.fromOffset(80, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = "",
		TextColor3 = theme.AccentHover,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card,
	})
	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -13),
		Size = UDim2.new(1, -28, 0, 6),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = card,
	})
	corner(track, 3)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(fill, 3)
	local thumb = create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(thumb, 8)
	stroke(thumb, theme.Accent, 0.15, 2)

	self.ValueLabel = valueLabel
	self.Track = track
	self.Fill = fill
	self.Thumb = thumb

	local dragging = false
	local function updateFromX(x)
		local width = math.max(track.AbsoluteSize.X, 1)
		local alpha = clamp((x - track.AbsolutePosition.X) / width, 0, 1)
		self:Set(self.Minimum + ((self.Maximum - self.Minimum) * alpha))
	end
	self._maid:Give(card.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			updateFromX(input.Position.X)
		end
	end))
	self._maid:Give(UserInputService.InputChanged:Connect(function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			updateFromX(input.Position.X)
		end
	end))
	self._maid:Give(UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end))

	self:Set(options.Default ~= nil and options.Default or self.Minimum, true)
	return self
end

function Slider:Set(value, silent)
	value = clamp(roundToStep(tonumber(value) or self.Minimum, self.Step), self.Minimum, self.Maximum)
	local changed = self.Value ~= value
	self.Value = value
	local alpha = (value - self.Minimum) / (self.Maximum - self.Minimum)
	self.ValueLabel.Text = formatNumber(value) .. self.Suffix
	Motion.tween(self.Fill, Motion.Fast, { Size = UDim2.fromScale(alpha, 1) })
	Motion.tween(self.Thumb, Motion.Fast, { Position = UDim2.fromScale(alpha, 0.5) })
	if changed then
		self.Changed:Fire(value)
		if not silent then
			safeCall(self._callback, value, self)
		end
	end
	return self
end

function Slider:Get()
	return self.Value
end
