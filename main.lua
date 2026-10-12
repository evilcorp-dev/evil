local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local Workspace   = game:GetService("Workspace")
local TPS         = game:GetService("TeleportService")
local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local EVIL_IMG = "rbxassetid://0"

local cfg = {
    esp=false, box=true, skel=true, name=true, hp=true, dist=true,
    aim=false, aimPart="Head", silent=false, trigger=false, aimVisible=false,
    fovCircle=false, fov=150, smooth=50,
    god=false, fly=false, spd=60,
    speed=false, speedVal=0,
    tpEnemy=false,
}

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

local C = {
    bg=Color3.fromRGB(12,12,14), panel=Color3.fromRGB(18,18,21),
    card=Color3.fromRGB(26,26,30), on=Color3.fromRGB(58,58,66),
    txt=Color3.fromRGB(228,228,234), dim=Color3.fromRGB(140,140,150),
}

local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0,64,0,64)
Float.Position = UDim2.new(0,30,0,120)
Float.BackgroundColor3 = C.panel
Float.Text = "evil"
Float.TextColor3 = C.txt
Float.Font = Enum.Font.GothamBold
Float.TextSize = 16
Float.AutoButtonColor = false
Float.Parent = gui
Instance.new("UICorner", Float).CornerRadius = UDim.new(1,0)
local fs = Instance.new("UIStroke", Float)
fs.Color = C.dim
fs.Thickness = 2

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,700,0,440)
Main.Position = UDim2.new(0,100,0,80)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.dim
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
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if drag and not moved then Main.Visible = not Main.Visible end
            drag = false
        end
    end)
end

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,140,1,0)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,12)

local LogoBox = Instance.new("Frame", Sidebar)
LogoBox.Size = UDim2.new(0,78,0,78)
LogoBox.Position = UDim2.new(0.5,-39,0,14)
LogoBox.BackgroundColor3 = C.card
LogoBox.BorderSizePixel = 0
Instance.new("UICorner", LogoBox).CornerRadius = UDim.new(1,0)

if EVIL_IMG and EVIL_IMG ~= "rbxassetid://0" then
    local img = Instance.new("ImageLabel", LogoBox)
    img.Size = UDim2.new(1,-14,1,-14)
    img.Position = UDim2.new(0,7,0,7)
    img.BackgroundTransparency = 1
    img.Image = EVIL_IMG
    img.ScaleType = Enum.ScaleType.Fit
    img.ImageColor3 = C.txt
else
    local ll = Instance.new("TextLabel", LogoBox)
    ll.Size = UDim2.new(1,0,1,0)
    ll.BackgroundTransparency = 1
    ll.Text = "evil"
    ll.TextColor3 = C.txt
    ll.Font = Enum.Font.GothamBold
    ll.TextSize = 22
end

local CatFrame = Instance.new("Frame", Sidebar)
CatFrame.Size = UDim2.new(1,-16,1,-120)
CatFrame.Position = UDim2.new(0,8,0,105)
CatFrame.BackgroundTransparency = 1
local cl = Instance.new("UIListLayout", CatFrame)
cl.Padding = UDim.new(0,4)
cl.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-140,1,0)
Pages.Position = UDim2.new(0,140,0,0)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants = true

local PM, CB = {}, {}
local function page(n)
    local p = Instance.new("Frame", Pages)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    PM[n] = p
    return p
end
local function sel(n)
    for k,v in pairs(PM) do v.Visible = (k==n) end
    for k,b in pairs(CB) do
        b.BackgroundColor3 = (k==n) and C.on or C.card
        b.TextColor3 = (k==n) and C.txt or C.dim
    end
end
local function cat(n,o)
    local b = Instance.new("TextButton", CatFrame)
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = C.card
    b.Text = "  "..n
    b.TextColor3 = C.dim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = o
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(function() sel(n) end)
    CB[n] = b
end

local function tog(p, label, def, order, cb)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,-16,0,34)
    b.BackgroundColor3 = def and C.on or C.card
    b.Text = "  "..label
    b.TextColor3 = C.txt
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = def
    b.MouseButton1Click:Connect(function()
        s = not s
        b.BackgroundColor3 = s and C.on or C.card
        cb(s)
    end)
end

local function sld(p, label, mn, mx, def, order, cb)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1,-16,0,46)
    h.BackgroundColor3 = C.card
    h.LayoutOrder = order or 0
    Instance.new("UICorner", h).CornerRadius = UDim.new(0,8)

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-20,0,18)
    lb.Position = UDim2.new(0,12,0,3)
    lb.BackgroundTransparency = 1
    lb.Text = label..": "..def
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1,-24,0,6)
    bar.Position = UDim2.new(0,12,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(42,42,48)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = C.dim
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0,12,0,12)
    knob.Position = UDim2.new((def-mn)/(mx-mn),-6,0.5,-6)
    knob.BackgroundColor3 = C.txt
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    knob.ZIndex = 2

    local dr = false
    local function upd(i)
        local pr = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx-mn)*pr)
        fill.Size = UDim2.new(pr,0,1,0)
        knob.Position = UDim2.new(pr,-6,0.5,-6)
        lb.Text = label..": "..v
        cb(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dr = true; upd(i)
        end
    end)
    bar.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

