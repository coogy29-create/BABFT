local Context = getgenv().BABFT_CALCULATOR

local HalfAdder = Context.Modules.HalfAdder
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local FullAdder = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function FullAdder.Build(name, origin)
	local halfAdder1 = HalfAdder.Build(
		name .. "_HA1",
		P(origin, 0, 0, 0)
	)

	local halfAdder2 = HalfAdder.Build(
		name .. "_HA2",
		P(origin, 24, 0, 0)
	)

	local carryOr = Gates.Or(
		name .. "_CARRY_OR",
		P(origin, 48, 0, 4)
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

	local function connectA(source)
		halfAdder1.ConnectA(source)
	end

	local function connectB(source)
		halfAdder1.ConnectB(source)
	end

	local function connectCarryIn(source)
		halfAdder2.ConnectB(source)
	end

	return {
		Sum = halfAdder2.Sum,
		Carry = carryOr,
		ConnectA = connectA,
		ConnectB = connectB,
		ConnectCarryIn = connectCarryIn
	}
end

Context.Modules.FullAdder = FullAdder

return FullAdder
