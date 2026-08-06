local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local HalfAdder = {}

local function L(origin, index)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		0
	)
end

function HalfAdder.Build(name, origin)
	local xorGate = Gates.Xor(
		name .. "_XOR",
		L(origin, 0)
	)

	local andGate = Gates.And(
		name .. "_AND",
		L(origin, 1)
	)

	local self = {}

	function self.ConnectA(source)
		Wiring.Connect(
			source,
			xorGate
		)

		Wiring.Connect(
			source,
			andGate
		)
	end

	function self.ConnectB(source)
		Wiring.Connect(
			source,
			xorGate
		)

		Wiring.Connect(
			source,
			andGate
		)
	end

	self.Sum = xorGate
	self.Carry = andGate

	return self
end

Context.Modules.HalfAdder = HalfAdder

return HalfAdder
