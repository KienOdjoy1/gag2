local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GameUtilityGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 300)
main.Position = UDim2.new(0.5, -170, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(90, 80, 125)
stroke.Thickness = 1.5
stroke.Transparency = 0.15
stroke.Parent = main

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 30, 45)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 13, 19))
})
gradient.Rotation = 90
gradient.Parent = main

--==================================================
-- TOP BAR
--==================================================

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 62)
topBar.BackgroundColor3 = Color3.fromRGB(35, 28, 55)
topBar.BorderSizePixel = 0
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 55, 135)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 30, 55))
})
topGradient.Parent = topBar

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 30)
title.Position = UDim2.new(0, 15, 0, 7)
title.BackgroundTransparency = 1
title.Text = "MACRO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -70, 0, 18)
subtitle.Position = UDim2.new(0, 16, 0, 35)
subtitle.BackgroundTransparency = 1
subtitle.Text = "SAE BY KIEN"
subtitle.TextColor3 = Color3.fromRGB(190, 180, 210)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topBar

--==================================================
-- MINIMIZE
--==================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 40, 0, 34)
minimize.Position = UDim2.new(1, -50, 0, 14)
minimize.BackgroundColor3 = Color3.fromRGB(60, 55, 75)
minimize.BorderSizePixel = 0
minimize.Text = "−"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 22
minimize.Font = Enum.Font.GothamBold
minimize.Parent = topBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 9)
minimizeCorner.Parent = minimize

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.new(0, 15, 0, 70)
status.BackgroundTransparency = 1
status.Text = "●  Ready"
status.TextColor3 = Color3.fromRGB(150, 150, 165)
status.TextSize = 11
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==================================================
-- BUTTON FUNCTION
--==================================================

local function createButton(text, x, y, width, height, color)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, width, 0, height)
	button.Position = UDim2.new(0, x, 0, y)
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.Parent = main

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = button

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 255, 255)
	buttonStroke.Transparency = 0.9
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button

	button.MouseEnter:Connect(function()

		button.BackgroundColor3 = Color3.fromRGB(
			math.min(color.R * 255 + 15, 255),
			math.min(color.G * 255 + 15, 255),
			math.min(color.B * 255 + 15, 255)
		)

	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = color
	end)

	return button
end

--==================================================
-- BUTTONS
--==================================================

