Config = {}

Config.DispatchAllowedJobs = { 'police' }

Config.MaxDispatchAlerts = 5

Config.Shooting = {
    Enable = true,
    CooldownSeconds = 180,
    AlertJobs = { 'police' },
    IgnoreJobs = { 'police'},
    WhitelistWeapons = {
        [`WEAPON_UNARMED`] = true,
        [`WEAPON_STUNGUN`] = true,
        [`WEAPON_GREENREEK`] = true,
        [`WEAPON_COMBATPISTOL`] = true,
        [`WEAPON_FLARE`] = true,
        [`WEAPON_SMOKEGRENADE`] = true,
        [`WEAPON_BZGAS`] = true,
        [`WEAPON_FIREEXTINGUISHER`] = true,
        [`WEAPON_PETROLCAN`] = true,
        [`WEAPON_JXMP5`] = true,
        [`WEAPON_PURPSEMITK`] = true,
        [`WEAPON_ONEPIECEGLOCK`] = true,
        [`WEAPON_LONETWO`] = true,
        [`WEAPON_DTAP`] = true,
        [`WEAPON_DTP`] = true,
        [`WEAPON_PISTOL`] = true,
        [`WEAPON_APPISTOL`] = true,
        [`WEAPON_DTGREY`] = true,
        [`WEAPON_BAR15`] = true,
        [`WEAPON_BSCAR`] = true,
        [`WEAPON_CHICAGOPD`] = true,
        [`WEAPON_PUMPSHOTGUN`] = true,
        [`WEAPON_PDNYC`] = true,
        [`WEAPON_LONETWO`] = true,
        [`WEAPON_FLAREGUN`] = true,
        [`WEAPON_LILRED`] = true,
    },
    Title = 'Shots Fired',
    codePrimary = '10',
    codeSecondary = '71',
    sound = 'dispatch',
}
