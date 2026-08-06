local Context = getgenv().BABFT_CALCULATOR

local Layout = {}

function Layout.Offset(origin, x, y, z)
	assert(
		typeof(origin) == "CFrame",
		"origin은 CFrame이어야 합니다."
	)

	return origin * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)
end

function Layout.Line(
	origin,
	count,
	spacing,
	direction
)
	local positions = {}

	direction = direction or Vector3.new(1, 0, 0)
	spacing = spacing or 4

	local offset = direction.Unit * spacing

	for index = 0, count - 1 do
		positions[index] =
			origin * CFrame.new(offset * index)
	end

	return positions
end

function Layout.Grid(
	origin,
	columns,
	rows,
	columnSpacing,
	rowSpacing,
	columnDirection,
	rowDirection
)
	local positions = {}

	columnSpacing = columnSpacing or 4
	rowSpacing = rowSpacing or 4

	columnDirection =
		columnDirection
		or Vector3.new(1, 0, 0)

	rowDirection =
		rowDirection
		or Vector3.new(0, 0, 1)

	local columnOffset =
		columnDirection.Unit * columnSpacing

	local rowOffset =
		rowDirection.Unit * rowSpacing

	for row = 0, rows - 1 do
		positions[row] = {}

		for column = 0, columns - 1 do
			local offset =
				columnOffset * column
				+ rowOffset * row

			positions[row][column] =
				origin * CFrame.new(offset)
		end
	end

	return positions
end

function Layout.Stack(
	origin,
	count,
	spacing
)
	return Layout.Line(
		origin,
		count,
		spacing or 4,
		Vector3.new(0, 1, 0)
	)
end

function Layout.Bus(
	origin,
	bitCount,
	spacing,
	direction
)
	local positions = {}

	local line = Layout.Line(
		origin,
		bitCount,
		spacing or 4,
		direction or Vector3.new(0, 0, 1)
	)

	for bit = 0, bitCount - 1 do
		positions[bit] = line[bit]
	end

	return positions
end

function Layout.Block(
	origin,
	width,
	height,
	depth,
	spacing
)
	local positions = {}

	spacing = spacing or 4

	for y = 0, height - 1 do
		positions[y] = {}

		for z = 0, depth - 1 do
			positions[y][z] = {}

			for x = 0, width - 1 do
				positions[y][z][x] =
					origin
					* CFrame.new(
						x * spacing,
						y * spacing,
						z * spacing
					)
			end
		end
	end

	return positions
end

function Layout.CenteredLine(
	origin,
	count,
	spacing,
	direction
)
	local positions = {}

	spacing = spacing or 4
	direction =
		direction
		or Vector3.new(1, 0, 0)

	local totalLength =
		(count - 1) * spacing

	local start =
		-totalLength / 2

	for index = 0, count - 1 do
		local distance =
			start + index * spacing

		positions[index] =
			origin
			* CFrame.new(
				direction.Unit * distance
			)
	end

	return positions
end

function Layout.Rotate(
	cframe,
	xDegrees,
	yDegrees,
	zDegrees
)
	return cframe
		* CFrame.Angles(
			math.rad(xDegrees or 0),
			math.rad(yDegrees or 0),
			math.rad(zDegrees or 0)
		)
end

Context.Modules.Layout = Layout

return Layout
