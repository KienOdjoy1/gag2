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
--------------------------------------------------
--// 🥚 KYOSH EGG + ACCOUNT MONITOR
--// Sends heartbeat + egg count to ONE monitor server.
--// The monitor server keeps ONE Discord message.
--------------------------------------------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
--// MONITOR SERVER SETTINGS
--------------------------------------------------

-- Put your PUBLIC monitor-server URL here.
-- Example: https://your-server.example.com
local MONITOR_URL = "https://gag2-1.onrender.com"

-- Must match API_KEY in monitor_server.py
local MONITOR_API_KEY = "KYOSH-12162006"

local HEARTBEAT_INTERVAL = 10
local INVENTORY_SCAN_INTERVAL = 0.5

--------------------------------------------------
--// HTTP REQUEST FUNCTION
--------------------------------------------------

local RequestFunction =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

local function SendMonitorRequest(Data)
    if not RequestFunction then
        warn("❌ HTTP request function unavailable")
        return false, "No request function"
    end

    if MONITOR_URL == ""
        or MONITOR_URL == "PASTE_YOUR_MONITOR_URL_HERE" then
        warn("❌ MONITOR_URL is not configured")
        return false, "No monitor URL"
    end

    local Success, Result = pcall(function()
        return RequestFunction({
            Url = MONITOR_URL .. "/heartbeat",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-API-Key"] = MONITOR_API_KEY
            },
            Body = HttpService:JSONEncode(Data)
        })
    end)

    if not Success then
        return false, Result
    end

    return true, Result
end

--------------------------------------------------
--// MONITOR STATE
--------------------------------------------------

local CurrentEggCount = 0

local function SendHeartbeat(EggCount)
    CurrentEggCount = tonumber(EggCount) or 0

    local Success, Result = SendMonitorRequest({
        userId = tostring(Player.UserId),
        playerName = Player.Name,
        displayName = Player.DisplayName,
        eggs = CurrentEggCount,
        timestamp = os.time()
    })

    if not Success then
        warn("⚠️ Monitor heartbeat failed:", Result)
        return false
    end

    return true
end
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
--------------------------------------------------
--// UPDATE GUI
--------------------------------------------------

local function UpdateGUI()
    local Total = GetTotalEggs()

    CurrentEggCount = Total
    Count.Text = tostring(Total)

    return Total
end

--------------------------------------------------
--// INVENTORY UI DETECTION
--------------------------------------------------

task.spawn(function()
    local Inventory = nil
    local Attempts = 0

    while Gui.Parent
        and not Inventory
        and Attempts < 120 do

        Inventory = GetInventory()

        if not Inventory then
            task.wait(0.25)
            Attempts += 1
        end
    end

    if Inventory then
        print("✅ Inventory UI detected:", Inventory:GetFullName())
    else
        warn("⚠️ Inventory UI was not detected")
    end
end)

--------------------------------------------------
--// REJOIN / INVENTORY LOAD SCANNER
--------------------------------------------------

task.spawn(function()
    local LastCount = -1
    local StableScans = 0

    while Gui.Parent do
        task.wait(INVENTORY_SCAN_INTERVAL)

        local Success, Total = pcall(function()
            return GetTotalEggs()
        end)

        if Success and type(Total) == "number" then
            CurrentEggCount = Total
            Count.Text = tostring(Total)

            if Total ~= LastCount then
                print("🥚 Inventory changed:", LastCount, "→", Total)
                LastCount = Total
                StableScans = 0
            else
                StableScans += 1
            end
        end
    end
end)

--------------------------------------------------
--// INITIAL LOAD + FIRST HEARTBEAT
--------------------------------------------------

task.spawn(function()
    local Inventory = nil
    local Attempts = 0

    while not Inventory and Attempts < 80 do
        Inventory = GetInventory()

        if not Inventory then
            task.wait(0.25)
            Attempts += 1
        end
    end

    task.wait(2)

    local Total = GetTotalEggs()

    CurrentEggCount = Total
    Count.Text = tostring(Total)

    print("📦 Initial egg count:", Total)

    if SendHeartbeat(Total) then
        print("📡 Account monitor heartbeat started")
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
--// ACCOUNT HEARTBEAT
--------------------------------------------------

task.spawn(function()
    while Gui.Parent do
        task.wait(HEARTBEAT_INTERVAL)

        local Success, Total = pcall(function()
            return GetTotalEggs()
        end)

        if Success and type(Total) == "number" then
            CurrentEggCount = Total
            Count.Text = tostring(Total)
            SendHeartbeat(Total)
        else
            -- Still send a heartbeat using the last known count.
            SendHeartbeat(CurrentEggCount)
        end
    end
end)

--------------------------------------------------
--// LOADED
--------------------------------------------------

print("🥚 KYOSH EGG COUNTER + ACCOUNT MONITOR LOADED")
print("📦 Inventory + Hotbar 1-10")
print("🟢 Heartbeat interval:", HEARTBEAT_INTERVAL, "seconds")
print("📡 Discord is handled by the external monitor server")
