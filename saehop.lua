--// 🥚 ADVANCED SERVER HOP
--// Fixed Manual Retry Version
--// Small Server Finder
--// Account Age Checker
--// Basic Bacon / Noob Avatar Checker
--// Teleport failure NEVER starts another search
--// Old script sessions are invalidated

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local MIN_ACCOUNT_AGE = 30
local MAX_PLAYERS = 2
local MAX_PAGES = 10
local MAX_RETRIES = 20
local TELEPORT_TIMEOUT = 12

--==================================================
-- GLOBAL CONTROLLER
--==================================================
-- Every time this script runs, the old controller
-- becomes invalid.

local controller = {}

_G.AdvancedServerHopController = controller

controller.alive = true
controller.session = 0

--==================================================
-- INVALIDATE OLD CONTROLLER
--==================================================

local oldController = _G.AdvancedServerHopController

-- The assignment above replaces the old controller.
-- Old scripts check whether their controller is still
-- the current controller before doing anything.

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("AdvancedServerHop")

if oldGui then
	oldGui:Destroy()
end

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "AdvancedServerHop"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

--==================================================
-- MAIN WINDOW
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 360, 0, 300)
main.Position = UDim2.new(0.5, -180, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(255, 205, 70)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.2
mainStroke.Parent = main

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 70)
header.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
header.BorderSizePixel = 0
header.Active = true
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 18)
headerCorner.Parent = header

local egg = Instance.new("TextLabel")
egg.Size = UDim2.new(0, 55, 0, 55)
egg.Position = UDim2.new(0, 10, 0, 8)
egg.BackgroundTransparency = 1
egg.Text = "🥚"
egg.TextSize = 34
egg.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -130, 0, 28)
title.Position = UDim2.new(0, 68, 0, 9)
title.BackgroundTransparency = 1
title.Text = "SERVER HOP"
title.TextColor3 = Color3.fromRGB(255, 215, 80)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -130, 0, 20)
subtitle.Position = UDim2.new(0, 69, 0, 37)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Find small & safe servers"
subtitle.TextColor3 = Color3.fromRGB(155, 155, 165)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

--==================================================
-- CLOSE BUTTON
--==================================================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -45, 0, 18)
close.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
close.BorderSizePixel = 0
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = close

--==================================================
-- SERVER INFO CARD
--==================================================

local info = Instance.new("Frame")
info.Size = UDim2.new(1, -24, 0, 72)
info.Position = UDim2.new(0, 12, 0, 82)
info.BackgroundColor3 = Color3.fromRGB(29, 29, 40)
info.BorderSizePixel = 0
info.Parent = main

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 12)
infoCorner.Parent = info

--==================================================
-- PLAYER COUNT
--==================================================

local playerIcon = Instance.new("TextLabel")
playerIcon.Size = UDim2.new(0, 35, 0, 35)
playerIcon.Position = UDim2.new(0, 10, 0, 10)
playerIcon.BackgroundTransparency = 1
playerIcon.Text = "👥"
playerIcon.TextSize = 20
playerIcon.Parent = info

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(0, 100, 0, 18)
playerTitle.Position = UDim2.new(0, 48, 0, 9)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "PLAYERS"
playerTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
playerTitle.TextSize = 10
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = info

local playerCount = Instance.new("TextLabel")
playerCount.Size = UDim2.new(0, 100, 0, 25)
playerCount.Position = UDim2.new(0, 48, 0, 28)
playerCount.BackgroundTransparency = 1
playerCount.Text = "..."
playerCount.TextColor3 = Color3.fromRGB(255, 215, 80)
playerCount.TextSize = 17
playerCount.Font = Enum.Font.GothamBold
playerCount.TextXAlignment = Enum.TextXAlignment.Left
playerCount.Parent = info

--==================================================
-- ACCOUNT STATUS
--==================================================

local accountIcon = Instance.new("TextLabel")
accountIcon.Size = UDim2.new(0, 35, 0, 35)
accountIcon.Position = UDim2.new(0.5, 5, 0, 10)
accountIcon.BackgroundTransparency = 1
accountIcon.Text = "🛡️"
accountIcon.TextSize = 20
accountIcon.Parent = info

