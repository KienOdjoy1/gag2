--============================================================--
-- KYOSH // GHOUL GARDEN
-- MOBILE + PC RESPONSIVE
--
-- 🌱 SEED SHOP
-- ⚙ GEAR SHOP
-- 🧪 CAULDRON AUTO BREW
-- ⚙ CONFIG MANAGER
--============================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--============================================================--
-- SETTINGS
--============================================================--

local SETTINGS = {
    PurchaseDelay = 0.35,
    CycleDelay = 1,

    BrewCheckDelay = 1,
    BrewErrorDelay = 2,
}

local CONFIG_FOLDER = "KYOSH"
local CONFIG_FILE = CONFIG_FOLDER .. "/GhoulGardenConfigs.json"

--============================================================--
-- GAME FOLDERS
--============================================================--

local StockValues =
    ReplicatedStorage:WaitForChild("StockValues")

local SeedShop =
    StockValues:WaitForChild("SeedShop")

local GearShop =
    StockValues:WaitForChild("GearShop")

local SeedItemsFolder =
    SeedShop:WaitForChild("Items")

local GearItemsFolder =
    GearShop:WaitForChild("Items")

--============================================================--
-- PACKET
--============================================================--

local Packet = require(
    ReplicatedStorage
        :WaitForChild("SharedModules")
        :WaitForChild("Packet")
)

--============================================================--
-- GAME NETWORKING
--============================================================--

local Networking = require(
    ReplicatedStorage
        :WaitForChild("SharedModules")
        :WaitForChild("Networking")
)

--============================================================--
-- SHOP PACKETS
--============================================================--

local PurchaseSeed =
    Packet(
        "PurchaseSeed",
        Packet.String
    )

local PurchaseGear =
    Packet(
        "PurchaseGear",
        Packet.String
    )

--============================================================--
-- MONSTER PACKET
--============================================================--
-- The game exposes the player monster-hit packet as an Any payload.
-- The Auto Kill system keeps the targeting logic separate from Auto Brew.
-- Server-side validation still decides whether a hit is accepted.
--============================================================--

local HitMonsterFromClientToServer =
    Packet(
        "HitMonsterFromClientToServer",
        Packet.Any
    )

--============================================================--
-- CAULDRON MODULE
--============================================================--

local CauldronRecipes = require(
    ReplicatedStorage
        :WaitForChild("SharedModules")
        :WaitForChild("CauldronRecipes")
)

--============================================================--
-- CAULDRON PACKETS
--
-- IMPORTANT:
-- These are RESPONSE packets.
-- The game's Packet module uses :Fire() and returns
-- the response from the server.
--============================================================--

local CauldronRequest =
    Packet("CauldronRequest")
        :Response(Packet.Any)

local CauldronStartBrew =
    Packet("CauldronStartBrew", Packet.String)
        :Response(
            Packet.Boolean8,
            Packet.String
        )

local CauldronReveal =
    Packet("CauldronReveal")
        :Response(
            Packet.Boolean8,
            Packet.String,
            Packet.Boolean8,
            Packet.String,
            Packet.NumberF64
        )

local CauldronSaveCraft =
    Packet("CauldronSaveCraft")
        :Response(
            Packet.Boolean8,
            Packet.String,
            Packet.String,
            Packet.NumberF64
        )

--============================================================--
-- STATE
--============================================================--

local CurrentTab = "Seeds"

local SelectedSeeds = {}
local SelectedGears = {}

local SeedSearch = ""
local GearSearch = ""
local RecipeSearch = ""

local AutoBuy = false
local AutoBuyMode = "ALL"
local AutoBuyThread = nil

local AutoBrew = false
local AutoBrewThread = nil

local AutoKill = false
local AutoKillThread = nil
local AutoKillMode = "ALL"
local SelectedMonsters = {}
local AutoKillWalkSpeed = 35
local AutoKillOriginalWalkSpeed = nil
local AutoKillShovel = nil
local AutoKillPumpkinTarget = nil

local AutoSaveFailedCraft = false

local SelectedRecipe = nil

local Destroyed = false

local Configs = {}
local SelectedConfigName = nil
local AutoLoadEnabled = false

--============================================================--
-- FILE SYSTEM
--============================================================--

local FileSystemAvailable =
    type(isfile) == "function"
    and type(readfile) == "function"
    and type(writefile) == "function"

local function ensureConfigFolder()

    if not FileSystemAvailable then
        return false
    end

    if type(isfolder) == "function"
        and type(makefolder) == "function" then

        if not isfolder(CONFIG_FOLDER) then

            pcall(function()
                makefolder(CONFIG_FOLDER)
            end)

        end
    end

    return true
end

local function loadConfigFile()

    if not ensureConfigFolder() then
        return {}
    end

    if not isfile(CONFIG_FILE) then
        return {}
    end

    local Success, Result =
        pcall(function()

            local Data = readfile(CONFIG_FILE)

            if not Data or Data == "" then
                return {}
            end

            return HttpService:JSONDecode(Data)

        end)

    if Success and type(Result) == "table" then
        return Result
    end

    return {}
end

local function saveConfigFile()

    if not ensureConfigFolder() then
        return false
    end

    local Success =
        pcall(function()

            writefile(
                CONFIG_FILE,
                HttpService:JSONEncode(Configs)
            )

        end)

    return Success
end

Configs = loadConfigFile()

--============================================================--
-- CLIPBOARD
--============================================================--

local function copyText(Text)

    if type(setclipboard) == "function" then

        local Success =
            pcall(function()
                setclipboard(Text)
            end)

        if Success then
            return true
        end

    end

    if type(toclipboard) == "function" then

        local Success =
            pcall(function()
                toclipboard(Text)
            end)

        if Success then
            return true
        end

    end

    return false
end

--============================================================--
-- GENERAL HELPERS
--============================================================--

local function getItems(Folder)

    local Items = {}

    for _, Object in ipairs(Folder:GetChildren()) do

        if Object.Name
            and Object.Name ~= "" then

            table.insert(
                Items,
                Object.Name
            )

        end

    end

    table.sort(
        Items,
        function(A, B)

            return string.lower(A)
                < string.lower(B)

        end
    )

    return Items
end

local function matchesSearch(Name, Search)

    if Search == "" then
        return true
    end

    return string.find(
        string.lower(Name),
        string.lower(Search),
        1,
        true
    ) ~= nil
end

local function countSelected(Selection)

    local Count = 0

    for _, Selected in pairs(Selection) do

        if Selected then
            Count += 1
        end

    end

    return Count
end

--============================================================--
-- GET RECIPES
--============================================================--

local function getCauldronRecipes()

    local Recipes = {}

    local Success, Result =
        pcall(function()

            return CauldronRecipes.ResolveAll()

        end)

    if not Success
        or type(Result) ~= "table" then

        return Recipes
    end

    for _, Recipe in ipairs(Result) do

        if type(Recipe) == "table"
            and type(Recipe.Name) == "string"
            and Recipe.Name ~= "" then

            table.insert(
                Recipes,
                Recipe
            )

        end

    end

    table.sort(
        Recipes,
        function(A, B)

            if tonumber(A.DurationSeconds)
                ~= tonumber(B.DurationSeconds) then

                return
                    (tonumber(A.DurationSeconds) or 0)
                    <
                    (tonumber(B.DurationSeconds) or 0)

            end

            return string.lower(A.Name)
                <
                string.lower(B.Name)

        end
    )

    return Recipes
end

local function getRecipeByName(Name)

    if type(Name) ~= "string" then
        return nil
    end

    for _, Recipe in ipairs(
        getCauldronRecipes()
    ) do

        if Recipe.Name == Name then
            return Recipe
        end

    end

    return nil
end

--============================================================--
-- CAULDRON STATE
--============================================================--

local function normalizeCauldronState(Result)

    if type(Result) ~= "table" then
        return nil
    end

    -- Some implementations may wrap state.
    if type(Result.State) == "table" then
        return Result.State
    end

    if type(Result.Brew) == "table" then
        return Result.Brew
    end

    return Result
end

local function getCauldronState()

    local Success, Result =
        pcall(function()

            return CauldronRequest:Fire()

        end)

    if not Success then

        warn(
            "[KYOSH] CauldronRequest failed:",
            Result
        )

        return nil
    end

    return normalizeCauldronState(Result)
end

local function getCauldronStateName(State)

    if type(State) ~= "table" then
        return "Unknown"
    end

    local Now =
        workspace:GetServerTimeNow()

    local Recipe =
        type(State.Recipe) == "string"
        and State.Recipe
        or ""

    local FinishesAt =
        tonumber(State.FinishesAt) or 0

    local RevealedAt =
        tonumber(State.RevealedAt) or 0

    local Failed =
        State.Failed == true

    if Recipe == ""
        or FinishesAt <= 0 then

        return "Empty"
    end

    if RevealedAt <= 0 then

        if Now < FinishesAt then
            return "Brewing"
        end

        return "Ready"
    end

    if Failed then
        return "Saving"
    end

    return "Empty"
end

--============================================================--
-- DESTROY EXISTING GUI
--============================================================--

local ExistingGui =
    PlayerGui:FindFirstChild(
        "KYOSH_GhoulGarden"
    )

if ExistingGui then
    ExistingGui:Destroy()
end

--============================================================--
-- SCREEN GUI
--============================================================--

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "KYOSH_GhoulGarden"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.IgnoreGuiInset =
    false

ScreenGui.Parent =
    PlayerGui

--============================================================--
-- RESPONSIVE SCALE
--============================================================--

local MainScale =
    Instance.new("UIScale")

MainScale.Name =
    "ResponsiveScale"

MainScale.Parent =
    ScreenGui

local function updateScale()

    if Destroyed then
        return
    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    local Viewport =
        Camera.ViewportSize

    local Width =
        Viewport.X

    local Height =
        Viewport.Y

    local WidthScale =
        Width / 390

    local HeightScale =
        Height / 700

    local Scale =
        math.min(
            WidthScale,
            HeightScale
        )

    Scale =
        math.clamp(
            Scale,
            0.68,
            1.15
        )

    if Width >= 800 then
        Scale = 1
    end

    MainScale.Scale =
        Scale
end

--============================================================--
-- MAIN FRAME
--============================================================--

local Main =
    Instance.new("Frame")

Main.Name = "Main"

Main.Size =
    UDim2.fromOffset(
        350,
        535
    )

Main.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Main.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        18,
        18,
        23
    )

Main.BorderSizePixel =
    0

Main.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

MainCorner.Parent =
    Main

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Color =
    Color3.fromRGB(
        110,
        80,
        255
    )

MainStroke.Thickness =
    1.5

MainStroke.Parent =
    Main

--============================================================--
-- TOP BAR
--============================================================--

local TopBar =
    Instance.new("Frame")

TopBar.Size =
    UDim2.new(
        1,
        0,
        0,
        42
    )

TopBar.BackgroundColor3 =
    Color3.fromRGB(
        25,
        24,
        33
    )

TopBar.BorderSizePixel =
    0

TopBar.Parent =
    Main

local TopCorner =
    Instance.new("UICorner")

TopCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

TopCorner.Parent =
    TopBar

local Title =
    Instance.new("TextLabel")

Title.BackgroundTransparency =
    1

Title.Position =
    UDim2.fromOffset(
        12,
        3
    )

Title.Size =
    UDim2.new(
        1,
        -100,
        0,
        20
    )

Title.Font =
    Enum.Font.GothamBold

Title.Text =
    "KYOSH // GHOUL GARDEN"

Title.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        255
    )

Title.TextSize =
    14

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    TopBar

local Status =
    Instance.new("TextLabel")

Status.BackgroundTransparency =
    1

Status.Position =
    UDim2.fromOffset(
        12,
        23
    )

Status.Size =
    UDim2.new(
        1,
        -100,
        0,
        14
    )

Status.Font =
    Enum.Font.Gotham

Status.Text =
    "Ready"

Status.TextColor3 =
    Color3.fromRGB(
        145,
        145,
        160
    )

Status.TextSize =
    10

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent =
    TopBar

--============================================================--
-- CONFIG BUTTON
--============================================================--

local ConfigButton =
    Instance.new("TextButton")

ConfigButton.Size =
    UDim2.fromOffset(
        32,
        30
    )

ConfigButton.Position =
    UDim2.new(
        1,
        -72,
        0,
        6
    )

ConfigButton.BackgroundColor3 =
    Color3.fromRGB(
        45,
        40,
        65
    )

ConfigButton.BorderSizePixel =
    0

ConfigButton.Text =
    "⚙"

ConfigButton.TextColor3 =
    Color3.fromRGB(
        205,
        190,
        255
    )

ConfigButton.TextSize =
    17

ConfigButton.Font =
    Enum.Font.GothamBold

ConfigButton.Parent =
    TopBar

local ConfigButtonCorner =
    Instance.new("UICorner")

ConfigButtonCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ConfigButtonCorner.Parent =
    ConfigButton

--============================================================--
-- CLOSE BUTTON
--============================================================--

local CloseButton =
    Instance.new("TextButton")

