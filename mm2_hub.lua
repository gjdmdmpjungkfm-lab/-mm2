local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("UltimateMM2_Menu") then
    PlayerGui.UltimateMM2_Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMM2_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = PlayerGui
end

local MAIN_WIDTH = 450
local MAIN_HEIGHT = 350

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -MAIN_WIDTH / 2, 0.5, -MAIN_HEIGHT / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.Visible = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

local MenuScale = Instance.new("UIScale")
MenuScale.Scale = 1
MenuScale.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(160, 80, 220)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(22, 17, 32)
Header.BorderSizePixel = 0
Header.Active = true
Header.ZIndex = 2
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 28, 0, 28)
LogoBox.Position = UDim2.new(0, 6, 0.5, -14)
LogoBox.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
LogoBox.BorderSizePixel = 0
LogoBox.ZIndex = 3
LogoBox.Parent = Header

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 6)
LogoCorner.Parent = LogoBox

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "U"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 18
LogoText.Font = Enum.Font.GothamBold
LogoText.ZIndex = 4
LogoText.Parent = LogoBox

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 42, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "UltimateMM2 Hub"
Title.TextColor3 = Color3.fromRGB(240, 220, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = Header

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -38, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(230, 170, 255)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.ZIndex = 5
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.1, 0, 0.2, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "U"
OpenBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.ZIndex = 100
OpenBtn.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenBtn

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(160, 80, 220)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenBtn

local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -16, 0, 30)
TabsFrame.Position = UDim2.new(0, 8, 0, 46)
TabsFrame.BackgroundTransparency = 1
TabsFrame.ZIndex = 2
TabsFrame.Parent = MainFrame

local tabs = {"VISUALS", "COMBAT", "PLAYER", "SETTINGS"}
local tabContentFrames = {}
local tabButtons = {}

local ContainersParent = Instance.new("Frame")
ContainersParent.Size = UDim2.new(1, -16, 1, -84)
ContainersParent.Position = UDim2.new(0, 8, 0, 80)
ContainersParent.BackgroundTransparency = 1
ContainersParent.ClipsDescendants = true
ContainersParent.ZIndex = 2
ContainersParent.Parent = MainFrame

local espEnabled = false
local combatAimEnabled = false
local autoPickGunEnabled = false

local autoFarmCoinsEnabled = false
local farmSpeedDelay = 0.1
local legitFarmEnabled = false
local avoidMurdererEnabled = false
local safeDistance = 25

local highlights = {}

local function getPlayerRole(player)
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    local function checkItem(name)
        if char and char:FindFirstChild(name) then return true end
        if backpack and backpack:FindFirstChild(name) then return true end
        return false
    end

    if checkItem("Knife") then return "Murderer" end
    if checkItem("Gun") then return "Sheriff" end
    return "Innocent"
end

local function touchPart(hrp, targetPart)
    if not hrp or not targetPart or not targetPart.Parent then return end

    if legitFarmEnabled then
        local distance = (hrp.Position - targetPart.Position).Magnitude
        local tweenTime = math.clamp(distance / 28, 0.05, 0.4)
        local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPart.CFrame})
        tween:Play()
        tween.Completed:Wait()
    else
        if firetouchinterest then
            pcall(function()
                firetouchinterest(hrp, targetPart, 0)
                firetouchinterest(hrp, targetPart, 1)
            end)
        else
            hrp.CFrame = targetPart.CFrame
        end
    end
end

