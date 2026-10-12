local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local cfg = {
    esp = false, box = true, skel = true, name = true, hp = true, dist = true, line = false,
    aim = false, aimKey = Enum.KeyCode.E, aimKeyIsMouse = false, aimMouseBtn = 1,
    silent = false, trigger = false, rapidFire = false,
    fovCircle = false, god = false,
    fly = false, spd = 60,
    fov = 150, smooth = 30,
}

if CoreGui:FindFirstChild("EvilUI") then CoreGui.EvilUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EvilUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
--  Flutuante
-- ============================================================
local Float = Instance.new("TextButton")
Float.Size = UDim2.new(0, 64, 0, 64)
Float.Position = UDim2.new(0, 30, 0, 120)
Float.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Float.Text = ""
Float.AutoButtonColor = false
Float.Active = true
Float.Parent = ScreenGui
Instance.new("UICorner", Float).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", Float)
FloatStroke.Color = Color3.fromRGB(180, 180, 185)
FloatStroke.Thickness = 2

local FloatIcon = Instance.new("TextLabel", Float)
FloatIcon.Size = UDim2.new(1, 0, 1, 0)
FloatIcon.BackgroundTransparency = 1
FloatIcon.Text = "E"
FloatIcon.TextColor3 = Color3.fromRGB(230, 230, 235)
FloatIcon.Font = Enum.Font.GothamBold
FloatIcon.TextSize = 26

-- ============================================================
--  Menu
-- ============================================================
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 780, 0, 480)
Main.Position = UDim2.new(0, 100, 0, 80)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(50, 50, 55)
MainStroke.Thickness = 1

do
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.AbsolutePosition
        end
    end)
    Main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

do
    local dragging, dragStart, startPos, moved
    Float.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = Float.AbsolutePosition
        end
    end)
    Float.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then moved = true end
            Float.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then Main.Visible = not Main.Visible end
            dragging = false
        end
    end)
end

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local LogoBox = Instance.new("Frame", Sidebar)
LogoBox.Size = UDim2.new(0, 80, 0, 80)
LogoBox.Position = UDim2.new(0.5, -40, 0, 15)
LogoBox.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
LogoBox.BorderSizePixel = 0
Instance.new("UICorner", LogoBox).CornerRadius = UDim.new(1, 0)

local LogoIcon = Instance.new("TextLabel", LogoBox)
LogoIcon.Size = UDim2.new(1, 0, 1, 0)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "E"
LogoIcon.TextColor3 = Color3.fromRGB(230, 230, 235)
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.TextSize = 44

local CatFrame = Instance.new("Frame", Sidebar)
CatFrame.Size = UDim2.new(1, -16, 1, -120)
CatFrame.Position = UDim2.new(0, 8, 0, 105)
CatFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", CatFrame).Padding = UDim.new(0, 4)

local Pages = Instance.new("Frame", Main)
Pages.Size = UDim2.new(1, -150, 1, 0)
Pages.Position = UDim2.new(0, 150, 0, 0)
Pages.BackgroundTransparency = 1

local PageMap = {}
local function makePage(name)
    local pg = Instance.new("Frame", Pages)
    pg.Size = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.Visible = false
    PageMap[name] = pg
    return pg
end

local function makeCat(name)
    local b = Instance.new("TextButton", CatFrame)
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(200, 200, 210)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        for k, v in pairs(PageMap) do v.Visible = (k == name) end
        for _, c in ipairs(CatFrame:GetChildren()) do
            if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(28, 28, 32) end
        end
        b.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
    end)
    return b
end

-- Componentes
local function toggleBtn(parent, label, default, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -16, 0, 32)
    b.BackgroundColor3 = default and Color3.fromRGB(70, 70, 78) or Color3.fromRGB(30, 30, 34)
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -60, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1; l.Text = label
    l.TextColor3 = Color3.fromRGB(220, 220, 225); l.Font = Enum.Font.Gotham
    l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
    local s = Instance.new("TextLabel", b)
    s.Size = UDim2.new(0, 44, 1, 0); s.Position = UDim2.new(1, -50, 0, 0)
    s.BackgroundTransparency = 1
    s.Text = default and "ON" or "OFF"
    s.TextColor3 = default and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(120, 120, 130)
    s.Font = Enum.Font.GothamBold; s.TextSize = 12
    local st = default
    b.MouseButton1Click:Connect(function()
        st = not st
        b.BackgroundColor3 = st and Color3.fromRGB(70, 70, 78) or Color3.fromRGB(30, 30, 34)
        s.Text = st and "ON" or "OFF"
        s.TextColor3 = st and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(120, 120, 130)
        cb(st)
    end)
end

