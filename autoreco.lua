local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local ScriptContext = game:GetService("ScriptContext")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- Check if WebhookUrl is already set globally
local WEBHOOK_URL = getgenv().WebhookUrl or "https://discord.com/api/webhooks/1532835349728854128/ie6a1f70yZ5RiRupqHMoZ8o6GU7lJVBtASlpCy8b0SZqYRiBxmX-L8Y1SlAgNFmVwQzo"

local function sendWebhook(title, statusText, colorCode)
    if WEBHOOK_URL and WEBHOOK_URL ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        task.spawn(function()
            pcall(function()
                local payload = {
                    ["embeds"] = {{
                        ["title"] = title,
                        ["description"] = string.format("**Username:** %s\n**Status:** %s", player.Name, statusText),
                        ["color"] = colorCode,
                        ["footer"] = {
                            ["text"] = os.date("%Y-%m-%d %H:%M:%S") .. " | hennessy"
                        }
                    }}
                }
                local encodedData = HttpService:JSONEncode(payload)
                local requestFunc = syn and syn.request or http_request or request or HttpPost
                if requestFunc then
                    requestFunc({
                        Url = WEBHOOK_URL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = encodedData
                    })
                end
            end)
        end)
    end
end

if getgenv().JustReconnectedFlag then
    getgenv().JustReconnectedFlag = nil
    sendWebhook("Reconnected", "Successfully reconnected to the game!", 65280)
end

local targetParent = player:WaitForChild("PlayerGui")
pcall(function()
    if syn and syn.protect_gui then
        local protected = Instance.new("ScreenGui")
        syn.protect_gui(protected)
        protected.Parent = CoreGui
        targetParent = CoreGui
    elseif gethui then
        targetParent = gethui()
    end
end)

if targetParent:FindFirstChild("HennessyHubGUI") then
    targetParent.HennessyHubGUI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HennessyHubGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 2147483647
screenGui.Parent = targetParent

-- ========================================================================
-- FULL SCREEN COVER OVERLAY
-- ========================================================================
local fullScreenOverlay = Instance.new("Frame")
fullScreenOverlay.Name = "FullScreenOverlay"
fullScreenOverlay.Size = UDim2.new(1, 0, 1, 0)
fullScreenOverlay.Position = UDim2.new(0, 0, 0, 0)
fullScreenOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Default Black
fullScreenOverlay.BackgroundTransparency = 0
fullScreenOverlay.ZIndex = 5
fullScreenOverlay.Visible = true
fullScreenOverlay.Parent = screenGui

-- ========================================================================
-- MAIN HENNESSY MENU BAR (Draggable)
-- ========================================================================
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 160, 0, 38)
mainButton.Position = UDim2.new(0, 20, 0, 50)
mainButton.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
mainButton.Font = Enum.Font.GothamBold
mainButton.Text = "  Hennessy"
mainButton.TextColor3 = Color3.fromRGB(210, 215, 225)
mainButton.TextSize = 13
mainButton.TextXAlignment = Enum.TextXAlignment.Left
mainButton.ZIndex = 100
mainButton.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainButton

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 62, 80)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainButton

-- Master Kill Switch Button (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 26, 0, 26)
closeButton.Position = UDim2.new(1, -30, 0.5, -13)
closeButton.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(220, 80, 80)
closeButton.TextSize = 12
closeButton.ZIndex = 102
closeButton.Parent = mainButton

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- ========================================================================
-- DROPDOWN CONTAINER
-- ========================================================================
local dropdownContainer = Instance.new("Frame")
dropdownContainer.Size = UDim2.new(0, 160, 0, 250)
dropdownContainer.Position = UDim2.new(0, 0, 1, 6)
dropdownContainer.BackgroundTransparency = 1
dropdownContainer.Visible = false
dropdownContainer.ZIndex = 105
dropdownContainer.Parent = mainButton

-- 1. Auto Recon Button
local autoReconBtn = Instance.new("TextButton")
autoReconBtn.Size = UDim2.new(0, 160, 0, 36)
autoReconBtn.Position = UDim2.new(0, 0, 0, 0)
autoReconBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
autoReconBtn.Font = Enum.Font.Gotham
autoReconBtn.Text = "  Auto Recon: On"
autoReconBtn.TextColor3 = Color3.fromRGB(210, 215, 225)
autoReconBtn.TextSize = 12
autoReconBtn.TextXAlignment = Enum.TextXAlignment.Left
autoReconBtn.ZIndex = 106
autoReconBtn.Parent = dropdownContainer

