local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local common = ReplicatedStorage:WaitForChild("common")
local commonUtil = common:WaitForChild("util")

local callOnAll = require(commonUtil:WaitForChild("callOnAll"))

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Client = {}

Client.modules = {
	sell = require(script:WaitForChild("sell")),
	
	confirmPurchase = require(script:WaitForChild("confirmPurchase")),
	
	sidebar = require(script:WaitForChild("sidebar")),
	skillbar = require(script:WaitForChild("skillbar")),
	store = require(script:WaitForChild("store")),
	store_gamepass = require(script:WaitForChild("store_gamepass")),
	store_coin = require(script:WaitForChild("store_coin")),
	shop = require(script:WaitForChild("shop")),
	stats = require(script:WaitForChild("stats")),
	profile = require(script:WaitForChild("profile")),
	rebirth = require(script:WaitForChild("rebirth")),
	crates = require(script:WaitForChild("crates")),
}

Client.toLoad = {
	Client.modules.sell,
	
	Client.modules.confirmPurchase,
	
	Client.modules.skillbar,
	Client.modules.stats,
	Client.modules.shop,
	Client.modules.store,
	Client.modules.store_gamepass,
	Client.modules.store_coin,
	Client.modules.sidebar,
	Client.modules.profile,
	Client.modules.rebirth,
	Client.modules.crates,
}

function Client:update()
	for _,module in pairs(Client.toLoad) do
		module:updateClient(self)
	end
end

function Client:setView(frameId)
	print("Set view from",Client.view,"to",frameId)
	Client.view = frameId
	self:update()
end

function Client:setShopCategory(categoryId)
	Client.shopCategory = categoryId
	self:update()
end

Client.view = nil
Client.shopCategory = nil
Client.isGliding = false

Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

-- init on all modules
callOnAll(Client.toLoad,"init")

-- player ready, start all modules
callOnAll(Client.toLoad,"start",Client)