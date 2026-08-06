local Context=getgenv().BABFT_CALCULATOR

local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring

local Components={}

local function P(origin,x,z)

	return CFrame.new(
		origin.Position+
		Vector3.new(x,0,z)
	)

end

function Components.HalfAdder(name,origin)

	local xor=Gates.Xor(
		name.."_XOR",
		P(origin,0,0)
	)

	local andGate=Gates.And(
		name.."_AND",
		P(origin,0,4)
	)

	Wiring.Connect(
		name.."_A",
		name.."_XOR"
	)

	Wiring.Connect(
		name.."_B",
		name.."_XOR"
	)

	Wiring.Connect(
		name.."_A",
		name.."_AND"
	)

	Wiring.Connect(
		name.."_B",
		name.."_AND"
	)

	return{

		Sum=xor,

		Carry=andGate

	}

end

Context.Modules.Components=Components

return Components
