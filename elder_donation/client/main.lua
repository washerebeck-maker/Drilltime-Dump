
ESX = exports['es_extended']:getSharedObject()

function notify(description,type)
    lib.notify({
        description = description,
        position = 'center-left',
        type = type,
        duration = 5000
    })
end

function getItemLabel(name)
	local item  = exports.ox_inventory:Items(name)
	return item and item.label or name
end

function getItemImage(name)
    return config.images_path .. name .. '.png'
end