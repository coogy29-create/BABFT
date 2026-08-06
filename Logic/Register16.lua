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
	local cells = {}
	local outputBus = {}
	local invertedBus = {}

	for bit = 0, 15 do
		local column = bit % 4
		local row = math.floor(bit / 4)

		local cell = Register1.Build(
			name .. "_BIT_" .. bit,
			P(
				origin,
				column * 54,
				0,
				row * 24
			)
		)

		cells[bit] = cell
		outputBus[bit] = cell.Q
		invertedBus[bit] = cell.QB
	end

	local function connectData(inputBus)
		assert(
			type(inputBus) == "table",
			"입력 버스가 필요합니다."
		)

		for bit = 0, 15 do
			assert(
				inputBus[bit],
				"입력 버스 비트 누락: " .. bit
			)

			cells[bit].ConnectData(
				inputBus[bit]
			)
		end
	end

	local function connectClock(source)
		assert(
			source,
			"클럭 입력이 필요합니다."
		)

		for bit = 0, 15 do
			cells[bit].ConnectClock(source)
		end
	end

	return {
		Cells = cells,
		Q = outputBus,
		QB = invertedBus,
		ConnectData = connectData,
		ConnectClock = connectClock
	}
end

Context.Modules.Register16 = Register16

return Register16
