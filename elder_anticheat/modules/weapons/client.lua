
local g_whitelisted_weapons = {}
local g_copyright = nil

GetItemLabel = function(_item)
	local item  = exports.ox_inventory:Items(_item)
	return item and item.label or _item
end

local function getWhitelistedWeapons()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_anticheat:server:get_whitelisted_weapons', function(data) 
        result:resolve(data)  
    end)
    return Citizen.Await(result)  
end

local function getCopyright()
    local result = promise:new()
    ESX.TriggerServerCallback('elder_anticheat:server:get_copyright', function(data) 
        result:resolve(data)  
    end)
    return Citizen.Await(result)  
end

local function GetItemDataInSlot(slot)
	local items = exports.ox_inventory:GetPlayerItems()
	local data = nil
	for k,v in pairs(items) do 
		if v.slot == slot then
			data = v
			break
		end 
	end
	return data
end

CreateThread(function()
    g_whitelisted_weapons = getWhitelistedWeapons()
    g_copyright = getCopyright()
end)

exports('checkItem', function(slotData)
    if not slotData then return false end
    local item = string.upper(slotData.name)
	if item:sub(0, 7) == 'WEAPON_' then 
        if not g_whitelisted_weapons[item] then
            if slotData.metadata and not slotData.metadata.serial and ( not slotData.metadata.copyright or slotData.metadata.copyright ~= g_copyright) then
                TriggerServerEvent('elder_anticheat:server:illegal_item_detected', slotData, GetItemLabel(slotData.name))
                return false
            end
        end
    end 
    return true
end)

exports('checkGiveItem', function(slot)
    if not slot then return false end
    local data = GetItemDataInSlot(slot)
    local item = string.upper(data.name)
	if item:sub(0, 7) == 'WEAPON_' then 
        if not g_whitelisted_weapons[item] then 
            if data.metadata and not data.metadata.serial and ( not data.metadata.copyright or data.metadata.copyright ~= g_copyright) then
                TriggerServerEvent('elder_anticheat:server:illegal_item_detected', data, GetItemLabel(data.name))
                return false
            end
        end
    end
    return true
end)

exports('checkSwapItem', function(slotData)
    if not slotData then return false end
    if slotData.fromType ~= 'player' then return true end
    local data = GetItemDataInSlot(slotData.fromSlot)
    local item = string.upper(data.name)
	if item:sub(0, 7) == 'WEAPON_' then 
        if not g_whitelisted_weapons[item] then 
            if data.metadata and not data.metadata.serial and ( not data.metadata.copyright or data.metadata.copyright ~= g_copyright) then
                TriggerServerEvent('elder_anticheat:server:illegal_item_detected', data, GetItemLabel(data.name))
                return false
            end
        end
    end
    return true
end)

