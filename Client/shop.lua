local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local common = ReplicatedStorage:WaitForChild("common")
local commonUtil = common:WaitForChild("util")

local dictLen = require(commonUtil:WaitForChild("dictLen"))

local onClick = require(script.Parent:WaitForChild("onClick"))
local frameOpenAnimation = require(script.Parent:WaitForChild("frameOpenAnimation"))
local shopButton = require(script.Parent:WaitForChild("shopButton"))

local PouchData = require(ReplicatedStorage:WaitForChild("BackpackData"))
local ItemData = require(ReplicatedStorage:WaitForChild("ItemData"))

local Client
local localPlayer = Players.LocalPlayer
local stats = localPlayer:WaitForChild("stats")
local character = localPlayer.Character or localPlayer.CharacterAdded:wait()

local shopFolder = game.Workspace:WaitForChild("ShopFolder")
local backpackShop = game.Workspace:WaitForChild("BackpackShop")
local shopEnter = game.Workspace:WaitForChild("ShopEnter")
local shopLeave = game.Workspace:WaitForChild("ShopLeave")

local gui = script.Parent.Parent
local components = {mainFrame = gui:WaitForChild("shop")}
components.close = components.mainFrame:WaitForChild("close")
components.title = components.mainFrame:WaitForChild("title")
components.content = components.mainFrame:WaitForChild("content")
components.pouch = components.content:WaitForChild("pouch")
components.wings = components.content:WaitForChild("wings")

local debounce

local shop = {}

function shop:updateClient()
	if Client.view ~= "shop" and components.mainFrame.Visible == true then
		frameOpenAnimation:Close(components.mainFrame)
	end
	
	components.pouch.Visible = Client.shopCategory == "pouch"
	components.wings.Visible = Client.shopCategory == "wings"
	
	components.title.Text = Client.shopCategory == "pouch" and "Pouch shop" or Client.shopCategory == "wings" and "Wings shop" or "Shop"
	components.mainFrame.ImageColor3 = Client.shopCategory == "pouch" and Color3.fromRGB(53,27,51) or Client.shopCategory == "wings" and Color3.fromRGB(20,44,53) or Color3.fromRGB(33,36,53)
	
	if Client.view == "shop" then
		if components.mainFrame.Visible == false then
			components.mainFrame.Visible = true
			frameOpenAnimation:Open(components.mainFrame)
		end
	end
end

function shop:start(client)
	Client = client
end

local function teleport(enter)
	script.doorSound:Play()
	character:WaitForChild("HumanoidRootPart").CFrame = enter and shopLeave.CFrame * CFrame.new(8, 0, 0) * CFrame.Angles(0,math.rad(-90),0) or shopEnter.CFrame * CFrame.new(8, 0, 0)
end

local function anim()
	
end

function shop:init()
	components.close.MouseButton1Click:Connect(function()
		onClick:PlaySound()
		Client:setView(nil)
	end)
	
	for name,data in pairs(PouchData.Backpacks) do
		spawn(function()
			if data.passId then
				local productInfo = MarketplaceService:GetProductInfo(data.passId,Enum.InfoType.GamePass)
				
				local button = shopButton.create({
					id = name,
					type = "pouch",
					name = name,
					passId = data.passId,
					price = productInfo.PriceInRobux,
					cap = data.Capacity,
					image = data.ImageId or "rbxassetid://"..productInfo.IconImageAssetId,
					zindex = 12,
					layoutorder = #components.pouch:GetChildren()-2+1,
				})
				button.Parent = components.pouch
			else
				local button = shopButton.create({
					id = name,
					type = "pouch",
					name = name,
					price = data.Price,
					cap = data.Capacity,
					image = data.ImageId,
					zindex = 12,
					layoutorder = #components.pouch:GetChildren()-2+1,
				})
				button.Parent = components.pouch
			end
		end)
	end
	
	for name,data in pairs(ItemData.Wings) do
		spawn(function()
			if not data.Price then return end
			
			if data.passId then
				local productInfo = MarketplaceService:GetProductInfo(data.passId,Enum.InfoType.GamePass)
				
				local button = shopButton.create({
					id = name,
					type = "wings",
					name = name,
					passId = data.passId,
					price = productInfo.PriceInRobux,
					power = data.Power,
					image = "rbxassetid://"..productInfo.IconImageAssetId,
					zindex = 12,
					layoutorder = #components.wings:GetChildren()-2+1,
				})
				button.Parent = components.wings
			else
				local button = shopButton.create({
					id = name,
					type = "wings",
					name = name,
					price = data.Price,
					power = data.Power,
					image = data.ImageId,
					zindex = 12,
					layoutorder = #components.wings:GetChildren()-2+1,
				})
				button.Parent = components.wings
			end
		end)
	end
	
	components.pouch.CanvasSize = UDim2.new(0,0,0,math.ceil(dictLen(PouchData.Backpacks)/3)*106+6)
	
	backpackShop.Touched:Connect(function(part)
		if part.Parent == character then
			if Client.view then return end
			Client:setShopCategory("pouch")
			Client:setView("shop")
		end
	end)
	
	for i,v in pairs(shopFolder:GetChildren()) do
		v.Touched:Connect(function(part)
			if part.Parent == character then
				if Client.view then return end
				Client:setShopCategory("wings")
				Client:setView("shop")
			end
		end)
	end
	
	shopEnter.Touched:Connect(function(part)
		if part.Parent == character and not debounce then
			debounce = true
			delay(1,function()
				debounce = false
			end)
			
			-- teleport and shop fade
			teleport(true)
			anim()
		end
	end)
	
	shopLeave.Touched:Connect(function(part)
		if part.Parent == character and not debounce then
			debounce = true
			delay(1,function()
				debounce = false
			end)
			
			-- teleport and shop fade
			teleport()
			anim()
		end
	end)
end

return shop