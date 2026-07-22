local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {}, _destroyed = false }, Maid)
end

function Maid:Give(taskValue)
	if taskValue == nil then
		return nil
	end
	if self._destroyed then
		self:_clean(taskValue)
		return taskValue
	end
	table.insert(self._tasks, taskValue)
	return taskValue
end

function Maid:_clean(taskValue)
	local kind = typeof(taskValue)
	if kind == "RBXScriptConnection" then
		taskValue:Disconnect()
	elseif kind == "Instance" then
		taskValue:Destroy()
	elseif type(taskValue) == "function" then
		taskValue()
	elseif type(taskValue) == "table" then
		if type(taskValue.Destroy) == "function" then
			taskValue:Destroy()
		elseif type(taskValue.Disconnect) == "function" then
			taskValue:Disconnect()
		end
	end
end

function Maid:Cleanup()
	for index = #self._tasks, 1, -1 do
		local taskValue = self._tasks[index]
		self._tasks[index] = nil
		local ok, message = pcall(function()
			self:_clean(taskValue)
		end)
		if not ok then
			warn("[Lotus] Cleanup error: " .. tostring(message))
		end
	end
end

function Maid:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:Cleanup()
end
