local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils

local Property = {}

local function getPropertyRemote()
	local tool = Utils.WaitForTool(
		Config.Tools.PropertiesTool,
		true,
		10
	)

	assert(
		tool,
		"PropertiesTool을 찾을 수 없습니다."
	)

	local remote = tool:FindFirstChild(
		"SetPropertieRF"
	)

	assert(
		remote,
		"PropertiesTool.SetPropertieRF를 찾을 수 없습니다."
	)

	return remote
end

local function resolveObject(object)
	if typeof(object) == "Instance" then
		return object
	end

	local found = Context:GetObject(object)

	assert(
		found and found.Parent,
		"등록되지 않은 Gate: "
			.. tostring(object)
	)

	return found
end

function Property.Set(gateType, objects)
	assert(
		Config.GateTypes[gateType],
		"지원하지 않는 Gate 종류: "
			.. tostring(gateType)
	)

	assert(
		type(objects) == "table",
		"objects는 테이블이어야 합니다."
	)

	local targets = {}

	for _, object in ipairs(objects) do
		targets[#targets + 1] =
			resolveObject(object)
	end

	if #targets == 0 then
		return
	end

	local remote = getPropertyRemote()

	local success, result = pcall(function()
		return remote:InvokeServer(
			Config.GateTypes[gateType],
			targets
		)
	end)

	if not success then
		error(
			"Gate 종류 변경 실패: "
				.. tostring(gateType)
				.. "\n"
				.. tostring(result)
		)
	end

	Context.Statistics.PropertiesChanged += #targets

	task.wait(Config.PropertyDelay)

	return result
end

function Property.SetOne(gateType, object)
	return Property.Set(
		gateType,
		{object}
	)
end

function Property.ProcessQueue()
	local grouped = {
		And = {},
		Or = {},
		Xor = {},
		Not = {}
	}

	for _, data in ipairs(
		Context.PropertyQueue
	) do
		local gateType = data.Type
		local object =
			data.Gate or data.Object

		if grouped[gateType] and object then
			grouped[gateType][
				#grouped[gateType] + 1
			] = object
		end
	end

	local order = {
		"And",
		"Or",
		"Xor",
		"Not"
	}

	for _, gateType in ipairs(order) do
		if Utils.IsCancelled() then
			break
		end

		if #grouped[gateType] > 0 then
			Property.Set(
				gateType,
				grouped[gateType]
			)
		end
	end

	table.clear(Context.PropertyQueue)
end

Context.Modules.Property = Property

return Property
