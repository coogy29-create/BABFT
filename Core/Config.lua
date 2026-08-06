local Context = getgenv().BABFT_CALCULATOR

local Config = {}

Config.Tools = {
	BuildingTool = "BuildingTool",
	BindTool = "BindTool",
	PropertiesTool = "PropertiesTool",
	PaintTool = "PaintTool"
}

Config.BlockNames = {
	Gate = "Gate",
	Button = "Button",
	Switch = "Switch",
	DisplayBlock = "DisplayBlock"
}

Config.Inventory = {
	Gate = 3156,
	Button = 94,
	Switch = 100,
	DisplayBlock = 4100
}

Config.GateTypes = {
	And = "And",
	Or = "Or",
	Xor = "Xor",
	Not = "Not"
}

Config.PlaceDelay = 0.05
Config.BindDelay = 0.03
Config.PropertyDelay = 0.03
Config.PaintDelay = 0.02

Config.InstallTimeout = 5
Config.ActionTimeout = 5

Config.ZoneOffset = Vector3.zero

Config.AutoUnbind = true
Config.AutoPaint = true
Config.AutoProperty = true

Config.DefaultColor = Color3.new(1, 1, 1)

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
	OutputMode = "Decimal"
}

Context.Config = Config

return Config
