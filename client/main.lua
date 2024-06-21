-------------
-- Configs --
-------------
local config = require 'config.client'
local sharedConfig = require 'config.shared'
local serverConfig = nil


---------------
-- Functions --
---------------
local function calculateReputationModifier(val, multiplier)
    lib.print.debug("Starting calculateReputationModifier(val, multiplier)", val, multiplier)

    -- Calculates our reputation and then multiplies it by our multiplier to return our value
    local currentRep = nil

    if config.repStorage.type == "PlayerData" then
        if sharedConfig.framework == "qbcore" then
            local player = QBCore.Functions.GetPlayerData()
            currentRep = player.PlayerData.metadata[config.repStorage.key].config.repStorage.val
        
            if currentRep == nil then
                currentRep = 1
            end
        end

        if sharedConfig.framework == "qbox" then
            local player = exports.qbx_core:GetPlayerData()
            currentRep = player.PlayerData.metadata[config.repStorage.key].config.repStorage.val
        
            if currentRep == nil then
                currentRep = 1
            end
        end
    end

    -- Here is where we multiply it by our value and our modifier
    val = (val-(multiplier * val))

    lib.print.debug("Ending calculateReputationModifier: val", val)
    return val
end

local function sudotext(text)
    local scaleform = RequestScaleformMovie("mp_big_message_freemode")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieMethodParameterString(text)
    PushScaleformMovieMethodParameterString("")
    EndScaleformMovieMethod()

    local endTime = GetGameTimer() + 3500
    while GetGameTimer() < endTime do
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        Wait(0)
    end

    -- Clean up the scaleform movie after use
    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

local function deleteAllProps()
    for _, v in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cache.ped, v) then
          SetEntityAsMissionEntity(v, true, true)
          DeleteObject(v)
          DeleteEntity(v)
        end
    end
end

