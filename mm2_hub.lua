local P, G, U, W, T, L = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"Workspace", game:GetService"TweenService", game:GetService"Lighting"
local p = P.LocalPlayer
if not p then P:GetPropertyChangedSignal"LocalPlayer":Wait() p = P.LocalPlayer end

local g = p:WaitForChild("PlayerGui", 10)
if g:FindFirstChild"UltimateMM2_Menu" then g.UltimateMM2_Menu:Destroy() end

local s = Instance.new"ScreenGui"
s.Name = "UltimateMM2_Menu"
s.ResetOnSpawn = false
s.DisplayOrder = 999999
s.Parent = g

local f = Instance.new"Frame"
f.Size = UDim2.new(0, 450, 0, 380)
f.Position = UDim2.new(0.5, -225, 0.5, -190)
f.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
f.BackgroundTransparency = 0.4
f.BorderSizePixel = 0
f.Active = true
f.ClipsDescendants = false
f.Visible = true
f.ZIndex = 1
f.Parent = s

local sc = Instance.new"UIScale"
sc.Scale = 1
sc.Parent = f
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

local st = Instance.new"UIStroke"
st.Color = Color3.fromRGB(160, 80, 220)
st.Thickness = 1.5
st.Parent = f

local h = Instance.new"Frame"
h.Size = UDim2.new(1, 0, 0, 38)
h.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
h.BackgroundTransparency = 0.2
h.BorderSizePixel = 0
h.Active = true
h.ZIndex = 2
h.Parent = f
Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

local lb = Instance.new"Frame"
lb.Size = UDim2.new(0, 28, 0, 28)
lb.Position = UDim2.new(0, 6, 0.5, -14)
lb.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
lb.BorderSizePixel = 0
lb.ZIndex = 3
lb.Parent = h
Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 6)

local lt = Instance.new"TextLabel"
lt.Size = UDim2.new(1, 0, 1, 0)
lt.BackgroundTransparency = 1
lt.Text = "U"
lt.TextColor3 = Color3.new(1, 1, 1)
lt.TextSize = 18
lt.Font = Enum.Font.GothamBold
lt.ZIndex = 4
lt.Parent = lb

local ti = Instance.new"TextLabel"
ti.Size = UDim2.new(0, 200, 1, 0)
ti.Position = UDim2.new(0, 42, 0, 0)
ti.BackgroundTransparency = 1
ti.Text = "UltimateMM2 Hub"
ti.TextColor3 = Color3.fromRGB(240, 220, 255)
ti.TextSize = 15
ti.Font = Enum.Font.GothamBold
ti.TextXAlignment = Enum.TextXAlignment.Left
ti.ZIndex = 3
ti.Parent = h

local mb = Instance.new"TextButton"
mb.Size = UDim2.new(0, 32, 0, 28)
mb.Position = UDim2.new(1, -38, 0.5, -14)
mb.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
mb.BorderSizePixel = 0
mb.Text = "—"
mb.TextColor3 = Color3.fromRGB(230, 170, 255)
mb.TextSize = 16
mb.Font = Enum.Font.GothamBold
mb.ZIndex = 5
mb.Parent = h
Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 6)

local ob = Instance.new"TextButton"
ob.Size = UDim2.new(0, 50, 0, 50)
ob.Position = UDim2.new(0.1, 0, 0.2, 0)
ob.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
ob.BorderSizePixel = 0
ob.Text = "U"
ob.TextColor3 = Color3.fromRGB(200, 100, 255)
ob.TextSize = 26
ob.Font = Enum.Font.GothamBold
ob.Visible = false
ob.Active = true
ob.ZIndex = 100
ob.Parent = s
Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 12)

local os = Instance.new"UIStroke"
os.Color = Color3.fromRGB(160, 80, 220)
os.Thickness = 2
os.Parent = ob

local tf = Instance.new"Frame"
tf.Size = UDim2.new(1, -16, 0, 30)
tf.Position = UDim2.new(0, 8, 0, 46)
tf.BackgroundTransparency = 1
tf.ZIndex = 2
tf.Parent = f

local tabs = {"VISUALS", "COMBAT", "PLAYER", "SETTINGS"}
local tcf = {}
local tb = {}

