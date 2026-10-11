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

-- 4. Background (*) Radio Dropdown Main Button
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

-- Background Radio Options Container
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

-- Radio Option 1: White
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

-- Radio Option 2: Black (Default Active)
local radioBlack = Instance.new("TextButton")
radioBlack.Size = UDim2.new(1, -10, 0, 28)
radioBlack.Position = UDim2.new(0, 5, 0, 34)
radioBlack.BackgroundTransparency = 1
radioBlack.Font = Enum.Font.Gotham
radioBlack.Text = "  (*) Black"
radioBlack.TextColor3 = Color3.fromRGB(100, 225, 120) -- Highlight Active
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

local statConfig = {
    {key = "coins", display = "coins"},
    {key = "rubies", display = "rubies"},
    {key = "gems", display = "gems"},
    {key = "vip key", display = "VIP key"},
    {key = "vip upper", display = "VIP upper half"},
    {key = "vip lower", display = "VIP lower half"},
    {key = "party eggs", display = "party eggs"},
    {key = "alien eggs", display = "alien eggs"}
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
    statLabels[cfg.key] = {label = lbl, display = cfg.display}
end

-- Toggle Stat Tracker Visibility & Background Overlay
local statTrackerActive = true
statTrackerBtn.MouseButton1Click:Connect(function()
    statTrackerActive = not statTrackerActive
    statFrame.Visible = statTrackerActive
    fullScreenOverlay.Visible = statTrackerActive
    statTrackerBtn.Text = statTrackerActive and "  Stat Tracker: On" or "  Stat Tracker: Off"
end)

-- Radio Button Color Selection Logic
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

-- Make Center Panel Draggable
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

-- Pet Universe Targeted Stat Reader Loop
task.spawn(function()
    while screenGui.Parent do
        task.wait(0.5)
        pcall(function()
            local searchContainers = {
                player:FindFirstChild("leaderstats"),
                player:FindFirstChild("Data"),
                player:FindFirstChild("Stats"),
                player:FindFirstChild("Currency"),
                player
            }

            for searchKey, item in pairs(statLabels) do
                local foundValue = nil
                for _, container in ipairs(searchContainers) do
                    if container then
                        for _, child in ipairs(container:GetDescendants()) do
                            if string.lower(child.Name):find(searchKey) then
                                if child:IsA("ValueBase") or child:IsA("StringValue") then
                                    foundValue = child.Value
                                    break
                                end
                            end
                        end
                    end
                    if foundValue then break end
                end

                if foundValue ~= nil then
                    item.label.Text = string.format("%s: %s", item.display, tostring(foundValue))
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

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = textBox

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0, 320, 0, 35)
    submitButton.Position = UDim2.new(0.5, -160, 0, 108)
    submitButton.BackgroundColor3 = Color3.fromRGB(45, 52, 68)
    submitButton.Font = Enum.Font.Gotham
    submitButton.Text = "Submit"
    submitButton.TextColor3 = Color3.fromRGB(210, 215, 225)
    submitButton.TextSize = 13
    submitButton.ZIndex = 1001
    submitButton.Parent = promptFrame

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = submitButton

    submitButton.MouseButton1Click:Connect(function()
        local inputContent = textBox.Text
        if inputContent and inputContent ~= "" then
            WEBHOOK_URL = inputContent
            getgenv().WebhookUrl = inputContent
            promptFrame:Destroy()
            blurOverlay:Destroy()
            sendWebhook("Webhook Connected", "Successfully linked webhook to script!", 65280)
        else
            textBox.PlaceholderText = "Please enter a valid URL!"
        end
    end)

    promptClose.MouseButton1Click:Connect(function()
        promptFrame:Destroy()
        blurOverlay:Destroy()
    end)
end

task.spawn(createWebhookPopup)

-- ========================================================================
-- AUTO RECONNECT & ERROR MONITORING
-- ========================================================================
local hasSentWebhook = false

local function triggerRejoin(reason)
    if not getgenv().AutoRejoinActive then return end
    
    if not hasSentWebhook then
        hasSentWebhook = true
        getgenv().JustReconnectedFlag = true
        sendWebhook("Disconnected", "Reconnecting due to: " .. tostring(reason), 16711680)
    end

    while getgenv().AutoRejoinActive do
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
        task.wait(2)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)
        task.wait(4)
    end
end

TeleportService.TeleportInitFailed:Connect(function(targetPlayer, _, errorMessage)
    if targetPlayer == player then
        triggerRejoin("TeleportInitFailed: " .. tostring(errorMessage))
    end
end)

pcall(function()
    GuiService.ErrorMessageChanged:Connect(function()
        local err = GuiService:GetErrorMessage()
        if err and err ~= "" then
            triggerRejoin("GuiService Error: " .. err)
        end
    end)
end)

pcall(function()
    ScriptContext.MessageOut:Connect(function(message, messageType)
        local lowerMsg = string.lower(message)
        if lowerMsg:find("shutdown") or lowerMsg:find("server shutting down") or lowerMsg:find("restart") then
            triggerRejoin("Server Shutdown Event Log: " .. message)
        end
    end)
end)

task.spawn(function()
    while screenGui.Parent do
        task.wait(0.3)
        pcall(function()
            local robloxGui = CoreGui:FindFirstChild("RobloxGui")
            if robloxGui then
                for _, descendant in ipairs(robloxGui:GetDescendants()) do
                    if descendant:IsA("TextLabel") and descendant.Visible then
                        local text = string.lower(descendant.Text)
                        if text:find("disconnected") or text:find("lost connection") or text:find("reconnect") or text:find("error code") or text:find("shut down") or text:find("server restart") then
                            triggerRejoin("CoreGui Text Match: " .. descendant.Text)
                        end
                    end
                end
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        triggerRejoin("PlayerRemoving Event")
    end
end)

print("[Hennessy Hub] Background Dropdown Radio UI Updated Successfully!")
