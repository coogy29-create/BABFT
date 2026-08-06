local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config
local Utils = Context.Modules.Utils
local Scanner = Context.Modules.Scanner
local Inventory = Context.Modules.Inventory
local WhiteZone = Context.Modules.WhiteZone

local Builder = {}

local LocalPlayer = Players.LocalPlayer

local function getBuildingRemote()
	local tool = Utils.WaitForTool(
		Config.Tools.BuildingTool,
		true,
		10
	)

	assert(tool, "BuildingTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BuildingTool.RF를 찾을 수 없습니다.")

	return remote
end

local function resolveBlockName(blockType)
	return Config.BlockNames[blockType] or blockType
end

local function resolveInventoryValue(blockType)
	if Inventory then
		return Inventory.Get(blockType)
	end

	local value = Config.Inventory[blockType]

	assert(
		type(value) == "number" and value > 0,
		"보유량 값이 잘못되었습니다: " .. tostring(blockType)
	)

	return value
end

local function validateCFrame(worldCFrame)
	assert(
		typeof(worldCFrame) == "CFrame",
		"worldCFrame은 CFrame이어야 합니다."
	)
end

function Builder.PlaceBlock(blockType, worldCFrame)
	validateCFrame(worldCFrame)

	if Utils.IsCancelled() then
		return nil, "사용자가 중단했습니다."
	end

	local folder = Utils.GetBlocksFolder()
	local snapshot = Scanner
		and Scanner.TakeSnapshot()
		or Utils.SnapshotChildren(folder)

	local remote = getBuildingRemote()
	local blockName = resolveBlockName(blockType)
	local inventoryValue = resolveInventoryValue(blockType)
	local zone = WhiteZone and WhiteZone.Get() or Utils.GetWhiteZone()

	assert(zone, "workspace.WhiteZone을 찾을 수 없습니다.")

	local zoneCFrame = WhiteZone
		and WhiteZone.WorldToZone(worldCFrame)
		or Utils.WorldToZoneCFrame(worldCFrame)

	local success, result = pcall(function()
		return remote:InvokeServer(
			blockName,
			inventoryValue,
			zone,
			zoneCFrame,
			true,
			worldCFrame,
			false
		)
	end)

	if not success then
		return nil,
			"블록 설치 리모트 실패: "
			.. blockName
			.. "\n"
			.. tostring(result)
	end

	local created

	if Scanner then
		created = Scanner.WaitForCreated(
			snapshot,
			Config.InstallTimeout
		)
	else
		created = Utils.WaitForNewObject(
			folder,
			snapshot,
			blockName,
			Config.InstallTimeout
		)
	end

	if not created then
		return nil,
			"생성된 블록을 찾지 못했습니다: "
			.. blockName
	end

	if created.Name ~= blockName then
		local deadline = os.clock() + 1

		repeat
			for _, object in ipairs(folder:GetChildren()) do
				if not snapshot[object]
					and object.Name == blockName then
					created = object
					break
				end
			end

			if created.Name == blockName then
				break
			end

			task.wait(0.02)
		until os.clock() >= deadline
	end

	Context.Statistics.BlocksPlaced += 1

	return created
end

function Builder.PlaceNamedBlock(
	name,
	blockType,
	worldCFrame
)
	assert(
		type(name) == "string" and name ~= "",
		"등록 이름이 필요합니다."
	)

	local object, errorMessage = Builder.PlaceBlock(
		blockType,
		worldCFrame
	)

	if not object then
		error(errorMessage)
	end

	Context:RegisterObject(name, object)

	return object
end

function Builder.PlaceMany(list)
	assert(
		type(list) == "table",
		"설치 목록은 테이블이어야 합니다."
	)

	local created = {}
	local total = #list

	for index, data in ipairs(list) do
		if Utils.IsCancelled() then
			break
		end

		assert(data.Name, "설치 항목 Name 누락")
		assert(data.Type, "설치 항목 Type 누락")

		local worldCFrame =
			data.CFrame
			or (
				typeof(data.Position) == "Vector3"
				and CFrame.new(data.Position)
			)

		assert(
			typeof(worldCFrame) == "CFrame",
			"설치 항목 CFrame 누락: "
			.. tostring(data.Name)
		)

		Utils.SetTask(
			"블록 설치: " .. data.Name,
			total > 0 and index / total or 1
		)

		local object = Builder.PlaceNamedBlock(
			data.Name,
			data.Type,
			worldCFrame
		)

		created[#created + 1] = object

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

	return created
end

function Builder.Find(name)
	return Context:GetObject(name)
end

function Builder.Exists(name)
	local object = Builder.Find(name)

	return object ~= nil and object.Parent ~= nil
end

function Builder.Require(name)
	local object = Builder.Find(name)

	assert(
		object and object.Parent,
		"등록된 블록을 찾을 수 없습니다: "
		.. tostring(name)
	)

	return object
end

function Builder.Unregister(name)
	local object = Context.NamedObjects[name]
	Context.NamedObjects[name] = nil

	return object
end

function Builder.ClearRegistry()
	for key in pairs(Context.NamedObjects) do
		Context.NamedObjects[key] = nil
	end
end

Context.Modules.Builder = Builder

return Builder
