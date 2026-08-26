local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local blipana = {}

local Intervals = {}
SetInterval = function(id, msec, callback, onclear)
	if Intervals[id] and msec then
		Intervals[id] = msec
	else
		CreateThread(function()
			Intervals[id] = msec
			repeat
				Wait(Intervals[id])
				callback(Intervals[id])
			until Intervals[id] == -1 and (onclear and onclear() or true)
			Intervals[id] = nil
		end)
	end
end

ClearInterval = function(id)
	if Intervals[id] then Intervals[id] = -1 end
end

Citizen.CreateThread(function()

	while Config.ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	Config.ESX.PlayerData = Config.ESX.GetPlayerData()

	if Config.ESX.PlayerData.job.name == 'gotur' then
		Config.Zones.OfficeActions.Type = 1
		BlipGotur()
	else
		Config.Zones.OfficeActions.Type = -1
		blipsil()
	end

end)

RegisterNetEvent(Config.Setjob)
AddEventHandler(Config.Setjob, function(job)
	Config.ESX.PlayerData.job = job

	if Config.ESX.PlayerData.job.name == 'gotur' then
		Config.Zones.OfficeActions.Type = 1
		BlipGotur()
	else
		Config.Zones.OfficeActions.Type = -1
		blipsil()
	end
end)

-- Create blips

function blipsil ()
	if blipana[1] then
		for i, blip in pairs(blipana) do
			RemoveBlip(blip)
		end
	end
end

function BlipGotur()
	if not Config.EnableBlips then return end

	for _, GOTURLocations in pairs(Config.GOTURLocations) do
		GOTURLocations.blip = AddBlipForCoord(GOTURLocations.x, GOTURLocations.y, GOTURLocations.z - Config.ZDiff)
		table.insert(blipana, GOTURLocations.blip)
		SetBlipSprite(GOTURLocations.blip, Config.BlipSprite)
		SetBlipDisplay(GOTURLocations.blip, 4)
		SetBlipScale(GOTURLocations.blip, 0.9)
		SetBlipColour(GOTURLocations.blip, 2)
		SetBlipAsShortRange(GOTURLocations.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('gotur_appname'))
		EndTextCommandSetBlipName(GOTURLocations.blip)
	end
end



function test ()


		if (Config.Zones.OfficeActions.Type == 1) then

			if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Zones.OfficeActions.Pos.x, Config.Zones.OfficeActions.Pos.y, Config.Zones.OfficeActions.Pos.z, true) < Config.DrawDistance then
				DrawMarker(Config.Zones.OfficeActions.Type, Config.Zones.OfficeActions.Pos.x, Config.Zones.OfficeActions.Pos.y, Config.Zones.OfficeActions.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Zones.OfficeActions.Size.x, Config.Zones.OfficeActions.Size.y, Config.Zones.OfficeActions.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
				if IsControlJustReleased(0, Keys['E']) then

						OpenRealestateAgentMenu()

				end
			end

		end

end


Citizen.CreateThread(function()
	while true do
		test()
		Citizen.Wait(0)
	end
end)


function depoitem ()
	local elements = {}

	Config.ESX.TriggerServerCallback('gks_gotur:depoitemgotur', function(result)

	  for i=1, #result, 1 do

		local invitem = result[i]

		  if invitem.count > 0 then
			  table.insert(elements, { label = invitem.label .. ' | ' .. invitem.count .. ' ', count = invitem.count, name = invitem.item})
		  end
	  end

	Config.ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'putitem',
	{
	  title    = _U('gotur_store'),
	  align    = 'left',
	  elements = elements
	},
	function(data, menu)

		  local itemName = data.current.name
		  local invcount = tonumber(data.current.count)

			  Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
			  title = 'piece'
			  }, function(data2, menu2)
				if tonumber(data2.value) then
					local count = math.abs(tonumber(data2.value))
						if count > invcount then
							Config.ESX.ShowNotification(_U('gotur_itemsell'))
							menu2.close()
							menu.close()
						else
							menu2.close()
							menu.close()

							TriggerServerEvent('gks_gotur:depoitemdelete', itemName, count)

						end
				end
	  	   end)
	end, function(data, menu)
        menu.close()
    end)
end)

end



function depoyaitemekle ()
	local elements = {}

	Config.ESX.TriggerServerCallback('gks_gotur:getInventory', function(result)

		for k,v in pairs(result.items) do
			if v.count > 0 then
				table.insert(elements, { label = v.label .. ' | ' .. v.count .. ' pieces ', count = v.count, name = v.name, label2 = v.label})
			end
		end

	Config.ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'putitem',
	{
	  title    = _U('gotur_store'),
	  align    = 'left',
	  elements = elements
	},
	function(data, menu)

		  local itemName = data.current.name
		  local invcount = tonumber(data.current.count)

			  Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
			  title = _U('gotur_piece')
			  }, function(data2, menu2)

				if tonumber(data2.value) then
				local count = math.abs(tonumber(data2.value))

					if count > invcount then
						Config.ESX.ShowNotification(_U('gotur_itemadd'))
						menu2.close()
						menu.close()
					else
						menu2.close()
						menu.close()
						Config.ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'price', {
							title = _U('gotur_price')
							}, function(data3, menu3)

								if tonumber(data3.value) then
									local price = math.abs(tonumber(data3.value))

									menu3.close()
									local engellitem = false
									for k, v in pairs(Config.BlacklistItem) do
									if itemName == v then
										engellitem = true
										Config.ESX.ShowNotification(_U('gotur_blacklist'))
									end
									end
									if engellitem == false then
										TriggerServerEvent('gks_gotur:depoitem', itemName, count, price)
									end
								end
							end)


					end
				end
	  	   end)
	end, function(data, menu)
        menu.close()
    end)
