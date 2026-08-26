RegisterNetEvent('esx_drilltime:boost_discord:client:set_presence')
AddEventHandler('esx_drilltime:boost_discord:client:set_presence', function(data)
	local data = data
	local player = PlayerId()
	if Config.UseJobs then
		SetDiscordRichPresenceAssetSmall(data.job.name)
		SetDiscordRichPresenceAssetSmallText(data.job.label .. " - " .. data.job.grade_label)	
	end	
	--This is the Application ID (Replace this with you own)
	SetDiscordAppId(Config.ClientID)
	--Here you will have to put the image name for the "large" icon.
	SetDiscordRichPresenceAsset('newlarge')
	if Config.UseESXIdentity then
		SetRichPresence((Config.RichPresence):format(GetPlayerServerId(player), data.identityName, Config.PlayerText, data.activePlayers, tostring(Config.PlayerCount)))
	else
		SetRichPresence((Config.RichPresence):format(GetPlayerServerId(player), data.playerName, Config.PlayerText, data.activePlayers, tostring(Config.PlayerCount)))
	end
	SetDiscordRichPresenceAssetText('DrillTime')
end)

Citizen.CreateThread(function()
	while not PlayerLoaded do
		Citizen.Wait(10)
	end
	while true do
		TriggerServerEvent('esx_drilltime:boost_discord:server::update_presence')
		Citizen.Wait(Config.ResourceTimer * 1000)
	end
end)

