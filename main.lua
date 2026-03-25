-- NBS LOADER (AUTO LOAD)

local url = "https://raw.githubusercontent.com/Dicky035/Info/main/script.lua"

local success, err = pcall(function()
    loadstring(game:HttpGet(url))()
end)

if not success then
    warn("❌ Gagal load script:", err)
end
