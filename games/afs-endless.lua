-- [[ SETTINGS & PERSISTENCE ]]
_G.SelectedAutoChampID = _G.SelectedAutoChampID or nil
_G.UpgradeList = _G.UpgradeList or {}

-- [[ CLEANUP OLD SCRIPT ]]
if _G.StopTraining then 
    _G.StopTraining() 
    task.wait(0.5)
end

-- Cleanup all connections and loops
if _G.CleanupConnections then
    for _, connection in pairs(_G.CleanupConnections) do
        if connection and connection.Disconnect then
            connection:Disconnect()
        end
    end
end
_G.CleanupConnections = {}

-- Session ID to stop old loops
_G.ScriptSessionId = (_G.ScriptSessionId or 0) + 1
local CurrentScriptSession = _G.ScriptSessionId

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvent")
local RemoteFunc = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteFunction")
local GameData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameData"))

-- [[ VARIABLES ]]
local TrainingActive = false
local CurrentSessionId = math.random(1, 100000)
local LastEquippedStat = "None"
local AutoEquipEnabled = false
local AutoUpgradeActive = false
local SmartAreaEnabled = true
local SelectedStatId = "1"

-- [[ TRAINING AREAS ]]
local TrainingAreas = {
    -- Strength Areas
    {Stat = "1", Requires = 100, Position = Vector3.new(-5.9, 66.9, 133.6), Name = "Dummy", Multiply = 5},
    {Stat = "1", Requires = 10000, Position = Vector3.new(1340.8, 139.5, -137.3), Name = "Gym", Multiply = 15},
    {Stat = "1", Requires = 100000, Position = Vector3.new(-1256.9, 59.8, 485.6), Name = "Beach", Multiply = 50},
    {Stat = "1", Requires = 1000000, Position = Vector3.new(-906.4, 48, 174.6), Name = "Meteor", Multiply = 100},
    {Stat = "1", Requires = 10000000, Position = Vector3.new(-2258.3, 614.7, 537.7), Name = "Lookout Island", Multiply = 500},
    {Stat = "1", Requires = 100000000, Position = Vector3.new(-40.7, 84.3, -1308), Name = "Arena", Multiply = 1000},
    {Stat = "1", Requires = 1000000000, Position = Vector3.new(718.8, 144.2, 929.8), Name = "Excalibur", Multiply = 5000},
    {Stat = "1", Requires = 100000000000, Position = Vector3.new(1855.19, 146.1, 92.2), Name = "Leveling", Multiply = 10000},
    {Stat = "1", Requires = 5000000000000, Position = Vector3.new(631, 663, 432), Name = "Floating Island", Multiply = 25000},
    {Stat = "1", Requires = 250000000000000, Position = Vector3.new(4235, 60, -599), Name = "Skull", Multiply = 100000},
    {Stat = "1", Requires = 150000000000000000, Position = Vector3.new(796.781, 216.74, -1003.9), Name = "Boulder", Multiply = 150000},
    {Stat = "1", Requires = 25000000000000000000, Position = Vector3.new(3873.46, 118.198, 880.244), Name = "Piggy", Multiply = 300000},
    {Stat = "1", Requires = 1e22, Position = Vector3.new(3860.03, 724.489, -1184.4), Name = "Heavenly Pillar", Multiply = 1000000},
    
    -- Durability Areas
    {Stat = "2", Requires = 100, Position = Vector3.new(72.5, 83.6, 880.6), Name = "Pirate Ship", Multiply = 5},
    {Stat = "2", Requires = 10000, Position = Vector3.new(-1652.4, 58.9, -541.09), Name = "Desert Island", Multiply = 15},
    {Stat = "2", Requires = 100000, Position = Vector3.new(-79.099, 61.5, 2029.8), Name = "Igloo", Multiply = 50},
    {Stat = "2", Requires = 1000000, Position = Vector3.new(-623.9, 191.1, 735.4), Name = "Paw", Multiply = 100},
    {Stat = "2", Requires = 10000000, Position = Vector3.new(-1062.6, 88.3, -927.2), Name = "Volcano", Multiply = 500},
    {Stat = "2", Requires = 100000000, Position = Vector3.new(-337.1, 59.5, -1651), Name = "Black Flames", Multiply = 1000},
    {Stat = "2", Requires = 1000000000, Position = Vector3.new(2465.3, 1439.5, -370.85), Name = "Planet", Multiply = 5000},
    {Stat = "2", Requires = 100000000000, Position = Vector3.new(-2753.8, -230.19, 352.6), Name = "Time Chamber", Multiply = 10000},
    {Stat = "2", Requires = 5000000000000, Position = Vector3.new(2176, 516, 598), Name = "Hollow", Multiply = 25000},
    {Stat = "2", Requires = 250000000000000, Position = Vector3.new(1670, 424, -1303), Name = "Founder", Multiply = 100000},
    {Stat = "2", Requires = 150000000000000000, Position = Vector3.new(190.854, 785.492, -702.3), Name = "Rock Planet", Multiply = 150000},
    {Stat = "2", Requires = 25000000000000000000, Position = Vector3.new(2561, 183.5, 1558), Name = "Marine Island", Multiply = 300000},
    {Stat = "2", Requires = 1e22, Position = Vector3.new(1687.05, 2479.83, -34.979), Name = "Island of Power", Multiply = 1000000},
    
    -- Chakra Areas
    {Stat = "3", Requires = 100, Position = Vector3.new(-7.9, 71.8, -123.59), Name = "Chakra Tree", Multiply = 5},
    {Stat = "3", Requires = 10000, Position = Vector3.new(1423.3, 144.5, -586.4), Name = "Library", Multiply = 15},
    {Stat = "3", Requires = 100000, Position = Vector3.new(912.5, 138, 784), Name = "Truth Waterfall", Multiply = 50},
    {Stat = "3", Requires = 1000000, Position = Vector3.new(1621.8, 446.7, 639.799), Name = "Temple", Multiply = 100},
    {Stat = "3", Requires = 10000000, Position = Vector3.new(335.799, -152.5, -1830.3), Name = "Fox Statue", Multiply = 500},
    {Stat = "3", Requires = 100000000, Position = Vector3.new(1026.3, 255.199, -626.79), Name = "Sakura Chakra Tree", Multiply = 1000},
    {Stat = "3", Requires = 1000000000, Position = Vector3.new(3053.6, 108.599, 1105.5), Name = "Sage Platform", Multiply = 5000},
    {Stat = "3", Requires = 100000000000, Position = Vector3.new(1496.4, 486, 1892), Name = "Crystal Of Heaven", Multiply = 10000},
    {Stat = "3", Requires = 5000000000000, Position = Vector3.new(-8.965, 72.0849, -478.3), Name = "Ramen Shop", Multiply = 25000},
    {Stat = "3", Requires = 250000000000000, Position = Vector3.new(-395.15, 1230.93, 669.817), Name = "Ultimate Dragon", Multiply = 100000},
    {Stat = "3", Requires = 150000000000000000, Position = Vector3.new(-741.75, 2687.94, 593.848), Name = "Eyeball", Multiply = 150000},
    {Stat = "3", Requires = 25000000000000000000, Position = Vector3.new(3243.87, -454.47, -244.19), Name = "Gate", Multiply = 300000},
    {Stat = "3", Requires = 1e22, Position = Vector3.new(329.196, 287.459, 1893), Name = "Mystical Tree", Multiply = 1000000},
    
    -- Speed Areas
    {Stat = "6", Requires = 100, Position = Vector3.new(-106.69, 66, -505), Name = "Treadmills", Multiply = 5},
    {Stat = "6", Requires = 10000, Position = Vector3.new(-434.7, 133.8, -78.8), Name = "Gravity Chamber", Multiply = 20},
    {Stat = "6", Requires = 100000, Position = Vector3.new(3482.13, 66.18, 146.6), Name = "Kunai Grounds", Multiply = 100},
    {Stat = "6", Requires = 5000000, Position = Vector3.new(4109.44, 70.485, 852.289), Name = "Church", Multiply = 500},
    
    -- Agility Areas
    {Stat = "5", Requires = 100, Position = Vector3.new(42.8, 86, 451.5), Name = "Trampoline", Multiply = 5},
    {Stat = "5", Requires = 10000, Position = Vector3.new(-434.7, 133.8, -78.8), Name = "Gravity Chamber", Multiply = 20},
    {Stat = "5", Requires = 100000, Position = Vector3.new(3482.13, 66.18, 146.6), Name = "Kunai Grounds", Multiply = 100},
    {Stat = "5", Requires = 5000000, Position = Vector3.new(4109.44, 70.485, 842.289), Name = "Church", Multiply = 500},
}

