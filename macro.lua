local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--==================================================
-- GARDEN UTILITY GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GardenUtilityGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--==================================================
-- GARDEN COLORS
--==================================================

local colors = {
    soil = Color3.fromRGB(76, 50, 32),
    soilDark = Color3.fromRGB(55, 38, 27),

    grass = Color3.fromRGB(49, 82, 43),
    grassDark = Color3.fromRGB(35, 59, 33),

    leaf = Color3.fromRGB(76, 145, 70),
    leafLight = Color3.fromRGB(105, 175, 82),

    panel = Color3.fromRGB(30, 48, 28),
    panelLight = Color3.fromRGB(40, 62, 35),

    gold = Color3.fromRGB(221, 174, 74),
    flower = Color3.fromRGB(205, 105, 130),

    blue = Color3.fromRGB(76, 139, 183),
    purple = Color3.fromRGB(120, 91, 165),
    orange = Color3.fromRGB(183, 125, 58),
    red = Color3.fromRGB(173, 71, 65),

    text = Color3.fromRGB(242, 255, 225),
    subtext = Color3.fromRGB(166, 194, 150),

    off = Color3.fromRGB(57, 72, 52)
}

--==================================================
-- FEATURE STATES
--==================================================

local instantEEnabled = false
local floatEnabled = false
local antiSitEnabled = false

local fpsBoostEnabled = false
local lowGraphicsEnabled = false
local effectsRemoved = false

--==================================================
-- TELEPORT POSITIONS
--==================================================

local savedCFrame1 = nil
local savedCFrame2 = nil

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")
main.Name = "GardenMenu"

main.Size = UDim2.new(0, 340, 0, 330)
main.Position = UDim2.new(0.5, -170, 0.08, 0)

main.BackgroundColor3 = colors.panel
main.BorderSizePixel = 0

main.Active = true
main.Draggable = false

main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = colors.leaf
mainStroke.Thickness = 2
mainStroke.Transparency = 0.15
mainStroke.Parent = main

--==================================================
-- CUSTOM DRAG SYSTEM
--==================================================

local dragging = false
local dragStart = nil
local startPosition = nil
local dragMoved = false

local function beginDrag(input)
    dragging = true
    dragMoved = false

    dragStart = input.Position
    startPosition = main.Position

    input.Changed:Connect(function()

        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end

    end)
end

local function updateDrag(input)

    if not dragging then
        return
    end

    local delta = input.Position - dragStart

    if math.abs(delta.X) > 5
        or math.abs(delta.Y) > 5 then

        dragMoved = true

    end

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

end

--==================================================
-- MAIN FRAME DRAG
--==================================================

main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        beginDrag(input)
    end

end)

UserInputService.InputChanged:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end

end)

--==================================================
-- HEADER
--==================================================

local woodHeader = Instance.new("Frame")

woodHeader.Size = UDim2.new(1, 0, 0, 67)
woodHeader.Position = UDim2.new(0, 0, 0, 0)

woodHeader.BackgroundColor3 = colors.soil
woodHeader.BorderSizePixel = 0

woodHeader.Parent = main

local woodCorner = Instance.new("UICorner")
woodCorner.CornerRadius = UDim.new(0, 18)
woodCorner.Parent = woodHeader

local grassStrip = Instance.new("Frame")

grassStrip.Size = UDim2.new(1, 0, 0, 5)
grassStrip.Position = UDim2.new(0, 0, 1, -5)

grassStrip.BackgroundColor3 = colors.leafLight
grassStrip.BorderSizePixel = 0

grassStrip.Parent = woodHeader

--==================================================
-- HEADER DRAG
--==================================================

woodHeader.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        beginDrag(input)
    end

end)

--==================================================
-- HEADER DECORATIONS
--==================================================

local leafLeft = Instance.new("TextLabel")

leafLeft.Size = UDim2.new(0, 40, 0, 35)
leafLeft.Position = UDim2.new(0, 7, 0, 12)

leafLeft.BackgroundTransparency = 1
leafLeft.Text = "🌿"
leafLeft.TextSize = 25

leafLeft.Parent = woodHeader

local leafRight = Instance.new("TextLabel")

leafRight.Size = UDim2.new(0, 40, 0, 35)
leafRight.Position = UDim2.new(1, -48, 0, 12)

leafRight.BackgroundTransparency = 1
leafRight.Text = "🌱"
leafRight.TextSize = 24

leafRight.Parent = woodHeader

--==================================================
-- TITLE
--==================================================

