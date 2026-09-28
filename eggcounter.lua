--//============================================================//
--// KYOSH EGG COUNTER + ACCOUNT MONITOR
--// Clean inventory scanner - does not use Client.Save
--// Reads the visible BackpackGui inventory.
--//
--// Website data:
--//   Eggs: name, weight
--//   Pets: name, weight, cash, rate
--//   Optional: category, favorite, equipped, mutations
--//============================================================//

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Egg sell-price modules used by the game
local EggSave = nil
local EggRecords = nil

pcall(function()
    EggSave = require(game:GetService("ReplicatedStorage").Shared.Save)
end)

pcall(function()
    EggRecords = require(game:GetService("ReplicatedStorage").Shared.Util.EggRecords)
end)

--==============================================================--
-- SETTINGS
--==============================================================--

local MONITOR_URL = "https://khscript.onrender.com/"
local MONITOR_API_KEY = "KYOSH-12162006"

local HEARTBEAT_INTERVAL = 5
local INVENTORY_SCAN_INTERVAL = 0.5

--==============================================================--
-- HTTP
--==============================================================--

local RequestFunction =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

local function SendMonitorRequest(data)
    if not RequestFunction then
        warn("HTTP request function unavailable")
        return false, "No request function"
    end

    if MONITOR_URL == "" then
        warn("MONITOR_URL is not configured")
        return false, "No monitor URL"
    end

    local success, result = pcall(function()
        return RequestFunction({
            Url = MONITOR_URL .. "/heartbeat",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-API-Key"] = MONITOR_API_KEY
            },
            Body = HttpService:JSONEncode(data)
        })
    end)

    if not success then
        return false, result
    end

    return true, result
end

--==============================================================--
-- STATE
--==============================================================--

local CurrentEggCount = 0
local CurrentMoney = nil
local CurrentSpeed = nil
local CurrentPets = nil

--==============================================================--
-- BASIC HELPERS
--==============================================================--

local function SafeText(object)
    if not object then
        return ""
    end

    local parts = {}

    local function addText(child)
        if child:IsA("TextLabel")
            or child:IsA("TextButton")
            or child:IsA("TextBox") then

            local value = child.Text
            if value and value ~= "" then
                table.insert(parts, value)
            end
        end
    end

    addText(object)

    for _, child in ipairs(object:GetDescendants()) do
        addText(child)
    end

    return table.concat(parts, " ")
end

local function Lower(value)
    return string.lower(tostring(value or ""))
end

local function NumberFromText(text)
    if not text then
        return nil
    end

    local cleaned = tostring(text)
        :gsub(",", "")
        :gsub("%$", "")
        :gsub("/s", "")
        :gsub("%s+", " ")

    local value = cleaned:match("([%d%.]+)%s*[kK][gG]")
    if value then
        return tonumber(value)
    end

    value = cleaned:match("([%d%.]+)")
    return tonumber(value)
end

local function WeightFromText(text)
    if not text then
        return nil
    end

    local value = tostring(text):match("([%d%.]+)%s*[kK][gG]")
    return value and tonumber(value) or nil
end

local function CashFromText(text)
    if not text then
        return nil
    end

    local value = tostring(text)
        :gsub(",", "")
        :gsub("%$", "")

    local number = value:match("([%d%.]+)%s*([kKmMbBtT]?)")

    if not number then
        return nil
    end

    local n, suffix = value:match("([%d%.]+)%s*([kKmMbBtT]?)")
    n = tonumber(n)

    if not n then
        return nil
    end

    suffix = string.lower(suffix or "")

    if suffix == "k" then
        n = n * 1000
    elseif suffix == "m" then
        n = n * 1000000
    elseif suffix == "b" then
        n = n * 1000000000
    elseif suffix == "t" then
        n = n * 1000000000000
    end

    return n
end

local function GetAttribute(object, names)
    if not object then
        return nil
    end

    for _, name in ipairs(names) do
        local ok, value = pcall(function()
            return object:GetAttribute(name)
        end)

        if ok and value ~= nil then
            return value
        end
    end

    return nil
end

local function GetNamedText(object, names)
    if not object then
        return nil
    end

    for _, name in ipairs(names) do
        local child = object:FindFirstChild(name, true)

        if child and child:IsA("TextLabel")
            or child and child:IsA("TextButton")
            or child and child:IsA("TextBox") then

            if child.Text and child.Text ~= "" then
                return child.Text
            end
        end
    end

    return nil
end

