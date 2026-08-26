Config.DoseLimit = {
    same_drug = 10,
    mixed_drug = 5,
}

Config.Overdose = { -- will loose health 10 in every 1 second
    tick = 1,
    HealthLose = 3,
}

Config.AddictionLevel = {   -- max 99
    low  = {    
        level = 30, health_lose = 10, tick = 30, period = 15,       -- player will lose 10 health in every 30 sec after 15 minutes to reach the level
        passout_chance = 10, vomit_chance = 30, chance_tick = 10,   -- will check for passout & vomit in every 2 minutes
    },  
    mid  = {
        level = 50, health_lose = 10,  tick = 15, period = 10,       -- player will lose 5 health in every 10 sec after 10 minutes to reach the level
        passout_chance = 20, vomit_chance = 50, chance_tick = 5,    -- will check for passout & vomit in every 5 minutes
    },  
    high = {
        level = 75, health_lose = 10,  tick = 3,  period = 5,        -- player will lose 1 health in every 1 sec after 5 minutes to reach the level
        passout_chance = 30, vomit_chance = 70, chance_tick = 1,    -- will check for passout & vomit in every 1 minute
    },
}

Config.AddictionReduce = {   -- addiction Level reduce
    tick = 5,                -- every 5 minute
    amount = 2
}

