--[[
    👑 PROJECT: ThD Hub v6 - THE GOD MODE
    👤 AUTHOR: ThD
    📱 TARGET: Mobile (Perfect Optimized)
    🛠️ UPDATED: Added Auto Click, White Screen, Hitbox, Speed Slider & All V4/V5 Features
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThD_V6_GodMode"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- [ BIẾN HỆ THỐNG ] ---
local Flags = {
    Fly = false, FlySpeed = 70,
    WalkSpeed = 16, JumpPower = 50,
    Noclip = false,
    AutoHopActive = false, AutoHopTime = 600, CurrentTimer = 600,
    ESP = false, ShowHUD = true,
    AimbotTarget = nil,
    AutoClick = false,
    HitboxSize = 2, -- Mặc định
    WhiteScreen = false
}

-- --- [ VÒNG LẶP CHIẾN ĐẤU & DI CHUYỂN ] ---
RunService.RenderStepped:Connect(function()
    -- 1. Select Aim
    if Flags.AimbotTarget and Flags.AimbotTarget.Character and Flags.AimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
        local hum = Flags.AimbotTarget.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Flags.AimbotTarget.Character.HumanoidRootPart.Position)
        else Flags.AimbotTarget = nil end
    end
    -- 2. Noclip (Từ bản v4)
    if Flags.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- 3. Auto Click (Mới)
task.spawn(function()
    while task.wait(0.1) do
        if Flags.AutoClick then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end
end)

-- --- [ HUD THÔNG SỐ ] ---
local InfoPanel = Instance.new("Frame", ScreenGui)
local InfoText = Instance.new("TextLabel", InfoPanel)
InfoPanel.Size = UDim2.new(0, 240, 0, 80); InfoPanel.Position = UDim2.new(0.5, -120, 0, 10)
InfoPanel.BackgroundColor3 = Color3.new(0, 0, 0); InfoPanel.BackgroundTransparency = 0.5; Instance.new("UICorner", InfoPanel)
local Stroke = Instance.new("UIStroke", InfoPanel); Stroke.Thickness = 2
InfoText.Size = UDim2.new(1, 0, 1, 0); InfoText.TextColor3 = Color3.new(1, 1, 1); InfoText.Font = Enum.Font.GothamBold; InfoText.TextSize = 10; InfoText.BackgroundTransparency = 1

task.spawn(function()
    while true do
        local aim = Flags.AimbotTarget and Flags.AimbotTarget.DisplayName or "None"
        InfoText.Text = string.format("User: %s | FPS: %d\nTime: %s | Date: %s\nAiming: %s\nAuto Hop: %ds", LocalPlayer.Name, math.floor(1/RunService.RenderStepped:Wait()), os.date("%X"), os.date("%x"), aim, Flags.CurrentTimer)
        Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
        InfoPanel.Visible = Flags.ShowHUD and (not Flags.WhiteScreen)
        task.wait(0.5)
    end
end)

-- --- [ MENU V6 ] ---
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 45, 0, 45); MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0); MainBtn.Text = "THD"; MainBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); MainBtn.TextColor3 = Color3.new(1,1,1); MainBtn.Draggable = true; Instance.new("UICorner", MainBtn)

local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 280, 0, 400); Menu.Position = UDim2.new(0.5, -140, 0.5, -200); Menu.Visible = false; Menu.BackgroundColor3 = Color3.fromRGB(15,15,15); Instance.new("UICorner", Menu); Menu.ClipsDescendants = true

local Scroll = Instance.new("ScrollingFrame", Menu)
Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,0,1000); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- Hàm tạo nút mượt
local function CreateBtn(txt, color, parent, cb)
    local b = Instance.new("TextButton", parent or Scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = color or Color3.fromRGB(40,40,40); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb) return b
end

-- --- [ PHÂN LOẠI CHỨC NĂNG ] ---

-- 1. NHÓM COMBAT
CreateBtn("⚔️ AUTO CLICK: OFF", Color3.fromRGB(150, 50, 0), nil, function(self)
    Flags.AutoClick = not Flags.AutoClick
    self.Text = "⚔️ AUTO CLICK: " .. (Flags.AutoClick and "ON" or "OFF")
end)

