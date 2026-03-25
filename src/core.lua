request = request or http_request or (syn and syn.request)

if not request then
    warn("Executor tidak support HTTP Request")
    return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

-- SAVE
local fileName = "fish_webhook.txt"
local webhook = isfile and isfile(fileName) and readfile(fileName) or ""

local function saveWebhook(url)
    if writefile then writefile(fileName, url) end
end

-- RARITY
local rarityEnabled = {
    ["common"] = false,
    ["uncommon"] = false,
    ["rare"] = false,
    ["epic"] = false,
    ["legendary"] = true,
    ["mythic"] = true,
    ["secret"] = true,
    ["forgotten"] = true
}

local rarityOrder = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

local cache = {}

-- INFO IKAN
local function extractInfo(name)
    name = tostring(name)

    local weight = name:match("(%d+%.?%d*%s?kg)")
    local mutation = name:match("[Mm]utation[:%s]+([%w%s]+)")

    local result = "🐟 "..name
    if weight then result = result .. "\n⚖️ "..weight end
    if mutation then result = result .. "\n✨ "..mutation end

    return result
end

-- NOTIF
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "NBS",
            Text = msg,
            Duration = 3
        })
    end)
end

-- FILTER
local function isUltra(text)
    text = tostring(text):lower()
    for rarity, enabled in pairs(rarityEnabled) do
        if enabled and text:find(rarity) then
            return true
        end
    end
    return false
end

-- WEBHOOK
local function sendWebhook(text)
    if webhook == "" then return end

    local info = extractInfo(text)

    if cache[info] then return end
    cache[info] = true
    task.delay(5, function() cache[info] = nil end)

    notify("Ikan kamu terdeteksi!")

    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = "🎣 NBS PLAYER LOG\n"..info
        })
    })

    if logBox then
        logBox.Text = info .. "\n\n" .. logBox.Text
    end
end

-- DETECT PLAYER SAJA
local function watchContainer(container)
    container.ChildAdded:Connect(function(item)
        task.wait(0.2)
        if isUltra(item.Name) then
            sendWebhook(item.Name)
        end
    end)
end

watchContainer(backpack)

player.CharacterAdded:Connect(function(char)
    watchContainer(char)
end)

-- UI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NBS_UI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 230, 0, 320)
main.Position = UDim2.new(0.35, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,35)
header.BackgroundTransparency = 1
header.Text = "NBS"
header.TextColor3 = Color3.fromRGB(0,255,170)
header.Font = Enum.Font.GothamBold
header.TextSize = 18

-- MINIMIZE BUTTON
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-35,0,5)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(40,40,45)

-- 🖼️ ICON POPUP
local icon = Instance.new("ImageButton", gui)
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0.4,0,0.3,0)
icon.BackgroundColor3 = Color3.fromRGB(20,20,25)
icon.Image = "rbxassetid://7733960981"
icon.Visible = false
icon.Active = true
icon.Draggable = true
Instance.new("UICorner", icon)

-- MINIMIZE LOGIC
minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    icon.Visible = true
end)

icon.MouseButton1Click:Connect(function()
    main.Visible = true
    icon.Visible = false
end)

-- INPUT
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,30)
input.Position = UDim2.new(0,10,0,45)
input.Text = webhook
input.PlaceholderText = "Webhook..."
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
input.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input)

-- SAVE
local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,28)
save.Position = UDim2.new(0,10,0,80)
save.Text = "Save"
save.BackgroundColor3 = Color3.fromRGB(0,200,140)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    saveWebhook(webhook)
    notify("Webhook saved")
end)

-- TEST
local test = Instance.new("TextButton", main)
test.Size = UDim2.new(1,-20,0,28)
test.Position = UDim2.new(0,10,0,115)
test.Text = "Test"
test.BackgroundColor3 = Color3.fromRGB(0,140,255)

test.MouseButton1Click:Connect(function()
    sendWebhook("TEST FISH")
end)

-- RARITY BUTTON
local y = 150
for _,rarity in ipairs(rarityOrder) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,25)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = (rarityEnabled[rarity] and "ON " or "OFF ")..rarity
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = (rarityEnabled[rarity] and "ON " or "OFF ")..rarity
    end)

    y = y + 28
end

-- LOG
logBox = Instance.new("TextLabel", main)
logBox.Size = UDim2.new(1,-20,0,60)
logBox.Position = UDim2.new(0,10,1,-70)
logBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.TextScaled = true
logBox.Text = "Waiting..."
Instance.new("UICorner", logBox)

print("🔥 NBS FINAL + ICON VERSION AKTIF!")
