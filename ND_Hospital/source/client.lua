local display = false
local nearHospitalizeUi = false
local hospitalTime = 0
local ped
NDCore = exports["ND_Core"]:GetCoreObject()

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

function text(text, x, y, scale)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
    SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function drawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 0.3)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function hasAccess()
    local job = NDCore.Functions.GetSelectedCharacter().job
    for _, department in pairs(config.accessDepartments) do
        if department == job then
            return true
        end
    end
    return false
end

function inRange(ped)
    local pedCoords = GetEntityCoords(ped)
    for locations in pairs(config.accessLocation) do
        local uiCoords = vector3(config.accessLocation[locations].x, config.accessLocation[locations].y, config.accessLocation[locations].z)
        if (#(pedCoords - uiCoords)) < config.accessDistance then
            if hasAccess() then
                return uiCoords
            end
        end
    end
    return false
end

local tablet = false
function ToggleTablet(toggle)
    if toggle and not tablet then
        tablet = true
        Citizen.CreateThread(function()
            RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
            while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
                Citizen.Wait(150)
            end
            RequestModel(`prop_cs_tablet`)
            while not HasModelLoaded(`prop_cs_tablet`) do
                Citizen.Wait(150)
            end
            local playerPed = PlayerPedId()
            local tabletObj = CreateObject(`prop_cs_tablet`, 0.0, 0.0, 0.0, true, true, false)
            local tabletBoneIndex = GetPedBoneIndex(playerPed, 60309)
            SetCurrentPedWeapon(playerPed, `weapon_unarmed`, true)
            AttachEntityToEntity(tabletObj, playerPed, tabletBoneIndex, 0.03, 0.002, -0.0, 10.0, 160.0, 0.0, true, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(`prop_cs_tablet`)
            while tablet do
                Citizen.Wait(100)
                playerPed = PlayerPedId()

                if not IsEntityPlayingAnim(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3) then
                    TaskPlayAnim(playerPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
                end
            end
            ClearPedSecondaryTask(playerPed)
            Citizen.Wait(450)
            DetachEntity(tabletObj, true, false)
            DeleteEntity(tabletObj)
        end)
    elseif not toggle and tablet then
        tablet = false
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
        ped = PlayerPedId()
        nearHospitalizeUi = inRange(ped)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not display and nearHospitalizeUi then
            drawText3D(nearHospitalizeUi, "~w~Press ~b~E ~w~to open the hospital ui")
            if IsControlJustPressed(0, 51) then
                TriggerServerEvent("ND_Hospitalize:getPlayers")
            end
        end
    end
end)

-- Return list of all players on the server and open ui.
RegisterNetEvent("ND_Hospitalize:returnPlayers")
AddEventHandler("ND_Hospitalize:returnPlayers", function(players)
    for _, player in pairs(players) do
        SendNUIMessage({
            type = "players",
            players = player,
        })
    end
    SetDisplay(true)
    ToggleTablet(display)
end)

AddEventHandler("playerSpawned", function()
    TriggerServerEvent("ND_Hospitalize:getHospitalTime")
end)

function hospital(time)
    local player = PlayerPedId()
    local pedCoords = GetEntityCoords(player)
    hospitalTime = time
    SetEntityCoords(player, config.hospitalCoords.x, config.hospitalCoords.y, config.hospitalCoords.z, false, false, false, false)
    SetEntityHeading(player, config.hospitalCoords.h)
    TriggerEvent("ND_Hospitalize:timeLeft")
    TriggerServerEvent("ND_Hospitalize:updateHospitalize", hospitalTime)

    while hospitalTime > 0 do
        hospitalTime = hospitalTime -1
        player = PlayerPedId()
        if #(GetEntityCoords(player) - vector3(config.hospitalCoords.x, config.hospitalCoords.y, config.hospitalCoords.z)) > config.hospitalDistance then
            SetEntityCoords(player, config.hospitalCoords.x, config.hospitalCoords.y, config.hospitalCoords.z, false, false, false, false)
        end
        Citizen.Wait(1000)
    end
    SetEntityCoords(player, config.releaseCoords.x, config.releaseCoords.y, config.releaseCoords.z, false, false, false, false)
    SetEntityHeading(player, config.releaseCoords.h)
    TriggerServerEvent("ND_Hospitalize:updateHospitalize", hospitalTime)
end

RegisterNetEvent("ND_Hospitalize:timeLeft")
AddEventHandler("ND_Hospitalize:timeLeft", function()
    while hospitalTime > 0 do
        Citizen.Wait(0)
        text("Time until release: " .. tostring(hospitalTime), 0.5, 0.9, 0.5)
    end
end)

-- hospitalize a player and loop to keep them in hospital every second.
RegisterNetEvent("ND_Hospitalize:hospitalPlayer")
AddEventHandler("ND_Hospitalize:hospitalPlayer", function(time)
    hospital(time)
end)

RegisterNetEvent("ND_Hospitalize:unhospitalPlayer")
AddEventHandler("ND_Hospitalize:unhospitalPlayer", function(time)
    hospitalTime = 0
end)

-- Chat suggestion for command.
TriggerEvent("chat:addSuggestion", "/hospitalize", "Hospitalize a player", {
    {name="Id", help="Player Id"},
    {name="Time", help="Time to hospital (seconds)"},
    {name="Fine", help="How much will the player be fined?"},
    {name="Reason", help="Short description of the charge."}
})

-- Same hospital function but with a command.
RegisterCommand("hospitalize", function(source, args, rawCommand)
    local id = tonumber(args[1])
    local time = tonumber(args[2])
    local fine = args[3]
    local reason = args[4]
    if hasAccess() then
        if not GetPlayerFromServerId(id) then
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0},
                multiline = true,
                args = {"[Error]", "couldn't find a player with id " .. id .. "."}
            })
        elseif time > config.maxHospitalTime then
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0},
                multiline = true,
                args = {"[Error]", "max time to hospital is: " .. config.maxHospitalTime .. " seconds."}
            })
        elseif time <= config.maxHospitalTime then
            TriggerServerEvent("ND_Hospitalize:hospitalPlayer", id, time, fine, reason)
            SetDisplay(false)
        end
    else
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Error]", "You don't have permission to use this command."}
        })
    end
end, false)

-- When form is submitted.
RegisterNUICallback("sumbit", function(data)
    local id = tonumber(string.sub(data.id, 2, string.find(data.id, ")") - 1))
    local time = tonumber(data.time)
    local fine = data.fine
    local reason = data.reason
    if time > config.maxHospitalTime then
        SendNUIMessage({
            error = "Error: max time to hospital is: " .. config.maxHospitalTime .. " seconds."
        })
        Citizen.Wait(5000)
        SendNUIMessage({
            error = ""
        })
    else
        TriggerServerEvent("ND_Hospitalize:hospitalPlayer", id, time, fine, reason)
        SendNUIMessage({
            type = "clean"
        })
        SetDisplay(false)
        ToggleTablet(display)
    end
end)

-- Close ui.
RegisterNUICallback("close", function(data)
    SetDisplay(false)
    ToggleTablet(display)
end)