local function GetIcon(object)
    if not object then
        return ""
    end

    local icon = object:FindFirstChild("Icon", true)

    if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
        return icon.Image or ""
    end

    return ""
end

--==============================================================--
-- INVENTORY UI PATH
--==============================================================--

local function GetInventory()
    local BackpackGui = PlayerGui:FindFirstChild("BackpackGui")
    if not BackpackGui then
        return nil
    end

    local Backpack = BackpackGui:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end

    local Main = Backpack:FindFirstChild("Main")
    if not Main then
        return nil
    end

    return Main:FindFirstChild("Inventory")
end

local function GetHotbar()
    local BackpackGui = PlayerGui:FindFirstChild("BackpackGui")
    if not BackpackGui then
        return nil
    end

    local Backpack = BackpackGui:FindFirstChild("Backpack")
    if not Backpack then
        return nil
    end

    return Backpack:FindFirstChild("Hotbar")
end

--==============================================================--
-- INVENTORY SLOT PARSER
--==============================================================--

local function IsInventorySlot(object)
    if not object or not object:IsA("TextButton") then
        return false
    end

    return tonumber(object.Name) ~= nil
end

local function GetSlotName(slot, fullText, isEgg)
    local attributeName = GetAttribute(slot, {
        "DisplayName",
        "ItemName",
        "PetName",
        "EggName",
        "Name"
    })

    if attributeName and tostring(attributeName) ~= "" then
        return tostring(attributeName)
    end

    local namedText = GetNamedText(slot, {
        "DisplayName",
        "ItemName",
        "PetName",
        "EggName",
        "Name",
        "Title"
    })

    if namedText and namedText ~= "" then
        return namedText
    end

    -- Use the first useful text line as a fallback.
    local lines = {}

    for line in tostring(fullText):gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")

        if line ~= ""
            and not line:match("^%d+$")
            and not line:match("^%([xX]%d+%)$")
            and not line:match("^[%d%.]+%s*[kKmMbBtT]?[gG]?$")
            and not line:match("^[%$%d%.]+") then

            table.insert(lines, line)
        end
    end

    if lines[1] then
        return lines[1]
    end

    return isEgg and "Egg" or "Pet"
end

local function GetSlotCategory(slot, fullText)
    local category = GetAttribute(slot, {
        "Category",
        "AssetCategory",
        "ItemType",
        "Type"
    })

    if category ~= nil then
        return tostring(category)
    end

    local text = Lower(fullText)

    if string.find(text, "egg", 1, true) then
        return "Egg"
    end

    return "Pet"
end

local function GetSlotWeight(slot, fullText)
    local value = GetAttribute(slot, {
        "Weight",
        "WeightKg",
        "VisualWeight",
        "Kg"
    })

    if value ~= nil then
        local number = tonumber(value)
        if number then
            return number
        end
    end

    local namedText = GetNamedText(slot, {
        "Weight",
        "WeightLabel",
        "Kg",
        "Size"
    })

    return WeightFromText(namedText or fullText)
end

local function GetSlotCash(slot, fullText)
    local value = GetAttribute(slot, {
        "Cash",
        "SellPrice",
        "Value",
        "Price"
    })

    if value ~= nil then
        local number = tonumber(value)
        if number then
            return number
        end
    end

    local namedText = GetNamedText(slot, {
        "Cash",
        "SellPrice",
        "Price",
        "Value"
    })

    return CashFromText(namedText or fullText)
end

local function GetSlotRate(slot, fullText)
    local value = GetAttribute(slot, {
        "Rate",
        "EarningRate",
        "Income",
        "CashPerSecond"
    })

    if value ~= nil then
        local number = tonumber(value)
        if number then
            return number
        end
    end

    local namedText = GetNamedText(slot, {
        "Rate",
        "EarningRate",
        "Income",
        "CashPerSecond"
    })

    local text = namedText or fullText
    if not text then
        return nil
    end

    local n = tostring(text)
        :gsub(",", "")
        :match("([%d%.]+)%s*/?%s*[sS]")

    return tonumber(n)
end