local accountTitle = Instance.new("TextLabel")
accountTitle.Size = UDim2.new(0, 120, 0, 18)
accountTitle.Position = UDim2.new(0.5, 43, 0, 9)
accountTitle.BackgroundTransparency = 1
accountTitle.Text = "ACCOUNT CHECK"
accountTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
accountTitle.TextSize = 10
accountTitle.Font = Enum.Font.GothamBold
accountTitle.TextXAlignment = Enum.TextXAlignment.Left
accountTitle.Parent = info

local accountStatus = Instance.new("TextLabel")
accountStatus.Size = UDim2.new(0, 130, 0, 25)
accountStatus.Position = UDim2.new(0.5, 43, 0, 28)
accountStatus.BackgroundTransparency = 1
accountStatus.Text = "READY"
accountStatus.TextColor3 = Color3.fromRGB(100, 255, 130)
accountStatus.TextSize = 14
accountStatus.Font = Enum.Font.GothamBold
accountStatus.TextXAlignment = Enum.TextXAlignment.Left
accountStatus.Parent = info

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 30)
status.Position = UDim2.new(0, 12, 0, 162)
status.BackgroundTransparency = 1
status.Text = "● Ready to search"
status.TextColor3 = Color3.fromRGB(170, 170, 180)
status.TextSize = 12
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==================================================
-- PROGRESS BAR
--==================================================

local progressBackground = Instance.new("Frame")
progressBackground.Size = UDim2.new(1, -24, 0, 6)
progressBackground.Position = UDim2.new(0, 12, 0, 190)
progressBackground.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
progressBackground.BorderSizePixel = 0
progressBackground.Parent = main

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBackground

local progress = Instance.new("Frame")
progress.Size = UDim2.new(0, 0, 1, 0)
progress.BackgroundColor3 = Color3.fromRGB(255, 205, 70)
progress.BorderSizePixel = 0
progress.Parent = progressBackground

local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(1, 0)
progressFillCorner.Parent = progress

--==================================================
-- LEAVE BUTTON
--==================================================

local leave = Instance.new("TextButton")
leave.Size = UDim2.new(0, 104, 0, 45)
leave.Position = UDim2.new(0, 12, 0, 218)
leave.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
leave.BorderSizePixel = 0
leave.Text = "LEAVE"
leave.TextColor3 = Color3.fromRGB(255, 120, 120)
leave.TextSize = 13
leave.Font = Enum.Font.GothamBold
leave.Parent = main

local leaveCorner = Instance.new("UICorner")
leaveCorner.CornerRadius = UDim.new(0, 10)
leaveCorner.Parent = leave

--==================================================
-- SERVER HOP BUTTON
--==================================================

local hop = Instance.new("TextButton")
hop.Size = UDim2.new(0, 224, 0, 45)
hop.Position = UDim2.new(0, 124, 0, 218)
hop.BackgroundColor3 = Color3.fromRGB(255, 195, 60)
hop.BorderSizePixel = 0
hop.Text = "🔄  SERVER HOP"
hop.TextColor3 = Color3.fromRGB(25, 25, 25)
hop.TextSize = 14
hop.Font = Enum.Font.GothamBold
hop.Parent = main

local hopCorner = Instance.new("UICorner")
hopCorner.CornerRadius = UDim.new(0, 10)
hopCorner.Parent = hop

--==================================================
-- OPEN BUTTON
--==================================================

local open = Instance.new("TextButton")
open.Size = UDim2.new(0, 60, 0, 60)
open.Position = UDim2.new(0, 20, 0.5, -30)
open.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
open.BorderSizePixel = 0
open.Text = "🥚"
open.TextSize = 30
open.Visible = false
open.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = open

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(255, 205, 70)
openStroke.Thickness = 2
openStroke.Parent = open

--==================================================
-- STATE
--==================================================

local hopping = false
local teleporting = false

--==================================================
-- SESSION CHECK
--==================================================

local function isCurrentController()
	return _G.AdvancedServerHopController == controller
		and controller.alive == true
