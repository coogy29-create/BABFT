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
	local self = {}

	self.Adder = Adder16.Build(
		name .. "_ADDER",
		P(origin, 0, 0, 28)
	)

	self.BXor = {}
	self.Sum = self.Adder.Sum
	self.Carry = self.Adder.Carry
	self.CarryOut = self.Adder.CarryOut

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		local xorGate = Gates.Xor(
			name .. "_B_XOR_" .. bit,
			P(
				origin,
				column * 60,
				0,
				row * 36
			)
		)

		self.BXor[bit] = xorGate

		self.Adder.Adders[bit].ConnectB(
			xorGate
		)
	end

	function self.ConnectABus(bus)
		assert(
			type(bus) == "table",
			"A 입력 버스가 필요합니다."
		)

		self.Adder.ConnectABus(bus)
	end

	function self.ConnectBBus(bus)
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
				self.BXor[bit]
			)
		end
	end

	function self.ConnectSubtract(source)
		assert(
			source,
			"감산 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.BXor[bit]
			)
		end

		self.Adder.ConnectCarryIn(source)
	end

	return self
end

Context.Modules.Subtractor16 = Subtractor16

return Subtractor16
