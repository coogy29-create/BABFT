local Context=getgenv().BABFT_CALCULATOR

local Register16=Context.Modules.Register16
local Wiring=Context.Modules.Wiring
local Gates=Context.Modules.Gates

local BinaryToBCD={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function BinaryToBCD.Build(name,origin)

	local bcdRegisters={}

	for digit=0,4 do

		bcdRegisters[digit]=Register16.Build(
			name.."_BCD_"..digit,
			P(origin,digit*34,0)
		)

	end

	local compareGates={}
	local add3Gates={}

	for digit=0,4 do

		compareGates[digit]={}
		add3Gates[digit]={}

		for bit=0,3 do

			compareGates[digit][bit]=Gates.And(
				name.."_CMP_"..digit.."_"..bit,
				P(origin,digit*34,16+bit*2)
			)

			add3Gates[digit][bit]=Gates.Xor(
				name.."_ADD3_"..digit.."_"..bit,
				P(origin,digit*34+10,16+bit*2)
			)

		end

	end

	local shiftBus={}

	for bit=0,15 do

		shiftBus[bit]=Gates.Or(
			name.."_SHIFT_"..bit,
			P(origin,190,bit*2)
		)

	end

	function BinaryToBCD.ConnectBinaryBus(bus)

		for bit=0,15 do

			Wiring.Connect(
				bus[bit],
				shiftBus[bit]
			)

		end

	end

	function BinaryToBCD.ConnectClock(clock)

		for digit=0,4 do

			bcdRegisters[digit].ConnectClock(
				clock
			)

		end

	end

	return{

		BCD=bcdRegisters,

		ShiftBus=shiftBus,

		Compare=compareGates,

		Add3=add3Gates,

		ConnectBinaryBus=BinaryToBCD.ConnectBinaryBus,

		ConnectClock=BinaryToBCD.ConnectClock

	}

end

Context.Modules.BinaryToBCD=BinaryToBCD

return BinaryToBCD
