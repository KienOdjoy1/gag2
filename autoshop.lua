--============================================================--
-- KYOSH // GHOUL GARDEN
-- MOBILE + PC RESPONSIVE VERSION
-- AFK AUTO BUY + CONFIG MANAGER
--============================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--============================================================--
-- SETTINGS
--============================================================--

local SETTINGS = {
    PurchaseDelay = 0.35,
    CycleDelay = 1
}

local CONFIG_FOLDER = "KYOSH"
local CONFIG_FILE = CONFIG_FOLDER .. "/GhoulGardenConfigs.json"

--============================================================--
-- GAME REFERENCES
--============================================================--

local StockValues = ReplicatedStorage:WaitForChild("StockValues")

local SeedShop = StockValues:WaitForChild("SeedShop")
local GearShop = StockValues:WaitForChild("GearShop")

local SeedItemsFolder = SeedShop:WaitForChild("Items")
local GearItemsFolder = GearShop:WaitForChild("Items")

local Packet = require(
    ReplicatedStorage
        :WaitForChild("SharedModules")
        :WaitForChild("Packet")
)

local PurchaseSeed = Packet("PurchaseSeed", Packet.String)
local PurchaseGear = Packet("PurchaseGear", Packet.String)

--============================================================--
-- STATE
--============================================================--

local CurrentTab = "Seeds"

local SelectedSeeds = {}
local SelectedGears = {}

local SeedSearch = ""
local GearSearch = ""

local AutoBuy = false
local AutoBuyMode = "ALL"
local AutoBuyThread = nil

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

    local success, result = pcall(function()

        local data = readfile(CONFIG_FILE)

        if not data or data == "" then
            return {}
        end

        return HttpService:JSONDecode(data)

    end)

    if success and type(result) == "table" then
        return result
    end

    return {}
end

local function saveConfigFile()

    if not ensureConfigFolder() then
        return false
    end

    local success = pcall(function()

        writefile(
            CONFIG_FILE,
            HttpService:JSONEncode(Configs)
        )

    end)

    return success
end

Configs = loadConfigFile()

--============================================================--
-- CLIPBOARD
--============================================================--

local function copyText(text)

    if type(setclipboard) == "function" then

        local success = pcall(function()
            setclipboard(text)
        end)

        if success then
            return true
        end
    end

    if type(toclipboard) == "function" then

        local success = pcall(function()
            toclipboard(text)
        end)

        if success then
            return true
        end
    end

    return false
end

--============================================================--
-- ITEM HELPERS
--============================================================--

local function getItems(folder)

    local items = {}

    for _, object in ipairs(folder:GetChildren()) do

        if object.Name and object.Name ~= "" then

            table.insert(
                items,
                object.Name
            )

        end
    end

    table.sort(items, function(a, b)

        return string.lower(a)
            < string.lower(b)

    end)

    return items
end

local function matchesSearch(name, search)

    if search == "" then
        return true
    end

    return string.find(
        string.lower(name),
        string.lower(search),
        1,
        true
    ) ~= nil
end

local function countSelected(selection)

    local count = 0

    for _, selected in pairs(selection) do

        if selected then
            count += 1
        end

    end

    return count
end

--============================================================--
-- REMOVE OLD GUI
--============================================================--

local ExistingGui =
    PlayerGui:FindFirstChild("KYOSH_GhoulGarden")

if ExistingGui then
    ExistingGui:Destroy()
end

--============================================================--
-- SCREEN GUI
--============================================================--

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "KYOSH_GhoulGarden"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = false

ScreenGui.Parent = PlayerGui

--============================================================--
-- RESPONSIVE SCALE
--============================================================--

local MainScale = Instance.new("UIScale")
MainScale.Name = "ResponsiveScale"
MainScale.Parent = ScreenGui

local function updateScale()

    if Destroyed then
        return
    end

    local Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    local Viewport = Camera.ViewportSize

    local Width = Viewport.X
    local Height = Viewport.Y

    -- Designed around a 390x700 reference phone.
    local WidthScale = Width / 390
    local HeightScale = Height / 700

    local Scale = math.min(
        WidthScale,
        HeightScale
    )

    -- Prevent extremely tiny UI.
    Scale = math.clamp(
        Scale,
        0.68,
        1.15
    )

    -- PC/tablet gets normal size.
    if Width >= 800 then
        Scale = 1
    end

    MainScale.Scale = Scale
end

--============================================================--
-- MAIN FRAME
--============================================================--

local Main = Instance.new("Frame")

Main.Name = "Main"

Main.Size = UDim2.fromOffset(
    350,
    535
)

Main.AnchorPoint = Vector2.new(
    0.5,
    0.5
)

Main.Position = UDim2.fromScale(
    0.5,
    0.5
)

Main.BackgroundColor3 =
    Color3.fromRGB(18, 18, 23)

Main.BorderSizePixel = 0

Main.Parent = ScreenGui

--============================================================--
-- MAIN CORNER
--============================================================--

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 10)

MainCorner.Parent = Main

--============================================================--
-- MAIN STROKE
--============================================================--

local MainStroke = Instance.new("UIStroke")

MainStroke.Color =
    Color3.fromRGB(110, 80, 255)

MainStroke.Thickness = 1.5

MainStroke.Parent = Main

--============================================================--
-- TOP BAR
--============================================================--

local TopBar = Instance.new("Frame")

TopBar.Size =
    UDim2.new(1, 0, 0, 42)

TopBar.BackgroundColor3 =
    Color3.fromRGB(25, 24, 33)

