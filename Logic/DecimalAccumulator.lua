local Context = getgenv().BABFT_CALCULATOR

local Register16 = Context.Modules.Register16
local ALU16 = Context.Modules.ALU16
local Wiring = Context.Modules.Wiring

local DecimalAccumulator = {}

local function P(origin,x,y,z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DecimalAccumulator.Build(name,origin)

	local register=Register16.Build(
		name.."_REGISTER",
		P(origin,0,0,0)
	)

	local alu=ALU16.Build(
		name.."_ALU",
		P(origin,120,0,0)
	)

	local digitBus={}

	for bit=0,15 do
		digitBus[bit]=false
	end

	alu.ConnectABus(
		register.Q
	)

	alu.ConnectBBus(
		digitBus
	)

	register.ConnectData(
		alu.Result
	)

	function DecimalAccumulator.ConnectDigit(bus)

		for bit=0,15 do
			digitBus[bit]=bus[bit]
		end

		alu.ConnectBBus(
			digitBus
		)

	end

	function DecimalAccumulator.ConnectClock(clock)

		register.ConnectClock(clock)

	end

	function DecimalAccumulator.Clear(source)

		for bit=0,15 do

			Wiring.Connect(
				source,
				register.QB[bit]
			)

		end

	end

	return{

		Register=register,

		Result=register.Q,

		ConnectDigit=DecimalAccumulator.ConnectDigit,

		ConnectClock=DecimalAccumulator.ConnectClock,

		Clear=DecimalAccumulator.Clear

	}

end

Context.Modules.DecimalAccumulator=DecimalAccumulator

return DecimalAccumulator
