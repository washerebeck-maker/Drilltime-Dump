local SCREENSHOT_CAPTURE_TIMEOUT_MS = 15000
local shotBusy = false
local GLOBAL_STATE_KEY = 'elder_dispatch_screenshot_upload'

local function trim(s)
    if type(s) ~= 'string' then return '' end
    return (s:match('^%s*(.-)%s*$') or '')
end

local function uploadUrl()
    local gs = GlobalState[GLOBAL_STATE_KEY]
    if type(gs) == 'string' and trim(gs) ~= '' then
        return trim(gs)
    end
    return ''
end

local function extractImageUrlFromUploadResponse(data)
    if not data or data == '' or type(data) ~= 'string' then
        return nil
    end
    local trimmed = data:match('^%s*(.-)%s*$') or data
    if trimmed:match('^https?://') and not trimmed:match('^%s*[%[{]') then
        return trimmed
    end
    local ok, decoded = pcall(json.decode, data)
    if ok and type(decoded) == 'string' and decoded:match('^https?://') then
        return decoded
    end
    if ok and type(decoded) == 'table' then
        if type(decoded.url) == 'string' and decoded.url:match('^https?://') then
            return decoded.url
        end
        if type(decoded.link) == 'string' and decoded.link:match('^https?://') then
            return decoded.link
        end
        local attachments = decoded.attachments
        if type(attachments) == 'table' then
            for i = 1, #attachments do
                local att = attachments[i]
                if type(att) == 'table' and type(att.url) == 'string' and att.url:match('^https?://') then
                    return att.url
                end
            end
        end
        local embeds = decoded.embeds
        if type(embeds) == 'table' then
            for i = 1, #embeds do
                local e = embeds[i]
                if type(e) == 'table' and type(e.image) == 'table' and type(e.image.url) == 'string' and e.image.url:match('^https?://') then
                    return e.image.url
                end
            end
        end
        if type(decoded[1]) == 'string' and decoded[1]:match('^https?://') then
            return decoded[1]
        end
    end
    local cdn = trimmed:match('(https://cdn%.discordapp%.com/[^%s"<>]+)')
    if cdn then return cdn end
    cdn = trimmed:match('(https://media%.discordapp%.net/[^%s"<>]+)')
    if cdn then return cdn end
    local generic = trimmed:match('(https?://%S+)')
    if generic then return generic end
    return nil
end

function getScreenshot()
    if shotBusy then
        return nil
    end
    local url = uploadUrl()
    if url == '' or GetResourceState('screenshot-basic') ~= 'started' then
        return nil
    end
    local holder = { done = false, result = nil }
    shotBusy = true
    local okShot = pcall(function()
        exports['screenshot-basic']:requestScreenshotUpload(
            url,
            'file',
            {
                encoding = 'jpg',
                headers = {},
            },
            function(data)
                holder.result = extractImageUrlFromUploadResponse(data)
                holder.done = true
            end
        )
    end)
    if not okShot then
        shotBusy = false
        return nil
    end
    local deadline = GetGameTimer() + SCREENSHOT_CAPTURE_TIMEOUT_MS
    while not holder.done and GetGameTimer() < deadline do
        Wait(0)
    end
    shotBusy = false
    if type(holder.result) == 'string' and holder.result:match('^https?://') then
        return holder.result
    end
    return nil
end
