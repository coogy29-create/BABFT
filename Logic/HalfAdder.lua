local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates

local HalfAdder = {}

function HalfAdder.Build(prefix, origin)

	local xorPos = origin

	local andPos = origin + Vector3.new(0,0,4)

	local xorGate = Gates.Xor(
		prefix.."_SUM",
		CFrame.new(xorPos)
	)

	local andGate = Gates.And(
		prefix.."_CARRY",
		CFrame.new(andPos)
	)

	return {

		Sum = xorGate,

		Carry = andGate,

		InputA = xorGate,

		InputB = xorGate,

		CarryInputA = andGate,

		CarryInputB = andGate

	}

end

Context.Modules.HalfAdder = HalfAdder

return HalfAdder
