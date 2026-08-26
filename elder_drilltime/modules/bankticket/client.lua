
local NPC = nil
local PlayerLoaded = false
local IsViperPlayer = false

local function IsVipPlayer()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:bankticket:server:is_vip_player', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function BuyTicket()
    if not IsViperPlayer then
        local alert = lib.alertDialog({
            header = 'Do you want to buy Vip Personal Locker Ticket ?',
            content = 'Price : $'.. ESX.Math.GroupDigits(Config.BankTicket.Price),
            centered = true,
            cancel = true,
            labels = {
                cancel=  "Cancel",
                confirm=  "Pay",
            }
        })
        if alert ~= 'cancel' then
            ESX.TriggerServerCallback('elder_drilltime:bankticket:server:subscribe', function(data) 
                if data then
                    Notify("You are successfully subscribed.")
                    IsViperPlayer = true
                else
                    Notify("You dont have enough money.", "error")
                end 
            end) 
        end
    else
        Notify("You are already subscribed.")
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   Wait(2000)
   PlayerLoaded = true
   IsViperPlayer = IsVipPlayer()
end)

if Config.DebugMode then
    CreateThread(function()
        PlayerLoaded = true
        IsViperPlayer = IsVipPlayer()
    end)
end

Citizen.CreateThread(function()   
    local ped_hash = GetHashKey(Config.BankTicket.Shop.Model)
    local coords = Config.BankTicket.Shop.Coords
    ESX.Streaming.RequestModel(ped_hash)
    NPC = CreatePed(5, ped_hash, coords.x, coords.y, coords.z-1, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)	    
end)

Citizen.CreateThread(function()
    local coords = Config.BankTicket.Shop.Coords
    local price = Config.BankTicket.Price
    local markerTextUi = false
    while true do
        local sleep = 1000  
        local distance = GetDistanceBetweenCoords(cache.coords, coords.xyz, true)
        if distance <= 2.0 then
            sleep = 1
            if not markerTextUi then
                lib.showTextUI('[E] to buy vip personal locker ticket [$'..ESX.Math.GroupDigits(price)..']', { position = "right-center", icon = 'fa-crown', iconColor = 'gold'})
                markerTextUi = true
            end
            if IsControlJustPressed(0, 38) then
                lib.hideTextUI()
                markerTextUi = false
                BuyTicket()
            end
        else
            if markerTextUi then
                markerTextUi = false
                lib.hideTextUI()
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while not PlayerLoaded do Wait(100) end
    while true do
        local sleep = 10
        local distance = GetDistanceBetweenCoords(cache.coords, Config.BankTicket.Locker, true)
        if distance <= 2.0 then
            if not IsViperPlayer then
                TriggerServerEvent('JD_CommunityService:sendToService', GetPlayerServerId(PlayerId()), Config.BankTicket.CommunityServiceActions)
                Wait(5000)
            end
        else
            if distance > 10.0 then sleep = 1000 end
        end
        Wait(sleep)
    end
end)


