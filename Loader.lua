if not game:IsLoaded() then
	game.Loaded:Wait()
end

local BASE = "https://raw.githubusercontent.com/coogy29-create/BABFT/main/"

local FILES = {
	"Core/Config.lua",
	"Core/Context.lua",
	"Core/Utils.lua",
	"Core/Builder.lua",
	"Core/Bind.lua",
	"Core/Paint.lua",

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
	"Logic/DecimalInput.lua",
	"Logic/BinaryToBCD.lua",

	"Display/Font5x7.lua",
	"Display/DisplayDriver.lua",

	"Calculator/Main.lua"
}

getgenv().BABFT_CALCULATOR = getgenv().BABFT_CALCULATOR or {}

local Context = getgenv().BABFT_CALCULATOR

Context.Modules = {}
Context.State = {}
Context.Ready = false

for _, file in ipairs(FILES) do
	local source = game:HttpGet(BASE .. file .. "?t=" .. tostring(os.time()))
	local chunk, err = loadstring(source, "@BABFT/" .. file)

	if not chunk then
		error("컴파일 실패 : " .. file .. "\n" .. tostring(err))
	end

	local ok, result = pcall(chunk)

	if not ok then
		error("실행 실패 : " .. file .. "\n" .. tostring(result))
	end
end

Context.Ready = true

local Main = Context.Modules.Calculator

if Main and Main.Build then
	Main.Build(CFrame.new(0, 5, 0))
end

print("[BABFT] Calculator Loaded")
