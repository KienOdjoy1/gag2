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
title.Text = "GAME MENU - SAE"
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
-- BUTTONS
--==================================================

local godMode = createButton(
    "GOD MODE: OFF",
    10, 70,
    145, 42,
    Color3.fromRGB(90, 90, 100)
)

local transparencyButton = createButton(
    "TRANSPARENCY: OFF",
    165, 70,
    145, 42,
    Color3.fromRGB(90, 90, 100)
)

local transparencyLevel = createButton(
    "TRANSPARENCY 50%",
    10, 120,
    300, 42,
    Color3.fromRGB(100, 80, 160)
)

local noCollisionButton = createButton(
    "NO COLLIDE: OFF",
    10, 170,
    300, 42,
    Color3.fromRGB(90, 90, 100)
)

local lowGraphicsButton = createButton(
    "LOW GRAPHICS: OFF",
    10, 220,
    145, 42,
    Color3.fromRGB(90, 90, 100)
)

local removeEffectsButton = createButton(
    "EFFECTS: ON",
    165, 220,
    145, 42,
    Color3.fromRGB(90, 90, 100)
)

local hidePartsButton = createButton(
    "HIDE PARTS: OFF",
    10, 270,
    300, 42,
    Color3.fromRGB(90, 90, 100)
)

local disableRunWalkButton = createButton(
    "RUN/WALK: ON",
    10, 320,
    300, 42,
    Color3.fromRGB(90, 90, 100)
)

--==================================================
-- STATES
--==================================================

local godModeEnabled = false
local godConnection = nil

local transparencyEnabled = false
local transparencyValue = 0.5
local originalTransparency = {}

local noCollisionEnabled = false

local lowGraphicsEnabled = false
local effectsRemoved = false
local partsHidden = false

local hiddenParts = {}
local hiddenDecals = {}

local runWalkDisabled = false
local originalWalkSpeed = 16
local runWalkConnection = nil

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

            status.Text = "Character not found!"
            status.TextColor3 =
                Color3.fromRGB(255, 100, 100)

            return
        end

        godMode.Text = "GOD MODE: ON"
        godMode.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text = "God Mode enabled"
        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        disableGodMode()

        godMode.Text = "GOD MODE: OFF"
        godMode.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text = "God Mode disabled"
        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

end)

--==================================================
-- TRANSPARENCY
--==================================================

local function saveTransparency(object)

    if originalTransparency[object] == nil then
        originalTransparency[object] =
            object.Transparency
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

    transparencyEnabled =
        not transparencyEnabled

    if transparencyEnabled then

        setAvatarTransparency(
            transparencyValue
        )

        transparencyButton.Text =
            "TRANSPARENCY: ON"

        transparencyButton.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text =
            "Avatar transparency enabled"

        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        restoreAvatarTransparency()

        transparencyButton.Text =
            "TRANSPARENCY: OFF"

        transparencyButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "Avatar transparency disabled"

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
        setAvatarTransparency(
            transparencyValue
        )
    end

    status.Text =
        "Transparency: "
        .. math.floor(
            transparencyValue * 100
        )
        .. "%"

end)

--==================================================
-- NO COLLISION
--==================================================

local function setNoCollision(enabled)

    local character = getCharacter()

    if not character then
        return
    end

    for _, object in ipairs(
        character:GetDescendants()
    ) do

        if object:IsA("BasePart") then

            object.CanCollide = not enabled
            object.CanTouch = not enabled

        end

    end

end

