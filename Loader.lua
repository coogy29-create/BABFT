if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local BASE_URL =
	"https://raw.githubusercontent.com/coogy29-create/BABFT/main/"

local FILES = {
	"Core/Context.lua",
	"Core/Config.lua",
	"Core/Utils.lua",
	"Core/Inventory.lua",
	"Core/WhiteZone.lua",
	"Core/Scanner.lua",
	"Core/Layout.lua",
	"Core/NameService.lua",
	"Core/Queue.lua",
	"Core/Builder.lua",
	"Core/Bind.lua",
	"Core/Paint.lua",
	"Core/Property.lua",
	"Core/Executor.lua",
	"Core/Compiler.lua",
	"Core/Project.lua",
	"Core/Bus.lua",

	"Logic/Gates.lua",
	"Logic/Wiring.lua",
	"Logic/Circuit.lua",
	"Logic/Components.lua",
	"Logic/HalfAdder.lua",
	"Logic/FullAdder.lua",
	"Logic/DLatch.lua",
	"Logic/Register1.lua",
	"Logic/Register16.lua",
	"Logic/Adder16.lua",
	"Logic/Subtractor16.lua",
	"Logic/ALU16.lua",
	"Logic/DecimalInput.lua",
	"Logic/BinaryToBCD.lua",
	"Logic/KeypadEncoder.lua",
	"Logic/DecimalAccumulator.lua",
	"Logic/CalculatorController.lua",

	"Display/Font5x7.lua",
	"Display/DisplayDriver.lua",

	"Calculator/DisplayController.lua",
	"Calculator/System.lua",
	"Calculator/Main.lua"
}

local Environment = getgenv()

if Environment.BABFT_CALCULATOR_LOADER_RUNNING then
	warn("[BABFT] 로더가 이미 실행 중입니다.")
	return
end

Environment.BABFT_CALCULATOR_LOADER_RUNNING = true
Environment.BABFT_CALCULATOR = nil

local SelectedCFrame = nil
local SelectingPosition = false
local Building = false
local Marker = nil
local Closed = false

local function download(fileName)
	local url =
		BASE_URL
		.. fileName
		.. "?cache="
		.. tostring(os.time())
		.. "_"
		.. tostring(math.random(100000, 999999))

	local success, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		error(
			"다운로드 실패: "
				.. fileName
				.. "\n"
				.. tostring(source)
		)
	end

	if type(source) ~= "string"
		or source == ""
		or source:find("404: Not Found", 1, true) then
		error("GitHub 파일 없음: " .. fileName)
	end

	return source
end

local function execute(fileName, source)
	local chunk, compileError = loadstring(
		source,
		"@BABFT/" .. fileName
	)

	if not chunk then
		error(
			"컴파일 실패: "
				.. fileName
				.. "\n"
				.. tostring(compileError)
		)
	end

	local success, result = xpcall(
		chunk,
		debug.traceback
	)

	if not success then
		error(
			"실행 실패: "
				.. fileName
				.. "\n"
				.. tostring(result)
		)
	end

	return result
end

local oldGui =
	CoreGui:FindFirstChild("BABFTCalculatorBuilderUI")

if oldGui then
	oldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "BABFTCalculatorBuilderUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(330, 340)
Main.Position = UDim2.new(0.5, -165, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(25, 27, 34)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(70, 145, 255)
MainStroke.Thickness = 2
MainStroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = TitleBar.BackgroundColor3
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -58, 1, 0)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "16비트 계산기 자동건설기"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(36, 34)
CloseButton.Position = UDim2.new(1, -42, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(175, 60, 60)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 22
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 9)
CloseCorner.Parent = CloseButton

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 108)
Status.Position = UDim2.fromOffset(12, 58)
Status.BackgroundColor3 = Color3.fromRGB(39, 42, 52)
Status.BorderSizePixel = 0
Status.Text = "모듈을 불러오는 중입니다."
Status.TextColor3 = Color3.fromRGB(230, 232, 240)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.TextWrapped = true
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = Status

local ProgressBack = Instance.new("Frame")
ProgressBack.Size = UDim2.new(1, -24, 0, 12)
ProgressBack.Position = UDim2.fromOffset(12, 176)
ProgressBack.BackgroundColor3 = Color3.fromRGB(55, 58, 68)
ProgressBack.BorderSizePixel = 0
ProgressBack.Parent = Main

local ProgressBackCorner = Instance.new("UICorner")
ProgressBackCorner.CornerRadius = UDim.new(1, 0)
ProgressBackCorner.Parent = ProgressBack

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(65, 160, 255)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBack

local ProgressFillCorner = Instance.new("UICorner")
ProgressFillCorner.CornerRadius = UDim.new(1, 0)
ProgressFillCorner.Parent = ProgressFill

