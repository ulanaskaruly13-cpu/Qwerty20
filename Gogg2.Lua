local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local loopCounter = {}
local grabbers = {}

local function KickPlayer(target)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        wait(0.1)
        
        local fakeEvent = Instance.new("RemoteEvent")
        fakeEvent.Name = "Kick_" .. tostring(os.time())
        fakeEvent.Parent = ReplicatedStorage
        fakeEvent:FireClient(target)
        wait(0.1)
        fakeEvent:Destroy()
        
        if target.Character then
            target.Character:Destroy()
        end
        
        for i = 1, 50 do
            local ev = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
            if ev then ev:FireServer() end
            wait()
        end
    end)
end

local function DropItems(char)
    if not char then return end
    for _, item in pairs(char:GetDescendants()) do
        if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Clothing") then
            pcall(function()
                local handle = item:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = false
                    handle.Velocity = Vector3.new(math.random(-50,50), math.random(20,60), math.random(-50,50))
                end
                item.Parent = workspace
                wait(0.1)
                item:Destroy()
            end)
        end
    end
    for _, acc in pairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            pcall(function() acc:Destroy() end)
        end
    end
end

local function AntiGrab()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot and RootPart then
                local distance = (RootPart.Position - otherRoot.Position).Magnitude
                if distance < 15 then
                    local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                    if otherHumanoid then
                        Humanoid.PlatformStand = false
                        Humanoid:BreakJoints()
                        
                        local pushDir = (otherRoot.Position - RootPart.Position).Unit * 100
                        otherRoot.Velocity = pushDir + Vector3.new(0, 50, 0)
                        
                        if not grabbers[otherPlayer] then
                            grabbers[otherPlayer] = true
                            KickPlayer(otherPlayer)
                        end
                        
                        DropItems(Character)
                    end
                end
            end
        end
    end
end

local function AntiLoop()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            if otherHumanoid then
                local animator = otherHumanoid:FindFirstChild("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.IsPlaying then
                            local key = otherPlayer.Name .. "_" .. tostring(track.AnimationId)
                            loopCounter[key] = (loopCounter[key] or 0) + 1
                            
                            if loopCounter[key] > 5 then
                                Humanoid.PlatformStand = false
                                Humanoid:BreakJoints()
                                KickPlayer(otherPlayer)
                                DropItems(Character)
                                loopCounter[key] = 0
                            end
                        end
                    end
                end
            end
        end
    end
    
    if tick() % 10 < 0.5 then
        loopCounter = {}
    end
end

local function KickAll()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot and RootPart then
                local distance = (RootPart.Position - otherRoot.Position).Magnitude
                if distance < 20 then
                    KickPlayer(otherPlayer)
                end
            end
        end
    end
end

spawn(function()
    while wait(0.3) do
        if Character and Humanoid and RootPart then
            AntiGrab()
        end
    end
end)

spawn(function()
    while wait(0.5) do
        if Character and Humanoid then
            AntiLoop()
        end
    end
end)

Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    wait(1)
    DropItems(Character)
end)

Player.Chatted:Connect(function(msg)
    if msg:lower() == "/kickall" then
        KickAll()
    end
end)