local cp = Instance.new"Frame"
cp.Size = UDim2.new(1, -16, 1, -84)
cp.Position = UDim2.new(0, 8, 0, 80)
cp.BackgroundTransparency = 1
cp.ClipsDescendants = true
cp.ZIndex = 2
cp.Parent = f

local ee, ne, ce, ap, ac, ax, sh, fl, nv = false, false, false, false, false, false, false, false, false
local hl = {}
local nt = {}

local function gr(pl)
    local c = pl.Character
    local b = pl:FindFirstChild"Backpack"
    local function ci(n)
        if c and c:FindFirstChild(n) then return true end
        if b and b:FindFirstChild(n) then return true end
        return false
    end
    if ci"Knife" then return "Murderer" end
    if ci"Gun" then return "Sheriff" end
    return "Innocent"
end

local function tp(h, t)
    if not h or not t then return end
    if firetouchinterest then
        pcall(function() firetouchinterest(h, t, 0) firetouchinterest(h, t, 1) end)
    else
        h.CFrame = t.CFrame
    end
end

local cc = {}
local lcs = 0
local function sc()
    if tick() - lcs < 0.5 then return cc end
    local co = {}
    local cn = {"Coin", "Coin_Sub", "Snowflake", "Candy", "Gift"}
    for _, o in ipairs(W:GetDescendants()) do
        for _, n in ipairs(cn) do
            if o.Name == n then
                local pt = o:IsA"BasePart" and o or o:FindFirstChildWhichIsA"BasePart"
                if pt and pt.Parent then table.insert(co, pt) end
            end
        end
    end
    cc = co
    lcs = tick()
    return co
end

local dr, ds, dsp = false, nil, nil
local function ud(i)
    local d = i.Position - ds
    f.Position = UDim2.new(dsp.X.Scale, dsp.X.Offset + d.X, dsp.Y.Scale, dsp.Y.Offset + d.Y)
end

h.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dr = true
        ds = i.Position
        dsp = f.Position
        di = i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then
                dr = false
            else
                ud(i)
            end
        end)
    end
end)

h.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dr = false
        if di then di:Disconnect() end
    end
end)
local mv = true
local function tm()
    mv = not mv
    f.Visible = mv
    ob.Visible = not mv
end

mb.Activated:Connect(tm)
ob.Activated:Connect(tm)

