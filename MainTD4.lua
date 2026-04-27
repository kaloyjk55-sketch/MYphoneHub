--[[
    👑 PROJECT: ThD Hub v4 - FINAL EDITION
    👤 AUTHOR: ThD
    📱 TARGET: Mobile (Android/iOS)
    🛠️ FIX: HUD Timer, Hop Now Logic, Sub-Menu ON/OFF
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThD_V4_Final"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- [ CẤU HÌNH HỆ THỐNG ] ---
local Flags = {
    Fly = false, FlySpeed = 70,
    WalkSpeed = 16, Noclip = false,
    AutoHopActive = false,
    AutoHopTime = 600, -- Mặc định 600s
    CurrentTimer = 600
}

-- --- [ HÀM HOP SERVER CAO CẤP ] ---
local function HopNow()
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    
    pcall(function()
        local Site = game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        local Data = HttpService:JSONDecode(Site)
        
        if Data and Data.data then
            local PossibleServers = {}
            for _, s in pairs(Data.data) do
                if s.id ~= JobId and s.playing < s.maxPlayers - 1 then
                    table.insert(PossibleServers, s.id)
                end
            end
            
            if #PossibleServers > 0 then
                TeleportService:TeleportToPlaceInstance(PlaceId, PossibleServers[math.random(1, #PossibleServers)], LocalPlayer)
            end
        end
    end)
end

-- --- [ NÚT THD (CHỮ NHỎ, GỌN) ] ---
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 45, 0, 45); MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainBtn.Text = "THD"; MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.TextSize = 10; MainBtn.Font = Enum.Font.GothamBold; MainBtn.Draggable = true
Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 12)

-- --- [ HUD BẢNG ĐẾM NGƯỢC (ĐÃ FIX) ] ---
local InfoPanel = Instance.new("Frame", ScreenGui)
local InfoText = Instance.new("TextLabel", InfoPanel)
InfoPanel.Size = UDim2.new(0, 240, 0, 55); InfoPanel.Position = UDim2.new(0.5, -120, 0, 10)
InfoPanel.BackgroundColor3 = Color3.new(1, 1, 1); InfoPanel.BackgroundTransparency = 0.6
Instance.new("UICorner", InfoPanel)
local Stroke = Instance.new("UIStroke", InfoPanel); Stroke.Thickness = 2.5

InfoText.Size = UDim2.new(1, 0, 1, 0); InfoText.BackgroundTransparency = 1
InfoText.TextColor3 = Color3.new(0, 0, 0); InfoText.Font = Enum.Font.GothamBold; InfoText.TextSize = 10

-- Vòng lặp cập nhật HUD liên tục (Fix lỗi không hiện đếm ngược)
task.spawn(function()
    while true do
        local status = Flags.AutoHopActive and "ON" or "OFF"
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        
        -- Dòng chữ hiển thị theo yêu cầu của bạn: vd 367s / 600s
        InfoText.Text = string.format(
            "User: %s | FPS: %d\nAuto Hop: %s [%ds / %ds]\nTime: %s",
            LocalPlayer.Name, fps, status, Flags.CurrentTimer, Flags.AutoHopTime, os.date("%X")
        )
        
        Stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
        task.wait(0.5)
    end
end)

-- Vòng lặp đếm ngược độc lập
task.spawn(function()
    while task.wait(1) do
        if Flags.AutoHopActive then
            Flags.CurrentTimer = Flags.CurrentTimer - 1
            if Flags.CurrentTimer <= 0 then
                HopNow()
                Flags.CurrentTimer = Flags.AutoHopTime
            end
        end
    end
end)

-- --- [ MENU CHÍNH V4 ] ---
local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 280, 0, 400); Menu.Position = UDim2.new(0.5, -140, 0.5, -200)
Menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Menu.Visible = false
Instance.new("UICorner", Menu)

local Scroll = Instance.new("ScrollingFrame", Menu)
Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 0; Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

local function AddActionBtn(name, color, cb)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 45); b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
    b.Text = name; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.Gotham; b.TextSize = 12
    Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
    return b
end

-- --- [ XỬ LÝ NHÓM HOP SV (SUB-MENU ON/OFF) ] ---
local HopMainBtn = AddActionBtn("⚙️ CHỨC NĂNG HOP SV", Color3.fromRGB(65, 65, 65), function() end)
local HopSubMenu = Instance.new("Frame", Scroll)
HopSubMenu.Size = UDim2.new(1, 0, 0, 95); HopSubMenu.BackgroundTransparency = 1; HopSubMenu.Visible = false
Instance.new("UIListLayout", HopSubMenu).Padding = UDim.new(0, 5)

HopMainBtn.MouseButton1Click:Connect(function()
    HopSubMenu.Visible = not HopSubMenu.Visible
end)

local function AddSubBtn(txt, c, cb)
    local b = Instance.new("TextButton", HopSubMenu)
    b.Size = UDim2.new(0.95, 0, 0, 40); b.BackgroundColor3 = c; b.Text = txt; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 11; Instance.new("UICorner", b); b.MouseButton1Click:Connect(cb)
end

AddSubBtn("▶️ BẬT ĐẾM NGƯỢC (ON)", Color3.fromRGB(0, 150, 0), function() 
    Flags.AutoHopActive = true 
    Flags.CurrentTimer = Flags.AutoHopTime -- Reset lại mốc thời gian khi bắt đầu
end)

AddSubBtn("⏹️ TẮT ĐẾM NGƯỢC (OFF)", Color3.fromRGB(150, 0, 0), function() 
    Flags.AutoHopActive = false 
end)

-- --- [ CÁC CHỨC NĂNG TIỆN ÍCH KHÁC ] ---

AddActionBtn("🔥 HOP NOW (NHẢY TỨC THÌ)", Color3.fromRGB(180, 0, 0), function() HopNow() end)

AddActionBtn("🚀 Fly (Fix Dừng Im)", nil, function()
    Flags.Fly = not Flags.Fly
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Flags.Fly and hrp then
        local bv = hrp:FindFirstChild("ThD_FlyVel") or Instance.new("BodyVelocity", hrp)
        bv.Name = "ThD_FlyVel"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while Flags.Fly do
                if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                    bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * Flags.FlySpeed
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

AddActionBtn("⚡ Speed Chạy (+25)", nil, function()
    Flags.WalkSpeed = Flags.WalkSpeed + 25
    if Flags.WalkSpeed > 175 then Flags.WalkSpeed = 16 end
    LocalPlayer.Character.Humanoid.WalkSpeed = Flags.WalkSpeed
end)

AddActionBtn("🛡️ Fix Lag & Anti-AFK", nil, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v:Destroy() end
    end
    settings().Rendering.QualityLevel = 1
end)

AddActionBtn("👻 Noclip (Xuyên Tường)", nil, function()
    Flags.Noclip = not Flags.Noclip
end)
RunService.Stepped:Connect(function()
    if Flags.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Đóng mở Menu
MainBtn.MouseButton1Click:Connect(function() Menu.Visible = not Menu.Visible end)

-- Anti-AFK ngầm (Luôn chạy)
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