end

local function newSession()
	controller.session += 1
	return controller.session
end

local function isCurrentSession(sessionId)
	return isCurrentController()
		and controller.session == sessionId
end

--==================================================
-- RESET
--==================================================

local function resetHopButton(message, sessionId)
	if sessionId and not isCurrentSession(sessionId) then
		return
	end

	-- Invalidate the current search.
	newSession()

	hopping = false
	teleporting = false

	hop.Active = true
	leave.Active = true

	hop.Text = "🔄  SERVER HOP"

	accountStatus.Text = "READY"
	accountStatus.TextColor3 = Color3.fromRGB(100, 255, 130)

	progress.Size = UDim2.new(0, 0, 1, 0)

	if message then
		status.Text = "● " .. message
	else
		status.Text = "● Ready"
	end
end

--==================================================
-- LEAVE
--==================================================

leave.MouseButton1Click:Connect(function()
	if hopping then
		return
	end

	controller.alive = false
	player:Kick("You left the game.")
end)

--==================================================
-- CLOSE / OPEN
--==================================================

close.MouseButton1Click:Connect(function()
	main.Visible = false
	open.Visible = true
end)

open.MouseButton1Click:Connect(function()
	main.Visible = true
	open.Visible = false
end)

--==================================================
-- ACCOUNT AGE CHECK
--==================================================

local function hasNewAccount()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			if plr.AccountAge < MIN_ACCOUNT_AGE then
				return true, plr
			end
		end
	end

	return false, nil
end

--==================================================
-- BASIC BACON / NOOB CHECK
--==================================================
-- This is only a heuristic.
-- It checks for a very basic/default-looking avatar.
--
-- It does NOT guarantee that the player is actually
-- a bacon/noob.

local function isBasicAvatar(plr)
	if not plr.Character then
		return false
	end

	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	local success, description = pcall(function()
		return humanoid:GetAppliedDescription()
	end)

	if not success or not description then
		return false
	end

	local accessories = 0

	if description.HatAccessory ~= "" then
		accessories += 1
	end

	if description.HairAccessory ~= "" then
		accessories += 1
	end

	if description.FaceAccessory ~= "" then
		accessories += 1
	end

	if description.NeckAccessory ~= "" then
		accessories += 1
	end

	if description.ShoulderAccessory ~= "" then
		accessories += 1
	end

	if description.FrontAccessory ~= "" then
		accessories += 1
	end

	if description.BackAccessory ~= "" then
		accessories += 1
	end

	if description.WaistAccessory ~= "" then
		accessories += 1
	end

	local hasClothes =
		description.Shirt ~= 0
		or description.Pants ~= 0

	-- Very basic avatar:
	-- no clothes + no accessories
	if not hasClothes and accessories == 0 then
		return true
	end

	return false
end

--==================================================
-- UPDATE CURRENT SERVER INFO
--==================================================

local function updateCurrentServer()
	if not isCurrentController() then
		return true, nil
	end

	local count = #Players:GetPlayers()

	playerCount.Text =
		tostring(count)
		.. " / "
		.. tostring(game.Players.MaxPlayers)

	local badAccount, badPlayer = hasNewAccount()

	if badAccount then
		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		return false, badPlayer
	end

	accountStatus.Text = "SAFE"
	accountStatus.TextColor3 =
		Color3.fromRGB(100, 255, 130)

	return true, nil
end

--==================================================
-- HTTP SERVER REQUEST
--==================================================

local function getServers(cursor)
	if not isCurrentController() then
		return nil
	end

	local baseUrl =
		"https://games.roblox.com/v1/games/"
		.. game.PlaceId
		.. "/servers/Public?sortOrder=Asc&limit=100"

	local url = baseUrl

	if cursor then
		url =
			url
			.. "&cursor="
			.. HttpService:UrlEncode(cursor)
	end

	local success, result = pcall(function()
		local raw = game:HttpGet(url)
		return HttpService:JSONDecode(raw)
	end)

	if success and result then
		return result
	end

	return nil
end

--==================================================
-- FIND SMALL SERVER
--==================================================

