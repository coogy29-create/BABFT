local Context = getgenv().BABFT_CALCULATOR

local Components = {}

local Circuit = Context.Modules.Circuit

function Components.Create(definition)
	return Circuit.Build(definition)
end

function Components.Connect(source,target)

	Circuit.ConnectOutput(
		source,
		target
	)

end

function Components.ConnectMany(source,...)

	local targets={...}

	Circuit.ConnectOutput(
		source,
		targets
	)

end

function Components.Bus(prefix,width)

	local result={}

	for bit=0,width-1 do

		result[bit]=prefix.."_BIT_"..bit

	end

	return result

end

function Components.Named(prefix,count)

	local result={}

	for i=1,count do

		result[i]=prefix.."_"..i

	end

	return result

end

function Components.Pair(inputBus,outputBus)

	local result={}

	for bit,input in pairs(inputBus) do

		result[#result+1]={

			Input=input,

			Output=outputBus[bit]

		}

	end

	return result

end

Context.Modules.Components=Components

return Components