local function row(p, label, opts, def, order, cb)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1,-16,0,52)
    h.BackgroundColor3 = C.card
    h.LayoutOrder = order or 0
    Instance.new("UICorner", h).CornerRadius = UDim.new(0,8)

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-20,0,18)
    lb.Position = UDim2.new(0,12,0,3)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local holder = Instance.new("Frame", h)
    holder.Size = UDim2.new(1,-24,0,24)
    holder.Position = UDim2.new(0,12,0,24)
    holder.BackgroundTransparency = 1
    local hl = Instance.new("UIListLayout", holder)
    hl.FillDirection = Enum.FillDirection.Horizontal
    hl.Padding = UDim.new(0,6)
    hl.SortOrder = Enum.SortOrder.LayoutOrder

    local btns = {}
    local function setActive(name)
        for n, b in pairs(btns) do
            b.BackgroundColor3 = (n == name) and C.on or Color3.fromRGB(34,34,38)
            b.TextColor3 = (n == name) and C.txt or C.dim
        end
    end

    for i, name in ipairs(opts) do
        local b = Instance.new("TextButton", holder)
        b.Size = UDim2.new(0,70,1,0)
        b.BackgroundColor3 = (name == def) and C.on or Color3.fromRGB(34,34,38)
        b.Text = name
        b.TextColor3 = (name == def) and C.txt or C.dim
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.AutoButtonColor = false
        b.LayoutOrder = i
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            setActive(name)
            cb(name)
        end)
        btns[name] = b
    end
end

local function sc(p)
    local s = Instance.new("ScrollingFrame", p)
    s.Size = UDim2.new(1,-16,1,-16)
    s.Position = UDim2.new(0,8,0,8)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 4
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local l = Instance.new("UIListLayout", s)
    l.Padding = UDim.new(0,6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

local AP = page("AIM")
local VP = page("VISUALS")
local MP = page("MISC")
local PP = page("PLAYER")

local AS = sc(AP)
local VS = sc(VP)
local MS = sc(MP)
local PS = sc(PP)

cat("AIM",1) cat("VISUALS",2) cat("MISC",3) cat("PLAYER",4)

local applyRapid, setFly
local isVisible, target

tog(AS, "Aimbot", cfg.aim, 1, function(v) cfg.aim=v end)
row(AS, "Aim Part", {"Head","Neck","Body"}, cfg.aimPart, 2, function(v) cfg.aimPart = v end)
sld(AS, "Regular FOV", 30, 600, cfg.fov, 3, function(v) cfg.fov = v end)
sld(AS, "Smooth", 1, 100, cfg.smooth, 4, function(v) cfg.smooth = v end)
tog(AS, "Aim Visible", cfg.aimVisible, 5, function(v) cfg.aimVisible=v end)
tog(AS, "Silent Aim", cfg.silent, 6, function(v) cfg.silent=v end)
tog(AS, "Triggerbot", cfg.trigger, 7, function(v) cfg.trigger=v end)
tog(AS, "FOV Circle", cfg.fovCircle, 8, function(v) cfg.fovCircle=v end)

tog(VS, "ATIVAR ESP", cfg.esp, 1, function(v) cfg.esp=v end)
tog(VS, "Box", cfg.box, 2, function(v) cfg.box=v end)
tog(VS, "Skeleton", cfg.skel, 3, function(v) cfg.skel=v end)
tog(VS, "Name", cfg.name, 4, function(v) cfg.name=v end)
tog(VS, "Health", cfg.hp, 5, function(v) cfg.hp=v end)
tog(VS, "Distance", cfg.dist, 6, function(v) cfg.dist=v end)

tog(PS, "Godmode", cfg.god, 1, function(v) cfg.god=v end)
tog(PS, "Fly [WASD+Space]", cfg.fly, 2, function(v) cfg.fly=v; if setFly then setFly(v) end end)
sld(PS, "Fly Speed", 10, 300, cfg.spd, 3, function(v) cfg.spd = v end)
tog(PS, "Speed", cfg.speed, 4, function(v) cfg.speed=v end)
sld(PS, "Speed Value", 0, 30, cfg.speedVal, 5, function(v) cfg.speedVal = v end)

tog(MS, "TP to Enemy", false, 1, function(v)
    if v then
        local t = target and target()
        if t then
            local c = LP.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            if hr then
                hr.CFrame = CFrame.new(t.Position + Vector3.new(0, 3, 0))
            end
        end
        task.delay(0.3, function() cfg.tpEnemy = false end)
    end
    cfg.tpEnemy = false
end)
tog(MS, "Rapid Fire", false, 2, function(v) if applyRapid then applyRapid(v) end end)
tog(MS, "Rejoin", false, 3, function(v) if v then TPS:Teleport(game.PlaceId, LP) end end)

sel("AIM")
