local Context=getgenv().BABFT_CALCULATOR

local DisplayDriver=Context.Modules.DisplayDriver
local BinaryToBCD=Context.Modules.BinaryToBCD

local DisplayController={}

local function P(origin,x,y,z)
	return origin*CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DisplayController.Build(name,origin,resultBus,clock)

	local converter=BinaryToBCD.Build(
		name.."_CONVERTER",
		P(origin,0,0,0)
	)

	local display=DisplayDriver.Build(
		name.."_DISPLAY",
		P(origin,260,0,0),
		5
	)

	converter.ConnectBinaryBus(
		resultBus
	)

	converter.ConnectClock(
		clock
	)

	for digit=0,4 do

		display.ConnectDigit(
			digit+1,
			converter.BCD[digit].Q
		)

	end

	return{

		Converter=converter,

		Display=display

	}

end

Context.Modules.DisplayController=DisplayController

return DisplayController
