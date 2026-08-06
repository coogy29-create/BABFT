local Context = getgenv().BABFT_CALCULATOR

local Config = {}

Config.Tools = {
	BuildingTool = "BuildingTool",
	BindTool = "BindTool",
	PropertiesTool = "PropertiesTool",
	PaintingTool = "PaintingTool",
	PaintTool = "PaintingTool"
}

Config.BlockNames = {
	Gate = "Gate",
	Button = "Button",
	Switch = "Switch",
	DisplayBlock = "DisplayBlock",
	Delay = "Delay"
}

Config.Inventory = {
	Gate = 3156,
	Button = 94,
	Switch = 100,
	DisplayBlock = 4100,
	Delay = 551
}

Config.GateTypes = {
	And = "And",
	Or = "Or",
	Xor = "Xor",
	Not = "Not"
}

Config.Colors = {
	White = Color3.new(
		0.97254902124405,
		0.97254902124405,
		0.97254902124405
	),

	Black = Color3.new(
		0.066666670143604,
		0.066666670143604,
		0.066666670143604
	)
}

Config.PlaceDelay = 0.05
Config.BindDelay = 0.03
Config.PropertyDelay = 0.03
Config.PaintDelay = 0.02

Config.InstallTimeout = 7
Config.ActionTimeout = 7

Config.ZoneOffset = Vector3.new(
	53.565689086914,
	18,
	345.50686645508
)

Config.AutoUnbind = true
Config.AutoPaint = true
Config.AutoProperty = true

Config.Layout = {
	GridSpacing = 2,
	BusSpacing = 2,
	GateSpacing = 2.5,
	RegisterSpacing = 10,
	ModuleSpacing = 18,

	Compact = true,

	HorizontalScale = 0.22,
	DepthScale = 0.22,

	LayerHeight = 3.2,
	LayerCount = 100
}

function Config.Layout.GetLayeredOffset(index)
	index = math.max(
		0,
		math.floor(index or 0)
	)

	local layer =
		index % Config.Layout.LayerCount

	local slot =
		math.floor(
			index / Config.Layout.LayerCount
		)

	return Vector3.new(
		slot * Config.Layout.GateSpacing,
		layer * Config.Layout.LayerHeight,
		0
	)
end

function Config.Layout.GetLayeredCFrame(
	origin,
	index,
	depth
)
	assert(
		typeof(origin) == "CFrame",
		"origin은 CFrame이어야 합니다."
	)

	local offset =
		Config.Layout.GetLayeredOffset(index)

	return origin * CFrame.new(
		offset.X,
		offset.Y,
		depth or 0
	)
end

function Config.Layout.ScaleOffset(
	x,
	y,
	z
)
	return Vector3.new(
		(x or 0)
			* Config.Layout.HorizontalScale,

		y or 0,

		(z or 0)
			* Config.Layout.DepthScale
	)
end

function Config.Layout.ScaleCFrame(
	origin,
	x,
	y,
	z
)
	assert(
		typeof(origin) == "CFrame",
		"origin은 CFrame이어야 합니다."
	)

	local offset =
		Config.Layout.ScaleOffset(
			x,
			y,
			z
		)

	return origin * CFrame.new(offset)
end

Config.Display = {
	Digits = 5,
	Width = 5,
	Height = 7,
	PixelSpacing = 2,
	DigitSpacing = 14
}

Config.Calculator = {
	BitWidth = 16,
	InputMode = "Decimal",
	OutputMode = "Decimal",
	MinimumValue = 0,
	MaximumValue = 65535
}

Context.Config = Config

return Config
