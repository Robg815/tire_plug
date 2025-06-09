AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print(("[tire_plug] Resource '%s' started successfully (Created by Smokey)"):format(resourceName))
    end
end)

local QBCore = exports['qb-core']:GetCoreObject()
local lastRepairTime = {}
local activeRepairs = {} -- Format: ["netId_tireIndex"] = true

RegisterNetEvent('tire_plug:tryRepairTire', function(vehicleNetId, tireIndex, pedCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Anti-spam: 5 seconds cooldown
    if lastRepairTime[src] and os.time() - lastRepairTime[src] < 5 then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Wait',
            description = 'You are repairing too quickly!',
        })
        return
    end

    local lockKey = ("%s_%s"):format(vehicleNetId, tireIndex)
    if activeRepairs[lockKey] then
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Busy',
            description = 'Someone is already repairing this tire!',
        })
        return
    end

    lastRepairTime[src] = os.time()
    activeRepairs[lockKey] = true

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then
        activeRepairs[lockKey] = nil
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Error',
            description = 'Vehicle not found.',
        })
        return
    end

    -- Range check (5 meters)
    local vehCoords = GetEntityCoords(vehicle)
    local dist = #(vehCoords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))
    if dist > 5.0 then
        activeRepairs[lockKey] = nil
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Too Far',
            description = 'You are too far from the vehicle!',
        })
        return
    end

    local hasItem = Player.Functions.GetItemByName('tire_plug')
    if hasItem and hasItem.amount > 0 then
        Player.Functions.RemoveItem('tire_plug', 1)

        -- Lock tire for all clients before repair starts
        TriggerClientEvent('tire_plug:lockTire', -1, vehicleNetId, tireIndex, true)

        -- Broadcast repair to all clients
        TriggerClientEvent('tire_plug:repairTire', -1, vehicleNetId, tireIndex)

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            title = 'Success',
            description = 'Tire repaired!',
        })

        -- Unlock tire after repair finished
        TriggerClientEvent('tire_plug:lockTire', -1, vehicleNetId, tireIndex, false)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Error',
            description = 'You don’t have a Tire Plug!',
        })
    end

    activeRepairs[lockKey] = nil
end)
