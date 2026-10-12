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

-- paleta Kavo
local C = {
    bg     = Color3.fromRGB(20,20,20),
    panel  = Color3.fromRGB(14,14,14),
    card   = Color3.fromRGB(30,30,30),
    cardHd = Color3.fromRGB(34,34,34),
    track  = Color3.fromRGB(55,55,55),
    fill   = Color3.fromRGB(200,200,200),
    txt    = Color3.fromRGB(220,220,220),
    dim    = Color3.fromRGB(110,110,110),
    accent = Color3.fromRGB(200,200,200),
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

local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0,44,0,44)
Float.Position = UDim2.new(0,30,0,120)
Float.BackgroundColor3 = C.panel
Float.Text = ""
Float.AutoButtonColor = false
Float.Parent = gui
Instance.new("UICorner", Float).CornerRadius = UDim.new(0,6)
local fs = Instance.new("UIStroke", Float)
fs.Color = C.card
fs.Thickness = 1
local fl = Instance.new("TextLabel", Float)
fl.Size = UDim2.new(1,0,1,0)
fl.BackgroundTransparency = 1
fl.Text = "✦"
fl.TextColor3 = C.txt
fl.Font = Enum.Font.GothamBold
fl.TextSize = 20

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,760,0,460)
Main.Position = UDim2.new(0,100,0,80)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.card
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

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,60,1,0)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,8)

local CatFrame = Instance.new("Frame", Sidebar)
CatFrame.Size = UDim2.new(1,0,0,400)
CatFrame.Position = UDim2.new(0,0,0,20)
CatFrame.BackgroundTransparency = 1
local cl = Instance.new("UIListLayout", CatFrame)
cl.Padding = UDim.new(0,6)
cl.SortOrder = Enum.SortOrder.LayoutOrder
cl.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ÁREA DE CONTEÚDO
local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1,-60,1,0)
Pages.Position = UDim2.new(0,60,0,0)
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
        if k == n then
            b.BackgroundColor3 = C.card
            b.TextColor3 = C.txt
        else
            b.BackgroundColor3 = C.panel
            b.TextColor3 = C.dim
        end
    end
end

local function cat(icon, n, o)
    local b = Instance.new("TextButton", CatFrame)
    b.Size = UDim2.new(0,40,0,40)
    b.BackgroundColor3 = C.panel
    b.Text = icon
    b.TextColor3 = C.dim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    b.AutoButtonColor = false
    b.LayoutOrder = o
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(function() sel(n) end)
    CB[n] = b
    return b
end

-- COMPONENTES KAVO
local function card(parent, title, order)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1,-12,0,0)
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = C.card
    c.BorderSizePixel = 0
    c.LayoutOrder = order or 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,6)

    local hd = Instance.new("Frame", c)
    hd.Size = UDim2.new(1,0,0,28)
    hd.BackgroundColor3 = C.cardHd
    hd.BorderSizePixel = 0
    Instance.new("UICorner", hd).CornerRadius = UDim.new(0,6)

    local hl = Instance.new("TextLabel", hd)
    hl.Size = UDim2.new(1,-16,1,0)
    hl.Position = UDim2.new(0,12,0,0)
    hl.BackgroundTransparency = 1
    hl.Text = title
    hl.TextColor3 = C.txt
    hl.Font = Enum.Font.GothamBold
    hl.TextSize = 13
    hl.TextXAlignment = Enum.TextXAlignment.Left

    local body = Instance.new("Frame", c)
    body.Size = UDim2.new(1,0,0,0)
    body.Position = UDim2.new(0,0,0,28)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1
    local lay = Instance.new("UIListLayout", body)
    lay.Padding = UDim.new(0,2)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", body)
    pad.PaddingTop = UDim.new(0,4)
    pad.PaddingBottom = UDim.new(0,6)
    pad.PaddingLeft = UDim.new(0,4)
    pad.PaddingRight = UDim.new(0,4)

    return body
end

