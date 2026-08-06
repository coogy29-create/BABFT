
local P=game:GetService("Players").LocalPlayer
local UIS=game:GetService("UserInputService")
local WS=game:GetService("Workspace")
local CG=game:GetService("CoreGui")
local Cam=WS.CurrentCamera
local F=WS:WaitForChild("Blocks"):WaitForChild(P.Name)

local GATE_ID,SWITCH_ID,DISPLAY_ID=556,100,4100
local WHITE=Color3.new(0.97254902124405,0.97254902124405,0.97254902124405)
local BLACK=Color3.new(0.066666670143604,0.066666670143604,0.066666670143604)
local ZOFF=Vector3.new(53.565689086914,18,345.50686645508)
local BASE=nil
local RUN=false
local CANCEL=false
local MARK=nil

local DIG={
[0]={"11111","10001","10001","10001","10001","10001","11111"},
[1]={"00100","01100","00100","00100","00100","00100","01110"},
[2]={"11111","00001","00001","11111","10000","10000","11111"},
[3]={"11111","00001","00001","11111","00001","00001","11111"},
[4]={"10001","10001","10001","11111","00001","00001","00001"},
[5]={"11111","10000","10000","11111","00001","00001","11111"},
[6]={"11111","10000","10000","11111","10001","10001","11111"},
[7]={"11111","00001","00010","00100","01000","01000","01000"},
[8]={"11111","10001","10001","11111","10001","10001","11111"},
[9]={"11111","10001","10001","11111","00001","00001","11111"}}

local old=CG:FindFirstChild("BABFTCalcBuilder")
if old then old:Destroy() end

local gui=Instance.new("ScreenGui")
gui.Name="BABFTCalcBuilder"
gui.ResetOnSpawn=false
gui.Parent=CG

local main=Instance.new("Frame")
main.Size=UDim2.fromOffset(330,330)
main.Position=UDim2.new(.5,-165,.5,-165)
main.BackgroundColor3=Color3.fromRGB(28,30,36)
main.BorderSizePixel=0
main.Active=true
main.Parent=gui
Instance.new("UICorner",main).CornerRadius=UDim.new(0,14)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-50,0,42)
title.Position=UDim2.fromOffset(14,4)
title.BackgroundTransparency=1
title.Text="4비트 10진수 계산기 자동건설 V4"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=17
title.Font=Enum.Font.GothamBold
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=main

local close=Instance.new("TextButton")
close.Size=UDim2.fromOffset(34,34)
close.Position=UDim2.new(1,-42,0,7)
close.Text="×"
close.TextSize=22
close.TextColor3=Color3.new(1,1,1)
close.BackgroundColor3=Color3.fromRGB(170,60,60)
close.Parent=main
Instance.new("UICorner",close).CornerRadius=UDim.new(0,9)

local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,-28,0,68)
info.Position=UDim2.fromOffset(14,50)
info.BackgroundColor3=Color3.fromRGB(40,43,52)
info.Text="A/B 4비트 · SUB OFF=덧셈 / ON=뺄셈\nSwitch 자동 근접배선만 해제\n흰색/검은색 이중 출력으로 화면 복원"
info.TextColor3=Color3.fromRGB(220,220,230)
info.TextWrapped=true
info.TextSize=13
info.Parent=main
Instance.new("UICorner",info).CornerRadius=UDim.new(0,9)

local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,-28,0,88)
status.Position=UDim2.fromOffset(14,128)
status.BackgroundColor3=Color3.fromRGB(40,43,52)
status.Text="위치 선택 후 계산기 좌하단을 누르세요."
status.TextColor3=Color3.fromRGB(235,235,240)
status.TextWrapped=true
status.TextSize=14
status.Parent=main
Instance.new("UICorner",status).CornerRadius=UDim.new(0,9)

local sel=Instance.new("TextButton")
sel.Size=UDim2.new(1,-28,0,42)
sel.Position=UDim2.fromOffset(14,226)
sel.Text="위치 선택"
sel.TextColor3=Color3.new(1,1,1)
sel.TextSize=15
sel.Font=Enum.Font.GothamBold
sel.BackgroundColor3=Color3.fromRGB(65,110,200)
sel.Parent=main
Instance.new("UICorner",sel).CornerRadius=UDim.new(0,9)

