
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local CoreGui=game:GetService("CoreGui")

local Player=Players.LocalPlayer
local Camera=Workspace.CurrentCamera
local Folder=Workspace:WaitForChild("Blocks"):WaitForChild(Player.Name)

local GATE_ID=556
local SWITCH_ID=100
local DISPLAY_ID=4100
local ZONE_OFFSET=Vector3.new(53.565689086914,18,345.50686645508)

local WHITE=Color3.new(0.97254902124405,0.97254902124405,0.97254902124405)
local BLACK=Color3.new(0.066666670143604,0.066666670143604,0.066666670143604)

local SelectedBase=nil
local Selecting=false
local Running=false
local CancelRequested=false
local Marker=nil

local OldGui=CoreGui:FindFirstChild("BABFTSRLatchBuilder")
if OldGui then OldGui:Destroy() end

local function getCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function findTool(name,equip)
	local character=getCharacter()
	local backpack=Player:WaitForChild("Backpack")
	local tool=character:FindFirstChild(name) or backpack:FindFirstChild(name)

	if tool and equip and tool.Parent~=character then
		tool.Parent=character
		task.wait(0.15)
	end

	return tool
end

local function snapshotChildren()
	local snapshot={}
	for _,object in ipairs(Folder:GetChildren()) do
		snapshot[object]=true
	end
	return snapshot
end

local function worldToZoneCFrame(worldCFrame)
	return CFrame.new(worldCFrame.Position+ZONE_OFFSET)*worldCFrame.Rotation
end

local function installBlock(buildRF,kind,id,worldCFrame)
	local zone=Workspace:FindFirstChild("WhiteZone")
	if not zone then
		return nil,"workspace.WhiteZone을 찾지 못했습니다."
	end

	local before=snapshotChildren()

	local ok,result=pcall(function()
		return buildRF:InvokeServer(
			kind,
			id,
			zone,
			worldToZoneCFrame(worldCFrame),
			true,
			worldCFrame,
			false
		)
	end)

	if not ok then
		return nil,tostring(result)
	end

	local deadline=os.clock()+7

	repeat
		if CancelRequested then
			return nil,"사용자가 중단했습니다."
		end

		for _,object in ipairs(Folder:GetChildren()) do
			if not before[object] and object.Name==kind then
				return object
			end
		end

		task.wait(0.02)
	until os.clock()>=deadline

	return nil,kind.." 생성 확인 시간 초과"
end

local function waitChild(parent,name,timeout)
	local deadline=os.clock()+(timeout or 5)

	repeat
		local child=parent and parent:FindFirstChild(name)
		if child then return child end
		task.wait(0.02)
	until os.clock()>=deadline

	return nil
end

local function objectPosition(object)
	if object:IsA("Model") then
		return object:GetPivot().Position
	elseif object:IsA("BasePart") then
		return object.Position
	end
end

local function nearestAutoTarget(source,previousObjects)
	local sourcePosition=objectPosition(source)
	if not sourcePosition then return nil end

	local bestBind=nil
	local bestDistance=math.huge

	for _,target in ipairs(previousObjects) do
		if target and target.Parent then
			local bind=target:FindFirstChild("BindActivate")
				or target:FindFirstChild("BindFire")

			local position=bind and objectPosition(target)

			if bind and position then
				local distance=(position-sourcePosition).Magnitude

				if distance<bestDistance then
					bestDistance=distance
					bestBind=bind
				end
			end
		end
	end

	return bestBind
end

local function removeSwitchAutoLink(bindRF,switch,previousObjects)
	local targetBind=nearestAutoTarget(switch,previousObjects)
	if not targetBind then return true end

	local ok,result=pcall(function()
		return bindRF:InvokeServer(
			{Activate={targetBind}},
			switch,
			{},
			true,
			true
		)
	end)

	return ok,result
end

local function bind(bindRF,source,targets)
	local ok,result=pcall(function()
		return bindRF:InvokeServer(
			{Activate=targets},
			source,
			{},
			false,
			true
		)
	end)

	return ok,result
end

local Gui=Instance.new("ScreenGui")
Gui.Name="BABFTSRLatchBuilder"
Gui.ResetOnSpawn=false
Gui.Parent=CoreGui

local Main=Instance.new("Frame")
Main.Size=UDim2.fromOffset(330,330)
Main.Position=UDim2.new(0.5,-165,0.5,-165)
Main.BackgroundColor3=Color3.fromRGB(27,29,35)
Main.BorderSizePixel=0
Main.Active=true
Main.Parent=Gui
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,14)

local Stroke=Instance.new("UIStroke")
Stroke.Color=Color3.fromRGB(80,160,255)
Stroke.Thickness=2
Stroke.Parent=Main

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-52,0,42)
Title.Position=UDim2.fromOffset(14,4)
Title.BackgroundTransparency=1
Title.Text="SR 래치 자동건설기 V1"
Title.TextColor3=Color3.new(1,1,1)
Title.TextSize=18
Title.Font=Enum.Font.GothamBold
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=Main

