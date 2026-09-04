--//============================================================//
--// 🥚 EGG FPS MONITOR
--// FPS BOOST + GOD MODE + ADVANCED FLOAT + GUARD FREEZE
--// + CHAR FREEZE + BAT AUTO + FAR CAMERA + COSMIC BAT
--//============================================================//

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
--// GUI
--//============================================================//

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggFPSMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--//============================================================//
--// MAIN
--//============================================================//

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0,350,0,435)
Main.Position = UDim2.new(0.5,-175,0.5,-217)
Main.BackgroundColor3 = Color3.fromRGB(18,18,25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255,205,70)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--//============================================================//
--// HEADER
--//============================================================//

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60)
Header.BackgroundColor3 = Color3.fromRGB(28,28,37)
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,16)
HeaderCorner.Parent = Header

local EggIcon = Instance.new("TextLabel")
EggIcon.Size = UDim2.new(0,48,0,48)
EggIcon.Position = UDim2.new(0,8,0,6)
EggIcon.BackgroundTransparency = 1
EggIcon.Text = "🥚"
EggIcon.TextSize = 30
EggIcon.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0,210,0,25)
Title.Position = UDim2.new(0,58,0,7)
Title.BackgroundTransparency = 1
Title.Text = "KYOSH [SAE]"
Title.TextColor3 = Color3.fromRGB(255,215,80)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0,210,0,18)
Subtitle.Position = UDim2.new(0,59,0,32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Performance + Protection"
Subtitle.TextColor3 = Color3.fromRGB(155,155,165)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

--//============================================================//
--// CLOSE BUTTON
--//============================================================//

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0,32,0,32)
CloseButton.Position = UDim2.new(1,-42,0,14)
CloseButton.BackgroundColor3 = Color3.fromRGB(48,48,58)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.TextSize = 21
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,9)
CloseCorner.Parent = CloseButton

--//============================================================//
--// CATEGORY BAR
--//============================================================//

local CategoryBar = Instance.new("Frame")
CategoryBar.Size = UDim2.new(1,-20,0,38)
CategoryBar.Position = UDim2.new(0,10,0,70)
CategoryBar.BackgroundTransparency = 1
CategoryBar.Parent = Main

local HomeButton = Instance.new("TextButton")
HomeButton.Size = UDim2.new(0.5,-4,1,0)
HomeButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
HomeButton.Text = "HOME"
HomeButton.TextColor3 = Color3.fromRGB(170,170,180)
HomeButton.TextSize = 12
HomeButton.Font = Enum.Font.GothamBold
HomeButton.BorderSizePixel = 0
HomeButton.Parent = CategoryBar

local HomeCorner = Instance.new("UICorner")
HomeCorner.CornerRadius = UDim.new(0,9)
HomeCorner.Parent = HomeButton

local FPSButton = Instance.new("TextButton")
FPSButton.Size = UDim2.new(0.5,-4,1,0)
FPSButton.Position = UDim2.new(0.5,4,0,0)
FPSButton.BackgroundColor3 = Color3.fromRGB(255,195,60)
FPSButton.Text = "FPS"
FPSButton.TextColor3 = Color3.fromRGB(25,25,25)
FPSButton.TextSize = 12
FPSButton.Font = Enum.Font.GothamBold
FPSButton.BorderSizePixel = 0
FPSButton.Parent = CategoryBar

local FPSCorner = Instance.new("UICorner")
FPSCorner.CornerRadius = UDim.new(0,9)
FPSCorner.Parent = FPSButton

--//============================================================//
--// HOME PAGE
--//============================================================//

local HomePage = Instance.new("Frame")
HomePage.Size = UDim2.new(1,-20,0,280)
HomePage.Position = UDim2.new(0,10,0,120)
HomePage.BackgroundTransparency = 1
HomePage.Visible = false
HomePage.Parent = Main

local HomeTitle = Instance.new("TextLabel")
HomeTitle.Size = UDim2.new(1,0,0,30)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Text = "🥚 Welcome to Kyosh [SAE]"
HomeTitle.TextColor3 = Color3.fromRGB(230,230,235)
HomeTitle.TextSize = 14
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextXAlignment = Enum.TextXAlignment.Left
HomeTitle.Parent = HomePage

local HomeInfo = Instance.new("TextLabel")
HomeInfo.Size = UDim2.new(1,0,0,180)
HomeInfo.Position = UDim2.new(0,0,0,40)
HomeInfo.BackgroundTransparency = 1
HomeInfo.Text =
    "Monitor your FPS and network ping in real time.\n\n" ..
    "60+ FPS = Smooth\n" ..
    "30–59 FPS = Moderate\n" ..
    "Below 30 FPS = Low\n\n" ..
    "FPS BOOST removes local visual effects.\n" ..
    "Pets and eggs are hidden locally while FPS Boost is ON.\n" ..
    "GOD MODE protects your Humanoid.\n" ..
    "FLOAT follows the ground while allowing movement.\n" ..
    "GUARD FREEZE freezes guards inside GuardAreas.\n" ..
    "CHAR FREEZE sets NPC/Monster Humanoid speed to 0."

HomeInfo.TextColor3 = Color3.fromRGB(170,170,180)
HomeInfo.TextSize = 12
HomeInfo.Font = Enum.Font.Gotham
HomeInfo.TextXAlignment = Enum.TextXAlignment.Left
HomeInfo.TextYAlignment = Enum.TextYAlignment.Top
HomeInfo.Parent = HomePage