local arCorner = Instance.new("UICorner")
arCorner.CornerRadius = UDim.new(0, 8)
arCorner.Parent = autoReconBtn

local arStroke = Instance.new("UIStroke")
arStroke.Color = Color3.fromRGB(55, 62, 80)
arStroke.Thickness = 1.5
arStroke.Parent = autoReconBtn

getgenv().AutoRejoinActive = true

autoReconBtn.MouseButton1Click:Connect(function()
    getgenv().AutoRejoinActive = not getgenv().AutoRejoinActive
    autoReconBtn.Text = getgenv().AutoRejoinActive and "  Auto Recon: On" or "  Auto Recon: Off"
end)

-- 2. FPS Booster Button
local fpsBtn = Instance.new("TextButton")
fpsBtn.Size = UDim2.new(0, 160, 0, 36)
fpsBtn.Position = UDim2.new(0, 0, 0, 42)
fpsBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
fpsBtn.Font = Enum.Font.Gotham
fpsBtn.Text = "  FPS Booster: On"
fpsBtn.TextColor3 = Color3.fromRGB(210, 215, 225)
fpsBtn.TextSize = 12
fpsBtn.TextXAlignment = Enum.TextXAlignment.Left
fpsBtn.ZIndex = 106
fpsBtn.Parent = dropdownContainer

local fpsCorner = Instance.new("UICorner")
fpsCorner.CornerRadius = UDim.new(0, 8)
fpsCorner.Parent = fpsBtn

local fpsStroke = Instance.new("UIStroke")
fpsStroke.Color = Color3.fromRGB(55, 62, 80)
fpsStroke.Thickness = 1.5
fpsStroke.Parent = fpsBtn

local storedObjects = {}
local function applyBoost()
    pcall(function()
        Lighting.GlobalShadows = false
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("Clouds") then
                v.Enabled = false
                table.insert(storedObjects, v)
            end
        end
    end)
end

local function restoreOriginal()
    pcall(function()
        Lighting.GlobalShadows = true
    end)
    for _, obj in ipairs(storedObjects) do
        if obj and obj.Parent then
            if obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj.Enabled = true
            end
        end
    end
    storedObjects = {}
end

local boosterActive = true
applyBoost()

fpsBtn.MouseButton1Click:Connect(function()
    boosterActive = not boosterActive
    if boosterActive then
        fpsBtn.Text = "  FPS Booster: On"
        applyBoost()
    else
        fpsBtn.Text = "  FPS Booster: Off"
        restoreOriginal()
    end
end)

-- 3. Stat Tracker Toggle Button
local statTrackerBtn = Instance.new("TextButton")
statTrackerBtn.Size = UDim2.new(0, 160, 0, 36)
statTrackerBtn.Position = UDim2.new(0, 0, 0, 84)
statTrackerBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
statTrackerBtn.Font = Enum.Font.Gotham
statTrackerBtn.Text = "  Stat Tracker: On"
statTrackerBtn.TextColor3 = Color3.fromRGB(210, 215, 225)
statTrackerBtn.TextSize = 12
statTrackerBtn.TextXAlignment = Enum.TextXAlignment.Left
statTrackerBtn.ZIndex = 106
statTrackerBtn.Parent = dropdownContainer

local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 8)
stCorner.Parent = statTrackerBtn

local stStroke = Instance.new("UIStroke")
stStroke.Color = Color3.fromRGB(55, 62, 80)
stStroke.Thickness = 1.5
stStroke.Parent = statTrackerBtn

-- 4. Background (*) Dropdown
local bgMenuBtn = Instance.new("TextButton")
bgMenuBtn.Size = UDim2.new(0, 160, 0, 36)
bgMenuBtn.Position = UDim2.new(0, 0, 0, 126)
bgMenuBtn.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
bgMenuBtn.Font = Enum.Font.Gotham
bgMenuBtn.Text = "  Background (*)"
bgMenuBtn.TextColor3 = Color3.fromRGB(210, 215, 225)
bgMenuBtn.TextSize = 12
bgMenuBtn.TextXAlignment = Enum.TextXAlignment.Left
bgMenuBtn.ZIndex = 106
bgMenuBtn.Parent = dropdownContainer

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 8)
bgCorner.Parent = bgMenuBtn

local bgStroke = Instance.new("UIStroke")
bgStroke.Color = Color3.fromRGB(55, 62, 80)
bgStroke.Thickness = 1.5
bgStroke.Parent = bgMenuBtn

