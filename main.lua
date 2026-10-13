--[[
  evil ui - evilcorp
  external-style roblox executor script
  fixes: silent aim (metatable hook robusto) + esp culling/cache
]]

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
    local cg = game:GetService("CoreGui")
    if cg:FindFirstChild("EvilUI") then cg.EvilUI:Destroy() end
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
Float.Text = "Evil"
Float.TextColor3 = C.accent
Float.Font = Enum.Font.GothamBlack
Float.TextSize = 14
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
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if drag and not moved then Main.Visible = not Main.Visible end
            drag = false
        end
    end)
end

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,155,1,0)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)

local LogoBox = Instance.new("Frame", Sidebar)
LogoBox.Size = UDim2.new(1,0,0,80)
LogoBox.Position = UDim2.new(0,0,0,6)
LogoBox.BackgroundTransparency = 1

local LogoLabel = Instance.new("TextLabel", LogoBox)
LogoLabel.Size = UDim2.new(1,0,1,0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "Evil"
LogoLabel.TextColor3 = C.accent
LogoLabel.Font = Enum.Font.GothamBlack
LogoLabel.TextSize = 34
LogoLabel.TextXAlignment = Enum.TextXAlignment.Center

local CatFrame = Instance.new("Frame", Sidebar)
CatFrame.Size = UDim2.new(1,-16,1,-102)
CatFrame.Position = UDim2.new(0,8,0,96)
CatFrame.BackgroundTransparency = 1
local cl = Instance.new("UIListLayout", CatFrame)
cl.Padding = UDim.new(0,3)
cl.SortOrder = Enum.SortOrder.LayoutOrder

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-155,1,0)
Pages.Position = UDim2.new(0,155,0,0)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants = true

local PM, CB = {}, {}

local function page(n)
    local p = Instance.new("Frame", Pages)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    PM[n] = p

    local hdr = Instance.new("TextLabel", p)
    hdr.Name = "Header"
    hdr.Size = UDim2.new(1,-28,0,28)
    hdr.Position = UDim2.new(0,20,0,16)
    hdr.BackgroundTransparency = 1
    hdr.Text = string.upper(n)
    hdr.TextColor3 = C.dim
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 11
    hdr.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", p)
    line.Name = "HeaderLine"
    line.Size = UDim2.new(1,-28,0,1)
    line.Position = UDim2.new(0,20,0,46)
    line.BackgroundColor3 = C.on
    line.BorderSizePixel = 0

    return p
end

local function sel(n)
    for k,v in pairs(PM) do v.Visible = (k==n) end
    for k,b in pairs(CB) do
        if k == n then
            b.BackgroundColor3 = C.on
            if b:FindFirstChild("Label") then b.Label.TextColor3 = C.txt end
            if b:FindFirstChild("Indicator") then b.Indicator.Visible = true end
        else
            b.BackgroundColor3 = C.panel
            if b:FindFirstChild("Label") then b.Label.TextColor3 = C.dim end
            if b:FindFirstChild("Indicator") then b.Indicator.Visible = false end
        end
    end
end