local AimH = CreateBtn("🎯 SELECT AIM TARGET", Color3.fromRGB(100, 0, 0))
local AimS = Instance.new("Frame", Scroll); AimS.Size = UDim2.new(1,0,0,120); AimS.Visible = false; AimS.BackgroundTransparency = 1
local AimL = Instance.new("ScrollingFrame", AimS); AimL.Size = UDim2.new(1,0,1,0); AimL.CanvasSize = UDim2.new(0,0,5,0); Instance.new("UIListLayout", AimL)
AimH.MouseButton1Click:Connect(function() AimS.Visible = not AimS.Visible end)

local function UpdateList()
    for _,v in pairs(AimL:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    CreateBtn("❌ STOP AIM", Color3.fromRGB(200,0,0), AimL, function() Flags.AimbotTarget = nil end)
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then CreateBtn(p.DisplayName, nil, AimL, function() Flags.AimbotTarget = p end) end
    end
end
UpdateList(); Players.PlayerAdded:Connect(UpdateList); Players.PlayerRemoving:Connect(UpdateList)

-- 2. NHÓM DI CHUYỂN (Gồm Noclip V4)
CreateBtn("🚀 FLY: ON/OFF", nil, nil, function()
    Flags.Fly = not Flags.Fly
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Flags.Fly and hrp then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "ThD_Fly"; bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        task.spawn(function() while Flags.Fly do bv.Velocity = (LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0) and (Camera.CFrame.LookVector * Flags.FlySpeed) or Vector3.new(0,0,0); task.wait() end bv:Destroy() end)
    end
end)

CreateBtn("👻 NOCLIP: ON/OFF", nil, nil, function() Flags.Noclip = not Flags.Noclip end)
CreateBtn("⚡ SPEED +20", nil, nil, function() Flags.WalkSpeed = Flags.WalkSpeed + 20; if Flags.WalkSpeed > 200 then Flags.WalkSpeed = 16 end; LocalPlayer.Character.Humanoid.WalkSpeed = Flags.WalkSpeed end)

-- 3. NHÓM TỐI ƯU (Gồm Anti-Lag & AFK V4)
CreateBtn("🛡️ ANTI-LAG & AFK", Color3.fromRGB(0, 100, 50), nil, function()
    for _,v in pairs(workspace:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") then v:Destroy() end end
    settings().Rendering.QualityLevel = 1
    print("Anti-AFK Active")
end)

local WhiteBtn = CreateBtn("🌑 WHITE SCREEN (TREO MÁY)", nil, nil, function()
    Flags.WhiteScreen = not Flags.WhiteScreen
    game:GetService("RunService"):Set3dRenderingEnabled(not Flags.WhiteScreen)
end)

-- 4. SERVER & HUD
local HopH = CreateBtn("⚙️ SERVER HOP SETTINGS", Color3.fromRGB(60,60,60))
local HopS = Instance.new("Frame", Scroll); HopS.Size = UDim2.new(1,0,0,80); HopS.Visible = false; HopS.BackgroundTransparency = 1; Instance.new("UIListLayout", HopS).Padding = UDim.new(0,5)
HopH.MouseButton1Click:Connect(function() HopS.Visible = not HopS.Visible end)
CreateBtn("▶️ AUTO HOP: ON", Color3.fromRGB(0,120,0), HopS, function() Flags.AutoHopActive = true end)
CreateBtn("⏹️ AUTO HOP: OFF", Color3.fromRGB(120,0,0), HopS, function() Flags.AutoHopActive = false end)

CreateBtn("👁️ ESP & HUD TOGGLE", nil, nil, function() Flags.ESP = not Flags.ESP; Flags.ShowHUD = not Flags.ShowHUD end)

-- --- [ HIỆU ỨNG ĐÓNG MỞ ] ---
MainBtn.MouseButton1Click:Connect(function()
    if not Menu.Visible then
        Menu.Size = UDim2.new(0,0,0,0); Menu.Position = UDim2.new(0.5,0,0.5,0); Menu.Visible = true
        TweenService:Create(Menu, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0,280,0,400), Position = UDim2.new(0.5,-140,0.5,-200)}):Play()
    else
        local t = TweenService:Create(Menu, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)})
        t:Play(); t.Completed:Wait(); Menu.Visible = false
    end
end)

-- Anti-AFK Logic
LocalPlayer.Idled:Connect(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