CloseButton.Size =
    UDim2.fromOffset(
        30,
        30
    )

CloseButton.Position =
    UDim2.new(
        1,
        -35,
        0,
        6
    )

CloseButton.BackgroundColor3 =
    Color3.fromRGB(
        45,
        35,
        45
    )

CloseButton.BorderSizePixel =
    0

CloseButton.Text =
    "×"

CloseButton.TextColor3 =
    Color3.fromRGB(
        255,
        120,
        140
    )

CloseButton.TextSize =
    20

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Parent =
    TopBar

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

CloseCorner.Parent =
    CloseButton

--============================================================--
-- DRAGGING MAIN
--============================================================--

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(
    function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1
            or Input.UserInputType
            == Enum.UserInputType.Touch then

            Dragging = true

            DragStart =
                Input.Position

            StartPosition =
                Main.Position

            Input.Changed:Connect(
                function()

                    if Input.UserInputState
                        == Enum.UserInputState.End then

                        Dragging = false

                    end

                end
            )

        end

    end
)

UserInputService.InputChanged:Connect(
    function(Input)

        if not Dragging then
            return
        end

        if Input.UserInputType
            ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType
            ~= Enum.UserInputType.Touch then

            return
        end

        local Delta =
            Input.Position
            - DragStart

        Main.Position =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset
                    + Delta.X,

                StartPosition.Y.Scale,
                StartPosition.Y.Offset
                    + Delta.Y
            )

    end
)

--============================================================--
-- TABS
--============================================================--

local Tabs =
    Instance.new("Frame")

Tabs.BackgroundTransparency =
    1

Tabs.Position =
    UDim2.fromOffset(
        10,
        50
    )

Tabs.Size =
    UDim2.new(
        1,
        -20,
        0,
        35
    )

Tabs.Parent =
    Main

local function createTab(
    Text,
    Position,
    Width
)

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            Width,
            -4,
            1,
            0
        )

    Button.Position =
        Position

    Button.BackgroundColor3 =
        Color3.fromRGB(
            35,
            34,
            45
        )

    Button.BorderSizePixel =
        0

    Button.Text =
        Text

    Button.TextColor3 =
        Color3.new(
            1,
            1,
            1
        )

    Button.TextSize =
        11

    Button.Font =
        Enum.Font.GothamBold

    Button.Parent =
        Tabs

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    return Button
end

local SeedTab =
    createTab(
        "🌱 SEEDS",
        UDim2.fromScale(
            0,
            0
        ),
        0.25
    )

local GearTab =
    createTab(
        "⚙ GEAR",
        UDim2.fromScale(
            0.25,
            0
        ),
        0.25
    )

local BrewTab =
    createTab(
        "🧪 BREW",
        UDim2.fromScale(
            0.50,
            0
        ),
        0.25
    )

local KillTab =
    createTab(
        "👹 KILL",
        UDim2.fromScale(
            0.75,
            0
        ),
        0.25
    )

--============================================================--
-- SEARCH
--============================================================--

local SearchBox =
    Instance.new("TextBox")

SearchBox.Position =
    UDim2.fromOffset(
        10,
        92
    )

SearchBox.Size =
    UDim2.new(
        1,
        -20,
        0,
        34
    )

SearchBox.BackgroundColor3 =
    Color3.fromRGB(
        28,
        28,
        36
    )

SearchBox.BorderSizePixel =
    0

SearchBox.ClearTextOnFocus =
    false

SearchBox.PlaceholderText =
    "🔎 Search seeds..."

SearchBox.PlaceholderColor3 =
    Color3.fromRGB(
        120,
        120,
        135
    )

SearchBox.Text =
    ""

SearchBox.TextColor3 =
    Color3.fromRGB(
        240,
        240,
        250
    )

SearchBox.TextSize =
    12

SearchBox.Font =
    Enum.Font.Gotham

SearchBox.Parent =
    Main

local SearchCorner =
    Instance.new("UICorner")

SearchCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

SearchCorner.Parent =
    SearchBox

--============================================================--
-- ITEM / RECIPE LIST
--============================================================--

local ItemList =
    Instance.new("ScrollingFrame")

ItemList.Position =
    UDim2.fromOffset(
        10,
        132
    )

ItemList.Size =
    UDim2.new(
        1,
        -20,
        0,
        245
    )

ItemList.BackgroundColor3 =
    Color3.fromRGB(
        14,
        14,
        19
    )

ItemList.BorderSizePixel =
    0

ItemList.ScrollBarThickness =
    4

ItemList.ScrollBarImageColor3 =
    Color3.fromRGB(
        100,
        75,
        230
    )

ItemList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

ItemList.CanvasSize =
    UDim2.new()

ItemList.Parent =
    Main

local ItemListCorner =
    Instance.new("UICorner")

ItemListCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ItemListCorner.Parent =
    ItemList

local ItemLayout =
    Instance.new("UIListLayout")

ItemLayout.Padding =
    UDim.new(
        0,
        4
    )

ItemLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

ItemLayout.Parent =
    ItemList

local ItemPadding =
    Instance.new("UIPadding")

ItemPadding.PaddingTop =
    UDim.new(
        0,
        5
    )

ItemPadding.PaddingBottom =
    UDim.new(
        0,
        5
    )

ItemPadding.PaddingLeft =
    UDim.new(
        0,
        5
    )

ItemPadding.PaddingRight =
    UDim.new(
        0,
        5
    )

ItemPadding.Parent =
    ItemList

--============================================================--
-- MODE BUTTON
--============================================================--

local ModeButton =
    Instance.new("TextButton")

ModeButton.Position =
    UDim2.fromOffset(
        10,
        387
    )

ModeButton.Size =
    UDim2.new(
        1,
        -20,
        0,
        34
    )

ModeButton.BackgroundColor3 =
    Color3.fromRGB(
        35,
        34,
        45
    )

ModeButton.BorderSizePixel =
    0

ModeButton.Text =
    "MODE: BUY ALL"

ModeButton.TextColor3 =
    Color3.fromRGB(
        225,
        225,
        235
    )

ModeButton.TextSize =
    11

ModeButton.Font =
    Enum.Font.GothamBold

ModeButton.Parent =
    Main

local ModeCorner =
    Instance.new("UICorner")

ModeCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ModeCorner.Parent =
    ModeButton

--============================================================--
-- AUTO BUTTON
--============================================================--

local AutoButton =
    Instance.new("TextButton")

AutoButton.Position =
    UDim2.fromOffset(
        10,
        427
    )

AutoButton.Size =
    UDim2.new(
        1,
        -20,
        0,
        42
    )

AutoButton.BackgroundColor3 =
    Color3.fromRGB(
        55,
        35,
        65
    )

AutoButton.BorderSizePixel =
    0

AutoButton.Text =
    "🔴 AUTO BUY: OFF"

AutoButton.TextColor3 =
    Color3.fromRGB(
        255,
        150,
        165
    )

AutoButton.TextSize =
    13

AutoButton.Font =
    Enum.Font.GothamBold

AutoButton.Parent =
    Main

local AutoCorner =
    Instance.new("UICorner")

AutoCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

AutoCorner.Parent =
    AutoButton

local AutoStroke =
    Instance.new("UIStroke")

AutoStroke.Color =
    Color3.fromRGB(
        100,
        55,
        100
    )

AutoStroke.Thickness =
    1

AutoStroke.Parent =
    AutoButton

--============================================================--
-- BREW AUTO BUTTON
--============================================================--

local BrewAutoButton =
    Instance.new("TextButton")

BrewAutoButton.Position =
    UDim2.fromOffset(
        10,
        387
    )

BrewAutoButton.Size =
    UDim2.new(
        1,
        -20,
        0,
        42
    )

BrewAutoButton.BackgroundColor3 =
    Color3.fromRGB(
        55,
        35,
        65
    )

BrewAutoButton.BorderSizePixel =
    0

BrewAutoButton.Text =
    "🔴 AUTO BREW: OFF"

BrewAutoButton.TextColor3 =
    Color3.fromRGB(
        255,
        150,
        165
    )

BrewAutoButton.TextSize =
    13

BrewAutoButton.Font =
    Enum.Font.GothamBold

BrewAutoButton.Visible =
    false

BrewAutoButton.Parent =
    Main

local BrewAutoCorner =
    Instance.new("UICorner")

BrewAutoCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

BrewAutoCorner.Parent =
    BrewAutoButton

local BrewAutoStroke =
    Instance.new("UIStroke")

BrewAutoStroke.Color =
    Color3.fromRGB(
        100,
        55,
        100
    )

BrewAutoStroke.Thickness =
    1

BrewAutoStroke.Parent =
    BrewAutoButton

--============================================================--
-- BREW SAVE BUTTON
--============================================================--

local BrewSaveButton =
    Instance.new("TextButton")

BrewSaveButton.Position =
    UDim2.fromOffset(
        10,
        437
    )

BrewSaveButton.Size =
    UDim2.new(
        1,
        -20,
        0,
        32
    )

BrewSaveButton.BackgroundColor3 =
    Color3.fromRGB(
        35,
        34,
        45
    )

BrewSaveButton.BorderSizePixel =
    0

BrewSaveButton.Text =
    "🛡 AUTO SAVE FAILED CRAFT: OFF"

BrewSaveButton.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        235
    )

BrewSaveButton.TextSize =
    10

BrewSaveButton.Font =
    Enum.Font.GothamBold

BrewSaveButton.Visible =
    false

BrewSaveButton.Parent =
    Main

local BrewSaveCorner =
    Instance.new("UICorner")

BrewSaveCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

BrewSaveCorner.Parent =
    BrewSaveButton

--============================================================--
-- AUTO KILL BUTTON
--============================================================--

local AutoKillButton =
    Instance.new("TextButton")

AutoKillButton.Position =
    UDim2.fromOffset(10, 387)

AutoKillButton.Size =
    UDim2.new(1, -20, 0, 42)

AutoKillButton.BackgroundColor3 =
    Color3.fromRGB(55, 35, 65)

AutoKillButton.BorderSizePixel = 0
AutoKillButton.Text = "🔴 AUTO KILL: OFF"
AutoKillButton.TextColor3 = Color3.fromRGB(255, 150, 165)
AutoKillButton.TextSize = 13
AutoKillButton.Font = Enum.Font.GothamBold
AutoKillButton.Visible = false
AutoKillButton.Parent = Main

local AutoKillCorner = Instance.new("UICorner")
AutoKillCorner.CornerRadius = UDim.new(0, 8)
AutoKillCorner.Parent = AutoKillButton

local AutoKillStroke = Instance.new("UIStroke")
AutoKillStroke.Color = Color3.fromRGB(100, 55, 100)
AutoKillStroke.Thickness = 1
AutoKillStroke.Parent = AutoKillButton

--============================================================--
-- REFRESH
--============================================================--

local RefreshButton =
    Instance.new("TextButton")

RefreshButton.Position =
    UDim2.fromOffset(
        10,
        477
    )

RefreshButton.Size =
    UDim2.new(
        0.5,
        -15,
        0,
        34
    )

RefreshButton.BackgroundColor3 =
    Color3.fromRGB(
        35,
        34,
        45
    )

RefreshButton.BorderSizePixel =
    0

RefreshButton.Text =
    "↻ REFRESH"

RefreshButton.TextColor3 =
    Color3.fromRGB(
        225,
        225,
        235
    )

RefreshButton.TextSize =
    11

RefreshButton.Font =
    Enum.Font.GothamBold

RefreshButton.Parent =
    Main

local RefreshCorner =
    Instance.new("UICorner")

RefreshCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

RefreshCorner.Parent =
    RefreshButton

local InfoLabel =
    Instance.new("TextLabel")

InfoLabel.Position =
    UDim2.new(
        0.5,
        5,
        0,
        477
    )

InfoLabel.Size =
    UDim2.new(
        0.5,
        -15,
        0,
        34
    )

InfoLabel.BackgroundTransparency =
    1

InfoLabel.Text =
    "AFK AUTO BUY"

InfoLabel.TextColor3 =
    Color3.fromRGB(
        120,
        120,
        135
    )

InfoLabel.TextSize =
    10

InfoLabel.Font =
    Enum.Font.Gotham

InfoLabel.Parent =
    Main

--============================================================--
-- CONFIG FRAME
--============================================================--

local ConfigFrame =
    Instance.new("Frame")

ConfigFrame.Name =
    "ConfigFrame"

ConfigFrame.Size =
    UDim2.fromOffset(
        350,
        535
    )

ConfigFrame.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

ConfigFrame.Position =
    UDim2.fromScale(
        0.5,
        0.5
    )

ConfigFrame.BackgroundColor3 =
    Color3.fromRGB(
        18,
        18,
        23
    )

ConfigFrame.BorderSizePixel =
    0

ConfigFrame.Visible =
    false

ConfigFrame.ZIndex =
    20

ConfigFrame.Parent =
    ScreenGui

local ConfigFrameCorner =
    Instance.new("UICorner")

ConfigFrameCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

