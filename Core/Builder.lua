local Players = game:GetService("Players")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config
local Utils = Context.Modules.Utils

local Builder = {}

local LocalPlayer = Players.LocalPlayer

local function getBuildingTool()
	local tool = Utils.WaitForTool(
		Config.Tools.BuildingTool,
		true
	)

	assert(tool, "BuildingTool을 찾을 수 없습니다.")

	local remote = tool:FindFirstChild("RF")

	assert(remote, "BuildingTool.RF를 찾을 수 없습니다.")

	return tool, remote
end

function Builder.PlaceBlock(
	blockType,
	worldCFrame
)

	local folder = Utils.GetBlocksFolder()

	local before =
		Utils.SnapshotChildren(folder)

	local _, remote =
		getBuildingTool()

	local inventoryValue =
		assert(
			Utils.GetInventoryValue(blockType)
		)

	local success, result =
		pcall(function()

			return remote:InvokeServer(
				Utils.ResolveBlockName(blockType),
				inventoryValue,
				Utils.GetWhiteZone(),
				Utils.WorldToZoneCFrame(worldCFrame),
				true,
				worldCFrame,
				false
			)

		end)

	if not success then
		error(
			"블록 설치 실패 : "
			.. tostring(result)
		)
	end

	local created, reason =
		Utils.WaitForNewObject(
			folder,
			before,
			Utils.ResolveBlockName(blockType)
		)

	if not created then
		error(reason)
	end

	Context.Statistics.BlocksPlaced += 1

	return created
end

function Builder.PlaceNamedBlock(
	name,
	blockType,
	worldCFrame
)

	local object =
		Builder.PlaceBlock(
			blockType,
			worldCFrame
		)

	Context:RegisterObject(
		name,
		object
	)

	return object
end

function Builder.PlaceMany(list)

	local created = {}

	for index,data in ipairs(list) do

		if Utils.IsCancelled() then
			break
		end

		Utils.SetTask(
			"블록 설치",
			index/#list
		)

		local object =
			Builder.PlaceNamedBlock(
				data.Name,
				data.Type,
				data.CFrame
			)

		table.insert(
			created,
			object
		)

		task.wait(
			Config.PlaceDelay
		)

	end

	return created

end

function Builder.Find(name)

	return Context:GetObject(name)

end

function Builder.Exists(name)

	return Builder.Find(name) ~= nil

end

function Builder.Clear()

	Context.NamedObjects = {}

end

Context.Modules.Builder = Builder

return Builder