--//============================================================//
--// FPS PAGE
--//============================================================//

local FPSPage = Instance.new("Frame")
FPSPage.Size = UDim2.new(1,-20,0,280)
FPSPage.Position = UDim2.new(0,10,0,120)
FPSPage.BackgroundTransparency = 1
FPSPage.Visible = true
FPSPage.Parent = Main

local FPSBox = Instance.new("Frame")
FPSBox.Size = UDim2.new(0.48,0,0,60)
FPSBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
FPSBox.BorderSizePixel = 0
FPSBox.Parent = FPSPage

local FPSBoxCorner = Instance.new("UICorner")
FPSBoxCorner.CornerRadius = UDim.new(0,10)
FPSBoxCorner.Parent = FPSBox

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1,0,1,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(100,255,130)
FPSLabel.TextSize = 21
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Parent = FPSBox

local PingBox = Instance.new("Frame")
PingBox.Size = UDim2.new(0.48,0,0,60)
PingBox.Position = UDim2.new(0.52,0,0,0)
PingBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
PingBox.BorderSizePixel = 0
PingBox.Parent = FPSPage

local PingCorner = Instance.new("UICorner")
PingCorner.CornerRadius = UDim.new(0,10)
PingCorner.Parent = PingBox

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(1,0,1,0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "PING: --"
PingLabel.TextColor3 = Color3.fromRGB(100,255,130)
PingLabel.TextSize = 21
PingLabel.Font = Enum.Font.GothamBold
PingLabel.Parent = PingBox

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1,0,0,22)
StatusLabel.Position = UDim2.new(0,0,0,70)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● Starting..."
StatusLabel.TextColor3 = Color3.fromRGB(255,215,80)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FPSPage

--//============================================================//
--// BUTTON HELPER
--//============================================================//

local function MakeButton(Name,Text,Position)

    local Button = Instance.new("TextButton")

    Button.Name = Name
    Button.Size = UDim2.new(0.48,0,0,40)
    Button.Position = Position
    Button.BackgroundColor3 = Color3.fromRGB(55,55,68)
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(255,110,110)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.AutoButtonColor = false
    Button.Parent = FPSPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,9)
    Corner.Parent = Button

    return Button
end

local GodModeButton =
    MakeButton(
        "GodModeButton",
        "GOD MODE: OFF",
        UDim2.new(0,0,0,100)
    )

local FPSBoostButton =
    MakeButton(
        "FPSBoostButton",
        "FPS BOOST: OFF",
        UDim2.new(0.52,0,0,100)
    )

local FloatButton =
    MakeButton(
        "FloatButton",
        "FLOAT: OFF",
        UDim2.new(0,0,0,148)
    )

local GuardFreezeButton =
    MakeButton(
        "GuardFreezeButton",
        "FREEZE GUARDS: OFF",
        UDim2.new(0.52,0,0,148)
    )

local BatAutoButton =
    MakeButton(
        "BatAutoButton",
        "BAT AUTO: OFF",
        UDim2.new(0,0,0,196)
    )

local AIFreezeButton =
    MakeButton(
        "AIFreezeButton",
        "CHAR FREEZE: OFF",
        UDim2.new(0.52,0,0,196)
    )

local FarCameraButton =
    MakeButton(
        "FarCameraButton",
        "FAR CAMERA: OFF",
        UDim2.new(0,0,0,244)
    )

local BatVisualButton =
    MakeButton(
        "BatVisualButton",
        "BAT VISUAL: OFF",
        UDim2.new(0.52,0,0,244)
    )

--//============================================================//
--// GOD MODE
--//============================================================//

local GodModeEnabled = false
local GodHealthConnection = nil
local GodMaxHealthConnection = nil
local GodStateConnection = nil
local CurrentGodHumanoid = nil

local function GetHumanoid()

    local Character = Player.Character

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass("Humanoid")
end

local function DisconnectGodConnections()

    if GodHealthConnection then
        GodHealthConnection:Disconnect()
        GodHealthConnection = nil
    end

    if GodMaxHealthConnection then
        GodMaxHealthConnection:Disconnect()
        GodMaxHealthConnection = nil
    end

    if GodStateConnection then
        GodStateConnection:Disconnect()
        GodStateConnection = nil
    end
end

local function ProtectHumanoid(Humanoid)

    if not Humanoid then
        return
    end

    DisconnectGodConnections()

    CurrentGodHumanoid = Humanoid

    pcall(function()
        Humanoid.Health = Humanoid.MaxHealth
        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Dead,
            false
        )
    end)

    GodHealthConnection =
        Humanoid.HealthChanged:Connect(function()

            if not GodModeEnabled then
                return
            end

            if Humanoid.Parent
                and Humanoid.Health < Humanoid.MaxHealth
            then

                task.defer(function()

                    if GodModeEnabled
                        and Humanoid.Parent
                    then

                        pcall(function()
                            Humanoid.Health = Humanoid.MaxHealth
                        end)

                    end
                end)
            end
        end)

    GodMaxHealthConnection =
        Humanoid:GetPropertyChangedSignal(
            "MaxHealth"
        ):Connect(function()

            if not GodModeEnabled then
                return
            end

            if Humanoid.Parent then

                pcall(function()

                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = Humanoid.MaxHealth
                    end

                end)
            end
        end)

    GodStateConnection =
        Humanoid.StateChanged:Connect(function(_,NewState)

            if not GodModeEnabled then
                return
            end

            if NewState == Enum.HumanoidStateType.Dead then

                task.defer(function()

                    if GodModeEnabled
                        and Humanoid.Parent
                    then

                        pcall(function()

                            Humanoid:SetStateEnabled(
                                Enum.HumanoidStateType.Dead,
                                false
                            )

                            Humanoid.Health = Humanoid.MaxHealth

                            Humanoid:ChangeState(
                                Enum.HumanoidStateType.GettingUp
                            )

                        end)
                    end
                end)
            end
        end)
