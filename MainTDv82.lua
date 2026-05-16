--[[
    👑 PROJECT: ThD Hub v8.2 - THE ULTIMATE KING (FULL OPTIONS)
    👤 AUTHOR: ThD (Upgraded by AI #1)
    📱 TARGET: Mobile/Tablet - Anti-Crash & Custom Config
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- [ BIẾN HỆ THỐNG CÓ TÙY CHỈNH ] ---
local Flags = {
    Fly = false, FlySpeed = 80,
    Noclip = false,
    ESP = false,
    Aimbot = false, AimTarget = nil, AimSmooth = 0.2, AimFOV = 150,
    SpeedActive = false, WalkSpeed = 80, InfJump = false,
    AutoClick = false,
    AntiLag = false, AntiAFK = true
}

-- --- [ VÒNG FOV CHO AIMBOT ] ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.Color = Color3.fromRGB(0, 255, 150); FOVCircle.Filled = false; FOVCircle.Transparency = 0.7; FOVCircle.Visible = false

-- --- [ HÀM TÌM MỤC TIÊU NGẮM ] ---
local function GetClosestPlayer()
    local target = nil
    local dist = Flags.AimFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then target = p; dist = mag end
            end
        end
    end
    return target
end

-- --- [ BYPASS ANTI-CHEAT (CHỐNG KICK KHI SPEED/FLY) ] ---
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and self:IsA("BasePart") and (key == "Velocity" or key == "CFrame") then
            if Flags.Fly or Flags.SpeedActive then
                return Vector3.new(0,0,0) -- Trả về vận tốc ảo cho hệ thống kiểm tra để tránh bị ban/kick
            end
        end
        return oldIndex(self, key)
    end)
end

-- --- [ CORE LOGIC VẬN HÀNH ] ---
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Fly Mỏ Neo Chống Rung
    if Flags.Fly and hrp then
        local vel = hrp:FindFirstChild("ThD_Vel") or Instance.new("BodyVelocity", hrp)
        local gyro = hrp:FindFirstChild("ThD_Gyro") or Instance.new("BodyGyro", hrp)
        vel.Name = "ThD_Vel"; vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        gyro.Name = "ThD_Gyro"; gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        gyro.CFrame = Camera.CFrame
        vel.Velocity = char.Humanoid.MoveDirection.Magnitude > 0 and Camera.CFrame.LookVector * Flags.FlySpeed or Vector3.new(0, 0, 0)
    else
        if hrp then
            if hrp:FindFirstChild("ThD_Vel") then hrp.ThD_Vel:Destroy() end
            if hrp:FindFirstChild("ThD_Gyro") then hrp.ThD_Gyro:Destroy() end
        end
    end

    -- 2. Noclip Mượt
    if Flags.Noclip and char then
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    -- 3. Aimbot Logic
    FOVCircle.Visible = Flags.Aimbot; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle.Radius = Flags.AimFOV
    if Flags.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position), Flags.AimSmooth)
        end
    end
    
    -- 4. Ép tốc độ chạy tùy chỉnh
    if Flags.SpeedActive and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Flags.WalkSpeed
    end
end)

-- --- [ LOGIC ANTI-LAG ] ---
local function ApplyAntiLag(part)
    if Flags.AntiLag then
        if part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Smoke") or part:IsA("Sparkles") then part.Enabled = false
        elseif part:IsA("Decal") or part:IsA("Texture") then part.Transparency = 1 end
    end
end
workspace.DescendantAdded:Connect(function(d) if Flags.AntiLag then task.wait(); ApplyAntiLag(d) end end)
local function ToggleAntiLagLogic(enable)
    settings().Rendering.QualityLevel = enable and 1 or 5
    for _, v in pairs(workspace:GetDescendants()) do
        if enable then ApplyAntiLag(v) else
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then v.Enabled = true
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
        end
    end
end

-- --- [ GIAO DIỆN NEON V8.2 ] ---
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 420); MainFrame.Position = UDim2.new(0.5, -130, 0.5, -210); MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame); local Glow = Instance.new("UIStroke", MainFrame); Glow.Thickness = 2; Glow.Color = Color3.fromRGB(0, 255, 150)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40); Header.Text = "ThD HUB - ULTIMATE V8.2"; Header.TextColor3 = Color3.new(1,1,1); Header.Font = Enum.Font.GothamBold; Header.BackgroundTransparency = 1; Header.TextSize = 13

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -60); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,0,650); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 6)

