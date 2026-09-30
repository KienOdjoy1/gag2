--//============================================================//
--// KYOSH // ANIME DICE INVENTORY MONITOR
--// EXECUTOR VERSION
--//============================================================//

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local URL = "https://inventory-ad.onrender.com/heartbeat"
local API_KEY = "KYOSH-12162006"

local INTERVAL = 5

--//============================================================//
--// PLAYER GUI
--//============================================================//

local playerGui = player:WaitForChild("PlayerGui")

local backpack =
    playerGui
        :WaitForChild("Root")
        :WaitForChild("Menus")
        :WaitForChild("Backpack")

local tooltipGui =
    playerGui:FindFirstChild("Tooltips")

--//============================================================//
--// HTTP REQUEST
--//============================================================//

local req =
    request
    or http_request
    or (syn and syn.request)

if not req then
    warn("[KYOSH] HTTP request function not found.")
    return
end

--//============================================================//
--// TEXT HELPERS
--//============================================================//

local function clean(text)
    return tostring(text or "")
        :gsub("<[^>]->", "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")
end

local function isAmount(text)
    return text:match("^x%d+$") ~= nil
end

local function isIncome(text)
    return text:match("^%$[%d%.,]+/s$") ~= nil
end

local function isChance(text)
    return text:match("^1%s+in%s+[%d%.]+[%a]*$") ~= nil
end

local function isLevel(text)
    return text:match("^Level%s+%d+$") ~= nil
end

local function isRarity(text)

    local rarities = {
        Common = true,
        Uncommon = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Secret = true,
        Divine = true,
        Celestial = true
    }

    return rarities[text] == true
end

--//============================================================//
--// THINGS THAT ARE NOT ITEM / UNIT NAMES
--//============================================================//

local ignored = {

    Equip = true,
    Cancel = true,
    Confirm = true,
    Close = true,

    Lock = true,
    Locked = true,
    Unlock = true,

    Sell = true,
    Delete = true,
    Favorite = true,
    Unequip = true,
    Use = true,

    Title = true,

    Head = true,
    Torso = true,
    Back = true,
    Upper = true,
    Waist = true,
    Arms = true,
    Legs = true,

    ["You don't own any gear for this slot yet."] = true
}

local function isBadName(text)

    if text == "" then
        return true
    end

    if ignored[text] then
        return true
    end

    if isAmount(text) then
        return true
    end

    if isIncome(text) then
        return true
    end

    if isChance(text) then
        return true
    end

    if isLevel(text) then
        return true
    end

    if isRarity(text) then
        return true
    end

    return false
end

--//============================================================//
--// READ CURRENT TOOLTIP
--//============================================================//

local function readTooltip()

    if not tooltipGui then
        return nil
    end

    local data = {
        name = nil,
        rarity = nil,
        level = nil,
        income = nil,
        chance = nil,
        grade = nil,
        trait = nil,
        description = nil,
        category = nil
    }

    local texts = {}

    for _, obj in ipairs(tooltipGui:GetDescendants()) do

        if (
            obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox")
        )
        and obj.Visible
        then

            local text = clean(obj.Text)

            if text ~= "" then
                table.insert(texts, text)
            end
        end
    end

    for _, text in ipairs(texts) do

        --======================================================//
        -- CHANCE
        --======================================================//

        if text:match("^1%s+in%s+[%d%.]+[%a]*$") then

            data.chance = text

        --======================================================//
        -- MONEY / INCOME
        --======================================================//

        elseif text:match("^%$[%d%.,]+/s$") then

            data.income = text

        --======================================================//
        -- LEVEL
        --======================================================//

        elseif text:match("^Level%s+%d+$") then

            data.level =
                text:match("^Level%s+(%d+)$")

        --======================================================//
        -- RARITY
        --======================================================//

        elseif
            text == "Common"
            or text == "Uncommon"
            or text == "Rare"
            or text == "Epic"
            or text == "Legendary"
            or text == "Mythic"
            or text == "Secret"
            or text == "Divine"
            or text == "Celestial"
        then

            data.rarity = text

        --======================================================//
        -- GRADE
        --======================================================//

        elseif text:match("^Grade%s*[:%-]?%s*.+$") then

            data.grade = text

        --======================================================//
        -- TRAIT
        --======================================================//

        elseif text:match("^Trait%s*[:%-]?%s*.+$") then

            data.trait = text

        --======================================================//
        -- DESCRIPTION
        --======================================================//

        elseif text:match("^Description%s*[:%-]?%s*.+$") then

            data.description = text

        --======================================================//
        -- NAME
        --======================================================//

        elseif
            not data.name
            and not isBadName(text)
        then

            data.name = text
        end
    end

    return data
