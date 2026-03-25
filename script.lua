-- ================= HTTP FIX =================
local request =
    (syn and syn.request)
    or (http and http.request)
    or (fluxus and fluxus.request)
    or http_request
    or request

if not request then
    warn("❌ Executor tidak support HTTP Request")
    return
end

-- ================= SERVICES =================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ================= SERVER =================
local serverId = game.JobId

-- ================= SAVE =================
local fileName = "fish_webhook.txt"
local webhook = (isfile and isfile(fileName) and readfile(fileName)) or ""

local function saveWebhook(url)
    if writefile then writefile(fileName, url) end
end

-- ================= MODE =================
local allFishMode = false

local rarityEnabled = {
    common=false, uncommon=false, rare=false, epic=false,
    legendary=false, mythic=false, secret=false, forgotten=false
}

local rarityOrder = {
    "common","uncommon","rare","epic",
    "legendary","mythic","secret","forgotten"
}

local rarityColors = {
    common = 8421504,
    uncommon = 65280,
    rare = 3071999,
    epic = 11141375,
    legendary = 16753920,
    mythic = 16724787,
    secret = 65535,
    forgotten = 10066329
}

local cache = {}

-- ================= FUNCTIONS =================
local function normalizeFishName(name)
    name = name:lower()
    name = name:gsub("%d+%.?%d*%s?kg","")
    name = name:gsub("[Mm]utation[:%s]+[%w%s]+","")

    for _,r in ipairs(rarityOrder) do
        name = name:gsub(r,"")
    end

    return name:gsub("^%s+",""):gsub("%s+$","")
end

local function getFishImage(name)
    local clean = normalizeFishName(name)
    clean = clean:gsub(" ", "_")
    return "https://fish-it.fandom.com/wiki/Special:FilePath/"..clean..".png"
end

local function extractData(name)
    local weight = name:match("(%d+%.?%d*%s?kg)") or "Unknown"
    local mutation = name:match("[Mm]utation[:%s]+([%w%s]+)") or "None"
    return weight, mutation
end

local function isSelected(text)
    text = tostring(text):lower()
    if allFishMode then return true end

    for rarity, enabled in pairs(rarityEnabled) do
        if enabled and text:find(rarity) then
            return true
        end
    end
    return false
end

local function getColor(text)
    text = tostring(text):lower()
    for rarity, color in pairs(rarityColors) do
        if text:find(rarity) then return color end
    end
    return 16777215
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Fish Hub",
            Text = msg,
            Duration = 3
        })
    end)
end

-- ================= WEBHOOK =================
local function sendWebhook(text, playerName)
    if webhook == "" then return end

    local key = serverId.."|"..text
    if cache[key] then return end
    cache[key] = true

    local weight, mutation = extractData(text)

    local data = {
        embeds = {{
            title = "🎣 Fish Detected",
            color = getColor(text),

            image = {
                url = getFishImage(text)
            },

            fields = {
                {name="👤 Player", value=playerName, inline=true},
                {name="🐟 Fish", value=normalizeFishName(text), inline=false},
                {name="⚖️ Weight", value=weight, inline=true},
                {name="✨ Mutation", value=mutation, inline=true},
                {name="🖥️ Server", value=serverId, inline=false}
            },

            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    for i=1,3 do
        local success = pcall(function()
            request({
                Url = webhook,
                Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)

        if success then break end
        task.wait(1)
    end
end

-- ================= DETECTOR =================
local function watchPlayer(plr)

    local function hook(container)
        container.ChildAdded:Connect(function(item)
            task.wait(0.2)
            if item and item.Name and isSelected(item.Name) then
                sendWebhook(item.Name, plr.Name)
            end
        end)
    end

    if plr:FindFirstChild("Backpack") then
        hook(plr.Backpack)
    end

    plr.ChildAdded:Connect(function(c)
        if c.Name == "Backpack" then hook(c) end
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
main.Size = UDim2.new(0,300,0,450)
main.Position = UDim2.new(0.35,0,0.2,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,40)
header.Text = "🎣 FISH IT HUB"
header.BackgroundTransparency = 1
header.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,5)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(170,0,0)
Instance.new("UICorner", close)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,30)
input.Position = UDim2.new(0,10,0,60)
input.Text = webhook
input.PlaceholderText = "Webhook..."
input.BackgroundColor3 = Color3.fromRGB(35,35,40)

local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,30)
save.Position = UDim2.new(0,10,0,100)
save.Text = "SAVE WEBHOOK"
save.BackgroundColor3 = Color3.fromRGB(0,120,255)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    saveWebhook(webhook)
    notify("Webhook disimpan!")
end)

local toggleAll = Instance.new("TextButton", main)
toggleAll.Size = UDim2.new(1,-20,0,30)
toggleAll.Position = UDim2.new(0,10,0,140)
toggleAll.Text = "ALL FISH: OFF"
toggleAll.BackgroundColor3 = Color3.fromRGB(50,50,50)

toggleAll.MouseButton1Click:Connect(function()
    allFishMode = not allFishMode
    toggleAll.Text = "ALL FISH: "..(allFishMode and "ON" or "OFF")
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-20,0,220)
scroll.Position = UDim2.new(0,10,0,180)
scroll.CanvasSize = UDim2.new(0,0,0,400)
scroll.BackgroundColor3 = Color3.fromRGB(30,30,35)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

for _,rarity in ipairs(rarityOrder) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,30)
    btn.Text = rarity:upper().." : OFF"
    btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
    btn.Parent = scroll

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = rarity:upper().." : "..(rarityEnabled[rarity] and "ON" or "OFF")
    end)
end

print("🔥 FISH IT HUB FULL SCRIPT AKTIF!")