local radioContainer = Instance.new("Frame")
radioContainer.Size = UDim2.new(0, 150, 0, 68)
radioContainer.Position = UDim2.new(0, 5, 0, 166)
radioContainer.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
radioContainer.Visible = false
radioContainer.ZIndex = 107
radioContainer.Parent = dropdownContainer

local rcCorner = Instance.new("UICorner")
rcCorner.CornerRadius = UDim.new(0, 6)
rcCorner.Parent = radioContainer

local rcStroke = Instance.new("UIStroke")
rcStroke.Color = Color3.fromRGB(45, 50, 65)
rcStroke.Thickness = 1
rcStroke.Parent = radioContainer

local radioWhite = Instance.new("TextButton")
radioWhite.Size = UDim2.new(1, -10, 0, 28)
radioWhite.Position = UDim2.new(0, 5, 0, 4)
radioWhite.BackgroundTransparency = 1
radioWhite.Font = Enum.Font.Gotham
radioWhite.Text = "  ( ) White"
radioWhite.TextColor3 = Color3.fromRGB(180, 185, 195)
radioWhite.TextSize = 11
radioWhite.TextXAlignment = Enum.TextXAlignment.Left
radioWhite.ZIndex = 108
radioWhite.Parent = radioContainer

local radioBlack = Instance.new("TextButton")
radioBlack.Size = UDim2.new(1, -10, 0, 28)
radioBlack.Position = UDim2.new(0, 5, 0, 34)
radioBlack.BackgroundTransparency = 1
radioBlack.Font = Enum.Font.Gotham
radioBlack.Text = "  (*) Black"
radioBlack.TextColor3 = Color3.fromRGB(100, 225, 120)
radioBlack.TextSize = 11
radioBlack.TextXAlignment = Enum.TextXAlignment.Left
radioBlack.ZIndex = 108
radioBlack.Parent = radioContainer

bgMenuBtn.MouseButton1Click:Connect(function()
    radioContainer.Visible = not radioContainer.Visible
end)

-- ========================================================================
-- CENTERED STAT TRACKER PANEL
-- ========================================================================
local statFrame = Instance.new("Frame")
statFrame.Name = "StatTrackerPanel"
statFrame.Size = UDim2.new(0, 360, 0, 170)
statFrame.AnchorPoint = Vector2.new(0.5, 0.5)
statFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
statFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
statFrame.ZIndex = 20
statFrame.Visible = true
statFrame.Parent = screenGui

local statCorner = Instance.new("UICorner")
statCorner.CornerRadius = UDim.new(0, 12)
statCorner.Parent = statFrame

local statStroke = Instance.new("UIStroke")
statStroke.Color = Color3.fromRGB(55, 62, 80)
statStroke.Thickness = 1.5
statStroke.Parent = statFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "STAT TRACKER"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.ZIndex = 21
titleLabel.Parent = statFrame

local containerFrame = Instance.new("Frame")
containerFrame.Size = UDim2.new(1, -20, 0, 120)
containerFrame.Position = UDim2.new(0, 10, 0, 42)
containerFrame.BackgroundTransparency = 1
containerFrame.ZIndex = 21
containerFrame.Parent = statFrame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 108, 0, 26)
gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = containerFrame

-- Updated Stat Config with comprehensive Key / Key Half patterns
local statConfig = {
    {id = "coins", keywords = {"coin", "coins"}, display = "coins"},
    {id = "rubies", keywords = {"ruby", "rubies"}, display = "rubies"},
    {id = "gems", keywords = {"gem", "gems"}, display = "gems"},
    {id = "vip_key", keywords = {"vip key", "vipkey", "full key", "completed key"}, display = "VIP key"},
    {id = "vip_upper", keywords = {"vip upper", "vip upper half", "upper half", "top half", "upperkey", "topkey", "upper"}, display = "VIP upper half"},
    {id = "vip_lower", keywords = {"vip lower", "vip lower half", "lower half", "bottom half", "lowerkey", "bottomkey", "lower"}, display = "VIP lower half"},
    {id = "party_eggs", keywords = {"party egg", "party eggs", "party"}, display = "party eggs"},
    {id = "alien_eggs", keywords = {"alien egg", "alien eggs", "alien"}, display = "alien eggs"}
}

local statLabels = {}

for i, cfg in ipairs(statConfig) do
    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = i
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.Text = string.format("%s: 0", cfg.display)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 22
    lbl.Parent = containerFrame
    statLabels[cfg.id] = {label = lbl, keywords = cfg.keywords, display = cfg.display}