end

--//============================================================//
--// OPEN TOOLTIP
--//============================================================//

local function openTooltip(card)

    if typeof(firesignal) ~= "function" then
        return nil
    end

    -- First attempt
    pcall(function()
        firesignal(card.MouseEnter)
    end)

    task.wait(0.15)

    local data = readTooltip()

    pcall(function()
        firesignal(card.MouseLeave)
    end)

    task.wait(0.05)

    return data
end

--//============================================================//
--// OPEN TOOLTIP WITH RETRIES
--//============================================================//

local function openTooltipRetry(card, attempts)

    attempts = attempts or 3

    for i = 1, attempts do

        local data = openTooltip(card)

        if data and data.name then
            return data
        end

        task.wait(0.08)
    end

    return nil
end

--//============================================================//
--// GET AMOUNT
--//============================================================//

local function getAmount(card)

    local amount = 1

    for _, obj in ipairs(card:GetDescendants()) do

        if
            obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox")
        then

            local text = clean(obj.Text)

            local n =
                text:match("^x(%d+)$")

            if n then
                amount = tonumber(n) or 1
            end
        end
    end

    return amount
end

--//============================================================//
--// GET ALL POSSIBLE TOOLTIP TARGETS FROM CARD
--//============================================================//

local function getTooltipTargets(card)

    local targets = {}
    local seen = {}

    local function addTarget(obj)

        if not obj then
            return
        end

        if seen[obj] then
            return
        end

        seen[obj] = true

        if
            obj:IsA("GuiButton")
            or obj:IsA("ImageButton")
            or obj:IsA("TextButton")
        then
            table.insert(targets, obj)
        end
    end

    -- Try the card itself first
    addTarget(card)

    -- Then children
    for _, obj in ipairs(card:GetDescendants()) do
        addTarget(obj)
    end

    return targets
end

--//============================================================//
--// READ TOOLTIP FROM CARD
--//============================================================//

local function readCardTooltip(card)

    -- Try card itself
    local info =
        openTooltipRetry(card, 3)

    if info and info.name then
        return info
    end

    -- Try buttons inside card
    local targets =
        getTooltipTargets(card)

    for _, target in ipairs(targets) do

        info =
            openTooltipRetry(target, 2)

        if info and info.name then
            return info
        end
    end

    return nil
end

--//============================================================//
--// READ UNITS
--//============================================================//

local function readUnits()

    local result = {}

    local category =
        backpack:FindFirstChild("Units")

    if not category then
        warn("[KYOSH] Units category not found")
        return result
    end

    local scrolling =
        category:FindFirstChild("ScrollingFrame")
        or category

    for _, card in ipairs(scrolling:GetChildren()) do

        if card:IsA("GuiObject") then

            local amount =
                getAmount(card)

            local info =
                readCardTooltip(card)

            if info and info.name then

                table.insert(result, {

                    name = info.name,

                    amount = amount,

                    rarity =
                        info.rarity or "",

                    level =
                        info.level or "",

                    income =
                        info.income or "",

                    chance =
                        info.chance or "",

                    grade =
                        info.grade or "",

                    trait =
                        info.trait or ""
                })

                print(
                    "[KYOSH][UNIT]",
                    info.name,
                    "x" .. tostring(amount),
                    info.rarity or "",
                    info.income or "",
                    info.chance or "",
                    info.grade or "",
                    info.trait or ""
                )
            end
        end
    end

    print(
        "[KYOSH] Units found:",
        #result
    )

    return result
