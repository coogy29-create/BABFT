local Context=getgenv().BABFT_CALCULATOR

local Gates={}

local Builder=Context.Modules.Builder

local function create(name,gateType,cframe)

	local gate=Builder.PlaceNamedBlock(
		name,
		"Gate",
		cframe
	)

	Context:QueueProperty({

		Type=gateType,

		Gate=gate

	})

	return gate

end

function Gates.And(name,cframe)

	return create(
		name,
		"And",
		cframe
	)

end

function Gates.Or(name,cframe)

	return create(
		name,
		"Or",
		cframe
	)

end

function Gates.Xor(name,cframe)

	return create(
		name,
		"Xor",
		cframe
	)

end

function Gates.Not(name,cframe)

	return create(
		name,
		"Not",
		cframe
	)

end

function Gates.Array(prefix,gateType,count,origin,spacing)

	local result={}

	spacing=spacing or 6

	for i=0,count-1 do

		result[i]=create(

			prefix.."_"..i,

			gateType,

			origin*CFrame.new(i*spacing,0,0)

		)

	end

	return result

end

Context.Modules.Gates=Gates

return Gates
