shared = shared or {}
shared.serializer = shared.serializer or {}
local serializer = shared.serializer

function serializer.pack(value)
    if value == nil then return nil end
    local ok, encoded = pcall(json.encode, value)
    if not ok or not encoded then return nil end
    local compressed = LibDeflate:CompressZlib(encoded)
    if not compressed then return nil end
    return LibDeflate:EncodeForPrint(compressed)
end

function serializer.unpack(packed)
    if type(packed) ~= 'string' or packed == '' then return nil end
    local compressed = LibDeflate:DecodeForPrint(packed)
    if not compressed then return nil end
    local raw = LibDeflate:DecompressZlib(compressed)
    if not raw then return nil end
    local ok, decoded = pcall(json.decode, raw)
    if not ok then return nil end
    return decoded
end

function serializer.trigger_client(event_name, target, value)
    TriggerClientEvent(event_name, target, serializer.pack(value))
end

function serializer.register_net(event_name, handler)
    RegisterNetEvent(event_name, function(packed)
        local value = serializer.unpack(packed)
        handler(value)
    end)
end
