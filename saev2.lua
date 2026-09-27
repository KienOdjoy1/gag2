--//============================================================//

--// 🥚 EGG FPS MONITOR

--// FPS BOOST + GOD MODE

--// + BAT AUTO + COSMIC BAT

--//============================================================//

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local TweenService = game:GetService("TweenService")

local UserInputService = game:GetService("UserInputService")

local Lighting = game:GetService("Lighting")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

--//============================================================//

--// REMOVE OLD GUI

--//============================================================//

local OldGUI = PlayerGui:FindFirstChild("EggFPSMonitor")

if OldGUI then

    OldGUI:Destroy()

end

--//============================================================//

--// 🥚 KYOSH // STEAL A EGG UI

--// MOBILE-FIRST • RESPONSIVE • MINIMIZABLE

--//============================================================//

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "EggFPSMonitor"

ScreenGui.ResetOnSpawn = false

-- Respect the phone safe-area/top bar instead of occupying the whole screen.

ScreenGui.IgnoreGuiInset = false

ScreenGui.DisplayOrder = 999

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

--//============================================================//

--// MAIN WINDOW

--//============================================================//

local Main = Instance.new("Frame")

Main.Name = "Main"

-- Keep one base layout and scale the complete panel.

-- This makes every existing button/text element resize together.

local BASE_WIDTH = 370

local BASE_HEIGHT = 445

Main.Size = UDim2.fromOffset(BASE_WIDTH,BASE_HEIGHT)

Main.AnchorPoint = Vector2.new(0.5,0.5)

Main.Position = UDim2.fromScale(0.5,0.5)

Main.BackgroundColor3 = Color3.fromRGB(13,14,19)

Main.BorderSizePixel = 0

Main.Active = true

Main.ClipsDescendants = false

Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")

MainCorner.CornerRadius = UDim.new(0,18)

MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")

MainStroke.Color = Color3.fromRGB(255,205,70)

MainStroke.Thickness = 1.8

MainStroke.Transparency = 0.08

MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")

MainGradient.Color = ColorSequence.new({

    ColorSequenceKeypoint.new(0,Color3.fromRGB(22,23,31)),

    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,11,15))

})

MainGradient.Rotation = 90

MainGradient.Parent = Main

--//============================================================//

--// RESPONSIVE UI

--//============================================================//

local UIScale = Instance.new("UIScale")

UIScale.Scale = 0.88

UIScale.Parent = Main

local ResponsiveConnection = nil

local function UpdateResponsiveScale()

    local Camera = workspace.CurrentCamera

    if not Camera then

        return

    end

    local Viewport = Camera.ViewportSize

    if Viewport.X <= 0 or Viewport.Y <= 0 then

        return

    end

    -- Leave a visible margin around the panel.

    local HorizontalMargin = UserInputService.TouchEnabled and 30 or 50

    local VerticalMargin = UserInputService.TouchEnabled and 55 or 50

    local FitX =

        (Viewport.X - HorizontalMargin) / BASE_WIDTH

    local FitY =

        (Viewport.Y - VerticalMargin) / BASE_HEIGHT

    local Scale = math.min(FitX,FitY)

    if UserInputService.TouchEnabled then

        -- Phones/tablets: deliberately smaller than the available screen.

        Scale = math.min(Scale,0.84)

    else

        -- PC: keep the panel compact instead of letting it grow.

        Scale = math.min(Scale,0.92)

    end

    Scale = math.clamp(Scale,0.60,0.92)

    UIScale.Scale = Scale

    -- Re-center after rotation/resizing.

    Main.AnchorPoint = Vector2.new(0.5,0.5)

    Main.Position = UDim2.fromScale(0.5,0.5)

end

UpdateResponsiveScale()

local function ConnectViewport()

    if ResponsiveConnection then

        ResponsiveConnection:Disconnect()

        ResponsiveConnection = nil

    end

    local Camera = workspace.CurrentCamera

    if Camera then

        ResponsiveConnection =

            Camera:GetPropertyChangedSignal("ViewportSize"):Connect(

                UpdateResponsiveScale

            )

    end

end

ConnectViewport()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()

    ConnectViewport()

    task.defer(UpdateResponsiveScale)

end)

--//============================================================//

--// HEADER

--//============================================================//

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1,0,0,68)

Header.BackgroundColor3 = Color3.fromRGB(25,26,34)

Header.BorderSizePixel = 0

Header.Active = true

Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")

HeaderCorner.CornerRadius = UDim.new(0,18)

HeaderCorner.Parent = Header

local HeaderLine = Instance.new("Frame")

HeaderLine.Size = UDim2.new(1,-28,0,1)

HeaderLine.Position = UDim2.new(0,14,1,-1)

HeaderLine.BackgroundColor3 = Color3.fromRGB(255,205,70)

HeaderLine.BackgroundTransparency = 0.55

HeaderLine.BorderSizePixel = 0

HeaderLine.Parent = Header

local EggIcon = Instance.new("TextLabel")

EggIcon.Size = UDim2.new(0,50,0,52)

EggIcon.Position = UDim2.new(0,8,0,7)

EggIcon.BackgroundTransparency = 1

EggIcon.Text = "🥚"

EggIcon.TextSize = 31

EggIcon.Parent = Header

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(1,-145,0,25)

Title.Position = UDim2.new(0,58,0,7)

Title.BackgroundTransparency = 1

Title.Text = "KYOSH // STEAL A EGG"

Title.TextColor3 = Color3.fromRGB(255,215,80)

Title.TextSize = 17

Title.Font = Enum.Font.GothamBold

Title.TextXAlignment = Enum.TextXAlignment.Left

Title.Parent = Header

local Subtitle = Instance.new("TextLabel")

Subtitle.Size = UDim2.new(1,-145,0,18)

Subtitle.Position = UDim2.new(0,59,0,34)

Subtitle.BackgroundTransparency = 1

Subtitle.Text = "EGG MACRO"

Subtitle.TextColor3 = Color3.fromRGB(145,147,158)

Subtitle.TextSize = 10

Subtitle.Font = Enum.Font.GothamMedium

Subtitle.TextXAlignment = Enum.TextXAlignment.Left

Subtitle.Parent = Header

--//============================================================//

--// MINIMIZE / CLOSE

--//============================================================//

local MinimizeButton = Instance.new("TextButton")

MinimizeButton.Name = "MinimizeButton"

MinimizeButton.Size = UDim2.new(0,30,0,30)

MinimizeButton.Position = UDim2.new(1,-76,0,19)

MinimizeButton.BackgroundColor3 = Color3.fromRGB(48,49,59)

MinimizeButton.Text = "—"

MinimizeButton.TextColor3 = Color3.fromRGB(255,215,80)

MinimizeButton.TextSize = 17

MinimizeButton.Font = Enum.Font.GothamBold

MinimizeButton.BorderSizePixel = 0

MinimizeButton.AutoButtonColor = false

MinimizeButton.Parent = Header

local MinCorner = Instance.new("UICorner")

MinCorner.CornerRadius = UDim.new(0,9)

MinCorner.Parent = MinimizeButton

local CloseButton = Instance.new("TextButton")

CloseButton.Name = "CloseButton"

CloseButton.Size = UDim2.new(0,30,0,30)

CloseButton.Position = UDim2.new(1,-40,0,19)

CloseButton.BackgroundColor3 = Color3.fromRGB(48,49,59)

CloseButton.Text = "×"

CloseButton.TextColor3 = Color3.fromRGB(255,115,115)

CloseButton.TextSize = 20

CloseButton.Font = Enum.Font.GothamBold

CloseButton.BorderSizePixel = 0

CloseButton.AutoButtonColor = false

CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")

CloseCorner.CornerRadius = UDim.new(0,9)

CloseCorner.Parent = CloseButton

--//============================================================//

--// CATEGORY BAR

--//============================================================//

local CategoryBar = Instance.new("Frame")

CategoryBar.Size = UDim2.new(1,-20,0,38)

CategoryBar.Position = UDim2.new(0,10,0,78)

CategoryBar.BackgroundTransparency = 1

CategoryBar.Parent = Main

local function MakeTab(Name,Text,Position)

    local Button = Instance.new("TextButton")

    Button.Name = Name

    Button.Size = UDim2.new(0.5,-4,1,0)

    Button.Position = Position

    Button.BackgroundColor3 = Color3.fromRGB(32,33,43)

    Button.Text = Text

    Button.TextColor3 = Color3.fromRGB(160,162,174)

    Button.TextSize = 11

    Button.Font = Enum.Font.GothamBold

    Button.BorderSizePixel = 0

    Button.AutoButtonColor = false

    Button.Parent = CategoryBar

    local Corner = Instance.new("UICorner")

    Corner.CornerRadius = UDim.new(0,10)

    Corner.Parent = Button

    return Button

end

local HomeButton = MakeTab("HomeButton","🏠  OVERVIEW",UDim2.new(0,0,0,0))

local FPSButton = MakeTab("FPSButton","⚡  FEATURES",UDim2.new(0.5,4,0,0))

FPSButton.BackgroundColor3 = Color3.fromRGB(255,195,60)

