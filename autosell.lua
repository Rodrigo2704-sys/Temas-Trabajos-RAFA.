local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Misc = ReplicatedStorage:WaitForChild("BrainrotsThings"):WaitForChild("Misc")
local BrainrotEconomy = require(Misc:WaitForChild("BrainrotEconomy"))
local PlayerEvents = Misc:WaitForChild("Events"):WaitForChild("Player")

local RequestInventory = PlayerEvents:WaitForChild("RequestInventory")
local InventoryUpdated = PlayerEvents:WaitForChild("InventoryUpdated")
local SellAll = PlayerEvents:WaitForChild("SellAll")
local SellItem = PlayerEvents:WaitForChild("SellItem")

local inventory = {}
local favourites = {}

InventoryUpdated.OnClientEvent:Connect(function(items, _, favourited)
	inventory = type(items) == "table" and items or {}
	favourites = type(favourited) == "table" and favourited or {}
end)

RequestInventory:FireServer()

local SELLABLE_RARITIES = {
	"Common", "Uncommon", "Rare", "Epic", "Legendary",
	"Mythic", "Cosmic", "Secret", "Celestial", "Divine"
}

-- Rarezas que NO se pueden vender por lote con SellAll (el juego solo permite venderlas una por una con SellItem)
local INDIVIDUAL_SELL_ONLY = {
	Divine = true,
}

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoSellExact"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 430)
Main.Position = UDim2.new(0.5, -130, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
Title.Text = "Auto Sell (Fixed)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -33, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Main
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local function makeToggle(text, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	btn.Text = text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(255, 100, 100)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = Main
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local AutoSellToggle = makeToggle("Auto Sell", 48)
local AutoSellEarnToggle = makeToggle("Auto Sell By Earn", 88)

local ThresholdLabel = Instance.new("TextLabel")
ThresholdLabel.Size = UDim2.new(1, -20, 0, 18)
ThresholdLabel.Position = UDim2.new(0, 10, 0, 128)
ThresholdLabel.BackgroundTransparency = 1
ThresholdLabel.Text = "Sell Under Cash/s:"
ThresholdLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
ThresholdLabel.Font = Enum.Font.Gotham
ThresholdLabel.TextSize = 12
ThresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
ThresholdLabel.Parent = Main

local ThresholdBox = Instance.new("TextBox")
ThresholdBox.Size = UDim2.new(1, -20, 0, 28)
ThresholdBox.Position = UDim2.new(0, 10, 0, 148)
ThresholdBox.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
ThresholdBox.Text = "0"
ThresholdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ThresholdBox.Font = Enum.Font.Gotham
ThresholdBox.TextSize = 13
ThresholdBox.ClearTextOnFocus = false
ThresholdBox.Parent = Main
Instance.new("UICorner", ThresholdBox).CornerRadius = UDim.new(0, 6)

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, -20, 0, 18)
DelayLabel.Position = UDim2.new(0, 10, 0, 184)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Loop Delay (segundos):"
DelayLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 12
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = Main

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(1, -20, 0, 28)
DelayBox.Position = UDim2.new(0, 10, 0, 204)
DelayBox.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
DelayBox.Text = "4"
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.Font = Enum.Font.Gotham
DelayBox.TextSize = 13
DelayBox.ClearTextOnFocus = false
DelayBox.Parent = Main
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 6)

local RarityLabel = Instance.new("TextLabel")
RarityLabel.Size = UDim2.new(1, -20, 0, 18)
RarityLabel.Position = UDim2.new(0, 10, 0, 242)
RarityLabel.BackgroundTransparency = 1
RarityLabel.Text = "Rarities (verde = vender):"
RarityLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
RarityLabel.Font = Enum.Font.Gotham
RarityLabel.TextSize = 12
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.Parent = Main

local selectedRarities = {
	Common = true,
	Uncommon = true,
	Rare = true,
	Epic = true,
}