-- [[ AUTO-EQUIP LOGIC ]]

local function getOwnedChampionsList()
    local list = {"None"}
    local champFolder = player:FindFirstChild("Champions")
    if champFolder then
        for _, champObj in pairs(champFolder:GetChildren()) do
            local champId = tostring(champObj.Name)
            local data = GameData.Champions[champId]
            if data then 
                table.insert(list, data.Name)
            end
        end
    end
    return list
end

local function getChampObjByName(name)
    if name == "None" then return nil end
    
    local champFolder = player:FindFirstChild("Champions")
    if not champFolder then return nil end
    
    for _, champObj in pairs(champFolder:GetChildren()) do
        local champId = tostring(champObj.Name)
        local data = GameData.Champions[champId]
        if data and data.Name == name then 
            print("[DEBUG] Mapped", name, "to IntValue object")
            return champObj
        end
    end
    
    warn("[DEBUG] Could not find champion object for:", name)
    return nil
end

-- [[ AUTO-EQUIP WITH CLEANUP ]]
local lastEquipAttempt = 0
local equipCooldown = 5

local function tryEquipChampion(targetChampObj)
    if not targetChampObj then return false end
    
    local now = tick()
    if now - lastEquipAttempt < equipCooldown then
        return false
    end
    
    local success, result = pcall(function()
        return RemoteFunc:InvokeServer("SummonChamp", targetChampObj)
    end)
    
    if success then
        lastEquipAttempt = now
        if result == 'A' then
            print("[AUTO-EQUIP] ✓ Successfully equipped!")
            return true
        elseif result == 'B' then
            print("[AUTO-EQUIP] On cooldown from game")
            return false
        else
            print("[AUTO-EQUIP] Unknown result:", result)
            return false
        end
    else
        warn("[AUTO-EQUIP] ✗ Remote call failed:", result)
        lastEquipAttempt = now
        return false
    end
