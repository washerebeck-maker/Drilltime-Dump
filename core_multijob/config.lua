Config = {

MaxJobs = 10, -- Maximum amount of jobs avalable for every player (Only applies to jobs that are auto savable)
AllowAutoJobSavining = true, -- When the script detects a new job it will add it to your jobs Ex. You get police job and it saves that job (if maximum not reached) to your job list

OpenJobUIKey = 'F12', -- The key used to open the UI (Leave blank if you do not want to use key)
OpenJobUICommand = 'jobs', -- Command used to open the UI (MUST NOT BE BLANK!!)

--Set up blip info (https://docs.fivem.net/docs/game-references/blips/)
BlipSprite = 457,
BlipColor = 3,
BlipText = 'Job Managment',

MarkerSprite = 27,
MarkerColor = {66, 135, 245},
MarkerSize = 1.5,

LocationsToChangeJobs = { -- If you want you can setup locations to change jobs (Leave without entiries if you dont want locations) (ADDS 0.02 MS)
	{coords = vector3(-267.58975219727,-958.55718994141,-31.22312927246), blip = false}
},

OffdutyForEveryone = true, -- Everyone can go into offduty job
JobsThatCanUseOffduty = { -- Jobs that can use offduty if option above is false
	'police',
	'ambulance',
	'mechanic'
},

DefaultJobs = { -- Jobs that will be added in menu by default and wont be removable
	
	{job = 'unemployed', grade = 0}
},

Text = {

	['cant_offduty'] = 'You cant go offduty!',
	['open_ui_hologram'] = '[~b~E~w~] Open Job Managment',
	['wrong_usage'] = 'Wrong command usage'

}
	

}

-- Only change if you know what are you doing!
function SendTextMessage(msg)
	-- SetNotificationTextEntry('STRING')
	-- AddTextComponentString(msg)
	-- DrawNotification(0,1)

	--EXAMPLE USED IN VIDEO
	exports['mythic_notify']:SendAlert('error', msg)
end
