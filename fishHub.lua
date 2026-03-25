--==================================================
-- FISH HUB DELTA (FIXED VERSION)
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- universal request
local http = http_request or request or syn and syn.request
if not http then
    warn("Executor tidak support HTTP request")
end

--========================
-- CONFIG
--========================
local webhook = ""
local allFish = false
local rarityEnabled = {
    common=false,uncommon=false,rare=false,epic=false,
    legendary=false,mythic=false,secret=false,forgotten=false
}

--========================
-- GUI FIX (COREGUI)
--========================
local gui = Instance.new("ScreenGui")
gui.Name = "FishHubDelta"
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,460)
main.Position = UDim2.new(0.35,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🎣 FISH HUB DELTA"
title.TextColor3 = Color3.fromRGB(0,200,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,35)
input.Position = UDim2.new(0,10,0,50)
input.PlaceholderText = "Webhook URL..."
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
input.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input)

local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,35)
save.Position = UDim2.new(0,10,0,95)
save.Text = "SAVE"
save.BackgroundColor3 = Color3.fromRGB(0,140,255)
Instance.new("UICorner", save)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,135)
status.Text = ""
status.TextColor3 = Color3.fromRGB(0,255,100)
status.BackgroundTransparency = 1

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(1,-20,0,30)
toggle.Position = UDim2.new(0,10,0,160)
toggle.Text = "ALL FISH: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", toggle)

--========================
-- BUTTON LOGIC
--========================
toggle.MouseButton1Click:Connect(function()
    allFish = not allFish
    toggle.Text = "ALL FISH: "..(allFish and "ON" or "OFF")
end)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    status.Text = "Saved!"
    task.wait(1.5)
    status.Text = ""
end)

--========================
-- WEBHOOK
--========================
local function sendWebhook(msg)
    if webhook == "" or not http then return end

    local data = {
        content = "**Fish Detected**\n"..msg
    }

    http({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

--========================
-- DETECT TEXT (UNIVERSAL)
--========================
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("TextLabel") then
        v:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = v.Text
            if txt and txt ~= "" then
                if allFish or txt:lower():find("fish") or txt:lower():find("ikan") then
                    print("Detected:", txt)
                    sendWebhook(txt)
                end
            end
        end)
    end
end

print("✅ Fish Hub Delta Loaded")
