local Context = getgenv().BABFT_CALCULATOR

local Builder = Context.Modules.Builder
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring
local Config = Context.Config

local DisplayDriver = {}

local FONT = {
	[0] = {
		"11111",
		"10001",
		"10001",
		"10001",
		"10001",
		"10001",
		"11111"
	},

	[1] = {
		"00100",
		"01100",
		"00100",
		"00100",
		"00100",
		"00100",
		"01110"
	},

	[2] = {
		"11111",
		"00001",
		"00001",
		"11111",
		"10000",
		"10000",
		"11111"
	},

	[3] = {
		"11111",
		"00001",
		"00001",
		"11111",
		"00001",
		"00001",
		"11111"
	},

	[4] = {
		"10001",
		"10001",
		"10001",
		"11111",
		"00001",
		"00001",
		"00001"
	},

	[5] = {
		"11111",
		"10000",
		"10000",
		"11111",
		"00001",
		"00001",
		"11111"
	},

	[6] = {
		"11111",
		"10000",
		"10000",
		"11111",
		"10001",
		"10001",
		"11111"
	},

	[7] = {
		"11111",
		"00001",
		"00010",
		"00100",
		"01000",
		"01000",
		"01000"
	},

	[8] = {
		"11111",
		"10001",
		"10001",
		"11111",
		"10001",
		"10001",
		"11111"
	},

	[9] = {
		"11111",
		"10001",
		"10001",
		"11111",
		"00001",
		"00001",
		"11111"
	}
}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

local function buildDigitDecoder(
	name,
	origin,
	inputBus
)
	local inverted = {}
	local values = {}

	for bit = 0, 3 do
		inverted[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			P(origin, bit * 6, 0, 0)
		)

		Wiring.Connect(
			inputBus[bit],
			inverted[bit]
		)
	end

	for value = 0, 9 do
		local detector = Gates.And(
			name .. "_VALUE_" .. value,
			P(
				origin,
				value * 6,
				0,
				10
			)
		)

		for bit = 0, 3 do
			local enabled =
				math.floor(value / (2 ^ bit)) % 2 == 1

			Wiring.Connect(
				enabled
					and inputBus[bit]
					or inverted[bit],
				detector
			)
		end

		values[value] = detector
	end

	return {
		Values = values,
		Inverted = inverted
	}
end

function DisplayDriver.Build(
	name,
	origin,
	digitCount
)
	digitCount = digitCount or 5

	local result = {
		Digits = {},
		Decoders = {},
		Pixels = {}
	}

	local function connectDigit(
		digitIndex,
		inputBus
	)
		assert(
			type(inputBus) == "table",
			"BCD 입력 버스가 필요합니다."
		)

		for bit = 0, 3 do
			assert(
				inputBus[bit],
				"BCD 비트 누락: " .. bit
			)
		end

		local digitOrigin = P(
			origin,
			(digitIndex - 1) * 90,
			0,
			0
		)

		local decoder = buildDigitDecoder(
			name .. "_DIGIT_" .. digitIndex,
			P(digitOrigin, 0, 0, -32),
			inputBus
		)

		result.Decoders[digitIndex] = decoder
		result.Pixels[digitIndex] = {}

		for row = 1, 7 do
			result.Pixels[digitIndex][row] = {}

			for column = 1, 5 do
				local pixelName = string.format(
					"%s_D%d_R%d_C%d",
					name,
					digitIndex,
					row,
					column
				)

				local display = Builder.PlaceNamedBlock(
					pixelName,
					"DisplayBlock",
					P(
						digitOrigin,
						column * 4,
						(8 - row) * 4,
						0
					)
				)

				local whiteOutput = Gates.Or(
					pixelName .. "_WHITE",
					P(
						digitOrigin,
						column * 4,
						(8 - row) * 4,
						-12
					)
				)

				local blackOutput = Gates.Not(
					pixelName .. "_BLACK",
					P(
						digitOrigin,
						column * 4,
						(8 - row) * 4,
						-20
					)
				)

				Context:QueuePaint({
					Object = whiteOutput,
					Color = Config.Colors.White
				})

				Context:QueuePaint({
					Object = blackOutput,
					Color = Config.Colors.Black
				})

				for value = 0, 9 do
					if FONT[value][row]:sub(
						column,
						column
					) == "1" then
						Wiring.Connect(
							decoder.Values[value],
							whiteOutput
						)
					end
				end

				Wiring.Connect(
					whiteOutput,
					blackOutput
				)

				Wiring.Connect(
					whiteOutput,
					display
				)

				Wiring.Connect(
					blackOutput,
					display
				)

				result.Pixels[digitIndex][row][column] = {
					Display = display,
					White = whiteOutput,
					Black = blackOutput
				}
			end
		end
	end

	result.ConnectDigit = connectDigit

	return result
end

Context.Modules.DisplayDriver = DisplayDriver

return DisplayDriver