end

-- Toggle Stat Tracker Visibility & Background Overlay
local statTrackerActive = true
statTrackerBtn.MouseButton1Click:Connect(function()
    statTrackerActive = not statTrackerActive
    statFrame.Visible = statTrackerActive
    fullScreenOverlay.Visible = statTrackerActive
    statTrackerBtn.Text = statTrackerActive and "  Stat Tracker: On" or "  Stat Tracker: Off"
end)

-- Theme Color Picker
local function selectBlack()
    radioBlack.Text = "  (*) Black"
    radioBlack.TextColor3 = Color3.fromRGB(100, 225, 120)
    radioWhite.Text = "  ( ) White"
    radioWhite.TextColor3 = Color3.fromRGB(180, 185, 195)
    
    fullScreenOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    statStroke.Color = Color3.fromRGB(55, 62, 80)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    for _, item in pairs(statLabels) do
        item.label.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end

local function selectWhite()
    radioWhite.Text = "  (*) White"
    radioWhite.TextColor3 = Color3.fromRGB(100, 225, 120)
    radioBlack.Text = "  ( ) Black"
    radioBlack.TextColor3 = Color3.fromRGB(180, 185, 195)
    
    fullScreenOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statFrame.BackgroundColor3 = Color3.fromRGB(240, 242, 245)
    statStroke.Color = Color3.fromRGB(180, 185, 195)
    titleLabel.TextColor3 = Color3.fromRGB(20, 22, 30)
    for _, item in pairs(statLabels) do
        item.label.TextColor3 = Color3.fromRGB(30, 32, 40)
    end
end

radioBlack.MouseButton1Click:Connect(selectBlack)
radioWhite.MouseButton1Click:Connect(selectWhite)

-- Draggable Center Panel
local UIS = game:GetService("UserInputService")
local stDragging, stDragStart, stStartPos, stDragInput
statFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        stDragging = true
        stDragStart = input.Position
        stStartPos = statFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                stDragging = false
            end
        end)
    end
end)

statFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        stDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == stDragInput and stDragging then
        local delta = input.Position - stDragStart
        statFrame.Position = UDim2.new(stStartPos.X.Scale, stStartPos.X.Offset + delta.X, stStartPos.Y.Scale, stStartPos.Y.Offset + delta.Y)
    end
end)

-- ========================================================================
-- DUAL-MODE SCANNER (Item-Counting + Value-Reading)
-- ========================================================================
local function formatNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

task.spawn(function()
    while screenGui.Parent do
        task.wait(0.3)
        pcall(function()
            local searchRoots = {
                player:FindFirstChild("leaderstats"),
                player:FindFirstChild("Data"),
                player:FindFirstChild("Stats"),
                player:FindFirstChild("Currency"),
                player:FindFirstChild("Values"),
                player:FindFirstChild("Inventory"),
                player:FindFirstChild("Items"),
                player:FindFirstChild("Backpack"),
                player:FindFirstChild("PlayerGui"),
                player
            }

            for statId, item in pairs(statLabels) do
                local detectedVal = nil
                local instanceCount = 0

                -- 1. Scan Player Attributes
                local attributes = player:GetAttributes()
                for attrName, attrVal in pairs(attributes) do
                    local lowerAttr = string.lower(attrName)
                    for _, kw in ipairs(item.keywords) do
                        if lowerAttr == kw or lowerAttr:find(kw) then
                            detectedVal = attrVal
                            break
                        end
                    end
                    if detectedVal then break end
                end

                -- 2. Scan Inventory Trees (Value-reading + Item Counting)
                if not detectedVal then
                    for _, root in ipairs(searchRoots) do
                        if root then
                            for _, descendant in ipairs(root:GetDescendants()) do
                                local lowerName = string.lower(descendant.Name)
                                local matches = false
                                for _, kw in ipairs(item.keywords) do
                                    if lowerName == kw or lowerName:find(kw) then
                                        matches = true
                                        break
                                    end
                                end

                                if matches then
                                    -- Check if it's a numeric Value container
                                    if descendant:IsA("ValueBase") or descendant:IsA("StringValue") then
                                        local num = tonumber(descendant.Value)
                                        if num then
                                            detectedVal = num
                                            break
                                        end
                                    -- Check if it has stack attributes
                                    elseif descendant:GetAttribute("Amount") or descendant:GetAttribute("Count") or descendant:GetAttribute("Value") then
                                        detectedVal = descendant:GetAttribute("Amount") or descendant:GetAttribute("Count") or descendant:GetAttribute("Value")
                                        break
                                    -- Count instances if items are individual objects
                                    else
                                        instanceCount = instanceCount + 1
                                    end
                                end
                            end
                        end
                        if detectedVal then break end
                    end
                end

                -- Fallback to Instance Count if no explicit numeric value was found
                if detectedVal == nil and instanceCount > 0 then
                    detectedVal = instanceCount
                end

                -- 3. Render UI Label
                if detectedVal ~= nil then
                    item.label.Text = string.format("%s: %s", item.display, formatNumber(detectedVal))
                else
                    item.label.Text = string.format("%s: 0", item.display)
                end
            end
        end)
    end
end)

