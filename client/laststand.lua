local isEscorting = false
local lib = exports.ox_lib
---@param bool boolean
---TODO: this event name should be changed within qb-policejob to be generic
AddEventHandler('hospital:client:SetEscortingState', function(bool)
    isEscorting = bool
end)

---Use first aid pack on nearest player.
lib.callback.register('hospital:client:UseFirstAid', function()
    if isEscorting then
        lib.notify({title = 'Medical', type = 'error', description = locale('error.impossible'), position = 'top', duration = 5000, icon = 'fa fa-medkit' })
        return
    end

    local player = GetClosestPlayer()
    if player then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('hospital:server:UseFirstAid', playerId)
    end
end)

lib.callback.register('hospital:client:canHelp', function()
    return exports.qbx_medical:IsLaststand() and exports.qbx_medical:GetLaststandTime() <= 300
end)

---@param targetId number playerId
RegisterNetEvent('hospital:client:HelpPerson', function(targetId)
    if GetInvokingResource() then return end
    if lib.progressCircle({
        duration = math.random(30000, 60000),
        position = 'bottom',
        label = locale('progress.revive'),
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = false,
            car = false,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = HealAnimDict,
            clip = HealAnim,
        },
    })
    then
        lib.notify({title = 'Medical', type = 'success', description = locale('success.revive'), position = 'top', duration = 5000, icon = 'fa fa-medkit' })
        TriggerServerEvent('hospital:server:RevivePlayer', targetId)
    else
        lib.notify({title = 'Medical', type = 'error', description = locale('error.canceled'), position = 'top', duration = 5000, icon = 'fa fa-medkit' })
    end
end)