local function cat(icon, n, o)
    local b = Instance.new("TextButton", CatFrame)
    b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = C.panel
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = o
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local ind = Instance.new("Frame", b)
    ind.Name = "Indicator"
    ind.Size = UDim2.new(0,3,0,16)
    ind.Position = UDim2.new(0,0,0.5,-8)
    ind.BackgroundColor3 = C.accent
    ind.BorderSizePixel = 0
    ind.Visible = false

    local ic = Instance.new("TextLabel", b)
    ic.Size = UDim2.new(0,26,1,0)
    ic.Position = UDim2.new(0,10,0,0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextColor3 = C.txt
    ic.Font = Enum.Font.GothamBold
    ic.TextSize = 13

    local lb = Instance.new("TextLabel", b)
    lb.Name = "Label"
    lb.Size = UDim2.new(1,-40,1,0)
    lb.Position = UDim2.new(0,36,0,0)
    lb.BackgroundTransparency = 1
    lb.Text = n
    lb.TextColor3 = C.dim
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    b.MouseButton1Click:Connect(function() sel(n) end)
    CB[n] = b
    return b
end

local function tog(p, label, def, order, cb)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,-36,0,38)
    b.Position = UDim2.new(0,18,0,0)
    b.BackgroundColor3 = C.card
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1,-46,1,0)
    l.Position = UDim2.new(0,12,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left

    local chk = Instance.new("Frame", b)
    chk.Size = UDim2.new(0,18,0,18)
    chk.Position = UDim2.new(1,-30,0.5,-9)
    chk.BackgroundColor3 = def and C.accent or Color3.fromRGB(32,32,38)
    chk.BorderSizePixel = 0
    Instance.new("UICorner", chk).CornerRadius = UDim.new(0,4)

    local check = Instance.new("TextLabel", chk)
    check.Size = UDim2.new(1,0,1,0)
    check.BackgroundTransparency = 1
    check.Text = "✓"
    check.TextColor3 = Color3.fromRGB(255,255,255)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 12
    check.Visible = def

    local s = def
    b.MouseButton1Click:Connect(function()
        s = not s
        chk.BackgroundColor3 = s and C.accent or Color3.fromRGB(32,32,38)
        check.Visible = s
        cb(s)
    end)
end

local function sld(p, label, mn, mx, def, order, cb)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1,-36,0,48)
    h.Position = UDim2.new(0,18,0,0)
    h.BackgroundColor3 = C.card
    h.LayoutOrder = order or 0
    Instance.new("UICorner", h).CornerRadius = UDim.new(0,6)

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-70,0,16)
    lb.Position = UDim2.new(0,12,0,4)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", h)
    val.Size = UDim2.new(0,50,0,16)
    val.Position = UDim2.new(1,-60,0,4)
    val.BackgroundTransparency = 1
    val.Text = tostring(def)
    val.TextColor3 = C.dim
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1,-24,0,3)
    bar.Position = UDim2.new(0,12,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(36,36,42)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local dr = false
    local function upd(i)
        local pr = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx-mn)*pr)
        fill.Size = UDim2.new(pr,0,1,0)
        val.Text = tostring(v)
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
    h.Size = UDim2.new(1,-36,0,56)
    h.Position = UDim2.new(0,18,0,0)
    h.BackgroundColor3 = C.card
    h.LayoutOrder = order or 0
    Instance.new("UICorner", h).CornerRadius = UDim.new(0,6)

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-20,0,16)
    lb.Position = UDim2.new(0,12,0,4)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local holder = Instance.new("Frame", h)
    holder.Size = UDim2.new(1,-24,0,22)
    holder.Position = UDim2.new(0,12,0,28)
    holder.BackgroundTransparency = 1
    local hl = Instance.new("UIListLayout", holder)
    hl.FillDirection = Enum.FillDirection.Horizontal
    hl.Padding = UDim.new(0,6)
    hl.SortOrder = Enum.SortOrder.LayoutOrder

    local btns = {}
    local function setActive(name)
        for n, b in pairs(btns) do
            b.BackgroundColor3 = (n == name) and C.on or Color3.fromRGB(32,32,38)
            b.TextColor3 = (n == name) and C.txt or C.dim
        end
    end

    for i, name in ipairs(opts) do
        local b = Instance.new("TextButton", holder)
        b.Size = UDim2.new(0,66,1,0)
        b.BackgroundColor3 = (name == def) and C.on or Color3.fromRGB(32,32,38)
        b.Text = name
        b.TextColor3 = (name == def) and C.txt or C.dim
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.AutoButtonColor = false
        b.LayoutOrder = i
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
        b.MouseButton1Click:Connect(function()
            setActive(name)
            cb(name)
        end)
        btns[name] = b
    end
end