-- ========================================================================
-- UNDETECTABLE MOBILE ANTI-AFK
-- ========================================================================
local function sendTouchPing()
    pcall(function()
        VirtualInputManager:SendTouchEvent(1, 0, 0, 0)
        task.wait(0.05)
        VirtualInputManager:SendTouchEvent(1, 2, 0, 0)
    end)
end

player.Idled:Connect(function()
    sendTouchPing()
end)

task.spawn(function()
    while screenGui.Parent do
        task.wait(240)
        sendTouchPing()
    end
end)

-- ========================================================================
-- DRAGGABLE TOP MENU LOGIC & KILL SWITCH
-- ========================================================================
local dragging, dragInput, dragStart, startPos
local hasMoved = false

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = mainButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if delta.Magnitude > 3 then
            hasMoved = true
        end
        mainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

mainButton.MouseButton1Click:Connect(function()
    if hasMoved then
        hasMoved = false
        return
    end
    dropdownContainer.Visible = not dropdownContainer.Visible
end)

-- Master Kill Switch
closeButton.MouseButton1Click:Connect(function()
    getgenv().AutoRejoinActive = false
    restoreOriginal()
    screenGui:Destroy()
end)

-- ========================================================================
-- WEBHOOK POPUP PROMPT
-- ========================================================================
local function createWebhookPopup()
    if WEBHOOK_URL and WEBHOOK_URL ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        return
    end

    local blurOverlay = Instance.new("Frame")
    blurOverlay.Size = UDim2.new(1, 0, 1, 0)
    blurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurOverlay.BackgroundTransparency = 0.5
    blurOverlay.ZIndex = 999
    blurOverlay.Parent = screenGui

    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 360, 0, 160)
    promptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    promptFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    promptFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
    promptFrame.BorderSizePixel = 0
    promptFrame.ZIndex = 1000
    promptFrame.Parent = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = promptFrame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Color3.fromRGB(55, 62, 80)
    frameStroke.Thickness = 1.5
    frameStroke.Parent = promptFrame

    local promptTitle = Instance.new("TextLabel")
    promptTitle.Size = UDim2.new(1, -50, 0, 40)
    promptTitle.Position = UDim2.new(0, 15, 0, 10)
    promptTitle.BackgroundTransparency = 1
    promptTitle.Font = Enum.Font.Gotham
    promptTitle.Text = "Enter Discord Webhook URL"
    promptTitle.TextColor3 = Color3.fromRGB(210, 215, 225)
    promptTitle.TextSize = 15
    promptTitle.TextXAlignment = Enum.TextXAlignment.Left
    promptTitle.ZIndex = 1001
    promptTitle.Parent = promptFrame

    local promptClose = Instance.new("TextButton")
    promptClose.Size = UDim2.new(0, 32, 0, 32)
    promptClose.Position = UDim2.new(1, -42, 0, 14)
    promptClose.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    promptClose.Font = Enum.Font.Gotham
    promptClose.Text = "X"
    promptClose.TextColor3 = Color3.fromRGB(180, 185, 195)
    promptClose.TextSize = 14
    promptClose.ZIndex = 1002
    promptClose.Parent = promptFrame

    local pcCorner = Instance.new("UICorner")
    pcCorner.CornerRadius = UDim.new(0, 6)
    pcCorner.Parent = promptClose

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 320, 0, 35)
    textBox.Position = UDim2.new(0.5, -160, 0, 60)
    textBox.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = "Paste webhook URL here..."
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(210, 215, 225)
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
    textBox.TextSize = 13
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 1001
    textBox.Parent = promptFrame

    localThe issue with `VIP upper half` and `VIP lower half` displaying **0** comes down to how **Pet Universe** names and structures key items in player data.

