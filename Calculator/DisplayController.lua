local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local BinaryToBCD = Context.Modules.BinaryToBCD
local DisplayDriver = Context.Modules.DisplayDriver

local DisplayController = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function DisplayController.Build(
	name,
	origin,
	binaryBus,
	clock
)
	local self = {}

	self.Converter = BinaryToBCD.Build(
		name .. "_BCD",
		origin
	)

	local converterColumns =
		math.ceil(
			(
				32
				+ 16 * 90
			)
			/ Config.Layout.LayerCount
		)

	local converterWidth =
		converterColumns
		* Config.Layout.GateSpacing

	local displayOffset =
		converterWidth + 8

	self.Display = DisplayDriver.Build(
		name .. "_DISPLAY",
		P(
			origin,
			displayOffset,
			0,
			0
		),
		5
	)

	self.Converter.ConnectBinaryBus(
		binaryBus
	)

	for digit = 0, 4 do
		self.Display.ConnectDigit(
			digit + 1,
			self.Converter.Digits[digit]
		)
	end

	self.Clock = clock

	return self
end

Context.Modules.DisplayController =
	DisplayController

return DisplayController
