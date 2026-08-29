--// EGG FPS MONITOR
--// FPS BOOST + GOD MODE + ADVANCED FLOAT + GUARD FREEZE + AI FREEZE

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- REMOVE OLD GUI
--------------------------------------------------

local OldGUI = PlayerGui:FindFirstChild("EggFPSMonitor")

if OldGUI then
	OldGUI:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggFPSMonitor"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- MAIN
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 350, 0, 405)
Main.Position = UDim2.new(0.5, -175, 0.5, -202)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 205, 70)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 37)
Header.BorderSizePixel = 0
Header.Active = true
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local EggIcon = Instance.new("TextLabel")
EggIcon.Size = UDim2.new(0, 48, 0, 48)
EggIcon.Position = UDim2.new(0, 8, 0, 6)
EggIcon.BackgroundTransparency = 1
EggIcon.Text = "🥚"
EggIcon.TextSize = 30
EggIcon.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 210, 0, 25)
Title.Position = UDim2.new(0, 58, 0, 7)
Title.BackgroundTransparency = 1
Title.Text = "KYOSH [SAE]"
Title.TextColor3 = Color3.fromRGB(255, 215, 80)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 210, 0, 18)
Subtitle.Position = UDim2.new(0, 59, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Performance + Protection"
Subtitle.TextColor3 = Color3.fromRGB(155, 155, 165)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -42, 0, 14)
CloseButton.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 21
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = CloseButton

--------------------------------------------------
-- CATEGORY BAR
--------------------------------------------------

local CategoryBar = Instance.new("Frame")
CategoryBar.Size = UDim2.new(1, -20, 0, 38)
CategoryBar.Position = UDim2.new(0, 10, 0, 70)
CategoryBar.BackgroundTransparency = 1
CategoryBar.Parent = Main

--------------------------------------------------
-- HOME BUTTON
--------------------------------------------------

local HomeButton = Instance.new("TextButton")
HomeButton.Size = UDim2.new(0.5, -4, 1, 0)
HomeButton.Position = UDim2.new(0, 0, 0, 0)
HomeButton.BackgroundColor3 = Color3.fromRGB(255, 195, 60)
HomeButton.Text = "HOME"
HomeButton.TextColor3 = Color3.fromRGB(25, 25, 25)
HomeButton.TextSize = 12
HomeButton.Font = Enum.Font.GothamBold
HomeButton.BorderSizePixel = 0
HomeButton.Parent = CategoryBar

local HomeCorner = Instance.new("UICorner")
HomeCorner.CornerRadius = UDim.new(0, 9)
HomeCorner.Parent = HomeButton

--------------------------------------------------
-- FPS BUTTON
--------------------------------------------------

local FPSButton = Instance.new("TextButton")
FPSButton.Size = UDim2.new(0.5, -4, 1, 0)
FPSButton.Position = UDim2.new(0.5, 4, 0, 0)
FPSButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FPSButton.Text = "FPS"
FPSButton.TextColor3 = Color3.fromRGB(170, 170, 180)
FPSButton.TextSize = 12
FPSButton.Font = Enum.Font.GothamBold
FPSButton.BorderSizePixel = 0
FPSButton.Parent = CategoryBar

local FPSCorner = Instance.new("UICorner")
FPSCorner.CornerRadius = UDim.new(0, 9)
FPSCorner.Parent = FPSButton

--------------------------------------------------
-- HOME PAGE
--------------------------------------------------

local HomePage = Instance.new("Frame")
HomePage.Size = UDim2.new(1, -20, 0, 250)
HomePage.Position = UDim2.new(0, 10, 0, 120)
HomePage.BackgroundTransparency = 1
HomePage.Parent = Main

local HomeTitle = Instance.new("TextLabel")
HomeTitle.Size = UDim2.new(1, 0, 0, 30)
HomeTitle.BackgroundTransparency = 1
HomeTitle.Text = "🥚 Welcome to Kyosh [SAE]"
HomeTitle.TextColor3 = Color3.fromRGB(230, 230, 235)
HomeTitle.TextSize = 14
HomeTitle.Font = Enum.Font.GothamBold
HomeTitle.TextXAlignment = Enum.TextXAlignment.Left
HomeTitle.Parent = HomePage

local HomeInfo = Instance.new("TextLabel")
HomeInfo.Size = UDim2.new(1, 0, 0, 180)
HomeInfo.Position = UDim2.new(0, 0, 0, 40)
HomeInfo.BackgroundTransparency = 1

