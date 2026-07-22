local Motion = {}

Motion.Fast = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
Motion.Normal = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
Motion.Slow = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function Motion.tween(instance, tweenInfo, properties)
	if not instance or not instance.Parent then
		return nil
	end
	local tween = TweenService:Create(instance, tweenInfo or Motion.Normal, properties)
	tween:Play()
	return tween
end

function Motion.press(button, scale)
	local uiScale = create("UIScale", { Scale = 1, Parent = button })
	local maid = Maid.new()
	maid:Give(button.MouseButton1Down:Connect(function()
		Motion.tween(uiScale, Motion.Fast, { Scale = scale or 0.97 })
	end))
	maid:Give(button.MouseButton1Up:Connect(function()
		Motion.tween(uiScale, Motion.Fast, { Scale = 1 })
	end))
	maid:Give(button.MouseLeave:Connect(function()
		Motion.tween(uiScale, Motion.Fast, { Scale = 1 })
	end))
	return maid
end
