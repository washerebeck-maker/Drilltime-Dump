


ESX = exports['es_extended']:getSharedObject()


local function isStaffMember()
    local player_data = ESX.GetPlayerData()
    return player_data and ( player_data.group == 'admin' or player_data.group == 'moderator' )
end

local function isPoliceMember()
    local player_data = ESX.GetPlayerData()
    return player_data and player_data.job and player_data.job.name == 'police'
end

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        TriggerServerEvent('elder_antiCL:server:register_player')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Wait(2000)
    TriggerServerEvent('elder_antiCL:server:register_player')
end)

RegisterNetEvent('elder_antiCL:client:player_dropped')
AddEventHandler('elder_antiCL:client:player_dropped', function(pedData)
    if isPoliceMember() or isStaffMember() then
        OnPlayerDropped(pedData)
    end
end)

OnPlayerDropped = function(pedData)
    local model = GetHashKey(pedData.ped.model)
    local coords = pedData.ped.coords
    local heading = pedData.ped.heading
    local skin = pedData.ped.skin
    ESX.Streaming.RequestModel(model)
    local ped = CreatePed(5, model, coords.x, coords.y, coords.z-1, heading, false, true)
    PlaceObjectOnGroundProperly(ped)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)	  
    SetEntityCollision(ped, false, false)
    SetEntityAlpha(ped, 100, false)
    SetPedCanLosePropsOnDamage(ped, false, 0)
    NetworkSetEntityGhostedWithOwner(ped, true)
    SetEntityNoCollisionEntity(PlayerPedId(), ped, false)
    exports['fivem-appearance']:setPedAppearance(ped, skin)
    Wait(250)
    local inProgress = true
    CreateThread(function()
        while true do 
            Wait(Config.PedTime * 1000)
            inProgress = false
            DeleteEntity(ped)
        end
    end)
    
    CreateThread(function()
        local is_staff_member = isStaffMember()
        while inProgress do 
            local sleep = 1000
            local distance = #(GetEntityCoords(PlayerPedId()) - coords)
            if distance < 5.0 then
                sleep = 1
                x, y, z = table.unpack(GetPedBoneCoords(ped , 0x796e))
                z = z + 0.3
                if is_staff_member then
                    DrawText3D(coords.x, coords.y, coords.z - 0.1, "[~b~Z~s~] punish ~y~player~s~")
                else
                    DrawText3D(coords.x, coords.y, coords.z - 0.1, "[~b~Z~s~] report ~y~player~s~")
                end
                
                DrawText3D(x, y, z , "~y~"..pedData.name.."~s~ ["..pedData.id.."] [~r~$"..ESX.Math.GroupDigits(pedData.black_money).."~s~] left [~g~" ..pedData.reason.."~s~]" )

                local done = false
                if IsControlJustPressed(0, 20) and not done then
                    done = true
                    if is_staff_member then
                        local input = lib.inputDialog('Punish Player', {
                            { type = 'input', label = 'Reason', description = 'Why this player will get punished ?', required = true },
                        }, { allowCancel = true })
                        
                        if input then 
                            local alert = lib.alertDialog({
                                header = 'Warning : Are you sure you want to punish the player? ',
                                content = input[1],
                                centered = true,
                                cancel = true,
                                labels = {
                                    cancel=  "Cancel",
                                    confirm=  "Confirm",
                                }
                            })
                            if alert ~= 'cancel' then
                                TriggerServerEvent('elder_antiCL:server:punish', pedData.identifier, input[1])
                                done = false
                            end
                        end   
                    else
                        TriggerServerEvent('elder_antiCL:server:report', pedData.identifier, 'User f8 quit on police .. HELP', pedData.black_money)
                        done = false
                    end  
                end
            end
            Wait(sleep)
        end
    end) 
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 170)
    ClearDrawOrigin()
end