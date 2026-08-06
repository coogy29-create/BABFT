
local Context = getgenv().BABFT_CALCULATOR

local Config = {}

Config.Tools = {
	BuildingTool = "BuildingTool",
	BindTool = "BindTool",
	PropertiesTool = "PropertiesTool",
	PaintingTool = "PaintingTool"
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
	GridSpacing = 4,
	BusSpacing = 4,
	GateSpacing = 6,
	RegisterSpacing = 28,
	ModuleSpacing = 64
}

Config.Display = {
	Digits = 5,
	Width = 5,
	Height = 7
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