end

local function EnableGodMode()

    GodModeEnabled = true

    local Humanoid = GetHumanoid()

    if not Humanoid then
        return
    end

    ProtectHumanoid(Humanoid)

    GodModeButton.Text = "GOD MODE: ON"
    GodModeButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    GodModeButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

end

local function DisableGodMode()

    GodModeEnabled = false

    DisconnectGodConnections()

    if CurrentGodHumanoid
        and CurrentGodHumanoid.Parent
    then

        pcall(function()

            CurrentGodHumanoid:SetStateEnabled(
                Enum.HumanoidStateType.Dead,
                true
            )

        end)
    end

    CurrentGodHumanoid = nil

    GodModeButton.Text = "GOD MODE: OFF"
    GodModeButton.TextColor3 =
        Color3.fromRGB(255,110,110)

    GodModeButton.BackgroundColor3 =
        Color3.fromRGB(55,55,68)
end

GodModeButton.MouseButton1Click:Connect(function()

    if GodModeEnabled then
        DisableGodMode()
    else
        EnableGodMode()
    end

end)

--//============================================================//
--// ADVANCED FLOAT
--//============================================================//

local FloatEnabled = false
local FloatHeight = 0.5
local FloatConnection = nil

local FLOAT_RAY_DISTANCE = 15
local FLOAT_STRENGTH = 8
local FLOAT_MAX_VERTICAL_SPEED = 15

local function StopFloat()

    if FloatConnection then
        FloatConnection:Disconnect()
        FloatConnection = nil
    end
end

local function FindGround(Character,Root)

    local Params = RaycastParams.new()

    Params.FilterType =
        Enum.RaycastFilterType.Exclude

    Params.FilterDescendantsInstances = {
        Character
    }

    Params.IgnoreWater = false

    return workspace:Raycast(
        Root.Position + Vector3.new(0,2,0),
        Vector3.new(0,-FLOAT_RAY_DISTANCE,0),
        Params
    )
end

local function StartFloat()

    StopFloat()

    FloatConnection =
        RunService.Heartbeat:Connect(function()

            if not FloatEnabled then
                return
            end

            local Character = Player.Character

            if not Character then
                return
            end

            local Humanoid =
                Character:FindFirstChildOfClass("Humanoid")

            local Root =
                Character:FindFirstChild("HumanoidRootPart")

            if not Humanoid or not Root then
                return
            end

            local Ground =
                FindGround(Character,Root)

            if not Ground then
                return
            end

            local RootHalfHeight =
                math.max(Root.Size.Y * 1,1)

            local TargetY =
                Ground.Position.Y +
                RootHalfHeight +
                FloatHeight

            local Difference =
                TargetY - Root.Position.Y

            local VerticalVelocity =
                math.clamp(
                    Difference * FLOAT_STRENGTH,
                    -FLOAT_MAX_VERTICAL_SPEED,
                    FLOAT_MAX_VERTICAL_SPEED
                )

            local CurrentVelocity =
                Root.AssemblyLinearVelocity

            Root.AssemblyLinearVelocity =
                Vector3.new(
                    CurrentVelocity.X,
                    VerticalVelocity,
                    CurrentVelocity.Z
                )

        end)
end

local function EnableFloat()

    FloatEnabled = true

    FloatButton.Text = "FLOAT: ON"
    FloatButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    FloatButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    StartFloat()
end

local function DisableFloat()

    FloatEnabled = false

    StopFloat()

    FloatButton.Text = "FLOAT: OFF"
    FloatButton.TextColor3 =
        Color3.fromRGB(255,110,110)

    FloatButton.BackgroundColor3 =
        Color3.fromRGB(55,55,68)
end

FloatButton.MouseButton1Click:Connect(function()

    if FloatEnabled then
        DisableFloat()
    else
        EnableFloat()
    end

end)

--//============================================================//
--// FPS BOOST
--//============================================================//

local FPSBoostEnabled = false

local SavedParts = {}
local SavedEffects = {}
local SavedLighting = {}
local SavedRenderFolders = {}
local SavedObjectFolders = {}

local RenderFolderNames = {

    ["ClientRenderedAssets"] = true,
    ["PlacedEggRenders"] = true,
    ["Plots"] = true,
    ["Stands"] = true,
    ["__ClientTreadmillRenders"] = true

}

local ObjectFolderNames = {

    ["AREAS"] = true,
    ["LEADERBOARDS"] = true,
    ["MACHINES"] = true

}

local function IsRenderFolder(Object)

    return Object
        and RenderFolderNames[Object.Name] == true
end

local function IsPlayerCharacter(Object)

    local Character = Player.Character

    if not Character then
        return false
    end

    return Object:IsDescendantOf(Character)
