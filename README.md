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
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = false, car = true, combat = true },
			usetime = 2500,
		},
		buttons = {
			{
				label = 'Activate',
				action = function(slot)
					TriggerEvent('vib_fabricator:client:fabricator', slot, 'small')
					exports.ox_inventory:closeInventory()
				end
			},
		}
	},

    ['large_fabricator'] = {
		label = 'Large Fabricator',
		description = 'A device (like a 3D printer) capable of making things',
		weight = 1000,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = false, car = true, combat = true },
			usetime = 2500,
		},
		buttons = {
			{
				label = 'Activate',
				action = function(slot)
					TriggerEvent('vib_fabricator:client:fabricator', slot, 'large')
					exports.ox_inventory:closeInventory()
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

## How to get support
https://discord.gg/PdjtgQKpvs