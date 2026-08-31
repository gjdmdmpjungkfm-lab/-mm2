local P=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local TS=game:GetService("TweenService")
local LP=P.LocalPlayer or P:GetPropertyChangedSignal("LocalPlayer"):Wait() and P.LocalPlayer
local PG=LP:WaitForChild("PlayerGui",10)if PG:FindFirstChild("UIM_Menu")then PG.UIM_Menu:Destroy()end
local SG=Instance.new("ScreenGui",PG)SG.Name,SG.ResetOnSpawn,SG.DisplayOrder="UIM_Menu",false,999999
local MF=Instance.new("Frame",SG)MF.Size,MF.Position,MF.BackgroundColor3=UDim2.new(0,430,0,270),UDim2.new(0.5,-215,0.5,-135),Color3.fromRGB(15,12,22)MF.BackgroundTransparency,MF.BorderSizePixel,MF.Active,MF.Visible=0.4,0,true,true
local MS=Instance.new("UIScale",MF)Instance.new("UICorner",MF).CornerRadius=UDim.new(0,8)local US=Instance.new("UIStroke",MF)US.Color,US.Thickness=Color3.fromRGB(160,80,220),1.5
local H=Instance.new("Frame",MF)H.Size,H.BackgroundColor3,H.BackgroundTransparency,H.BorderSizePixel,H.Active=UDim2.new(1,0,0,46),Color3.fromRGB(22,17,32),0.2,0,true
Instance.new("UICorner",H).CornerRadius=UDim.new(0,8)
local LB=Instance.new("Frame",H)LB.Size,LB.Position,LB.BackgroundColor3,LB.BorderSizePixel=UDim2.new(0,26,0,26),UDim2.new(0,6,0,10),Color3.fromRGB(130,50,200),0
Instance.new("UICorner",LB).CornerRadius=UDim.new(0,6)local LT=Instance.new("TextLabel",LB)LT.Size,LT.BackgroundTransparency,LT.Text,LT.TextColor3,LT.TextSize,LT.Font=UDim2.new(1,0,1,0),1,"U",Color3.new(1,1,1),17,Enum.Font.GothamBold
local T=Instance.new("TextLabel",H)T.Size,T.Position,T.BackgroundTransparency,T.Text,T.TextColor3,T.TextSize,T.Font,T.TextXAlignment=UDim2.new(0,330,0,18),UDim2.new(0,40,0,5),1,"UltimateMM2 Hub",Color3.fromRGB(240,220,255),14,Enum.Font.GothamBold,Enum.TextXAlignment.Left
local ST=Instance.new("TextLabel",H)ST.Size,ST.Position,ST.BackgroundTransparency,ST.Text,ST.TextColor3,ST.TextSize,ST.Font,ST.TextXAlignment=UDim2.new(0,330,0,16),UDim2.new(0,40,0,23),1,"t.me/UltimateHub_Official",Color3.fromRGB(160,130,200),10,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local MB=Instance.new("TextButton",H)MB.Size,MB.Position,MB.BackgroundColor3,MB.BorderSizePixel,MB.Text,MB.TextColor3,MB.TextSize,MB.Font=UDim2.new(0,30,0,26),UDim2.new(1,-36,0,10),Color3.fromRGB(45,30,70),0,"—",Color3.fromRGB(230,170,255),15,Enum.Font.GothamBold
Instance.new("UICorner",MB).CornerRadius=UDim.new(0,6)
local OB=Instance.new("TextButton",SG)OB.Size,OB.Position,OB.BackgroundColor3,OB.BorderSizePixel,OB.Text,OB.TextColor3,OB.TextSize,OB.Font,OB.Visible,OB.ZIndex=UDim2.new(0,45,0,45),UDim2.new(0.1,0,0.2,0),Color3.fromRGB(25,18,38),0,"U",Color3.fromRGB(200,100,255),24,Enum.Font.GothamBold,false,100
Instance.new("UICorner",OB).CornerRadius=UDim.new(0,10)local OS=Instance.new("UIStroke",OB)OS.Color,OS.Thickness=Color3.fromRGB(160,80,220),2
local TF=Instance.new("Frame",MF)TF.Size,TF.Position,TF.BackgroundTransparency=UDim2.new(1,-16,0,28),UDim2.new(0,8,0,53),1

