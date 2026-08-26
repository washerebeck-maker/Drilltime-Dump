local datastore = client.datastore

function get_player_gang()
    return datastore.player.get()?.gang
end

function get_player_gang_id()
    local gang = datastore.player.get()?.gang
    return gang and gang.id and tostring(gang.id) or nil
end

function in_gang_hood()
    return InMyHood == true or InOtherHood == true
end

function is_in_own_hood()
    return InMyHood == true
end

function is_in_other_hood()
    return InOtherHood == true
end

exports('get_player_gang', get_player_gang)
exports('get_player_gang_id', get_player_gang_id)
exports('in_gang_hood', in_gang_hood)
exports('is_in_own_hood', is_in_own_hood)
exports('is_in_other_hood', is_in_other_hood)
