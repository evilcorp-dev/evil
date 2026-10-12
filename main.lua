local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")
local TPS         = game:GetService("TeleportService")
local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local cfg = {
    esp=false, box=true, skel=true, name=true, hp=true, dist=true,
    aim=false, aimPart="Head", silent=false, trigger=false, aimVisible=false,
    fovCircle=false, fov=150, smooth=50,
    god=false, fly=false, spd=60,
    speed=false, speedVal=0,
    tpEnemy=false,
}

local THEMES = {
    { name="Preto",    bg=Color3.fromRGB(11,11,13), panel=Color3.fromRGB(15,15,18), card=Color3.fromRGB(22,22,26), on=Color3.fromRGB(48,48,56),  txt=Color3.fromRGB(228,228,234), dim=Color3.fromRGB(130,130,140), accent=Color3.fromRGB(220,40,40) },
    { name="Verde",    bg=Color3.fromRGB(9,15,11),  panel=Color3.fromRGB(12,22,15), card=Color3.fromRGB(18,32,22), on=Color3.fromRGB(40,110,65), txt=Color3.fromRGB(220,240,225), dim=Color3.fromRGB(130,180,145), accent=Color3.fromRGB(80,220,120) },
    { name="Branco",   bg=Color3.fromRGB(225,225,230), panel=Color3.fromRGB(238,238,242), card=Color3.fromRGB(250,250,252), on=Color3.fromRGB(175,175,185), txt=Color3.fromRGB(18,18,22), dim=Color3.fromRGB(90,90,100), accent=Color3.fromRGB(210,40,40) },
    { name="Roxo",     bg=Color3.fromRGB(14,9,22),  panel=Color3.fromRGB(20,12,32), card=Color3.fromRGB(28,16,44), on=Color3.fromRGB(85,50,140), txt=Color3.fromRGB(230,220,240), dim=Color3.fromRGB(150,130,180), accent=Color3.fromRGB(180,90,230) },
    { name="Vermelho", bg=Color3.fromRGB(18,9,9),   panel=Color3.fromRGB(28,12,12), card=Color3.fromRGB(40,16,16), on=Color3.fromRGB(130,40,40), txt=Color3.fromRGB(240,220,220), dim=Color3.fromRGB(180,130,130), accent=Color3.fromRGB(230,60,60) },
    { name="Azul",     bg=Color3.fromRGB(9,13,20),  panel=Color3.fromRGB(12,18,30), card=Color3.fromRGB(16,26,42), on=Color3.fromRGB(40,80,140), txt=Color3.fromRGB(220,228,240), dim=Color3.fromRGB(130,150,190), accent=Color3.fromRGB(70,150,230) },
}

local C = {}
for k,v in pairs(THEMES[1]) do C[k] = v end

pcall(function()
    if game:GetService("CoreGui"):FindFirstChild("EvilUI") then
        game:GetService("CoreGui").EvilUI:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "EvilUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0,58,0,58)
Float.Position = UDim2.new(0,30,0,120)
Float.BackgroundColor3 = C.panel
Float.Text = "evil"
Float.TextColor3 = C.accent
Float.Font = Enum.Font.GothamBold
Float.TextSize = 15
Float.AutoButtonColor = false
Float.Parent = gui
Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local fs = Instance.new("UIStroke", Float)
fs.Color = C.accent
fs.Thickness = 1.5

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,700,0,440)
Main.Position = UDim2.new(0,100,0,80)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.on
ms.Thickness = 1

do
    local drag, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = Main.AbsolutePosition
        end
    end)
    Main.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Main.Position = UDim2.new(0, sp.X + d.X, 0, sp.Y + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

do
    local drag, ds, sp, moved
    Float.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; moved = false; ds = i.Position; sp = Float.AbsolutePosition
        end
    end)
    Float.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            if d.Magnitude > 5 then moved = true end
            Float.Position = UDim2.new(0, sp.X + d.X, 0, sp.Y + d.Y)
        end
... (789 linhas)