TopBar.BorderSizePixel = 0

TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")

TopCorner.CornerRadius =
    UDim.new(0, 10)

TopCorner.Parent = TopBar

--============================================================--
-- TITLE
--============================================================--

local Title = Instance.new("TextLabel")

Title.BackgroundTransparency = 1

Title.Position =
    UDim2.fromOffset(12, 3)

Title.Size =
    UDim2.new(1, -100, 0, 20)

Title.Font =
    Enum.Font.GothamBold

Title.Text =
    "KYOSH // GHOUL GARDEN"

Title.TextColor3 =
    Color3.fromRGB(235, 235, 255)

Title.TextSize = 14

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = TopBar

--============================================================--
-- STATUS
--============================================================--

local Status = Instance.new("TextLabel")

Status.BackgroundTransparency = 1

Status.Position =
    UDim2.fromOffset(12, 23)

Status.Size =
    UDim2.new(1, -100, 0, 14)

Status.Font =
    Enum.Font.Gotham

Status.Text =
    "Ready"

Status.TextColor3 =
    Color3.fromRGB(145, 145, 160)

Status.TextSize = 10

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = TopBar

--============================================================--
-- CONFIG BUTTON
--============================================================--

local ConfigButton = Instance.new("TextButton")

ConfigButton.Size =
    UDim2.fromOffset(32, 30)

ConfigButton.Position =
    UDim2.new(1, -72, 0, 6)

ConfigButton.BackgroundColor3 =
    Color3.fromRGB(45, 40, 65)

ConfigButton.BorderSizePixel = 0

ConfigButton.Text = "⚙"

ConfigButton.TextColor3 =
    Color3.fromRGB(205, 190, 255)

ConfigButton.TextSize = 17

ConfigButton.Font =
    Enum.Font.GothamBold

ConfigButton.Parent = TopBar

local ConfigButtonCorner =
    Instance.new("UICorner")

ConfigButtonCorner.CornerRadius =
    UDim.new(0, 7)

ConfigButtonCorner.Parent =
    ConfigButton

--============================================================--
-- CLOSE BUTTON
--============================================================--

local CloseButton = Instance.new("TextButton")

CloseButton.Size =
    UDim2.fromOffset(30, 30)

CloseButton.Position =
    UDim2.new(1, -35, 0, 6)

CloseButton.BackgroundColor3 =
    Color3.fromRGB(45, 35, 45)

CloseButton.BorderSizePixel = 0

CloseButton.Text = "×"

CloseButton.TextColor3 =
    Color3.fromRGB(255, 120, 140)

CloseButton.TextSize = 20

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Parent = TopBar

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 7)

CloseCorner.Parent =
    CloseButton

--============================================================--
-- DRAG SYSTEM
-- PC + MOBILE
--============================================================--

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true

        DragStart =
            input.Position

        StartPosition =
            Main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                Dragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not Dragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.MouseMovement

        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local Delta =
        input.Position - DragStart

    Main.Position =
        UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

end)

--============================================================--
-- TABS
--============================================================--

local Tabs = Instance.new("Frame")

Tabs.BackgroundTransparency = 1

Tabs.Position =
    UDim2.fromOffset(10, 50)

Tabs.Size =
    UDim2.new(1, -20, 0, 35)

Tabs.Parent = Main

--============================================================--
-- SEED TAB
--============================================================--

local SeedTab = Instance.new("TextButton")

SeedTab.Size =
    UDim2.new(0.5, -3, 1, 0)

SeedTab.BackgroundColor3 =
    Color3.fromRGB(75, 55, 155)

SeedTab.BorderSizePixel = 0

SeedTab.Text = "🌱 SEEDS"

SeedTab.TextColor3 =
    Color3.new(1, 1, 1)

SeedTab.TextSize = 12

SeedTab.Font =
    Enum.Font.GothamBold

SeedTab.Parent = Tabs

local SeedTabCorner =
    Instance.new("UICorner")

SeedTabCorner.CornerRadius =
    UDim.new(0, 7)

SeedTabCorner.Parent =
    SeedTab

--============================================================--
-- GEAR TAB
--============================================================--

local GearTab = Instance.new("TextButton")

GearTab.Size =
    UDim2.new(0.5, -3, 1, 0)

GearTab.Position =
    UDim2.new(0.5, 3, 0, 0)

GearTab.BackgroundColor3 =
    Color3.fromRGB(35, 34, 45)

GearTab.BorderSizePixel = 0

GearTab.Text = "⚙ GEAR"

GearTab.TextColor3 =
    Color3.new(1, 1, 1)

GearTab.TextSize = 12

GearTab.Font =
    Enum.Font.GothamBold

GearTab.Parent = Tabs

local GearTabCorner =
    Instance.new("UICorner")

GearTabCorner.CornerRadius =
    UDim.new(0, 7)

GearTabCorner.Parent =
    GearTab

--============================================================--
-- SEARCH BOX
--============================================================--

local SearchBox = Instance.new("TextBox")

SearchBox.Position =
    UDim2.fromOffset(10, 92)

SearchBox.Size =
    UDim2.new(1, -20, 0, 34)

SearchBox.BackgroundColor3 =
    Color3.fromRGB(28, 28, 36)

SearchBox.BorderSizePixel = 0

SearchBox.ClearTextOnFocus = false

SearchBox.PlaceholderText =
    "🔎 Search seeds..."

SearchBox.PlaceholderColor3 =
    Color3.fromRGB(120, 120, 135)

