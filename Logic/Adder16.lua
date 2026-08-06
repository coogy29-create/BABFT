local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local FullAdder = Context.Modules.FullAdder

local Adder16 = {}

function Adder16.Build(name, origin)
	local self = {}

	self.Adders = {}
	self.Sum = {}
	self.Carry = {}

	local layersPerAdder = 5

	local addersPerColumn = math.max(
		1,
		math.floor(
			Config.Layout.LayerCount
				/ layersPerAdder
		)
	)

	for bit = 0, 15 do
		local column =
			math.floor(
				bit / addersPerColumn
			)

		local adderInColumn =
			bit % addersPerColumn

		local startLayer =
			adderInColumn * layersPerAdder

		local adderOrigin =
			origin
			* CFrame.new(
				column
					* Config.Layout.GateSpacing,
				startLayer
					* Config.Layout.LayerHeight,
				0
			)

		local adder = FullAdder.Build(
			name .. "_BIT_" .. bit,
			adderOrigin
		)

		self.Adders[bit] = adder
		self.Sum[bit] = adder.Sum
		self.Carry[bit] = adder.Carry
	end

	for bit = 0, 14 do
		self.Adders[bit + 1].ConnectCarryIn(
			self.Carry[bit]
		)
	end

	function self.ConnectABus(bus)
		assert(
			type(bus) == "table",
			"A 입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				bus[bit],
				"A 입력 비트 누락: "
					.. tostring(bit)
			)

			self.Adders[bit].ConnectA(
				bus[bit]
			)
		end
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

			self.Adders[bit].ConnectB(
				bus[bit]
			)
		end
	end

	function self.ConnectCarryIn(source)
		assert(
			source,
			"Carry 입력이 필요합니다."
		)

		self.Adders[0].ConnectCarryIn(
			source
		)
	end

	self.CarryOut = self.Carry[15]

	return self
end

Context.Modules.Adder16 = Adder16

return Adder16
