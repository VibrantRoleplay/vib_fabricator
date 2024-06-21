-------------
-- Configs --
-------------
local config = require 'config.server'
local sharedConfig = require 'config.shared'

---------------
-- Callbacks --
---------------
lib.callback.register('vib_fabricator:server:getcontaineritems', function(containerId, slotId)
    return exports.ox_inventory:GetContainerFromSlot(containerId, slotId)
end)

lib.callback.register('vib_fabricator:server:getrecipes', function(source)
    return config.recipes
end)

lib.callback.register('vib_fabricator:server:getconfig', function(source)
    return config
end)

--------------
-- Commands --
--------------


---------------
-- Functions --
---------------

------------
-- Events --
------------
RegisterNetEvent("vib_fabricator:server:fabricator", function(recipe, id)
    local src = source
    lib.print.debug("Running vib_fabricator:server:fabricator")
    for _, v in pairs(recipe.input) do
        local item = v.item
        local count = v.count
        exports.ox_inventory:RemoveItem(id, item, count)
    end

    exports.ox_inventory:AddItem(src, recipe.output[1].item, recipe.output[1].count)
end)

RegisterNetEvent("vib_fabricator:server:removebattery", function(id)
    local src = source
    lib.print.debug("Running vib_fabricator:server:removebattery")
    exports.ox_inventory:RemoveItem(id, 'fabricator_battery', 1)
end)

RegisterNetEvent("vib_fabricator:server:setmetadata", function(slot, metadata)
    local src = source
    lib.print.debug("Running vib_fabricator:server:setmetadata on", src, slot, metadata)
    exports.ox_inventory:SetMetadata(src, slot, metadata)
end)

