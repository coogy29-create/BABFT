local Context = getgenv().BABFT_CALCULATOR

local Builder = Context.Modules.Builder
local Paint = Context.Modules.Paint

local Gates = {}

local function register(name, object)
	Context:RegisterObject(name, object)
	return object
end

function Gates.Create(name, gateType, cframe)

	local gate = Builder.PlaceNamedBlock(
		name,
		"Gate",
		cframe
	)

	Context:QueueProperty({
		Type = gateType,
		Gate = gate
	})

	return gate

end

function Gates.And(name, cframe)

	return Gates.Create(
		name,
		"And",
		cframe
	)

end

function Gates.Or(name, cframe)

	return Gates.Create(
		name,
		"Or",
		cframe
	)

end

function Gates.Xor(name, cframe)

	return Gates.Create(
		name,
		"Xor",
		cframe
	)

end

function Gates.Not(name, cframe)

	return Gates.Create(
		name,
		"Not",
		cframe
	)

end

function Gates.White(name, cframe)

	local gate = Gates.And(
		name,
		cframe
	)

	Paint.PaintWhite(gate)

	return gate

end

function Gates.Black(name, cframe)

	local gate = Gates.And(
		name,
		cframe
	)

	Paint.PaintBlack(gate)

	return gate

end

function Gates.Line(startPos, direction, count, spacing)

	local result = {}

	local offset = direction.Unit * spacing

	for i = 1, count do

		table.insert(
			result,
			startPos + offset * (i - 1)
		)

	end

	return result

end

function Gates.Grid(origin, right, forward, width, height, spacing)

	local result = {}

	local rightOffset = right.Unit * spacing
	local forwardOffset = forward.Unit * spacing

	for y = 0, height - 1 do

		for x = 0, width - 1 do

			table.insert(
				result,
				origin
				+ rightOffset * x
				+ forwardOffset * y
			)

		end

	end

	return result

end

Context.Modules.Gates = Gates

return Gates
