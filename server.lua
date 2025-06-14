local SCRIPT_VERSION = '1.0.3'

local RED = '\27[31m'
local GREEN = '\27[32m'
local RESET = '\27[0m'

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print(("[tire_plug] Resource '%s' started successfully (Created by Smokey) - Version %s"):format(resourceName, SCRIPT_VERSION))

        local versionCheckUrl = 'https://gist.githubusercontent.com/Robg815/b4d71e977dae3924ed76536b4144bbd4/raw/b3e683523081b16be670f64369bac7b55024791f/version.json'

        PerformHttpRequest(versionCheckUrl, function(statusCode, text)
            if statusCode == 200 and text then
                local success, data = pcall(function() return json.decode(text) end)
                if success and data and data.latest_version then
                    if data.latest_version ~= SCRIPT_VERSION then
                        print(RED .. "[tire_plug] ⚠️ WARNING: Your version (" .. SCRIPT_VERSION .. ") is outdated! Latest is " .. data.latest_version .. RESET)
                        print(RED .. "[tire_plug] 📦 Update here: https://github.com/Robg815/tire_plug" .. RESET)
                    else
                        print(GREEN .. "[tire_plug] ✅ You are running the latest version." .. RESET)
                    end
                else
                    print("[tire_plug] ❌ Failed to decode version check response.")
                end
            else
                print(("[tire_plug] ❌ Failed to check latest version, HTTP error: %s"):format(statusCode))
            end
        end, 'GET', '', {})
    end
end)

local QBCore = exports['qb-core']:GetCoreObject()
local lastRepairTime = {}
local activeRepairs = {} -- Format: ["netId_tireIndex"] = true

RegisterNetEvent('tire_plug:tryRepairTire', function(vehicleNetId, tireIndex, pedCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

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

    -- Proximity check (5m)
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

        -- Lock tire locally
        local players = GetPlayers()
        for _, id in ipairs(players) do
            local targetPed = GetPlayerPed(id)
            local targetCoords = GetEntityCoords(targetPed)
            if #(targetCoords - vehCoords) < 40.0 then
                TriggerClientEvent('tire_plug:lockTire', tonumber(id), vehicleNetId, tireIndex, true)
                TriggerClientEvent('tire_plug:repairTire', tonumber(id), vehicleNetId, tireIndex)
                TriggerClientEvent('tire_plug:lockTire', tonumber(id), vehicleNetId, tireIndex, false)
            end
        end

        TriggerClientEvent('ox_lib:notify', src, {
            type = 'success',
            title = 'Success',
            description = 'Tire repaired!',
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            title = 'Error',
            description = 'You don’t have a Tire Plug!',
        })
    end

    activeRepairs[lockKey] = nil
end)
