local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config

local Utils = {}

local LocalPlayer = Players.LocalPlayer

function Utils.GetCharacter()
	return LocalPlayer.Character
		or LocalPlayer.CharacterAdded:Wait()
end

function Utils.GetBackpack()
	return LocalPlayer:WaitForChild("Backpack")
end

function Utils.GetBlocksFolder()
	local blocks = Workspace:WaitForChild("Blocks")

	return blocks:WaitForChild(LocalPlayer.Name)
end

function Utils.FindTool(toolName, equipToCharacter)
	local character = Utils.GetCharacter()
	local backpack = Utils.GetBackpack()

	local tool = character:FindFirstChild(toolName)
		or backpack:FindFirstChild(toolName)

	if not tool then
		return nil
	end

	if equipToCharacter and tool.Parent ~= character then
		tool.Parent = character
		task.wait(0.15)
	end

	return tool
end

function Utils.WaitForTool(toolName, equipToCharacter, timeout)
	local deadline = os.clock() + (timeout or 10)

	repeat
		local tool = Utils.FindTool(
			toolName,
			equipToCharacter
		)

		if tool then
			return tool
		end

		task.wait(0.1)
	until os.clock() >= deadline

	return nil
end

function Utils.GetWhiteZone()
	return Workspace:FindFirstChild("WhiteZone")
end

function Utils.WorldToZoneCFrame(worldCFrame)
	return CFrame.new(
		worldCFrame.Position + Config.ZoneOffset
	) * worldCFrame.Rotation
end

function Utils.SnapshotChildren(folder)
	local snapshot = {}

	for _, object in ipairs(folder:GetChildren()) do
		snapshot[object] = true
	end

	return snapshot
end

function Utils.FindNewObject(
	folder,
	beforeSnapshot,
	expectedName
)
	local fallback = nil

	for _, object in ipairs(folder:GetChildren()) do
		if not beforeSnapshot[object] then
			fallback = fallback or object

			if not expectedName
				or object.Name == expectedName then
				return object
			end
		end
	end

	return fallback
end

function Utils.WaitForNewObject(
	folder,
	beforeSnapshot,
	expectedName,
	timeout
)
	local deadline =
		os.clock()
		+ (timeout or Config.InstallTimeout)

	repeat
		if Context.State.CancelRequested then
			return nil, "사용자가 중단했습니다."
		end

		local object = Utils.FindNewObject(
			folder,
			beforeSnapshot,
			expectedName
		)

		if object then
			return object
		end

		task.wait(0.02)
	until os.clock() >= deadline

	return nil,
		(expectedName or "블록")
		.. " 생성 확인 시간 초과"
end

function Utils.WaitForChild(
	parent,
	childName,
	timeout
)
	if not parent then
		return nil
	end

	local existing = parent:FindFirstChild(childName)

	if existing then
		return existing
	end

	local deadline = os.clock() + (timeout or 5)

	repeat
		if Context.State.CancelRequested then
			return nil
		end

		if not parent.Parent then
			return nil
		end

		local child = parent:FindFirstChild(childName)

		if child then
			return child
		end

		task.wait(0.02)
	until os.clock() >= deadline

	return nil
end

function Utils.GetObjectPosition(object)
	if not object then
		return nil
	end

	if object:IsA("Model") then
		return object:GetPivot().Position
	end

	if object:IsA("BasePart") then
		return object.Position
	end

	local part = object:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

	if part then
		return part.Position
	end

	return nil
end

function Utils.DistanceBetween(objectA, objectB)
	local positionA = Utils.GetObjectPosition(objectA)
	local positionB = Utils.GetObjectPosition(objectB)

	if not positionA or not positionB then
		return math.huge
	end

	return (positionA - positionB).Magnitude
end

function Utils.FindNearestBindableTarget(
	source,
	objects
)
	local sourcePosition =
		Utils.GetObjectPosition(source)

	if not sourcePosition then
		return nil, nil, math.huge
	end

	local nearestObject = nil
	local nearestBind = nil
	local nearestDistance = math.huge

	for _, target in ipairs(objects) do
		if target
			and target ~= source
			and target.Parent then

			local bind =
				target:FindFirstChild("BindActivate")
				or target:FindFirstChild("BindFire")

			if bind then
				local targetPosition =
					Utils.GetObjectPosition(target)

				if targetPosition then
					local distance =
						(
							sourcePosition
							- targetPosition
						).Magnitude

					if distance < nearestDistance then
						nearestDistance = distance
						nearestObject = target
						nearestBind = bind
					end
				end
			end
		end
	end

	return nearestObject,
		nearestBind,
		nearestDistance
end

function Utils.GetInventoryValue(blockType)
	local value = Config.Inventory[blockType]

	if type(value) ~= "number" then
		return nil,
			"보유량 값이 없습니다: "
			.. tostring(blockType)
	end

	if value <= 0 then
		return nil,
			"보유량 값이 0 이하입니다: "
			.. tostring(blockType)
	end

	return value
end

function Utils.ResolveBlockName(blockType)
	return Config.BlockNames[blockType]
		or blockType
end

function Utils.IsCancelled()
	return Context.State.CancelRequested == true
end

function Utils.RequestCancel()
	Context.State.CancelRequested = true
end

function Utils.ClearCancel()
	Context.State.CancelRequested = false
end

function Utils.SetTask(taskName, progress)
	Context.State.CurrentTask =
		taskName or "Idle"

	if progress ~= nil then
		Context.State.Progress =
			math.clamp(progress, 0, 1)
	end

	if Config.Debug then
		print(
			"[BABFT]",
			Context.State.CurrentTask,
			math.floor(
				Context.State.Progress * 100
			) .. "%"
		)
	end
end

function Utils.SafeCall(label, callback)
	local success, result =
		xpcall(callback, debug.traceback)

	if not success then
		warn(
			"[BABFT] "
			.. tostring(label)
			.. " 실패\n"
			.. tostring(result)
		)

		return false, result
	end

	return true, result
end

function Utils.CopyArray(array)
	local copy = {}

	for index, value in ipairs(array) do
		copy[index] = value
	end

	return copy
end

function Utils.TableCount(dictionary)
	local count = 0

	for _ in pairs(dictionary) do
		count += 1
	end

	return count
end

function Utils.ClearTable(target)
	for key in pairs(target) do
		target[key] = nil
	end
end

function Utils.RoundVector3(vector, precision)
	local multiplier = 10 ^ (precision or 0)

	return Vector3.new(
		math.round(vector.X * multiplier)
			/ multiplier,
		math.round(vector.Y * multiplier)
			/ multiplier,
		math.round(vector.Z * multiplier)
			/ multiplier
	)
end

Context.Modules.Utils = Utils

return Utils
