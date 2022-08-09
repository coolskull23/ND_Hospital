NDCore = exports["ND_Core"]:GetCoreObject()
NDCore.Functions.VersionChecker("ND_Hospital", GetCurrentResourceName(), "https://github.com/Andyyy7666/ND_Framework", "")

local hospitaledPlayer = {}

-- Get player any identifier, available types: steam, license, xbl, ip, discord, live.
function GetPlayerIdentifierFromType(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

-- send discord embed with webhook.
function sendToDiscord(name, message, color)
    local embed = {
        {
            title = name,
            description = message,
            footer = {
                icon_url = "https://i.imgur.com/notBtrZ.png",
                text = "Created by Andyyy#7666"
            },
            color = color
        }
    }
    PerformHttpRequest(server_config.discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "ND Hospitalize", embeds = embed}), {["Content-Type"] = "application/json"})
end

-- Hospitalize player discord log, trigger the even on the players client and send a message to everyone.
RegisterNetEvent("ND_Hospitalize:hospitalPlayer")
AddEventHandler("ND_Hospitalize:hospitalPlayer", function(id, time, fine, reason)
    local player = source
    local players = NDCore.Functions.GetPlayers()
    local dept = players[player].job
    for _, department in pairs(config.accessDepartments) do
        if department == dept then
            hospitaledPlayer[GetPlayerIdentifierFromType("license", id)] = time
            NDCore.Functions.DeductMoney(fine, id, "bank")
            TriggerClientEvent("ND_Hospitalize:hospitalPlayer", id, time)
            sendToDiscord("Hospital Logs", "**" .. GetPlayerName(player) .. "** Hospitalize **" .. GetPlayerName(id) .. "** for **" .. time .. " seconds** with the reason: **" .. reason .. "**.", 1595381)
            TriggerClientEvent('chat:addMessage', -1, {
                color = { 255, 0, 0},
                multiline = true,
                args = {"[Doctor]", GetPlayerName(id) .. " was charaged with " .. reason .. " and will be spending " .. time .. " months in hospital."}
            })
            break
        end
    end
end)

RegisterNetEvent("ND_Hospitalize:updateHospitalize")
AddEventHandler("ND_Hospitalize:updateHospitalize", function(time)
    local player = source
    if time == 0 then
        hospitaledPlayer[GetPlayerIdentifierFromType("license", player)] = nil
    else
        hospitaledPlayer[GetPlayerIdentifierFromType("license", player)] = time
    end
end)

-- Gets all players on the server and adds them to a table.
RegisterNetEvent("ND_Hospitalize:getPlayers")
AddEventHandler("ND_Hospitalize:getPlayers", function()
    local players = {}
    for _, id in pairs(GetPlayers()) do
        players[id] = "(" .. id .. ") " .. GetPlayerName(id)
    end
    TriggerClientEvent("ND_Hospitalize:returnPlayers", source, players)
end)

RegisterNetEvent("ND_Hospitalize:getHospitalTime")
AddEventHandler("ND_Hospitalize:getHospitalTime", function()
    local player = source
    local time = hospitaledPlayer[GetPlayerIdentifierFromType("license", player)]
    if time then
        TriggerClientEvent("ND_Hospitalize:hospitalPlayer", player, time)
    end
end)