ConfigFrameCorner.Parent =
    ConfigFrame

local ConfigFrameStroke =
    Instance.new("UIStroke")

ConfigFrameStroke.Color =
    Color3.fromRGB(
        110,
        80,
        255
    )

ConfigFrameStroke.Thickness =
    1.5

ConfigFrameStroke.Parent =
    ConfigFrame

--============================================================--
-- CONFIG HEADER
--============================================================--

local ConfigHeader =
    Instance.new("Frame")

ConfigHeader.Size =
    UDim2.new(
        1,
        0,
        0,
        42
    )

ConfigHeader.BackgroundColor3 =
    Color3.fromRGB(
        25,
        24,
        33
    )

ConfigHeader.BorderSizePixel =
    0

ConfigHeader.ZIndex =
    21

ConfigHeader.Parent =
    ConfigFrame

local ConfigTitle =
    Instance.new("TextLabel")

ConfigTitle.BackgroundTransparency =
    1

ConfigTitle.Position =
    UDim2.fromOffset(
        12,
        0
    )

ConfigTitle.Size =
    UDim2.new(
        1,
        -55,
        1,
        0
    )

ConfigTitle.Text =
    "⚙ KYOSH CONFIG MANAGER"

ConfigTitle.TextColor3 =
    Color3.fromRGB(
        235,
        235,
        255
    )

ConfigTitle.TextSize =
    13

ConfigTitle.Font =
    Enum.Font.GothamBold

ConfigTitle.TextXAlignment =
    Enum.TextXAlignment.Left

ConfigTitle.ZIndex =
    22

ConfigTitle.Parent =
    ConfigHeader

local ConfigClose =
    Instance.new("TextButton")

ConfigClose.Size =
    UDim2.fromOffset(
        30,
        30
    )

ConfigClose.Position =
    UDim2.new(
        1,
        -35,
        0,
        6
    )

ConfigClose.BackgroundColor3 =
    Color3.fromRGB(
        45,
        35,
        45
    )

ConfigClose.BorderSizePixel =
    0

ConfigClose.Text =
    "×"

ConfigClose.TextColor3 =
    Color3.fromRGB(
        255,
        120,
        140
    )

ConfigClose.TextSize =
    20

ConfigClose.Font =
    Enum.Font.GothamBold

ConfigClose.ZIndex =
    22

ConfigClose.Parent =
    ConfigHeader

local ConfigCloseCorner =
    Instance.new("UICorner")

ConfigCloseCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ConfigCloseCorner.Parent =
    ConfigClose

--============================================================--
-- DRAG CONFIG
--============================================================--

local ConfigDragging = false
local ConfigDragStart
local ConfigStartPosition

ConfigHeader.InputBegan:Connect(
    function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1
            or Input.UserInputType
            == Enum.UserInputType.Touch then

            ConfigDragging = true

            ConfigDragStart =
                Input.Position

            ConfigStartPosition =
                ConfigFrame.Position

            Input.Changed:Connect(
                function()

                    if Input.UserInputState
                        == Enum.UserInputState.End then

                        ConfigDragging = false

                    end

                end
            )

        end

    end
)

UserInputService.InputChanged:Connect(
    function(Input)

        if not ConfigDragging then
            return
        end

        if Input.UserInputType
            ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType
            ~= Enum.UserInputType.Touch then

            return
        end

        local Delta =
            Input.Position
            - ConfigDragStart

        ConfigFrame.Position =
            UDim2.new(
                ConfigStartPosition.X.Scale,
                ConfigStartPosition.X.Offset
                    + Delta.X,

                ConfigStartPosition.Y.Scale,
                ConfigStartPosition.Y.Offset
                    + Delta.Y
            )

    end
)

--============================================================--
-- CONFIG NAME
--============================================================--

local ConfigNameBox =
    Instance.new("TextBox")

ConfigNameBox.Position =
    UDim2.fromOffset(
        10,
        55
    )

ConfigNameBox.Size =
    UDim2.new(
        1,
        -20,
        0,
        36
    )

ConfigNameBox.BackgroundColor3 =
    Color3.fromRGB(
        28,
        28,
        36
    )

ConfigNameBox.BorderSizePixel =
    0

ConfigNameBox.ClearTextOnFocus =
    false

ConfigNameBox.PlaceholderText =
    "Config name..."

ConfigNameBox.PlaceholderColor3 =
    Color3.fromRGB(
        120,
        120,
        135
    )

ConfigNameBox.Text =
    ""

ConfigNameBox.TextColor3 =
    Color3.fromRGB(
        240,
        240,
        250
    )

ConfigNameBox.TextSize =
    12

ConfigNameBox.Font =
    Enum.Font.Gotham

ConfigNameBox.ZIndex =
    21

ConfigNameBox.Parent =
    ConfigFrame

local ConfigNameCorner =
    Instance.new("UICorner")

ConfigNameCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ConfigNameCorner.Parent =
    ConfigNameBox

--============================================================--
-- CONFIG LIST
--============================================================--

local ConfigList =
    Instance.new("ScrollingFrame")

ConfigList.Position =
    UDim2.fromOffset(
        10,
        101
    )

ConfigList.Size =
    UDim2.new(
        1,
        -20,
        0,
        210
    )

ConfigList.BackgroundColor3 =
    Color3.fromRGB(
        14,
        14,
        19
    )

ConfigList.BorderSizePixel =
    0

ConfigList.ScrollBarThickness =
    4

ConfigList.ScrollBarImageColor3 =
    Color3.fromRGB(
        100,
        75,
        230
    )

ConfigList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

ConfigList.CanvasSize =
    UDim2.new()

ConfigList.ZIndex =
    21

ConfigList.Parent =
    ConfigFrame

local ConfigListCorner =
    Instance.new("UICorner")

ConfigListCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ConfigListCorner.Parent =
    ConfigList

local ConfigLayout =
    Instance.new("UIListLayout")

ConfigLayout.Padding =
    UDim.new(
        0,
        4
    )

ConfigLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

ConfigLayout.Parent =
    ConfigList

local ConfigPadding =
    Instance.new("UIPadding")

ConfigPadding.PaddingTop =
    UDim.new(
        0,
        5
    )

ConfigPadding.PaddingBottom =
    UDim.new(
        0,
        5
    )

ConfigPadding.PaddingLeft =
    UDim.new(
        0,
        5
    )

ConfigPadding.PaddingRight =
    UDim.new(
        0,
        5
    )

ConfigPadding.Parent =
    ConfigList

--============================================================--
-- CONFIG STATUS
--============================================================--

local ConfigStatus =
    Instance.new("TextLabel")

ConfigStatus.Position =
    UDim2.fromOffset(
        10,
        320
    )

ConfigStatus.Size =
    UDim2.new(
        1,
        -20,
        0,
        25
    )

ConfigStatus.BackgroundTransparency =
    1

ConfigStatus.Text =
    FileSystemAvailable
    and "Local config storage available"
    or "Executor file storage unavailable"

ConfigStatus.TextColor3 =
    Color3.fromRGB(
        125,
        125,
        140
    )

ConfigStatus.TextSize =
    10

ConfigStatus.Font =
    Enum.Font.Gotham

ConfigStatus.ZIndex =
    21

ConfigStatus.Parent =
    ConfigFrame

--============================================================--
-- CONFIG BUTTON CREATOR
--============================================================--

local function createConfigButton(
    Text,
    X,
    Y,
    Width
)

    local Button =
        Instance.new("TextButton")

    Button.Position =
        UDim2.fromOffset(
            X,
            Y
        )

    Button.Size =
        UDim2.fromOffset(
            Width,
            34
        )

    Button.BackgroundColor3 =
        Color3.fromRGB(
            35,
            34,
            45
        )

    Button.BorderSizePixel =
        0

    Button.Text =
        Text

    Button.TextColor3 =
        Color3.fromRGB(
            230,
            230,
            240
        )

    Button.TextSize =
        10

    Button.Font =
        Enum.Font.GothamBold

    Button.ZIndex =
        21

    Button.Parent =
        ConfigFrame

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    return Button
end

local SaveButton =
    createConfigButton(
        "SAVE CONFIG",
        10,
        355,
        160
    )

local LoadButton =
    createConfigButton(
        "LOAD CONFIG",
        175,
        355,
        165
    )

local DeleteButton =
    createConfigButton(
        "DELETE",
        10,
        395,
        105
    )

local AutoLoadButton =
    createConfigButton(
        "AUTO LOAD: OFF",
        120,
        395,
        110
    )

local CopyButton =
    createConfigButton(
        "COPY CODE",
        235,
        395,
        105
    )

--============================================================--
-- IMPORT
--============================================================--

local ImportBox =
    Instance.new("TextBox")

ImportBox.Position =
    UDim2.fromOffset(
        10,
        438
    )

ImportBox.Size =
    UDim2.new(
        1,
        -20,
        0,
        36
    )

ImportBox.BackgroundColor3 =
    Color3.fromRGB(
        28,
        28,
        36
    )

ImportBox.BorderSizePixel =
    0

ImportBox.ClearTextOnFocus =
    false

ImportBox.PlaceholderText =
    "Paste config transfer code..."

ImportBox.Text =
    ""

ImportBox.TextColor3 =
    Color3.fromRGB(
        240,
        240,
        250
    )

ImportBox.TextSize =
    10

ImportBox.Font =
    Enum.Font.Gotham

ImportBox.ZIndex =
    21

ImportBox.Parent =
    ConfigFrame

local ImportCorner =
    Instance.new("UICorner")

ImportCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ImportCorner.Parent =
    ImportBox

local ImportButton =
    createConfigButton(
        "IMPORT",
        10,
        480,
        105
    )

local SelectedLabel =
    Instance.new("TextLabel")

SelectedLabel.Position =
    UDim2.fromOffset(
        120,
        480
    )

SelectedLabel.Size =
    UDim2.new(
        1,
        -130,
        0,
        34
    )

SelectedLabel.BackgroundTransparency =
    1

SelectedLabel.Text =
    "No config selected"

SelectedLabel.TextColor3 =
    Color3.fromRGB(
        130,
        130,
        145
    )

SelectedLabel.TextSize =
    9

SelectedLabel.Font =
    Enum.Font.Gotham

SelectedLabel.TextXAlignment =
    Enum.TextXAlignment.Left

SelectedLabel.TextTruncate =
    Enum.TextTruncate.AtEnd

SelectedLabel.ZIndex =
    21

SelectedLabel.Parent =
    ConfigFrame

--============================================================--
-- STATUS
--============================================================--

local function updateStatus()

    if Destroyed then
        return
    end

    if CurrentTab == "Seeds" then

        local Count =
            countSelected(
                SelectedSeeds
            )

        if AutoBuy then

            if AutoBuyMode == "ALL" then

                Status.Text =
                    "AUTO BUY ALL • SEEDS"

            else

                Status.Text =
                    "AUTO BUY SELECTED • "
                    .. tostring(Count)

            end

        else

            Status.Text =
                "SEEDS • "
                .. tostring(Count)
                .. " selected"

        end

    elseif CurrentTab == "Gear" then

        local Count =
            countSelected(
                SelectedGears
            )

        if AutoBuy then

            if AutoBuyMode == "ALL" then

                Status.Text =
                    "AUTO BUY ALL • GEAR"

            else

                Status.Text =
                    "AUTO BUY SELECTED • "
                    .. tostring(Count)

            end

        else

            Status.Text =
                "GEAR • "
                .. tostring(Count)
                .. " selected"

        end

    elseif CurrentTab == "Brew" then

        if AutoBrew then

            Status.Text =
                "AUTO BREW • "
                .. tostring(
                    SelectedRecipe
                    or "NO RECIPE"
                )

        elseif SelectedRecipe then

            Status.Text =
                "BREW • "
                .. SelectedRecipe

        else

            Status.Text =
                "BREW • Select a recipe"

        end

    elseif CurrentTab == "Kill" then

        local Count = 0

        for Id, Selected in pairs(SelectedMonsters) do
            if Selected then
                Count += 1
            end
        end

        if AutoKill then
            Status.Text =
                AutoKillMode == "ALL"
                and "AUTO KILL • ALL MONSTERS"
                or ("AUTO KILL • SELECTED • " .. tostring(Count))
        else
            Status.Text =
                AutoKillMode == "ALL"
                and "KILL • ALL MONSTERS"
                or ("KILL • " .. tostring(Count) .. " selected")
        end

    else

        Status.Text = "BREW • Select a recipe"

    end
end

--============================================================--
-- CLEAR ITEM LIST
--============================================================--

local function clearItemList()

    for _, Child in ipairs(
        ItemList:GetChildren()
    ) do

        if Child:IsA("TextButton")
            or Child:IsA("TextLabel") then

            Child:Destroy()

        end

    end
end

--============================================================--
-- RENDER NORMAL ITEMS
--============================================================--