FPSButton.TextColor3 = Color3.fromRGB(25,25,25)

--//============================================================//

--// HOME PAGE

--//============================================================//

local HomePage = Instance.new("Frame")

HomePage.Size = UDim2.new(1,-20,0,315)

HomePage.Position = UDim2.new(0,10,0,128)

HomePage.BackgroundTransparency = 1

HomePage.Visible = false

HomePage.Parent = Main

local HomeTitle = Instance.new("TextLabel")

HomeTitle.Size = UDim2.new(1,0,0,30)

HomeTitle.BackgroundTransparency = 1

HomeTitle.Text = "🥚  STEAL A EGG // READY"

HomeTitle.TextColor3 = Color3.fromRGB(238,239,244)

HomeTitle.TextSize = 14

HomeTitle.Font = Enum.Font.GothamBold

HomeTitle.TextXAlignment = Enum.TextXAlignment.Left

HomeTitle.Parent = HomePage

local HomeInfo = Instance.new("TextLabel")

HomeInfo.Size = UDim2.new(1,0,0,225)

HomeInfo.Position = UDim2.new(0,0,0,42)

HomeInfo.BackgroundTransparency = 1

HomeInfo.Text =

    "KYOSH // STEAL A EGG\n\n" ..

    "A compact control panel for performance,\n" ..

    "protection, movement and Bat utilities.\n\n" ..

    "🛡  GOD MODE     Protect your Humanoid\n" ..

    "⚡  FPS BOOST    One-way visual optimization\n" ..

    "🦇  BAT AUTO     Automatic Bat interaction\n" ..

    "🌌  COSMIC BAT   Visual Bat selector\n\n" ..

    "● SYSTEM STATUS: ONLINE"

HomeInfo.TextColor3 = Color3.fromRGB(164,166,177)

HomeInfo.TextSize = 12

HomeInfo.Font = Enum.Font.Gotham

HomeInfo.TextXAlignment = Enum.TextXAlignment.Left

HomeInfo.TextYAlignment = Enum.TextYAlignment.Top

HomeInfo.Parent = HomePage

--//============================================================//

--// FEATURES PAGE

--//============================================================//

local FPSPage = Instance.new("Frame")

FPSPage.Size = UDim2.new(1,-20,0,315)

FPSPage.Position = UDim2.new(0,10,0,128)

FPSPage.BackgroundTransparency = 1

FPSPage.Visible = true

FPSPage.Parent = Main

local FPSBox = Instance.new("Frame")

FPSBox.Size = UDim2.new(0.48,0,0,62)

FPSBox.BackgroundColor3 = Color3.fromRGB(27,29,37)

FPSBox.BorderSizePixel = 0

FPSBox.Parent = FPSPage

local FPSBoxCorner = Instance.new("UICorner")

FPSBoxCorner.CornerRadius = UDim.new(0,11)

FPSBoxCorner.Parent = FPSBox

local FPSAccent = Instance.new("Frame")

FPSAccent.Size = UDim2.new(0,3,1,-20)

FPSAccent.Position = UDim2.new(0,8,0,10)

FPSAccent.BackgroundColor3 = Color3.fromRGB(100,255,130)

FPSAccent.BorderSizePixel = 0

FPSAccent.Parent = FPSBox

local FPSLabel = Instance.new("TextLabel")

FPSLabel.Size = UDim2.new(1,-24,1,0)

FPSLabel.Position = UDim2.new(0,18,0,0)

FPSLabel.BackgroundTransparency = 1

FPSLabel.Text = "FPS: --"

FPSLabel.TextColor3 = Color3.fromRGB(100,255,130)

FPSLabel.TextSize = 20

FPSLabel.Font = Enum.Font.GothamBold

FPSLabel.Parent = FPSBox

local PingBox = Instance.new("Frame")

PingBox.Size = UDim2.new(0.48,0,0,62)

PingBox.Position = UDim2.new(0.52,0,0,0)

PingBox.BackgroundColor3 = Color3.fromRGB(27,29,37)

PingBox.BorderSizePixel = 0

PingBox.Parent = FPSPage

local PingCorner = Instance.new("UICorner")

PingCorner.CornerRadius = UDim.new(0,11)

PingCorner.Parent = PingBox

local PingAccent = Instance.new("Frame")

PingAccent.Size = UDim2.new(0,3,1,-20)

PingAccent.Position = UDim2.new(0,8,0,10)

PingAccent.BackgroundColor3 = Color3.fromRGB(255,205,70)

PingAccent.BorderSizePixel = 0

PingAccent.Parent = PingBox

local PingLabel = Instance.new("TextLabel")

PingLabel.Size = UDim2.new(1,-24,1,0)

PingLabel.Position = UDim2.new(0,18,0,0)

PingLabel.BackgroundTransparency = 1

PingLabel.Text = "PING: --"

PingLabel.TextColor3 = Color3.fromRGB(255,215,80)

PingLabel.TextSize = 20

PingLabel.Font = Enum.Font.GothamBold

PingLabel.Parent = PingBox

local StatusLabel = Instance.new("TextLabel")

StatusLabel.Size = UDim2.new(1,0,0,22)

StatusLabel.Position = UDim2.new(0,0,0,73)

StatusLabel.BackgroundTransparency = 1

StatusLabel.Text = "● SYSTEM ONLINE"

StatusLabel.TextColor3 = Color3.fromRGB(100,255,130)

StatusLabel.TextSize = 11

StatusLabel.Font = Enum.Font.GothamBold

StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

StatusLabel.Parent = FPSPage

--//============================================================//

--// BUTTON HELPER

--//============================================================//

local function MakeButton(Name,Text,Position,IsToggle)

    local Button = Instance.new("TextButton")

    Button.Name = Name

    Button.Size = UDim2.new(0.48,0,0,42)

    Button.Position = Position

    Button.BackgroundColor3 = Color3.fromRGB(35,36,46)

    Button.Text = Text

    Button.TextColor3 = Color3.fromRGB(238,239,244)

    Button.TextSize = 11

    Button.Font = Enum.Font.GothamBold

    Button.TextXAlignment = Enum.TextXAlignment.Left

    Button.BorderSizePixel = 0

    Button.AutoButtonColor = false

    Button.Parent = FPSPage

    local Corner = Instance.new("UICorner")

    Corner.CornerRadius = UDim.new(0,10)

    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")

    Stroke.Color = Color3.fromRGB(65,66,78)

    Stroke.Thickness = 1

    Stroke.Transparency = 0.2

    Stroke.Parent = Button

    if IsToggle then

        Button.Text = Text

        Button.TextXAlignment = Enum.TextXAlignment.Left

        local ToggleTrack = Instance.new("Frame")

        ToggleTrack.Name = "ToggleTrack"

        ToggleTrack.Size = UDim2.new(0,62,0,30)

        ToggleTrack.Position = UDim2.new(1,-70,0.5,-15)

        ToggleTrack.BackgroundColor3 = Color3.fromRGB(18,19,25)

        ToggleTrack.BorderSizePixel = 0

        ToggleTrack.Parent = Button

        local TrackCorner = Instance.new("UICorner")

        TrackCorner.CornerRadius = UDim.new(1,0)

        TrackCorner.Parent = ToggleTrack

        local TrackStroke = Instance.new("UIStroke")

        TrackStroke.Name = "ToggleStroke"

        TrackStroke.Color = Color3.fromRGB(255,205,35)

        TrackStroke.Thickness = 1.5

        TrackStroke.Transparency = 0

        TrackStroke.Parent = ToggleTrack

        local ToggleKnob = Instance.new("Frame")

        ToggleKnob.Name = "ToggleKnob"

        ToggleKnob.Size = UDim2.new(0,24,0,24)

        ToggleKnob.Position = UDim2.new(0,3,0.5,-12)

        ToggleKnob.BackgroundColor3 = Color3.fromRGB(248,248,245)

        ToggleKnob.BorderSizePixel = 0

        ToggleKnob.Parent = ToggleTrack

        local KnobCorner = Instance.new("UICorner")

        KnobCorner.CornerRadius = UDim.new(1,0)

        KnobCorner.Parent = ToggleKnob

        local KnobStroke = Instance.new("UIStroke")

        KnobStroke.Color = Color3.fromRGB(255,220,120)

        KnobStroke.Thickness = 1

        KnobStroke.Transparency = 0.15

        KnobStroke.Parent = ToggleKnob

        local ToggleGlow = Instance.new("UIGradient")

        ToggleGlow.Color = ColorSequence.new({

            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),

            ColorSequenceKeypoint.new(1,Color3.fromRGB(225,225,220))

        })

        ToggleGlow.Rotation = 90

        ToggleGlow.Parent = ToggleKnob

    end

    return Button

end

