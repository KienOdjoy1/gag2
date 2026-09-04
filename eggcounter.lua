--//============================================================//
--// 🥚 KYOSH EGG COUNTER
--//
--// MAIN INVENTORY + HOTBAR 1-10
--// FIXED HOTBAR DETECTION
--// + DISCORD SINGLE MESSAGE AUTO UPDATE
--// + LIVE UPDATES
--// + REJOIN INVENTORY LOAD FIX
--//============================================================//

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
--// DISCORD WEBHOOK
--------------------------------------------------

-- IMPORTANT:
-- Your old webhook was exposed. Create a NEW webhook
-- and paste it here.
local WEBHOOK_URL = "https://discord.com/api/webhooks/1543291508223123467/e-F7h7fpeNSvu75P6J7TQWtFyW7oTf2EW36YDpcjx18HIKh3Of3m_XqiavR4WC3rCQ2a"

--------------------------------------------------
--// SETTINGS
--------------------------------------------------

local DISCORD_UPDATE_INTERVAL = 10

-- How often the inventory is rescanned.
local INVENTORY_SCAN_INTERVAL = 0.5

--------------------------------------------------
--// HTTP REQUEST FUNCTION
--------------------------------------------------

local RequestFunction =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

--------------------------------------------------
--// VARIABLES
--------------------------------------------------

local DiscordMessageID = nil
local CurrentEggCount = 0

--------------------------------------------------
--// REMOVE OLD GUI
--------------------------------------------------

local old = PlayerGui:FindFirstChild("KyoshEggCounter")

if old then
    old:Destroy()
end

--------------------------------------------------
--// GUI
--------------------------------------------------

local Gui = Instance.new("ScreenGui")

Gui.Name = "KyoshEggCounter"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--------------------------------------------------
--// FRAME
--------------------------------------------------

local Frame = Instance.new("Frame")

Frame.Size = UDim2.fromOffset(150, 80)
Frame.Position = UDim2.new(0.5, -75, 0, 80)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.BackgroundTransparency = 0.05
Frame.BorderSizePixel = 0
Frame.Parent = Gui

local Corner = Instance.new("UICorner")

Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

