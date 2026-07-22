local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local LocalChar = Player.Character or Player.CharacterAdded:Wait()

local ESPObjects = {}

local function CreateESP(player)
    if player == Player then return end
    if ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local esp = {
        Player = player,
        Character = character,
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        NameTag = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
    }
    
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false
    esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
    
    esp.NameTag.Size = 14
    esp.NameTag.Center = true
    esp.NameTag.Visible = false
    esp.NameTag.Font = Drawing.Fonts.UI
    
    esp.HealthBar.Thickness = 3
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(255, 50, 50)
    esp.HealthBarBG.Thickness = 3
    esp.HealthBarBG.Visible = false
    esp.HealthBarBG.Color = Color3.fromRGB(30, 30, 30)
    
    ESPObjects[player] = esp
    return esp
end

local function RemoveESP(player)
    local esp = ESPObjects[player]
    if esp then
        esp.Box:Remove()
        esp.Tracer:Remove()
        esp.NameTag:Remove()
        esp.HealthBar:Remove()
        esp.HealthBarBG:Remove()
        ESPObjects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player == Player then continue end
        
        local character = player.Character
        if not character then 
            RemoveESP(player)
            continue 
        end
        
        local esp = ESPObjects[player]
        if not esp then
            esp = CreateESP(player)
            if not esp then continue end
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if not rootPart then 
            RemoveESP(player)
            continue 
        end
        
        local pos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.NameTag.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBG.Visible = false
            continue
        end
        
        local localRoot = LocalChar:FindFirstChild("HumanoidRootPart")
        if not localRoot then continue end
        
        local distance = (rootPart.Position - localRoot.Position).Magnitude
        if distance > 1000 then
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.NameTag.Visible = false
            esp.HealthBar.Visible = false
            esp.HealthBarBG.Visible = false
            continue
        end
        
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not head or not torso then
            esp.Box.Visible = false
            continue
        end
        
        local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 1.5, 0))
        local footPos, footOnScreen = Camera:WorldToScreenPoint(torso.Position - Vector3.new(0, 2, 0))
        
        if not headOnScreen or not footOnScreen then
            esp.Box.Visible = false
            continue
        end
        
        local height = footPos.Y - headPos.Y
        local width = height * 0.5
        local centerX = (headPos.X + footPos.X) / 2
        
        local boxPos = Vector2.new(centerX - width/2, headPos.Y)
        local boxSize = Vector2.new(width, height)
        
        local health = 100
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            health = (humanoid.Health / humanoid.MaxHealth) * 100
        end
        
        local r = 1 - (health / 100)
        local g = health / 100
        local boxColor = Color3.fromRGB(r * 255, g * 255, 0)
        
        esp.Box.Position = boxPos
        esp.Box.Size = boxSize
        esp.Box.Color = boxColor
        esp.Box.Visible = true
        
        esp.NameTag.Text = player.Name .. " | " .. math.floor(distance) .. "m"
        esp.NameTag.Position = Vector2.new(centerX, headPos.Y - 20)
        esp.NameTag.Color = boxColor
        esp.NameTag.Visible = true
        
        local barWidth = width
        local barHeight = 3
        local barPos = Vector2.new(centerX - barWidth/2, headPos.Y + height + 5)
        
        esp.HealthBarBG.From = barPos
        esp.HealthBarBG.To = Vector2.new(barPos.X + barWidth, barPos.Y)
        esp.HealthBarBG.Visible = true
        
        local healthWidth = (health / 100) * barWidth
        esp.HealthBar.From = barPos
        esp.HealthBar.To = Vector2.new(barPos.X + healthWidth, barPos.Y)
        esp.HealthBar.Visible = true
        
        local localPos, _ = Camera:WorldToScreenPoint(localRoot.Position)
        esp.Tracer.From = Vector2.new(localPos.X, localPos.Y)
        esp.Tracer.To = Vector2.new(centerX, headPos.Y + height/2)
        esp.Tracer.Visible = true
    end
    
    for player, esp in pairs(ESPObjects) do
        if not table.find(Players:GetPlayers(), player) then
            RemoveESP(player)
        end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)
