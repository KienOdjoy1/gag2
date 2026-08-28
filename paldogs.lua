local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GardenUtilityGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 480)
main.Position = UDim2.new(0.5, -170, 0.08, 0)
main.BackgroundColor3 = Color3.fromRGB(32, 42, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(78, 110, 65)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.15
mainStroke.Parent = main

--==================================================
-- TOP DECORATION
--==================================================

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 5)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(92, 155, 72)
topBar.BorderSizePixel = 0
topBar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 0, 34)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🌱  GARDEN MENU"
title.TextColor3 = Color3.fromRGB(235, 255, 220)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -30, 0, 18)
subtitle.Position = UDim2.new(0, 15, 0, 39)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Grow • Harvest • Explore"
subtitle.TextColor3 = Color3.fromRGB(155, 185, 140)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 35, 0, 30)
minimize.Position = UDim2.new(1, -47, 0, 11)
minimize.BackgroundColor3 = Color3.fromRGB(53, 70, 49)
minimize.BorderSizePixel = 0
minimize.Text = "−"
minimize.TextColor3 = Color3.fromRGB(235, 255, 225)
minimize.TextSize = 21
minimize.Font = Enum.Font.GothamBold
minimize.Parent = main

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 9)
minimizeCorner.Parent = minimize

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 20)
status.Position = UDim2.new(0, 15, 0, 61)
status.BackgroundTransparency = 1
status.Text = "● Ready"
status.TextColor3 = Color3.fromRGB(155, 185, 140)
status.TextSize = 11
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
    button.TextColor3 = Color3.fromRGB(245, 255, 240)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = main

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88
    stroke.Thickness = 1
    stroke.Parent = button

    return button

end

--==================================================
-- BUTTON COLORS
--==================================================

local green = Color3.fromRGB(70, 145, 75)
local blue = Color3.fromRGB(62, 125, 185)
local red = Color3.fromRGB(170, 65, 65)
local purple = Color3.fromRGB(105, 82, 155)
local orange = Color3.fromRGB(175, 115, 55)
local offColor = Color3.fromRGB(63, 72, 60)

--==================================================
-- POSITION BUTTONS
--==================================================

local save1 = createButton(
    "🌱 SAVE POSITION 1",
    15, 91,
    150, 42,
    green
)

local teleport1 = createButton(
    "🚜 TELEPORT 1 [F]",
    175, 91,
    150, 42,
    blue
)

local save2 = createButton(
    "🌱 SAVE POSITION 2",
    15, 140,
    150, 42,
    green
)

local teleport2 = createButton(
    "🚜 TELEPORT 2 [G]",
    175, 140,
    150, 42,
    blue
)

local clear = createButton(
    "✕  CLEAR POSITIONS",
    15, 189,
    310, 34,
    red
)

--==================================================
-- GRAPHICS
--==================================================

local sectionGraphics = Instance.new("TextLabel")
sectionGraphics.Size = UDim2.new(1, -30, 0, 18)
sectionGraphics.Position = UDim2.new(0, 15, 0, 229)
sectionGraphics.BackgroundTransparency = 1
sectionGraphics.Text = "⚙  PERFORMANCE"
sectionGraphics.TextColor3 = Color3.fromRGB(175, 205, 155)
sectionGraphics.TextSize = 11
sectionGraphics.Font = Enum.Font.GothamBold
sectionGraphics.TextXAlignment = Enum.TextXAlignment.Left
sectionGraphics.Parent = main

local fpsBoost = createButton(
    "⚡ FPS BOOST",
    15, 251,
    150, 42,
    green
)

local normalGraphics = createButton(
    "☀ NORMAL",
    175, 251,
    150, 42,
    blue
)

local removeEffects = createButton(
    "✦ REMOVE EFFECTS",
    15, 300,
    150, 42,
    purple
)

local lowGraphics = createButton(
    "🍂 LOW GRAPHICS",
    175, 300,
    150, 42,
    orange
)