end

local function RemoveRenderFolder(Object)

    if not Object
        or not IsRenderFolder(Object)
    then
        return
    end

    if SavedRenderFolders[Object] then
        return
    end

    SavedRenderFolders[Object] = {
        Parent = Object.Parent
    }

    pcall(function()
        Object.Parent = nil
    end)
end

local function RemoveRenderFolders()

    for _,Object in ipairs(workspace:GetDescendants()) do

        if IsRenderFolder(Object) then
            RemoveRenderFolder(Object)
        end

    end
end

local function RestoreRenderFolders()

    for Object,Data in pairs(SavedRenderFolders) do

        if Object
            and Data
            and Data.Parent
        then

            pcall(function()
                Object.Parent = Data.Parent
            end)

        end
    end

    table.clear(SavedRenderFolders)
end

local function IsObjectFolder(Object)

    return Object
        and Object.Parent
        and Object.Parent.Name == "__OBJECTS"
        and ObjectFolderNames[Object.Name] == true
end

local function RemoveObjectFolder(Object)

    if not IsObjectFolder(Object) then
        return
    end

    if SavedObjectFolders[Object] then
        return
    end

    SavedObjectFolders[Object] = {
        Parent = Object.Parent
    }

    pcall(function()
        Object.Parent = nil
    end)
end

local function RemoveObjectFolders()

    local ObjectsFolder =
        workspace:FindFirstChild("__OBJECTS")

    if not ObjectsFolder then
        return
    end

    for _,Object in ipairs(ObjectsFolder:GetChildren()) do

        if ObjectFolderNames[Object.Name] then
            RemoveObjectFolder(Object)
        end

    end
end

local function RestoreObjectFolders()

    for Object,Data in pairs(SavedObjectFolders) do

        if Object
            and Data
            and Data.Parent
        then

            pcall(function()
                Object.Parent = Data.Parent
            end)

        end
    end

    table.clear(SavedObjectFolders)
end

local function HidePart(Object)

    if IsPlayerCharacter(Object) then
        return
    end

    if not SavedParts[Object] then

        SavedParts[Object] = {

            Transparency =
                Object.LocalTransparencyModifier,

            CastShadow =
                Object.CastShadow

        }

    end

    pcall(function()

        Object.LocalTransparencyModifier = 1
        Object.CastShadow = false

    end)
end

local function HideEffect(Object)

    if not SavedEffects[Object] then

        if Object:IsA("Decal")
            or Object:IsA("Texture")
        then

            SavedEffects[Object] = {

                Type = "Transparency",
                Value = Object.Transparency

            }

        elseif Object:IsA("PostEffect")
            or Object:IsA("ParticleEmitter")
            or Object:IsA("Trail")
            or Object:IsA("Beam")
            or Object:IsA("Fire")
            or Object:IsA("Smoke")
            or Object:IsA("Sparkles")
        then

            SavedEffects[Object] = {

                Type = "Enabled",
                Value = Object.Enabled

            }

        end
    end

    pcall(function()

        if Object:IsA("Decal")
            or Object:IsA("Texture")
        then

            Object.Transparency = 1

        else

            Object.Enabled = false

        end

    end)
end

local function ApplyBoost(Object)

    if not FPSBoostEnabled then
        return
    end

    if not Object then
        return
    end

    if IsPlayerCharacter(Object) then
        return
    end

    if IsRenderFolder(Object) then

        RemoveRenderFolder(Object)
        return

    end

    if Object:IsA("BasePart") then

        HidePart(Object)

    elseif Object:IsA("ParticleEmitter")
        or Object:IsA("Trail")
        or Object:IsA("Beam")
        or Object:IsA("Fire")
        or Object:IsA("Smoke")
        or Object:IsA("Sparkles")
        or Object:IsA("PostEffect")
        or Object:IsA("Decal")
        or Object:IsA("Texture")
    then

        HideEffect(Object)

    end
end

local function ApplyLightingBoost()

    local Properties = {

        GlobalShadows = false,
        ShadowSoftness = 0,
        EnvironmentDiffuseScale = 0,
        EnvironmentSpecularScale = 0,
        FogEnd = 1000000

    }

    for Property,Value in pairs(Properties) do

        if SavedLighting[Property] == nil then

            local Success,OldValue =
                pcall(function()
                    return Lighting[Property]
                end)

            if Success then
                SavedLighting[Property] = OldValue
            end

        end

        pcall(function()
            Lighting[Property] = Value
        end)

    end
end

local function EnableFPSBoost()

    FPSBoostEnabled = true

    FPSBoostButton.Text = "FPS BOOST: ON"
    FPSBoostButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    FPSBoostButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    ApplyLightingBoost()

    RemoveRenderFolders()
    RemoveObjectFolders()

    for _,Object in ipairs(workspace:GetDescendants()) do
        ApplyBoost(Object)
    end
end