local tabs={"FEATURES","SETTINGS"}local tContent,tBtns={},{}
local CP=Instance.new("Frame",MF)CP.Size,CP.Position,CP.BackgroundTransparency,CP.ClipsDescendants=UDim2.new(1,-16,1,-89),UDim2.new(0,8,0,85),1,true
local espE,aimE,autoGunE,speedE,autoFarmE,avoidMurdE=false,false,false,false,false,false
local avoidRadius = 100
local hls={}
local collectedCoins = {}
local collectedPositions = {}

local controls = nil
pcall(function()
    controls = require(LP:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
end)

local function setControlsLocked(locked)
    pcall(function()
        if controls then
            if locked then controls:Disable() else controls:Enable() end
        end
    end)
end

local function getRole(p)
local c,bp=p.Character,p:FindFirstChild("Backpack")
local function chk(n)return(c and c:FindFirstChild(n))or(bp and bp:FindFirstChild(n))end
return chk("Knife")and"Murderer"or chk("Gun")and"Sheriff"or"Innocent"
end

local function isPlayerAlive(c)
if not c then return false end
local hum = c:FindFirstChildOfClass("Humanoid")
local hrp = c:FindFirstChild("HumanoidRootPart")
return hum and hrp and hum.Health > 0
end

local function getMurdererHRP()
for _, p in ipairs(P:GetPlayers()) do
if p ~= LP and getRole(p) == "Murderer" and isPlayerAlive(p.Character) then
return p.Character:FindFirstChild("HumanoidRootPart")
end
end
return nil
end

local function getClosestCoin(hrp)
local closestPart = nil
local shortestDist = 1000
local currentTime = tick()

for coin, t in pairs(collectedCoins) do
if currentTime - t > 3 then collectedCoins[coin] = nil end
end

for pos, t in pairs(collectedPositions) do
if currentTime - t > 3 then collectedPositions[pos] = nil end
end

local function evaluate(obj)
if collectedCoins[obj] then return end
local tp = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
if tp and not collectedCoins[tp] then
if tp.Position.Y > 500 or tp.Position.Y < -200 then return end

local posIgnored = false
for pPos, _ in pairs(collectedPositions) do
if (tp.Position - pPos).Magnitude < 4 then posIgnored = true; break end
end
if posIgnored then return end

local dist = (hrp.Position - tp.Position).Magnitude
if dist < shortestDist then
shortestDist = dist
closestPart = tp
end
end
end

for _, obj in ipairs(WS:GetChildren()) do
if obj.Name == "CoinContainer" or obj.Name == "Coins" then
for _, coin in ipairs(obj:GetChildren()) do evaluate(coin) end
end
end

for _, obj in ipairs(WS:GetDescendants()) do
if obj.Name == "Coin_Server" or obj.Name == "CoinVisual" or obj.Name == "Coin" then evaluate(obj) end
end

return closestPart
end

local function tweenToTarget(hrp, tp)
if not hrp or not tp then return end

if tp.Position.Y > 500 or tp.Position.Y < -200 then collectedCoins[tp] = tick(); return end

local targetPos = tp.Position
local distance = (hrp.Position - targetPos).Magnitude
if distance > 1000 then return end

if firetouchinterest then pcall(function() firetouchinterest(hrp, tp, 0); firetouchinterest(hrp, tp, 1) end) end

local speed = 26
local timeTaken = distance / speed
if timeTaken < 0.05 then collectedCoins[tp] = tick(); collectedPositions[targetPos] = tick(); return end

local tweenInfo = TweenInfo.new(timeTaken, Enum.EasingStyle.Linear)
local tween = TS:Create(hrp, tweenInfo, {CFrame = tp.CFrame})
tween:Play()

local completed = false
local conn
conn = tween.Completed:Connect(function()
completed = true
if conn then conn:Disconnect() end
end)

local startTick = tick()
while not completed and tick() - startTick < timeTaken + 0.5 do
local c = LP.Character
if not c or not isPlayerAlive(c) or not autoFarmE then tween:Cancel(); break end

if avoidMurdE then
local murdHRP = getMurdererHRP()
if murdHRP and (hrp.Position - murdHRP.Position).Magnitude < avoidRadius then tween:Cancel(); break end
end

task.wait(0.05)
end

if not completed then pcall(function() tween:Cancel() end); if conn then conn:Disconnect() end end

collectedCoins[tp] = tick()
if tp.Parent then collectedCoins[tp.Parent] = tick() end
collectedPositions[targetPos] = tick()

task.wait(0.08)
end

-- Оптимизация ESP через задержку (троттлинг), чтобы игра не лагала
local espTick = 0
RS.RenderStepped:Connect(function()
local now = tick()
if now - espTick > 0.15 then
espTick = now
if espE then
for _,p in ipairs(P:GetPlayers())do
if p~=LP and p.Character then
local c,hl=p.Character,hls[p]
if not hl or hl.Parent~=c then
if hl then pcall(function() hl:Destroy()end)end
hl=Instance.new("Highlight",c)hl.FillTransparency,hl.OutlineTransparency=0.4,0;hls[p]=hl
end
local r=getRole(p)hl.FillColor=r=="Murderer"and Color3.fromRGB(255,40,40)or r=="Sheriff"and Color3.fromRGB(40,120,255)or Color3.fromRGB(40,255,40)
end
end
else
for p,hl in pairs(hls)do if hl then pcall(function() hl:Destroy()end)hls[p]=nil end end
end
end

if aimE then
pcall(function()
local mr=getRole(LP)
if mr=="Murderer" or mr=="Sheriff" then
local cam=WS.CurrentCamera
local closestDist = math.huge
local targetPart = nil
for _,p in ipairs(P:GetPlayers())do
if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart")then
local tr=getRole(p)
if(mr=="Murderer" and tr=="Sheriff")or(mr=="Sheriff" and tr=="Murderer")then
local rp = p.Character.HumanoidRootPart
local dist = (rp.Position - cam.CFrame.Position).Magnitude
if dist < closestDist then closestDist = dist; targetPart = rp end
end
end
end
if targetPart then cam.CFrame = CFrame.new(cam.CFrame.Position, targetPart.Position) end
end
end)
end

pcall(function()
local c=LP.Character
if c then
local hum=c:FindFirstChildOfClass("Humanoid")
if hum and not autoFarmE then hum.WalkSpeed=speedE and 31 or(hum.WalkSpeed==31 and 16 or hum.WalkSpeed) end
end
end)
end)

task.spawn(function()
local wasActive = false
while true do
task.wait(0.2)
if autoFarmE then
if not wasActive then wasActive = true; setControlsLocked(true) end
pcall(function()
local c = LP.Character
if isPlayerAlive(c) then
local hrp = c.HumanoidRootPart
local hum = c:FindFirstChildOfClass("Humanoid")

if hum then
hum.WalkSpeed = 0
hum.JumpPower = 0
for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
end

while autoFarmE and isPlayerAlive(c) do
if avoidMurdE then
local murdHRP = getMurdererHRP()
if murdHRP then
local mDist = (hrp.Position - murdHRP.Position).Magnitude
if mDist < avoidRadius then
local escapeDir = (hrp.Position - murdHRP.Position).Unit
local safePos = hrp.Position + (escapeDir * (avoidRadius - mDist + 20))
safePos = Vector3.new(safePos.X, hrp.Position.Y, safePos.Z)

local escapeTween = TS:Create(hrp, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {CFrame = CFrame.new(safePos)})
escapeTween:Play()
task.wait(0.6)
continue
end
end
end

local targetCoin = getClosestCoin(hrp)
if targetCoin then tweenToTarget(hrp, targetCoin) else break end
end
end
end)
else
if wasActive then
wasActive = false
setControlsLocked(false)
pcall(function()
local c = LP.Character
if c then
local hum = c:FindFirstChildOfClass("Humanoid")
if hum then hum.JumpPower = 50; hum.WalkSpeed = speedE and 31 or 16 end
end
end)
end
end
end
end)

task.spawn(function()
while true do
task.wait(0.5)
if autoGunE then
pcall(function()
local c = LP.Character
if isPlayerAlive(c) then
local hrp = c.HumanoidRootPart
for _,obj in ipairs(WS:GetDescendants())do
if not autoGunE then break end
if obj.Name=="GunDrop" or obj.Name=="GunServer" then
local tp=obj:IsA("BasePart")and obj or obj:FindFirstChildWhichIsA("BasePart")
if tp then tweenToTarget(hrp,tp) end
end
end
end
end)
end
end
end)

local function bBtn(b,cb)
b.Activated:Connect(function()
pcall(function()
TS:Create(b,TweenInfo.new(0.06),{Size=b.Size-UDim2.new(0,4,0,4)}):Play()
task.delay(0.06,function() TS:Create(b,TweenInfo.new(0.06),{Size=b.Size+UDim2.new(0,4,0,4)}):Play()end)
end)
cb()
end)
end

local function cTogGrid(par,txt,x,y,cb,disabled)
local r=Instance.new("Frame",par)r.Size,r.Position,r.BackgroundTransparency=UDim2.new(0.48,0,0,32),UDim2.new(x,0,0,y),1
local l=Instance.new("TextLabel",r)l.Size,l.BackgroundTransparency,l.Text,l.TextColor3,l.TextSize,l.Font,l.TextXAlignment=UDim2.new(1,-42,1,0),1,txt,disabled and Color3.fromRGB(130,120,140) or Color3.fromRGB(230,220,245),10,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local tb=Instance.new("TextButton",r)tb.Size,tb.Position,tb.BackgroundColor3,tb.BorderSizePixel,tb.Text=UDim2.new(0,38,0,22),UDim2.new(1,-38,0.5,-11),disabled and Color3.fromRGB(30,25,40) or Color3.fromRGB(45,35,65),0,""
Instance.new("UICorner",tb).CornerRadius=UDim.new(1,0)
local c=Instance.new("Frame",tb)c.Size,c.Position,c.BackgroundColor3,c.BorderSizePixel=UDim2.new(0,16,0,16),UDim2.new(0,3,0.5,-8),disabled and Color3.fromRGB(80,70,95) or Color3.fromRGB(200,180,220),0
Instance.new("UICorner",c).CornerRadius=UDim.new(1,0)

if not disabled then
local st=false
bBtn(tb,function()
st=not st
TS:Create(tb,TweenInfo.new(0.15),{BackgroundColor3=st and Color3.fromRGB(150,70,220)or Color3.fromRGB(45,35,65)}):Play()
TS:Create(c,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-19,0.5,-8)or UDim2.new(0,3,0.5,-8),BackgroundColor3=st and Color3.new(1,1,1)or Color3.fromRGB(200,180,220)}):Play()
cb(st)
end)
end
end