local start=Instance.new("TextButton")
start.Size=UDim2.new(.65,-18,0,44)
start.Position=UDim2.fromOffset(14,280)
start.Text="자동 건설 시작"
start.TextColor3=Color3.fromRGB(160,160,170)
start.TextSize=15
start.Font=Enum.Font.GothamBold
start.BackgroundColor3=Color3.fromRGB(60,65,75)
start.AutoButtonColor=false
start.Parent=main
Instance.new("UICorner",start).CornerRadius=UDim.new(0,9)

local stop=Instance.new("TextButton")
stop.Size=UDim2.new(.35,-10,0,44)
stop.Position=UDim2.new(.65,4,0,280)
stop.Text="중단"
stop.TextColor3=Color3.new(1,1,1)
stop.TextSize=15
stop.Font=Enum.Font.GothamBold
stop.BackgroundColor3=Color3.fromRGB(160,65,65)
stop.Parent=main
Instance.new("UICorner",stop).CornerRadius=UDim.new(0,9)

do
 local drag=false; local di,ds,sp
 title.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
   drag=true; ds=i.Position; sp=main.Position
  end
 end)
 title.InputChanged:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then di=i end
 end)
 UIS.InputChanged:Connect(function(i)
  if drag and i==di then
   local d=i.Position-ds
   main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
  end
 end)
 UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
 end)
end

local function char() return P.Character or P.CharacterAdded:Wait() end
local function tool(n,equip)
 local c,b=char(),P:WaitForChild("Backpack")
 local t=c:FindFirstChild(n) or b:FindFirstChild(n)
 if t and equip and t.Parent~=c then t.Parent=c task.wait(.15) end
 return t
end
local function snap()
 local s={}
 for _,o in ipairs(F:GetChildren()) do s[o]=true end
 return s
end
local function install(rf,kind,id,cf)
 local z=WS:FindFirstChild("WhiteZone")
 if not z then return nil,"WhiteZone 없음" end
 local before=snap()
 local ok,res=pcall(function()
  return rf:InvokeServer(kind,id,z,CFrame.new(cf.Position+ZOFF)*cf.Rotation,true,cf,false)
 end)
 if not ok then return nil,tostring(res) end
 local deadline=os.clock()+7
 repeat
  if CANCEL then return nil,"중단됨" end
  for _,o in ipairs(F:GetChildren()) do
   if not before[o] and o.Name==kind then return o end
  end
  task.wait(.02)
 until os.clock()>deadline
 return nil,kind.." 생성 감지 시간초과"
end
local function child(o,n)
 local d=os.clock()+5
 repeat
  local c=o and o:FindFirstChild(n)
  if c then return c end
  task.wait(.02)
 until os.clock()>d
end
local function setEnabled(v)
 start.AutoButtonColor=v
 start.BackgroundColor3=v and Color3.fromRGB(45,165,95) or Color3.fromRGB(60,65,75)
 start.TextColor3=v and Color3.new(1,1,1) or Color3.fromRGB(160,160,170)
end