end

-- Persistent loop with session check
task.spawn(function()
    local mySession = CurrentScriptSession
    print("[AUTO-EQUIP] Loop started (Session:", mySession, ")")
    
    while _G.ScriptSessionId == mySession do
        task.wait(3)
        
        if AutoEquipEnabled and _G.SelectedAutoChampID then
            pcall(function()
                if not player:FindFirstChild("ChampionEquipped") then 
                    warn("[ERROR] player.ChampionEquipped not found")
                    return 
                end
                
                local currentEquipped = player.ChampionEquipped.Value
                local targetChampObj = _G.SelectedAutoChampID
                
                if currentEquipped ~= targetChampObj then
                    local currentId = currentEquipped and tostring(currentEquipped.Name) or "nil"
                    local targetId = tostring(targetChampObj.Name)
                    print("[AUTO-EQUIP] Current:", currentId, "| Target:", targetId)
                    tryEquipChampion(targetChampObj)
                end
            end)
        end
    end
    
    print("[AUTO-EQUIP] Loop stopped (Session:", mySession, "ended)")
end)

-- Handle character reset with cleanup
local characterAddedConnection = player.CharacterAdded:Connect(function(character)
    if _G.ScriptSessionId ~= CurrentScriptSession then return end
    if not AutoEquipEnabled or not _G.SelectedAutoChampID then return end
    
    print("[AUTO-EQUIP] Character respawned, waiting to re-equip...")
    character:WaitForChild("Humanoid")
    task.wait(3)
    
    task.spawn(function()
        for i = 1, 3 do
            if _G.ScriptSessionId ~= CurrentScriptSession then break end
            if tryEquipChampion(_G.SelectedAutoChampID) then
                print("[AUTO-EQUIP] ✓ Re-equipped after respawn!")
                break
            end
            task.wait(5)
        end
    end)
end)
table.insert(_G.CleanupConnections, characterAddedConnection)