local function tog(parent, label, def, order, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,28)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0

    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1,-40,1,0)
    l.Position = UDim2.new(0,8,0,0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.txt
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left

    local sw = Instance.new("Frame", b)
    sw.Size = UDim2.new(0,28,0,14)
    sw.Position = UDim2.new(1,-36,0.5,-7)
    sw.BackgroundColor3 = def and C.fill or C.track
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)

    local dot = Instance.new("Frame", sw)
    dot.Size = UDim2.new(0,10,0,10)
    dot.Position = def and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)
    dot.BackgroundColor3 = C.bg
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local s = def
    b.MouseButton1Click:Connect(function()
        s = not s
        sw.BackgroundColor3 = s and C.fill or C.track
        dot.Position = s and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)
        cb(s)
    end)
end

local function sld(parent, label, mn, mx, def, order, cb)
    local h = Instance.new("Frame", parent)
    h.Size = UDim2.new(1,0,0,44)
    h.BackgroundTransparency = 1
    h.LayoutOrder = order or 0

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-40,0,14)
    lb.Position = UDim2.new(0,8,0,0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", h)
    val.Size = UDim2.new(0,50,0,14)
    val.Position = UDim2.new(1,-58,0,0)
    val.BackgroundTransparency = 1
    val.Text = tostring(def)
    val.TextColor3 = C.txt
    val.Font = Enum.Font.Gotham
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1,-16,0,3)
    bar.Position = UDim2.new(0,8,0,32)
    bar.BackgroundColor3 = C.track
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = C.fill
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

local function text(parent, label, value, order)
    local h = Instance.new("Frame", parent)
    h.Size = UDim2.new(1,0,0,28)
    h.BackgroundTransparency = 1
    h.LayoutOrder = order or 0

    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1,-80,1,0)
    lb.Position = UDim2.new(0,8,0,0)
    lb.BackgroundTransparency = 1
    lb.Text = label
    lb.TextColor3 = C.txt
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", h)
    vl.Size = UDim2.new(0,72,1,0)
    vl.Position = UDim2.new(1,-80,0,0)
    vl.BackgroundTransparency = 1
    vl.Text = value
    vl.TextColor3 = C.dim
    vl.Font = Enum.Font.Gotham
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
end

local function btn(parent, label, order, cb, danger)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = danger and Color3.fromRGB(120,40,40) or C.cardHd
    b.Text = label
    b.TextColor3 = C.txt
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.AutoButtonColor = false
    b.LayoutOrder = order or 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- colunas paralelas para uma página