for i,tn in ipairs(tabs)do
local b=Instance.new("TextButton",TF)b.Size,b.Position,b.BackgroundColor3,b.BorderSizePixel,b.Text,b.TextColor3,b.TextSize,b.Font=UDim2.new(0.485,0,1,0),UDim2.new((i-1)*0.515,0,0,0),i==1 and Color3.fromRGB(75,35,125)or Color3.fromRGB(22,18,32),0,tn,i==1 and Color3.new(1,1,1)or Color3.fromRGB(150,130,180),11,Enum.Font.GothamBold
Instance.new("UICorner",b).CornerRadius=UDim.new(0,6);tBtns[tn]=b
local cnt=Instance.new("Frame",CP)cnt.Size,cnt.BackgroundTransparency,cnt.BorderSizePixel,cnt.Visible=UDim2.new(1,0,1,0),1,0,i==1;tContent[tn]=cnt

if tn=="FEATURES" then 
cTogGrid(cnt,"ESP",0,5,function(s) espE=s end)
cTogGrid(cnt,"Aim Bot",0.52,5,function(s) aimE=s end)
cTogGrid(cnt,"Auto Gun",0,42,function(s) autoGunE=s end)
cTogGrid(cnt,"Speed 31",0.52,42,function(s) speedE=s end)