-- [[ AUTO TRAINING HELPERS ]]
local function getCharacterSafely()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
        if player.Character.Humanoid.Health > 0 then return player.Character, player.Character.HumanoidRootPart, player.Character.Humanoid end
    end
    return nil, nil, nil
end

local function findBestAreaForStat(statId)
    if not player.Stats or not player.Stats[statId] then return nil end
    local currentStatValue = player.Stats[statId].Value
    local bestArea = nil
    local highestRequirement = 0
    for _, area in ipairs(TrainingAreas) do
        if area.Stat == statId and currentStatValue >= area.Requires then
            if area.Requires > highestRequirement then
                highestRequirement = area.Requires
                bestArea = area
            end
        end
    end
    return bestArea
end

local function equipToolOnce(slot)
    local char, hrp, hum = getCharacterSafely()
    if char and not char:FindFirstChildWhichIsA("Tool") then
        local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
        pcall(function()
            VIM:SendKeyEvent(true, keys[slot], false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, keys[slot], false, game)
        end)
    end
end

_G.StopTraining = function()
    TrainingActive = false
    AutoUpgradeActive = false
    CurrentSessionId = math.random(1, 100000)
    LastEquippedStat = "None"
    
    pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game) end)
    
    pcall(function()
        local _, root, _ = getCharacterSafely()
        if root then root.Anchored = false end
    end)
    
    -- Deactivate sword if equipped
    pcall(function()
        local char = player.Character
        if char then
            local sword = char:FindFirstChild("SWORD")
            if sword and sword:FindFirstChild("Active") and sword.Active.Value == true then
                RemoteEvent:FireServer("ActivateSword")
                print("[STOP] Deactivated sword")
            end
        end
    end)
    
    -- Unequip all tools to reset state
    pcall(function()
        local char = player.Character
        if char then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                tool.Parent = player.Backpack
            end
        end
    end)
end

-- [[ UI SYSTEM ]]
local Window = Rayfield:CreateWindow({
   Name = "Anime Fighting Simulator: Endless",
   ConfigurationSaving = { Enabled = false },
   LoadingTitle = "SHIT BUTT POOP HUB",
   LoadingSubtitle = "By Miki",
   ToggleUIKeybind = "K"
})

local Main = Window:CreateTab("Main")
local Upgrades = Window:CreateTab("Upgrades")

Main:CreateSection("Auto Train")

Main:CreateDropdown({
   Name = "Target Stat:",
   Options = {"Strength","Durability","Chakra","Speed","Agility"},
   CurrentOption = {"Strength"},
   Callback = function(Option)
        local val = Option[1]
        if val == "Strength" then SelectedStatId = "1"
        elseif val == "Durability" then SelectedStatId = "2"
        elseif val == "Chakra" then SelectedStatId = "3"
        elseif val == "Agility" then SelectedStatId = "5"
        elseif val == "Speed" then SelectedStatId = "6"
        end
        LastEquippedStat = "None"
   end,
})

