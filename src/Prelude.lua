-- Core services and shared helpers. Kept dependency-free for one-file use.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Lotus = {
	Name = "lotus-library",
	Version = "1.0.0",
}

local function cloneTable(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = type(value) == "table" and cloneTable(value) or value
	end
	return copy
end

local function mergeTable(base, overrides)
	local result = cloneTable(base)
	for key, value in pairs(overrides or {}) do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = mergeTable(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

local function create(className, properties, children)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		if key ~= "Parent" then
			instance[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end
	if properties and properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or left or 0),
		PaddingTop = UDim.new(0, top or left or 0),
		PaddingBottom = UDim.new(0, bottom or top or left or 0),
		Parent = parent,
	})
end

local function clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function roundToStep(value, step)
	if not step or step <= 0 then
		return value
	end
	return math.floor((value / step) + 0.5) * step
end

local function safeCall(callback, ...)
	if type(callback) ~= "function" then
		return true
	end
	local ok, message = pcall(callback, ...)
	if not ok then
		warn("[Lotus] Callback error: " .. tostring(message))
	end
	return ok
end

local function normalizeOptions(value, titleKey)
	if type(value) == "string" then
		return { [titleKey or "Title"] = value }
	end
	return value or {}
end

local function resolveGuiParent(explicitParent)
	if explicitParent then
		return explicitParent
	end
	local player = Players.LocalPlayer
	assert(player, "[Lotus] Lotus.new must run on the client or receive config.Parent")
	return player:WaitForChild("PlayerGui")
end

local function formatNumber(value)
	if math.abs(value - math.floor(value)) < 0.00001 then
		return tostring(math.floor(value))
	end
	return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end
