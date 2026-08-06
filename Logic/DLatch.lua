local Context = getgenv().BABFT_CALCULATOR

local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local DLatch = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DLatch.Build(name, origin)
	local notD = Gates.Not(
		name .. "_NOT_D",
		P(origin, 0, 0, 8)
	)

	local setGate = Gates.And(
		name .. "_SET",
		P(origin, 12, 0, 0)
	)

	local resetGate = Gates.And(
		name .. "_RESET",
		P(origin, 12, 0, 12)
	)

	local qOr = Gates.Or(
		name .. "_Q_OR",
		P(origin, 28, 0, 0)
	)

	local qNot = Gates.Not(
		name .. "_Q",
		P(origin, 40, 0, 0)
	)

	local qbOr = Gates.Or(
		name .. "_QB_OR",
		P(origin, 28, 0, 12)
	)

	local qbNot = Gates.Not(
		name .. "_QB",
		P(origin, 40, 0, 12)
	)

	Wiring.Connect(
		notD,
		resetGate
	)

	Wiring.Connect(
		resetGate,
		qOr
	)

	Wiring.Connect(
		setGate,
		qbOr
	)

	Wiring.Connect(
		qOr,
		qNot
	)

	Wiring.Connect(
		qbOr,
		qbNot
	)

	Wiring.Connect(
		qNot,
		qbOr
	)

	Wiring.Connect(
		qbNot,
		qOr
	)

	local function connectData(source)
		Wiring.Connect(
			source,
			notD
		)

		Wiring.Connect(
			source,
			setGate
		)
	end

	local function connectEnable(source)
		Wiring.Connect(
			source,
			setGate
		)

		Wiring.Connect(
			source,
			resetGate
		)
	end

	return {
		Q = qNot,
		QB = qbNot,
		Set = setGate,
		Reset = resetGate,
		ConnectData = connectData,
		ConnectEnable = connectEnable
	}
end

Context.Modules.DLatch = DLatch

return DLatch