local function GetSlotMutations(slot)
    local mutations = {}

    local attribute = GetAttribute(slot, {
        "Mutations",
        "Mutation"
    })

    if type(attribute) == "table" then
        for _, value in ipairs(attribute) do
            table.insert(mutations, tostring(value))
        end
    elseif attribute ~= nil and tostring(attribute) ~= "" then
        table.insert(mutations, tostring(attribute))
    end

    local text = SafeText(slot)
    local lower = Lower(text)

    local known = {
        "golden",
        "rainbow",
        "shiny",
        "huge",
        "mythic",
        "rainbow shiny"
    }

    for _, mutation in ipairs(known) do
        if string.find(lower, mutation, 1, true) then
            local already = false

            for _, existing in ipairs(mutations) do
                if Lower(existing) == mutation then
                    already = true
                    break
                end
            end

            if not already then
                table.insert(mutations, mutation)
            end
        end
    end

    return mutations
end

local function GetSlotBoolean(slot, names)
    local value = GetAttribute(slot, names)

    if value ~= nil then
        return value == true
    end

    return false
end

local function GetEggSellPrice(uid)
    if not EggSave or not EggRecords then
        return nil
    end

    local price = nil

    pcall(function()
        -- This follows the game's own seller logic:
        -- Save.Await() -> EggInventory[UID] -> EggRecords.Decode() -> EggRecords.SellPrice()
        local saveData = EggSave.Await()

        if type(saveData) ~= "table" or type(saveData.EggInventory) ~= "table" then
            return
        end

        local savedEgg = saveData.EggInventory[tostring(uid)]

        if type(savedEgg) ~= "table" or savedEgg.Placement ~= nil then
            return
        end

        local eggData = EggRecords.Decode(savedEgg)

        if eggData ~= nil then
            price = tonumber(EggRecords.SellPrice(eggData))

            if price and Player:GetAttribute("VIP") then
                price *= 2
            end
        end
    end)

    return price
end

local function ParseInventorySlot(slot)
    local fullText = SafeText(slot)
    local lowerText = Lower(fullText)

    local category = GetSlotCategory(slot, fullText)
    local isEgg = string.find(lowerText, "egg", 1, true) ~= nil

    local explicitType = Lower(GetAttribute(slot, {
        "ItemType",
        "Type",
        "Category"
    }))

    if explicitType ~= "" then
        if string.find(explicitType, "egg", 1, true) then
            isEgg = true
        end
    end

    local item = {
        uid = tostring(slot.Name),
        name = GetSlotName(slot, fullText, isEgg),
        category = category,
        weight = GetSlotWeight(slot, fullText),
        cash = nil,
        rate = nil,
        scale = tonumber(GetAttribute(slot, {"Scale", "AssetScale"})),
        mutations = GetSlotMutations(slot),
        favorite = GetSlotBoolean(slot, {"Favorite", "IsFavorite"}),
        equipped = GetSlotBoolean(slot, {"Equipped", "IsEquipped"})
    }

    if isEgg then
        -- Get the real sell value from the same EggRecords.SellPrice()
        -- calculation used by the game's Sell Shop.
        item.cash = GetEggSellPrice(slot.Name)

        -- Fallback to visible UI text if the saved egg data is not ready yet.
        if item.cash == nil then
            item.cash = GetSlotCash(slot, fullText)
        end
    else
        item.cash = GetSlotCash(slot, fullText)
        item.rate = GetSlotRate(slot, fullText)
    end

    return item, isEgg
end

--==============================================================--
-- DETAILED INVENTORY
--==============================================================--

local function GetDetailedInventory()
    local result = {
        pets = {},
        eggs = {},
        totalPets = 0,
        totalEggs = 0
    }

    local inventory = GetInventory()

    if not inventory then
        warn("Inventory UI is not loaded")
        return result
    end

    local seen = {}

    for _, slot in ipairs(inventory:GetDescendants()) do
        if IsInventorySlot(slot) then
            local item, isEgg = ParseInventorySlot(slot)

            local key = tostring(slot:GetFullName())

            if not seen[key] then
                seen[key] = true

                if isEgg then
                    table.insert(result.eggs, item)
                else
                    table.insert(result.pets, item)
                end
            end
        end
    end

    result.totalPets = #result.pets
    result.totalEggs = #result.eggs

    print(
        "INVENTORY SENT:",
        "Pets =", result.totalPets,
        "Eggs =", result.totalEggs
    )

    return result
end

--==============================================================--
-- EGG COUNT
--==============================================================--

local function GetEggIcons()
    local inventory = GetInventory()
    local eggIcons = {}

    if not inventory then
        return eggIcons
    end

    for _, slot in ipairs(inventory:GetDescendants()) do
        if IsInventorySlot(slot) then
            local text = Lower(SafeText(slot))

            if string.find(text, "egg", 1, true) then
                local icon = GetIcon(slot)

                if icon ~= "" then
                    eggIcons[icon] = true
                end
            end
        end
    end

    return eggIcons