local function sc(p)
    local s = Instance.new("ScrollingFrame", p)
    s.Size = UDim2.new(1,-8,1,-60)
    s.Position = UDim2.new(0,4,0,56)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 3
    s.ScrollBarImageColor3 = C.accent
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local l = Instance.new("UIListLayout", s)
    l.Padding = UDim.new(0,6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

local CombatP  = page("Combat")
local ExploitP = page("Exploits")
local VisualP  = page("Visuals")
local ColorP   = page("Colors")
local ConfigP  = page("Config")

local CombatS  = sc(CombatP)
local ExploitS = sc(ExploitP)
local VisualS  = sc(VisualP)
local ColorS   = sc(ColorP)

cat("⚔", "Combat", 1)
cat("⚡", "Exploits", 2)
cat("👁", "Visuals", 3)
cat("🎨", "Colors", 4)
cat("⚙", "Config", 5)

local applyRapid, setFly
local isVisible, target

tog(CombatS, "Aimbot", cfg.aim, 1, function(v) cfg.aim=v end)
row(CombatS, "Aim Part", {"Head","Neck","Body"}, cfg.aimPart, 2, function(v) cfg.aimPart = v end)
sld(CombatS, "Regular FOV", 30, 600, cfg.fov, 3, function(v) cfg.fov = v end)
sld(CombatS, "Smooth", 1, 100, cfg.smooth, 4, function(v) cfg.smooth = v end)
tog(CombatS, "Aim Visible", cfg.aimVisible, 5, function(v) cfg.aimVisible=v end)
tog(CombatS, "Silent Aim", cfg.silent, 6, function(v) cfg.silent=v end)
tog(CombatS, "Triggerbot", cfg.trigger, 7, function(v) cfg.trigger=v end)
tog(CombatS, "FOV Circle", cfg.fovCircle, 8, function(v) cfg.fovCircle=v end)

tog(ExploitS, "Fly [WASD+Space]", cfg.fly, 1, function(v) cfg.fly=v; if setFly then setFly(v) end end)
sld(ExploitS, "Fly Speed", 10, 300, cfg.spd, 2, function(v) cfg.spd = v end)
tog(ExploitS, "Speed", cfg.speed, 3, function(v) cfg.speed=v end)
sld(ExploitS, "Speed Value", 0, 30, cfg.speedVal, 4, function(v) cfg.speedVal = v end)
tog(ExploitS, "Godmode", cfg.god, 5, function(v) cfg.god=v end)
tog(ExploitS, "TP to Enemy", false, 6, function(v)
    if v then
        local t = target and target()
        if t then
            local c = LP.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            if hr then hr.CFrame = CFrame.new(t.Position + Vector3.new(0, 3, 0)) end
        end
        task.delay(0.3, function() cfg.tpEnemy = false end)
    end
    cfg.tpEnemy = false
end)
tog(ExploitS, "Rapid Fire", false, 7, function(v) if applyRapid then applyRapid(v) end end)
tog(ExploitS, "Rejoin", false, 8, function(v) if v then TPS:Teleport(game.PlaceId, LP) end end)

tog(VisualS, "ATIVAR ESP", cfg.esp, 1, function(v) cfg.esp=v end)
tog(VisualS, "Box", cfg.box, 2, function(v) cfg.box=v end)
tog(VisualS, "Skeleton", cfg.skel, 3, function(v) cfg.skel=v end)
tog(VisualS, "Name", cfg.name, 4, function(v) cfg.name=v end)
tog(VisualS, "Health", cfg.hp, 5, function(v) cfg.hp=v end)
tog(VisualS, "Distance", cfg.dist, 6, function(v) cfg.dist=v end)

local themeNames = {}
for i, t in ipairs(THEMES) do themeNames[i] = t.name end
row(ColorS, "Theme", themeNames, THEMES[1].name, 1, function(v)
    for i, t in ipairs(THEMES) do
        if t.name == v then
            for k,val in pairs(t) do if k ~= "name" then C[k] = val end end
            Main.BackgroundColor3 = C.bg
            Sidebar.BackgroundColor3 = C.panel
            Float.BackgroundColor3 = C.panel
            Float.TextColor3 = C.accent
            LogoLabel.TextColor3 = C.accent
            fs.Color = C.accent
            ms.Color = C.on
            break
        end
    end
end)

local exitBtn = Instance.new("TextButton", ConfigP)
exitBtn.Size = UDim2.new(1,-36,0,40)
exitBtn.Position = UDim2.new(0,18,0,64)
exitBtn.BackgroundColor3 = Color3.fromRGB(140,45,45)
exitBtn.Text = "Exit"
exitBtn.TextColor3 = Color3.fromRGB(240,220,220)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 13
exitBtn.AutoButtonColor = false
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,6)
exitBtn.MouseButton1Click:Connect(function()
    Float.Visible = false
    Main.Visible = false
end)

sel("Combat")

-- ============================================================
-- ESP (rework)
-- ============================================================

local hasDrawing = pcall(function() return Drawing.new end)
local Cache = {}

