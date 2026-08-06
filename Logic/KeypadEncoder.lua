local Context = getgenv().BABFT_CALCULATOR

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

function KeypadEncoder.Build(name, origin)
	local buttons = {}
	local digitBus = {}

	local positions = {
		[1] = {0, 12},
		[2] = {6, 12},
		[3] = {12, 12},

		[4] = {0, 8},
		[5] = {6, 8},
		[6] = {12, 8},

		[7] = {0, 4},
		[8] = {6, 4},
		[9] = {12, 4},

		[0] = {6, 0}
	}

	for digit = 0, 9 do
		local position = positions[digit]

		local button = Builder.PlaceNamedBlock(
			name .. "_BUTTON_" .. digit,
			"Button",
			P(
				origin,
				position[1],
				0,
				position[2]
			)
		)

		buttons[digit] = button

		Binder.AutoUnbindNearest(button)
	end

	for bit = 0, 3 do
		digitBus[bit] = Gates.Or(
			name .. "_BIT_" .. bit,
			P(
				origin,
				24,
				0,
				bit * 6
			)
		)
	end

	local bitDigits = {
		[0] = {1, 3, 5, 7, 9},
		[1] = {2, 3, 6, 7},
		[2] = {4, 5, 6, 7},
		[3] = {8, 9}
	}

	for bit = 0, 3 do
		for _, digit in ipairs(bitDigits[bit]) do
			Wiring.Connect(
				buttons[digit],
				digitBus[bit]
			)
		end
	end

	local pulse = Gates.Or(
		name .. "_DIGIT_PULSE",
		P(origin, 32, 0, 10)
	)

	for digit = 0, 9 do
		Wiring.Connect(
			buttons[digit],
			pulse
		)
	end

	return {
		Buttons = buttons,
		DigitBus = digitBus,
		Pulse = pulse
	}
end

Context.Modules.KeypadEncoder = KeypadEncoder

return KeypadEncoder
