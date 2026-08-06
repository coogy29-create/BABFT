local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local DLatch = {}

local function L(origin, index, depth)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		depth or 0
	)
end

function DLatch.Build(name, origin)
	local notData = Gates.Not(
		name .. "_NOT_DATA",
		L(origin, 0)
	)

	local setGate = Gates.And(
		name .. "_SET",
		L(origin, 1)
	)

	local resetGate = Gates.And(
		name .. "_RESET",
		L(origin, 2)
	)

	local qOr = Gates.Or(
		name .. "_Q_OR",
		L(origin, 3)
	)

	local q = Gates.Not(
		name .. "_Q",
		L(origin, 4)
	)

	local qbOr = Gates.Or(
		name .. "_QB_OR",
		L(origin, 5)
	)

	local qb = Gates.Not(
		name .. "_QB",
		L(origin, 6)
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
