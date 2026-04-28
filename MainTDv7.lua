--[[
    👑 PROJECT: ThD Hub v7 - BUG FIX EDITION
    👤 AUTHOR: ThD
    📱 TARGET: Mobile (Fixed Fly, Noclip, ESP, UI Colors)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThD_V7_Fixed"
ScreenGui.Parent = game:GetService("CoreGui")

-- --- [ BIẾN HỆ THỐNG ] ---
local Flags = {
    Fly = false, FlySpeed = 70,
    Noclip = false,
    ESP = false,
    ShowHUD = true,
    AimbotTarget = nil,
    Speed = 16
}

-- --- [ LOGIC XUYÊN TƯỜNG (NOCLIP) ] ---
local CollisionCache = {}
RunService.Stepped:Connect(function()
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Flags.Noclip then
                    part.CanCollide = false
                else
                    -- Khi tắt Noclip, trả lại trạng thái va chạm bình thường
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- --- [ LOGIC BAY (FIX ĐỨNG YÊN) ] ---
local BodyVel, BodyGyro
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if Flags.Fly and hrp then
        if not hrp:FindFirstChild("ThD_Vel") then
            BodyVel = Instance.new("BodyVelocity", hrp); BodyVel.Name = "ThD_Vel"
            BodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyGyro = Instance.new("BodyGyro", hrp); BodyGyro.Name = "ThD_Gyro"
            BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        BodyGyro.CFrame = Camera.CFrame
        local moveDir = char.Humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            BodyVel.Velocity = Camera.CFrame.LookVector * Flags.FlySpeed
        else
            -- KHÓA VỊ TRÍ: Khi không bấm nút di chuyển, vận tốc bằng 0 để đứng yên
            BodyVel.Velocity = Vector3.new(0, 0, 0)
        end
    else
        if hrp then
            if hrp:FindFirstChild("ThD_Vel") then hrp.ThD_Vel:Destroy() end
            if hrp:FindFirstChild("ThD_Gyro") then hrp.ThD_Gyro:Destroy() end
        end
    end
end)

-- --- [ HỆ THỐNG ĐỊNH VỊ (ESP) ] ---
local function CreateESP(p)
    local function Apply()
        if p == LocalPlayer then return end
        local bgui = Instance.new("BillboardGui", game:GetService("CoreGui"))
        bgui.Name = "ESP_" .. p.Name; bgui.AlwaysOnTop = true; bgui.Size = UDim2.new(0, 200, 0, 50); bgui.ExtentsOffset = Vector3.new(0, 3, 0)
        local text = Instance.new("TextLabel", bgui); text.Size = UDim2.new(1, 0, 1, 0); text.BackgroundTransparency = 1; text.TextColor3 = Color3.new(1,1,1); text.Font = Enum.Font.GothamBold; text.TextSize = 12
        Instance.new("UIStroke", text).Thickness = 1.5

        RunService.RenderStepped:Connect(function()
            if Flags.ESP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                bgui.Adornee = p.Character.HumanoidRootPart; bgui.Enabled = true
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)
                text.Text = p.DisplayName .. "\n[" .. dist .. "m]"
            else bgui.Enabled = false end
        end)
    end
    Apply(); p.CharacterAdded:Connect(Apply)
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- --- [ GIAO DIỆN MENU ] ---
local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 280, 0, 380); Menu.Position = UDim2.new(0.5, -140, 0.5, -190); Menu.BackgroundColor3 = Color3.fromRGB(20,20,20); Menu.Visible = false; Instance.new("UICorner", Menu)

local Scroll = Instance.new("ScrollingFrame", Menu)
Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,0,600); Scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 8)

-- Hàm tạo nút đổi màu theo trạng thái
local function CreateToggle(txt, flagKey, cb)
    local b = Instance.new("TextButton", Scroll)
    b.Size = UDim2.new(1, 0, 0, 45); b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    
    local function UpdateUI()
        b.Text = txt .. (Flags[flagKey] and ": ON" or ": OFF")
        b.BackgroundColor3 = Flags[flagKey] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    end
    
    b.MouseButton1Click:Connect(function()
        Flags[flagKey] = not Flags[flagKey]
        UpdateUI()
        if cb then cb(Flags[flagKey]) end
    end)
    UpdateUI()
