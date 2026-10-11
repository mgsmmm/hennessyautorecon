-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- UI Reference
local textLabel = script.Parent

-- Function to locate a currency value across common data locations
local function findStat(statName)
	-- Check standard leaderstats first
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild(statName) then
		return leaderstats[statName]
	end
	
	-- Check alternative folders like "Stats", "Data", or "Values"
	for _, folderName in ipairs({"Stats", "Data", "Values", "Currencies"}) do
		local folder = player:FindFirstChild(folderName)
		if folder and folder:FindFirstChild(statName) then
			return folder[statName]
		end
	end
	
	-- Direct child of player fallback
	return player:FindFirstChild(statName)
end

-- Wait for player data to load
task.wait(1)

-- Find currency ValueObjects
local coins = findStat("Coins") or findStat("Coin")
local rubies = findStat("Rubies") or findStat("Ruby")
local gems = findStat("Gems") or findStat("Gem")

-- Helper function to format numbers neatly (e.g., 1000 -> 1,000)
local function formatNumber(n)
	n = math.floor(tonumber(n) or 0)
	return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Function to update the TextLabel display
local function updateDisplay()
	local coinVal = coins and coins.Value or 0
	local rubyVal = rubies and rubies.Value or 0
	local gemVal = gems and gems.Value or 0

	textLabel.Text = string.format(
		"🪙 Coins: %s  |  ❤️ Rubies: %s  |  💎 Gems: %s",
		formatNumber(coinVal),
		formatNumber(rubyVal),
		formatNumber(gemVal)
	)
end

-- Bind listener events for live updates
if coins then coins.Changed:Connect(updateDisplay) end
if rubies then rubies.Changed:Connect(updateDisplay) end
if gems then gems.Changed:Connect(updateDisplay) end

-- If stats are added dynamically slightly later
player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" or child.Name == "Stats" then
		task.wait(0.5)
		coins = coins or findStat("Coins") or findStat("Coin")
		rubies = rubies or findStat("Rubies") or findStat("Ruby")
		gems = gems or findStat("Gems") or findStat("Gem")
		
		if coins then coins.Changed:Connect(updateDisplay) end
		if rubies then rubies.Changed:Connect(updateDisplay) end
		if gems then gems.Changed:Connect(updateDisplay) end
		
		updateDisplay()
	end
end)

-- Initial UI render
updateDisplay()