U.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert or i.KeyCode == Enum.KeyCode.Home then tm() end
end)
G.RenderStepped:Connect(function()
    if ee then
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= p and pl.Character then
                local c = pl.Character
                local h = hl[pl]
                if not h or h.Parent ~= c then
                    if h then pcall(function() h:Destroy() end) end
                    h = Instance.new"Highlight"
                    h.Name = "MM2_ESP"
                    h.FillTransparency = 0.4
                    h.OutlineTransparency = 0
                    h.Parent = c
                    hl[pl] = h
                end
                local r = gr(pl)
                if r == "Murderer" then
                    h.FillColor = Color3.fromRGB(255, 40, 40)
                    h.OutlineColor = Color3.new(1, 1, 1)
                elseif r == "Sheriff" then
                    h.FillColor = Color3.fromRGB(40, 120, 255)
                    h.OutlineColor = Color3.new(1, 1, 1)
                else
                    h.FillColor = Color3.fromRGB(40, 255, 40)
                    h.OutlineColor = Color3.new(1, 1, 1)
                end
            end
        end
    else
        for pl, h in pairs(hl) do
            if h then pcall(function() h:Destroy() end) end
            hl[pl] = nil
        end
    end

    if ne then
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= p and pl.Character and pl.Character:FindFirstChild"HumanoidRootPart" then
                if not nt[pl] then
                    local b = Instance.new"BillboardGui"
                    b.Name = "NameTag"
                    b.Size = UDim2.new(0, 200, 0, 50)
                    b.StudsOffset = Vector3.new(0, 3, 0)
                    b.AlwaysOnTop = true
                    local l = Instance.new"TextLabel"
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextScaled = true
                    l.Font = Enum.Font.GothamBold
                    l.TextStrokeTransparency = 0.5
                    b.Parent = pl.Character.HumanoidRootPart
                    l.Parent = b
                    nt[pl] = {b = b, l = l}
                end
                local r = gr(pl)
                local n = nt[pl]
                if n then
                    n.l.Text = pl.Name .. " [" .. r .. "]"
                    if r == "Murderer" then
                        n.l.TextColor3 = Color3.fromRGB(255, 50, 50)
                    elseif r == "Sheriff" then
                        n.l.TextColor3 = Color3.fromRGB(50, 150, 255)
                    else
                        n.l.TextColor3 = Color3.fromRGB(50, 255, 50)
                    end
                end
            end
        end
    else
        for pl, n in pairs(nt) do
            if n.b then pcall(function() n.b:Destroy() end) end
            nt[pl] = nil
        end
    end

    if ce then
        pcall(function()
            local mr = gr(p)
            if mr == "Murderer" or mr == "Sheriff" then
                local ca = W.CurrentCamera
                for _, pl in ipairs(P:GetPlayers()) do
                    if pl ~= p and pl.Character and pl.Character:FindFirstChild"HumanoidRootPart" then
                        local tr = gr(pl)
                        local st = false
                        if mr == "Murderer" and tr == "Sheriff" then st = true
                        elseif mr == "Sheriff" and tr == "Murderer" then st = true end
                        if st then
                            ca.CFrame = CFrame.new(ca.CFrame.Position, pl.Character.HumanoidRootPart.Position)
                            break
                        end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if ap then
            pcall(function()
                local c = p.Character
                if c and c:FindFirstChild"HumanoidRootPart" then
                    local hr = c.HumanoidRootPart
                    for _, o in ipairs(W:GetDescendants()) do
                        if (o.Name == "GunDrop" or o.Name == "GunServer") then
                            local t = o:IsA"BasePart" and o or o:FindFirstChildWhichIsA"BasePart"
                            if t then tp(hr, t) end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if ac then
            pcall(function()
                local c = p.Character
                if c and c:FindFirstChild"HumanoidRootPart" then
                    local hr = c.HumanoidRootPart
                    local co = sc()
                    for _, cp in ipairs(co) do
                        if not ac then break end
                        if cp and cp.Parent then
                            local d = (hr.Position - cp.Position).Magnitude
                            if d < 500 then
                                tp(hr, cp)
                                task.wait(0.03)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if ax then
            pcall(function()
                local c = p.Character
                if c and c:FindFirstChild"Humanoid" then
                    local hd = c.Humanoid
                    if hd.Health > 0 then
                        local mr = gr(p)
                        if mr == "Murderer" then
                            for _, pl in ipairs(P:GetPlayers()) do
                                if pl ~= p and pl.Character and pl.Character:FindFirstChild"HumanoidRootPart" then
                                    local tr = gr(pl)
                                    if tr == "Innocent" or tr == "Sheriff" then
                                        local th = pl.Character.HumanoidRootPart
                                        local d = (c.HumanoidRootPart.Position - th.Position).Magnitude
                                        if d < 100 then
                                            tp(c.HumanoidRootPart, th)
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if sh then
            pcall(function()
                local c = p.Character
                if c and c:FindFirstChild"Humanoid" then c.Humanoid.WalkSpeed = 50 end
            end)
        else
            pcall(function()
                local c = p.Character
                if c and c:FindFirstChild"Humanoid" then c.Humanoid.WalkSpeed = 16 end
            end)
        end
    end
end)

local fc
task.spawn(function()
    while true do
        task.wait(0.1)
        if fl then
            if not fc then
                fc = G.RenderStepped:Connect(function()
                    pcall(function()
                        local c = p.Character
                        if c and c:FindFirstChild"HumanoidRootPart" then
                            local hr = c.HumanoidRootPart
                            local v = Vector3.new(0, 0, 0)
                            if U:IsKeyDown(Enum.KeyCode.W) then v = v + Vector3.new(0, 0, -1) end
                            if U:IsKeyDown(Enum.KeyCode.S) then v = v + Vector3.new(0, 0, 1) end
                            if U:IsKeyDown(Enum.KeyCode.A) then v = v + Vector3.new(-1, 0, 0) end
                            if U:IsKeyDown(Enum.KeyCode.D) then v = v + Vector3.new(1, 0, 0) end
                            if U:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, 1, 0) end
                            if U:IsKeyDown(Enum.KeyCode.LeftShift) then v = v + Vector3.new(0, -1, 0) end
                            if v.Magnitude > 0 then hr.Velocity = v * 50 end
                        end
                    end)
                end)
            end
        else
            if fc then
                fc:Disconnect()
                fc = nil
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if nv then
            L.Brightness = 3
            L.ClockTime = 14
            L.FogEnd = 100000
        else
            L.Brightness = 1
            L.ClockTime = 12
            L.FogEnd = 1000
        end
    end
end)

local function bb(b, cb)
    local lc = 0
    b.Activated:Connect(function()
        if tick() - lc > 0.15 then
            lc = tick()
            pcall(function()
                T:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = b.Size - UDim2.new(0, 4, 0, 4)}):Play()
                task.delay(0.08, function()
                    T:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = b.Size + UDim2.new(0, 4, 0, 4)}):Play()
                end)
            end)
            cb()
        end
    end)