HomeInfo.Text =
	"Monitor your FPS and network ping in real time.\n\n" ..
	"60+ FPS = Smooth\n" ..
	"30–59 FPS = Moderate\n" ..
	"Below 30 FPS = Low\n\n" ..
	"FPS BOOST removes local visual effects.\n" ..
	"GOD MODE protects your Humanoid.\n" ..
	"FLOAT 0.5 follows the ground while allowing movement.\n" ..
	"GUARD FREEZE freezes guards inside GuardAreas.\n" ..
	"AI FREEZE sets NPC/Monster Humanoid speed to 0."

HomeInfo.TextColor3 = Color3.fromRGB(170, 170, 180)
HomeInfo.TextSize = 12
HomeInfo.Font = Enum.Font.Gotham
HomeInfo.TextXAlignment = Enum.TextXAlignment.Left
HomeInfo.TextYAlignment = Enum.TextYAlignment.Top
HomeInfo.Parent = HomePage

--------------------------------------------------
-- FPS PAGE
--------------------------------------------------

local FPSPage = Instance.new("Frame")
FPSPage.Size = UDim2.new(1, -20, 0, 250)
FPSPage.Position = UDim2.new(0, 10, 0, 120)
FPSPage.BackgroundTransparency = 1
FPSPage.Visible = false
FPSPage.Parent = Main

--------------------------------------------------
-- FPS BOX
--------------------------------------------------

local FPSBox = Instance.new("Frame")
FPSBox.Size = UDim2.new(0.48, 0, 0, 60)
FPSBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
FPSBox.BorderSizePixel = 0
FPSBox.Parent = FPSPage

local FPSBoxCorner = Instance.new("UICorner")
FPSBoxCorner.CornerRadius = UDim.new(0, 10)
FPSBoxCorner.Parent = FPSBox

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, 0, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Color3.fromRGB(100, 255, 130)
FPSLabel.TextSize = 21
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Parent = FPSBox

--------------------------------------------------
-- PING BOX
--------------------------------------------------

local PingBox = Instance.new("Frame")
PingBox.Size = UDim2.new(0.48, 0, 0, 60)
PingBox.Position = UDim2.new(0.52, 0, 0, 0)
PingBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
PingBox.BorderSizePixel = 0
PingBox.Parent = FPSPage

local PingCorner = Instance.new("UICorner")
PingCorner.CornerRadius = UDim.new(0, 10)
PingCorner.Parent = PingBox

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(1, 0, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "PING: --"
PingLabel.TextColor3 = Color3.fromRGB(100, 255, 130)
PingLabel.TextSize = 21
PingLabel.Font = Enum.Font.GothamBold
PingLabel.Parent = PingBox

--------------------------------------------------
-- STATUS
--------------------------------------------------

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 68)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● Monitoring"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 130)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FPSPage

--------------------------------------------------
-- GOD MODE BUTTON
--------------------------------------------------

local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0.48, 0, 0, 38)
GodModeButton.Position = UDim2.new(0, 0, 0, 100)
GodModeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
GodModeButton.Text = "GOD MODE: OFF"
GodModeButton.TextColor3 = Color3.fromRGB(255, 110, 110)
GodModeButton.TextSize = 12
GodModeButton.Font = Enum.Font.GothamBold
GodModeButton.BorderSizePixel = 0
GodModeButton.Parent = FPSPage

local GodCorner = Instance.new("UICorner")
GodCorner.CornerRadius = UDim.new(0, 9)
GodCorner.Parent = GodModeButton

--------------------------------------------------
-- FPS BOOST BUTTON
--------------------------------------------------

local FPSBoostButton = Instance.new("TextButton")
FPSBoostButton.Size = UDim2.new(0.48, 0, 0, 38)
FPSBoostButton.Position = UDim2.new(0.52, 0, 0, 100)
FPSBoostButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
FPSBoostButton.Text = "FPS BOOST: OFF"
FPSBoostButton.TextColor3 = Color3.fromRGB(255, 110, 110)
FPSBoostButton.TextSize = 12
FPSBoostButton.Font = Enum.Font.GothamBold
FPSBoostButton.BorderSizePixel = 0
FPSBoostButton.Parent = FPSPage

local BoostCorner = Instance.new("UICorner")
BoostCorner.CornerRadius = UDim.new(0, 9)
BoostCorner.Parent = FPSBoostButton