local Close=Instance.new("TextButton")
Close.Size=UDim2.fromOffset(34,34)
Close.Position=UDim2.new(1,-42,0,7)
Close.BackgroundColor3=Color3.fromRGB(170,60,60)
Close.Text="×"
Close.TextColor3=Color3.new(1,1,1)
Close.TextSize=22
Close.Font=Enum.Font.GothamBold
Close.Parent=Main
Instance.new("UICorner",Close).CornerRadius=UDim.new(0,9)

local Info=Instance.new("TextLabel")
Info.Size=UDim2.new(1,-28,0,72)
Info.Position=UDim2.fromOffset(14,50)
Info.BackgroundColor3=Color3.fromRGB(39,42,50)
Info.Text="S/R 토글 스위치 2개\nOR 2개 + NOT 2개로 교차 NOR 래치 구성\nQ/Q̅ 화면은 흰색·검은색 양방향 출력"
Info.TextColor3=Color3.fromRGB(220,223,232)
Info.TextSize=13
Info.TextWrapped=true
Info.Parent=Main
Instance.new("UICorner",Info).CornerRadius=UDim.new(0,9)

local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(1,-28,0,88)
Status.Position=UDim2.fromOffset(14,132)
Status.BackgroundColor3=Color3.fromRGB(39,42,50)
Status.Text="위치 선택 후 회로 좌하단을 누르세요."
Status.TextColor3=Color3.fromRGB(235,235,240)
Status.TextSize=14
Status.TextWrapped=true
Status.Parent=Main
Instance.new("UICorner",Status).CornerRadius=UDim.new(0,9)

local Select=Instance.new("TextButton")
Select.Size=UDim2.new(1,-28,0,42)
Select.Position=UDim2.fromOffset(14,230)
Select.BackgroundColor3=Color3.fromRGB(60,110,200)
Select.Text="위치 선택"
Select.TextColor3=Color3.new(1,1,1)
Select.TextSize=15
Select.Font=Enum.Font.GothamBold
Select.Parent=Main
Instance.new("UICorner",Select).CornerRadius=UDim.new(0,9)

local Start=Instance.new("TextButton")
Start.Size=UDim2.new(0.65,-18,0,44)
Start.Position=UDim2.fromOffset(14,280)
Start.BackgroundColor3=Color3.fromRGB(60,65,75)
Start.Text="자동 건설 시작"
Start.TextColor3=Color3.fromRGB(160,164,174)
Start.TextSize=15
Start.Font=Enum.Font.GothamBold
Start.AutoButtonColor=false
Start.Parent=Main
Instance.new("UICorner",Start).CornerRadius=UDim.new(0,9)

local Stop=Instance.new("TextButton")
Stop.Size=UDim2.new(0.35,-10,0,44)
Stop.Position=UDim2.new(0.65,4,0,280)
Stop.BackgroundColor3=Color3.fromRGB(160,65,65)
Stop.Text="중단"
Stop.TextColor3=Color3.new(1,1,1)
Stop.TextSize=15
Stop.Font=Enum.Font.GothamBold
Stop.Parent=Main
Instance.new("UICorner",Stop).CornerRadius=UDim.new(0,9)

do
	local dragging=false
	local dragInput,dragStart,startPosition

	Title.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.Touch
			or input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true
			dragStart=input.Position
			startPosition=Main.Position
		end
	end)

	Title.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.Touch
			or input.UserInputType==Enum.UserInputType.MouseMovement then
			dragInput=input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input==dragInput then
			local delta=input.Position-dragStart

			Main.Position=UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset+delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset+delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.Touch
			or input.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=false
		end
	end)
end

local function setStartEnabled(enabled)
	Start.AutoButtonColor=enabled
	Start.BackgroundColor3=enabled
		and Color3.fromRGB(45,165,95)
		or Color3.fromRGB(60,65,75)
	Start.TextColor3=enabled
		and Color3.new(1,1,1)
		or Color3.fromRGB(160,164,174)
end

Select.MouseButton1Click:Connect(function()
	if Running then return end
	Selecting=true
	Status.Text="창 밖에서 SR 래치 좌하단 위치를 누르세요."
end)

