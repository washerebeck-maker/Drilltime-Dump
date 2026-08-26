RegisterNetEvent('esx_drilltime:staff_streamer:client:staff')
AddEventHandler('esx_drilltime:staff_streamer:client:staff', function(staffId)
	if not Staff[staffId] then 
        Staff[staffId] = true
    else
        Staff[staffId] = not Staff[staffId]
    end
end)

RegisterNetEvent('esx_drilltime:staff_streamer:client:trailstaff')
AddEventHandler('esx_drilltime:staff_streamer:client:trailstaff', function(staffId)
	if not TrailStaff[staffId] then 
        TrailStaff[staffId] = true
    else
        TrailStaff[staffId] = not TrailStaff[staffId]
    end
end)

RegisterNetEvent('esx_drilltime:staff_streamer:client:modstaff')
AddEventHandler('esx_drilltime:staff_streamer:client:modstaff', function(staffId)
	if not ModStaff[staffId] then 
        ModStaff[staffId] = true
    else
        ModStaff[staffId] = not ModStaff[staffId]
    end
end)

RegisterNetEvent('esx_drilltime:staff_streamer:client:streamer')
AddEventHandler('esx_drilltime:staff_streamer:client:streamer', function(streamerId)
    if not Streamers[streamerId] then 
        Streamers[streamerId] = true
    else
        Streamers[streamerId] = not Streamers[streamerId]
    end
end)

RegisterNetEvent('esx_drilltime:staff_streamer:client:gangManagers')
AddEventHandler('esx_drilltime:staff_streamer:client:gangManagers', function(id)
    if not GangManagers[id] then 
        GangManagers[id] = true
    else
        GangManagers[id] = not GangManagers[id]
    end
end)

RegisterNetEvent('esx_drilltime:staff_streamer:client:kosManagers')
AddEventHandler('esx_drilltime:staff_streamer:client:kosManagers', function(id)
    if not KosManagers[id] then 
        KosManagers[id] = true
    else
        KosManagers[id] = not KosManagers[id]
    end
end)




Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(Streamers) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if Streamers[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=160,g=32,b=240}
                if NetworkIsPlayerTalking(id) then
                    color = {r=193,g=15,b=36}
                end
				DrawText3DTag(vector3(x2, y2, z2), '~p~Streamer~s~', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(Staff) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if Staff[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=193,g=15,b=36}
                if NetworkIsPlayerTalking(id) then
                    color = {r=0,g=0,b=255}
                end
				--DrawText3DTag(vector3(x2, y2, z2), '☠️ ~italic~Admin~italic~', color)   
				DrawText3DTag(vector3(x2, y2, z2), '🛡 Admin', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(TrailStaff) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if TrailStaff[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=255,g=0,b=0}
                if NetworkIsPlayerTalking(id) then
                    color = {r=193,g=15,b=36}
                end
				DrawText3DTag(vector3(x2, y2, z2), '~g~🛡️ Trial Staff~s~', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(ModStaff) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if ModStaff[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=0,g=0,b=255}
                if NetworkIsPlayerTalking(id) then
                    color = {r=193,g=15,b=36}
                end
				DrawText3DTag(vector3(x2, y2, z2), '⚒ Moderator', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(GangManagers) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if GangManagers[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=255,g=215,b=0}
                if NetworkIsPlayerTalking(id) then
                    color = {r=193,g=15,b=36}
                end
				DrawText3DTag(vector3(x2, y2, z2), '~y~🔰 Gang Management~s~', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

Citizen.CreateThread(function()
    while true do
        local wait = 2000
		for k,v in pairs(KosManagers) do 
            local id = GetPlayerFromServerId(k)
            local coords = GetEntityCoords(PlayerPedId())
            local player_ped = GetPlayerPed(id) 
            local player_coords = GetEntityCoords(player_ped)
            if GetDistanceBetweenCoords(coords, player_coords, true) > 20 then goto continue end
            wait = 1
            if KosManagers[k] and NetworkIsPlayerActive(id) then
                x2, y2, z2 = table.unpack(GetPedBoneCoords(player_ped, 0x796e))
			    z2 = z2 + 0.4
                local color = {r=127,g=255,b=0}
                if NetworkIsPlayerTalking(id) then
                    color = {r=193,g=15,b=36}
                end
				DrawText3DTag(vector3(x2, y2, z2), '⚔️ KOS Management', color)   
                DrawMarker(26,player_coords.x,player_coords.y,player_coords.z - 0.98, 0, 0, 10, 0, 0, 0, 1.0, 1.0, 1.0, color.r, color.g, color.b, 105, 0, 1, 2, 0, 0, 0, 0)		
			end
            ::continue::
		end	
        Wait(wait)	
    end
end)

function DrawText3DTag(coords, text, color)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)
    SetTextColour(250, 250, 250, 250)
    SetTextScale(0.0, 0.6 * scale)
    SetTextFont(4)
	SetTextColour(color.r, color.g, color.b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
	SetTextCentre(1)
	SetTextProportional(1)
    SetTextDropShadow()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

function DrawText3D(x,y,z, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0*scale, 0.5*scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(r, g, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end