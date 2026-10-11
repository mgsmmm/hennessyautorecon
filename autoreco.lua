-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Prevent duplicate UI if executed twice
if CoreGui:FindFirstChild("PetUniverseCurrencyGui") then
	CoreGui.PetUniverseCurrencyGui:Destroy()
end

-- Create ScreenGui (using CoreGui so it works with executors smoothly)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PetUniverseCurrencyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Create Main Frame (Draggable & Clean look)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 50)
frame.Position = UDim2.new(0.5, -130, 0, 10) -- Top center
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 95)
stroke.Thickness = 1.5
stroke.Parent = frame

-- Create TextLabel for Display
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -10, 1, 0)
textLabel.Position = UDim2.new(0, 5, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.GothamBold
textLabel.Text = "Loading currencies..."
textLabel.Parent = frame

-- Function to find stats dynamically
local function findStat(statName)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild(statName) then
		return leaderstats[statName]
	end
	
	for _, folderName in ipairs({"Stats", "Data", "Values", "Currencies", "PlayerValues"}) do
		local folder = player:FindFirstChild(folderName)
		if folder and folder:FindFirstChild(statName) then
			return folder[statName]
		end
	end
	
	return player:FindFirstChild(statName)
end

-- Number formatter
local function formatNumber(n)
	n = math.floor(tonumber(n) or 0)
	return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Main update loop/checker
task.spawn(function()
	local coins, rubies, gems
	
	-- Continuously look for stats until they load in
	while not (coins and rubies and gems) do
		coins = findStat("Coins") or findStat("Coin")
		rubies = findStat("Rubies") or findStat("Ruby")
		gems = findStat("Gems") or findStat("Gem")
		task.wait(1)
	end

	local function updateDisplay()
		local coinVal = coins and coins.Value or 0
		local rubyVal = rubies and rubies.Value or 0
		local gemVal = gems and gems.Value or 0

		textLabel.Text = string.format(
			"🪙 %s  |  ❤️ %s  |  💎 %s",
			formatNumber(coinVal),
			formatNumber(rubyVal),
			formatNumber(gemVal)
		)
	end

	coins.Changed:Connect(updateDisplay)
	rubies.Changed:Connect(updateDisplay)
	gems.Changed:Connect(updateDisplay)

	updateDisplay()
end)
