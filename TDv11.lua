--[[
    👑 PROJECT: ThD Hub v11 - THE ULTIMATE REMASTERED
    👤 AUTHOR: ThD (Optimized & Perfected by AI)
    📱 TARGET: Mobile/Tablet - Smooth v8 Core, Anti-AFK Bá Đạo, Hyper Anti-Lag
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- --- [ KHỞI TẠO BIẾN HỆ THỐNG TOÀN CỤC ] ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Khởi tạo bảng quản lý trạng thái nâng cao
local Flags = {
    Banner = true,
    AntiAFK = true,
    AntiLag = false,
    Fly = false, FlySpeed = 50,
    SpeedActive = false, WalkSpeed = 50,
    Noclip = false,
    ESP = false,
    Aimbot = false, AimFOV = 100, AimSmooth = 0.15
}

-- Bộ đếm FPS hiệu năng cao
local fpsCount = 0
local lastTick = tick()
local currentFps = 60
RunService.Heartbeat:Connect(function()
    fpsCount = fpsCount + 1
    if tick() - lastTick >= 1 then
        currentFps = fpsCount
        fpsCount = 0
        lastTick = tick()
    end
end)

-- --- [ GIAO DIỆN CHÍNH THỨC CỦA HUB ] ---
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "ThD_Hub_Ultimate_v10"

-- ─── 1. REAL-TIME STAT BANNER (GÓC TRÊN MÀN HÌNH) ───
local StatLabel = Instance.new("TextLabel", ScreenGui)
StatLabel.Size = UDim2.new(0, 450, 0, 30)
StatLabel.Position = UDim2.new(0, 15, 0, 10)
StatLabel.BackgroundTransparency = 1
StatLabel.TextSize = 13
StatLabel.Font = Enum.Font.RobotoMono
StatLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
StatLabel.TextXAlignment = Enum.TextXAlignment.Left
StatLabel.TextStrokeTransparency = 0.3
StatLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

task.spawn(function()
    while task.wait(0.5) do
        if Flags.Banner then
            StatLabel.Visible = true
            local dateString = os.date("%d/%m/%Y")
            local timeString = os.date("%X")
            StatLabel.Text = string.format("👤 Player: %s  |  ⚡ FPS: %d  |  📅 %s  |  ⏰ %s", LocalPlayer.Name, currentFps, dateString, timeString)
        else
            StatLabel.Visible = false
        end
    end
end)

-- ─── 2. CHỨC NĂNG ANTI-AFK CỰC KỲ BÁ ĐẠO ───
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        -- Cơ chế click ảo bypass triệt để hệ thống kiểm tra treo máy của Roblox
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
        task.wait(0.1)
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end
end)

-- ─── 3. ENGINE ANTI-LAG (SIÊU MƯỢT NHƯ MÁY XỊN) ───
local function CleanInstance(part)
    if Flags.AntiLag then
        if part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Smoke") or part:IsA("Sparkles") or part:IsA("Fire") then 
            part.Enabled = false
        elseif part:IsA("Decal") or part:IsA("Texture") then 
            part.Transparency = 1 
        end
    end
end
workspace.DescendantAdded:Connect(CleanInstance)

local function ToggleAntiLag(enable)
    -- Hạ cấu hình kết xuất Roblox xuống mức tối thiểu giải phóng CPU/GPU
    settings().Rendering.QualityLevel = enable and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level05
    for _, v in pairs(workspace:GetDescendants()) do
        if enable then 
            CleanInstance(v) 
        else
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then v.Enabled = true
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
    end
end

-- ─── 4. CƠ CHẾ DI CHUYỂN GỐC V8 (ĐÃ TÍCH HỢP CHỈNH TỐC ĐỘ) ───
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not char or not hrp or not hum then return end
    
    -- Speed v8 core có tùy chỉnh Slider
    if Flags.SpeedActive then
        hum.WalkSpeed = Flags.WalkSpeed
    else
        if hum.WalkSpeed == Flags.WalkSpeed then hum.WalkSpeed = 16 end
    end
    
    -- Noclip core
    if Flags.Noclip then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    -- Fly v8 core có tùy chỉnh Slider (Không chạm vào Gyro, cực mượt)
    if Flags.Fly then
        hum.PlatformStand = true
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir * (Flags.FlySpeed / 10))
        end
        hrp.Velocity = Vector3.new(0, 0, 0)
    else
        if hum.PlatformStand then hum.PlatformStand = false end
    end
end)

-- ─── 5. HOÀN THIỆN AIMBOT THÔNG MINH ───
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Color = Color3.fromRGB(0, 255, 255); FOVCircle.Filled = false; FOVCircle.Transparency = 0.5; FOVCircle.Visible = false

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

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Flags.Aimbot
    if Flags.Aimbot then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Flags.AimFOV
        
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- Sử dụng nội suy tuyến tính .Lerp giúp bám góc mượt mà
            local targetLook = CFrame.lookAt(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetLook, Flags.AimSmooth)
        end
    end
end)

-- ─── 6. HOÀN THIỆN HIGH-PERFORMANCE ESP SYTEM ───
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

    local Text = Drawing.new("Text")
    Text.Size = 13; Text.Center = true; Text.Outline = true; Text.OutlineColor = Color3.fromRGB(0, 0, 0); Text.Color = Color3.fromRGB(255, 255, 255); Text.Visible = false

    ESPOBJECTS[p] = {
        Drawings = {Box, Text},
        Conn = RunService.RenderStepped:Connect(function()
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if Flags.ESP and hrp and hum and hum.Health > 0 and localHrp then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local scale = 1 / (hrpPos.Z * 0.04) * 100
                    local w, h = 1 * scale, 1.4 * scale
                    local x, y = hrpPos.X - w / 2, hrpPos.Y - h / 2

                    Box.Position = Vector2.new(x, y); Box.Size = Vector2.new(w, h); Box.Visible = true

                    local dist = math.floor((localHrp.Position - hrp.Position).Magnitude)
                    Text.Text = string.format("%s [%dm]", p.Name, dist)
                    Text.Position = Vector2.new(hrpPos.X, y - 20); Text.Visible = true
                    return
                end
            end
            Box.Visible = false; Text.Visible = false
        end)
    }
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(ClearESP)

