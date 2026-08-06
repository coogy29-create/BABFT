local Context=getgenv().BABFT_CALCULATOR

local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring

local HalfAdder={}

local function P(origin,x,y,z)
	return origin*CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function HalfAdder.Build(name,origin)

	local xorGate=Gates.Xor(
		name.."_XOR",
		P(origin,0,0,0)
	)

	local andGate=Gates.And(
		name.."_AND",
		P(origin,0,0,8)
	)

	local inputA={}
	local inputB={}

	function HalfAdder.ConnectA(source)

		inputA[1]=source

		Wiring.Connect(
			source,
			xorGate
		)

		Wiring.Connect(
			source,
			andGate
		)

	end

	function HalfAdder.ConnectB(source)

		inputB[1]=source

		Wiring.Connect(
			source,
			xorGate
		)

		Wiring.Connect(
			source,
			andGate
		)

	end

	return{

		Sum=xorGate,

		Carry=andGate,

		ConnectA=HalfAdder.ConnectA,

		ConnectB=HalfAdder.ConnectB

	}

end

Context.Modules.HalfAdder=HalfAdder

return HalfAdder
