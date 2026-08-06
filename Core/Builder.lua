local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config
local Utils = Context.Modules.Utils
local Inventory = Context.Modules.Inventory
local WhiteZone = Context.Modules.WhiteZone

local Builder = {}

local LocalPlayer = Players.LocalPlayer


local ToolHoldRunning = false

local function equipAllTools()
	local character =
		LocalPlayer.Character
		or LocalPlayer.CharacterAdded:Wait()

	local backpack =
		LocalPlayer:WaitForChild("Backpack")

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			pcall(function()
				tool.Parent = character
			end)
		end
	end
end

local function startToolHold()
	if ToolHoldRunning then
		return
	end

	ToolHoldRunning = true

	task.spawn(function()
		while ToolHoldRunning do
			if Utils.IsCancelled() then
				break
			end

			if Context.Ready then
				break
			end

			equipAllTools()
			task.wait(0.1)
		end

		ToolHoldRunning = false
	end)
end

function Builder.StopToolHold()
	ToolHoldRunning = false
end

local function getBuildingRemote()
	local tool = Utils.WaitForTool(
		Config.Tools.BuildingTool,
		true,
		10
	)

	if not tool then
		local backpack = LocalPlayer:FindFirstChild("Backpack")

		tool = backpack
			and backpack:FindFirstChild(
				Config.Tools.BuildingTool
			)
	end

	assert(tool, "BuildingTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BuildingTool.RF를 찾을 수 없습니다.")

	return remote
end

local function getObjectPosition(object)
	if not object then
		return nil
	end

	if object:IsA("BasePart") then
		return object.Position
	end

	if object:IsA("Model") then
		return object:GetPivot().Position
	end

	local part = object:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

	return part and part.Position or nil
end

local function isExpectedObject(object, blockName)
	return object
		and object.Parent
		and object.Name == blockName
end

local function findNearestNewObject(
	folder,
	snapshot,
	blockName,
	targetPosition
)
	local nearest = nil
	local nearestDistance = math.huge

	for _, object in ipairs(folder:GetChildren()) do
		if not snapshot[object]
			and object.Name == blockName then

			local position = getObjectPosition(object)

			if position then
				local distance =
					(position - targetPosition).Magnitude

				if distance < nearestDistance then
					nearest = object
					nearestDistance = distance
				end
			elseif not nearest then
				nearest = object
			end
		end
	end

	return nearest
end

local function findNearestExistingObject(
	folder,
	blockName,
	targetPosition,
	maxDistance
)
	local nearest = nil
	local nearestDistance = maxDistance or 8

	for _, object in ipairs(folder:GetChildren()) do
		if object.Name == blockName then
			local position = getObjectPosition(object)

			if position then
				local distance =
					(position - targetPosition).Magnitude

				if distance < nearestDistance then
					nearest = object
					nearestDistance = distance
				end
			end
		end
	end

	return nearest
end

local function resolveInventoryValue(blockType)
	if Inventory then
		return Inventory.Get(blockType)
	end

	local value = Config.Inventory[blockType]

	assert(
		type(value) == "number" and value > 0,
		"보유량 값 오류: " .. tostring(blockType)
	)

	return value
end

function Builder.PlaceBlock(blockType, worldCFrame)
	startToolHold()
	equipAllTools()

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

	local snapshot = {}

	for _, object in ipairs(folder:GetChildren()) do
		snapshot[object] = true
	end

	local detectedObject = nil

	local childConnection =
		folder.ChildAdded:Connect(function(object)
			if object.Name == blockName then
				detectedObject = object
			end
		end)

	local remote = getBuildingRemote()
	local inventoryValue =
		resolveInventoryValue(blockType)

	local zone = WhiteZone
		and WhiteZone.Get()
		or Utils.GetWhiteZone()

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
		childConnection:Disconnect()

		return nil,
			"블록 설치 리모트 실패: "
			.. blockName
			.. "\n"
			.. tostring(result)
	end

	local created = nil

	if typeof(result) == "Instance"
		and isExpectedObject(result, blockName) then

		created = result
	end

	local deadline =
		os.clock()
		+ (Config.InstallTimeout or 7)

	repeat
		if detectedObject
			and isExpectedObject(
				detectedObject,
				blockName
			) then

			created = detectedObject
			break
		end

		created = findNearestNewObject(
			folder,
			snapshot,
			blockName,
			worldCFrame.Position
		)

		if created then
			break
		end

		task.wait(0.03)
	until os.clock() >= deadline

	childConnection:Disconnect()

	if not created then
		created = findNearestExistingObject(
			folder,
			blockName,
			worldCFrame.Position,
			12
		)
	end

	if not created then
		return nil,
			"생성된 블록을 찾지 못했습니다: "
			.. blockName
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
	local created = {}

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
			"CFrame 누락: " .. tostring(data.Name)
		)

		Utils.SetTask(
			"블록 설치: " .. tostring(data.Name),
			index / #list
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

		task.wait(Config.PlaceDelay)
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
		"등록된 블록 없음: " .. tostring(name)
	)

	return object
end

function Builder.ClearRegistry()
	Builder.StopToolHold()
	table.clear(Context.NamedObjects)
end

Context.Modules.Builder = Builder

return Builder