local function renderShopList()

    clearItemList()

    local Folder
    local Selection
    local Search

    if CurrentTab == "Seeds" then

        Folder =
            SeedItemsFolder

        Selection =
            SelectedSeeds

        Search =
            SeedSearch

    else

        Folder =
            GearItemsFolder

        Selection =
            SelectedGears

        Search =
            GearSearch

    end

    local VisibleCount = 0

    for _, ItemName in ipairs(
        getItems(Folder)
    ) do

        if matchesSearch(
            ItemName,
            Search
        ) then

            VisibleCount += 1

            local IsSelected =
                Selection[ItemName] == true

            local Row =
                Instance.new("TextButton")

            Row.Size =
                UDim2.new(
                    1,
                    -10,
                    0,
                    31
                )

            Row.BackgroundColor3 =
                IsSelected
                and Color3.fromRGB(
                    65,
                    48,
                    115
                )
                or Color3.fromRGB(
                    25,
                    25,
                    32
                )

            Row.BorderSizePixel =
                0

            Row.AutoButtonColor =
                false

            Row.Text =
                ""

            Row.Parent =
                ItemList

            local RowCorner =
                Instance.new("UICorner")

            RowCorner.CornerRadius =
                UDim.new(
                    0,
                    6
                )

            RowCorner.Parent =
                Row

            local Check =
                Instance.new("TextLabel")

            Check.BackgroundTransparency =
                1

            Check.Position =
                UDim2.fromOffset(
                    8,
                    0
                )

            Check.Size =
                UDim2.fromOffset(
                    25,
                    31
                )

            Check.Font =
                Enum.Font.GothamBold

            Check.Text =
                IsSelected
                and "✓"
                or "□"

            Check.TextColor3 =
                IsSelected
                and Color3.fromRGB(
                    190,
                    160,
                    255
                )
                or Color3.fromRGB(
                    125,
                    125,
                    140
                )

            Check.TextSize =
                15

            Check.Parent =
                Row

            local NameLabel =
                Instance.new("TextLabel")

            NameLabel.BackgroundTransparency =
                1

            NameLabel.Position =
                UDim2.fromOffset(
                    38,
                    0
                )

            NameLabel.Size =
                UDim2.new(
                    1,
                    -45,
                    1,
                    0
                )

            NameLabel.Font =
                Enum.Font.Gotham

            NameLabel.Text =
                ItemName

            NameLabel.TextColor3 =
                Color3.fromRGB(
                    235,
                    235,
                    240
                )

            NameLabel.TextSize =
                11

            NameLabel.TextXAlignment =
                Enum.TextXAlignment.Left

            NameLabel.TextTruncate =
                Enum.TextTruncate.AtEnd

            NameLabel.Parent =
                Row

            Row.MouseButton1Click:Connect(
                function()

                    if Selection[ItemName] then

                        Selection[ItemName] =
                            nil

                    else

                        Selection[ItemName] =
                            true

                    end

                    renderShopList()

                end
            )

        end

    end

    if VisibleCount == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Size =
            UDim2.new(
                1,
                -10,
                0,
                40
            )

        Empty.BackgroundTransparency =
            1

        Empty.Text =
            "No items found"

        Empty.TextColor3 =
            Color3.fromRGB(
                120,
                120,
                135
            )

        Empty.Font =
            Enum.Font.Gotham

        Empty.TextSize =
            12

        Empty.Parent =
            ItemList

    end

    updateStatus()
end

--============================================================--
-- RENDER RECIPES
--============================================================--

local function renderRecipeList()

    clearItemList()

    local Recipes =
        getCauldronRecipes()

    local VisibleCount = 0

    for _, Recipe in ipairs(Recipes) do

        if matchesSearch(
            Recipe.Name,
            RecipeSearch
        ) then

            VisibleCount += 1

            local IsSelected =
                SelectedRecipe
                == Recipe.Name

            local Row =
                Instance.new("TextButton")

            Row.Size =
                UDim2.new(
                    1,
                    -10,
                    0,
                    44
                )

            Row.BackgroundColor3 =
                IsSelected
                and Color3.fromRGB(
                    65,
                    48,
                    115
                )
                or Color3.fromRGB(
                    25,
                    25,
                    32
                )

            Row.BorderSizePixel =
                0

            Row.AutoButtonColor =
                false

            Row.Text =
                ""

            Row.Parent =
                ItemList

            local Corner =
                Instance.new("UICorner")

            Corner.CornerRadius =
                UDim.new(
                    0,
                    6
                )

            Corner.Parent =
                Row

            local NameLabel =
                Instance.new("TextLabel")

            NameLabel.BackgroundTransparency =
                1

            NameLabel.Position =
                UDim2.fromOffset(
                    10,
                    3
                )

            NameLabel.Size =
                UDim2.new(
                    1,
                    -20,
                    0,
                    20
                )

            NameLabel.Text =
                (IsSelected and "✓ " or "")
                .. Recipe.Name

            NameLabel.TextColor3 =
                IsSelected
                and Color3.fromRGB(
                    210,
                    185,
                    255
                )
                or Color3.fromRGB(
                    235,
                    235,
                    240
                )

            NameLabel.TextSize =
                11

            NameLabel.Font =
                Enum.Font.GothamBold

            NameLabel.TextXAlignment =
                Enum.TextXAlignment.Left

            NameLabel.TextTruncate =
                Enum.TextTruncate.AtEnd

            NameLabel.Parent =
                Row

            local DetailLabel =
                Instance.new("TextLabel")

            DetailLabel.BackgroundTransparency =
                1

            DetailLabel.Position =
                UDim2.fromOffset(
                    10,
                    22
                )

            DetailLabel.Size =
                UDim2.new(
                    1,
                    -20,
                    0,
                    17
                )

            local Duration =
                tonumber(
                    Recipe.DurationSeconds
                ) or 0

            local FailChance =
                tonumber(
                    Recipe.FailChance
                ) or 0

            DetailLabel.Text =
                tostring(
                    math.floor(
                        Duration
                    )
                )
                .. "s"
                .. " • "
                .. tostring(
                    math.floor(
                        FailChance * 100
                    )
                )
                .. "% fail"

            DetailLabel.TextColor3 =
                Color3.fromRGB(
                    125,
                    125,
                    140
                )

            DetailLabel.TextSize =
                9

            DetailLabel.Font =
                Enum.Font.Gotham

            DetailLabel.TextXAlignment =
                Enum.TextXAlignment.Left

            DetailLabel.Parent =
                Row

            Row.MouseButton1Click:Connect(
                function()

                    SelectedRecipe =
                        Recipe.Name

                    renderRecipeList()

                    updateStatus()

                end
            )

        end

    end

    if VisibleCount == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Size =
            UDim2.new(
                1,
                -10,
                0,
                40
            )

        Empty.BackgroundTransparency =
            1

        Empty.Text =
            "No recipes found"

        Empty.TextColor3 =
            Color3.fromRGB(
                120,
                120,
                135
            )

        Empty.Font =
            Enum.Font.Gotham

        Empty.TextSize =
            12

        Empty.Parent =
            ItemList

    end

    updateStatus()
end

--============================================================--
-- MONSTER HELPERS / RENDER
--============================================================--

local function getMonsterRoot(Monster)

    if not Monster or not Monster.Parent then
        return nil
    end

    if Monster:IsA("BasePart") then
        return Monster
    end

    if Monster:IsA("Model") then

        if Monster.PrimaryPart then
            return Monster.PrimaryPart
        end

        local HumanoidRootPart =
            Monster:FindFirstChild("HumanoidRootPart")

        if HumanoidRootPart
            and HumanoidRootPart:IsA("BasePart") then

            return HumanoidRootPart
        end

    end

    return Monster:FindFirstChildWhichIsA(
        "BasePart",
        true
    )
end

local function getMonsterAttribute(Monster, Name)

    if not Monster then
        return nil
    end

    local Value =
        Monster:GetAttribute(Name)

    if Value ~= nil then
        return Value
    end

    local ValueObject =
        Monster:FindFirstChild(Name)

    if ValueObject
        and ValueObject:IsA("ValueBase") then

        return ValueObject.Value
    end

    return nil
end

local function getMonsterId(Monster)

    local Id =
        getMonsterAttribute(Monster, "MonsterId")
        or getMonsterAttribute(Monster, "MonsterID")
        or getMonsterAttribute(Monster, "Id")

    if Id ~= nil then
        return Id
    end

    return Monster and Monster.Name or nil
end

local function getMonsterDisplayName(Monster)

    local DisplayName =
        getMonsterAttribute(Monster, "DisplayName")
        or getMonsterAttribute(Monster, "MonsterType")

    if type(DisplayName) == "string"
        and DisplayName ~= "" then

        return DisplayName
    end

    return Monster and Monster.Name or "Monster"
end

local function isMonsterAlive(Monster)

    if not Monster or not Monster.Parent then
        return false
    end

    if getMonsterAttribute(Monster, "Dead") == true then
        return false
    end

    local Health =
        tonumber(
            getMonsterAttribute(
                Monster,
                "Health"
            )
        )

    if Health ~= nil
        and Health <= 0 then

        return false
    end

    return getMonsterRoot(Monster) ~= nil
end

local function getMonsters()

    -- MonsterController confirms that the live monster objects
    -- are BaseParts under workspace.Monsters.
    local MonstersFolder =
        workspace:FindFirstChild("Monsters")

    if not MonstersFolder then
        return {}
    end

    local Monsters = {}

    for _, Monster in ipairs(
        MonstersFolder:GetChildren()
    ) do

        if isMonsterAlive(Monster) then
            table.insert(
                Monsters,
                Monster
            )
        end

    end

    table.sort(
        Monsters,
        function(A, B)
            return string.lower(A.Name)
                < string.lower(B.Name)
        end
    )

    return Monsters
end

local function monsterMatchesSelection(Monster)

    if AutoKillMode == "ALL" then
        return true
    end

    local Id = getMonsterId(Monster)

    return Id ~= nil
        and SelectedMonsters[tostring(Id)] == true
end

local function getCharacterParts()

    local Character =
        LocalPlayer.Character

    if not Character then
        return nil, nil
    end

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not Humanoid
        or not Root
        or Humanoid.Health <= 0 then

        return nil, nil
    end

    return Humanoid, Root
end

local function getNearestMonster()

    local _, Root =
        getCharacterParts()

    if not Root then
        return nil
    end

    local Best = nil
    local BestDistance = math.huge

    for _, Monster in ipairs(
        getMonsters()
    ) do

        if monsterMatchesSelection(Monster) then

            local MonsterRoot =
                getMonsterRoot(Monster)

            if MonsterRoot then

                local Distance =
                    (Root.Position - MonsterRoot.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    Best = Monster
                end

            end
        end

    end

    return Best
end

local function moveTowardMonster(Monster)

    local Humanoid, Root =
        getCharacterParts()

    local MonsterRoot =
        getMonsterRoot(Monster)

    if not Humanoid
        or not Root
        or not MonsterRoot then

        return false
    end

    -- Pass the monster part as WalkToPart so Roblox keeps the
    -- destination attached to a moving monster.
    Humanoid:MoveTo(
        MonsterRoot.Position,
        MonsterRoot
    )

    return true
end

local function tryPathTowardMonster(Monster)

    local Humanoid, Root =
        getCharacterParts()

    local MonsterRoot =
        getMonsterRoot(Monster)

    if not Humanoid
        or not Root
        or not MonsterRoot then

        return false
    end

    local Success, Path =
        pcall(function()

            local NewPath =
                PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true,
                    AgentCanClimb = true,
                    WaypointSpacing = 5,
                })

            NewPath:ComputeAsync(
                Root.Position,
                MonsterRoot.Position
            )

            return NewPath
        end)

    if not Success
        or not Path
        or Path.Status ~= Enum.PathStatus.Success then

        return moveTowardMonster(Monster)
    end

    local Waypoints =
        Path:GetWaypoints()

    if #Waypoints < 2 then
        return moveTowardMonster(Monster)
    end

    local NextWaypoint =
        Waypoints[2]

    if NextWaypoint.Action
        == Enum.PathWaypointAction.Jump then

        Humanoid.Jump = true
    end

    Humanoid:MoveTo(
        NextWaypoint.Position
    )

    return true
end

local function getShovelTool()

    local Character =
        LocalPlayer.Character

    if Character then

        local Equipped =
            Character:FindFirstChildOfClass("Tool")

        if Equipped
            and string.lower(Equipped.Name):find("shovel", 1, true) then

            return Equipped
        end

    end

    local Backpack =
        LocalPlayer:FindFirstChildOfClass("Backpack")

    if Backpack then

        for _, Tool in ipairs(Backpack:GetChildren()) do

            if Tool:IsA("Tool")
                and string.lower(Tool.Name):find("shovel", 1, true) then

                return Tool
            end

        end

    end

    return nil
end

local function equipShovel()

    local Humanoid =
        select(1, getCharacterParts())

    if not Humanoid then
        return nil
    end

    local Shovel =
        getShovelTool()

    if not Shovel then
        return nil
    end

    if Shovel.Parent ~= LocalPlayer.Character then

        pcall(function()
            Humanoid:EquipTool(Shovel)
        end)

        task.wait(0.08)

    end

    if Shovel.Parent == LocalPlayer.Character then
        AutoKillShovel = Shovel
        return Shovel
    end

    return nil