UIS.InputBegan:Connect(function(input,processed)
	if processed or not Selecting or Running then return end

	if input.UserInputType~=Enum.UserInputType.Touch
		and input.UserInputType~=Enum.UserInputType.MouseButton1 then
		return
	end

	Camera=Workspace.CurrentCamera
	local ray=Camera:ViewportPointToRay(input.Position.X,input.Position.Y)

	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances={Player.Character,Marker}

	local hit=Workspace:Raycast(ray.Origin,ray.Direction*3000,params)

	if not hit then
		Status.Text="위치 감지 실패"
		return
	end

	local position=hit.Position+hit.Normal
	position=Vector3.new(
		math.round(position.X),
		math.round(position.Y*10)/10,
		math.round(position.Z)
	)

	local right=Camera.CFrame.RightVector
	right=Vector3.new(right.X,0,right.Z)
	right=right.Magnitude<0.1 and Vector3.new(1,0,0) or right.Unit

	local up=Vector3.new(0,1,0)
	local back=right:Cross(up)
	back=back.Magnitude<0.1 and Vector3.new(0,0,1) or back.Unit

	SelectedBase=CFrame.fromMatrix(position,right,up,back)
	Selecting=false

	if Marker then Marker:Destroy() end

	Marker=Instance.new("Part")
	Marker.Name="SRLatchBuilderMarker"
	Marker.Anchored=true
	Marker.CanCollide=false
	Marker.CanQuery=false
	Marker.CanTouch=false
	Marker.Material=Enum.Material.Neon
	Marker.Color=Color3.fromRGB(0,230,255)
	Marker.Transparency=0.55
	Marker.Size=Vector3.new(30,18,18)
	Marker.CFrame=SelectedBase*CFrame.new(15,9,0)
	Marker.Parent=Workspace

	Status.Text=string.format(
		"위치 선택 완료\nX %.1f / Y %.1f / Z %.1f",
		position.X,
		position.Y,
		position.Z
	)

	setStartEnabled(true)
end)

Stop.MouseButton1Click:Connect(function()
	if Running then
		CancelRequested=true
		Status.Text="중단 요청됨"
	end
end)

local function fail(message)
	Status.Text=message
	Running=false
	Start.Text="다시 시작"
	setStartEnabled(SelectedBase~=nil)
end

