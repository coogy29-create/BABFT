local Context=getgenv().BABFT_CALCULATOR

local Font5x7={}

Font5x7.Patterns={
	[0]={
		"11111",
		"10001",
		"10001",
		"10001",
		"10001",
		"10001",
		"11111"
	},

	[1]={
		"00100",
		"01100",
		"00100",
		"00100",
		"00100",
		"00100",
		"01110"
	},

	[2]={
		"11111",
		"00001",
		"00001",
		"11111",
		"10000",
		"10000",
		"11111"
	},

	[3]={
		"11111",
		"00001",
		"00001",
		"11111",
		"00001",
		"00001",
		"11111"
	},

	[4]={
		"10001",
		"10001",
		"10001",
		"11111",
		"00001",
		"00001",
		"00001"
	},

	[5]={
		"11111",
		"10000",
		"10000",
		"11111",
		"00001",
		"00001",
		"11111"
	},

	[6]={
		"11111",
		"10000",
		"10000",
		"11111",
		"10001",
		"10001",
		"11111"
	},

	[7]={
		"11111",
		"00001",
		"00010",
		"00100",
		"01000",
		"01000",
		"01000"
	},

	[8]={
		"11111",
		"10001",
		"10001",
		"11111",
		"10001",
		"10001",
		"11111"
	},

	[9]={
		"11111",
		"10001",
		"10001",
		"11111",
		"00001",
		"00001",
		"11111"
	},

	Minus={
		"00000",
		"00000",
		"00000",
		"11111",
		"00000",
		"00000",
		"00000"
	},

	Blank={
		"00000",
		"00000",
		"00000",
		"00000",
		"00000",
		"00000",
		"00000"
	}
}

function Font5x7.Get(character)

	if character=="-" then
		return Font5x7.Patterns.Minus
	end

	if character==" " then
		return Font5x7.Patterns.Blank
	end

	local number=tonumber(character)

	if number~=nil then
		return Font5x7.Patterns[number]
	end

	return Font5x7.Patterns.Blank
end

function Font5x7.GetPixel(character,row,column)

	local pattern=Font5x7.Get(character)

	if not pattern[row] then
		return false
	end

	return pattern[row]:sub(column,column)=="1"
end

Context.Modules.Font5x7=Font5x7

return Font5x7