end

local function ct(pa, tt, py, cb)
    local r = Instance.new"Frame"
    r.Size = UDim2.new(1, -20, 0, 40)
    r.Position = UDim2.new(0, 10, 0, py)
    r.BackgroundTransparency = 1
    r.ZIndex = 3
    r.Parent = pa

    local l = Instance.new"TextLabel"
    l.Size = UDim2.new(0, 240, 1, 0)
    l.Position = UDim2.new(0, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = tt
    l.TextColor3 = Color3.fromRGB(230, 220, 245)
    l.TextSize = 14
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 4
    l.Active = false
    l.Parent = r

    local tb = Instance.new"TextButton"
    tb.Size = UDim2.new(0, 52, 0, 28)
    tb.Position = UDim2.new(1, -52, 0.5, -14)
    tb.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    tb.BorderSizePixel = 0
    tb.Text = ""
    tb.ZIndex = 5
    tb.Active = true
    tb.Parent = r
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

    local ci = Instance.new"Frame"
    ci.Size = UDim2.new(0, 22, 0, 22)
    ci.Position = UDim2.new(0, 3, 0.5, -11)
    ci.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    ci.BorderSizePixel = 0
    ci.ZIndex = 6
    ci.Active = false
    ci.Parent = tb
    Instance.new("UICorner", ci).CornerRadius = UDim.new(1, 0)

    local st = false
    bb(tb, function()
        st = not st
        local tc, tp, cc
        if st then
            tc = Color3.fromRGB(150, 70, 220)
            tp = UDim2.new(1, -25, 0.5, -11)
            cc = Color3.new(1, 1, 1)
        else
            tc = Color3.fromRGB(45, 35, 65)
            tp = UDim2.new(0, 3, 0.5, -11)
            cc = Color3.fromRGB(200, 180, 220)
        end
        T:Create(tb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = tc}):Play()
        T:Create(ci, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = tp, BackgroundColor3 = cc}):Play()
        cb(st)
    end)
end

for i, tn in ipairs(tabs) do
    local b = Instance.new"TextButton"
    b.Size = UDim2.new(0.235, 0, 1, 0)
    b.Position = UDim2.new((i - 1) * 0.255, 0, 0, 0)
    b.BackgroundColor3 = (i == 1) and Color3.fromRGB(75, 35, 125) or Color3.fromRGB(22, 18, 32)
    b.BorderSizePixel = 0
    b.Text = tn
    b.TextColor3 = (i == 1) and Color3.new(1, 1, 1) or Color3.fromRGB(150, 130, 180)
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 3
    b.Active = true
    b.Parent = tf
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    tb[tn] = b

    local c = Instance.new"Frame"
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.BorderSizePixel = 0
    c.Visible = (i == 1)
    c.ZIndex = 2
    c.Parent = cp
    tcf[tn] = c

local P, G, U, W, T, L = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"Workspace", game:GetService"TweenService", game:GetService"Lighting"
local p = P.LocalPlayer
if not p then P:GetPropertyChangedSignal"LocalPlayer":Wait() p = P.LocalPlayer end

local g = p:WaitForChild("PlayerGui", 10)
if g:FindFirstChild"UltimateMM2_Menu" then g.UltimateMM2_Menu:Destroy() end

local s = Instance.new"ScreenGui"
s.Name = "UltimateMM2_Menu"
s.ResetOnSpawn = false
s.DisplayOrder = 999999
s.Parent = g

