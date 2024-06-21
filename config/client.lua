return {
    debug = true,

    -- Determines how to often to degrade max battery.
    -- Increase the max to make it more rare. min = 1, max = 5 = 20% chance.
    batteryDecay = {
        min = 1,
        max = 5,
    },

    -- Default charge duration
    batteryChargeDuration = 30000,

    -- Reputation multiplier; currently 1%. 
    batteryRepMultiplier = .01,

    -- Reputation Storage
    -- Currently supported reputation storages: PlayerData.
    -- the key is where to store it in PlayerData, and the value is the rep name.
    repStorage = {
        type = "PlayerData",
        key = "jobrep",
        val = "fabricator",
    },

    -- This is how much % battery we use per use.
    batteryDrainPerUse = 5,

    -- This is how much reputation effects batteryDrainPerUse.
    batteryDrainPerUseMultiplier = .01,

    states = {
        setup = false,
        rope = nil,
    },

}