local title = Instance.new("TextLabel")

title.Size = UDim2.new(1, -105, 0, 28)
title.Position = UDim2.new(0, 52, 0, 9)

title.BackgroundTransparency = 1
title.Text = "🌻 KYOSH"

title.TextColor3 = colors.text
title.TextSize = 19
title.Font = Enum.Font.GothamBold

title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = woodHeader

local subtitle = Instance.new("TextLabel")

subtitle.Size = UDim2.new(1, -105, 0, 17)
subtitle.Position = UDim2.new(0, 53, 0, 36)

subtitle.BackgroundTransparency = 1
subtitle.Text = "Plant • Grow • Harvest"

subtitle.TextColor3 = Color3.fromRGB(207, 177, 120)

subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamMedium

subtitle.TextXAlignment = Enum.TextXAlignment.Left

subtitle.Parent = woodHeader

--==================================================
-- MINIMIZE BUTTON
--==================================================

local minimize = Instance.new("TextButton")

minimize.Size = UDim2.new(0, 35, 0, 30)
minimize.Position = UDim2.new(1, -47, 0, 10)

minimize.BackgroundColor3 = colors.soilDark
minimize.BorderSizePixel = 0

minimize.Text = "−"
minimize.TextColor3 = colors.text
minimize.TextSize = 21
minimize.Font = Enum.Font.GothamBold

minimize.AutoButtonColor = false

minimize.Parent = main

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 9)
minimizeCorner.Parent = minimize

local minimizeStroke = Instance.new("UIStroke")
minimizeStroke.Color = colors.leafLight
minimizeStroke.Thickness = 1
minimizeStroke.Transparency = 0.25
minimizeStroke.Parent = minimize

--==================================================
-- MINIMIZE BUTTON DRAG
--==================================================

local minimizeDragging = false
local minimizeDragStart = nil
local minimizeStartPosition = nil
local minimizeMoved = false

minimize.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        minimizeDragging = true
        minimizeMoved = false

        minimizeDragStart = input.Position
        minimizeStartPosition = main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                minimizeDragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if minimizeDragging
        and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta =
            input.Position - minimizeDragStart

        if math.abs(delta.X) > 5
            or math.abs(delta.Y) > 5 then

            minimizeMoved = true

        end

        main.Position = UDim2.new(
            minimizeStartPosition.X.Scale,
            minimizeStartPosition.X.Offset + delta.X,

            minimizeStartPosition.Y.Scale,
            minimizeStartPosition.Y.Offset + delta.Y
        )

    end

end)

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")

status.Size = UDim2.new(1, -30, 0, 20)
status.Position = UDim2.new(0, 15, 1, -25)

status.BackgroundTransparency = 1

status.Text = "● Garden ready"
status.TextColor3 = colors.subtext
status.TextSize = 10
status.Font = Enum.Font.Gotham

status.TextXAlignment = Enum.TextXAlignment.Left

status.Parent = main

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")

content.Size = UDim2.new(1, -30, 1, -105)
content.Position = UDim2.new(0, 15, 0, 78)

content.BackgroundTransparency = 1

content.Parent = main

--==================================================
-- BUTTON FUNCTION
--==================================================

local function createButton(parent, text, x, y, width, height, color)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(0, width, 0, height)
    button.Position = UDim2.new(0, x, 0, y)

    button.BackgroundColor3 = color
    button.BorderSizePixel = 0

    button.Text = text
    button.TextColor3 = colors.text

    button.TextSize = 11
    button.Font = Enum.Font.GothamBold

    button.AutoButtonColor = false

    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88
    stroke.Thickness = 1
    stroke.Parent = button

    button:SetAttribute("NormalColorR", color.R)
    button:SetAttribute("NormalColorG", color.G)
    button:SetAttribute("NormalColorB", color.B)

    button.MouseEnter:Connect(function()

        local currentColor = button.BackgroundColor3

        button.BackgroundColor3 =
            currentColor:Lerp(
                Color3.new(1, 1, 1),
                0.08
            )

    end)

    button.MouseLeave:Connect(function()

        local r = button:GetAttribute("NormalColorR")
        local g = button:GetAttribute("NormalColorG")
        local b = button:GetAttribute("NormalColorB")

        if r and g and b then

            button.BackgroundColor3 =
                Color3.new(r, g, b)

        end

    end)

    return button
end

--==================================================
-- SET BUTTON COLOR
--==================================================