local function SetToggleVisual(Button,Enabled)

    local ToggleTrack = Button:FindFirstChild("ToggleTrack")

    local ToggleKnob = ToggleTrack and ToggleTrack:FindFirstChild("ToggleKnob")

    local ToggleStroke = ToggleTrack and ToggleTrack:FindFirstChild("ToggleStroke")

    if not ToggleTrack or not ToggleKnob then

        return

    end

    local TargetPosition

    if Enabled then

        TargetPosition = UDim2.new(1,-27,0.5,-12)

    else

        TargetPosition = UDim2.new(0,3,0.5,-12)

    end

    TweenService:Create(

        ToggleKnob,

        TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),

        {Position = TargetPosition}

    ):Play()

    ToggleTrack.BackgroundColor3 =

        Enabled and Color3.fromRGB(28,31,24) or Color3.fromRGB(18,19,25)

    if ToggleStroke then

        ToggleStroke.Color =

            Enabled and Color3.fromRGB(255,205,35) or Color3.fromRGB(150,125,35)

        ToggleStroke.Thickness = Enabled and 1.8 or 1.5

    end

end

local GodModeButton = MakeButton("GodModeButton","  GOD MODE",UDim2.new(0,0,0,102),true)

local FPSBoostButton = MakeButton("FPSBoostButton","  FPS BOOST",UDim2.new(0.52,0,0,102),true)

local BatAutoButton = MakeButton("BatAutoButton","  BAT AUTO",UDim2.new(0,0,0,151),true)

local BatVisualButton = MakeButton("BatVisualButton","  BAT VISUAL: OFF",UDim2.new(0.52,0,0,151))

local InstantSafeButton = MakeButton("InstantSafeButton","  INSTANT SAFE",UDim2.new(0,0,0,200),true)

SetToggleVisual(GodModeButton,false)

SetToggleVisual(FPSBoostButton,false)

SetToggleVisual(BatAutoButton,false)

SetToggleVisual(InstantSafeButton,false)

--//============================================================//

--// MOBILE MINIMIZED BUTTON

--//============================================================//

local MiniButton = Instance.new("TextButton")

MiniButton.Name = "MiniButton"

MiniButton.Size = UDim2.new(0,58,0,58)

MiniButton.Position = UDim2.new(0,18,0.72,0)

MiniButton.BackgroundColor3 = Color3.fromRGB(20,21,28)

MiniButton.Text = "🥚"

MiniButton.TextSize = 29

MiniButton.TextColor3 = Color3.fromRGB(255,215,80)

MiniButton.BorderSizePixel = 0

MiniButton.AutoButtonColor = false

MiniButton.Visible = false

MiniButton.Active = true

MiniButton.Parent = ScreenGui

-- Smaller floating button on phones so it does not dominate the screen.

if UserInputService.TouchEnabled then

    MiniButton.Size = UDim2.fromOffset(52,52)

    MiniButton.TextSize = 25

    MiniButton.Position = UDim2.new(0,14,1,-66)

else

    MiniButton.Size = UDim2.fromOffset(58,58)

    MiniButton.Position = UDim2.new(0,18,1,-76)

end

local MiniCorner = Instance.new("UICorner")

MiniCorner.CornerRadius = UDim.new(0,17)

MiniCorner.Parent = MiniButton

local MiniStroke = Instance.new("UIStroke")

MiniStroke.Color = Color3.fromRGB(255,205,70)

MiniStroke.Thickness = 2

MiniStroke.Parent = MiniButton

--//============================================================//

--// MINIMIZE / RESTORE

--//============================================================//

local function SetMinimized(State)

    Main.Visible = not State

    MiniButton.Visible = State

end

MinimizeButton.MouseButton1Click:Connect(function()

    SetMinimized(true)

end)

MiniButton.MouseButton1Click:Connect(function()

    SetMinimized(false)

end)

CloseButton.MouseButton1Click:Connect(function()

    ScreenGui:Destroy()

end)

--//============================================================//

--// DRAG SUPPORT — MOUSE + TOUCH

--//============================================================//

local function MakeDraggable(Object,Handle)

    local Dragging = false

    local DragStart = nil

    local StartPosition = nil

    local function ClampToViewport()

        local Camera = workspace.CurrentCamera

        if not Camera then

            return

        end

        local Viewport = Camera.ViewportSize

        local Size = Object.AbsoluteSize

        local Anchor = Object.AnchorPoint

        local MinX =

            (Size.X * Anchor.X) + 8

        local MaxX =

            Viewport.X - (Size.X * (1 - Anchor.X)) - 8

        local MinY =

            (Size.Y * Anchor.Y) + 8

        local MaxY =

            Viewport.Y - (Size.Y * (1 - Anchor.Y)) - 8

        local X = math.clamp(

            Object.AbsolutePosition.X + (Size.X * Anchor.X),

            MinX,

            math.max(MinX,MaxX)

        )

        local Y = math.clamp(

            Object.AbsolutePosition.Y + (Size.Y * Anchor.Y),

            MinY,

            math.max(MinY,MaxY)

        )

        Object.Position = UDim2.fromOffset(X,Y)

    end

    Handle.InputBegan:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1

        or Input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true

            DragStart = Input.Position

            StartPosition = Object.Position

            Input.Changed:Connect(function()

                if Input.UserInputState == Enum.UserInputState.End then

                    Dragging = false

                    ClampToViewport()

                end

            end)

        end

    end)

    UserInputService.InputChanged:Connect(function(Input)

        if not Dragging then

            return

        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement

        and Input.UserInputType ~= Enum.UserInputType.Touch then

            return

        end

        local Delta = Input.Position - DragStart

        Object.Position = UDim2.new(

            StartPosition.X.Scale,

            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,

            StartPosition.Y.Offset + Delta.Y

        )

    end)

end

MakeDraggable(Main,Header)

MakeDraggable(MiniButton,MiniButton)

--//============================================================//

--// TAB SWITCHING

--//============================================================//

local function SelectTab(Tab)

    if Tab == "Home" then

        HomePage.Visible = true

        FPSPage.Visible = false

        HomeButton.BackgroundColor3 = Color3.fromRGB(255,195,60)

        HomeButton.TextColor3 = Color3.fromRGB(25,25,25)

        FPSButton.BackgroundColor3 = Color3.fromRGB(32,33,43)

        FPSButton.TextColor3 = Color3.fromRGB(160,162,174)

    else

        HomePage.Visible = false

        FPSPage.Visible = true

        HomeButton.BackgroundColor3 = Color3.fromRGB(32,33,43)

        HomeButton.TextColor3 = Color3.fromRGB(160,162,174)

        FPSButton.BackgroundColor3 = Color3.fromRGB(255,195,60)

        FPSButton.TextColor3 = Color3.fromRGB(25,25,25)

    end

end

HomeButton.MouseButton1Click:Connect(function()

    SelectTab("Home")

end)

FPSButton.MouseButton1Click:Connect(function()

    SelectTab("FPS")

end)

SelectTab("FPS")

--//============================================================//
--// 🖤 KYOSH PREMIUM / PORTFOLIO UI RESTYLE
--//============================================================//

-- Premium palette
local UI_BG       = Color3.fromRGB(12, 11, 11)
local UI_PANEL    = Color3.fromRGB(20, 18, 17)
local UI_CARD     = Color3.fromRGB(28, 25, 23)
local UI_CARD2    = Color3.fromRGB(34, 30, 27)
local UI_WHITE    = Color3.fromRGB(245, 243, 239)
local UI_MUTED    = Color3.fromRGB(155, 149, 143)
local UI_ORANGE   = Color3.fromRGB(232, 137, 61)
local UI_ORANGE2  = Color3.fromRGB(255, 174, 91)
local UI_GREEN    = Color3.fromRGB(108, 225, 143)

--//============================================================//
--// MAIN WINDOW
--//============================================================//

BASE_WIDTH = 560
BASE_HEIGHT = 460
Main.Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT)
Main.BackgroundColor3 = UI_BG
MainStroke.Color = Color3.fromRGB(104, 76, 55)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.15
MainCorner.CornerRadius = UDim.new(0, 24)
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 21, 19)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(18, 15, 14)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
})
MainGradient.Rotation = 135

--//============================================================//
--// AMBIENT GLOW
--//============================================================//

local AmbientGlow = Instance.new("Frame")
AmbientGlow.Name = "AmbientGlow"
AmbientGlow.Size = UDim2.fromOffset(360, 300)
AmbientGlow.Position = UDim2.new(0, -100, 0, 30)
AmbientGlow.BackgroundColor3 = Color3.fromRGB(115, 54, 24)
AmbientGlow.BackgroundTransparency = 0.82
AmbientGlow.BorderSizePixel = 0
AmbientGlow.ZIndex = 0
AmbientGlow.Parent = Main

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(1, 0)
GlowCorner.Parent = AmbientGlow

local GlowRight = Instance.new("Frame")
GlowRight.Name = "GlowRight"
GlowRight.Size = UDim2.fromOffset(280, 250)
GlowRight.Position = UDim2.new(1, -180, 0, 120)
GlowRight.BackgroundColor3 = Color3.fromRGB(85, 43, 25)
GlowRight.BackgroundTransparency = 0.88
GlowRight.BorderSizePixel = 0
GlowRight.ZIndex = 0
GlowRight.Parent = Main

local GlowRightCorner = Instance.new("UICorner")
GlowRightCorner.CornerRadius = UDim.new(1, 0)
GlowRightCorner.Parent = GlowRight

--//============================================================//
--// HEADER
--//============================================================//

