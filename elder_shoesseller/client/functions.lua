
function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading( entity1, heading )
end

function playAnim(dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(PlayerPedId(), dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
end

function playAnimOnPed(ped, dict, anim, speed, time, flag)
    ESX.Streaming.RequestAnimDict(dict, function()
        TaskPlayAnim(ped, dict, anim, speed, speed, time, flag, 1, false, false, false)
    end)
end

function getRandomOffset()
    local x = { [1] = 2.0, [2] = 2.2, [3] = 2.4, [4] = 2.6, [5] = 2.8, [6] = 3.0, [7] = -2.0, [8] = -2.2, [9] = -2.4, [10] = -2.6, [11] = -2.8, [12] = -3.0}
    local y = { [1] = 2.0, [2] = 2.2, [3] = 2.4, [4] = 2.6, [5] = 2.8, [6] = 3.0, [7] = -2.0, [8] = -2.2, [9] = -2.4, [10] = -2.6, [11] = -2.8, [12] = -3.0}
    return x[math.random(1,#x)], y[math.random(1,#y)]
end

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

function notifyError(text)
    ESX.ShowNotification(text)
end

function notifySuccess(text)
    ESX.ShowNotification(text)
end

function getRandomPositionInRadius()
    local angle = math.random() * 2 * math.pi
    return 10.0 * math.cos(angle), 10.0 * math.sin(angle) 
end

function getLabel(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

function showNotification(msg)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(msg)
	DrawNotification(0,1)
end





