local Progress = setmetatable({}, ComponentBase)
Progress.__index = Progress

function Progress.new(section, rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = section._window._theme
	local card = makeCard(section, options.Description and 78 or 66)
	local self = setmetatable({}, Progress):_initialize(card)
	self.Minimum = tonumber(options.Min) or 0
	self.Maximum = tonumber(options.Max) or 100
	assert(self.Maximum > self.Minimum, "Progress Max must be greater than Min")
	self.Value = nil
	self.Changed = Signal.new()
	self._maid:Give(self.Changed)
	makeControlText(card, options, 84, theme)

	local valueLabel = create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 10),
		Size = UDim2.fromOffset(72, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = "0%",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = card,
	})
	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 14, 1, -13),
		Size = UDim2.new(1, -28, 0, 7),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = card,
	})
	corner(track, 4)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = options.Color or theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(fill, 4)
	self.ValueLabel = valueLabel
	self.Fill = fill
	self:Set(options.Value ~= nil and options.Value or self.Minimum)
	return self
end

function Progress:Set(value, label)
	value = clamp(tonumber(value) or self.Minimum, self.Minimum, self.Maximum)
	local changed = self.Value ~= value
	self.Value = value
	local alpha = (value - self.Minimum) / (self.Maximum - self.Minimum)
	self.ValueLabel.Text = label or (tostring(math.floor((alpha * 100) + 0.5)) .. "%")
	Motion.tween(self.Fill, Motion.Normal, { Size = UDim2.fromScale(alpha, 1) })
	if changed then
		self.Changed:Fire(value, alpha)
	end
	return self
end

function Progress:Get()
	return self.Value
end
