local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Utils = Context.Modules.Utils
local Builder = Context.Modules.Builder
local Binder = Context.Modules.Bind
local Property = Context.Modules.Property
local Paint = Context.Modules.Paint

local Executor = {}

local function resolveCFrame(data)
	if typeof(data.CFrame) == "CFrame" then
		return data.CFrame
	end

	if typeof(data.Position) == "Vector3" then
		return CFrame.new(data.Position)
	end

	error(
		"설치 좌표가 없습니다: "
			.. tostring(data.Name)
	)
end

function Executor.ProcessBuildQueue()
	local queue = Context.BuildQueue
	local total = #queue

	for index, data in ipairs(queue) do
		if Utils.IsCancelled() then
			return false, "사용자가 중단했습니다."
		end

		assert(data.Name, "설치 항목 Name 누락")
		assert(data.Type, "설치 항목 Type 누락")

		Utils.SetTask(
			"블록 설치: " .. tostring(data.Name),
			total > 0 and index / total or 1
		)

		local object = Builder.PlaceNamedBlock(
			data.Name,
			data.Type,
			resolveCFrame(data)
		)

		if (
			data.Type == "Switch"
			or data.Type == "Button"
		) and data.AutoUnbind ~= false then
			Binder.AutoUnbindNearest(object)
		end

		if data.GateType then
			Context:QueueProperty({
				Type = data.GateType,
				Gate = object
			})
		end

		if data.Color then
			Context:QueuePaint({
				Object = object,
				Color = data.Color
			})
		end

		task.wait(Config.PlaceDelay)
	end

	table.clear(queue)

	return true
end

function Executor.ProcessPropertyQueue()
	if Utils.IsCancelled() then
		return false, "사용자가 중단했습니다."
	end

	Property.ProcessQueue()

	return true
end

function Executor.ProcessPaintQueue()
	local queue = Context.PaintQueue
	local total = #queue

	for index, data in ipairs(queue) do
		if Utils.IsCancelled() then
			return false, "사용자가 중단했습니다."
		end

		assert(data.Object, "도색 대상 누락")
		assert(data.Color, "도색 색상 누락")

		Utils.SetTask(
			"블록 도색",
			total > 0 and index / total or 1
		)

		Paint.Paint(
			data.Object,
			data.Color
		)
	end

	table.clear(queue)

	return true
end

function Executor.ProcessConnectionQueue()
	local queue = Context.ConnectionQueue
	local total = #queue

	for index, data in ipairs(queue) do
		if Utils.IsCancelled() then
			return false, "사용자가 중단했습니다."
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

	table.clear(queue)

	return true
end

function Executor.Run()
	if Context.State.Running then
		return false, "이미 자동건설이 실행 중입니다."
	end

	Context.State.Running = true
	Context.State.CancelRequested = false
	Context.State.Progress = 0
	Context.State.CurrentTask = "자동건설 준비"
	Context.State.LastError = nil

	Context:ResetStatistics()

	local success, result = xpcall(function()
		local ok, reason

		ok, reason = Executor.ProcessBuildQueue()

		if not ok then
			error(reason)
		end

		ok, reason = Executor.ProcessPropertyQueue()

		if not ok then
			error(reason)
		end

		ok, reason = Executor.ProcessPaintQueue()

		if not ok then
			error(reason)
		end

		ok, reason = Executor.ProcessConnectionQueue()

		if not ok then
			error(reason)
		end

		Utils.SetTask("자동건설 완료", 1)

		return true
	end, debug.traceback)

	Context.State.Running = false

	if not success then
		Context.State.CurrentTask = "자동건설 실패"
		Context.State.LastError = result

		warn(
			"[BABFT] 자동건설 실패\n"
				.. tostring(result)
		)

		return false, result
	end

	Context.State.CurrentTask = "완료"
	Context.State.Progress = 1

	print(
		string.format(
			"[BABFT] 완료 | 설치 %d | 연결 %d | 속성 %d | 도색 %d",
			Context.Statistics.BlocksPlaced,
			Context.Statistics.ConnectionsMade,
			Context.Statistics.PropertiesChanged,
			Context.Statistics.PaintOperations
		)
	)

	return true
end

function Executor.Cancel()
	Context.State.CancelRequested = true
	Context.State.CurrentTask = "중단 요청"
end

Context.Modules.Executor = Executor

return Executor
