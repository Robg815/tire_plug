AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("[script:tire_plug] Script created by Smokey (client)")
    end
end)

local tireBones = {
    [0] = "wheel_lf",
    [1] = "wheel_rf",
    [4] = "wheel_lr",
    [5] = "wheel_rr"
}

local lockedTires = {} -- Format: ["netId_tireIndex"] = true

RegisterNetEvent('tire_plug:lockTire', function(vehicleNetId, tireIndex, state)
    local key = ("%s_%s"):format(vehicleNetId, tireIndex)
    lockedTires[key] = state
end)

RegisterNetEvent('tire_plug:attemptRepair', function(vehicle, tireIndex)
    local netId = VehToNet(vehicle)
    local key = ("%s_%s"):format(netId, tireIndex)

    if lockedTires[key] then
        lib.notify({ type = 'info', title = 'Busy', description = "This tire is currently being repaired by another player." })
        return
    end

    local hasItem = exports.ox_inventory:Search('count', 'tire_plug') > 0
    if not hasItem then
        lib.notify({ type = 'error', title = 'Error', description = "You don't have a Tire Plug!" })
        return
    end

    local passed = lib.skillCheck({'easy', 'medium'}, {'w', 'a', 's', 'd'})
    if not passed then
        lib.notify({ type = 'error', title = 'Failed', description = 'You failed the skillcheck!' })
        return
    end

    local ped = PlayerPedId()
    local boneName = tireBones[tireIndex]
    if not boneName then return end

    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    local forwardVec = GetEntityForwardVector(vehicle)
    local repairPos = boneCoords + forwardVec * 0.5

    local vehCoords = GetEntityCoords(vehicle)
    local headingToVehicle = GetHeadingFromVector_2d(vehCoords.x - repairPos.x, vehCoords.y - repairPos.y)

    SetEntityCoords(ped, repairPos.x, repairPos.y, repairPos.z - 0.9, false, false, false, false)
    SetEntityHeading(ped, headingToVehicle)
    FreezeEntityPosition(ped, true)

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
            FreezeEntityPosition(ped, false)
            lib.notify({ type = 'error', title = 'Cancelled', description = 'Repair was cancelled.' })
        end
    })

    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)

    if success then
        local pedCoords = GetEntityCoords(ped)
        TriggerServerEvent('tire_plug:tryRepairTire', netId, tireIndex, pedCoords)
    end
end)

RegisterNetEvent('tire_plug:repairTire', function(vehicleNetId, tireIndex)
    local vehicle = NetToVeh(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 0)
            return not lockedTires[key] and IsVehicleTyreBurst(entity, 0, false)
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 1)
            return not lockedTires[key] and IsVehicleTyreBurst(entity, 1, false)
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 4)
            return not lockedTires[key] and IsVehicleTyreBurst(entity, 4, false)
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 5)
            return not lockedTires[key] and IsVehicleTyreBurst(entity, 5, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 5)
        end
    }
})