--------------------------------------------------
-- FLOAT BUTTON
--------------------------------------------------

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0.48, 0, 0, 38)
FloatButton.Position = UDim2.new(0, 0, 0, 148)
FloatButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
FloatButton.Text = "FLOAT 0.5: OFF"
FloatButton.TextColor3 = Color3.fromRGB(255, 110, 110)
FloatButton.TextSize = 12
FloatButton.Font = Enum.Font.GothamBold
FloatButton.BorderSizePixel = 0
FloatButton.Parent = FPSPage

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 9)
FloatCorner.Parent = FloatButton

--------------------------------------------------
-- GUARD FREEZE BUTTON
--------------------------------------------------

local GuardFreezeButton = Instance.new("TextButton")
GuardFreezeButton.Size = UDim2.new(0.48, 0, 0, 38)
GuardFreezeButton.Position = UDim2.new(0.52, 0, 0, 148)
GuardFreezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
GuardFreezeButton.Text = "FREEZE GUARDS: OFF"
GuardFreezeButton.TextColor3 = Color3.fromRGB(255, 110, 110)
GuardFreezeButton.TextSize = 12
GuardFreezeButton.Font = Enum.Font.GothamBold
GuardFreezeButton.BorderSizePixel = 0
GuardFreezeButton.Parent = FPSPage

local GuardFreezeCorner = Instance.new("UICorner")
GuardFreezeCorner.CornerRadius = UDim.new(0, 9)
GuardFreezeCorner.Parent = GuardFreezeButton

--------------------------------------------------
-- AI FREEZE BUTTON
--------------------------------------------------

local AIFreezeButton = Instance.new("TextButton")
AIFreezeButton.Size = UDim2.new(0.48, 0, 0, 38)
AIFreezeButton.Position = UDim2.new(0, 0, 0, 196)
AIFreezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
AIFreezeButton.Text = "AI FREEZE: OFF"
AIFreezeButton.TextColor3 = Color3.fromRGB(255, 110, 110)
AIFreezeButton.TextSize = 12
AIFreezeButton.Font = Enum.Font.GothamBold
AIFreezeButton.BorderSizePixel = 0
AIFreezeButton.Parent = FPSPage

local AIFreezeCorner = Instance.new("UICorner")
AIFreezeCorner.CornerRadius = UDim.new(0, 9)
AIFreezeCorner.Parent = AIFreezeButton

--------------------------------------------------
-- GOD MODE
--------------------------------------------------

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

							Humanoid.Health =
								Humanoid.MaxHealth

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

					if Humanoid.Health <
						Humanoid.MaxHealth
					then

						Humanoid.Health =
							Humanoid.MaxHealth

					end

				end)

			end

		end)

	GodStateConnection =
		Humanoid.StateChanged:Connect(
			function(_, NewState)

				if not GodModeEnabled then
					return
				end

				if NewState ==
					Enum.HumanoidStateType.Dead
				then

					task.defer(function()

						if GodModeEnabled
							and Humanoid.Parent
						then

							pcall(function()

								Humanoid:SetStateEnabled(
									Enum.HumanoidStateType.Dead,
									false
								)

								Humanoid.Health =
									Humanoid.MaxHealth

								Humanoid:ChangeState(
									Enum.HumanoidStateType.GettingUp
								)

							end)

						end

					end)

				end

			end
		)
end

local function EnableGodMode()

	GodModeEnabled = true

	local Humanoid = GetHumanoid()

	if not Humanoid then
		GodModeEnabled = false
		return
	end

	ProtectHumanoid(Humanoid)

	GodModeButton.Text =
		"GOD MODE: ON"

	GodModeButton.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)

	GodModeButton.BackgroundColor3 =
		Color3.fromRGB(
			35,
			75,
			48
		)

	StatusLabel.Text =
		"● God Mode enabled"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)
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

	GodModeButton.Text =
		"GOD MODE: OFF"

	GodModeButton.TextColor3 =
		Color3.fromRGB(
			255,
			110,
			110
		)

	GodModeButton.BackgroundColor3 =
		Color3.fromRGB(
			55,
			55,
			68
		)

	StatusLabel.Text =
		"● God Mode disabled"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			170,
			170,
			180
		)
end

GodModeButton.MouseButton1Click:Connect(function()

	if GodModeEnabled then
		DisableGodMode()
	else
		EnableGodMode()
	end

end)

--------------------------------------------------
-- ADVANCED MOVABLE FLOAT 0.5
--------------------------------------------------

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

