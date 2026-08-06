local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
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

local function L(origin, index)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		0
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

function CalculatorController.Build(
	name,
	origin,
	keypad
)
	local self = {}

	local gateSpacing =
		Config.Layout.GateSpacing

	self.CurrentInput = DecimalInput.Build(
		name .. "_CURRENT_INPUT",
		P(
			origin,
			0,
			0,
			0
		)
	)

	self.OperandA = Register16.Build(
		name .. "_OPERAND_A",
		P(
			origin,
			gateSpacing * 11,
			0,
			0
		)
	)

	self.Arithmetic = Subtractor16.Build(
		name .. "_ARITHMETIC",
		P(
			origin,
			gateSpacing * 15,
			0,
			0
		)
	)

	self.ResultRegister = Register16.Build(
		name .. "_RESULT",
		P(
			origin,
			gateSpacing * 20,
			0,
			0
		)
	)

	local buttonOrigin = P(
		origin,
		0,
		0,
		14
	)

	local buttonSpacing = 3

	self.AddButton = createButton(
		name .. "_BUTTON_ADD",
		P(
			buttonOrigin,
			0,
			0,
			0
		)
	)

	self.SubtractButton = createButton(
		name .. "_BUTTON_SUBTRACT",
		P(
			buttonOrigin,
			buttonSpacing,
			0,
			0
		)
	)

	self.EqualsButton = createButton(
		name .. "_BUTTON_EQUALS",
		P(
			buttonOrigin,
			buttonSpacing * 2,
			0,
			0
		)
	)

	self.ClearButton = createButton(
		name .. "_BUTTON_CLEAR",
		P(
			buttonOrigin,
			buttonSpacing * 3,
			0,
			0
		)
	)

	local controlOrigin = P(
		origin,
		gateSpacing * 24,
		0,
		0
	)

	self.SubtractSet = Gates.Or(
		name .. "_SUBTRACT_SET",
		L(
			controlOrigin,
			0
		)
	)

	self.SubtractReset = Gates.Or(
		name .. "_SUBTRACT_RESET",
		L(
			controlOrigin,
			1
		)
	)

	self.SubtractQOr = Gates.Or(
		name .. "_SUBTRACT_Q_OR",
		L(
			controlOrigin,
			2
		)
	)

	self.SubtractQ = Gates.Not(
		name .. "_SUBTRACT_Q",
		L(
			controlOrigin,
			3
		)
	)

	self.SubtractQBOr = Gates.Or(
		name .. "_SUBTRACT_QB_OR",
		L(
			controlOrigin,
			4
		)
	)

	self.SubtractQB = Gates.Not(
		name .. "_SUBTRACT_QB",
		L(
			controlOrigin,
			5
		)
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

	self.Result =
		self.ResultRegister.Q

	self.ResultInverse =
		self.ResultRegister.QB

	self.SubtractMode =
		self.SubtractQ

	return self
end

Context.Modules.CalculatorController =
	CalculatorController

return CalculatorController
