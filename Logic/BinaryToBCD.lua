local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local Register16 = Context.Modules.Register16
local Builder = Context.Modules.Builder

local BinaryToBCD = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

local function createBCDRegister(name, origin)
	local bits = {}
	local q = {}
	local qb = {}

	for bit = 0, 19 do
		local column = bit % 5
		local row = math.floor(bit / 5)

		local register = Context.Modules.Register1.Build(
			name .. "_BIT_" .. bit,
			P(
				origin,
				column * 54,
				0,
				row * 24
			)
		)

		bits[bit] = register
		q[bit] = register.Q
		qb[bit] = register.QB
	end

	local function connectData(bus)
		for bit = 0, 19 do
			assert(
				bus[bit],
				"BCD 입력 비트 누락: " .. bit
			)

			bits[bit].ConnectData(
				bus[bit]
			)
		end
	end

	local function connectClock(source)
		for bit = 0, 19 do
			bits[bit].ConnectClock(source)
		end
	end

	return {
		Bits = bits,
		Q = q,
		QB = qb,
		ConnectData = connectData,
		ConnectClock = connectClock
	}
end

local function buildAdd3Nibble(name, origin)
	local input = {}
	local output = {}

	for bit = 0, 3 do
		input[bit] = Gates.Or(
			name .. "_INPUT_" .. bit,
			P(origin, 0, 0, bit * 6)
		)
	end

	local not0 = Gates.Not(
		name .. "_NOT_0",
		P(origin, 12, 0, 0)
	)

	local not1 = Gates.Not(
		name .. "_NOT_1",
		P(origin, 12, 0, 6)
	)

	local not2 = Gates.Not(
		name .. "_NOT_2",
		P(origin, 12, 0, 12)
	)

	local not3 = Gates.Not(
		name .. "_NOT_3",
		P(origin, 12, 0, 18)
	)

	Wiring.Connect(input[0], not0)
	Wiring.Connect(input[1], not1)
	Wiring.Connect(input[2], not2)
	Wiring.Connect(input[3], not3)

	local ge5a = Gates.And(
		name .. "_GE5_A",
		P(origin, 24, 0, 0)
	)

	local ge5b = Gates.And(
		name .. "_GE5_B",
		P(origin, 24, 0, 8)
	)

	local ge5 = Gates.Or(
		name .. "_GE5",
		P(origin, 36, 0, 4)
	)

	Wiring.Connect(input[3], ge5a)
	Wiring.Connect(input[2], ge5a)

	Wiring.Connect(input[3], ge5b)
	Wiring.Connect(input[1], ge5b)

	Wiring.Connect(ge5a, ge5)
	Wiring.Connect(ge5b, ge5)

	local add0 = Gates.Xor(
		name .. "_ADD0",
		P(origin, 48, 0, 0)
	)

	local carry0 = Gates.And(
		name .. "_CARRY0",
		P(origin, 48, 0, 6)
	)

	Wiring.Connect(input[0], add0)
	Wiring.Connect(ge5, add0)

	Wiring.Connect(input[0], carry0)
	Wiring.Connect(ge5, carry0)

	local add1x = Gates.Xor(
		name .. "_ADD1_X",
		P(origin, 60, 0, 6)
	)

	local add1 = Gates.Xor(
		name .. "_ADD1",
		P(origin, 72, 0, 6)
	)

	local carry1a = Gates.And(
		name .. "_CARRY1_A",
		P(origin, 60, 0, 12)
	)

	local carry1b = Gates.And(
		name .. "_CARRY1_B",
		P(origin, 72, 0, 12)
	)

	local carry1 = Gates.Or(
		name .. "_CARRY1",
		P(origin, 84, 0, 12)
	)

	Wiring.Connect(input[1], add1x)
	Wiring.Connect(ge5, add1x)

	Wiring.Connect(add1x, add1)
	Wiring.Connect(carry0, add1)

	Wiring.Connect(input[1], carry1a)
	Wiring.Connect(ge5, carry1a)

	Wiring.Connect(add1x, carry1b)
	Wiring.Connect(carry0, carry1b)

	Wiring.Connect(carry1a, carry1)
	Wiring.Connect(carry1b, carry1)

	local add2 = Gates.Xor(
		name .. "_ADD2",
		P(origin, 96, 0, 12)
	)

	local carry2 = Gates.And(
		name .. "_CARRY2",
		P(origin, 96, 0, 18)
	)

	Wiring.Connect(input[2], add2)
	Wiring.Connect(carry1, add2)

	Wiring.Connect(input[2], carry2)
	Wiring.Connect(carry1, carry2)

	local add3 = Gates.Xor(
		name .. "_ADD3",
		P(origin, 108, 0, 18)
	)

	Wiring.Connect(input[3], add3)
	Wiring.Connect(carry2, add3)

	output[0] = add0
	output[1] = add1
	output[2] = add2
	output[3] = add3

	local function connectInput(bus)
		for bit = 0, 3 do
			assert(
				bus[bit],
				"Add3 입력 비트 누락: " .. bit
			)

			Wiring.Connect(
				bus[bit],
				input[bit]
			)
		end
	end

	return {
		Input = input,
		Output = output,
		GreaterOrEqual5 = ge5,
		ConnectInput = connectInput
	}
