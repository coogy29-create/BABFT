local Context = getgenv().BABFT_CALCULATOR

local Builder = Context.Modules.Builder
local Binder = Context.Modules.Bind
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local DecimalInput = Context.Modules.DecimalInput
local Register16 = Context.Modules.Register16
local Subtractor16 = Context.Modules.Subtractor16

local CalculatorController = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

local function createButton(name, cframe)
	local button = Builder.PlaceNamedBlock(
		name,
		"Button",
		cframe
	)

	Binder.AutoUnbindNearest(button)

	return button
end

function CalculatorController.Build(name, origin, keypad)
	local self = {}

	self.CurrentInput = DecimalInput.Build(
		name .. "_CURRENT_INPUT",
		P(origin, 0, 0, 0)
	)

	self.OperandA = Register16.Build(
		name .. "_OPERAND_A",
		P(origin, 820, 0, 0)
	)

	self.Arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		P(origin, 1080, 0, 0)
	)

	self.ResultRegister = Register16.Build(
		name .. "_RESULT",
		P(origin, 1380, 0, 0)
	)

	self.AddButton = createButton(
		name .. "_BUTTON_ADD",
		P(origin, -24, 0, 20)
	)

	self.SubtractButton = createButton(
		name .. "_BUTTON_SUBTRACT",
		P(origin, -16, 0, 20)
	)

	self.EqualsButton = createButton(
		name .. "_BUTTON_EQUALS",
		P(origin, -8, 0, 20)
	)

	self.ClearButton = createButton(
		name .. "_BUTTON_CLEAR",
		P(origin, 0, 0, 20)
	)

	self.SubtractSet = Gates.Or(
		name .. "_SUBTRACT_SET",
		P(origin, 960, 0, 0)
	)

	self.SubtractReset = Gates.Or(
		name .. "_SUBTRACT_RESET",
		P(origin, 960, 0, 16)
	)

	self.SubtractQOr = Gates.Or(
		name .. "_SUBTRACT_Q_OR",
		P(origin, 980, 0, 0)
	)

	self.SubtractQ = Gates.Not(
		name .. "_SUBTRACT_Q",
		P(origin, 994, 0, 0)
	)

	self.SubtractQBOr = Gates.Or(
		name .. "_SUBTRACT_QB_OR",
		P(origin, 980, 0, 16)
	)

	self.SubtractQB = Gates.Not(
		name .. "_SUBTRACT_QB",
		P(origin, 994, 0, 16)
	)

	Wiring.Connect(
		self.SubtractReset,
		self.SubtractQOr
	)

	Wiring.Connect(
		self.SubtractSet,
		self.SubtractQBOr
	)

	Wiring.Connect(
		self.SubtractQOr,
		self.SubtractQ
	)

	Wiring.Connect(
		self.SubtractQBOr,
		self.SubtractQB
	)

	Wiring.Connect(
		self.SubtractQ,
		self.SubtractQBOr
	)

	Wiring.Connect(
		self.SubtractQB,
		self.SubtractQOr
	)

	Wiring.Connect(
		self.SubtractButton,
		self.SubtractSet
	)

	Wiring.Connect(
		self.AddButton,
		self.SubtractReset
	)

	Wiring.Connect(
		self.ClearButton,
		self.SubtractReset
	)

	self.CurrentInput.ConnectDigitBus(
		keypad.DigitBus
	)

	self.CurrentInput.ConnectClock(
		keypad.Pulse
	)

	self.OperandA.ConnectData(
		self.CurrentInput.Output
	)

	self.OperandA.ConnectClock(
		self.AddButton
	)

	self.OperandA.ConnectClock(
		self.SubtractButton
	)

	self.Arithmetic.ConnectABus(
		self.OperandA.Q
	)

	self.Arithmetic.ConnectBBus(
		self.CurrentInput.Output
	)

	self.Arithmetic.ConnectSubtract(
		self.SubtractQ
	)

	self.ResultRegister.ConnectData(
		self.Arithmetic.Sum
	)

	self.ResultRegister.ConnectClock(
		self.EqualsButton
	)

	self.Result = self.ResultRegister.Q
	self.ResultInverse = self.ResultRegister.QB
	self.SubtractMode = self.SubtractQ

	return self
end

Context.Modules.CalculatorController = CalculatorController

return CalculatorController
