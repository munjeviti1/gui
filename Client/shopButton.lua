local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local common = ReplicatedStorage:WaitForChild("common")
local commonUtil = common:WaitForChild("util")

local getTextSize = require(commonUtil:WaitForChild("getTextSize"))
local suffixModule = require(ReplicatedStorage:WaitForChild("SuffixModule"))

local confirmPurchase = require(script.Parent:WaitForChild("confirmPurchase"))
local frameOpenAnimation = require(script.Parent:WaitForChild("frameOpenAnimation"))
local onClick = require(script.Parent:WaitForChild("onClick"))

local buyEvent = script.Parent.Parent:WaitForChild("Server"):WaitForChild("buy")

local localPlayer = Players.LocalPlayer
local backpacks = localPlayer:WaitForChild("backpacks")
local items = localPlayer:WaitForChild("items")
local stats = localPlayer:WaitForChild("stats")
local equippedBackpack = stats:WaitForChild("EquippedBackpack")
local equippedWing = stats:WaitForChild("EquippedWing")

local shopButton = {}

function shopButton.create(props)
	
	local owned = props.passId and MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, props.passId) or props.type == "pouch" and backpacks:FindFirstChild(props.id) or props.type == "wings" and items:FindFirstChild(props.id)
	local equipped = props.type == "pouch" and equippedBackpack.Value == props.id or props.type == "wings" and equippedWing.Value == props.id or nil
	
	local Size = props.size or UDim2.new(0,100,0,100)
	local LayoutOrder = props.layoutorder or 0
	local ZIndex = props.zindex or 1
	
	local Name = props.name or "Button"
	local Image = props.image or ""
	
	local Button = Instance.new("ImageButton")
	Button.Name = Name
	Button.BackgroundTransparency = 1
	Button.ImageColor3 = Color3.new()
	Button.Image = "rbxassetid://4446551967"
	Button.ImageTransparency = .6
	Button.ScaleType = Enum.ScaleType.Slice
	Button.SliceCenter = Rect.new(20,20,20,20)
	Button.ZIndex = ZIndex
	Button.LayoutOrder = LayoutOrder
	
	Button.MouseButton1Click:Connect(function()
		if owned then
			buyEvent:FireServer(props.id,props.type)
		elseif not owned then
			if props.passId then MarketplaceService:PromptGamePassPurchase(localPlayer,props.passId) return end
			confirmPurchase:loadPurchase({
				id = props.id,
				type = props.type,
				name = props.name,
				price = props.price,
				desc = props.type == "pouch" and tostring(props.cap).." Capacity" or props.type == "wings" and tostring(props.power).." Power" or props.type == "crate" and "Yayeet",
			})
		end
	end)
	
	local img = Instance.new("ImageLabel",Button)
	img.Name = "img"
	img.BackgroundTransparency = 1
	img.AnchorPoint = Vector2.new(.5,.5)
	img.Position = UDim2.new(.5,0,.5,0)
	img.Size = UDim2.new(1,-20,1,-20)
	img.ZIndex = ZIndex
	img.Image = Image
	img.ScaleType = Enum.ScaleType.Fit
	
	local equippedImage
	
	if props.type == "pouch" or props.type == "wings" then
		equippedImage = Instance.new("ImageLabel")
		equippedImage.Name = "equipped"
		equippedImage.BackgroundTransparency = 1
		equippedImage.Size = UDim2.new(1,0,1,0)
		equippedImage.ImageColor3 = Color3.fromRGB(60,220,60)
		equippedImage.Image = "rbxassetid://4918389192"
		equippedImage.ScaleType = Enum.ScaleType.Slice
		equippedImage.SliceCenter = Rect.new(20,20,20,20)
		equippedImage.Visible = equipped
		equippedImage.ZIndex = ZIndex + 1
		equippedImage.Parent = Button
	end
	
	local price = Instance.new("ImageLabel",Button)
	price.Name = "price"
	price.AnchorPoint = Vector2.new(1,1)
	price.BackgroundTransparency = 1
	price.Position = UDim2.new(1,5,1,5)
	price.Size = UDim2.new(0,20,0,20)
	price.ZIndex = ZIndex + 1
	price.ImageColor3 = equipped and Color3.fromRGB(60,220,60) or Color3.fromRGB(241,196,15)
	price.Image = "rbxassetid://3206414908"
	price.ScaleType = Enum.ScaleType.Slice
	price.SliceCenter = Rect.new(10,10,10,10)
	
	local gradient = Instance.new("UIGradient",price)
	gradient.Name = "gradient"
	gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
	gradient.Rotation = 90
	
	local layout = Instance.new("UIListLayout",price)
	layout.Name = "layout"
	layout.Padding = UDim.new(0,3)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	
	local text = Instance.new("TextLabel",price)
	text.Name = "text"
	text.BackgroundTransparency = 1
	text.LayoutOrder = 1
	text.Size = UDim2.new(0,0,0,16)
	text.Font = Enum.Font.GothamBlack
	text.Text = equipped and "EQUIPPED" or props.price == 0 and "FREE" or props.price and "¢"..suffixModule.HandleMoney(props.price) or ""
	text.TextColor3 = Color3.new(1,1,1)
	text.TextSize = 16
	text.ZIndex = ZIndex + 1
	
	if props.type == "pouch" then
		
		backpacks.DescendantAdded:Connect(function(descendant)
			if descendant.Name == props.id then
				owned = true
				
				if not equipped then
					price.ImageColor3 = Color3.fromRGB(41,180,218)
					text.Text = "OWNED"
					text.TextColor3 = Color3.new(1,1,1)
					
					text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
					price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
				end
			end
		end)
		
		equippedBackpack.Changed:Connect(function(newValue)
			if newValue == props.id then
				equipped = true
				
				price.ImageColor3 = Color3.fromRGB(60,220,60)
				text.Text = "EQUIPPED"
				text.TextColor3 = Color3.new(1,1,1)
				
				equippedImage.Visible = true
				text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
				price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
			else
				equipped = false
				equippedImage.Visible = false
				
				if owned then
					price.ImageColor3 = Color3.fromRGB(41,180,218)
					text.Text = "OWNED"
					text.TextColor3 = Color3.new(1,1,1)
				elseif not owned then
					price.ImageColor3 = props.passId and Color3.new(1,1,1) or Color3.fromRGB(241,196,15)
					text.Text = props.passId and tostring(props.price) or props.price == 0 and "FREE" or "¢"..suffixModule.HandleMoney(props.price)
					text.TextColor3 = props.passId and Color3.fromRGB(35,35,35) or Color3.new(1,1,1)
				end
				
				text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
				price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
			end
		end)
		
		Button.LayoutOrder = props.cap
		
		local cap = Instance.new("ImageLabel",Button)
		cap.Name = "cap"
		cap.BackgroundTransparency = 1
		cap.Position = UDim2.new(0,-5,0,-5)
		cap.Size = UDim2.new(0,20,0,20)
		cap.ZIndex = ZIndex + 1
		cap.ImageColor3 = Color3.new(.05,.05,.05)--Color3.fromRGB(255, 100, 61)
		cap.Image = "rbxassetid://3206414908"
		cap.ScaleType = Enum.ScaleType.Slice
		cap.SliceCenter = Rect.new(10,10,10,10)
		
		local gradient = Instance.new("UIGradient",cap)
		gradient.Name = "gradient"
		gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
		gradient.Rotation = 90
		
		local layout = Instance.new("UIListLayout",cap)
		layout.Name = "layout"
		layout.Padding = UDim.new(0,3)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		
		local text = Instance.new("TextLabel",cap)
		text.Name = "text"
		text.BackgroundTransparency = 1
		text.LayoutOrder = 1
		text.Size = UDim2.new(0,0,0,16)
		text.Font = Enum.Font.GothamBlack
		text.Text = props.cap == math.huge and "INFINITE" or suffixModule.HandleMoney(props.cap)
		text.TextColor3 = Color3.new(1,1,1)
		text.TextSize = 16
		text.TextYAlignment = Enum.TextYAlignment.Center
		text.ZIndex = ZIndex + 1
		
		text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
		cap.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
		
		if props.cap == math.huge then
			local gradient = Instance.new("UIGradient",text)
			gradient.Name = "grad"
			
			local ts = game:GetService("TweenService")
			local ti = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local offset = {Offset = Vector2.new(1, 0)}
			local create = ts:Create(gradient, ti, offset)
			local startingPos = Vector2.new(-1, 0)
			local list = {}
			local s, kpt = ColorSequence.new, ColorSequenceKeypoint.new
			local counter = 0
			local status = "down"
			
			gradient.Offset = startingPos
			
			local function rainbowColors()
				local sat, val = 255, 255
				
				for i = 1, 15 do
					local hue = i * 17
					table.insert(list, Color3.fromHSV(hue / 255, sat / 255, val / 255))
				end
			end
			
			rainbowColors()
			
			gradient.Color = s({
				kpt(0, list[#list]),
				kpt(0.5, list[#list - 1]),
				kpt(1, list[#list - 2])
			})
			
			counter = #list
			
			local function animate()
				create:Play()
				create.Completed:Wait()
				gradient.Offset = startingPos
				gradient.Rotation = 180
				
				if counter == #list - 1 and status == "down" then
					gradient.Color = s({
						kpt(0, gradient.Color.Keypoints[1].Value),
						kpt(0.5, list[#list]),
						kpt(1, list[1])
					})
					counter = 1
					status = "up"
				elseif counter == #list and status == "down" then
					gradient.Color = s({
						kpt(0, gradient.Color.Keypoints[1].Value),
						kpt(0.5, list[1]),
						kpt(1, list[2])
					})
					counter = 2
					status = "up"
				elseif counter <= #list - 2 and status == "down" then 
					gradient.Color = s({
						kpt(0, gradient.Color.Keypoints[1].Value),
						kpt(0.5, list[counter + 1]),
						kpt(1, list[counter + 2])
					})
					counter = counter + 2
					status = "up"
				end
				
				create:Play()
				create.Completed:Wait()
				gradient.Offset = startingPos
				gradient.Rotation = 0
				
				if counter == #list - 1 and status == "up" then
					gradient.Color = s({
						kpt(0, list[1]),
						kpt(0.5, list[#list]),
						kpt(1, gradient.Color.Keypoints[3].Value)	
					})
					counter = 1
					status = "down"
				 elseif counter == #list and status == "up" then
					gradient.Color = s({
						kpt(0, list[2]),
						kpt(0.5, list[1]),
						kpt(1, gradient.Color.Keypoints[3].Value)	
					})
					counter = 2
					status = "down"
				elseif counter <= #list - 2 and status == "up" then
					gradient.Color = s({
						kpt(0, list[counter + 2]),
						kpt(0.5, list[counter + 1]),
						kpt(1, gradient.Color.Keypoints[3].Value)
							
					})
					counter = counter + 2
					status = "down"
				end
				animate()
			end
			
			spawn(animate)
		end
	elseif props.type == "wings" then
		
		items.DescendantAdded:Connect(function(descendant)
			if descendant.Name == props.id then
				owned = true
				
				if not equipped then
					price.ImageColor3 = Color3.fromRGB(41,180,218)
					text.Text = "OWNED"
					text.TextColor3 = Color3.new(1,1,1)
					
					text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
					price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
				end
			end
		end)
		
		equippedWing.Changed:Connect(function(newValue)
			if newValue == props.id then
				equipped = true
				
				price.ImageColor3 = Color3.fromRGB(60,220,60)
				text.Text = "EQUIPPED"
				text.TextColor3 = Color3.new(1,1,1)
				
				equippedImage.Visible = true
				text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
				price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
			else
				equipped = false
				equippedImage.Visible = false
				
				if owned then
					price.ImageColor3 = Color3.fromRGB(41,180,218)
					text.Text = "OWNED"
					text.TextColor3 = Color3.new(1,1,1)
				elseif not owned then
					price.ImageColor3 = props.passId and Color3.new(1,1,1) or Color3.fromRGB(241,196,15)
					text.Text = props.passId and tostring(props.price) or props.price == 0 and "FREE" or "¢"..suffixModule.HandleMoney(props.price)
					text.TextColor3 = props.passId and Color3.fromRGB(35,35,35) or Color3.new(1,1,1)
				end
				
				text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
				price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
			end
		end)
		
		Button.LayoutOrder = props.power
		
		local power = Instance.new("ImageLabel",Button)
		power.Name = "cap"
		power.BackgroundTransparency = 1
		power.Position = UDim2.new(0,-5,0,-5)
		power.Size = UDim2.new(0,20,0,20)
		power.ZIndex = ZIndex + 1
		power.ImageColor3 = Color3.new(.05,.05,.05)--Color3.fromRGB(255, 100, 61)
		power.Image = "rbxassetid://3206414908"
		power.ScaleType = Enum.ScaleType.Slice
		power.SliceCenter = Rect.new(10,10,10,10)
		
		local gradient = Instance.new("UIGradient",power)
		gradient.Name = "gradient"
		gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
		gradient.Rotation = 90
		
		local layout = Instance.new("UIListLayout",power)
		layout.Name = "layout"
		layout.Padding = UDim.new(0,3)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		
		local img = Instance.new("ImageLabel",power)
		img.Name = "img"
		img.LayoutOrder = 1
		img.BackgroundTransparency = 1
		img.Size = UDim2.new(0,9,0,16)
		img.ScaleType = Enum.ScaleType.Fit
		img.ImageColor3 = Color3.new(1,1,0)
		img.Image = "rbxassetid://4902683015"
		img.ZIndex = ZIndex + 1
		
		local text = Instance.new("TextLabel",power)
		text.Name = "text"
		text.BackgroundTransparency = 1
		text.LayoutOrder = 2
		text.Size = UDim2.new(0,0,0,16)
		text.Font = Enum.Font.GothamBlack
		text.Text = suffixModule.HandleMoney(props.power)
		text.TextColor3 = Color3.new(1,1,1)
		text.TextSize = 16
		text.ZIndex = ZIndex + 1
		
		text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
		power.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
	elseif props.type == "crate" or props.type == "crate_inventory" then
		local rarity = Instance.new("ImageLabel",Button)
		rarity.Name = "rarity"
		rarity.BackgroundTransparency = 1
		rarity.Position = UDim2.new(0,-5,0,-5)
		rarity.Size = UDim2.new(0,20,0,20)
		rarity.ZIndex = ZIndex + 1
		rarity.ImageColor3 = props.rarityColor
		rarity.Image = "rbxassetid://3206414908"
		rarity.ScaleType = Enum.ScaleType.Slice
		rarity.SliceCenter = Rect.new(10,10,10,10)
		
		local gradient = Instance.new("UIGradient",rarity)
		gradient.Name = "gradient"
		gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
		gradient.Rotation = 90
		
		local layout = Instance.new("UIListLayout",rarity)
		layout.Name = "layout"
		layout.Padding = UDim.new(0,3)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		
		local text = Instance.new("TextLabel",rarity)
		text.Name = "text"
		text.BackgroundTransparency = 1
		text.LayoutOrder = 2
		text.Size = UDim2.new(0,0,0,16)
		text.Font = Enum.Font.GothamBlack
		text.Text = tostring(props.rarity)
		text.TextColor3 = Color3.new(1,1,1)
		text.TextSize = 16
		text.ZIndex = ZIndex + 1
		
		price.ImageColor3 = Color3.fromRGB(127,75,65)
		
		text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
		rarity.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
		
		if props.type == "crate_inventory" then
			price:Destroy()
			
			local quantity = Instance.new("ImageLabel",Button)
			quantity.Name = "quantity"
			quantity.BackgroundTransparency = 1
			quantity.Position = UDim2.new(0,-5,0,17)
			quantity.Size = UDim2.new(0,20,0,20)
			quantity.ZIndex = ZIndex + 1
			quantity.ImageColor3 = Color3.fromRGB(127,75,65)
			quantity.Image = "rbxassetid://3206414908"
			quantity.ScaleType = Enum.ScaleType.Slice
			quantity.SliceCenter = Rect.new(10,10,10,10)
			
			local gradient = Instance.new("UIGradient",quantity)
			gradient.Name = "gradient"
			gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
			gradient.Rotation = 90
			
			local layout = Instance.new("UIListLayout",quantity)
			layout.Name = "layout"
			layout.Padding = UDim.new(0,3)
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			
			local text = Instance.new("TextLabel",quantity)
			text.Name = "text"
			text.BackgroundTransparency = 1
			text.LayoutOrder = 1
			text.Size = UDim2.new(0,0,0,16)
			text.Font = Enum.Font.GothamBlack
			text.Text = tostring(props.amount)
			text.TextColor3 = Color3.new(1,1,1)
			text.TextSize = 16
			text.ZIndex = ZIndex + 1
			
			text:GetPropertyChangedSignal("Text"):Connect(function()
				text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
				quantity.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
			end)
			
			local consume = Instance.new("ImageButton",Button)
			consume.Name = "consume"
			consume.AnchorPoint = Vector2.new(.5,.5)
			consume.BackgroundTransparency = 1
			consume.Position = UDim2.new(.5,0,1,0)
			consume.Size = UDim2.new(0,getTextSize("OPEN",Enum.Font.GothamBlack,16).X+10,0,20)
			consume.ZIndex = ZIndex + 1
			consume.ImageColor3 = Color3.fromRGB(29,165,255) -- 46, 147, 241
			consume.Image = "rbxassetid://3206414908"
			consume.ScaleType = Enum.ScaleType.Slice
			consume.Visible = false
			consume.SliceCenter = Rect.new(10,10,10,10)
			
			local gradient = Instance.new("UIGradient",consume)
			gradient.Name = "gradient"
			gradient.Color = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(139,139,139))
			gradient.Rotation = 90
			
			local layout = Instance.new("UIListLayout",consume)
			layout.Name = "layout"
			layout.Padding = UDim.new(0,3)
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			
			local text = Instance.new("TextLabel",consume)
			text.Name = "text"
			text.BackgroundTransparency = 1
			text.LayoutOrder = 1
			text.Size = UDim2.new(0,0,0,16)
			text.Font = Enum.Font.GothamBlack
			text.Text = "OPEN"
			text.TextColor3 = Color3.new(1,1,1)
			text.TextSize = 16
			text.ZIndex = ZIndex + 1
			
			Button.MouseEnter:Connect(function()
				consume.Visible = true
				frameOpenAnimation:Open(consume)
			end)
			
			Button.MouseLeave:Connect(function()
				--consume.Visible = false
				frameOpenAnimation:Close(consume)
			end)
		end
	end
	
	if props.productId then
		local robuxImg = Instance.new("ImageLabel", price)
		robuxImg.Name = "robuxImg"
		robuxImg.BackgroundTransparency = 1
		robuxImg.Size = UDim2.new(0,16,0,16)
		robuxImg.ZIndex = ZIndex + 1
		robuxImg.Image = "rbxassetid://4793508838"
		robuxImg.ImageColor3 = Color3.fromRGB(35,35,35)
		robuxImg.ScaleType = Enum.ScaleType.Fit
		
		price.ImageColor3 = Color3.new(1,1,1)
		text.Text = tostring(props.price)
		text.TextColor3 = Color3.fromRGB(35,35,35)
	end
	
	if props.passId then
		price.ImageColor3 = owned and Color3.fromRGB(41,180,218) or Color3.new(1,1,1)
		text.Text = owned and "OWNED" or tostring(props.price)
		text.TextColor3 = owned and Color3.new(1,1,1) or Color3.fromRGB(35,35,35)
		
		if not owned then
			local robuxImg = Instance.new("ImageLabel", price)
			robuxImg.Name = "robuxImg"
			robuxImg.BackgroundTransparency = 1
			robuxImg.Size = UDim2.new(0,16,0,16)
			robuxImg.ZIndex = ZIndex + 1
			robuxImg.Image = "rbxassetid://4793508838"
			robuxImg.ImageColor3 = Color3.fromRGB(35,35,35)
			robuxImg.ScaleType = Enum.ScaleType.Fit
		end
		
		Button.MouseButton1Click:Connect(function()
			if not owned then
				MarketplaceService:PromptGamePassPurchase(localPlayer,props.passId)
			end
		end)
	end
	
	text.Size = UDim2.new(0,getTextSize(text.Text,Enum.Font.GothamBlack,16).X,0,16)
	price.Size = UDim2.new(0,layout.AbsoluteContentSize.X+10,0,20)
	
	return Button
end

return shopButton