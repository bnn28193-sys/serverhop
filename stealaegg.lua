-- =========================================================
-- CYBERPUNK SERVER HOPPER - RELAXED & FAST EDITION
-- =========================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ลบ UI เก่าทิ้งกันซ้ำ
if CoreGui:FindFirstChild("CyberHopGUI") then
    CoreGui.CyberHopGUI:Destroy()
end

-- สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberHopGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- กรอบหลัก (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 65)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- เส้นขอบนีออนเรืองแสง
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 200)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- เอฟเฟกต์แสงนีออนกระพริบ
task.spawn(function()
    while MainFrame and MainFrame.Parent do
        TweenService:Create(UIStroke, TweenInfo.new(1.5), {Color = Color3.fromRGB(180, 0, 255)}):Play()
        task.wait(1.5)
        TweenService:Create(UIStroke, TweenInfo.new(1.5), {Color = Color3.fromRGB(0, 255, 200)}):Play()
        task.wait(1.5)
    end
end)

-- ปุ่มกด (Action Button)
local HopButton = Instance.new("TextButton")
HopButton.Size = UDim2.new(1, -12, 1, -12)
HopButton.Position = UDim2.new(0, 6, 0, 6)
HopButton.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
HopButton.BorderSizePixel = 0
HopButton.Text = "⚡ QUICK HOP (ย้ายเซิร์ฟ)"
HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HopButton.TextSize = 13
HopButton.Font = Enum.Font.GothamBold
HopButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = HopButton

-- ฟังก์ชันสุ่มหาเซิร์ฟเวอร์แบบผ่อนปรนเงื่อนไข
HopButton.MouseButton1Click:Connect(function()
    HopButton.Text = "🔍 กำลังสแกนเซิร์ฟ..."
    HopButton.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    task.spawn(function()
        local success, err = pcall(function()
            local servers = {}
            local cursor = ""
            
            -- วนดึงข้อมูลสูงสุด 5 หน้า เพื่อให้เจอตัวเลือกเยอะที่สุด
            for i = 1, 5 do
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor ~= "" then
                    url = url .. "&cursor=" .. cursor
                end
                
                local response = game:HttpGet(url)
                local data = HttpService:JSONDecode(response)
                
                if data and data.data then
                    for _, s in ipairs(data.data) do
                        -- เงื่อนไขใหม่: ขอแค่ไม่ใช่ห้องเดิม และเซิร์ฟเวอร์ยังมีที่ว่าง (คนไม่เต็ม) เอาหมด!
                        if s.id ~= game.JobId and s.playing < s.maxPlayers then
                            table.insert(servers, s)
                        end
                    end
                end
                
                cursor = data.nextPageCursor
                if not cursor then break end
            end
            
            if #servers > 0 then
                -- เรียงลำดับจากห้องที่คนน้อยไปหามาก แล้วสุ่มหยิบสักห้องในกลุ่มคนน้อย
                table.sort(servers, function(a, b)
                    return a.playing < b.playing
                end)
                
                local target = servers[math.random(1, math.min(#servers, 10))]
                
                HopButton.Text = "🚀 ย้ายไปห้อง (" .. target.playing .. " คน)"
                HopButton.TextColor3 = Color3.fromRGB(0, 255, 100)
                
                task.wait(0.3)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
            else
                HopButton.Text = "⚠️ ไม่พบห้องว่าง"
                HopButton.TextColor3 = Color3.fromRGB(255, 50, 50)
                task.wait(2.5)
                HopButton.Text = "⚡ QUICK HOP (ย้ายเซิร์ฟ)"
                HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        if not success then
            HopButton.Text = "❌ ลองใหม่อีกครั้ง"
            HopButton.TextColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(2.5)
            HopButton.Text = "⚡ QUICK HOP (ย้ายเซิร์ฟ)"
            HopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end)

