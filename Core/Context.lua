local Environment = getgenv()

Environment.BABFT_CALCULATOR = Environment.BABFT_CALCULATOR or {}

local Context = Environment.BABFT_CALCULATOR

Context.Version = Context.Version or "0.1.0"

Context.Modules = Context.Modules or {}

Context.Config = Context.Config or {}

Context.State = Context.State or {}

Context.Objects = Context.Objects or {}

Context.BuildQueue = Context.BuildQueue or {}

Context.ConnectionQueue = Context.ConnectionQueue or {}

Context.PropertyQueue = Context.PropertyQueue or {}

Context.PaintQueue = Context.PaintQueue or {}

Context.NamedObjects = Context.NamedObjects or {}

Context.LoadedFiles = Context.LoadedFiles or {}

Context.Statistics = Context.Statistics or {
	BlocksPlaced = 0,
	ConnectionsMade = 0,
	PropertiesChanged = 0,
	PaintOperations = 0
}

Context.State.Running = false
Context.State.CancelRequested = false
Context.State.Progress = 0
Context.State.CurrentTask = "Idle"

function Context:RegisterObject(name, object)
	self.NamedObjects[name] = object
	return object
end

function Context:GetObject(name)
	return self.NamedObjects[name]
end

function Context:QueueBuild(data)
	table.insert(self.BuildQueue, data)
end

function Context:QueueConnection(data)
	table.insert(self.ConnectionQueue, data)
end

function Context:QueueProperty(data)
	table.insert(self.PropertyQueue, data)
end

function Context:QueuePaint(data)
	table.insert(self.PaintQueue, data)
end

function Context:ClearQueues()
	table.clear(self.BuildQueue)
	table.clear(self.ConnectionQueue)
	table.clear(self.PropertyQueue)
	table.clear(self.PaintQueue)
end

function Context:ResetStatistics()
	self.Statistics.BlocksPlaced = 0
	self.Statistics.ConnectionsMade = 0
	self.Statistics.PropertiesChanged = 0
	self.Statistics.PaintOperations = 0
end

Context.Modules.Context = Context

return Context
