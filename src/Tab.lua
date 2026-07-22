local Tab = {}
Tab.__index = Tab

function Tab.new(window, rawOptions)
	local options = normalizeOptions(rawOptions, "Name")
	local theme = window._theme
	local self = setmetatable({}, Tab)
	self._window = window
	self._maid = Maid.new()
	self._sections = {}
	self.Name = options.Name or options.Title or "Tab"
	self._icon = options.Icon

	local navButton = create("TextButton", {
		Name = "Tab_" .. self.Name,
		Size = UDim2.new(1, 0, 0, 40),
		AutoButtonColor = false,
		BackgroundColor3 = theme.AccentSoft,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = "  " .. (options.Icon and (options.Icon .. "  ") or "") .. self.Name,
		TextColor3 = theme.MutedText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = window._nav,
	})
	corner(navButton, 6)
	local accent = create("Frame", {
		Name = "Accent",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 5, 0.5, 0),
		Size = UDim2.fromOffset(2, 16),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = navButton,
	})
	corner(accent, 2)

	local page = create("ScrollingFrame", {
		Name = "Page_" .. self.Name,
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.45,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		Parent = window._pages,
	})
	padding(page, 24, 24, 20, 24)
	create("UIListLayout", {
		Padding = UDim.new(0, 16),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})

	self._button = navButton
	self._accent = accent
	self._page = page
	self._maid:Give(navButton.Activated:Connect(function()
		window:SelectTab(self)
	end))
	self._maid:Give(navButton.MouseEnter:Connect(function()
		if window._activeTab ~= self then
			Motion.tween(navButton, Motion.Fast, { BackgroundTransparency = 0.45 })
		end
	end))
	self._maid:Give(navButton.MouseLeave:Connect(function()
		if window._activeTab ~= self then
			Motion.tween(navButton, Motion.Fast, { BackgroundTransparency = 1 })
		end
	end))
	return self
end

function Tab:_setActive(active)
	local theme = self._window._theme
	self._page.Visible = active
	Motion.tween(self._button, Motion.Normal, {
		BackgroundTransparency = active and 0.15 or 1,
		TextColor3 = active and theme.Text or theme.MutedText,
	})
	Motion.tween(self._accent, Motion.Normal, {
		BackgroundTransparency = active and 0 or 1,
	})
end

function Tab:AddSection(options)
	local section = Section.new(self, options)
	table.insert(self._sections, section)
	return section
end

function Tab:SetTitle(title)
	self.Name = tostring(title)
	self._button.Text = "  " .. (self._icon and (self._icon .. "  ") or "") .. self.Name
	return self
end

function Tab:Select()
	self._window:SelectTab(self)
	return self
end

function Tab:Destroy()
	for index = #self._sections, 1, -1 do
		self._sections[index]:Destroy()
	end
	self._maid:Destroy()
	self._button:Destroy()
	self._page:Destroy()
end
