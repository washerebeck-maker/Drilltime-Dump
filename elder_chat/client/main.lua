ESX = exports['es_extended']:getSharedObject()

local g_chat_input_active = false
local g_chat_input_activating = false
local g_chat_hidden = true
local g_chat_loaded = false
local g_chat_staff = nil


local function refreshCommands()
	if GetRegisteredCommands then
		local registeredCommands = GetRegisteredCommands()
		local suggestions = {}

		for _, command in ipairs(registeredCommands) do
			if IsAceAllowed(('command.%s'):format(command.name)) then
				table.insert(suggestions, {
					name = '/' .. command.name,
					help = ''
				})
			end
		end
		TriggerEvent('chat:addSuggestions', suggestions)
	end
end

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:client:ClearChat')
RegisterNetEvent('__cfx_internal:serverPrint')
RegisterNetEvent('_chat:messageEntered')

AddEventHandler('chatMessage', function(author, color, text)
	local args = { text }
	if author ~= "" then
		table.insert(args, 1, author)
	end
	SendNUIMessage({
		action = 'on_message',
		data = {
			color = color,
			args = args
		}
	})
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
	--[[ SendNUIMessage({
		action = 'on_message',
		message = {
			templateId = 'print',
			args = { msg }
		}
	}) ]]
end)

AddEventHandler('chat:addMessage', function(data)
	local message = {}
	if data.args then
		message.message = table.concat(data.args, " ")
		message.tag = {name = 'Server', color = '#4500BD'}
		message.author = 'DRILLTIME'
		message.id = 0
		message.avatar = "https://i.ibb.co/Dg4HCtRB/newlarge.png?size=80&quality=lossless"
	else
		message = data
	end
	SendNUIMessage({
		action = 'on_message',
		data = {message = message}
	})
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
    SendNUIMessage({
        action = 'on_suggestion_add',
        data = {
            suggestion = {
                name = name,
                help = help,
                params = params or {}
            }
        }
    })
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
	for _, suggestion in ipairs(suggestions) do
		SendNUIMessage({
			action = 'on_suggestion_add',
			data = {suggestion = suggestion}
		})
	end
end)

AddEventHandler('chat:removeSuggestion', function(name)
	SendNUIMessage({
		action = 'on_suggestion_remove',
		name = name
	})
end)

RegisterNetEvent('chat:resetSuggestions')
AddEventHandler('chat:resetSuggestions', function()
	SendNUIMessage({
		action = 'on_commands_reset'
	})
end)

AddEventHandler('chat:addTemplate', function(id, html)
	
end)

AddEventHandler('chat:client:ClearChat', function(name)
	SendNUIMessage({
		action = 'on_clear'
	})
end)

RegisterNUICallback('chatResult', function(data, cb)
	g_chat_input_active = false
	SetNuiFocus(false)
	if not data.canceled then
		local id = PlayerId()
		if data.message:sub(1, 1) == '/' then
			ExecuteCommand(data.message:sub(2))
		else
			TriggerServerEvent('chat:messageEntered', GetPlayerName(id), data.message)
		end
	end
	cb('ok')
end)

AddEventHandler('onClientResourceStart', function(resName)
	Wait(500)
	refreshCommands()
end)

AddEventHandler('onClientResourceStop', function(resName)
	Wait(500)
	refreshCommands()
end)

RegisterNUICallback('loaded', function(data, cb)
	TriggerServerEvent('chat:init');
	refreshCommands()
	g_chat_loaded = true
	cb('ok')
end)

Citizen.CreateThread(function()
	SetTextChatEnabled(false)
	SetNuiFocus(false)
	while true do
		Wait(0)
		if not g_chat_input_active then
			if IsControlPressed(0, 245) then
				g_chat_input_active = true
				g_chat_input_activating = true
				SendNUIMessage({
					action = 'on_open'
				})
			end
		end
		if g_chat_input_activating then
			if not IsControlPressed(0, 245) then
				SetNuiFocus(true)
				g_chat_input_activating = false
			end
		end
		if g_chat_loaded then
			local should_be_hidden = false
			if IsScreenFadedOut() or IsPauseMenuActive() then
				should_be_hidden = true
			end
			if (should_be_hidden and not g_chat_hidden) or (not should_be_hidden and g_chat_hidden) then
				g_chat_hidden = should_be_hidden
				SendNUIMessage({
					action = 'on_screen_state_changed',
					should_hide = should_be_hidden
				})
                if should_be_hidden then 
                    g_chat_input_active = false
                    SetNuiFocus(false)
                end
			end
		end
	end
end)

RegisterNUICallback('altPressed', function(data, cb)
	SetNuiFocus(true,true)
	cb('ok')
end)

RegisterNUICallback('settings', function(data, cb)
	cb('ok')
	if not isCustomTagAllowed() then
		lib.notify({
			description = 'You need to purchase discord role.',
			position = 'bottom',
			type = 'error',
			duration = 5000
    	})
		return
	end
	openTagMenu()
end)

function openTagMenu()
	local tag = getPlayerCustomTag()
	local input = lib.inputDialog('Customise your tag', {
		{type = 'input', label = 'Tag Name', default = tag and tag.name, required = true, min = Config.CustomTag.min_characters, max = Config.CustomTag.max_characters},
		{type = 'color', label = 'Colour input', default = tag and tag.color or '#eb4034'},
		{type = 'checkbox', checked = tag and tag.enabled or false, label = 'Enable/Disable'},

	})
	if not input then return end
	TriggerServerEvent('chat:server:updateTag', input[1], input[2], input[3])
end

isCustomTagAllowed = function()
    local result = promise:new()
    ESX.TriggerServerCallback('chat:server:isCustomTagAllowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

getPlayerCustomTag = function()
    local result = promise:new()
    ESX.TriggerServerCallback('chat:server:getPlayerCustomTag', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end


lib.callback.register('chat:client:inputCallback', function()
	local input = lib.inputDialog('Chat Ban', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID', required = true },
	}, { allowCancel = false })
	return input
end)

lib.callback.register('chat:client:inputCallback2', function()
	local input = lib.inputDialog('Chat UnBan', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID ', required = true },
	}, { allowCancel = false })
	return input
end)

RegisterNetEvent('elder_chat:client:sendStaffMessage')
AddEventHandler('elder_chat:client:sendStaffMessage', function(data)
    if isStaffAllowed() then 
        TriggerEvent('chat:addMessage', data)
    end
end)

function isStaffAllowed()
    if g_chat_staff ~= nil then return g_chat_staff end
    local result = promise:new()
    ESX.TriggerServerCallback('chat:server:isStaffAllowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end
