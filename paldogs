local Players = game:GetService("Players")
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
main.Size = UDim2.new(0, 320, 0, 410)
main.Position = UDim2.new(0.5, -160, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 35)
title.Position = UDim2.new(0, 10, 0, 7)
title.BackgroundTransparency = 1
title.Text = "GAME MENU - GAG2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 35, 0, 30)
minimize.Position = UDim2.new(1, -45, 0, 8)
minimize.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
minimize.BorderSizePixel = 0
minimize.Text = "−"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.TextSize = 22
minimize.Font = Enum.Font.GothamBold
minimize.Parent = main

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimize

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 40)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(150, 150, 160)
status.TextSize = 12
status.Font = Enum.Font.Gotham
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
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.Parent = main

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 9)
	buttonCorner.Parent = button

	return button
end

--==================================================
-- POSITION BUTTONS
--==================================================

local save = createButton(
	"SAVE POSITION",
	10, 70,
	145, 42,
	Color3.fromRGB(55, 170, 90)
)

local teleport = createButton(
	"TELEPORT",
	165, 70,
	145, 42,
	Color3.fromRGB(55, 125, 230)
)

local clear = createButton(
	"CLEAR POSITION",
	10, 120,
	300, 35,
	Color3.fromRGB(190, 55, 65)
)

--==================================================
-- FPS BUTTONS
--==================================================

local fpsBoost = createButton(
	"FPS BOOST",
	10, 170,
	145, 42,
	Color3.fromRGB(40, 180, 100)
)

local normalGraphics = createButton(
	"NORMAL",
	165, 170,
	145, 42,
	Color3.fromRGB(55, 125, 230)
)

local removeEffects = createButton(
	"REMOVE EFFECTS",
	10, 220,
	145, 42,
	Color3.fromRGB(120, 80, 180)
)

local lowGraphics = createButton(
	"LOW GRAPHICS",
	165, 220,
	145, 42,
	Color3.fromRGB(190, 120, 55)
)

--==================================================
-- INSTANT E
--==================================================

local instantE = createButton(
	"INSTANT E: OFF",
	10, 270,
	300, 42,
	Color3.fromRGB(90, 90, 100)
)

--==================================================
-- LEAVE
--==================================================

local leave = createButton(
	"LEAVE GAME",
	10, 325,
	300, 35,
	Color3.fromRGB(190, 55, 65)
)

--==================================================
-- MINIMIZE / SHOW
--==================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

	minimized = not minimized

	if minimized then

		-- Hide everything except minimize button
		for _, object in ipairs(main:GetChildren()) do

			if object ~= corner
				and object ~= title
				and object ~= minimize then

				if object:IsA("GuiObject") then
					object.Visible = false
				end

			end
		end

		-- Make menu small
		main.Size = UDim2.new(0, 55, 0, 45)

		title.Visible = false

		-- Change to +
		minimize.Size = UDim2.new(0, 40, 0, 35)
		minimize.Position = UDim2.new(0, 7, 0, 5)
		minimize.Text = "+"

	else

		-- Restore menu
		main.Size = UDim2.new(0, 320, 0, 410)

		title.Visible = true

		-- Show everything
		for _, object in ipairs(main:GetChildren()) do

			if object:IsA("GuiObject") then
				object.Visible = true
			end

		end

		-- Restore minimize button
		minimize.Size = UDim2.new(0, 35, 0, 30)
		minimize.Position = UDim2.new(1, -45, 0, 8)
		minimize.Text = "−"
	end
end)

--==================================================
-- SAVED POSITION
--==================================================

local savedCFrame = nil

--==================================================
-- GRAPHICS SETTINGS
--==================================================

local savedEffects = {}

local savedLighting = {
	GlobalShadows = Lighting.GlobalShadows,
	Brightness = Lighting.Brightness,
	FogEnd = Lighting.FogEnd
}

--==================================================
-- INSTANT E SETTINGS
--==================================================

local instantEEnabled = false
local originalHoldDurations = {}

-- Save original HoldDuration
local function savePromptDuration(prompt)

	if originalHoldDurations[prompt] == nil then
		originalHoldDurations[prompt] = prompt.HoldDuration
	end

end

-- Make prompt instant
local function makePromptInstant(prompt)

	savePromptDuration(prompt)

	prompt.HoldDuration = 0
end

--==================================================
-- SAVE POSITION
--==================================================

save.MouseButton1Click:Connect(function()

	local character = player.Character

	if not character then
		status.Text = "Character not found"
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if root then

		savedCFrame = root.CFrame

		status.Text = "Position saved!"
		status.TextColor3 = Color3.fromRGB(80, 220, 120)

		save.Text = "SAVED!"

		task.wait(1)

		save.Text = "SAVE POSITION"
	end
end)

--==================================================
-- TELEPORT
--==================================================

teleport.MouseButton1Click:Connect(function()

	if not savedCFrame then

		status.Text = "No position saved!"
		status.TextColor3 = Color3.fromRGB(255, 100, 100)

		return
	end

	local character = player.Character

	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	if root then

		root.CFrame = savedCFrame

		status.Text = "Teleported!"
		status.TextColor3 = Color3.fromRGB(80, 170, 255)

		teleport.Text = "TELEPORTED!"

		task.wait(1)

		teleport.Text = "TELEPORT"
	end
end)