local godMode = createButton(
	"GOD MODE: OFF",
	10, 105,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local transparencyButton = createButton(
	"TRANSPARENCY: OFF",
	175, 105,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local transparencyLevel = createButton(
	"TRANSPARENCY 50%",
	10, 155,
	320, 42,
	Color3.fromRGB(90, 65, 145)
)

local antiFallButton = createButton(
	"ANTI-FALL: OFF",
	10, 205,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local noKnockbackButton = createButton(
	"NO KNOCKBACK: OFF",
	175, 205,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local lowGraphicsButton = createButton(
	"LOW GRAPHICS: OFF",
	10, 255,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local removeEffectsButton = createButton(
	"EFFECTS: OFF",
	175, 255,
	155, 42,
	Color3.fromRGB(65, 65, 80)
)

local hidePartsButton = createButton(
	"HIDE PARTS: OFF",
	10, 305,
	320, 42,
	Color3.fromRGB(65, 65, 80)
)

local ragdollButton = createButton(
	"RAGDOLL: OFF",
	10, 355,
	320, 42,
	Color3.fromRGB(65, 65, 80)
)

--==================================================
-- STATES
--==================================================

local godModeEnabled = false
local godConnection = nil

local transparencyEnabled = false
local transparencyValue = 0.5
local originalTransparency = {}

local antiFallEnabled = false
local antiFallConnection = nil

local noKnockbackEnabled = false
local noKnockbackConnection = nil

local lowGraphicsEnabled = false

local effectsRemoved = false
local savedEffects = {}

local partsHidden = false
local hiddenParts = {}
local hiddenDecals = {}

local ragdollEnabled = false
local ragdollConnection = nil

--==================================================
-- CHARACTER FUNCTIONS
--==================================================

local function getCharacter()
	return player.Character
end

local function getHumanoid()

	local character = getCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()

	local character = getCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- GOD MODE
--==================================================

local function enableGodMode()

	local humanoid = getHumanoid()

	if not humanoid then
		return false
	end

	humanoid.Health = humanoid.MaxHealth

	if godConnection then
		godConnection:Disconnect()
	end

	godConnection = humanoid.HealthChanged:Connect(function()

		if godModeEnabled and humanoid.Parent then

			if humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end

		end

	end)

	return true
end

local function disableGodMode()

	if godConnection then
		godConnection:Disconnect()
		godConnection = nil
	end

end

godMode.MouseButton1Click:Connect(function()

	godModeEnabled = not godModeEnabled

	if godModeEnabled then

		if not enableGodMode() then

			godModeEnabled = false

			status.Text = "●  Character not found!"
			status.TextColor3 =
				Color3.fromRGB(255, 100, 100)

			return
		end

		godMode.Text = "GOD MODE: ON"
		godMode.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text = "●  God Mode enabled"
		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		disableGodMode()

		godMode.Text = "GOD MODE: OFF"
		godMode.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text = "●  God Mode disabled"
		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end)

--==================================================
-- TRANSPARENCY
--==================================================

local function saveTransparency(object)

	if originalTransparency[object] == nil then
		originalTransparency[object] = object.Transparency
	end

end

local function setAvatarTransparency(value)

	local character = getCharacter()

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do

		if object:IsA("BasePart") then

			if object.Name == "HumanoidRootPart" then

				object.Transparency = 1

			else

				saveTransparency(object)
				object.Transparency = value

			end

		elseif object:IsA("Decal") then

			saveTransparency(object)
			object.Transparency = value

		end

	end

end

local function restoreAvatarTransparency()

	for object, value in pairs(originalTransparency) do

		if object and object.Parent then
			object.Transparency = value
		end

	end

end

transparencyButton.MouseButton1Click:Connect(function()

	transparencyEnabled = not transparencyEnabled

	if transparencyEnabled then

		setAvatarTransparency(transparencyValue)

		transparencyButton.Text =
			"TRANSPARENCY: ON"

		transparencyButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Transparency enabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		restoreAvatarTransparency()

		transparencyButton.Text =
			"TRANSPARENCY: OFF"

		transparencyButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Transparency disabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end)

--==================================================
-- TRANSPARENCY LEVEL
--==================================================

transparencyLevel.MouseButton1Click:Connect(function()

	if transparencyValue == 0.5 then

		transparencyValue = 0.75
		transparencyLevel.Text =
			"TRANSPARENCY 75%"

	elseif transparencyValue == 0.75 then

		transparencyValue = 0.25
		transparencyLevel.Text =
			"TRANSPARENCY 25%"

	else

		transparencyValue = 0.5
		transparencyLevel.Text =
			"TRANSPARENCY 50%"

	end

	if transparencyEnabled then
		setAvatarTransparency(transparencyValue)
	end

	status.Text =
		"●  Transparency: "
		.. math.floor(transparencyValue * 100)
		.. "%"

end)

--==================================================
-- ANTI-FALL
--==================================================

local function setAntiFall(enabled)

	antiFallEnabled = enabled

	local humanoid = getHumanoid()

	if not humanoid then
		return
	end

	if antiFallConnection then

		antiFallConnection:Disconnect()
		antiFallConnection = nil

	end

	if enabled then

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.FallingDown,
			false
		)

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Ragdoll,
			false
		)

		antiFallConnection =
			RunService.Heartbeat:Connect(function()

				if not antiFallEnabled then
					return
				end

				if not humanoid.Parent then
					return
				end

				local state = humanoid:GetState()

				if state ==
					Enum.HumanoidStateType.FallingDown
					or state ==
					Enum.HumanoidStateType.Ragdoll then

					humanoid:ChangeState(
						Enum.HumanoidStateType.GettingUp
					)

				end

			end)

		antiFallButton.Text =
			"ANTI-FALL: ON"

		antiFallButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Anti-Fall enabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.FallingDown,
			true
		)

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Ragdoll,
			true
		)

		antiFallButton.Text =
			"ANTI-FALL: OFF"

		antiFallButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Anti-Fall disabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

antiFallButton.MouseButton1Click:Connect(function()

	setAntiFall(not antiFallEnabled)

end)

--==================================================
-- NO KNOCKBACK
-- RETURN TO LAST STABLE POSITION
--==================================================

local function setNoKnockback(enabled)

	noKnockbackEnabled = enabled

	if noKnockbackConnection then

		noKnockbackConnection:Disconnect()
		noKnockbackConnection = nil

	end

	if enabled then

		local lastStablePosition = nil
		local lastStableCFrame = nil
		local lastNormalTime = 0

		noKnockbackConnection =
			RunService.Heartbeat:Connect(function()

				if not noKnockbackEnabled then
					return
				end

				local character = getCharacter()
				local humanoid = getHumanoid()
				local root = getRoot()

				if not character
					or not humanoid
					or not root then

					return
				end

				local velocity =
					root.AssemblyLinearVelocity

				local horizontalVelocity =
					Vector3.new(
						velocity.X,
						0,
						velocity.Z
					)

				local horizontalSpeed =
					horizontalVelocity.Magnitude

				--==========================================
				-- KNOCKBACK SETTINGS
				--==========================================

				local knockbackLimit =
					math.max(
						humanoid.WalkSpeed * 1.5,
						25
					)

				--==========================================
				-- SAVE STABLE POSITION
				--==========================================

				if horizontalSpeed <= knockbackLimit then

					lastStablePosition =
						root.Position

					lastStableCFrame =
						root.CFrame

					lastNormalTime =
						os.clock()

				end

				--==========================================
				-- DETECT STRONG KNOCKBACK
				--==========================================

				if horizontalSpeed >
					knockbackLimit then

					-- Stop horizontal launch.

					root.AssemblyLinearVelocity =
						Vector3.zero

					root.AssemblyAngularVelocity =
						Vector3.zero

					-- Return to the last stable position.

					if lastStableCFrame then

						root.CFrame =
							lastStableCFrame

					elseif lastStablePosition then

						root.CFrame =
							CFrame.new(
								lastStablePosition
							)

					end

					return

				end

				--==========================================
				-- DETECT LARGE POSITION JUMP
				--==========================================

				if lastStablePosition then

					local distance =
						(
							root.Position
							- lastStablePosition
						).Magnitude

					local recentlyStable =
						os.clock() - lastNormalTime < 0.8

					if distance > 12
						and recentlyStable then

						root.CFrame =
							CFrame.new(
								lastStablePosition
							)

						root.AssemblyLinearVelocity =
							Vector3.zero

						root.AssemblyAngularVelocity =
							Vector3.zero

					end

				end

			end)

		noKnockbackButton.Text =
			"NO KNOCKBACK: ON"

		noKnockbackButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  No Knockback enabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		noKnockbackButton.Text =
			"NO KNOCKBACK: OFF"

		noKnockbackButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  No Knockback disabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

noKnockbackButton.MouseButton1Click:Connect(function()

	setNoKnockback(not noKnockbackEnabled)

end)

--==================================================
-- LOW GRAPHICS
--==================================================

local function setLowGraphics(enabled)

	lowGraphicsEnabled = enabled

	if enabled then

		Lighting.GlobalShadows = false
		Lighting.Brightness = 1

		for _, object in ipairs(
			Lighting:GetChildren()
		) do

			if object:IsA("PostEffect") then
				object.Enabled = false
			end

		end

		local terrain =
			workspace:FindFirstChildOfClass("Terrain")

		if terrain then

			pcall(function()
				terrain.Decoration = false
			end)

		end

		lowGraphicsButton.Text =
			"LOW GRAPHICS: ON"

		lowGraphicsButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Low graphics enabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		lowGraphicsButton.Text =
			"LOW GRAPHICS: OFF"

		lowGraphicsButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Low graphics disabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

lowGraphicsButton.MouseButton1Click:Connect(function()

	setLowGraphics(not lowGraphicsEnabled)

end)

--==================================================
-- EFFECTS
-- FIXED:
-- ON = ENABLE
-- OFF = DISABLE
--==================================================

local function isVisualEffect(object)

	return object:IsA("ParticleEmitter")
		or object:IsA("Trail")
		or object:IsA("Beam")
		or object:IsA("Fire")
		or object:IsA("Smoke")
		or object:IsA("Sparkles")
		or object:IsA("PostEffect")

end

local function saveEffectState(object)

	if savedEffects[object] == nil then

		savedEffects[object] =
			object.Enabled

	end

end

local function setEffectsRemoved(enabled)

	effectsRemoved = enabled

	for _, object in ipairs(
		game:GetDescendants()
	) do

		if isVisualEffect(object) then

			if enabled then

				-- OFF = disable effect

				saveEffectState(object)
				object.Enabled = false

			else

				-- ON = restore effect

				local oldState =
					savedEffects[object]

				if oldState ~= nil then
					object.Enabled = oldState
				else
					object.Enabled = true
				end

			end

		end

	end

	if enabled then

		removeEffectsButton.Text =
			"EFFECTS: ON"

		removeEffectsButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Effects disabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		removeEffectsButton.Text =
			"EFFECTS: OFF"

		removeEffectsButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Effects enabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

removeEffectsButton.MouseButton1Click:Connect(function()

	setEffectsRemoved(not effectsRemoved)

end)

--==================================================
-- KEEP NEW EFFECTS DISABLED
--==================================================

game.DescendantAdded:Connect(function(object)

	if effectsRemoved
		and isVisualEffect(object) then

		task.defer(function()

			if object and object.Parent then
				object.Enabled = false
			end

		end)

	end

end)

--==================================================
-- HIDE PARTS
--==================================================

local function hideAllParts(enabled)

	partsHidden = enabled

	if enabled then

		for _, object in ipairs(
			workspace:GetDescendants()
		) do

			if object:IsA("BasePart") then

				if not player.Character
					or not object:IsDescendantOf(
						player.Character
					) then

					if hiddenParts[object] == nil then

						hiddenParts[object] =
							object.LocalTransparencyModifier

					end

					object.LocalTransparencyModifier =
						1

				end

			elseif object:IsA("Decal")
				or object:IsA("Texture") then

				if not player.Character
					or not object:IsDescendantOf(
						player.Character
					) then

					if hiddenDecals[object] == nil then

						hiddenDecals[object] =
							object.Transparency

					end

					object.Transparency = 1

				end

			end

		end

		hidePartsButton.Text =
			"HIDE PARTS: ON"

		hidePartsButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Map parts hidden"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		for object, value in pairs(
			hiddenParts
		) do

			if object and object.Parent then

				object.LocalTransparencyModifier =
					value

			end

		end

		for object, value in pairs(
			hiddenDecals
		) do

			if object and object.Parent then

				object.Transparency =
					value

			end

		end

		table.clear(hiddenParts)
		table.clear(hiddenDecals)

		hidePartsButton.Text =
			"HIDE PARTS: OFF"

		hidePartsButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Map parts restored"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