local function mkESP(p)
    if p == LP or not hasDrawing then return end
    if Cache[p] then return end
    local d = {}
    d.box  = Drawing.new("Square"); d.box.Thickness=1; d.box.Filled=false; d.box.Visible=false
    d.name = Drawing.new("Text"); d.name.Size=14; d.name.Center=true; d.name.Outline=true; d.name.Visible=false
    d.hp   = Drawing.new("Line"); d.hp.Thickness=2; d.hp.Color=Color3.fromRGB(0,255,100); d.hp.Visible=false
    d.dist = Drawing.new("Text"); d.dist.Size=12; d.dist.Center=true; d.dist.Outline=true; d.dist.Visible=false
    d.skel = {}
    for i = 1, 20 do
        local l = Drawing.new("Line")
        l.Thickness = 1
        l.Color = Color3.fromRGB(230,230,235)
        l.Visible = false
        d.skel[i] = l
    end
    Cache[p] = d
end

local function clearCache(p)
    local d = Cache[p]
    if not d then return end
    Cache[p] = nil
    if d.box  then pcall(function() d.box:Remove()  end) end
    if d.name then pcall(function() d.name:Remove() end) end
    if d.hp   then pcall(function() d.hp:Remove()   end) end
    if d.dist then pcall(function() d.dist:Remove() end) end
    if d.skel then
        for _, l in pairs(d.skel) do pcall(function() l:Remove() end) end
    end
end

local function hide(e)
    e.box.Visible=false e.name.Visible=false e.hp.Visible=false e.dist.Visible=false
    for _, l in pairs(e.skel) do l.Visible=false end
end

for _, p in ipairs(Players:GetPlayers()) do mkESP(p) end
Players.PlayerAdded:Connect(mkESP)
Players.PlayerRemoving:Connect(function(p) clearCache(p) end)

local Fov
if hasDrawing then
    Fov = Drawing.new("Circle")
    Fov.Thickness=1; Fov.Color=Color3.fromRGB(230,230,235)
    Fov.Transparency=0.7; Fov.NumSides=64; Fov.Filled=false; Fov.Visible=false
end

-- cached references, updated once per frame
local playerList = {}
local function rebuildPlayerList()
    playerList = Players:GetPlayers()
end
rebuildPlayerList()
Players.PlayerAdded:Connect(rebuildPlayerList)
Players.PlayerRemoving:Connect(rebuildPlayerList)

