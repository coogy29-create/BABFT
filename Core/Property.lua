local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils

local Property = {}

local function getPropertyRemote()
	local tool = Utils.WaitForTool(
		Config.Tools.PropertiesTool,
		true
	)

	assert(tool, "PropertiesTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("SetPropertieRF")

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
		found,
		"등록되지 않은 객체: " .. tostring(object)
	)

	return found
end

function Property.Set(gateType, objects)
	assert(
		Config.GateTypes[gateType],
		"지원하지 않는 Gate 종류: " .. tostring(gateType)
	)

	local targets = {}

	for _, object in ipairs(objects) do
		table.insert(
			targets,
			resolveObject(object)
		)
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
			"Gate 종류 변경 실패\n"
			.. tostring(gateType)
			.. "\n"
			.. tostring(result)
		)
	end

	Context.Statistics.PropertiesChanged += #targets

	task.wait(Config.PropertyDelay)
end

function Property.SetOne(gateType, object)
	Property.Set(
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

	for _, data in ipairs(Context.PropertyQueue) do
		local gateType = data.Type
		local object = data.Gate or data.Object

		if gateType and object then
			table.insert(
				grouped[gateType],
				object
			)
		end
	end

	local order = {
		"And",
		"Or",
		"Xor",
		"Not"
	}

	for index, gateType in ipairs(order) do
		if Utils.IsCancelled() then
			break
		end

		Utils.SetTask(
			"Gate 종류 설정: " .. gateType,
			index / #order
		)

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
