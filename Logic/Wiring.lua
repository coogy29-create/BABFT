local Context = getgenv().BABFT_CALCULATOR

local Wiring = {}

local Binder = Context.Modules.Bind

local function normalizeTargets(...)
	local result = {}

	for _, value in ipairs({...}) do
		if type(value) == "table" then
			for _, v in ipairs(value) do
				table.insert(result, v)
			end
		else
			table.insert(result, value)
		end
	end

	return result
end

function Wiring.Connect(source, target)

	Context:QueueConnection({
		Source = source,
		Targets = {target},
		Remove = false
	})

end

function Wiring.ConnectMany(source, ...)

	Context:QueueConnection({
		Source = source,
		Targets = normalizeTargets(...),
		Remove = false
	})

end

function Wiring.Disconnect(source, target)

	Context:QueueConnection({
		Source = source,
		Targets = {target},
		Remove = true
	})

end

function Wiring.DisconnectMany(source, ...)

	Context:QueueConnection({
		Source = source,
		Targets = normalizeTargets(...),
		Remove = true
	})

end

function Wiring.BindNow(source, target)

	return Binder.Bind(
		source,
		{target}
	)

end

function Wiring.UnbindNow(source, target)

	return Binder.Unbind(
		source,
		{target}
	)

end

function Wiring.Bus(sourceBus, targetBus)

	assert(#sourceBus == #targetBus)

	for i = 1, #sourceBus do
		Wiring.Connect(
			sourceBus[i],
			targetBus[i]
		)
	end

end

function Wiring.BusIndexed(sourceBus, targetBus)

	for bit, source in pairs(sourceBus) do
		local target = targetBus[bit]

		if target then
			Wiring.Connect(
				source,
				target
			)
		end
	end

end

Context.Modules.Wiring = Wiring

return Wiring