local afSub=Instance.new("Frame",cnt)afSub.Size,afSub.Position,afSub.BackgroundColor3,afSub.BackgroundTransparency,afSub.BorderSizePixel=UDim2.new(1,0,0,82),UDim2.new(0,0,0,79),Color3.fromRGB(20,15,30),0.3,0
Instance.new("UICorner",afSub).CornerRadius=UDim.new(0,6)local afSubS=Instance.new("UIStroke",afSub)afSubS.Color,afSubS.Thickness=Color3.fromRGB(130,60,190),1.2

local r1=Instance.new("Frame",afSub)r1.Size,r1.Position,r1.BackgroundTransparency=UDim2.new(0.48,0,0,32),UDim2.new(0.02,0,0,6),1
local l1=Instance.new("TextLabel",r1)l1.Size,l1.BackgroundTransparency,l1.Text,l1.TextColor3,l1.TextSize,l1.Font,l1.TextXAlignment=UDim2.new(1,-42,1,0),1,"Auto Farm",Color3.fromRGB(230,220,245),10,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local tb1=Instance.new("TextButton",r1)tb1.Size,tb1.Position,tb1.BackgroundColor3,tb1.BorderSizePixel,tb1.Text=UDim2.new(0,38,0,22),UDim2.new(1,-38,0.5,-11),Color3.fromRGB(45,35,65),0,""
Instance.new("UICorner",tb1).CornerRadius=UDim.new(1,0)local c1=Instance.new("Frame",tb1)c1.Size,c1.Position,c1.BackgroundColor3,c1.BorderSizePixel=UDim2.new(0,16,0,16),UDim2.new(0,3,0.5,-8),Color3.fromRGB(200,180,220),0
Instance.new("UICorner",c1).CornerRadius=UDim.new(1,0)
bBtn(tb1,function()
autoFarmE=not autoFarmE
TS:Create(tb1,TweenInfo.new(0.15),{BackgroundColor3=autoFarmE and Color3.fromRGB(150,70,220)or Color3.fromRGB(45,35,65)}):Play()
TS:Create(c1,TweenInfo.new(0.15),{Position=autoFarmE and UDim2.new(1,-19,0.5,-8)or UDim2.new(0,3,0.5,-8),BackgroundColor3=autoFarmE and Color3.new(1,1,1)or Color3.fromRGB(200,180,220)}):Play()
end)

