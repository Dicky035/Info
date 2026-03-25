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

-- 🎯 RARITY
local rarityEnabled = {
    common=false,uncommon=false,rare=false,epic=false,
    legendary=true,mythic=true,secret=true,forgotten=true
}

local rarityOrder = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

-- 🎨 WARNA RARITY
local rarityColors = {
    common = Color3.fromRGB(120,120,120),
    uncommon = Color3.fromRGB(0,200,0),
    rare = Color3.fromRGB(0,120,255),
    epic = Color3.fromRGB(170,0,255),
    legendary = Color3.fromRGB(255,200,0),
    mythic = Color3.fromRGB(255,50,50),
    secret = Color3.fromRGB(64,224,208), -- TOSCA
    forgotten = Color3.fromRGB(150,150,150) -- ABU
}

local cache = {}

-- INFO IKAN
local function extractInfo(name)
    local weight = name:match("(%d+%.?%d*%s?kg)")
    local mutation = name:match("[Mm]utation[:%s]+([%w%s]+)")

    local result = "🐟 "..name
    if weight then result = result.."\n⚖️ "..weight end
    if mutation then result = result.."\n✨ "..mutation end

    return result
end

-- NOTIF
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "NBS Detector",
            Text = msg,
            Duration = 3
        })
    end)
end

-- FILTER
local function isUltra(text)
    text = tostring(text):lower()
    for r,en in pairs(rarityEnabled) do
        if en and text:find(r) then return true end
    end
    return false
end

-- 🚀 WEBHOOK ANTI GAGAL
local function sendWebhook(text)
    if webhook == "" then
        warn("Webhook kosong!")
        return
    end

    local info = extractInfo(text)

    if cache[info] then return end
    cache[info] = true

    notify("Mengirim ke webhook...")

    for i=1,3 do
        local success = pcall(function()
            request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "🎣 NBS LOG\n"..info
                })
            })
        end)

        if success then
            print("✅ Webhook terkirim!")
            break
        else
            warn("Retry "..i.." gagal")
            task.wait(1)
        end
    end

    if logBox then
        logBox.Text = info.."\n\n"..logBox.Text
    end
end

-- DETECT PLAYER
local function watch(container)
    container.ChildAdded:Connect(function(item)
        task.wait(0.2)
        if isUltra(item.Name) then
            sendWebhook(item.Name)
        end
    end)
end

watch(backpack)
player.CharacterAdded:Connect(watch)

-- UI
local gui = Instance.new("ScreenGui", PlayerGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,250,0,360)
main.Position = UDim2.new(0.35,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "NBS PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0,255,170)
title.BackgroundTransparency = 1

-- MINIMIZE
local minimize = Instance.new("TextButton", main)
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-35,0,5)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(40,40,45)

-- ICON
local icon = Instance.new("ImageButton", gui)
icon.Size = UDim2.new(0,50,0,50)
icon.Position = UDim2.new(0.4,0,0.3,0)
icon.Image = "rbxassetid://7733960981"
icon.Visible = false
icon.Active = true
icon.Draggable = true
Instance.new("UICorner", icon)

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
input.Position = UDim2.new(0,10,0,50)
input.Text = webhook
input.PlaceholderText = "Webhook..."
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.TextColor3 = Color3.new(1,1,1)
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", input)

-- SAVE
local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,28)
save.Position = UDim2.new(0,10,0,90)
save.Text = "SAVE WEBHOOK"
save.Font = Enum.Font.GothamBold
save.TextSize = 14
save.BackgroundColor3 = Color3.fromRGB(0,200,140)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    saveWebhook(webhook)
    notify("Webhook tersimpan!")
end)

-- TEST
local test = Instance.new("TextButton", main)
test.Size = UDim2.new(1,-20,0,28)
test.Position = UDim2.new(0,10,0,125)
test.Text = "TEST WEBHOOK"
test.Font = Enum.Font.GothamBold
test.TextSize = 14
test.BackgroundColor3 = Color3.fromRGB(0,140,255)

test.MouseButton1Click:Connect(function()
    sendWebhook("TEST LEGENDARY FISH 10kg Mutation Fire")
end)

-- 🎨 RARITY BUTTON
local y = 160
for _,r in ipairs(rarityOrder) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,25)
    btn.Position = UDim2.new(0,10,0,y)

    btn.Text = (rarityEnabled[r] and "ON " or "OFF ")..r
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)

    btn.BackgroundColor3 = rarityEnabled[r] and rarityColors[r] or Color3.fromRGB(40,40,45)

    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[r] = not rarityEnabled[r]

        btn.Text = (rarityEnabled[r] and "ON " or "OFF ")..r
        btn.BackgroundColor3 = rarityEnabled[r] and rarityColors[r] or Color3.fromRGB(40,40,45)
    end)

    y = y + 28
end

-- LOG
logBox = Instance.new("TextLabel", main)
logBox.Size = UDim2.new(1,-20,0,70)
logBox.Position = UDim2.new(0,10,1,-80)
logBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.Font = Enum.Font.Code
logBox.TextSize = 12
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.Text = "Waiting..."
Instance.new("UICorner", logBox)

print("🔥 NBS FINAL COLOR VERSION AKTIF!")