end

local function CountMainEggs()
    local inventory = GetInventory()

    if not inventory then
        return 0
    end

    local count = 0

    for _, slot in ipairs(inventory:GetDescendants()) do
        if IsInventorySlot(slot) then
            local text = Lower(SafeText(slot))

            if string.find(text, "egg", 1, true) then
                count += 1
            end
        end
    end

    return count
end

local function CountHotbarEggs(eggIcons)
    local hotbar = GetHotbar()

    if not hotbar then
        return 0
    end

    local count = 0

    for number = 1, 10 do
        local slot = hotbar:FindFirstChild(tostring(number))

        if slot then
            local icon = GetIcon(slot)

            if icon ~= "" and eggIcons[icon] then
                count += 1
            end
        end
    end

    return count
end

local function GetTotalEggs()
    local eggIcons = GetEggIcons()
    local mainEggs = CountMainEggs()
    local hotbarEggs = CountHotbarEggs(eggIcons)

    return mainEggs + hotbarEggs
end

--==============================================================--
-- PLAYER STATS
--==============================================================--

local function GetPlayerStats()
    local money = nil
    local speed = nil
    local pets = nil

    local gui = Player:FindFirstChild("PlayerGui")

    if not gui then
        return nil, nil, nil
    end

    pcall(function()
        local hud = gui:FindFirstChild("HUD")
        local gameHUD = hud and hud:FindFirstChild("GameHUD")
        local bottomLeft = gameHUD and gameHUD:FindFirstChild("BottomLeft")
        local moneyUI = bottomLeft and bottomLeft:FindFirstChild("Money")
        local value = moneyUI and moneyUI:FindFirstChild("Value")

        if value and value:IsA("TextLabel") then
            money = value.Text
        end
    end)

    pcall(function()
        local hud = gui:FindFirstChild("HUD")
        local gameHUD = hud and hud:FindFirstChild("GameHUD")
        local bottomLeft = gameHUD and gameHUD:FindFirstChild("BottomLeft")
        local speedUI = bottomLeft and bottomLeft:FindFirstChild("Speed")
        local value = speedUI and speedUI:FindFirstChild("Value")

        if value and value:IsA("TextLabel") then
            speed = value.Text
        end
    end)

    pcall(function()
        local activePets = gui:FindFirstChild("ActivePets")
        local frame = activePets and activePets:FindFirstChild("Frame")
        local scrollingFrame = frame and frame:FindFirstChild("ScrollingFrame")

        if scrollingFrame then
            local count = 0

            for _, pet in ipairs(scrollingFrame:GetChildren()) do
                if pet:IsA("Frame")
                    and string.sub(pet.Name, 1, 4) == "Pet_" then

                    count += 1
                end
            end

            pets = count
        end
    end)

    CurrentMoney = money
    CurrentSpeed = speed
    CurrentPets = pets

    return money, speed, pets
end

--==============================================================--
-- HEARTBEAT
--==============================================================--

local function SendHeartbeat(eggCount)
    CurrentEggCount = tonumber(eggCount) or 0

    local money, _, pets = GetPlayerStats()

    local speed = nil

    pcall(function()
        local hud = PlayerGui:FindFirstChild("HUD")
        local gameHUD = hud and hud:FindFirstChild("GameHUD")
        local bottomLeft = gameHUD and gameHUD:FindFirstChild("BottomLeft")
        local speedUI = bottomLeft and bottomLeft:FindFirstChild("Speed")
        local value = speedUI and speedUI:FindFirstChild("Value")

        if value and value:IsA("TextLabel") then
            speed = value.Text
        end
    end)

    local data = {
        userId = tostring(Player.UserId),
        playerName = Player.Name,
        displayName = Player.DisplayName,

        eggs = CurrentEggCount,
        money = money,
        rate = speed,
        pets = pets,

        inventory = GetDetailedInventory(),

        timestamp = os.time()
    }

    print("SENDING MONEY:", money)
    print("SENDING SPEED:", speed)
    print("SENDING PETS:", pets)

    local success, result = SendMonitorRequest(data)

    if not success then
        warn("Monitor heartbeat failed:", result)
        return false
    end

    return true
end

--==============================================================--
-- GUI - MODERN EGG GAME STYLE
--==============================================================--

local old = PlayerGui:FindFirstChild("KyoshEggCounter")

