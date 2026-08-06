local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils

local Paint = {}

local function getPaintTool()

	local tool = Utils.WaitForTool(
		Config.Tools.PaintingTool,
		true
	)

	assert(tool, "PaintingTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "PaintingTool.RF를 찾을 수 없습니다.")

	return remote

end

local function resolveObject(object)

	if typeof(object) == "Instance" then
		return object
	end

	local found = Context:GetObject(object)

	assert(found, "등록되지 않은 객체 : "..tostring(object))

	return found

end

function Paint.Paint(object, color)

	local remote = getPaintTool()

	local target = resolveObject(object)

	local success, result = pcall(function()

		return remote:InvokeServer({
			{
				target,
				color
			}
		})

	end)

	if not success then
		error(
			"Paint 실패\n"
			..tostring(result)
		)
	end

	Context.Statistics.PaintOperations += 1

	task.wait(Config.PaintDelay)

end

function Paint.PaintWhite(object)

	Paint.Paint(
		object,
		Config.Colors.White
	)

end

function Paint.PaintBlack(object)

	Paint.Paint(
		object,
		Config.Colors.Black
	)

end

function Paint.BatchPaint(list)

	for index,data in ipairs(list) do

		if Utils.IsCancelled() then
			break
		end

		Utils.SetTask(
			"도색",
			index/#list
		)

		Paint.Paint(
			data.Object,
			data.Color
		)

	end

end

Context.Modules.Paint = Paint

return Paint