noCollisionButton.MouseButton1Click:Connect(function()

    noCollisionEnabled =
        not noCollisionEnabled

    setNoCollision(
        noCollisionEnabled
    )

    if noCollisionEnabled then

        noCollisionButton.Text =
            "NO COLLIDE: ON"

        noCollisionButton.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text =
            "No Collision enabled"

        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        noCollisionButton.Text =
            "NO COLLIDE: OFF"

        noCollisionButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "No Collision disabled"

        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

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
            workspace:FindFirstChildOfClass(
                "Terrain"
            )

        if terrain then

            pcall(function()
                terrain.Decoration = false
            end)

        end

        for _, object in ipairs(
            game:GetDescendants()
        ) do

            if object:IsA("ParticleEmitter")
                or object:IsA("Trail")
                or object:IsA("Beam")
                or object:IsA("Fire")
                or object:IsA("Smoke")
                or object:IsA("Sparkles") then

                object.Enabled = false

            end

        end

        lowGraphicsButton.Text =
            "LOW GRAPHICS: ON"

        lowGraphicsButton.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text =
            "Low graphics enabled"

        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        lowGraphicsButton.Text =
            "LOW GRAPHICS: OFF"

        lowGraphicsButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "Low graphics disabled"

        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

end

lowGraphicsButton.MouseButton1Click:Connect(function()

    setLowGraphics(
        not lowGraphicsEnabled
    )

end)

--==================================================
-- REMOVE EFFECTS
--==================================================

local function setEffectsRemoved(enabled)

    effectsRemoved = enabled

    for _, object in ipairs(
        game:GetDescendants()
    ) do

        if object:IsA("ParticleEmitter")
            or object:IsA("Trail")
            or object:IsA("Beam")
            or object:IsA("Fire")
            or object:IsA("Smoke")
            or object:IsA("Sparkles") then

            object.Enabled = not enabled

        elseif object:IsA("PostEffect") then

            object.Enabled = not enabled

        end

    end

    if enabled then

        removeEffectsButton.Text =
            "EFFECTS: OFF"

        removeEffectsButton.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text =
            "Visual effects removed"

        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        removeEffectsButton.Text =
            "EFFECTS: ON"

        removeEffectsButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "Visual effects restored"

        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

end

removeEffectsButton.MouseButton1Click:Connect(function()

    setEffectsRemoved(
        not effectsRemoved
    )

end)

--==================================================
-- HIDE ALL PARTS
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

                    object.LocalTransparencyModifier = 1

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
            "Map parts hidden"

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
                object.Transparency = value
            end

        end

        table.clear(hiddenParts)
        table.clear(hiddenDecals)

        hidePartsButton.Text =
            "HIDE PARTS: OFF"

        hidePartsButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "Map parts restored"

        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

end

hidePartsButton.MouseButton1Click:Connect(function()

    hideAllParts(
        not partsHidden
    )

end)

--==================================================
-- DISABLE RUN / WALK
--==================================================

local function stopRunWalkConnection()

    if runWalkConnection then

        runWalkConnection:Disconnect()
        runWalkConnection = nil

    end

end

local function setRunWalkDisabled(disabled)

    runWalkDisabled = disabled

    local humanoid = getHumanoid()

    if not humanoid then
        return
    end

    if disabled then

        if humanoid.WalkSpeed > 0 then
            originalWalkSpeed =
                humanoid.WalkSpeed
        end

        humanoid.WalkSpeed = 0

        stopRunWalkConnection()

        runWalkConnection =
            RunService.Heartbeat:Connect(
                function()

                    if not runWalkDisabled then
                        return
                    end

                    local currentHumanoid =
                        getHumanoid()

                    if currentHumanoid then

                        if currentHumanoid.WalkSpeed ~= 0 then
                            currentHumanoid.WalkSpeed = 0
                        end

                        currentHumanoid:Move(
                            Vector3.zero,
                            false
                        )

                    end

                end
            )

        disableRunWalkButton.Text =
            "RUN/WALK: OFF"

        disableRunWalkButton.BackgroundColor3 =
            Color3.fromRGB(55, 170, 90)

        status.Text =
            "Run/Walk disabled"

        status.TextColor3 =
            Color3.fromRGB(80, 220, 120)

    else

        stopRunWalkConnection()

        humanoid.WalkSpeed =
            originalWalkSpeed > 0
            and originalWalkSpeed
            or 16

        disableRunWalkButton.Text =
            "RUN/WALK: ON"

        disableRunWalkButton.BackgroundColor3 =
            Color3.fromRGB(90, 90, 100)

        status.Text =
            "Run/Walk enabled"

        status.TextColor3 =
            Color3.fromRGB(150, 150, 160)

    end

end

disableRunWalkButton.MouseButton1Click:Connect(
    function()

        setRunWalkDisabled(
            not runWalkDisabled
        )

    end
)

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
                and object ~= title
                and object ~= minimize then

                if object:IsA("GuiObject") then
                    object.Visible = false
                end

            end

        end

        main.Size =
            UDim2.new(0, 55, 0, 45)

        title.Visible = false

        minimize.Size =
            UDim2.new(0, 40, 0, 35)

        minimize.Position =
            UDim2.new(0, 7, 0, 5)

        minimize.Text = "+"

    else

        main.Size =
            UDim2.new(0, 320, 0, 475)

        title.Visible = true

        for _, object in ipairs(
            main:GetChildren()
        ) do

            if object:IsA("GuiObject") then
                object.Visible = true
            end

        end

        minimize.Size =
            UDim2.new(0, 35, 0, 30)

        minimize.Position =
            UDim2.new(1, -45, 0, 8)

        minimize.Text = "−"

    end

end)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(
    function(character)

        task.wait(1)

        if godModeEnabled then
            enableGodMode()
        end

        if transparencyEnabled then
            setAvatarTransparency(
                transparencyValue
            )
        end

        if noCollisionEnabled then
            setNoCollision(true)
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

        if runWalkDisabled then

            task.wait(0.2)

            originalWalkSpeed = 16

            setRunWalkDisabled(true)

        end

    end
)

--==================================================
-- CLEANUP
--==================================================

script.Destroying:Connect(function()

    if godConnection then
        godConnection:Disconnect()
    end

    if runWalkConnection then
        runWalkConnection:Disconnect()
    end

end)