local function columns(p)
    local holder = Instance.new("Frame", p)
    holder.Size = UDim2.new(1,-16,1,-16)
    holder.Position = UDim2.new(0,8,0,8)
    holder.BackgroundTransparency = 1
    local grid = Instance.new("UIGridLayout", holder)
    grid.CellSize = UDim2.new(0.333,-6,0,0)
    grid.CellPadding = UDim2.new(0,8,0,8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder

    local cols = {}
    for i = 1, 3 do
        local c = Instance.new("ScrollingFrame", holder)
        c.Size = UDim2.new(0,100,0,100)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ScrollBarThickness = 2
        c.ScrollBarImageColor3 = C.dim
        c.CanvasSize = UDim2.new(0,0,0,0)
        c.AutomaticCanvasSize = Enum.AutomaticSize.Y
        c.LayoutOrder = i
        local lay = Instance.new("UIListLayout", c)
        lay.Padding = UDim.new(0,8)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        cols[i] = c
    end
    return cols[1], cols[2], cols[3]
end

-- coluna única
local function single(p)
    local s = Instance.new("ScrollingFrame", p)
    s.Size = UDim2.new(1,-16,1,-16)
    s.Position = UDim2.new(0,8,0,8)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 2
    s.ScrollBarImageColor3 = C.dim
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local lay = Instance.new("UIListLayout", s)
    lay.Padding = UDim.new(0,8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    return s
end

local CombatP  = page("Combat")
local ExploitP = page("Exploits")
local VisualP  = page("Visuals")
local ColorP   = page("Colors")
local ConfigP  = page("Config")

cat("🎯", "Combat", 1)
cat("⚡", "Exploits", 2)
cat("👁", "Visuals", 3)
cat("🎨", "Colors", 4)
cat("⚙", "Config", 5)

local applyRapid, setFly
local isVisible, target

-- COMBAT: 3 colunas
local CC1, CC2, CC3 = columns(CombatP)

local cAim = card(CC1, "Aimbot", 1)
tog(cAim, "Show", cfg.aim, 1, function(v) cfg.aim=v end)
tog(cAim, "Show Fov", cfg.fovCircle, 2, function(v) cfg.fovCircle=v end)
text(cAim, "Fov Color", "Default", 3)
tog(cAim, "Visible Check", cfg.aimVisible, 4, function(v) cfg.aimVisible=v end)
tog(cAim, "Ignore NPCs", false, 5, function(v) end)
text(cAim, "KeyBind", "None", 6)
sld(cAim, "Fov Size", 30, 600, cfg.fov, 7, function(v) cfg.fov=v end)
sld(cAim, "Smoothing", 1, 100, cfg.smooth, 8, function(v) cfg.smooth=v end)
sld(cAim, "Max Distance", 50, 1000, 240, 9, function(v) end)

local cTrig = card(CC2, "Trigger", 1)
tog(cTrig, "Show", cfg.trigger, 1, function(v) cfg.trigger=v end)
tog(cTrig, "Show Fov", false, 2, function(v) end)
tog(cTrig, "Smart Triggerbot", false, 3, function(v) end)
tog(cTrig, "Visible Check", cfg.aimVisible, 4, function(v) cfg.aimVisible=v end)
tog(cTrig, "Ignore NPCs", false, 5, function(v) end)
text(cTrig, "KeyBind", "None", 6)
sld(cTrig, "Fov Size", 10, 300, 20, 7, function(v) end)
sld(cTrig, "Max Distance", 50, 1000, 200, 8, function(v) end)
sld(cTrig, "Delay", 0, 500, 0, 9, function(v) end)

local cSil = card(CC3, "Silent", 1)
tog(cSil, "Show", cfg.silent, 1, function(v) cfg.silent=v end)
tog(cSil, "Show Fov", false, 2, function(v) end)
tog(cSil, "Magic Bullets", false, 3, function(v) end)
tog(cSil, "Visible Check", cfg.aimVisible, 4, function(v) cfg.aimVisible=v end)
tog(cSil, "Ignore NPCs", false, 5, function(v) end)
text(cSil, "KeyBind", "None", 6)
sld(cSil, "Fov Size", 30, 600, 40, 7, function(v) end)
sld(cSil, "Miss Chance", 0, 100, 0, 8, function(v) end)
sld(cSil, "Max Distance", 50, 1000, 200, 9, function(v) end)

-- EXPLOITS: coluna única
local ES = single(ExploitP)
local cMove = card(ES, "Movement", 1)
tog(cMove, "Fly [WASD+Space]", cfg.fly, 1, function(v) cfg.fly=v; if setFly then setFly(v) end end)
sld(cMove, "Fly Speed", 10, 300, cfg.spd, 2, function(v) cfg.spd=v end)
tog(cMove, "Speed", cfg.speed, 3, function(v) cfg.speed=v end)
sld(cMove, "Speed Value", 0, 30, cfg.speedVal, 4, function(v) cfg.speedVal=v end)

local cCombat2 = card(ES, "Combat", 2)
tog(cCombat2, "Godmode", cfg.god, 1, function(v) cfg.god=v end)
tog(cCombat2, "Rapid Fire", false, 2, function(v) if applyRapid then applyRapid(v) end end)

local cTele = card(ES, "Teleport", 3)
tog(cTele, "TP to Enemy", false, 1, function(v)
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
btn(cTele, "Rejoin", 2, function() TPS:Teleport(game.PlaceId, LP) end)

-- VISUALS
local VS = single(VisualP)
local cVis = card(VS, "ESP", 1)
tog(cVis, "ATIVAR ESP", cfg.esp, 1, function(v) cfg.esp=v end)
tog(cVis, "Box", cfg.box, 2, function(v) cfg.box=v end)
tog(cVis, "Skeleton", cfg.skel, 3, function(v) cfg.skel=v end)
tog(cVis, "Name", cfg.name, 4, function(v) cfg.name=v end)
tog(cVis, "Health", cfg.hp, 5, function(v) cfg.hp=v end)
tog(cVis, "Distance", cfg.dist, 6, function(v) cfg.dist=v end)

-- COLORS
local CS = single(ColorP)
local cCol = card(CS, "Theme", 1)
local themes = {"Preto", "Verde", "Branco", "Roxo", "Vermelho", "Azul"}
local THEME_DATA = {
    Preto    = { bg=Color3.fromRGB(20,20,20), panel=Color3.fromRGB(14,14,14), card=Color3.fromRGB(30,30,30), cardHd=Color3.fromRGB(34,34,34), track=Color3.fromRGB(55,55,55), fill=Color3.fromRGB(200,200,200), txt=Color3.fromRGB(220,220,220), dim=Color3.fromRGB(110,110,110) },
    Verde    = { bg=Color3.fromRGB(14,22,16), panel=Color3.fromRGB(10,16,12), card=Color3.fromRGB(20,34,24), cardHd=Color3.fromRGB(24,40,28), track=Color3.fromRGB(40,70,50), fill=Color3.fromRGB(100,220,140), txt=Color3.fromRGB(220,240,225), dim=Color3.fromRGB(120,170,140) },
    Branco   = { bg=Color3.fromRGB(230,230,230), panel=Color3.fromRGB(215,215,215), card=Color3.fromRGB(245,245,245), cardHd=Color3.fromRGB(235,235,235), track=Color3.fromRGB(190,190,190), fill=Color3.fromRGB(80,80,80), txt=Color3.fromRGB(30,30,30), dim=Color3.fromRGB(120,120,120) },
    Roxo     = { bg=Color3.fromRGB(18,12,26), panel=Color3.fromRGB(12,8,18), card=Color3.fromRGB(28,18,42), cardHd=Color3.fromRGB(34,22,50), track=Color3.fromRGB(70,45,110), fill=Color3.fromRGB(180,120,230), txt=Color3.fromRGB(230,220,240), dim=Color3.fromRGB(140,120,170) },
    Vermelho = { bg=Color3.fromRGB(24,12,12), panel=Color3.fromRGB(16,8,8), card=Color3.fromRGB(38,18,18), cardHd=Color3.fromRGB(46,22,22), track=Color3.fromRGB(90,40,40), fill=Color3.fromRGB(220,100,100), txt=Color3.fromRGB(240,220,220), dim=Color3.fromRGB(170,120,120) },
    Azul     = { bg=Color3.fromRGB(12,16,24), panel=Color3.fromRGB(8,12,18), card=Color3.fromRGB(18,28,44), cardHd=Color3.fromRGB(22,34,52), track=Color3.fromRGB(40,70,120), fill=Color3.fromRGB(100,170,240), txt=Color3.fromRGB(220,228,240), dim=Color3.fromRGB(120,145,185) },
}
for i, name in ipairs(themes) do
    btn(cCol, name, i, function()
        local t = THEME_DATA[name]
        for k,v in pairs(t) do C[k] = v end
        Main.BackgroundColor3 = C.bg
        Sidebar.BackgroundColor3 = C.panel
        Float.BackgroundColor3 = C.panel
        ms.Color = C.card
        fs.Color = C.card
        -- reaplica nas linhas conhecidas
        for _, el in ipairs(Main:GetDescendants()) do
            if el:IsA("Frame") and el.Name == "" then
                if el.Parent and el.Parent:IsA("Frame") and el.Parent.Name == "" then end
            end
        end
    end)
end

-- CONFIG
local CfS = single(ConfigP)
local cExit = card(CfS, "Config", 1)
btn(cExit, "Exit", 1, function()
    Float.Visible = false
    Main.Visible = false
end, true)

sel("Combat")

-- ============ resto das funções (iguais) ============
local hasDrawing = pcall(function() return Drawing.new end)
local Cache = {}

local function clearCache(p)
    local d = Cache[p]
    if not d then return end
    Cache[p] = nil
    if d.box then pcall(function() d.box:Remove() end) end
    if d.name then pcall(function() d.name:Remove() end) end
    if d.hp then pcall(function() d.hp:Remove() end) end
    if d.dist then pcall(function() d.dist:Remove() end) end
    if d.skel then for _, l in pairs(d.skel) do pcall(function() l:Remove() end) end end
end

local function mkESP(p)
    if p == LP or not hasDrawing then return end
    if Cache[p] then return end
    if not p.Parent then return end
    local d = {}
    d.box  = Drawing.new("Square"); d.box.Thickness=1; d.box.Filled=false; d.box.Visible=false
    d.name = Drawing.new("Text"); d.name.Size=14; d.name.Center=true; d.name.Outline=true; d.name.Visible=false
    d.hp   = Drawing.new("Line"); d.hp.Thickness=2; d.hp.Color=Color3.fromRGB(0,255,100); d.hp.Visible=false
    d.dist = Drawing.new("Text"); d.dist.Size=12; d.dist.Center=true; d.dist.Outline=true; d.dist.Visible=false
    d.skel = {}
    for i = 1, 20 do
        local l = Drawing.new("Line"); l.Thickness=1; l.Color=Color3.fromRGB(230,230,235); l.Visible=false
        d.skel[i] = l
    end
    Cache[p] = d
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

local function w2v(p)
    local s = Camera:WorldToViewportPoint(p)
    return Vector2.new(s.X, s.Y)
end

local function hide(e)
    e.box.Visible=false e.name.Visible=false e.hp.Visible=false e.dist.Visible=false
    for _, l in pairs(e.skel) do l.Visible=false end
end

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

local function drawSkel(c, e)
    local isR15 = c:FindFirstChild("UpperTorso") ~= nil
    local bones = isR15 and SKEL_R15 or SKEL_R6
    for i, l in pairs(e.skel) do l.Visible = false end
    for i, pr in ipairs(bones) do
        local a = c:FindFirstChild(pr[1])
        local b = c:FindFirstChild(pr[2])
        local l = e.skel[i]
        if a and b and l then
            l.From = w2v(a.Position)
            l.To   = w2v(b.Position)
            l.Visible = true
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Fov then
        Fov.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        Fov.Radius = cfg.fov
        Fov.Visible = cfg.fovCircle
    end
    for p, e in pairs(Cache) do
        if not p or not p.Parent or p == LP then
            hide(e)
            task.spawn(function() clearCache(p) end)
        else
            local c = p.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            local hd = c and c:FindFirstChild("Head")
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            local valid = c and hr and hr.Parent and hd and hd.Parent and hm and hm.Parent and hm.Health > 0
            if not cfg.esp or not valid then
                hide(e)
            else
                local ok, cf, size = pcall(function() return c:GetBoundingBox() end)
                if ok then
                    local p0 = w2v(cf.Position - size/2)
                    local p1 = w2v(cf.Position + size/2)
                    local x,y = math.min(p0.X,p1.X), math.min(p0.Y,p1.Y)
                    local w,h = math.abs(p1.X-p0.X), math.abs(p1.Y-p0.Y)
                    if w > 0 and h > 0 and w < 2000 and h < 2000 then
                        e.box.Size = Vector2.new(w,h); e.box.Position = Vector2.new(x,y)
                        e.box.Color = Color3.fromRGB(230,230,235); e.box.Visible = cfg.box
                        e.name.Text = p.Name; e.name.Position = Vector2.new(x+w/2, y-18)
                        e.name.Color = Color3.fromRGB(255,255,255); e.name.Visible = cfg.name
                        local hpr = hm.Health / math.max(hm.MaxHealth,1)
                        e.hp.From = Vector2.new(x-6, y+h); e.hp.To = Vector2.new(x-6, y+h-h*hpr); e.hp.Visible = cfg.hp
                        if cfg.dist then
                            local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if mr and mr.Parent then
                                e.dist.Text = "["..math.floor((mr.Position-hr.Position).Magnitude).."]"
                                e.dist.Position = Vector2.new(x+w/2, y+h+4)
                                e.dist.Color = Color3.fromRGB(255,255,255); e.dist.Visible = true
                            end
                        else e.dist.Visible = false end
                        if cfg.skel then drawSkel(c, e) else for _, l in pairs(e.skel) do l.Visible=false end end
                    else hide(e) end
                else hide(e) end
            end
        end
    end
end)

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
    if LP.Team ~= nil and p.Team ~= nil then return LP.Team == p.Team end
    if LP.TeamColor ~= nil and p.TeamColor ~= nil and LP.TeamColor == p.TeamColor then return true end
    local lpA, pA = LP:GetAttribute("Team"), p:GetAttribute("Team")
    if lpA ~= nil and pA ~= nil then return lpA == pA end
    local lc, pc = LP.Character, p.Character
    if lc and pc then
        local lv, pv = lc:FindFirstChild("Team"), pc:FindFirstChild("Team")
        if lv and pv and lv:IsA("StringValue") and pv:IsA("StringValue") then return lv.Value == pv.Value end
    end
    local lpP, ppP = LP:FindFirstChild("Team"), p:FindFirstChild("Team")
    if lpP and ppP and lpP:IsA("StringValue") and ppP:IsA("StringValue") then return lpP.Value == ppP.Value end
    return false
end

local function aimPoint(c)
    if cfg.aimPart == "Head" then return c:FindFirstChild("Head")
    elseif cfg.aimPart == "Neck" then return c:FindFirstChild("Neck") or c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("Head")
    else return c:FindFirstChild("UpperTorso") or c:FindFirstChild("Torso") or c:FindFirstChild("LowerTorso") or c:FindFirstChild("Head") end
end

target = function()
    local best, bd = nil, cfg.fov
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Parent and not sameTeam(p) then
            local c = p.Character
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            if c and hm and hm.Parent and hm.Health > 0 then
                local part = aimPoint(c)
                if part and part.Parent then
                    local sp, on = Camera:WorldToViewportPoint(part.Position)
                    if on then
                        local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                        if d < bd and isVisible(part) then bd = d; best = part end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not cfg.aim then return end
    local t = target()
    if t then
        local sm = 1 - (cfg.smooth/100)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), sm)
    end