end

local function setAutoKillSpeed(Enabled)

    local Humanoid =
        select(1, getCharacterParts())

    if not Humanoid then
        return
    end

    if Enabled then

        if AutoKillOriginalWalkSpeed == nil then
            AutoKillOriginalWalkSpeed =
                Humanoid.WalkSpeed
        end

        Humanoid.WalkSpeed =
            math.max(
                AutoKillOriginalWalkSpeed,
                AutoKillWalkSpeed
            )

    else

        if AutoKillOriginalWalkSpeed ~= nil then

            Humanoid.WalkSpeed =
                AutoKillOriginalWalkSpeed

        end

        AutoKillOriginalWalkSpeed = nil

    end
end

local AutoKillSwingAnimation = nil

local function playAutoKillShovelAnimation()

    local Character = LocalPlayer.Character
    if not Character then
        return false
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        return false
    end

    local Animator = Humanoid:FindFirstChildOfClass("Animator")
    if not Animator then
        Animator = Instance.new("Animator")
        Animator.Parent = Humanoid
    end

    if AutoKillSwingAnimation then
        pcall(function()
            AutoKillSwingAnimation:Stop(0)
            AutoKillSwingAnimation:Destroy()
        end)
        AutoKillSwingAnimation = nil
    end

    local Animation = Instance.new("Animation")
    Animation.AnimationId = "rbxassetid://78592768207309"

    local Success, Track = pcall(function()
        return Animator:LoadAnimation(Animation)
    end)

    Animation:Destroy()

    if not Success or not Track then
        return false
    end

    AutoKillSwingAnimation = Track
    Track.Looped = false
    Track.Priority = Enum.AnimationPriority.Action4
    Track:Play(0.05, 1, 1)

    return true
end

local function stopAutoKillShovelAnimation()
    if AutoKillSwingAnimation then
        pcall(function()
            AutoKillSwingAnimation:Stop(0.05)
            AutoKillSwingAnimation:Destroy()
        end)
        AutoKillSwingAnimation = nil
    end
end

local function fireShovelSwing()

    local Shovel =
        equipShovel()

    if not Shovel then
        return false
    end

    -- IMPORTANT: the real ShovelController calls SwingShovel:Fire()
    -- with NO arguments. Passing the monster here was incorrect.
    local Success =
        pcall(function()
            Networking.Shovel
                .SwingShovel
                :Fire()
        end)

    return Success
end

local function fireMonsterHit(Monster)

    if not isMonsterAlive(Monster) then
        return false
    end

    local Humanoid, Root = getCharacterParts()
    local MonsterRoot = getMonsterRoot(Monster)

    if not Root or not MonsterRoot then
        return false
    end

    -- The real ShovelController only accepts monster hits while the
    -- monster is within 14 studs of the player's HumanoidRootPart.
    local Distance =
        (Root.Position - MonsterRoot.Position).Magnitude

    if Distance > 14 then
        return false
    end

    local MonsterId = getMonsterId(Monster)
    if MonsterId == nil then
        return false
    end

    -- Start the actual visible shovel swing first.
    playAutoKillShovelAnimation()
    fireShovelSwing()

    -- Match ShovelController.ActivateHitDetection exactly:
    -- HitMonsterFromClientToServer:Fire({Id = monsterId})
    local Success = pcall(function()
        Networking.Monster
            .HitMonsterFromClientToServer
            :Fire({
                Id = MonsterId,
            })
    end)

    return Success
end


--============================================================--
-- AUTO KILL // PUMPKIN SMASH
--============================================================--

local function getPumpkins()

    local Folder =
        workspace:FindFirstChild("Pumpkins")

    if not Folder then
        return {}
    end

    return Folder:GetChildren()
end

local function getPumpkinId(Pumpkin)

    if not Pumpkin then
        return nil
    end

    local Id =
        Pumpkin:GetAttribute("PumpkinId")

    if type(Id) == "string" and Id ~= "" then
        return Id
    end

    return nil
end

local function getPumpkinRoot(Pumpkin)

    if not Pumpkin or not Pumpkin.Parent then
        return nil
    end

    local Root =
        Pumpkin:FindFirstChild("Root")

    if Root and Root:IsA("BasePart") then
        return Root
    end

    if Pumpkin:IsA("Model") then
        return Pumpkin.PrimaryPart
            or Pumpkin:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

local function isPumpkinAlive(Pumpkin)

    if not Pumpkin
        or not Pumpkin.Parent then

        return false
    end

    if not getPumpkinId(Pumpkin) then
        return false
    end

    local Root =
        getPumpkinRoot(Pumpkin)

    if not Root then
        return false
    end

    if Pumpkin:GetAttribute("Dead") == true
        or Pumpkin:GetAttribute("Broken") == true
        or Pumpkin:GetAttribute("Smashed") == true then

        return false
    end

    return true
end