SearchBox.Text = ""

SearchBox.TextColor3 =
    Color3.fromRGB(240, 240, 250)

SearchBox.TextSize = 12

SearchBox.Font =
    Enum.Font.Gotham

SearchBox.Parent = Main

local SearchCorner =
    Instance.new("UICorner")

SearchCorner.CornerRadius =
    UDim.new(0, 7)

SearchCorner.Parent =
    SearchBox

--============================================================--
-- ITEM LIST
--============================================================--

local ItemList = Instance.new("ScrollingFrame")

ItemList.Position =
    UDim2.fromOffset(10, 132)

ItemList.Size =
    UDim2.new(1, -20, 0, 245)

ItemList.BackgroundColor3 =
    Color3.fromRGB(14, 14, 19)

ItemList.BorderSizePixel = 0

ItemList.ScrollBarThickness = 4

ItemList.ScrollBarImageColor3 =
    Color3.fromRGB(100, 75, 230)

ItemList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

ItemList.CanvasSize =
    UDim2.new()

ItemList.Parent = Main

local ItemListCorner =
    Instance.new("UICorner")

ItemListCorner.CornerRadius =
    UDim.new(0, 7)

ItemListCorner.Parent =
    ItemList

local ItemLayout =
    Instance.new("UIListLayout")

ItemLayout.Padding =
    UDim.new(0, 4)

ItemLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

ItemLayout.Parent =
    ItemList

local ItemPadding =
    Instance.new("UIPadding")

ItemPadding.PaddingTop =
    UDim.new(0, 5)

ItemPadding.PaddingBottom =
    UDim.new(0, 5)

ItemPadding.PaddingLeft =
    UDim.new(0, 5)

ItemPadding.PaddingRight =
    UDim.new(0, 5)

ItemPadding.Parent =
    ItemList

--============================================================--
-- MODE BUTTON
--============================================================--

local ModeButton = Instance.new("TextButton")

ModeButton.Position =
    UDim2.fromOffset(10, 387)

ModeButton.Size =
    UDim2.new(1, -20, 0, 34)

ModeButton.BackgroundColor3 =
    Color3.fromRGB(35, 34, 45)

ModeButton.BorderSizePixel = 0

ModeButton.Text =
    "MODE: BUY ALL"

ModeButton.TextColor3 =
    Color3.fromRGB(225, 225, 235)

ModeButton.TextSize = 11

ModeButton.Font =
    Enum.Font.GothamBold

ModeButton.Parent = Main

local ModeCorner =
    Instance.new("UICorner")

ModeCorner.CornerRadius =
    UDim.new(0, 7)

ModeCorner.Parent =
    ModeButton

--============================================================--
-- AUTO BUTTON
--============================================================--

local AutoButton = Instance.new("TextButton")

AutoButton.Position =
    UDim2.fromOffset(10, 427)

AutoButton.Size =
    UDim2.new(1, -20, 0, 42)

AutoButton.BackgroundColor3 =
    Color3.fromRGB(55, 35, 65)

AutoButton.BorderSizePixel = 0

AutoButton.Text =
    "🔴 AUTO BUY: OFF"

AutoButton.TextColor3 =
    Color3.fromRGB(255, 150, 165)

AutoButton.TextSize = 13

AutoButton.Font =
    Enum.Font.GothamBold

AutoButton.Parent = Main

local AutoCorner =
    Instance.new("UICorner")

AutoCorner.CornerRadius =
    UDim.new(0, 8)

AutoCorner.Parent =
    AutoButton

local AutoStroke =
    Instance.new("UIStroke")

AutoStroke.Color =
    Color3.fromRGB(100, 55, 100)

AutoStroke.Thickness = 1

AutoStroke.Parent =
    AutoButton

--============================================================--
-- REFRESH
--============================================================--

local RefreshButton = Instance.new("TextButton")

RefreshButton.Position =
    UDim2.fromOffset(10, 477)

RefreshButton.Size =
    UDim2.new(0.5, -15, 0, 34)

RefreshButton.BackgroundColor3 =
    Color3.fromRGB(35, 34, 45)

RefreshButton.BorderSizePixel = 0

RefreshButton.Text =
    "↻ REFRESH"

RefreshButton.TextColor3 =
    Color3.fromRGB(225, 225, 235)

RefreshButton.TextSize = 11

RefreshButton.Font =
    Enum.Font.GothamBold

RefreshButton.Parent =
    Main

local RefreshCorner =
    Instance.new("UICorner")

RefreshCorner.CornerRadius =
    UDim.new(0, 7)

RefreshCorner.Parent =
    RefreshButton

--============================================================--
-- INFO
--============================================================--

local InfoLabel = Instance.new("TextLabel")

InfoLabel.Position =
    UDim2.new(0.5, 5, 0, 477)

InfoLabel.Size =
    UDim2.new(0.5, -15, 0, 34)

InfoLabel.BackgroundTransparency = 1

InfoLabel.Text =
    "AFK AUTO BUY"

InfoLabel.TextColor3 =
    Color3.fromRGB(120, 120, 135)

InfoLabel.TextSize = 10

InfoLabel.Font =
    Enum.Font.Gotham

InfoLabel.Parent =
    Main

--============================================================--
-- CONFIG FRAME
--============================================================--

local ConfigFrame = Instance.new("Frame")

ConfigFrame.Name =
    "ConfigFrame"

ConfigFrame.Size =
    UDim2.fromOffset(350, 535)

