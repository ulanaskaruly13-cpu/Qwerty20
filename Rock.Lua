local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local PlayerList = {}
local loopCounter = {}
local isEnabled = true

local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateMenu"
    ScreenGui.Parent = Player.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Text = "⚡ ULTIMATE MENU ⚡"
    Title.TextColor3 = Color3.fromRGB(0, 200, 255)
    Title.BackgroundTransparency = 1
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 0, 40)
    TabFrame.Position = UDim2.new(0, 0, 0, 40)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = MainFrame
    
    local Tabs = {"Players", "Defense", "Visual", "Misc"}
    local TabButtons = {}
    
    for i, name in pairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 112, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Parent = TabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        TabButtons[name] = btn
    end
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    local PlayerFrame = Instance.new("ScrollingFrame")
    PlayerFrame.Size = UDim2.new(1, 0, 1, 0)
    PlayerFrame.BackgroundTransparency = 1
    PlayerFrame.Parent = ContentFrame
    PlayerFrame.Visible = true
    
    local DefenseFrame = Instance.new("Frame")
    DefenseFrame.Size = UDim2.new(1, 0, 1, 0)
    DefenseFrame.BackgroundTransparency = 1
    DefenseFrame.Parent = ContentFrame
    DefenseFrame.Visible = false
    
    local VisualFrame = Instance.new("Frame")
    VisualFrame.Size = UDim2.new(1, 0, 1, 0)
    VisualFrame.BackgroundTransparency = 1
    VisualFrame.Parent = ContentFrame
    VisualFrame.Visible = false
    
    local MiscFrame = Instance.new("Frame")
    MiscFrame.Size = UDim2.new(1, 0, 1, 0)
    MiscFrame.BackgroundTransparency = 1
    MiscFrame.Parent = ContentFrame
    MiscFrame.Visible = false
    
    local function SwitchTab(tab)
        PlayerFrame.Visible = tab == "Players"
        DefenseFrame.Visible = tab == "Defense"
        VisualFrame.Visible = tab == "Visual"
        MiscFrame.Visible = tab == "Misc"
        
        for name, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = name == tab and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 50)
        end
    end
    
    for name, btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
    end
    
    local function CreateButton(parent, text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, y, 0)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local function CreateToggle(parent, text, y, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0, 35)
        frame.Position = UDim2.new(0.05, 0, y, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextScaled = true
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.2, 0, 1, 0)
        toggle.Position = UDim2.new(0.8, 0, 0, 0)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggle.BorderSizePixel = 0
        toggle.Font = Enum.Font.GothamBold
        toggle.TextScaled = true
        toggle.Parent = frame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = toggle
        
        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = state and "ON" or "OFF"
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            callback(state)
        end)
        
        return {Toggle = toggle, SetState = function(s)
            state = s
            toggle.Text = state and "ON" or "OFF"
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        end}
    end
    
    -- PLAYER TAB
    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, 0, 1, -40)
    playerList.Position = UDim2.new(0, 0, 0, 0)
    playerList.BackgroundTransparency = 1
    playerList.Parent = PlayerFrame
    
    local function UpdatePlayerList()
        for _, child in pairs(playerList:GetChildren()) do
            child:Destroy()
        end
        
        local y = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 35)
                frame.Position = UDim2.new(0, 0, y, 0)
                frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                frame.BorderSizePixel = 0
                frame.Parent = playerList
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 4)
                corner.Parent = frame
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
                nameLabel.Position = UDim2.new(0.02, 0, 0, 0)
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextScaled = true
                nameLabel.Parent = frame
                
                local killBtn = Instance.new("TextButton")
                killBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
                killBtn.Position = UDim2.new(0.35, 0, 0.1, 0)
                killBtn.Text = "💀"
                killBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
                killBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
                killBtn.BorderSizePixel = 0
                killBtn.Font = Enum.Font.GothamBold
                killBtn.TextScaled = true
                killBtn.Parent = frame
                
                local corner2 = Instance.new("UICorner")
                corner2.CornerRadius = UDim.new(0, 4)
                corner2.Parent = killBtn
                
                local kickBtn = Instance.new("TextButton")
                kickBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
                kickBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
                kickBtn.Text = "👢"
                kickBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
                kickBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 0)
                kickBtn.BorderSizePixel = 0
                kickBtn.Font = Enum.Font.GothamBold
                kickBtn.TextScaled = true
                kickBtn.Parent = frame
                
                local corner3 = Instance.new("UICorner")
                corner3.CornerRadius = UDim.new(0, 4)
                corner3.Parent = kickBtn
                
                local loopBtn = Instance.new("TextButton")
                loopBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
                loopBtn.Position = UDim2.new(0.69, 0, 0.1, 0)
                loopBtn.Text = "🔄"
                loopBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
                loopBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 50)
                loopBtn.BorderSizePixel = 0
                loopBtn.Font = Enum.Font.GothamBold
                loopBtn.TextScaled = true
                loopBtn.Parent = frame
                
                local corner4 = Instance.new("UICorner")
                corner4.CornerRadius = UDim.new(0, 4)
                corner4.Parent = loopBtn
                
                local dropBtn = Instance.new("TextButton")
                dropBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
                dropBtn.Position = UDim2.new(0.86, 0, 0.1, 0)
                dropBtn.Text = "📦"
                dropBtn.TextColor3 = Color3.fromRGB(255, 100, 255)
                dropBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 50)
                dropBtn.BorderSizePixel = 0
                dropBtn.Font = Enum.Font.GothamBold
                dropBtn.TextScaled = true
                dropBtn.Parent = frame
                
                local corner5 = Instance.new("UICorner")
                corner5.CornerRadius = UDim.new(0, 4)
                corner5.Parent = dropBtn
                
                killBtn.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.Health = 0
                    end
                end)
                
                kickBtn.MouseButton1Click:Connect(function()
                    local function Kick()
                        pcall(function()
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                            if player.Character then player.Character:Destroy() end
                            for i = 1, 30 do
                                local ev = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
                                if ev then ev:FireServer() end
                                wait()
                            end
                        end)
                    end
                    spawn(Kick)
                end)
                
                local loopActive = false
                loopBtn.MouseButton1Click:Connect(function()
                    loopActive = not loopActive
                    loopBtn.BackgroundColor3 = loopActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 50, 50)
                    if loopActive then
                        spawn(function()
                            while loopActive and player and player.Character do
                                pcall(function()
                                    if player.Character:FindFirstChild("Humanoid") then
                                        player.Character.Humanoid.Health = 0
                                    end
                                    wait(0.5)
                                end)
                                wait(0.5)
                            end
                        end)
                    end
                end)
                
                dropBtn.MouseButton1Click:Connect(function()
                    if player.Character then
                        for _, item in pairs(player.Character:GetDescendants()) do
                            if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Clothing") then
                                pcall(function()
                                    item.Parent = workspace
                                    wait(0.05)
                                    item:Destroy()
                                end)
                            end
                        end
                    end
                end)
                
                y = y + 0.05
            end
        end
        playerList.CanvasSize = UDim2.new(0, 0, 0, y * 35)
    end
    
    UpdatePlayerList()
    Players.PlayerAdded:Connect(UpdatePlayerList)
    Players.PlayerRemoving:Connect(UpdatePlayerList)
    
    -- DEFENSE TAB
    local defenseY = 0
    local antiKickState = false
    local antiGrabState = false
    local infiniteState = false
    local antiInputState = false
    
    local function AntiKick()
        if not antiKickState then return end
        pcall(function()
            local kicks = 0
            while antiKickState do
                local success, err = pcall(function()
                    local ev = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
                    if ev then ev:FireServer() end
                end)
                if not success then
                    kicks = kicks + 1
                    if kicks > 10 then
                        Player:Kick("Anti-Kick Active")
                        wait(0.1)
                    end
                end
                wait(0.1)
            end
        end)
    end
    
    local function AntiGrab()
        spawn(function()
            while antiGrabState do
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= Player and otherPlayer.Character then
                        local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if otherRoot and RootPart then
                            local distance = (RootPart.Position - otherRoot.Position).Magnitude
                            if distance < 10 then
                                Humanoid.PlatformStand = false
                                Humanoid:BreakJoints()
                                local pushDir = (otherRoot.Position - RootPart.Position).Unit * 80
                                otherRoot.Velocity = pushDir + Vector3.new(0, 40, 0)
                            end
                        end
                    end
                end
                wait(0.2)
            end
        end)
    end
    
    local function Infinite()
        spawn(function()
            while infiniteState do
                pcall(function()
                    local success, err = pcall(function()
                        Player:Kick("")
                    end)
                    if success then
                        wait(5)
                        Player:Kick("")
                    end
                end)
                wait(0.5)
            end
        end)
    end
    
    local function AntiInput()
        spawn(function()
            while antiInputState do
                pcall(function()
                    local tool = Character:FindFirstChildOfClass("Tool")
                    if tool then
                        local handle = tool:FindFirstChild("Handle")
                        if handle then
                            handle.Velocity = Vector3.new(
                                math.random(-100, 100),
                                math.random(50, 150),
                                math.random(-100, 100)
                            )
                        end
                    end
                end)
                wait(0.05)
            end
        end)
    end
    
    local toggle1 = CreateToggle(DefenseFrame, "🛡️ Infinite (Нельзя кикнуть)", defenseY, false, function(state)
        infiniteState = state
        if state then Infinite() end
    end)
    defenseY = defenseY + 0.1
    
    local toggle2 = CreateToggle(DefenseFrame, "🤚 Anti-Grab (Слабый)", defenseY, false, function(state)
        antiGrabState = state
        if state then AntiGrab() end
    end)
    defenseY = defenseY + 0.1
    
    local toggle3 = CreateToggle(DefenseFrame, "👢 Anti-Kick Suriken", defenseY, false, function(state)
        antiKickState = state
        if state then AntiKick() end
    end)
    defenseY = defenseY + 0.1
    
    local toggle4 = CreateToggle(DefenseFrame, "🎯 Anti-Input (Спам в руке)", defenseY, false, function(state)
        antiInputState = state
        if state then AntiInput() end
    end)
    defenseY = defenseY + 0.1
    
    -- VISUAL TAB
    local visualY = 0
    local thirdPersonState = false
    local espState = false
    
    local toggle5 = CreateToggle(VisualFrame, "👤 Third Person", visualY, false, function(state)
        thirdPersonState = state
        if state then
            Camera.CameraSubject = Character
            Camera.CameraType = Enum.CameraType.Follow
            Camera.FieldOfView = 70
        else
            Camera.CameraType = Enum.CameraType.Custom
        end
    end)
    visualY = visualY + 0.1
    
    local toggle6 = CreateToggle(VisualFrame, "👁️ ESP Players", visualY, false, function(state)
        espState = state
    end)
    visualY = visualY + 0.1
    
    -- MISC TAB
    local miscY = 0
    
    CreateButton(MiscFrame, "📦 Drop All Items", miscY, function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, item in pairs(player.Character:GetDescendants()) do
                    if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Clothing") then
                        pcall(function()
                            item.Parent = workspace
                            wait(0.05)
                            item:Destroy()
                        end)
                    end
                end
            end
        end
    end)
    miscY = miscY + 0.1
    
    CreateButton(MiscFrame, "👢 Kick All Players", miscY, function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player then
                spawn(function()
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                        if player.Character then player.Character:Destroy() end
                        for i = 1, 30 do
                            local ev = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
                            if ev then ev:FireServer() end
                            wait()
                        end
                    end)
                end)
                wait(0.3)
            end
        end
    end)
    miscY = miscY + 0.1
    
    CreateButton(MiscFrame, "💀 Kill All Players", miscY, function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
            wait(0.1)
        end
    end)
    miscY = miscY + 0.1
    
    CreateButton(MiscFrame, "🌀 Reset Server", miscY, function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            part.Velocity = Vector3.new(
                                math.random(-200, 200),
                                math.random(100, 300),
                                math.random(-200, 200)
                            )
                        end)
                    end
                end
                wait(0.1)
                player.Character:Destroy()
            end
        end
    end)
    miscY = miscY + 0.1
    
    CreateButton(MiscFrame, "🗑️ Clear Game Items", miscY, function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Clothing") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
    miscY = miscY + 0.1
    
    local openBtn = Instance.new("TextButton")
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(0.01, 0, 0.5, -25)
    openBtn.Text = "⚡"
    openBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    openBtn.BackgroundTransparency = 0.2
    openBtn.BorderSizePixel = 0
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextScaled = true
    openBtn.Parent = ScreenGui
    
    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(1, 0)
    openCorner.Parent = openBtn
    
    openBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        openBtn.Visible = not MainFrame.Visible
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightAlt then
            MainFrame.Visible = not MainFrame.Visible
            openBtn.Visible = not MainFrame.Visible
        end
    end)
    
    -- ESP Logic
    local ESPObjects = {}
    
    local function CreateESPObject(player)
        if ESPObjects[player] then return end
        local esp = {
            Box = Drawing.new("Square"),
            Name = Drawing.new("Text")
        }
        esp.Box.Thickness = 1.5
        esp.Box.Filled = false
        esp.Box.Visible = false
        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Visible = false
        esp.Name.Font = Drawing.Fonts.UI
        ESPObjects[player] = esp
    end
    
    local function RemoveESPObject(player)
        local esp = ESPObjects[player]
        if esp then
            esp.Box:Remove()
            esp.Name:Remove()
            ESPObjects[player] = nil
        end
    end
    
    RunService.RenderStepped:Connect(function()
        if espState then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local char = player.Character
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    if root then
                        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                        if onScreen then
                            local esp = ESPObjects[player]
                            if not esp then CreateESPObject(player) end
                            esp = ESPObjects[player]
                            if esp then
                                local head = char:FindFirstChild("Head")
                                if head then
                                    local headPos, _ = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 1.5, 0))
                                    local height = 100
                                    local width = 50
                                    esp.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                                    esp.Box.Size = Vector2.new(width, height)
                                    esp.Box.Color = Color3.fromRGB(255, 0, 0)
                                    esp.Box.Visible = true
                                    
                                    esp.Name.Text = player.Name
                                    esp.Name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                                    esp.Name.Color = Color3.fromRGB(255, 255, 255)
                                    esp.Name.Visible = true
                                end
                            end
                        else
                            local esp = ESPObjects[player]
                            if esp then
                                esp.Box.Visible = false
                                esp.Name.Visible = false
                            end
                        end
                    end
                end
            end
        else
            for player, esp in pairs(ESPObjects) do
                esp.Box.Visible = false
                esp.Name.Visible = false
            end
        end
    end)
    
    SwitchTab("Players")
    
    return ScreenGui
end

CreateMenu()

print("✅ Меню загружено! Нажми RightAlt для открытия")
