local function isFirstRewardAllowed()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:gangpackage:server:isFirstRewardAllowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function isSecondRewardAllowed()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_drilltime:gangpackage:server:isSecondRewardAllowed', function(data) 
		result:resolve(data)  
    end)
    return Citizen.Await(result)
end

local function isGangLeader()
    local gang = exports.elder_gangs:get_player_gang()
    return gang and gang.is_leader or false
end

local function claimFree()
    TriggerServerEvent('elder_drilltime:gangpackage:server:claimFree')
end

local function claimFirst()
    TriggerServerEvent('elder_drilltime:gangpackage:server:claimFirst')
end

local function claimSecond()
    TriggerServerEvent('elder_drilltime:gangpackage:server:claimSecond')
end


local function openGangPackageMenu()
    local _isFirstRewardAllowed = isFirstRewardAllowed()
    local _isSecondRewardAllowed = isSecondRewardAllowed()
    local _isGangLeader = isGangLeader()

    local menuOptions = {} 
    table.insert(menuOptions, {
        title = 'Gang Leader Reward', 
        icon = 'fa-gift', 
        iconColor = 'silver', 
        disabled = (not _isGangLeader or ( _isFirstRewardAllowed or _isSecondRewardAllowed)),
        onSelect = function() 
            claimFree()
        end
    })
    table.insert(menuOptions, {
        title = 'Gold Gang Leader Reward', 
        icon = 'fa-star', 
        iconColor = 'gold',
        disabled = (not _isGangLeader or not _isFirstRewardAllowed or _isSecondRewardAllowed),
        onSelect = function()
            claimFirst()
        end
    })
    table.insert(menuOptions, {
        title = 'Diamond Gang Leader Reward', 
        icon = 'fa-gem', 
        iconColor = '#b9f2ff', 
        disabled = (not _isGangLeader or not _isSecondRewardAllowed),
        onSelect = function() 
            claimSecond()
        end
    })

    lib.registerContext({
        id = 'gang_leader_reward',
        title = 'Gang Leaders Weekly Reward',
        options = menuOptions,
    })
    lib.showContext('gang_leader_reward')
end

CreateThread(function()
    local model = lib.requestModel(Config.GangPackage.npc.model)
    local coords = Config.GangPackage.npc.coords

    lib.requestModel(model)
    NPC = CreatePed(5, model, coords.x, coords.y, coords.z-0.9, coords.w, false, true)
    PlaceObjectOnGroundProperly(NPC)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)


    local point = lib.points.new({ coords = coords, distance = 2.0})
    function point:nearby()
        if IsControlJustPressed(0, 38) then
            openGangPackageMenu()
        end
    end
    function point:onEnter()
        lib.showTextUI('[E] GANG LEADERS REWARDS', { position = "right-center", icon = 'crown', iconColor= 'gold'}) 
    end
    function point:onExit()
        lib.hideTextUI()
    end
end)