Header.BackgroundTransparency = 1
Header.Size = UDim2.new(1, 0, 0, 92)
HeaderLine.BackgroundColor3 = UI_ORANGE
HeaderLine.BackgroundTransparency = 0.35
HeaderLine.Size = UDim2.new(1, -40, 0, 1)
HeaderLine.Position = UDim2.new(0, 20, 1, -1)
EggIcon.Visible = false

local EntryLabel = Instance.new("TextLabel")
EntryLabel.Name = "EntryLabel"
EntryLabel.Size = UDim2.new(0, 250, 0, 16)
EntryLabel.Position = UDim2.new(0, 24, 0, 12)
EntryLabel.BackgroundTransparency = 1
EntryLabel.Text = "●  KYOSH // EGG UTILITY"
EntryLabel.TextColor3 = UI_ORANGE2
EntryLabel.TextSize = 9
EntryLabel.Font = Enum.Font.GothamBold
EntryLabel.TextXAlignment = Enum.TextXAlignment.Left
EntryLabel.ZIndex = 3
EntryLabel.Parent = Header

Title.Size = UDim2.new(1, -190, 0, 38)
Title.Position = UDim2.new(0, 22, 0, 29)
Title.Text = "KYOSH"
Title.TextColor3 = UI_WHITE
Title.TextSize = 28
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

Subtitle.Size = UDim2.new(1, -190, 0, 18)
Subtitle.Position = UDim2.new(0, 24, 0, 65)
Subtitle.Text = "PERFORMANCE  •  PROTECTION  •  CONTROL"
Subtitle.TextColor3 = UI_MUTED
Subtitle.TextSize = 8
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 3

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(0, 100, 0, 18)
VersionLabel.Position = UDim2.new(1, -125, 0, 13)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "2026 / ONLINE"
VersionLabel.TextColor3 = UI_MUTED
VersionLabel.TextSize = 8
VersionLabel.Font = Enum.Font.GothamMedium
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.ZIndex = 3
VersionLabel.Parent = Header

MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 31, 29)
MinimizeButton.BackgroundTransparency = 0.15
MinimizeButton.TextColor3 = UI_ORANGE2
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 31, 29)
CloseButton.BackgroundTransparency = 0.15
CloseButton.TextColor3 = Color3.fromRGB(235, 125, 105)

--//============================================================//
--// CATEGORY BAR
--//============================================================//

CategoryBar.Position = UDim2.new(0, 20, 0, 104)
CategoryBar.Size = UDim2.new(1, -40, 0, 34)

local TabStroke1 = Instance.new("UIStroke")
TabStroke1.Color = Color3.fromRGB(90, 69, 55)
TabStroke1.Transparency = 0.35
TabStroke1.Thickness = 1
TabStroke1.Parent = HomeButton

local TabStroke2 = Instance.new("UIStroke")
TabStroke2.Color = Color3.fromRGB(90, 69, 55)
TabStroke2.Transparency = 0.35
TabStroke2.Thickness = 1
TabStroke2.Parent = FPSButton

HomeButton.BackgroundColor3 = Color3.fromRGB(29, 25, 23)
HomeButton.TextColor3 = UI_MUTED
HomeButton.TextSize = 9
FPSButton.BackgroundColor3 = UI_ORANGE
FPSButton.TextColor3 = Color3.fromRGB(30, 22, 18)
FPSButton.TextSize = 9

HomePage.Position = UDim2.new(0, 20, 0, 150)
HomePage.Size = UDim2.new(1, -40, 0, 285)
FPSPage.Position = UDim2.new(0, 20, 0, 150)
FPSPage.Size = UDim2.new(1, -40, 0, 285)

--//============================================================//
--// FPS / PING CARDS
--//============================================================//

FPSBox.Size = UDim2.new(0.48, 0, 0, 70)
FPSBox.BackgroundColor3 = UI_CARD
FPSBox.BackgroundTransparency = 0.05
PingBox.Size = UDim2.new(0.48, 0, 0, 70)
PingBox.BackgroundColor3 = UI_CARD
PingBox.BackgroundTransparency = 0.05
FPSBoxCorner.CornerRadius = UDim.new(0, 15)
PingCorner.CornerRadius = UDim.new(0, 15)
FPSAccent.BackgroundColor3 = UI_GREEN
FPSAccent.Size = UDim2.new(0, 2, 1, -24)
FPSAccent.Position = UDim2.new(0, 10, 0, 12)
PingAccent.BackgroundColor3 = UI_ORANGE
PingAccent.Size = UDim2.new(0, 2, 1, -24)
PingAccent.Position = UDim2.new(0, 10, 0, 12)
FPSLabel.Position = UDim2.new(0, 22, 0, 0)
FPSLabel.TextColor3 = UI_WHITE
FPSLabel.TextSize = 19
FPSLabel.Font = Enum.Font.GothamBlack
PingLabel.Position = UDim2.new(0, 22, 0, 0)
PingLabel.TextColor3 = UI_ORANGE2
PingLabel.TextSize = 19
PingLabel.Font = Enum.Font.GothamBlack

StatusLabel.Position = UDim2.new(0, 2, 0, 82)
StatusLabel.Text = "●  SYSTEM ONLINE"
StatusLabel.TextColor3 = UI_GREEN
StatusLabel.TextSize = 9
StatusLabel.Font = Enum.Font.GothamBold

--//============================================================//
--// FEATURE BUTTONS
--//============================================================//

local FeatureButtons = {
    GodModeButton,
    FPSBoostButton,
    BatAutoButton,
    BatVisualButton,
    InstantSafeButton
}

for _, Button in ipairs(FeatureButtons) do
    Button.BackgroundColor3 = UI_CARD
    Button.TextColor3 = UI_WHITE
    Button.TextSize = 10

    local Stroke = Button:FindFirstChildOfClass("UIStroke")
    if Stroke then
        Stroke.Color = Color3.fromRGB(83, 65, 52)
        Stroke.Transparency = 0.25
        Stroke.Thickness = 1
    end

    local Corner = Button:FindFirstChildOfClass("UICorner")
    if Corner then
        Corner.CornerRadius = UDim.new(0, 13)
    end
end

local function PremiumToggle(Button)
    local Track = Button:FindFirstChild("ToggleTrack")
    if not Track then
        return
    end

    Track.BackgroundColor3 = Color3.fromRGB(15, 14, 13)

    local TrackStroke = Track:FindFirstChild("ToggleStroke")
    if TrackStroke then
        TrackStroke.Color = Color3.fromRGB(117, 78, 48)
        TrackStroke.Transparency = 0.15
        TrackStroke.Thickness = 1
    end

    local Knob = Track:FindFirstChild("ToggleKnob")
    if Knob then
        Knob.BackgroundColor3 = Color3.fromRGB(242, 239, 234)

        local KnobStroke = Knob:FindFirstChildOfClass("UIStroke")
        if KnobStroke then
            KnobStroke.Color = UI_ORANGE
            KnobStroke.Thickness = 1
        end
    end
end

PremiumToggle(GodModeButton)
PremiumToggle(FPSBoostButton)
PremiumToggle(BatAutoButton)
PremiumToggle(InstantSafeButton)

--//============================================================//
--// GHOST BRAND
--//============================================================//

local GhostBrand = Instance.new("TextLabel")
GhostBrand.Name = "GhostBrand"
GhostBrand.Size = UDim2.new(1, 0, 0, 100)
GhostBrand.Position = UDim2.new(0, 15, 1, -100)
GhostBrand.BackgroundTransparency = 1
GhostBrand.Text = "KYOSH"
GhostBrand.TextColor3 = Color3.fromRGB(255, 255, 255)
GhostBrand.TextTransparency = 0.95
GhostBrand.TextSize = 75
GhostBrand.Font = Enum.Font.GothamBlack
GhostBrand.TextXAlignment = Enum.TextXAlignment.Left
GhostBrand.ZIndex = 0
GhostBrand.Parent = Main


--//============================================================//
--// MINI BUTTON
--//============================================================//

MiniButton.BackgroundColor3 = Color3.fromRGB(22, 19, 18)
MiniButton.Text = "🥚"
MiniButton.TextColor3 = UI_ORANGE2
MiniStroke.Color = UI_ORANGE
MiniStroke.Thickness = 1.5

-- Recalculate the responsive scale using the new premium dimensions.
UpdateResponsiveScale()

--//============================================================//
--// ACTIVE TAB COLORS
--//============================================================//

local OriginalSelectTab = SelectTab

SelectTab = function(Tab)
    OriginalSelectTab(Tab)

    if Tab == "Home" then
        HomeButton.BackgroundColor3 = Color3.fromRGB(29, 25, 23)
        HomeButton.TextColor3 = UI_MUTED
        FPSButton.BackgroundColor3 = Color3.fromRGB(29, 25, 23)
        FPSButton.TextColor3 = UI_MUTED
    else
        HomeButton.BackgroundColor3 = Color3.fromRGB(29, 25, 23)
        HomeButton.TextColor3 = UI_MUTED
        FPSButton.BackgroundColor3 = UI_ORANGE
        FPSButton.TextColor3 = Color3.fromRGB(30, 22, 18)
    end
