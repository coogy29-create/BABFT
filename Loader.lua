if not game:IsLoaded() then
	game.Loaded:Wait()
end

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

local function finish()
	Environment.BABFT_CALCULATOR_LOADER_RUNNING = false
end

local function download(fileName)
	local url =
		BASE_URL
		.. fileName
		.. "?cache="
		.. tostring(os.time())
		.. "_"
		.. tostring(math.random(100000,999999))

	local success,source = pcall(function()
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
		or source:find("404: Not Found",1,true) then
		error("GitHub 파일 없음: "..fileName)
	end

	return source
end

local function execute(fileName,source)
	local chunk,compileError = loadstring(
		source,
		"@BABFT/"..fileName
	)

	if not chunk then
		error(
			"컴파일 실패: "
			.. fileName
			.. "\n"
			.. tostring(compileError)
		)
	end

	local success,result = xpcall(
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

local success,errorMessage = xpcall(function()
	for index,fileName in ipairs(FILES) do
		print(
			string.format(
				"[BABFT] %d/%d 로드 중: %s",
				index,
				#FILES,
				fileName
			)
		)

		local source = download(fileName)
		execute(fileName,source)

		task.wait()
	end

	local Context = Environment.BABFT_CALCULATOR

	assert(Context,"Context가 생성되지 않았습니다.")
	assert(Context.Modules,"Context.Modules가 없습니다.")

	local Config = Context.Config
	local Utils = Context.Modules.Utils

	assert(Config,"Config 모듈이 없습니다.")
	assert(Utils,"Utils 모듈이 없습니다.")

	Config.Tools.PaintTool =
		Config.Tools.PaintTool
		or Config.Tools.PaintingTool
		or "PaintingTool"

	Config.Tools.PaintingTool =
		Config.Tools.PaintingTool
		or Config.Tools.PaintTool

	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	function Utils.WaitForTool(name,equip,timeout)
		timeout = timeout or 10

		local deadline = os.clock()+timeout

		repeat
			local character = LocalPlayer.Character
			local backpack = LocalPlayer:FindFirstChild("Backpack")

			local tool =
				(character and character:FindFirstChild(name))
				or (backpack and backpack:FindFirstChild(name))

			if tool then
				if equip
					and character
					and tool.Parent ~= character then

					tool.Parent = character
					task.wait(0.15)
				end

				return tool
			end

			task.wait(0.05)
		until os.clock() >= deadline

		return nil
	end

	local Paint = Context.Modules.Paint

	if Paint then
		local function resolveObject(object)
			if typeof(object) == "Instance" then
				return object
			end

			local found = Context:GetObject(object)

			assert(
				found,
				"등록되지 않은 도색 대상: "
				.. tostring(object)
			)

			return found
		end

		function Paint.Paint(object,color)
			object = resolveObject(object)

			local tool = Utils.WaitForTool(
				Config.Tools.PaintTool,
				true,
				10
			)

			assert(tool,"PaintingTool을 찾을 수 없습니다.")

			local remote =
				tool:FindFirstChild("RF")
				or tool:FindFirstChild("PaintRF")

			assert(remote,"PaintingTool Remote를 찾을 수 없습니다.")

			local paintSuccess,paintResult = pcall(function()
				return remote:InvokeServer({
					{object,color}
				})
			end)

			if not paintSuccess then
				error(
					"도색 실패\n"
					.. tostring(paintResult)
				)
			end

			Context.Statistics.PaintOperations += 1
			task.wait(Config.PaintDelay)
		end
	end

	local BinaryToBCD = Context.Modules.BinaryToBCD
	local DisplayDriver = Context.Modules.DisplayDriver
	local DisplayController = Context.Modules.DisplayController

	assert(BinaryToBCD,"BinaryToBCD 모듈이 없습니다.")
	assert(DisplayDriver,"DisplayDriver 모듈이 없습니다.")
	assert(DisplayController,"DisplayController 모듈이 없습니다.")

	function DisplayController.Build(
		name,
		origin,
		binaryBus,
		clock
	)
		local converter = BinaryToBCD.Build(
			name.."_BCD",
			origin
		)

		local display = DisplayDriver.Build(
			name.."_DISPLAY",
			origin*CFrame.new(340,0,0),
			5
		)

		converter.ConnectBinaryBus(binaryBus)

		for digit=0,4 do
			display.ConnectDigit(
				digit+1,
				converter.Digits[digit]
			)
		end

		return {
			Converter=converter,
			Display=display,
			Clock=clock
		}
	end

	local Main = Context.Modules.Calculator

	assert(
		Main and type(Main.Build)=="function",
		"Calculator/Main.lua의 Build 함수를 찾지 못했습니다."
	)

	print("[BABFT] 모든 모듈 로드 완료")
	print("[BABFT] 계산기 자동건설 시작")

	local calculator = Main.Build(
		CFrame.new(0,5,0)
	)

	Context.Calculator = calculator
	Context.Ready = true

	print("[BABFT] 계산기 자동건설 요청 완료")
end,debug.traceback)

finish()

if not success then
	warn(
		"[BABFT] 로더 오류\n"
		.. tostring(errorMessage)
	)

	error(errorMessage)
end
