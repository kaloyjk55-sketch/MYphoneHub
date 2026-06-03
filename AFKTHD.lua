--[[
    👑 PROJECT: THD AFK
    👤 CREDITS: Nguyễn Thành Đoàn 2014
    📱 TARGET: Mobile - Treo Đêm Siêu Cấp, Chống Nóng Máy, Auto Rejoin
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer

local AFKFlags = {
    AntiAFK = true,
    SuperAntiLag = false,
    WhiteScreen = false,
    AutoRejoin = true
}

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "THD_AFK_Official"

-- ─── 1. AUTO REJOIN (TỰ ĐỘNG VÀO LẠI KHI MẤT KẾT NỐI) ───
if AFKFlags.AutoRejoin then
    GuiService.ErrorMessageChanged:Connect(function()
        task.wait(5)
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

-- ─── 2. ANTI-AFK BYPASS (CỰC KỲ BÁ ĐẠO) ───
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if AFKFlags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
        VirtualUser:ClickButton1(Vector2.new(0,0))
    end
end)

-- ─── 3. WHITE SCREEN (TẮT RENDER 3D - MÁT MÁY TIẾT KIỆM PIN 99%) ───
local BlankFrame = Instance.new("Frame", ScreenGui)
BlankFrame.Size = UDim2.new(1, 0, 1, 0)
BlankFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Đổi sang nền tối cho dịu mắt ban đêm
BlankFrame.Visible = false
BlankFrame.ZIndex = 999999

local OverlayText = Instance.new("TextLabel", BlankFrame)
OverlayText.Size = UDim2.new(1, 0, 0, 80)
OverlayText.Position = UDim2.new(0, 0, 0.5, -40)
OverlayText.Text = "THD AFK\n(Đang tối ưu đồ họa để làm mát máy...)\n\nCre: Nguyễn Thành Đoàn 2014"
OverlayText.TextColor3 = Color3.fromRGB(0, 255, 255)
OverlayText.Font = Enum.Font.GothamBold
OverlayText.TextSize = 15

local function ToggleWhiteScreen(enable)
    BlankFrame.Visible = enable
    RunService:Set3dRenderingEnabled(not enable)
end

-- ─── 4. SUPER ANTI-LAG + DỌN RÁC BỘ NHỚ ĐỆM ───
local function CleanGarbage()
    if AFKFlags.SuperAntiLag then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
                v.Enabled = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v:Destroy()
            end
        end
    end
end

task.spawn(function()
    while task.wait(120) do
        if AFKFlags.SuperAntiLag then
            CleanGarbage()
            collectgarbage("collect")
        end
    end
end)

-- ─── 5. GIAO DIỆN THIẾT KẾ THD AFK CYBER ───
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 235)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, -117)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(0, 255, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "THD AFK ⚡ GOD ENGINE"; Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.BackgroundTransparency = 1

local CreditsLabel = Instance.new("TextLabel", MainFrame)
CreditsLabel.Size = UDim2.new(1, 0, 0, 20); CreditsLabel.Text = "Cre: Nguyễn Thành Đoàn 2014"; CreditsLabel.TextColor3 = Color3.fromRGB(0, 255, 255); CreditsLabel.Font = Enum.Font.SourceSansItalic; CreditsLabel.TextSize = 12; CreditsLabel.BackgroundTransparency = 1

local ListLayout = Instance.new("UIListLayout", MainFrame)
ListLayout.Padding = UDim.new(0, 5)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function AddAFKToggle(name, flag, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 210, 0, 32)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local function Update()
        if AFKFlags[flag] then
            btn.Text = "🔹 " .. name .. ": [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(12, 30, 36)
            btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        else
            btn.Text = "❌ " .. name .. ": [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            btn.TextColor3 = Color3.fromRGB(130, 130, 130)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        AFKFlags[flag] = not AFKFlags[flag]
        Update()
        if callback then callback(AFKFlags[flag]) end
    end)
    Update()
end

-- Sắp xếp thứ tự hiển thị chuẩn cấu trúc UIListLayout
Title.Parent = MainFrame
CreditsLabel.Parent = MainFrame

AddAFKToggle("ANTI-AFK TREO MÁY", "AntiAFK")
AddAFKToggle("AUTO REJOIN SERVER", "AutoRejoin")
AddAFKToggle("SIÊU CHỐNG LAG FPS+", "SuperAntiLag", function(s) if s then CleanGarbage() end end)
AddAFKToggle("CHẾ ĐỘ MÀN HÌNH TỐI", "WhiteScreen", function(s) ToggleWhiteScreen(s) end)

-- BUTTON THU GỌN NỔI
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 46, 0, 46); OpenBtn.Position = UDim2.new(0.04, 0, 0.6, 0); OpenBtn.Text = "THD"; OpenBtn.BackgroundColor3 = Color3.fromRGB(12, 13, 17); OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 255); OpenBtn.Font = Enum.Font.GothamBold; OpenBtn.TextSize = 11; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 50); OpenBtn.Draggable = true
local BtnStroke = Instance.new("UIStroke", OpenBtn); BtnStroke.Color = Color3.fromRGB(0, 255, 255)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("⚡ THD AFK BY NGUYỄN THÀNH ĐOÀN 2014 LOAEDED SUCCESSFULLY!")
