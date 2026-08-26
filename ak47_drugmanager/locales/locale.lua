Locales = {}

function translate(str, ...)  -- Translate string

	if Locales[Config.Locale] ~= nil then

		if Locales[Config.Locale][str] ~= nil then
			local args = {...}
			if not CheckArgs(args) then 
				return 'Locale [' .. Config.Locale .. '] does not exist'
			end
			return string.format(Locales[Config.Locale][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(translate(str, ...):gsub("^%l", string.upper))
end

CheckArgs = function(args)
	for k,v in pairs(args) do
		if v == nil or v == '' then
			return false
		end
	end
	return true
end
