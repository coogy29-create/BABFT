if not game:IsLoaded() then
	game.Loaded:Wait()
end

local REPOSITORY =
	"https://raw.githubusercontent.com/coogy29-create/BABFT/refs/heads/main/"

local FILES = {
	"Core/Config.lua",
	"Core/Context.lua",
	"Core/Utils.lua",
	"Core/Builder.lua",
	"Core/Bind.lua",
	"Core/Paint.lua",
	"Core/UI.lua",

	"Logic/GateLibrary.lua",
	"Logic/Latch.lua",
	"Logic/Register.lua",
	"Logic/AdderSubtractor16.lua",
	"Logic/DecimalInput.lua",
	"Logic/BinaryToBCD.lua",

	"Display/Font5x7.lua",
	"Display/DisplayDriver.lua",

	"Calculator/Main.lua"
}

local Environment = getgenv()

if Environment.BABFT_CALCULATOR
	and Environment.BABFT_CALCULATOR.Running then
	warn("BABFT 계산기 로더가 이미 실행 중입니다.")
	return
end

Environment.BABFT_CALCULATOR = {
	Version = "0.1.0",
	Running = true,
	Modules = {},
	State = {},
	LoadedFiles = {},
	BaseURL = REPOSITORY
}

local Context = Environment.BABFT_CALCULATOR

local function downloadFile(fileName)
	local url =
		REPOSITORY
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
			"파일 다운로드 실패\n"
			.. fileName
			.. "\n"
			.. tostring(source)
		)
	end

	if type(source) ~= "string" or source == "" then
		error("빈 파일을 받았습니다: " .. fileName)
	end

	if source:find("404: Not Found", 1, true) then
		error("GitHub에 파일이 없습니다: " .. fileName)
	end

	return source
end

local function executeFile(fileName, source)
	local chunk, compileError = loadstring(
		source,
		"@BABFT/" .. fileName
	)

	if not chunk then
		error(
			"파일 컴파일 실패\n"
			.. fileName
			.. "\n"
			.. tostring(compileError)
		)
	end

	local success, result = pcall(chunk)

	if not success then
		error(
			"파일 실행 실패\n"
			.. fileName
			.. "\n"
			.. tostring(result)
		)
	end

	Context.LoadedFiles[fileName] = true

	if result ~= nil then
		Context.Modules[fileName] = result
	end

	return result
end

local success, errorMessage = xpcall(function()
	for index, fileName in ipairs(FILES) do
		print(
			string.format(
				"[BABFT] %d/%d 불러오는 중: %s",
				index,
				#FILES,
				fileName
			)
		)

		local source = downloadFile(fileName)
		executeFile(fileName, source)

		task.wait()
	end

	Context.Running = false
	Context.Ready = true

	print("[BABFT] 16비트 계산기 모듈 로드 완료")
end, debug.traceback)

if not success then
	Context.Running = false
	Context.Ready = false
	Context.LastError = errorMessage

	warn(
		"[BABFT] 로더 실행 실패\n"
		.. tostring(errorMessage)
	)
end
