--// 🥚 ADVANCED SERVER HOP
--// Modern Egg-Style UI
--// Finds servers with 1-2 players
--// Rejects accounts younger than 30 days
--// Bacon / Noob avatar checker
--// Teleport failure DOES NOT automatically retry
--// SERVER HOP button becomes usable again after teleport failure

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local MIN_ACCOUNT_AGE = 30

local MAX_PLAYERS = 2

local MAX_PAGES = 10
local MAX_RETRIES = 20

-- Avatar checking
local ENABLE_AVATAR_CHECK = true
local REJECT_BACON = true
local REJECT_NOOB = true

--==================================================
-- REMOVE OLD GUI
--==================================================

local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("AdvancedServerHop")

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
gui.Parent = player:WaitForChild("PlayerGui")

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
-- BOTTOM BUTTONS
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
-- LEAVE
--==================================================

leave.MouseButton1Click:Connect(function()
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
-- ACCOUNT CHECK
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
-- AVATAR HELPERS
--==================================================

local function getBodyColor(character, bodyPartName)
	local bodyColors = character:FindFirstChildOfClass("BodyColors")

	if not bodyColors then
		return nil
	end

	local propertyName = bodyPartName .. "Color"

	local brickColor = bodyColors[propertyName]

	if brickColor then
		return brickColor.Color
	end

	return nil
end

local function isNoobAvatar(plr)
	if not plr.Character then
		return false
	end

	local character = plr.Character

	local headColor = getBodyColor(character, "Head")
	local torsoColor = getBodyColor(character, "Torso")
	local leftArmColor = getBodyColor(character, "LeftArm")
	local rightArmColor = getBodyColor(character, "RightArm")
	local leftLegColor = getBodyColor(character, "LeftLeg")
	local rightLegColor = getBodyColor(character, "RightLeg")

	if not headColor
		or not torsoColor
		or not leftArmColor
		or not rightArmColor
		or not leftLegColor
		or not rightLegColor
	then
		return false
	end

	-- Classic Roblox noob colors:
	-- Head/arms = yellow
	-- Torso = blue
	-- Legs = green

	local yellow = Color3.fromRGB(245, 205, 48)
	local blue = Color3.fromRGB(13, 105, 172)
	local green = Color3.fromRGB(75, 151, 75)

	local function closeColor(a, b)
		return math.abs(a.R - b.R) < 0.08
			and math.abs(a.G - b.G) < 0.08
			and math.abs(a.B - b.B) < 0.08
	end

	if closeColor(headColor, yellow)
		and closeColor(leftArmColor, yellow)
		and closeColor(rightArmColor, yellow)
		and closeColor(torsoColor, blue)
		and closeColor(leftLegColor, green)
		and closeColor(rightLegColor, green)
	then
		return true
	end

	return false
end

local function isBaconAvatar(plr)
	if not plr.Character then
		return false
	end

	local character = plr.Character

	-- Look for common bacon/default hair names.
	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("Accessory") then
			local name = string.lower(object.Name)

			if string.find(name, "bacon")
				or string.find(name, "pal hair")
				or string.find(name, "bacon hair")
			then
				return true
			end
		end
	end

	-- Also check for classic R6-style avatar
	-- with very few accessories.
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 then
		local accessoryCount = 0

		for _, object in ipairs(character:GetChildren()) do
			if object:IsA("Accessory") then
				accessoryCount += 1
			end
		end

		-- A classic R6 avatar with only 1 accessory
		-- is treated as a possible bacon avatar.
		if accessoryCount <= 1 then
			for _, object in ipairs(character:GetChildren()) do
				if object:IsA("Accessory") then
					local name = string.lower(object.Name)

					if string.find(name, "hair")
						or string.find(name, "pal")
					then
						return true
					end
				end
			end
		end
	end

	return false
end

--==================================================
-- FIND BAD AVATAR
--==================================================

local function findBadAvatar()
	if not ENABLE_AVATAR_CHECK then
		return false, nil, nil
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then

			if REJECT_NOOB and isNoobAvatar(plr) then
				return true, plr, "NOOB"
			end

			if REJECT_BACON and isBaconAvatar(plr) then
				return true, plr, "BACON"
			end

		end
	end

	return false, nil, nil
end

--==================================================
-- UPDATE CURRENT SERVER INFO
--==================================================

local function updateCurrentServer()
	local count = #Players:GetPlayers()

	playerCount.Text =
		tostring(count)
		.. " / "
		.. tostring(MAX_PLAYERS)

	-- Account age check
	local badAccount, badPlayer = hasNewAccount()

	if badAccount then
		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		return false, badPlayer, "ACCOUNT"
	end

	-- Bacon / Noob check
	local badAvatar, avatarPlayer, avatarType = findBadAvatar()

	if badAvatar then
		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		return false, avatarPlayer, avatarType
	end

	accountStatus.Text = "SAFE"
	accountStatus.TextColor3 =
		Color3.fromRGB(100, 255, 130)

	return true, nil, nil
end

--==================================================
-- HTTP SERVER REQUEST
--==================================================

local function getServers(cursor)

	local baseUrl =
		"https://games.roblox.com/v1/games/"
		.. game.PlaceId
		.. "/servers/Public?sortOrder=Asc&limit=100"

	local url = baseUrl

	if cursor then
		url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
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

local function findSmallServer()

	local cursor = nil

	for page = 1, MAX_PAGES do

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

		if not result or not result.data then
			return nil
		end

		for _, server in ipairs(result.data) do

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
-- TELEPORT FAILURE HANDLER
--==================================================

local teleporting = false
local hopping = false

TeleportService.TeleportInitFailed:Connect(
	function(failedPlayer, teleportResult, errorMessage)

		if failedPlayer ~= player then
			return
		end

		-- Teleport failed.
		-- IMPORTANT:
		-- We DO NOT automatically search again.

		teleporting = false
		hopping = false

		hop.Active = true
		leave.Active = true

		hop.Text = "🔄  SERVER HOP"

		progress.Size =
			UDim2.new(0, 0, 1, 0)

		accountStatus.Text = "TELEPORT FAILED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		status.Text =
			"● Teleport failed: "
			.. tostring(teleportResult)

		task.delay(3, function()

			if not hopping then

				accountStatus.Text = "READY"
				accountStatus.TextColor3 =
					Color3.fromRGB(100, 255, 130)

				status.Text =
					"● Click SERVER HOP to try again"

			end

		end)
	end
)

--==================================================
-- SERVER HOP
--==================================================

local function serverHop()

	if hopping or teleporting then
		return
	end

	hopping = true

	hop.Active = false
	leave.Active = false

	hop.Text = "🔍  SEARCHING..."

	accountStatus.Text = "CHECKING"
	accountStatus.TextColor3 =
		Color3.fromRGB(255, 215, 80)

	progress.Size =
		UDim2.new(0, 0, 1, 0)

	--==================================================
	-- CHECK CURRENT SERVER FIRST
	--==================================================

	local safe, badPlayer, badType = updateCurrentServer()

	if not safe then

		if badType == "ACCOUNT" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is under "
				.. MIN_ACCOUNT_AGE
				.. " days"

		elseif badType == "NOOB" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is a NOOB avatar"

		elseif badType == "BACON" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is a BACON avatar"

		else

			status.Text =
				"● Server rejected"

		end

		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

		task.wait(0.8)

	end

	--==================================================
	-- SEARCH
	--==================================================

	for attempt = 1, MAX_RETRIES do

		status.Text =
			"● Searching... "
			.. attempt
			.. "/"
			.. MAX_RETRIES

		local server = findSmallServer()

		if server then

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

			teleporting = true

			local success, errorMessage =
				pcall(function()

					TeleportService:TeleportToPlaceInstance(
						game.PlaceId,
						server.id,
						player
					)

				end)

			if success then

				-- IMPORTANT:
				-- Do NOT return the UI to READY here.
				-- Roblox may still be processing teleport.
				-- TeleportInitFailed will handle actual failure.

				status.Text =
					"● Teleporting..."

				return

			else

				-- This is an immediate Lua/API error.
				-- We do NOT search again.

				teleporting = false
				hopping = false

				hop.Active = true
				leave.Active = true

				hop.Text = "🔄  SERVER HOP"

				accountStatus.Text = "FAILED"
				accountStatus.TextColor3 =
					Color3.fromRGB(255, 100, 100)

				progress.Size =
					UDim2.new(0, 0, 1, 0)

				status.Text =
					"● Teleport failed — click SERVER HOP again"

				warn(
					"[ServerHop] Teleport error: ",
					errorMessage
				)

				return
			end

		else

			-- No server found on this search attempt.
			-- Continue searching because this is not a teleport failure.

			status.Text =
				"● No 1-2 player server found..."

			hop.Text = "🔍  SEARCHING..."

			task.wait(1)

		end
	end

	--==================================================
	-- SEARCH LIMIT REACHED
	--==================================================

	hopping = false
	teleporting = false

	hop.Active = true
	leave.Active = true

	hop.Text = "🔄  SERVER HOP"

	accountStatus.Text = "READY"
	accountStatus.TextColor3 =
		Color3.fromRGB(100, 255, 130)

	progress.Size =
		UDim2.new(0, 0, 1, 0)

	status.Text =
		"● Search finished — click SERVER HOP again"
end

--==================================================
-- BUTTON
--==================================================

hop.MouseButton1Click:Connect(function()

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

local function addHover(button, normalColor, hoverColor)

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
-- PLAYER ADDED
--==================================================

Players.PlayerAdded:Connect(function(plr)

	task.wait(1)

	if not hopping and not teleporting then

		local safe, badPlayer, badType =
			updateCurrentServer()

		if not safe then

			if badType == "ACCOUNT" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is under "
					.. MIN_ACCOUNT_AGE
					.. " days"

			elseif badType == "NOOB" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is a NOOB avatar"

			elseif badType == "BACON" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is a BACON avatar"

			end

			accountStatus.Text = "REJECTED"
			accountStatus.TextColor3 =
				Color3.fromRGB(255, 100, 100)

		end

	end

end)

--==================================================
-- PLAYER REMOVING
--==================================================

Players.PlayerRemoving:Connect(function()

	task.wait(0.2)

	if not hopping and not teleporting then

		updateCurrentServer()

	end

end)

--==================================================
-- CHARACTER APPEARANCE LOADED
--==================================================

local function monitorPlayer(plr)

	if plr == player then
		return
	end

	plr.CharacterAppearanceLoaded:Connect(function()

		task.wait(0.5)

		if hopping or teleporting then
			return
		end

		local safe, badPlayer, badType =
			updateCurrentServer()

		if not safe then

			if badType == "NOOB" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is a NOOB avatar"

			elseif badType == "BACON" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is a BACON avatar"

			elseif badType == "ACCOUNT" then

				status.Text =
					"● "
					.. badPlayer.Name
					.. " is under "
					.. MIN_ACCOUNT_AGE
					.. " days"

			end

			accountStatus.Text = "REJECTED"
			accountStatus.TextColor3 =
				Color3.fromRGB(255, 100, 100)

		end

	end)

end

for _, plr in ipairs(Players:GetPlayers()) do
	monitorPlayer(plr)
end

Players.PlayerAdded:Connect(function(plr)
	monitorPlayer(plr)
end)

--==================================================
-- INITIAL CHECK
--==================================================

task.spawn(function()

	task.wait(3)

	if hopping or teleporting then
		return
	end

	local safe, badPlayer, badType =
		updateCurrentServer()

	if not safe then

		if badType == "ACCOUNT" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is under "
				.. MIN_ACCOUNT_AGE
				.. " days"

		elseif badType == "NOOB" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is a NOOB avatar"

		elseif badType == "BACON" then

			status.Text =
				"● "
				.. badPlayer.Name
				.. " is a BACON avatar"

		end

		accountStatus.Text = "REJECTED"
		accountStatus.TextColor3 =
			Color3.fromRGB(255, 100, 100)

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
print("Minimum account age: " .. MIN_ACCOUNT_AGE .. " days")
print("Bacon checker: " .. tostring(ENABLE_AVATAR_CHECK))
print("Noob checker: " .. tostring(REJECT_NOOB))
print("Auto retry after teleport failure: DISABLED")
