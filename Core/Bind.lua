local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils

local Binder = {}

local function getBindRemote()
	local tool = Utils.WaitForTool(
		Config.Tools.BindTool,
		true,
		10
	)

	assert(tool, "BindTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BindTool.RF를 찾을 수 없습니다.")

	return remote
end

local function resolveSource(source)
	if typeof(source) == "Instance" then
		return source
	end

	local object = Context:GetObject(source)

	assert(
		object and object.Parent,
		"등록되지 않은 원본 객체: "
			.. tostring(source)
	)

	return object
end

local function resolveTargetObject(target)
	if typeof(target) == "Instance" then
		return target
	end

	local object = Context:GetObject(target)

	assert(
		object and object.Parent,
		"등록되지 않은 대상 객체: "
			.. tostring(target)
	)

	return object
end

local function resolveTargetBind(target)
	local object = resolveTargetObject(target)

	local bind =
		object:FindFirstChild("BindActivate")
		or object:FindFirstChild("BindFire")

	if not bind then
		bind = Utils.WaitForChild(
			object,
			"BindActivate",
			1
		)
	end

	if not bind then
		bind = Utils.WaitForChild(
			object,
			"BindFire",
			1
		)
	end

	assert(
		bind,
		"대상 연결 단자를 찾을 수 없습니다: "
			.. tostring(target)
	)

	return bind
end

local function invoke(
	source,
	targets,
	remove
)
	local remote = getBindRemote()
	local sourceObject = resolveSource(source)
	local activate = {}

	for _, target in ipairs(targets) do
		activate[#activate + 1] =
			resolveTargetBind(target)
	end

	assert(
		#activate > 0,
		"연결 대상이 없습니다."
	)

	local success, result = pcall(function()
		return remote:InvokeServer(
			{
				Activate = activate
			},
			sourceObject,
			{},
			remove == true,
			true
		)
	end)

	if not success then
		error(
			(remove and "연결 해제 실패" or "연결 실패")
				.. "\n"
				.. tostring(result)
		)
	end

	task.wait(Config.BindDelay)

	return result
end

function Binder.Bind(source, targets)
	assert(
		type(targets) == "table",
		"targets는 테이블이어야 합니다."
	)

	local result = invoke(
		source,
		targets,
		false
	)

	Context.Statistics.ConnectionsMade += 1

	return result
end

function Binder.BindOne(source, target)
	return Binder.Bind(
		source,
		{target}
	)
end

function Binder.Unbind(source, targets)
	assert(
		type(targets) == "table",
		"targets는 테이블이어야 합니다."
	)

	return invoke(
		source,
		targets,
		true
	)
end

function Binder.UnbindOne(source, target)
	return Binder.Unbind(
		source,
		{target}
	)
end

function Binder.AutoUnbindNearest(sourceObject)
	assert(
		typeof(sourceObject) == "Instance",
		"sourceObject는 Instance여야 합니다."
	)

	local folder = Utils.GetBlocksFolder()
	local candidates = {}

	for _, object in ipairs(folder:GetChildren()) do
		if object ~= sourceObject
			and object.Parent
			and (
				object.Name == "Gate"
				or object.Name == "DisplayBlock"
			) then

			candidates[#candidates + 1] = object
		end
	end

	local nearestObject, nearestBind =
		Utils.FindNearestBindableTarget(
			sourceObject,
			candidates
		)

	if not nearestObject or not nearestBind then
		return nil
	end

	local remote = getBindRemote()

	local success, result = pcall(function()
		return remote:InvokeServer(
			{
				Activate = {
					nearestBind
				}
			},
			sourceObject,
			{},
			true,
			true
		)
	end)

	if not success then
		error(
			"자동 근접 연결 해제 실패\n"
				.. tostring(result)
		)
	end

	task.wait(Config.BindDelay)

	return nearestObject
end

function Binder.BatchBind(list)
	assert(
		type(list) == "table",
		"배선 목록은 테이블이어야 합니다."
	)

	local total = #list

	for index, data in ipairs(list) do
		if Utils.IsCancelled() then
			break
		end

		assert(data.Source, "배선 Source 누락")
		assert(data.Targets, "배선 Targets 누락")

		Utils.SetTask(
			"회로 배선: " .. tostring(data.Source),
			total > 0 and index / total or 1
		)

		if data.Remove == true then
			Binder.Unbind(
				data.Source,
				data.Targets
			)
		else
			Binder.Bind(
				data.Source,
				data.Targets
			)
		end
	end
end

Context.Modules.Bind = Binder

return Binder
