local Window = {}
Window.__index = Window

local function makeIconButton(parent, text, offset, theme)
	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offset, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceAlt,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = 16,
		Parent = parent,
	})
	corner(button, 7)
	button.MouseEnter:Connect(function()
		Motion.tween(button, Motion.Fast, {
			BackgroundTransparency = 0.15,
			TextColor3 = theme.Text,
		})
	end)
	button.MouseLeave:Connect(function()
		Motion.tween(button, Motion.Fast, {
			BackgroundTransparency = 1,
			TextColor3 = theme.MutedText,
		})
	end)
	return button
end

function Window.new(rawOptions)
	local options = rawOptions or {}
	local self = setmetatable({}, Window)
	self._maid = Maid.new()
	self._theme = mergeTable(activeTheme, options.Theme)
	self._tabs = {}
	self._activeTab = nil
	self._destroyed = false
	self._minimized = false
	self._fullSize = options.Size or UDim2.fromOffset(720, 460)
	self.VisibilityChanged = Signal.new()
	self._maid:Give(self.VisibilityChanged)

	local parent = resolveGuiParent(options.Parent)
	local guiName = options.GuiName or "LotusLibrary"
	if options.SingleInstance ~= false then
		local previous = parent:FindFirstChild(guiName)
		if previous then
			previous:Destroy()
		end
	end

	local screenGui = create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = options.DisplayOrder or 50,
		Parent = parent,
	})
	self._maid:Give(screenGui)
	self.ScreenGui = screenGui

	local main = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = self._fullSize,
		BackgroundColor3 = self._theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	})
	corner(main, 14)
	stroke(main, self._theme.Border, 0.35, 1)
	local sizeConstraint = create("UISizeConstraint", {
		MinSize = Vector2.new(560, 340),
		MaxSize = Vector2.new(1100, 760),
		Parent = main,
	})
	local scale = create("UIScale", { Scale = 0.96, Parent = main })
	self._sizeConstraint = sizeConstraint
	self.Main = main

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, options.SidebarWidth or 184, 1, 0),
		BackgroundColor3 = self._theme.Surface,
		BorderSizePixel = 0,
		Parent = main,
	})
	create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = self._theme.Border,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	local brandMark = create("Frame", {
		Name = "BrandMark",
		Position = UDim2.fromOffset(16, 17),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = self._theme.Accent,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	corner(brandMark, 9)
	create("TextLabel", {
		Name = "Glyph",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = options.BrandGlyph or "L",
		TextColor3 = self._theme.AccentText,
		TextSize = 15,
		Parent = brandMark,
	})
	local sidebarTitle = create("TextLabel", {
		Name = "SidebarTitle",
		Position = UDim2.fromOffset(56, 15),
		Size = UDim2.new(1, -68, 0, 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = options.SidebarTitle or options.Title or "LOTUS",
		TextColor3 = self._theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sidebar,
	})
	local navCaption = create("TextLabel", {
		Name = "NavCaption",
		Position = UDim2.fromOffset(16, 64),
		Size = UDim2.new(1, -32, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = string.upper(options.NavTitle or "Navigation"),
		TextColor3 = self._theme.MutedText,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar,
	})
	local nav = create("ScrollingFrame", {
		Name = "Navigation",
		Position = UDim2.fromOffset(12, 88),
		Size = UDim2.new(1, -24, 1, -104),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = nav,
	})
	self._sidebarTitle = sidebarTitle
	self._navCaption = navCaption
	self._nav = nav

	local sidebarWidth = options.SidebarWidth or 184
	local topbar = create("Frame", {
		Name = "Topbar",
		Position = UDim2.fromOffset(sidebarWidth, 0),
		Size = UDim2.new(1, -sidebarWidth, 0, 64),
		BackgroundColor3 = self._theme.Background,
		BorderSizePixel = 0,
		Parent = main,
	})
	create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = self._theme.Border,
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
		Parent = topbar,
	})
	local titleLabel = create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(20, 12),
		Size = UDim2.new(1, -120, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = options.Title or "Lotus Menu",
		TextColor3 = self._theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})
	local subtitleLabel = create("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(20, 34),
		Size = UDim2.new(1, -120, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = options.Subtitle or "Ready",
		TextColor3 = self._theme.MutedText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})
	self._titleLabel = titleLabel
	self._subtitleLabel = subtitleLabel

	local closeButton = makeIconButton(topbar, "×", -12, self._theme)
	closeButton.Name = "Close"
	local minimizeButton = makeIconButton(topbar, "–", -48, self._theme)
	minimizeButton.Name = "Minimize"
	self._maid:Give(closeButton.Activated:Connect(function()
		self:SetVisible(false)
	end))
	self._maid:Give(minimizeButton.Activated:Connect(function()
		self:SetMinimized(not self._minimized)
	end))

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(sidebarWidth, 64),
		Size = UDim2.new(1, -sidebarWidth, 1, -64),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self._pages = pages

	local notificationHost = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(290, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = screenGui,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = notificationHost,
	})
	self._notificationHost = notificationHost

	local dragging = false
	local dragStart
	local startPosition
	self._maid:Give(topbar.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
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
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
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

	local toggleKey = options.ToggleKey == nil and Enum.KeyCode.RightShift or options.ToggleKey
	if toggleKey then
		self._maid:Give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.KeyCode == toggleKey then
				self:SetVisible(not screenGui.Enabled)
			end
		end))
	end

	Motion.tween(scale, Motion.Slow, { Scale = 1 })
	self:_setupLoader(options.Loading)
	return self
