local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local function getUIContainer()
    local success, res = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    if success and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui", 3)
end

local ParentContainer = getUIContainer()

if ParentContainer:FindFirstChild("UltimateMM2_Menu") then
    ParentContainer.UltimateMM2_Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMM2_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ParentContainer

local MAIN_WIDTH = 450
local MAIN_HEIGHT = 290

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -MAIN_WIDTH / 2, 0.5, -MAIN_HEIGHT / 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
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
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(0, 28, 0, 28)
LogoBox.Position = UDim2.new(0, 6, 0.5, -14)
LogoBox.BackgroundColor3 = Color3.fromRGB(130, 50, 200)
LogoBox.BorderSizePixel = 0
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
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local currentIconSize = 50
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, currentIconSize, 0, currentIconSize)
OpenBtn.Position = UDim2.new(0.5, -currentIconSize / 2, 0.5, -currentIconSize / 2)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "U"
OpenBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
OpenBtn.TextSize = 26
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
OpenBtn.Active = true
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
TabsFrame.Parent = MainFrame

local tabs = {"VISUALS", "COMBAT", "PLAYER", "SETTINGS"}
local tabContentFrames = {}
local tabButtons = {}

local ContainersParent = Instance.new("Frame")
ContainersParent.Size = UDim2.new(1, -16, 1, -84)
ContainersParent.Position = UDim2.new(0, 8, 0, 80)
ContainersParent.BackgroundTransparency = 1
ContainersParent.ClipsDescendants = true
ContainersParent.Parent = MainFrame

local espEnabled = false
local gunEspEnabled = false
local combatAimEnabled = false
local aimWallCheckEnabled = false
local autoPickupGunEnabled = false
local highlights = {}
local gunHighlights = {}

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

local function getGunDrop()
    local gun = Workspace:FindFirstChild("GunDrop")
    if gun then return gun end
    
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "GunDrop" or (child:IsA("Tool") and string.find(string.lower(child.Name), "gun")) then
            return child
        end
    end
    return nil
end

local function isVisibleThroughWalls(origin, targetPart, ignoreList)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true
    
    local direction = targetPart.Position - origin
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local lastGunScan = 0
local lastPickupTime = 0

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
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif role == "Sheriff" then
                    hl.FillColor = Color3.fromRGB(40, 120, 255)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    hl.FillColor = Color3.fromRGB(40, 255, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    else
        for p, hl in pairs(highlights) do
            if hl then pcall(function() hl:Destroy() end) end
            highlights[p] = nil
        end
    end

    if gunEspEnabled then
        if tick() - lastGunScan > 0.3 then
            lastGunScan = tick()
            local gunObj = getGunDrop()
            
            if gunObj then
                if not gunHighlights[gunObj] or gunHighlights[gunObj].Parent ~= gunObj then
                    pcall(function()
                        local ghl = Instance.new("Highlight")
                        ghl.Name = "Gun_ESP"
                        ghl.FillColor = Color3.fromRGB(255, 215, 0)
                        ghl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        ghl.FillTransparency = 0.2
                        ghl.OutlineTransparency = 0
                        ghl.Parent = gunObj
                        gunHighlights[gunObj] = ghl
                    end)
                end
            else
                for obj, ghl in pairs(gunHighlights) do
                    if ghl then pcall(function() ghl:Destroy() end) end
                    gunHighlights[obj] = nil
                end
            end
        end
    else
        for obj, ghl in pairs(gunHighlights) do
            if ghl then pcall(function() ghl:Destroy() end) end
            gunHighlights[obj] = nil
        end
    end

    if autoPickupGunEnabled and tick() - lastPickupTime > 0.4 then
        local gunObj = getGunDrop()
        if gunObj and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local gunPart = gunObj:IsA("BasePart") and gunObj or gunObj:FindFirstChildWhichIsA("BasePart")
            
            if gunPart then
                lastPickupTime = tick()
                local oldCFrame = hrp.CFrame
                hrp.CFrame = gunPart.CFrame
                
                if firetouchinterest then
                    firetouchinterest(hrp, gunPart, 0)
                    firetouchinterest(hrp, gunPart, 1)
                end
                
                task.delay(0.05, function()
                    if hrp then hrp.CFrame = oldCFrame end
                end)
            end
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
                        local shouldTarget = false
                        
                        if myRole == "Murderer" and targetRole == "Sheriff" then
                            shouldTarget = true
                        elseif myRole == "Sheriff" and targetRole == "Murderer" then
                            shouldTarget = true
                        end
                        
                        if shouldTarget then
                            local targetPart = p.Character.HumanoidRootPart
                            local cameraPos = camera.CFrame.Position
                            
                            if aimWallCheckEnabled then
                                local ignoreList = {LocalPlayer.Character, camera}
                                if isVisibleThroughWalls(cameraPos, targetPart, ignoreList) then
                                    camera.CFrame = CFrame.new(cameraPos, targetPart.Position)
                                    break
                                end
                            else
                                camera.CFrame = CFrame.new(cameraPos, targetPart.Position)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then
        pcall(function() highlights[p]:Destroy() end)
        highlights[p] = nil
    end
end)

