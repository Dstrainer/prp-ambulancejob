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
                lib.notify({ type = 'error', description = 'No patient nearby', title = 'Medical', position = 'top', duration = 5000, icon = 'fa fa-medkit'  })
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
                lib.notify({title = 'Medical', type = 'error', description = 'No patient nearby', position = 'top', duration = 5000, icon = 'fa fa-medkit' })
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

RegisterNetEvent('prp-amb:performCpr', function(targetId)
    local ped = PlayerPedId()
    local dict, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'

    -- 1) Load the anim dict
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(10)
    end

    -- 2) Kick off the progress bar with onStart/onFinish hooks
    exports.ox_lib:progressBar({
        duration     = 5000,
        label        = 'Performing CPR...',
        useWhileDead = false,
        canCancel    = true,
        disable = {
            move   = true,
            combat = true,
            mouse  = false
        },
        onStart = function()
            -- start CPR emote
            TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
        end,
        onFinish = function()
            -- clear the anim and notify server
            ClearPedTasks(ped)
            TriggerServerEvent('prp-amb:finishCpr', targetId)
        end,
        onCancel = function()
            -- if you cancel, stop anim too
            ClearPedTasks(ped)
        end
    })
end)


-- Quick‐action feedback
RegisterNetEvent('prp-amb:showPulse', function()
    lib.notify({ title = 'Medical', type = 'inform', description = 'Pulse: ' .. (GetEntityHealth(PlayerPedId()) > 100 and 'Present' or 'None'), position = 'top', duration = 5000, icon = 'fa fa-medkit' })
end)
RegisterNetEvent('prp-amb:showConsciousness', function()
    lib.notify({ title = 'Medical', type = 'inform', description = IsPedInjured(PlayerPedId()) and 'Unconscious' or 'Conscious', position = 'top', duration = 5000, icon = 'fa fa-medkit' })
end)
RegisterNetEvent('prp-amb:showTemperature', function()
    lib.notify({ title = 'Medical', type = 'inform', description = 'Body Temp: Normal', position = 'top', duration = 5000, icon = 'fa fa-medkit' })
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