if old then
    old:Destroy()
end

local TweenService = game:GetService("TweenService")

local Gui = Instance.new("ScreenGui")
Gui.Name = "KyoshEggCounter"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--==============================================================--
-- MAIN CONTAINER
--==============================================================--

local Frame = Instance.new("Frame")
Frame.Name = "EggCounter"
Frame.Size = UDim2.fromOffset(220, 125)
Frame.Position = UDim2.new(0.5, -110, 0, 70)
Frame.BackgroundColor3 = Color3.fromRGB(45, 105, 58)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = false
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 22)
Corner.Parent = Frame

-- Outer border
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(170, 235, 112)
Stroke.Thickness = 3
Stroke.Parent = Frame

--==============================================================--
-- BACKGROUND GRADIENT
--==============================================================--

local Gradient = Instance.new("UIGradient")
Gradient.Rotation = 90
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 155, 77)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(48, 115, 62)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 70, 43))
})
Gradient.Parent = Frame

--==============================================================--
-- SHADOW
--==============================================================--

local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.fromOffset(5, 8)
Shadow.BackgroundColor3 = Color3.fromRGB(10, 35, 15)
Shadow.BackgroundTransparency = 0.35
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = Frame

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 22)
ShadowCorner.Parent = Shadow

--==============================================================--
-- TOP GLOSS
--==============================================================--

local Gloss = Instance.new("Frame")
Gloss.Name = "Gloss"
Gloss.Size = UDim2.new(1, -12, 0, 34)
Gloss.Position = UDim2.fromOffset(6, 6)
Gloss.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Gloss.BackgroundTransparency = 0.88
Gloss.BorderSizePixel = 0
Gloss.ZIndex = 2
Gloss.Parent = Frame

local GlossCorner = Instance.new("UICorner")
GlossCorner.CornerRadius = UDim.new(0, 17)
GlossCorner.Parent = Gloss

--==============================================================--
-- EGG CIRCLE
--==============================================================--

local EggHolder = Instance.new("Frame")
EggHolder.Name = "EggHolder"
EggHolder.Size = UDim2.fromOffset(62, 62)
EggHolder.Position = UDim2.new(0, 12, 0.5, -31)
EggHolder.BackgroundColor3 = Color3.fromRGB(255, 213, 76)
EggHolder.BorderSizePixel = 0
EggHolder.ZIndex = 5
EggHolder.Parent = Frame

local EggHolderCorner = Instance.new("UICorner")
EggHolderCorner.CornerRadius = UDim.new(1, 0)
EggHolderCorner.Parent = EggHolder

local EggHolderStroke = Instance.new("UIStroke")
EggHolderStroke.Color = Color3.fromRGB(255, 241, 150)
EggHolderStroke.Thickness = 3
EggHolderStroke.Parent = EggHolder

-- Egg emoji
local Egg = Instance.new("TextLabel")
Egg.Name = "EggIcon"
Egg.Size = UDim2.fromScale(1, 1)
Egg.BackgroundTransparency = 1
Egg.Text = "🥚"
Egg.TextSize = 36
Egg.Font = Enum.Font.GothamBold
Egg.TextColor3 = Color3.fromRGB(255, 255, 255)
Egg.ZIndex = 6
Egg.Parent = EggHolder

--==============================================================--
-- TITLE
--==============================================================--

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.fromOffset(125, 28)
Title.Position = UDim2.fromOffset(82, 12)
Title.BackgroundTransparency = 1
Title.Text = "EGG COLLECTION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.ZIndex = 6
Title.Parent = Frame

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(22, 67, 30)
TitleStroke.Thickness = 2
TitleStroke.Parent = Title

--==============================================================--
-- COUNT
--==============================================================--

local Count = Instance.new("TextLabel")
Count.Name = "Count"
Count.Size = UDim2.fromOffset(125, 48)
Count.Position = UDim2.fromOffset(82, 40)
Count.BackgroundTransparency = 1
Count.Text = "0"
Count.TextColor3 = Color3.fromRGB(255, 241, 117)
Count.TextSize = 36
Count.Font = Enum.Font.GothamBlack
Count.TextXAlignment = Enum.TextXAlignment.Center
Count.TextYAlignment = Enum.TextYAlignment.Center
Count.ZIndex = 6
Count.Parent = Frame

local CountStroke = Instance.new("UIStroke")
CountStroke.Color = Color3.fromRGB(24, 72, 31)
CountStroke.Thickness = 3
CountStroke.Parent = Count

