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

local function L(origin, index, depth)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		depth or 0
	)
end

local function getPixelIndex(row, column)
	return (row - 1) * 5 + (column - 1)
end

local function buildDecoder(
	name,
	logicOrigin,
	inputBus
)
	local inverted = {}
	local values = {}

	for bit = 0, 3 do
		inverted[bit] = Gates.Not(
			name .. "_NOT_" .. bit,
			L(
				logicOrigin,
				bit
			)
		)

		Wiring.Connect(
			inputBus[bit],
			inverted[bit]
		)
	end

	for value = 0, 9 do
		local detector = Gates.And(
			name .. "_VALUE_" .. value,
			L(
				logicOrigin,
				4 + value
			)
		)

		for bit = 0, 3 do
			local enabled =
				math.floor(
					value / (2 ^ bit)
				) % 2 == 1

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
		Inverted = inverted,
		Values = values
	}
end

function DisplayDriver.Build(
	name,
	origin,
	digitCount
)
	local self = {}

	digitCount = digitCount or 5

	local displayConfig =
		Config.Display or {}

	local pixelSpacing =
		displayConfig.PixelSpacing or 3

	local digitSpacing =
		displayConfig.DigitSpacing or 19

	self.Digits = {}
	self.Decoders = {}
	self.Pixels = {}

	function self.ConnectDigit(
		digitIndex,
		inputBus
	)
		assert(
			digitIndex >= 1
				and digitIndex <= digitCount,
			"잘못된 자릿수: "
				.. tostring(digitIndex)
		)

		assert(
			type(inputBus) == "table",
			"4비트 BCD 입력 버스가 필요합니다."
		)

		for bit = 0, 3 do
			assert(
				inputBus[bit],
				"BCD 입력 비트 누락: "
					.. tostring(bit)
			)
		end

		local digitOrigin = P(
			origin,
			(digitIndex - 1)
				* digitSpacing,
			0,
			0
		)

		local logicOrigin = P(
			digitOrigin,
			0,
			0,
			-8
		)

		local decoder = buildDecoder(
			name
				.. "_DIGIT_"
				.. digitIndex,
			logicOrigin,
			inputBus
		)

		self.Decoders[digitIndex] =
			decoder

		self.Digits[digitIndex] = {}
		self.Pixels[digitIndex] = {}

		for row = 1, 7 do
			self.Pixels[digitIndex][row] =
				{}

			for column = 1, 5 do
				local pixelName =
					string.format(
						"%s_D%d_R%d_C%d",
						name,
						digitIndex,
						row,
						column
					)

				local pixelIndex =
					getPixelIndex(
						row,
						column
					)

				local pixelX =
					(column - 1)
					* pixelSpacing

				local pixelY =
					(7 - row)
					* pixelSpacing

				local display =
					Builder.PlaceNamedBlock(
						pixelName,
						"DisplayBlock",
						P(
							digitOrigin,
							pixelX,
							pixelY,
							0
						)
					)

				local whiteOutput =
					Gates.Or(
						pixelName
							.. "_WHITE",
						L(
							logicOrigin,
							14
								+ pixelIndex
									* 2
						)
					)

				local blackOutput =
					Gates.Not(
						pixelName
							.. "_BLACK",
						L(
							logicOrigin,
							15
								+ pixelIndex
									* 2
						)
					)

				for value = 0, 9 do
					local enabled =
						FONT[value][row]:sub(
							column,
							column
						) == "1"

					if enabled then
						Wiring.Connect(
							decoder.Values[
								value
							],
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

				Context:QueuePaint({
					Object = whiteOutput,
					Color =
						Config.Colors.White
				})

				Context:QueuePaint({
					Object = blackOutput,
					Color =
						Config.Colors.Black
				})

				self.Digits[digitIndex][
					#self.Digits[
						digitIndex
					] + 1
				] = display

				self.Pixels[
					digitIndex
				][row][column] = {
					Display = display,
					White = whiteOutput,
					Black = blackOutput
				}
			end
		end
	end

	return self
end

Context.Modules.DisplayDriver =
	DisplayDriver

return DisplayDriver