Main:CreateToggle({
   Name = "Auto Train Stat",
   CurrentValue = false,
   Callback = function(Value)
        TrainingActive = Value
        if Value then
            CurrentSessionId = CurrentSessionId + 1
            local mySession = CurrentSessionId
            task.spawn(function()
                while TrainingActive and CurrentSessionId == mySession and _G.ScriptSessionId == CurrentScriptSession do
                    pcall(function()
                        local area = SmartAreaEnabled and findBestAreaForStat(SelectedStatId) or nil
                        local char, root, hum = getCharacterSafely()
                        if char and root and hum and area then
                            if (root.Position - area.Position).Magnitude > 10 then
                                root.CFrame = CFrame.new(area.Position)
                                task.wait(0.2)
                            end
                            if SelectedStatId == "5" or SelectedStatId == "6" or SelectedStatId == "3" then
                                if not root.Anchored then root.Anchored = true end
                            else
                                if root.Anchored then root.Anchored = false end
                            end
                            
                            if SelectedStatId == "1" then 
                                if LastEquippedStat ~= "1" then equipToolOnce(1) task.wait(0.1) LastEquippedStat = "1" end
                                pcall(function() RemoteEvent:FireServer("Train", 1) end)
                            elseif SelectedStatId == "2" then 
                                if LastEquippedStat ~= "2" then 
                                    equipToolOnce(4)
                                    task.wait(0.2)
                                    local sw = char:FindFirstChild("SWORD")
                                    if sw and sw:FindFirstChild("Active") and sw.Active.Value == false then 
                                        pcall(function() RemoteEvent:FireServer("ActivateSword") end)
                                    end
                                    LastEquippedStat = "2"
                                end
                                pcall(function() RemoteEvent:FireServer("Train", 4) end)
                            elseif SelectedStatId == "3" then 
                                if LastEquippedStat ~= "3" then equipToolOnce(3) task.wait(0.1) LastEquippedStat = "3" end
                                pcall(function() RemoteEvent:FireServer("Train", 3) end)
                            elseif SelectedStatId == "5" then 
                                RemoteEvent:FireServer("Train", 5) 
                                hum.Jump = true
                            elseif SelectedStatId == "6" then 
                                RemoteEvent:FireServer("Train", 6) 
                                VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game) 
                            end
                        end
                    end)
                    task.wait(0.25)
                end
            end)
        else
            _G.StopTraining()
        end
   end,
})

Main:CreateSection("Simple Auto-Equip")

Main:CreateDropdown({
   Name = "Select Champion to Keep Equipped:",
   Options = getOwnedChampionsList(),
   CurrentOption = {"None"},
   Callback = function(Option)
        _G.SelectedAutoChampID = getChampObjByName(Option[1])
        print("[UI] Selected champion object:", _G.SelectedAutoChampID)
   end,
})

Main:CreateToggle({
   Name = "Enable Auto-Equip",
   CurrentValue = false,
   Callback = function(Value)
        AutoEquipEnabled = Value
   end,
})

-- [[ UPGRADES TAB ]]
local StatMapping = {["Strength"]="1", ["Durability"]="2", ["Chakra"]="3", ["Sword"]="4", ["Agility"]="5", ["Speed"]="6"}
Upgrades:CreateSection("Auto Upgrade")
Upgrades:CreateDropdown({
   Name = "Select Stats:",
   Options = {"Strength", "Durability", "Chakra", "Sword", "Agility", "Speed"},
   CurrentOption = _G.UpgradeList,
   MultipleOptions = true,
   Callback = function(Options) _G.UpgradeList = Options end,
})

Upgrades:CreateToggle({
   Name = "Auto Upgrade",
   CurrentValue = false,
   Callback = function(Value)
        AutoUpgradeActive = Value
        if Value then
            task.spawn(function()
                while AutoUpgradeActive and _G.ScriptSessionId == CurrentScriptSession do
                    for _, statName in pairs(_G.UpgradeList) do
                        local statId = StatMapping[statName]
                        if statId then 
                            pcall(function() 
                                RemoteFunc:InvokeServer("Upgrade", tonumber(statId)) 
                            end) 
                        end
                        task.wait(0.1)
                    end
                    task.wait(3)
                end
            end)
        end
   end,
})

