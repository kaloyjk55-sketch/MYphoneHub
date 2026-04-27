--[[
    👑 PROJECT: ThD Hub v3 - Ultimate Mobile Edition
    👤 AUTHOR: ThD
    📱 PLATFORM: Mobile (Android / iOS)
    ⚡ FEATURES: Auto Hop Logic, Aimbot, ESP, Fly Fix, Anti-Lag
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThD_Hub_V3"
ScreenGui.Parent = game:GetService("CoreGui")

-- --- [ BIẾN HỆ THỐNG CAO CẤP ] ---
local Flags = {
    Fly = false, FlySpeed = 60,
    WalkSpeed = 16, Noclip = false,
    Aimbot = false, ESP = false,
    AutoHopActive = false, AutoHopTime = 600, CurrentTimer = 600
}

-- --- [ HÀM HOP SERVER TỨC THÌ ] ---
local function HopNow()
    pcall(function()
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")).data
        for _, s in pairs(Servers) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end)
end

-- --- [ 1. NÚT THD ANIMATION ] ---
local MainBtn = Instance.new("TextButton")
MainBtn.Size = UDim2.new(0, 45, 0, 45); MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MainBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainBtn.Text = "THD"; MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.TextSize = 12; MainBtn.Font = Enum.Font.GothamBold; MainBtn.Parent = ScreenGui; MainBtn.Draggable = true
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainBtn).Color = Color3.fromRGB(255, 255, 255)

-- --- [ 2. HUD THÔNG SỐ (V3) ] ---
local InfoPanel = Instance.new("Frame")
local InfoText = Instance.new("TextLabel")
InfoPanel.Size = UDim2.new(0, 250, 0, 50); InfoPanel.Position = UDim2.new(0.5, -125, 0, 5)
InfoPanel.BackgroundColor3 = Color3.new(1, 1, 1); InfoPanel.BackgroundTransparency = 0.6; InfoPanel.Parent = ScreenGui
Instance.new("UICorner", InfoPanel)
local Stroke = Instance.new("UIStroke", InfoPanel); Stroke.Thickness = 2.5
InfoText.Size = UDim2.new(1, 0, 1, 0); InfoText.BackgroundTransparency = 1
InfoText.TextColor3 = Color3.new(0, 0, 0); InfoText.Font = Enum.Font.GothamBold; InfoText.TextSize = 11; InfoText.Parent = InfoPanel

task.spawn(function()
    while task.wait(1) do
        if Flags.AutoHopActive then
            Flags.CurrentTimer = Flags.CurrentTimer - 1
            if Flags.CurrentTimer <= 0 then HopNow() end
        end
        local hopStat = Flags.AutoHopActive and "ON" or "OFF"
        InfoText.Text = string.format("User: %s | FPS: %d\nHop: %s (%ds) | %s", 
            LocalPlayer.Name, math.floor(1/RunService.RenderStepped:Wait()), hopStat, Flags.CurrentTimer, os.date("%X"))
        Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    end
end)

-- --- [ 3. GIAO DIỆN MENU CHÍNH ] ---
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 280, 0, 400); Menu.Position = UDim2.new(0.5, -140, 0.5, -200)
Menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Menu.Visible = false; Menu.Parent = ScreenGui
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 15)

-- Hiệu ứng bật/tắt Menu
MainBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
    if Menu.Visible then
        Menu.Size = UDim2.new(0, 260, 0, 380)
        TweenService:Create(Menu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 400)}):Play()
    end
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0; Scroll.CanvasSize = UDim2.new(0, 0, 0, 950); Scroll.Parent = Menu
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 6); Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- --- [ HÀM TẠO NÚT V3 ] ---
local function CreateHeader(txt)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, 0, 0, 25); h.BackgroundTransparency = 1
    h.Text = " ✦ " .. txt .. " ✦ "; h.TextColor3 = Color3.fromRGB(0, 200, 255)
    h.Font = Enum.Font.GothamBlack; h.TextSize = 13; h.Parent = Scroll
end

