local Context=getgenv().BABFT_CALCULATOR

local Gates=Context.Modules.Gates
local Wiring=Context.Modules.Wiring
local Components=Context.Modules.Components

local DLatch={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function DLatch.Build(name,origin)

	local notD=Gates.Not(
		name.."_NOT_D",
		P(origin,0,4)
	)

	local setGate=Gates.And(
		name.."_SET",
		P(origin,6,0)
	)

	local resetGate=Gates.And(
		name.."_RESET",
		P(origin,6,8)
	)

	local orQ=Gates.Or(
		name.."_OR_Q",
		P(origin,12,0)
	)

	local notQ=Gates.Not(
		name.."_Q",
		P(origin,18,0)
	)

	local orQB=Gates.Or(
		name.."_OR_QB",
		P(origin,12,8)
	)

	local notQB=Gates.Not(
		name.."_QB",
		P(origin,18,8)
	)

	Wiring.Connect(
		notD,
		resetGate
	)

	Wiring.Connect(
		setGate,
		orQB
	)

	Wiring.Connect(
		resetGate,
		orQ
	)

	Wiring.Connect(
		orQ,
		notQ
	)

	Wiring.Connect(
		orQB,
		notQB
	)

	Wiring.Connect(
		notQ,
		orQB
	)

	Wiring.Connect(
		notQB,
		orQ
	)

	return{
		Q=notQ,
		QB=notQB,

		DataTargets={
			notD,
			setGate
		},

		EnableTargets={
			setGate,
			resetGate
		}
	}

end

Components.DLatch=DLatch.Build
Context.Modules.DLatch=DLatch

return DLatch
