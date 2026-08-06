local Context = getgenv().BABFT_CALCULATOR

local Config = {}

Config.Version = "0.1.0"

Config.Inventory = {
	Gate = 3156,
	Switch = 100,
	DisplayBlock = 4100,
	Delay = 551,
	Button = 94
}

Config.ZoneOffset = Vector3.new(
	53.565689086914,
	18,
	345.50686645508
)

Config.PlaceDelay = 0.03
Config.BindDelay = 0.03
Config.PropertyDelay = 0.03
Config.PaintDelay = 0.03

Config.InstallTimeout = 7

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

Config.Tools = {
	BuildingTool = "BuildingTool",
	PropertiesTool = "PropertiesTool",
	BindTool = "BindTool",
	PaintingTool = "PaintingTool"
}

Config.BlockNames = {
	Gate = "Gate",
	Switch = "Switch",
	Button = "Button",
	DisplayBlock = "DisplayBlock",
	Delay = "Delay"
}

Config.GateTypes = {
	And = "And",
	Or = "Or",
	Xor = "Xor",
	Not = "Not"
}

Config.Debug = true

Context.Config = Config

return Config