local r2=Instance.new("Frame",afSub)r2.Size,r2.Position,r2.BackgroundTransparency=UDim2.new(0.48,0,0,32),UDim2.new(0.52,0,0,6),1
local l2=Instance.new("TextLabel",r2)l2.Size,l2.BackgroundTransparency,l2.Text,l2.TextColor3,l2.TextSize,l2.Font,l2.TextXAlignment=UDim2.new(1,-42,1,0),1,"Избегать убийцу",Color3.fromRGB(230,220,245),10,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local tb2=Instance.new("TextButton",r2)tb2.Size,tb2.Position,tb2.BackgroundColor3,tb2.BorderSizePixel,tb2.Text=UDim2.new(0,38,0,22),UDim2.new(1,-38,0.5,-11),Color3.fromRGB(45,35,65),0,""
Instance.new("UICorner",tb2).CornerRadius=UDim.new(1,0)local c2=Instance.new("Frame",tb2)c2.Size,c2.Position,c2.BackgroundColor3,c2.BorderSizePixel=UDim2.new(0,16,0,16),UDim2.new(0,3,0.5,-8),Color3.fromRGB(200,180,220),0
Instance.new("UICorner",c2).CornerRadius=UDim.new(1,0)
bBtn(tb2,function()
avoidMurdE=not avoidMurdE
TS:Create(tb2,TweenInfo.new(0.15),{BackgroundColor3=avoidMurdE and Color3.fromRGB(150,70,220)or Color3.fromRGB(45,35,65)}):Play()
TS:Create(c2,TweenInfo.new(0.15),{Position=avoidMurdE and UDim2.new(1,-19,0.5,-8)or UDim2.new(0,3,0.5,-8),BackgroundColor3=avoidMurdE and Color3.new(1,1,1)or Color3.fromRGB(200,180,220)}):Play()
end)