ConfigFrame.AnchorPoint =
    Vector2.new(0.5, 0.5)

ConfigFrame.Position =
    UDim2.fromScale(0.5, 0.5)

ConfigFrame.BackgroundColor3 =
    Color3.fromRGB(18, 18, 23)

ConfigFrame.BorderSizePixel = 0

ConfigFrame.Visible = false

ConfigFrame.ZIndex = 20

ConfigFrame.Parent = ScreenGui

local ConfigFrameCorner =
    Instance.new("UICorner")

ConfigFrameCorner.CornerRadius =
    UDim.new(0, 10)

ConfigFrameCorner.Parent =
    ConfigFrame

local ConfigFrameStroke =
    Instance.new("UIStroke")

ConfigFrameStroke.Color =
    Color3.fromRGB(110, 80, 255)

ConfigFrameStroke.Thickness = 1.5

ConfigFrameStroke.Parent =
    ConfigFrame

--============================================================--
-- CONFIG HEADER
--============================================================--

local ConfigHeader = Instance.new("Frame")

ConfigHeader.Size =
    UDim2.new(1, 0, 0, 42)

ConfigHeader.BackgroundColor3 =
    Color3.fromRGB(25, 24, 33)

ConfigHeader.BorderSizePixel = 0

ConfigHeader.ZIndex = 21

ConfigHeader.Parent =
    ConfigFrame

local ConfigTitle = Instance.new("TextLabel")

ConfigTitle.BackgroundTransparency = 1

ConfigTitle.Position =
    UDim2.fromOffset(12, 0)

ConfigTitle.Size =
    UDim2.new(1, -55, 1, 0)

ConfigTitle.Text =
    "⚙ KYOSH CONFIG MANAGER"

ConfigTitle.TextColor3 =
    Color3.fromRGB(235, 235, 255)

ConfigTitle.TextSize = 13

ConfigTitle.Font =
    Enum.Font.GothamBold

ConfigTitle.TextXAlignment =
    Enum.TextXAlignment.Left

ConfigTitle.ZIndex = 22

ConfigTitle.Parent =
    ConfigHeader

local ConfigClose =
    Instance.new("TextButton")

ConfigClose.Size =
    UDim2.fromOffset(30, 30)

ConfigClose.Position =
    UDim2.new(1, -35, 0, 6)

ConfigClose.BackgroundColor3 =
    Color3.fromRGB(45, 35, 45)

ConfigClose.BorderSizePixel = 0

ConfigClose.Text = "×"

ConfigClose.TextColor3 =
    Color3.fromRGB(255, 120, 140)

ConfigClose.TextSize = 20

ConfigClose.Font =
    Enum.Font.GothamBold

ConfigClose.ZIndex = 22

ConfigClose.Parent =
    ConfigHeader

local ConfigCloseCorner =
    Instance.new("UICorner")

ConfigCloseCorner.CornerRadius =
    UDim.new(0, 7)

ConfigCloseCorner.Parent =
    ConfigClose

--============================================================--
-- CONFIG DRAG
--============================================================--

local ConfigDragging = false
local ConfigDragStart
local ConfigStartPosition

ConfigHeader.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or input.UserInputType ==
        Enum.UserInputType.Touch then

        ConfigDragging = true

        ConfigDragStart =
            input.Position

        ConfigStartPosition =
            ConfigFrame.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                ConfigDragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not ConfigDragging then
        return
    end

    if input.UserInputType ~=
        Enum.UserInputType.MouseMovement

        and input.UserInputType ~=
        Enum.UserInputType.Touch then

        return
    end

    local Delta =
        input.Position - ConfigDragStart

    ConfigFrame.Position =
        UDim2.new(
            ConfigStartPosition.X.Scale,
            ConfigStartPosition.X.Offset + Delta.X,
            ConfigStartPosition.Y.Scale,
            ConfigStartPosition.Y.Offset + Delta.Y
        )

end)

--============================================================--
-- CONFIG NAME
--============================================================--

local ConfigNameBox =
    Instance.new("TextBox")

ConfigNameBox.Position =
    UDim2.fromOffset(10, 55)

ConfigNameBox.Size =
    UDim2.new(1, -20, 0, 36)

ConfigNameBox.BackgroundColor3 =
    Color3.fromRGB(28, 28, 36)

ConfigNameBox.BorderSizePixel = 0

ConfigNameBox.ClearTextOnFocus = false

ConfigNameBox.PlaceholderText =
    "Config name..."

ConfigNameBox.PlaceholderColor3 =
    Color3.fromRGB(120, 120, 135)

ConfigNameBox.Text = ""

ConfigNameBox.TextColor3 =
    Color3.fromRGB(240, 240, 250)

ConfigNameBox.TextSize = 12

ConfigNameBox.Font =
    Enum.Font.Gotham

ConfigNameBox.ZIndex = 21

ConfigNameBox.Parent =
    ConfigFrame

local ConfigNameCorner =
    Instance.new("UICorner")

ConfigNameCorner.CornerRadius =
    UDim.new(0, 7)

ConfigNameCorner.Parent =
    ConfigNameBox

--============================================================--
-- CONFIG LIST
--============================================================--

local ConfigList =
    Instance.new("ScrollingFrame")

ConfigList.Position =
    UDim2.fromOffset(10, 101)

ConfigList.Size =
    UDim2.new(1, -20, 0, 210)

ConfigList.BackgroundColor3 =
    Color3.fromRGB(14, 14, 19)

ConfigList.BorderSizePixel = 0

