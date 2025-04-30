return {
    -- Hospital check-in
    checkInCost    = 2000,  -- Price for using the hospital check-in system
    minForCheckIn  = 2,     -- Minimum on-duty EMS required to block the pay check-in
  
    -- Core locations
    locations = {
        duty = {
            vec3(310.39, -597.07, 43.28),
            vec3(-256.58, 6326.68, 32.43),
        },
        vehicle = {
            vec4(294.578, -574.761, 43.179, 35.79),
            vec4(-234.28, 6329.16, 32.15, 222.5),
        },
        helicopter = {
            vec4(351.58, -587.45, 74.16, 160.5),
            vec4(-475.43, 5988.353, 31.716, 31.34),
        },
        armory = {
            {
                shopType = 'AmbulanceArmory',
                name     = 'Armory',
                groups   = { ambulance = 0 },
                inventory = {
                    { name = 'radio',             price = 0 },
                    { name = 'bandage',           price = 0 },
                    { name = 'painkillers',       price = 0 },
                    { name = 'firstaid',          price = 0 },
                    { name = 'weapon_flashlight', price = 0 },
                    { name = 'weapon_fireextinguisher', price = 0 },
                },
                locations = {
                    vec3(310.33, -602.97, 43.28),
                },
            }
        },
        roof = {
            vec3(338.54, -583.88, 74.17),
        },
        main = {
            vec3(332.27, -595.81, 43.28),
        },
        stash = {
            {
                name    = 'ambulanceStash',
                label   = 'Personal stash',
                weight  = 100000,
                slots   = 30,
                groups  = { ambulance = 0 },
                owner   = true, -- Set to false for shared group stash
                location= vec3(302.0, -599.4, 43.28),
            }
        },
  
        -- Hospitals / beds
        hospitals = {
            pillbox = {
                coords  = vec3(350, -580, 43),
                checkIn = vec3(307.0, -595.05, 43.28),
                beds = {
                    { coords = vec4(313.88, -579.07, 44.2, 339.77), model = 1631638868 },
                    { coords = vec4(309.3,  -577.31, 44.2, 333.94), model = 1631638868 },
                    { coords = vec4(307.67, -581.71, 44.2, 163.18), model = 1631638868 },
                    { coords = vec4(311.19, -582.76, 44.2, 160.66), model = 1631638868 },
                    { coords = vec4(314.5,  -584.1,  44.2, 155.74), model = 1631638868 },
                    { coords = vec4(317.65, -585.33, 44.2, 159.99), model = 1631638868 },
                    { coords = vec4(322.63, -587.07, 44.2, 157.96), model = 1631638868 },
                    { coords = vec4(324.26, -582.95, 44.2, 334.44), model = 1631638868 },
                    { coords = vec4(319.37, -581.14, 44.2, 338.65), model = 1631638868 },
                    { coords = vec4(354.12, -593.12, 43.1,  336.32), model = 2117668672 },
                    { coords = vec4(350.79, -591.8,  43.1,  336.32), model = 2117668672 },
                    { coords = vec4(346.99, -590.48, 43.1,  336.32), model = 2117668672 },
                    { coords = vec4(360.32, -587.19, 43.02, 152.08), model = -1091386327 },
                    { coords = vec4(349.82, -583.33, 43.02, 152.08), model = -1091386327 },
                    { coords = vec4(326.98, -576.17, 43.02, 152.08), model = -1091386327 },
                },
            },
            paleto = {
                coords  = vec3(-250, 6315, 32),
                checkIn = vec3(-254.54, 6331.78, 32.43),
                beds = {
                    { coords = vec4(-252.43, 6312.25, 32.34, 313.48), model = 2117668672 },
                    { coords = vec4(-247.04, 6317.95, 32.34, 134.64), model = 2117668672 },
                    { coords = vec4(-255.98, 6315.67, 32.34, 313.91), model = 2117668672 },
                },
            },
            jail = {
                coords = vec3(1761, 2600, 46),
                beds = {
                    { coords = vec4(1761.96, 2597.74, 45.66, 270.14), model = 2117668672 },
                    { coords = vec4(1761.96, 2591.51, 45.66, 269.80), model = 2117668672 },
                    { coords = vec4(1771.80, 2598.02, 45.66,  89.05), model = 2117668672 },
                    { coords = vec4(1771.85, 2591.85, 45.66,  91.51), model = 2117668672 },
                },
            },
        },
  
        stations = {
            { label  = 'Pillbox Hospital', coords = vec4(304.27, -600.33, 43.28, 272.249) },
        },
    },
  
    ----------------------------------------------------------------
    -- New Medical Items for PRP NUI / Defib System
    ----------------------------------------------------------------
    MedicalItems = {
        medic_bag      = 'medic_bag',       -- useable bag to inspect patients
        defibrillator  = 'defibrillator',   -- revives downed players
        tourniquet     = 'tourniquet',
        field_dressing = 'field_dressing',
        elastic_bandage= 'elastic_bandage',
        quick_clot     = 'quick_clot',
        packing_bandage= 'packing_bandage',
        surgical_kit   = 'surgical_kit',
        epi_pen        = 'epi_pen',
        morphine       = 'morphine',
        painkiller     = 'painkiller',
    }
  }
  