local function setButtonColor(button, color)

    button.BackgroundColor3 = color

    button:SetAttribute("NormalColorR", color.R)
    button:SetAttribute("NormalColorG", color.G)
    button:SetAttribute("NormalColorB", color.B)

end

--==================================================
-- UPDATE TOGGLE BUTTON
--==================================================

local function updateToggleButton(
    button,
    onText,
    offText,
    enabled
)

    if enabled then

        button.Text = onText

        setButtonColor(
            button,
            colors.leaf
        )

    else

        button.Text = offText

        setButtonColor(
            button,
            colors.off
        )

    end

end

--==================================================
-- RESIZE
--==================================================

local minimized = false

local function resizeFrame(height)

    if minimized then
        return
    end

    TweenService:Create(
        main,

        TweenInfo.new(
            0.22,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),

        {
            Size = UDim2.new(
                0,
                340,
                0,
                height
            )
        }

    ):Play()

end

--==================================================
-- PAGE CONTROL
--==================================================

local currentPage = "MENU"

local showMainMenu
local showGameFeatures
local showPerformance
local showTeleport

--==================================================
-- CLEAR PAGE
--==================================================

local function clearPage()

    for _, object in ipairs(
        content:GetChildren()
    ) do

        object:Destroy()

    end

end

--==================================================
-- BACK BUTTON
--==================================================

local function createBackButton()

    local back =
        createButton(
            content,
            "‹  BACK TO GARDEN",
            0,
            0,
            310,
            34,
            colors.grassDark
        )

    back.MouseButton1Click:Connect(
        function()

            showMainMenu()

        end
    )

    return back
end

--==================================================
-- INSTANT E
--==================================================

local originalHoldDurations = {}

local function savePromptDuration(prompt)

    if originalHoldDurations[prompt] == nil then

        originalHoldDurations[prompt] =
            prompt.HoldDuration

    end

end

local function makePromptInstant(prompt)

    savePromptDuration(prompt)

    prompt.HoldDuration = 0

end

local function enableInstantE()

    instantEEnabled = true

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do

        if object:IsA("ProximityPrompt") then

            makePromptInstant(object)

        end

    end

    status.Text =
        "● Instant E enabled"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            220,
            110
        )

end

local function disableInstantE()

    instantEEnabled = false

    for prompt, duration in pairs(
        originalHoldDurations
    ) do

        if prompt
            and prompt.Parent then

            prompt.HoldDuration =
                duration

        end

    end

    status.Text =
        "● Instant E disabled"

    status.TextColor3 =
        colors.subtext

end

--==================================================
-- FLOAT
--==================================================

local floatConnection = nil
local floatHeight = nil

local function toggleFloat()

    floatEnabled =
        not floatEnabled

    local character =
        player.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    if floatEnabled then

        if not root then

            floatEnabled = false

            status.Text =
                "● Character not found"

            status.TextColor3 =
                Color3.fromRGB(
                    255,
                    110,
                    110
                )

            return

        end

        floatHeight =
            root.Position.Y + 0.5

        if floatConnection then

            floatConnection:Disconnect()
            floatConnection = nil

        end

        floatConnection =
            RunService.Heartbeat:Connect(
                function()

                    if not floatEnabled then
                        return
                    end

                    local currentCharacter =
                        player.Character

                    if not currentCharacter then
                        return
                    end

                    local currentRoot =
                        currentCharacter:
                        FindFirstChild(
                            "HumanoidRootPart"
                        )

                    if not currentRoot then
                        return
                    end

                    local position =
                        currentRoot.Position

                    currentRoot.AssemblyLinearVelocity =
                        Vector3.new(
                            currentRoot.AssemblyLinearVelocity.X,
                            0,
                            currentRoot.AssemblyLinearVelocity.Z
                        )

                    currentRoot.CFrame =
                        CFrame.new(
                            position.X,
                            floatHeight,
                            position.Z
                        ) *
                        (
                            currentRoot.CFrame -
                            currentRoot.CFrame.Position
                        )

                end
            )

        status.Text =
            "● Garden float enabled"

        status.TextColor3 =
            Color3.fromRGB(
                120,
                220,
                110
            )

    else

        if floatConnection then

            floatConnection:Disconnect()
            floatConnection = nil

        end

        floatHeight = nil

        status.Text =
            "● Garden float disabled"

        status.TextColor3 =
            colors.subtext

    end

end

