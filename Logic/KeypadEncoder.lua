local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config
local Builder = Context.Modules.Builder
local Binder = Context.Modules.Bind
local Gates = Context.Modules.Gates
local Wiring = Context.Modules.Wiring

local KeypadEncoder = {}

local function P(origin, x, y, z)
	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

local function L(origin, index)
	return Config.Layout.GetLayeredCFrame(
		origin,
		index,
		0
	)
end

function KeypadEncoder.Build(name, origin)
	local self = {}

	self.Buttons = {}
	self.DigitBus = {}

	local buttonSpacing = 3

	local positions = {
		[1] = {0, 0, buttonSpacing * 3},
		[2] = {buttonSpacing, 0, buttonSpacing * 3},
		[3] = {buttonSpacing * 2, 0, buttonSpacing * 3},

		[4] = {0, 0, buttonSpacing * 2},
		[5] = {buttonSpacing, 0, buttonSpacing * 2},
		[6] = {buttonSpacing * 2, 0, buttonSpacing * 2},

		[7] = {0, 0, buttonSpacing},
		[8] = {buttonSpacing, 0, buttonSpacing},
		[9] = {buttonSpacing * 2, 0, buttonSpacing},

		[0] = {buttonSpacing, 0, 0}
	}

	for digit = 0, 9 do
		local position = positions[digit]

		local button = Builder.PlaceNamedBlock(
			name .. "_BUTTON_" .. digit,
			"Button",
			P(
				origin,
				position[1],
				position[2],
				position[3]
			)
		)

		self.Buttons[digit] = button

		Binder.AutoUnbindNearest(button)
	end

	local logicOrigin = P(
		origin,
		buttonSpacing * 3,
		0,
		0
	)

	for bit = 0, 3 do
		self.DigitBus[bit] = Gates.Or(
			name .. "_DIGIT_BIT_" .. bit,
			L(
				logicOrigin,
				bit
			)
		)
	end

	self.Pulse = Gates.Or(
		name .. "_PRESSED_PULSE",
		L(
			logicOrigin,
			4
		)
	)

	local bitMap = {
		[0] = {
			1,
			3,
			5,
			7,
			9
		},

		[1] = {
			2,
			3,
			6,
			7
		},

		[2] = {
			4,
			5,
			6,
			7
		},

		[3] = {
			8,
			9
		}
	}

	for bit = 0, 3 do
		for _, digit in ipairs(
			bitMap[bit]
		) do
			Wiring.Connect(
				self.Buttons[digit],
				self.DigitBus[bit]
			)
		end
	end

	for digit = 0, 9 do
		Wiring.Connect(
			self.Buttons[digit],
			self.Pulse
		)
	end

	return self
end

Context.Modules.KeypadEncoder =
	KeypadEncoder

return KeypadEncoder
