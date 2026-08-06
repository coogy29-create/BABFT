local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local HalfAdder = {}

local function P(origin,x,y,z)
	return origin * CFrame.new(x or 0,y or 0,z or 0)
end

function HalfAdder.Build(name,origin)

	local xor = Gates.Xor(
		name.."_XOR",
		P(origin,0,0,0)
	)

	local andGate = Gates.And(
		name.."_AND",
		P(origin,0,0,8)
	)

	local self = {}

	function self.ConnectA(source)

		Wiring.Connect(source,xor)
		Wiring.Connect(source,andGate)

	end

	function self.ConnectB(source)

		Wiring.Connect(source,xor)
		Wiring.Connect(source,andGate)

	end

	self.Sum = xor
	self.Carry = andGate

	return self

end

Context.Modules.HalfAdder = HalfAdder

return HalfAdder
