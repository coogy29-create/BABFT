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
	local notData = Gates.Not(
		name .. "_NOT_DATA",
		P(origin, 0, 0, 12)
	)

	local setGate = Gates.And(
		name .. "_SET",
		P(origin, 14, 0, 0)
	)

	local resetGate = Gates.And(
		name .. "_RESET",
		P(origin, 14, 0, 16)
	)

	local qOr = Gates.Or(
		name .. "_Q_OR",
		P(origin, 30, 0, 0)
	)

	local q = Gates.Not(
		name .. "_Q",
		P(origin, 44, 0, 0)
	)

	local qbOr = Gates.Or(
		name .. "_QB_OR",
		P(origin, 30, 0, 16)
	)

	local qb = Gates.Not(
		name .. "_QB",
		P(origin, 44, 0, 16)
	)

	Wiring.Connect(
		notData,
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
		q
	)

	Wiring.Connect(
		qbOr,
		qb
	)

	Wiring.Connect(
		q,
		qbOr
	)

	Wiring.Connect(
		qb,
		qOr
	)

	local self = {}

	function self.ConnectData(source)
		Wiring.Connect(
			source,
			notData
		)

		Wiring.Connect(
			source,
			setGate
		)
	end

	function self.ConnectEnable(source)
		Wiring.Connect(
			source,
			setGate
		)

		Wiring.Connect(
			source,
			resetGate
		)
	end

	self.Q = q
	self.QB = qb
	self.Set = setGate
	self.Reset = resetGate
	self.NotData = notData

	return self
end

Context.Modules.DLatch = DLatch

return DLatch
