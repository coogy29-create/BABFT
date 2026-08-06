local Context = getgenv().BABFT_CALCULATOR

local BinaryToBCD = Context.Modules.BinaryToBCD
local DisplayDriver = Context.Modules.DisplayDriver

local DisplayController = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DisplayController.Build(name, origin, binaryBus, clock)

	local converter = BinaryToBCD.Build(
		name .. "_BCD",
		P(origin, 0, 0, 0)
	)

	local display = DisplayDriver.Build(
		name .. "_DISPLAY",
		P(origin, 340, 0, 0),
		5
	)

	converter.ConnectBinaryBus(
		binaryBus
	)

	converter.ConnectLoad(
		clock
	)

	converter.ConnectStep(
		converter.StepDelay
	)

	for digit = 0, 4 do

		display.ConnectDigit(

			digit + 1,

			converter.Digits[digit]

		)

	end

	return {

		Converter = converter,

		Display = display

	}

end

Context.Modules.DisplayController = DisplayController

return DisplayController