--==============================================================--
-- BOTTOM BADGE
--==============================================================--

local Badge = Instance.new("Frame")
Badge.Name = "Badge"
Badge.Size = UDim2.fromOffset(180, 23)
Badge.Position = UDim2.new(0.5, -90, 1, -29)
Badge.BackgroundColor3 = Color3.fromRGB(24, 70, 37)
Badge.BorderSizePixel = 0
Badge.ZIndex = 6
Badge.Parent = Frame

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(1, 0)
BadgeCorner.Parent = Badge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Color = Color3.fromRGB(115, 190, 90)
BadgeStroke.Thickness = 1
BadgeStroke.Transparency = 0.3
BadgeStroke.Parent = Badge

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.fromScale(1, 1)
Status.BackgroundTransparency = 1
Status.Text = "🥚  INVENTORY MONITOR"
Status.TextColor3 = Color3.fromRGB(220, 255, 205)
Status.TextSize = 10
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Center
Status.TextYAlignment = Enum.TextYAlignment.Center
Status.ZIndex = 7
Status.Parent = Badge

--==============================================================--
-- EGG FLOAT ANIMATION
--==============================================================--

task.spawn(function()
    while Gui.Parent do

        local up = TweenService:Create(
            EggHolder,
            TweenInfo.new(
                0.9,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.new(0, 12, 0.5, -35),
                Rotation = 4
            }
        )

        up:Play()
        up.Completed:Wait()

        local down = TweenService:Create(
            EggHolder,
            TweenInfo.new(
                0.9,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            ),
            {
                Position = UDim2.new(0, 12, 0.5, -27),
                Rotation = -4
            }
        )

        down:Play()
        down.Completed:Wait()
    end
end)

--==============================================================--
-- COUNT POP ANIMATION
--==============================================================--

local LastCount = 0

task.spawn(function()
    while Gui.Parent do
        task.wait(0.2)

        local current = tonumber(Count.Text) or 0

        if current ~= LastCount then
            LastCount = current

            Count.Size = UDim2.fromOffset(140, 55)
            Count.Position = UDim2.fromOffset(74, 37)

            local pop = TweenService:Create(
                Count,
                TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.fromOffset(125, 48),
                    Position = UDim2.fromOffset(82, 40)
                }
            )

            pop:Play()
        end
    end
end)

--==============================================================--
-- WAIT FOR INVENTORY
--==============================================================--

task.spawn(function()
    local inventory = nil
    local attempts = 0

    while Gui.Parent and not inventory and attempts < 120 do
        inventory = GetInventory()

        if not inventory then
            task.wait(0.25)
            attempts += 1
        end
    end

    if inventory then
        print("Inventory UI detected:", inventory:GetFullName())
    else
        warn("Inventory UI was not detected")
    end
end)

--==============================================================--
-- LIVE EGG COUNTER
--==============================================================--

task.spawn(function()
    while Gui.Parent do
        task.wait(INVENTORY_SCAN_INTERVAL)

        pcall(function()
            local total = GetTotalEggs()

            CurrentEggCount = total
            Count.Text = tostring(total)
        end)
    end
end)

--==============================================================--
-- FIRST HEARTBEAT
--==============================================================--

task.spawn(function()
    local inventory = nil
    local attempts = 0

    while not inventory and attempts < 80 do
        inventory = GetInventory()

        if not inventory then
            task.wait(0.25)
            attempts += 1
        end
    end

    task.wait(2)

    local total = GetTotalEggs()

    CurrentEggCount = total
    Count.Text = tostring(total)

    print("Initial egg count:", total)

    if SendHeartbeat(total) then
        print("Account monitor heartbeat started")
    end
end)

--==============================================================--
-- ACCOUNT HEARTBEAT LOOP
--==============================================================--

task.spawn(function()
    while Gui.Parent do
        task.wait(HEARTBEAT_INTERVAL)

        local success, total = pcall(function()
            return GetTotalEggs()
        end)

        if success and type(total) == "number" then
            CurrentEggCount = total
            Count.Text = tostring(total)

            SendHeartbeat(total)
        else
            SendHeartbeat(CurrentEggCount)
        end
    end
end)

print("KYOSH EGG COUNTER + ACCOUNT MONITOR LOADED")
print("Inventory source: PlayerGui > BackpackGui > Backpack > Main > Inventory")
print("Egg cash: disabled")
print("Heartbeat interval:", HEARTBEAT_INTERVAL, "seconds")
