local Context = getgenv().BABFT_CALCULATOR

local Register1 = Context.Modules.Register1

local Register16 = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function Register16.Build(name, origin)
	local self = {}

	self.Cells = {}
	self.Q = {}
	self.QB = {}

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		local cell = Register1.Build(
			name .. "_BIT_" .. bit,
			P(
				origin,
				column * 56,
				0,
				row * 28
			)
		)

		self.Cells[bit] = cell
		self.Q[bit] = cell.Q
		self.QB[bit] = cell.QB
	end

	function self.ConnectData(inputBus)
		assert(
			type(inputBus) == "table",
			"16비트 데이터 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				inputBus[bit],
				"데이터 비트 누락: " .. bit
			)

			self.Cells[bit].ConnectData(
				inputBus[bit]
			)
		end
	end

	function self.ConnectClock(source)
		assert(
			source,
			"클럭 입력이 필요합니다."
		)

		for bit = 0, 15 do
			self.Cells[bit].ConnectClock(source)
		end
	end

	return self
end

Context.Modules.Register16 = Register16

return Register16
