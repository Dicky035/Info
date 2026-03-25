--==================================================
-- FISH HUB DELTA (FINAL PRO UI)
--==================================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local http = http_request or request or syn and syn.request

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

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,460)
main.Position = UDim2.new(0.35,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,30)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- STROKE
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,200,255)
stroke.Thickness = 1.5

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-40,0,40)
title.Text = "🎣 FISH HUB PRO"
title.TextColor3 = Color3.fromRGB(0,255,200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0,40,0,40)
minBtn.Position = UDim2.new(1,-40,0,0)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
minBtn.TextColor3 = Color3.new(1,1,1)

-- MINI ICON
local mini = Instance.new("TextButton", gui)
mini.Size = UDim2.new(0,120,0,35)
mini.Position = UDim2.new(0.02,0,0.4,0)
mini.Text = "🎣 OPEN HUB"
mini.Visible = false
mini.BackgroundColor3 = Color3.fromRGB(60,60,70)
mini.TextColor3 = Color3.new(1,1,1)

local minimized = false

-- INPUT
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,35)
input.Position = UDim2.new(0,10,0,50)
input.PlaceholderText = "Webhook URL..."
input.BackgroundColor3 = Color3.fromRGB(40,40,45)
input.TextColor3 = Color3.new(1,1,1)
input.TextSize = 14
Instance.new("UICorner", input)

-- SAVE
local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,35)
save.Position = UDim2.new(0,10,0,95)
save.Text = "SAVE"
save.BackgroundColor3 = Color3.fromRGB(0,140,255)
save.TextColor3 = Color3.new(1,1,1)
save.TextSize = 14
save.Font = Enum.Font.GothamBold

-- STATUS
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,135)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(0,255,150)
status.TextSize = 14
status.Font = Enum.Font.GothamBold

-- ALL FISH
local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,30)
toggleAll.Position = UDim2.new(0,10,0,160)
toggleAll.Text = "ALL FISH: OFF"
toggleAll.BackgroundColor3 = Color3.fromRGB(60,60,70)
toggleAll.TextColor3 = Color3.new(1,1,1)
toggleAll.TextSize = 14
toggleAll.Font = Enum.Font.GothamBold

-- SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-20,0,220)
scroll.Position = UDim2.new(0,10,0,200)
scroll.CanvasSize = UDim2.new(0,0,0,400)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", scroll)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- RARITY BUTTONS
for _,rarity in ipairs(rarityList) do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = rarity:upper().." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = rarity:upper().." : "..(rarityEnabled[rarity] and "ON" or "OFF")

        btn.BackgroundColor3 = rarityEnabled[rarity]
            and Color3.fromRGB(0,200,120)
            or Color3.fromRGB(60,60,70)
    end)
end

-- BUTTON LOGIC
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Visible = not minimized
    mini.Visible = minimized
end)

mini.MouseButton1Click:Connect(function()
    minimized = false
    main.Visible = true
    mini.Visible = false
end)

toggleAll.MouseButton1Click:Connect(function()
    allFish = not allFish
    toggleAll.Text = "ALL FISH: "..(allFish and "ON" or "OFF")
    toggleAll.BackgroundColor3 = allFish
        and Color3.fromRGB(0,170,255)
        or Color3.fromRGB(60,60,70)
end)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    status.Text = "Saved!"
    task.wait(1.5)
    status.Text = ""
end)

-- WEBHOOK
local function sendWebhook(msg)
    if webhook == "" or not http then return end

    http({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = "🎣 "..msg
        })
    })
end

-- FILTER
local function allowed(text)
    text = text:lower()

    if allFish then return true end

    for r,v in pairs(rarityEnabled) do
        if v and text:find(r) then
            return true
        end
    end

    return false
end

-- DETECT
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("TextLabel") then
        v:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = v.Text
            if txt and txt ~= "" then
                if allowed(txt) then
                    print("🎣 Detected:", txt)
                    sendWebhook(txt)
                end
            end
        end)
    end
end

print("✅ Fish Hub Pro Loaded")
