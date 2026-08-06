local Workspace = game:GetService("Workspace")

local Context = getgenv().BABFT_CALCULATOR
local Config = Context.Config

local WhiteZone = {}

function WhiteZone.Get()
	local zone = Workspace:FindFirstChild("WhiteZone")

	assert(
		zone,
		"WhiteZone을 찾을 수 없습니다."
	)

	return zone
end

function WhiteZone.WorldToZone(worldCFrame)

	assert(
		typeof(worldCFrame) == "CFrame",
		"worldCFrame은 CFrame이어야 합니다."
	)

	return CFrame.new(
		worldCFrame.Position + Config.ZoneOffset
	) * worldCFrame.Rotation

end

function WhiteZone.ZoneToWorld(zoneCFrame)

	assert(
		typeof(zoneCFrame) == "CFrame",
		"zoneCFrame은 CFrame이어야 합니다."
	)

	return CFrame.new(
		zoneCFrame.Position - Config.ZoneOffset
	) * zoneCFrame.Rotation

end

function WhiteZone.Offset(cframe,x,y,z)

	return cframe * CFrame.new(
		x or 0,
		y or 0,
		z or 0
	)

end

function WhiteZone.Move(cframe,offset)

	return cframe * CFrame.new(offset)

end

function WhiteZone.Rotate(cframe,x,y,z)

	return cframe * CFrame.Angles(
		math.rad(x or 0),
		math.rad(y or 0),
		math.rad(z or 0)
	)

end

Context.Modules.WhiteZone = WhiteZone

return WhiteZone