local function DisableFPSBoost()

    FPSBoostEnabled = false

    FPSBoostButton.Text = "FPS BOOST: OFF"
    FPSBoostButton.TextColor3 =
        Color3.fromRGB(255,110,110)

    FPSBoostButton.BackgroundColor3 =
        Color3.fromRGB(55,55,68)

    for Property,Value in pairs(SavedLighting) do

        pcall(function()
            Lighting[Property] = Value
        end)

    end

    table.clear(SavedLighting)

    for Object,Data in pairs(SavedParts) do

        if Object and Object.Parent then

            pcall(function()

                Object.LocalTransparencyModifier =
                    Data.Transparency

                Object.CastShadow =
                    Data.CastShadow

            end)

        end
    end

    table.clear(SavedParts)

    for Object,Data in pairs(SavedEffects) do

        if Object and Object.Parent then

            pcall(function()

                if Data.Type == "Transparency" then
                    Object.Transparency = Data.Value
                else
                    Object.Enabled = Data.Value
                end

            end)

        end
    end

    table.clear(SavedEffects)

    RestoreRenderFolders()
    RestoreObjectFolders()
end

FPSBoostButton.MouseButton1Click:Connect(function()

    if FPSBoostEnabled then
        DisableFPSBoost()
    else
        EnableFPSBoost()
    end

end)

--//============================================================//
--// GUARD FREEZE
--//============================================================//

local GuardFreezeEnabled = false
local FrozenGuards = {}
local GuardFolder = nil

local function GetGuardFolder()

    local ObjectsFolder =
        workspace:FindFirstChild("__OBJECTS")

    if not ObjectsFolder then
        return nil
    end

    local AreasFolder =
        ObjectsFolder:FindFirstChild("Areas")

    if not AreasFolder then
        return nil
    end

    return AreasFolder:FindFirstChild("GuardAreas")
end

local function IsGuardModel(Model)

    if not Model:IsA("Model") then
        return false
    end

    return Model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function FreezeGuard(Model)

    if not IsGuardModel(Model) then
        return
    end

    if FrozenGuards[Model] then
        return
    end

    local Humanoid =
        Model:FindFirstChildOfClass("Humanoid")

    local Data = {

        Parts = {},
        Humanoid = Humanoid,

        WalkSpeed =
            Humanoid and Humanoid.WalkSpeed,

        JumpPower =
            Humanoid and Humanoid.JumpPower,

        JumpHeight =
            Humanoid and Humanoid.JumpHeight,

        AutoRotate =
            Humanoid and Humanoid.AutoRotate

    }

    if Humanoid then

        pcall(function()

            Humanoid.WalkSpeed = 0
            Humanoid.JumpPower = 0
            Humanoid.JumpHeight = 0
            Humanoid.AutoRotate = false

        end)
    end

    for _,Object in ipairs(Model:GetDescendants()) do

        if Object:IsA("BasePart") then

            Data.Parts[Object] =
                Object.Anchored

            pcall(function()
                Object.Anchored = true
            end)

        end
    end

    FrozenGuards[Model] = Data
end

local function UnfreezeGuard(Model,Data)

    if not Data then
        return
    end

    for Object,OldAnchored in pairs(Data.Parts) do

        if Object and Object.Parent then

            pcall(function()
                Object.Anchored = OldAnchored
            end)

        end
    end

    if Data.Humanoid
        and Data.Humanoid.Parent
    then

        pcall(function()

            Data.Humanoid.WalkSpeed =
                Data.WalkSpeed

            Data.Humanoid.JumpPower =
                Data.JumpPower

            Data.Humanoid.JumpHeight =
                Data.JumpHeight

            Data.Humanoid.AutoRotate =
                Data.AutoRotate

        end)
    end
end

local function FreezeAllGuards()

    GuardFolder = GetGuardFolder()

    if not GuardFolder then
        return
    end

    for _,Object in ipairs(GuardFolder:GetDescendants()) do

        if Object:IsA("Model")
            and IsGuardModel(Object)
        then

            FreezeGuard(Object)

        end
    end
end

local function UnfreezeAllGuards()

    for Model,Data in pairs(FrozenGuards) do
        UnfreezeGuard(Model,Data)
    end

    table.clear(FrozenGuards)
end

GuardFreezeButton.MouseButton1Click:Connect(function()

    if GuardFreezeEnabled then

        GuardFreezeEnabled = false

        UnfreezeAllGuards()

        GuardFreezeButton.Text =
            "FREEZE GUARDS: OFF"

        GuardFreezeButton.TextColor3 =
            Color3.fromRGB(255,110,110)

        GuardFreezeButton.BackgroundColor3 =
            Color3.fromRGB(55,55,68)

    else

        GuardFreezeEnabled = true

        FreezeAllGuards()

        GuardFreezeButton.Text =
            "FREEZE GUARDS: ON"

        GuardFreezeButton.TextColor3 =
            Color3.fromRGB(100,255,130)

        GuardFreezeButton.BackgroundColor3 =
            Color3.fromRGB(35,75,48)

    end
end)

--//============================================================//
--// AI / MONSTER FREEZE
--//============================================================//

local AIFreezeEnabled = false
local FrozenAI = {}

local function IsPlayerModel(Model)

    if not Model then
        return false
    end

    for _,OtherPlayer in ipairs(Players:GetPlayers()) do

        if OtherPlayer.Character
            and Model:IsDescendantOf(
                OtherPlayer.Character
            )
        then

            return true

        end
    end

    return false
end

local function IsAIModel(Model)

    if not Model
        or not Model:IsA("Model")
    then
        return false
    end

    if IsPlayerModel(Model) then
        return false
    end

    return Model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function FreezeAI(Model)

    if not IsAIModel(Model) then
        return
    end

    local Humanoid =
        Model:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if FrozenAI[Model] then
        return
    end

    FrozenAI[Model] = {

        Humanoid = Humanoid,

        WalkSpeed =
            Humanoid.WalkSpeed,

        JumpPower =
            Humanoid.JumpPower,

        JumpHeight =
            Humanoid.JumpHeight,

        AutoRotate =
            Humanoid.AutoRotate

    }

    pcall(function()

        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        Humanoid.JumpHeight = 0
        Humanoid.AutoRotate = false

    end)