local function slider(parent, label, mn, mx, d, cb)
    local h = Instance.new("Frame", parent)
    h.Size = UDim2.new(1, -16, 0, 46)
    h.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 6)
    local lb = Instance.new("TextLabel", h)
    lb.Size = UDim2.new(1, -20, 0, 18); lb.Position = UDim2.new(0, 12, 0, 2)
    lb.BackgroundTransparency = 1; lb.Text = label .. ": " .. d
    lb.TextColor3 = Color3.fromRGB(220, 220, 225); lb.Font = Enum.Font.Gotham
    lb.TextSize = 12; lb.TextXAlignment = Enum.TextXAlignment.Left
    local bar = Instance.new("Frame", h)
    bar.Size = UDim2.new(1, -24, 0, 6); bar.Position = UDim2.new(0, 12, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((d - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 180, 185)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dr = false
    local function upd(i)
        local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(mn + (mx - mn) * p)
        fill.Size = UDim2.new(p, 0, 1, 0)
        lb.Text = label .. ": " .. v
        cb(v)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = true; upd(i) end
    end)
    bar.InputChanged:Connect(function(i)
        if dr and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dr = false end
    end)
end

-- Keybind que aceita teclado E mouse
local function keybindBtn(parent, label, getKeyFn, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -16, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    b.Text = ""
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", b)
    l.Size = UDim2.new(1, -100, 1, 0); l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1; l.Text = label
    l.TextColor3 = Color3.fromRGB(220, 220, 225); l.Font = Enum.Font.Gotham
    l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
    local k = Instance.new("TextLabel", b)
    k.Size = UDim2.new(0, 88, 1, 0); k.Position = UDim2.new(1, -94, 0, 0)
    k.BackgroundTransparency = 1
    k.Text = getKeyFn()
    k.TextColor3 = Color3.fromRGB(240, 240, 245); k.Font = Enum.Font.GothamBold; k.TextSize = 12
    local waiting = false
    b.MouseButton1Click:Connect(function()
        waiting = true
        k.Text = "[...]"
        k.TextColor3 = Color3.fromRGB(255, 200, 100)
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not waiting or gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            k.Text = input.KeyCode.Name
            k.TextColor3 = Color3.fromRGB(240, 240, 245)
            waiting = false
            cb("keyboard", input.KeyCode)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            k.Text = "MB1"
            k.TextColor3 = Color3.fromRGB(240, 240, 245)
            waiting = false
            cb("mouse", 1)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            k.Text = "MB2"
            k.TextColor3 = Color3.fromRGB(240, 240, 245)
            waiting = false
            cb("mouse", 2)
        end
    end)
end

-- Páginas
local AimPage = makePage("AIM")
local VisPage = makePage("VISUALS")
local MiscPage = makePage("MISC")
local PlayerPage = makePage("PLAYER")

local function makeTitle(page, text)
    local t = Instance.new("TextLabel", page)
    t.Size = UDim2.new(1, 0, 0, 36)
    t.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    t.Text = text
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold; t.TextSize = 16
end

makeTitle(AimPage, "AIM")
makeTitle(VisPage, "VISUALS")
makeTitle(MiscPage, "MISC")
makeTitle(PlayerPage, "PLAYER")

local function makeScroll(page)
    local sc = Instance.new("ScrollingFrame", page)
    sc.Size = UDim2.new(1, -16, 1, -50)
    sc.Position = UDim2.new(0, 8, 0, 44)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", sc).Padding = UDim.new(0, 6)
    return sc
end

local AimScroll = makeScroll(AimPage)
local VisScroll = makeScroll(VisPage)
local MiscScroll = makeScroll(MiscPage)
local PlayerScroll = makeScroll(PlayerPage)

toggleBtn(AimScroll, "Aimbot", cfg.aim, function(v) cfg.aim = v end)
keybindBtn(AimScroll, "Aimbot Key", function()
    if cfg.aimKeyIsMouse then
        return cfg.aimMouseBtn == 1 and "MB1" or "MB2"
    else
        return cfg.aimKey.Name
    end
end, function(kind, val)
    if kind == "mouse" then
        cfg.aimKeyIsMouse = true
        cfg.aimMouseBtn = val
    else
        cfg.aimKeyIsMouse = false
        cfg.aimKey = val
    end
end)
toggleBtn(AimScroll, "Silent Aim", cfg.silent, function(v) cfg.silent = v end)
toggleBtn(AimScroll, "Triggerbot", cfg.trigger, function(v) cfg.trigger = v end)
toggleBtn(AimScroll, "FOV Circle", cfg.fovCircle, function(v) cfg.fovCircle = v end)
slider(AimScroll, "FOV", 30, 600, cfg.fov, function(v) cfg.fov = v end)
slider(AimScroll, "Smooth", 1, 100, cfg.smooth, function(v) cfg.smooth = v end)

toggleBtn(VisScroll, "ESP", cfg.esp, function(v) cfg.esp = v end)
toggleBtn(VisScroll, "Box", cfg.box, function(v) cfg.box = v end)
toggleBtn(VisScroll, "Skeleton", cfg.skel, function(v) cfg.skel = v end)
toggleBtn(VisScroll, "Name", cfg.name, function(v) cfg.name = v end)
toggleBtn(VisScroll, "Health", cfg.hp, function(v) cfg.hp = v end)
toggleBtn(VisScroll, "Distance", cfg.dist, function(v) cfg.dist = v end)
toggleBtn(VisScroll, "Line", cfg.line, function(v) cfg.line = v end)

toggleBtn(PlayerScroll, "Godmode", cfg.god, function(v) cfg.god = v end)
toggleBtn(PlayerScroll, "Fly", cfg.fly, function(v) cfg.fly = v; setFly(v) end)
slider(PlayerScroll, "Fly Speed", 10, 300, cfg.spd, function(v) cfg.spd = v end)

toggleBtn(MiscScroll, "Rapid Fire", cfg.rapidFire, function(v) cfg.rapidFire = v end)
toggleBtn(MiscScroll, "Rejoin", false, function(v)
    if v then game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end
end)

for k, v in pairs(PageMap) do v.Visible = (k == "AIM") end
for _, c in ipairs(CatFrame:GetChildren()) do
    if c:IsA("TextButton") and c.Text:find("AIM") then
        c.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
    end
end

-- ============================================================
--  ESP
-- ============================================================
local hasDrawing = pcall(function() return Drawing.new end)
local ESPCache = {}

local function createESP(player)
    if player == LocalPlayer or not hasDrawing then return end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness = 1; d.Box.Filled = false; d.Box.Transparency = 1; d.Box.Visible = false
    d.Name = Drawing.new("Text"); d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true; d.Name.Visible = false
    d.HP = Drawing.new("Line"); d.HP.Thickness = 2; d.HP.Color = Color3.fromRGB(0, 255, 100); d.HP.Visible = false
    d.Dist = Drawing.new("Text"); d.Dist.Size = 12; d.Dist.Center = true; d.Dist.Outline = true; d.Dist.Visible = false
    d.Line = Drawing.new("Line"); d.Line.Thickness = 1; d.Line.Visible = false
    local bones = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}
    d.Skel = {}
    for _, bn in ipairs(bones) do
        local ln = Drawing.new("Line")
        ln.Thickness = 1; ln.Color = Color3.fromRGB(230, 230, 235); ln.Visible = false
        d.Skel[bn] = ln
    end
    ESPCache[player] = d
end

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPCache[p] then
        for _, o in pairs(ESPCache[p]) do
            if typeof(o) == "table" then
                for _, l in pairs(o) do pcall(function() l:Remove() end) end
            else pcall(function() o:Remove() end) end
        end
        ESPCache[p] = nil
    end
end)

