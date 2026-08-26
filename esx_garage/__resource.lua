shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper



resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts {
	"config.lua",
	"client/functions.lua",
	"client/main.lua"
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"config.lua",
	"server/main.lua",
	"server/functions.lua",
}