end

local function UnfreezeAI(Model,Data)

    if not Data then
        return
    end

    local Humanoid = Data.Humanoid

    if not Humanoid
        or not Humanoid.Parent
    then
        return
    end

    pcall(function()

        Humanoid.WalkSpeed =
            Data.WalkSpeed

        Humanoid.JumpPower =
            Data.JumpPower

        Humanoid.JumpHeight =
            Data.JumpHeight

        Humanoid.AutoRotate =
            Data.AutoRotate

    end)
end

local function FreezeAllAI()

    for _,Object in ipairs(workspace:GetDescendants()) do

        if Object:IsA("Model")
            and IsAIModel(Object)
        then

            FreezeAI(Object)

        end
    end
end

local function UnfreezeAllAI()

    for Model,Data in pairs(FrozenAI) do
        UnfreezeAI(Model,Data)
    end

    table.clear(FrozenAI)
end

AIFreezeButton.MouseButton1Click:Connect(function()

    if AIFreezeEnabled then

        AIFreezeEnabled = false

        UnfreezeAllAI()

        AIFreezeButton.Text =
            "CHAR FREEZE: OFF"

        AIFreezeButton.TextColor3 =
            Color3.fromRGB(255,110,110)

        AIFreezeButton.BackgroundColor3 =
            Color3.fromRGB(55,55,68)

    else

        AIFreezeEnabled = true

        FreezeAllAI()

        AIFreezeButton.Text =
            "CHAR FREEZE: ON"

        AIFreezeButton.TextColor3 =
            Color3.fromRGB(100,255,130)

        AIFreezeButton.BackgroundColor3 =
            Color3.fromRGB(35,75,48)

    end
end)

--//============================================================//
--// NEW AI DETECTION
--//============================================================//

workspace.DescendantAdded:Connect(function(Object)

    if not AIFreezeEnabled then
        return
    end

    task.defer(function()

        local Model =
            Object:FindFirstAncestorOfClass("Model")

        if Model
            and IsAIModel(Model)
        then

            FreezeAI(Model)

        end
    end)
end)

--//============================================================//
--// NEW GUARDS
--//============================================================//

workspace.DescendantAdded:Connect(function(Object)

    if not GuardFreezeEnabled then
        return
    end

    local Folder = GetGuardFolder()

    if not Folder then
        return
    end

    if not Object:IsDescendantOf(Folder) then
        return
    end

    task.defer(function()

        local Model =
            Object:FindFirstAncestorOfClass("Model")

        if Model
            and IsGuardModel(Model)
            and Model:IsDescendantOf(Folder)
        then

            FreezeGuard(Model)

        end
    end)
end)

--//============================================================//
--// FPS BOOST NEW OBJECT DETECTION
--//============================================================//

workspace.DescendantAdded:Connect(function(Object)

    if not FPSBoostEnabled then
        return
    end

    task.defer(function()

        if not FPSBoostEnabled then
            return
        end

        if IsRenderFolder(Object) then

            RemoveRenderFolder(Object)
            return

        end

        if IsObjectFolder(Object) then

            RemoveObjectFolder(Object)
            return

        end

        --// Check ancestors manually
        local Current = Object

        while Current
            and Current ~= workspace
        do

            if IsRenderFolder(Current) then

                RemoveRenderFolder(Current)
                return

            end

            Current = Current.Parent

        end

        ApplyBoost(Object)

    end)
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

local function GetNearbyTarget()

    local Character = Player.Character

    if not Character then
        return nil
    end

    local Root =
        Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return nil
    end

    local ClosestTarget = nil
    local ClosestDistance = BatDetectionDistance

    for _,OtherPlayer in ipairs(Players:GetPlayers()) do

        if OtherPlayer ~= Player then

            local TargetCharacter =
                OtherPlayer.Character

            if TargetCharacter then

                local TargetHumanoid =
                    TargetCharacter:FindFirstChildOfClass(
                        "Humanoid"
                    )

                local TargetRoot =
                    TargetCharacter:FindFirstChild(
                        "HumanoidRootPart"
                    )

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
                        ClosestTarget = TargetCharacter

                    end
                end
            end
        end
    end

    return ClosestTarget
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
            "BAT AUTO: ON"

        BatAutoButton.TextColor3 =
            Color3.fromRGB(100,255,130)

        BatAutoButton.BackgroundColor3 =
            Color3.fromRGB(35,75,48)

    else

        BatAutoButton.Text =
            "BAT AUTO: OFF"

        BatAutoButton.TextColor3 =
            Color3.fromRGB(255,110,110)

        BatAutoButton.BackgroundColor3 =
            Color3.fromRGB(55,55,68)

    end
end)

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(0.01)

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
            "BAT VISUAL: OFF"

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
            "BAT VISUAL: OFF"

        return
    end

    local Success =
        ApplyBatVisual(BatName)

    if Success then

        BatVisualButton.Text =
            "BAT: " .. BatName

    else

        BatVisualButton.Text =
            "BAT VISUAL: " .. BatName

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
                "BAT: Cosmic Bat"

        end
    end
