client = client or {}
client.framework = client.framework or {}
local framework = client.framework
framework.player = framework.player or {}
framework.vehicle = framework.vehicle or {}

local ESX = exports['es_extended']:getSharedObject()

function framework.player.is_loaded()
  return ESX.IsPlayerLoaded() == true
end

function framework.player.get_data()
  return ESX.GetPlayerData()
end

function framework.player.get_name()
  local data = ESX.GetPlayerData()
  if data and data.firstName then
    local full = ((data.firstName or '') .. ' ' .. (data.lastName or '')):gsub('^%s+', ''):gsub('%s+$', '')
    if full ~= '' then return full end
  end
  return GetPlayerName(PlayerId())
end

function framework.player.get_job_name()
  local data = ESX.GetPlayerData()
  return data and data.job and data.job.name or nil
end

function framework.notify(msg)
  ESX.ShowNotification(msg or '')
end

function framework.vehicle.get_in_direction()
  return ESX.Game.GetVehicleInDirection()
end
