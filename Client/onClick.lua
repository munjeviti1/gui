local onClick = {}

local buttonEntry = {}

function onClick:Press(button)
	local buttonAnchorPoint = button.AnchorPoint
	
	local SizeX = button.Size.X
	local SizeY = button.Size.Y
	local PosX = button.Position.X
	local PosY = button.Position.Y
	
	if not buttonEntry[button] then
		buttonEntry[button] = {SizeX = SizeX, SizeY = SizeY, PosX = PosX, PosY = PosY}
	elseif buttonEntry[button] then
		SizeX = buttonEntry[button].SizeX
		SizeY = buttonEntry[button].SizeY
		PosX = buttonEntry[button].PosX
		PosY = buttonEntry[button].PosY
	end
	
	local PosG = UDim2.new(PosX,PosY)
	local SizeG = UDim2.new(SizeX.Scale*.9, SizeX.Offset*.9, SizeY.Scale*.9, SizeY.Offset*.9)
	
	if buttonAnchorPoint == Vector2.new(0,0) then
		PosG = UDim2.new(PosX.Scale + SizeX.Scale*.1/2, PosX.Offset + SizeX.Offset*.1/2, PosY.Scale + SizeY.Scale*.1/2, PosY.Offset + SizeY.Offset*.1/2)
	elseif buttonAnchorPoint == Vector2.new(0,1) then
		PosG = UDim2.new(PosX.Scale + SizeX.Scale*.1/2, PosX.Offset + SizeX.Offset*.1/2, PosY.Scale - SizeY.Scale*.1/2, PosY.Offset - SizeY.Offset*.1/2)
	elseif buttonAnchorPoint == Vector2.new(1,0) then
		PosG = UDim2.new(PosX.Scale - SizeX.Scale*.1/2, PosX.Offset - SizeX.Offset*.1/2, PosY.Scale + SizeY.Scale*.1/2, PosY.Offset + SizeY.Offset*.1/2)
	elseif buttonAnchorPoint == Vector2.new(1,1) then
		PosG = UDim2.new(PosX.Scale - SizeX.Scale*.1/2, PosX.Offset - SizeX.Offset*.1/2, PosY.Scale - SizeY.Scale*.1/2, PosY.Offset - SizeY.Offset*.1/2)
	end
	
	button:TweenSizeAndPosition(SizeG,PosG,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.1,true)
end

function onClick:Release(button)
	local buttonAnchorPoint = button.AnchorPoint
	
	if not buttonEntry[button] then return end
	
	local SizeX = buttonEntry[button].SizeX
	local SizeY = buttonEntry[button].SizeY
	local PosX = buttonEntry[button].PosX
	local PosY = buttonEntry[button].PosY
	
	local PosG = UDim2.new(PosX,PosY)
	local SizeG = UDim2.new(SizeX,SizeY)
	
	button:TweenSizeAndPosition(SizeG,PosG,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.2,true)
end

function onClick:PlaySound()
	script.sound:Play()
end

function onClick.Animate(button)
	local mouseDown
	button.MouseButton1Click:Connect(function()
		onClick:PlaySound()
	end)
	button.MouseButton1Down:Connect(function()
		mouseDown = true
		onClick:Press(button)
	end)
	button.MouseButton1Up:Connect(function()
		mouseDown = false
		onClick:Release(button)
	end)
	button.MouseLeave:Connect(function()
		if mouseDown then onClick:Release(button) end
	end)
end

return onClick