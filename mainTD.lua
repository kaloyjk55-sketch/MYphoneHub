--[[
    🚀 PROJECT: ThD Hub v2 - Premium Edition
    👤 AUTHOR: ThD
    📱 PLATFORM: Mobile (Android / iOS)
    🛠️ OPTIMIZATION: High-Performance Lua
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThD_Hub_Official"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- [ BIẾN TRẠNG THÁI ] ---
local Flags = {
    Fly = false, FlySpeed = 60,
    Noclip = false,
    InfJump = false,
    ESP = false,
    Speed = 16
}

-- --- [ 1. NÚT MỞ MENU (DRAGGABLE) ] ---
local MainBtn = Instance.new("TextButton")
MainBtn.Size = UDim2.new(0, 60, 0, 60)
MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.Text = "THD"
MainBtn.TextColor3 = Color3.new(1, 1, 1)
MainBtn.TextSize = 16
MainBtn.Font = Enum.Font.GothamBold
MainBtn.Parent = ScreenGui
MainBtn.Draggable = true
MainBtn.Active = true

local MainBtnCorner = Instance.new("UICorner", MainBtn)
MainBtnCorner.CornerRadius = UDim.new(0, 15)
local MainBtnStroke = Instance.new("UIStroke", MainBtn)
MainBtnStroke.Thickness = 2
MainBtnStroke.Color = Color3.new(1, 1, 1)

-- --- [ 2. BẢNG THÔNG SỐ CẦU VỒNG (TOP HUD) ] ---
local InfoPanel = Instance.new("Frame")
local InfoText = Instance.new("TextLabel")
local Stroke = Instance.new("UIStroke")

InfoPanel.Size = UDim2.new(0, 260, 0, 50)
InfoPanel.Position = UDim2.new(0.5, -130, 0, 10)
InfoPanel.BackgroundColor3 = Color3.new(1, 1, 1)
InfoPanel.BackgroundTransparency = 0.5
InfoPanel.Parent = ScreenGui
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 8)

Stroke.Thickness = 2.5
Stroke.Parent = InfoPanel
InfoText.Size = UDim2.new(1, 0, 1, 0)
InfoText.BackgroundTransparency = 1
InfoText.TextColor3 = Color3.new(0, 0, 0)
InfoText.Font = Enum.Font.GothamBold
InfoText.TextSize = 13
InfoText.Parent = InfoPanel

task.spawn(function()
    while true do
        local hue = tick() % 5 / 5
        Stroke.Color = Color3.fromHSV(hue, 0.8, 1)
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        InfoText.Text = string.format("User: %s | %s\nFPS: %d | Ping: %s", LocalPlayer.Name, os.date("%X"), fps, ping)
        task.wait(0.1)
    end
end)

-- --- [ 3. MENU CHÍNH (SQUARE MENU) ] ---
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 300, 0, 380)
Menu.Position = UDim2.new(0.5, -150, 0.5, -190)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Menu.Visible = false
Menu.Parent = ScreenGui
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 15)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.Position = UDim2.new(0, 10, 0, 50)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.ScrollBarThickness = 0
Scroll.Parent = Menu

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- --- [ HÀM TẠO NÚT TỔI ƯU ] ---
local function NewToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(45, 45, 45)
        callback(active)
    end)
end

-- --- [ LOGIC CHỨC NĂNG ] ---

-- Đóng/Mở Menu
MainBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- 1. Fly (Bay)
local bodyVel = Instance.new("BodyVelocity")
NewToggle("Fly (Bay)", function(state)
    Flags.Fly = state
    if state then
        bodyVel.Parent = LocalPlayer.Character.HumanoidRootPart
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while Flags.Fly do
                bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * Flags.FlySpeed
                task.wait()
            end
            bodyVel.Parent = nil
        end)
    else
        bodyVel.Parent = nil
    end
end)

-- 2. Speed (Tốc độ)
NewToggle("Tốc độ (100)", function(state)
    LocalPlayer.Character.Humanoid.WalkSpeed = state and 100 or 16
end)

-- 3. Noclip (Xuyên tường)
NewToggle("Noclip (Xuyên tường)", function(state)
    Flags.Noclip = state
end)
RunService.Stepped:Connect(function()
    if Flags.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- 4. ESP (Nhìn xuyên)
NewToggle("ESP (Health/Distance)", function(state)
    Flags.ESP = state
end)

task.spawn(function()
    while task.wait(0.5) do
        if Flags.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    local esp = hrp:FindFirstChild("ThD_ESP") or Instance.new("BillboardGui", hrp)
                    esp.Name = "ThD_ESP"; esp.AlwaysOnTop = true; esp.Size = UDim2.new(0, 120, 0, 45); esp.ExtentsOffset = Vector3.new(0, 3, 0)
                    
                    local lab = esp:FindFirstChild("Lab") or Instance.new("TextLabel", esp)
                    lab.Name = "Lab"; lab.Size = UDim2.new(1, 0, 1, 0); lab.BackgroundTransparency = 1; lab.TextSize = 12; lab.TextColor3 = Color3.new(1,0,0)
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    lab.Text = string.format("%s\nHP: %d | %dm", p.Name, p.Character.Humanoid.Health, dist)
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local e = p.Character.HumanoidRootPart:FindFirstChild("ThD_ESP")
                    if e then e:Destroy() end
                end
            end
        end
    end
end)

-- 5. Infinite Jump
NewToggle("Infinite Jump", function(state) Flags.InfJump = state end)
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

-- 6. Fullbright
NewToggle("Fullbright (Sáng map)", function(state)
    game.Lighting.Brightness = state and 2 or 1
    game.Lighting.GlobalShadows = not state
    game.Lighting.Ambient = state and Color3.new(1,1,1) or Color3.new(0.5,0.5,0.5)
end)

-- 7. Anti-AFK (Luôn bật)
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

print("ThD Hub v2 Loaded Successfully!")
