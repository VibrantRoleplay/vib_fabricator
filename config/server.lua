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