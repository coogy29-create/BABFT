local Context = getgenv().BABFT_CALCULATOR

local Bus = {}

local function create(size)

	local bus={}

	for i=0,size-1 do
		bus[i]=false
	end

	return bus

end

function Bus.New(size)

	return create(size)

end

function Bus.Clone(bus)

	local new={}

	for i,v in pairs(bus) do
		new[i]=v
	end

	return new

end

function Bus.Connect(source,target)

	assert(#source==#target)

	for i=1,#source do
		target[i]=source[i]
	end

end

function Bus.Fill(bus,value)

	for i=1,#bus do
		bus[i]=value
	end

end

function Bus.Clear(bus)

	Bus.Fill(bus,false)

end

function Bus.Width(bus)

	return #bus

end

function Bus.Get(bus,index)

	return bus[index]

end

function Bus.Set(bus,index,value)

	bus[index]=value

end

function Bus.Slice(bus,startBit,endBit)

	local new={}

	local j=1

	for i=startBit,endBit do

		new[j]=bus[i]

		j=j+1

	end

	return new

end

function Bus.Merge(...)

	local result={}

	local index=1

	for _,bus in ipairs({...}) do

		for _,bit in ipairs(bus) do

			result[index]=bit

			index=index+1

		end

	end

	return result

end

Context.Modules.Bus=Bus

return Bus