end

SelectTab("FPS")

--//============================================================//
--// SUBTLE HOVER EFFECT
--//============================================================//

local function AddHover(Button)
    if not Button then
        return
    end

    local Normal = Button.BackgroundColor3

    Button.MouseEnter:Connect(function()
        TweenService:Create(
            Button,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundColor3 = Color3.fromRGB(43, 36, 31)
            }
        ):Play()
    end)

    Button.MouseLeave:Connect(function()
        if Button == FPSButton then
            return
        end

        TweenService:Create(
            Button,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                BackgroundColor3 = Normal
            }
        ):Play()
    end)
end

AddHover(GodModeButton)
AddHover(FPSBoostButton)
AddHover(BatAutoButton)
AddHover(BatVisualButton)
AddHover(InstantSafeButton)

--//============================================================//

--// 🛡️ KYOSH ADVANCED GOD MODE

--// STEAL A EGG

--// Local character protection

--//============================================================//

local GOD_MODE_ENABLED = false

local GOD_HEALTH = 100

local HEALTH_CHECK_RATE = 0.05

local BLOCK_DEATH_STATE = true

local LOCK_MAX_HEALTH = true

local LOCK_HEALTH = true

local PROTECT_RESPAWNS = true

local GodData = nil

local function DisconnectGodData()

    if not GodData then

        return

    end

    if GodData.HealthConnection then

        pcall(function()

            GodData.HealthConnection:Disconnect()

        end)

    end

    if GodData.DiedConnection then

        pcall(function()

            GodData.DiedConnection:Disconnect()

        end)

    end

    if GodData.CharacterConnection then

        pcall(function()

            GodData.CharacterConnection:Disconnect()

        end)

    end

    GodData = nil

end

local function ProtectHumanoid(Humanoid)

    if not Humanoid then

        return

    end

    if not GodData then

        GodData = {}

    end

    -- Remove connections belonging to the previous Humanoid,

    -- but keep CharacterConnection alive for future respawns.

    if GodData.HealthConnection then

        pcall(function()

            GodData.HealthConnection:Disconnect()

        end)

        GodData.HealthConnection = nil

    end

    if GodData.DiedConnection then

        pcall(function()

            GodData.DiedConnection:Disconnect()

        end)

        GodData.DiedConnection = nil

    end

    GodData.Humanoid = Humanoid

    pcall(function()

        Humanoid.MaxHealth = GOD_HEALTH

        Humanoid.Health = GOD_HEALTH

    end)

    if BLOCK_DEATH_STATE then

        pcall(function()

            Humanoid:SetStateEnabled(

                Enum.HumanoidStateType.Dead,

                false

            )

        end)

    end

    if not GodData.HealthConnection then

        GodData.HealthConnection =

            Humanoid.HealthChanged:Connect(function(Health)

                if not GOD_MODE_ENABLED then

                    return

                end

                if not Humanoid.Parent then

                    return

                end

                if LOCK_HEALTH and Health < GOD_HEALTH then

                    pcall(function()

                        Humanoid.Health = GOD_HEALTH

                    end)

                end

            end)

    end

    if not GodData.DiedConnection then

        GodData.DiedConnection =

            Humanoid.Died:Connect(function()

                if not GOD_MODE_ENABLED then

                    return

                end

                task.defer(function()

                    if not Humanoid.Parent

                        or not GOD_MODE_ENABLED

                    then

                        return

                    end

                    pcall(function()

                        Humanoid:SetStateEnabled(

                            Enum.HumanoidStateType.Dead,

                            false

                        )

                        Humanoid.MaxHealth = GOD_HEALTH

                        Humanoid.Health = GOD_HEALTH

                    end)

                end)

            end)

    end

end

local function ProtectCharacter(Character)

    if not Character or not GOD_MODE_ENABLED then

        return

    end

    local Humanoid =

        Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then

        Humanoid =

            Character:WaitForChild("Humanoid",10)

    end

    if not Humanoid then

        return

    end

    ProtectHumanoid(Humanoid)

    local ThisHumanoid = Humanoid

    task.spawn(function()

        while Character.Parent

            and GOD_MODE_ENABLED

            and GodData

            and GodData.Humanoid == ThisHumanoid

        do

            if LOCK_MAX_HEALTH then

                if ThisHumanoid.MaxHealth ~= GOD_HEALTH then

                    pcall(function()

                        ThisHumanoid.MaxHealth = GOD_HEALTH

                    end)

                end

            end

            if LOCK_HEALTH then

                if ThisHumanoid.Health < GOD_HEALTH then

                    pcall(function()

                        ThisHumanoid.Health = GOD_HEALTH

                    end)

                end

            end

            if BLOCK_DEATH_STATE then

                pcall(function()

                    if ThisHumanoid:GetStateEnabled(

                        Enum.HumanoidStateType.Dead

                    ) then

                        ThisHumanoid:SetStateEnabled(

                            Enum.HumanoidStateType.Dead,

                            false

                        )

                    end

                end)

            end

            task.wait(HEALTH_CHECK_RATE)

        end

    end)

end

local function EnableGodMode()

    if GOD_MODE_ENABLED then

        return

    end

    GOD_MODE_ENABLED = true

    -- Create persistent state before protecting the current character.

    GodData = {}

    if PROTECT_RESPAWNS then

        GodData.CharacterConnection =

            Player.CharacterAdded:Connect(function(Character)

                if not GOD_MODE_ENABLED then

                    return

                end

                task.wait(0.1)

                if GOD_MODE_ENABLED then

                    ProtectCharacter(Character)

                end

            end)

        -- CharacterAdded is stored above, so reconnect protection

        -- survives until God Mode is disabled.

    end

    GodModeButton.Text = "  GOD MODE"

    GodModeButton.TextColor3 =

        Color3.fromRGB(100,255,130)

    GodModeButton.BackgroundColor3 =

        Color3.fromRGB(35,36,46)

    SetToggleVisual(GodModeButton,true)

    StatusLabel.Text =

        "● GOD MODE ACTIVE"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

end

local function DisableGodMode()

    GOD_MODE_ENABLED = false

    local OldHumanoid =

        GodData and GodData.Humanoid

    DisconnectGodData()

    if OldHumanoid and OldHumanoid.Parent then

        pcall(function()

            OldHumanoid:SetStateEnabled(

                Enum.HumanoidStateType.Dead,

                true

            )

        end)

    end

    GodModeButton.Text = "  GOD MODE"

    GodModeButton.TextColor3 =

        Color3.fromRGB(238,239,244)

    GodModeButton.BackgroundColor3 =

        Color3.fromRGB(35,36,46)

    SetToggleVisual(GodModeButton,false)

    StatusLabel.Text =

        "● SYSTEM ONLINE"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

end

GodModeButton.MouseButton1Click:Connect(function()

    if GOD_MODE_ENABLED then

        DisableGodMode()

    else

        EnableGodMode()

    end

end)

--//============================================================//

--//============================================================//

--//============================================================//

--// FPS BOOST — LOW-OVERHEAD / ONE-WAY

--//============================================================//

local FPSBoostEnabled = false

-- These folders are visual-only containers in the place.

-- They are optimized instead of repeatedly destroyed/recreated.

local RenderFolderNames = {

    ["ClientRenderedAssets"] = true,

    ["PlacedEggRenders"] = true,

    ["Stands"] = true,

    ["__ClientTreadmillRenders"] = true

}

local ObjectFolderNames = {

    ["AREAS"] = true,

    ["LEADERBOARDS"] = true,

    ["MACHINES"] = true

}

-- Objects that must remain visible because they are part of plot/gameplay.

local KeepPlotObjectsVisible = {

    ["TreadmillBottom"] = true,

    ["TreadmillUpgrade"] = true,

    ["PlotUpgrade"] = true,

    ["Multiplier"] = true

}

local ProcessedVisuals = setmetatable({}, {__mode = "k"})

local PendingVisuals = {}

local PendingVisualSet = setmetatable({}, {__mode = "k"})

local PendingHead = 1

local VisualQueueRunning = false

local function IsPlayerCharacter(Object)

    local Character = Player.Character

    if not Character or not Object then

        return false

    end

    return Object:IsDescendantOf(Character)

end

local function IsRenderFolder(Object)

    return Object

        and RenderFolderNames[Object.Name] == true

end

local function IsObjectFolder(Object)

    return Object

        and Object.Parent

        and Object.Parent.Name == "__OBJECTS"

        and ObjectFolderNames[Object.Name] == true

end

local function IsTreadmillRender(Object)

    if not Object then

        return false

    end

    if Object.Name == "__ClientTreadmillRenders" then

        return true

    end

    local Current = Object.Parent

    local Depth = 0

    while Current and Current ~= workspace and Depth < 8 do

        if Current.Name == "__ClientTreadmillRenders" then

            return true

        end

        Current = Current.Parent

        Depth += 1

    end

    return false

end

local function IsKeepPlotObject(Object)

    if not Object then

        return false

    end

    if KeepPlotObjectsVisible[Object.Name] then

        return true

    end

    local Current = Object.Parent

    local Depth = 0

    while Current and Current ~= workspace and Depth < 12 do

        if KeepPlotObjectsVisible[Current.Name] then

            return true

        end

        Current = Current.Parent

        Depth += 1

    end

    return false

