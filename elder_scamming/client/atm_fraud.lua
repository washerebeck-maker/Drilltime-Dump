
local PlayerJob = nil
local ClosestATM, ATMPos
local IsHacking = false
local HackingMessages = {}
local IsPriting = false
local ATMCardReaderDone = false
local Accounts = {}
local HackedATM = nil
local FraudCardUsed = false

-------------------------------------------------------------------------------------------------------------
------------------------------------------------- FUNCTIONS -------------------------------------------------
-------------------------------------------------------------------------------------------------------------

local function split (input)
    local t={}
    for str in string.gmatch(input, "([^/]+)") do
       table.insert(t, str)
    end
    return t[1],t[2]
 end

local function getNearestATM()
    local coords = GetEntityCoords(cache.ped)
    for _,model in pairs(Config.ATMFraud.ATMModels) do
        local atm = GetClosestObjectOfType(coords.x, coords.y, coords.z, Config.ATMFraud.ATMDistance + 5, model, false, false, false)
        if DoesEntityExist(atm) then
            if atm ~= ClosestATM then
                ClosestATM = atm
                ATMPos = GetEntityCoords(atm)
            end
            local dist = #(coords - ATMPos)
            if dist <= Config.ATMFraud.ATMDistance then
                return true
            end
            return false
        end
    end
end

local function playATMAnimation()
    RequestAnimDict('anim@amb@prop_human_atm@interior@male@enter')
    while not HasAnimDictLoaded('anim@amb@prop_human_atm@interior@male@enter') do
		Wait(5)
	end
	TaskPlayAnim(cache.ped, 'anim@amb@prop_human_atm@interior@male@enter', 'enter', 8.0, 8.0, -1, 0, 0, 0, 0, 0)
	Wait(4000)
	ClearPedTasks(cache.ped)
end

local function recoverATMReaderIntro()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Recovering ATM Reader ...", is_card_number = false}
    Wait(10000)
    SendNUIMessage({action = "hide"})
end

local function recoverATMReader()
    ATMCardReaderDone = false
    playATMAnimation()
    recoverATMReaderIntro()
    TriggerServerEvent('scamming:server:getAtmFiles', Accounts)
end

local function useFraudCard(account, pin, slot)
    lib.progressBar({
        duration = 5000,
        label = 'Inserting Credit Card ...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@amb@prop_human_atm@interior@male@enter',
            clip = 'enter'
        },
    })

    local input = lib.inputDialog('Card Emboss', {
		{ type = 'input', label = 'Pin Code', description = 'Put the pin code from Fraud CC Files', required = true }
	}, { allowCancel = false })

    if tostring(pin) == input[1] then
        local chance = math.random(1,10)
        if chance == 5 then
            local success = lib.skillCheck({'easy','easy','easy','easy','easy'})
            if success then
                TriggerServerEvent('scamming:server:getReward', slot, tostring(pin))
            else
                TriggerServerEvent('scamming:server:wrongPinCancel', slot)
                TriggerServerEvent('scamming:server:notifyPolice', GetEntityCoords(cache.ped))
            end
        else
            TriggerServerEvent('scamming:server:getReward', slot, tostring(pin))
        end
    else
        notify('Wrong Pin Code', 'error')
        TriggerServerEvent('scamming:server:wrongPinCancel', slot)
        TriggerServerEvent('scamming:server:notifyPolice', GetEntityCoords(cache.ped))
    end
end

local function startATMHackingLogs()
    CreateThread(function()
        while IsHacking do
            Wait(1000)
            if #HackingMessages > 0 and not IsPriting then
                IsPriting = true
                SendNUIMessage({action = "show", msg = HackingMessages[1].msg, is_card_number = HackingMessages[1].is_card_number, card_number = HackingMessages[1].card_number})
                table.remove(HackingMessages, 1)
            end
        end
    end)
end