local f = Instance.new"Frame"
f.Size = UDim2.new(0.6, 0, 0.7, 0)
f.Position = UDim2.new(0.2, 0, 0.15, 0)
f.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0
f.Active = true
f.ClipsDescendants = false
f.ZIndex = 10
f.Parent = s

Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

local st = Instance.new"UIStroke"
st.Color = Color3.fromRGB(160, 80, 220)
st.Thickness = 2
st.Parent = f

local h = Instance.new"Frame"
h.Size = UDim2.new(1, 0, 0, 36)
h.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
h.BorderSizePixel = 0
h.ZIndex = 11
h.Parent = f
Instance.new("UICorner", h).CornerRadius = UDim.new(0, 10)

local ti = Instance.new"TextLabel"
ti.Size = UDim2.new(0.7, 0, 1, 0)
ti.Position = UDim2.new(0, 12, 0, 0)
ti.BackgroundTransparency = 1
ti.Text = "UltimateMM2 Hub"
ti.TextColor3 = Color3.fromRGB(240, 220, 255)
ti.TextSize = 16
ti.Font = Enum.Font.GothamBold
ti.TextXAlignment = Enum.TextXAlignment.Left
ti.ZIndex = 12
ti.Parent = h

local mb = Instance.new"TextButton"
mb.Size = UDim2.new(0, 30, 0, 26)
mb.Position = UDim2.new(1, -36, 0.5, -13)
mb.BackgroundColor3 = Color3.fromRGB(60, 40, 90)
mb.BorderSizePixel = 0
mb.Text = "—"
mb.TextColor3 = Color3.fromRGB(255, 255, 255)
mb.TextSize = 16
mb.Font = Enum.Font.GothamBold
mb.ZIndex = 12
mb.Parent = h
Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 6)

local ob = Instance.new"TextButton"
ob.Size = UDim2.new(0, 45, 0, 45)
ob.Position = UDim2.new(0.05, 0, 0.1, 0)
ob.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
ob.BorderSizePixel = 0
ob.Text = "U"
ob.TextColor3 = Color3.fromRGB(200, 100, 255)
ob.TextSize = 24
ob.Font = Enum.Font.GothamBold
ob.Visible = false
ob.Active = true
ob.ZIndex = 100
ob.Parent = s
Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 10)
local os = Instance.new"UIStroke"
os.Color = Color3.fromRGB(160, 80, 220)
os.Thickness = 2
os.Parent = ob

local tf = Instance.new"Frame"
tf.Size = UDim2.new(1, -16, 0, 32)
tf.Position = UDim2.new(0, 8, 0, 42)
tf.BackgroundTransparency = 1
tf.ZIndex = 11
tf.Parent = f

local cp = Instance.new"Frame"
cp.Size = UDim2.new(1, -16, 1, -82)
cp.Position = UDim2.new(0, 8, 0, 78)
cp.BackgroundTransparency = 1
cp.ZIndex = 11
cp.Parent = f

local tabs = {"VISUALS", "COMBAT", "PLAYER", "SETTINGS"}
local tcf = {}
local tb = {}
local ee, ne, ce, ap, ac, ax, sh, fl, nv = false, false, false, false, false, false, false, false, false
local hl, nt = {}, {}

local function gr(pl)
    local c = pl.Character
    local b = pl:FindFirstChild"Backpack"
    local function ci(n)
        return (c and c:FindFirstChild(n)) or (b and b:FindFirstChild(n))
    end
    if ci"Knife" then return "Murderer" end
    if ci"Gun" then return "Sheriff" end
    return "Innocent"
end

local function tp(h, t)
    if not h or not t then return end
    if firetouchinterest then
        pcall(function() firetouchinterest(h, t, 0) firetouchinterest(h, t, 1) end)
    else
        h.CFrame = t.CFrame
    end
end

