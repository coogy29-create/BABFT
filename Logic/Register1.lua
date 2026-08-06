local Context = getgenv().BABFT_CALCULATOR

local DLatch = Context.Modules.DLatch

local Register1 = {}

function Register1.Build(name, origin)
	local latch = DLatch.Build(
		name .. "_LATCH",
		origin
	)

	local function connectData(source)
		latch.ConnectData(source)
	end

	local function connectClock(source)
		latch.ConnectEnable(source)
	end

	return {
		Q = latch.Q,
		QB = latch.QB,
		Latch = latch,
		ConnectData = connectData,
		ConnectClock = connectClock
	}
end

Context.Modules.Register1 = Register1

return Register1