local function FindGround(Character, Root)

	local Params = RaycastParams.new()

	Params.FilterType =
		Enum.RaycastFilterType.Exclude

	Params.FilterDescendantsInstances = {
		Character
	}

	Params.IgnoreWater = false

	local Origin =
		Root.Position +
		Vector3.new(0, 2, 0)

	local Direction =
		Vector3.new(
			0,
			-FLOAT_RAY_DISTANCE,
			0
		)

	return workspace:Raycast(
		Origin,
		Direction,
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

			local Character =
				Player.Character

			if not Character then
				return
			end

			local Humanoid =
				Character:FindFirstChildOfClass(
					"Humanoid"
				)

			local Root =
				Character:FindFirstChild(
					"HumanoidRootPart"
				)

			if not Humanoid or not Root then
				return
			end

			local Ground =
				FindGround(
					Character,
					Root
				)

			if not Ground then
				return
			end

			--------------------------------------------------
			-- TARGET HEIGHT
			--------------------------------------------------

			local RootHalfHeight =
				math.max(
					Root.Size.Y * 1,
					1
				)

			local TargetY =
				Ground.Position.Y
				+ RootHalfHeight
				+ FloatHeight

			--------------------------------------------------
			-- ONLY CONTROL Y VELOCITY
			-- X/Z REMAIN UNDER HUMANOID CONTROL
			--------------------------------------------------

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

FloatButton.MouseButton1Click:Connect(function()

	FloatEnabled =
		not FloatEnabled

	if FloatEnabled then

		FloatButton.Text =
			"FLOAT 0.5: ON"

		FloatButton.TextColor3 =
			Color3.fromRGB(
				100,
				255,
				130
			)

		FloatButton.BackgroundColor3 =
			Color3.fromRGB(
				35,
				75,
				48
			)

		StartFloat()

		StatusLabel.Text =
			"● Float 0.5 enabled"

		StatusLabel.TextColor3 =
			Color3.fromRGB(
				100,
				255,
				130
			)

	else

		StopFloat()

		FloatButton.Text =
			"FLOAT 0.5: OFF"

		FloatButton.TextColor3 =
			Color3.fromRGB(
				255,
				110,
				110
			)

		FloatButton.BackgroundColor3 =
			Color3.fromRGB(
				55,
				55,
				68
			)

		StatusLabel.Text =
			"● Float disabled"

		StatusLabel.TextColor3 =
			Color3.fromRGB(
				170,
				170,
				180
			)

	end
end)

--------------------------------------------------
-- FPS BOOST
--------------------------------------------------

local FPSBoostEnabled = false

local SavedParts = {}
local SavedEffects = {}
local SavedLighting = {}

local function IsPlayerCharacter(Object)

	local Character =
		Player.Character

	if not Character then
		return false
	end

	return Object:IsDescendantOf(
		Character
	)
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

	if IsPlayerCharacter(Object) then
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

	for Property, Value in pairs(Properties) do

		if SavedLighting[Property] == nil then

			local Success, OldValue =
				pcall(function()

					return Lighting[Property]

				end)

			if Success then
				SavedLighting[Property] =
					OldValue
			end

		end

		pcall(function()

			Lighting[Property] =
				Value

		end)

	end
end

local function EnableFPSBoost()

	FPSBoostEnabled = true

	FPSBoostButton.Text =
		"FPS BOOST: ON"

	FPSBoostButton.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)

	FPSBoostButton.BackgroundColor3 =
		Color3.fromRGB(
			35,
			75,
			48
		)

	StatusLabel.Text =
		"● FPS Boost enabled"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)

	ApplyLightingBoost()

	for _, Object in ipairs(
		workspace:GetDescendants()
	) do

		ApplyBoost(Object)

	end
end

