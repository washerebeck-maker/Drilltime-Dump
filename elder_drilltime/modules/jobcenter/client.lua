local function DrawBusySpinner(text)
    SetLoadingPromptTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    ShowLoadingPrompt(3)
end

local function DrawText3D(x, y, z, text)
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

local function TeleportToJob(coords)
    ESX.Game.Teleport(cache.ped, coords)
    local freezed = true
    CreateThread(function()
        FreezeEntityPosition(cache.ped, true)
        Wait(10 * 1000)
        FreezeEntityPosition(cache.ped, false)
        freezed = false
    end)
    CreateThread(function()
        local timer = 10
        while freezed and timer > 0 do
            DrawBusySpinner("loading, please wait : ".. timer .. " seconds")
            Wait(1000)
            timer = timer - 1
        end
        RemoveLoadingPrompt()
    end)
end

local function OpenJobCenter()
    local menuOptions = {} 
    for k,v in pairs(Config.Jobcenter.jobs) do 
        table.insert(menuOptions, 
            {
                title = v.title, 
                description = 'Teleport to job area.',
                arrow = true, 
                icon = v.icon, 
                iconColor = v.color, 
                onSelect = function() TeleportToJob(v.coords) end
            }
        )
    end 
    lib.registerContext({
        id = 'jobcenter_menu',
        title = 'Job Center',
        options = menuOptions,
    })
    lib.showContext('jobcenter_menu')
end


Citizen.CreateThread(function()   
    local model = GetHashKey(Config.Jobcenter.model)
    local coords1 = Config.Jobcenter.coords1
    local coords2 = Config.Jobcenter.coords2

    local blip = AddBlipForCoord(coords1)
	SetBlipSprite(blip, 408)
	SetBlipColour(blip, 5)
	SetBlipAlpha(blip, 250)
	SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Job Center")
	EndTextCommandSetBlipName(blip)

    
    ESX.Streaming.RequestModel(model)

    local ped1 = CreatePed(5, model, coords1.x, coords1.y, coords1.z-1, coords1.w, false, true)
    PlaceObjectOnGroundProperly(ped1)
    FreezeEntityPosition(ped1, true)
    SetEntityInvincible(ped1, true)
    SetBlockingOfNonTemporaryEvents(ped1, true)	 

    local ped2 = CreatePed(5, model, coords2.x, coords2.y, coords2.z-1, coords2.w, false, true)
    PlaceObjectOnGroundProperly(ped2)
    FreezeEntityPosition(ped2, true)
    SetEntityInvincible(ped2, true)
    SetBlockingOfNonTemporaryEvents(ped2, true)	 
    
    
    local textUI
    local location1 = lib.points.new({
            coords = coords1,
            distance = 20.0
    })

    function location1:onEnter()
        
    end
    function location1:onExit()
        
    end
    function location1:nearby()
        if self.currentDistance < self.distance then
            DrawText3D(self.coords.x, self.coords.y, self.coords.z + 1.3, "~p~DRILLTIME JOB CENTER~s~")
            DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 0.7,128, 0, 128, 170, false, false, 2, false, false, false, false)
            if self.currentDistance <= 1.5 then
                if not textUI then
                    lib.showTextUI('[E] - Job Center', {icon = 'fa-building-circle-arrow-right'})
                    textUI = true
                end
                if IsControlJustReleased(0, 38) then
                    OpenJobCenter()
                end
            elseif self.currentDistance >= 1.5 and textUI then
                lib.hideTextUI()
                textUI = nil
            end
        end
    end

    local location2 = lib.points.new(coords2, 2, {})
    function location2:onEnter()
        lib.showTextUI('[E] - Job Center', {icon = 'fa-building-circle-arrow-right'})
    end
    function location2:onExit()
        lib.hideTextUI()
    end
    function location2:nearby()
        if IsControlJustReleased(0, 38) then
            OpenJobCenter()
        end
    end
end)