local function findSmallServer(sessionId)
	local cursor = nil

	for page = 1, MAX_PAGES do

		-- STOP immediately if this search is no longer valid.
		if not isCurrentSession(sessionId) then
			return nil
		end

		status.Text =
			"● Searching servers... Page "
			.. page

		progress.Size =
			UDim2.new(
				math.clamp(page / MAX_PAGES, 0, 1),
				0,
				1,
				0
			)

		local result = getServers(cursor)

		if not isCurrentSession(sessionId) then
			return nil
		end

		if not result or not result.data then
			return nil
		end

		for _, server in ipairs(result.data) do

			if not isCurrentSession(sessionId) then
				return nil
			end

			if server.id ~= game.JobId then

				if server.playing >= 1
					and server.playing <= MAX_PLAYERS
					and server.playing < server.maxPlayers
				then
					return server
				end
			end
		end

		cursor = result.nextPageCursor

		if not cursor then
			break
		end

		task.wait(0.2)
	end

	return nil
end

--==================================================
-- TELEPORT FAILURE
--==================================================

TeleportService.TeleportInitFailed:Connect(
	function(
		failedPlayer,
		teleportResult,
		errorMessage
	)

		if failedPlayer ~= player then
			return
		end

		-- Ignore events belonging to old controllers.
		if not isCurrentController() then
			return
		end

		if not teleporting then
			return
		end

		print(
			"[SERVER HOP] Teleport failed:",
			tostring(teleportResult),
			errorMessage or ""
		)

		-- VERY IMPORTANT:
		-- Stop the current session completely.
		newSession()

		hopping = false
		teleporting = false

		hop.Active = true
		leave.Active = true

		hop.Text = "🔄  SERVER HOP"

		progress.Size =
			UDim2.new(0, 0, 1, 0)

		accountStatus.Text = "FAILED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		local reason = tostring(teleportResult)

		if string.find(reason, "GameFull") then
			status.Text =
				"● Server full. Click SERVER HOP to retry."
		else
			status.Text =
				"● Teleport failed. Click SERVER HOP to retry."
		end
	end
)

--==================================================
-- SERVER HOP
--==================================================

local function serverHop()

	if not isCurrentController() then
		return
	end

	-- Prevent double clicking.
	if hopping or teleporting then
		return
	end

	-- Create a NEW search session.
	local sessionId = newSession()

	hopping = true
	teleporting = false

	hop.Active = false
	leave.Active = false

	hop.Text = "🔍  SEARCHING..."

	accountStatus.Text = "CHECKING"
	accountStatus.TextColor3 =
		Color3.fromRGB(255, 215, 80)

	progress.Size =
		UDim2.new(0, 0, 1, 0)

	--==================================================
	-- SEARCH
	--==================================================

	local server = nil

	for attempt = 1, MAX_RETRIES do

		if not isCurrentSession(sessionId) then
			return
		end

		status.Text =
			"● Searching... "
			.. attempt
			.. "/"
			.. MAX_RETRIES

		server = findSmallServer(sessionId)

		if not isCurrentSession(sessionId) then
			return
		end

		if server then
			break
		end

		status.Text =
			"● No small server found..."

		task.wait(1)
	end

	--==================================================
	-- NO SERVER
	--==================================================

	if not isCurrentSession(sessionId) then
		return
	end

	if not server then
		resetHopButton(
			"No 1-2 player server found.",
			sessionId
		)

		return
	end

	--==================================================
	-- SERVER FOUND
	--==================================================

	if not isCurrentSession(sessionId) then
		return
	end

	playerCount.Text =
		tostring(server.playing)
		.. " / "
		.. tostring(server.maxPlayers)

	accountStatus.Text = "SERVER FOUND"
	accountStatus.TextColor3 =
		Color3.fromRGB(100, 255, 130)

	status.Text =
		"● Found "
		.. server.playing
		.. " player(s) • Joining..."

	hop.Text = "🚀  JOINING..."

	progress.Size =
		UDim2.new(1, 0, 1, 0)

	task.wait(0.5)

	--==================================================
	-- TELEPORT
	--==================================================

	if not isCurrentSession(sessionId) then
		return
	end

	teleporting = true

	local teleportCallSuccess, teleportError =
		pcall(function()

			TeleportService:TeleportToPlaceInstance(
				game.PlaceId,
				server.id,
				player
			)

		end)

	-- pcall success only means the function call itself
	-- did not throw an immediate Lua error.

	if not teleportCallSuccess then

		print(
			"[SERVER HOP] Teleport call error:",
			teleportError
		)

		resetHopButton(
			"Teleport failed. Click SERVER HOP to retry.",
			sessionId
		)

		return
	end

	if not isCurrentSession(sessionId) then
		return
	end

	status.Text = "● Teleporting..."
	hop.Text = "🚀  JOINING..."

	--==================================================
	-- TELEPORT TIMEOUT
	--==================================================
	-- IMPORTANT:
	-- This only unlocks the button.
	-- It NEVER calls serverHop().
	-- It NEVER searches again.

	task.spawn(function()

		local started = os.clock()

		while true do

			if not isCurrentSession(sessionId) then
				return
			end

			if not teleporting then
				return
			end

			if os.clock() - started >= TELEPORT_TIMEOUT then

				-- Check whether we actually left
				-- the original server.

				if game.JobId ~= server.id then
					return
				end

				print(
					"[SERVER HOP] Teleport timed out."
				)

				resetHopButton(
					"Teleport timed out. Click SERVER HOP to retry.",
					sessionId
				)

				return
			end

			task.wait(0.5)
		end
	end)
