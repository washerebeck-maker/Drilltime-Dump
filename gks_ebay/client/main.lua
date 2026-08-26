local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local gksebay 				  = nil



function OpenRealestateAgentMenu()
	local elements = {
		{label = _U('ebay_store'), 		value = 'properties'},
		{label = _U('ebay_storeadd'),    value = 'customers'},
		{label = _U('ebay_pstore'),     value = 'purchased'},
	}

	Config.ESX.UI.Menu.CloseAll()

	Config.ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gotur', {
		title    = _U('ebay_store'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'properties' then
			depoitem()
		elseif data.current.value == 'customers' then
			depoyaitemekle()
		elseif data.current.value == 'purchased' then
			purchaseditem()
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'gotur'
		CurrentActionMsg  = 'test'
		CurrentActionData = {}
	end)

end



function depoitem ()
	local elements = {}

	Config.ESX.TriggerServerCallback('gks_ebay:depoitemgoturtest', function(result)

	  for i=1, #result, 1 do

		local invitem = result[i]
			if invitem then
				if invitem.count > 0 then
					table.insert(elements, { label = invitem.label .. ' | ' .. invitem.count .. ' ', count = invitem.count, name = invitem.item})
				end
			end
	  end

		Config.ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'putitem',
		{
		title    = _U('ebay_store'),
		align    = 'left',
		elements = elements
		},
		function(data, menu)

			local itemName = data.current.name
			local invcount = tonumber(data.current.count)

				Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
				title = _U('ebay_piece')
				}, function(data2, menu2)

				local count = tonumber(math.abs(data2.value))
					if count > invcount then
						Config.ESX.ShowNotification(_U('ebay_itemsell'))
						menu2.close()
						menu.close()
					else
						menu2.close()
						menu.close()

						TriggerServerEvent('gks_ebay:depoitemdelete', itemName, count)

					end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)

end



function depoyaitemekle ()
	local elements = {}

	Config.ESX.TriggerServerCallback('gks_ebay:getInventory', function(result)
	  for k,v in pairs(result.items) do
		if v.count > 0 then
			table.insert(elements, { label = v.label .. ' | ' .. v.count .. ' pieces ', count = v.count, name = v.name, label2 = v.label})
		end
	  end

	Config.ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'putitem',
	{
	  title    = _U('ebay_store'),
	  align    = 'left',
	  elements = elements
	},
	function(data, menu)
		  local itemLabel = data.current.label2
		  local itemName = data.current.name
		  local invcount = tonumber(data.current.count)

			  Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
			  title = _U('ebay_piece')
			  }, function(data2, menu2)

			  local count = tonumber(math.abs(data2.value))

				if tonumber(count) > tonumber(invcount) then
					Config.ESX.ShowNotification(_U('ebay_itemadd'))
					menu2.close()
					menu.close()
				else
					menu2.close()
					menu.close()
					Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'price', {
						title = _U('ebay_price')
						}, function(data3, menu3)

							local price = tonumber(math.abs(data3.value))


							menu3.close()

							local engellitem = false
							for k, v in pairs(Config.BlacklistItem) do
							  if itemName == v then
								engellitem = true
								Config.ESX.ShowNotification(_U('ebay_itemadd'))
							  end
							end
							if engellitem == false then
								TriggerServerEvent('gks_ebay:depoitem', itemName, count, price, itemLabel)
							end

						end)


				end
	  	   end)
	end, function(data, menu)
        menu.close()
    end)
end)
end

function purchaseditem ()
	local elements = {}

	Config.ESX.TriggerServerCallback('gks_ebay:purchitemgotur', function(result)

	  for i=1, #result, 1 do

		local invitem = result[i]

		  if invitem.count > 0 then
			  table.insert(elements, { label = invitem.label .. ' | ' .. invitem.count .. ' ', count = invitem.count, name = invitem.item})
		  end
	  end

		Config.ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'putitem',
		{
		title    = _U('ebay_store'),
		align    = 'left',
		elements = elements
		},
		function(data, menu)

			local itemName = data.current.name
			local invcount = tonumber(data.current.count)

				Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
				title = _U('ebay_piece')
				}, function(data2, menu2)

				local count = tonumber(math.abs(data2.value))
					if count > invcount then
						Config.ESX.ShowNotification(_U('ebay_itemsell'))
						menu2.close()
						menu.close()
					else
						menu2.close()
						menu.close()

						TriggerServerEvent('gks_ebay:purchitemdelete', itemName, count)

					end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end



Citizen.CreateThread(function()
    if Config.NPCEnable == true then
		RequestModel(Config.NPCIdyenileehliyet)
		while not HasModelLoaded(Config.NPCIdyenileehliyet) do
			Wait(1)
		end

		gksebay = CreatePed(1, Config.NPCIdyenileehliyet, Config.NPCKonummrpd.x, Config.NPCKonummrpd.y, Config.NPCKonummrpd.z - 1.0, Config.NPCKonummrpd.h, false, true)
		FreezeEntityPosition(gksebay, true)
		SetEntityInvincible(gksebay, true)
		SetBlockingOfNonTemporaryEvents(gksebay, true)

		if Config.EyeTarget then
            exports['qtarget']:AddTargetEntity(gksebay, {
                options = {
                    {
                        label = _U('ebay_appname'),
                        icon = "fas fa-shopping-basket",
                        action = function()
                            OpenRealestateAgentMenu()
                        end
                    }
                },
                distance = 2.0
            })
        end
	end
end)

function npckafa(deneme)
	local Tag = CreateFakeMpGamerTag(gksebay, _U('ebay_appname'), false, false, "NOS", false)
	if deneme then
		SetMpGamerTagAlpha(Tag, 0, 255) -- Sets "MP_TAG_GAMER_NAME" bar alpha to 100% (not needed just as a fail safe)
		SetMpGamerTagColour(Tag, 0, 012) 			-- https://wiki.rage.mp/index.php?title=Fonts_and_Colors -- 000 //  129
		--SetMpGamerTagHealthBarColour(Tag, 25)  --https://wiki.rage.mp/index.php?title=Fonts_and_Colors
		SetMpGamerTagVisibility(Tag, 0, true) -- Activates the player ID Char name and FiveM name
	else
		SetMpGamerTagVisibility(Tag, 0, false)
		RemoveMpGamerTag(Tag)
	end
end

local letSleep = true
local teksefer = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.NPCKonummrpd.x, Config.NPCKonummrpd.y, Config.NPCKonummrpd.z, true) < Config.DrawDistance then
			letSleep = false
			if not teksefer then
				teksefer = true
				npckafa(teksefer)
			end
			if not Config.EyeTarget then
				if IsControlJustReleased(0, 38) then
					OpenRealestateAgentMenu()
				end
			end
		else
			letSleep = true
			if teksefer then
				teksefer = false
				npckafa(teksefer)
			end
		end
		if letSleep then Citizen.Wait(1000) end
	end
end)