ConfigList.ScrollBarThickness = 4

ConfigList.ScrollBarImageColor3 =
    Color3.fromRGB(100, 75, 230)

ConfigList.AutomaticCanvasSize =
    Enum.AutomaticSize.Y

ConfigList.CanvasSize =
    UDim2.new()

ConfigList.ZIndex = 21

ConfigList.Parent =
    ConfigFrame

local ConfigListCorner =
    Instance.new("UICorner")

ConfigListCorner.CornerRadius =
    UDim.new(0, 7)

ConfigListCorner.Parent =
    ConfigList

local ConfigLayout =
    Instance.new("UIListLayout")

ConfigLayout.Padding =
    UDim.new(0, 4)

ConfigLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

ConfigLayout.Parent =
    ConfigList

local ConfigPadding =
    Instance.new("UIPadding")

ConfigPadding.PaddingTop =
    UDim.new(0, 5)

ConfigPadding.PaddingBottom =
    UDim.new(0, 5)

ConfigPadding.PaddingLeft =
    UDim.new(0, 5)

ConfigPadding.PaddingRight =
    UDim.new(0, 5)

ConfigPadding.Parent =
    ConfigList

--============================================================--
-- CONFIG STATUS
--============================================================--

local ConfigStatus =
    Instance.new("TextLabel")

ConfigStatus.Position =
    UDim2.fromOffset(10, 320)

ConfigStatus.Size =
    UDim2.new(1, -20, 0, 25)

ConfigStatus.BackgroundTransparency = 1

ConfigStatus.Text =
    FileSystemAvailable
    and "Local config storage available"
    or "Executor file storage unavailable"

ConfigStatus.TextColor3 =
    Color3.fromRGB(125, 125, 140)

ConfigStatus.TextSize = 10

ConfigStatus.Font =
    Enum.Font.Gotham

ConfigStatus.ZIndex = 21

ConfigStatus.Parent =
    ConfigFrame

--============================================================--
-- CONFIG BUTTON CREATOR
--============================================================--

local function createConfigButton(
    text,
    x,
    y,
    width
)

    local button =
        Instance.new("TextButton")

    button.Position =
        UDim2.fromOffset(x, y)

    button.Size =
        UDim2.fromOffset(width, 34)

    button.BackgroundColor3 =
        Color3.fromRGB(35, 34, 45)

    button.BorderSizePixel = 0

    button.Text = text

    button.TextColor3 =
        Color3.fromRGB(230, 230, 240)

    button.TextSize = 10

    button.Font =
        Enum.Font.GothamBold

    button.ZIndex = 21

    button.Parent =
        ConfigFrame

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 7)

    corner.Parent =
        button

    return button
end

--============================================================--
-- CONFIG BUTTONS
--============================================================--

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
-- IMPORT BOX
--============================================================--

local ImportBox =
    Instance.new("TextBox")

ImportBox.Position =
    UDim2.fromOffset(10, 438)

ImportBox.Size =
    UDim2.new(1, -20, 0, 36)

ImportBox.BackgroundColor3 =
    Color3.fromRGB(28, 28, 36)

ImportBox.BorderSizePixel = 0

ImportBox.ClearTextOnFocus = false

ImportBox.PlaceholderText =
    "Paste config transfer code..."

ImportBox.Text = ""

ImportBox.TextColor3 =
    Color3.fromRGB(240, 240, 250)

ImportBox.TextSize = 10

ImportBox.Font =
    Enum.Font.Gotham

ImportBox.ZIndex = 21

ImportBox.Parent =
    ConfigFrame

local ImportCorner =
    Instance.new("UICorner")

ImportCorner.CornerRadius =
    UDim.new(0, 7)

ImportCorner.Parent =
    ImportBox

local ImportButton =
    createConfigButton(
        "IMPORT",
        10,
        480,
        105
    )

--============================================================--
-- SELECTED CONFIG LABEL
--============================================================--

local SelectedLabel =
    Instance.new("TextLabel")

SelectedLabel.Position =
    UDim2.fromOffset(120, 480)

SelectedLabel.Size =
    UDim2.new(1, -130, 0, 34)

SelectedLabel.BackgroundTransparency = 1

SelectedLabel.Text =
    "No config selected"

SelectedLabel.TextColor3 =
    Color3.fromRGB(130, 130, 145)

SelectedLabel.TextSize = 9

SelectedLabel.Font =
    Enum.Font.Gotham

SelectedLabel.TextXAlignment =
    Enum.TextXAlignment.Left

SelectedLabel.TextTruncate =
    Enum.TextTruncate.AtEnd

SelectedLabel.ZIndex = 21

SelectedLabel.Parent =
    ConfigFrame

--============================================================--
-- STATUS UPDATE
--============================================================--

local function updateStatus()

    if Destroyed then
        return
    end

    local selection

    if CurrentTab == "Seeds" then
        selection = SelectedSeeds
    else
        selection = SelectedGears
    end

    local count =
        countSelected(selection)

    if AutoBuy then

        if AutoBuyMode == "ALL" then

            Status.Text =
                "AUTO BUY ALL • "
                .. CurrentTab

        else

            Status.Text =
                "AUTO BUY SELECTED • "
                .. tostring(count)

        end

    else

        Status.Text =
            CurrentTab
            .. " • "
            .. tostring(count)
            .. " selected"

    end
end

--============================================================--
-- CLEAR ITEM LIST
--============================================================--

