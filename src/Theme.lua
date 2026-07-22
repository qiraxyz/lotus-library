local DEFAULT_THEME = {
	Background = Color3.fromRGB(8, 9, 10),
	Surface = Color3.fromRGB(15, 16, 17),
	SurfaceAlt = Color3.fromRGB(25, 26, 27),
	SurfaceHover = Color3.fromRGB(40, 40, 44),
	SurfaceMuted = Color3.fromRGB(20, 21, 22),
	Border = Color3.fromRGB(35, 37, 42),
	BorderStrong = Color3.fromRGB(52, 52, 58),
	Text = Color3.fromRGB(247, 248, 248),
	MutedText = Color3.fromRGB(138, 143, 152),
	SubtleText = Color3.fromRGB(98, 102, 109),
	Accent = Color3.fromRGB(94, 106, 210),
	AccentHover = Color3.fromRGB(113, 112, 255),
	AccentSoft = Color3.fromRGB(39, 42, 71),
	AccentText = Color3.fromRGB(255, 255, 255),
	Success = Color3.fromRGB(39, 166, 68),
	Warning = Color3.fromRGB(245, 158, 11),
	Danger = Color3.fromRGB(239, 68, 68),
	Overlay = Color3.fromRGB(1, 1, 2),
	Shadow = Color3.fromRGB(0, 0, 0),
}

Lotus.Themes = {
	Default = cloneTable(DEFAULT_THEME),
	Midnight = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(5, 8, 15),
		Surface = Color3.fromRGB(10, 15, 26),
		SurfaceAlt = Color3.fromRGB(17, 24, 39),
		SurfaceHover = Color3.fromRGB(27, 38, 58),
		SurfaceMuted = Color3.fromRGB(12, 19, 32),
		Border = Color3.fromRGB(30, 41, 59),
		BorderStrong = Color3.fromRGB(51, 65, 85),
		Accent = Color3.fromRGB(99, 102, 241),
		AccentHover = Color3.fromRGB(129, 140, 248),
		AccentSoft = Color3.fromRGB(30, 32, 70),
	}),
	Rose = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(16, 9, 13),
		Surface = Color3.fromRGB(25, 14, 21),
		SurfaceAlt = Color3.fromRGB(38, 21, 32),
		SurfaceHover = Color3.fromRGB(54, 29, 45),
		SurfaceMuted = Color3.fromRGB(29, 16, 24),
		Border = Color3.fromRGB(63, 35, 52),
		BorderStrong = Color3.fromRGB(88, 48, 72),
		Accent = Color3.fromRGB(244, 114, 182),
		AccentHover = Color3.fromRGB(251, 154, 205),
		AccentSoft = Color3.fromRGB(70, 30, 53),
	}),
	Graphite = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(12, 12, 13),
		Surface = Color3.fromRGB(20, 20, 22),
		SurfaceAlt = Color3.fromRGB(29, 29, 32),
		SurfaceHover = Color3.fromRGB(43, 43, 47),
		SurfaceMuted = Color3.fromRGB(24, 24, 26),
		Border = Color3.fromRGB(46, 46, 51),
		BorderStrong = Color3.fromRGB(64, 64, 70),
		Accent = Color3.fromRGB(161, 161, 170),
		AccentHover = Color3.fromRGB(212, 212, 216),
		AccentSoft = Color3.fromRGB(52, 52, 58),
	}),
	Ocean = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(4, 12, 18),
		Surface = Color3.fromRGB(7, 22, 31),
		SurfaceAlt = Color3.fromRGB(10, 34, 47),
		SurfaceHover = Color3.fromRGB(14, 48, 64),
		SurfaceMuted = Color3.fromRGB(8, 27, 37),
		Border = Color3.fromRGB(21, 55, 72),
		BorderStrong = Color3.fromRGB(30, 75, 95),
		Accent = Color3.fromRGB(14, 165, 233),
		AccentHover = Color3.fromRGB(56, 189, 248),
		AccentSoft = Color3.fromRGB(8, 56, 76),
	}),
	Emerald = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(5, 13, 10),
		Surface = Color3.fromRGB(9, 24, 18),
		SurfaceAlt = Color3.fromRGB(13, 36, 27),
		SurfaceHover = Color3.fromRGB(18, 51, 38),
		SurfaceMuted = Color3.fromRGB(11, 29, 22),
		Border = Color3.fromRGB(24, 61, 46),
		BorderStrong = Color3.fromRGB(35, 83, 63),
		Accent = Color3.fromRGB(16, 185, 129),
		AccentHover = Color3.fromRGB(52, 211, 153),
		AccentSoft = Color3.fromRGB(14, 62, 47),
	}),
	Amber = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(16, 11, 5),
		Surface = Color3.fromRGB(27, 19, 8),
		SurfaceAlt = Color3.fromRGB(41, 29, 11),
		SurfaceHover = Color3.fromRGB(57, 40, 14),
		SurfaceMuted = Color3.fromRGB(32, 23, 9),
		Border = Color3.fromRGB(69, 49, 17),
		BorderStrong = Color3.fromRGB(93, 65, 22),
		Accent = Color3.fromRGB(245, 158, 11),
		AccentHover = Color3.fromRGB(251, 191, 36),
		AccentSoft = Color3.fromRGB(76, 48, 11),
		AccentText = Color3.fromRGB(24, 16, 4),
	}),
	Light = mergeTable(DEFAULT_THEME, {
		Background = Color3.fromRGB(247, 248, 248),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceAlt = Color3.fromRGB(243, 244, 245),
		SurfaceHover = Color3.fromRGB(232, 234, 237),
		SurfaceMuted = Color3.fromRGB(239, 240, 242),
		Border = Color3.fromRGB(214, 217, 222),
		BorderStrong = Color3.fromRGB(190, 195, 202),
		Text = Color3.fromRGB(24, 26, 29),
		MutedText = Color3.fromRGB(92, 97, 105),
		SubtleText = Color3.fromRGB(126, 132, 141),
		Accent = Color3.fromRGB(79, 70, 229),
		AccentHover = Color3.fromRGB(67, 56, 202),
		AccentSoft = Color3.fromRGB(224, 225, 252),
		Overlay = Color3.fromRGB(17, 24, 39),
		Shadow = Color3.fromRGB(31, 41, 55),
	}),
}

local activeTheme = cloneTable(DEFAULT_THEME)

function Lotus.ResolveTheme(theme)
	if theme == nil then
		return cloneTable(DEFAULT_THEME)
	end
	if type(theme) == "string" then
		local preset = Lotus.Themes[theme]
		assert(preset, "Unknown Lotus theme: " .. theme)
		return cloneTable(preset)
	end
	assert(type(theme) == "table", "Lotus theme must be a preset name or table")
	return mergeTable(DEFAULT_THEME, theme)
end

function Lotus.SetTheme(theme)
	activeTheme = Lotus.ResolveTheme(theme)
	return cloneTable(activeTheme)
end

function Lotus.GetTheme()
	return cloneTable(activeTheme)
end