--==================================================
-- ANTI SIT
--==================================================

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

    local humanoid =
        character:WaitForChild(
            "Humanoid",
            10
        )

    if not humanoid then
        return
    end

    antiSitConnection =
        RunService.Heartbeat:Connect(
            function()

                if not antiSitEnabled then
                    return
                end

                if not humanoid
                    or not humanoid.Parent then

                    return

                end

                if humanoid.Sit then

                    humanoid.Sit = false

                end

                if humanoid:GetState()
                    == Enum.HumanoidStateType.Seated then

                    humanoid.Sit = false

                    humanoid:ChangeState(
                        Enum.HumanoidStateType.GettingUp
                    )

                end

            end
        )

    antiSitStateConnection =
        humanoid.StateChanged:Connect(
            function(_, newState)

                if not antiSitEnabled then
                    return
                end

                if newState ==
                    Enum.HumanoidStateType.Seated then

                    humanoid.Sit = false

                    task.defer(
                        function()

                            if humanoid
                                and humanoid.Parent
                                and antiSitEnabled then

                                humanoid:ChangeState(
                                    Enum.HumanoidStateType.GettingUp
                                )

                            end

                        end
                    )

                end

            end
        )

end

--==================================================
-- PERFORMANCE STORAGE
--==================================================

local savedEffects = {}

local savedLighting = {
    GlobalShadows =
        Lighting.GlobalShadows,

    Brightness =
        Lighting.Brightness,

    FogEnd =
        Lighting.FogEnd
}

local lowGraphicsOriginals = {}

--==================================================
-- SAVE EFFECT
--==================================================

local function saveEffect(object)

    if savedEffects[object] == nil then

        if object:IsA("ParticleEmitter")
            or object:IsA("Trail")
            or object:IsA("Beam")
            or object:IsA("Smoke")
            or object:IsA("Fire")
            or object:IsA("Sparkles")
            or object:IsA("BloomEffect")
            or object:IsA("BlurEffect")
            or object:IsA("ColorCorrectionEffect")
            or object:IsA("SunRaysEffect")
            or object:IsA("DepthOfFieldEffect") then

            savedEffects[object] = {
                Enabled = object.Enabled
            }

        end

    end

end

--==================================================
-- FPS BOOST
--==================================================

local function enableFPSBoost()

    fpsBoostEnabled = true

    Lighting.GlobalShadows = false

    for _, object in ipairs(
        Lighting:GetChildren()
    ) do

        if object:IsA("BloomEffect")
            or object:IsA("BlurEffect")
            or object:IsA("ColorCorrectionEffect")
            or object:IsA("SunRaysEffect")
            or object:IsA("DepthOfFieldEffect") then

            saveEffect(object)

            object.Enabled = false

        end

    end

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do

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

    status.Text =
        "● Garden FPS boost enabled"

    status.TextColor3 =
        Color3.fromRGB(
            120,
            220,
            110
        )

end

local function disableFPSBoost()

    fpsBoostEnabled = false

    Lighting.GlobalShadows =
        savedLighting.GlobalShadows

    for object, settings in pairs(
        savedEffects
    ) do

        if object
            and object.Parent then

            object.Enabled =
                settings.Enabled

        end

    end

    status.Text =
        "● Garden FPS boost disabled"

    status.TextColor3 =
        colors.subtext

end

--==================================================
-- LOW GRAPHICS
--==================================================

local function enableLowGraphics()

    lowGraphicsEnabled = true

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do

        if object:IsA("BasePart") then

            if lowGraphicsOriginals[object] == nil then

                lowGraphicsOriginals[object] = {
                    Material = object.Material,
                    CastShadow = object.CastShadow
                }

            end

            object.Material =
                Enum.Material.SmoothPlastic

            object.CastShadow = false

        end

    end

    status.Text =
        "● Low graphics enabled"

    status.TextColor3 =
        colors.orange

end

local function disableLowGraphics()

    lowGraphicsEnabled = false

    for object, data in pairs(
        lowGraphicsOriginals
    ) do

        if object
            and object.Parent
            and data then

            object.Material =
                data.Material

            object.CastShadow =
                data.CastShadow

        end

    end

    status.Text =
        "● Low graphics disabled"

    status.TextColor3 =
        colors.subtext

end

--==================================================
-- EFFECTS
--==================================================

local function removeAllEffects()

    effectsRemoved = true

    for _, object in ipairs(
        workspace:GetDescendants()
    ) do

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

    for _, object in ipairs(
        Lighting:GetChildren()
    ) do

        if object:IsA("BloomEffect")
            or object:IsA("BlurEffect")
            or object:IsA("ColorCorrectionEffect")
            or object:IsA("SunRaysEffect")
            or object:IsA("DepthOfFieldEffect") then

            saveEffect(object)

            object.Enabled = false

        end

    end

    status.Text =
        "● Effects removed"

    status.TextColor3 =
        colors.purple

