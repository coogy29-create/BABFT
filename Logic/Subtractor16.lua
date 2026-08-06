local Context=getgenv().BABFT_CALCULATOR

local Gates=Context.Modules.Gates
local Adder16=Context.Modules.Adder16
local Wiring=Context.Modules.Wiring

local Subtractor16={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function Subtractor16.Build(name,origin)

	local adder=Adder16.Build(
		name.."_ADDER",
		P(origin,0,0)
	)

	local xorBus={}

	for bit=0,15 do

		xorBus[bit]=Gates.Xor(
			name.."_BXOR_"..bit,
			P(origin,bit*24,-8)
		)

		Wiring.Connect(
			xorBus[bit],
			name.."_ADDER_FA_"..bit.."_HA1_B"
		)

	end

	function xorBus.ConnectBBus(bus)

		for bit=0,15 do

			Wiring.Connect(
				bus[bit],
				name.."_BXOR_"..bit
			)

		end

	end

	function xorBus.ConnectSubtract(source)

		for bit=0,15 do

			Wiring.Connect(
				source,
				name.."_BXOR_"..bit
			)

		end

		adder.ConnectCarryIn(source)

	end

	function xorBus.ConnectABus(bus)

		adder.ConnectABus(bus)

	end

	return{

		Sum=adder.Sum,

		CarryOut=adder.CarryOut,

		ConnectABus=xorBus.ConnectABus,

		ConnectBBus=xorBus.ConnectBBus,

		ConnectSubtract=xorBus.ConnectSubtract

	}

end

Context.Modules.Subtractor16=Subtractor16

return Subtractor16
