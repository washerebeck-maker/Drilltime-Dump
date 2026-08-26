ESX = exports.es_extended:getSharedObject()

function notify(msg, type, duration)
    return lib.notify({ description = msg, position = 'center-left', type = type, duration = duration })
end

function getItemLabel(name)
	local item = exports.ox_inventory:Items(name)
	return item and item.label or name
end