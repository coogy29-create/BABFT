local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Adder16 = Context.Modules.Adder16
local Wiring = Context.Modules.Wiring

local Subtractor16 = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function Subtractor16.Build(name, origin)
	local adder = Adder16.Build(
		name .. "_ADDER",
		P(origin, 0, 0, 24)
	)

	local invertedBBus = {}

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		invertedBBus[bit] = Gates.Xor(
			name .. "_B_XOR_" .. bit,
			P(
				origin,
				column * 60,
				0,
				row * 34
			)
		)

		adder.Adders[bit].ConnectB(
			invertedBBus[bit]
		)
	end

	local function connectABus(bus)
		assert(
			type(bus) == "table",
			"A 입력 버스가 필요합니다."
		)

		adder.ConnectABus(bus)
	end

	local function connectBBus(bus)
		assert(
			type(bus) == "table",
			"B 입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				bus[bit],
				"B 입력 비트 누락: " .. bit
			)

			Wiring.Connect(
				bus[bit],
				invertedBBus[bit]
			)
		end
	end

	local function connectSubtract(source)
		assert(
			source,
			"감산 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				invertedBBus[bit]
			)
		end

		adder.ConnectCarryIn(source)
	end

	return {
		Adder = adder,
		InvertedB = invertedBBus,
		Sum = adder.Sum,
		Carry = adder.Carry,
		CarryOut = adder.CarryOut,
		ConnectABus = connectABus,
		ConnectBBus = connectBBus,
		ConnectSubtract = connectSubtract
	}
end

Context.Modules.Subtractor16 = Subtractor16

return Subtractor16