local SelectButton = Instance.new("TextButton")
SelectButton.Size = UDim2.new(1, -24, 0, 42)
SelectButton.Position = UDim2.fromOffset(12, 202)
SelectButton.BackgroundColor3 = Color3.fromRGB(60, 115, 205)
SelectButton.Text = "위치 선택"
SelectButton.TextColor3 = Color3.new(1, 1, 1)
SelectButton.TextSize = 15
SelectButton.Font = Enum.Font.GothamBold
SelectButton.Parent = Main

local SelectCorner = Instance.new("UICorner")
SelectCorner.CornerRadius = UDim.new(0, 10)
SelectCorner.Parent = SelectButton

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.66, -8, 0, 46)
StartButton.Position = UDim2.fromOffset(12, 256)
StartButton.BackgroundColor3 = Color3.fromRGB(65, 68, 78)
StartButton.Text = "자동건설 시작"
StartButton.TextColor3 = Color3.fromRGB(160, 164, 175)
StartButton.TextSize = 15
StartButton.Font = Enum.Font.GothamBold
StartButton.AutoButtonColor = false
StartButton.Parent = Main

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 10)
StartCorner.Parent = StartButton

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.34, -8, 0, 46)
StopButton.Position = UDim2.new(0.66, 4, 0, 256)
StopButton.BackgroundColor3 = Color3.fromRGB(165, 65, 65)
StopButton.Text = "중단"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.TextSize = 15
StopButton.Font = Enum.Font.GothamBold
StopButton.Parent = Main

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 10)
StopCorner.Parent = StopButton

local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, -24, 0, 24)
Hint.Position = UDim2.fromOffset(12, 308)
Hint.BackgroundTransparency = 1
Hint.Text = "위치를 선택한 뒤 시작을 누르세요."
Hint.TextColor3 = Color3.fromRGB(155, 160, 175)
Hint.TextSize = 12
Hint.Font = Enum.Font.Gotham
Hint.Parent = Main

local function setProgress(value)
	value = math.clamp(value or 0, 0, 1)

	ProgressFill.Size = UDim2.new(
		value,
		0,
		1,
		0
	)
end

local function setStartEnabled(enabled)
	StartButton.AutoButtonColor = enabled

	if enabled then
		StartButton.BackgroundColor3 =
			Color3.fromRGB(45, 165, 90)

		StartButton.TextColor3 =
			Color3.new(1, 1, 1)
	else
		StartButton.BackgroundColor3 =
			Color3.fromRGB(65, 68, 78)

		StartButton.TextColor3 =
			Color3.fromRGB(160, 164, 175)
	end
end

local function removeMarker()
	if Marker then
		Marker:Destroy()
		Marker = nil
	end
end

local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType
			== Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position
	end
end)

TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType
			== Enum.UserInputType.Touch
		or input.UserInputType
			== Enum.UserInputType.MouseMovement then

		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart

		Main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType
			== Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