hidePartsButton.MouseButton1Click:Connect(function()

	hideAllParts(not partsHidden)

end)

--==================================================
-- RAGDOLL
--==================================================

local function maintainRagdoll()

	if ragdollConnection then

		ragdollConnection:Disconnect()
		ragdollConnection = nil

	end

	ragdollConnection =
		RunService.Heartbeat:Connect(function()

			if not ragdollEnabled then
				return
			end

			local humanoid =
				getHumanoid()

			if not humanoid then
				return
			end

			if humanoid:GetState()
				~= Enum.HumanoidStateType.Physics then

				humanoid:ChangeState(
					Enum.HumanoidStateType.Physics
				)

			end

			humanoid.AutoRotate = false
			humanoid.PlatformStand = true

		end)

end

local function stopRagdoll()

	if ragdollConnection then

		ragdollConnection:Disconnect()
		ragdollConnection = nil

	end

	local humanoid =
		getHumanoid()

	if humanoid then

		humanoid.PlatformStand = false
		humanoid.AutoRotate = true

		humanoid:ChangeState(
			Enum.HumanoidStateType.GettingUp
		)

	end

end

local function setRagdoll(enabled)

	ragdollEnabled = enabled

	local humanoid =
		getHumanoid()

	if not humanoid then

		status.Text =
			"●  Character not found!"

		status.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		return
	end

	if enabled then

		humanoid.PlatformStand = true
		humanoid.AutoRotate = false

		humanoid:ChangeState(
			Enum.HumanoidStateType.Physics
		)

		maintainRagdoll()

		ragdollButton.Text =
			"RAGDOLL: ON"

		ragdollButton.BackgroundColor3 =
			Color3.fromRGB(55, 170, 90)

		status.Text =
			"●  Ragdoll enabled"

		status.TextColor3 =
			Color3.fromRGB(80, 220, 120)

	else

		stopRagdoll()

		ragdollButton.Text =
			"RAGDOLL: OFF"

		ragdollButton.BackgroundColor3 =
			Color3.fromRGB(65, 65, 80)

		status.Text =
			"●  Ragdoll disabled"

		status.TextColor3 =
			Color3.fromRGB(150, 150, 160)

	end