local function createTargets()
    lib.print.debug("Running createTargets()")
    -- Get the server config
    serverConfig = lib.callback.await("vib_fabricator:server:getconfig")
    lib.print.debug("createTargets(): Got serverConfig")

    for _, v in pairs(serverConfig.locations.large_fabricator_locations) do
        local obj = lib.getClosestObject(v, 5.0)

        lib.print.debug("createTargets(): Found an object", obj)
        if obj == nil then 
            lib.print.debug("Could not find an object")
            return
        else
            lib.print.debug("Found an object", obj)
        end

        exports.ox_target:addLocalEntity(obj, {
            {
                icon = 'fa fa-hand',
                label = "Attach and Charge Fabricator",
                onSelect = function()

                    local count = exports.ox_inventory:Search('count', 'large_fabricator')

                    if count < 1 then
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
                    local objCoords = v
    
                    config.states.rope = AddRope(playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, 0.0, ropeLength, ropeType, ropeLength, 0.1, false, false, false, 1.0, false, 0)
    
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
                        label = 'Charging Fabricator Battery',
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
                        }
                    }) then
                        print("DONE Charged")

                        -- Loop through all your items and make sure you don't have more than 1 fabricator on you.
                        local count = exports.ox_inventory:Search('count', 'large_fabricator')

                        if count > 1 then
							local alert = lib.alertDialog({
								header = 'Error',
								content = "Cannot charge more than 1 large fabricator at a time.",
								centered = true,
								cancel = false
							})
                            return
                        end

                        local item = exports.ox_inventory:Search('slots', 'large_fabricator')
                        lib.print.debug("item", item)
                        for _, v in pairs(item) do
                            lib.print.debug(v.slot, slot)
                            if (v.slot == item[1].slot) then 

                                local metadata = v.metadata
                                
                                lib.print.debug("large_fabricator metadata before", metadata)
    
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
                                lib.print.debug("Running vib_fabricator:server:setmetadata")
                                TriggerServerEvent('vib_fabricator:server:setmetadata', v.slot, metadata)
                            end
                        end

                        deleteAllProps()

                    else
                        for _, v in pairs(GetGamePool("CObject")) do
                            deleteAllProps()
                        end
                        exports.qbx_core:Notify('Cancelled', 'error')
                    end

                end,
                distance = 5,
            },
            {
                icon = 'fa fa-hand',
                label = "Attach Fabricator",
                onSelect = function()

                    SetRopesCreateNetworkWorldState(true)

                    local ropeType = 4 -- Type of the rope (for example, 4 for normal rope)
                    local ropeLength = 5.0 -- Length of the rope
    
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local objCoords = v
    
                    config.states.rope = AddRope(playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, 0.0, ropeLength, ropeType, ropeLength, 0.1, false, false, false, 1.0, false, 0)
    
                    if config.states.rope ~= -1 then
    
                        AttachEntitiesToRope(config.states.rope, PlayerPedId(), obj, playerCoords.x, playerCoords.y, playerCoords.z, objCoords.x, objCoords.y, objCoords.z, ropeLength, false, false)
                        ActivatePhysics(config.states.rope)
                        RopeLoadTextures()
                        
                    end
                end,
                distance = 5,
            },
            {
                icon = 'fa fa-hand',
                label = "Detach Fabricator",
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

------------
-- Events --
------------

RegisterNetEvent('vib_fabricator:client:fabricator', function(slot, size)
    lib.print.debug("Running vib_fabricator:client:fabricator")

    -- Let's establish some variables
    local items             = exports.ox_inventory:GetPlayerItems()
    local item              = items[slot]
    local containerId       = item.metadata.container

    -- Check for nil values and set to 0 if they exist
    lib.print.debug("PRECHECK: item.metadata.chargelevel", item.metadata.chargelevel)
    if item.metadata.chargelevel == nil then
        item.metadata.chargelevel = 0
        TriggerServerEvent('vib_fabricator:server:setmetadata', slot, item.metadata)
    end

    -- Get our recipes from the server.
    local recipes           = lib.callback.await("vib_fabricator:server:getrecipes")
    local containerItems    = lib.callback.await("vib_fabricator:server:getcontaineritems", containerId, slot)
    lib.print.debug("containerItems", containerItems)
    lib.print.debug("containerId", containerId)
    lib.print.debug("size", size)

    if containerItems.items == nil then
        local alert = lib.alertDialog({
            header = 'Error',
            content = "No Items Found!",
            centered = true,
            cancel = false
        })
        return
    end

    if size == "small" then
        for _, containerItem in ipairs(containerItems.items) do
            lib.print.debug("item", item.name, item.count)
            if containerItem.name == "fabricator_battery" and containerItem.count >= 1 then
                local metadata = item.metadata
                lib.print.debug("metadata", metadata)
                metadata.chargelevel = 100
                lib.print.debug("Running vib_fabricator:server:setmetadata")
                TriggerServerEvent('vib_fabricator:server:setmetadata', slot, metadata)
                TriggerServerEvent('vib_fabricator:server:removebattery', containerId)

                local alert = lib.alertDialog({
                    header = 'Success',
                    content = "Battery is now charged!",
                    centered = true,
                    cancel = false
                })
                return
            end
        end
    end


    -- Let's make sure we have enough charge.
    if item.metadata.chargelevel < 5 then
        local alert = lib.alertDialog({
            header = 'Error',
            content = "Not enough charge to work fabricator!",
            centered = true,
            cancel = false
        })
        return
    end

    -- Let's make sure if we're using the large_fabricator we're near our power source.
    lib.print.debug("PRECHECK: config.rope, size", config.states.rope, size)
    if config.states.rope == nil and size == "large" then 
        local alert = lib.alertDialog({
            header = 'Error',
            content = "Must be attached to a power source for the large fabricator!",
            centered = true,
            cancel = false
        })
        return
    end

    -- Let's make sure charge mode isn't activated
    lib.print.debug("PRECHECK: item.metadata.chargemode", item.metadata.chargemode)
    if item.metadata.chargemode == true then 
        local alert = lib.alertDialog({
            header = 'Error',
            content = "Fabricator is set to charge mode! Toggle the charge mode.",
            centered = true,
            cancel = false
        })
        return
    end

    -- This function matches the items in our cube with our recipes
    local function getCraftableRecipe(recipes, playerItems)
        lib.print.debug("playerItems", playerItems)
        
        -- Merging player items into a name-indexed table with counts
        local mergedItems = {}
        for _, item in ipairs(playerItems.items) do
            if mergedItems[item.name] then
                mergedItems[item.name].count = mergedItems[item.name].count + item.count
            else
                mergedItems[item.name] = { count = item.count }
            end
        end
        
        lib.print.debug("mergedItems", mergedItems)
        
        -- Function to check if all required items are sufficient
        local function hasSufficientItems(recipe)
            for _, reqItem in ipairs(recipe.input) do
                lib.print.debug("EVAL RECIPE CONTENTS", reqItem.item, reqItem.count)
                local item = mergedItems[reqItem.item]
                if not (item and item.count >= reqItem.count) then
                    lib.print.debug("NO WE DO NOT HAVE ENOUGH")
                    return false
                end
            end
            lib.print.debug("YES WE HAVE ENOUGH")
            return true
        end
        
        -- Finding all recipes that can be crafted
        local matched_recipes = {}
        for _, recipe in ipairs(recipes) do
            lib.print.debug("EVAL RECIPE", recipe)
            if hasSufficientItems(recipe) then
                table.insert(matched_recipes, recipe)
            end
        end
        
        return matched_recipes
    end

    -- This creates a table of matched recipes.
    local recipes_to_execute = getCraftableRecipe(recipes, containerItems)
    lib.print.debug("recipes", recipes_to_execute)

    -- Now let's put our recipes into the format for ox_lib menu options
    local moptions = {}
    for k,v in pairs(recipes_to_execute) do
        lib.print.debug("v", v.output[1].item)
        table.insert(moptions, {
            title = v.output[1].label,
            onSelect = function() 
                lib.print.debug("Running vib_fabricator:server:fabricator")
                TriggerServerEvent('vib_fabricator:server:fabricator', v, containerId)
                sudotext("Fabricated: "..v.output[1].label)

                -- Let's remove our charge.
                -- item.metadata, slot
                local metadata = item.metadata
                local currentCharge = metadata.chargelevel
                lib.print.debug("Pre currentCharge", currentCharge)
                lib.print.debug("Pre drainAmount", config.batteryDrainPerUse)

                local drainAmount = calculateReputationModifier(config.batteryDrainPerUse, config.batteryDrainPerUseMultiplier)
                local newCharge = currentCharge - drainAmount

                if newCharge < 0 then 
                    newCharge = 0
                end

                metadata.chargelevel = newCharge

                lib.print.debug("Calculated drainAmount", drainAmount)
                lib.print.debug("Calculated newCharge", config.batteryDrainPerUse)

                TriggerServerEvent('vib_fabricator:server:setmetadata', slot, metadata)

            end,
        })
    end

    lib.registerContext({
        id = 'fabricator',
        title = 'Pick a Recipe',
        menu = 'fabricatorchoose',
        onBack = function()
          print('Went back!')
        end,
        options = moptions
      })

    Wait(500)
    lib.showContext('fabricator')
end)

---------------
-- Functions --
---------------



-------------
-- Threads --
-------------
CreateThread(function()
    lib.print.debug("TOCK", config.states.setup)
    while config.states.setup == false do
        lib.print.debug("TICK", config.states.setup)

        if LocalPlayer.state.isLoggedIn == false then
            Wait(1000)
        else
            createTargets()
        end

        Wait(5000)
    end
end)