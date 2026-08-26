shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper



























-- THIS MUST BE ABOVE ALL OTHER SCRIPTS
--x
--
------------------------------------------

-- THIS MUST BE ABOVE ALL OTHER SCRIPTS
--x
--
------------------------------------------

fx_version 'cerulean'
game 'gta5'

author 'JaredScar'
description 'Badger\'s Discord API'
version '1.6'
url 'https://github.com/JaredScar/Badger_Discord_API'

client_scripts {
	'client.lua',
}

server_scripts {
	'config.lua',
	"server.lua", -- Uncomment this line
	--"example.lua" -- Remove this when you actually start using the script!!!
}

server_exports { 
	"GetDiscordRoles",
	"GetRoleIdFromRoleName",
	"GetDiscordAvatar",
    "GetDiscordBanner",
	"GetDiscordName",
	"GetDiscordEmail",
	"IsDiscordEmailVerified",
	"GetDiscordNickname",
	"GetGuildIcon",
	"GetGuildSplash",
	"GetGuildName",
	"GetGuildDescription",
	"GetGuildMemberCount",
	"GetGuildOnlineMemberCount",
	"GetGuildRoleList",
	"ResetCaches",
	"CheckEqual"
} 






