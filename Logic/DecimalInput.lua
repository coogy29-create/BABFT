local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Adder16 = Context.Modules.Adder16
local Register16 = Context.Modules.Register16

local DecimalInput = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DecimalInput.Build(name, origin)
	local self = {}

	self.Zero = Gates.And(
		name .. "_ZERO",
		P(origin, 0, 0, 0)
	)

	self.Register = Register16.Build(
		name .. "_REGISTER",
		P(origin, 20, 0, 0)
	)

	self.Multiply10Adder = Adder16.Build(
		name .. "_MULTIPLY_10",
		P(origin, 260, 0, 0)
	)

	self.DigitAdder = Adder16.Build(
		name .. "_DIGIT_ADDER",
		P(origin, 520, 0, 0)
	)

	self.ShiftLeft1 = {}
	self.ShiftLeft3 = {}
	self.ExtendedDigit = {}

	for bit = 0, 15 do
		if bit >= 1 then
			self.ShiftLeft1[bit] =
				self.Register.Q[bit - 1]
		else
			self.ShiftLeft1[bit] =
				self.Zero
		end

		if bit >= 3 then
			self.ShiftLeft3[bit] =
				self.Register.Q[bit - 3]
		else
			self.ShiftLeft3[bit] =
				self.Zero
		end

		self.ExtendedDigit[bit] =
			self.Zero
	end

	self.Multiply10Adder.ConnectABus(
		self.ShiftLeft1
	)

	self.Multiply10Adder.ConnectBBus(
		self.ShiftLeft3
	)

	self.Multiply10Adder.ConnectCarryIn(
		self.Zero
	)

	self.DigitAdder.ConnectABus(
		self.Multiply10Adder.Sum
	)

	self.DigitAdder.ConnectBBus(
		self.ExtendedDigit
	)

	self.DigitAdder.ConnectCarryIn(
		self.Zero
	)

	self.Register.ConnectData(
		self.DigitAdder.Sum
	)

	function self.ConnectDigitBus(digitBus)
		assert(
			type(digitBus) == "table",
			"4비트 숫자 입력 버스가 필요합니다."
		)

		for bit = 0, 3 do
			assert(
				digitBus[bit],
				"숫자 입력 비트 누락: " .. bit
			)

			self.ExtendedDigit[bit] =
				digitBus[bit]

			self.DigitAdder.Adders[bit].ConnectB(
				digitBus[bit]
			)
		end
	end

	function self.ConnectClock(source)
		assert(
			source,
			"숫자 입력 클럭이 필요합니다."
		)

		self.Register.ConnectClock(source)
	end

	self.Output = self.Register.Q
	self.OutputInverse = self.Register.QB

	return self
end

Context.Modules.DecimalInput = DecimalInput

return DecimalInput
