local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local Subtractor16 = Context.Modules.Subtractor16

local ALU16 = {}

function ALU16.Build(name, origin)
	local self = {}

	local gateSpacing =
		Config.Layout.GateSpacing

	local layerHeight =
		Config.Layout.LayerHeight

	local layerCount =
		Config.Layout.LayerCount

	self.Arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		origin
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

	local function getGateCFrame(
		bit,
		localIndex
	)
		local globalIndex =
			bit * 10 + localIndex

		local layer =
			globalIndex % layerCount

		local column =
			math.floor(
				globalIndex / layerCount
			)

		return origin * CFrame.new(
			(column + 6) * gateSpacing,
			layer * layerHeight,
			0
		)
	end

	for bit = 0, 15 do
		self.AndBus[bit] = Gates.And(
			name .. "_AND_" .. bit,
			getGateCFrame(bit, 0)
		)

		self.OrBus[bit] = Gates.Or(
			name .. "_OR_" .. bit,
			getGateCFrame(bit, 1)
		)

		self.XorBus[bit] = Gates.Xor(
			name .. "_XOR_" .. bit,
			getGateCFrame(bit, 2)
		)

		self.NotBus[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			getGateCFrame(bit, 3)
		)

		self.SelectArithmetic[bit] =
			Gates.And(
				name
					.. "_SELECT_ARITHMETIC_"
					.. bit,
				getGateCFrame(bit, 4)
			)

		self.SelectAnd[bit] = Gates.And(
			name .. "_SELECT_AND_" .. bit,
			getGateCFrame(bit, 5)
		)

		self.SelectOr[bit] = Gates.And(
			name .. "_SELECT_OR_" .. bit,
			getGateCFrame(bit, 6)
		)

		self.SelectXor[bit] = Gates.And(
			name .. "_SELECT_XOR_" .. bit,
			getGateCFrame(bit, 7)
		)

		self.SelectNot[bit] = Gates.And(
			name .. "_SELECT_NOT_" .. bit,
			getGateCFrame(bit, 8)
		)

		self.Result[bit] = Gates.Or(
			name .. "_RESULT_" .. bit,
			getGateCFrame(bit, 9)
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
				"A 입력 비트 누락: "
					.. tostring(bit)
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
				"B 입력 비트 누락: "
					.. tostring(bit)
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
		assert(
			source,
			"감산 선택 신호가 필요합니다."
		)

		self.Arithmetic.ConnectSubtract(
			source
		)
	end

	function self.ConnectSelectArithmetic(
		source
	)
		assert(
			source,
			"산술 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectArithmetic[bit]
			)
		end
	end

	function self.ConnectSelectAnd(source)
		assert(
			source,
			"AND 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectAnd[bit]
			)
		end
	end

	function self.ConnectSelectOr(source)
		assert(
			source,
			"OR 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectOr[bit]
			)
		end
	end

	function self.ConnectSelectXor(source)
		assert(
			source,
			"XOR 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectXor[bit]
			)
		end
	end

	function self.ConnectSelectNot(source)
		assert(
			source,
			"NOT 선택 신호가 필요합니다."
		)

		for bit = 0, 15 do
			Wiring.Connect(
				source,
				self.SelectNot[bit]
			)
		end
	end

	self.CarryOut =
		self.Arithmetic.CarryOut

	self.Negative =
		self.Result[15]

	return self
end

Context.Modules.ALU16 = ALU16

return ALU16
