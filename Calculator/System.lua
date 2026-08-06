local Context = getgenv().BABFT_CALCULATOR

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

	local self = {}

	self.Keypad = KeypadEncoder.Build(
		name .. "_KEYPAD",
		P(origin, 0, 0, 0)
	)

	self.Controller = CalculatorController.Build(
		name .. "_CONTROLLER",
		P(origin, 120, 0, 0),
		self.Keypad
	)

	self.Display = DisplayController.Build(
		name .. "_DISPLAY",
		P(origin, 1700, 0, 0),
		self.Controller.Result,
		self.Keypad.Pulse
	)

	self.Result = self.Controller.Result
	self.KeypadOutput = self.Keypad.DigitBus

	return self

end

Context.Modules.CalculatorSystem = CalculatorSystem

return CalculatorSystem
