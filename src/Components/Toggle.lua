local Toggle = setmetatable({}, ComponentBase)
Toggle.__index = Toggle

function Toggle.new(section, rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = section._window._theme
	local card = makeCard(section, options.Description and 58 or 50)
	local self = setmetatable({}, Toggle):_initialize(card)
	self._sectionTheme = theme
	self.Value = options.Default == true
	self.Changed = Signal.new()
	self._maid:Give(self.Changed)
	makeControlText(card, options, 88, theme)

	local hitbox = create("TextButton", {
		Name = "ToggleHitbox",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = card,
	})
	local track = create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(46, 24),
		BackgroundColor3 = self.Value and theme.Accent or theme.Border,
		BorderSizePixel = 0,
		Parent = hitbox,
	})
	corner(track, 12)
	local thumb = create("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = self.Value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(thumb, 9)
	self.Track = track
	self.Thumb = thumb
	self._callback = options.Callback
	self._maid:Give(hitbox.Activated:Connect(function()
		self:Set(not self.Value)
	end))
	return self
end

function Toggle:Set(value, silent)
	value = value == true
	if self.Value == value then
		return self
	end
	self.Value = value
	local theme = self._sectionTheme or activeTheme
	Motion.tween(self.Track, Motion.Normal, {
		BackgroundColor3 = value and theme.Accent or theme.Border,
	})
	Motion.tween(self.Thumb, Motion.Normal, {
		Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
	})
	self.Changed:Fire(value)
	if not silent then
		safeCall(self._callback, value, self)
	end
	return self
end

function Toggle:Get()
	return self.Value
end