--==================================================
-- GAME FEATURES
--==================================================

local sectionFeatures = Instance.new("TextLabel")
sectionFeatures.Size = UDim2.new(1, -30, 0, 18)
sectionFeatures.Position = UDim2.new(0, 15, 0, 348)
sectionFeatures.BackgroundTransparency = 1
sectionFeatures.Text = "🌿  GAME FEATURES"
sectionFeatures.TextColor3 = Color3.fromRGB(175, 205, 155)
sectionFeatures.TextSize = 11
sectionFeatures.Font = Enum.Font.GothamBold
sectionFeatures.TextXAlignment = Enum.TextXAlignment.Left
sectionFeatures.Parent = main

local instantE = createButton(
    "⚡ INSTANT E: OFF",
    15, 370,
    150, 42,
    offColor
)

local floatButton = createButton(
    "☁ FLOAT: OFF",
    175, 370,
    150, 42,
    offColor
)

local antiSitButton = createButton(
    "🪑 ANTI SIT: OFF",
    15, 419,
    310, 42,
    offColor
)

--==================================================
-- MINIMIZE / SHOW
--==================================================

local minimized = false

minimize.MouseButton1Click:Connect(function()

    minimized = not minimized

    if minimized then

        for _, object in ipairs(main:GetChildren()) do

            if object ~= mainCorner
                and object ~= mainStroke
                and object ~= topBar
                and object ~= title
                and object ~= minimize then

                if object:IsA("GuiObject") then
                    object.Visible = false
                end

            end

        end

        main.Size = UDim2.new(0, 58, 0, 48)

        title.Visible = false
        minimize.Size = UDim2.new(0, 42, 0, 36)
        minimize.Position = UDim2.new(0, 8, 0, 6)
        minimize.Text = "+"

    else

        main.Size = UDim2.new(0, 340, 0, 480)

        title.Visible = true

        for _, object in ipairs(main:GetChildren()) do

            if object:IsA("GuiObject") then
                object.Visible = true
            end

        end

        minimize.Size = UDim2.new(0, 35, 0, 30)
        minimize.Position = UDim2.new(1, -47, 0, 11)
        minimize.Text = "−"

    end

end)

--==================================================
-- SAVED POSITIONS
--==================================================

local savedCFrame1 = nil
local savedCFrame2 = nil

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

local function savePromptDuration(prompt)

    if originalHoldDurations[prompt] == nil then
        originalHoldDurations[prompt] = prompt.HoldDuration
    end

end

local function makePromptInstant(prompt)

    savePromptDuration(prompt)
    prompt.HoldDuration = 0

end

--==================================================
-- SAVE POSITION 1
--==================================================

save1.MouseButton1Click:Connect(function()

    local character = player.Character

    if not character then
        status.Text = "● Character not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then

        savedCFrame1 = root.CFrame

        status.Text = "● Position 1 saved!"
        status.TextColor3 = Color3.fromRGB(120, 220, 110)

        save1.Text = "✓ POSITION 1 SAVED"

        task.delay(1, function()
            if save1 then
                save1.Text = "🌱 SAVE POSITION 1"
            end
        end)

    end

end)

--==================================================
-- TELEPORT 1
--==================================================

local function teleportToPosition1()

    if not savedCFrame1 then

        status.Text = "● Position 1 not saved!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    local character = player.Character

    if not character then

        status.Text = "● Character not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not root or not humanoid then

        status.Text = "● Character parts not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    character:PivotTo(savedCFrame1)

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    status.Text = "● Teleported to Position 1!"
    status.TextColor3 = Color3.fromRGB(105, 185, 255)

    teleport1.Text = "✓ TELEPORTED 1"

    task.delay(1, function()

        if teleport1 then
            teleport1.Text = "🚜 TELEPORT 1 [F]"
        end

    end)

end

teleport1.MouseButton1Click:Connect(teleportToPosition1)