local FovCircle
if hasDrawing then
    FovCircle = Drawing.new("Circle")
    FovCircle.Thickness = 1
    FovCircle.Color = Color3.fromRGB(230, 230, 235)
    FovCircle.Transparency = 0.7
    FovCircle.NumSides = 64
    FovCircle.Radius = cfg.fov
    FovCircle.Filled = false
    FovCircle.Visible = false
end

RunService.RenderStepped:Connect(function()
    if FovCircle then
        FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FovCircle.Radius = cfg.fov
        FovCircle.Visible = cfg.fovCircle
    end
end)

local function hideESP(e)
    e.Box.Visible = false; e.Name.Visible = false; e.HP.Visible = false
    e.Dist.Visible = false; e.Line.Visible = false
    for _, l in pairs(e.Skel) do l.Visible = false end
end

local function wp(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on
end

local function bbox(char)
    local ok, cf, size = pcall(function() return char:GetBoundingBox() end)
    if not ok then return nil end
    local c0 = cf.Position - size / 2
    local c1 = cf.Position + size / 2
    local x0, y0 = wp(c0)
    local x1, y1 = wp(c1)
    return math.min(x0.X, x1.X), math.min(x0.Y, y1.Y), math.max(x0.X, x1.X), math.max(x0.Y, y1.Y)
end

RunService.RenderStepped:Connect(function()
    for p, e in pairs(ESPCache) do
        local c = p.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        local hd = c and c:FindFirstChild("Head")
        local hm = c and c:FindFirstChildOfClass("Humanoid")
        if not cfg.esp or not c or not hr or not hd or not hm or hm.Health <= 0 then hideESP(e); continue end
        local minx, miny, maxx, maxy = bbox(c)
        if not minx then hideESP(e); continue end
        local x, y, w, h = minx, miny, maxx - minx, maxy - miny
        e.Box.Size = Vector2.new(w, h)
        e.Box.Position = Vector2.new(x, y)
        e.Box.Color = Color3.fromRGB(230, 230, 235)
        e.Box.Visible = cfg.box
        e.Name.Text = p.Name
        e.Name.Position = Vector2.new(x + w / 2, y - 18)
        e.Name.Color = Color3.fromRGB(255, 255, 255)
        e.Name.Visible = cfg.name
        local hpr = hm.Health / math.max(hm.MaxHealth, 1)
        e.HP.From = Vector2.new(x - 6, y + h)
        e.HP.To = Vector2.new(x - 6, y + h - h * hpr)
        e.HP.Visible = cfg.hp
        if cfg.dist then
            local mr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if mr then
                e.Dist.Text = "[" .. math.floor((mr.Position - hr.Position).Magnitude) .. "]"
                e.Dist.Position = Vector2.new(x + w / 2, y + h + 4)
                e.Dist.Color = Color3.fromRGB(255, 255, 255)
                e.Dist.Visible = true
            end
        else e.Dist.Visible = false end
        if cfg.line then
            e.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            e.Line.To = Vector2.new(x + w / 2, y + h)
            e.Line.Color = Color3.fromRGB(230, 230, 235)
            e.Line.Visible = true
        else e.Line.Visible = false end
        if cfg.skel then
            local bonesList = {
                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
            }
            for _, pr in ipairs(bonesList) do
                local a = c:FindFirstChild(pr[1])
                local b = c:FindFirstChild(pr[2])
                local ln = e.Skel[pr[1]]
                if a and b and ln then
                    ln.From = wp(a.Position)
                    ln.To = wp(b.Position)
                    ln.Visible = true
                end
            end
        else for _, ln in pairs(e.Skel) do ln.Visible = false end end
    end
end)

-- ============================================================
--  GetTarget
-- ============================================================
local function getTarget()
    local closest, shortest = nil, cfg.fov
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local c = p.Character
            local hd = c and c:FindFirstChild("Head")
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            if hd and hm and hm.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(hd.Position)
                if on then
                    local d = math.sqrt((sp.X - cx) ^ 2 + (sp.Y - cy) ^ 2)
                    if d < shortest then shortest = d; closest = hd end
                end
            end
        end
    end
    return closest
end

-- Checa se a key do aimbot ta pressionada (teclado OU mouse)
local function aimKeyDown()
    if cfg.aimKeyIsMouse then
        if cfg.aimMouseBtn == 1 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif cfg.aimMouseBtn == 2 then
            return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end
    else
        return UserInputService:IsKeyDown(cfg.aimKey)
    end
    return false
end

-- ============================================================
--  Aimbot corrigido
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not cfg.aim then return end
    if not aimKeyDown() then return end
    local target = getTarget()
    if target then
        local smooth = 1 - (cfg.smooth / 100)
        local goal = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, smooth)
    end