local moduleLoadSuccess, moduleLoadError =
	xpcall(function()
		for index, fileName in ipairs(FILES) do
			Status.Text = string.format(
				"모듈 불러오는 중\n%d / %d\n%s",
				index,
				#FILES,
				fileName
			)

			setProgress(index / #FILES)

			local source = download(fileName)
			execute(fileName, source)

			task.wait()
		end
	end, debug.traceback)

if not moduleLoadSuccess then
	Environment.BABFT_CALCULATOR_LOADER_RUNNING = false

	Status.Text =
		"모듈 로드 실패\n"
		.. tostring(moduleLoadError)

	Status.TextColor3 =
		Color3.fromRGB(255, 120, 120)

	warn(
		"[BABFT] 모듈 로드 실패\n"
			.. tostring(moduleLoadError)
	)

	return
end

local Context = Environment.BABFT_CALCULATOR

if not Context
	or not Context.Modules
	or not Context.Modules.Calculator then

	Environment.BABFT_CALCULATOR_LOADER_RUNNING = false
	Status.Text = "Calculator 모듈을 찾지 못했습니다."
	Status.TextColor3 = Color3.fromRGB(255, 120, 120)
	return
end

local MainModule = Context.Modules.Calculator

Status.Text =
	"모듈 로드 완료\n"
	.. "위치 선택 버튼을 누른 뒤\n"
	.. "월드에서 건설 기준점을 누르세요."

setProgress(1)

SelectButton.MouseButton1Click:Connect(function()
	if Building then
		return
	end

	SelectingPosition = true

	Status.Text =
		"위치 선택 중\n"
		.. "UI 바깥의 바닥이나 블록을 누르세요."

	SelectButton.Text = "위치 선택 중..."
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed
		or not SelectingPosition
		or Building
		or Closed then

		return
	end

	if input.UserInputType
		~= Enum.UserInputType.Touch
		and input.UserInputType
		~= Enum.UserInputType.MouseButton1 then

		return
	end

	local Camera = Workspace.CurrentCamera

	if not Camera then
		Status.Text = "카메라를 찾을 수 없습니다."
		return
	end

	local ray = Camera:ViewportPointToRay(
		input.Position.X,
		input.Position.Y
	)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local exclude = {}

	if LocalPlayer.Character then
		exclude[#exclude + 1] =
			LocalPlayer.Character
	end

	if Marker then
		exclude[#exclude + 1] = Marker
	end

	params.FilterDescendantsInstances = exclude
	params.IgnoreWater = true

	local result = Workspace:Raycast(
		ray.Origin,
		ray.Direction * 3000,
		params
	)

	if not result then
		Status.Text = "선택할 위치를 찾지 못했습니다."
		return
	end

	local position =
		result.Position
		+ result.Normal * 1.5

	position = Vector3.new(
		math.round(position.X),
		math.round(position.Y * 10) / 10,
		math.round(position.Z)
	)

	local right = Camera.CFrame.RightVector
	right = Vector3.new(right.X, 0, right.Z)

	if right.Magnitude < 0.1 then
		right = Vector3.new(1, 0, 0)
	else
		right = right.Unit
	end

	local up = Vector3.new(0, 1, 0)
	local back = right:Cross(up)

	if back.Magnitude < 0.1 then
		back = Vector3.new(0, 0, 1)
	else
		back = back.Unit
	end

	SelectedCFrame = CFrame.fromMatrix(
		position,
		right,
		up,
		back
	)

	SelectingPosition = false
	SelectButton.Text = "위치 다시 선택"

	removeMarker()

	Marker = Instance.new("Part")
	Marker.Name = "BABFTCalculatorBuildMarker"
	Marker.Size = Vector3.new(20, 2, 20)
	Marker.CFrame = SelectedCFrame
	Marker.Anchored = true
	Marker.CanCollide = false
	Marker.CanTouch = false
	Marker.CanQuery = false
	Marker.Transparency = 0.45
	Marker.Material = Enum.Material.Neon
	Marker.Color = Color3.fromRGB(0, 225, 255)
	Marker.Parent = Workspace

	Status.Text = string.format(
		"위치 선택 완료\nX %.1f / Y %.1f / Z %.1f\n시작 버튼을 누르세요.",
		position.X,
		position.Y,
		position.Z
	)

	setStartEnabled(true)
end)

StartButton.MouseButton1Click:Connect(function()
	if Building then
		return
	end

	if not SelectedCFrame then
		Status.Text = "먼저 건설 위치를 선택하세요."
		return
	end

	Building = true
	setStartEnabled(false)
	SelectButton.Active = false
	StartButton.Text = "건설 중..."

	removeMarker()

	task.spawn(function()
		local buildSuccess, buildResult =
			xpcall(function()
				Status.Text =
					"계산기 설계 생성 및 자동건설 시작"

				setProgress(0)

				local calculator =
					MainModule.Build(SelectedCFrame)

				Context.Calculator = calculator
				Context.Ready = true

				return calculator
			end, debug.traceback)

		Building = false
		Environment.BABFT_CALCULATOR_LOADER_RUNNING =
			false

		if not buildSuccess then
			Status.Text =
				"자동건설 실패\n"
				.. tostring(buildResult)

			Status.TextColor3 =
				Color3.fromRGB(255, 120, 120)

			StartButton.Text = "다시 시작"
			SelectButton.Active = true
			setStartEnabled(true)

			warn(
				"[BABFT] 자동건설 실패\n"
					.. tostring(buildResult)
			)

			return
		end

		setProgress(1)

		Status.Text =
			"자동건설 완료\n"
			.. "설치된 계산기를 테스트하세요."

		Status.TextColor3 =
			Color3.fromRGB(130, 255, 160)

		StartButton.Text = "완료"
		SelectButton.Active = true
	end)
end)

StopButton.MouseButton1Click:Connect(function()
	if not Building then
		Status.Text = "현재 실행 중인 건설 작업이 없습니다."
		return
	end

	if Context.Modules.Executor
		and Context.Modules.Executor.Cancel then

		Context.Modules.Executor.Cancel()
	end

	if Context.State then
		Context.State.CancelRequested = true
	end

	Status.Text = "중단 요청을 보냈습니다."
end)

task.spawn(function()
	while Gui.Parent and not Closed do
		if Building and Context.State then
			local taskName =
				Context.State.CurrentTask
				or "자동건설 중"

			local progress =
				Context.State.Progress or 0

			Status.Text = string.format(
				"%s\n진행률: %d%%",
				taskName,
				math.floor(progress * 100)
			)

			setProgress(progress)
		end

		task.wait(0.15)
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	Closed = true
	SelectingPosition = false

	if Building and Context.State then
		Context.State.CancelRequested = true
	end

	removeMarker()

	Environment.BABFT_CALCULATOR_LOADER_RUNNING =
		false

	Gui:Destroy()
end)
