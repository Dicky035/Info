pcall(function()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- HTTP UNIVERSAL FIX
local http = http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)

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

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,360,0,320)
main.Position = UDim2.new(0.3,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.Text = "🎣 FISH HUB PRO"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0,255,200)

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

-- TEST
local testBtn = Instance.new("TextButton", main)
testBtn.Size = UDim2.new(0.18,0,0,30)
testBtn.Position = UDim2.new(0.82,0,0,45)
testBtn.Text = "TEST"

-- STATUS
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,10,0,80)
status.BackgroundTransparency = 1

-- ALL FISH
local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,30)
toggleAll.Position = UDim2.new(0,10,0,105)
toggleAll.Text = "ALL FISH: OFF"

-- RARITY GRID
local grid = Instance.new("Frame", main)
grid.Size = UDim2.new(1,-20,0,170)
grid.Position = UDim2.new(0,10,0,140)

local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.new(0.48,0,0,30)
layout.CellPadding = UDim2.new(0,5,0,5)

for _,rarity in ipairs(rarityList) do
    local btn = Instance.new("TextButton", grid)
    btn.Text = rarity:upper().." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,70)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = rarity:upper().." : "..(rarityEnabled[rarity] and "ON" or "OFF")
    end)
end

-- SAVE
save.MouseButton1Click:Connect(function()
    webhook = input.Text
    status.Text = "💾 Saved!"
end)

-- TEST WEBHOOK
testBtn.MouseButton1Click:Connect(function()

    if webhook == "" then
        status.Text = "❌ Isi webhook!"
        return
    end

    if not http then
        status.Text = "❌ HTTP not supported"
        return
    end

    local success = pcall(function()
        http({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                content = "✅ Webhook Connected!\nPlayer: "..player.Name
            })
        })
    end)

    status.Text = success and "🟢 Connected!" or "🔴 Failed!"
end)

-- ALL TOGGLE
toggleAll.MouseButton1Click:Connect(function()
    allFish = not allFish
    toggleAll.Text = "ALL FISH: "..(allFish and "ON" or "OFF")
end)

-- DETECT
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

local function hook(v)
    if not v:IsA("TextLabel") then return end

    v:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = v.Text
        if not txt or txt == "" then return end

        local lower = txt:lower()

        if allowed(lower) then
            if lastSent == lower then return end
            lastSent = lower

            sendWebhook("🎣 Fish Caught:\n"..txt)
        end
    end)
end

-- FIX: function webhook kepanggil
function sendWebhook(msg)
    if webhook == "" or not http then return end

    pcall(function()
        http({
            Url = webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({content = msg})
        })
    end)
end

for _,v in pairs(game:GetDescendants()) do
    hook(v)
end

game.DescendantAdded:Connect(function(v)
    task.wait(0.2)
    hook(v)
end)

print("✅ FULL FIX LOADED")

end)
