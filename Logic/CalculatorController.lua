local Context = getgenv().BABFT_CALCULATOR

local Builder = Context.Modules.Builder
local Binder = Context.Modules.Bind
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local DecimalAccumulator = Context.Modules.DecimalAccumulator
local Register16 = Context.Modules.Register16
local Subtractor16 = Context.Modules.Subtractor16
local BinaryToBCD = Context.Modules.BinaryToBCD

local CalculatorController = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function CalculatorController.Build(name, origin, keypad)
	local currentInput = DecimalAccumulator.Build(
		name .. "_CURRENT_INPUT",
		P(origin, 0, 0, 0)
	)

	local operandA = Register16.Build(
		name .. "_OPERAND_A",
		P(origin, 260, 0, 0)
	)

	local arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		P(origin, 520, 0, 0)
	)

	local resultRegister = Register16.Build(
		name .. "_RESULT",
		P(origin, 920, 0, 0)
	)

	local bcd = BinaryToBCD.Build(
		name .. "_BCD",
		P(origin, 1180, 0, 0)
	)

	local addButton = Builder.PlaceNamedBlock(
		name .. "_BUTTON_ADD",
		"Button",
		P(origin, -20, 0, 18)
	)

	local subtractButton = Builder.PlaceNamedBlock(
		name .. "_BUTTON_SUBTRACT",
		"Button",
		P(origin, -14, 0, 18)
	)

	local equalsButton = Builder.PlaceNamedBlock(
		name .. "_BUTTON_EQUALS",
		"Button",
		P(origin, -8, 0, 18)
	)

	local clearButton = Builder.PlaceNamedBlock(
		name .. "_BUTTON_CLEAR",
		"Button",
		P(origin, -2, 0, 18)
	)

	Binder.AutoUnbindNearest(addButton)
	Binder.AutoUnbindNearest(subtractButton)
	Binder.AutoUnbindNearest(equalsButton)
	Binder.AutoUnbindNearest(clearButton)

	local subtractState = Gates.Or(
		name .. "_SUBTRACT_STATE",
		P(origin, 430, 0, 20)
	)

	currentInput.ConnectDigit(
		keypad.DigitBus
	)

	currentInput.ConnectClock(
		keypad.Pulse
	)

	operandA.ConnectData(
		currentInput.Result
	)

	operandA.ConnectClock(
		addButton
	)

	operandA.ConnectClock(
		subtractButton
	)

	arithmetic.ConnectABus(
		operandA.Q
	)

	arithmetic.ConnectBBus(
		currentInput.Result
	)

	arithmetic.ConnectSubtract(
		subtractState
	)

	Wiring.Connect(
		subtractButton,
		subtractState
	)

	resultRegister.ConnectData(
		arithmetic.Sum
	)

	resultRegister.ConnectClock(
		equalsButton
	)

	bcd.ConnectBinaryBus(
		resultRegister.Q
	)

	bcd.ConnectClock(
		equalsButton
	)

	currentInput.Clear(
		clearButton
	)

	return {
		CurrentInput = currentInput,
		OperandA = operandA,
		Arithmetic = arithmetic,
		ResultRegister = resultRegister,
		BCD = bcd,

		AddButton = addButton,
		SubtractButton = subtractButton,
		EqualsButton = equalsButton,
		ClearButton = clearButton,

		SubtractState = subtractState
	}
end

Context.Modules.CalculatorController = CalculatorController

return CalculatorController
