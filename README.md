# Fabricator

## How to install

### Configure ox_inventory
1. Copy install/*.png to ox_inventory/web/images
2. Copy the following item stanzas to ox_inventory/data/items.lua

```
	['small_fabricator'] = {
		label = 'Small Fabricator',
		description = 'A device (like a 3D printer) capable of making things',
		weight = 1000,
		stack = false,
		buttons = {
			{
				label = 'Activate',
				action = function(slot)
					TriggerEvent('vib_fabricator:client:fabricator', slot, 'small')
					exports.ox_inventory:closeInventory()
				end
			},
			{
				label = 'Get Battery (%)',
				action = function(slot)
					local item = exports.ox_inventory:Search('slots', 'small_fabricator')
					for _, v in pairs(item) do
						if (v.slot == slot) then 
							exports.ox_inventory:closeInventory()
							local metadata = v.metadata
							if metadata.chargelevel == nil then metadata.chargelevel = 0 end

							lib.print.debug("large_fabricator metadata", metadata)
							local alert = lib.alertDialog({
								header = 'Current Charge Level',
								content = '%'..tostring(metadata.chargelevel),
								centered = true,
								cancel = false
							})
						end
					end
				end
			},
		}
	},

    ['large_fabricator'] = {
		label = 'Large Fabricator',
		description = 'A device (like a 3D printer) capable of making things',
		weight = 1000,
		stack = false,
		buttons = {
			{
				label = 'Activate',
				action = function(slot)
					TriggerEvent('vib_fabricator:client:fabricator', slot, 'large')
					exports.ox_inventory:closeInventory()
				end
			},
			{
				label = 'Get Battery (%)',
				action = function(slot)
					local item = exports.ox_inventory:Search('slots', 'large_fabricator')
					for _, v in pairs(item) do
						if (v.slot == slot) then 
							exports.ox_inventory:closeInventory()
							local metadata = v.metadata
							if metadata.chargelevel == nil then metadata.chargelevel = 0 end

							lib.print.debug("large_fabricator metadata", metadata)
							local alert = lib.alertDialog({
								header = 'Current Charge Level',
								content = '%'..tostring(metadata.chargelevel),
								centered = true,
								cancel = false
							})
						end
					end
				end
			},
		}
	},

	['fabricator_battery'] = {
		label = 'Fabricator Battery',
		description = 'A battery for a small fabricator',
		weight = 1000,
		stack = true,
	},

```

3. Copy these stanzas into ox_inventory/modules/items/containers.lua
```
setContainerProperties('large_fabricator', {
	slots = 5,
	maxWeight = 20000,
	whitelist = { 'steel', 'copper_wire', 'metalscrap'}
})

setContainerProperties('small_fabricator', {
	slots = 3,
	maxWeight = 20000,
	whitelist = { 'steel', 'copper_wire', 'metalscrap', 'fabricator_battery'}
})
```

^ Customize these to add whatever items you want in your recipes.

4. Copy these stanzas into ox_inventory/data/shops.lua
```
	Fabricator = {
		name = 'Fabricator Supplies',
		blip = {
			id = 869,
			colour = 69,
			scale = 0.8
		},
		inventory = {
			{ name = 'large_fabricator', price = 50000 },
			{ name = 'small_fabricator', price = 25000 },
			{ name = 'fabricator_battery', price = 1000 },
		},
		locations = {
			vec3(1070.9, -2006.16, 31.08),
		},
		targets = {
			{
				ped = `ig_stevehains`,
				scenario = 'WORLD_HUMAN_WELDING',
				loc = vec3(1070.9, -2006.16, 31.08),
				heading = 324.99,
			},
		}
	},
```

### How to Configure
1. All of the recipes are stored in config/server.lua

```
return {
    locations = {
        large_fabricator_locations = {
            [1] = vector3(1069.31, -2005.35, 32.09),
        },
    },
    recipes = {
        [1] = { 
            input = { 
                { item = "steel", count = 1},
                { item = "metalscrap", count = 10},
            }, 
            output = {
                { label = "Lockpick", item = "lockpick", count = 1 },
            }
        },
        [2] = { 
            input = { 
                { item = "steel", count = 1},
                { item = "metalscrap", count = 10},
                { item = "copper_wire", count = 10},
            }, 
            output = {
                { label = "Advanced Lockpick", item = "advancedlockpick", count = 1 },
            }
        },
    },
}
```

This should be self-explainatory.

## How to get support
https://discord.gg/PdjtgQKpvs
