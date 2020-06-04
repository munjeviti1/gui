local TweenService = game:GetService("TweenService")

local frameOpenAnimation = {}

function frameOpenAnimation:Open(frame)
	local UIScale = frame:FindFirstChildOfClass("UIScale")
	
	if not UIScale then
		UIScale = Instance.new("UIScale", frame)
		UIScale.Name = "anim"
	end
	
	UIScale.Scale = .5
	local anim = TweenService:Create(UIScale,TweenInfo.new(.2,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Scale = 1})
	anim:Play()
	anim.Completed:Connect(function()
		UIScale:Destroy()
	end)
end

function frameOpenAnimation:Close(frame)
	local UIScale = frame:FindFirstChildOfClass("UIScale")
	
	if not UIScale then
		UIScale = Instance.new("UIScale", frame)
		UIScale.Name = "anim"
	end
	
	UIScale.Scale = 1
	local anim = TweenService:Create(UIScale,TweenInfo.new(.1,Enum.EasingStyle.Cubic,Enum.EasingDirection.In),{Scale = .8})
	anim:Play()
	anim.Completed:Connect(function()
		frame.Visible = false
		UIScale:Destroy()
	end)
end

return frameOpenAnimation