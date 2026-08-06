local Context = getgenv().BABFT_CALCULATOR

local Compiler = Context.Modules.Compiler

local Project = {}

Project.Name = "Unnamed"

Project.Version = "1.0"

Project.Author = "Unknown"

Project.Root = CFrame.new()

function Project.SetRoot(cframe)

	Project.Root = cframe

end

function Project.Begin()

	Compiler.Begin()

end

function Project.End()

	return Compiler.Run()

end

function Project.Cancel()

	return Compiler.Cancel()

end

function Project.Build(callback)

	assert(
		type(callback)=="function",
		"callback이 필요합니다."
	)

	Project.Begin()

	callback()

	return Project.End()

end

function Project.Place(name,typeName,x,y,z)

	Compiler.Place(

		name,

		typeName,

		Project.Root*CFrame.new(x,y,z)

	)

end

function Project.Gate(name,gateType,x,y,z)

	Compiler.Gate(

		name,

		gateType,

		Project.Root*CFrame.new(x,y,z)

	)

end

function Project.Bind(source,...)

	Compiler.Bind(
		source,
		...
	)

end

function Project.Paint(object,color)

	Compiler.Paint(
		object,
		color
	)

end

Context.Modules.Project=Project

return Project
