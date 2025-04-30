-- client/medical.lua
local lib    = exports.ox_lib

local sharedConfig = require 'config.shared'

-- Place Medic Bag & register ox_target
RegisterNetEvent('prp-amb:PlaceMedicBag', function()
    local ped, c = PlayerPedId(), GetEntityCoords(PlayerPedId())
    RequestModel(`prop_amb_bag_med_01`)
    while not HasModelLoaded(`prop_amb_bag_med_01`) do Wait(10) end

    local bag = CreateObject(`prop_amb_bag_med_01`, c.x, c.y, c.z - 1.0, true, true, true)
    PlaceObjectOnGroundProperly(bag); FreezeEntityPosition(bag, true)

    exports.ox_target:addEntity(bag, {{
        name        = 'inspect_patient',
        icon        = 'fas fa-user-md',
        label       = 'Inspect Patient',
        onSelect    = function()
            local tgt, dist = lib.getClosestPlayer()
            if tgt ~= -1 and dist < sharedConfig.MaxInspectDistance then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'open', target = GetPlayerServerId(tgt) })
            else
                lib.notify({ type = 'error', description = 'No patient nearby' })
            end
        end,
        canInteract = function()
            return QBX.PlayerData.job.name == 'ambulance'
        end
    }})
end)

-- Place Defibrillator & register ox_target
RegisterNetEvent('prp-amb:PlaceDefib', function()
    local ped, c = PlayerPedId(), GetEntityCoords(PlayerPedId())
    RequestModel(sharedConfig.defibrillator)  -- store model in cfg if desired
    while not HasModelLoaded(sharedConfig.defibrillator) do Wait(10) end

    local defib = CreateObject(sharedConfig.defibrillator, c.x, c.y, c.z - 1.0, true, true, true)
    PlaceObjectOnGroundProperly(defib); FreezeEntityPosition(defib, true)

    exports.ox_target:addEntity(defib, {{
        name        = 'use_defibrillator',
        icon        = 'fas fa-bolt',
        label       = 'Use Defibrillator',
        onSelect    = function()
            local tgt, dist = lib.getClosestPlayer()
            if tgt ~= -1 and dist < sharedConfig.MaxInspectDistance then
                -- apply "heart" injury part with defib
                TriggerServerEvent('prp-amb:applyItem', GetPlayerServerId(tgt), 'heart', 'defibrillator')
            else
                lib.notify({ type = 'error', description = 'No patient nearby' })
            end
        end,
        canInteract = function()
            return QBX.PlayerData.job.name == 'ambulance'
        end
    }})
end)

-- Receive healPart from server
RegisterNetEvent('prp-amb:healPart', function(target, part, item)
    local ped = GetPlayerPed(GetPlayerFromServerId(target))
    if item == 'tourniquet' then
        ClearPedBloodDamage(ped)
    elseif item == 'defibrillator' and GetEntityHealth(ped) <= 100 then
        local loc = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(loc, GetEntityHeading(ped), true, true, false, false)
        SetEntityHealth(ped, 200)
    end
    -- add other item effects as needed...
end)

-- Quick‐action feedback
RegisterNetEvent('prp-amb:showPulse', function()
    lib.notify({ type = 'inform', description = 'Pulse: ' .. (GetEntityHealth(PlayerPedId()) > 100 and 'Present' or 'None') })
end)
RegisterNetEvent('prp-amb:showConsciousness', function()
    lib.notify({ type = 'inform', description = IsPedInjured(PlayerPedId()) and 'Unconscious' or 'Conscious' })
end)
RegisterNetEvent('prp-amb:showTemperature', function()
    lib.notify({ type = 'inform', description = 'Body Temp: Normal' })
end)

-- NUI callbacks → forward to server
RegisterNUICallback('applyItem', function(data, cb)
    TriggerServerEvent('prp-amb:applyItem', data.target, data.part, data.item)
    cb({})
end)

RegisterNUICallback('quickAction', function(data, cb)
    TriggerServerEvent('prp-amb:quickAction', data.action)
    cb({})
end)
