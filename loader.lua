-- Configuration
local GITHUB_URL = "https://raw.githubusercontent.com/kapliken/Script/main/games/"
local PlaceIds = {
    -- Anime Fighting Simulator: Endless
    [130247632398296] = "afs-endless.lua",
}

-- Get current game
local currentPlaceId = game.PlaceId
local scriptName = PlaceIds[currentPlaceId]

-- Check if game is supported
if not scriptName then
    warn("This game is not supported!")
    warn("Place ID:", currentPlaceId)
    warn("Supported games:", #PlaceIds)
    _G.ScriptHubLoaded = false
    return
end

-- Load the script
print("Detected:", game:GetService("MarketplaceService"):GetProductInfo(currentPlaceId).Name)
print("Loading script...")

local success, err = pcall(function()
    local url = GITHUB_URL .. scriptName
    loadstring(game:HttpGet(url))()
end)

if success then
    print("✅ Script loaded successfully!")
else
    warn("❌ Failed to load script:", err)
    _G.ScriptHubLoaded = false
end
