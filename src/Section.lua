local Section = {}
Section.__index = Section

function Section.new(tab, rawOptions)
	local options = normalizeOptions(rawOptions, "Title")
	local theme = tab._window._theme
	local self = setmetatable({}, Section)
	self._window = tab._window
	self._tab = tab
	self._maid = Maid.new()
	self._controls = {}

	local root = create("Frame", {
		Name = "Section_" .. tostring(options.Title or "Section"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = tab._page,
	})
	local title = create("TextLabel", {
		Name = "SectionTitle",
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = string.upper(options.Title or "SECTION"),
		TextColor3 = theme.MutedText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = root,
	})
	local body = create("Frame", {
		Name = "Controls",
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = root,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = body,
	})
	create("UIPadding", {
		PaddingBottom = UDim.new(0, 2),
		Parent = body,
	})

	self.Root = root
	self._title = title
	self._body = body
	return self
end

function Section:SetTitle(title)
	self._title.Text = string.upper(tostring(title))
	return self
end

function Section:AddButton(options)
	local control = Button.new(self, options)
	table.insert(self._controls, control)
	return control
end

function Section:AddToggle(options)
	local control = Toggle.new(self, options)
	table.insert(self._controls, control)
	return control
end

function Section:AddSlider(options)
	local control = Slider.new(self, options)
	table.insert(self._controls, control)
	return control
end

function Section:AddProgress(options)
	local control = Progress.new(self, options)
	table.insert(self._controls, control)
	return control
end

function Section:Destroy()
	for index = #self._controls, 1, -1 do
		self._controls[index]:Destroy()
	end
	self._maid:Destroy()
	self.Root:Destroy()
end
