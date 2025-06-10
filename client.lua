local SCRIPT_VERSION = '1.0.2'  -- your current script version

local tireBones = {
    [0] = "wheel_lf",
    [1] = "wheel_rf",
    [4] = "wheel_lr",
    [5] = "wheel_rr"
}

RegisterNetEvent('tire_plug:attemptRepair', function(vehicle, tireIndex)
    local ped = PlayerPedId()
    local boneName = tireBones[tireIndex]
    if not boneName then return end

    local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
    local boneCoords = GetWorldPositionOfEntityBone(vehicle, boneIndex)

    -- Position player crouched slightly in front of the tire
    local forwardVec = GetEntityForwardVector(vehicle)
    local repairPos = boneCoords + forwardVec * 0.3
    repairPos = vector3(repairPos.x, repairPos.y, repairPos.z - 0.85) -- crouched height adjustment

    local vehCoords = GetEntityCoords(vehicle)
    local headingToVehicle = GetHeadingFromVector_2d(vehCoords.x - repairPos.x, vehCoords.y - repairPos.y)

    -- Teleport player to crouch position
    SetEntityCoords(ped, repairPos.x, repairPos.y, repairPos.z, false, false, false, false)
    SetEntityHeading(ped, headingToVehicle)
    FreezeEntityPosition(ped, true)

    -- Play crouched repair animation
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
        local netId = VehToNet(vehicle)
        TriggerServerEvent('tire_plug:tryRepairTire', netId, tireIndex, pedCoords)
    end
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 1)
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 4)
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
        canInteract = function(entity, distance)
            local netId = VehToNet(entity)
            local key = ("%s_%s"):format(netId, 5)
            return IsVehicleTyreBurst(entity, 5, false)
        end,
        onSelect = function(data)
            TriggerEvent('tire_plug:attemptRepair', data.entity, 5)
        end
    }
})
