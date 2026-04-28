--[[
    👑 PROJECT: ThD Hub v8 - THE APEX (ULTIMATE)
    👤 AUTHOR: ThD (Upgraded by AI #1)
    📱 TARGET: Mobile/Tablet
    🔥 STATUS: GOD MODE ACTIVATED
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- [ CÀI ĐẶT HỆ THỐNG ] ---
local Flags = {
    Fly = false, FlySpeed = 80,
    Noclip = false,
    ESP = false,
    Aimbot = false, AimTarget = nil, AimSmooth = 0.2, AimFOV = 150,
    Speed = 16, InfJump = false,
    AutoClick = false
}

-- --- [ VÒNG FOV CHO AIMBOT ] ---
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 127)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- --- [ HÀM HỖ TRỢ CHIẾN ĐẤU ] ---
local function GetClosestPlayer()
    local target = nil
    local dist = Flags.AimFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    target = p
                    dist = mag
                end
            end
        end
    end
    return target
end

-- --- [ CORE LOGIC (VẬN HÀNH TỐI CAO) ] ---
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Fly Lock "Mỏ Neo" (Fixed v7)
    if Flags.Fly and hrp then
        local vel = hrp:FindFirstChild("ThD_Vel") or Instance.new("BodyVelocity", hrp)
        local gyro = hrp:FindFirstChild("ThD_Gyro") or Instance.new("BodyGyro", hrp)
        vel.Name = "ThD_Vel"; vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        gyro.Name = "ThD_Gyro"; gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        
        gyro.CFrame = Camera.CFrame
        if char.Humanoid.MoveDirection.Magnitude > 0 then
            vel.Velocity = Camera.CFrame.LookVector * Flags.FlySpeed
        else
            vel.Velocity = Vector3.new(0, 0, 0) -- Khóa cứng tại chỗ
        end
    else
        if hrp then
            if hrp:FindFirstChild("ThD_Vel") then hrp.ThD_Vel:Destroy() end
            if hrp:FindFirstChild("ThD_Gyro") then hrp.ThD_Gyro:Destroy() end
        end
    end

    -- 2. Noclip Triệt Để
    if Flags.Noclip and char then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- 3. Aimbot Smooth
    FOVCircle.Visible = Flags.Aimbot
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = Flags.AimFOV
    
    if Flags.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Flags.AimSmooth)
        end
    end
end)

-- --- [ GIAO DIỆN NEON (LEVEL MAX) ] ---
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
local Corner = Instance.new("UICorner", MainFrame)
local Glow = Instance.new("UIStroke", MainFrame); Glow.Thickness = 2; Glow.Color = Color3.fromRGB(0, 255, 150)

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40); Header.Text = "ThD HUB - APEX V8"; Header.TextColor3 = Color3.new(1,1,1); Header.Font = Enum.Font.GothamBold; Header.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -50); Scroll.Position = UDim2.new(0, 10, 0, 45); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,0,500); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 7)

-- --- [ HÀM TẠO NÚT BẤM CHUYÊN NGHIỆP ] ---
local function AddToggle(name, flag, callback)
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, 0, 0, 40); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.TextColor3 = Color3.new(1,1,1)
    local btnCorner = Instance.new("UICorner", btn)
    
    local function Update()
        btn.Text = name .. (Flags[flag] and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = Flags[flag] and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(40, 40, 40)
        local glow = btn:FindFirstChild("UIStroke") or Instance.new("UIStroke", btn)
        glow.Color = Flags[flag] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
    end
    
    btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        Update()
        if callback then callback(Flags[flag]) end
    end)
    Update()
end

-- --- [ DANH SÁCH CHỨC NĂNG ] ---
AddToggle("🎯 SMART AIMBOT", "Aimbot")
AddToggle("🚀 FLY LOCK", "Fly")
AddToggle("👻 GHOST NOCLIP", "Noclip")
AddToggle("👁️ ESP VISION", "ESP")
AddToggle("⚡ SUPER SPEED", "SpeedActive", function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16 end)
AddToggle("🦘 INF JUMP", "InfJump")
AddToggle("🖱️ AUTO CLICK", "AutoClick")

-- --- [ HỆ THỐNG ESP BOX & TRACER ] ---
local function MakeESP(p)
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1; tracer.Color = Color3.fromRGB(0, 255, 150)
    
    RunService.RenderStepped:Connect(function()
        if Flags.ESP and p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = true
            else tracer.Visible = false end
        else tracer.Visible = false end
    end)
end
for _, p in pairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)

-- --- [ TIỆN ÍCH PHỤ ] ---
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoClick then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

-- --- [ NÚT MỞ MENU ] ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
OpenBtn.Text = "ThD"; OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150); OpenBtn.TextColor3 = Color3.new(0,0,0)
OpenBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", OpenBtn); OpenBtn.Draggable = true

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 260, 0, 350)}):Play()
    end
end)

-- --- [ THÔNG BÁO KHI KÍCH HOẠT ] ---
print("ThD Hub v8 Activated - God Mode")