local choosing=false
sel.MouseButton1Click:Connect(function()
 if RUN then return end
 choosing=true
 status.Text="창 밖에서 계산기 좌하단 위치를 누르세요."
end)
UIS.InputBegan:Connect(function(i,p)
 if p or not choosing or RUN then return end
 if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
 local ray=Cam:ViewportPointToRay(i.Position.X,i.Position.Y)
 local rp=RaycastParams.new()
 rp.FilterType=Enum.RaycastFilterType.Exclude
 rp.FilterDescendantsInstances={P.Character,MARK}
 local hit=WS:Raycast(ray.Origin,ray.Direction*3000,rp)
 if not hit then status.Text="위치 감지 실패" return end
 local pos=hit.Position+hit.Normal
 pos=Vector3.new(math.round(pos.X),math.round(pos.Y*10)/10,math.round(pos.Z))
 local right=Cam.CFrame.RightVector
 right=Vector3.new(right.X,0,right.Z)
 right=right.Magnitude<.1 and Vector3.new(1,0,0) or right.Unit
 local up=Vector3.new(0,1,0)
 local back=right:Cross(up)
 back=back.Magnitude<.1 and Vector3.new(0,0,1) or back.Unit
 BASE=CFrame.fromMatrix(pos,right,up,back)
 choosing=false
 if MARK then MARK:Destroy() end
 MARK=Instance.new("Part")
 MARK.Anchored=true
 MARK.CanCollide=false
 MARK.CanQuery=false
 MARK.CanTouch=false
 MARK.Material=Enum.Material.Neon
 MARK.Color=Color3.fromRGB(0,230,255)
 MARK.Transparency=.55
 MARK.Size=Vector3.new(72,44,48)
 MARK.CFrame=BASE*CFrame.new(36,22,0)
 MARK.Parent=WS
 status.Text=string.format("위치 선택 완료\nX %.1f / Y %.1f / Z %.1f",pos.X,pos.Y,pos.Z)
 setEnabled(true)
end)

stop.MouseButton1Click:Connect(function()
 if RUN then CANCEL=true status.Text="중단 요청됨" end
end)

local function fail(m)
 status.Text=m
 RUN=false
 start.Text="다시 시작"
 setEnabled(BASE~=nil)
end

local function objectPosition(o)
 if not o then return nil end
 if o:IsA("Model") then
  return o:GetPivot().Position
 elseif o:IsA("BasePart") then
  return o.Position
 end
 return nil
end

local function nearestCompatibleTarget(source, previousObjects)
 local sourcePos=objectPosition(source)
 if not sourcePos then return nil,nil end

 local best,bestBind,bestDistance=nil,nil,math.huge

 for _,target in ipairs(previousObjects) do
  if target and target.Parent then
   local bind=target:FindFirstChild("BindActivate")
   if not bind then bind=target:FindFirstChild("BindFire") end

   if bind then
    local targetPos=objectPosition(target)
    if targetPos then
     local distance=(targetPos-sourcePos).Magnitude
     if distance<bestDistance then
      bestDistance=distance
      best=target
      bestBind=bind
     end
    end
   end
  end
 end

 return best,bestBind
end

local function removeAutoNearestLink(bindRF,source,previousObjects)
 if not source then return true end

 local _,targetBind=nearestCompatibleTarget(source,previousObjects)
 if not targetBind then return true end

 local ok,result=pcall(function()
  return bindRF:InvokeServer(
   {Activate={targetBind}},
   source,
   {},
   true,
   true
  )
 end)

 return ok,result
end