local function DisableFPSBoost()

	FPSBoostEnabled = false

	FPSBoostButton.Text =
		"FPS BOOST: OFF"

	FPSBoostButton.TextColor3 =
		Color3.fromRGB(
			255,
			110,
			110
		)

	FPSBoostButton.BackgroundColor3 =
		Color3.fromRGB(
			55,
			55,
			68
		)

	--------------------------------------------------
	-- RESTORE LIGHTING
	--------------------------------------------------

	for Property, Value in pairs(
		SavedLighting
	) do

		pcall(function()

			Lighting[Property] =
				Value

		end)

	end

	table.clear(
		SavedLighting
	)

	--------------------------------------------------
	-- RESTORE PARTS
	--------------------------------------------------

	for Object, Data in pairs(
		SavedParts
	) do

		if Object
			and Object.Parent
		then

			pcall(function()

				Object.LocalTransparencyModifier =
					Data.Transparency

				Object.CastShadow =
					Data.CastShadow

			end)

		end

	end

	table.clear(
		SavedParts
	)

	--------------------------------------------------
	-- RESTORE EFFECTS
	--------------------------------------------------

	for Object, Data in pairs(
		SavedEffects
	) do

		if Object
			and Object.Parent
		then

			pcall(function()

				if Data.Type ==
					"Transparency"
				then

					Object.Transparency =
						Data.Value

				else

					Object.Enabled =
						Data.Value

				end

			end)

		end

	end

	table.clear(
		SavedEffects
	)

	StatusLabel.Text =
		"● FPS Boost disabled"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			170,
			170,
			180
		)
end

FPSBoostButton.MouseButton1Click:Connect(function()

	if FPSBoostEnabled then
		DisableFPSBoost()
	else
		EnableFPSBoost()
	end

end)

--------------------------------------------------
-- GUARD FREEZE
--------------------------------------------------

local GuardFreezeEnabled = false
local FrozenGuards = {}
local GuardFolder = nil

local function GetGuardFolder()

	local ObjectsFolder =
		workspace:FindFirstChild(
			"__OBJECTS"
		)

	if not ObjectsFolder then
		return nil
	end

	local AreasFolder =
		ObjectsFolder:FindFirstChild(
			"Areas"
		)

	if not AreasFolder then
		return nil
	end

	return AreasFolder:FindFirstChild(
		"GuardAreas"
	)
end

local function IsGuardModel(Model)

	if not Model:IsA("Model") then
		return false
	end

	local Humanoid =
		Model:FindFirstChildOfClass(
			"Humanoid"
		)

	return Humanoid ~= nil
end

local function FreezeGuard(Model)

	if not IsGuardModel(Model) then
		return
	end

	if FrozenGuards[Model] then
		return
	end

	local Data = {

		Parts = {},

		Humanoid = nil,

		WalkSpeed = nil,

		JumpPower = nil,

		JumpHeight = nil,

		AutoRotate = nil

	}

	local Humanoid =
		Model:FindFirstChildOfClass(
			"Humanoid"
		)

	if Humanoid then

		Data.Humanoid =
			Humanoid

		Data.WalkSpeed =
			Humanoid.WalkSpeed

		Data.JumpPower =
			Humanoid.JumpPower

		Data.JumpHeight =
			Humanoid.JumpHeight

		Data.AutoRotate =
			Humanoid.AutoRotate

		pcall(function()

			Humanoid.WalkSpeed = 0
			Humanoid.JumpPower = 0
			Humanoid.JumpHeight = 0
			Humanoid.AutoRotate = false

		end)

	end

	for _, Object in ipairs(
		Model:GetDescendants()
	) do

		if Object:IsA("BasePart") then

			Data.Parts[Object] =
				Object.Anchored

			pcall(function()

				Object.Anchored = true

			end)

		end

	end

	FrozenGuards[Model] =
		Data
end

local function UnfreezeGuard(Model, Data)

	if not Data then
		return
	end

	for Object, OldAnchored in pairs(
		Data.Parts
	) do

		if Object
			and Object.Parent
		then

			pcall(function()

				Object.Anchored =
					OldAnchored

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

	GuardFolder =
		GetGuardFolder()

	if not GuardFolder then

		StatusLabel.Text =
			"● GuardAreas not found"

		StatusLabel.TextColor3 =
			Color3.fromRGB(
				255,
				80,
				80
			)

		return
	end

	local Count = 0

	for _, Object in ipairs(
		GuardFolder:GetDescendants()
	) do

		if Object:IsA("Model")
			and IsGuardModel(Object)
		then

			FreezeGuard(Object)

			Count += 1

		end

	end

	StatusLabel.Text =
		"● Frozen Guards: " ..
		Count

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)
end

local function UnfreezeAllGuards()

	for Model, Data in pairs(
		FrozenGuards
	) do

		UnfreezeGuard(
			Model,
			Data
		)

	end

	table.clear(
		FrozenGuards
	)

	StatusLabel.Text =
		"● Guards unfrozen"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			170,
			170,
			180
		)
end