local function getNearestPumpkin()

    local _, Root =
        getCharacterParts()

    if not Root then
        return nil
    end

    local Best = nil
    local BestDistance = math.huge

    for _, Pumpkin in ipairs(getPumpkins()) do

        if isPumpkinAlive(Pumpkin) then

            local PumpkinRoot =
                getPumpkinRoot(Pumpkin)

            if PumpkinRoot then

                local Distance =
                    (Root.Position - PumpkinRoot.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    Best = Pumpkin
                end

            end

        end

    end

    return Best
end

local function firePumpkinHit(Pumpkin)

    if not isPumpkinAlive(Pumpkin) then
        return false
    end

    local _, Root =
        getCharacterParts()

    local PumpkinRoot =
        getPumpkinRoot(Pumpkin)

    if not Root or not PumpkinRoot then
        return false
    end

    -- Keep the same practical shovel range used by the game's
    -- client-side hit detection.
    local Distance =
        (Root.Position - PumpkinRoot.Position).Magnitude

    if Distance > 14 then
        return false
    end

    local PumpkinId =
        getPumpkinId(Pumpkin)

    if not PumpkinId then
        return false
    end

    playAutoKillShovelAnimation()
    fireShovelSwing()

    -- Pumpkin packet is defined as Any. The pumpkin visual controller
    -- identifies pumpkins through the same {Id = PumpkinId} structure.
    local Success =
        pcall(function()
            Networking.Pumpkin
                .HitPumpkinFromClientToServer
                :Fire({
                    Id = PumpkinId,
                })
        end)

    return Success
end

local function renderMonsterList()

    clearItemList()

    local Monsters = getMonsters()
    local VisibleCount = 0

    for _, Monster in ipairs(Monsters) do

        local DisplayName =
            getMonsterDisplayName(Monster)

        local Id =
            tostring(
                getMonsterId(Monster)
                or Monster.Name
            )

        if matchesSearch(
            DisplayName,
            RecipeSearch
        ) or matchesSearch(
            Monster.Name,
            RecipeSearch
        ) then

            VisibleCount += 1

            local IsSelected =
                AutoKillMode == "SELECTED"
                and SelectedMonsters[Id] == true

            local Row =
                Instance.new("TextButton")

            Row.Size =
                UDim2.new(
                    1,
                    -10,
                    0,
                    42
                )

            Row.BackgroundColor3 =
                IsSelected
                and Color3.fromRGB(
                    65,
                    48,
                    115
                )
                or Color3.fromRGB(
                    25,
                    25,
                    32
                )

            Row.BorderSizePixel = 0
            Row.AutoButtonColor = false
            Row.Text = ""
            Row.Parent = ItemList

            local Corner =
                Instance.new("UICorner")

            Corner.CornerRadius =
                UDim.new(0, 6)

            Corner.Parent = Row

            local NameLabel =
                Instance.new("TextLabel")

            NameLabel.BackgroundTransparency = 1
            NameLabel.Position =
                UDim2.fromOffset(10, 3)
            NameLabel.Size =
                UDim2.new(1, -20, 0, 20)
            NameLabel.Font =
                Enum.Font.GothamBold
            NameLabel.Text =
                (IsSelected and "✓ " or "")
                .. DisplayName
            NameLabel.TextColor3 =
                Color3.fromRGB(235, 235, 240)
            NameLabel.TextSize = 11
            NameLabel.TextXAlignment =
                Enum.TextXAlignment.Left
            NameLabel.TextTruncate =
                Enum.TextTruncate.AtEnd
            NameLabel.Parent = Row

            local Detail =
                Instance.new("TextLabel")

            Detail.BackgroundTransparency = 1
            Detail.Position =
                UDim2.fromOffset(10, 22)
            Detail.Size =
                UDim2.new(1, -20, 0, 16)
            Detail.Font = Enum.Font.Gotham
            Detail.Text =
                "ID: " .. Id
            Detail.TextColor3 =
                Color3.fromRGB(125, 125, 140)
            Detail.TextSize = 9
            Detail.TextXAlignment =
                Enum.TextXAlignment.Left
            Detail.TextTruncate =
                Enum.TextTruncate.AtEnd
            Detail.Parent = Row

            Row.MouseButton1Click:Connect(
                function()

                    if SelectedMonsters[Id] then
                        SelectedMonsters[Id] = nil
                    else
                        SelectedMonsters[Id] = true
                    end

                    renderMonsterList()
                    updateStatus()

                end
            )

        end

    end

    if VisibleCount == 0 then

        local Empty = Instance.new("TextLabel")
        Empty.Size = UDim2.new(1, -10, 0, 40)
        Empty.BackgroundTransparency = 1
        Empty.Text = "No live monsters found"
        Empty.TextColor3 = Color3.fromRGB(120, 120, 135)
        Empty.Font = Enum.Font.Gotham
        Empty.TextSize = 12
        Empty.Parent = ItemList

    end

    updateStatus()
end

--============================================================--
-- RENDER CURRENT TAB
--============================================================--

local function renderList()

    if CurrentTab == "Brew" then

        renderRecipeList()

    elseif CurrentTab == "Kill" then

        renderMonsterList()

    else

        renderShopList()

    end

end

--============================================================--
-- AUTO BUY UI
--============================================================--

local function updateAutoButton()

    if AutoBuy then

        AutoButton.Text =
            "🟢 AUTO BUY: ON"

        AutoButton.TextColor3 =
            Color3.fromRGB(
                150,
                255,
                170
            )

        AutoButton.BackgroundColor3 =
            Color3.fromRGB(
                30,
                75,
                45
            )

        AutoStroke.Color =
            Color3.fromRGB(
                70,
                160,
                90
            )

    else

        AutoButton.Text =
            "🔴 AUTO BUY: OFF"

        AutoButton.TextColor3 =
            Color3.fromRGB(
                255,
                150,
                165
            )

        AutoButton.BackgroundColor3 =
            Color3.fromRGB(
                55,
                35,
                65
            )

        AutoStroke.Color =
            Color3.fromRGB(
                100,
                55,
                100
            )

    end
end

--============================================================--
-- AUTO BREW UI
--============================================================--

local function updateBrewAutoButton()

    if AutoBrew then

        BrewAutoButton.Text =
            "🟢 AUTO BREW: ON"

        BrewAutoButton.TextColor3 =
            Color3.fromRGB(
                150,
                255,
                170
            )

        BrewAutoButton.BackgroundColor3 =
            Color3.fromRGB(
                30,
                75,
                45
            )

        BrewAutoStroke.Color =
            Color3.fromRGB(
                70,
                160,
                90
            )

    else

        BrewAutoButton.Text =
            "🔴 AUTO BREW: OFF"

        BrewAutoButton.TextColor3 =
            Color3.fromRGB(
                255,
                150,
                165
            )

        BrewAutoButton.BackgroundColor3 =
            Color3.fromRGB(
                55,
                35,
                65
            )

        BrewAutoStroke.Color =
            Color3.fromRGB(
                100,
                55,
                100
            )

    end
end

local function updateBrewSaveButton()

    if AutoSaveFailedCraft then

        BrewSaveButton.Text =
            "🟢 AUTO SAVE FAILED CRAFT: ON"

        BrewSaveButton.BackgroundColor3 =
            Color3.fromRGB(
                30,
                65,
                45
            )

        BrewSaveButton.TextColor3 =
            Color3.fromRGB(
                160,
                255,
                180
            )

    else

        BrewSaveButton.Text =
            "🛡 AUTO SAVE FAILED CRAFT: OFF"

        BrewSaveButton.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        BrewSaveButton.TextColor3 =
            Color3.fromRGB(
                220,
                220,
                235
            )

    end
end

--============================================================--
-- AUTO BUY LOOP
--============================================================--

local function startAutoBuyLoop()

    if AutoBuyThread then
        return
    end

    AutoBuyThread =
        task.spawn(
            function()

                while AutoBuy
                    and not Destroyed do

                    local Folder
                    local Selection

                    if CurrentTab == "Seeds" then

                        Folder =
                            SeedItemsFolder

                        Selection =
                            SelectedSeeds

                    elseif CurrentTab == "Gear" then

                        Folder =
                            GearItemsFolder

                        Selection =
                            SelectedGears

                    else

                        task.wait(1)
                        continue

                    end

                    local Items =
                        getItems(Folder)

                    for _, ItemName in ipairs(
                        Items
                    ) do

                        if not AutoBuy
                            or Destroyed then

                            break
                        end

                        local ShouldBuy =
                            false

                        if AutoBuyMode
                            == "ALL" then

                            ShouldBuy =
                                true

                        elseif AutoBuyMode
                            == "SELECTED" then

                            ShouldBuy =
                                Selection[
                                    ItemName
                                ] == true

                        end

                        if ShouldBuy then

                            if CurrentTab
                                == "Seeds" then

                                pcall(
                                    function()

                                        PurchaseSeed:Fire(
                                            ItemName
                                        )

                                    end
                                )

                            elseif CurrentTab
                                == "Gear" then

                                pcall(
                                    function()

                                        PurchaseGear:Fire(
                                            ItemName
                                        )

                                    end
                                )

                            end

                            Status.Text =
                                "AUTO BUY • "
                                .. ItemName

                            task.wait(
                                SETTINGS.PurchaseDelay
                            )

                        end

                    end

                    if AutoBuy
                        and not Destroyed then

                        task.wait(
                            SETTINGS.CycleDelay
                        )

                    end

                end

                AutoBuyThread =
                    nil

                if not Destroyed then
                    updateStatus()
                end

            end
        )

end

local function setAutoBuy(Enabled)

    AutoBuy =
        Enabled

    updateAutoButton()

    if AutoBuy then
        startAutoBuyLoop()
    end

    updateStatus()
end

--============================================================--
-- AUTO CLAIM FINISHED BREW
--============================================================--
-- When the server reports the cauldron as Ready, the game's
-- CauldronReveal packet is the claim/reveal action. This helper
-- keeps that action explicit and prevents the Auto Brew loop from
-- starting another brew before the finished brew is claimed.
--============================================================--

local function autoClaimFinishedBrew()

    local Success,
        Revealed,
        Message,
        Failed,
        OutputName,
        Amount =

        pcall(
            function()

                return
                    CauldronReveal:Fire()

            end
        )

    return
        Success,
        Revealed,
        Message,
        Failed,
        OutputName,
        Amount
end

--============================================================--
-- AUTO BREW LOOP
--============================================================--

local function startAutoBrewLoop()

    if AutoBrewThread then
        return
    end

    AutoBrewThread =
        task.spawn(
            function()

                while AutoBrew
                    and not Destroyed do

                    --========================================--
                    -- RECIPE CHECK
                    --========================================--

                    if not SelectedRecipe then

                        Status.Text =
                            "AUTO BREW • SELECT RECIPE"

                        task.wait(1)

                        continue
                    end

                    local Recipe =
                        getRecipeByName(
                            SelectedRecipe
                        )

                    if not Recipe then

                        Status.Text =
                            "AUTO BREW • RECIPE NOT FOUND"

                        task.wait(2)

                        continue
                    end

                    --========================================--
                    -- REQUEST STATE
                    --========================================--

                    local State =
                        getCauldronState()

                    if not State then

                        Status.Text =
                            "AUTO BREW • WAITING"

                        task.wait(
                            SETTINGS.BrewErrorDelay
                        )

                        continue
                    end

                    local StateName =
                        getCauldronStateName(
                            State
                        )

                    --========================================--
                    -- EMPTY
                    --========================================--

                    if StateName == "Empty" then

                        Status.Text =
                            "STARTING • "
                            .. Recipe.Name

                        local Success,
                            Started,
                            Message =

                            pcall(
                                function()

                                    return
                                        CauldronStartBrew:Fire(
                                            Recipe.Name
                                        )

                                end
                            )

                        if Success
                            and Started then

                            Status.Text =
                                "BREWING • "
                                .. Recipe.Name

                            task.wait(1)

                        else

                            Status.Text =
                                "START FAILED • "
                                .. tostring(
                                    Message
                                    or "Unknown"
                                )

                            task.wait(
                                SETTINGS.BrewErrorDelay
                            )

                        end

                    --========================================--
                    -- BREWING
                    --========================================--

                    elseif StateName
                        == "Brewing" then

                        local FinishTime =
                            tonumber(
                                State.FinishesAt
                            ) or 0

                        local Now =
                            workspace:GetServerTimeNow()

                        local Remaining =
                            math.max(
                                0,
                                FinishTime - Now
                            )

                        Status.Text =
                            "BREWING • "
                            .. Recipe.Name
                            .. " • "
                            .. tostring(
                                math.ceil(
                                    Remaining
                                )
                            )
                            .. "s"

                        task.wait(
                            math.clamp(
                                Remaining,
                                0.5,
                                3
                            )
                        )

                    --========================================--
                    -- READY
                    --========================================--

                    elseif StateName
                        == "Ready" then

                        Status.Text =
                            "AUTO CLAIMING • "
                            .. Recipe.Name

                        -- The brew is finished. Automatically claim/reveal it now.
                        local Success,
                            Revealed,
                            Message,
                            Failed,
                            OutputName,
                            Amount =

                            autoClaimFinishedBrew()

                        if Success
                            and Revealed then

                            if Failed then

                                Status.Text =
                                    "BREW FAILED • "
                                    .. Recipe.Name

                                --================================--
                                -- AUTO SAVE
                                --================================--

                                if AutoSaveFailedCraft then

                                    task.wait(0.25)

                                    local SaveSuccess,
                                        Saved,
                                        SaveMessage,
                                        SavedItem,
                                        SavedAmount =

                                        pcall(
                                            function()

                                                return
                                                    CauldronSaveCraft:Fire()

                                            end
                                        )

                                    if SaveSuccess
                                        and Saved then

                                        Status.Text =
                                            "CRAFT SAVED • "
                                            .. Recipe.Name

                                    else

                                        Status.Text =
                                            "SAVE FAILED • "
                                            .. tostring(
                                                SaveMessage
                                                or "No save"
                                            )

                                    end

                                end

                            else

                                Status.Text =
                                    "SUCCESS • "
                                    .. tostring(
                                        OutputName
                                        or Recipe.Name
                                    )
                                    .. " x"
                                    .. tostring(
                                        Amount
                                        or 1
                                    )

                            end

                            task.wait(1)

                        else

                            Status.Text =
                                "REVEAL FAILED • "
                                .. tostring(
                                    Message
                                    or "Unknown"
                                )

                            task.wait(
                                SETTINGS.BrewErrorDelay
                            )

                        end

                    --========================================--
                    -- SAVING
                    --========================================--

                    elseif StateName
                        == "Saving" then

                        Status.Text =
                            "SAVING CRAFT..."

                        task.wait(1)

                    else

                        Status.Text =
                            "CAULDRON • "
                            .. StateName

                        task.wait(1)

                    end

                end

                AutoBrewThread =
                    nil

                if not Destroyed then
                    updateStatus()
                end

            end
        )

end

local function setAutoBrew(Enabled)

    AutoBrew =
        Enabled

    updateBrewAutoButton()

    if AutoBrew then
        startAutoBrewLoop()
    end

    updateStatus()
end

--============================================================--
-- AUTO KILL UI / LOOP
--============================================================--

local function updateAutoKillButton()

    if AutoKill then

        AutoKillButton.Text =
            "🟢 AUTO KILL: ON"

        AutoKillButton.TextColor3 =
            Color3.fromRGB(150, 255, 170)

        AutoKillButton.BackgroundColor3 =
            Color3.fromRGB(30, 75, 45)

        AutoKillStroke.Color =
            Color3.fromRGB(70, 160, 90)

    else

        AutoKillButton.Text =
            "🔴 AUTO KILL: OFF"

        AutoKillButton.TextColor3 =
            Color3.fromRGB(255, 150, 165)

        AutoKillButton.BackgroundColor3 =
            Color3.fromRGB(55, 35, 65)

        AutoKillStroke.Color =
            Color3.fromRGB(100, 55, 100)

    end
end

local function startAutoKillLoop()

    if AutoKillThread then
        return
    end

    setAutoKillSpeed(true)

    AutoKillThread =
        task.spawn(
            function()

                while AutoKill
                    and not Destroyed do

                    --====================================================--
                    -- PUMPKIN SMASH PRIORITY
                    --====================================================--
                    -- If a pumpkin is already close enough, smash it first.
                    -- This lets Auto Kill collect pumpkin rewards while it
                    -- continues hunting monsters.

                    local NearbyPumpkin =
                        getNearestPumpkin()

                    if NearbyPumpkin then

                        local _, Root =
                            getCharacterParts()

                        local PumpkinRoot =
                            getPumpkinRoot(NearbyPumpkin)

                        if Root and PumpkinRoot then

                            local PumpkinDistance =
                                (Root.Position - PumpkinRoot.Position).Magnitude

                            if PumpkinDistance <= 14 then

                                AutoKillPumpkinTarget =
                                    NearbyPumpkin

                                Status.Text =
                                    "AUTO KILL • SMASHING PUMPKIN"

                                equipShovel()

                                local Smashed =
                                    firePumpkinHit(
                                        NearbyPumpkin
                                    )

                                -- Use the same 0.65s shovel swing timing
                                -- as the game's ShovelController.
                                if Smashed then
                                    task.wait(0.65)
                                else
                                    task.wait(0.12)
                                end

                                if not isPumpkinAlive(
                                    NearbyPumpkin
                                ) then
                                    AutoKillPumpkinTarget = nil
                                end

                                continue

                            end

                        end

                    end

                    --====================================================--
                    -- MONSTER TARGET
                    --====================================================--

                    local Target =
                        CurrentKillTarget

                    if not isMonsterAlive(Target)
                        or not monsterMatchesSelection(Target) then

                        Target =
                            getNearestMonster()

                        CurrentKillTarget =
                            Target
                    end

                    --====================================================--
                    -- NO MONSTER: GO TO A PUMPKIN
                    --====================================================--

                    if not Target then

                        local Pumpkin =
                            getNearestPumpkin()

                        if not Pumpkin then

                            Status.Text =
                                "AUTO KILL • WAITING FOR MONSTER / PUMPKIN"

                            task.wait(0.5)
                            continue
                        end

                        AutoKillPumpkinTarget =
                            Pumpkin

                        local Humanoid, Root =
                            getCharacterParts()

                        local PumpkinRoot =
                            getPumpkinRoot(Pumpkin)

                        if not Humanoid
                            or not Root
                            or not PumpkinRoot then

                            AutoKillPumpkinTarget = nil
                            task.wait(0.25)
                            continue
                        end

                        local Distance =
                            (Root.Position - PumpkinRoot.Position).Magnitude

                        if Distance > 10 then

                            Status.Text =
                                "AUTO KILL • GOING TO PUMPKIN • "
                                .. tostring(
                                    math.floor(Distance)
                                )
                                .. " studs"

                            Humanoid:MoveTo(
                                PumpkinRoot.Position
                            )

                            task.wait(0.08)

                        else

                            Status.Text =
                                "AUTO KILL • SMASHING PUMPKIN"

                            equipShovel()

                            local Smashed =
                                firePumpkinHit(Pumpkin)

                            if Smashed then
                                task.wait(0.65)
                            else
                                task.wait(0.12)
                            end

                            if not isPumpkinAlive(Pumpkin) then
                                AutoKillPumpkinTarget = nil
                            end

                        end

                        continue
                    end

                    --====================================================--
                    -- MOVE TO MONSTER
                    --====================================================--

                    local Humanoid, Root =
                        getCharacterParts()

                    local MonsterRoot =
                        getMonsterRoot(Target)

                    if not Humanoid
                        or not Root
                        or not MonsterRoot then

                        CurrentKillTarget = nil
                        task.wait(0.25)
                        continue
                    end

                    local Distance =
                        (Root.Position - MonsterRoot.Position).Magnitude

                    if Distance > 10 then

                        Status.Text =
                            "AUTO KILL • GOING TO "
                            .. getMonsterDisplayName(Target)
                            .. " • "
                            .. tostring(
                                math.floor(Distance)
                            )
                            .. " studs"

                        moveTowardMonster(Target)

                        if Distance > 35 then
                            tryPathTowardMonster(Target)
                        end

                        task.wait(0.08)

                    else

                        equipShovel()

                        Status.Text =
                            "AUTO KILL • ATTACKING "
                            .. getMonsterDisplayName(Target)

                        local BeforeHealth =
                            tonumber(
                                getMonsterAttribute(
                                    Target,
                                    "Health"
                                )
                            )

                        local HitSent =
                            fireMonsterHit(Target)

                        -- ShovelController uses a 0.65s swing cooldown.
                        if HitSent then
                            task.wait(0.65)
                        else
                            task.wait(0.12)
                        end

                        if not isMonsterAlive(Target) then

                            CurrentKillTarget = nil

                        else

                            local AfterHealth =
                                tonumber(
                                    getMonsterAttribute(
                                        Target,
                                        "Health"
                                    )
                                )

                            if BeforeHealth ~= nil
                                and AfterHealth ~= nil
                                and AfterHealth >= BeforeHealth then

                                task.wait(0.25)
                            end

                        end

                    end

                end

                stopAutoKillShovelAnimation()
                setAutoKillSpeed(false)
                AutoKillShovel = nil
                AutoKillPumpkinTarget = nil

                AutoKillThread = nil
                CurrentKillTarget = nil

                if not Destroyed then
                    updateStatus()
                end

            end
        )

end

local function setAutoKill(Enabled)

    AutoKill =
        Enabled

    if not AutoKill then
        CurrentKillTarget = nil
        stopAutoKillShovelAnimation()
        setAutoKillSpeed(false)
        AutoKillShovel = nil
        AutoKillPumpkinTarget = nil
    end

    updateAutoKillButton()

    if AutoKill then
        startAutoKillLoop()
    end

    updateStatus()
end

--============================================================--
-- CREATE CONFIG
--============================================================--

local function createConfig(Name)

    local SeedList = {}
    local GearList = {}

    for ItemName, Selected in pairs(
        SelectedSeeds
    ) do

        if Selected then
            table.insert(
                SeedList,
                ItemName
            )
        end

    end

    for ItemName, Selected in pairs(
        SelectedGears
    ) do

        if Selected then
            table.insert(
                GearList,
                ItemName
            )
        end

    end

    table.sort(SeedList)
    table.sort(GearList)

    return {

        Version = 3,

        Name = Name,

        CurrentTab =
            CurrentTab,

        SeedSearch =
            SeedSearch,

        GearSearch =
            GearSearch,

        RecipeSearch =
            RecipeSearch,

        SelectedSeeds =
            SeedList,

        SelectedGears =
            GearList,

        SelectedRecipe =
            SelectedRecipe,

        AutoBuy =
            AutoBuy,

        AutoBuyMode =
            AutoBuyMode,

        AutoBrew =
            AutoBrew,

        AutoKillMode =
            AutoKillMode,

        AutoSaveFailedCraft =
            AutoSaveFailedCraft,

        PurchaseDelay =
            SETTINGS.PurchaseDelay,

        CycleDelay =
            SETTINGS.CycleDelay,

        BrewCheckDelay =
            SETTINGS.BrewCheckDelay,

        AutoLoad =
            false,
    }
end

--============================================================--
-- APPLY CONFIG
--============================================================--

local function applyConfig(Config)

    if type(Config) ~= "table" then
        return false
    end

    table.clear(
        SelectedSeeds
    )

    table.clear(
        SelectedGears
    )

    --========================================--
    -- SEEDS
    --========================================--

    if type(Config.SelectedSeeds)
        == "table" then

        for _, ItemName in ipairs(
            Config.SelectedSeeds
        ) do

            if type(ItemName)
                == "string" then

                SelectedSeeds[
                    ItemName
                ] = true

            end

        end

    end

    --========================================--
    -- GEAR
    --========================================--

    if type(Config.SelectedGears)
        == "table" then

        for _, ItemName in ipairs(
            Config.SelectedGears
        ) do

            if type(ItemName)
                == "string" then

                SelectedGears[
                    ItemName
                ] = true

            end

        end

    end

    --========================================--
    -- TAB
    --========================================--

    if Config.CurrentTab == "Seeds"
        or Config.CurrentTab == "Gear"
        or Config.CurrentTab == "Brew"
        or Config.CurrentTab == "Kill" then

        CurrentTab =
            Config.CurrentTab

    end

    --========================================--
    -- SEARCH
    --========================================--

    if type(Config.SeedSearch)
        == "string" then

        SeedSearch =
            Config.SeedSearch

    end

    if type(Config.GearSearch)
        == "string" then

        GearSearch =
            Config.GearSearch

    end

    if type(Config.RecipeSearch)
        == "string" then

        RecipeSearch =
            Config.RecipeSearch

    end

    --========================================--
    -- RECIPE
    --========================================--

    if type(Config.SelectedRecipe)
        == "string"
        and Config.SelectedRecipe ~= "" then

        if getRecipeByName(
            Config.SelectedRecipe
        ) then

            SelectedRecipe =
                Config.SelectedRecipe

        else

            SelectedRecipe =
                nil

        end

    else

        SelectedRecipe =
            nil

    end

    --========================================--
    -- AUTO BUY MODE
    --========================================--

    if Config.AutoBuyMode
        == "ALL"
        or Config.AutoBuyMode
        == "SELECTED" then

        AutoBuyMode =
            Config.AutoBuyMode

    end

    if Config.AutoKillMode
        == "ALL"
        or Config.AutoKillMode
        == "SELECTED" then

        AutoKillMode =
            Config.AutoKillMode

    end

    --========================================--
    -- DELAYS
    --========================================--

    if type(Config.PurchaseDelay)
        == "number" then

        SETTINGS.PurchaseDelay =
            math.clamp(
                Config.PurchaseDelay,
                0.05,
                10
            )

    end

    if type(Config.CycleDelay)
        == "number" then

        SETTINGS.CycleDelay =
            math.clamp(
                Config.CycleDelay,
                0.1,
                30
            )

    end

    if type(Config.BrewCheckDelay)
        == "number" then

        SETTINGS.BrewCheckDelay =
            math.clamp(
                Config.BrewCheckDelay,
                0.25,
                10
            )

    end

    --========================================--
    -- DO NOT AUTO START DURING LOAD
    --========================================--

    AutoBuy =
        false

    AutoBrew =
        false

    AutoKill =
        false

    updateAutoButton()
    updateBrewAutoButton()
    updateAutoKillButton()

    --========================================--
    -- MODE
    --========================================--

    if AutoBuyMode == "ALL" then

        ModeButton.Text =
            "MODE: BUY ALL"

    else

        ModeButton.Text =
            "MODE: BUY SELECTED"

    end

    --========================================--
    -- TAB UI
    --========================================--

    if CurrentTab == "Seeds" then

        SeedTab.BackgroundColor3 =
            Color3.fromRGB(
                75,
                55,
                155
            )

        GearTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        BrewTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        SearchBox.Text =
            SeedSearch

        SearchBox.PlaceholderText =
            "🔎 Search seeds..."

    elseif CurrentTab == "Gear" then

        SeedTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        GearTab.BackgroundColor3 =
            Color3.fromRGB(
                75,
                55,
                155
            )

        BrewTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        SearchBox.Text =
            GearSearch

        SearchBox.PlaceholderText =
            "🔎 Search gear..."

    else

        SeedTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        GearTab.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        BrewTab.BackgroundColor3 =
            Color3.fromRGB(
                75,
                55,
                155
            )

        SearchBox.Text =
            RecipeSearch

        SearchBox.PlaceholderText =
            "🔎 Search recipes..."

    end

    if CurrentTab == "Kill" then
        ModeButton.Text = AutoKillMode == "ALL"
            and "TARGET MODE: ALL"
            or "TARGET MODE: SELECTED"
    end

    renderList()

    return true
end

--============================================================--
-- CONFIG LIST
--============================================================--

local function renderConfigs()

    for _, Child in ipairs(
        ConfigList:GetChildren()
    ) do

        if Child:IsA("TextButton")
            or Child:IsA("TextLabel") then

            Child:Destroy()

        end

    end

    local Names = {}

    for Name in pairs(Configs) do

        table.insert(
            Names,
            Name
        )

    end

    table.sort(
        Names,
        function(A, B)

            return string.lower(A)
                < string.lower(B)

        end
    )

    if #Names == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Size =
            UDim2.new(
                1,
                -10,
                0,
                40
            )

        Empty.BackgroundTransparency =
            1

        Empty.Text =
            "No saved configs"

        Empty.TextColor3 =
            Color3.fromRGB(
                120,
                120,
                135
            )

        Empty.Font =
            Enum.Font.Gotham

        Empty.TextSize =
            11

        Empty.ZIndex =
            22

        Empty.Parent =
            ConfigList

        return
    end

    for _, Name in ipairs(Names) do

        local Row =
            Instance.new("TextButton")

        Row.Size =
            UDim2.new(
                1,
                -10,
                0,
                32
            )

        Row.BackgroundColor3 =
            SelectedConfigName == Name
            and Color3.fromRGB(
                65,
                48,
                115
            )
            or Color3.fromRGB(
                25,
                25,
                32
            )

        Row.BorderSizePixel =
            0

        Row.Text =
            "  " .. Name

        Row.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        Row.TextSize =
            11

        Row.Font =
            Enum.Font.Gotham

        Row.TextXAlignment =
            Enum.TextXAlignment.Left

        Row.ZIndex =
            22

        Row.Parent =
            ConfigList

        local Corner =
            Instance.new("UICorner")

        Corner.CornerRadius =
            UDim.new(
                0,
                6
            )

        Corner.Parent =
            Row

        Row.MouseButton1Click:Connect(
            function()

                SelectedConfigName =
                    Name

                SelectedLabel.Text =
                    "Selected: " .. Name

                local Config =
                    Configs[Name]

                if Config
                    and Config.AutoLoad == true then

                    AutoLoadEnabled =
                        true

                    AutoLoadButton.Text =
                        "AUTO LOAD: ON"

                    AutoLoadButton.BackgroundColor3 =
                        Color3.fromRGB(
                            30,
                            75,
                            45
                        )

                else

                    AutoLoadEnabled =
                        false

                    AutoLoadButton.Text =
                        "AUTO LOAD: OFF"

                    AutoLoadButton.BackgroundColor3 =
                        Color3.fromRGB(
                            35,
                            34,
                            45
                        )

                end

                renderConfigs()

            end
        )

    end
end

--============================================================--
-- SAVE CONFIG
--============================================================--

SaveButton.MouseButton1Click:Connect(
    function()

        local Name =
            ConfigNameBox.Text

        Name =
            Name:gsub(
                "^%s+",
                ""
            )

        Name =
            Name:gsub(
                "%s+$",
                ""
            )

        if Name == "" then

            ConfigStatus.Text =
                "Enter a config name."

            return
        end

        if #Name > 40 then

            Name =
                string.sub(
                    Name,
                    1,
                    40
                )

        end

        Configs[Name] =
            createConfig(Name)

        SelectedConfigName =
            Name

        saveConfigFile()

        ConfigNameBox.Text =
            Name

        SelectedLabel.Text =
            "Selected: " .. Name

        ConfigStatus.Text =
            "Saved: " .. Name

        renderConfigs()

    end
)

--============================================================--
-- LOAD CONFIG
--============================================================--

LoadButton.MouseButton1Click:Connect(
    function()

        if not SelectedConfigName then

            ConfigStatus.Text =
                "Select a config first."

            return
        end

        local Config =
            Configs[
                SelectedConfigName
            ]

        if not Config then

            ConfigStatus.Text =
                "Config not found."

            return
        end

        local Success =
            applyConfig(
                Config
            )

        if Success then

            ConfigStatus.Text =
                "Loaded: "
                .. SelectedConfigName

        else

            ConfigStatus.Text =
                "Could not load config."

        end

    end
)

--============================================================--
-- DELETE CONFIG
--============================================================--

DeleteButton.MouseButton1Click:Connect(
    function()

        if not SelectedConfigName then

            ConfigStatus.Text =
                "Select a config first."

            return
        end

        local Name =
            SelectedConfigName

        Configs[Name] =
            nil

        SelectedConfigName =
            nil

        AutoLoadEnabled =
            false

        saveConfigFile()

        SelectedLabel.Text =
            "No config selected"

        AutoLoadButton.Text =
            "AUTO LOAD: OFF"

        AutoLoadButton.BackgroundColor3 =
            Color3.fromRGB(
                35,
                34,
                45
            )

        ConfigStatus.Text =
            "Deleted: " .. Name

        renderConfigs()

    end
)

--============================================================--
-- AUTO LOAD
--============================================================--

AutoLoadButton.MouseButton1Click:Connect(
    function()

        if not SelectedConfigName then

            ConfigStatus.Text =
                "Select a config first."

            return
        end

        AutoLoadEnabled =
            not AutoLoadEnabled

        for _, Config in pairs(
            Configs
        ) do

            if type(Config)
                == "table" then

                Config.AutoLoad =
                    false

            end

        end

        if AutoLoadEnabled then

            if Configs[
                SelectedConfigName
            ] then

                Configs[
                    SelectedConfigName
                ].AutoLoad =
                    true

            end

            AutoLoadButton.Text =
                "AUTO LOAD: ON"

            AutoLoadButton.BackgroundColor3 =
                Color3.fromRGB(
                    30,
                    75,
                    45
                )

            ConfigStatus.Text =
                "Auto Load: "
                .. SelectedConfigName

        else

            AutoLoadButton.Text =
                "AUTO LOAD: OFF"

            AutoLoadButton.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    34,
                    45
                )

            ConfigStatus.Text =
                "Auto Load disabled."

        end

        saveConfigFile()
        renderConfigs()

    end
)

