local framework = client.framework
local datastore = client.datastore

local isOpen = false

local function open_admin()
  if isOpen then return end
  if not datastore.player.data?.is_admin then
    lib.notify({ type = 'error', description = 'You are not allowed to open the gang admin panel.' })
    return
  end
  isOpen = true
  SetNuiFocus(true, true)
  local memberAvatars = lib.callback.await('elder_gangs:admin:get_member_avatars', false) or {}
  SendNUIMessage({
    action = 'openAdmin',
    gangs = datastore.gangs.get_all(),
    adminName = framework.player.get_name(),
    defaultAvatar = Config.DefaultAvatar,
    memberAvatars = memberAvatars,
  })
end

local function close_admin()
  if not isOpen then return end
  isOpen = false
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })
end

RegisterCommand('gangadmin', function()
  open_admin()
end, false)

RegisterNUICallback('close', function(_, cb)
  close_admin()
  cb({ ok = true })
end)

RegisterNUICallback('getMyCoords', function(_, cb)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  cb({
    coords = {
      x = pos.x + 0.0,
      y = pos.y + 0.0,
      z = pos.z + 0.0,
      h = heading + 0.0,
    },
  })
end)

RegisterNUICallback('getGangs', function(_, cb)
  datastore.gangs.invalidate()
  cb({ gangs = datastore.gangs.get_all() })
end)


RegisterNUICallback('teleportToPed', function(payload, cb)
  if not datastore.player.data?.is_admin then
    cb({ ok = false, error = 'forbidden' })
    return
  end
  local c = payload and payload.coords
  if not c or c.x == nil or c.y == nil or c.z == nil then
    cb({ ok = false, error = 'bad_coords' })
    return
  end
  local ped = PlayerPedId()
  SetEntityCoords(ped, c.x + 0.0, c.y + 0.0, c.z + 0.0, false, false, false, false)
  if c.h ~= nil then SetEntityHeading(ped, c.h + 0.0) end
  cb({ ok = true })
end)

RegisterNUICallback('createGang', function(payload, cb)
  local res = lib.callback.await('elder_gangs:admin:create_gang', false, payload)
  cb(res or { ok = false })
end)

RegisterNUICallback('updateGang', function(payload, cb)
  local res = lib.callback.await('elder_gangs:admin:update_gang', false, payload)
  cb(res or { ok = false })
end)

RegisterNUICallback('setGangStatus', function(payload, cb)
  local res = lib.callback.await('elder_gangs:admin:set_status', false, payload)
  cb(res or { ok = false })
end)

RegisterNUICallback('removeGang', function(payload, cb)
  local res = lib.callback.await('elder_gangs:admin:remove_gang', false, payload)
  cb(res or { ok = false })
end)

local function refresh_admin_ui()
  if not isOpen then return end
  SendNUIMessage({ action = 'refresh', gangs = datastore.gangs.get_all() })
end

RegisterNetEvent('elder_gangs:datastore:gangs:create', refresh_admin_ui)
RegisterNetEvent('elder_gangs:datastore:gangs:update', refresh_admin_ui)
RegisterNetEvent('elder_gangs:datastore:gangs:remove', refresh_admin_ui)
