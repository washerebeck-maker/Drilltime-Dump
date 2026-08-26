shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper


fx_version 'bodacious'
game 'gta5'
author 'dullpear'
version '1.0.3'
description 'dpClothing+'

client_scripts {
	'Client/Functions.lua', 		-- Global Functions / Events / Debug and Locale start.
	'Locale/*.lua', 				-- Locales.
	'Client/Config.lua',			-- Configuration.
	'Client/Variations.lua',		-- Variants, this is where you wanan change stuff around most likely.
	'Client/Clothing.lua',
	'Client/GUI.lua',				-- The GUI.
}
