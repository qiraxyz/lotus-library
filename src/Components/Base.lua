local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase:_initialize(root)
	self.Root = root
	self._maid = Maid.new()
	self._destroyed = false
	self.Destroyed = Signal.new()
	self._maid:Give(self.Destroyed)
	return self
end

function ComponentBase:SetVisible(visible)
	if not self._destroyed then
		self.Root.Visible = visible == true
	end
	return self
end

function ComponentBase:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self.Destroyed:Fire()
	self._maid:Destroy()
	if self.Root then
		self.Root:Destroy()
	end
end

local function makeCard(section, height)
	local theme = section._window._theme
	local card = create("Frame", {
		Name = "Control",
		Size = UDim2.new(1, 0, 0, height),
		Active = true,
		BackgroundColor3 = theme.SurfaceMuted,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Parent = section._body,
	})
	corner(card, 8)
	stroke(card, theme.Border, 0.22, 1)
	card.MouseEnter:Connect(function()
		Motion.tween(card, Motion.Fast, { BackgroundColor3 = theme.SurfaceHover })
	end)
	card.MouseLeave:Connect(function()
		Motion.tween(card, Motion.Fast, { BackgroundColor3 = theme.SurfaceMuted })
	end)
	return card
end

local function makeControlText(card, options, rightInset, theme)
	theme = theme or activeTheme
	local title = options.Title or options.Name or options.Text or "Control"
	local description = options.Description
	local titleLabel = create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(16, description and 10 or 0),
		Size = description and UDim2.new(1, -(rightInset or 130), 0, 20) or UDim2.new(1, -(rightInset or 130), 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	local descriptionLabel
	if description then
		descriptionLabel = create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(16, 30),
			Size = UDim2.new(1, -(rightInset or 130), 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = description,
			TextColor3 = theme.SubtleText,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
	end
	return titleLabel, descriptionLabel
end
