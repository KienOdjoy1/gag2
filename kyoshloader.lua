--//============================================================//
--// 🛡️ KYOSH UNIVERSAL SECURE LOADER
--//============================================================//

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local RequestFunction =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

if not RequestFunction then
    error("❌ HTTP request function unavailable.")
end

--------------------------------------------------
--// GAME CONFIG
--------------------------------------------------

local GAME_SCRIPTS = {

    --// STEAL AN EGG
    [107778070777162] = {
        Name = "Steal an Egg",
        Endpoint = "https://YOUR-DOMAIN/api/steal-an-egg"
    },

    --// GROW A GARDEN 2
    --// Replace this with the actual PlaceId
    [1234567890] = {
        Name = "Grow a Garden 2",
        Endpoint = "https://YOUR-DOMAIN/api/grow-a-garden"
    }

}

--------------------------------------------------
--// DETECT CURRENT GAME
--------------------------------------------------

local PlaceId = game.PlaceId
local GameInfo = GAME_SCRIPTS[PlaceId]

if not GameInfo then
    error(
        "❌ Unsupported game\nPlaceId: "
        .. tostring(PlaceId)
    )
end

print(
    "🎮 Game detected:",
    GameInfo.Name
)

--------------------------------------------------
--// REQUEST CORRECT SCRIPT
--------------------------------------------------

local Success, Response = pcall(function()

    return RequestFunction({

        Url = GameInfo.Endpoint,

        Method = "GET",

        Headers = {

            ["Content-Type"] = "application/json",

            ["X-Kyosh-Version"] = "1.0",

            ["X-Kyosh-Game"] =
                tostring(PlaceId)

        }

    })

end)

if not Success then

    error(
        "❌ Failed to contact KYOSH security server."
    )

end

--------------------------------------------------
--// STATUS
--------------------------------------------------

local StatusCode =
    Response.StatusCode
    or Response.Status
    or Response.status

if StatusCode ~= 200 then

    error(
        "❌ Access denied for "
        .. GameInfo.Name
    )

end

--------------------------------------------------
--// GET SCRIPT
--------------------------------------------------

local Script =
    Response.Body
    or Response.body

if not Script or Script == "" then

    error(
        "❌ Empty script received."
    )

end

--------------------------------------------------
--// EXECUTE
--------------------------------------------------

local Function, ErrorMessage =
    loadstring(Script)

if not Function then

    error(
        "❌ Script compilation failed:\n"
        .. tostring(ErrorMessage)
    )

end

print(
    "✅ Loading:",
    GameInfo.Name
)

Function()