end)

do
    if hookmetamethod and getrawmetatable and checkcaller and newcclosure then
        pcall(function()
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if cfg.silent and not checkcaller() then
                    if self == LP:GetMouse() then
                        if method == "get_Hit" or method == "Hit" then
                            local t = target(); if t then return CFrame.new(t.Position) end
                        elseif method == "get_Target" or method == "Target" then
                            local t = target(); if t then return t end
                        end
                    elseif self == Camera then
                        if method == "ViewportPointToRay" or method == "ScreenPointToRay" then
                            local t = target()
                            if t then
                                return oldNamecall(self, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
                            end
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not cfg.trigger then return end
    local t = target()
    if t and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local d = (LP.Character.HumanoidRootPart.Position - t.Position).Magnitude
        if d < 100 then pcall(function() mouse1click() end) end
    end
end)

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

RunService.Heartbeat:Connect(function() if cfg.god then applyGod() end end)

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
    if cfg.speed then hm.WalkSpeed = base + cfg.speedVal else hm.WalkSpeed = base end
end

RunService.Heartbeat:Connect(function()
    if cfg.speed or cfg.speedVal > 0 then applySpeed() end
end)

LP.CharacterAdded:Connect(function()
    if cfg.fly then setFly(true) end
    if cfg.god then applyGod() end
end)
