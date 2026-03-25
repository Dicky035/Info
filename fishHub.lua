--==================================================
-- FISH HUB DELTA (ULTIMATE FINAL FIX)
--==================================================

pcall(function()

-- SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- HTTP SUPPORT (ALL EXECUTOR)
local http = http_request or request or (syn and syn.request)

-- CONFIG
local webhook = ""
local allFish = false

local rarityEnabled = {
    common=false,uncommon=false,rare=false,epic=false,
    legendary=false,mythic=false,secret=false,forgotten=false
}

local rarityList = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

local lastSent = ""

--==================================================
-- GUI
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FishHubPro"
gui.Parent = game.CoreGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,360,0,290)
main.Position = UDim2.new(0.3,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,200,255)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-40,0,35)
title.Text = "🎣 FISH HUB PRO"
title.TextColor3 = Color3.fromRGB(0,255,200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- INPUT
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(0.6,-10,0,30)
input.Position = UDim2.new(0,10,0,45)
input.PlaceholderText = "Webhook..."
input.BackgroundColor3 = Color3.fromRGB(40,40,45)
input.TextColor3 = Color3.new(1,1,1)

-- SAVE
local save = Instance.new("TextButton", main)
save.Size = UDim2.new(0.18,0,0,30)
save.Position = UDim2.new(0.62,0,0,45)
save.Text = "SAVE"
save.BackgroundColor3 = Color3.fromRGB(0,140,255)

-- TEST
local testBtn = Instance.new("TextButton", main)
testBtn.Size = UDim2.new(0.18,0,0,30)
testBtn.Position = UDim2.new(0.82,0,0,45)
testBtn.Text = "TEST"
testBtn.BackgroundColor3 = Color3.fromRGB(255,170,0)

-- STATUS
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,80)
status.BackgroundTransparency = 1
status.Text = ""

-- ALL FISH
local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,28)
toggleAll.Position = UDim2.new(0,10,0,105)
toggleAll.Text = "ALL FISH: OFF"
toggleAll.BackgroundColor3 = Color3.fromRGB(60,60,70)

--==================================================
-- WEBHOOK
--==================================================
local function sendWebhook(msg)
    if webhook == "" or not http then return end

    pcall(function()
        http({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = msg
            })
        })
    end)
end

-- TEST BUTTON
testBtn.MouseButton1Click:Connect(function()

    if webhook == "" then
        status.Text = "❌ Isi webhook!"
        return
    end

    if not http then
        status.Text = "❌ Executor no HTTP"
        return
    end

    status.Text = "⏳ Testing..."

    local ok = pcall(function()
        http({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "✅ Webhook Connected!\nPlayer: "..player.Name
            })
        })
    end)

    status.Text = ok and "🟢 Connected!" or "🔴 Failed!"
end)

-- SAVE
save.MouseButton1Click:Connect(function()
    webhook = input.Text
    status.Text = "💾 Saved!"
end)

-- ALL TOGGLE
toggleAll.MouseButton1Click:Connect(function()
    allFish = not allFish
    toggleAll.Text = "ALL FISH: "..(allFish and "ON" or "OFF")
end)

--==================================================
-- DETECTION (FIX TOTAL)
--==================================================
local function isFish(text)
    text = text:lower()

    if text:find("fish") or text:find("caught") then
        for _,r in ipairs(rarityList) do
            if text:find(r) then
                return true, r
            end
        end
    end

    return false
end

local function allowed(text)
    local valid, rarity = isFish(text)
    if not valid then return false end
    if allFish then return true end
    if rarityEnabled[rarity] then return true end
    return false
end

-- HOOK TEXT
local function hook(v)
    if not v:IsA("TextLabel") then return end

    v:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = v.Text
        if not txt or txt == "" then return end

        local lower = txt:lower()

        if allowed(lower) then
            if lastSent == lower then return end
            lastSent = lower

            print("🎣", txt)
            sendWebhook("🎣 Fish Caught:\n"..txt)
        end
    end)
end

-- SCAN
for _,v in pairs(game:GetDescendants()) do
    hook(v)
end

-- REALTIME
game.DescendantAdded:Connect(function(v)
    task.wait(0.2)
    hook(v)
end)

print("✅ FISH HUB ULTIMATE LOADED")

end)
