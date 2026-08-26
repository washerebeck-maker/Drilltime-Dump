
local lastReloadCharTime = 0
local lastFixCharTime = 0

local function ReloadChar()
    if GetGameTimer() - lastReloadCharTime < Config.PersonalMenu.ReloadCharCooldown then
        Notify('Action on cooldown, you should wait.')
        return
    end
    lastReloadCharTime = GetGameTimer()
    exports['fivem-appearance']:ReloadChar()
end

local function FixChar()
    if GetGameTimer() - lastFixCharTime < Config.PersonalMenu.FixCharCooldown then
        Notify('Action on cooldown, you should wait.')
        return
    end
    lastFixCharTime = GetGameTimer()
    ClearPedSecondaryTask(GetPlayerPed(-1))
    exports['fivem-appearance']:ReloadChar()
end

local function ChangeName()
    TriggerServerEvent('elder_drilltime:personalmenu:server:change_name')
end

local function PersonalMenu()
    local menuOptions = {}              
    table.insert(menuOptions, {title = 'Reload Character', description = 'Use this if you want to reload your character skin.', icon = 'fa-user-check', onSelect = function() ReloadChar() end })
    table.insert(menuOptions, { title = 'Fix Character', description = 'Use this if you want to fix character issues.', icon = 'fa-user-gear', onSelect = function() FixChar() end })
    table.insert(menuOptions, { title = 'Change Character Name ($'..ESX.Math.GroupDigits(Config.PersonalMenu.ChangeNamePrice)..')', description = 'Use this if you want to change character name.', icon = 'fa-user', onSelect = function() ChangeName() end })
    
    lib.registerContext({
        id = 'personal_menu',
        title = '💯 Drilletime Or No Time 💯',
        options = menuOptions,
    })
    lib.showContext('personal_menu')
end

lib.callback.register('elder_drilltime:personalmenu:client:change_name', function(firstname, lastname)
	local input = lib.inputDialog('Current Character Name : FirstName : ' .. firstname .. ' | LastName : ' .. lastname, {
		{ type = 'input', label = 'First Name', description = 'First Name', required = true },
		{ type = 'input', label = 'Last Name', description = 'Last Name', required = true }
	}, { allowCancel = true })
	return input
end)

RegisterCommand(Config.PersonalMenu.Command, function()
    PersonalMenu()
end)
