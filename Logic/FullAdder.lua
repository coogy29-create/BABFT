local Context=getgenv().BABFT_CALCULATOR

local HalfAdder=Context.Modules.HalfAdder
local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring

local FullAdder={}

local function P(origin,x,y,z)
	return origin*CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function FullAdder.Build(name,origin)

	local ha1=HalfAdder.Build(
		name.."_HA1",
		P(origin,0,0,0)
	)

	local ha2=HalfAdder.Build(
		name.."_HA2",
		P(origin,24,0,0)
	)

	local carryOr=Gates.Or(
		name.."_CARRY_OR",
		P(origin,48,0,4)
	)

	function FullAdder.ConnectA(source)

		ha1.ConnectA(source)

	end

	function FullAdder.ConnectB(source)

		ha1.ConnectB(source)

	end

	function FullAdder.ConnectCarryIn(source)

		ha2.ConnectB(source)

	end

	Wiring.Connect(
		ha1.Sum,
		ha2.Sum
	)

	Wiring.Connect(
		ha1.Carry,
		carryOr
	)

	Wiring.Connect(
		ha2.Carry,
		carryOr
	)

	return{

		Sum=ha2.Sum,

		Carry=carryOr,

		ConnectA=FullAdder.ConnectA,

		ConnectB=FullAdder.ConnectB,

		ConnectCarryIn=FullAdder.ConnectCarryIn

	}

end

Context.Modules.FullAdder=FullAdder

return FullAdder