end

function BinaryToBCD.Build(name, origin)
	local binaryRegister = Register16.Build(
		name .. "_BINARY",
		P(origin, 0, 0, 0)
	)

	local bcdRegister = createBCDRegister(
		name .. "_BCD",
		P(origin, 260, 0, 0)
	)

	local add3 = {}

	for digit = 0, 4 do
		add3[digit] = buildAdd3Nibble(
			name .. "_ADD3_DIGIT_" .. digit,
			P(
				origin,
				520,
				0,
				digit * 34
			)
		)
	end

	local shiftedBinary = {}
	local nextBCD = {}

	for bit = 0, 15 do
		if bit == 0 then
			shiftedBinary[bit] = Gates.Or(
				name .. "_ZERO_BINARY",
				P(origin, 700, 0, bit * 5)
			)
		else
			shiftedBinary[bit] = binaryRegister.Q[bit - 1]
		end
	end

	for digit = 0, 4 do
		local nibble = {}

		for bit = 0, 3 do
			nibble[bit] = bcdRegister.Q[
				digit * 4 + bit
			]
		end

		add3[digit].ConnectInput(nibble)
	end

	for bit = 0, 19 do
		local digit = math.floor(bit / 4)
		local nibbleBit = bit % 4

		if bit == 0 then
			nextBCD[bit] = binaryRegister.Q[15]
		else
			local previousDigit = math.floor(
				(bit - 1) / 4
			)

			local previousBit = (bit - 1) % 4

			nextBCD[bit] =
				add3[previousDigit].Output[previousBit]
		end
	end

	local stepDelay = Builder.PlaceNamedBlock(
		name .. "_STEP_DELAY",
		"Delay",
		P(origin, 760, 0, 0)
	)

	binaryRegister.ConnectData(
		shiftedBinary
	)

	bcdRegister.ConnectData(
		nextBCD
	)

	binaryRegister.ConnectClock(
		stepDelay
	)

	bcdRegister.ConnectClock(
		stepDelay
	)

	local function connectBinaryBus(bus)
		binaryRegister.ConnectData(bus)
	end

	local function connectLoad(source)
		binaryRegister.ConnectClock(source)
	end

	local function connectStep(source)
		Wiring.Connect(
			source,
			stepDelay
		)
	end

	local digits = {}

	for digit = 0, 4 do
		digits[digit] = {}

		for bit = 0, 3 do
			digits[digit][bit] =
				bcdRegister.Q[
					digit * 4 + bit
				]
		end
	end

	return {
		BinaryRegister = binaryRegister,
		BCDRegister = bcdRegister,
		Add3 = add3,
		StepDelay = stepDelay,
		Digits = digits,
		ConnectBinaryBus = connectBinaryBus,
		ConnectLoad = connectLoad,
		ConnectStep = connectStep
	}
end

Context.Modules.BinaryToBCD = BinaryToBCD

return BinaryToBCD