local function clearItemList()

    for _, child in ipairs(
        ItemList:GetChildren()
    ) do

        if child:IsA("TextButton")
            or child:IsA("TextLabel") then

            child:Destroy()

        end
    end
end

--============================================================--
-- RENDER ITEMS
--============================================================--

local function renderList()

    clearItemList()

    local folder
    local selection
    local search

    if CurrentTab == "Seeds" then

        folder =
            SeedItemsFolder

        selection =
            SelectedSeeds

        search =
            SeedSearch

    else

        folder =
            GearItemsFolder

        selection =
            SelectedGears

        search =
            GearSearch

    end

    local visibleCount = 0

    for _, itemName in ipairs(
        getItems(folder)
    ) do

        if matchesSearch(
            itemName,
            search
        ) then

            visibleCount += 1

            local IsSelected =
                selection[itemName] == true

            local Row =
                Instance.new("TextButton")

            Row.Size =
                UDim2.new(1, -10, 0, 31)

            Row.BackgroundColor3 =
                IsSelected
                and Color3.fromRGB(65, 48, 115)
                or Color3.fromRGB(25, 25, 32)

            Row.BorderSizePixel = 0

            Row.AutoButtonColor = false

            Row.Text = ""

            Row.Parent =
                ItemList

            local RowCorner =
                Instance.new("UICorner")

            RowCorner.CornerRadius =
                UDim.new(0, 6)

            RowCorner.Parent =
                Row

            local Check =
                Instance.new("TextLabel")

            Check.BackgroundTransparency = 1

            Check.Position =
                UDim2.fromOffset(8, 0)

            Check.Size =
                UDim2.fromOffset(25, 31)

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

            Check.TextSize = 15

            Check.Parent =
                Row

            local NameLabel =
                Instance.new("TextLabel")

            NameLabel.BackgroundTransparency = 1

            NameLabel.Position =
                UDim2.fromOffset(38, 0)

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
                itemName

            NameLabel.TextColor3 =
                Color3.fromRGB(
                    235,
                    235,
                    240
                )

            NameLabel.TextSize = 11

            NameLabel.TextXAlignment =
                Enum.TextXAlignment.Left

            NameLabel.TextTruncate =
                Enum.TextTruncate.AtEnd

            NameLabel.Parent =
                Row

            Row.MouseButton1Click:Connect(
                function()

                    if selection[itemName] then

                        selection[itemName] =
                            nil

                    else

                        selection[itemName] =
                            true

                    end

                    renderList()

                end
            )
        end
    end

    if visibleCount == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Size =
            UDim2.new(1, -10, 0, 40)

        Empty.BackgroundTransparency = 1

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

        Empty.TextSize = 12

        Empty.Parent =
            ItemList

    end

    updateStatus()
end

--============================================================--
-- CREATE CONFIG
--============================================================--

local function createConfig(name)

    local seedList = {}
    local gearList = {}

    for itemName, selected in pairs(
        SelectedSeeds
    ) do

        if selected then

            table.insert(
                seedList,
                itemName
            )

        end
    end

    for itemName, selected in pairs(
        SelectedGears
    ) do

        if selected then

            table.insert(
                gearList,
                itemName
            )

        end
    end

    table.sort(seedList)
    table.sort(gearList)

    return {

        Version = 1,

        Name = name,

        CurrentTab =
            CurrentTab,

        SeedSearch =
            SeedSearch,

        GearSearch =
            GearSearch,

        SelectedSeeds =
            seedList,

        SelectedGears =
            gearList,

        AutoBuy =
            AutoBuy,

        AutoBuyMode =
            AutoBuyMode,

        PurchaseDelay =
            SETTINGS.PurchaseDelay,

        CycleDelay =
            SETTINGS.CycleDelay,

        AutoLoad = false
    }
end

--============================================================--
-- AUTO BUTTON
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
-- AUTO BUY LOOP
--============================================================--

local function startAutoBuyLoop()

    if AutoBuyThread then
        return
    end

    AutoBuyThread =
        task.spawn(function()

            while AutoBuy
                and not Destroyed do

                local folder
                local selection

                if CurrentTab == "Seeds" then

                    folder =
                        SeedItemsFolder

                    selection =
                        SelectedSeeds

                else

                    folder =
                        GearItemsFolder

                    selection =
                        SelectedGears

                end

                local items =
                    getItems(folder)

                for _, itemName in ipairs(
                    items
                ) do

                    if not AutoBuy
                        or Destroyed then

                        break

                    end

                    local ShouldBuy = false

                    if AutoBuyMode ==
                        "ALL" then

                        ShouldBuy = true

                    elseif AutoBuyMode ==
                        "SELECTED" then

                        ShouldBuy =
                            selection[itemName]
                            == true

                    end

                    if ShouldBuy then

                        if CurrentTab ==
                            "Seeds" then

                            pcall(function()

                                PurchaseSeed:Fire(
                                    itemName
                                )

                            end)

                        else

                            pcall(function()

                                PurchaseGear:Fire(
                                    itemName
                                )

                            end)

                        end

                        Status.Text =
                            "AUTO BUY • "
                            .. itemName

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

            AutoBuyThread = nil

            if not Destroyed then
                updateStatus()
            end

        end)
end

--============================================================--
-- SET AUTO BUY
--============================================================--

local function setAutoBuy(enabled)

    AutoBuy = enabled

    updateAutoButton()

    if AutoBuy then

        startAutoBuyLoop()

    else

        updateStatus()

    end
end

--============================================================--
-- APPLY CONFIG
--============================================================--

