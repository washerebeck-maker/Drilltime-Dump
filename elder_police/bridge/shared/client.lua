
local timeouts = {}

function SetTimeout(msec, cb)
    timeouts[#timeouts + 1] = {
        time = GetGameTimer() + msec,
        cb = cb
    }
    return #timeouts
end

function ClearTimeout(i)
    timeouts[i] = nil
end

function Trim(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end