local function createRarityButton(name, index)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 78, 0, 26)
	local row = math.floor((index - 1) / 3)
	local col = (index - 1) % 3
	btn.Position = UDim2.new(0, 10 + col * 84, 0, 264 + row * 30)
	btn.BackgroundColor3 = selectedRarities[name] and Color3.fromRGB(55, 130, 75) or Color3.fromRGB(42, 42, 52)
	btn.Text = name
	btn.TextColor3 = selectedRarities[name] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 11
	btn.Parent = Main
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	btn.MouseButton1Click:Connect(function()
		if selectedRarities[name] then
			selectedRarities[name] = nil
			btn.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
			btn.TextColor3 = Color3.fromRGB(170, 170, 170)
		else
			selectedRarities[name] = true
			btn.BackgroundColor3 = Color3.fromRGB(55, 130, 75)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
end

for i, rarity in ipairs(SELLABLE_RARITIES) do
	createRarityButton(rarity, i)
end

-- ===================== LOGIC =====================
local autoSellEnabled = false
local autoSellEarnEnabled = false

local function setToggleVisual(btn, state, onText, offText)
	if state then
		btn.Text = onText
		btn.TextColor3 = Color3.fromRGB(100, 255, 120)
		btn.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
	else
		btn.Text = offText
		btn.TextColor3 = Color3.fromRGB(255, 100, 100)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	end
end

AutoSellToggle.MouseButton1Click:Connect(function()
	autoSellEnabled = not autoSellEnabled
	setToggleVisual(AutoSellToggle, autoSellEnabled, "Auto Sell: ON", "Auto Sell: OFF")
end)

AutoSellEarnToggle.MouseButton1Click:Connect(function()
	autoSellEarnEnabled = not autoSellEarnEnabled
	setToggleVisual(AutoSellEarnToggle, autoSellEarnEnabled, "Auto Sell By Earn: ON", "Auto Sell By Earn: OFF")
end)

local function isFavourited(id)
	for _, fav in favourites do
		if fav == id then return true end
	end
	return false
end

-- Intenta detectar el campo de rareza real dentro de un item (por si el nombre varía según el juego)
local function getItemRarity(item)
	if type(item) ~= "table" then return nil end
	return item.Rarity or item.rarity or item.RarityName or item.rarityName
end

-- Cuenta cuántos items quedan de una rareza específica en el inventario (sin contar favoritos)
-- Devuelve nil si no pudo detectar el campo de rareza en ningún item (para no bloquear la venta)
local function countRarity(rarity)
	local count = 0
	local detectedAny = false
	for _, item in ipairs(inventory) do
		local r = getItemRarity(item)
		if r ~= nil then
			detectedAny = true
			if r == rarity and not isFavourited(item.id) then
				count += 1
			end
		end
	end
	if not detectedAny then
		return nil -- no se pudo leer el campo de rareza, no confiamos en el conteo
	end
	return count
end

task.spawn(function()
	while ScreenGui.Parent do
		if autoSellEnabled then
			for _, rarity in ipairs(SELLABLE_RARITIES) do
				if selectedRarities[rarity] then
					if INDIVIDUAL_SELL_ONLY[rarity] then
						-- Esta rareza no soporta venta por lote: se vende item por item con SellItem
						local safety = 0
						while countRarity(rarity) ~= 0 and safety < 60 do
							local soldAny = false
							for _, item in ipairs(inventory) do
								if type(item) == "table" and item.id and getItemRarity(item) == rarity and not isFavourited(item.id) then
									pcall(function() SellItem:FireServer(item.id) end)
									task.wait(0.15)
									soldAny = true
								end
							end
							safety += 1
							pcall(function() RequestInventory:FireServer() end)
							task.wait(0.4)
							if not soldAny then break end -- no había nada que vender (o no se detectó la rareza)
						end
					else
						local attempts = 0
						local minAttempts = 3 -- garantiza al menos 3 clicks, igual que el comportamiento original

						while attempts < 40 do
							pcall(function() SellAll:FireServer(rarity) end)
							task.wait(0.18)
							attempts += 1

							-- cada 3 clicks pedimos inventario actualizado para saber si ya se vendió todo
							if attempts % 3 == 0 then
								pcall(function() RequestInventory:FireServer() end)
								task.wait(0.4) -- tiempo para que llegue InventoryUpdated

								local remaining = countRarity(rarity)
								-- Solo cortamos temprano si pudimos confirmar que ya no queda nada de esta rareza
								if remaining ~= nil and remaining <= 0 and attempts >= minAttempts then
									break
								end
							end
						end
					end
				end
			end
			pcall(function()
				RequestInventory:FireServer()
			end)
		end

		if autoSellEarnEnabled then
			local threshold = tonumber(ThresholdBox.Text) or 0
			if threshold > 0 then
				for _, item in ipairs(inventory) do
					if type(item) == "table" and item.id and not isFavourited(item.id) then
						local ok, earn = pcall(BrainrotEconomy.getCashPerSecondForItem, item)
						if ok and (tonumber(earn) or 0) < threshold then
							pcall(function()
								SellItem:FireServer(item.id)
							end)
							task.wait(0.12)
						end
					end
				end
			end
		end

		local delay = tonumber(DelayBox.Text) or 4
		delay = math.clamp(delay, 1.5, 60)
		task.wait(delay)
	end
end)

task.spawn(function()
	while ScreenGui.Parent do
		pcall(function()
			RequestInventory:FireServer()
		end)
		task.wait(8)
	end
end)

print("✅ Auto Sell Fixed cargado")