local function CreateBtn(txt, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = color or Color3.fromRGB(35, 35, 35)
    b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
    b.Parent = Scroll; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function CreateToggle(txt, flagName, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.Text = txt .. ": OFF"; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
    b.Parent = Scroll; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        Flags[flagName] = not Flags[flagName]
        b.Text = txt .. (Flags[flagName] and ": ON" or ": OFF")
        b.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(35, 35, 35)
        if cb then cb(Flags[flagName]) end
    end)
end

-- --- [ MENU BUILDER ] ---

CreateHeader("SERVER & UTILITY")

-- Logic Hop SV Đặc Biệt
local HopMain = CreateBtn("⚙️ CHỨC NĂNG HOP SV", Color3.fromRGB(50, 50, 50), function() end)
local HopSub = Instance.new("Frame", Scroll)
HopSub.Size = UDim2.new(1, 0, 0, 85); HopSub.BackgroundTransparency = 1; HopSub.Visible = false
local SubLay = Instance.new("UIListLayout", HopSub); SubLay.Padding = UDim.new(0, 5); SubLay.HorizontalAlignment = Enum.HorizontalAlignment.Center

HopMain.MouseButton1Click:Connect(function() HopSub.Visible = not HopSub.Visible end)

local function SubBtn(txt, c, cb)
    local b = Instance.new("TextButton", HopSub)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.BackgroundColor3 = c; b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 11; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end
SubBtn("▶️ AUTO HOP: ON", Color3.fromRGB(0, 120, 0), function() Flags.AutoHopActive = true; Flags.CurrentTimer = Flags.AutoHopTime end)
SubBtn("⏹️ AUTO HOP: OFF", Color3.fromRGB(150, 0, 0), function() Flags.AutoHopActive = false end)

CreateBtn("🔥 HOP NOW (TỨC THÌ)", Color3.fromRGB(170, 0, 0), function() HopNow() end)
CreateBtn("🛡️ Fix Lag (Clear Visuals)", nil, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
end)


CreateHeader("LOCAL PLAYER")

CreateToggle("🚀 Fly (Fix Tự Động Dừng)", "Fly", function(state)
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if state and hrp then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while Flags.Fly do
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    bv.Velocity = Camera.CFrame.LookVector * Flags.FlySpeed
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

local spdBtn = CreateBtn("⚡ Tốc Độ Chạy: 16", nil, function()
    Flags.WalkSpeed = Flags.WalkSpeed + 20
    if Flags.WalkSpeed > 150 then Flags.WalkSpeed = 16 end
    LocalPlayer.Character.Humanoid.WalkSpeed = Flags.WalkSpeed
    -- Cập nhật text thẳng vào nút (thay vì spdBtn.Text vì scope, ta dùng mẹo)
end)
spdBtn.MouseButton1Click:Connect(function() spdBtn.Text = "⚡ Tốc Độ Chạy: " .. Flags.WalkSpeed end)

CreateToggle("👻 Noclip (Xuyên Tường)", "Noclip")
RunService.Stepped:Connect(function()
    if Flags.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)


CreateHeader("COMBAT & VISUALS")

-- AIMBOT MOBILE
CreateToggle("🎯 Aimbot (Khóa Mục Tiêu)", "Aimbot")
RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        local closestTarget = nil
        local shortestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if magnitude < shortestDist then
                    closestTarget = p.Character.HumanoidRootPart
                    shortestDist = magnitude
                end
            end
        end
        if closestTarget then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        end
    end
end)

-- ESP CAO CẤP
CreateToggle("👁️ ESP (Nhìn Xuyên V3)", "ESP", function(state)
    if not state then
        for _, v in pairs(game.CoreGui:GetChildren()) do
            if v.Name == "ThD_ESP_V3" then v:Destroy() end
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if Flags.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    local hrp = p.Character.HumanoidRootPart
                    local esp = game.CoreGui:FindFirstChild(p.Name.."_ESP") or Instance.new("BillboardGui")
                    esp.Name = p.Name.."_ESP"; esp.AlwaysOnTop = true; esp.Size = UDim2.new(0, 100, 0, 40)
                    esp.ExtentsOffset = Vector3.new(0, 3, 0); esp.Parent = game.CoreGui; esp.Adornee = hrp
                    
                    local txt = esp:FindFirstChild("T") or Instance.new("TextLabel", esp)
                    txt.Name = "T"; txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
                    txt.Font = Enum.Font.GothamBold; txt.TextSize = 10; txt.TextColor3 = Color3.new(1,0,0)
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    txt.Text = p.Name .. "\n[" .. dist .. "m]"
                end
            end
        end
    end
end)

-- Anti-AFK Bắt buộc
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("ThD Hub v3 - Đã nâng cấp thành công!")
