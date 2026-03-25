--==================================================
-- FISH WEBHOOK HUB PRO (CLIENT + SERVER)
-- By ChatGPT (Pro Version)
--==================================================

local RunService = game:GetService("RunService")

--//////////////////////////////////////////////////
--// CLIENT (UI HUB MEWAH)
--//////////////////////////////////////////////////
if RunService:IsClient() then

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local player = Players.LocalPlayer
    local remote = ReplicatedStorage:WaitForChild("FishConfig")

    -- GUI
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "FishHubPro"

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,320,0,460)
    main.Position = UDim2.new(0.35,0,0.2,0)
    main.BackgroundColor3 = Color3.fromRGB(15,15,20)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main)

    -- SHADOW EFFECT
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0,170,255)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,40)
    title.Text = "🎣 FISH HUB PRO"
    title.TextColor3 = Color3.fromRGB(0,200,255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    -- INPUT
    local input = Instance.new("TextBox", main)
    input.Size = UDim2.new(1,-20,0,35)
    input.Position = UDim2.new(0,10,0,50)
    input.PlaceholderText = "Discord Webhook URL..."
    input.BackgroundColor3 = Color3.fromRGB(30,30,35)
    input.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", input)

    -- SAVE BUTTON
    local save = Instance.new("TextButton", main)
    save.Size = UDim2.new(1,-20,0,35)
    save.Position = UDim2.new(0,10,0,95)
    save.Text = "💾 SAVE CONFIG"
    save.BackgroundColor3 = Color3.fromRGB(0,140,255)
    Instance.new("UICorner", save)

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1,0,0,20)
    status.Position = UDim2.new(0,0,0,135)
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(0,255,100)
    status.BackgroundTransparency = 1

    -- ALL FISH
    local allFish = false
    local toggleAll = Instance.new("TextButton", main)
    toggleAll.Size = UDim2.new(1,-20,0,30)
    toggleAll.Position = UDim2.new(0,10,0,160)
    toggleAll.Text = "ALL FISH: OFF"
    toggleAll.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Instance.new("UICorner", toggleAll)

    -- SCROLL
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1,-20,0,230)
    scroll.Position = UDim2.new(0,10,0,200)
    scroll.CanvasSize = UDim2.new(0,0,0,500)
    scroll.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Instance.new("UICorner", scroll)

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,6)

    local rarityList = {
        "common","uncommon","rare","epic",
        "legendary","mythic","secret","forgotten"
    }

    local rarityEnabled = {}

    for _,rarity in ipairs(rarityList) do
        rarityEnabled[rarity] = false

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
        remote:FireServer({
            webhook = input.Text,
            rarity = rarityEnabled,
            all = allFish
        })

        status.Text = "✅ Saved!"
        task.wait(2)
        status.Text = ""
    end)

end


--//////////////////////////////////////////////////
--// SERVER (FULL LOGIC PRO)
--//////////////////////////////////////////////////
if RunService:IsServer() then

    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local DataStoreService = game:GetService("DataStoreService")

    local store = DataStoreService:GetDataStore("FishWebhookPro")

    -- REMOTES
    local configEvent = Instance.new("RemoteEvent", ReplicatedStorage)
    configEvent.Name = "FishConfig"

    local fishEvent = Instance.new("RemoteEvent", ReplicatedStorage)
    fishEvent.Name = "FishCaught"

    local playerConfig = {}
    local cooldown = {}

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

    local function getRarity(text)
        text = string.lower(text)
        for r,_ in pairs(rarityColors) do
            if text:find(r) then return r end
        end
        return "common"
    end

    local function getImage(name)
        name = string.lower(name):gsub(" ", "_")
        return "https://fish-it.fandom.com/wiki/Special:FilePath/"..name..".png"
    end

    game.Players.PlayerAdded:Connect(function(plr)
        local data
        pcall(function()
            data = store:GetAsync(plr.UserId)
        end)
        if data then
            playerConfig[plr] = data
        end
    end)

    configEvent.OnServerEvent:Connect(function(player, data)
        playerConfig[player] = data

        pcall(function()
            store:SetAsync(player.UserId, data)
        end)
    end)

    local function allowed(cfg, fish)
        if not cfg then return false end
        if cfg.all then return true end

        fish = string.lower(fish)
        for r,v in pairs(cfg.rarity) do
            if v and fish:find(r) then return true end
        end

        return false
    end

    local function sendWebhook(url, player, fish)

        if cooldown[player] and tick() - cooldown[player] < 3 then return end
        cooldown[player] = tick()

        local rarity = getRarity(fish)

        local data = {
            embeds = {{
                title = "🎣 Fish Caught!",
                description = "**"..fish.."**",
                color = rarityColors[rarity],

                thumbnail = {url = getImage(fish)},

                fields = {
                    {name="👤 Player", value=player.Name, inline=true},
                    {name="⭐ Rarity", value=rarity, inline=true},
                    {name="🆔 UserId", value=tostring(player.UserId)},
                    {name="🌍 Server", value=game.JobId}
                },

                footer = {text = "Fish Hub Pro"},
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        HttpService:PostAsync(
            url,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end

    fishEvent.OnServerEvent:Connect(function(player, fish)
        local cfg = playerConfig[player]
        if not cfg or cfg.webhook == "" then return end

        if allowed(cfg, fish) then
            sendWebhook(cfg.webhook, player, fish)

            if fish:lower():find("mythic") or fish:lower():find("secret") then
                print("🔥 RARE FISH DETECTED:", fish)
            end
        end
    end)

end
