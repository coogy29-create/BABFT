local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local HalfAdder = Context.Modules.HalfAdder
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local FullAdder = {}

local function L(origin, index)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		0
	)
end

function FullAdder.Build(name, origin)
	local halfAdder1 = HalfAdder.Build(
		name .. "_HA1",
		L(origin, 0)
	)

	local halfAdder2 = HalfAdder.Build(
		name .. "_HA2",
		L(origin, 2)
	)

	local carryOr = Gates.Or(
		name .. "_CARRY_OR",
		L(origin, 4)
	)

	halfAdder2.ConnectA(
		halfAdder1.Sum
	)

	Wiring.Connect(
		halfAdder1.Carry,
		carryOr
	)

	Wiring.Connect(
		halfAdder2.Carry,
		carryOr
	)

	local self = {}

	function self.ConnectA(source)
		halfAdder1.ConnectA(source)
	end

	function self.ConnectB(source)
		halfAdder1.ConnectB(source)
	end

	function self.ConnectCarryIn(source)
		halfAdder2.ConnectB(source)
	end

	self.Sum = halfAdder2.Sum
	self.Carry = carryOr
	self.HalfAdder1 = halfAdder1
	self.HalfAdder2 = halfAdder2

	return self
end

Context.Modules.FullAdder = FullAdder

return FullAdder