local function getMurdererHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if getPlayerRole(p) == "Murderer" then
                return p.Character.HumanoidRootPart
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local hl = highlights[p]
                
                if not hl or hl.Parent ~= char then
                    if hl then pcall(function() hl:Destroy() end) end
                    hl = Instance.new("Highlight")
                    hl.Name = "MM2_ESP"
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                    highlights[p] = hl
                end
                
                local role = getPlayerRole(p)
                if role == "Murderer" then
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                elseif role == "Sheriff" then
                    hl.FillColor = Color3.fromRGB(40, 120, 255)
                else
                    hl.FillColor = Color3.fromRGB(40, 255, 40)
                end
            end
        end
    else
        for p, hl in pairs(highlights) do
            if hl then pcall(function() hl:Destroy() end) end
            highlights[p] = nil
        end
    end

    if combatAimEnabled then
        pcall(function()
            local myRole = getPlayerRole(LocalPlayer)
            if myRole == "Murderer" or myRole == "Sheriff" then
                local camera = Workspace.CurrentCamera
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRole = getPlayerRole(p)
                        if (myRole == "Murderer" and targetRole == "Sheriff") or (myRole == "Sheriff" and targetRole == "Murderer") then
                            camera.CFrame = CFrame.new(camera.CFrame.Position, p.Character.HumanoidRootPart.Position)
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
        if autoPickGunEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if autoPickGunEnabled and (obj.Name == "GunDrop" or obj.Name == "GunServer") then
                            local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if targetPart then touchPart(hrp, targetPart) end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(farmSpeedDelay)
        if autoFarmCoinsEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    
                    if avoidMurdererEnabled then
                        local mHrp = getMurdererHRP()
                        if mHrp and (hrp.Position - mHrp.Position).Magnitude < safeDistance then
                            local escapeDir = (hrp.Position - mHrp.Position).Unit
                            hrp.CFrame = CFrame.new(hrp.Position + escapeDir * 15)
                            task.wait(0.2)
                            return
                        end
                    end

                    local coinContainer = Workspace:FindFirstChild("CoinContainer", true)
                    local items = coinContainer and coinContainer:GetChildren() or Workspace:GetDescendants()
                    
                    for _, coin in ipairs(items) do
                        if not autoFarmCoinsEnabled then break end
                        if coin.Name == "Coin_Server" or coin.Name == "Coin" or coin.Name == "Coin_Sub" then
                            local targetPart = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
                            if targetPart and targetPart.Parent then
                                touchPart(hrp, targetPart)
                                task.wait(farmSpeedDelay)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

local function bindButton(button, callback)
    local lastClick = 0
    button.Activated:Connect(function()
        if tick() - lastClick > 0.15 then
            lastClick = tick()
            callback()
        end
    end)
end

local function createToggle(parent, titleText, posY, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 35)
    row.Position = UDim2.new(0, 10, 0, posY)
    row.BackgroundTransparency = 1
    row.ZIndex = 3
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 240, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(230, 220, 245)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 52, 0, 26)
    toggleBtn.Position = UDim2.new(1, -52, 0.5, -13)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.ZIndex = 5
    toggleBtn.Parent = row
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = UDim2.new(0, 3, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    circle.BorderSizePixel = 0
    circle.ZIndex = 6
    circle.Parent = toggleBtn
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle
    
    local state = false
    bindButton(toggleBtn, function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            circle.Position = UDim2.new(1, -23, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
            circle.Position = UDim2.new(0, 3, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
        end
        callback(state)
    end)
end

local function createSlider(parent, titleText, posY, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, posY)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    frame.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(230, 220, 245)
    title.TextSize = 13
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 60, 0, 18)
    valLabel.Position = UDim2.new(1, -60, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = string.format("%.2fs", defaultVal)
    valLabel.TextColor3 = Color3.fromRGB(180, 150, 220)
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.ZIndex = 4
    valLabel.Parent = frame

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, 0, 0, 8)
    sliderBack.Position = UDim2.new(0, 0, 0, 26)
    sliderBack.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    sliderBack.BorderSizePixel = 0
    sliderBack.ZIndex = 4
    sliderBack.Parent = frame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = sliderBack

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = sliderBack

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local isDragging = false
    local function updateInput(input)
        local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = minVal + (maxVal - minVal) * pos
        valLabel.Text = string.format("%.2fs", val)
        callback(val)
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
end

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.235, 0, 1, 0)
    btn.Position = UDim2.new((i - 1) * 0.255, 0, 0, 0)
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(75, 35, 125) or Color3.fromRGB(22, 18, 32)
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 130, 180)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    btn.Parent = TabsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    tabButtons[tabName] = btn

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Visible = (i == 1)
    container.ZIndex = 2
    container.Parent = ContainersParent
    
    if tabName == "VISUALS" then
        createToggle(container, "ESP (Убийца / Шериф)", 10, function(state) espEnabled = state end)

    elseif tabName == "COMBAT" then
        createToggle(container, "Aim Bot (Авто-наведение)", 10, function(state) combatAimEnabled = state end)
        createToggle(container, "Auto Pick Gun (Авто-подбор)", 50, function(state) autoPickGunEnabled = state end)

    elseif tabName == "PLAYER" then
        createToggle(container, "Auto Farm Coins (Фарм монет)", 5, function(state) autoFarmCoinsEnabled = state end)
        createToggle(container, "Легит режим (Плавный сбор)", 45, function(state) legitFarmEnabled = state end)
        createToggle(container, "Избегать Убийцу (Avoid Murderer)", 85, function(state) avoidMurdererEnabled = state end)
        
        createSlider(container, "Задержка сбора", 125, 0.01, 0.50, 0.10, function(val)
            farmSpeedDelay = val
        end)

    elseif tabName == "SETTINGS" then
        local scaleLabel = Instance.new("TextLabel")
        scaleLabel.Size = UDim2.new(0, 160, 0, 38)
        scaleLabel.Position = UDim2.new(0, 10, 0, 10)
        scaleLabel.BackgroundTransparency = 1
        scaleLabel.Text = "Масштаб меню"
        scaleLabel.TextColor3 = Color3.fromRGB(210, 200, 230)
        scaleLabel.TextSize = 14
        scaleLabel.Font = Enum.Font.GothamMedium
        scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
        scaleLabel.ZIndex = 4
        scaleLabel.Parent = container
        
        local minusBtn = Instance.new("TextButton")
        minusBtn.Size = UDim2.new(0, 54, 0, 38)
        minusBtn.Position = UDim2.new(0, 190, 0, 10)
        minusBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        minusBtn.BorderSizePixel = 0
        minusBtn.Text = "-"
        minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        minusBtn.TextSize = 22
        minusBtn.Font = Enum.Font.GothamBold
        minusBtn.ZIndex = 5
        minusBtn.Parent = container
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 54, 0, 38)
        plusBtn.Position = UDim2.new(0, 252, 0, 10)
        plusBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 20
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.ZIndex = 5
        plusBtn.Parent = container

        bindButton(plusBtn, function()
            if MenuScale.Scale < 1.4 then MenuScale.Scale = MenuScale.Scale + 0.1 end
        end)
        
        bind