end

local function IsTrapObject(Object)

    if not Object then

        return false

    end

    local Current = Object

    local Depth = 0

    while Current and Current ~= workspace and Depth < 12 do

        local Name = string.lower(Current.Name or "")

        if Name:find("trap",1,true) then

            return true

        end

        if Current:IsA("Tool") then

            local GearName = Current:GetAttribute("GearName")

            if typeof(GearName) == "string" and string.lower(GearName):find("trap",1,true) then

                return true

            end

        end

        Current = Current.Parent

        Depth += 1

    end

    return false

end

local function HideVisual(Object)

    if not Object or not Object.Parent then

        return

    end

    if IsPlayerCharacter(Object) then

        return

    end

    -- Never hide or destroy trap visuals/tools.

    if IsTrapObject(Object) then

        if Object:IsA("BasePart") then

            pcall(function()

                Object.LocalTransparencyModifier = 0

                Object.CastShadow = true

            end)

        end

        return

    end

    if IsKeepPlotObject(Object) then

        if Object:IsA("BasePart") then

            pcall(function()

                Object.LocalTransparencyModifier = 0

                Object.CastShadow = false

            end)

        end

        return

    end

    -- Keep interaction/prompts/models alive. Only remove rendering work.

    if Object:IsA("ParticleEmitter")

        or Object:IsA("Trail")

        or Object:IsA("Beam")

        or Object:IsA("Fire")

        or Object:IsA("Smoke")

        or Object:IsA("Sparkles")

    then

        pcall(function()

            Object.Enabled = false

        end)

        ProcessedVisuals[Object] = true

        return

    end

    if Object:IsA("PostEffect") then

        pcall(function()

            Object.Enabled = false

        end)

        ProcessedVisuals[Object] = true

        return

    end

    if Object:IsA("Decal") or Object:IsA("Texture") then

        pcall(function()

            Object.Transparency = 1

        end)

        ProcessedVisuals[Object] = true

        return

    end

    if Object:IsA("SurfaceAppearance") then

        pcall(function()

            Object:Destroy()

        end)

        ProcessedVisuals[Object] = true

        return

    end

    if Object:IsA("BasePart") then

        pcall(function()

            Object.LocalTransparencyModifier = 1

            Object.CastShadow = false

            Object.Reflectance = 0

        end)

        ProcessedVisuals[Object] = true

    end

end

local function IsVisualCandidate(Object)

    if not Object then

        return false

    end

    return Object:IsA("BasePart")

        or Object:IsA("ParticleEmitter")

        or Object:IsA("Trail")

        or Object:IsA("Beam")

        or Object:IsA("Fire")

        or Object:IsA("Smoke")

        or Object:IsA("Sparkles")

        or Object:IsA("PostEffect")

        or Object:IsA("Decal")

        or Object:IsA("Texture")

        or Object:IsA("SurfaceAppearance")

end