local function applyConfig(config)

    if type(config) ~= "table" then
        return false
    end

    table.clear(
        SelectedSeeds
    )

    table.clear(
        SelectedGears
    )

    if type(config.SelectedSeeds)
        == "table" then

        for _, itemName in ipairs(
            config.SelectedSeeds
        ) do

            if type(itemName) ==
                "string" then

                SelectedSeeds[itemName] =
                    true

            end
        end
    end

    if type(config.SelectedGears)
        == "table" then

        for _, itemName in ipairs(
            config.SelectedGears
        ) do

            if type(itemName) ==
                "string" then

                SelectedGears[itemName] =
                    true

            end
        end
    end

    if config.CurrentTab ==
        "Seeds"

        or config.CurrentTab ==
        "Gear" then

        CurrentTab =
            config.CurrentTab

    end

    if type(config.SeedSearch) ==
        "string" then

        SeedSearch =
            config.SeedSearch

    end

    if type(config.GearSearch) ==
        "string" then

        GearSearch =
            config.GearSearch

    end

    if config.AutoBuyMode ==
        "ALL"

        or config.AutoBuyMode ==
        "SELECTED" then

        AutoBuyMode =
            config.AutoBuyMode

    end

    if type(config.PurchaseDelay) ==
        "number" then

        SETTINGS.PurchaseDelay =
            math.clamp(
                config.PurchaseDelay,
                0.05,
                10
            )

    end

    if type(config.CycleDelay) ==
        "number" then

        SETTINGS.CycleDelay =
            math.clamp(
                config.CycleDelay,
                0.1,
                30
            )

    end

    AutoBuy = false

    updateAutoButton()

    if AutoBuyMode == "ALL" then

        ModeButton.Text =
            "MODE: BUY ALL"

    else

        ModeButton.Text =
            "MODE: BUY SELECTED"

    end

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

        SearchBox.Text =
            SeedSearch

        SearchBox.PlaceholderText =
            "🔎 Search seeds..."

    else

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

        SearchBox.Text =
            GearSearch

        SearchBox.PlaceholderText =
            "🔎 Search gear..."

    end

    renderList()

    return true
end

--============================================================--
-- RENDER CONFIGS
--============================================================--

local function renderConfigs()

    for _, child in ipairs(
        ConfigList:GetChildren()
    ) do

        if child:IsA("TextButton")
            or child:IsA("TextLabel") then

            child:Destroy()

        end
    end

    local names = {}

    for name in pairs(Configs) do

        table.insert(
            names,
            name
        )

    end

    table.sort(
        names,
        function(a, b)

            return string.lower(a)
                < string.lower(b)

        end
    )

    if #names == 0 then

        local Empty =
            Instance.new("TextLabel")

        Empty.Size =
            UDim2.new(1, -10, 0, 40)

        Empty.BackgroundTransparency = 1

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

        Empty.TextSize = 11

        Empty.ZIndex = 22

        Empty.Parent =
            ConfigList

        return
    end

    for _, name in ipairs(names) do

        local Row =
            Instance.new("TextButton")

        Row.Size =
            UDim2.new(1, -10, 0, 32)

        Row.BackgroundColor3 =
            SelectedConfigName == name
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

        Row.Text =
            "  " .. name

        Row.TextColor3 =
            Color3.fromRGB(
                235,
                235,
                240
            )

        Row.TextSize = 11

        Row.Font =
            Enum.Font.Gotham

        Row.TextXAlignment =
            Enum.TextXAlignment.Left

        Row.ZIndex = 22

        Row.Parent =
            ConfigList

        local Corner =
            Instance.new("UICorner")

        Corner.CornerRadius =
            UDim.new(0, 6)

        Corner.Parent =
            Row

        Row.MouseButton1Click:Connect(
            function()

                SelectedConfigName =
                    name

                SelectedLabel.Text =
                    "Selected: " .. name

                local config =
                    Configs[name]

                if config
                    and config.AutoLoad == true then

                    AutoLoadEnabled = true

                    AutoLoadButton.Text =
                        "AUTO LOAD: ON"

                    AutoLoadButton.BackgroundColor3 =
                        Color3.fromRGB(
                            30,
                            75,
                            45
                        )

                else

                    AutoLoadEnabled = false

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

        local name =
            ConfigNameBox.Text

        name =
            name:gsub(
                "^%s+",
                ""
            )

        name =
            name:gsub(
                "%s+$",
                ""
            )

        if name == "" then

            ConfigStatus.Text =
                "Enter a config name."

            return
        end

        if #name > 40 then

            name =
                string.sub(
                    name,
                    1,
                    40
                )

        end

        Configs[name] =
            createConfig(name)

        SelectedConfigName =
            name

        saveConfigFile()

        ConfigNameBox.Text =
            name

        SelectedLabel.Text =
            "Selected: " .. name

        ConfigStatus.Text =
            "Saved: " .. name

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

        local config =
            Configs[SelectedConfigName]

        if not config then

            ConfigStatus.Text =
                "Config not found."

            return
        end

        local success =
            applyConfig(config)

        if success then

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

        local name =
            SelectedConfigName

        Configs[name] = nil

        SelectedConfigName = nil

        AutoLoadEnabled = false

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
            "Deleted: " .. name

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

        for _, config in pairs(
            Configs
        ) do

            if type(config) ==
                "table" then

                config.AutoLoad = false

            end
        end

        if AutoLoadEnabled then

            if Configs[
                SelectedConfigName
            ] then

                Configs[
                    SelectedConfigName
                ].AutoLoad = true

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

        local config =
            Configs[
                SelectedConfigName
            ]

        if not config then

            ConfigStatus.Text =
                "Config not found."

            return
        end

        local success, json =
            pcall(function()

                return HttpService:JSONEncode(
                    config
                )

            end)

        if not success then

            ConfigStatus.Text =
                "Could not encode config."

            return
        end

        local code =
            "KYOSHCFG1:" .. json

        local copied =
            copyText(code)

        if copied then

            ConfigStatus.Text =
                "Config code copied!"

        else

            ImportBox.Text =
                code

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

        local code =
            ImportBox.Text

        code =
            code:gsub(
                "^%s+",
                ""
            )

        code =
            code:gsub(
                "%s+$",
                ""
            )

        if code == "" then

            ConfigStatus.Text =
                "Paste a config code."

            return
        end

        if string.sub(
            code,
            1,
            10
        ) == "KYOSHCFG1:" then

            code =
                string.sub(
                    code,
                    11
                )

        end

        local success, config =
            pcall(function()

                return HttpService:JSONDecode(
                    code
                )

            end)

        if not success
            or type(config) ~= "table" then

            ConfigStatus.Text =
                "Invalid config code."

            return
        end

        local name =
            tostring(
                config.Name
                or "Imported Config"
            )

        if name == "" then
            name = "Imported Config"
        end

        local OriginalName =
            name

        local Number = 2

        while Configs[name] do

            name =
                OriginalName
                .. " "
                .. tostring(Number)

            Number += 1

        end

        config.Name =
            name

        Configs[name] =
            config

        SelectedConfigName =
            name

        saveConfigFile()

        ConfigNameBox.Text =
            name

        SelectedLabel.Text =
            "Selected: " .. name

        ConfigStatus.Text =
            "Imported: " .. name

        renderConfigs()

    end
)

