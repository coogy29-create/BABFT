local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils

local Paint = {}

local function getPaintRemote()

	local tool = Utils.WaitForTool(
		Config.Tools.PaintTool,
		true,
		10
	)

	assert(tool,"PaintTool을 찾을 수 없습니다.")

	local remote =
		tool:FindFirstChild("RF")
		or tool:FindFirstChild("PaintRF")

	assert(remote,"Paint Remote를 찾을 수 없습니다.")

	return remote

end

local function resolve(object)

	if typeof(object)=="Instance" then
		return object
	end

	local result=Context:GetObject(object)

	assert(result,"등록되지 않은 객체 : "..tostring(object))

	return result

end

function Paint.Paint(object,color)

	object=resolve(object)

	local remote=getPaintRemote()

	local success,result=pcall(function()

		return remote:InvokeServer(
			color,
			{
				object
			}
		)

	end)

	if not success then
		error(result)
	end

	Context.Statistics.PaintOperations+=1

	task.wait(Config.PaintDelay)

end

function Paint.PaintMany(objects,color)

	for _,object in ipairs(objects) do

		Paint.Paint(
			object,
			color
		)

	end

end

function Paint.PaintWhite(object)

	Paint.Paint(
		object,
		Color3.new(1,1,1)
	)

end

function Paint.PaintBlack(object)

	Paint.Paint(
		object,
		Color3.new(0,0,0)
	)

end

function Paint.ProcessQueue()

	for _,data in ipairs(Context.PaintQueue) do

		Paint.Paint(
			data.Object,
			data.Color
		)

	end

	table.clear(Context.PaintQueue)

end

Context.Modules.Paint=Paint

return Paint