--==================================================
-- SAVE POSITION 2
--==================================================

save2.MouseButton1Click:Connect(function()

    local character = player.Character

    if not character then

        status.Text = "● Character not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then

        savedCFrame2 = root.CFrame

        status.Text = "● Position 2 saved!"
        status.TextColor3 = Color3.fromRGB(120, 220, 110)

        save2.Text = "✓ POSITION 2 SAVED"

        task.delay(1, function()

            if save2 then
                save2.Text = "🌱 SAVE POSITION 2"
            end

        end)

    end

end)

--==================================================
-- TELEPORT 2
--==================================================

local function teleportToPosition2()

    if not savedCFrame2 then

        status.Text = "● Position 2 not saved!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    local character = player.Character

    if not character then

        status.Text = "● Character not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not root or not humanoid then

        status.Text = "● Character parts not found!"
        status.TextColor3 = Color3.fromRGB(255, 110, 110)

        return

    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    character:PivotTo(savedCFrame2)

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    status.Text = "● Teleported to Position 2!"
    status.TextColor3 = Color3.fromRGB(105, 185, 255)

    teleport2.Text = "✓ TELEPORTED 2"

    task.delay(1, function()

        if teleport2 then
            teleport2.Text = "🚜 TELEPORT 2 [G]"
        end

    end)

end

teleport2.MouseButton1Click:Connect(teleportToPosition2)

--==================================================
-- CLEAR POSITIONS
--==================================================

clear.MouseButton1Click:Connect(function()

    savedCFrame1 = nil
    savedCFrame2 = nil

    status.Text = "● Both positions cleared"
    status.TextColor3 = Color3.fromRGB(255, 110, 110)

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

    status.Text = "● FPS Boost enabled"
    status.TextColor3 = Color3.fromRGB(120, 220, 110)

    fpsBoost.Text = "✓ BOOST ON"

end

fpsBoost.MouseButton1Click:Connect(enableFPSBoost)

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

    status.Text = "● Normal graphics restored"
    status.TextColor3 = Color3.fromRGB(105, 185, 255)

    fpsBoost.Text = "⚡ FPS BOOST"
    lowGraphics.Text = "🍂 LOW GRAPHICS"

end

normalGraphics.MouseButton1Click:Connect(restoreGraphics)

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

    status.Text = "● Effects removed"
    status.TextColor3 = Color3.fromRGB(185, 150, 245)

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

    status.Text = "● Low graphics enabled"
    status.TextColor3 = Color3.fromRGB(235, 180, 90)

    lowGraphics.Text = "✓ LOW ON"

end)

--==================================================
-- INSTANT E TOGGLE
--==================================================

