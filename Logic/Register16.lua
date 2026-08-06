local Context=getgenv().BABFT_CALCULATOR

local Register1=Context.Modules.Register1
local Wiring=Context.Modules.Wiring

local Register16={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function Register16.Build(name,origin)

	local bits={}
	local outputs={}
	local invertedOutputs={}
	local dataTargets={}
	local clockTargets={}

	for bit=0,15 do

		local cell=Register1.Build(
			name.."_BIT_"..bit,
			P(
				origin,
				(bit%4)*28,
				math.floor(bit/4)*14
			)
		)

		bits[bit]=cell
		outputs[bit]=cell.Q
		invertedOutputs[bit]=cell.QB

		dataTargets[bit]={
			name.."_BIT_"..bit.."_DLATCH_NOT_D",
			name.."_BIT_"..bit.."_DLATCH_SET"
		}

		clockTargets[bit]={
			name.."_BIT_"..bit.."_DLATCH_SET",
			name.."_BIT_"..bit.."_DLATCH_RESET"
		}

	end

	function bits.ConnectData(inputBus)

		for bit=0,15 do

			for _,target in ipairs(
				dataTargets[bit]
			) do

				Wiring.Connect(
					inputBus[bit],
					target
				)

			end

		end

	end

	function bits.ConnectClock(clockSource)

		for bit=0,15 do

			for _,target in ipairs(
				clockTargets[bit]
			) do

				Wiring.Connect(
					clockSource,
					target
				)

			end

		end

	end

	return{
		Bits=bits,
		Q=outputs,
		QB=invertedOutputs,
		ConnectData=bits.ConnectData,
		ConnectClock=bits.ConnectClock
	}

end

Context.Modules.Register16=Register16

return Register16
