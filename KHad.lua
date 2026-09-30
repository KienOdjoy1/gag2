--============================================================
-- 🎲 KYOSH // ANIME DICE INVENTORY HEARTBEAT
-- CLIENT SIDE
--
-- Reads:
-- DataController.Inventory
--
-- Converts:
-- Unit  -> Units
-- Gear  -> Gear
-- Other -> Items
--
-- Then sends the data to the server through a RemoteEvent.
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================

local HEARTBEAT_INTERVAL = 5

-- RemoteEvent created in ReplicatedStorage
local HeartbeatEvent = ReplicatedStorage:WaitForChild(
	"AnimeDiceHeartbeat",
	30
)

if not HeartbeatEvent then
	warn("[KYOSH] AnimeDiceHeartbeat RemoteEvent was not found.")
	return
end

--============================================================
-- LOAD GAME MODULES
--============================================================

local Framework = ReplicatedStorage:WaitForChild("Framework")

local InventoryFolder =
	Framework:WaitForChild("Features")
	:WaitForChild("Inventory")

local DataFolder =
	Framework:WaitForChild("Features")
	:WaitForChild("Data")

local EntryRegistry =
	require(InventoryFolder:WaitForChild("EntryRegistry"))

local DataController =
	require(DataFolder:WaitForChild("DataController"))

--============================================================
-- SAFE COPY
--============================================================

local function safeValue(value)
	if value == nil then
		return nil
	end

	local valueType = typeof(value)

	if valueType == "string"
		or valueType == "number"
		or valueType == "boolean" then

		return value
	end

	return tostring(value)
end

--============================================================
-- COPY ATTRIBUTES
--============================================================

local function copyAttributes(attributes)
	local result = {}

	if typeof(attributes) ~= "table" then
		return result
	end

	for key, value in pairs(attributes) do
		local valueType = typeof(value)

		if valueType == "string"
			or valueType == "number"
			or valueType == "boolean" then

			result[tostring(key)] = value

		elseif valueType == "table" then
			-- Keep simple nested tables where possible.
			local nested = {}

			for nestedKey, nestedValue in pairs(value) do
				local nestedType = typeof(nestedValue)

				if nestedType == "string"
					or nestedType == "number"
					or nestedType == "boolean" then

					nested[tostring(nestedKey)] = nestedValue
				end
			end

			result[tostring(key)] = nested
		end
	end

	return result
end

--============================================================
-- GET ENTRY KIND
--============================================================

local function getEntryKind(entryName)
	if not entryName then
		return nil
	end

	local config = EntryRegistry.getEntryConfig(entryName)

	if not config then
		return nil
	end

	return config.kind
end

--============================================================
-- SERIALIZE ONE INVENTORY ENTRY
--============================================================

local function serializeEntry(entryKey, entry)
	if typeof(entry) ~= "table" then
		return nil
	end

	local name = entry.name

	if not name then
		return nil
	end

	local kind = getEntryKind(name)

	local amount = tonumber(entry.amount) or 1

	local result = {
		key = tostring(entryKey),
		name = tostring(name),
		amount = amount,
		attributes = copyAttributes(entry.attributes),
	}

	-- Keep the actual internal kind.
	if kind then
		result.kind = tostring(kind)
	end

	-- Optional config information.
	local config = EntryRegistry.getEntryConfig(name)

	if config then
		if config.rarity ~= nil then
			result.rarity = safeValue(config.rarity)
		end

		if config.slot ~= nil then
			result.slot = safeValue(config.slot)
		end

		if config.description ~= nil then
			result.description = safeValue(config.description)
		end
	end

	return result, kind
end

--============================================================
-- BUILD INVENTORY
--============================================================

local function collectInventory()
	local inventory = {
		units = {},
		gear = {},
		items = {}
	}

	local source = DataController.Inventory

	if not source then
		return inventory
	end

	-- DataController.Inventory is a reactive/state table.
	-- Use pairs to read its current contents.
	for key, entryObject in pairs(source) do

		local entry

		-- In EntryIcon.new(), the game accesses:
		-- DataController.Inventory[p1.key]()
		--
		-- So inventory entries are callable state objects.
		if typeof(entryObject) == "function" then
			local success, result = pcall(entryObject)

			if success then
				entry = result
			end
		else
			entry = entryObject
		end

		if entry then
			local serialized, kind =
				serializeEntry(key, entry)

			if serialized then

				if kind == "Unit" then

					table.insert(
						inventory.units,
						serialized
					)

				elseif kind == "Gear" then

					table.insert(
						inventory.gear,
						serialized
					)

				else

					-- Boost
					-- Token
					-- Spin
					-- Any other non-unit/non-gear item
					table.insert(
						inventory.items,
						serialized
					)

				end
			end
		end
	end

	return inventory
end

--============================================================
-- SEND HEARTBEAT
--============================================================

local function sendHeartbeat()

	local inventory = collectInventory()

	local payload = {
		userId = tostring(Player.UserId),

		playerName = Player.Name,

		displayName = Player.DisplayName,

		inventory = inventory
	}

	HeartbeatEvent:FireServer(payload)

	print(
		"[KYOSH] Anime Dice heartbeat:",
		"Units =", #inventory.units,
		"Gear =", #inventory.gear,
		"Items =", #inventory.items
	)
end

--============================================================
-- INITIAL WAIT
--============================================================

task.wait(5)

--============================================================
-- HEARTBEAT LOOP
--============================================================

while Player.Parent do

	local success, errorMessage = pcall(
		sendHeartbeat
	)

	if not success then
		warn(
			"[KYOSH] Heartbeat error:",
			errorMessage
		)
	end

	task.wait(HEARTBEAT_INTERVAL)
end
