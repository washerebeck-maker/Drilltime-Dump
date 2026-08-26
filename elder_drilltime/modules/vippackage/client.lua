

isAllowed = function()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:vippackage:server:is_allowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function claimVipPackage()
    TriggerServerEvent('elder_drilltime:vippackage:server:claim_daily')
end

CreateThread(function()
    local model = lib.requestModel(Config.VipPackage.npc.model)
    local coords = Config.VipPackage.npc.coords

    lib.requestModel(model)
    NPC = CreatePed(5, model, coords.x, coords.y, coords.z-0.9, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)


    local point = lib.points.new({ coords = coords, distance = 2.0})
    function point:nearby()
        if IsControlJustPressed(0, 38) then
            claimVipPackage()
        end
    end
    function point:onEnter()
        lib.showTextUI('[E] VIP REWARDS', { position = "right-center", icon = 'crown', iconColor= 'gold'}) 
    end
    function point:onExit()
        lib.hideTextUI()
    end
end)