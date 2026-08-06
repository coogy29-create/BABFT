local Players = game:GetService("Players")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config
local Utils = Context.Modules.Utils

local Binder = {}

local function getBindTool()

	local tool = Utils.WaitForTool(
		Config.Tools.BindTool,
		true
	)

	assert(tool, "BindTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BindTool.RF를 찾을 수 없습니다.")

	return remote

end

local function resolveTarget(target)

	if typeof(target) == "Instance" then

		local bind =
			target:FindFirstChild("BindActivate")
			or target:FindFirstChild("BindFire")

		assert(bind, "대상 Bind를 찾을 수 없습니다.")

		return bind

	end

	local object = Context:GetObject(target)

	assert(object, "등록되지 않은 객체 : "..tostring(target))

	local bind =
		object:FindFirstChild("BindActivate")
		or object:FindFirstChild("BindFire")

	assert(bind, "Bind를 찾을 수 없습니다.")

	return bind

end

local function resolveSource(source)

	if typeof(source) == "Instance" then
		return source
	end

	local object = Context:GetObject(source)

	assert(object, "등록되지 않은 객체 : "..tostring(source))

	return object

end

function Binder.Bind(source, targets)

	local remote = getBindTool()

	local sourceObject = resolveSource(source)

	local activate = {}

	for _,target in ipairs(targets) do
		table.insert(
			activate,
			resolveTarget(target)
		)
	end

	local success,result =
		pcall(function()

			return remote:InvokeServer(

				{
					Activate = activate
				},

				sourceObject,

				{},

				false,

				true

			)

		end)

	if not success then

		error(
			"Bind 실패\n"
			..tostring(result)
		)

	end

	Context.Statistics.ConnectionsMade += 1

	task.wait(Config.BindDelay)

end

function Binder.Unbind(source, targets)

	local remote = getBindTool()

	local sourceObject = resolveSource(source)

	local activate = {}

	for _,target in ipairs(targets) do

		table.insert(
			activate,
			resolveTarget(target)
		)

	end

	local success,result =
		pcall(function()

			return remote:InvokeServer(

				{
					Activate = activate
				},

				sourceObject,

				{},

				true,

				true

			)

		end)

	if not success then

		error(
			"Unbind 실패\n"
			..tostring(result)
		)

	end

	task.wait(Config.BindDelay)

end

function Binder.AutoUnbindNearest(switchObject)

	local folder = Utils.GetBlocksFolder()

	local objects = {}

	for _,object in ipairs(folder:GetChildren()) do

		if object ~= switchObject then

			if object.Name == "Gate"
			or object.Name == "DisplayBlock" then

				table.insert(
					objects,
					object
				)

			end

		end

	end

	local nearestObject,
	nearestBind =
	Utils.FindNearestBindableTarget(
		switchObject,
		objects
	)

	if nearestBind then

		Binder.Unbind(
			switchObject,
			{
				nearestObject
			}
		)

	end

	return nearestObject

end

function Binder.BatchBind(list)

	for index,data in ipairs(list) do

		if Utils.IsCancelled() then
			break
		end

		Utils.SetTask(
			"배선",
			index/#list
		)

		Binder.Bind(
			data.Source,
			data.Targets
		)

	end

end

Context.Modules.Bind = Binder

return Binder
