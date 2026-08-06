local Context=getgenv().BABFT_CALCULATOR

local DecimalInput=Context.Modules.DecimalInput
local Adder16=Context.Modules.Adder16
local Subtractor16=Context.Modules.Subtractor16
local BinaryToBCD=Context.Modules.BinaryToBCD
local DisplayDriver=Context.Modules.DisplayDriver

local Calculator={}

function Calculator.Build(origin)

	local inputA=DecimalInput.Build(
		"INPUT_A",
		origin*CFrame.new(0,0,0)
	)

	local inputB=DecimalInput.Build(
		"INPUT_B",
		origin*CFrame.new(0,0,90)
	)

	local adder=Adder16.Build(
		"ADDER16",
		origin*CFrame.new(180,0,0)
	)

	local subtractor=Subtractor16.Build(
		"SUB16",
		origin*CFrame.new(180,0,120)
	)

	local bcd=BinaryToBCD.Build(
		"BCD",
		origin*CFrame.new(620,0,0)
	)

	local display=DisplayDriver.Build(
		"DISPLAY",
		origin*CFrame.new(900,0,0),
		5
	)

	adder.ConnectABus(
		inputA.Output
	)

	adder.ConnectBBus(
		inputB.Output
	)

	subtractor.ConnectABus(
		inputA.Output
	)

	subtractor.ConnectBBus(
		inputB.Output
	)

	bcd.ConnectBinaryBus(
		adder.Sum
	)

	for digit=1,5 do

		display.ConnectDigit(
			digit,
			bcd.BCD[digit-1].Q
		)

	end

	return{

		InputA=inputA,

		InputB=inputB,

		Adder=adder,

		Subtractor=subtractor,

		BCD=bcd,

		Display=display

	}

end

Context.Modules.Calculator=Calculator

return Calculator