local function createToggle(parent, titleText, posY, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 40)
    row.Position = UDim2.new(0, 10, 0, posY)
    row.BackgroundTransparency = 1
    row.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 240, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(230, 220, 245)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 52, 0, 28)
    toggleBtn.Position = UDim2.new(1, -52, 0.5, -14)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = row
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 3, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle
    
    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            circle.Position = UDim2.new(1, -25, 0.5, -11)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
            circle.Position = UDim2.new(0, 3, 0.5, -11)
            circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
        end
        callback(state)
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
    btn.Parent = TabsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    tabButtons[tabName] = btn

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Visible = (i == 1)
    container.Parent = ContainersParent
    
    if tabName == "VISUALS" then
        createToggle(container, "ESP (Убийца / Шериф)", 10, function(state)
            espEnabled = state
        end)

        createToggle(container, "Gun ESP (Подсветка оружия)", 55, function(state)
            gunEspEnabled = state
        end)

    elseif tabName == "COMBAT" then
        createToggle(container, "Aim Bot (Авто-наведение)", 10, function(state)
            combatAimEnabled = state
        end)

        createToggle(container, "Aim Wall Check (Проверка стен)", 55, function(state)
            aimWallCheckEnabled = state
        end)

        createToggle(container, "Auto Pickup Gun (Авто-подбор)", 100, function(state)
            autoPickupGunEnabled = state
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
        minusBtn.Parent = container
        
        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 6)
        mCorner.Parent = minusBtn
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 54, 0, 38)
        plusBtn.Position = UDim2.new(0, 252, 0, 10)
        plusBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 20
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.Parent = container
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 6)
        pCorner.Parent = plusBtn

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 160, 0, 38)
        iconLabel.Position = UDim2.new(0, 10, 0, 60)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = "Размер иконки"
        iconLabel.TextColor3 = Color3.fromRGB(210, 200, 230)
        iconLabel.TextSize = 14
        iconLabel.Font = Enum.Font.GothamMedium
        iconLabel.TextXAlignment = Enum.TextXAlignment.Left
        iconLabel.Parent = container
        
        local iconMinus = Instance.new("TextButton")
        iconMinus.Size = UDim2.new(0, 54, 0, 38)
        iconMinus.Position = UDim2.new(0, 190, 0, 60)
        iconMinus.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        iconMinus.BorderSizePixel = 0
        iconMinus.Text = "-"
        iconMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconMinus.TextSize = 22
        iconMinus.Font = Enum.Font.GothamBold
        iconMinus.Parent = container
        
        local imCorner = Instance.new("UICorner")
        imCorner.CornerRadius = UDim.new(0, 6)
        imCorner.Parent = iconMinus
        
        local iconPlus = Instance.new("TextButton")
        iconPlus.Size = UDim2.new(0, 54, 0, 38)
        iconPlus.Position = UDim2.new(0, 252, 0, 60)
        iconPlus.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        iconPlus.BorderSizePixel = 0
        iconPlus.Text = "+"
        iconPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconPlus.TextSize = 20
        iconPlus.Font = Enum.Font.GothamBold
        iconPlus.Parent = container
        
        local ipCorner = Instance.new("UICorner")
        ipCorner.CornerRadius = UDim.new(0, 6)
        ipCorner.Parent = iconPlus

        plusBtn.MouseButton1Click:Connect(function()
            if MenuScale.Scale < 1.4 then MenuScale.Scale = MenuScale.Scale + 0.1 end
        end)
        
        minusBtn.MouseButton1Click:Connect(function()
            if MenuScale.Scale > 0.7 then MenuScale.Scale = MenuScale.Scale - 0.1 end
        end)

        iconPlus.MouseButton1Click:Connect(function()
            if currentIconSize < 90 then
                currentIconSize = currentIconSize + 8
                OpenBtn.Size = UDim2.new(0, currentIconSize, 0, currentIconSize)
            end
        end)
        
        iconMinus.MouseButton1Click:Connect(function()
            if currentIconSize > 30 then
                currentIconSize = currentIconSize - 8
                OpenBtn.Size = UDim2.new(0, currentIconSize, 0, currentIconSize)
            end
        end)
    else
        local placeholder = Instance.new("TextLabel")
        placeholder.Size = UDim2.new(1, 0, 0, 30)
        placeholder.Position = UDim2.new(0, 0, 0.4, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = "Раздел '" .. tabName .. "' пуст"
        placeho)
    circle.Size = UDim2.new(0, 22, 0, 22)
    circle.Position = UDim2.new(0, 3, 0.5, -11)
    circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle
    
    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            circle.Position = UDim2.new(1, -25, 0.5, -11)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
            circle.Position = UDim2.new(0, 3, 0.5, -11)
            circle.BackgroundColor3 = Color3.fromRGB(200, 180, 220)
        end
        callback(state)
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
    btn.Parent = TabsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    tabButtons[tabName] = btn

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Visible = (i == 1)
    container.Parent = ContainersParent
    
    if tabName == "VISUALS" then
        createToggle(container, "ESP (Убийца / Шериф)", 10, function(state)
            espEnabled = state
        end)

        createToggle(container, "Gun ESP (Подсветка оружия)", 55, function(state)
            gunEspEnabled = state
        end)

    elseif tabName == "COMBAT" then
        createToggle(container, "Aim Bot (Авто-наведение)", 10, function(state)
            combatAimEnabled = state
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
        minusBtn.Parent = container
        
        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(0, 6)
        mCorner.Parent = minusBtn
        
        local plusBtn = Instance.new("TextButton")
        plusBtn.Size = UDim2.new(0, 54, 0, 38)
        plusBtn.Position = UDim2.new(0, 252, 0, 10)
        plusBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        plusBtn.BorderSizePixel = 0
        plusBtn.Text = "+"
        plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        plusBtn.TextSize = 20
        plusBtn.Font = Enum.Font.GothamBold
        plusBtn.Parent = container
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 6)
        pCorner.Parent = plusBtn

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 160, 0, 38)
        iconLabel.Position = UDim2.new(0, 10, 0, 60)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = "Размер иконки"
        iconLabel.TextColor3 = Color3.fromRGB(210, 200, 230)
        iconLabel.TextSize = 14
        iconLabel.Font = Enum.Font.GothamMedium
        iconLabel.TextXAlignment = Enum.TextXAlignment.Left
        iconLabel.Parent = container
        
        local iconMinus = Instance.new("TextButton")
        iconMinus.Size = UDim2.new(0, 54, 0, 38)
        iconMinus.Position = UDim2.new(0, 190, 0, 60)
        iconMinus.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        iconMinus.BorderSizePixel = 0
        iconMinus.Text = "-"
        iconMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconMinus.TextSize = 22
        iconMinus.Font = Enum.Font.GothamBold
        iconMinus.Parent = container
        
        local imCorner = Instance.new("UICorner")
        imCorner.CornerRadius = UDim.new(0, 6)
        imCorner.Parent = iconMinus
        
        local iconPlus = Instance.new("TextButton")
        iconPlus.Size = UDim2.new(0, 54, 0, 38)
        iconPlus.Position = UDim2.new(0, 252, 0, 60)
        iconPlus.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        iconPlus.BorderSizePixel = 0
        iconPlus.Text = "+"
        iconPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
        iconPlus.TextSize = 20
        iconPlus.Font = Enum.Font.GothamBold
        iconPlus.Parent = container
        
        local ipCorner = Instance.new("UICorner")
        ipCorner.CornerRadius = UDim.new(0, 6)
        ipCorner.Parent = iconPlus

        plusBtn.MouseButton1Click:Connect(function()
            if MenuScale.Scale < 1.4 then
                MenuScale.Scale = MenuScale.Scale + 0.1
            end
        end)
        
        minusBtn.MouseButton1Click:Connect(function()
            if MenuScale.Scale > 0.7 then
                MenuScale.Scale = MenuScale.Scale - 0.1
            end
        end)

        iconPlus.MouseButton1Click:Connect(function()
            if currentIconSize < 80 then
                currentIconSize = currentIconSize + 8
                OpenBtn.Size = UDim2.new(0, currentIconSize, 0, currentIconSize)
            end
        end)
        
        iconMinus.MouseButton1Click:Connect(function()
            if currentIconSize > 40 then
                currentIconSize = currentIconSize - 8
                OpenBtn.Size = UDim2.new(0, currentIconSize, 0, currentIconSize)
            end
        end)
    else
        local placeholder = Instance.new("TextLabel")
        placeholder.Size = UDim2.new(1, 0, 0, 30)
        placeholder.Position = UDim2.new(0, 0, 0.4, 0)
        placeholder.BackgroundTransparency = 1
        placeholder.Text = "Раздел '" .. tabName .. "' пуст"
        placeholder.TextColor3 = Color3.fromRGB(120, 100, 150)
        placeholder.TextSize = 12
        placeholder.Font = Enum.Font.Gotham
        placeholder.Parent = container
    end

    tabContentFrames[tabName] = container

    btn.MouseButton1Click:Connect(function()
        for name, frame in pairs(tabContentFrames) do
            frame.Visible = (name == tabName)
        end
        for name, b in pairs(tabButtons) do
            local active = (name == tabName)
            b.BackgroundColor3 = active and Color3.fromRGB(75, 35, 125) or Color3.fromRGB(22, 18, 32)
            b.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 130, 180)
        end
    end)
end

-- Переключение свернутого состояния
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    MainFrame.Visible = true
end)

-- Перетаскивание главного окна
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Перетаскивание кнопки открытия
local bDragging, bInput, bStart, bStartPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bDragging = true
        bStart = input.Position
        bStartPos = OpenBtn.Position
    end
end)

OpenBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        bInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == bInput and bDragging then
        local delta = input.Position - bStart
        OpenBtn.Position = UDim2.new(bStartPos.X.Scale, bStartPos.X.Offset + delta.X, bStartPos.Y.Scale, bStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        bDragging = false
    end
end)

