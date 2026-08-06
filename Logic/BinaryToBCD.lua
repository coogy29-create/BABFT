local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local BinaryToBCD = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

local function buildAdd3Digit(name, origin, inputBus)
	local inverted = {}
	local detectors = {}
	local outputBus = {}

	for bit = 0, 3 do
		inverted[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			P(origin, bit * 6, 0, 0)
		)

		Wiring.Connect(
			inputBus[bit],
			inverted[bit]
		)
	end

	for value = 0, 9 do
		local detector = Gates.And(
			name .. "_VALUE_" .. value,
			P(
				origin,
				(value % 5) * 8,
				0,
				10 + math.floor(value / 5) * 8
			)
		)

		for bit = 0, 3 do
			local isOne =
				math.floor(value / (2 ^ bit)) % 2 == 1

			Wiring.Connect(
				isOne and inputBus[bit] or inverted[bit],
				detector
			)
		end

		detectors[value] = detector
	end

	for bit = 0, 3 do
		local output = Gates.Or(
			name .. "_OUTPUT_" .. bit,
			P(origin, bit * 8, 0, 30)
		)

		for value = 0, 9 do
			local transformed =
				value >= 5 and value + 3 or value

			local enabled =
				math.floor(transformed / (2 ^ bit)) % 2 == 1

			if enabled then
				Wiring.Connect(
					detectors[value],
					output
				)
			end
		end

		outputBus[bit] = output
	end

	return {
		Input = inputBus,
		Output = outputBus,
		Detectors = detectors
	}
end

local function buildStage(
	name,
	origin,
	stageInput,
	injectedBit
)
	local corrected = {}
	local stageOutput = {}

	for digit = 0, 4 do
		local digitInput = {}

		for bit = 0, 3 do
			digitInput[bit] =
				stageInput[digit * 4 + bit]
		end

		local add3 = buildAdd3Digit(
			name .. "_DIGIT_" .. digit,
			P(origin, digit * 48, 0, 0),
			digitInput
		)

		for bit = 0, 3 do
			corrected[digit * 4 + bit] =
				add3.Output[bit]
		end
	end

	stageOutput[0] = injectedBit

	for bit = 1, 19 do
		stageOutput[bit] =
			corrected[bit - 1]
	end

	return {
		Input = stageInput,
		Corrected = corrected,
		Output = stageOutput,
		InjectedBit = injectedBit
	}
end

function BinaryToBCD.Build(name, origin)
	local self = {}

	self.ZeroInput = Gates.And(
		name .. "_ZERO_INPUT",
		P(origin, 0, 0, -30)
	)

	self.ZeroInverse = Gates.Not(
		name .. "_ZERO_INVERSE",
		P(origin, 10, 0, -30)
	)

	self.Zero = Gates.And(
		name .. "_ZERO",
		P(origin, 20, 0, -30)
	)

	Wiring.Connect(
		self.ZeroInput,
		self.ZeroInverse
	)

	Wiring.Connect(
		self.ZeroInput,
		self.Zero
	)

	Wiring.Connect(
		self.ZeroInverse,
		self.Zero
	)

	self.InputGates = {}
	self.Stages = {}

	local currentBus = {}

	for bit = 0, 19 do
		currentBus[bit] = self.Zero
	end

	for stage = 0, 15 do
		local inputGate = Gates.Or(
			name .. "_INPUT_BIT_" .. stage,
			P(
				origin,
				stage * 8,
				0,
				-18
			)
		)

		self.InputGates[stage] = inputGate

		local stageResult = buildStage(
			name .. "_STAGE_" .. stage,
			P(
				origin,
				0,
				0,
				stage * 44
			),
			currentBus,
			inputGate
		)

		self.Stages[stage] = stageResult
		currentBus = stageResult.Output
	end

	self.Output = currentBus
	self.Digits = {}

	for digit = 0, 4 do
		self.Digits[digit] = {}

		for bit = 0, 3 do
			self.Digits[digit][bit] =
				self.Output[digit * 4 + bit]
		end
	end

	function self.ConnectBinaryBus(binaryBus)
		assert(
			type(binaryBus) == "table",
			"16비트 이진 입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				binaryBus[bit],
				"이진 입력 비트 누락: " .. bit
			)
		end

		Wiring.Connect(
			binaryBus[0],
			self.ZeroInput
		)

		for stage = 0, 15 do
			local sourceBit = 15 - stage

			Wiring.Connect(
				binaryBus[sourceBit],
				self.InputGates[stage]
			)
		end
	end

	return self
end

Context.Modules.BinaryToBCD = BinaryToBCD

return BinaryToBCD
