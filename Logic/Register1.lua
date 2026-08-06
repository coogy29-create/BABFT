local Context=getgenv().BABFT_CALCULATOR

local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring
local Components=Context.Modules.Components

local Register1={}

local function P(origin,x,z)

	return CFrame.new(
		origin.Position+
		Vector3.new(x,0,z)
	)

end

function Register1.Build(name,origin)

	local latch=Components.DLatch(
		name.."_DLATCH",
		P(origin,0,0)
	)

	Wiring.Connect(
		name.."_D",
		name.."_DLATCH_D"
	)

	Wiring.Connect(
		name.."_CLK",
		name.."_DLATCH_CLK"
	)

	return{

		Q=latch.Q,

		QB=latch.QB

	}

end

Context.Modules.Register1=Register1

return Register1