GuardFreezeButton.MouseButton1Click:Connect(
	function()

		if GuardFreezeEnabled then

			GuardFreezeEnabled =
				false

			UnfreezeAllGuards()

			GuardFreezeButton.Text =
				"FREEZE GUARDS: OFF"

			GuardFreezeButton.TextColor3 =
				Color3.fromRGB(
					255,
					110,
					110
				)

			GuardFreezeButton.BackgroundColor3 =
				Color3.fromRGB(
					55,
					55,
					68
				)

		else

			GuardFreezeEnabled =
				true

			FreezeAllGuards()

			GuardFreezeButton.Text =
				"FREEZE GUARDS: ON"

			GuardFreezeButton.TextColor3 =
				Color3.fromRGB(
					100,
					255,
					130
				)

			GuardFreezeButton.BackgroundColor3 =
				Color3.fromRGB(
					35,
					75,
					48
				)

		end

	end
)

--------------------------------------------------
-- AI / MONSTER FREEZE
--------------------------------------------------

local AIFreezeEnabled = false

local FrozenAI = {}

--------------------------------------------------
-- CHECK IF MODEL BELONGS TO A PLAYER
--------------------------------------------------

local function IsPlayerModel(Model)

	if not Model then
		return false
	end

	for _, OtherPlayer in ipairs(
		Players:GetPlayers()
	) do

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

--------------------------------------------------
-- CHECK AI / MONSTER
--------------------------------------------------

local function IsAIModel(Model)

	if not Model
		or not Model:IsA("Model")
	then

		return false

	end

	if IsPlayerModel(Model) then
		return false
	end

	local Humanoid =
		Model:FindFirstChildOfClass(
			"Humanoid"
		)

	return Humanoid ~= nil
end

--------------------------------------------------
-- FREEZE ONE AI
--------------------------------------------------

local function FreezeAI(Model)

	if not IsAIModel(Model) then
		return
	end

	local Humanoid =
		Model:FindFirstChildOfClass(
			"Humanoid"
		)

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

		--------------------------------------------------
		-- SPEED = 0
		--------------------------------------------------

		Humanoid.WalkSpeed = 0

		--------------------------------------------------
		-- DISABLE JUMP MOVEMENT
		--------------------------------------------------

		Humanoid.JumpPower = 0
		Humanoid.JumpHeight = 0

		--------------------------------------------------
		-- STOP ROTATION
		--------------------------------------------------

		Humanoid.AutoRotate = false

	end)
end

--------------------------------------------------
-- RESTORE ONE AI
--------------------------------------------------

local function UnfreezeAI(Model, Data)

	if not Data then
		return
	end

	local Humanoid =
		Data.Humanoid

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

--------------------------------------------------
-- FREEZE ALL AI / MONSTERS
--------------------------------------------------

local function FreezeAllAI()

	local Count = 0

	for _, Object in ipairs(
		workspace:GetDescendants()
	) do

		if Object:IsA("Model")
			and IsAIModel(Object)
		then

			FreezeAI(Object)

			if FrozenAI[Object] then
				Count += 1
			end

		end

	end

	StatusLabel.Text =
		"● AI Speed 0: " ..
		Count

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			100,
			255,
			130
		)
end

--------------------------------------------------
-- RESTORE ALL AI
--------------------------------------------------

local function UnfreezeAllAI()

	for Model, Data in pairs(
		FrozenAI
	) do

		UnfreezeAI(
			Model,
			Data
		)

	end

	table.clear(
		FrozenAI
	)

	StatusLabel.Text =
		"● AI speed restored"

	StatusLabel.TextColor3 =
		Color3.fromRGB(
			170,
			170,
			180
		)
end

--------------------------------------------------
-- AI BUTTON
--------------------------------------------------

AIFreezeButton.MouseButton1Click:Connect(
	function()

		if AIFreezeEnabled then

			AIFreezeEnabled =
				false

			UnfreezeAllAI()

			AIFreezeButton.Text =
				"AI FREEZE: OFF"

			AIFreezeButton.TextColor3 =
				Color3.fromRGB(
					255,
					110,
					110
				)

			AIFreezeButton.BackgroundColor3 =
				Color3.fromRGB(
					55,
					55,
					68
				)

		else

			AIFreezeEnabled =
				true

			FreezeAllAI()

			AIFreezeButton.Text =
				"AI FREEZE: ON"

			AIFreezeButton.TextColor3 =
				Color3.fromRGB(
					100,
					255,
					130
				)

			AIFreezeButton.BackgroundColor3 =
				Color3.fromRGB(
					35,
					75,
					48
				)

		end

	end
)

