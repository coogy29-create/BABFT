local Context = getgenv().BABFT_CALCULATOR

local Queue = {}

Queue.Build = {}
Queue.Bind = {}
Queue.Property = {}
Queue.Paint = {}

function Queue.PushBuild(data)
	table.insert(Queue.Build,data)
end

function Queue.PushBind(source,targets)

	table.insert(
		Queue.Bind,
		{
			Source=source,
			Targets=targets
		}
	)

end

function Queue.PushProperty(gate,gateType)

	table.insert(
		Queue.Property,
		{
			Gate=gate,
			Type=gateType
		}
	)

end

function Queue.PushPaint(object,color)

	table.insert(
		Queue.Paint,
		{
			Object=object,
			Color=color
		}
	)

end

function Queue.PopBuild()

	if #Queue.Build==0 then
		return nil
	end

	return table.remove(
		Queue.Build,
		1
	)

end

function Queue.PopBind()

	if #Queue.Bind==0 then
		return nil
	end

	return table.remove(
		Queue.Bind,
		1
	)

end

function Queue.PopProperty()

	if #Queue.Property==0 then
		return nil
	end

	return table.remove(
		Queue.Property,
		1
	)

end

function Queue.PopPaint()

	if #Queue.Paint==0 then
		return nil
	end

	return table.remove(
		Queue.Paint,
		1
	)

end

function Queue.Clear()

	table.clear(Queue.Build)
	table.clear(Queue.Bind)
	table.clear(Queue.Property)
	table.clear(Queue.Paint)

end

function Queue.IsEmpty()

	return
		#Queue.Build==0
		and #Queue.Bind==0
		and #Queue.Property==0
		and #Queue.Paint==0

end

Context.Modules.Queue=Queue

return Queue