Config.AddictionEffect = {  -- make false if you don't want any effect
    MotionBlur      = true,
    ScreenEffect    = {enable = true, effect = 'Drug_gas_huffin', strength = 0.1},
    ScreenShake     = {enable = true, strength = 0.15},
    WalkStyle       = {enable = true, style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK'},
}

Config.ToleranceReduce = {  -- tolerance Level reduce
    tick = 10,       -- every 5 minute
    amount = 2
}

Config.DatabaseSave = 2 -- every 5 minutes

Config.BongMaxSound = 0.3

Config.Usables = {
    weed_joint = {
        Type = 'smoke',
        ObjPlacement = {
            obj = `p_amb_joint_01`,             -- Object name
            x  = 0.15, y  = 0.015, z  = 0.0,    -- position x, position y, position z
            rx = 0.0,  ry = 90.0,  rz = 0       -- rotation x, rotation y, rotation z
        }, 
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = true, startAfter = 30, endAfter = 200},
        ScreenShake         = {enable = true, strength = 2.5, startAfter = 30, endAfter = 320},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            [1] = {strength = 1.0, setAfter = 0}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10}, -- spectator5 is a timecycle modifier name [https://wiki.rage.mp/index.php?title=Timecycle_Modifiers]
            [2] = {effect = 'spectator5', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator5', strength = 0.4, setAfter = 150},
            [4] = {effect = 'spectator5', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            -- [1] = {value = 10, addAfter = 5},
            -- [2] = {value = 15, addAfter = 15},
            -- [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 15},          --1st movement style will set after 15 seconds [https://docs.fivem.net/natives/?_0xAF8A94EDE7712BEF]
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 30},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 300},
            [4] = {style = 'Default', startAfter = 350},                            --Back to default after 300 seconds
        },
        StressRelieve = 250000, --
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            lighter = {quantity = 1, removable = false},
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 0,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    flakka_joint = {
        Type = 'smoke',
        ObjPlacement = {
            obj = `p_amb_joint_01`,             -- Object name
            x  = 0.15, y  = 0.015, z  = 0.0,    -- position x, position y, position z
            rx = 0.0,  ry = 90.0,  rz = 0       -- rotation x, rotation y, rotation z
        }, 
        TotalTime           = 300,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = true, strength = 1.0, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 15, endAfter = 200},
        RunSpeedCycle = {
            [1] = {strength = 1.2, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.3, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'BikerForm01', strength = 0.1, setAfter = 10},
            [2] = {effect = 'BikerForm01', strength = 0.5, setAfter = 30},
            [3] = {effect = 'BikerForm01', strength = 0.7, setAfter = 60},
            [4] = {effect = 'BikerForm01', strength = 0.4, setAfter = 150},
            [5] = {effect = 'BikerForm01', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            lighter = {quantity = 1, removable = false},
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    spice_joint = {
        Type = 'smoke',
        ObjPlacement = {
            obj = `p_amb_joint_01`,             -- Object name
            x  = 0.15, y  = 0.015, z  = 0.0,    -- position x, position y, position z
            rx = 0.0,  ry = 90.0,  rz = 0       -- rotation x, rotation y, rotation z
        }, 
        TotalTime           = 350,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 30, endAfter = 200},  --Difficulty driving
        ScreenShake         = {enable = true, strength = 3.5, startAfter = 30, endAfter = 320},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 10, endAfter = 60},
        RunSpeedCycle = {
            [1] = {strength = 1.0, setAfter = 0}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'Dont_tazeme_bro', strength = 0.1, setAfter = 10},
            [2] = {effect = 'Dont_tazeme_bro', strength = 0.6, setAfter = 60},
            [3] = {effect = 'Dont_tazeme_bro', strength = 0.7, setAfter = 150},
            [4] = {effect = 'Dont_tazeme_bro', strength = 0.9, setAfter = 240},
            [5] = {effect = 'Dont_tazeme_bro', strength = 0.8, setAfter = 300},
            [6] = {effect = 'Dont_tazeme_bro', strength = 0.0, setAfter = 400},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 15}, 
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 30},  
            [3] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK', startAfter = 40},  
            [4] = {style = 'MOVE_M@DRUNK@VERYDRUNK', startAfter = 60}, 
            [5] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK', startAfter = 250},
            [6] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 300},
            [7] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 350},
            [8] = {style = 'Default', startAfter = 350},
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            lighter = {quantity = 1, removable = false},
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    dab = {
        Type = 'bong',
        TotalTime           = 350,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 30, endAfter = 200},  --Difficulty driving
        ScreenShake         = {enable = true, strength = 3.5, startAfter = 30, endAfter = 320},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 10, endAfter = 60},
        RunSpeedCycle = {
            [1] = {strength = 1.0, setAfter = 0}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'Dont_tazeme_bro', strength = 0.1, setAfter = 10},
            [2] = {effect = 'Dont_tazeme_bro', strength = 0.6, setAfter = 60},
            [3] = {effect = 'Dont_tazeme_bro', strength = 0.7, setAfter = 150},
            [4] = {effect = 'Dont_tazeme_bro', strength = 0.9, setAfter = 240},
            [5] = {effect = 'Dont_tazeme_bro', strength = 0.8, setAfter = 300},
            [6] = {effect = 'Dont_tazeme_bro', strength = 0.0, setAfter = 400},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 15}, 
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 30},  
            [3] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK', startAfter = 40},  
            [4] = {style = 'MOVE_M@DRUNK@VERYDRUNK', startAfter = 60}, 
            [5] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK', startAfter = 250},
            [6] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 300},
            [7] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 350},
            [8] = {style = 'Default', startAfter = 350},
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            lighter = {quantity = 1, removable = false},
            bong = {quantity = 1, removable = false},
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    coke_rail = {
        Type = 'nose_inhale',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = true, strength = 1.5, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 15, endAfter = 200},
        RunSpeedCycle = {
            [1] = {strength = 1.2, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.3, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'BikerForm01', strength = 0.1, setAfter = 10},
            [2] = {effect = 'BikerForm01', strength = 0.5, setAfter = 30},
            [3] = {effect = 'BikerForm01', strength = 0.7, setAfter = 60},
            [4] = {effect = 'BikerForm01', strength = 0.4, setAfter = 150},
            [5] = {effect = 'BikerForm01', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    bathsalts = {
        Type = 'nose_inhale',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = true, strength = 1.5, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 15, endAfter = 200},
        RunSpeedCycle = {
            [1] = {strength = 1.2, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.3, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'BikerForm01', strength = 0.1, setAfter = 10},
            [2] = {effect = 'BikerForm01', strength = 0.5, setAfter = 30},
            [3] = {effect = 'BikerForm01', strength = 0.7, setAfter = 60},
            [4] = {effect = 'BikerForm01', strength = 0.4, setAfter = 150},
            [5] = {effect = 'BikerForm01', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    ketamine = {
        Type = 'nose_inhale',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = true, strength = 1.5, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = true, startAfter = 15, endAfter = 200},
        RunSpeedCycle = {
            [1] = {strength = 1.2, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.3, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'BikerForm01', strength = 0.1, setAfter = 10},
            [2] = {effect = 'BikerForm01', strength = 0.5, setAfter = 30},
            [3] = {effect = 'BikerForm01', strength = 0.7, setAfter = 60},
            [4] = {effect = 'BikerForm01', strength = 0.4, setAfter = 150},
            [5] = {effect = 'BikerForm01', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    speedball = {
        Type = 'inject',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = true, strength = 1.3, startAfter = 10, endAfter = 350},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 350},
        Stamina             = {enable = true, startAfter = 15, endAfter = 400},
        RunSpeedCycle = {
            [1] = {strength = 1.2, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.49, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'BikerForm01', strength = 0.1, setAfter = 10},
            [2] = {effect = 'BikerForm01', strength = 0.5, setAfter = 30},
            [3] = {effect = 'BikerForm01', strength = 0.7, setAfter = 60},
            [4] = {effect = 'BikerForm01', strength = 0.4, setAfter = 150},
            [5] = {effect = 'BikerForm01', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 20, addAfter = 15},
            [3] = {value = 20, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 45000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    meth_shot = {
        Type = 'inject',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 250},
        ScreenShake         = {enable = true, strength = 1.4, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 20}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 350}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'Drug_gas_huffin', strength = 0.1, setAfter = 10},
            [2] = {effect = 'Drug_gas_huffin', strength = 0.5, setAfter = 30},
            [3] = {effect = 'Drug_gas_huffin', strength = 0.8, setAfter = 60},
            [4] = {effect = 'Drug_gas_huffin', strength = 0.4, setAfter = 150},
            [5] = {effect = 'Drug_gas_huffin', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            
        },
        WalkStyleCycle = {
            [1] = {style = 'move_m@casual@e', startAfter = 15},         --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 35000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    heroin_shot = {
        Type = 'inject',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 250},
        ScreenShake         = {enable = true, strength = 1.2, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            
        },
        EffectCycle = {
            [1] = {effect = 'Drug_gas_huffin', strength = 0.1, setAfter = 10},
            [2] = {effect = 'Drug_gas_huffin', strength = 0.5, setAfter = 30},
            [3] = {effect = 'Drug_gas_huffin', strength = 0.8, setAfter = 60},
            [4] = {effect = 'Drug_gas_huffin', strength = 0.4, setAfter = 150},
            [5] = {effect = 'Drug_gas_huffin', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            
        },
        WalkStyleCycle = {
            [1] = {style = 'move_m@casual@e', startAfter = 15},         --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 35000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    blacktar = {
        Type = 'inject',
        TotalTime           = 300,  -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 250},
        ScreenShake         = {enable = true, strength = 1.2, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            
        },
        EffectCycle = {
            [1] = {effect = 'Drug_gas_huffin', strength = 0.1, setAfter = 10},
            [2] = {effect = 'Drug_gas_huffin', strength = 0.5, setAfter = 30},
            [3] = {effect = 'Drug_gas_huffin', strength = 0.8, setAfter = 60},
            [4] = {effect = 'Drug_gas_huffin', strength = 0.4, setAfter = 150},
            [5] = {effect = 'Drug_gas_huffin', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {
            
        },
        WalkStyleCycle = {
            [1] = {style = 'move_m@casual@e', startAfter = 15},         --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 350},                    --Back to default after 300 seconds
        },
        StressRelieve = 35000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    lean = {
        Type = 'drink',
        ObjPlacement = {
            obj = `p_amb_coffeecup_01`,             -- Object name
            x  = 0.14, y  = -0.03, z  = -0.08,  -- position x, position y, position z
            rx = -60.0,  ry = 40.0,  rz = 0         -- rotation x, rotation y, rotation z
        }, 
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 30, endAfter = 200},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            
        },
        EffectCycle = {
            [1] = {effect = 'spectator7', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator7', strength = 1.0, setAfter = 60},
            [3] = {effect = 'spectator7', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 15},          --1st movement style will set after 15 seconds
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 30},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 300},
            [4] = {style = 'Default', startAfter = 350},                            --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 0,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    oxycodone = {
        Type = 'pill',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 30, endAfter = 200},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 20, endAfter = 300},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            
        },
        EffectCycle = {
            [1] = {effect = 'spectator7', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator7', strength = 1.0, setAfter = 60},
            [3] = {effect = 'spectator7', strength = 0.0, setAfter = 240},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 15},          --1st movement style will set after 15 seconds
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 30},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 300},
            [4] = {style = 'Default', startAfter = 350},                            --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 0,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    shroom_cut = {
        Type = 'eat',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 150},
        ScreenShake         = {enable = true, strength = 2.5, startAfter = 5, endAfter = 140},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 160},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {
            
        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator5', strength = 0.5, setAfter = 30},
            [3] = {effect = 'spectator5', strength = 1.0, setAfter = 60},
            [4] = {effect = 'spectator5', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 10},          --1st movement style will set after 15 seconds
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 20},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 160},
            [4] = {style = 'Default', startAfter = 200},                            --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    perc = {
        Type = 'pill',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 160},
        Stamina             = {enable = true, startAfter = 10, endAfter = 180},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 300}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator8', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator8', strength = 0.8, setAfter = 60},
            [3] = {effect = 'spectator8', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    adderall = {
        Type = 'pill',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 160},
        Stamina             = {enable = true, startAfter = 10, endAfter = 180},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 300}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator8', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator8', strength = 0.8, setAfter = 60},
            [3] = {effect = 'spectator8', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    angeldust = {
        Type = 'pill',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 160},
        Stamina             = {enable = true, startAfter = 10, endAfter = 180},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 300}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator8', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator8', strength = 0.8, setAfter = 60},
            [3] = {effect = 'spectator8', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    blacklightning = {
        Type = 'pill',
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 160},
        Stamina             = {enable = true, startAfter = 10, endAfter = 180},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.3, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.3, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 300}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator8', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator8', strength = 0.8, setAfter = 60},
            [3] = {effect = 'spectator8', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 15, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    opium_joint = {
        Type = 'smoke',
        ObjPlacement = {
            obj = `p_amb_joint_01`,             -- Object name
            x  = 0.15, y  = 0.015, z  = 0.0,    -- position x, position y, position z
            rx = 0.0,  ry = 90.0,  rz = 0       -- rotation x, rotation y, rotation z
        },
        TotalTime           = 200,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 200},
        ScreenShake         = {enable = true, strength = 1.2, startAfter = 10, endAfter = 180},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 180},
        Stamina             = {enable = true, startAfter = 10, endAfter = 180},
        RunSpeedCycle = {

        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator5', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator5', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            lighter = {quantity = 1, removable = false},
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    fentanyl_pill = {
        Type = 'pill',
        TotalTime           = 250,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 10, endAfter = 220},
        ScreenShake         = {enable = true, strength = 2.1, startAfter = 12, endAfter = 210},
        MotionBlur          = {enable = true, startAfter = 10, endAfter = 200},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {

        },
        EffectCycle = {
            [1] = {effect = 'spectator9', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator9', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator9', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 10},          --1st movement style will set after 15 seconds
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 20},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 180},
            [4] = {style = 'Default', startAfter = 220},                            --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    xpill = {
        Type = 'pill',
        TotalTime           = 350,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = false, startAfter = 0, endAfter = 0},
        ScreenShake         = {enable = false, strength = 0, startAfter = 0, endAfter = 0},
        MotionBlur          = {enable = false, startAfter = 0, endAfter = 0},
        Stamina             = {enable = true, startAfter = 10, endAfter = 320},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 250}, -- default run speed 1.0 and max 1.49
            [4] = {strength = 1.0, setAfter = 320}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator1', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator1', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator1', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {
            [1] = {value = 10, addAfter = 5},
            [2] = {value = 15, addAfter = 15},
            [3] = {value = 25, addAfter = 35},
        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    molly = {
        Type = 'pill',
        TotalTime           = 280,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 5, endAfter = 250},
        ScreenShake         = {enable = true, strength = 2.4, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 250},
        Stamina             = {enable = true, startAfter = 10, endAfter = 150},
        RunSpeedCycle = {
            [1] = {strength = 1.1, setAfter = 10}, -- default run speed 1.0 and max 1.49
            [2] = {strength = 1.2, setAfter = 40}, -- default run speed 1.0 and max 1.49
            [3] = {strength = 1.2, setAfter = 220}, -- default run speed 1.0 and max 1.49
        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator5', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator5', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@GANGSTER@VAR_E', startAfter = 15},       --1st movement style will set after 15 seconds
            [2] = {style = 'Default', startAfter = 250},                    --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    xanax = {
        Type = 'pill',
        TotalTime           = 280,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 5, endAfter = 250},
        ScreenShake         = {enable = true, strength = 2.4, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 250},
        Stamina             = {enable = true, startAfter = 10, endAfter = 150},
        RunSpeedCycle = {

        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator5', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator5', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {

        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
    lsd = {
        Type = 'pill',
        TotalTime           = 280,  -- seconds
        RemoveTimeOnUse     = 25,   -- seconds
        DrivingDificulty    = {enable = true, startAfter = 5, endAfter = 250},
        ScreenShake         = {enable = true, strength = 2.4, startAfter = 10, endAfter = 250},
        MotionBlur          = {enable = true, startAfter = 8, endAfter = 250},
        Stamina             = {enable = false, startAfter = 0, endAfter = 0},
        RunSpeedCycle = {

        },
        EffectCycle = {
            [1] = {effect = 'spectator5', strength = 0.1, setAfter = 10},
            [2] = {effect = 'spectator5', strength = 0.6, setAfter = 60},
            [3] = {effect = 'spectator5', strength = 0.0, setAfter = 180},
        },
        AddArmourCycles = {

        },
        WalkStyleCycle = {
            [1] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 10},          --1st movement style will set after 15 seconds
            [2] = {style = 'MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP', startAfter = 20},  --2nd movement style will set after 15 seconds
            [3] = {style = 'MOVE_M@DRUNK@SLIGHTLYDRUNK', startAfter = 180},
            [4] = {style = 'Default', startAfter = 220},                            --Back to default after 300 seconds
        },
        StressRelieve = 25000,
        Relieve = function(value)
            -- place your stress relieve code here
            TriggerEvent('esx_status:remove', 'stress', value)
        end,
        required = {
            
        },
        stayInTheBlood = 5, -- drug will stay in your blood (in minute)
        addAddiction = 10,  -- high addiction will lead player to health issues & death
        addTolerance = 2,   -- high tolerance will prevent player from vomiting and passout
        passOutChance = 30, -- chance in percent between 0 - 100
        vomitChance = 50,   -- chance in percent between 0 - 100
    },
}

--Vehicle Control Config
--Don't touch if you don't know what you are doing
Config.ApplyForceFor = {min = 1, max = 3} -- second
Config.NextForceIntervel = {min = 5, max = 10} --second
Config.VehicleControl = {
    left_force = { --maximum value 1.0, higher value makes harder to drive
        [1] = 0.010,
        [2] = 0.011,
        [3] = 0.012,
        [4] = 0.014,
        [5] = 0.015,
        [6] = 0.016,
        [7] = 0.017,
        [8] = 0.018,
        [9] = 0.019,
        [10] = 0.020,
    },
    right_force = { --minimum value -1.0, lower value makes harder to drive
        [1] = -0.010,
        [2] = -0.011,
        [3] = -0.012,
        [4] = -0.014,
        [5] = -0.015,
        [6] = -0.016,
        [7] = -0.017,
        [8] = -0.018,
        [9] = -0.019,
        [10] = -0.020,
    },
}
Config.LooseGripFor = {min = 1, max = 3} --second