-- --- [ HÀM TẠO TOGGLE PHẢN HỒI MÀU ] ---
local function AddToggle(name, flag, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 38); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1
    
    local function Update()
        btn.Text = name .. (Flags[flag] and " : ON" or " : OFF")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 170, 85) or Color3.fromRGB(45, 45, 45)
        stroke.Color = Flags[flag] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(65, 65, 65)
    end
    btn.MouseButton1Click:Connect(function() Flags[flag] = not Flags[flag]; Update(); if callback then callback(Flags[flag]) end end)
    Update()
end

-- --- [ HÀM TẠO THANH CHỈNH SỐ (+ / -) ] ---
local function AddSlider(name, min, max, flag, step)
    local pnl = Instance.new("Frame", Scroll); pnl.Size = UDim2.new(1, 0, 0, 45); pnl.BackgroundColor3 = Color3.fromRGB(30,30,30); Instance.new("UICorner", pnl)
    local lbl = Instance.new("TextLabel", pnl); lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0,10,0,0); lbl.Text = name .. ": " .. Flags[flag]; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
    
    local btnSub = Instance.new("TextButton", pnl); btnSub.Size = UDim2.new(0, 30, 0, 30); btnSub.Position = UDim2.new(0.65, 0, 0.15, 0); btnSub.Text = "-"; btnSub.BackgroundColor3 = Color3.fromRGB(50,50,50); btnSub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnSub)
    local btnAdd = Instance.new("TextButton", pnl); btnAdd.Size = UDim2.new(0, 30, 0, 30); btnAdd.Position = UDim2.new(0.82, 0, 0.15, 0); btnAdd.Text = "+"; btnAdd.BackgroundColor3 = Color3.fromRGB(50,50,50); btnAdd.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnAdd)
    
    btnSub.MouseButton1Click:Connect(function() if Flags[flag] - step >= min then Flags[flag] = Flags[flag] - step; lbl.Text = name .. ": " .. Flags[flag] end end)
    btnAdd.MouseButton1Click:Connect(function() if Flags[flag] + step <= max then Flags[flag] = Flags[flag] + step; lbl.Text = name .. ": " .. Flags[flag] end end)
end

-- --- [ SETUP MENU CHỨC NĂNG ] ---
AddToggle("🎯 SMART AIMBOT", "Aimbot")
AddSlider("⭕ TẦM NGẮM FOV", 50, 400, "AimFOV", 25)
AddToggle("🚀 FLY LOCK (MỎ NEO)", "Fly")
AddSlider("✈️ TỐC ĐỘ BAY", 50, 200, "FlySpeed", 10)
AddToggle("👻 GHOST NOCLIP", "Noclip")
AddToggle("👁️ ESP VISION (TRACER)", "ESP")
AddToggle("⚡ SUPER SPEED", "SpeedActive")
AddSlider("🏃 TỐC ĐỘ CHẠY", 16, 250, "WalkSpeed", 15)
AddToggle("🦘 INF JUMP (BAY CAO)", "InfJump")
AddToggle("⚔️ AUTO CLICK", "AutoClick")
AddToggle("🛡️ ANTI-LAG (XÓA CHI TIẾT)", "AntiLag", function(v) ToggleAntiLagLogic(v) end)
AddToggle("💤 ANTI-AFK (CHỐNG KICK)", "AntiAFK")

-- --- [ ESP TRACER ] ---
local function MakeESP(p)
    local tracer = Drawing.new("Line"); tracer.Thickness = 1.5; tracer.Color = Color3.fromRGB(0, 255, 150)
    RunService.RenderStepped:Connect(function()
        if Flags.ESP and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); tracer.To = Vector2.new(pos.X, pos.Y); tracer.Visible = true
                else tracer.Visible = false end
            else tracer.Visible = false end
        else tracer.Visible = false end
    end)
end
for _, p in pairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)

-- --- [ EVENT PHỤ & ANTI-AFK ] ---
UserInputService.JumpRequest:Connect(function() if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
task.spawn(function() while task.wait(0.1) do if Flags.AutoClick then local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool"); if t then t:Activate() end end end end)
LocalPlayer.Idled:Connect(function() if Flags.AntiAFK then game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end end)

-- --- [ NÚT FLOATING MỞ MENU ] ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0.05, 0, 0.4, 0); OpenBtn.Text = "ThD"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.TextColor3 = Color3.new(0,0,0); OpenBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", OpenBtn); OpenBtn.Draggable = true
Instance.new("UIStroke", OpenBtn).Color = Color3.new(1,1,1)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 260, 0, 420)}):Play()
    end
end)

print("ThD Hub v8.2 - KING EDITION LOADED!")