end

--==================================================
-- BUTTON
--==================================================

hop.MouseButton1Click:Connect(function()

	if not isCurrentController() then
		return
	end

	if hopping or teleporting then
		return
	end

	serverHop()
end)

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	then

		local delta =
			input.Position - dragStart

		main.Position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then

		dragging = false
	end
end)

--==================================================
-- HOVER EFFECTS
--==================================================

local function addHover(
	button,
	normalColor,
	hoverColor
)

	button.MouseEnter:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = hoverColor
			}
		):Play()

	end)

	button.MouseLeave:Connect(function()

		TweenService:Create(
			button,
			TweenInfo.new(0.15),
			{
				BackgroundColor3 = normalColor
			}
		):Play()

	end)
end

addHover(
	hop,
	Color3.fromRGB(255, 195, 60),
	Color3.fromRGB(255, 210, 90)
)

addHover(
	leave,
	Color3.fromRGB(55, 55, 68),
	Color3.fromRGB(70, 70, 82)
)

addHover(
	close,
	Color3.fromRGB(48, 48, 58),
	Color3.fromRGB(65, 65, 75)
)

--==================================================
-- PLAYER UPDATE
--==================================================

Players.PlayerAdded:Connect(function()

	task.wait(0.5)

	if not isCurrentController() then
		return
	end

	if not hopping and not teleporting then
		updateCurrentServer()
	end
end)

Players.PlayerRemoving:Connect(function()

	task.wait(0.2)

	if not isCurrentController() then
		return
	end

	if not hopping and not teleporting then
		updateCurrentServer()
	end
end)

--==================================================
-- INITIAL CHECK
--==================================================

task.spawn(function()

	task.wait(3)

	if not isCurrentController() then
		return
	end

	if hopping or teleporting then
		return
	end

	local safe, badPlayer =
		updateCurrentServer()

	if not safe and badPlayer then

		status.Text =
			"● "
			.. badPlayer.Name
			.. " is under "
			.. MIN_ACCOUNT_AGE
			.. " days"

		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		-- IMPORTANT:
		-- Do NOT automatically hop.
		-- User must click SERVER HOP.

	else

		status.Text =
			"● Server accepted!"

	end
end)

--==================================================
-- LOADED
--==================================================

print("🥚 ADVANCED SERVER HOP LOADED")
print("Small server: 1-2 players")
print(
	"Minimum account age: "
		.. MIN_ACCOUNT_AGE
		.. " days"
)
print("Teleport failure: MANUAL RETRY ONLY")
print("Old sessions: INVALIDATED")
