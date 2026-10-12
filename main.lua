local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Workspace    = game:GetService("Workspace")
local CoreGui      = game:GetService("CoreGui")
local TPS          = game:GetService("TeleportService")
local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera

local EVIL_IMAGE_ID = nil

local cfg = {
    esp=false, box=true, skel=true, name=true, hp=true, dist=true, line=false,
    aim=false, aimKey=Enum.KeyCode.E, aimMouse=false, aimMouseBtn=1,
    silent=false, trigger=false, rapidFire=false,
    fovCircle=false, fov=150, smooth=50,
    god=false, fly=false, spd=60,
}

pcall(function()
    if CoreGui:FindFirstChild("EvilUI") then CoreGui.EvilUI:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvilUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

local placed = pcall(function() ScreenGui.Parent = CoreGui end)
if not placed or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local COL = {
    bg=Color3.fromRGB(12,12,14), panel=Color3.fromRGB(18,18,21),
    card=Color3.fromRGB(26,26,30), cardOn=Color3.fromRGB(58,58,66),
    stroke=Color3.fromRGB(50,50,58), accent=Color3.fromRGB(90,90,100),
    text=Color3.fromRGB(228,228,234), textDim=Color3.fromRGB(140,140,150),
    danger=Color3.fromRGB(170,60,60),
}

-- FLOAT
local Float = Instance.new("TextButton")
Float.Name = "EvilFloat"
Float.Size = UDim2.new(0, 64, 0, 64)
Float.Position = UDim2.new(0, 30, 0, 120)
Float.BackgroundColor3 = COL.panel
Float.Text = ""
Float.AutoButtonColor = false
Float.Active = true
Float.Parent = ScreenGui
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", Float)
FloatStroke.Color = COL.accent
FloatStroke.Thickness = 2

if EVIL_IMAGE_ID then
    local img = Instance.new("ImageLabel", Float)
    img.Size = UDim2.new(1, -14, 1, -14)
    img.Position = UDim2.new(0, 7, 0, 7)
    img.BackgroundTransparency = 1
    img.Image = EVIL_IMAGE_ID
    img.ScaleType = Enum.ScaleType.Fit
    img.ImageColor3 = COL.text
else
    local lbl = Instance.new("TextLabel", Float)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "evil"
    lbl.TextColor3 = COL.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
end

-- MENU
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 760, 0, 470)
Main.Position = UDim2.new(0, 100, 0, 80)
Main.BackgroundColor3 = COL.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MStroke = Instance.new("UIStroke", Main)
MStroke.Color = COL.stroke
MStroke.Thickness = 1

do
    local dragging, ds, sp
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; sp = Main.AbsolutePosition
        end
    end)
    Main.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            Main.Position = UDim2.new(0, sp.X + d.X, 0, sp.Y + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

do
    local dragging, ds, sp, moved
    Float.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; ds = i.Position; sp = Float.AbsolutePosition
        end
    end)
    Float.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            if d.Magnitude > 5 then moved = true end
            Float.Position = UDim2.new(0, sp.X + d.X, 0, sp.Y + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then Main.Visible = not Main.Visible end
            dragging = false
        end
    end)
end

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = COL.danger
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = COL.panel
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local LogoBox = Instance.new("Frame", Sidebar)
LogoBox.Size = UDim2.new(0, 78, 0, 78)
LogoBox.Position = UDim2.new(0.5, -39, 0, 16)
LogoBox.BackgroundColor3 = COL.card
LogoBox.BorderSizePixel = 0
Instance.new("UICorner", LogoBox).CornerRadius = UDim.new(1, 0)

if EVIL_IMAGE_ID then
    local li = Instance.new("ImageLabel", LogoBox)
    li.Size = UDim2.new(1, -16, 1, -16)
    li.Position = UDim2.new(0, 8, 0, 8)
    li.BackgroundTransparency = 1
    li.Image = EVIL_IMAGE_ID
    li.ScaleType = Enum.ScaleType.Fit
    li.ImageColor3 = COL.text
