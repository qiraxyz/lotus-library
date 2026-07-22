local DEFAULT_THEME = {
	Background = Color3.fromRGB(10, 12, 18),
	Surface = Color3.fromRGB(17, 20, 29),
	SurfaceAlt = Color3.fromRGB(23, 27, 38),
	SurfaceHover = Color3.fromRGB(30, 35, 49),
	Border = Color3.fromRGB(48, 55, 72),
	Text = Color3.fromRGB(242, 244, 248),
	MutedText = Color3.fromRGB(145, 153, 174),
	Accent = Color3.fromRGB(129, 92, 246),
	AccentHover = Color3.fromRGB(148, 115, 255),
	AccentText = Color3.fromRGB(255, 255, 255),
	Success = Color3.fromRGB(56, 189, 148),
	Danger = Color3.fromRGB(248, 113, 113),
	Overlay = Color3.fromRGB(5, 7, 12),
}

local activeTheme = cloneTable(DEFAULT_THEME)

function Lotus.SetTheme(overrides)
	assert(type(overrides) == "table", "Lotus.SetTheme expects a table")
	activeTheme = mergeTable(DEFAULT_THEME, overrides)
	return cloneTable(activeTheme)
end

function Lotus.GetTheme()
	return cloneTable(activeTheme)
end

Lotus.Themes = {
	Default = cloneTable(DEFAULT_THEME),
	Midnight = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(7, 11, 20),
		Surface = Color3.fromRGB(13, 20, 33),
		SurfaceAlt = Color3.fromRGB(18, 29, 46),
		Accent = Color3.fromRGB(56, 189, 248),
		AccentHover = Color3.fromRGB(103, 207, 255),
	}),
	Rose = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(18, 10, 16),
		Surface = Color3.fromRGB(29, 17, 26),
		SurfaceAlt = Color3.fromRGB(40, 23, 36),
		Accent = Color3.fromRGB(244, 114, 182),
		AccentHover = Color3.fromRGB(251, 154, 205),
	}),
}