--------------------------------------------------
--// TITLE
--------------------------------------------------

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1, 0, 0, 32)
Title.Position = UDim2.fromOffset(0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🥚 EGGS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

--------------------------------------------------
--// COUNT
--------------------------------------------------

local Count = Instance.new("TextLabel")

Count.Size = UDim2.new(1, 0, 0, 40)
Count.Position = UDim2.fromOffset(0, 35)
Count.BackgroundTransparency = 1
Count.Text = "0"
Count.TextColor3 = Color3.fromRGB(255, 255, 255)
Count.TextSize = 28
Count.Font = Enum.Font.GothamBold
Count.Parent = Frame

--------------------------------------------------
--// GET INVENTORY
--------------------------------------------------

local function GetInventory()

    local BackpackGui =
        PlayerGui:FindFirstChild("BackpackGui")

    if not BackpackGui then
        return nil
    end

    local Backpack =
        BackpackGui:FindFirstChild("Backpack")

    if not Backpack then
        return nil
    end

    local Main =
        Backpack:FindFirstChild("Main")

    if not Main then
        return nil
    end

    return Main:FindFirstChild("Inventory")
end

--------------------------------------------------
--// GET HOTBAR
--------------------------------------------------

local function GetHotbar()

    local BackpackGui =
        PlayerGui:FindFirstChild("BackpackGui")

    if not BackpackGui then
        return nil
    end

    local Backpack =
        BackpackGui:FindFirstChild("Backpack")

    if not Backpack then
        return nil
    end

    return Backpack:FindFirstChild("Hotbar")
end

--------------------------------------------------
--// GET SLOT TEXT
--------------------------------------------------

local function GetText(Object)

    local Text = ""

    if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

        Text = Object.Text or ""
    end

    for _, Child in ipairs(Object:GetDescendants()) do

        if Child:IsA("TextLabel")
            or Child:IsA("TextButton")
            or Child:IsA("TextBox") then

            if Child.Text and Child.Text ~= "" then

                Text =
                    Text
                    .. " "
                    .. Child.Text
            end
        end
    end

    return string.lower(Text)
end

--------------------------------------------------
--// GET ONLY REAL ICON
--------------------------------------------------

local function GetIcon(Object)

    local Icon =
        Object:FindFirstChild("Icon")

    if Icon
        and (
            Icon:IsA("ImageLabel")
            or Icon:IsA("ImageButton")
        ) then

        return Icon.Image or ""
    end

    return ""
end

--------------------------------------------------
--// FIND ALL EGG ICONS
--------------------------------------------------

local function GetEggIcons()

    local Inventory =
        GetInventory()

    local EggIcons = {}

    if not Inventory then
        return EggIcons
    end

    for _, Slot in ipairs(
        Inventory:GetDescendants()
    ) do

        if Slot:IsA("TextButton") then

            local SlotNumber =
                tonumber(Slot.Name)

            if SlotNumber then

                local Text =
                    GetText(Slot)

                if string.find(
                    Text,
                    "egg",
                    1,
                    true
                ) then

                    local IconImage =
                        GetIcon(Slot)

                    if IconImage ~= "" then

                        EggIcons[IconImage] = true
                    end
                end
            end
        end
    end

    return EggIcons
end

--------------------------------------------------
--// COUNT MAIN INVENTORY EGGS
--------------------------------------------------

local function CountMainEggs()

    local Inventory =
        GetInventory()

    if not Inventory then
        return 0
    end

    local EggCount = 0

    for _, Slot in ipairs(
        Inventory:GetDescendants()
    ) do

        if Slot:IsA("TextButton") then

            local SlotNumber =
                tonumber(Slot.Name)

            if SlotNumber then

                local Text =
                    GetText(Slot)

                if string.find(
                    Text,
                    "egg",
                    1,
                    true
                ) then

                    EggCount += 1
                end
            end
        end
    end

    return EggCount
end

--------------------------------------------------
--// COUNT HOTBAR EGGS
--------------------------------------------------

local function CountHotbarEggs(EggIcons)

    local Hotbar =
        GetHotbar()

    if not Hotbar then
        return 0
    end

    local EggCount = 0

    --------------------------------------------------
    --// ONLY DIRECT HOTBAR SLOTS 1-10
    --------------------------------------------------

    for Number = 1, 10 do

        local Slot =
            Hotbar:FindFirstChild(
                tostring(Number)
            )

        if Slot then

            local IconImage =
                GetIcon(Slot)

            if IconImage ~= ""
                and EggIcons[IconImage] then

                EggCount += 1
            end
        end
    end

    return EggCount
end

--------------------------------------------------
--// GET TOTAL EGGS
--------------------------------------------------

local function GetTotalEggs()

    local EggIcons =
        GetEggIcons()

    local MainEggs =
        CountMainEggs()

    local HotbarEggs =
        CountHotbarEggs(EggIcons)

    return MainEggs + HotbarEggs
end

--------------------------------------------------
--// CREATE DISCORD EMBED
--------------------------------------------------

local function CreateDiscordData(EggCount)

    return {

        username = "KYOSH Egg Counter",

        embeds = {{

            title =
                "🥚 KYOSH EGG COUNTER",

            description =
                "Latest egg inventory status.",

            color = 0x9B59B6,

            fields = {

                {
                    name = "🥚 Egg Count",

                    value =
                        "**"
                        .. tostring(EggCount)
                        .. "**",

                    inline = true
                },

                {
                    name = "👤 Player",

                    value =
                        Player.Name,

                    inline = true
                },

                {
                    name = "📦 Source",

                    value =
                        "Main Inventory",

                    inline = false
                },

                {
                    name = "🔄 Update",

                    value =
                        "**LIVE**",

                    inline = false
                }
            },

            footer = {

                text =
                    "KYOSH Egg Counter • Live Status"
            },

            timestamp =
                DateTime.now():ToIsoDate()
        }}
    }
end

--------------------------------------------------
--// REQUEST HELPER
--------------------------------------------------

local function SendRequest(Options)

    if not RequestFunction then

        return false,
            "HTTP request function unavailable"
    end

    local Success, Result =
        pcall(function()

            return RequestFunction(Options)

        end)

    if not Success then

        return false, Result
    end

    return true, Result
end

--------------------------------------------------
--// CREATE FIRST DISCORD MESSAGE
--------------------------------------------------

local function CreateDiscordMessage(EggCount)

    if WEBHOOK_URL == ""
        or WEBHOOK_URL ==
            "PASTE_YOUR_NEW_WEBHOOK_HERE" then

        warn(
            "❌ Discord webhook URL is not configured"
        )

        return false
    end

    local Data =
        CreateDiscordData(EggCount)

    local CreateURL =
        WEBHOOK_URL

    if not string.find(
        CreateURL,
        "?",
        1,
        true
    ) then

        CreateURL =
            CreateURL
            .. "?wait=true"

    else

        CreateURL =
            CreateURL
            .. "&wait=true"
    end

    local Success, Result =
        SendRequest({

            Url = CreateURL,

            Method = "POST",

            Headers = {

                ["Content-Type"] =
                    "application/json"
            },

            Body =
                HttpService:JSONEncode(
                    Data
                )
        })

    if not Success then

        warn(
            "❌ Discord create failed:",
            Result
        )

        return false
    end

    --------------------------------------------------
    --// READ RESPONSE
    --------------------------------------------------

    local Body = nil

    if type(Result) == "table" then

        Body =
            Result.Body
            or Result.body
    end

    if Body and Body ~= "" then

        local DecodeSuccess, Decoded =
            pcall(function()

                return HttpService:JSONDecode(
                    Body
                )

            end)

        if DecodeSuccess
            and Decoded
            and Decoded.id then

            DiscordMessageID =
                tostring(
                    Decoded.id
                )

            print(
                "✅ Discord message created | ID:",
                DiscordMessageID
            )

            return true
        end
    end

    warn(
        "⚠️ Discord message sent, but message ID was not returned"
    )

    return false
end

--------------------------------------------------
--// UPDATE EXISTING DISCORD MESSAGE
--------------------------------------------------

local function UpdateDiscordMessage(EggCount)

    if not DiscordMessageID then

        warn(
            "⚠️ No Discord message ID"
        )

        return false
    end

    local Data =
        CreateDiscordData(EggCount)

    local EditURL =
        WEBHOOK_URL
        .. "/messages/"
        .. tostring(
            DiscordMessageID
        )

    local Success, Result =
        SendRequest({

            Url = EditURL,

            Method = "PATCH",

            Headers = {

                ["Content-Type"] =
                    "application/json"
            },

            Body =
                HttpService:JSONEncode(
                    Data
                )
        })

    if not Success then

        warn(
            "❌ Discord update failed:",
            Result
        )

        return false
    end

    print(
        "🔄 Discord message updated | Eggs:",
        EggCount
    )

    return true
end

--------------------------------------------------
--// UPDATE GUI
--------------------------------------------------

local function UpdateGUI()

    local Total =
        GetTotalEggs()

    CurrentEggCount =
        Total

    Count.Text =
        tostring(Total)

    return Total
end

--------------------------------------------------
--// IMPORTANT:
--// WAIT UNTIL INVENTORY UI REALLY EXISTS
--------------------------------------------------

task.spawn(function()

    local Inventory = nil
    local Attempts = 0

    while Gui.Parent
        and not Inventory
        and Attempts < 120 do

        Inventory =
            GetInventory()

        if not Inventory then

            task.wait(0.25)

            Attempts += 1

        end
    end

    if Inventory then

        print(
            "✅ Inventory UI detected:",
            Inventory:GetFullName()
        )

    else

        warn(
            "⚠️ Inventory UI was not detected"
        )
    end
end)

--------------------------------------------------
--// REJOIN / INVENTORY LOAD SCANNER
--------------------------------------------------
--//
--// This does NOT stop after the first non-zero
--// count.
--//
--// It continuously rescans while the inventory
--// is being populated after joining.
--------------------------------------------------

task.spawn(function()

    local LastCount = -1
    local StableScans = 0

    while Gui.Parent do

        task.wait(
            INVENTORY_SCAN_INTERVAL
        )

        local Success, Total =
            pcall(function()

                return GetTotalEggs()

            end)

        if Success and type(Total) == "number" then

            CurrentEggCount =
                Total

            Count.Text =
                tostring(Total)

            --------------------------------------------------
            --// Detect inventory changes
            --------------------------------------------------

            if Total ~= LastCount then

                print(
                    "🥚 Inventory changed:",
                    LastCount,
                    "→",
                    Total
                )

                LastCount =
                    Total

                StableScans = 0

            else

                StableScans += 1
            end

        end
    end
end)

--------------------------------------------------
--// EXTRA INITIAL LOAD RESCAN
--------------------------------------------------
--//
--// After joining, the UI can populate gradually.
--// Rescan for 15 seconds instead of stopping at
--// the first egg count.
--------------------------------------------------

task.spawn(function()

    local StartTime =
        os.clock()

    while Gui.Parent
        and os.clock() - StartTime < 15 do

        task.wait(0.25)

        pcall(function()

            UpdateGUI()

        end)
    end
end)

--------------------------------------------------
--// CREATE DISCORD MESSAGE
--------------------------------------------------

task.spawn(function()

    --------------------------------------------------
    --// WAIT FOR INVENTORY TO LOAD
    --------------------------------------------------

    local Inventory = nil

    local Attempts = 0

    while not Inventory
        and Attempts < 80 do

        Inventory =
            GetInventory()

        if not Inventory then

            task.wait(0.25)

            Attempts += 1

        end
    end

    --------------------------------------------------
    --// GIVE THE GAME TIME TO POPULATE SLOTS
    --------------------------------------------------

    task.wait(2)

    --------------------------------------------------
    --// FINAL INITIAL SCAN
    --------------------------------------------------

    local Total =
        GetTotalEggs()

    CurrentEggCount =
        Total

    Count.Text =
        tostring(Total)

    print(
        "📦 Initial egg count:",
        Total
    )

    --------------------------------------------------
    --// CREATE ONE MESSAGE
    --------------------------------------------------

    local Created =
        CreateDiscordMessage(
            Total
        )

    if Created then

        print(
            "📡 Single Discord status message active"
        )

    else

        warn(
            "❌ Could not create Discord status message"
        )
    end
end)

--------------------------------------------------
--// LIVE GUI UPDATE
--------------------------------------------------

task.spawn(function()

    while Gui.Parent do

        task.wait(0.25)

        pcall(function()

            UpdateGUI()

        end)
    end
end)

--------------------------------------------------
--// DISCORD LIVE UPDATE
--------------------------------------------------

task.spawn(function()

    --------------------------------------------------
    --// WAIT FOR MESSAGE CREATION
    --------------------------------------------------

    local Timeout = 0

    while Gui.Parent
        and not DiscordMessageID
        and Timeout < 120 do

        task.wait(1)

        Timeout += 1
    end

    if not DiscordMessageID then

        warn(
            "❌ Discord message ID was never received"
        )

        return
    end

    --------------------------------------------------
    --// UPDATE SAME MESSAGE FOREVER
    --------------------------------------------------

    while Gui.Parent do

        task.wait(
            DISCORD_UPDATE_INTERVAL
        )

        local Success, Total =
            pcall(function()

                return GetTotalEggs()

            end)

        if Success then

            CurrentEggCount =
                Total

            Count.Text =
                tostring(Total)

            UpdateDiscordMessage(
                Total
            )
        end
    end
end)

--------------------------------------------------
--// LOADED
--------------------------------------------------

print(
    "🥚 KYOSH EGG COUNTER LOADED"
)

print(
    "📦 Inventory + Hotbar 1-10"
)

print(
    "🔄 Rejoin Inventory Scanner ENABLED"
)

print(
    "📡 Discord Single Message Mode"
)

print(
    "🔄 Live Discord Updates"
)

print(
    "⏱️ Discord Update Interval: 10 Seconds"
)
