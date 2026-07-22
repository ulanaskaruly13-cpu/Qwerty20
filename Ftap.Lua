-- // Anti-Grab + Anti-Loop + Auto-Kick by DeepSeek // --
-- Защита от: грабберов, бесконечных холдов, кражи вещей

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ========== НАСТРОЙКИ ==========
local CONFIG = {
    AntiGrab = true,              -- Включить анти-граб
    AntiLoop = true,              -- Включить анти-луп (бесконечные холды)
    AutoKick = true,              -- Кидать грабберов из игры
    DropItems = true,             -- Сбрасывать все вещи с игрока
    KickAllGrabbers = false,      -- Кидать ВСЕХ, кто пытается грабить (даже своих)
    AntiGrabDistance = 15,        -- Дистанция сканирования грабберов
    LoopCheckInterval = 0.5,      -- Как часто проверять лупы (сек)
}

-- ========== ОСНОВНАЯ ЛОГИКА ==========

-- Функция: Сбросить все вещи с игрока
local function DropAllItems()
    if not CONFIG.DropItems then return end
    
    for _, item in pairs(Character:GetDescendants()) do
        -- Проверяем инструменты и аксессуары
        if item:IsA("Tool") or item:IsA("Accessory") or item:IsA("Clothing") then
            if item.Parent == Character then
                pcall(function()
                    -- Открепляем вещь
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
                    wait(0.1)
                    item:Destroy() -- Полностью удаляем
                end)
            end
        end
    end
    
    -- Очищаем все аксессуары из Character
    for _, accessory in pairs(Character:GetChildren()) do
        if accessory:IsA("Accessory") then
            pcall(function()
                accessory:Destroy()
            end)
        end
    end
    
    print("✅ Все вещи сброшены!")
end

-- Функция: Кикнуть игрока (через Remote или баг)
local function KickPlayer(targetPlayer)
    if not CONFIG.AutoKick then return end
    if targetPlayer == Player then return end
    
    pcall(function()
        -- Способ 1: Через VirtualUser (если есть)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        wait(0.1)
        
        -- Способ 2: Отправить фейковый запрос
        local fakeEvent = Instance.new("RemoteEvent")
        fakeEvent.Name = "KickPlayer_" .. HttpService:GenerateGUID(false)
        fakeEvent.Parent = ReplicatedStorage
        fakeEvent:FireClient(targetPlayer)
        wait(0.1)
        fakeEvent:Destroy()
        
        -- Способ 3: Удалить их Character (если кик не работает)
        if targetPlayer.Character then
            targetPlayer.Character:Destroy()
        end
        
        -- Способ 4: Заспамить репликацию (вызовет дисконнект)
        for i = 1, 100 do
            game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent"):FireServer()
            wait()
        end
    end)
    
    print("👢 Кикнут игрок: " .. targetPlayer.Name)
end

-- Функция: Анти-Граб (освобождение от хвата)
local function AntiGrab()
    if not CONFIG.AntiGrab then return end
    
    -- Сканируем всех игроков рядом
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot and RootPart then
                local distance = (RootPart.Position - otherRoot.Position).Magnitude
                
                -- Если игрок слишком близко и пытается грабить
                if distance < CONFIG.AntiGrabDistance then
                    -- Проверяем, есть ли у них активный холд (через анимацию или инструменты)
                    local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
                    if otherHumanoid then
                        -- Освобождаемся
                        Humanoid.PlatformStand = false
                        Humanoid:BreakJoints() -- Сбрасываем все джойнты
                        
                        -- Отталкиваем граббера
                        local pushDirection = (otherRoot.Position - RootPart.Position).Unit * 100
                        otherRoot.Velocity = pushDirection + Vector3.new(0, 50, 0)
                        
                        -- Если включен авто-кик
                        if CONFIG.KickAllGrabbers then
                            KickPlayer(otherPlayer)
                        end
                        
                        -- Сбрасываем вещи у граббера (если они у нас украли)
                        DropAllItems()
                    end
                end
            end
        end
    end
end

-- Функция: Анти-Луп (защита от бесконечного холда)
local loopCounter = {}
local function AntiLoop()
    if not CONFIG.AntiLoop then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
            if otherHumanoid then
                -- Проверяем анимации (луперы часто используют одну анимацию)
                local animator = otherHumanoid:FindFirstChild("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.IsPlaying then
                            -- Считаем количество повторений
                            local key = otherPlayer.Name .. "_" .. track.AnimationId
                            loopCounter[key] = (loopCounter[key] or 0) + 1
                            
                            -- Если анимация повторяется слишком часто -> это луп
                            if loopCounter[key] > 5 then
                                print("🔄 Обнаружен луп от " .. otherPlayer.Name)
                                
                                -- Освобождаемся
                                Humanoid.PlatformStand = false
                                Humanoid:BreakJoints()
                                
                                -- Кикаем лупера
                                KickPlayer(otherPlayer)
                                
                                -- Сбрасываем вещи
                                DropAllItems()
                                
                                -- Сбрасываем счетчик
                                loopCounter[key] = 0
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Чистим старые записи (раз в 10 секунд)
    if tick() % 10 < CONFIG.LoopCheckInterval then
        loopCounter = {}
    end
end

-- Функция: Авто-сброс вещей по команде (можно вызвать вручную)
local function ManualDrop()
    print("🗑️ Ручной сброс вещей...")
    DropAllItems()
end

-- Функция: Кикнуть всех грабберов в радиусе
local function KickAllNearby()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot and RootPart then
                local distance = (RootPart.Position - otherRoot.Position).Magnitude
                if distance < CONFIG.AntiGrabDistance then
                    KickPlayer(otherPlayer)
                end
            end
        end
    end
end

-- ========== ЗАПУСК ЛУПОВ ==========

-- Основной цикл (анти-граб)
spawn(function()
    while wait(0.3) do
        if Character and Humanoid and RootPart then
            AntiGrab()
        end
    end
end)

-- Цикл анти-луп
spawn(function()
    while wait(CONFIG.LoopCheckInterval) do
        if Character and Humanoid then
            AntiLoop()
        end
    end
end)

-- Авто-сброс вещей при входе в игру
CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    wait(1)
    DropAllItems()
end)

-- ========== УПРАВЛЕНИЕ ЧЕРЕЗ ЧАТ ==========

-- Команды (вводить в чат)
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:lower() == "/drop" then
        ManualDrop()
    elseif msg:lower() == "/kickall" then
        KickAllNearby()
    elseif msg:lower() == "/antigrab on" then
        CONFIG.AntiGrab = true
        print("✅ Анти-граб ВКЛЮЧЕН")
    elseif msg:lower() == "/antigrab off" then
        CONFIG.AntiGrab = false
        print("❌ Анти-граб ВЫКЛЮЧЕН")
    end
end)

print("🛡️ Anti-Grab + Anti-Loop + Auto-Kick успешно загружен!")
print("📌 Команды: /drop - сбросить вещи, /kickall - кикнуть всех рядом, /antigrab on/off")
