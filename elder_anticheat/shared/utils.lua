CompareTables = function(t1, t2)
    if not t1 or not t2 then
        return false
    end
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false
    end
    for key, value in pairs(t1) do
        if type(value) == "table" then
            if not CompareTables(value, t2[key]) then
                return false
            end
        elseif value ~= t2[key] then
            return false
        end
    end
    for key, value in pairs(t2) do
        if type(value) == "table" then
            if not CompareTables(value, t1[key]) then
                return false
            end
        elseif value ~= t1[key] then
            return false
        end
    end
    return true
end


function ToString(t, indent)
    local result = ""
    indent = indent or 0
    local function addIndent()
        for i = 1, indent do
            result = result .. "    "
        end
    end
    
    if type(t) == "table" then
        result = result .. "{\n"
        for k, v in pairs(t) do
            addIndent()
            if type(k) == "number" then
                result = result .. "[" .. k .. "] = "
            else
                result = result .. k .. " = "
            end
            if type(v) == "table" then
                result = result .. ToString(v, indent + 1)
            elseif type(v) == "string" then
                result = result .. '"' .. v .. '"'
            else
                result = result .. tostring(v)
            end
            result = result .. ",\n"
        end
        addIndent()
        result = result .. "}"
    else
        result = tostring(t)
    end
    return result
end
