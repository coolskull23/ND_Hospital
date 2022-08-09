c48onfig = {
    maxHospitalTime = 600, -- Max time in seconds that someone can Hospital another player.
    hospitalDistance = 90.0, -- How far can the player go from the Hospital coordinates. If the player is further than the set amount they will be teleported back.

    hospitalCoords = {x = 354.76, y = -586.33, z = 43.32, h = 6.53}, -- Second Floor Pillbox Medical Center
    releaseCoords = {x = 296.4, y = -584.82, z = 43.13, h = 270.09}, -- Second Floor Pillbox Medical Center

    -- Where can players access it from.
    accessLocation = {
        {x = 1826.2, y = 3685.71, z = 34.27}, -- Sandy Shores Hospital
        {x = -263.81, y = 6313.53, z = 32.44}, -- Paleto Bay Hospital
        {x = 339.94, y = -582.5, z = 28.79}, -- First Floor Pillbox Medical Center
        {x = 308.47, y = -596.5, z = 43.29}, -- Second Floor Pillbox Medical Center
        {x = 342.83, y = -1400.29, z = 32.51} -- Center LS Medical Center
    },

    -- Departments that can access the hospital tablet.
    accessDepartments = {
        "SAHP",
        "LSPD",
        "BCSO",
        "LSFD"
    },

    -- How close does the player have to be to the coordiantes to be able to open the tablet.
    accessDistance = 1.2,
}

--[[
    MLO USED

    Sandy Shores Hospital - https://www.gta5-mods.com/maps/sandy-shores-hospital-mlo-interior-add-on-fivem
    Paleto Bay Hospital - https://www.gta5-mods.com/maps/mlo-paleto-bay-hospital-add-on-sp-fivem-ragemp
    First Floor Pillbox Medical Center - https://forum.cfx.re/t/release-pillbox-hospital-interior-mlo/609786
    Second Floor Pillbox Medical Center - https://forum.cfx.re/t/interior-map-pillbox-medical-center-top-floor/949788
    
]]