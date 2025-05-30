AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print(("[tire_plug] Resource '%s' started successfully (Created by Smokey)"):format(resourceName))
    end
end)

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('tire_plug:tryRepairTire', function(vehicleNetId, tireIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local hasItem = Player.Functions.GetItemByName('tire_plug')
    if hasItem and hasItem.amount > 0 then
        Player.Functions.RemoveItem('tire_plug', 1)
        TriggerClientEvent('tire_plug:repairTire', src, vehicleNetId, tireIndex)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Error',
            description = 'You don’t have a Tire Plug!',
        })
    end
end)