--------------------------------------------------
-- NEW AI DETECTION
--------------------------------------------------

workspace.DescendantAdded:Connect(
	function(Object)

		if not AIFreezeEnabled then
			return
		end

		task.defer(function()

			local Model =
				Object:FindFirstAncestorOfClass(
					"Model"
				)

			if Model
				and IsAIModel(Model)
			then

				FreezeAI(Model)

			end

		end)

	end
)

--------------------------------------------------
-- NEW GUARDS
--------------------------------------------------

workspace.DescendantAdded:Connect(
	function(Object)

		if not GuardFreezeEnabled then
			return
		end

		local Folder =
			GetGuardFolder()

		if not Folder then
			return
		end

		if not Object:IsDescendantOf(
			Folder
		) then

			return

		end

		task.defer(function()

			local Model =
				Object:FindFirstAncestorOfClass(
					"Model"
				)

			if Model
				and IsGuardModel(Model)
				and Model:IsDescendantOf(
					Folder
				)
			then

				FreezeGuard(Model)

			end

		end)

	end
)

--------------------------------------------------
-- NEW WORLD OBJECTS FOR FPS BOOST
--------------------------------------------------

workspace.DescendantAdded:Connect(
	function(Object)

		if FPSBoostEnabled then

			task.defer(function()

				if FPSBoostEnabled then

					ApplyBoost(
						Object
					)

				end

			end)

		end

	end
)

--------------------------------------------------
-- CHARACTER RESPAWN
--------------------------------------------------

Player.CharacterAdded:Connect(
	function(Character)

		task.wait(0.5)

		--------------------------------------------------
		-- GOD MODE
		--------------------------------------------------

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

				ProtectHumanoid(
					Humanoid
				)

			end

		end

		--------------------------------------------------
		-- FLOAT
		--------------------------------------------------

		if FloatEnabled then

			task.wait(0.15)

			StartFloat()

		end

	end
)

--------------------------------------------------
-- FLOAT LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(
	function()

		-- Float is controlled by StartFloat()

	end
)

--------------------------------------------------
-- GOD MODE LOOP
--------------------------------------------------

