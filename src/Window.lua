local Window = {}
Window.__index = Window

local function makeIconButton(parent, text, offset, theme)
	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offset, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		AutoButtonColor = false,
		BackgroundColor3 = theme.SurfaceHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = 16,
		Parent = parent,
	})
	corner(button, 6)
	button.MouseEnter:Connect(function()
		Motion.tween(button, Motion.Fast, {
			BackgroundTransparency = 0.08,
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
	self._theme = type(options.Theme) == "string" and Lotus.ResolveTheme(options.Theme)
		or mergeTable(activeTheme, options.Theme)
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

	local theme = self._theme
	local initialPosition = options.Position or UDim2.fromScale(0.5, 0.5)
	local shadow = create("Frame", {
		Name = "WindowShadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(
			initialPosition.X.Scale,
			initialPosition.X.Offset,
			initialPosition.Y.Scale,
			initialPosition.Y.Offset + 8
		),
		Size = self._fullSize,
		BackgroundColor3 = theme.Shadow,
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	corner(shadow, 16)
	local shadowSizeConstraint = create("UISizeConstraint", {
		MinSize = Vector2.new(560, 340),
		MaxSize = Vector2.new(1100, 760),
		Parent = shadow,
	})
	local shadowScale = create("UIScale", { Scale = 0.96, Parent = shadow })
	self._shadow = shadow
	self._shadowSizeConstraint = shadowSizeConstraint

	local main = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = initialPosition,
		Size = self._fullSize,
		BackgroundColor3 = self._theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	})
	corner(main, 12)
	stroke(main, theme.BorderStrong, 0.35, 1)
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
		Size = UDim2.new(0, options.SidebarWidth or 188, 1, 0),
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
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	local brandMark = create("Frame", {
		Name = "BrandMark",
		Position = UDim2.fromOffset(16, 18),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = self._theme.Accent,
		BorderSizePixel = 0,
		Parent = sidebar,
	})
	corner(brandMark, 8)
	stroke(brandMark, self._theme.AccentHover, 0.58, 1)
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
		Position = UDim2.fromOffset(58, 17),
		Size = UDim2.new(1, -72, 0, 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = options.SidebarTitle or options.Title or "LOTUS",
		TextColor3 = self._theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = sidebar,
	})
	local navCaption = create("TextLabel", {
		Name = "NavCaption",
		Position = UDim2.fromOffset(16, 70),
		Size = UDim2.new(1, -32, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = string.upper(options.NavTitle or "Navigation"),
		TextColor3 = self._theme.SubtleText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar,
	})
	local nav = create("ScrollingFrame", {
		Name = "Navigation",
		Position = UDim2.fromOffset(12, 94),
		Size = UDim2.new(1, -24, 1, -112),
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

	local sidebarWidth = options.SidebarWidth or 188
	local topbar = create("Frame", {
		Name = "Topbar",
		Position = UDim2.fromOffset(sidebarWidth, 0),
		Size = UDim2.new(1, -sidebarWidth, 0, 68),
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
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Parent = topbar,
	})
	local titleLabel = create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(24, 13),
		Size = UDim2.new(1, -120, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = options.Title or "Lotus Menu",
		TextColor3 = self._theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})
	local subtitleLabel = create("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(24, 37),
		Size = UDim2.new(1, -120, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = options.Subtitle or "Ready",
		TextColor3 = self._theme.SubtleText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})
	self._titleLabel = titleLabel
	self._subtitleLabel = subtitleLabel

	local closeButton = makeIconButton(topbar, "×", -16, self._theme)
	closeButton.Name = "Close"
	local minimizeButton = makeIconButton(topbar, "–", -52, self._theme)
	minimizeButton.Name = "Minimize"
	self._maid:Give(closeButton.Activated:Connect(function()
		self:SetVisible(false)
	end))
	self._maid:Give(minimizeButton.Activated:Connect(function()
		self:SetMinimized(not self._minimized)
	end))

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(sidebarWidth, 68),
		Size = UDim2.new(1, -sidebarWidth, 1, -68),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self._pages = pages

	local notificationHost = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(310, 0),
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
			local newPosition = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
			main.Position = newPosition
			shadow.Position = UDim2.new(
				newPosition.X.Scale,
				newPosition.X.Offset,
				newPosition.Y.Scale,
				newPosition.Y.Offset + 8
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
	Motion.tween(shadowScale, Motion.Slow, { Scale = 1 })
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
	self._shadow.Visible = false
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
		Size = UDim2.fromOffset(360, 180),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = overlay,
	})
	corner(panel, 12)
	stroke(panel, theme.BorderStrong, 0.28, 1)
	create("TextLabel", {
		Name = "LoaderTitle",
		Position = UDim2.fromOffset(24, 22),
		Size = UDim2.new(1, -48, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
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
		TextColor3 = theme.SubtleText,
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
		Size = UDim2.new(1, -48, 0, 5),
		BackgroundColor3 = theme.BorderStrong,
		BorderSizePixel = 0,
		Parent = panel,
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
		self._shadow.Visible = true
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
			self._shadow.Visible = true
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
		self._sizeConstraint.MinSize = Vector2.new(560, 68)
		self._shadowSizeConstraint.MinSize = Vector2.new(560, 68)
	else
		self._sizeConstraint.MinSize = Vector2.new(560, 340)
		self._shadowSizeConstraint.MinSize = Vector2.new(560, 340)
	end
	Motion.tween(self.Main, Motion.Slow, {
		Size = minimized and UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, 68) or self._fullSize,
	})
	Motion.tween(self._shadow, Motion.Slow, {
		Size = minimized and UDim2.new(self._fullSize.X.Scale, self._fullSize.X.Offset, 0, 68) or self._fullSize,
	})
	return self
end

function Window:Notify(rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = self._theme
	local height = options.Description and 76 or 60
	local toast = create("Frame", {
		Name = "Notification",
		Size = UDim2.fromOffset(310, height),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Parent = self._notificationHost,
	})
	corner(toast, 8)
	stroke(toast, theme.BorderStrong, 0.32, 1)
	local accent = create("Frame", {
		Name = "Accent",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = options.Color or theme.Accent,
		BorderSizePixel = 0,
		Parent = toast,
	})
	corner(accent, 4)
	create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(36, options.Description and 13 or 0),
		Size = options.Description and UDim2.new(1, -52, 0, 20) or UDim2.new(1, -52, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
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
			Position = UDim2.fromOffset(36, 36),
			Size = UDim2.new(1, -52, 0, 24),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = options.Description,
			TextColor3 = theme.SubtleText,
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
