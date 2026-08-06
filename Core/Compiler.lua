local Context = getgenv().BABFT_CALCULATOR

local Queue = Context.Modules.Queue
local Executor = Context.Modules.Executor

local Compiler = {}

function Compiler.Begin()

	Queue.Clear()

	Context.State.Compiling = true

end

function Compiler.Place(name,blockType,cframe)

	Queue.PushBuild({

		Name=name,

		Type=blockType,

		CFrame=cframe

	})

end

function Compiler.Gate(name,gateType,cframe)

	Queue.PushBuild({

		Name=name,

		Type="Gate",

		CFrame=cframe,

		GateType=gateType

	})

end

function Compiler.Bind(source,...)

	local targets={...}

	Queue.PushBind(

		source,

		targets

	)

end

function Compiler.Paint(object,color)

	Queue.PushPaint(

		object,

		color

	)

end

function Compiler.Property(object,gateType)

	Queue.PushProperty(

		object,

		gateType

	)

end

function Compiler.Run()

	Context.State.Compiling=false

	return Executor.Run()

end

function Compiler.Cancel()

	Context.State.Compiling=false

	return Executor.Cancel()

end

Context.Modules.Compiler=Compiler

return Compiler
