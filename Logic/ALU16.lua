local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local Subtractor16 = Context.Modules.Subtractor16

local ALU16 = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function ALU16.Build(name, origin)
	local arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		P(origin, 0, 0, 0)
	)

	local andBus = {}
	local orBus = {}
	local xorBus = {}
	local notBus = {}

	local selectedBus = {}

	for bit = 0, 15 do
		andBus[bit] = Gates.And(
			name .. "_AND_" .. bit,
			P(origin, bit * 6, 0, 40)
		)

		orBus[bit] = Gates.Or(
			name .. "_OR_" .. bit,
			P(origin, bit * 6, 0, 48)
		)

		xorBus[bit] = Gates.Xor(
			name .. "_XOR_" .. bit,
			P(origin, bit * 6, 0, 56)
		)

		notBus[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			P(origin, bit * 6, 0, 64)
		)

		local selectArithmetic = Gates.And(
			name .. "_SELECT_ARITHMETIC_" .. bit,
			P(origin, bit * 6, 0, 76)
		)

		local selectAnd = Gates.And(
			name .. "_SELECT_AND_" .. bit,
			P(origin, bit * 6, 0, 84)
		)

		local selectOr = Gates.And(
			name .. "_SELECT_OR_" .. bit,
			P(origin, bit * 6, 0, 92)
		)

		local selectXor = Gates.And(
			name .. "_SELECT_XOR_" .. bit,
			P(origin, bit * 6, 0, 100)
		)

		local selectNot = Gates.And(
			name .. "_SELECT_NOT_" .. bit,
			P(origin, bit * 6, 0, 108)
		)

		local output = Gates.Or(
			name .. "_RESULT_" .. bit,
			P(origin, bit * 6, 0, 120)
		)

		Wiring.Connect(
			arithmetic.Sum[bit],
			selectArithmetic
		)

		Wiring.Connect(
			andBus[bit],
			selectAnd
		)

		Wiring.Connect(
			orBus[bit],
			selectOr
		)

		Wiring.Connect(
			xorBus[bit],
			selectXor
		)

		Wiring.Connect(
			notBus[bit],
			selectNot
		)

		Wiring.ConnectMany(
			selectArithmetic,
			output
		)

		Wiring.ConnectMany(
			selectAnd,
			output
		)

		Wiring.ConnectMany(
			selectOr,
			output
		)

		Wiring.ConnectMany(
			selectXor,
			output
		)

		Wiring.ConnectMany(
			selectNot,
			output
		)

		selectedBus[bit] = output
	end

	local zeroFlag = Gates.Not(
		name .. "_ZERO_FLAG",
		P(origin, 102, 0, 120)
	)

	local negativeFlag = selectedBus[15]

	local carryFlag = arithmetic.CarryOut

	function ALU16.ConnectABus(bus)
		arithmetic.ConnectABus(bus)

		for bit = 0, 15 do
			Wiring.Connect(
				bus[bit],
				andBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				orBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				xorBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				notBus[bit]
			)
		end
	end

	function ALU16.ConnectBBus(bus)
		arithmetic.ConnectBBus(bus)

		for bit = 0, 15 do
			Wiring.Connect(
				bus[bit],
				andBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				orBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				xorBus[bit]
			)
		end
	end

	function ALU16.ConnectSubtract(source)
		arithmetic.ConnectSubtract(source)
	end

	return {
		Result = selectedBus,
		Carry = carryFlag,
		Zero = zeroFlag,
		Negative = negativeFlag,

		ConnectABus = ALU16.ConnectABus,
		ConnectBBus = ALU16.ConnectBBus,
		ConnectSubtract = ALU16.ConnectSubtract
	}
end

Context.Modules.ALU16 = ALU16

return ALU16