end

function Window:_setupLoader(rawLoading)
	local config = rawLoading
	if config == false or (type(config) == "table" and config.Enabled == false) then
		return
	end
	if config == nil or config == true then
		config = {}
	end
	local theme = self._theme
	self.Main.Visible = false
	local overlay = create("Frame", {
		Name = "LoadScreen",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Overlay,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Parent = self.ScreenGui,
	})
	local panel = create("Frame", {
		Name = "LoaderCard",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(350, 174),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = overlay,
	})
	corner(panel, 14)
	stroke(panel, theme.Border, 0.4, 1)
	create("TextLabel", {
		Name = "LoaderTitle",
		Position = UDim2.fromOffset(24, 22),
		Size = UDim2.new(1, -48, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = config.Title or self._titleLabel.Text,
		TextColor3 = theme.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})
	local status = create("TextLabel", {
		Name = "Status",
		Position = UDim2.fromOffset(24, 55),
		Size = UDim2.new(1, -48, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = config.Text or "Loading interface…",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})
	local percent = create("TextLabel", {
		Name = "Percent",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, 94),
		Size = UDim2.fromOffset(48, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = "0%",
		TextColor3 = theme.AccentHover,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = panel,
	})
	local track = create("Frame", {
		Name = "Track",
		Position = UDim2.fromOffset(24, 120),
		Size = UDim2.new(1, -48, 0, 8),
		BackgroundColor3 = theme.Border,
		BorderSizePixel = 0,
		Parent = panel,
	})
	corner(track, 4)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = track,
	})
	corner(fill, 4)
	self._loader = {
		Root = overlay,
		Panel = panel,
		Status = status,
		Percent = percent,
		Fill = fill,
	}

	if config.Auto ~= false then
		local duration = math.max(tonumber(config.Duration) or 1.15, 0.05)
		task.spawn(function()
			local started = os.clock()
			while not self._destroyed and self._loader do
				local alpha = clamp((os.clock() - started) / duration, 0, 1)
				self:SetLoadingProgress(alpha * 100)
				if alpha >= 1 then
					break
				end
				RunService.Heartbeat:Wait()
			end
			if not self._destroyed and self._loader then
				self:FinishLoading()
			end
		end)
	end
end

function Window:SetLoadingProgress(value, text)
	if not self._loader then
		return self
	end
	local alpha = clamp((tonumber(value) or 0) / 100, 0, 1)
	self._loader.Percent.Text = tostring(math.floor((alpha * 100) + 0.5)) .. "%"
	if text then
		self._loader.Status.Text = tostring(text)
	end
	Motion.tween(self._loader.Fill, Motion.Fast, { Size = UDim2.fromScale(alpha, 1) })
	return self
