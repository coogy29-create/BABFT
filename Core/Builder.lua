local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config
local Utils = Context.Modules.Utils
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

	if not tool then
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local character = LocalPlayer.Character

		tool =
			(character and character:FindFirstChild(Config.Tools.BuildingTool))
			or (backpack and backpack:FindFirstChild(Config.Tools.BuildingTool))
	end

	assert(tool, "BuildingTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BuildingTool.RF를 찾을 수 없습니다.")

	return remote
end

local function resolveInventoryValue(blockType)
	if Inventory and Inventory.Get then
		return Inventory.Get(blockType)
	end

	local value = Config.Inventory[blockType]

	assert(
		type(value) == "number" and value > 0,
		"보유량 값 오류: " .. tostring(blockType)
	)

	return value
end

local function getObjectPosition(object)
	if not object then
		return nil
	end

	if object:IsA("BasePart") then
		return object.Position
	end

	if object:IsA("Model") then
		local ok, pivot = pcall(function()
			return object:GetPivot()
		end)

		if ok then
			return pivot.Position
		end
	end

	local part = object:FindFirstChildWhichIsA("BasePart", true)

	return part and part.Position or nil
end

local function snapshotChildren(folder)
	local snapshot = {}

	for _, object in ipairs(folder:GetChildren()) do
		snapshot[object] = true
	end

	return snapshot
end

local function scoreCandidate(
	object,
	blockName,
	targetPosition,
	snapshot
)
	if not object or not object.Parent then
		return nil
	end

	if snapshot[object] then
		return nil
	end

	local score = 0

	if object.Name == blockName then
		score += 100000
	end

	local position = getObjectPosition(object)

	if position then
		local distance = (position - targetPosition).Magnitude
		score -= distance
	else
		score -= 10000
	end

	return score
end

local function chooseBestCandidate(
	folder,
	snapshot,
	blockName,
	targetPosition,
	addedObjects
)
	local bestObject = nil
	local bestScore = -math.huge

	local function consider(object)
		local score = scoreCandidate(
			object,
			blockName,
			targetPosition,
			snapshot
		)

		if score and score > bestScore then
			bestScore = score
			bestObject = object
		end
	end

	for _, object in ipairs(addedObjects) do
		consider(object)
	end

	for _, object in ipairs(folder:GetChildren()) do
		consider(object)
	end

	return bestObject
end

local function waitForCreatedObject(
	folder,
	snapshot,
	blockName,
	targetPosition,
	addedObjects,
	timeout
)
	local deadline = os.clock() + timeout
	local stableCandidate = nil
	local stableSince = nil

	repeat
		if Utils.IsCancelled() then
			return nil, "사용자가 중단했습니다."
		end

		local candidate = chooseBestCandidate(
			folder,
			snapshot,
			blockName,
			targetPosition,
			addedObjects
		)

		if candidate then
			if candidate ~= stableCandidate then
				stableCandidate = candidate
				stableSince = os.clock()
			elseif os.clock() - stableSince >= 0.08 then
				return candidate
			end
		end

		task.wait(0.02)
	until os.clock() >= deadline

	if stableCandidate and stableCandidate.Parent then
		return stableCandidate
	end

	return nil,
		"생성된 블록을 찾지 못했습니다: "
		.. tostring(blockName)
end

function Builder.PlaceBlock(blockType, worldCFrame)
	assert(
		typeof(worldCFrame) == "CFrame",
		"worldCFrame은 CFrame이어야 합니다."
	)

	if Utils.IsCancelled() then
		return nil, "사용자가 중단했습니다."
	end

	local folder = Utils.GetBlocksFolder()
	local blockName =
		Config.BlockNames[blockType] or blockType

	local snapshot = snapshotChildren(folder)
	local addedObjects = {}

	local childConnection =
		folder.ChildAdded:Connect(function(object)
			addedObjects[#addedObjects + 1] = object
		end)

	local remote = getBuildingRemote()
	local inventoryValue =
		resolveInventoryValue(blockType)

	local zone =
		WhiteZone
		and WhiteZone.Get
		and WhiteZone.Get()
		or Utils.GetWhiteZone()

	assert(zone, "WhiteZone을 찾을 수 없습니다.")

	local zoneCFrame =
		WhiteZone
		and WhiteZone.WorldToZone
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
		childConnection:Disconnect()

		return nil,
			"블록 설치 리모트 실패: "
			.. tostring(blockName)
			.. "\n"
			.. tostring(result)
	end

	if typeof(result) == "Instance"
		and result.Parent
		and not snapshot[result] then

		childConnection:Disconnect()

		Context.Statistics.BlocksPlaced += 1

		return result
	end

	local created, reason = waitForCreatedObject(
		folder,
		snapshot,
		blockName,
		worldCFrame.Position,
		addedObjects,
		Config.InstallTimeout or 7
	)

	childConnection:Disconnect()

	if not created then
		return nil, reason
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

	local object, errorMessage =
		Builder.PlaceBlock(
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

		local cframe =
			data.CFrame
			or (
				typeof(data.Position) == "Vector3"
				and CFrame.new(data.Position)
			)

		assert(
			typeof(cframe) == "CFrame",
			"CFrame 누락: "
			.. tostring(data.Name)
		)

		Utils.SetTask(
			"블록 설치: "
			.. tostring(data.Name),
			total > 0 and index / total or 1
		)

		local object =
			Builder.PlaceNamedBlock(
				data.Name,
				data.Type,
				cframe
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

		task.wait(Config.PlaceDelay or 0)
	end

	return created
end

function Builder.Find(name)
	return Context:GetObject(name)
end

function Builder.Exists(name)
	local object = Context:GetObject(name)

	return object ~= nil
		and object.Parent ~= nil
end

function Builder.Require(name)
	local object = Context:GetObject(name)

	assert(
		object and object.Parent,
		"등록된 블록 없음: "
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
	table.clear(Context.NamedObjects)
end

Context.Modules.Builder = Builder

return Builder
