local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Gates = Context.Modules.Gates
local Adder16 = Context.Modules.Adder16
local Wiring = Context.Modules.Wiring

local Subtractor16 = {}

function Subtractor16.Build(name, origin)
	local self = {}

	local gateSpacing =
		Config.Layout.GateSpacing

	local layerHeight =
		Config.Layout.LayerHeight

	local layerCount =
		Config.Layout.LayerCount

	self.Adder = Adder16.Build(
		name .. "_ADDER",
		origin
	)

	self.BXor = {}
	self.Sum = self.Adder.Sum
	self.Carry = self.Adder.Carry
	self.CarryOut = self.Adder.CarryOut

	for bit = 0, 15 do
		local layer =
			bit % layerCount

		local column =
			math.floor(bit / layerCount)

		local xorOrigin =
			origin
			* CFrame.new(
				(column + 3) * gateSpacing,
				layer * layerHeight,
				0
			)

		local xorGate = Gates.Xor(
			name .. "_B_XOR_" .. bit,
			xorOrigin
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
				"B 입력 비트 누락: "
					.. tostring(bit)
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

		self.Adder.ConnectCarryIn(
			source
		)
	end

	return self
end

Context.Modules.Subtractor16 = Subtractor16

return Subtractor16