end

function Window:FinishLoading()
	local loader = self._loader
	if not loader then
		self.Main.Visible = true
		return self
	end
	self._loader = nil
	Motion.tween(loader.Panel, Motion.Normal, { BackgroundTransparency = 1 })
	Motion.tween(loader.Root, Motion.Normal, { BackgroundTransparency = 1 })
	task.delay(0.22, function()
		if loader.Root then
			loader.Root:Destroy()
		end
		if not self._destroyed then
			self.Main.Visible = true
		end
	end)
	return self
end

function Window:AddTab(options)
	assert(not self._destroyed, "Cannot add a tab to a destroyed Lotus window")
	local tab = Tab.new(self, options)
	table.insert(self._tabs, tab)
	if not self._activeTab then
		self:SelectTab(tab)
	end
	return tab
end

function Window:SelectTab(tabOrName)
	local selected = tabOrName
	if type(tabOrName) == "string" then
		selected = nil
		for _, tab in ipairs(self._tabs) do
			if tab.Name == tabOrName then
				selected = tab
				break
			end
		end
	end
	assert(selected and selected._window == self, "Tab does not belong to this Lotus window")
	self._activeTab = selected
	for _, tab in ipairs(self._tabs) do
		tab:_setActive(tab == selected)
	end
	return selected
end

function Window:SetTitle(title, subtitle)
	self._titleLabel.Text = tostring(title)
	if subtitle ~= nil then
		self._subtitleLabel.Text = tostring(subtitle)
	end
	return self
end

function Window:SetSidebarTitle(title, navTitle)
	self._sidebarTitle.Text = tostring(title)
	if navTitle ~= nil then
		self._navCaption.Text = string.upper(tostring(navTitle))
	end
	return self
end

function Window:SetVisible(visible)
	visible = visible == true
	self.ScreenGui.Enabled = visible
	self.VisibilityChanged:Fire(visible)
	return self
end

function Window:SetMinimized(minimized)
	minimized = minimized == true
	if self._minimized == minimized then
		return self
	end
	self._minimized = minimized
	if minimized then
		self._fullSize = self.Main.Size
		self._sizeConstraint.MinSize = Vector2.new(560, 64)
	else
		self._sizeConstraint.MinSize = Vector2.new(560, 340)
	end
	Motion.tween(self.Main, Motion.Slow, {
		Size = minimized and UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, 64) or self._fullSize,
	})
	return self
end

function Window:Notify(rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = self._theme
	local toast = create("Frame", {
		Name = "Notification",
		Size = UDim2.fromOffset(290, options.Description and 74 or 58),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = self._notificationHost,
	})
	corner(toast, 10)
	stroke(toast, theme.Border, 0.35, 1)
	create("Frame", {
		Name = "Accent",
		Size = UDim2.fromOffset(3, options.Description and 74 or 58),
		BackgroundColor3 = options.Color or theme.Accent,
		BorderSizePixel = 0,
		Parent = toast,
	})
	create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(15, options.Description and 12 or 0),
		Size = options.Description and UDim2.new(1, -28, 0, 20) or UDim2.new(1, -28, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = options.Title or "Notification",
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = toast,
	})
	if options.Description then
		create("TextLabel", {
			Name = "Description",
			Position = UDim2.fromOffset(15, 34),
			Size = UDim2.new(1, -28, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = options.Description,
			TextColor3 = theme.MutedText,
			TextSize = 10,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = toast,
		})
	end
	local toastScale = create("UIScale", { Scale = 0.92, Parent = toast })
	Motion.tween(toastScale, Motion.Normal, { Scale = 1 })
	task.delay(tonumber(options.Duration) or 3, function()
		if toast and toast.Parent then
			Motion.tween(toastScale, Motion.Normal, { Scale = 0.92 })
			Motion.tween(toast, Motion.Normal, { BackgroundTransparency = 1 })
			task.delay(0.22, function()
				if toast then
					toast:Destroy()
				end
			end)
		end
	end)
	return toast
end

function Window:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	for index = #self._tabs, 1, -1 do
		self._tabs[index]:Destroy()
	end
	self._maid:Destroy()
end
