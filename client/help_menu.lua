RegisterNetEvent('vib_fabricator:client:helpmenu', function(size)
    lib.print.debug("Running vib_fabricator:client:helpmenu with size", size)

    ---------------------------------
    -- Help Screen String Literals --
    ---------------------------------
    -- I absolutely hate how string literals get fucked up when you indent them. If there is a better way to do this, make a PR.
    
    local small_what_is = [[
# Overview
From the labs of Vibrant Enterprise in Los Santos emerges the fabricator, crafted from military-grade titanium alloys and advanced quantum processing units. Designed for efficiency and precision, this sleek device transforms base materials—steel, electronics, plastics, and precision components—into custom items. It integrates seamlessly into operational environments, embodying Vibrant Enterprise's commitment to innovation and excellence in manufacturing within the competitive underworld of Los Santos.

# A few things:
1. You need to charge the battery, there is documentation on this in the main documentation.
2. To load it, you need to click 'use'. It will open the fabricator and you place your items.
3. To use it, you need to click 'Activate'. This will attempt to make something with the items you have placed inside.
4. If nothing happens, then you did not get the right combination.
    ]]

    local small_charge_battery = [[
# Instructions
1. Purchase a battery from the sales man in the Fabricator Room off the Smelter.
2. Place the battery inside the small fabricator.
3. Press activate.

# Notes
1. Frequent battery charges will degrade it over time. So you may need to purchase a new fabricator if the max battery gets too low.
2. Large Fabricators require no batteries, so are a better investment, but you cannot use them outside of the fabricator room.
3. Batteries are expensive, and you can craft batteries from materials you get from mining at a crafting bench.
    ]]

    local small_what_can_i_make = [[
# Overview
You can make all sorts of things with the Fabricator! It's not our job to discover these for you however! Experiment! Here at Vibrant Enteprise, we emplore you to put your scientific mind to use. THINK.

# Sample
As an example, if you combine:

1. 1x steel
2. 10x metal scrap

You will get a lockpick.

If you combine one more ingredient, you would get a more advanced lockpick.

# Notes
1. Small Fabricators can only load 3 ingredients. So you cannot make everything with this.
    ]]

    if size == "small" then
        lib.registerContext({
        id = 'small_fabricator',
        title = 'Vibrant Fabricator Manufacturer Documentation',
        menu = 'small_fabricator',
        options = {
            {
                title = 'What is a fabricator?',
                icon = "fa-question-circle",
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'What is a fabricator?',
                        content = small_what_is,
                        centered = true,
                        cancel = false
                    })
                end,
            },
            {
                title = 'How do I charge the battery?',
                icon = "fa-battery-quarter",
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'How do I charge the battery?',
                        content = small_charge_battery,
                        centered = true,
                        cancel = false
                    })
                end,
            },
            {
                title = 'What things can I make with a small fabricator?',
                icon = "fa-tools",
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'What things can I make?',
                        content = small_what_can_i_make,
                        centered = true,
                        cancel = false
                    })
                end,
            },
        }
        })
    
        lib.showContext('small_fabricator')
    end


    local large_what_is = [[
# Overview
From the labs of Vibrant Enterprise in Los Santos emerges the fabricator, crafted from military-grade titanium alloys and advanced quantum processing units. Designed for efficiency and precision, this sleek device transforms base materials—steel, electronics, plastics, and precision components—into custom items. It integrates seamlessly into operational environments, embodying Vibrant Enterprise's commitment to innovation and excellence in manufacturing within the competitive underworld of Los Santos.

# A few things:
1. You need to charge the fabricator, there is documentation on this in the main documentation.
2. To load it, you need to click 'use'. It will open the fabricator and you place your items.
3. To use it, you need to click 'Activate'. This will attempt to make something with the items you have placed inside.
4. If nothing happens, then you did not get the right combination.
    ]]

    local large_charge_battery = [[
# Instructions
Unlike the Small Fabricator, there is no battery. You must connect to the Large Fabricator Power Source - to charge the internal power source.

1. Walk up the Large Fabricator Power Source (near where you buy the fabricator)
2. Select 'Attach and Charge Fabricator'
3. You are now charged, and you can use the fabricator. 

# Notes
1. You can only have 1 large fabricator on you to charge it.
2. You must remain attached to use the Large Fabricator.
    ]]

    local large_what_can_i_make = [[
# Overview
You can make all sorts of things with the Fabricator! It's not our job to discover these for you however! Experiment! Here at Vibrant Enteprise, we emplore you to put your scientific mind to use. THINK.

# Sample
As an example, if you combine:

1. 1x steel
2. 10x metal scrap

You will get a lockpick.

If you combine one more ingredient, you would get a more advanced lockpick.

# Notes
1. Large Fabricators can load 5 ingredients. So you can make everything with this.
    ]]

    if size == "large" then
        lib.registerContext({
            id = 'large_fabricator',
            title = 'Vibrant Fabricator Manufacturer Documentation',
            menu = 'large_fabricator',
            options = {
                {
                    title = 'What is a fabricator?',
                    icon = "fa-question-circle",
                    onSelect = function()
                        lib.print.debug("Running xxx")
                        local alert = lib.alertDialog({
                            header = 'What is a fabricator?',
                            content = large_what_is,
                            centered = true,
                            cancel = false
                        })
                    end,
                },
                {
                    title = 'How do I charge the battery?',
                    icon = "fa-battery-quarter",
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = 'How do I charge the battery?',
                            content = large_charge_battery,
                            centered = true,
                            cancel = false
                        })
                    end,
                },
                {
                    title = 'What things can I make with a Large fabricator?',
                    icon = "fa-tools",
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = 'What things can I make?',
                            content = large_what_can_i_make,
                            centered = true,
                            cancel = false
                        })
                    end,
                },
            }
        })
    
        lib.showContext('large_fabricator')
    end
end)
