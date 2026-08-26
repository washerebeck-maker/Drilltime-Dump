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

resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

server_scripts {
	"config.lua",
	"server.lua"
}

server_export "IsRolePresent"
server_export "GetRoles"

