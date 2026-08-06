local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")

local Context=getgenv().BABFT_CALCULATOR

local Utils={}

local LocalPlayer=Players.LocalPlayer

function Utils.WaitForTool(name,searchCharacter,timeout)

	timeout=timeout or 10

	local finish=os.clock()+timeout

	repeat

		local container

		if searchCharacter then
			container=LocalPlayer.Character
		else
			container=LocalPlayer.Backpack
		end

		if container then

			local tool=container:FindFirstChild(name)

			if tool then
				return tool
			end

		end

		task.wait()

	until os.clock()>finish

	return nil

end

function Utils.WaitForChild(parent,name,timeout)

	timeout=timeout or 5

	local finish=os.clock()+timeout

	repeat

		local child=parent:FindFirstChild(name)

		if child then
			return child
		end

		task.wait()

	until os.clock()>finish

	return nil

end

function Utils.GetBlocksFolder()

	local blocks=Workspace:WaitForChild("Blocks")

	return blocks:WaitForChild(LocalPlayer.Name)

end

function Utils.GetWhiteZone()

	return Workspace:WaitForChild("WhiteZone")

end

function Utils.WorldToZoneCFrame(cf)

	return cf

end

function Utils.SnapshotChildren(folder)

	local snapshot={}

	for _,v in ipairs(folder:GetChildren()) do
		snapshot[v]=true
	end

	return snapshot

end

function Utils.WaitForNewObject(folder,before,name,timeout)

	timeout=timeout or 5

	local finish=os.clock()+timeout

	repeat

		for _,v in ipairs(folder:GetChildren()) do

			if not before[v] then

				if not name or v.Name==name then
					return v
				end

			end

		end

		task.wait()

	until os.clock()>finish

	return nil,"Timeout"

end

function Utils.FindNearestBindableTarget(source,list)

	local sourcePart=source:IsA("BasePart") and source or source:FindFirstChildWhichIsA("BasePart",true)

	if not sourcePart then
		return nil
	end

	local nearest
	local nearestBind
	local distance=math.huge

	for _,object in ipairs(list) do

		local bind=object:FindFirstChild("BindActivate") or object:FindFirstChild("BindFire")

		local part=object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart",true)

		if bind and part then

			local d=(part.Position-sourcePart.Position).Magnitude

			if d<distance then
				distance=d
				nearest=object
				nearestBind=bind
			end

		end

	end

	return nearest,nearestBind

end

function Utils.SetTask(taskName,progress)

	Context.State.CurrentTask=taskName
	Context.State.Progress=progress

end

function Utils.IsCancelled()

	return Context.State.CancelRequested==true

end

Context.Modules.Utils=Utils

return Utils