end)

--//============================================================//
--// FAR CAMERA
--//============================================================//

local FarCameraEnabled = false
local FarCameraDistance = 50
local FarCameraConnection = nil
local SavedMinZoomDistance = nil
local SavedMaxZoomDistance = nil

local function StartFarCamera()

    if FarCameraConnection then

        FarCameraConnection:Disconnect()
        FarCameraConnection = nil

    end

    local Camera =
        workspace.CurrentCamera

    if not Camera then
        return
    end

    SavedMinZoomDistance =
        Player.CameraMinZoomDistance

    SavedMaxZoomDistance =
        Player.CameraMaxZoomDistance

    Player.CameraMinZoomDistance =
        FarCameraDistance

    Player.CameraMaxZoomDistance =
        FarCameraDistance

    Player.CameraMode =
        Enum.CameraMode.Classic

    FarCameraConnection =
        RunService.RenderStepped:Connect(function()

            if not FarCameraEnabled then
                return
            end

            Player.CameraMode =
                Enum.CameraMode.Classic

            Player.CameraMinZoomDistance =
                FarCameraDistance

            Player.CameraMaxZoomDistance =
                FarCameraDistance

        end)
end

local function StopFarCamera()

    if FarCameraConnection then

        FarCameraConnection:Disconnect()
        FarCameraConnection = nil

    end

    if SavedMinZoomDistance ~= nil then

        Player.CameraMinZoomDistance =
            SavedMinZoomDistance

    end

    if SavedMaxZoomDistance ~= nil then

        Player.CameraMaxZoomDistance =
            SavedMaxZoomDistance

    end

    SavedMinZoomDistance = nil
    SavedMaxZoomDistance = nil
end

FarCameraButton.MouseButton1Click:Connect(function()

    FarCameraEnabled =
        not FarCameraEnabled

    if FarCameraEnabled then

        FarCameraButton.Text =
            "FAR CAMERA: ON"

        FarCameraButton.TextColor3 =
            Color3.fromRGB(100,255,130)

        FarCameraButton.BackgroundColor3 =
            Color3.fromRGB(35,75,48)

        StartFarCamera()

    else

        FarCameraButton.Text =
            "FAR CAMERA: OFF"

        FarCameraButton.TextColor3 =
            Color3.fromRGB(255,110,110)

        FarCameraButton.BackgroundColor3 =
            Color3.fromRGB(55,55,68)

        StopFarCamera()

    end
end)

--//============================================================//
--// CHARACTER RESPAWN
--//============================================================//

Player.CharacterAdded:Connect(function(Character)

    task.wait(0.75)

    if GodModeEnabled then

        local Humanoid =
            Character:FindFirstChildOfClass(
                "Humanoid"
            )

        if not Humanoid then

            Humanoid =
                Character:WaitForChild(
                    "Humanoid",
                    5
                )

        end

        if Humanoid
            and GodModeEnabled
        then

            ProtectHumanoid(Humanoid)

        end
    end

    if FloatEnabled then

        task.wait(0.15)
        StartFloat()

    end

    if FarCameraEnabled then

        task.wait(0.1)
        StartFarCamera()

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

            local Humanoid =
                GetHumanoid()

            if Humanoid then

                if Humanoid ~= CurrentGodHumanoid then
                    ProtectHumanoid(Humanoid)
                end

                pcall(function()

                    Humanoid:SetStateEnabled(
                        Enum.HumanoidStateType.Dead,
                        false
                    )

                    if Humanoid.Health <
                        Humanoid.MaxHealth
                    then

                        Humanoid.Health =
                            Humanoid.MaxHealth

                    end

                end)
            end
        end
    end
end)

--//============================================================//
--// GUARD FREEZE SAFETY
--//============================================================//

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(0.5)

        if GuardFreezeEnabled then

            local Folder =
                GetGuardFolder()

            if Folder then

                for Model,Data in pairs(FrozenGuards) do

                    if Model
                        and Model.Parent
                        and IsGuardModel(Model)
                    then

                        for Part in pairs(Data.Parts) do

                            if Part
                                and Part.Parent
                            then

                                pcall(function()
                                    Part.Anchored = true
                                end)

                            end
                        end

                    else

                        FrozenGuards[Model] = nil

                    end
                end
            end
        end
    end
end)

--//============================================================//
--// CHAR FREEZE SAFETY
--//============================================================//

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(0.25)

        if AIFreezeEnabled then

            for Model,Data in pairs(FrozenAI) do

                if Model
                    and Model.Parent
                    and IsAIModel(Model)
                then

                    local Humanoid =
                        Data.Humanoid

                    if Humanoid
                        and Humanoid.Parent
                    then

                        pcall(function()

                            Humanoid.WalkSpeed = 0
                            Humanoid.JumpPower = 0
                            Humanoid.JumpHeight = 0
                            Humanoid.AutoRotate = false

                        end)
                    end

                else

                    FrozenAI[Model] = nil

                end
            end
        end
    end
end)

--//============================================================//
--// OPEN BUTTON
--//============================================================//

local OpenButton = Instance.new("TextButton")

OpenButton.Size =
    UDim2.new(0,58,0,58)

OpenButton.Position =
    UDim2.new(0,20,0.5,-29)

OpenButton.BackgroundColor3 =
    Color3.fromRGB(25,25,33)