When the scanner searches for `"upper"` or `"lower"`, it is either:
1. Matching a different string in the player data before finding the actual item (such as character mesh parts or clothing instances).
2. Missing key items because they are stored inside a **Folder** or **Dictionary** as item counts (e.g., `Keys["VIP Upper"]` or `Inventory["VIP Key Half (Upper)"]`).

---

### Universal Real-Time Fix for Keys & Items

Below is an updated stat reader thread that specifically targets keys, key fragments, inventory items, and nested key folders.

Replace the **`ADVANCED REAL-TIME STAT SCANNER LOOP`** block in your script with this updated version:

```lua
-- ========================================================================
-- ENHANCED REAL-TIME STAT SCANNER (PET UNIVERSE KEY FIX)
-- ========================================================================
local function formatNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    local formatted = tostring(math.floor(n))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local statConfig = {
    {id = "coins", keywords = {"coin", "coins"}, display = "coins"},
    {id = "rubies", keywords = {"ruby", "rubies"}, display = "rubies"},
    {id = "gems", keywords = {"gem", "gems"}, display = "gems"},
    {id = "vip_key", keywords = {"vip key", "vip_key", "vipkey"}, display = "VIP key"},
    {id = "vip_upper", keywords = {"vip upper", "vip_upper", "upper half", "upperkey", "keyupper"}, display = "VIP upper half"},
    {id = "vip_lower", keywords = {"vip lower", "vip_lower", "lower half", "lowerkey", "keylower"}, display = "VIP lower half"},
    {id = "party_eggs", keywords = {"party egg", "party_egg", "partyegg"}, display = "party eggs"},
    {id = "alien_eggs", keywords = {"alien egg", "alien_egg", "alienegg"}, display = "alien eggs"}
}

task.spawn(function()
    while screenGui.Parent do
        task.wait(0.3)
        pcall(function()
            local searchRoots = {
                player:FindFirstChild("leaderstats"),
                player:FindFirstChild("Data"),
                player:FindFirstChild("Stats"),
                player:FindFirstChild("Currency"),
                player:FindFirstChild("Inventory"),
                player:FindFirstChild("Keys"),
                player:FindFirstChild("Values"),
                player:FindFirstChild("PlayerGui"),
                player
            }

            for _, cfg in ipairs(statConfig) do
                local item = statLabels[cfg.id]
                local detectedVal = nil

                -- 1. Scan Player Attributes First
                local attributes = player:GetAttributes()
                for attrName, attrVal in pairs(attributes) do
                    local lowerAttr = string.lower(attrName)
                    for _, kw in ipairs(cfg.keywords) do
                        if lowerAttr == kw or (lowerAttr:find(kw) and not lowerAttr:find("mesh") and not lowerAttr:find("body")) then
                            detectedVal = attrVal
                            break
                        end
                    end
                    if detectedVal then break end
                end

                -- 2. Deep Search in Data / Inventory Trees
                if not detectedVal then
                    for _, root in ipairs(searchRoots) do
                        if root then
                            for _, descendant in ipairs(root:GetDescendants()) do
                                -- Ignore Roblox Character Parts or GUI Elements to prevent false matches
                                local className = descendant.ClassName
                                if not descendant:IsA("BasePart") and not descendant:IsA("Accoutrement") and not descendant:IsA("GuiObject") then
                                    local lowerName = string.lower(descendant.Name)
                                    
                                    for _, kw in ipairs(cfg.keywords) do
                                        if lowerName == kw or (lowerName:find(kw) and (lowerName:find("key") or lowerName:find("vip") or lowerName:find("half") or lowerName:find("item"))) then
                                            if descendant:IsA("ValueBase") or descendant:IsA("StringValue") then
                                                detectedVal = descendant.Value
                                            elseif descendant:IsA("Folder") or descendant:IsA("Configuration") then
                                                -- Count instances inside a folder if items are represented as individual objects
                                                detectedVal = #descendant:GetChildren()
                                            end
                                            break
                                        end
                                    end
                                end
                                if detectedVal then break end
                            end
                        end
                        if detectedVal then break end
                    end
                end

                -- 3. Update Label Text
                if detectedVal ~= nil then
                    if type(detectedVal) == "number" then
                        item.label.Text = string.format("%s: %s", item.display, formatNumber(detectedVal))
                    else
                        item.label.Text = string.format("%s: %s", item.display, tostring(detectedVal))
                    end
                else
                    item.label.Text = string.format("%s: 0", item.display)
                end
            end
        end)
    end
end)
