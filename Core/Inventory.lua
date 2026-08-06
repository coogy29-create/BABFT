local Context = getgenv().BABFT_CALCULATOR

local Config = Context.Config

local Inventory = {}

function Inventory.Get(blockType)
	local value = Config.Inventory[blockType]

	assert(
		type(value) == "number",
		"보유량 값이 없습니다: " .. tostring(blockType)
	)

	assert(
		value > 0,
		"보유량이 0 이하입니다: " .. tostring(blockType)
	)

	return value
end

function Inventory.Set(blockType, value)
	assert(
		type(blockType) == "string",
		"blockType은 문자열이어야 합니다."
	)

	assert(
		type(value) == "number" and value > 0,
		"보유량은 0보다 큰 숫자여야 합니다."
	)

	Config.Inventory[blockType] = value

	return value
end

function Inventory.Has(blockType)
	local value = Config.Inventory[blockType]

	return type(value) == "number"
		and value > 0
end

function Inventory.GetAll()
	local result = {}

	for blockType, value in pairs(
		Config.Inventory
	) do
		result[blockType] = value
	end

	return result
end

function Inventory.Update(values)
	assert(
		type(values) == "table",
		"values는 테이블이어야 합니다."
	)

	for blockType, value in pairs(values) do
		Inventory.Set(blockType, value)
	end
end

function Inventory.Validate(requiredTypes)
	local missing = {}

	for _, blockType in ipairs(requiredTypes) do
		if not Inventory.Has(blockType) then
			table.insert(
				missing,
				blockType
			)
		end
	end

	if #missing > 0 then
		return false,
			"보유량 설정 누락: "
			.. table.concat(missing, ", ")
	end

	return true
end

Context.Modules.Inventory = Inventory

return Inventory
