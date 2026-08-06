local Context = getgenv().BABFT_CALCULATOR

local FullAdder = Context.Modules.FullAdder

local Adder16 = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function Adder16.Build(name, origin)
	local adders = {}
	local sumBus = {}
	local carryBus = {}

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		local adder = FullAdder.Build(
			name .. "_BIT_" .. bit,
			P(
				origin,
				column * 60,
				0,
				row * 34
			)
		)

		adders[bit] = adder
		sumBus[bit] = adder.Sum
		carryBus[bit] = adder.Carry
	end

	for bit = 0, 14 do
		adders[bit + 1].ConnectCarryIn(
			carryBus[bit]
		)
	end

	local function connectABus(bus)
		assert(
			type(bus) == "table",
			"A 입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				bus[bit],
				"A 입력 비트 누락: " .. bit
			)

			adders[bit].ConnectA(
				bus[bit]
			)
		end
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

			adders[bit].ConnectB(
				bus[bit]
			)
		end
	end

	local function connectCarryIn(source)
		assert(
			source,
			"Carry 입력이 필요합니다."
		)

		adders[0].ConnectCarryIn(source)
	end

	return {
		Adders = adders,
		Sum = sumBus,
		Carry = carryBus,
		CarryOut = carryBus[15],
		ConnectABus = connectABus,
		ConnectBBus = connectBBus,
		ConnectCarryIn = connectCarryIn
	}
end

Context.Modules.Adder16 = Adder16

return Adder16