local function QueueVisual(Object)

    if not FPSBoostEnabled

        or not Object

        or not Object.Parent

        or ProcessedVisuals[Object]

        or PendingVisualSet[Object]

    then

        return

    end

    if IsPlayerCharacter(Object)

        or IsTrapObject(Object)

        or not IsVisualCandidate(Object)

    then

        return

    end

    PendingVisualSet[Object] = true

    PendingVisuals[#PendingVisuals + 1] = Object

end

local function StartVisualQueue()

    if VisualQueueRunning then

        return

    end

    VisualQueueRunning = true

    task.spawn(function()

        while FPSBoostEnabled and ScreenGui.Parent do

            -- A small budget prevents treadmill spawning from freezing the frame.

            local Budget = 80

            local Processed = 0

            while Processed < Budget and PendingHead <= #PendingVisuals do

                local Object = PendingVisuals[PendingHead]

                PendingVisuals[PendingHead] = nil

                PendingHead += 1

                PendingVisualSet[Object] = nil

                if Object and Object.Parent then

                    -- Keep plot controls/interactions alive, including

                    -- TreadmillBottom and TreadmillUpgrade.

                    HideVisual(Object)

                end

                Processed += 1

            end

            -- Reset the queue without shifting thousands of array entries.

            if PendingHead > #PendingVisuals then

                table.clear(PendingVisuals)

                PendingHead = 1

            end

            -- 30 ms pause keeps the optimizer from competing with rendering.

            task.wait(0.03)

        end

        table.clear(PendingVisuals)

        table.clear(PendingVisualSet)

        PendingHead = 1

        VisualQueueRunning = false

    end)

end

local function QueueExistingVisuals()

    -- One initial pass only. Future objects are handled by DescendantAdded.

    for _, Object in ipairs(workspace:GetDescendants()) do

        if IsRenderFolder(Object) then

            -- Keep the container. Its children are queued below.

        elseif IsObjectFolder(Object) then

            pcall(function()

                Object:Destroy()

            end)

        elseif not IsPlayerCharacter(Object) and IsVisualCandidate(Object) then

            QueueVisual(Object)

        end

    end

end

local function ApplyFPSBoost()

    FPSBoostEnabled = true

    FPSBoostButton.Text = "  FPS BOOST"

    FPSBoostButton.TextColor3 =

        Color3.fromRGB(255,215,80)

    SetToggleVisual(FPSBoostButton,true)

    -- Aggressive local lighting reduction.

    pcall(function()

        Lighting.GlobalShadows = false

        Lighting.ShadowSoftness = 0

        Lighting.EnvironmentDiffuseScale = 0

        Lighting.EnvironmentSpecularScale = 0

        Lighting.FogEnd = 1000000

    end)

    -- Disable post effects without repeatedly creating/destroying them.

    for _, Object in ipairs(Lighting:GetChildren()) do

        if Object:IsA("PostEffect") then

            pcall(function()

                Object.Enabled = false

            end)

        end

    end

    -- Start the queue before scanning so large treadmill folders are

    -- processed over multiple small budgets instead of one long frame.

    StartVisualQueue()

    QueueExistingVisuals()

    StatusLabel.Text = "● FPS BOOST ACTIVE — LOW OVERHEAD"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

end

-- FPS Boost is intentionally one-way.

-- Clicking the button again only reapplies the boost.

FPSBoostButton.MouseButton1Click:Connect(function()

    ApplyFPSBoost()

end)

--//============================================================//

--// FPS BOOST — LOW-COST NEW OBJECT DETECTION

--//============================================================//

workspace.DescendantAdded:Connect(function(Object)

    if not FPSBoostEnabled then

        return

    end

    -- Do not spawn a new task for every treadmill part.

    QueueVisual(Object)

end)

workspace.DescendantRemoving:Connect(function(Object)

    -- If a treadmill/render object is removed and later reused, allow it

    -- to be optimized again.

    ProcessedVisuals[Object] = nil

    PendingVisualSet[Object] = nil

end)

-- Newly-added lighting effects are also disabled without destroying

-- their containers.

Lighting.ChildAdded:Connect(function(Object)

    if not FPSBoostEnabled then

        return

    end

    if Object:IsA("PostEffect") then

        pcall(function()

            Object.Enabled = false

        end)

    end

end)

--//============================================================//

--// BAT AUTO

--//============================================================//

local BatAutoEnabled = false

local BatDetectionDistance = 1000

local BatCooldown = 0.01

local LastBatActivation = 0

local function GetBat()

    local Character = Player.Character

    if not Character then

        return nil

    end

    for _,Object in ipairs(Character:GetChildren()) do

        if Object:IsA("Tool")

            and string.lower(Object.Name):find("bat")

        then

            return Object

        end

    end

    local Backpack =

        Player:FindFirstChildOfClass("Backpack")

    if Backpack then

        for _,Object in ipairs(Backpack:GetChildren()) do

            if Object:IsA("Tool")

                and string.lower(Object.Name):find("bat")

            then

                return Object

            end

        end

    end

    return nil

end

local function EquipBat()

    local Character = Player.Character

    if not Character then

        return nil

    end

    local Humanoid =

        Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then

        return nil

    end

    for _,Object in ipairs(Character:GetChildren()) do

        if Object:IsA("Tool")

            and string.lower(Object.Name):find("bat")

        then

            return Object

        end

    end

    local Backpack =

        Player:FindFirstChildOfClass("Backpack")

    if not Backpack then

        return nil

    end

    for _,Object in ipairs(Backpack:GetChildren()) do

        if Object:IsA("Tool")

            and string.lower(Object.Name):find("bat")

        then

            pcall(function()

                Humanoid:EquipTool(Object)

            end)

            return Object

        end

    end

    return nil

end

local CachedBatTarget = nil

local LastTargetScan = 0

local TARGET_SCAN_INTERVAL = 0.08

local function GetNearbyTarget()

    local Now = os.clock()

    if Now - LastTargetScan < TARGET_SCAN_INTERVAL then

        return CachedBatTarget

    end

    LastTargetScan = Now

    CachedBatTarget = nil

    local Character = Player.Character

    if not Character then

        return nil

    end

    local Root =

        Character:FindFirstChild("HumanoidRootPart")

    if not Root then

        return nil

    end

    local ClosestDistance = BatDetectionDistance

    for _,OtherPlayer in ipairs(Players:GetPlayers()) do

        if OtherPlayer ~= Player then

            local TargetCharacter =

                OtherPlayer.Character

            if TargetCharacter then

                local TargetHumanoid =

                    TargetCharacter:FindFirstChildOfClass("Humanoid")

                local TargetRoot =

                    TargetCharacter:FindFirstChild("HumanoidRootPart")

                if TargetHumanoid

                    and TargetRoot

                    and TargetHumanoid.Health > 0

                then

                    local Distance =

                        (

                            Root.Position -

                            TargetRoot.Position

                        ).Magnitude

                    if Distance <= ClosestDistance then

                        ClosestDistance = Distance

                        CachedBatTarget = TargetCharacter

                    end

                end

            end

        end

    end

    return CachedBatTarget

end

local function ActivateBat()

    if not BatAutoEnabled then

        return

    end

    if os.clock() - LastBatActivation < BatCooldown then

        return

    end

    local Target = GetNearbyTarget()

    if not Target then

        return

    end

    local Bat = EquipBat()

    if not Bat then

        return

    end

    LastBatActivation = os.clock()

    pcall(function()

        Bat:Activate()

    end)

    StatusLabel.Text = "● Bat activated"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

end

BatAutoButton.MouseButton1Click:Connect(function()

    BatAutoEnabled = not BatAutoEnabled

    if BatAutoEnabled then

        BatAutoButton.Text =

            "  BAT AUTO"

        BatAutoButton.TextColor3 =

            Color3.fromRGB(100,255,130)

        BatAutoButton.BackgroundColor3 =

            Color3.fromRGB(35,36,46)

        SetToggleVisual(BatAutoButton,true)

    else

        BatAutoButton.Text =

            "  BAT AUTO"

        BatAutoButton.TextColor3 =

            Color3.fromRGB(238,239,244)

        BatAutoButton.BackgroundColor3 =

            Color3.fromRGB(35,36,46)

        SetToggleVisual(BatAutoButton,false)

    end

end)

task.spawn(function()

    while ScreenGui.Parent do

        -- Avoid a 100 Hz player scan. Target lookup itself is cached.

        task.wait(0.03)

        if BatAutoEnabled then

            ActivateBat()

        end

    end

end)

--//============================================================//

--// BAT VISUAL

--//============================================================//

local BatVisualEnabled = false

local BatVisualIndex = 0

local BatVisualHandle = nil

local BatVisualWeld = nil

local BatVisualNames = {

    "Bat",

    "Desert Bat",

    "Snow Bat",

    "Jungle Bat",

    "Volcano Bat",

    "Lake Bat",

    "Cosmic Bat",

    "Prehistoric Bat",

    "Titan Axe",

    "Katana",

    "Flyswatter",

    "RainbowWrath",

    "Abyss Ocean Bat"

}

local function GetRealBat()

    local Character = Player.Character

    if not Character then

        return nil

    end

    local Bat =

        Character:FindFirstChild("Bat")

    if Bat and Bat:IsA("Tool") then

        return Bat

    end

    for _,Object in ipairs(Character:GetChildren()) do

        if Object:IsA("Tool")

            and string.find(

                string.lower(Object.Name),

                "bat"

            )

        then

            return Object

        end

    end

    return nil

end

local function ClearBatVisual()

    if BatVisualWeld then

        pcall(function()

            BatVisualWeld:Destroy()

        end)

        BatVisualWeld = nil

    end

    if BatVisualHandle then

        pcall(function()

            BatVisualHandle:Destroy()

        end)

        BatVisualHandle = nil

    end

    local RealBat = GetRealBat()

    if RealBat then

        local RealHandle =

            RealBat:FindFirstChild("Handle")

        if RealHandle

            and RealHandle:IsA("BasePart")

        then

            pcall(function()

                RealHandle.LocalTransparencyModifier = 0

            end)

        end

    end

end

local function ApplyBatVisual(BatName)

    ClearBatVisual()

    local RealBat = GetRealBat()

    if not RealBat then

        return false

    end

    local RealHandle =

        RealBat:FindFirstChild("Handle")

    if not RealHandle

        or not RealHandle:IsA("BasePart")

    then

        return false

    end

    local GearTools =

        ReplicatedStorage:FindFirstChild("GearTools")

    if not GearTools then

        return false

    end

    local ShopItems =

        GearTools:FindFirstChild("ShopItems")

    if not ShopItems then

        return false

    end

    local SourceBat =

        ShopItems:FindFirstChild(BatName)

    if not SourceBat then

        return false

    end

    local SourceHandle =

        SourceBat:FindFirstChild("Handle")

    if not SourceHandle

        or not SourceHandle:IsA("BasePart")

    then

        return false

    end

    local VisualHandle =

        SourceHandle:Clone()

    VisualHandle.Name =

        "KYOSH_BatVisual"

    VisualHandle.Anchored = false

    VisualHandle.CanCollide = false

    VisualHandle.CanTouch = false

    VisualHandle.CanQuery = false

    VisualHandle.Massless = true

    for _,Object in ipairs(

        VisualHandle:GetDescendants()

    ) do

        if Object:IsA("Sound")

            or Object:IsA("Script")

            or Object:IsA("LocalScript")

        then

            Object:Destroy()

        end

    end

    VisualHandle.CFrame =

        RealHandle.CFrame

    VisualHandle.Parent =

        RealBat

    local Weld =

        Instance.new("WeldConstraint")

    Weld.Name =

        "KYOSH_BatVisualWeld"

    Weld.Part0 =

        RealHandle

    Weld.Part1 =

        VisualHandle

    Weld.Parent =

        VisualHandle

    RealHandle.LocalTransparencyModifier = 1

    BatVisualHandle =

        VisualHandle

    BatVisualWeld =

        Weld

    StatusLabel.Text =

        "● BAT VISUAL: " .. BatName

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

    return true

end

local function SetBatVisual(Index)

    BatVisualIndex = Index

    if Index == 0 then

        BatVisualEnabled = false

        ClearBatVisual()

        BatVisualButton.Text =

            "  BAT VISUAL: OFF"

        return

    end

    BatVisualEnabled = true

    local BatName =

        BatVisualNames[Index]

    if not BatName then

        BatVisualIndex = 0

        BatVisualEnabled = false

        ClearBatVisual()

        BatVisualButton.Text =

            "  BAT VISUAL: OFF"

        return

    end

    local Success =

        ApplyBatVisual(BatName)

    if Success then

        BatVisualButton.Text =

            "  BAT: " .. BatName

    else

        BatVisualButton.Text =

            "  BAT VISUAL: " .. BatName

    end

end

BatVisualButton.MouseButton1Click:Connect(function()

    local NextIndex =

        BatVisualIndex + 1

    if NextIndex > #BatVisualNames then

        NextIndex = 0

    end

    SetBatVisual(NextIndex)

end)

--//============================================================//

--// AUTOMATIC COSMIC BAT RETRY

--//============================================================//

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(0.75)

        if BatVisualEnabled

            and BatVisualIndex == 7

            and not BatVisualHandle

        then

            pcall(function()

                ApplyBatVisual("Cosmic Bat")

            end)

            BatVisualButton.Text =

                "  BAT: Cosmic Bat"

        end

    end

end)

--//============================================================//

--// 🥚 INSTANT STEAL RETURN

--// Steal Egg -> Wait -> Return Player to SafeZone

--//============================================================//

local InstantSafeEnabled = false

local RETURN_DELAY = 1

local ProximityPromptService =

    game:GetService("ProximityPromptService")

local World = workspace:FindFirstChild("World")

local Areas = World and World:FindFirstChild("Areas")

local SafeZone = Areas and Areas:FindFirstChild("StartArea")

local function GetSafeZonePart()

    if not SafeZone or not SafeZone.Parent then

        World = workspace:FindFirstChild("World")

        Areas = World and World:FindFirstChild("Areas")

        SafeZone = Areas and Areas:FindFirstChild("StartArea")

    end

    if not SafeZone then

        return nil

    end

    if SafeZone:IsA("BasePart") then

        return SafeZone

    end

    if SafeZone:IsA("Model") and SafeZone.PrimaryPart then

        return SafeZone.PrimaryPart

    end

    return SafeZone:FindFirstChildWhichIsA(

        "BasePart",

        true

    )

end

local function ReturnToSafeZone()

    if not InstantSafeEnabled then

        return

    end

    local Character = Player.Character

    if not Character then

        return

    end

    local Root =

        Character:FindFirstChild("HumanoidRootPart")

    if not Root then

        return

    end

    local SafePart = GetSafeZonePart()

    if not SafePart then

        warn("[InstantSafe] StartArea has no BasePart")

        return

    end

    local Height =

        (SafePart.Size.Y / 2) + 3

    local TargetCFrame =

        SafePart.CFrame *

        CFrame.new(0,Height,0)

    pcall(function()

        Root.AssemblyLinearVelocity = Vector3.zero

        Root.AssemblyAngularVelocity = Vector3.zero

        Root.CFrame = TargetCFrame

    end)

    StatusLabel.Text =

        "● RETURNED TO SAFE ZONE"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

