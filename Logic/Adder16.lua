local Context=getgenv().BABFT_CALCULATOR

local FullAdder=Context.Modules.FullAdder
local Wiring=Context.Modules.Wiring

local Adder16={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function Adder16.Build(name,origin)

	local adders={}
	local sumBus={}
	local carryBus={}

	for bit=0,15 do

		local adder=FullAdder.Build(
			name.."_FA_"..bit,
			P(origin,bit*24,0)
		)

		adders[bit]=adder
		sumBus[bit]=adder.Sum
		carryBus[bit]=adder.Carry

	end

	for bit=0,14 do

		Wiring.Connect(
			carryBus[bit],
			name.."_FA_"..(bit+1).."_Cin"
		)

	end

	function adders.ConnectABus(bus)

		for bit=0,15 do

			Wiring.Connect(
				bus[bit],
				name.."_FA_"..bit.."_HA1_A"
			)

		end

	end

	function adders.ConnectBBus(bus)

		for bit=0,15 do

			Wiring.Connect(
				bus[bit],
				name.."_FA_"..bit.."_HA1_B"
			)

		end

	end

	function adders.ConnectCarryIn(source)

		Wiring.Connect(
			source,
			name.."_FA_0_Cin"
		)

	end

	return{

		Adders=adders,

		Sum=sumBus,

		CarryOut=carryBus[15],

		ConnectABus=adders.ConnectABus,

		ConnectBBus=adders.ConnectBBus,

		ConnectCarryIn=adders.ConnectCarryIn

	}

end

Context.Modules.Adder16=Adder16

return Adder16
