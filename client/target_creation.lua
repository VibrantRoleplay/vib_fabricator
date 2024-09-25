function createTargets(config)
    lib.print.debug("Running createTargets()")
    -- Get the server config
    serverConfig = lib.callback.await("vib_fabricator:server:getconfig")
    lib.print.debug("createTargets(): Got serverConfig")

    for _, v in pairs(serverConfig.locations.large_fabricator_locations) do
        lib.print.debug("Trying to discovery object at", v)
        local obj = lib.getClosestObject(v, 5.0)

        lib.print.debug("createTargets(): Object Discovery:", obj)
        if obj == nil then 
            lib.print.debug("Could not find an object")
            return
        else
            lib.print.debug("Found an object", obj)
        end

        exports.ox_target:addLocalEntity(obj, {
            {
                icon = 'fa fa-hand',
                label = "Attach and Charge battery",
                onSelect = function()

                    if config.states.rope ~= nil then
                        local alert = lib.alertDialog({
                            header = 'Error',
                            content = "You are already attached, please detach and attach to recharge.",
                            centered = true,
                            cancel = false
                        })
                        return
                    end

                    local count = exports.ox_inventory:Search('count', 'fabricator_battery')

                    if count < 1 then
                        local alert = lib.alertDialog({
                            header = 'Error',
                            content = "You do not have a battery on you",
                            centered = true,
                            cancel = false
                        })
                        return
                    end

                    if count > 1 then
                        local alert = lib.alertDialog({
                            header = 'Error',
                            content = "Cannot charge more than 1 battery at a time",
                            centered = true,
                            cancel = false
                        })
                        return
                    end

                    SetRopesCreateNetworkWorldState(true)

                    local ropeType = 4 -- Type of the rope (for example, 4 for normal rope)
                    local ropeLength = 5.0 -- Length of the rope
    
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local objCoords = v
    
                    config.states.rope = AddRope(playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, 0.0, ropeLength, ropeType, ropeLength, 0.0, 0.1, false, false, false, 1.0, true)
    
                    if config.states.rope ~= -1 then
                        AttachEntitiesToRope(config.states.rope, PlayerPedId(), obj, playerCoords.x, playerCoords.y, playerCoords.z, objCoords.x, objCoords.y, objCoords.z, ropeLength, false, false)
                        ActivatePhysics(config.states.rope)
                        RopeLoadTextures()
                    end

                    -- Calculate the duration
                    local calculatedDuration = calculateReputationModifier(config.batteryChargeDuration, config.batteryRepMultiplier)
                    if calculatedDuration == nil then
                        calculatedDuration = config.batteryChargeDuration
                        lib.print.error("Error calculating duration")
                    end

                    lib.print.debug("Calculated Duration", duration)

                    if lib.progressBar({
                        duration = calculatedDuration,
                        label = 'Charging Battery',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                            mouse = false,
                            combat = true
                        },
                        anim = {
                            clip = 'machinic_loop_mechandplayer',
                            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                            flag = 49
                        },
                        prop = {
                            model = 'sum_prop_sum_power_cell',
                            bone = 60309,
                            pos = {x = 0.12, y = 0.008, z = 0.03},
                            rot = {x = -240.0, y = 60.0, z = 120.0}
                        },
                    }) then
                        local item = exports.ox_inventory:Search('slots', 'fabricator_battery')

                        lib.print.debug("item", item)
                        for _, v in pairs(item) do
                            lib.print.debug(v.slot, slot)
                            if (v.slot == item[1].slot) then 

                                local metadata = v.metadata
                                
                                lib.print.debug("fabricator_battery metadata before", metadata)
    
                                -- Get the metadata from the slot, find the max battery level.
                                if metadata.maxbattery == nil then
                                    metadata.maxbattery = 100
                                end

                                -- Random chance to remove 1% of battery.
                                if math.random(config.batteryDecay.min, config.batteryDecay.max) == config.batteryDecay.min then
                                    metadata.maxbattery = metadata.maxbattery - 1
                                    TriggerServerEvent('vib_fabricator:server:setmetadata', v.slot, metadata)

                                    lib.notify({
                                        title = 'Battery Degraded',
                                        description = 'Battery has degraded by 1%.',
                                        type = 'success'
                                    })
                                end

                                -- Set the metadata for the charge level to the max.
                                Wait(500)

                                metadata.chargelevel = metadata.maxbattery
                                metadata.description = "Current Charge: "..metadata.chargelevel.."%"
                                lib.print.debug("Running vib_fabricator:server:setmetadata")
                                TriggerServerEvent('vib_fabricator:server:setmetadata', v.slot, metadata)
                            end
                        end
                        deleteAllProps()
                        DeleteRope(config.states.rope)
                        config.states.rope = nil

                    else
                        for _, v in pairs(GetGamePool("CObject")) do
                            deleteAllProps()
                            DeleteRope(config.states.rope)
                            config.states.rope = nil
                        end
                        lib.notify({
                            title = 'Canceled',
                            description = 'Canceled',
                            type = 'error'
                        })
                    end
                end,
                distance = 5,
            },
            {
                icon = 'fa fa-hand',
                label = "Attach Large Fabricator",
                onSelect = function()

                    if config.states.rope ~= nil then
                        local alert = lib.alertDialog({
                            header = 'Error',
                            content = "You do not have a large fabricator on you.",
                            centered = true,
                            cancel = false
                        })
                        return
                    end

                    SetRopesCreateNetworkWorldState(true)

                    local ropeType = 4 -- Type of the rope (for example, 4 for normal rope)
                    local ropeLength = 5.0 -- Length of the rope
    
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    lib.requestModel('sum_prop_sum_power_cell')
                    local objCoords = v
                    config.states.rope = AddRope(objCoords.x, objCoords.y, objCoords.z, 0.0, 0.0, 0.0, 3.0, ropeType, ropeLength, 0.0, 1.0, false, false, false, 1.0, true)

                    if config.states.rope ~= -1 then
                        AttachEntitiesToRope(config.states.rope, PlayerPedId(), obj, playerCoords.x, playerCoords.y, playerCoords.z, objCoords.x, objCoords.y, objCoords.z, ropeLength, false, false)
                        ActivatePhysics(config.states.rope)
                    end
                end,
                distance = 5,
            },
            {
                icon = 'fa fa-hand',
                label = "Detach Large Fabricator",
                onSelect = function()
                    DeleteRope(config.states.rope)
                    SetRopesCreateNetworkWorldState(false)
                    deleteAllProps()
                    config.states.rope = nil
                end,
                distance = 5,
            },
        })
    end

    -- Store our state
    lib.print.debug("Setting config.states.setup = true")
    config.states.setup = true
end