instantE.MouseButton1Click:Connect(function()

    instantEEnabled = not instantEEnabled

    if instantEEnabled then

        for _, object in ipairs(workspace:GetDescendants()) do

            if object:IsA("ProximityPrompt") then
                makePromptInstant(object)
            end

        end

        instantE.Text = "⚡ INSTANT E: ON"
        instantE.BackgroundColor3 = green

        status.Text = "● Instant E enabled"
        status.TextColor3 = Color3.fromRGB(120, 220, 110)

    else

        for prompt, duration in pairs(originalHoldDurations) do

            if prompt and prompt.Parent then
                prompt.HoldDuration = duration
            end

        end

        instantE.Text = "⚡ INSTANT E: OFF"
        instantE.BackgroundColor3 = offColor

        status.Text = "● Instant E disabled"
        status.TextColor3 = Color3.fromRGB(155, 185, 140)

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
-- FLOAT
--==================================================

local floatEnabled = false
local floatConnection = nil
local floatHeight = nil

local function toggleFloat()

    floatEnabled = not floatEnabled

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if floatEnabled then

        if not root then

            floatEnabled = false

            status.Text = "● Character not found!"
            status.TextColor3 = Color3.fromRGB(255, 110, 110)

            return

        end

        floatHeight = root.Position.Y + 0.5

        floatButton.Text = "☁ FLOAT: ON"
        floatButton.BackgroundColor3 = green

        status.Text = "● Float enabled"
        status.TextColor3 = Color3.fromRGB(120, 220, 110)

        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end

        floatConnection = RunService.Heartbeat:Connect(function()

            if not floatEnabled then
                return
            end

            local currentCharacter = player.Character

            if not currentCharacter then
                return
            end

            local currentRoot =
                currentCharacter:FindFirstChild("HumanoidRootPart")

            if not currentRoot then
                return
            end

            local position = currentRoot.Position

            currentRoot.AssemblyLinearVelocity = Vector3.new(
                currentRoot.AssemblyLinearVelocity.X,
                0,
                currentRoot.AssemblyLinearVelocity.Z
            )

            currentRoot.CFrame =
                CFrame.new(
                    position.X,
                    floatHeight,
                    position.Z
                )
                * (currentRoot.CFrame - currentRoot.CFrame.Position)

        end)

    else

        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end

        floatHeight = nil

        floatButton.Text = "☁ FLOAT: OFF"
        floatButton.BackgroundColor3 = offColor

        status.Text = "● Float disabled"
        status.TextColor3 = Color3.fromRGB(155, 185, 140)

    end

end

--==================================================
-- FLOAT GUI BUTTON
--==================================================

floatButton.MouseButton1Click:Connect(function()
    toggleFloat()
end)

--==================================================
-- ANTI SIT
--==================================================

local antiSitEnabled = false
local antiSitConnection = nil
local antiSitStateConnection = nil

local function disconnectAntiSit()

    if antiSitConnection then
        antiSitConnection:Disconnect()
        antiSitConnection = nil
    end

    if antiSitStateConnection then
        antiSitStateConnection:Disconnect()
        antiSitStateConnection = nil
    end

end

local function setupAntiSit(character)

    disconnectAntiSit()

    if not antiSitEnabled then
        return
    end

    local humanoid = character:WaitForChild("Humanoid", 5)

    if not humanoid then
        return
    end

    -- Prevent sitting immediately when the seated state changes
    antiSitStateConnection = humanoid.StateChanged:Connect(function(_, newState)

        if not antiSitEnabled then
            return
        end

        if newState == Enum.HumanoidStateType.Seated then

            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

        end

    end)

    -- Extra check for seats that repeatedly force Sit
    antiSitConnection = RunService.Heartbeat:Connect(function()

        if not antiSitEnabled then
            return
        end

        if not humanoid.Parent then
            return
        end

        if humanoid.Sit
            or humanoid:GetState() == Enum.HumanoidStateType.Seated
            or humanoid.SeatPart ~= nil then

            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

        end

    end)

end

antiSitButton.MouseButton1Click:Connect(function()

    antiSitEnabled = not antiSitEnabled

    if antiSitEnabled then

        antiSitButton.Text = "🪑 ANTI SIT: ON"
        antiSitButton.BackgroundColor3 = green

        status.Text = "● Anti Sit enabled"
        status.TextColor3 = Color3.fromRGB(120, 220, 110)

        if player.Character then
            setupAntiSit(player.Character)
        end

    else

        disconnectAntiSit()

        antiSitButton.Text = "🪑 ANTI SIT: OFF"
        antiSitButton.BackgroundColor3 = offColor

        status.Text = "● Anti Sit disabled"
        status.TextColor3 = Color3.fromRGB(155, 185, 140)

    end

end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(function(character)

    if antiSitEnabled then

        task.wait(0.5)

        if character and character.Parent then
            setupAntiSit(character)
        end

    end

end)

--==================================================
-- TELEPORT KEYBINDS
-- F = TELEPORT 1
-- G = TELEPORT 2
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F then

        teleportToPosition1()

    elseif input.KeyCode == Enum.KeyCode.G then

        teleportToPosition2()

    end

end)