end

InstantSafeButton.MouseButton1Click:Connect(function()

    InstantSafeEnabled =

        not InstantSafeEnabled

    if InstantSafeEnabled then

        InstantSafeButton.Text =

            "  INSTANT SAFE"

        InstantSafeButton.TextColor3 =

            Color3.fromRGB(100,255,130)

        InstantSafeButton.BackgroundColor3 =

            Color3.fromRGB(35,36,46)

        SetToggleVisual(

            InstantSafeButton,

            true

        )

        StatusLabel.Text =

            "● INSTANT SAFE ACTIVE"

        StatusLabel.TextColor3 =

            Color3.fromRGB(100,255,130)

    else

        InstantSafeButton.Text =

            "  INSTANT SAFE"

        InstantSafeButton.TextColor3 =

            Color3.fromRGB(238,239,244)

        InstantSafeButton.BackgroundColor3 =

            Color3.fromRGB(35,36,46)

        SetToggleVisual(

            InstantSafeButton,

            false

        )

        StatusLabel.Text =

            "● SYSTEM ONLINE"

        StatusLabel.TextColor3 =

            Color3.fromRGB(100,255,130)

    end

end)

ProximityPromptService.PromptTriggered:Connect(

    function(Prompt)

        if not InstantSafeEnabled then

            return

        end

        local PromptName =

            string.lower(Prompt.Name or "")

        local IsStealPrompt =

            string.find(PromptName,"steal",1,true)

            or string.find(PromptName,"egg",1,true)

        if not IsStealPrompt then

            return

        end

        task.defer(function()

            task.wait(RETURN_DELAY)

            if InstantSafeEnabled then

                ReturnToSafeZone()

            end

        end)

    end

)

--//============================================================//

--// CHARACTER RESPAWN

--//============================================================//

Player.CharacterAdded:Connect(function(Character)

    task.wait(0.75)

    if GOD_MODE_ENABLED then

        task.spawn(function()

            ProtectCharacter(Character)

        end)

    end

    if BatVisualEnabled

        and BatVisualIndex == 7

    then

        task.spawn(function()

            for i = 1,20 do

                if not ScreenGui.Parent then

                    break

                end

                if ApplyBatVisual("Cosmic Bat") then

                    BatVisualButton.Text =

                        "BAT: Cosmic Bat"

                    break

                end

                task.wait(0.5)

            end

        end)

    end

end)

--//============================================================//

--// GOD MODE SAFETY

--//============================================================//

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(0.1)

        if GodModeEnabled then

            if not GodCharacter

                or not GodHumanoid

                or not GodRootPart

                or not GodCharacter.Parent

            then

                local Character = Player.Character

                if Character then

                    task.spawn(function()

                        SetupGodCharacter(Character)

                    end)

                end

            end

            if GodHumanoid and GodRootPart and GodCharacter and GodCharacter.Parent then

                if ProtectHealth and

                    GodHumanoid.Health < GodHumanoid.MaxHealth

                then

                    pcall(function()

                        GodHumanoid.Health = GodHumanoid.MaxHealth

                    end)

                end

                if ProtectDeath then

                    pcall(function()

                        GodHumanoid:SetStateEnabled(

                            Enum.HumanoidStateType.Dead,

                            false

                        )

                    end)

                end

                local State = GodHumanoid:GetState()

                if State ~= Enum.HumanoidStateType.Freefall

                    and State ~= Enum.HumanoidStateType.FallingDown

                    and State ~= Enum.HumanoidStateType.Ragdoll

                    and GodRootPart.Position.Y > FALL_LIMIT + 50

                then

                    LastSafeCFrame = GodRootPart.CFrame

                end

                if ProtectFall and

                    GodRootPart.Position.Y <= FALL_LIMIT and

                    LastSafeCFrame

                then

                    pcall(function()

                        GodRootPart.AssemblyLinearVelocity = Vector3.zero

                        GodRootPart.AssemblyAngularVelocity = Vector3.zero

                        GodRootPart.CFrame =

                            LastSafeCFrame + Vector3.new(0,RECOVERY_HEIGHT,0)

                    end)

                end

            end

        end

    end

end)

--//============================================================//

--// MOBILE UI

--// Minimize/restore is handled by MiniButton above.

--//============================================================//

--//============================================================//

--// FPS MONITOR

--//============================================================//

local Frames = 0

local LastTime = os.clock()

RunService.RenderStepped:Connect(function()

    Frames += 1

    local CurrentTime =

        os.clock()

    if CurrentTime - LastTime >= 1 then

        local FPS =

            math.floor(

                Frames /

                (CurrentTime - LastTime)

            )

        Frames = 0

        LastTime = CurrentTime

        FPSLabel.Text =

            "FPS: " .. FPS

        if FPS >= 55 then

            FPSLabel.TextColor3 =

                Color3.fromRGB(100,255,130)

        elseif FPS >= 30 then

            FPSLabel.TextColor3 =

                Color3.fromRGB(255,215,80)

        else

            FPSLabel.TextColor3 =

                Color3.fromRGB(255,80,80)

        end

    end

end)

--//============================================================//

--// PING MONITOR

--//============================================================//

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(1)

        local Ping = 0

        pcall(function()

            Ping =

                math.floor(

                    Player:GetNetworkPing() * 1000

                )

        end)

        PingLabel.Text =

            "PING: " .. Ping .. " ms"

        if Ping <= 80 then

            PingLabel.TextColor3 =

                Color3.fromRGB(100,255,130)

        elseif Ping <= 150 then

            PingLabel.TextColor3 =

                Color3.fromRGB(255,215,80)

        else

            PingLabel.TextColor3 =

                Color3.fromRGB(255,80,80)

        end

    end

end)

--//============================================================//

--// ⭐ AUTO START

--//============================================================//

task.spawn(function()

    --// Make sure FPS page opens immediately

    HomePage.Visible = false

    FPSPage.Visible = true

    HomeButton.BackgroundColor3 =

        Color3.fromRGB(35,35,45)

    HomeButton.TextColor3 =

        Color3.fromRGB(170,170,180)

    FPSButton.BackgroundColor3 =

        Color3.fromRGB(255,195,60)

    FPSButton.TextColor3 =

        Color3.fromRGB(25,25,25)

    StatusLabel.Text =

        "● Starting all features..."

    StatusLabel.TextColor3 =

        Color3.fromRGB(255,215,80)

    --// GOD MODE

    task.wait(0.2)

    EnableGodMode()

    --// FPS BOOST

    task.wait(0.15)

    ApplyFPSBoost()



    --// BAT AUTO

    task.wait(0.15)

    BatAutoEnabled = true

    BatAutoButton.Text =

        "  BAT AUTO"

    BatAutoButton.TextColor3 =

        Color3.fromRGB(100,255,130)

    BatAutoButton.BackgroundColor3 =

        Color3.fromRGB(35,36,46)

    SetToggleVisual(BatAutoButton,true)





    --// COSMIC BAT

    task.wait(0.15)

    BatVisualEnabled = true

    BatVisualIndex = 7

    BatVisualButton.Text =

        "  BAT: Cosmic Bat"

    --// Try immediately

    ApplyBatVisual("Cosmic Bat")

    --// Retry until the Bat exists

    task.spawn(function()

        for i = 1,30 do

            if not ScreenGui.Parent then

                break

            end

            if BatVisualHandle

                and BatVisualHandle.Parent

            then

                break

            end

            ApplyBatVisual("Cosmic Bat")

            task.wait(0.5)

        end

    end)

    --// ALL DONE

    task.wait(0.25)

    StatusLabel.Text =

        "● ALL FEATURES ENABLED • FPS BOOST NO RESTORE"

    StatusLabel.TextColor3 =

        Color3.fromRGB(100,255,130)

    print(

        "🥚 KYOSH [SAE] AUTO START COMPLETE"

    )

    print(

        "✓ GOD MODE"

    )

    print(

        "✓ FPS BOOST"

    )



    print(

        "✓ BAT AUTO"

    )

    print(

        "✓ COSMIC BAT"

    )

end)

--//============================================================//

--// CLEANUP

--//============================================================//

ScreenGui.Destroying:Connect(function()

    GOD_MODE_ENABLED = false

    DisconnectGodData()

    InstantSafeEnabled = false

    BatAutoEnabled = false

    BatVisualEnabled = false

    BatVisualIndex = 0

    ClearBatVisual()

    --// FIXED: GetRealBat() instead of undefined GetEquippedRealBat()

    local RealBat = GetRealBat()

    if RealBat then

        for _,Object in ipairs(

            RealBat:GetDescendants()

        ) do

            if Object:IsA("BasePart") then

                pcall(function()

                    Object.LocalTransparencyModifier = 0

                end)

            end

        end

    end

end)

--//============================================================//

--// LOADED

--//============================================================//

print(

    "🥚 EGG FPS MONITOR LOADED - FPS BOOST ACTIVE"

)

print(

    "🌌 COSMIC BAT SELECTED AUTOMATICALLY"

)