-- ─── 7. THIẾT KẾ MENU GIAO DIỆN CYBERPUNK CHUYÊN DỤNG ───
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 400)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.8
MainStroke.Color = Color3.fromRGB(0, 255, 255)

-- Hiệu ứng viền chuyển sắc nhẹ nhàng tinh tế
task.spawn(function()
    while task.wait(0.05) do
        local hue = (tick() % 6) / 6
        MainStroke.Color = Color3.fromHSV(hue, 0.9, 1)
    end
end)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 45); Header.Text = "ThD HUB ★ REMASTERED v10"; Header.TextColor3 = Color3.fromRGB(255, 255, 255); Header.Font = Enum.Font.GothamBold; Header.BackgroundTransparency = 1; Header.TextSize = 12

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -16, 1, -55); Scroll.Position = UDim2.new(0, 8, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0, 0, 0, 600); Scroll.ScrollBarThickness = 0
local ListLayout = Instance.new("UIListLayout", Scroll); ListLayout.Padding = UDim.new(0, 6)

-- Component Tạo Toggle Neon Hiện Đại
local function AddToggle(name, flag, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 36); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    
    local function Update()
        if Flags[flag] then
            btn.Text = "🔹 " .. name .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(12, 30, 36); stroke.Color = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        else
            btn.Text = "  " .. name .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(19, 20, 24); stroke.Color = Color3.fromRGB(35, 37, 45); btn.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
    end
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; Update(); if callback then callback(Flags[flag]) end end)
    Update()
end

-- Component Tạo Slider (+/-) Diện Tích Lớn Dễ Bấm Trên Di Động
local function AddSlider(name, min, max, flag, step)
    local pnl = Instance.new("Frame", Scroll); pnl.Size = UDim2.new(1, 0, 0, 44); pnl.BackgroundColor3 = Color3.fromRGB(17, 18, 22); Instance.new("UICorner", pnl).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", pnl); lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = name .. "\n➔ " .. Flags[flag]; lbl.TextColor3 = Color3.fromRGB(160, 160, 160); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
    
    local btnSub = Instance.new("TextButton", pnl); btnSub.Size = UDim2.new(0, 32, 0, 32); btnSub.Position = UDim2.new(0.60, 0, 0.14, 0); btnSub.Text = "-"; btnSub.Font = Enum.Font.GothamBold; btnSub.TextSize = 14; btnSub.BackgroundColor3 = Color3.fromRGB(26, 27, 33); btnSub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnSub).CornerRadius = UDim.new(0, 5)
    local btnAdd = Instance.new("TextButton", pnl); btnAdd.Size = UDim2.new(0, 32, 0, 32); btnAdd.Position = UDim2.new(0.82, 0, 0.14, 0); btnAdd.Text = "+"; btnAdd.Font = Enum.Font.GothamBold; btnAdd.TextSize = 14; btnAdd.BackgroundColor3 = Color3.fromRGB(26, 27, 33); btnAdd.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnAdd).CornerRadius = UDim.new(0, 5)
    
    btnSub.MouseButton1Click:Connect(function() if Flags[flag] - step >= min then Flags[flag] = Flags[flag] - step; lbl.Text = name .. "\n➔ " .. Flags[flag] end end)
    btnAdd.MouseButton1Click:Connect(function() if Flags[flag] + step <= max then Flags[flag] = Flags[flag] + step; lbl.Text = name .. "\n➔ " .. Flags[flag] end end)
end

-- ─── KHỞI TẠO CÁC NÚT ĐIỀU KHIỂN MENU ───
AddToggle("HIỂN THỊ BANNER GÓC", "Banner")
AddToggle("ANTI-AFK TREO MÁY (BÁ)", "AntiAFK")
AddToggle("SIÊU CHỐNG LAG ANTI-LAG", "AntiLag", function(s) ToggleAntiLag(s) end)
AddToggle("BẬT TỐC ĐỘ CHẠY", "SpeedActive")
AddSlider("TỐC ĐỘ CHẠY (WALK)", 16, 250, "WalkSpeed", 10)
AddToggle("BẬT BAY NHÂN VẬT", "Fly")
AddSlider("TỐC ĐỘ BAY (FLY)", 20, 200, "FlySpeed", 10)
AddToggle("ĐI XUYÊN TƯỜNG NOCLIP", "Noclip")
AddToggle("AIMBOT KHÓA MỤC TIÊU", "Aimbot")
AddSlider("AIMBOT FOV TẦM QUÉT", 40, 300, "AimFOV", 20)
AddToggle("ESP XUYÊN TƯỜNG PLAYER", "ESP")

-- ─── FLOATING BUTTON ĐÓNG/MỞ MENU ───
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 48, 0, 48); OpenBtn.Position = UDim2.new(0.04, 0, 0.45, 0); OpenBtn.Text = "ThD"; OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 13, 17); OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 255); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 11; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 50); OpenBtn.Draggable = true
local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Color = Color3.fromRGB(0, 255, 255)

task.spawn(function()
    while task.wait(0.05) do
        BtnStroke.Color = MainStroke.Color
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.18); MainFrame.Visible = false
    else
        MainFrame.Visible = true; MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 260, 0, 400)}):Play()
    end
end)

print("⚡ ThD Hub v11 Ultimate Remastered Successfully Loaded!")
