shared_script "@ReaperV4/imports/bypass.lua"
shared_script "@ReaperV4/imports/bypass_s.lua"
shared_script "@ReaperV4/imports/bypass_c.lua"
lua54 "yes" -- needed for Reaper

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'gks-music'
author 'Trase'
description 'Proximity music app for GKSPHONE v2. Paste a link, your phone becomes the speaker, and anyone nearby can turn you down.'
version '1.0.0'
shared_script 'config.lua'
client_script 'client/client.lua'
server_script 'server/server.lua'
-- This is deliberately a blank, fully transparent page.
-- A resource's ui_page is always painted on top of the game, so the real app
-- must NOT live here or it would cover the player's screen. This empty frame
-- exists only so RegisterNUICallback binds for this resource; the actual app is
-- ui/index.html, which GKSPHONE loads inside the phone.
ui_page 'ui/nui.html'
files {
    'ui/nui.html',
    'ui/index.html',
    'ui/css/*.css',
    'ui/js/*.js',
    'ui/img/*.svg',
    'ui/fonts/*.woff2',
}
-- xsound is deliberately NOT declared as a dependency. A hard dependency makes
-- FiveM refuse to start this resource at all when xsound is missing, so the app
-- would vanish from the phone entirely with no obvious reason. Instead the
-- server checks for it at runtime and says so in console: the app still
-- installs and opens, it just cannot play audio until xsound is added.