Upgrades:CreateSection("Gachas")

local Gachas = {
    G1 = "G1",
    G2 = "G2",
    G3 = "G3",
    G4 = "G4",
    G5 = "G5",
    G6 = "G6"
}

local SelectedGacha = "G1"

Upgrades:CreateDropdown({
    Name = "Select Gacha:",
    Options = {"G1", "G2", "G3", "G4", "G5", "G6"},
    CurrentOption = {"G1"},
    MultipleOptions = false,
    Callback = function(Options)
        SelectedGacha = Options[1]
        print("[Gacha] Selected:", SelectedGacha)    
    end,
})

Upgrades:CreateToggle({
   Name = "Auto Spin",
   CurrentValue = false,
   Callback = function(Value)
        AutoSpinActive = Value
        if Value then
            task.spawn(function()
                while AutoSpinActive and _G.ScriptSessionId == CurrentScriptSession do
                    pcall(function()
                        RemoteFunc:InvokeServer("BuyGacha", SelectedGacha)
                        print("Auto Spinning", SelectedGacha)
                    end)
                    task.wait(3)
                end
            end)
        end
    end,
})

-- [[ COMBAT TAB ]]
local Combat = Window:CreateTab("Combat", 4483362458)
local ESPEnabled = false

local function CreateESP(p)
    if p == player then return end

    local function setup(char)
        if not char then return end
        
        local highlight = char:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
        highlight.Enabled = ESPEnabled
        highlight.Parent = char

        local billboard = char:FindFirstChild("ESPBillboard") or Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.Adornee = char:FindFirstChild("Head")
        billboard.AlwaysOnTop = true
        billboard.ExtentsOffset = Vector3.new(0, 3, 0)
        billboard.Enabled = ESPEnabled
        billboard.Parent = char

        local textLabel = billboard:FindFirstChild("Info") or Instance.new("TextLabel")
        textLabel.Name = "Info"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.Parent = billboard

        task.spawn(function()
            while char and char.Parent and billboard and _G.ScriptSessionId == CurrentScriptSession do
                if ESPEnabled then
                    local power = "0"
                    pcall(function()
                        power = GameData.abbreviateNumber(p.OtherData.TotalPower.Value)
                    end)
                    
                    local dist = 0
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                        dist = math.floor((player.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
                    end

                    textLabel.Text = string.format("%s\n[ %s Power ]\n[ %d Studs ]", p.DisplayName, power, dist)
                end
                task.wait(0.1)
            end
        end)
    end

    local conn = p.CharacterAdded:Connect(setup)
    table.insert(_G.CleanupConnections, conn)
    if p.Character then setup(p.Character) end
end

for _, p in pairs(game.Players:GetPlayers()) do CreateESP(p) end
local playerAddedConn = game.Players.PlayerAdded:Connect(CreateESP)
table.insert(_G.CleanupConnections, playerAddedConn)

Combat:CreateSection("Visuals")

Combat:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(Value)
        ESPEnabled = Value
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight.Enabled = Value end
                if p.Character:FindFirstChild("ESPBillboard") then p.Character.ESPBillboard.Enabled = Value end
            end
        end
   end,
})

-- [[ ANTI-AFK ]]
local function AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    
    -- Handle idle event
    local conn = player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    table.insert(_G.CleanupConnections, conn)
    
    -- Simulate click every 10 minutes
    task.spawn(function()
        while _G.ScriptSessionId == CurrentScriptSession do
            task.wait(600) -- 10 minutes = 600 seconds
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                print("[ANTI-AFK] Simulated click to prevent AFK kick")
            end)
        end
    end)
end

AntiAFK()
