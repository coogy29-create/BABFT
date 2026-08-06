local Context = getgenv().BABFT_CALCULATOR

local NameService = {}

local Counters = {}

function NameService.Next(prefix)
	prefix = tostring(prefix or "OBJECT")

	Counters[prefix] = (Counters[prefix] or 0) + 1

	return prefix .. "_" .. Counters[prefix]
end

function NameService.Bit(prefix, bit)
	return tostring(prefix) .. "_BIT_" .. tostring(bit)
end

function NameService.Gate(prefix, gateType, index)
	return table.concat({
		tostring(prefix),
		string.upper(tostring(gateType)),
		tostring(index or 0)
	}, "_")
end

function NameService.Module(parent, moduleName)
	return tostring(parent) .. "_" .. tostring(moduleName)
end

function NameService.Child(parent, child)
	return tostring(parent) .. "_" .. tostring(child)
end

function NameService.Reset(prefix)
	if prefix then
		Counters[prefix] = nil
	else
		table.clear(Counters)
	end
end

function NameService.Exists(name)
	return Context:GetObject(name) ~= nil
end

function NameService.Unique(prefix)
	local name

	repeat
		name = NameService.Next(prefix)
	until not NameService.Exists(name)

	return name
end

Context.Modules.NameService = NameService

return NameService
