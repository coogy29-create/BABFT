local Context=getgenv().BABFT_CALCULATOR

local Builder=Context.Modules.Builder
local Wiring=Context.Modules.Wiring
local Font=Context.Modules.Font5x7

local DisplayDriver={}

local function P(origin,x,z)
	return origin*CFrame.new(x,0,z)
end

function DisplayDriver.Build(name,origin,digits)

	digits=digits or 5

	local displays={}
	local pixels={}

	for d=1,digits do

		displays[d]={}
		pixels[d]={}

		for row=1,7 do

			pixels[d][row]={}

			for col=1,5 do

				local block=Builder.PlaceNamedBlock(
					string.format(
						"%s_D%d_R%d_C%d",
						name,
						d,
						row,
						col
					),
					"DisplayBlock",
					P(
						origin,
						(d-1)*7+col,
						(row-1)
					)
				)

				pixels[d][row][col]=block
				table.insert(
					displays[d],
					block
				)

			end

		end

	end

	function DisplayDriver.ConnectDigit(index,bus)

		for bit=0,3 do

			Wiring.Connect(
				bus[bit],
				name..
				"_DIGIT_"..
				index..
				"_BIT_"..
				bit
			)

		end

	end

	function DisplayDriver.DrawCharacter(index,ch)

		local pattern=Font.Get(ch)

		for row=1,7 do

			for col=1,5 do

				if pattern[row]:sub(col,col)=="1" then

					Wiring.Connect(
						name..
						"_DIGIT_"..
						index..
						"_BIT_ON",
						pixels[index][row][col]
					)

				else

					Wiring.Connect(
						name..
						"_DIGIT_"..
						index..
						"_BIT_OFF",
						pixels[index][row][col]
					)

				end

			end

		end

	end

	return{

		Digits=displays,

		Pixels=pixels,

		ConnectDigit=DisplayDriver.ConnectDigit,

		DrawCharacter=DisplayDriver.DrawCharacter

	}

end

Context.Modules.DisplayDriver=DisplayDriver

return DisplayDriver