local function ct(pa, tt, py, cb)
    local r = Instance.new"Frame"
    r.Size = UDim2.new(1, 0, 0, 36)
    r.Position = UDim2.new(0, 0, 0, py)
    r.BackgroundTransparency = 1
    r.ZIndex = 12
    r.Parent = pa

    local l = Instance.new"TextLabel"
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = tt
    l.TextColor3 = Color3.fromRGB(230, 220, 245)
    l.TextSize = 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 13
    l.Parent = r

    local btn = Instance.new"TextButton"
    btn.Size = UDim2.new(0, 48, 0, 24)
    btn.Position = UDim2.new(1, -50, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.ZIndex = 13
    btn.Parent = r
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local ci = Instance.new"Frame"
    ci.Size = UDim2.new(0, 18, 0, 18)
    ci.Position = UDim2.new(0, 3, 0.5, -9)
    ci.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    ci.BorderSizePixel = 0
    ci.ZIndex = 14
    ci.Parent = btn
    Instance.new("UICorner", ci).CornerRadius = UDim.new(1, 0)

    local st = false
    btn.Activated:Connect(function()
        st = not st
        local tc = st and Color3.fromRGB(150, 70, 220) or Color3.fromRGB(45, 35, 65)
        local tp = st and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        T:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = tc}):Play()
        T:Create(ci, TweenInfo.new(0.15), {Position = tp}):Play()
        cb(st)
    end)
end

for i, tn in ipairs(tabs) do
    local b = Instance.new"TextButton"
    b.Size = UDim2.new(0.23, 0, 1, 0)
    b.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
    b.BackgroundColor3 = (i == 1) and Color3.fromRGB(75, 35, 125) or Color3.fromRGB(25, 18, 38)
    b.BorderSizePixel = 0
    b.Text = tn
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.ZIndex = 12
    b.Parent = tf
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    tb[tn] = b

    local c = Instance.new"Frame"
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.Visible = (i == 1)
    c.ZIndex = 12
    c.Parent = cp
    tcf[tn] = c

    if tn == "VISUALS" then
        ct(c, "ESP (Подсветка)", 5, function(s) ee = s end)
        ct(c, "NameTags (Имена)", 45, function(s) ne = s end)
    elseif tn == "COMBAT" then
        ct(c, "Aim Bot", 5, function(s) ce = s end)
        ct(c, "Auto Pick Gun", 45, function(s) ap = s end)
    elseif tn == "PLAYER" then
        ct(c, "Auto Farm Coins", 5, function(s) ac = s end)
        ct(c, "Auto Farm XP", 45, function(s) ax = s end)
        ct(c, "Speed Hack", 85, function(s) sh = s end)
        ct(c, "Fly Mode", 125, function(s) fl = s end)
    elseif tn == "SETTINGS" then
        ct(c, "Night Vision", 5, function(s) nv = s end)
        local clb = Instance.new"TextButton"
        clb.Size = UDim2.new(1, 0, 0, 36)
        clb.Position = UDim2.new(0, 0, 0, 50)
        clb.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        clb.BorderSizePixel = 0
        clb.Text = "Закрыть скрипт"
        clb.TextColor3 = Color3.new(1, 1, 1)
        clb.TextSize = 12
        clb.Font = Enum.Font.GothamBold
        clb.ZIndex = 13
        clb.Parent = c
        Instance.new("UICorner", clb).CornerRadius = UDim.new(0, 6)
        clb.Activated:Connect(function() s:Destroy() end)
    end

    b.Activated:Connect(function()
        for _, ot in ipairs(tabs) do
            tb[ot].BackgroundColor3 = Color3.fromRGB(25, 18, 38)
            tcf[ot].Visible = false
        end
        b.BackgroundColor3 = Color3.fromRGB(75, 35, 125)
        tcf[tn].Visible = true
    end)
end

local mv = true
local function tm()
    mv = not mv
    f.Visible = mv
    ob.Visible = not mv
end
mb.Activated:Connect(tm)
ob.Activated:Connect(tm)

G.RenderStepped:Connect(function()
    if ee then
        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= p and pl.Character then
                local c = pl.Character
                local h = hl[pl]
                if not h or h.Parent ~= c then
                    if h then pcall(function() h:Destroy() end) end
                    h = Instance.new"Highlight"
                    h.FillTransparency = 0.4
                    h.Parent = c
                    hl[pl] = h
                end
                local r = gr(pl)
                h.FillColor = (r == "Murderer" and Color3.fromRGB(255, 40, 40)) or (r == "Sheriff" and Color3.fromRGB(40, 120, 255)) or Color3.fromRGB(40, 255, 40)
            end
        end
    else
        for pl, h in pairs(hl) do if h then pcall(function() h:Destroy() end) end hl[pl] = nil end
    end
end)
