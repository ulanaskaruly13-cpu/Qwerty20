local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local function DropItems(char)
    if not char then return end
    
    for _, item in pairs(char:GetDescendants()) do
        if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Clothing") then
            pcall(function()
                local handle = item:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = false
                    handle.Velocity = Vector3.new(
                        math.random(-50, 50),
                        math.random(20, 60),
                        math.random(-50, 50)
                    )
                end
                item.Parent = workspace
                wait(0.05)
                item:Destroy()
            end)
        end
    end
    
    for _, acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            pcall(function() acc:Destroy() end)
        end
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.Velocity = Vector3.new(
                    math.random(-30, 30),
                    math.random(10, 40),
                    math.random(-30, 30)
                )
            end)
        end
    end
end

local function DropAllPlayersItems()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            DropItems(player.Character)
        end
    end
end

local function KickPlayer(target)
    pcall(function()
        if target.Character then
            target.Character:Destroy()
        end
        
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        wait(0.1)
        
        for i = 1, 30 do
            local ev = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
            wait()
        end
    end)
end

local function KickAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            KickPlayer(player)
            wait(0.2)
        end
    end
end

local function ResetServer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local char = player.Character
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.Velocity = Vector3.new(
                            math.random(-100, 100),
                            math.random(50, 150),
                            math.random(-100, 100)
                        )
                    end)
                end
            end
            wait(0.1)
            char:Destroy()
        end
    end
end

Player.Chatted:Connect(function(msg)
    local cmd = msg:lower()
    
    if cmd == "/drop" then
        DropItems(Character)
    elseif cmd == "/dropall" then
        DropAllPlayersItems()
    elseif cmd == "/kickall" then
        KickAllPlayers()
    elseif cmd == "/reset" then
        ResetServer()
    elseif cmd == "/cleargame" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Clothing") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then
        DropItems(Character)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        DropAllPlayersItems()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        KickAllPlayers()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        ResetServer()
    end
end)

print("Скрипт загружен: /drop, /dropall, /kickall, /reset, /cleargame")