OpenButton.Text = "🥚"
OpenButton.TextSize = 29
OpenButton.TextColor3 =
    Color3.fromRGB(255,255,255)

OpenButton.BorderSizePixel = 0
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Parent = ScreenGui

local OpenCorner =
    Instance.new("UICorner")

OpenCorner.CornerRadius =
    UDim.new(1,0)

OpenCorner.Parent =
    OpenButton

local OpenStroke =
    Instance.new("UIStroke")

OpenStroke.Color =
    Color3.fromRGB(255,205,70)

OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

CloseButton.MouseButton1Click:Connect(function()

    Main.Visible = false
    OpenButton.Visible = true

end)

OpenButton.MouseButton1Click:Connect(function()

    Main.Visible = true
    OpenButton.Visible = false

end)

--//============================================================//
--// DRAG MAIN
--//============================================================//

local MainDragging = false
local MainDragStart
local MainStartPosition
local MainDragInput

Header.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or Input.UserInputType ==
        Enum.UserInputType.Touch
    then

        MainDragging = true

        MainDragStart =
            Input.Position

        MainStartPosition =
            Main.Position

        MainDragInput =
            Input

    end
end)

Header.InputChanged:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseMovement

        or Input.UserInputType ==
        Enum.UserInputType.Touch
    then

        MainDragInput =
            Input

    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if MainDragging
        and Input == MainDragInput
    then

        local Delta =
            Input.Position -
            MainDragStart

        Main.Position =
            UDim2.new(

                MainStartPosition.X.Scale,
                MainStartPosition.X.Offset + Delta.X,

                MainStartPosition.Y.Scale,
                MainStartPosition.Y.Offset + Delta.Y

            )
    end
end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1

        or Input.UserInputType ==
        Enum.UserInputType.Touch
    then

        MainDragging = false

    end
end)

--//============================================================//
--// PAGE SWITCHING
--//============================================================//

HomeButton.MouseButton1Click:Connect(function()

    HomePage.Visible = true
    FPSPage.Visible = false

    HomeButton.BackgroundColor3 =
        Color3.fromRGB(255,195,60)

    HomeButton.TextColor3 =
        Color3.fromRGB(25,25,25)

    FPSButton.BackgroundColor3 =
        Color3.fromRGB(35,35,45)

    FPSButton.TextColor3 =
        Color3.fromRGB(170,170,180)

end)

FPSButton.MouseButton1Click:Connect(function()

    HomePage.Visible = false
    FPSPage.Visible = true

    FPSButton.BackgroundColor3 =
        Color3.fromRGB(255,195,60)

    FPSButton.TextColor3 =
        Color3.fromRGB(25,25,25)

    HomeButton.BackgroundColor3 =
        Color3.fromRGB(35,35,45)

    HomeButton.TextColor3 =
        Color3.fromRGB(170,170,180)

end)

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

    EnableFPSBoost()

    --// FLOAT
    task.wait(0.15)

    EnableFloat()

    --// GUARD FREEZE
    task.wait(0.15)

    GuardFreezeEnabled = true
    FreezeAllGuards()

    GuardFreezeButton.Text =
        "FREEZE GUARDS: ON"

    GuardFreezeButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    GuardFreezeButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    --// CHAR FREEZE
    task.wait(0.15)

    AIFreezeEnabled = true
    FreezeAllAI()

    AIFreezeButton.Text =
        "CHAR FREEZE: ON"

    AIFreezeButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    AIFreezeButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    --// BAT AUTO
    task.wait(0.15)

    BatAutoEnabled = true

    BatAutoButton.Text =
        "BAT AUTO: ON"

    BatAutoButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    BatAutoButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    --// FAR CAMERA
    task.wait(0.15)

    FarCameraEnabled = true

    FarCameraButton.Text =
        "FAR CAMERA: ON"

    FarCameraButton.TextColor3 =
        Color3.fromRGB(100,255,130)

    FarCameraButton.BackgroundColor3 =
        Color3.fromRGB(35,75,48)

    StartFarCamera()

    --// COSMIC BAT
    task.wait(0.15)

    BatVisualEnabled = true
    BatVisualIndex = 7

    BatVisualButton.Text =
        "BAT: Cosmic Bat"

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
        "● ALL FEATURES ENABLED"

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
        "✓ FLOAT"
    )

    print(
        "✓ GUARD FREEZE"
    )

    print(
        "✓ CHAR FREEZE"
    )

    print(
        "✓ BAT AUTO"
    )

    print(
        "✓ FAR CAMERA"
    )

    print(
        "✓ COSMIC BAT"
    )

end)

--//============================================================//
--// CLEANUP
--//============================================================//

ScreenGui.Destroying:Connect(function()

    FloatEnabled = false
    StopFloat()

    GodModeEnabled = false
    DisconnectGodConnections()

    GuardFreezeEnabled = false
    UnfreezeAllGuards()

    AIFreezeEnabled = false
    UnfreezeAllAI()

    if FPSBoostEnabled then
        DisableFPSBoost()
    end

    RestoreRenderFolders()
    RestoreObjectFolders()

    BatAutoEnabled = false

    FarCameraEnabled = false
    StopFarCamera()

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
    "🥚 EGG FPS MONITOR LOADED - AUTO START ENABLED"
)

print(
    "🌌 COSMIC BAT SELECTED AUTOMATICALLY"
)
