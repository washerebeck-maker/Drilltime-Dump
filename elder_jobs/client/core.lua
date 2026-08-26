ESX = exports['es_extended']:getSharedObject()


G_CookiesNPC = {}
G_RestaurantNPC = {}
G_PickUpBlip = nil
G_DeliveryBlip = nil
G_Vehicle = nil
G_Object = nil

function Notify(msg, type)
	lib.notify({
        description = msg,
        position = position or 'center-left',
        type = type,
        duration = time
    })
end

function MissionAlert(text)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(1000, 1)
end

RegisterNetEvent("elder_jobs:client:notify")
AddEventHandler("elder_jobs:client:notify", function(msg, type) 
	Notify(msg, type)
end)

function MissionSuccess(text1, text2)
	Citizen.CreateThread(function()
		function Initialize(scaleform)
			local scaleform = RequestScaleformMovie(scaleform)
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString(text1)
			PushScaleformMovieFunctionParameterString(text2)
			PopScaleformMovieFunctionVoid()
			return scaleform
		end
		scaleform = Initialize("mp_big_message_freemode")
		local temps = 0
		while temps < 500 do
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
			temps = temps + 1
		end
		Citizen.Wait(500)
	end)
end

function LoadAnim(dict)
    if not DoesAnimDictExist(dict) then
        return false
    end

    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end

    return true
end

function LoadPropDict(model)
    while not HasModelLoaded(joaat(model)) do
        RequestModel(joaat(model))
        Wait(10)
    end
end

function CreateBlip(coords,sprite, colour, name)
	local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 525)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 5)
    EndTextCommandSetBlipName(blip)
	return blip
end

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3, textureVariation)
    local Player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(Player))
    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end
    prop = CreateObject(joaat(prop1), x, y, z + 0.2, true, true, true)
    if textureVariation ~= nil then
        SetObjectTextureVariation(prop, textureVariation)
    end
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true,
        false, true, 1, true)
    G_Object = prop
    SetModelAsNoLongerNeeded(prop1)
    return true
end