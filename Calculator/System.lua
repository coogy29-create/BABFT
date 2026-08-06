local Context=getgenv().BABFT_CALCULATOR

local KeypadEncoder=Context.Modules.KeypadEncoder
local CalculatorController=Context.Modules.CalculatorController
local DisplayController=Context.Modules.DisplayController

local System={}

local function P(origin,x,y,z)
	return origin*CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function System.Build(name,origin)

	local keypad=KeypadEncoder.Build(
		name.."_KEYPAD",
		P(origin,0,0,0)
	)

	local controller=CalculatorController.Build(
		name.."_CONTROLLER",
		P(origin,80,0,0),
		keypad
	)

	local display=DisplayController.Build(
		name.."_OUTPUT",
		P(origin,1500,0,0),
		controller.ResultRegister.Q,
		controller.EqualsButton
	)

	local result={
		Name=name,
		Origin=origin,
		Keypad=keypad,
		Controller=controller,
		Display=display
	}

	Context.System=result
	Context.Modules.System=result

	return result
end

Context.Modules.CalculatorSystem=System

return System