local rLbl=Instance.new("TextLabel",afSub)rLbl.Size,rLbl.Position,rLbl.BackgroundTransparency,rLbl.Text,rLbl.TextColor3,rLbl.TextSize,rLbl.Font,rLbl.TextXAlignment=UDim2.new(0,180,0,26),UDim2.new(0,8,0,46),1,"Радиус от убийцы ("..avoidRadius..")",Color3.fromRGB(210,200,230),11,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local rMn=Instance.new("TextButton",afSub)rMn.Size,rMn.Position,rMn.BackgroundColor3,rMn.BorderSizePixel,rMn.Text,rMn.TextColor3,rMn.TextSize,rMn.Font=UDim2.new(0,35,0,24),UDim2.new(1,-82,0,47),Color3.fromRGB(50,35,80),0,"-",Color3.new(1,1,1),16,Enum.Font.GothamBold
Instance.new("UICorner",rMn).CornerRadius=UDim.new(0,6)
local rPl=Instance.new("TextButton",afSub)rPl.Size,rPl.Position,rPl.BackgroundColor3,rPl.BorderSizePixel,rPl.Text,rPl.TextColor3,rPl.TextSize,rPl.Font=UDim2.new(0,35,0,24),UDim2.new(1,-42,0,47),Color3.fromRGB(50,35,80),0,"+",Color3.new(1,1,1),16,Enum.Font.GothamBold
Instance.new("UICorner",rPl).CornerRadius=UDim.new(0,6)
bBtn(rPl,function()if avoidRadius < 300 then avoidRadius = avoidRadius + 20; rLbl.Text = "Радиус от убийцы ("..avoidRadius..")" end end)
bBtn(rMn,function()if avoidRadius > 40 then avoidRadius = avoidRadius - 20; rLbl.Text = "Радиус от убийцы ("..avoidRadius..")" end end)

elseif tn=="SETTINGS" then
local l=Instance.new("TextLabel",cnt)l.Size,l.Position,l.BackgroundTransparency,l.Text,l.TextColor3,l.TextSize,l.Font,l.TextXAlignment=UDim2.new(0,150,0,30),UDim2.new(0,8,0,5),1,"Масштаб меню",Color3.fromRGB(210,200,230),12,Enum.Font.GothamMedium,Enum.TextXAlignment.Left
local mn=Instance.new("TextButton",cnt)mn.Size,mn.Position,mn.BackgroundColor3,mn.BorderSizePixel,mn.Text,mn.TextColor3,mn.TextSize,mn.Font=UDim2.new(0,40,0,26),UDim2.new(0,175,0,7),Color3.fromRGB(50,35,80),0,"-",Color3.new(1,1,1),18,Enum.Font.GothamBold
Instance.new("UICorner",mn).CornerRadius=UDim.new(0,6)
local pl=Instance.new("TextButton",cnt)pl.Size,pl.Position,pl.BackgroundColor3,pl.BorderSizePixel,pl.Text,pl.TextColor3,pl.TextSize,pl.Font=UDim2.new(0,40,0,26),UDim2.new(0,220,0,7),Color3.fromRGB(50,35,80),0,"+",Color3.new(1,1,1),16,Enum.Font.GothamBold
Instance.new("UICorner",pl).CornerRadius=UDim.new(0,6)
bBtn(pl,function() if MS.Scale<1.4 then MS.Scale=MS.Scale+0.1 end end)
bBtn(mn,function() if MS.Scale>0.7 then MS.Scale=MS.Scale-0.1 end end)
end

bBtn(b,function()
for n,f in pairs(tContent)do f.Visible=(n==tn)end
for n,tb in pairs(tBtns)do
local act=(n==tn)
TS:Create(tb,TweenInfo.new(0.15),{BackgroundColor3=act and Color3.fromRGB(75,35,125)or Color3.fromRGB(22,18,32),TextColor3=act and Color3.new(1,1,1)or Color3.fromRGB(150,130,180)}):Play()
end
end)
end

bBtn(MB,function() MF.Visible=false;OB.Visible=true end)
bBtn(OB,function() OB.Visible=false;MF.Visible=true end)

local dragging, dragInput, dragStart, startPos
H.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = MF.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then dragging = false end
end)
end
end)
H.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
