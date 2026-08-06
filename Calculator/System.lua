local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local KeypadEncoder = Context.Modules.KeypadEncoder
local CalculatorController = Context.Modules.CalculatorController
local DisplayController = Context.Modules.DisplayController

local CalculatorSystem = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function CalculatorSystem.Build(name, origin)
	assert(
		typeof(origin) == "CFrame",
		"계산기 기준 위치는 CFrame이어야 합니다."
	)

	local self = {}

	local gateSpacing =
		Config.Layout.GateSpacing

	local keypadWidth = 9

	local controllerOffset =
		keypadWidth
		+ gateSpacing * 2

	local controllerWidth =
		gateSpacing * 27

	local displayOffset =
		controllerOffset
		+ controllerWidth
		+ gateSpacing * 2

	self.Keypad = KeypadEncoder.Build(
		name .. "_KEYPAD",
		P(
			origin,
			0,
			0,
			0
		)
	)

	self.Controller =
		CalculatorController.Build(
			name .. "_CONTROLLER",
			P(
				origin,
				controllerOffset,
				0,
				0
			),
			self.Keypad
		)

	self.Display =
		DisplayController.Build(
			name .. "_DISPLAY",
			P(
				origin,
				displayOffset,
				0,
				0
			),
			self.Controller.Result,
			self.Keypad.Pulse
		)

	self.Result =
		self.Controller.Result

	self.KeypadOutput =
		self.Keypad.DigitBus

	self.Origin = origin

	self.Layout = {
		KeypadOrigin = origin,

		ControllerOrigin = P(
			origin,
			controllerOffset,
			0,
			0
		),

		DisplayOrigin = P(
			origin,
			displayOffset,
			0,
			0
		),

		ControllerOffset =
			controllerOffset,

		DisplayOffset =
			displayOffset
	}

	return self
end

Context.Modules.CalculatorSystem =
	CalculatorSystem

return CalculatorSystem