local function build()
 if RUN or not BASE then return end
 RUN=true
 CANCEL=false
 setEnabled(false)
 start.Text="건설 중..."

 local bt=tool("BuildingTool",false)
 local pt=tool("PropertiesTool",true)
 local bind=tool("BindTool",true)
 local paint=tool("PaintingTool",false)
 if not bt or not pt or not bind or not paint then
  return fail("Building/Properties/Bind/Painting 도구가 필요합니다.")
 end
 local brf=bt:WaitForChild("RF")
 local prf=pt:WaitForChild("SetPropertieRF")
 local rbf=bind:WaitForChild("RF")
 local paintRF=paint:WaitForChild("RF")

 local specs,edges,outs={}, {}, {}
 local nodes={}
 local generatedOrder={}
 local whiteOutputNames={}
 local blackOutputNames={}
 local gateGroups={And={},Or={},Xor={},Not={}}
 local gi=0

 local function sw(n,x)
  specs[#specs+1]={n=n,k="Switch",id=SWITCH_ID,cf=BASE*CFrame.new(x,0,24)}
  return n
 end
 local function gate(n,t)
  gi+=1
  local col=(gi-1)%12
  local row=math.floor((gi-1)/12)
  specs[#specs+1]={n=n,k="Gate",id=GATE_ID,t=t,cf=BASE*CFrame.new(2+col*3,-5-row*2.3,-24)}
  return n
 end
 local function disp(n,x,y)
  specs[#specs+1]={n=n,k="DisplayBlock",id=DISPLAY_ID,cf=BASE*CFrame.new(x,y,0)}
  return n
 end
 local function con(a,b) edges[#edges+1]={a,b} end
 local function out(a,b) outs[#outs+1]={a,b} end

 local A,B={},{}
 for bit=0,3 do
  A[bit]=sw("A"..bit,bit*3)
  B[bit]=sw("B"..bit,18+bit*3)
 end
 sw("SUB",36)

 local SUM={}
 local carry="SUB"
 for bit=0,3 do
  local bx=gate("BX"..bit,"Xor"); con(B[bit],bx); con("SUB",bx)
  local x1=gate("SX1_"..bit,"Xor"); con(A[bit],x1); con(bx,x1)
  local s=gate("SUM_"..bit,"Xor"); con(x1,s); con(carry,s); SUM[bit]=s
  local a1=gate("CA1_"..bit,"And"); con(A[bit],a1); con(bx,a1)
  local a2=gate("CA2_"..bit,"And"); con(carry,a2); con(x1,a2)
  local cn=gate("CARRY_"..(bit+1),"Or"); con(a1,cn); con(a2,cn)
  carry=cn
 end
 local C4=carry
 local nc4=gate("NOT_C4","Not"); con(C4,nc4)
 local sign=gate("SIGN","And"); con("SUB",sign); con(nc4,sign)
 local nsub=gate("NOT_SUB","Not"); con("SUB",nsub)

 local M={}
 local mc=sign
 for bit=0,3 do
  local t=gate("MT_"..bit,"Xor"); con(SUM[bit],t); con(sign,t)
  local m=gate("MAG_"..bit,"Xor"); con(t,m); con(mc,m); M[bit]=m
  local n=gate("MC_"..(bit+1),"And"); con(t,n); con(mc,n); mc=n
 end
 M[4]=gate("MAG_4","And"); con(C4,M[4]); con(nsub,M[4])

 local NM={}
 for bit=0,4 do NM[bit]=gate("NM_"..bit,"Not"); con(M[bit],NM[bit]) end

 local V={}
 for v=0,30 do
  V[v]=gate("V_"..v,"And")
  for bit=0,4 do
   con(math.floor(v/2^bit)%2==1 and M[bit] or NM[bit],V[v])
  end
 end

 local TD,OD={},{}
 for r=1,7 do
  TD[r]={}; OD[r]={}
  for c=1,5 do
   TD[r][c]=disp(("T_%d_%d"):format(r,c),46+(c-1)*2,14+(7-r)*2)
   OD[r][c]=disp(("O_%d_%d"):format(r,c),60+(c-1)*2,14+(7-r)*2)
  end
 end
 local notSign=gate("NOT_SIGN","Not")
 con(sign,notSign)
 whiteOutputNames[sign]=true
 blackOutputNames[notSign]=true

 for c=1,5 do
  local minusDisplay=disp("MINUS_"..c,34+(c-1)*2,20)
  out(sign,minusDisplay)
  out(notSign,minusDisplay)
 end

 for r=1,7 do
  for c=1,5 do
   local tg=gate(("TP_%d_%d"):format(r,c),"Or")
   local og=gate(("OP_%d_%d"):format(r,c),"Or")

   for v=0,30 do
    local t=math.floor(v/10)
    local o=v%10
    if v>=10 and DIG[t][r]:sub(c,c)=="1" then con(V[v],tg) end
    if DIG[o][r]:sub(c,c)=="1" then con(V[v],og) end
   end

   local tBlack=gate(("TP_BLACK_%d_%d"):format(r,c),"Not")
   local oBlack=gate(("OP_BLACK_%d_%d"):format(r,c),"Not")
   con(tg,tBlack)
   con(og,oBlack)

   whiteOutputNames[tg]=true
   whiteOutputNames[og]=true
   blackOutputNames[tBlack]=true
   blackOutputNames[oBlack]=true

   out(tg,TD[r][c])
   out(tBlack,TD[r][c])
   out(og,OD[r][c])
   out(oBlack,OD[r][c])
  end
 end

 table.sort(specs,function(a,b)
  local priority={Gate=1,DisplayBlock=2,Switch=3}
  local pa=priority[a.k] or 99
  local pb=priority[b.k] or 99
  if pa==pb then return a.n<b.n end
  return pa<pb
 end)

 for i,s in ipairs(specs) do
  if CANCEL then return fail("중단됨") end
  status.Text=("블록 설치 중\n%d / %d\n%s"):format(i,#specs,s.n)
  local o,e=install(brf,s.k,s.id,s.cf)
  if not o then return fail("설치 실패: "..s.n.."\n"..tostring(e)) end
  nodes[s.n]=o

  if s.k=="Switch" then
   status.Text=("자동 근접배선 해제 중\n%d / %d\n%s"):format(i,#specs,s.n)

   local clearOk,clearResult=removeAutoNearestLink(
    rbf,
    o,
    generatedOrder
   )

   if not clearOk then
    return fail(
     "자동 연결 해제 실패: "
     ..s.n
     .."\n"
     ..tostring(clearResult)
    )
   end
  end

  generatedOrder[#generatedOrder+1]=o

  if s.k=="Gate" then gateGroups[s.t][#gateGroups[s.t]+1]=o end
  task.wait(.03)
 end

 status.Text="Switch 자동 근접배선 정리 완료"
 task.wait(.3)

 status.Text="Gate 종류 설정 중..."
 for t,list in pairs(gateGroups) do
  local ok,e=pcall(function() return prf:InvokeServer(t,list) end)
  if not ok then return fail("Gate 설정 실패\n"..tostring(e)) end
  task.wait(.05)
 end

 status.Text="화면 출력 Gate 색상 설정 중..."
 local paintEntries={}

 for name in pairs(whiteOutputNames) do
  local object=nodes[name]
  if object then paintEntries[#paintEntries+1]={object,WHITE} end
 end

 for name in pairs(blackOutputNames) do
  local object=nodes[name]
  if object then paintEntries[#paintEntries+1]={object,BLACK} end
 end

 for first=1,#paintEntries,80 do
  local batch={}
  local last=math.min(first+79,#paintEntries)

  for index=first,last do
   batch[#batch+1]=paintEntries[index]
  end

  local ok,e=pcall(function()
   return paintRF:InvokeServer(batch)
  end)

  if not ok then
   return fail("출력 Gate 색칠 실패\n"..tostring(e))
  end

  task.wait(.05)
 end

 local grouped={}
 for _,e in ipairs(edges) do
  grouped[e[1]]=grouped[e[1]] or {}
  grouped[e[1]][#grouped[e[1]]+1]={e[2],"BindActivate"}
 end
 for _,e in ipairs(outs) do
  grouped[e[1]]=grouped[e[1]] or {}
  grouped[e[1]][#grouped[e[1]]+1]={e[2],"BindFire"}
 end

 local names={}
 for n in pairs(grouped) do names[#names+1]=n end
 table.sort(names)
 for i,n in ipairs(names) do
  if CANCEL then return fail("중단됨") end
  status.Text=("자동 배선 중\n%d / %d\n%s"):format(i,#names,n)
  local targets={}
  for _,t in ipairs(grouped[n]) do
   local obj=nodes[t[1]]
   local bv=child(obj,t[2])
   if not bv then return fail("단자 없음: "..t[1].."."..t[2]) end
   targets[#targets+1]=bv
  end
  local ok,e=pcall(function()
   return rbf:InvokeServer({Activate=targets},nodes[n],{},false,true)
  end)
  if not ok then return fail("배선 실패: "..n.."\n"..tostring(e)) end
  task.wait(.02)
 end

 if MARK then MARK:Destroy() MARK=nil end
 getgenv().BABFT4BitDecimalCalculator={Nodes=nodes,Base=BASE}
 RUN=false
 start.Text="완료"
 setEnabled(true)
 status.Text="완성\n흰색/검은색 양방향 화면 출력 적용\nSUB OFF=덧셈 / ON=뺄셈"
end

start.MouseButton1Click:Connect(function()
 if not BASE then status.Text="먼저 위치를 선택하세요." return end
 task.spawn(build)
end)

close.MouseButton1Click:Connect(function()
 CANCEL=true
 if MARK then MARK:Destroy() end
 gui:Destroy()
end)
