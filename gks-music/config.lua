Config = {}

-- Name shown under the icon on the phone home screen, and in the app store list.
-- The last word is drawn in the purple gradient, so "DRILLTIME FM" renders as
-- DRILLTIMEFM with the FM picked out in colour.
Config.AppLabel = 'DRILLTIME FM'
Config.AppDescription = 'Play music from your phone. Anyone nearby hears it, and anyone can turn you down.'

-- Icon shown on the home screen. Swap this file to rebrand the app.
Config.AppIcon = 'ui/img/icon.svg'

-- true  = the app is already on everyone's home screen when they spawn.
-- false = it only sits in the phone's App Store and each player installs it.
Config.AutoAddToHomeScreen = true

-- Which jobs may NOT use the app, and which jobs may use it exclusively.
-- Leave both empty so everyone gets it.
Config.BlockedJobs = {}
Config.AllowedJobs = {}

-- How far the music carries, in metres.
Config.DefaultRange = 30.0
Config.MinRange = 5.0
Config.MaxRange = 60.0

-- Volume a new broadcast starts at (0.0 - 1.0).
Config.DefaultBroadcastVolume = 0.7

-- Seconds a player must wait between starting tracks. Stops link spam.
Config.PlayCooldown = 3

-- Hard cap on track length in seconds. 0 disables the cap.
-- Useful if people start queueing ten hour loops.
Config.MaxTrackSeconds = 0

-- Only links on these hosts are accepted.
Config.AllowedHosts = {
    'youtube.com',
    'www.youtube.com',
    'm.youtube.com',
    'music.youtube.com',
    'youtu.be',
    'soundcloud.com',
    'www.soundcloud.com',
    'on.soundcloud.com',
}

-- Allow direct links to audio files (internet radio streams, hosted mp3s).
Config.AllowDirectAudio = true
Config.DirectAudioExtensions = { '.mp3', '.ogg', '.wav', '.m4a', '.aac', '.flac' }

-- How often clients reposition sounds and recalculate volume, in ms.
-- 250 is smooth. Raise it if you are chasing frames on a full server.
Config.UpdateInterval = 250

-- Console spam for debugging.
Config.Debug = false
