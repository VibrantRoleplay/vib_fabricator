-------------
-- Configs --
-------------
local config = require 'config.client'
local sharedConfig = require 'config.shared'
local serverConfig = nil


---------------
-- Functions --
---------------
function calculateReputationModifier(valueToModify, baseMultiplier)
    lib.print.debug("Starting calculateReputationModifier(val, multiplier)", valueToModify, baseMultiplier)

    -- Set a base reputation
    local currentRep = 1

    if config.repStorage.type == "PlayerData" then
        local PlayerData = nil

        if sharedConfig.framework == "qbox" then
            lib.print.debug("Detecting Framework as", sharedConfig.framework)
            PlayerData = exports.qbx_core:GetPlayerData()
        end

        if sharedConfig.framework == "qbcore" then
            lib.print.debug("Detecting Framework as", sharedConfig.framework)
            PlayerData = QBCore.Functions.GetPlayerData()
        end

        -- If we cannot calculate PlayerData, just return the original value, and notify the player.
        if PlayerData == nil or PlayerData == {} then
            lib.notify({
                title = 'Error',
                description = 'Error calculating reputation, send client log to Admins.',
                type = 'error',
                duration = 10000,
            })
            return valueToModify
        end

        -- Get our values from the config, this is used to access reputation.
        local key = config.repStorage.key
        local val = config.repStorage.val

        -- Retrieve our reputation
        lib.print.debug("key, val, PlayerData.metadata[key]", key, val, PlayerData.metadata[key])
        currentRep = PlayerData.metadata[key][val] or 1
        lib.print.debug("currentRep", currentRep)

        local repModifier = math.min(currentRep // 25 * 0.01, 0.50)
        local finalModifier = baseMultiplier + repModifier
        lib.print.debug("Calculated new modifier as", finalModifier)
    
        valueToModify = valueToModify - (finalModifier * valueToModify)
        
        lib.print.debug("Ending calculateReputationModifier: valueToModify", valueToModify)
        return valueToModify
    end

    return valueToModify
end


function sudotext(text)
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

function deleteAllProps()
    for _, v in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cache.ped, v) then
            SetEntityAsMissionEntity(v, true, true)
            DeleteObject(v)
            DeleteEntity(v)
        end
    end
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

    if next(recipes_to_execute) == nil then
        lib.notify({
            title = 'Unable',
            description = "You're unable to make anything out of these ingredients",
            type = 'error'
        })
        return
    end
    
    for k,v in pairs(recipes_to_execute) do
        lib.print.debug("v", v.output[1].item)
        table.insert(moptions, {
            title = v.output[1].label,
            icon = "nui://ox_inventory/web/images/"..v.output[1].item..".png",
            onSelect = function() 
                lib.print.debug("Running vib_fabricator:server:fabricator")

                if lib.progressCircle({
                    duration = 15000,
                    position = 'bottom',
                    label = 'Fabricating',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        combat = true,
                        move = true,
                    },
                    anim = {
                        clip = 'machinic_loop_mechandplayer',
                        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                        flag = 1
                    },
                    prop = {
                        model = 'v_med_oscillator4',
                        bone = 60309,
                        pos = {x = 0.0, y = 0.0, z = 0.0},
                        rot = {x = 0.0, y = 0.0, z = 0.0}
                    }
                }) then 
                    deleteAllProps()
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
                else 
                    print('Do stuff when cancelled') 
                end
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

-- This could be made into a polyzone, and trigger on entry (to create the target).
-- I'll refactor this in another release.
CreateThread(function()
    while config.states.setup == false do
        lib.print.debug("config.states.setup, LocalPlayer.state.isLoggedIn", config.states.setup, LocalPlayer.state.isLoggedIn)

        if LocalPlayer.state.isLoggedIn == false then
            Wait(5000)
        else
            createTargets(config)
        end

        Wait(5000)
    end
end)