end)

-- ============================================================
--  Silent Aim (hook + fallback)
-- ============================================================
local silentOK = false
if hookmetamethod and getrawmetatable and checkcaller then
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if cfg.silent and not checkcaller() then
                if self == LocalPlayer:GetMouse() and (method == "Hit" or method == "get_Hit") then
                    local t = getTarget()
                    if t then return CFrame.new(t.Position) end
                end
            end
            return oldNC(self, ...)
        end))
        setreadonly(mt, true)
        silentOK = true
    end)
end

-- Fallback: se hook não funcionou, faz aim instantâneo no silent
if not silentOK then
    RunService.RenderStepped:Connect(function()
        if not cfg.silent then return end
        local t = getTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end)
end

-- ============================================================
--  Triggerbot
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not cfg.trigger then return end
    local t = getTarget()
    if t and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - t.Position).Magnitude
        if dist < 100 then pcall(function() mouse1click() end) end
    end
end)

-- ============================================================
--  Rapid Fire
-- ============================================================
local rapidConn
local function applyRapidFire()
    if rapidConn then rapidConn:Disconnect() rapidConn = nil end
    if not cfg.rapidFire then return end
    rapidConn = RunService.Heartbeat:Connect(function()
        local c = LocalPlayer.Character
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
--  Godmode
-- ============================================================
local function applyGod()
    local c = LocalPlayer.Character
    if not c then return end
    local hm = c:FindFirstChildOfClass("Humanoid")
    if hm then
        hm.MaxHealth = math.huge
        hm.Health = math.huge
        if not hm:GetAttribute("EvilGodBound") then
            hm:SetAttribute("EvilGodBound", true)
            hm.HealthChanged:
