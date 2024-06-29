# Fabricator

## How does it work
vib_fabricator is an ox_inventory container based crafting resource. It works by placing ingredients inside an ox_inventory container, and then pressing 'activate' to explore what things you can create with the items you put in the container.

It has a 'charging' concept, where you need to either be attached (using a rope native) to a power source, OR the portable fabricator can be charged using an external battery.

Battery levels are tracked in the metadata of the item, so no database components.

## How you use the items

### Large Fabricator
1. Purchase the fabricator from the shop.
2. Right click on the item, and press 'Use'.
3. Place your items in the item on the right side of your inventory.
4. Walk to the power source (near the shop), and use ox_target to look at the power source.
5. Click 'Attach and Charge'. This charges your fabricator, and you're ready to use it.
6. While still attached, right click on the item, and press 'Activate'.

An ox_lib context menu you pop up, and give you a menu of items you can make with those ingredients. Click one, and enjoy.

### Small Fabricator
1. Purchase the fabricator AND a battery from the shop.
2. Right click on the item, and press 'Use'.
3. Place the battery in the right side of your inventory.
4. Press Activate.
5. Your battery is now charged and you can take this anywhere.
6. Use it like you would the large_fabricator.

NOTE: small fabricators can only use 3 ingredients, large fabricator can do 5.

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
			{
				label = 'Fabricator Documentation',
				action = function(slot)
					exports.ox_inventory:closeInventory()
					TriggerEvent('vib_fabricator:client:helpmenu', 'small')
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
				label = 'Fabricator Documentation',
				action = function(slot)
					exports.ox_inventory:closeInventory()
					TriggerEvent('vib_fabricator:client:helpmenu', 'large')
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

3. Copy these stanzas into ox_inventory/modules/items/containers.lua. Make sure you customize the whitelist, for the ingredients you want to allow. (Steel, copper_wire, metalscrap etc).
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

4. Copy these stanzas into ox_inventory/data/shops.lua
```
	Fabricator = {
		name = 'Fabricator Supplies',
		blip = {
			id = 402,
			colour = 69,
			scale = 1.5,
		},
		inventory = {
			{ name = 'large_fabricator', price = 50000 },
			{ name = 'small_fabricator', price = 25000 },
			{ name = 'fabricator_battery', price = 5000 },
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

## Install vib_fabricator
1. Drag and drop the resource into your resources folder.
2. Double check you have the required pre-requisites (ox_lib and ox_inventory)
3. Double check you are using a supported framework (qbox/qbcore)

## How to get support
https://discord.gg/PdjtgQKpvs