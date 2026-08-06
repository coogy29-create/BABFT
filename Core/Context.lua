local Context = {}

Context.Config = {}

Context.Modules = {}

Context.NamedObjects = {}

Context.BuildQueue = {}
Context.ConnectionQueue = {}
Context.PropertyQueue = {}
Context.PaintQueue = {}

Context.State = {
	Running = false,
	Compiling = false,
	CancelRequested = false,
	CurrentTask = "",
	Progress = 0,
	LastError = nil
}

Context.Statistics = {
	BlocksPlaced = 0,
	ConnectionsMade = 0,
	PropertiesChanged = 0,
	PaintOperations = 0
}

function Context:RegisterObject(name, object)
	assert(type(name) == "string", "이름은 문자열이어야 합니다.")
	assert(object, "객체가 없습니다.")

	self.NamedObjects[name] = object

	return object
end

function Context:GetObject(name)
	return self.NamedObjects[name]
end

function Context:RemoveObject(name)
	local object = self.NamedObjects[name]

	self.NamedObjects[name] = nil

	return object
end

function Context:ClearObjects()
	table.clear(self.NamedObjects)
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

function Context:ResetQueues()
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

getgenv().BABFT_CALCULATOR = Context

return Context
