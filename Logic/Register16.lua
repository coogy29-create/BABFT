local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Register1 = Context.Modules.Register1

local Register16 = {}

function Register16.Build(name, origin)
	local self = {}

	self.Cells = {}
	self.Q = {}
	self.QB = {}

	local layersPerCell = 7

	local cellsPerColumn = math.max(
		1,
		math.floor(
			Config.Layout.LayerCount
				/ layersPerCell
		)
	)

	for bit = 0, 15 do
		local column =
			math.floor(
				bit / cellsPerColumn
			)

		local cellInColumn =
			bit % cellsPerColumn

		local startLayer =
			cellInColumn * layersPerCell

		local cellOrigin =
			origin
			* CFrame.new(
				column
					* Config.Layout.GateSpacing,
				startLayer
					* Config.Layout.LayerHeight,
				0
			)

		local cell = Register1.Build(
			name .. "_BIT_" .. bit,
			cellOrigin
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
				"데이터 비트 누락: "
					.. tostring(bit)
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
			self.Cells[bit].ConnectClock(
				source
			)
		end
	end

	return self
end

Context.Modules.Register16 = Register16

return Register16
