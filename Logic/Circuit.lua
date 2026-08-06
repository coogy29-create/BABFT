local Context = getgenv().BABFT_CALCULATOR

local Circuit = {}

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local function createGate(spec)
	assert(spec.Name, "Gate Name 누락")
	assert(spec.Type, "Gate Type 누락")
	assert(typeof(spec.CFrame) == "CFrame", "Gate CFrame 누락: " .. tostring(spec.Name))

	if spec.Type == "And" then
		return Gates.And(spec.Name, spec.CFrame)
	elseif spec.Type == "Or" then
		return Gates.Or(spec.Name, spec.CFrame)
	elseif spec.Type == "Xor" then
		return Gates.Xor(spec.Name, spec.CFrame)
	elseif spec.Type == "Not" then
		return Gates.Not(spec.Name, spec.CFrame)
	end

	error("지원하지 않는 Gate 종류: " .. tostring(spec.Type))
end

function Circuit.Build(definition)
	assert(type(definition) == "table", "definition은 테이블이어야 합니다.")

	local result = {
		Name = definition.Name or "Circuit",
		Objects = {},
		Outputs = {},
		Inputs = definition.Inputs or {}
	}

	for _, spec in ipairs(definition.Gates or {}) do
		local object = createGate(spec)
		result.Objects[spec.Name] = object
	end

	for _, connection in ipairs(definition.Connections or {}) do
		assert(connection.From, "Connection From 누락")
		assert(connection.To, "Connection To 누락")

		if type(connection.To) == "table" then
			Wiring.ConnectMany(
				connection.From,
				connection.To
			)
		else
			Wiring.Connect(
				connection.From,
				connection.To
			)
		end
	end

	for outputName, source in pairs(definition.Outputs or {}) do
		if typeof(source) == "Instance" then
			result.Outputs[outputName] = source
		else
			result.Outputs[outputName] =
				Context:GetObject(source)
				or result.Objects[source]
		end
	end

	return result
end

function Circuit.ConnectInput(source, targets)
	if type(targets) == "table" then
		Wiring.ConnectMany(source, targets)
	else
		Wiring.Connect(source, targets)
	end
end

function Circuit.ConnectOutput(source, targets)
	if type(targets) == "table" then
		Wiring.ConnectMany(source, targets)
	else
		Wiring.Connect(source, targets)
	end
end

Context.Modules.Circuit = Circuit

return Circuit
