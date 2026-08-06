local Context = getgenv().BABFT_CALCULATOR

local DLatch = Context.Modules.DLatch

local Register1 = {}

function Register1.Build(name, origin)
	local latch = DLatch.Build(
		name .. "_LATCH",
		origin
	)

	local self = {}

	function self.ConnectData(source)
		assert(
			source,
			"데이터 입력이 필요합니다."
		)

		latch.ConnectData(source)
	end

	function self.ConnectClock(source)
		assert(
			source,
			"클럭 입력이 필요합니다."
		)

		latch.ConnectEnable(source)
	end

	self.Q = latch.Q
	self.QB = latch.QB
	self.Latch = latch

	return self
end

Context.Modules.Register1 = Register1

return Register1