else
    local LogoLabel = Instance.new("TextLabel", LogoBox)
    LogoLabel.Size = UDim2.new(1, 0, 1, 0)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = "evil"
    LogoLabel.TextColor3 = COL.text
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.TextSize = 22
end

local CatFrame = Instance.new("Frame", Sidebar)
CatFrame.Size = UDim2.new(1, -16, 1, -120)
CatFrame.Position = UDim2.new(0, 8, 0, 105)
CatFrame.BackgroundTransparency = 1
local CatLayout = Instance.new("UIListLayout", CatFrame)
CatLayout.Padding = UDim.new(0, 4)
CatLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -150, 1, 0)
Pages.Position = UDim2.new(0, 150, 0, 0)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants = true

local PageMap = {}
local CatButtons = {}

local function makePage(name)
    local p = Instance.new("Frame", Pages)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    PageMap[name] = p
    return p
end

local function selectCat(name)
    for k, v in pairs(PageMap) do v.Visible = (k == name) end
    for n, btn in pairs(CatButtons) do
        btn.BackgroundColor3 = (n == name) and COL.cardOn or COL.card
        btn.TextColor3 = (n == name) and COL.text or COL.textDim
    end
end

local function makeCat(name, order)
    local b = Instance.new("TextButton", CatFrame)
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = COL.card
    b.Text = "  " .. name
    b.TextColor3 = COL.textDim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() selectCat(name) end)
    CatButtons[name] = b
    return b
end

local function toggle(parent, label, def, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -16, 0, 36)
    b.BackgroundColor3 = def and COL.cardOn or COL.card
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -70, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = COL.text
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", b)
    pill.Size = UDim2.new(0, 38, 0, 20)
    pill.Position = UDim2.new(1, -50, 0.5, -10)
    pill.BackgroundColor3 = def and COL.accent or Color3.fromRGB(40,40,46)
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", pill)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = def and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = COL.text
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local st = def
    b.MouseButton1Click:Connect(function()
        st = not st
        b.BackgroundColor3 = st and COL.cardOn or COL.card
        pill.BackgroundColor3 = st and COL.accent or Color3.fromRGB(40,40,46)
        dot.Position = st and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        cb(st)
    end)
end