--============================================================--
-- COPY CONFIG
--============================================================--

CopyButton.MouseButton1Click:Connect(
    function()

        if not SelectedConfigName then

            ConfigStatus.Text =
                "Select a config first."

            return
        end

        local Config =
            Configs[
                SelectedConfigName
            ]

        if not Config then

            ConfigStatus.Text =
                "Config not found."

            return
        end

        local Success, JSON =
            pcall(
                function()

                    return
                        HttpService:JSONEncode(
                            Config
                        )

                end
            )

        if not Success then

            ConfigStatus.Text =
                "Could not encode config."

            return
        end

        local Code =
            "KYOSHCFG2:"
            .. JSON

        local Copied =
            copyText(
                Code
            )

        if Copied then

            ConfigStatus.Text =
                "Config code copied!"

        else

            ImportBox.Text =
                Code

            ConfigStatus.Text =
                "Copy unavailable. Code placed below."

        end

    end
)

--============================================================--
-- IMPORT CONFIG
--============================================================--

ImportButton.MouseButton1Click:Connect(
    function()

        local Code =
            ImportBox.Text

        Code =
            Code:gsub(
                "^%s+",
                ""
            )

        Code =
            Code:gsub(
                "%s+$",
                ""
            )

        if Code == "" then

            ConfigStatus.Text =
                "Paste a config code."

            return
        end

        if string.sub(
            Code,
            1,
            10
        ) == "KYOSHCFG2:" then

            Code =
                string.sub(
                    Code,
                    11
                )

        elseif string.sub(
            Code,
            1,
            10
        ) == "KYOSHCFG1:" then

            Code =
                string.sub(
                    Code,
                    11
                )

        end

        local Success, Config =
            pcall(
                function()

                    return
                        HttpService:JSONDecode(
                            Code
                        )

                end
            )

        if not Success
            or type(Config)
            ~= "table" then

            ConfigStatus.Text =
                "Invalid config code."

            return
        end

        local Name =
            tostring(
                Config.Name
                or "Imported Config"
            )

        if Name == "" then
            Name =
                "Imported Config"
        end

        local OriginalName =
            Name

        local Number =
            2

        while Configs[Name] do

            Name =
                OriginalName
                .. " "
                .. tostring(Number)

            Number += 1

        end

        Config.Name =
            Name

        Configs[Name] =
            Config

        SelectedConfigName =
            Name

        saveConfigFile()

        ConfigNameBox.Text =
            Name

        SelectedLabel.Text =
            "Selected: " .. Name

        ConfigStatus.Text =
            "Imported: " .. Name

        renderConfigs()

    end
)