end

--//============================================================//
--// READ GEAR
--//============================================================//

local function readGear()

    local result = {}

    local category =
        backpack:FindFirstChild("Gear")

    if not category then
        warn("[KYOSH] Gear category not found")
        return result
    end

    local scrolling =
        category:FindFirstChild("ScrollingFrame", true)

    -- The Gear page can contain equipment slots.
    -- Do NOT read those slot placeholders as owned gear.

    if not scrolling then
        print(
            "[KYOSH] Gear ScrollingFrame not found."
        )

        return result
    end

    for _, card in ipairs(scrolling:GetChildren()) do

        if card:IsA("GuiObject") then

            local amount =
                getAmount(card)

            local info =
                readCardTooltip(card)

            if info and info.name then

                if
                    not isBadName(info.name)
                    and info.name
                        ~= "You don't own any gear for this slot yet."
                then

                    table.insert(result, {

                        name = info.name,

                        amount = amount,

                        rarity =
                            info.rarity or ""
                    })

                    print(
                        "[KYOSH][GEAR]",
                        info.name,
                        "x" .. tostring(amount),
                        info.rarity or ""
                    )
                end
            end
        end
    end

    print(
        "[KYOSH] Gear found:",
        #result
    )

    return result
end

--//============================================================//
--// READ ITEMS - FIXED
--//============================================================//

local function readItems()

    local result = {}

    local category =
        backpack:FindFirstChild("Items")

    if not category then
        warn("[KYOSH] Items category not found")
        return result
    end

    local scrolling =
        category:FindFirstChild("ScrollingFrame", true)
        or category

    print(
        "[KYOSH] Reading Items from:",
        scrolling:GetFullName()
    )

    --==========================================================//
    -- IMPORTANT:
    -- Anime Dice Items are normally direct children of the
    -- ScrollingFrame. We check those first.
    --==========================================================//

    local cards = {}

    for _, child in ipairs(scrolling:GetChildren()) do

        if child:IsA("GuiObject") then

            if
                not child:IsA("UIListLayout")
                and not child:IsA("UIGridLayout")
                and not child:IsA("UIPadding")
                and child.Visible
            then

                table.insert(cards, child)
            end
        end
    end

    print(
        "[KYOSH] Item cards detected:",
        #cards
    )

    --==========================================================//
    -- READ EACH CARD
    --==========================================================//

    for index, card in ipairs(cards) do

        local amount =
            getAmount(card)

        print(
            "[KYOSH] Checking item card:",
            index,
            card.Name,
            "amount:",
            amount
        )

        local info =
            readCardTooltip(card)

        --======================================================//
        -- IF TOOLTIP FAILED, TRY AGAIN
        --======================================================//

        if not info or not info.name then

            task.wait(0.15)

            info =
                readCardTooltip(card)
        end

        --======================================================//
        -- SUCCESS
        --======================================================//

        if info and info.name then

            if not isBadName(info.name) then

                local item = {

                    name = info.name,

                    amount = amount,

                    rarity =
                        info.rarity or "",

                    description =
                        info.description or "",

                    category =
                        info.category or ""
                }

                table.insert(
                    result,
                    item
                )

                print(
                    "[KYOSH][ITEM FOUND]",
                    item.name,
                    "x" .. tostring(item.amount)
                )
            end

        else

            warn(
                "[KYOSH][ITEM FAILED]",
                card.Name,
                "- tooltip name could not be read"
            )
        end
    end

    print(
        "[KYOSH] Items found:",
        #result
    )

    return result
end

--//============================================================//
--// REMOVE DUPLICATES
--//============================================================//

