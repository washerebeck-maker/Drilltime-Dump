
G_NPC = nil
G_CurrentJob = nil

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.JobCenter.coords)
    SetBlipSprite(blip, 826)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 38)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Job Center")
    EndTextCommandSetBlipName(blip)

    ESX.Streaming.RequestModel(Config.JobCenter.ped)
    G_NPC = CreatePed(5, GetHashKey(Config.JobCenter.ped), Config.JobCenter.coords.x, Config.JobCenter.coords.y, Config.JobCenter.coords.z-1, Config.JobCenter.coords.w, false, true)
	PlaceObjectOnGroundProperly(G_NPC)
	TaskStartScenarioInPlace(G_NPC, "WORLD_HUMAN_CLIPBOARD", 0, true)
    FreezeEntityPosition(G_NPC, true)
    SetEntityInvincible(G_NPC, true)
    SetBlockingOfNonTemporaryEvents(G_NPC, true)
end)


Citizen.CreateThread(function()
    local wait
    while true do
        local ped = PlayerPedId()
        local ped_coords = GetEntityCoords(ped)
        if GetDistanceBetweenCoords(ped_coords, Config.JobCenter.coords,true) <= 1.5 then
            wait = 1
            ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to choose a ~y~job~s~')
            if IsControlJustReleased(0, 38) then
                OpenJobMenu()
            end
        else
            wait = 1000
        end
        Citizen.Wait(wait)
    end
end)

RegisterNetEvent('elder_jobs:client:job')
AddEventHandler('elder_jobs:client:job', function(args)
    if not G_CurrentJob then
        ESX.TriggerServerCallback('elder_jobs:server:check_job', function(check)
            if check then
                TriggerEvent(args.event)
            else
                Notify('You cannot start this job', 'error')
            end
        end,args.job)
    else
        Notify('You are already in job', 'error')
    end
end)

RegisterNetEvent('elder_jobs:client:leave_job')
AddEventHandler('elder_jobs:client:leave_job', function(args)
    if G_CurrentJob then
        TriggerEvent(Config.Jobs[G_CurrentJob].leave_job_event)
    end
end)

-- functions

function OpenJobMenu()
    local Options = {}
    for k,v in pairs(Config.Jobs) do
        Options[#Options + 1] = 
        {
            title = v.title,
            description = v.description,
            icon = v.icon,
            iconColor = v.color,
            arrow = true,
            event = 'elder_jobs:client:job',
            args = {job = k, event = v.event}
        }
    end

    Options[#Options + 1] = 
        {
            title = "Clock Out",
            description = '',
            icon = 'fa-right-from-bracket',
            iconColor = 'red',
            arrow = true,
            event = 'elder_jobs:client:leave_job',
        }
		
	lib.registerContext({
		id = 'job_center_menu',
		title = 'Job Center : Choose the job ...',
		options = Options
	})
	lib.showContext('job_center_menu')
end