--============================================================--
-- CONFIG OPEN
--============================================================--

ConfigButton.MouseButton1Click:Connect(
    function()

        Main.Visible =
            false

        ConfigFrame.Visible =
            true

        renderConfigs()

    end
)

--============================================================--
-- CONFIG CLOSE
--============================================================--

ConfigClose.MouseButton1Click:Connect(
    function()

        ConfigFrame.Visible =
            false

        Main.Visible =
            true

        renderList()

    end
)

--============================================================--
-- SHOP MODE
--============================================================--

ModeButton.MouseButton1Click:Connect(
    function()

        if CurrentTab == "Kill" then

            if AutoKillMode == "ALL" then
                AutoKillMode = "SELECTED"
                ModeButton.Text = "TARGET MODE: SELECTED"
            else
                AutoKillMode = "ALL"
                ModeButton.Text = "TARGET MODE: ALL"
            end

            renderMonsterList()
            updateStatus()
            return
        end

        if AutoBuyMode == "ALL" then

            AutoBuyMode = "SELECTED"
            ModeButton.Text = "MODE: BUY SELECTED"

        else

            AutoBuyMode = "ALL"
            ModeButton.Text = "MODE: BUY ALL"

        end

        updateStatus()

    end
)

--============================================================--
-- TAB SWITCH
--============================================================--

local function switchTab(Tab)

    CurrentTab = Tab

    local Active = Color3.fromRGB(75, 55, 155)
    local Inactive = Color3.fromRGB(35, 34, 45)

    SeedTab.BackgroundColor3 = Tab == "Seeds" and Active or Inactive
    GearTab.BackgroundColor3 = Tab == "Gear" and Active or Inactive
    BrewTab.BackgroundColor3 = Tab == "Brew" and Active or Inactive
    KillTab.BackgroundColor3 = Tab == "Kill" and Active or Inactive

    if Tab == "Seeds" then

        SearchBox.Text = SeedSearch
        SearchBox.PlaceholderText = "🔎 Search seeds..."
        ModeButton.Visible = true
        ModeButton.Text = AutoBuyMode == "ALL"
            and "MODE: BUY ALL"
            or "MODE: BUY SELECTED"
        AutoButton.Visible = true
        BrewAutoButton.Visible = false
        BrewSaveButton.Visible = false
        AutoKillButton.Visible = false
        InfoLabel.Text = "AFK AUTO BUY"

    elseif Tab == "Gear" then

        SearchBox.Text = GearSearch
        SearchBox.PlaceholderText = "🔎 Search gear..."
        ModeButton.Visible = true
        ModeButton.Text = AutoBuyMode == "ALL"
            and "MODE: BUY ALL"
            or "MODE: BUY SELECTED"
        AutoButton.Visible = true
        BrewAutoButton.Visible = false
        BrewSaveButton.Visible = false
        AutoKillButton.Visible = false
        InfoLabel.Text = "AFK AUTO BUY"

    elseif Tab == "Brew" then

        SearchBox.Text = RecipeSearch
        SearchBox.PlaceholderText = "🔎 Search recipes..."
        ModeButton.Visible = false
        AutoButton.Visible = false
        BrewAutoButton.Visible = true
        BrewSaveButton.Visible = true
        AutoKillButton.Visible = false
        InfoLabel.Text = SelectedRecipe
            and ("RECIPE • " .. SelectedRecipe)
            or "SELECT A RECIPE"

    else

        SearchBox.Text = RecipeSearch
        SearchBox.PlaceholderText = "🔎 Search monsters..."
        ModeButton.Visible = true
        AutoButton.Visible = false
        BrewAutoButton.Visible = false
        BrewSaveButton.Visible = false
        AutoKillButton.Visible = true
        ModeButton.Text = AutoKillMode == "ALL"
            and "TARGET MODE: ALL"
            or "TARGET MODE: SELECTED"
        InfoLabel.Text = "MONSTER AUTO KILL"

    end

    renderList()
end

SeedTab.MouseButton1Click:Connect(
    function()
        switchTab("Seeds")
    end
)

GearTab.MouseButton1Click:Connect(
    function()
        switchTab("Gear")
    end
)

BrewTab.MouseButton1Click:Connect(
    function()
        switchTab("Brew")
    end
)

KillTab.MouseButton1Click:Connect(
    function()
        switchTab("Kill")
    end
)

--============================================================--
-- SEARCH
--============================================================--

SearchBox:GetPropertyChangedSignal(
    "Text"
):Connect(
    function()

        if CurrentTab == "Seeds" then

            SeedSearch =
                SearchBox.Text

        elseif CurrentTab == "Gear" then

            GearSearch =
                SearchBox.Text

        elseif CurrentTab == "Brew" then

            RecipeSearch =
                SearchBox.Text

        elseif CurrentTab == "Kill" then

            RecipeSearch =
                SearchBox.Text

        end

        renderList()

    end
)

--============================================================--
-- REFRESH
--============================================================--

RefreshButton.MouseButton1Click:Connect(
    function()

        Status.Text =
            "Refreshing..."

        task.wait(0.1)

        renderList()

        task.wait(0.2)

        updateStatus()

    end
)

--============================================================--
-- AUTO BUY
--============================================================--

AutoButton.MouseButton1Click:Connect(
    function()

        setAutoBuy(
            not AutoBuy
        )

    end
)

--============================================================--
-- AUTO BREW
--============================================================--

BrewAutoButton.MouseButton1Click:Connect(
    function()

        if not SelectedRecipe then

            Status.Text =
                "SELECT A RECIPE FIRST"

            return
        end

        setAutoBrew(
            not AutoBrew
        )

    end
)

--============================================================--
-- AUTO KILL
--============================================================--

AutoKillButton.MouseButton1Click:Connect(
    function()
        setAutoKill(not AutoKill)
    end
)

--============================================================--
-- AUTO SAVE
--============================================================--

BrewSaveButton.MouseButton1Click:Connect(
    function()

        AutoSaveFailedCraft =
            not AutoSaveFailedCraft

        updateBrewSaveButton()

        if AutoSaveFailedCraft then

            Status.Text =
                "AUTO SAVE FAILED CRAFT: ON"

        else

            Status.Text =
                "AUTO SAVE FAILED CRAFT: OFF"

        end

    end
)

--============================================================--
-- DYNAMIC SHOP ITEMS
--============================================================--

SeedItemsFolder.ChildAdded:Connect(
    function()

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

SeedItemsFolder.ChildRemoved:Connect(
    function(Child)

        SelectedSeeds[
            Child.Name
        ] = nil

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

GearItemsFolder.ChildAdded:Connect(
    function()

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

GearItemsFolder.ChildRemoved:Connect(
    function(Child)

        SelectedGears[
            Child.Name
        ] = nil

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

--============================================================--
-- DYNAMIC MONSTERS
--============================================================--

CollectionService:GetInstanceAddedSignal("Monster"):Connect(
    function(Monster)
        task.wait(0.1)
        if not Destroyed and CurrentTab == "Kill" then
            renderMonsterList()
        end
    end
)

CollectionService:GetInstanceRemovedSignal("Monster"):Connect(
    function(Monster)
        local Id = getMonsterId(Monster)
        if Id ~= nil then
            SelectedMonsters[tostring(Id)] = nil
        end
        task.wait(0.1)
        if not Destroyed and CurrentTab == "Kill" then
            renderMonsterList()
        end
    end
)

local MonstersFolder = workspace:FindFirstChild("Monsters")

if MonstersFolder then

    MonstersFolder.ChildAdded:Connect(
        function()
            task.wait(0.1)
            if not Destroyed and CurrentTab == "Kill" then
                renderMonsterList()
            end
        end
    )

    MonstersFolder.ChildRemoved:Connect(
        function(Monster)
            if CurrentKillTarget == Monster then
                CurrentKillTarget = nil
            end
            task.wait(0.1)
            if not Destroyed and CurrentTab == "Kill" then
                renderMonsterList()
            end
        end
    )

end

--============================================================--
-- CLOSE
--============================================================--

CloseButton.MouseButton1Click:Connect(
    function()

        Destroyed =
            true

        AutoBuy =
            false

        AutoBrew =
            false

        AutoKill =
            false

        stopAutoKillShovelAnimation()
        setAutoKillSpeed(false)
        AutoKillShovel = nil
        AutoKillPumpkinTarget = nil

        if ScreenGui then
            ScreenGui:Destroy()
        end

    end
)

--============================================================--
-- CAMERA RESPONSIVE
--============================================================--

local function connectCamera()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    Camera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(
        function()

            updateScale()

        end
    )

end

workspace:GetPropertyChangedSignal(
    "CurrentCamera"
):Connect(
    function()

        task.wait()

        connectCamera()

        updateScale()

    end
)

--============================================================--
-- INITIALIZE
--============================================================--

updateScale()

updateAutoButton()

updateBrewAutoButton()

updateAutoKillButton()

updateBrewSaveButton()

renderList()

renderConfigs()

--============================================================--
-- AUTO LOAD
--============================================================--

task.defer(
    function()

        local AutoConfigName =
            nil

        for Name, Config in pairs(
            Configs
        ) do

            if type(Config)
                == "table"
                and Config.AutoLoad
                == true then

                AutoConfigName =
                    Name

                break

            end

        end

        if AutoConfigName then

            local Config =
                Configs[
                    AutoConfigName
                ]

            SelectedConfigName =
                AutoConfigName

            applyConfig(
                Config
            )

            ConfigStatus.Text =
                "Auto loaded: "
                .. AutoConfigName

            -- Automation intentionally stays OFF
            -- after loading a configuration.
            AutoBuy =
                false

            AutoBrew =
                false

            AutoKill =
                false

            updateAutoButton()

            updateBrewAutoButton()

            updateAutoKillButton()

            updateStatus()

        end

    end
)

--============================================================--
-- DEBUG
--============================================================--

print(
    "=========================================="
)

print(
    "KYOSH // GHOUL GARDEN"
)

print(
    "MOBILE + PC RESPONSIVE"
)

print(
    "SEEDS + GEAR + AUTO BUY"
)

print(
    "CAULDRON AUTO BREW"
)

print(
    "MONSTER AUTO KILL + CHASE"
)

print(
    "Configs:",
    #getItems(SeedItemsFolder),
    "Seeds"
)

print(
    "Gear:",
    #getItems(GearItemsFolder)
)

print(
    "Recipes:",
    #getCauldronRecipes()
)

print(
    "Config Count:",
    #Configs
)

print(
    "File System:",
    FileSystemAvailable
)

print(
    "UI Scale:",
    MainScale.Scale
)

print(
    "=========================================="
)