task.spawn(function()

	while ScreenGui.Parent do

		task.wait(0.1)

		if GodModeEnabled then

			local Humanoid =
				GetHumanoid()

			if Humanoid then

				if Humanoid ~=
					CurrentGodHumanoid
				then

					ProtectHumanoid(
						Humanoid
					)

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

--------------------------------------------------
-- GUARD FREEZE SAFETY LOOP
--------------------------------------------------

task.spawn(function()

	while ScreenGui.Parent do

		task.wait(0.5)

		if GuardFreezeEnabled then

			local Folder =
				GetGuardFolder()

			if Folder then

				for Model, Data in pairs(
					FrozenGuards
				) do

					if Model
						and Model.Parent
						and IsGuardModel(Model)
					then

						for Part, OldAnchored in pairs(
							Data.Parts
						) do

							if Part
								and Part.Parent
							then

								pcall(function()

									Part.Anchored =
										true

								end)

							end

						end

					else

						FrozenGuards[Model] =
							nil

					end

				end

			end

		end

	end

end)

--------------------------------------------------
-- AI FREEZE SAFETY LOOP
--------------------------------------------------

task.spawn(function()

	while ScreenGui.Parent do

		task.wait(0.25)

		if AIFreezeEnabled then

			for Model, Data in pairs(
				FrozenAI
			) do

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

							--------------------------------------------------
							-- KEEP AI SPEED AT 0
							--------------------------------------------------

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

--------------------------------------------------
-- OPEN BUTTON
--------------------------------------------------

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 58, 0, 58)
OpenButton.Position = UDim2.new(0, 20, 0.5, -29)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
OpenButton.Text = "🥚"
OpenButton.TextSize = 29
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.BorderSizePixel = 0
OpenButton.Visible = false
OpenButton.Active = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(255, 205, 70)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

--------------------------------------------------
-- CLOSE
--------------------------------------------------

CloseButton.MouseButton1Click:Connect(
	function()

		Main.Visible = false
		OpenButton.Visible = true

	end
)

--------------------------------------------------
-- OPEN
--------------------------------------------------

OpenButton.MouseButton1Click:Connect(
	function()

		Main.Visible = true
		OpenButton.Visible = false

	end
)

--------------------------------------------------
-- DRAG MAIN
--------------------------------------------------

local MainDragging = false
local MainDragStart
local MainStartPosition
local MainDragInput

Header.InputBegan:Connect(
	function(Input)

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

	end
)

Header.InputChanged:Connect(
	function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseMovement
			or Input.UserInputType ==
			Enum.UserInputType.Touch
		then

			MainDragInput =
				Input

		end

	end
)

UserInputService.InputChanged:Connect(
	function(Input)

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

	end
)

UserInputService.InputEnded:Connect(
	function(Input)

		if Input.UserInputType ==
			Enum.UserInputType.MouseButton1
			or Input.UserInputType ==
			Enum.UserInputType.Touch
		then

			MainDragging = false

		end

	end
)

--------------------------------------------------
-- PAGE SWITCHING
--------------------------------------------------

HomeButton.MouseButton1Click:Connect(
	function()

		HomePage.Visible = true
		FPSPage.Visible = false

		HomeButton.BackgroundColor3 =
			Color3.fromRGB(
				255,
				195,
				60
			)

		HomeButton.TextColor3 =
			Color3.fromRGB(
				25,
				25,
				25
			)

		FPSButton.BackgroundColor3 =
			Color3.fromRGB(
				35,
				35,
				45
			)

		FPSButton.TextColor3 =
			Color3.fromRGB(
				170,
				170,
				180
			)

	end
)

FPSButton.MouseButton1Click:Connect(
	function()

		HomePage.Visible = false
		FPSPage.Visible = true

		FPSButton.BackgroundColor3 =
			Color3.fromRGB(
				255,
				195,
				60
			)

		FPSButton.TextColor3 =
			Color3.fromRGB(
				25,
				25,
				25
			)

		HomeButton.BackgroundColor3 =
			Color3.fromRGB(
				35,
				35,
				45
			)

		HomeButton.TextColor3 =
			Color3.fromRGB(
				170,
				170,
				180
			)

	end
)

--------------------------------------------------
-- FPS MONITOR
--------------------------------------------------

local Frames = 0
local LastTime = os.clock()

RunService.RenderStepped:Connect(
	function()

		Frames += 1

		local CurrentTime =
			os.clock()

		if CurrentTime -
			LastTime >= 1
		then

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
					Color3.fromRGB(
						100,
						255,
						130
					)

			elseif FPS >= 30 then

				FPSLabel.TextColor3 =
					Color3.fromRGB(
						255,
						215,
						80
					)

			else

				FPSLabel.TextColor3 =
					Color3.fromRGB(
						255,
						80,
						80
					)

			end

		end

	end
)

--------------------------------------------------
-- PING MONITOR
--------------------------------------------------

task.spawn(function()

	while ScreenGui.Parent do

		task.wait(1)

		local Ping = 0

		pcall(function()

			Ping =
				math.floor(
					Player:GetNetworkPing()
					* 1000
				)

		end)

		PingLabel.Text =
			"PING: " ..
			Ping ..
			" ms"

		if Ping <= 80 then

			PingLabel.TextColor3 =
				Color3.fromRGB(
					100,
					255,
					130
				)

		elseif Ping <= 150 then

			PingLabel.TextColor3 =
				Color3.fromRGB(
					255,
					215,
					80
				)

		else

			PingLabel.TextColor3 =
				Color3.fromRGB(
					255,
					80,
					80
				)

		end

	end

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

ScreenGui.Destroying:Connect(
	function()

		--------------------------------------------------
		-- FLOAT
		--------------------------------------------------

		FloatEnabled = false
		StopFloat()

		--------------------------------------------------
		-- GOD MODE
		--------------------------------------------------

		GodModeEnabled = false
		DisconnectGodConnections()

		--------------------------------------------------
		-- GUARDS
		--------------------------------------------------

		GuardFreezeEnabled = false
		UnfreezeAllGuards()

		--------------------------------------------------
		-- AI
		--------------------------------------------------

		AIFreezeEnabled = false
		UnfreezeAllAI()

		--------------------------------------------------
		-- FPS
		--------------------------------------------------

		if FPSBoostEnabled then
			DisableFPSBoost()
		end

	end
)

--------------------------------------------------
-- START
--------------------------------------------------

print(
	"🥚 EGG FPS MONITOR + FPS BOOST + GOD MODE + FLOAT 0.5 + GUARD FREEZE + AI FREEZE LOADED"
)
