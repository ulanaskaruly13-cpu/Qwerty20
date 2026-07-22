local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local CONFIG = {
    Speed = 150,               
    FlyMode = "Free",          
    AutoHeight = 50,           
    NoClip = true,            
    AntiFall = true,          
    SmoothMovement = true,    
    JumpBoost = 100,          
}

-- ========== ПЕРЕМЕННЫЕ ==========
local flying = false
local flyDirection = Vector3.new(0, 0, 0)
local currentSpeed = 0
local maxSpeed = CONFIG.Speed
local isMoving = false


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player.PlayerGui

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 150, 0, 50)
FlyButton.Position = UDim2.new(0.5, -75, 0.8, 0)
FlyButton.Text = "🔹 ВЗЛЕТЕТЬ"
FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Parent = ScreenGui

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0, 200, 0, 30)
StatusText.Position = UDim2.new(0.5, -100, 0.85, 0)
StatusText.Text = "Статус: На земле"
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.TextScaled = true
StatusText.Parent = ScreenGui




local function ToggleFly()
    flying = not flying
    
    if flying then
        
        Humanoid.PlatformStand = true
        
        
        if CONFIG.NoClip then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        
        local targetPos = RootPart.Position + Vector3.new(0, 10, 0)
        if CONFIG.FlyMode == "Auto" then
            targetPos = Vector3.new(RootPart.Position.X, CONFIG.AutoHeight, RootPart.Position.Z)
        end
        
        local tween = TweenService:Create(RootPart, TweenInfo.new(0.5), {Position = targetPos})
        tween:Play()
        
        FlyButton.Text =
        StatusText.Text =
        StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        print
    else
        
        Humanoid.PlatformStand = false
        
        if CONFIG.NoClip then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        
        RootPart.Velocity = Vector3.new(0, -10, 0)
        FlyButton.Text = "🔹 ВЗЛЕТЕТЬ"
        StatusText.Text = "Статус: 🏠 На земле"
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        flyDirection = Vector3.new(0, 0, 0)
        currentSpeed = 0
        
        print("🛬 Полет деактивирован")
    end
end

 WASD
local function GetFlyDirection()
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDirection = moveDirection + Vector3.new(0, -1, 0)
    end
    
    return moveDirection.Unit
end

-- Обновление позиции полёта
local function UpdateFly()
    if not flying or not RootPart then return end
    
    -- Получаем направление
    local rawDirection = Vector3.new(0, 0, 0)
    
    if CONFIG.FlyMode == "Camera" then
        
        local cameraLook = Camera.CFrame.LookVector
        local moveInput = GetFlyDirection()
        rawDirection = (cameraLook * moveInput.Z) + (Camera.CFrame.RightVector * moveInput.X) + (Vector3.new(0, 1, 0) * moveInput.Y)
    elseif CONFIG.FlyMode == "Auto" then
        -- Автопилот: держимся на одной высоте
        rawDirection = GetFlyDirection()
        local heightDiff = CONFIG.AutoHeight - RootPart.Position.Y
        if math.abs(heightDiff) > 2 then
            rawDirection = rawDirection + Vector3.new(0, math.sign(heightDiff) * 0.5, 0)
        end
    else
        -- Свободный полёт (абсолютные координаты)
        rawDirection = GetFlyDirection()
    end
    
  
    isMoving = rawDirection.Magnitude > 0.1
    
    if isMoving then
      
        flyDirection = rawDirection.Unit
        
        
        if CONFIG.SmoothMovement then
            currentSpeed = math.min(currentSpeed + 10, maxSpeed)
        else
            currentSpeed = maxSpeed
        end
    else
    
        if CONFIG.SmoothMovement then
            currentSpeed = math.max(currentSpeed - 5, 0)
        else
            currentSpeed = 0
        end
    end
    
    
    if currentSpeed > 0 then
        local velocity = flyDirection * currentSpeed
        RootPart.Velocity = velocity
    else
        RootPart.Velocity = Vector3.new(0, 0, 0)
    end
    
    
    if CONFIG.AntiFall and RootPart.Position.Y < 0 then
        RootPart.Position = Vector3.new(RootPart.Position.X, 10, RootPart.Position.Z)
        print("🆘 Спасение от падения!")
    end
    
    
    if isMoving then
        StatusText.Text = "✈️ Скорость: " .. math.floor(currentSpeed)
    end
end


local function FlyJump()
    if flying then
        RootPart.Velocity = RootPart.Velocity + Vector3.new(0, CONFIG.JumpBoost, 0)
        print("💨 Буст активирован!")
    end
end


FlyButton.MouseButton1Click:Connect(ToggleFly)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFly()
    end
    
    if input.KeyCode == Enum.KeyCode.LeftControl and flying then
        CONFIG.Speed = CONFIG.Speed + 10
        maxSpeed = CONFIG.Speed
        print("⚡ Скорость: " .. CONFIG.Speed)
    end
    
    if input.KeyCode == Enum.KeyCode.LeftAlt and flying then
        CONFIG.Speed = math.max(CONFIG.Speed - 10, 10)
        maxSpeed = CONFIG.Speed
        print("🐢 Скорость: " .. CONFIG.Speed)
    end
end)


RunService.Heartbeat:Connect(UpdateFly)


Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    if flying then
        flying = false
        ToggleFly()
    end
end)




UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        CONFIG.FlyMode = "Camera"
        print("📷 Режим: По камере")
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        CONFIG.FlyMode = "Free"
        print("🆓 Режим: Свободный")
    end
end)



local function ChatCommand(msg)
    local cmd = msg:lower()
    
    if cmd == "/fly" then
        ToggleFly()
    elseif cmd == "/speed" then
        local newSpeed = tonumber(msg:match("/speed (.+)"))
        if newSpeed then
            CONFIG.Speed = newSpeed
            maxSpeed = newSpeed
            print("⚡ Скорость изменена на: " .. newSpeed)
        else
            print("Использование: /speed [число]")
        end
    elseif cmd == "/mode free" then
        CONFIG.FlyMode = "Free"
        print("🆓 Режим: Свободный")
    elseif cmd == "/mode camera" then
        CONFIG.FlyMode = "Camera"
        print("📷 Режим: По камере")
    elseif cmd == "/mode auto" then
        CONFIG.FlyMode = "Auto"
        print("🤖 Режим: Автопилот")
    elseif cmd == "/height" then
        local newHeight = tonumber(msg:match("/height (.+)"))
        if newHeight then
            CONFIG.AutoHeight = newHeight
            print("📏 Высота автопилота: " .. newHeight)
        end
    end
end

Player.Chatted:Connect(ChatCommand) 

print(

print([[

    ████████╗███████╗███████╗██████╗ 
    ╚══██╔══╝██╔════╝██╔════╝██╔══██╗
       ██║   █████╗  █████╗  ██████╔╝
       ██║   ██╔══╝  ██╔══╝  ██╔══██╗
       ██║   ██║     ███████╗██║  ██║
       ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝
    
    
    
    
    [F] - Вкл/Выкл полёт
    [WASD] - Движение
    [Space] - Вверх
    [Shift] - Вниз
    [Ctrl] - Увеличить скорость
    [Alt] - Уменьшить скорость
    [ПКМ] - Режим "По камере"
    
    
    /fly - Вкл/Выкл
    /speed [число] - Изменить скорость
    /mode [free/camera/auto] - Сменить режим
    /height [число] - Высота автопилота
    
    
]])

-- Автоматический полёт при запуске (закомментируйте, если не нужно)
-- wait(1)
-- ToggleFly()