end

ragdollButton.MouseButton1Click:Connect(function()

	setRagdoll(not ragdollEnabled)

end)

--==================================================
-- MINIMIZE
--==================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		for _, object in ipairs(
			main:GetChildren()
		) do

			if object ~= corner
				and object ~= stroke
				and object ~= gradient
				and object ~= topBar then

				if object:IsA("GuiObject") then
					object.Visible = false
				end

			end

		end

		main.Size =
			UDim2.new(0, 58, 0, 50)

		topBar.Size =
			UDim2.new(1, 0, 1, 0)

		title.Visible = false
		subtitle.Visible = false

		minimize.Size =
			UDim2.new(0, 42, 0, 38)

		minimize.Position =
			UDim2.new(0, 8, 0, 6)

		minimize.Text = "+"

	else

		main.Size =
			UDim2.new(0, 340, 0, 545)

		topBar.Size =
			UDim2.new(1, 0, 0, 62)

		title.Visible = true
		subtitle.Visible = true

		for _, object in ipairs(
			main:GetChildren()
		) do

			if object:IsA("GuiObject") then
				object.Visible = true
			end

		end

		minimize.Size =
			UDim2.new(0, 40, 0, 34)

		minimize.Position =
			UDim2.new(1, -50, 0, 14)

		minimize.Text = "−"

	end

end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(function(character)

	task.wait(1)

	if godModeEnabled then
		enableGodMode()
	end

	if transparencyEnabled then
		setAvatarTransparency(
			transparencyValue
		)
	end

	if antiFallEnabled then
		setAntiFall(true)
	end

	if noKnockbackEnabled then
		setNoKnockback(true)
	end

	if lowGraphicsEnabled then
		setLowGraphics(true)
	end

	if effectsRemoved then
		setEffectsRemoved(true)
	end

	if partsHidden then
		hideAllParts(true)
	end

	if ragdollEnabled then

		task.wait(0.2)

		setRagdoll(true)

	end

end)

--==================================================
-- CLEANUP
--==================================================

script.Destroying:Connect(function()

	if godConnection then

		godConnection:Disconnect()
		godConnection = nil

	end

	if antiFallConnection then

		antiFallConnection:Disconnect()
		antiFallConnection = nil

	end

	if noKnockbackConnection then

		noKnockbackConnection:Disconnect()
		noKnockbackConnection = nil

	end

	if ragdollConnection then

		ragdollConnection:Disconnect()
		ragdollConnection = nil

	end

end)
