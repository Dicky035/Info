--==================================================
-- FISH HUB DELTA (FINAL FIXED 100%)
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

-- ANTI DUPLICATE
local lastSent = ""

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

    print("📡 Sent:", msg)
end

--==================================================
-- DETECTION (FIX TOTAL)
--==================================================
local function isFish(text)
    text = text:lower()

    -- keyword global (WAJIB ADA SALAH SATU)
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

--==================================================
-- FUNCTION DETECT TEXTLABEL
--==================================================
local function hookLabel(v)
    if not v:IsA("TextLabel") then return end

    v:GetPropertyChangedSignal("Text"):Connect(function()
        local txt = v.Text

        if txt and txt ~= "" then
            local lower = txt:lower()

            if allowed(lower) then

                if lastSent == lower then return end
                lastSent = lower

                print("🎣 Fish:", txt)
                sendWebhook("🎣 Fish Caught:\n"..txt)
            end
        end
    end)
end

--==================================================
-- SCAN AWAL
--==================================================
for _,v in pairs(game:GetDescendants()) do
    hookLabel(v)
end

--==================================================
-- REALTIME DETECT (PENTING BANGET)
--==================================================
game.DescendantAdded:Connect(function(v)
    task.wait(0.2)
    hookLabel(v)
end)

print("✅ Fish Hub FINAL FIXED Loaded")