--==================================================
-- CLEAR POSITION
--==================================================

clear.MouseButton1Click:Connect(function()

	savedCFrame = nil

	status.Text = "Position cleared"
	status.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

--==================================================
-- SAVE EFFECT
--==================================================

local function saveEffect(object)

	if savedEffects[object] == nil then

		savedEffects[object] = {
			Enabled = object.Enabled
		}

	end
end

--==================================================
-- FPS BOOST
--==================================================

local function enableFPSBoost()

	Lighting.GlobalShadows = false

	for _, object in ipairs(Lighting:GetChildren()) do

		if object:IsA("BloomEffect")
			or object:IsA("BlurEffect")
			or object:IsA("ColorCorrectionEffect")
			or object:IsA("SunRaysEffect")
			or object:IsA("DepthOfFieldEffect") then

			saveEffect(object)

			object.Enabled = false
		end
	end

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("ParticleEmitter")
			or object:IsA("Trail")
			or object:IsA("Beam")
			or object:IsA("Smoke")
			or object:IsA("Fire")
			or object:IsA("Sparkles") then

			saveEffect(object)

			object.Enabled = false
		end
	end

	status.Text = "FPS Boost enabled"
	status.TextColor3 = Color3.fromRGB(80, 220, 120)

	fpsBoost.Text = "BOOST ON"
end

--==================================================
-- NORMAL GRAPHICS
--==================================================

local function restoreGraphics()

	Lighting.GlobalShadows = savedLighting.GlobalShadows
	Lighting.Brightness = savedLighting.Brightness
	Lighting.FogEnd = savedLighting.FogEnd

	for object, settings in pairs(savedEffects) do

		if object and object.Parent then

			object.Enabled = settings.Enabled

		end
	end

	status.Text = "Normal graphics"
	status.TextColor3 = Color3.fromRGB(80, 170, 255)

	fpsBoost.Text = "FPS BOOST"
end

--==================================================
-- REMOVE EFFECTS
--==================================================

removeEffects.MouseButton1Click:Connect(function()

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("ParticleEmitter")
			or object:IsA("Trail")
			or object:IsA("Beam")
			or object:IsA("Smoke")
			or object:IsA("Fire")
			or object:IsA("Sparkles") then

			object.Enabled = false
		end
	end

	for _, object in ipairs(Lighting:GetChildren()) do

		if object:IsA("BloomEffect")
			or object:IsA("BlurEffect")
			or object:IsA("ColorCorrectionEffect")
			or object:IsA("SunRaysEffect")
			or object:IsA("DepthOfFieldEffect") then

			object.Enabled = false
		end
	end

	status.Text = "Effects removed"
	status.TextColor3 = Color3.fromRGB(180, 140, 255)
end)

--==================================================
-- LOW GRAPHICS
--==================================================

lowGraphics.MouseButton1Click:Connect(function()

	enableFPSBoost()

	for _, object in ipairs(workspace:GetDescendants()) do

		if object:IsA("BasePart") then

			object.CastShadow = false
			object.Material = Enum.Material.SmoothPlastic

		end
	end

	status.Text = "Low graphics enabled"
	status.TextColor3 = Color3.fromRGB(255, 170, 80)

	lowGraphics.Text = "LOW ON"
end)

--==================================================
-- NORMAL
--==================================================

normalGraphics.MouseButton1Click:Connect(function()

	restoreGraphics()

	status.Text = "Normal graphics restored"
end)

--==================================================
-- INSTANT E TOGGLE
--==================================================

instantE.MouseButton1Click:Connect(function()

	instantEEnabled = not instantEEnabled

	if instantEEnabled then

		-- Make all existing prompts instant
		for _, object in ipairs(workspace:GetDescendants()) do

			if object:IsA("ProximityPrompt") then
				makePromptInstant(object)
			end

		end

		instantE.Text = "INSTANT E: ON"
		instantE.BackgroundColor3 = Color3.fromRGB(55, 170, 90)

		status.Text = "Instant E enabled"
		status.TextColor3 = Color3.fromRGB(80, 220, 120)

	else

		-- Restore original HoldDuration
		for prompt, duration in pairs(originalHoldDurations) do

			if prompt and prompt.Parent then
				prompt.HoldDuration = duration
			end

		end

		instantE.Text = "INSTANT E: OFF"
		instantE.BackgroundColor3 = Color3.fromRGB(90, 90, 100)

		status.Text = "Instant E disabled"
		status.TextColor3 = Color3.fromRGB(150, 150, 160)
	end
end)

--==================================================
-- NEW PROXIMITY PROMPTS
--==================================================

workspace.DescendantAdded:Connect(function(object)

	if object:IsA("ProximityPrompt") and instantEEnabled then

		makePromptInstant(object)

	end
end)

--==================================================
-- LEAVE
--==================================================

leave.MouseButton1Click:Connect(function()

	player:Kick("You left the game.")

end)
