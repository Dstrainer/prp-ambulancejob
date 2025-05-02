-- server/medical.lua
local sharedConfig = require 'config.shared'
local patientData = {}

-- Helper: map GTA bone ID → part name
local function boneToPart(bone)
    if     bone == 31086 then return 'head'
    elseif bone == 24816 then return 'torso'
    elseif bone == 18905 then return 'leftArm'
    elseif bone == 57005 then return 'rightArm'
    elseif bone == 48618 then return 'leftLeg'
    elseif bone == 51826 then return 'rightLeg'
    end
    return 'torso'
end

-- Track damage reported from client
RegisterServerEvent('prp-amb:trackDamage')
AddEventHandler('prp-amb:trackDamage', function(target, part)
    patientData[target] = patientData[target] or {}
    patientData[target][part] = true
end)

-- Apply a medical item (called from NUI via client)
RegisterServerEvent('prp-amb:applyItem')
AddEventHandler('prp-amb:applyItem', function(target, part, item)
    local src = source
    -- remove one from ox_inventory
    if exports.ox_inventory:RemoveItem(src, cfg[item], 1) then
        -- tell the target to heal that part
        TriggerClientEvent('prp-amb:healPart', target, part, item)
        -- notify the EMS medic
        TriggerClientEvent('ox_lib:notify', src, {title='Medical', type = 'success', description = ('Applied %s to %s'):format(item, part), position = 'top', duration = 5000, icon = 'fa fa-medkit'})
    else
        TriggerClientEvent('ox_lib:notify', src, {title='Medical', type = 'error', description = ('Missing item: %s'):format(item), position = 'top', duration = 5000, icon = 'fa fa-medkit'})
    end
end)

-- Quick‐action requests (pulse, consciousness, temp)
RegisterServerEvent('prp-amb:quickAction')
AddEventHandler('prp-amb:quickAction', function(action)
    local src = source
    if action == 'pulse' then
        TriggerClientEvent('prp-amb:showPulse', src)
    elseif action == 'consciousness' then
        TriggerClientEvent('prp-amb:showConsciousness', src)
    elseif action == 'temperature' then
        TriggerClientEvent('prp-amb:showTemperature', src)
    end
end)

-- Register Defibrillator & Medic Bag as useable items via QBox core
exports.qbx_core:CreateUseableItem(cfg.medic_bag, function(source, item)
    -- place the bag on client
    TriggerClientEvent('prp-amb:PlaceMedicBag', source)
end)

exports.qbx_core:CreateUseableItem(cfg.defibrillator, function(source, item)
    -- place the defibrillator on client
    TriggerClientEvent('prp-amb:PlaceDefib', source)
end)

-- EMS starts CPR on a downed player
RegisterNetEvent('prp-amb:startCpr', function(targetSrc)
    if GetInvokingResource() then return end
    local medic = exports.qbx_core:GetPlayer(source)
    if not medic or medic.PlayerData.job.type ~= 'ambulance' or medic.PlayerData.job.type ~= 'ems' or medic.PlayerData.job.type ~= 'police' then return end

    -- Tell the medic client to play CPR emote + progress bar
    TriggerClientEvent('prp-amb:performCpr', source, targetSrc)
end)

-- Medic finishes CPR successfully
RegisterNetEvent('prp-amb:finishCpr', function(targetSrc)
    if GetInvokingResource() then return end
    local medic = exports.qbx_core:GetPlayer(source)
    if not medic or medic.PlayerData.job.type ~= 'ambulance' or medic.PlayerData.job.type ~= 'ems' or medic.PlayerData.job.type ~= 'police' then return end

    -- Pause the target’s death timer
    TriggerClientEvent('prp-amb:pauseDeathTimer', targetSrc, sharedConfig.CPRPauseTime)

    -- Notify the medic via ox_lib
TriggerClientEvent('ox_lib:notify', source, {
    title      = 'Medical',
    type        = 'success',
    description = ('CPR successful! Respawn paused for %ds'):format(sharedConfig.CPRPauseTime),
    position   = 'top',
    duration  = 5000,
    icon     = 'fa fa-medkit'
})
end)


