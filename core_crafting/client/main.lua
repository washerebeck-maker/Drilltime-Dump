ESX = exports['es_extended']:getSharedObject()

local currentCraft = nil
local isCrafting = false
local Job = {}
local ItemLabels = {}

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	Job = ESX.GetPlayerData().job

    ESX.TriggerServerCallback("core_crafting:getItemNames", function(info)
        ItemLabels = info
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(JobInfo)
    Job = JobInfo
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)  
    Job = xPlayer.job or {}
end)


function isNearWorkbench()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local near = false

    for _, v in ipairs(Config.Workbenches) do
        
            local dst = #(coords - v.coords)
            if dst < v.radius then
                near = true
            end
        
    end
    if near then
        return true
    else
        return false
    end
end

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)
            if currentCraft ~= nil then
                if not Config.CraftingStopWithDistance or (Config.CraftingStopWithDistance and isNearWorkbench()) then
                    currentCraft.time = currentCraft.time - 1

                    SendNUIMessage(
                        {
                            type = "addqueue",
                            item = currentCraft.item,
                            time = currentCraft.time,
                            id = currentCraft.id
                        }
                    )

                    if currentCraft.time == 0 then
                        TriggerServerEvent("core_crafting:itemCrafted", currentCraft.item, currentCraft.count)
                        currentCraft = nil
                        isCrafting = false
                    end
                end
            end
        end
    end
)

function openWorkbench(val)
    ESX.TriggerServerCallback("core_crafting:getXP", function(xp)
        SetNuiFocus(true, true)
        TriggerScreenblurFadeIn(1000)

        local inv = {}
        for _, v in ipairs(ESX.GetPlayerData().inventory) do
            inv[v.name] = v.count
        end

        local recipes = {}

        if #val.recipes > 0 then
            for _, g in ipairs(val.recipes) do
                recipes[g] = Config.Recipes[g]
            end
        else
            recipes = Config.Recipes
        end

        SendNUIMessage({
            type = "open",
            recipes = recipes,
            names = ItemLabels,
            level = xp,
            skills = GetSkills(),
            inventory = inv,
            job = Job.name,
            grade = Job.grade,
            title = val.Title,
            images = Config.ImagesPath,
            hidecraft = Config.HideWhenCantCraft,
            categories = Config.Categories[val.category]})
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for _, v in ipairs(Config.Workbenches) do
            if v.access then
                local dst = #(coords - v.coords)
                if dst < 20 then 
                    DrawText3D(v.coords[1], v.coords[2], v.coords[3] - 0.8 , v.Text) 
                        
                end
                if dst < 2 then
                    if IsControlJustReleased(0, 38) then
                        local open = false
                        for _, g in ipairs(v.jobs) do
                            if g == Job.name then
                                open = true
                            end
                        end
                        if open or #v.jobs == 0 then openWorkbench(v) else SendTextMessage(Config.Text["wrong_job"],"error") end
                    end
                end
            end
         end
    end
end)

RegisterNetEvent("core_crafting:craftStart")
AddEventHandler("core_crafting:craftStart",function(item, count)
    local id = math.random(000, 999)
    isCrafting = true
    currentCraft = {time = Config.Recipes[item].Time, item = item, count = count, id = id}
    SendNUIMessage({type = "crafting",item = item})
    SendNUIMessage({
        type = "addqueue",
        item = item,
        time = Config.Recipes[item].Time,
        id = id
    })
end)

RegisterNetEvent("core_crafting:craftReset")
AddEventHandler("core_crafting:craftReset",function()
    isCrafting = false
end)

RegisterNetEvent("core_crafting:sendMessage")
AddEventHandler("core_crafting:sendMessage",function(msg,type)
    SendTextMessage(msg,type)
end)

RegisterNUICallback("close",function(data)
    TriggerScreenblurFadeOut(1000)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("craft",function(data)
    if isCrafting then
        SendTextMessage(Config.Text["already_crafting"], "error")
        return
    end
    isCrafting = true
    local item = data["item"]
    TriggerServerEvent("core_crafting:craft", item, false)
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = ((1 / dist) * 2) * (1 / GetGameplayCamFov()) * 100
    if onScreen then
        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0 * scale, 0.8 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextDropshadow(1, 1, 1, 1, 255)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.55 * scale, 4)
        local width = EndTextCommandGetWidth(4)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

function SendTextMessage(msg,type)
    ESX.ShowNotification(msg)
end

exports('OpenWorkBench', function(bench)
    openWorkbench(Config.Workbenches[bench])
end)

function GetSkills()
    local result = promise:new()
    ESX.TriggerServerCallback('core_crafting:getSkills', function(cb_result) 
		result:resolve(cb_result)  
    end)
    return Citizen.Await(result)
end 