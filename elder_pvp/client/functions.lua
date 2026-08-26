local function GetMatches()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_pvp:server:getMatches', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

local function GetRanks()
	local result = promise:new()
    ESX.TriggerServerCallback('elder_pvp:server:getRanks', function(data) 
		result:resolve(data)  
    end, plate)
    return Citizen.Await(result)
end

function SecondsToClock(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		mins = string.format("%02.f", math.floor(seconds / 60 - (math.floor(seconds / 3600) * 60)));
		secs = string.format("%02.f", math.floor(seconds - math.floor(seconds / 3600) * 3600 - mins * 60));
		return mins .. ":" .. secs
	end
end

function DrawNiceText(x, y, scale, text, f, c, n, color)
	color = color or { 255, 255, 255 }
	SetTextFont(f or 4)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(color[1], color[2], color[3], color[4] or 255)
	SetTextCentre(c)
	if not n then
		SetTextDropShadow()
		SetTextOutline()
		SetTextDropShadow(0, 0, 0, 0,255)
		SetTextEdge(2, 0, 0, 0, 255)
	end
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function Notify(msg, type, time)
	lib.notify({
        description = msg,
        position = 'center-left',
        type = type,
        duration = time
    })
end

function OpenPVPMenu()
	local menuOptions = {} 
	
	table.insert(menuOptions, {title = 'Create PVP Match', description = 'Create new PVP match.', arrow = true, icon = 'square-plus', event = 'elder_pvp:client:create'})
	table.insert(menuOptions, {title = 'Join PVP Match', description = 'Join a PVP Match.', arrow = true, icon = 'person-rifle', event = 'elder_pvp:client:listJoin'})
	table.insert(menuOptions, {title = 'Ongoing PVP Matches', description = 'Ongoing fights.', icon = 'fa-spinner', arrow = true, event = 'elder_pvp:client:listOnGoing'})
	table.insert(menuOptions, {title = 'PVP Ranks', description = 'Players PVP ranks.', icon = 'fa-users', arrow = true, event = 'elder_pvp:client:ranks'})
	table.insert(menuOptions, {title = 'City Teleport', description = 'Use this if you stuck inside pvp map', icon = 'fa-map-location-dot', arrow = true, event = 'elder_pvp:client:cityTeleport'})
	
    lib.registerContext({
        id = 'pvp_menu',
        title = '☠️ Drilltime PVP ☠️',
        options = menuOptions,
    })
    lib.showContext('pvp_menu')
end

function CreateMatch()

	local dialogoptions = {}
	table.insert(dialogoptions, {type = 'input', label = 'Name', required = true})
	table.insert(dialogoptions, {type = 'select', label = 'Rounds', options = {{value = "1", label = "1 ROUND"},{value = "2", label = "2 ROUNDS"},{value = "3", label = "3 ROUNDS"}} , required = true })
	table.insert(dialogoptions, {type = 'select', label = 'Weapon', options = Config.Weapons , required = true })
	table.insert(dialogoptions, {type = 'input', label = 'Password', description = 'leave blank for open matches.'})

	local input = lib.inputDialog('Create PVP Match', dialogoptions, { allowCancel = true })

	OpenPVPMenu()

	if not input then
		return 
	end

	TriggerServerEvent('elder_pvp:server:create', input)

end

function ListJoin()
	local matches = GetMatches()
	local menuOptions = {} 
	for k,v in ipairs(matches) do 
		if not v.closed and v.ongoing == false then 
			table.insert(menuOptions, {
				title = ('%s (%s)'):format(v.name, v.ownerName), 
				description = ('Rounds [%s]'):format(v.rounds),
				arrow = true, 
				icon = v.password and 'fa-lock' or 'fa-unlock',
				iconColor = v.isowner and 'green' or v.password and 'gold',
				image = Config.ImagesPath .. v.weapon .. '.png',
				event = 'elder_pvp:client:join',
				args = {id = v.id, password = v.password, isowner = v.isowner}
			})
		end
	end
	if #menuOptions == 0 then
		table.insert(menuOptions, {
			title = 'No matches available.', 
			icon = 'fa-circle-stop',
			readOnly = true
		})
	end
	lib.registerContext({
        id = 'pvp_listjoin_menu',
		menu = 'pvp_menu',
        title = '☠️ Join Match ☠️',
        options = menuOptions,
    })
    lib.showContext('pvp_listjoin_menu')
end

function ListOnGoing()
	local matches = GetMatches()
	local menuOptions = {} 
	for k,v in ipairs(matches) do 
		if not v.closed and v.ongoing == true then 
			table.insert(menuOptions, {
				title = ('%s : %s vs %s'):format(v.name, v.ownerName, v.opponentName), 
				description = ('Rounds [%s]'):format(v.rounds),
				arrow = true, 
				icon = v.password and 'fa-lock' or 'fa-unlock',
				iconColor = v.password and 'gold',
				image = Config.ImagesPath .. v.weapon .. '.png',
				readOnly = true,
			})
		end
	end
	if #menuOptions == 0 then
		table.insert(menuOptions, {
			title = 'No matches available.', 
			icon = 'fa-circle-stop',
			readOnly = true
		})
	end
	lib.registerContext({
        id = 'pvp_listongoing_menu',
		menu = 'pvp_menu',
        title = '☠️ OnGoing Matches ☠️',
        options = menuOptions,
    })
    lib.showContext('pvp_listongoing_menu')
end

function RanksMenu()
	local data = GetRanks()
    local menuOptions = {} 
    local index = 0
    for k,v in pairs(data) do
        index = index + 1
        if index < 10 then
            table.insert(menuOptions, 
            {
                title = ('%s# %s'):format(index,v.name) ,
                description = 'Wins : ' .. v.wins,
                icon = index <= 3 and 'fa-trophy' or 'fa-skull' ,
                iconColor = index == 1 and 'gold' or index == 2 and 'silver' or index == 3 and '#cd7f32' or 'white' ,
            })
        else
            break
        end
    end

    lib.registerContext({
        id = 'pvp_rank_menu',
        menu = 'pvp_menu',
        title = 'PVP TOP 10 PLAYERS',
        options = menuOptions,
    })
    lib.showContext('pvp_rank_menu')
end

function JoinMatch(args)

	if args.isowner then
		local alert = lib.alertDialog({
			header =  'Are you sure to remove the match?',
			centered = true,
			cancel = true
		}) 

		if alert == 'confirm' then
			TriggerServerEvent('elder_pvp:server:remove', args.id)
		end
		ListJoin()
	else
		local alert = lib.alertDialog({
			header =  'Are you sure to join the match?',
			centered = true,
			cancel = true
		}) 

		if alert == 'confirm' then
			if args.password then
				local dialogoptions = {}
				table.insert(dialogoptions, {type = 'input', label = 'Password', required = true})
				local input = lib.inputDialog('Enter Match Password', dialogoptions, { allowCancel = true })
				if not input then
					ListJoin()
					return 
				end
				if input[1] ~= args.password then
					Notify('Wrong password !', 'warning')
					ListJoin()
					return
				end
			end
			
			TriggerServerEvent('elder_pvp:server:join', args.id)
			
		else
			ListJoin()
		end
	end
end