--============================================================--
-- OPEN CONFIG
--============================================================--

ConfigButton.MouseButton1Click:Connect(
    function()

        Main.Visible = false

        ConfigFrame.Visible = true

        renderConfigs()

    end
)

--============================================================--
-- CLOSE CONFIG
--============================================================--

ConfigClose.MouseButton1Click:Connect(
    function()

        ConfigFrame.Visible = false

        Main.Visible = true

        renderList()

    end
)

--============================================================--
-- BUY MODE
--============================================================--

ModeButton.MouseButton1Click:Connect(
    function()

        if AutoBuyMode == "ALL" then

            AutoBuyMode =
                "SELECTED"

            ModeButton.Text =
                "MODE: BUY SELECTED"

        else

            AutoBuyMode =
                "ALL"

            ModeButton.Text =
                "MODE: BUY ALL"

        end

        updateStatus()

    end
)

--============================================================--
-- SWITCH TAB
--============================================================--

local function switchTab(tab)

    CurrentTab = tab

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

        SearchBox.Text =
            SeedSearch

        SearchBox.PlaceholderText =
            "🔎 Search seeds..."

    else

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

        SearchBox.Text =
            GearSearch

        SearchBox.PlaceholderText =
            "🔎 Search gear..."

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

        else

            GearSearch =
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
-- AUTO BUY BUTTON
--============================================================--

AutoButton.MouseButton1Click:Connect(
    function()

        setAutoBuy(
            not AutoBuy
        )

    end
)

--============================================================--
-- SEED CHANGES
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
    function(child)

        SelectedSeeds[
            child.Name
        ] = nil

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

--============================================================--
-- GEAR CHANGES
--============================================================--

GearItemsFolder.ChildAdded:Connect(
    function()

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

GearItemsFolder.ChildRemoved:Connect(
    function(child)

        SelectedGears[
            child.Name
        ] = nil

        task.wait(0.1)

        if not Destroyed then
            renderList()
        end

    end
)

--============================================================--
-- CLOSE EVERYTHING
--============================================================--

CloseButton.MouseButton1Click:Connect(
    function()

        Destroyed = true

        AutoBuy = false

        if ScreenGui then
            ScreenGui:Destroy()
        end

    end
)

--============================================================--
-- RESPONSIVE VIEWPORT LISTENER
--============================================================--

local function connectCamera()

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    Camera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(function()

        updateScale()

    end)

end

workspace:GetPropertyChangedSignal(
    "CurrentCamera"
):Connect(function()

    task.wait()

    connectCamera()
    updateScale()

end)

--============================================================--
-- INITIAL RENDER
--============================================================--

updateScale()

renderList()

renderConfigs()

--============================================================--
-- AUTO LOAD
--============================================================--

task.defer(
    function()

        local AutoConfigName = nil

        for name, config in pairs(
            Configs
        ) do

            if type(config) ==
                "table"

                and config.AutoLoad ==
                true then

                AutoConfigName =
                    name

                break

            end
        end

        if AutoConfigName then

            local config =
                Configs[
                    AutoConfigName
                ]

            SelectedConfigName =
                AutoConfigName

            applyConfig(config)

            ConfigStatus.Text =
                "Auto loaded: "
                .. AutoConfigName

            -- Auto Load restores settings
            -- but does NOT automatically
            -- activate Auto Buy.

            AutoBuy = false

            updateAutoButton()

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
    "AFK AUTO BUY + CONFIG MANAGER"
)

print(
    "Seeds:",
    #getItems(
        SeedItemsFolder
    )
)

print(
    "Gear:",
    #getItems(
        GearItemsFolder
    )
)

print(
    "Configs:",
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
