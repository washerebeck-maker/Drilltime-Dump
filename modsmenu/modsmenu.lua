ESX = exports['es_extended']:getSharedObject()

function openMenuInteraction()

	local elements = {}

	table.insert(elements, {label = "Graphic Mode 1", value = 'mod1'})
	table.insert(elements, {label = "Graphic Mode 2", value = 'mod2'})
	table.insert(elements, {label = "Graphic Mode 3 - High FPS", value = 'mod4'})
	table.insert(elements, {label = "Graphic Mode 4", value = 'mod5'})
	table.insert(elements, {label = "Graphic Mode 5", value = 'mod6'})
	table.insert(elements, {label = "Graphic Mode 6", value = 'mod7'})
	table.insert(elements, {label = "Original Graphic Mode",value = 'mod3'})
	table.insert(elements, {label = "Close Menu", value = 'close'})
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'menu_action',
		{
			title    = 'Drilltime Graphic Mods',
			align    = 'top-left',
			elements = elements
		},function(data, menu)

			local player, distance = ESX.Game.GetClosestPlayer()

			ESX.UI.Menu.CloseAll()	
		
			if data.current.value == 'mod1' then
				SetTimecycleModifier('MP_GARAGE_L')
				openMenuInteraction()
			end
		
			if data.current.value == 'mod2' then  
				SetTimecycleModifier('yell_tunnel_nodirect')
				openMenuInteraction()
			end
		
			if data.current.value == 'mod3' then 
				SetTimecycleModifier('')
				openMenuInteraction()
			end	
	
			if data.current.value == 'mod4' then  
				SetTimecycleModifier('int_dockcontrol_small')
				openMenuInteraction()
			end
	
			if data.current.value == 'mod5' then   
				SetTimecycleModifier('cashdepotEMERGENCY')
				openMenuInteraction()
			end
	
			if data.current.value == 'mod6' then   
				SetTimecycleModifier('mp_battle_int03_tint2')
				openMenuInteraction()
			end
			
			if data.current.value == 'mod7' then   
				SetTimecycleModifier('INT_NO_fogALPHA')
				openMenuInteraction()
			end
			
			if data.current.value == 'close' then
				menu.close()
			end	
		end)
end


RegisterNetEvent('modsmenu:open')
AddEventHandler('modsmenu:open', function()
	openMenuInteraction()
end)

RegisterCommand('fps', function()
openMenuInteraction()
end)
