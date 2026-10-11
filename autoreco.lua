local Players, UIS, VIM, Lighting, TS, GuiS, CoreGui = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("VirtualInputManager"), game:GetService("Lighting"), game:GetService("TeleportService"), game:GetService("GuiService"), game:GetService("CoreGui")
local player = Players.LocalPlayer
local WEBHOOK = getgenv().WebhookUrl or "https://discord.com/api/webhooks/1532835349728854128/ie6a1f70yZ5RiRupqHMoZ8o6GU7lJVBtASlpCy8b0SZqYRiBxmX-L8Y1SlAgNFmVwQzo"

local function sendWebhook(title, desc, color)
    if WEBHOOK ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
        task.spawn(function()
            pcall(function()
                request({Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = game:GetService("HttpService"):JSONEncode({embeds={{title=title, description="**Username:** "..player.Name.."\n**Status:** "..desc, color=color}}})})
            end)
        end)
    end
end

if getgenv().JustReconnectedFlag then getgenv().JustReconnectedFlag = nil sendWebhook("Reconnected", "Successfully reconnected!", 65280) end

local gui = Instance.new("ScreenGui", (gethui and gethui()) or CoreGui)
gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset, gui.DisplayOrder = "HennessyHubGUI", false, true, 2147483647

local bg = Instance.new("Frame", gui)
bg.Size, bg.BackgroundColor3, bg.Visible = UDim2.new(1,0,1,0), Color3.new(0,0,0), true

local main = Instance.new("TextButton", gui)
main.Size, main.Position, main.BackgroundColor3, main.Text, main.TextColor3, main.Font, main.TextSize, main.TextXAlignment = UDim2.new(0,160,0,38), UDim2.new(0,20,0,50), Color3.fromRGB(24,27,36), "  Hennessy", Color3.fromRGB(210,215,225), Enum.Font.GothamBold, 13, Enum.TextXAlignment.Left
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", main).Color = Color3.fromRGB(55,62,80)

local close = Instance.new("TextButton", main)
close.Size, close.Position, close.BackgroundColor3, close.Text, close.TextColor3, close.Font, close.TextSize = UDim2.new(0,26,0,26), UDim2.new(1,-30,0.5,-13), Color3.fromRGB(35,38,48), "X", Color3.fromRGB(220,80,80), Enum.Font.GothamBold, 12
Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

local drop = Instance.new("Frame", main)
drop.Size, drop.Position, drop.BackgroundTransparency, drop.Visible = UDim2.new(0,160,0,250), UDim2.new(0,0,1,6), 1, false

getgenv().AutoRejoinActive = true
local function makeBtn(y, txt)
    local b = Instance.new("TextButton", drop)
    b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize, b.TextXAlignment = UDim2.new(0,160,0,36), UDim2.new(0,0,0,y), Color3.fromRGB(24,27,36), txt, Color3.fromRGB(210,215,225), Enum.Font.Gotham, 12, Enum.TextXAlignment.Left
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(55,62,80)
    return b
end

local arBtn = makeBtn(0, "  Auto Recon: On")
arBtn.MouseButton1Click:Connect(function()
    getgenv().AutoRejoinActive = not getgenv().AutoRejoinActive
    arBtn.Text = getgenv().AutoRejoinActive and "  Auto Recon: On" or "  Auto Recon: Off"
end)

local fpsBtn = makeBtn(42, "  FPS Booster: On")
local boost = true
fpsBtn.MouseButton1Click:Connect(function()
    boost = not boost
    fpsBtn.Text = boost and "  FPS Booster: On" or "  FPS Booster: Off"
    Lighting.GlobalShadows = not boost
end)

local stBtn = makeBtn(84, "  Stat Tracker: On")
local statActive = true

local bgBtn = makeBtn(126, "  Background (*)")
local radio = Instance.new("Frame", drop)
radio.Size, radio.Position, radio.BackgroundColor3, radio.Visible = UDim2.new(0,150,0,68), UDim2.new(0,5,0,166), Color3.fromRGB(18,20,28), false
Instance.new("UICorner", radio).CornerRadius = UDim.new(0,6)

local rWhite = Instance.new("TextButton", radio)
rWhite.Size, rWhite.Position, rWhite.BackgroundTransparency, rWhite.Text, rWhite.TextColor3, rWhite.Font, rWhite.TextSize, rWhite.TextXAlignment = UDim2.new(1,-10,0,28), UDim2.new(0,5,0,4), 1, "  ( ) White", Color3.fromRGB(180,185,195), Enum.Font.Gotham, 11, Enum.TextXAlignment.Left
local rBlack = Instance.new("TextButton", radio)
rBlack.Size, rBlack.Position, rBlack.BackgroundTransparency, rBlack.Text, rBlack.TextColor3, rBlack.Font, rBlack.TextSize, rBlack.TextXAlignment = UDim2.new(1,-10,0,28), UDim2.new(0,5,0,34), 1, "  (*) Black", Color3.fromRGB(100,225,120), Enum.Font.Gotham, 11, Enum.TextXAlignment.Left

