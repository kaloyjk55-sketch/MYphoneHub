--[[
    👑 PROJECT: ThD Hub v9.0 - THE HYPER-OPTIMIZATION (ALL FIXED)
    👤 AUTHOR: ThD (Re-engineered for Mobile by AI #1)
    📱 TARGET: Mobile/Tablet - Zero Lag, Pure Performance, Single-Loop Core
]]

-- Chờ game tải hoàn tất để tránh lỗi nil instance
if not game:IsLoaded() then game.Loaded:Wait() end

-- --- [ TỐI ƯU HÓA BIẾN TOÀN CỤC ] ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Lưu trữ bộ nhớ đệm (Tăng tốc độ truy xuất, giảm lag)
local LocalChar, LocalHRP, LocalHum
local function UpdateLocalCache(char)
    LocalChar = char
    LocalHRP = char:WaitForChild("HumanoidRootPart", 5)
    LocalHum = char:WaitForChild("Humanoid", 5)
end
if LocalPlayer.Character then UpdateLocalCache(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(UpdateLocalCache)

-- --- [ QUẢN LÝ BIẾN HỆ THỐNG ] ---
local Flags = {
    Fly = false, FlySpeed = 80,
    Noclip = false,
    ESP = false,
    Aimbot = false, AimSmooth = 0.1, AimFOV = 120,
    SpeedActive = false, WalkSpeed = 80, InfJump = false,
    AutoClick = false, AntiLag = false, AntiAFK = true
}

-- --- [ DRAWING CACHE SYSTEM: AIMBOT FOV ] ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 180)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Visible = false

-- --- [ ALGORITHM: TÌM MỤC TIÊU NHANH NHẤT (O(N) OPTIMIZED) ] ---
local function GetClosestPlayer()
    local target = nil
    local dist = Flags.AimFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
            local pHum = p.Character:FindFirstChild("Humanoid")
            if pRoot and pHum and pHum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(pRoot.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        target = p
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- --- [ LIGHTWEIGHT HYPER BYPASS ] ---
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and self:IsA("BasePart") and (key == "Velocity" or key == "CFrame") then
        if Flags.Fly or Flags.SpeedActive then return Vector3.new(0, 0, 0) end
    end
    return oldIndex(self, key)
end)

-- --- [ SINGLE-LOOP CORE ENGINE (HỢP NHẤT TOÀN BỘ VÒNG LẶP CHỐNG LAG) ] ---
RunService.Heartbeat:Connect(function()
    if not LocalChar or not LocalHRP or not LocalHum then return end

    -- 1. Xử lý Fly Mode Mỏ Neo Tối Ưu
    if Flags.Fly then
        local vel = LocalHRP:FindFirstChild("ThD_Vel") or Instance.new("BodyVelocity", LocalHRP)
        local gyro = LocalHRP:FindFirstChild("ThD_Gyro") or Instance.new("BodyGyro", LocalHRP)
        vel.Name = "ThD_Vel"; vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        gyro.Name = "ThD_Gyro"; gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        
        gyro.CFrame = Camera.CFrame
        vel.Velocity = LocalHum.MoveDirection.Magnitude > 0 and Camera.CFrame.LookVector * Flags.FlySpeed or Vector3.new(0, 0, 0)
    else
        local vel = LocalHRP:FindFirstChild("ThD_Vel")
        local gyro = LocalHRP:FindFirstChild("ThD_Gyro")
        if vel then vel:Destroy() end
        if gyro then gyro:Destroy() end
    end

    -- 2. Xử lý Noclip Siêu Nhẹ
    if Flags.Noclip then
        for _, part in pairs(LocalChar:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- 3. Xử lý Tốc Độ Chạy Nhân Vật
    if Flags.SpeedActive then
        LocalHum.WalkSpeed = Flags.WalkSpeed
    end

    -- 4. Xử lý Aimbot Nhắm Thẳng Không Kẹt Cam
    FOVCircle.Visible = Flags.Aimbot
    if Flags.Aimbot then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Flags.AimFOV
        
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetLook = CFrame.lookAt(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetLook, Flags.AimSmooth)
        end
    end
end)

-- --- [ ANTI-LAG ENGINE (DỌN RÁC ĐỒ HỌA MẠNH MẼ) ] ---
local function CleanInstance(part)
    if Flags.AntiLag then
        if part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Smoke") or part:IsA("Sparkles") then 
            part.Enabled = false
        elseif part:IsA("Decal") or part:IsA("Texture") then 
            part.Transparency = 1 
        end
    end
end
workspace.DescendantAdded:Connect(CleanInstance)

local function ToggleAntiLag(enable)
    settings().Rendering.QualityLevel = enable and 1 or 5
    for _, v in pairs(workspace:GetDescendants()) do
        if enable then CleanInstance(v) else
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = true
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
    end
end

-- --- [ HIGH-PERFORMANCE ESP SYSTEM (SỬ DỤNG CACHE OBJECT) ] ---
local ESPOBJECTS = {}

local function ClearESP(p)
    if ESPOBJECTS[p] then
        for _, obj in pairs(ESPOBJECTS[p].Drawings) do obj:Destroy() end
        if ESPOBJECTS[p].Conn then ESPOBJECTS[p].Conn:Disconnect() end
        ESPOBJECTS[p] = nil
    end
end

local function CreateESP(p)
    if p == LocalPlayer then return end
    ClearESP(p)

    local Box = Drawing.new("Square")
    Box.Thickness = 1.5; Box.Color = Color3.fromRGB(0, 255, 180); Box.Filled = false; Box.Transparency = 0.7; Box.Visible = false

    local BarBg = Drawing.new("Square")
    BarBg.Thickness = 1; BarBg.Color = Color3.fromRGB(0, 0, 0); BarBg.Filled = true; BarBg.Transparency = 0.4; BarBg.Visible = false

    local Bar = Drawing.new("Square")
    Bar.Thickness = 1; Bar.Filled = true; Bar.Transparency = 0.8; Bar.Visible = false

    local Text = Drawing.new("Text")
    Text.Size = 12; Text.Center = true; Text.Outline = true; Text.OutlineColor = Color3.fromRGB(0, 0, 0); Text.Color = Color3.fromRGB(255, 255, 255); Text.Visible = false

    ESPOBJECTS[p] = {
        Drawings = {Box, BarBg, Bar, Text},
        Conn = RunService.RenderStepped:Connect(function()
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if Flags.ESP and hrp and hum and hum.Health > 0 and LocalHRP then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local scale = 1 / (hrpPos.Z * 0.04) * 100
                    local w, h = 1 * scale, 1.4 * scale
                    local x, y = hrpPos.X - w / 2, hrpPos.Y - h / 2

                    Box.Position = Vector2.new(x, y); Box.Size = Vector2.new(w, h); Box.Visible = true

                    local healthPercent = hum.Health / hum.MaxHealth
                    BarBg.Position = Vector2.new(x - 6, y); BarBg.Size = Vector2.new(3, h); BarBg.Visible = true
                    Bar.Position = Vector2.new(x - 6, y + (h * (1 - healthPercent))); Bar.Size = Vector2.new(3, h * healthPercent)
                    Bar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                    Bar.Visible = true

                    local dist = math.floor((LocalHRP.Position - hrp.Position).Magnitude)
                    Text.Text = string.format("%s [%dm]", p.Name, dist)
                    Text.Position = Vector2.new(hrpPos.X, y - 25); Text.Visible = true
                    return
                end
            end
            Box.Visible = false; BarBg.Visible = false; Bar.Visible = false; Text.Visible = false
        end)
    }
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(ClearESP)

-- --- [ EVENT PHỤ ĐƯỢC TỐI ƯU TẦN SUẤT CHẠY ] ---
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalHum then LocalHum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

task.spawn(function()
    while task.wait(0.1) do -- Giảm tần suất click từ 0.08 xuống 0.1 để CPU nghỉ ngơi
        if Flags.AutoClick and LocalChar then
            local tool = LocalChar:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- --- [ HIGH-PERFORMANCE CYBERPUNK UI V9.0 ] ---
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ThD_Optimized_V9"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 15, 19)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Glow = Instance.new("UIStroke", MainFrame)
Glow.Thickness = 1.5; Glow.Color = Color3.fromRGB(0, 255, 180)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40); Header.Text = "ThD HUB • HYPER v9.0"; Header.TextColor3 = Color3.fromRGB(255, 255, 255); Header.Font = Enum.Font.GothamBold; Header.BackgroundTransparency = 1; Header.TextSize = 12

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -16, 1, -55); Scroll.Position = UDim2.new(0, 8, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 610); Scroll.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", Scroll); ListLayout.Padding = UDim.new(0, 6)

-- Component: Toggle Tối Giản
local function AddToggle(name, flag, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 36); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    
    local function Update()
        if Flags[flag] then
            btn.Text = "⚡ " .. name .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(18, 32, 28); stroke.Color = Color3.fromRGB(0, 255, 180); btn.TextColor3 = Color3.fromRGB(0, 255, 180)
        else
            btn.Text = "  " .. name .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(22, 23, 27); stroke.Color = Color3.fromRGB(38, 40, 48); btn.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; Update(); if callback then callback(Flags[flag]) end end)
    Update()
end

-- Component: Slider (+/-) Tối Giản Tăng Diện Tích Bấm
local function AddSlider(name, min, max, flag, step)
    local pnl = Instance.new("Frame", Scroll); pnl.Size = UDim2.new(1, 0, 0, 44); pnl.BackgroundColor3 = Color3.fromRGB(20, 21, 25); Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", pnl); lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = name .. "\n➔ " .. Flags[flag]; lbl.TextColor3 = Color3.fromRGB(180, 180, 180); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
    
    local btnSub = Instance.new("TextButton", pnl); btnSub.Size = UDim2.new(0, 30, 0, 30); btnSub.Position = UDim2.new(0.62, 0, 0.15, 0); btnSub.Text = "-"; btnSub.Font = Enum.Font.GothamBold; btn
