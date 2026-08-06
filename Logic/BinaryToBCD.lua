local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local BinaryToBCD = {}

local GATES_PER_DIGIT = 18
local DIGITS_PER_STAGE = 5
local GATES_PER_STAGE =
	GATES_PER_DIGIT * DIGITS_PER_STAGE

local STAGE_BASE_INDEX = 32

local function L(origin, index, depth)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		depth or 0
	)
end

local function buildAdd3Digit(
	name,
	origin,
	inputBus,
	baseIndex
)
	local inverted = {}
	local detectors = {}
	local outputBus = {}

	for bit = 0, 3 do
		inverted[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			L(
				origin,
				baseIndex + bit
			)
		)

		Wiring.Connect(
			inputBus[bit],
			inverted[bit]
		)
	end

	for value = 0, 9 do
		local detectorIndex =
			baseIndex + 4 + value

		local detector = Gates.And(
			name .. "_VALUE_" .. value,
			L(
				origin,
				detectorIndex
			)
		)

		for bit = 0, 3 do
			local isOne =
				math.floor(
					value / (2 ^ bit)
				) % 2 == 1

			Wiring.Connect(
				isOne
					and inputBus[bit]
					or inverted[bit],
				detector
			)
		end

		detectors[value] = detector
	end

	for bit = 0, 3 do
		local outputIndex =
			baseIndex + 14 + bit

		local output = Gates.Or(
			name .. "_OUTPUT_" .. bit,
			L(
				origin,
				outputIndex
			)
		)

		for value = 0, 9 do
			local transformed =
				value >= 5
					and value + 3
					or value

			local enabled =
				math.floor(
					transformed / (2 ^ bit)
				) % 2 == 1

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
		Inverted = inverted,
		Detectors = detectors
	}
end

local function buildStage(
	name,
	origin,
	stageInput,
	injectedBit,
	stageIndex
)
	local corrected = {}
	local stageOutput = {}
	local digits = {}

	local stageBase =
		STAGE_BASE_INDEX
		+ stageIndex * GATES_PER_STAGE

	for digit = 0, 4 do
		local digitInput = {}

		for bit = 0, 3 do
			digitInput[bit] =
				stageInput[
					digit * 4 + bit
				]
		end

		local digitBase =
			stageBase
			+ digit * GATES_PER_DIGIT

		local add3 = buildAdd3Digit(
			name .. "_DIGIT_" .. digit,
			origin,
			digitInput,
			digitBase
		)

		digits[digit] = add3

		for bit = 0, 3 do
			corrected[
				digit * 4 + bit
			] = add3.Output[bit]
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
		InjectedBit = injectedBit,
		Digits = digits
	}
end

function BinaryToBCD.Build(name, origin)
	local self = {}

	self.ZeroInput = Gates.And(
		name .. "_ZERO_INPUT",
		L(origin, 0)
	)

	self.ZeroInverse = Gates.Not(
		name .. "_ZERO_INVERSE",
		L(origin, 1)
	)

	self.Zero = Gates.And(
		name .. "_ZERO",
		L(origin, 2)
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
			L(
				origin,
				3 + stage
			)
		)

		self.InputGates[stage] =
			inputGate

		local stageResult = buildStage(
			name .. "_STAGE_" .. stage,
			origin,
			currentBus,
			inputGate,
			stage
		)

		self.Stages[stage] =
			stageResult

		currentBus =
			stageResult.Output
	end

	self.Output = currentBus
	self.Digits = {}

	for digit = 0, 4 do
		self.Digits[digit] = {}

		for bit = 0, 3 do
			self.Digits[digit][bit] =
				self.Output[
					digit * 4 + bit
				]
		end
	end

	function self.ConnectBinaryBus(
		binaryBus
	)
		assert(
			type(binaryBus) == "table",
			"16비트 이진 입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				binaryBus[bit],
				"이진 입력 비트 누락: "
					.. tostring(bit)
			)
		end

		Wiring.Connect(
			binaryBus[0],
			self.ZeroInput
		)

		for stage = 0, 15 do
			local sourceBit =
				15 - stage

			Wiring.Connect(
				binaryBus[sourceBit],
				self.InputGates[stage]
			)
		end
	end

	return self
end

Context.Modules.BinaryToBCD =
	BinaryToBCD

return BinaryToBCD
