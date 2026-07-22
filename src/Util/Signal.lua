local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_bindable = Instance.new("BindableEvent"),
		_destroyed = false,
	}, Signal)
end

function Signal:Connect(callback)
	assert(not self._destroyed, "Cannot connect to a destroyed Signal")
	assert(type(callback) == "function", "Signal callback must be a function")
	return self._bindable.Event:Connect(callback)
end

function Signal:Once(callback)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

function Signal:Fire(...)
	if not self._destroyed then
		self._bindable:Fire(...)
	end
end

function Signal:Wait()
	assert(not self._destroyed, "Cannot wait on a destroyed Signal")
	return self._bindable.Event:Wait()
end

function Signal:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self._bindable:Destroy()
end