bgBtn.MouseButton1Click:Connect(function() radio.Visible = not radio.Visible end)

local statFrame = Instance.new("Frame", gui)
statFrame.Size, statFrame.AnchorPoint, statFrame.Position, statFrame.BackgroundColor3 = UDim2.new(0,360,0,170), Vector2.new(0.5,0.5), UDim2.new(0.5,0,0.5,0), Color3.fromRGB(20,22,30)
Instance.new("UICorner", statFrame).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", statFrame).Color = Color3.fromRGB(55,62,80)

local tLbl = Instance.new("TextLabel", statFrame)
tLbl.Size, tLbl.BackgroundTransparency, tLbl.Text, tLbl.TextColor3, tLbl.Font, tLbl.TextSize = UDim2.new(1,0,0,30), 1, "STAT TRACKER", Color3.fromRGB(255,255,255), Enum.Font.GothamBold, 14

local cFrame = Instance.new("Frame", statFrame)
cFrame.Size, cFrame.Position, cFrame.BackgroundTransparency = UDim2.new(1,-20,0,120), UDim2.new(0,10,0,42), 1
local grid = Instance.new("UIGridLayout", cFrame)
grid.CellSize, grid.CellPadding, grid.HorizontalAlignment = UDim2.new(0,108,0,26), UDim2.new(0,6,0,6), Enum.HorizontalAlignment.Center

local keys = {"coins", "rubies", "gems", "vip key", "vip upper half", "vip lower half", "party eggs", "alien eggs"}
local sLabels = {}
for i, k in ipairs(keys) do
    local l = Instance.new("TextLabel", cFrame)
    l.LayoutOrder, l.BackgroundTransparency, l.Text, l.TextColor3, l.Font, l.TextSize, l.TextXAlignment = i, 1, k..": 0", Color3.fromRGB(220,220,220), Enum.Font.Gotham, 11, Enum.TextXAlignment.Left
    sLabels[k] = l
end

stBtn.MouseButton1Click:Connect(function()
    statActive = not statActive
    statFrame.Visible, bg.Visible = statActive, statActive
    stBtn.Text = statActive and "  Stat Tracker: On" or "  Stat Tracker: Off"
end)

rBlack.MouseButton1Click:Connect(function()
    rBlack.Text, rBlack.TextColor3, rWhite.Text, rWhite.TextColor3 = "  (*) Black", Color3.fromRGB(100,225,120), "  ( ) White", Color3.fromRGB(180,185,195)
    bg.BackgroundColor3, statFrame.BackgroundColor3, tLbl.TextColor3 = Color3.new(0,0,0), Color3.fromRGB(20,22,30), Color3.new(1,1,1)
    for _, l in pairs(sLabels) do l.TextColor3 = Color3.fromRGB(220,220,220) end
end)

rWhite.MouseButton1Click:Connect(function()
    rWhite.Text, rWhite.TextColor3, rBlack.Text, rBlack.TextColor3 = "  (*) White", Color3.fromRGB(100,225,120), "  ( ) Black", Color3.fromRGB(180,185,195)
    bg.BackgroundColor3, statFrame.BackgroundColor3, tLbl.TextColor3 = Color3.new(1,1,1), Color3.fromRGB(240,242,245), Color3.fromRGB(20,22,30)
    for _, l in pairs(sLabels) do l.TextColor3 = Color3.fromRGB(30,32,40) end
end)

-- Real-time Stat Scanner
task.spawn(function()
    while gui.Parent do
        task.wait(0.4)
        pcall(function()
            for name, lbl in pairs(sLabels) do
                local val = 0
                for _, root in ipairs({player:FindFirstChild("leaderstats"), player:FindFirstChild("Data"), player:FindFirstChild("Inventory"), player}) do
                    if root then
                        for _, d in ipairs(root:GetDescendants()) do
                            if string.lower(d.Name):find(name) then
                                if d:IsA("ValueBase") then val = d.Value break
                                elseif d:IsA("Folder") then val = #d:GetChildren() break end
                            end
                        end
                    end
                    if val ~= 0 then break end
                end
                lbl.Text = name..": "..tostring(val)
            end
        end)
    end
end)

-- Anti-AFK & Reconnect
player.Idled:Connect(function() VIM:SendTouchEvent(1,0,0,0) task.wait(0.05) VIM:SendTouchEvent(1,2,0,0) end)
task.spawn(function() while true do task.wait(240) VIM:SendTouchEvent(1,0,0,0) task.wait(0.05) VIM:SendTouchEvent(1,2,0,0) end end)

close.MouseButton1Click:Connect(function() getgenv().AutoRejoinActive = false gui:Destroy() end)
main.MouseButton1Click:Connect(function() drop.Visible = not drop.Visible end)