end

local function restoreEffects()

    effectsRemoved = false

    for object, settings in pairs(
        savedEffects
    ) do

        if object
            and object.Parent then

            object.Enabled =
                settings.Enabled

        end

    end

    status.Text =
        "● Effects restored"

    status.TextColor3 =
        colors.blue

end

--==================================================
-- TELEPORT
--==================================================

local function teleportToPosition1()

    if not savedCFrame1 then

        status.Text =
            "● Position 1 not saved"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                110,
                110
            )

        return

    end

    local character =
        player.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    root.AssemblyLinearVelocity =
        Vector3.zero

    root.AssemblyAngularVelocity =
        Vector3.zero

    character:PivotTo(
        savedCFrame1
    )

    root.AssemblyLinearVelocity =
        Vector3.zero

    root.AssemblyAngularVelocity =
        Vector3.zero

    status.Text =
        "● Teleported to Garden Plot 1"

    status.TextColor3 =
        colors.blue

end

local function teleportToPosition2()

    if not savedCFrame2 then

        status.Text =
            "● Position 2 not saved"

        status.TextColor3 =
            Color3.fromRGB(
                255,
                110,
                110
            )

        return

    end

    local character =
        player.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    root.AssemblyLinearVelocity =
        Vector3.zero

    root.AssemblyAngularVelocity =
        Vector3.zero

    character:PivotTo(
        savedCFrame2
    )

    root.AssemblyLinearVelocity =
        Vector3.zero

    root.AssemblyAngularVelocity =
        Vector3.zero

    status.Text =
        "● Teleported to Garden Plot 2"

    status.TextColor3 =
        colors.blue

end

--==================================================
-- MAIN MENU
--==================================================

showMainMenu = function()

    currentPage = "MENU"

    clearPage()
    resizeFrame(330)

    local heading =
        Instance.new("TextLabel")

    heading.Size =
        UDim2.new(1, 0, 0, 25)

    heading.Position =
        UDim2.new(0, 0, 0, 4)

    heading.BackgroundTransparency = 1

    heading.Text =
        "🌱 GAG 2 - MACRO?"

    heading.TextColor3 =
        Color3.fromRGB(
            180,
            211,
            155
        )

    heading.TextSize = 11
    heading.Font =
        Enum.Font.GothamBold

    heading.TextXAlignment =
        Enum.TextXAlignment.Left

    heading.Parent = content

    local gameFeatures =
        createButton(
            content,
            "🎮  GAME FEATURES",
            0,
            37,
            310,
            56,
            colors.leaf
        )

    local performance =
        createButton(
            content,
            "⚡  GARDEN PERFORMANCE",
            0,
            101,
            310,
            56,
            colors.blue
        )

    local teleport =
        createButton(
            content,
            "📍  GARDEN LOCATIONS",
            0,
            165,
            310,
            56,
            colors.soil
        )

    gameFeatures.MouseButton1Click:Connect(
        showGameFeatures
    )

    performance.MouseButton1Click:Connect(
        showPerformance
    )

    teleport.MouseButton1Click:Connect(
        showTeleport
    )

end

--==================================================
-- GAME FEATURES
--==================================================