end

-- --- [ CÀI ĐẶT NÚT BẤM ] ---
CreateToggle("👻 XUYÊN TƯỜNG (NOCLIP)", "Noclip")
CreateToggle("🚀 BAY (FLY)", "Fly")
CreateToggle("👁️ ĐỊNH VỊ (ESP)", "ESP")

CreateToggle("⚡ TỐC ĐỘ (SPEED)", "IsSpeed", function(on)
    LocalPlayer.Character.Humanoid.WalkSpeed = on and 100 or 16
end)

-- Nhóm Chọn Target Aim (Giữ lại từ v5)
local AimH = Instance.new("TextButton", Scroll); AimH.Size = UDim2.new(1,0,0,45); AimH.BackgroundColor3 = Color3.fromRGB(45,45,45); AimH.Text = "🎯 CHỌN MỤC TIÊU AIM"; AimH.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", AimH)
local AimS = Instance.new("Frame", Scroll); AimS.Size = UDim2.new(1,0,0,120); AimS.Visible = false; AimS.BackgroundTransparency = 1
local AimL = Instance.new("ScrollingFrame", AimS); AimL.Size = UDim2.new(1,0,1,0); AimL.CanvasSize = UDim2.new(0,0,5,0); Instance.new("UIListLayout", AimL)
AimH.MouseButton1Click:Connect(function() AimS.Visible = not AimS.Visible end)

local function UpdateList()
    for _,v in pairs(AimL:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local stop = Instance.new("TextButton", AimL); stop.Size = UDim2.new(1, 0, 0, 35); stop.BackgroundColor3 = Color3.fromRGB(150,0,0); stop.Text = "TẮT AIM"; stop.TextColor3 = Color3.new(1,1,1); stop.MouseButton1Click:Connect(function() Flags.AimbotTarget = nil end)
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton", AimL); b.Size = UDim2.new(1, 0, 0, 30); b.Text = p.DisplayName; b.MouseButton1Click:Connect(function() Flags.AimbotTarget = p end)
        end
    end
end
UpdateList(); Players.PlayerAdded:Connect(UpdateList); Players.PlayerRemoving:Connect(UpdateList)

-- --- [ HUD TỐI GIẢN ] ---
local HUD = Instance.new("TextLabel", ScreenGui); HUD.Size = UDim2.new(0, 200, 0, 50); HUD.Position = UDim2.new(0.5, -100, 0, 5); HUD.BackgroundTransparency = 0.5; HUD.BackgroundColor3 = Color3.new(0,0,0); HUD.TextColor3 = Color3.new(1,1,1); HUD.Font = Enum.Font.GothamBold; HUD.TextSize = 10; Instance.new("UICorner", HUD)
RunService.RenderStepped:Connect(function()
    HUD.Text = string.format("User: %s | FPS: %d\nTime: %s | Aim: %s", LocalPlayer.Name, math.floor(1/RunService.RenderStepped:Wait()), os.date("%X"), Flags.AimbotTarget and Flags.AimbotTarget.DisplayName or "None")
end)

-- --- [ MỞ MENU ] ---
local MainBtn = Instance.new("TextButton", ScreenGui)
MainBtn.Size = UDim2.new(0, 45, 0, 45); MainBtn.Position = UDim2.new(0.05, 0, 0.4, 0); MainBtn.Text = "THD"; MainBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); MainBtn.TextColor3 = Color3.new(1,1,1); MainBtn.Draggable = true; Instance.new("UICorner", MainBtn)
MainBtn.MouseButton1Click:Connect(function() Menu.Visible = not Menu.Visible end)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Flags.AimbotTarget and Flags.AimbotTarget.Character and Flags.AimbotTarget.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Flags.AimbotTarget.Character.HumanoidRootPart.Position)
    end
end)
