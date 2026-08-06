local Context=getgenv().BABFT_CALCULATOR

local Components=Context.Modules.Components
local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring

local FullAdder={}

local function P(origin,x,z)

	return CFrame.new(
		origin.Position+
		Vector3.new(x,0,z)
	)

end

function FullAdder.Build(name,origin)

	local HA1=Components.HalfAdder(
		name.."_HA1",
		P(origin,0,0)
	)

	local HA2=Components.HalfAdder(
		name.."_HA2",
		P(origin,8,0)
	)

	local OR=Gates.Or(
		name.."_OR",
		P(origin,16,2)
	)

	Wiring.Connect(
		HA1.Sum,
		name.."_HA2_A"
	)

	Wiring.Connect(
		name.."_Cin",
		name.."_HA2_B"
	)

	Wiring.Connect(
		HA1.Carry,
		name.."_OR"
	)

	Wiring.Connect(
		HA2.Carry,
		name.."_OR"
	)

	return{

		Sum=HA2.Sum,

		Carry=OR

	}

end

Context.Modules.FullAdder=FullAdder

return FullAdder
