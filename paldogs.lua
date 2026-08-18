local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
main.Size = UDim2.new(0, 320, 0, 475)
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

local save1 = createButton(
    "SAVE POSITION 1",
    10, 70,
    145, 42,
    Color3.fromRGB(55, 170, 90)
)

local teleport1 = createButton(
    "TELEPORT 1",
    165, 70,
    145, 42,
    Color3.fromRGB(55, 125, 230)
)

local save2 = createButton(
    "SAVE POSITION 2",
    10, 120,
    145, 42,
    Color3.fromRGB(55, 170, 90)
)

local teleport2 = createButton(
    "TELEPORT 2",
    165, 120,
    145, 42,
    Color3.fromRGB(55, 125, 230)
)

local clear = createButton(
    "CLEAR POSITIONS",
    10, 170,
    300, 35,
    Color3.fromRGB(190, 55, 65)
)

--==================================================
-- FPS BUTTONS
--==================================================

local fpsBoost = createButton(
    "FPS BOOST",
    10, 220,
    145, 42,
    Color3.fromRGB(40, 180, 100)
)

local normalGraphics = createButton(
    "NORMAL",
    165, 220,
    145, 42,
    Color3.fromRGB(55, 125, 230)
)

local removeEffects = createButton(
    "REMOVE EFFECTS",
    10, 270,
    145, 42,
    Color3.fromRGB(120, 80, 180)
)

local lowGraphics = createButton(
    "LOW GRAPHICS",
    165, 270,
    145, 42,
    Color3.fromRGB(190, 120, 55)
)

--==================================================
-- INSTANT E
--==================================================

local instantE = createButton(
    "INSTANT E: OFF",
    10, 320,
    300, 42,
    Color3.fromRGB(90, 90, 100)
)

--==================================================
-- FLOAT
--==================================================

local floatButton = createButton(
    "FLOAT: OFF",
    10, 375,
    300, 42,
    Color3.fromRGB(90, 90, 100)
)

--==================================================
-- LEAVE
--==================================================

local leave = createButton(
    "LEAVE GAME",
    10, 430,
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

        for _, object in ipairs(main:GetChildren()) do

            if object ~= corner
                and object ~= title
                and object ~= minimize then

                if object:IsA("GuiObject") then
                    object.Visible = false
                end

            end

        end

        main.Size = UDim2.new(0, 55, 0, 45)

        title.Visible = false

        minimize.Size = UDim2.new(0, 40, 0, 35)
        minimize.Position = UDim2.new(0, 7, 0, 5)
        minimize.Text = "+"

    else

        main.Size = UDim2.new(0, 320, 0, 475)

        title.Visible = true

        for _, object in ipairs(main:GetChildren()) do

            if object:IsA("GuiObject") then
                object.Visible = true
            end

        end

        minimize.Size = UDim2.new(0, 35, 0, 30)
        minimize.Position = UDim2.new(1, -45, 0, 8)
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
        status.Text = "Character not found!"
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then

        savedCFrame1 = root.CFrame

        status.Text = "Position 1 saved!"
        status.TextColor3 = Color3.fromRGB(80, 220, 120)

        save1.Text = "POSITION 1 SAVED!"

        task.wait(1)

        save1.Text = "SAVE POSITION 1"

    end

end)

--==================================================
-- TELEPORT 1
--==================================================

teleport1.MouseButton1Click:Connect(function()

    if not savedCFrame1 then

        status.Text = "Position 1 not saved!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)

        return

    end

    local character = player.Character

    if not character then

        status.Text = "Character not found!"
        return

    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not root or not humanoid then

        status.Text = "Character parts not found!"
        return

    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    character:PivotTo(savedCFrame1)

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    status.Text = "Teleported to Position 1!"
    status.TextColor3 = Color3.fromRGB(80, 170, 255)

    teleport1.Text = "TELEPORTED 1!"

    task.wait(1)

    teleport1.Text = "TELEPORT 1"

end)

--==================================================
-- SAVE POSITION 2
--==================================================

save2.MouseButton1Click:Connect(function()

    local character = player.Character

    if not character then
        status.Text = "Character not found!"
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if root then

        savedCFrame2 = root.CFrame

        status.Text = "Position 2 saved!"
        status.TextColor3 = Color3.fromRGB(80, 220, 120)

        save2.Text = "POSITION 2 SAVED!"

        task.wait(1)

        save2.Text = "SAVE POSITION 2"

    end

end)

--==================================================
-- TELEPORT 2
--==================================================

teleport2.MouseButton1Click:Connect(function()

    if not savedCFrame2 then

        status.Text = "Position 2 not saved!"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)

        return

    end

    local character = player.Character

    if not character then

        status.Text = "Character not found!"
        return

    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not root or not humanoid then

        status.Text = "Character parts not found!"
        return

    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    character:PivotTo(savedCFrame2)

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    status.Text = "Teleported to Position 2!"
    status.TextColor3 = Color3.fromRGB(80, 170, 255)

    teleport2.Text = "TELEPORTED 2!"

    task.wait(1)

    teleport2.Text = "TELEPORT 2"

end)

--==================================================
-- CLEAR BOTH POSITIONS
--==================================================

clear.MouseButton1Click:Connect(function()

    savedCFrame1 = nil
    savedCFrame2 = nil

    status.Text = "Both positions cleared"
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

            status.Text = "Character not found!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)

            return

        end

        -- Approximately 10 meters / 33 studs above current position
        floatHeight = root.Position.Y + 33

        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(55, 170, 90)

        status.Text = "Float enabled [T]"
        status.TextColor3 = Color3.fromRGB(80, 220, 120)

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

        floatButton.Text = "FLOAT: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(90, 90, 100)

        status.Text = "Float disabled"
        status.TextColor3 = Color3.fromRGB(150, 150, 160)

    end

end

--==================================================
-- FLOAT GUI BUTTON
--==================================================

floatButton.MouseButton1Click:Connect(function()

    toggleFloat()

end)

--==================================================
-- FLOAT T KEY
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.T then

        toggleFloat()

    end

end)

--==================================================
-- LEAVE
--==================================================

leave.MouseButton1Click:Connect(function()

    player:Kick("You left the game.")

end)