showGameFeatures = function()

    currentPage = "GAME"

    clearPage()
    resizeFrame(325)

    createBackButton()

    local heading =
        Instance.new("TextLabel")

    heading.Size =
        UDim2.new(1, 0, 0, 30)

    heading.Position =
        UDim2.new(0, 0, 0, 45)

    heading.BackgroundTransparency = 1

    heading.Text =
        "🎮  GARDENER TOOLS"

    heading.TextColor3 =
        colors.text

    heading.TextSize = 16
    heading.Font =
        Enum.Font.GothamBold

    heading.TextXAlignment =
        Enum.TextXAlignment.Left

    heading.Parent = content

    local instantE =
        createButton(
            content,

            instantEEnabled
                and "⚡ INSTANT E: ON"
                or "⚡ INSTANT E: OFF",

            0,
            83,
            150,
            45,

            instantEEnabled
                and colors.leaf
                or colors.off
        )

    local floatButton =
        createButton(
            content,

            floatEnabled
                and "☁ FLOAT: ON"
                or "☁ FLOAT: OFF",

            160,
            83,
            150,
            45,

            floatEnabled
                and colors.leaf
                or colors.off
        )

    local antiSitButton =
        createButton(
            content,

            antiSitEnabled
                and "🪑 ANTI SIT: ON"
                or "🪑 ANTI SIT: OFF",

            0,
            136,
            310,
            45,

            antiSitEnabled
                and colors.leaf
                or colors.off
        )

    instantE.MouseButton1Click:Connect(
        function()

            if instantEEnabled then
                disableInstantE()
            else
                enableInstantE()
            end

            updateToggleButton(
                instantE,
                "⚡ INSTANT E: ON",
                "⚡ INSTANT E: OFF",
                instantEEnabled
            )

        end
    )

    floatButton.MouseButton1Click:Connect(
        function()

            toggleFloat()

            updateToggleButton(
                floatButton,
                "☁ FLOAT: ON",
                "☁ FLOAT: OFF",
                floatEnabled
            )

        end
    )

    antiSitButton.MouseButton1Click:Connect(
        function()

            antiSitEnabled =
                not antiSitEnabled

            if antiSitEnabled then

                if player.Character then

                    setupAntiSit(
                        player.Character
                    )

                end

                status.Text =
                    "● Anti Sit enabled"

                status.TextColor3 =
                    Color3.fromRGB(
                        120,
                        220,
                        110
                    )

            else

                disconnectAntiSit()

                status.Text =
                    "● Anti Sit disabled"

                status.TextColor3 =
                    colors.subtext

            end

            updateToggleButton(
                antiSitButton,
                "🪑 ANTI SIT: ON",
                "🪑 ANTI SIT: OFF",
                antiSitEnabled
            )

        end
    )

end

--==================================================
-- PERFORMANCE
--==================================================

showPerformance = function()

    currentPage = "PERFORMANCE"

    clearPage()
    resizeFrame(325)

    createBackButton()

    local heading =
        Instance.new("TextLabel")

    heading.Size =
        UDim2.new(1, 0, 0, 30)

    heading.Position =
        UDim2.new(0, 0, 0, 45)

    heading.BackgroundTransparency = 1

    heading.Text =
        "⚡  GARDEN PERFORMANCE"

    heading.TextColor3 =
        colors.text

    heading.TextSize = 16
    heading.Font =
        Enum.Font.GothamBold

    heading.TextXAlignment =
        Enum.TextXAlignment.Left

    heading.Parent = content

    local fpsBoost =
        createButton(
            content,

            fpsBoostEnabled
                and "✓ FPS BOOST: ON"
                or "⚡ FPS BOOST: OFF",

            0,
            83,
            150,
            45,

            fpsBoostEnabled
                and colors.leaf
                or colors.off
        )

    local normalGraphics =
        createButton(
            content,
            "☀ NORMAL GRAPHICS",
            160,
            83,
            150,
            45,
            colors.blue
        )

    local removeEffectsButton =
        createButton(
            content,

            effectsRemoved
                and "✓ EFFECTS: ON"
                or "✦ EFFECTS: OFF",

            0,
            136,
            150,
            45,

            effectsRemoved
                and colors.leaf
                or colors.off
        )

    local lowGraphics =
        createButton(
            content,

            lowGraphicsEnabled
                and "✓ LOW GRAPHICS: ON"
                or "🍂 LOW GRAPHICS: OFF",

            160,
            136,
            150,
            45,

            lowGraphicsEnabled
                and colors.leaf
                or colors.off
        )

    fpsBoost.MouseButton1Click:Connect(
        function()

            if fpsBoostEnabled then
                disableFPSBoost()
            else
                enableFPSBoost()
            end

            updateToggleButton(
                fpsBoost,
                "✓ FPS BOOST: ON",
                "⚡ FPS BOOST: OFF",
                fpsBoostEnabled
            )

            updateToggleButton(
                lowGraphics,
                "✓ LOW GRAPHICS: ON",
                "🍂 LOW GRAPHICS: OFF",
                lowGraphicsEnabled
            )

            updateToggleButton(
                removeEffectsButton,
                "✓ EFFECTS: ON",
                "✦ EFFECTS: OFF",
                effectsRemoved
            )

        end
    )

    normalGraphics.MouseButton1Click:Connect(
        function()

            disableFPSBoost()

            updateToggleButton(
                fpsBoost,
                "✓ FPS BOOST: ON",
                "⚡ FPS BOOST: OFF",
                fpsBoostEnabled
            )

            updateToggleButton(
                lowGraphics,
                "✓ LOW GRAPHICS: ON",
                "🍂 LOW GRAPHICS: OFF",
                lowGraphicsEnabled
            )

            updateToggleButton(
                removeEffectsButton,
                "✓ EFFECTS: ON",
                "✦ EFFECTS: OFF",
                effectsRemoved
            )

        end
    )

    removeEffectsButton.MouseButton1Click:Connect(
        function()

            if effectsRemoved then
                restoreEffects()
            else
                removeAllEffects()
            end

            updateToggleButton(
                removeEffectsButton,
                "✓ EFFECTS: ON",
                "✦ EFFECTS: OFF",
                effectsRemoved
            )

            updateToggleButton(
                fpsBoost,
                "✓ FPS BOOST: ON",
                "⚡ FPS BOOST: OFF",
                fpsBoostEnabled
            )

            updateToggleButton(
                lowGraphics,
                "✓ LOW GRAPHICS: ON",
                "🍂 LOW GRAPHICS: OFF",
                lowGraphicsEnabled
            )

        end
    )

    lowGraphics.MouseButton1Click:Connect(
        function()

            if lowGraphicsEnabled then
                disableLowGraphics()
            else
                enableLowGraphics()
            end

            updateToggleButton(
                lowGraphics,
                "✓ LOW GRAPHICS: ON",
                "🍂 LOW GRAPHICS: OFF",
                lowGraphicsEnabled
            )

            updateToggleButton(
                fpsBoost,
                "✓ FPS BOOST: ON",
                "⚡ FPS BOOST: OFF",
                fpsBoostEnabled
            )

            updateToggleButton(
                removeEffectsButton,
                "✓ EFFECTS: ON",
                "✦ EFFECTS: OFF",
                effectsRemoved
            )

        end
    )

