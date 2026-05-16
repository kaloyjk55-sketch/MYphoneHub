--[[
    👑 PROJECT: ThD Hub v10 - ULTIMATE CYBERPUNK (REAL-TIME STATS + GRADIENT UI)
    👤 AUTHOR: ThD (Re-engineered for Mobile by AI #1)
    📱 TARGET: Mobile/Tablet - High Performance, Beautiful Cyberpunk Aesthetic
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
FOVCircle.Color = Color3.fromRGB(0, 255, 255) -- Đổi sang màu Cyan đặc trưng Cyberpunk
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

-- --- [ SINGLE-LOOP CORE ENGINE + FPS COUNTER ] ---
local fpsCount = 0
local lastTick = tick()
local currentFps = 60

RunService.Heartbeat:Connect(function()
    -- Tính toán FPS mượt mà không tốn tài nguyên
    fpsCount = fpsCount + 1
    if tick() - lastTick >= 1 then
        currentFps = fpsCount
        fpsCount = 0
        lastTick = tick()
    end

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
    Box.Thickness = 1.5; Box.Color = Color3.fromRGB(0, 255, 255); Box.Filled = false; Box.Transparency = 0.7; Box.Visible = false

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
    while task.wait(0.1) do
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

-- --- [ HIGH-PERFORMANCE CYBERPUNK UI V10 ] ---
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ThD_Cyberpunk_V10"

-- ─── DÒNG CHỮ HIỂN THỊ THÔNG TIN GÓC MÀN HÌNH (STAT BANNER) ───
local StatLabel = Instance.new("TextLabel", ScreenGui)
StatLabel.Size = UDim2.new(0, 400, 0, 25)
StatLabel.Position = UDim2.new(0, 15, 0, 10) -- Nằm gọn gàng góc trên bên trái màn hình
StatLabel.BackgroundTransparency = 1
StatLabel.TextSize = 13
StatLabel.Font = Enum.Font.RobotoMono -- Font lập trình cực đẹp
StatLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
StatLabel.TextXAlignment = Enum.TextXAlignment.Left
StatLabel.TextStrokeTransparency = 0.5
StatLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Cập nhật thông tin thời gian thực mượt mà
task.spawn(function()
    while task.wait(0.5) do
        local dateString = os.date("%d/%m/%Y")
        local timeString = os.date("%X")
        StatLabel.Text = string.format("👤 Player: %s  |  ⚡ FPS: %d  |  📅 %s  |  ⏰ %s", LocalPlayer.Name, currentFps, dateString, timeString)
    end
end)

-- Main Frame Thiết kế theo phong cách Neon Gradient Cyberpunk
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Viền Neon phát sáng đổi màu Gradient cực sang
local Glow = Instance.new("UIStroke", MainFrame)
Glow.Thickness = 2
Glow.Color = Color3.fromRGB(0, 255, 255)

task.spawn(function()
    while task.wait(0.05) do
        local hue = (tick() % 5) / 5
        Glow.Color = Color3.fromHSV(hue, 1, 1)
    end
end)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45); Header.Text = "ThD HUB ★ ULTIMATE v10"; Header.TextColor3 = Color3.fromRGB(255, 255, 255); Header.Font = Enum.Font.GothamBold; Header.BackgroundTransparency = 1; Header.TextSize = 13

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -16, 1, -60); Scroll.Position = UDim2.new(0, 8, 0, 50); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 610); Scroll.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", Scroll); ListLayout.Padding = UDim.new(0, 6)

-- Component: Toggle Tối Giản Neon
local function AddToggle(name, flag, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 36); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    
    local function Update()
        if Flags[flag] then
            btn.Text = "🔷 " .. name .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(12, 28, 36); stroke.Color = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        else
            btn.Text = "  " .. name .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(20, 21, 25); stroke.Color = Color3.fromRGB(35, 37, 45); btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; Update(); if callback then callback(Flags[flag]) end end)
    Update()
end

-- Component: Slider (+/-) Cao Cấp
local function AddSlider(name, min, max, flag, step)
    local pnl = Instance.new("Frame", Scroll); pnl.Size = UDim2.new(1, 0, 0, 44); pnl.BackgroundColor3 = Color3.fromRGB(18, 19, 23); Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", pnl); lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = name .. "\n➔ " .. Flags[flag]; lbl.TextColor3 = Color3.fromRGB(160, 160, 160); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
    
    local btnSub = Instance.new("TextButton", pnl); btnSub.Size = UDim2.new(0, 30, 0, 30); btnSub.Position = UDim2.new(0.62, 0, 0.15, 0); btnSub.Text = "-"; btnSub.Font = Enum.Font.GothamBold; btnSub.BackgroundColor3 = Color3.fromRGB(26, 27, 33); btnSub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnSub).CornerRadius = UDim.new(0, 4)
    local btnAdd = Instance.new("TextButton", pnl); btnAdd.Size = UDim2.new(0, 30, 0, 30); btnAdd.Position = UDim2.new(0.82, 0, 0.15, 0); btnAdd.Text = "+"; btnAdd.Font = Enum.Font.GothamBold; btnAdd.BackgroundColor3 = Color3.fromRGB(26, 27, 33); btnAdd.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnAdd).CornerRadius = UDim.new(0, 4)
    
    btnSub.MouseButton1Click:Connect(function() if Flags[flag] - step >= min then Flags[flag] = Flags[flag] - step; lbl.Text = name .. "\n➔ " .. Flags[flag] end end)
    btnAdd.MouseButton1Click:Connect(function() if Flags[flag] + step <= max then Flags[flag] = Flags[flag] + step; lbl.Text = name .. "\n➔ " .. Flags[flag] end end)
end

-- --- [ KHỞI TẠO MENU V10 ] ---
AddToggle("AIMBOT LOCK", "Aimbot")
AddSlider("AIMBOT FOV", 40, 300, "AimFOV", 20)
AddToggle("FLY LOCK ENGINE", "Fly")
AddSlider("FLY SPEED", 40, 200, "FlySpeed", 10)
AddToggle("GHOST NOCLIP", "Noclip")
AddToggle("HYPER ESP VISION", "ESP")
AddToggle("WALK SPEED", "SpeedActive")
AddSlider("WALK SPEED VALUE", 16, 250, "WalkSpeed", 16)
AddToggle("INFINITE JUMP", "InfJump")
AddToggle("FAST AUTO CLICK", "AutoClick")
AddToggle("MAX FPS ANTI-LAG", "AntiLag", function(s) ToggleAntiLag(s) end)
AddToggle("ANTI-AFK DISCONNECT", "AntiAFK")

-- --- [ FLOATING OPEN/CLOSE BUTTON ] ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 48, 0, 48); OpenBtn.Position = UDim2.new(0.04, 0, 0.45, 0); OpenBtn.Text = "ThD"; OpenBtn.BackgroundColor3 = Color3.fromRGB(11, 12, 16); OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 255); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 11; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 50); OpenBtn.Draggable = true
local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 255)

-- Nút nổi cũng đổi màu đồng bộ với Menu chính
task.spawn(function()
    while task.wait(0.05) do
        BtnStroke.Color = Glow.Color
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.18); MainFrame.Visible = false
    else
        MainFrame.Visible = true; MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 260, 0, 420)}):Play()
    end
end)

print("⚡ ThD Hub v10.0 - ULTIMATE CYBERPUNK LOADED SUCCESSFULLY!")
