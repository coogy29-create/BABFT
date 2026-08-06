local Context=getgenv().BABFT_CALCULATOR

local Adder16=Context.Modules.Adder16
local Register16=Context.Modules.Register16
local Wiring=Context.Modules.Wiring

local DecimalInput={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function DecimalInput.Build(name,origin)

	local multiplyAdder=Adder16.Build(
		name.."_MUL10",
		P(origin,0,0)
	)

	local digitAdder=Adder16.Build(
		name.."_DIGIT_ADD",
		P(origin,0,32)
	)

	local register=Register16.Build(
		name.."_REGISTER",
		P(origin,0,64)
	)

	local shiftLeft1={}
	local shiftLeft3={}
	local digit16={}

	for bit=0,15 do
		shiftLeft1[bit]=nil
		shiftLeft3[bit]=nil
		digit16[bit]=nil
	end

	function DecimalInput.ConnectCurrentBus(currentBus,zeroSource)

		for bit=0,15 do

			if bit>=1 then
				shiftLeft1[bit]=currentBus[bit-1]
			else
				shiftLeft1[bit]=zeroSource
			end

			if bit>=3 then
				shiftLeft3[bit]=currentBus[bit-3]
			else
				shiftLeft3[bit]=zeroSource
			end

		end

		multiplyAdder.ConnectABus(shiftLeft1)
		multiplyAdder.ConnectBBus(shiftLeft3)
		multiplyAdder.ConnectCarryIn(zeroSource)

	end

	function DecimalInput.ConnectDigitBus(digitBus,zeroSource)

		for bit=0,15 do

			if bit<=3 then
				digit16[bit]=digitBus[bit]
			else
				digit16[bit]=zeroSource
			end

		end

		digitAdder.ConnectABus(
			multiplyAdder.Sum
		)

		digitAdder.ConnectBBus(
			digit16
		)

		digitAdder.ConnectCarryIn(
			zeroSource
		)

	end

	function DecimalInput.ConnectClock(clockSource)

		register.ConnectData(
			digitAdder.Sum
		)

		register.ConnectClock(
			clockSource
		)

	end

	return{
		Output=register.Q,
		OutputInverse=register.QB,
		MultiplyResult=multiplyAdder.Sum,
		DigitResult=digitAdder.Sum,
		Register=register,
		ConnectCurrentBus=DecimalInput.ConnectCurrentBus,
		ConnectDigitBus=DecimalInput.ConnectDigitBus,
		ConnectClock=DecimalInput.ConnectClock
	}

end

Context.Modules.DecimalInput=DecimalInput

return DecimalInput