end

--==================================================
-- TELEPORT
--==================================================

showTeleport = function()

    currentPage = "TELEPORT"

    clearPage()
    resizeFrame(365)

    createBackButton()

    local heading =
        Instance.new("TextLabel")

    heading.Size =
        UDim2.new(1, 0, 0, 30)

    heading.Position =
        UDim2.new(0, 0, 0, 45)

    heading.BackgroundTransparency = 1

    heading.Text =
        "📍  GARDEN LOCATIONS"

    heading.TextColor3 =
        colors.text

    heading.TextSize = 16
    heading.Font =
        Enum.Font.GothamBold

    heading.TextXAlignment =
        Enum.TextXAlignment.Left

    heading.Parent = content

    local save1 =
        createButton(
            content,
            "🌱 SAVE PLOT 1",
            0,
            83,
            150,
            45,
            colors.leaf
        )

    local teleport1 =
        createButton(
            content,
            "🚜 GO TO PLOT 1 [F]",
            160,
            83,
            150,
            45,
            colors.blue
        )

    local save2 =
        createButton(
            content,
            "🌱 SAVE PLOT 2",
            0,
            136,
            150,
            45,
            colors.leaf
        )

    local teleport2 =
        createButton(
            content,
            "🚜 GO TO PLOT 2 [G]",
            160,
            136,
            150,
            45,
            colors.blue
        )

    local clear =
        createButton(
            content,
            "🗑  CLEAR GARDEN LOCATIONS",
            0,
            189,
            310,
            40,
            colors.red
        )

    save1.MouseButton1Click:Connect(
        function()

            local character =
                player.Character

            if not character then
                return
            end

            local root =
                character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if root then

                savedCFrame1 =
                    root.CFrame

                save1.Text =
                    "✓ PLOT 1 SAVED"

                status.Text =
                    "● Garden Plot 1 saved"

                status.TextColor3 =
                    Color3.fromRGB(
                        120,
                        220,
                        110
                    )

                task.delay(
                    1,
                    function()

                        if save1
                            and save1.Parent then

                            save1.Text =
                                "🌱 SAVE PLOT 1"

                        end

                    end
                )

            end

        end
    )

    teleport1.MouseButton1Click:Connect(
        teleportToPosition1
    )

    save2.MouseButton1Click:Connect(
        function()

            local character =
                player.Character

            if not character then
                return
            end

            local root =
                character:FindFirstChild(
                    "HumanoidRootPart"
                )

            if root then

                savedCFrame2 =
                    root.CFrame

                save2.Text =
                    "✓ PLOT 2 SAVED"

                status.Text =
                    "● Garden Plot 2 saved"

                status.TextColor3 =
                    Color3.fromRGB(
                        120,
                        220,
                        110
                    )

                task.delay(
                    1,
                    function()

                        if save2
                            and save2.Parent then

                            save2.Text =
                                "🌱 SAVE PLOT 2"

                        end

                    end
                )

            end

        end
    )

    teleport2.MouseButton1Click:Connect(
        teleportToPosition2
    )

    clear.MouseButton1Click:Connect(
        function()

            savedCFrame1 = nil
            savedCFrame2 = nil

            status.Text =
                "● Garden locations cleared"

            status.TextColor3 =
                Color3.fromRGB(
                    255,
                    110,
                    110
                )

        end
    )

