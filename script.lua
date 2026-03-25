local request = request or http_request or (syn and syn.request)

if not request then
    warn("Executor tidak support HTTP Request")
    return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- SERVER INFO
local serverId = game.JobId
local placeId = game.PlaceId

-- SAVE
local fileName = "fish_webhook.txt"
local webhook = isfile and isfile(fileName) and readfile(fileName) or ""

local function saveWebhook(url)
    if writefile then writefile(fileName, url) end
end

-- MODE
local allFishMode = false

-- RARITY
local rarityEnabled = {
    common=false, uncommon=false, rare=false, epic=false,
    legendary=false, mythic=false, secret=false, forgotten=false
}

local rarityOrder = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

local rarityColors = {
    common = Color3.fromRGB(120,120,120),
    uncommon = Color3.fromRGB(0,200,0),
    rare = Color3.fromRGB(0,120,255),
    epic = Color3.fromRGB(170,0,255),
    legendary = Color3.fromRGB(255,200,0),
    mythic = Color3.fromRGB(255,50,50),
    secret = Color3.fromRGB(64,224,208),
    forgotten = Color3.fromRGB(150,150,150)
}

local cache = {}

-- NORMALIZE
local function normalizeFishName(name)
    name = name:lower()
    name = name:gsub("%d+%.?%d*%s?kg","")
    name = name:gsub("[Mm]utation[:%s]+[%w%s]+","")

    for _,r in ipairs(rarityOrder) do
        name = name:gsub(r,"")
    end

    return name:gsub("^%s+",""):gsub("%s+$","")
end

-- IMAGE
local function getFishImage(name)
    local clean = normalizeFishName(name)
    clean = clean:gsub(" ", "_")
    return "https://fish-it.fandom.com/wiki/Special:FilePath/"..clean..".png"
end

-- EXTRACT
local function extractData(name)
    local weight = name:match("(%d+%.?%d*%s?kg)") or "Unknown"
    local mutation = name:match("[Mm]utation[:%s]+([%w%s]+)") or "None"
    return weight, mutation
end

-- FILTER
local function isUltra(text)
    text = tostring(text):lower()
    if allFishMode then return true end

    for rarity, enabled in pairs(rarityEnabled) do
        if enabled and text:find(rarity) then
            return true
        end
    end
    return false
end

-- COLOR
local function getRarityColor(text)
    text = tostring(text):lower()

    for rarity, color in pairs(rarityColors) do
        if text:find(rarity) then
            return (math.floor(color.R*255) * 65536)
                 + (math.floor(color.G*255) * 256)
                 + math.floor(color.B*255)
        end
    end

    return 16777215
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

-- WEBHOOK
local function sendWebhook(text, playerName)
    if webhook == "" then return end

    local weight, mutation = extractData(text)

    local key = serverId.."|"..text
    if cache[key] then return end
    cache[key] = true

    notify("Mengirim ke webhook...")

    local embed = {
        title = "🎣 NBS FISH DETECTED",
        color = getRarityColor(text),

        image = {
            url = getFishImage(text)
        },

        fields = {
            {name = "👤 Player", value = playerName, inline = true},
            {name = "🐟 Fish", value = normalizeFishName(text), inline = false},
            {name = "⚖️ Weight", value = weight, inline = true},
            {name = "✨ Mutation", value = mutation, inline = true},
            {name = "🖥️ Server ID", value = serverId, inline = false},
            {name = "🌍 Place ID", value = tostring(placeId), inline = false}
        },

        footer = {
            text = "NBS HUB (SERVER LOCKED)"
        },

        timestamp = DateTime.now():ToIsoDate()
    }

    for i=1,3 do
        local success = pcall(function()
            request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    embeds = {embed}
                })
            })
        end)

        if success then break end
        task.wait(1)
    end
end

-- DETECT
local function watchPlayer(plr)

    local function hook(container)
        container.ChildAdded:Connect(function(item)
            task.wait(0.2)
            if item and item.Name and isUltra(item.Name) then
                sendWebhook(item.Name, plr.Name)
            end
        end)
    end

    if plr:FindFirstChild("Backpack") then
        hook(plr.Backpack)
    end

    plr.ChildAdded:Connect(function(c)
        if c.Name == "Backpack" then
            hook(c)
        end
    end)

    plr.CharacterAdded:Connect(function(char)
        hook(char)
    end)
end

for _,plr in ipairs(Players:GetPlayers()) do
    watchPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
    watchPlayer(plr)
end)

-- ================= UI HUB =================

local gui = Instance.new("ScreenGui", PlayerGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,280,0,420)
main.Position = UDim2.new(0.35,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🎣 NBS HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,0,0,20)
status.Position = UDim2.new(0,0,0,40)
status.Text = "Status: Idle"
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(150,150,150)

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,30)
input.Position = UDim2.new(0,10,0,70)
input.Text = webhook
input.PlaceholderText = "Webhook..."
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
Instance.new("UICorner", input)

local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,30)
save.Position = UDim2.new(0,10,0,110)
save.Text = "SAVE WEBHOOK"
save.BackgroundColor3 = Color3.fromRGB(0,120,255)
Instance.new("UICorner", save)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    saveWebhook(webhook)
    status.Text = "Status: Webhook Saved"
    notify("Webhook tersimpan!")
end)

local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,30)
toggleAll.Position = UDim2.new(0,10,0,150)
toggleAll.Text = "ALL FISH: OFF"
toggleAll.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", toggleAll)

toggleAll.MouseButton1Click:Connect(function()
    allFishMode = not allFishMode
    toggleAll.Text = "ALL FISH: "..(allFishMode and "ON" or "OFF")
    toggleAll.BackgroundColor3 = allFishMode and Color3.fromRGB(0,170,0) or Color3.fromRGB(50,50,50)
end)

local y = 190
for _,rarity in ipairs(rarityOrder) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,28)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = rarity:upper().." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = rarity:upper().." : "..(rarityEnabled[rarity] and "ON" or "OFF")
        btn.BackgroundColor3 = rarityEnabled[rarity] and rarityColors[rarity] or Color3.fromRGB(40,40,45)
    end)

    y = y + 32
end

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("🔥 NBS HUB FULL VERSION AKTIF!")
