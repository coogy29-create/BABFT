local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local Circuit = {}

local function createGate(spec)

	local gate

	if spec.Type == "And" then
		gate = Gates.And(spec.Name,spec.CFrame)

	elseif spec.Type == "Or" then
		gate = Gates.Or(spec.Name,spec.CFrame)

	elseif spec.Type == "Xor" then
		gate = Gates.Xor(spec.Name,spec.CFrame)

	elseif spec.Type == "Not" then
		gate = Gates.Not(spec.Name,spec.CFrame)

	else
		error("지원하지 않는 Gate : "..tostring(spec.Type))
	end

	return gate

end

function Circuit.Build(definition)

	assert(definition)

	local objects={}

	if definition.Gates then

		for _,gate in ipairs(definition.Gates) do

			objects[gate.Name]=createGate(gate)

		end

	end

	if definition.Connections then

		for _,connection in ipairs(definition.Connections) do

			Wiring.Connect(
				connection.From,
				connection.To
			)

		end

	end

	return objects

end

Context.Modules.Circuit=Circuit

return Circuit