end

--==================================================
-- MINIMIZE / K LOGO
--==================================================

local minimizedSize =
    UDim2.new(
        0,
        58,
        0,
        58
    )

minimize.MouseButton1Click:Connect(
    function()

        -- If the user dragged the K logo,
        -- do NOT restore the menu.
        if minimizeMoved then
            minimizeMoved = false
            return
        end

        minimized =
            not minimized

        if minimized then

            content.Visible = false
            subtitle.Visible = false
            status.Visible = false
            title.Visible = false

            leafLeft.Visible = false
            leafRight.Visible = false
            grassStrip.Visible = false
            woodHeader.Visible = false

            -- K LOGO STYLE
            main.BackgroundColor3 =
                colors.soil

            mainStroke.Color =
                colors.leafLight

            mainStroke.Thickness = 3
            mainStroke.Transparency = 0

            TweenService:Create(
                main,

                TweenInfo.new(
                    0.22,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ),

                {
                    Size =
                        minimizedSize
                }

            ):Play()

            minimize.Size =
                UDim2.new(
                    1,
                    -8,
                    1,
                    -8
                )

            minimize.Position =
                UDim2.new(
                    0,
                    4,
                    0,
                    4
                )

            minimize.BackgroundColor3 =
                colors.soilDark

            minimize.Text =
                "K"

            minimize.TextColor3 =
                colors.gold

            minimize.TextSize =
                25

            minimize.Font =
                Enum.Font.GothamBlack

        else

            local height

            if currentPage ==
                "TELEPORT" then

                height = 365

            elseif currentPage ==
                "MENU" then

                height = 330

            else

                height = 325

            end

            main.BackgroundColor3 =
                colors.panel

            mainStroke.Color =
                colors.leaf

            mainStroke.Thickness = 2
            mainStroke.Transparency = 0.15

            TweenService:Create(
                main,

                TweenInfo.new(
                    0.22,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.Out
                ),

                {
                    Size =
                        UDim2.new(
                            0,
                            340,
                            0,
                            height
                        )
                }

            ):Play()

            minimize.Size =
                UDim2.new(
                    0,
                    35,
                    0,
                    30
                )

            minimize.Position =
                UDim2.new(
                    1,
                    -47,
                    0,
                    10
                )

            minimize.BackgroundColor3 =
                colors.soilDark

            minimize.Text =
                "−"

            minimize.TextColor3 =
                colors.text

            minimize.TextSize =
                21

            minimize.Font =
                Enum.Font.GothamBold

            task.delay(
                0.15,
                function()

                    content.Visible = true
                    subtitle.Visible = true
                    status.Visible = true
                    title.Visible = true

                    leafLeft.Visible = true
                    leafRight.Visible = true
                    grassStrip.Visible = true
                    woodHeader.Visible = true

                end
            )

        end

    end
)

--==================================================
-- NEW PROXIMITY PROMPTS
--==================================================

workspace.DescendantAdded:Connect(
    function(object)

        if object:IsA(
            "ProximityPrompt"
        )
        and instantEEnabled then

            makePromptInstant(object)

        end

    end
)

--==================================================
-- CHARACTER RESPAWN
--==================================================

player.CharacterAdded:Connect(
    function(character)

        task.wait(0.5)

        if antiSitEnabled then

            setupAntiSit(character)

        end

    end
)

--==================================================
-- TELEPORT KEYBINDS
--==================================================

UserInputService.InputBegan:Connect(
    function(
        input,
        gameProcessed
    )

        if gameProcessed then
            return
        end

        if input.KeyCode ==
            Enum.KeyCode.F then

            teleportToPosition1()

        elseif input.KeyCode ==
            Enum.KeyCode.G then

            teleportToPosition2()

        end

    end
)

--==================================================
-- START GUI
--==================================================

showMainMenu()
