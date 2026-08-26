lib.callback.register('elder_admin:client:gmrevive_input', function()
	local input = lib.inputDialog('Revive', {
		{ type = 'input', label = 'Citizen ID', description = 'Citizen ID of the person to be revived', required = true },
		{ type = 'textarea', label = 'Reason', description = 'Give more details', required = true },
	}, { allowCancel = true })
    return input
end)

lib.callback.register('elder_admin:client:gmrevive_image', function(webhook)
	local image = nil

    exports['screenshot-basic']:requestScreenshotUpload(webhook, 'files[]', function(data) 
        local resp = json.decode(data)
        image = resp.attachments[1].url
    end)
    while image == nil do Wait(100) end
	return image
end)
