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
	local self = {}

	self.Arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		P(origin, 0, 0, 0)
	)

	self.AndBus = {}
	self.OrBus = {}
	self.XorBus = {}
	self.NotBus = {}
	self.Result = {}

	self.SelectArithmetic = {}
	self.SelectAnd = {}
	self.SelectOr = {}
	self.SelectXor = {}
	self.SelectNot = {}

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		local x = column * 72
		local z = row * 82

		self.AndBus[bit] = Gates.And(
			name .. "_AND_" .. bit,
			P(origin, x, 0, z + 34)
		)

		self.OrBus[bit] = Gates.Or(
			name .. "_OR_" .. bit,
			P(origin, x, 0, z + 42)
		)

		self.XorBus[bit] = Gates.Xor(
			name .. "_XOR_" .. bit,
			P(origin, x, 0, z + 50)
		)

		self.NotBus[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			P(origin, x, 0, z + 58)
		)

		self.SelectArithmetic[bit] = Gates.And(
			name .. "_SELECT_ARITHMETIC_" .. bit,
			P(origin, x + 18, 0, z + 34)
		)

		self.SelectAnd[bit] = Gates.And(
			name .. "_SELECT_AND_" .. bit,
			P(origin, x + 18, 0, z + 42)
		)

		self.SelectOr[bit] = Gates.And(
			name .. "_SELECT_OR_" .. bit,
			P(origin, x + 18, 0, z + 50)
		)

		self.SelectXor[bit] = Gates.And(
			name .. "_SELECT_XOR_" .. bit,
			P(origin, x + 18, 0, z + 58)
		)

		self.SelectNot[bit] = Gates.And(
			name .. "_SELECT_NOT_" .. bit,
			P(origin, x + 18, 0, z + 66)
		)

		self.Result[bit] = Gates.Or(
			name .. "_RESULT_" .. bit,
			P(origin, x + 36, 0, z + 50)
		)

		Wiring.Connect(
			self.Arithmetic.Sum[bit],
			self.SelectArithmetic[bit]
		)

		Wiring.Connect(
			self.AndBus[bit],
			self.SelectAnd[bit]
		)

		Wiring.Connect(
			self.OrBus[bit],
			self.SelectOr[bit]
		)

		Wiring.Connect(
			self.XorBus[bit],
			self.SelectXor[bit]
		)

		Wiring.Connect(
			self.NotBus[bit],
			self.SelectNot[bit]
		)

		Wiring.Connect(
			self.SelectArithmetic[bit],
			self.Result[bit]
		)

		Wiring.Connect(
			self.SelectAnd[bit],
			self.Result[bit]
		)

		Wiring.Connect(
			self.SelectOr[bit],
			self.Result[bit]
		)

		Wiring.Connect(
			self.SelectXor[bit],
			self.Result[bit]
		)

		Wiring.Connect(
			self.SelectNot[bit],
			self.Result[bit]
		)
	end

	function self.ConnectABus(bus)
		assert(
			type(bus) == "table",
			"A 입력 버스가 필요합니다."
		)

		self.Arithmetic.ConnectABus(bus)

		for bit = 0, 15 do
			assert(
				bus[bit],
				"A 입력 비트 누락: " .. bit
			)

			Wiring.Connect(
				bus[bit],
				self.AndBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				self.OrBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				self.XorBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				self.NotBus[bit]
			)
		end
	end

	function self.ConnectBBus(bus)
		assert(
			type(bus) == "table",
			"B 입력 버스가 필요합니다."
		)

		self.Arithmetic.ConnectBBus(bus)

		for bit = 0, 15 do
			assert(
				bus[bit],
				"B 입력 비트 누락: " .. bit
			)

			Wiring.Connect(
				bus[bit],
				self.AndBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				self.OrBus[bit]
			)

			Wiring.Connect(
				bus[bit],
				self.XorBus[bit]
			)
		end
	end

	function self.ConnectSubtract(source)
		self.Arithmetic.ConnectSubtract(source)
	end

	function self.ConnectSelectArithmetic(source)
		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectArithmetic[bit]
			)
		end
	end

	function self.ConnectSelectAnd(source)
		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectAnd[bit]
			)
		end
	end

	function self.ConnectSelectOr(source)
		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectOr[bit]
			)
		end
	end

	function self.ConnectSelectXor(source)
		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectXor[bit]
			)
		end
	end

	function self.ConnectSelectNot(source)
		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectNot[bit]
			)
		end
	end

	self.CarryOut = self.Arithmetic.CarryOut
	self.Negative = self.Result[15]

	return self
end

Context.Modules.ALU16 = ALU16

return ALU16