local SKEL_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local SKEL_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Left Arm","Left Leg"},
    {"Torso","Right Arm"},{"Right Arm","Right Leg"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

-- project world point, returns screen vec + depth, or nil if behind camera
local function project(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    if not on then return nil end
    if sp.Z <= 0 then return nil end
    return Vector2.new(sp.X, sp.Y), sp.Z
end

local function drawSkel(c, e)
    local bones = c:FindFirstChild("UpperTorso") and SKEL_R15 or SKEL_R6
    for i, l in pairs(e.skel) do l.Visible = false end
    for i, pr in ipairs(bones) do
        local a = c:FindFirstChild(pr[1])
        local b = c:FindFirstChild(pr[2])
        local l = e.skel[i]
        if a and b and l then
            local fa = project(a.Position)
            local tb = project(b.Position)
            if fa and tb then
                l.From = fa
                l.To   = tb
                l.Visible = true
            end
        end
    end
end

-- ============================================================
-- AIM helpers
-- ============================================================

isVisible = function(targetPart)
    if not cfg.aimVisible then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, Camera }
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance == targetPart or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function sameTeam(p)
    if LP.Team ~= nil and p.Team ~= nil then
        return LP.Team == p.Team
    end
    if LP.TeamColor ~= nil and p.TeamColor ~= nil then
        if LP.TeamColor == p.TeamColor then return true end
    end
    local lpA = LP:GetAttribute("Team")
    local pA  = p:GetAttribute("Team")
    if lpA ~= nil and pA ~= nil then
        return lpA == pA
    end
    local lc = LP.Character
    local pc = p.Character
    if lc and pc then
        local lv = lc:FindFirstChild("Team")
        local pv = pc:FindFirstChild("Team")
        if lv and pv and lv:IsA("StringValue") and pv:IsA("StringValue") then
            return lv.Value == pv.Value
        end
    end
    local lpP = LP:FindFirstChild("Team")
    local ppP = p:FindFirstChild("Team")
    if lpP and ppP and lpP:IsA("StringValue") and ppP:IsA("StringValue") then
        return lpP.Value == ppP.Value
    end
    return false
end

local function aimPoint(c)
    if cfg.aimPart == "Head" then
        return c:FindFirstChild("Head")
    elseif cfg.aimPart == "Neck" then
        return c:FindFirstChild("Neck")
            or c:FindFirstChild("UpperTorso")
            or c:FindFirstChild("Torso")
            or c:FindFirstChild("Head")
    else
        return c:FindFirstChild("UpperTorso")
            or c:FindFirstChild("Torso")
            or c:FindFirstChild("LowerTorso")
            or c:FindFirstChild("Head")
    end
end

target = function()
    local best, bd = nil, cfg.fov
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, p in ipairs(playerList) do
        if p ~= LP and p.Parent and not sameTeam(p) then
            local c = p.Character
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            if c and hm and hm.Parent and hm.Health > 0 then
                local part = aimPoint(c)
                if part and part.Parent then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                        if d < bd and isVisible(part) then
                            bd = d
                            best = part
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ============================================================
-- SILENT AIM (metatable hook, robust)
-- ============================================================

local silentHooked = false
local originalNamecall

local function installSilentHook()
    if silentHooked then return true end
    if not (getrawmetatable and setreadonly and hookmetamethod and newcclosure and checkcaller) then
        return false
    end
    local mt = getrawmetatable(game)
    if not mt or not mt.__namecall then return false end
    local old = mt.__namecall
    local ok = pcall(function()
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if cfg.silent and not checkcaller() then
                if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
                   or method == "FindPartOnRayWithWhitelist" or method == "Raycast"
                   or method == "GetMouse" or method == "ViewportPointToRay"
                   or method == "ScreenPointToRay" or method == "GetTarget" then
                    local t = target()
                    if t then
                        if method == "GetTarget" then
                            return t
                        end
                        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList"
                           or method == "FindPartOnRayWithWhitelist" then
                            return t, t.Position, t.Position, t
                        end
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    if not ok then return false end
    originalNamecall = old
    silentHooked = true
    return true
end

-- fallback silencioso: se não der pra hookar, usa o mouse.Target
local silentFallbackActive = false
local function silentFallbackLoop()
    if silentFallbackActive then return end
    silentFallbackActive = true
    RunService.RenderStepped:Connect(function()
        if not cfg.silent then return end
        if silentHooked then return end
        local t = target()
        if t then
            local mouse = LP:GetMouse()
            if mouse then
                pcall(function() mouse.TargetFilter = nil end)
            end
        end
    end)
end

if not installSilentHook() then
    silentFallbackLoop()
end

-- ============================================================
-- RENDER LOOPS
-- ============================================================

RunService.RenderStepped:Connect(function()
    if Fov then
        Fov.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        Fov.Radius = cfg.fov
        Fov.Visible = cfg.fovCircle
    end

    if not cfg.esp or not hasDrawing then
        for _, e in pairs(Cache) do hide(e) end
        return
    end

    -- cleanup players that left
    for p, e in pairs(Cache) do
        if not p or not p.Parent or p == LP then
            hide(e)
            clearCache(p)
        end
    end

    local myHr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    for _, p in ipairs(playerList) do
        if p ~= LP and p.Parent then
            local e = Cache[p]
            if not e then
                mkESP(p)
                e = Cache[p]
            end
            local c  = p.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            local hd = c and c:FindFirstChild("Head")
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            local valid = c and hr and hr.Parent and hd and hd.Parent and hm and hm.Parent and hm.Health > 0
            if e and valid then
                local ok, cf, size = pcall(function() return c:GetBoundingBox() end)
                if ok then
                    local corners = {
                        cf.Position - size/2,
                        cf.Position + size/2,
                    }
                    local p0 = project(corners[1])
                    local p1 = project(corners[2])
                    if p0 and p1 then
                        local x = math.min(p0.X, p1.X)
                        local y = math.min(p0.Y, p1.Y)
                        local w = math.abs(p1.X - p0.X)
                        local h = math.abs(p1.Y - p0.Y)
                        if w > 1 and h > 1 and w < 2000 and h < 2000 then
                            e.box.Size = Vector2.new(w, h)
                            e.box.Position = Vector2.new(x, y)
                            e.box.Color = Color3.fromRGB(230, 230, 235)
                            e.box.Visible = cfg.box

                            e.name.Text = p.Name
                            e.name.Position = Vector2.new(x + w/2, y - 18)
                            e.name.Color = Color3.fromRGB(255, 255, 255)
                            e.name.Visible = cfg.name

                            local hpr = hm.Health / math.max(hm.MaxHealth, 1)
                            e.hp.From = Vector2.new(x - 6, y + h)
                            e.hp.To   = Vector2.new(x - 6, y + h - h*hpr)
                            e.hp.Visible = cfg.hp

                            if cfg.dist and myHr then
                                e.dist.Text = "[" .. math.floor((myHr.Position - hr.Position).Magnitude) .. "]"
                                e.dist.Position = Vector2.new(x + w/2, y + h + 4)
                                e.dist.Color = Color3.fromRGB(255, 255, 255)
                                e.dist.Visible = true
                            else
                                e.dist.Visible = false
                            end

                            if cfg.skel then
                                drawSkel(c, e)
                            else
                                for _, l in pairs(e.skel) do l.Visible = false end
                            end
                        else
                            hide(e)
                        end
                    else
                        hide(e)
                    end
                else
                    hide(e)
                end
            elseif e then
                hide(e)
            end
        end
    end
end)

-- ============================================================
-- AIMBOT loop
-- ============================================================

RunService.RenderStepped:Connect(function()
    if not cfg.aim then return end
    local t = target()
    if t then
        local sm = 1 - (cfg.smooth/100)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), sm)
    end
end)