local function unique(list)

    local result = {}
    local seen = {}

    for _, item in ipairs(list) do

        local key =
            tostring(item.name or "")
            .. "|"
            .. tostring(item.amount or 1)
            .. "|"
            .. tostring(item.rarity or "")

        if not seen[key] then

            seen[key] = true

            table.insert(
                result,
                item
            )
        end
    end

    return result
end

--//============================================================//
--// SEND TO FLASK
--//============================================================//

local function send()

    print("")
    print("==============================================")
    print("[KYOSH] SCANNING ANIME DICE INVENTORY")
    print("==============================================")

    local inventory = {

        units =
            unique(
                readUnits()
            ),

        gear =
            unique(
                readGear()
            ),

        items =
            unique(
                readItems()
            )
    }

    print("")
    print("==============================================")
    print("[KYOSH] FINAL INVENTORY")
    print("==============================================")

    print(
        "Units:",
        #inventory.units
    )

    print(
        "Gear:",
        #inventory.gear
    )

    print(
        "Items:",
        #inventory.items
    )

    print("==============================================")

    --==========================================================//
    -- DEBUG UNITS
    --==========================================================//

    for _, item in ipairs(inventory.units) do

        print(
            "[UNIT]",
            item.name,
            "x" .. tostring(item.amount),

            item.rarity ~= ""
                and ("| Rarity: " .. item.rarity)
                or "",

            item.level ~= ""
                and ("| Level: " .. item.level)
                or "",

            item.income ~= ""
                and ("| Income: " .. item.income)
                or "",

            item.chance ~= ""
                and ("| Chance: " .. item.chance)
                or "",

            item.grade ~= ""
                and ("| Grade: " .. item.grade)
                or "",

            item.trait ~= ""
                and ("| Trait: " .. item.trait)
                or ""
        )
    end

    --==========================================================//
    -- DEBUG GEAR
    --==========================================================//

    for _, item in ipairs(inventory.gear) do

        print(
            "[GEAR]",
            item.name,
            "x" .. tostring(item.amount),

            item.rarity ~= ""
                and ("| Rarity: " .. item.rarity)
                or ""
        )
    end

    --==========================================================//
    -- DEBUG ITEMS
    --==========================================================//

    for _, item in ipairs(inventory.items) do

        print(
            "[ITEM]",
            item.name,
            "x" .. tostring(item.amount)
        )
    end

    --==========================================================//
    -- CREATE REQUEST
    --==========================================================//

    local data = {

        userId =
            tostring(player.UserId),

        playerName =
            player.Name,

        displayName =
            player.DisplayName,

        inventory =
            inventory
    }

    local body =
        HttpService:JSONEncode(data)

    --==========================================================//
    -- SEND REQUEST
    --==========================================================//

    local ok, response =
        pcall(function()

            return req({

                Url = URL,

                Method = "POST",

                Headers = {

                    ["Content-Type"] =
                        "application/json",

                    ["X-API-Key"] =
                        API_KEY
                },

                Body = body
            })

        end)

    if not ok then

        warn(
            "[KYOSH] Send failed:",
            response
        )

        return
    end

    print("")
    print(
        "[KYOSH] STATUS:",
        response and response.StatusCode
    )

    if response and response.Body then

        print(
            "[KYOSH] BODY:",
            response.Body
        )
    end

    print("")
end

--//============================================================//
--// START
--//============================================================//

print("==============================================")
print("[KYOSH] ANIME DICE MONITOR STARTED")
print("==============================================")

print(
    "[KYOSH] Player:",
    player.Name
)

print(
    "[KYOSH] UserId:",
    player.UserId
)

print(
    "[KYOSH] Backpack:",
    backpack:GetFullName()
)

print(
    "[KYOSH] Tooltip:",
    tooltipGui
        and tooltipGui:GetFullName()
        or "NOT FOUND"
)

print("==============================================")

task.wait(2)

--//============================================================//
--// LOOP
--//============================================================//

while true do

    local ok, err =
        pcall(send)

    if not ok then

        warn(
            "[KYOSH] Scan error:",
            err
        )
    end

    task.wait(INTERVAL)
end
