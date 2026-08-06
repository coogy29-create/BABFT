local Context=getgenv().BABFT_CALCULATOR

local System=Context.Modules.CalculatorSystem
local Project=Context.Modules.Project

local Main={}

function Main.Build(origin)

	origin=origin or CFrame.new(0,5,0)

	Project.Name="BABFT 16Bit Decimal Calculator"

	Project.Version="1.0.0"

	Project.Author="coogy29"

	Project.SetRoot(origin)

	local calculator=System.Build(
		"CALCULATOR",
		origin
	)

	Context.Calculator=calculator

	return calculator

end

Context.Modules.Calculator=Main

return Main
