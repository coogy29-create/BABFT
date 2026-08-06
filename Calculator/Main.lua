local Context = getgenv().BABFT_CALCULATOR

local Project = Context.Modules.Project
local CalculatorSystem = Context.Modules.CalculatorSystem

local Main = {}

function Main.Build(origin)

	origin = origin or CFrame.new(0,5,0)

	Project.Name = "16Bit Calculator"

	Project.Version = "1.0.0"

	Project.Author = "coogy29"

	Project.SetRoot(origin)

	local calculator

	Project.Build(function()

		calculator = CalculatorSystem.Build(

			"CALCULATOR",

			origin

		)

	end)

	Context.Calculator = calculator

	return calculator

end

function Main.BuildAt(position)

	if typeof(position) == "Vector3" then

		position = CFrame.new(position)

	end

	return Main.Build(position)

end

function Main.Rebuild()

	Context:ClearObjects()

	Context:ResetQueues()

	Context:ResetStatistics()

	return Main.Build()

end

Context.Modules.Calculator = Main

return Main