end)
end



function OpenRealestateAgentMenu()
	local elements = {
		{label = _U('gotur_store'), 	 value = 'properties'},
		{label = _U('gotur_addstore'),   value = 'customers'},
	}

	if Config.ESX.PlayerData.job ~= nil and Config.ESX.PlayerData.job.name == 'gotur' and Config.ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {
			label = _U('gotur_boss'),
			value = 'boss_actions'
		})
	end

	Config.ESX.UI.Menu.CloseAll()

	Config.ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gotur', {
		title    = _U('gotur_store'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'properties' then
			depoitem()
		elseif data.current.value == 'customers' then
			depoyaitemekle()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent(Config.SocietyBossmenu, 'gotur', function(data, menu)
				menu.close()
			end, { wash = false })
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'gotur'
		CurrentActionMsg  = 'test'
		CurrentActionData = {}
	end)

end

deliverytime = Config.deliverytime
maxdeliverytime = Config.deliverytime
deliverystarted = false
total = 0
bilgi = nil
TrackerRunning = false
StoreBlip = {}

RegisterNetEvent('gks_gotur:gerisaybitir')
AddEventHandler('gks_gotur:gerisaybitir', function()
  deliverystarted = false
  deliverytime = 3
  total = 0
  bilgi = nil
end)

RegisterNetEvent('gks_gotur:gerisayim')
AddEventHandler('gks_gotur:gerisayim', function(gelens, gotur)
  deliverystarted = true
  total = gelens
  bilgi = gotur
  TriggerEvent('gksphone:notifi', {title = _U('gotur_appname'), message = _U('gotur_time') .. deliverytime, img= '/html/static/img/icons/gotur.png' })

end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)
		if deliverystarted then
			deliverytime = deliverytime - 1

			if deliverytime <= (maxdeliverytime / 3) then
				TriggerEvent('gksphone:notifi', {title = _U('gotur_appname'), message = _U('gotur_time') .. deliverytime, img= '/html/static/img/icons/gotur.png' })
			elseif deliverytime <= (maxdeliverytime / 3) * 2 then
				TriggerEvent('gksphone:notifi', {title = _U('gotur_appname'), message = _U('gotur_time') .. deliverytime , img= '/html/static/img/icons/gotur.png' })
			elseif deliverytime <= (maxdeliverytime / 3) * 3 then
				TriggerEvent('gksphone:notifi', {title = _U('gotur_appname'), message = _U('gotur_time') .. deliverytime, img= '/html/static/img/icons/gotur.png' })
			end
			if deliverytime <= 0 then
				failed()
			end
		end
	end
end)

RegisterNetEvent('gks_gotur:blipp')
AddEventHandler('gks_gotur:blipp', function(bilgi, deneme, number)
	SetInterval(deneme.source, 5000, function()
	Config.ESX.TriggerServerCallback('tonygetcoords', function(coords)
			local playerCoords = coords
			startTracking(playerCoords, bilgi, number)
		end, deneme.source)
	end)
end)

function startTracking(coords, name, number)
	if StoreBlip[number] ~= nil then
	RemoveBlip(StoreBlip[number])
	StoreBlip[number] = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(StoreBlip[number], 480)
	SetBlipScale(StoreBlip[number], 1.0)
	SetBlipDisplay(StoreBlip[number], 4)
	SetBlipAsShortRange(StoreBlip[number], true)


	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(' ' ..name)
	EndTextCommandSetBlipName(StoreBlip[number])
	else
	StoreBlip[number] = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(StoreBlip[number], 480)
        SetBlipScale(StoreBlip[number], 1.0)
        SetBlipDisplay(StoreBlip[number], 4)
        SetBlipAsShortRange(StoreBlip[number], true)


        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(' ' ..name)
        EndTextCommandSetBlipName(StoreBlip[number])
	end
end

RegisterNetEvent('gks_gotur:stopblipp')
AddEventHandler('gks_gotur:stopblipp', function(number, ida)
    Wait(7000)
    TrackerRunning = false
	ClearInterval(ida)
	Wait(7000)
	RemoveBlip(StoreBlip[number])
end)



function failed()

	deliverystarted = false
	deliverytime = 3

	TriggerServerEvent('gks_gotur:failed', total, bilgi)

end

AddEventHandler('onClientResourceStart', function(resName)
	deliverytime = 3
	maxdeliverytime = 3
	deliverystarted = false
	total = 0
	bilgi = nil
	TrackerRunning = false
	StoreBlip = {}

end)