local function hackDisplayTextIntro()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Hello " .. GetPlayerName(PlayerId()) .. ", This operation may take 5 minutes.", is_card_number = false}
    HackingMessages[#HackingMessages + 1] = { msg = "</> Introducing hacking tool in ATM ........ Done ✔️", is_card_number = false}
end

local function hackDisplayTextIntro2()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Signal to laptop is now LIVE ........ Done ✔️", is_card_number = false} 
end

local function hackDisplayTextIntro3()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Starting reading ATM data ........ Done ✔️", is_card_number = false}  
end

local function recoveryReady()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Scanning done, You can recover the ATM Reader", is_card_number = false}
end

local function startHackingAccounts()
    HackingMessages[#HackingMessages + 1] = { msg = "</> Searching ATM clients data ...", is_card_number = false}  
    local n = math.random(1,3)
    if n > 0 then
        local wait = Config.ATMFraud.ATMReaderTimer / n
        for i = 1, n, 1 do
            Wait(wait * 1000)
            local account = math.random(1000000000, 9999999999)
            local pin = math.random(1000, 9999)
            Accounts[#Accounts + 1] = {account_number = account, pin = pin }
            HackingMessages[#HackingMessages + 1] = { msg = "</> NEW INSERT CARD DATA LOGGED ✔️", is_card_number = false}
            HackingMessages[#HackingMessages + 1] = { msg = "</> Scanning customer card number .... ", is_card_number = true, card_number = tostring(account)}
        end
    else
        HackingMessages[#HackingMessages + 1] = { msg = "</> No customer get scammed ❌", is_card_number = false}
    end
    Wait(30000)
    recoveryReady()
    ATMCardReaderDone = true
end

local function hackATM()
    IsHacking = true
    startATMHackingLogs()
    hackDisplayTextIntro()
    playATMAnimation()
    hackDisplayTextIntro2()
    hackDisplayTextIntro3()
    startHackingAccounts()
end

local function playGame()
    return lib.skillCheck({'easy','medium','easy','easy','medium','easy','medium','easy','hard','easy'})
end

local function IsHacking()
    return lib.callback.await('scamming:server:canHack')
end

local function CanUseCard()
    return lib.callback.await('scamming:server:canUseCard')
end

-------------------------------------------------------------------------------------------------------------
--------------------------------------------------- THREADS -------------------------------------------------
-------------------------------------------------------------------------------------------------------------

CreateThread(function()
    if ESX.IsPlayerLoaded() then
        PlayerJob = ESX.GetPlayerData().job 
        IsHacking = IsHacking()
        FraudCardUsed = CanUseCard()
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        isNearATM = getNearestATM()
        local atmCoords = GetEntityCoords(ClosestATM)
        if isNearATM and HackedATM and #(atmCoords - HackedATM) <= Config.ATMFraud.ATMDistance then
            if ATMCardReaderDone then
                ESX.ShowHelpNotification("Press ~INPUT_VEH_HANDBRAKE~ to recover ATM Reader")
                if IsControlJustPressed(0, 76) then
                    recoverATMReader()
                end
            end
        else
            Wait(1000)
        end
    end
end)

-------------------------------------------------------------------------------------------------------------
--------------------------------------------------- EVENTS --------------------------------------------------
-------------------------------------------------------------------------------------------------------------


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   PlayerJob = xPlayer.job
   IsHacking = IsHacking()
   FraudCardUsed = CanUseCard()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job
end)

RegisterNetEvent('scamming:client:fraudCard')
AddEventHandler('scamming:client:fraudCard', function(account, pin, slot)  
    if ClosestATM then
        local dist = #(GetEntityCoords(cache.ped) - GetEntityCoords(ClosestATM))
        if dist <= Config.ATMFraud.ATMDistance then
            if not FraudCardUsed then
                FraudCardUsed = true
                useFraudCard(account, pin,slot)
            else
                notify('You have already used a card', 'error')
            end
        else
            notify('You should use this item on ATM', 'error')
        end
    end
end)

RegisterNetEvent('scamming:client:atmReader')
AddEventHandler('scamming:client:atmReader', function()  
    if not ClosestATM then return end
    local atmCoords = GetEntityCoords(ClosestATM)
    local dist = #(GetEntityCoords(cache.ped) - atmCoords)
    if dist > Config.ATMFraud.ATMDistance then
        return notify('You should use this item on ATM', 'error')
    end
    if IsHacking then
        return notify('You cannot use this now', 'error')
    end
    if not lib.callback.await('scamming:server:checkAtm', false, atmCoords) then 
        return notify('ATM already hacked.', 'error')
    end
    TriggerServerEvent('scamming:server:onAtmHack', atmCoords)
    HackedATM = atmCoords
    hackATM()
end)

RegisterNetEvent('scamming:client:notifyPolice')
AddEventHandler('scamming:client:notifyPolice', function(coords)
    if not PlayerJob or PlayerJob.name ~= 'police' then return end
    street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
	street2 = GetStreetNameFromHashKey(street)

    lib.notify({
        title = "BANK ALERT",
        description = "ATM Fraud detected in "..street2..", check GPS",
        duration = 10000,
        type = "info",
        position = 'top'
    })
    CreateThread(function()
		PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
		local blip = AddBlipForCoord(coords)
		SetBlipSprite(blip,  521)
		SetBlipColour(blip,  1)
		SetBlipAlpha(blip, 250)
		SetBlipScale(blip, 1.2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('ATM Fraud')
		EndTextCommandSetBlipName(blip)
		Wait(60000)
        RemoveBlip(blip)
    end)
end)

RegisterNetEvent('scamming:client:embossCard')
AddEventHandler('scamming:client:embossCard', function(payload, items)  
    exports.ox_inventory:closeInventory()
    local options = {}
    for k,v in pairs(items) do
        if v.name == Config.ATMFraud.ATMFileItem then
            local a,p = split(v.metadata.description)
            options[#options + 1] = {
                title = getItemLabel(v.name),
                description = 'Account : '..a..' / Pin : '..p..'',
                icon = 'nui://ox_inventory/web/images/'..v.name..'.png',
                onSelect = function()
                    TriggerServerEvent('scamming:server:embossCard', payload,a,p,v.slot)
                end,
            }
        end
    end
    lib.registerContext({
        id = 'cc_files_menu',
        title = 'Choose CC file',
        options = options,
    })
    lib.showContext('cc_files_menu')
end)

RegisterNUICallback('done', function(data, cb)
    IsPriting = false
    cb({})
end)

lib.callback.register('scamming:client:inputEmbossCard', function(account, pin)
	exports.ox_inventory:closeInventory()
    lib.showTextUI('Card Number : '.. account ..'/ Pin : ' .. pin, {
        position = "top-center",
        icon = 'fa-credit-card',
    })
    local input = lib.inputDialog('Card Emboss', {
		{ type = 'input', label = 'Card Number', description = 'Put the card number from Fraud CC Files', required = true },
		{ type = 'input', label = 'Pin Code', description = 'Put the pin code from Fraud CC Files', required = true }
	}, { allowCancel = false })

    lib.hideTextUI()

    lib.progressBar({
        duration = 5000,
        label = 'Embossing Credit Card ...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
    })
	return input
end)

lib.callback.register('scamming:client:inputSwipeCard', function()
	exports.ox_inventory:closeInventory()
    local success = playGame()
    if not success then
        return false
    end
    lib.progressBar({
        duration = 5000,
        label = 'Inserting Data in Credit Card ...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        },
    })
	return true
end)