local function slider(parent, label, mn, mx, d, cb)
    local h = Instance.new("Frame", parent)
    h.Size = UDim2.new(1, -16, 0, 48)
    h.BackgroundColor3 = COL.card
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 8)

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1, -20, 0, 18)
    lb.Position = UDim2.new(0, 12, 0, 3)
    lb.BackgroundTransparency = 1
    lb.Text = label .. ": " .. d
    lb.TextColor3 = COL.text
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(42,42,48)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((d - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = COL.accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((d - mn) / (mx - mn), -6, 0.5, -6)
    knob.BackgroundColor3 = COL.text
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.ZIndex = 2

    local dr = false
    local function upd(i)
        local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -6, 0.5, -6)
        lb.Text = label .. ": " .. v
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

local function keybind(parent, label, getFn, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -16, 0, 36)
    b.BackgroundColor3 = COL.card
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -110, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = COL.text
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left

    local k = Instance.new("TextLabel", b)
    k.Size = UDim2.new(0, 88, 1, 0)
    k.Position = UDim2.new(1, -98, 0, 0)
    k.BackgroundTransparency = 1
    k.Text = getFn() or "NONE"
    k.TextColor3 = COL.text
    k.Font = Enum.Font.GothamBold
    k.TextSize = 12

    local waiting = false
    b.MouseButton1Click:Connect(function()
        waiting = true; k.Text = "[...]"; k.TextColor3 = Color3.fromRGB(255,200,100)
    end)
    UIS.InputBegan:Connect(function(input, gpe)
        if not waiting or gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            k.Text = input.KeyCode.Name; k.TextColor3 = COL.text; waiting = false; cb("kb", input.KeyCode)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            k.Text = "MB1"; k.TextColor3 = COL.text; waiting = false; cb("mouse", 1)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            k.Text = "MB2"; k.TextColor3 = COL.text; waiting = false; cb("mouse", 2)
        end
    end)
end

local AimPage    = makePage("AIM")
local VisPage    = makePage("VISUALS")
local MiscPage   = makePage("MISC")
local PlayerPage = makePage("PLAYER")

local function title(page, t)
    local x = Instance.new("TextLabel", page)
    x.Size = UDim2.new(1, 0, 0, 36)
    x.BackgroundColor3 = COL.panel
    x.Text = "  " .. t
    x.TextColor3 = COL.text
    x.Font = Enum.Font.GothamBold
    x.TextSize = 15
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.ZIndex = 5
    Instance.new("UICorner", x).CornerRadius = UDim.new(0, 8)
end

title(AimPage, "AIM")
title(VisPage, "VISUALS")
title(MiscPage, "MISC")
title(PlayerPage, "PLAYER")

local function scroll(page)
    local s = Instance.new("ScrollingFrame", page)
    s.Size = UDim2.new(1, -16, 1, -54)
    s.Position = UDim2.new(0, 8, 0, 46)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 4
    s.ScrollBarImageColor3 = COL.accent
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.ZIndex = 1
    local lay = Instance.new("UIListLayout", s)
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

local AS = scroll(AimPage)
local VS = scroll(VisPage)
local MS = scroll(MiscPage)
local PS = scroll(PlayerPage)

makeCat("AIM", 1)
makeCat("VISUALS", 2)
makeCat("MISC", 3)
makeCat("PLAYER", 4)

local applyRapid
local setFly

toggle(AS, "Aimbot", cfg.aim, function(v) cfg.aim = v end)
keybind(AS, "Aimbot Key", function()
    if cfg.aimMouse then return cfg.aimMouseBtn == 1 and "MB1" or "MB2" end
    return cfg.aimKey.Name
end, function(kind, val)
    if kind == "mouse" then cfg.aimMouse = true; cfg.aimMouseBtn = val
    else cfg.aimMouse = false; cfg.aimKey = val end
end)
toggle(AS, "Silent Aim", cfg.silent, function(v) cfg.silent = v end)
toggle(AS, "Triggerbot", cfg.trigger, function(v) cfg.trigger = v end)
toggle(AS, "FOV Circle", cfg.fovCircle, function(v) cfg.fovCircle = v end)
slider(AS, "FOV", 30, 600, cfg.fov, function(v) cfg.fov = v end)
slider(AS, "Smooth", 1, 100, cfg.smooth, function(v) cfg.smooth = v end)

toggle(VS, "ESP", cfg.esp, function(v) cfg.esp = v end)
toggle(VS, "Box", cfg.box, function(v) cfg.box = v end)
toggle(VS, "Skeleton", cfg.skel, function(v) cfg.skel = v end)
toggle(VS, "Name", cfg.name, function(v) cfg.name = v end)
toggle(VS, "Health", cfg.hp, function(v) cfg.hp = v end)
toggle(VS, "Distance", cfg.dist, function(v) cfg.dist = v end)
toggle(VS, "Line", cfg.line, function(v) cfg.line = v end)

toggle(PS, "Godmode", cfg.god, function(v) cfg.god = v end)
toggle(PS, "Fly", cfg.fly, function(v) cfg.fly = v; if setFly then setFly(v) end end)
slider(PS, "Fly Speed", 10, 300, cfg.spd, function(v) cfg.spd = v end)

toggle(MS, "Rapid Fire", cfg.rapidFire, function(v) cfg.rapidFire = v; if applyRapid then applyRapid() end end)
toggle(MS, "Rejoin", false, function(v) if v then TPS:Teleport(game.PlaceId, Local