-- ============================================================
-- TRIGGERBOT
-- ============================================================

RunService.RenderStepped:Connect(function()
    if not cfg.trigger then return end
    local t = target()
    if t and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local d = (LP.Character.HumanoidRootPart.Position - t.Position).Magnitude
        if d < 100 then pcall(function() mouse1click() end) end
    end
end)

-- ============================================================
-- RAPID FIRE
-- ============================================================

local rapidConn
function applyRapid(state)
    if rapidConn then rapidConn:Disconnect() rapidConn = nil end
    if not state then return end
    rapidConn = RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if not c then return end
        for _, tool in ipairs(c:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    if tool:FindFirstChild("FireRate") then tool.FireRate.Value = 0.01 end
                    if tool:FindFirstChild("FireRate2") then tool.FireRate2.Value = 0.01 end
                    if tool:FindFirstChild("Settings") and tool.Settings:FindFirstChild("FireRate") then
                        tool.Settings.FireRate.Value = 0.01
                    end
                end)
            end
        end
    end)
end

-- ============================================================
-- GOD / FLY / SPEED
-- ============================================================

local function applyGod()
    local c = LP.Character
    if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid")
    if hm then
        hm.MaxHealth = math.huge
        hm.Health = math.huge
        if not hm:GetAttribute("EvilGod") then
            hm:SetAttribute("EvilGod", true)
            hm.HealthChanged:Connect(function(v)
                if cfg.god and v < math.huge then hm.Health = math.huge end
            end)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if cfg.god then applyGod() end
end)

function setFly(s)
    local c = LP.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    if s then
        if not _G.EvilBV then
            _G.EvilBV = Instance.new("BodyVelocity", h)
            _G.EvilBV.MaxForce = Vector3.new(1e5,1e5,1e5)
            _G.EvilBV.Velocity = Vector3.zero
            _G.EvilBG = Instance.new("BodyGyro", h)
            _G.EvilBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
            _G.EvilBG.P = 1000
            _G.EvilBG.D = 50
        end
    else
        if _G.EvilBV then _G.EvilBV:Destroy() _G.EvilBV=nil end
        if _G.EvilBG then _G.EvilBG:Destroy() _G.EvilBG=nil end
    end
end

RunService.RenderStepped:Connect(function()
    if not cfg.fly or not _G.EvilBV then return end
    local mv = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - Camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + Camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
    if mv.Magnitude > 0 then mv = mv.Unit * cfg.spd end
    _G.EvilBV.Velocity = mv
    _G.EvilBG.CFrame = Camera.CFrame
end)

local function applySpeed()
    local c = LP.Character
    if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hm then return end
    if not hm:GetAttribute("EvilBaseSpeed") then
        hm:SetAttribute("EvilBaseSpeed", hm.WalkSpeed)
    end
    local base = hm:GetAttribute("EvilBaseSpeed") or 16
    if cfg.speed then
        hm.WalkSpeed = base + cfg.speedVal
    else
        hm.WalkSpeed = base
    end
end

RunService.Heartbeat:Connect(function()
    if cfg.speed or cfg.speedVal > 0 then applySpeed() end
end)

LP.CharacterAdded:Connect(function()
    if cfg.fly then setFly(true) end
    if cfg.god then applyGod() end
end)
