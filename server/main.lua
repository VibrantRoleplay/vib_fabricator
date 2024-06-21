-------------
-- Configs --
-------------
local config = require 'config.server'
local sharedConfig = require 'config.shared'
QBCore = nil

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
lib.addCommand('setfabrep', {
    help = 'Set fabrication rep',
    params = {
        {
            name = "reputation",
            type = "integer",
        },
    },
    restricted = "group.god"
}, function(source, args, raw)
    lib.print.debug("config.framework", config.framework)
    if config.framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayer(source)

        local rep = Player.PlayerData.metadata["jobrep"]
        lib.print.debug("Old Rep: ", rep)
        rep.fabricator = args.reputation
        Player.Functions.SetMetaData("jobrep", rep)
    end
end)

lib.addCommand('fabricator', {
    help = 'Show fabrication rep',
    restricted = "group.god"
}, function(source, args, raw)
    lib.print.debug("config.framework", config.framework)
    if config.framework == "qbcore" then
        local Player = QBCore.Functions.GetPlayer(source)

        local rep = Player.PlayerData.metadata["jobrep"].fabricator or 1
        lib.notify(source,{
            title = "Fabricator Rep",
            description = "Reputation: "..rep,
            type = 'success',
            duration = 5000
        })
    end
end)

---------------
-- Functions --
---------------

------------
-- Events --
------------
RegisterNetEvent("vib_fabricator:server:setframework", function(framework)
    local src = source
    config.framework = framework
    if framework == "qbcore" then
        QBCore = exports["qb-core"]:GetCoreObject()
    end
end)

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