local function buildLatch()
	if Running or not SelectedBase then return end

	Running=true
	CancelRequested=false
	setStartEnabled(false)
	Start.Text="건설 중..."

	local BuildingTool=findTool("BuildingTool",false)
	local PropertiesTool=findTool("PropertiesTool",true)
	local BindTool=findTool("BindTool",true)
	local PaintingTool=findTool("PaintingTool",false)

	if not BuildingTool or not PropertiesTool
		or not BindTool or not PaintingTool then
		return fail("Building/Properties/Bind/Painting 도구가 필요합니다.")
	end

	local BuildRF=BuildingTool:WaitForChild("RF")
	local PropertyRF=PropertiesTool:WaitForChild("SetPropertieRF")
	local BindRF=BindTool:WaitForChild("RF")
	local PaintRF=PaintingTool:WaitForChild("RF")

	local specs={
		{Name="OR_Q",Kind="Gate",Id=GATE_ID,Type="Or",CF=SelectedBase*CFrame.new(8,6,-6)},
		{Name="NOT_Q",Kind="Gate",Id=GATE_ID,Type="Not",CF=SelectedBase*CFrame.new(14,6,-6)},
		{Name="OR_QB",Kind="Gate",Id=GATE_ID,Type="Or",CF=SelectedBase*CFrame.new(8,0,-6)},
		{Name="NOT_QB",Kind="Gate",Id=GATE_ID,Type="Not",CF=SelectedBase*CFrame.new(14,0,-6)},

		{Name="Q_WHITE",Kind="Gate",Id=GATE_ID,Type="Or",CF=SelectedBase*CFrame.new(20,6,-6)},
		{Name="Q_BLACK",Kind="Gate",Id=GATE_ID,Type="Not",CF=SelectedBase*CFrame.new(20,3,-6)},
		{Name="QB_WHITE",Kind="Gate",Id=GATE_ID,Type="Or",CF=SelectedBase*CFrame.new(20,0,-6)},
		{Name="QB_BLACK",Kind="Gate",Id=GATE_ID,Type="Not",CF=SelectedBase*CFrame.new(20,-3,-6)},

		{Name="DISPLAY_Q",Kind="DisplayBlock",Id=DISPLAY_ID,CF=SelectedBase*CFrame.new(26,6,0)},
		{Name="DISPLAY_QB",Kind="DisplayBlock",Id=DISPLAY_ID,CF=SelectedBase*CFrame.new(26,0,0)},

		{Name="SWITCH_S",Kind="Switch",Id=SWITCH_ID,CF=SelectedBase*CFrame.new(0,0,6)},
		{Name="SWITCH_R",Kind="Switch",Id=SWITCH_ID,CF=SelectedBase*CFrame.new(0,6,6)}
	}

	local nodes={}
	local generated={}
	local gateGroups={Or={},Not={}}

	for index,spec in ipairs(specs) do
		if CancelRequested then return fail("건설 중 중단됨") end

		Status.Text=string.format(
			"블록 설치 중\n%d / %d\n%s",
			index,
			#specs,
			spec.Name
		)

		local object,errorMessage=installBlock(
			BuildRF,
			spec.Kind,
			spec.Id,
			spec.CF
		)

		if not object then
			return fail(
				"설치 실패: "..spec.Name.."\n"..tostring(errorMessage)
			)
		end

		nodes[spec.Name]=object

		if spec.Kind=="Switch" then
			Status.Text="스위치 자동 근접 연결 해제 중\n"..spec.Name

			local ok,result=removeSwitchAutoLink(
				BindRF,
				object,
				generated
			)

			if not ok then
				return fail(
					"자동 연결 해제 실패: "
					..spec.Name
					.."\n"
					..tostring(result)
				)
			end
		elseif spec.Kind=="Gate" then
			table.insert(gateGroups[spec.Type],object)
		end

		table.insert(generated,object)
		task.wait(0.03)
	end

	Status.Text="Gate 종류 설정 중..."

	for gateType,list in pairs(gateGroups) do
		local ok,result=pcall(function()
			return PropertyRF:InvokeServer(gateType,list)
		end)

		if not ok then
			return fail("Gate 설정 실패\n"..tostring(result))
		end

		task.wait(0.05)
	end

	Status.Text="출력 Gate 색칠 중..."

	local paintEntries={
		{nodes.Q_WHITE,WHITE},
		{nodes.Q_BLACK,BLACK},
		{nodes.QB_WHITE,WHITE},
		{nodes.QB_BLACK,BLACK}
	}

	local paintOk,paintResult=pcall(function()
		return PaintRF:InvokeServer(paintEntries)
	end)

	if not paintOk then
		return fail("색칠 실패\n"..tostring(paintResult))
	end

	local connections={
		{Source="SWITCH_R",Targets={{Name="OR_Q",Bind="BindActivate"}}},
		{Source="SWITCH_S",Targets={{Name="OR_QB",Bind="BindActivate"}}},

		{Source="OR_Q",Targets={{Name="NOT_Q",Bind="BindActivate"}}},
		{Source="OR_QB",Targets={{Name="NOT_QB",Bind="BindActivate"}}},

		{Source="NOT_Q",Targets={
			{Name="OR_QB",Bind="BindActivate"},
			{Name="Q_WHITE",Bind="BindActivate"},
			{Name="Q_BLACK",Bind="BindActivate"}
		}},

		{Source="NOT_QB",Targets={
			{Name="OR_Q",Bind="BindActivate"},
			{Name="QB_WHITE",Bind="BindActivate"},
			{Name="QB_BLACK",Bind="BindActivate"}
		}},

		{Source="Q_WHITE",Targets={{Name="DISPLAY_Q",Bind="BindFire"}}},
		{Source="Q_BLACK",Targets={{Name="DISPLAY_Q",Bind="BindFire"}}},
		{Source="QB_WHITE",Targets={{Name="DISPLAY_QB",Bind="BindFire"}}},
		{Source="QB_BLACK",Targets={{Name="DISPLAY_QB",Bind="BindFire"}}}
	}

	for index,connection in ipairs(connections) do
		if CancelRequested then return fail("배선 중 중단됨") end

		Status.Text=string.format(
			"자동 배선 중\n%d / %d\n%s",
			index,
			#connections,
			connection.Source
		)

		local targets={}

		for _,targetInfo in ipairs(connection.Targets) do
			local target=nodes[targetInfo.Name]
			local bindValue=waitChild(target,targetInfo.Bind,5)

			if not bindValue then
				return fail(
					"단자 없음: "
					..targetInfo.Name
					.."."
					..targetInfo.Bind
				)
			end

			table.insert(targets,bindValue)
		end

		local ok,result=bind(
			BindRF,
			nodes[connection.Source],
			targets
		)

		if not ok then
			return fail(
				"배선 실패: "
				..connection.Source
				.."\n"
				..tostring(result)
			)
		end

		task.wait(0.03)
	end

	if Marker then
		Marker:Destroy()
		Marker=nil
	end

	getgenv().BABFTSRLatch={
		Nodes=nodes,
		Base=SelectedBase
	}

	Running=false
	Start.Text="완료"
	setStartEnabled(true)

	Status.Text="완성\n먼저 R을 ON→OFF해 초기화\nS ON→OFF: Q=1 저장\nR ON→OFF: Q=0 저장"
end

Start.MouseButton1Click:Connect(function()
	if not SelectedBase then
		Status.Text="먼저 위치를 선택하세요."
		return
	end

	task.spawn(buildLatch)
end)

Close.MouseButton1Click:Connect(function()
	CancelRequested=true
	if Marker then Marker:Destroy() end
	Gui:Destroy()
end)
