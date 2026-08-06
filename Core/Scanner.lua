local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR

local Scanner = {}

local LocalPlayer = Players.LocalPlayer

local function getFolder()

	local blocks = Workspace:WaitForChild("Blocks")

	return blocks:WaitForChild(
		LocalPlayer.Name
	)

end

function Scanner.GetAll()

	return getFolder():GetChildren()

end

function Scanner.FindByName(name)

	for _,object in ipairs(
		Scanner.GetAll()
	) do

		if object.Name==name then
			return object
		end

	end

	return nil

end

function Scanner.FindNearest(position,className)

	local nearest=nil
	local distance=math.huge

	for _,object in ipairs(
		Scanner.GetAll()
	) do

		if (not className)
		or object.Name==className then

			local part=
				object:IsA("BasePart")
				and object
				or object:FindFirstChildWhichIsA(
					"BasePart",
					true
				)

			if part then

				local d=(
					part.Position-position
				).Magnitude

				if d<distance then

					distance=d
					nearest=object

				end

			end

		end

	end

	return nearest,distance

end

function Scanner.FindCreated(snapshot)

	local folder=getFolder()

	for _,object in ipairs(
		folder:GetChildren()
	) do

		if not snapshot[object] then
			return object
		end

	end

	return nil

end

function Scanner.TakeSnapshot()

	local result={}

	for _,object in ipairs(
		getFolder():GetChildren()
	) do

		result[object]=true

	end

	return result

end

function Scanner.WaitForCreated(snapshot,timeout)

	timeout=timeout or 5

	local finish=os.clock()+timeout

	repeat

		local object=
			Scanner.FindCreated(snapshot)

		if object then
			return object
		end

		task.wait()

	until os.clock()>finish

	return nil

end

function Scanner.Register(name,object)

	Context:RegisterObject(
		name,
		object
	)

	return object

end

Context.Modules.Scanner=Scanner

return Scanner
