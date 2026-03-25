--==================================================
-- FISH HUB PRO (DELTA VERSION - CLIENT ONLY)
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

--========================
-- CONFIG
--========================
local webhook = ""
local allFish = false
local rarityEnabled = {}

local rarityList = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

for _,r in ipairs(rarityList) do
    rarityEnabled[r] = false
end

--========================
-- GUI
--========================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FishHubDelta"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,460)
main.Position = UDim2.new(0.35,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2

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
input.PlaceholderText = "Discord Webhook URL..."
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
input.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input)

local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,35)
save.Position = UDim2.new(0,10,0,95)
save.Text = "💾 SAVE"
save.BackgroundColor3 = Color3.fromRGB(0,140,255)
Instance.new("UICorner", save)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,135)
status.Text = ""
status.TextColor3 = Color3.fromRGB(0,255,100)
status.BackgroundTransparency = 1

local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,30)
toggleAll.Position = UDim2.new(0,10,0,160)
toggleAll.Text = "ALL FISH: OFF"
toggleAll.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", toggleAll)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-20,0,230)
scroll.Position = UDim2.new(0,10,0,200)
scroll.CanvasSize = UDim2.new(0,0,0,500)
scroll.BackgroundColor3 = Color3.fromRGB(25,25,30)
Instance.new("UICorner", scroll)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- rarity buttons
for _,rarity in ipairs(rarityList) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,32)
    btn.Text = rarity:upper().." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = rarity:upper().." : "..(rarityEnabled[rarity] and "ON" or "OFF")
    end)
end

toggleAll.MouseButton1Click:Connect(function()
    allFish = not allFish
    toggleAll.Text = "ALL FISH: "..(allFish and "ON" or "OFF")
end)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    status.Text = "✅ Saved!"
    task.wait(2)
    status.Text = ""
end)

--========================
-- WEBHOOK SEND
--========================
local function sendWebhook(fish)

    if webhook == "" then return end

    local data = {
        content = "",
        embeds = {{
            title = "🎣 Fish Caught!",
            description = "**"..fish.."**",
            color = 65280,
            fields = {
                {name="👤 Player", value=player.Name},
                {name="🆔 UserId", value=tostring(player.UserId)}
            }
        }}
    }

    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

--========================
-- DETECT FISH (CLIENT SIDE)
--========================
-- NOTE: ini generic, tergantung game

local function detectFish(text)
    text = string.lower(text)

    if allFish then return true end

    for r,v in pairs(rarityEnabled) do
        if v and text:find(r) then
            return true
        end
    end

    return false
end

-- hook notifikasi / text muncul
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fish Hub",
    Text = "Loaded!",
    Duration = 3
})

-- contoh detect dari chat / text GUI (universal trick)
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("TextLabel") or v:IsA("TextBox") then
        v:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = v.Text
            if txt and txt ~= "" then
                if detectFish(txt) then
                    sendWebhook(txt)
                    print("🎣 Fish Detected:", txt)
                end
            end
        end)
    end
end
