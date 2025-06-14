AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[script:tire_plug] Script created by Smokey (client)")
    end
end)

local function GetTyreLabel(index)
    local labels = {
        [0] = "Front Left",
        [1] = "Front Right",
        [4] = "Rear Left",
        [5] = "Rear Right"
    }
    return labels[index] or nil
end

RegisterNetEvent('tire_plug:attemptRepair', function(vehicle, tireIndex)
    local hasItem = exports.ox_inventory:Search('count', 'tire_plug') > 0
    if not hasItem then
        lib.notify({ type = 'error', title = 'Error', description = "You don't have a Tire Plug!" })
        return
    end

    local passed = lib.skillCheck({ 'easy', 'medium' }, { 'w', 'a', 's', 'd' })
    if not passed then
        lib.notify({ type = 'error', title = 'Failed', description = 'You failed the skillcheck!' })
        return
    end

    local ped = PlayerPedId()
    local dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
    local anim = "machinic_loop_mechandplayer"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    PlaySoundFrontend(-1, "TOOLS", "MECHANIC", true)

    local success = lib.progressCircle({
        duration = 3500,
        label = "Repairing Tire...",
        canCancel = true,
        disable = { move = true, car = true },
        onCancel = function()
            ClearPedTasks(ped)
            lib.notify({ type = 'error', title = 'Cancelled', description = 'Repair was cancelled.' })
        end
    })

    ClearPedTasks(ped)

    if success then
        local coords = GetEntityCoords(ped)
        TriggerServerEvent('tire_plug:tryRepairTire', VehToNet(vehicle), tireIndex, coords)
    end
end)

RegisterNetEvent('tire_plug:repairTire', function(vehicleNetId, tireIndex)
    local vehicle = NetToVeh(vehicleNetId)
    if not DoesEntityExist(vehicle) then
        lib.notify({ type = 'error', title = 'Error', description = 'Vehicle not found.' })
        return
    end

    SetVehicleTyreFixed(vehicle, tireIndex)

    if GetResourceState('xt-slashtires') == 'started' then
        local success, err = pcall(function()
            exports['xt-slashtires']:FixTire(vehicle, tireIndex)
        end)
        if not success then
            print("[tire_plug] xt-slashtires error:", err)
        end
    end

    lib.notify({ type = 'success', title = 'Success', description = 'Tire repaired.' })
end)

exports.ox_target:addGlobalVehicle({
    {
        name = 'repair_tire_lf',
        bones = { 'wheel_lf' },
        label = 'Repair Front Left Tire',
        icon = 'fa-solid fa-wrench',
        canInteract = function(entity)
            return IsVehicleTyreBurst(entity, 0, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 0)
        end
    },
    {
        name = 'repair_tire_rf',
        bones = { 'wheel_rf' },
        label = 'Repair Front Right Tire',
        icon = 'fa-solid fa-wrench',
        canInteract = function(entity)
            return IsVehicleTyreBurst(entity, 1, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 1)
        end
    },
    {
        name = 'repair_tire_lr',
        bones = { 'wheel_lr' },
        label = 'Repair Rear Left Tire',
        icon = 'fa-solid fa-wrench',
        canInteract = function(entity)
            return IsVehicleTyreBurst(entity, 4, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 4)
        end
    },
    {
        name = 'repair_tire_rr',
        bones = { 'wheel_rr' },
        label = 'Repair Rear Right Tire',
        icon = 'fa-solid fa-wrench',
        canInteract = function(entity)
            return IsVehicleTyreBurst(entity, 5, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 5)
        end
    }
})
