ESX = nil

local PlayerJob = nil

local CoolDown = false

CreateThread(function()
    while ESX == nil do
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
        if ESX == nil then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        end
        Wait(50)
    end 
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerJob = ESX.GetPlayerData().job 
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   PlayerJob = xPlayer.job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
    PlayerJob = job
end)

RegisterCommand(Config.Command, function()
    if not Config.ADV[PlayerJob.name] then
        return
    end
    OpenAdvMenu()
end)

function IsAllowedGrade(index)
    for _,v in pairs(Config.ADV[PlayerJob.name][index].allowedgrades) do 
        if PlayerJob.grade == v then
            return true
        end
    end
    return false
end

function OpenAdvMenu()
    local menuOptions = {} 
    for k,v in ipairs(Config.ADV[PlayerJob.name]) do
        if IsAllowedGrade(k) then
            table.insert(menuOptions, 
            {
                title = '#'..k .. ' ' .. v.title .. ' | price : $' .. ESX.Math.GroupDigits(v.price),
                description = v.text,
                icon = v.icon,
                iconColor = 'rgb('..v.color[1]..','..v.color[2]..','..v.color[3]..')',
                onSelect = function() SendAlert(v) end
            })
        end
    end
    
    lib.registerContext({
        id = 'adv_menu',
        title = 'Adv Menu',
        options = menuOptions,
    })
    lib.showContext('adv_menu')
end

function SendAlert(alert)
    if not CoolDown then 
        TriggerServerEvent('elder_adv:server:sendAlert', alert)
        CoolDown = true
        Citizen.CreateThread(function()
            Citizen.Wait(Config.CoolDown * 1000)
            CoolDown = false
        end)
    else
        ESX.ShowNotification('You should wait for cooldown')
    end
end