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
    aim=false, silent=false, trigger=false, aimVisible=false,
    fovCircle=false, fov=150, smooth=50,
    god=false, fly=false, spd=60,
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

local function tog(p, label, def, cb)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1,-16,0,34)
    b.BackgroundColor3 = def and C.on or C.card
    b.Text = "  "..label
    b.TextColor3 = C.txt
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = def
    b.MouseButton1Click:Connect(function()
        s = not s
        b.BackgroundColor3 = s and C.on or C.card
        cb(s)
    end)
end

local function sld(p, label, mn, mx, def, cb)
    local h = Instance.new("Frame", p)
    h.Size = UDim2.new(1,-16,0,46)
    h.BackgroundColor3 = C.card
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

tog(AS, "Aimbot (sempre ativo)", cfg.aim, function(v) cfg.aim=v end)
sld(AS, "Regular FOV", 30, 600, cfg.fov, function(v) cfg.fov = v end)
sld(AS, "Smooth", 1, 100, cfg.smooth, function(v) cfg.smooth = v end)
tog(AS, "Aim Visible", cfg.aimVisible, function(v) cfg.aimVisible=v end)
tog(AS, "Silent Aim", cfg.silent, function(v) cfg.silent=v end)
tog(AS, "Triggerbot", cfg.trigger, function(v) cfg.trigger=v end)
tog(AS, "FOV Circle", cfg.fovCircle, function(v) cfg.fovCircle=v end)

tog(VS, "ESP", cfg.esp, function(v) cfg.esp=v end)
tog(VS, "Box", cfg.box, function(v) cfg.box=v end)
tog(VS, "Skeleton", cfg.skel, function(v) cfg.skel=v end)
tog(VS, "Name", cfg.name, function(v) cfg.name=v end)
tog(VS, "Health", cfg.hp, function(v) cfg.hp=v end)
tog(VS, "Distance", cfg.dist, function(v) cfg.dist=v end)

tog(PS, "Godmode", cfg.god, function(v) cfg.god=v end)
tog(PS, "Fly [WASD+Space]", cfg.fly, function(v) cfg.fly=v; if setFly then setFly(v) end end)

tog(MS, "Rapid Fire", false, function(v) if applyRapid then applyRapid(v) end end)
tog(MS, "Rejoin", false, function(v) if v then TPS:Teleport(game.PlaceId, LP) end end)

sel("AIM")

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
    if d.skel then
        for _, l in pairs(d.skel) do pcall(function() l:Remove() end) end
    end
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
    for _, bn in ipairs({"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do
        local l = Drawing.new("Line"); l.Thickness=1; l.Color=Color3.fromRGB(230,230,235); l.Visible=false
        d.skel[bn] = l
    end
    Cache[p] = d
end

for _, p in ipairs(Players:GetPlayers()) do mkESP(p) end
Players.PlayerAdded:Connect(mkESP)
Players.PlayerRemoving:Connect(function(p)
    clearCache(p)
end)

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
                if not p.Parent then task.spawn(function() clearCache(p) end) end
            else
                local ok, cf, size = pcall(function() return c:GetBoundingBox() end)
                if ok then
                    local p0 = w2v(cf.Position - size/2)
                    local p1 = w2v(cf.Position + size/2)
                    local x,y = math.min(p0.X,p1.X), math.min(p0.Y,p1.Y)
                    local w,h = math.abs(p1.X-p0.X), math.abs(p1.Y-p0.Y)
                    if w > 0 and h > 0 and w < 2000 and h < 2000 then
                        e.box.Size = Vector2.new(w,h)
                        e.box.Position = Vector2.new(x,y)
                        e.box.Color = Color3.fromRGB(230,230,235)
                        e.box.Visible = cfg.box
                        e.name.Text = p.Name
                        e.name.Position = Vector2.new(x+w/2, y-18)
                        e.name.Color = Color3.fromRGB(255,255,255)
                        e.name.Visible = cfg.name
                        local hpr = hm.Health / math.max(hm.MaxHealth,1)
                        e.hp.From = Vector2.new(x-6, y+h)
                        e.hp.To   = Vector2.new(x-6, y+h-h*hpr)
                        e.hp.Visible = cfg.hp
                        if cfg.dist then
                            local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if mr and mr.Parent then
                                e.dist.Text = "["..math.floor((mr.Position-hr.Position).Magnitude).."]"
                                e.dist.Position = Vector2.new(x+w/2, y+h+4)
                                e.dist.Color = Color3.fromRGB(255,255,255)
                                e.dist.Visible = true
                            end
                        else e.dist.Visible = false end
                        if cfg.skel then
                            local pairs_ = {
                                {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
                                {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
                                {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
                                {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
                                {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
                            }
                            for _, pr in ipairs(pairs_) do
                                local a = c:FindFirstChild(pr[1])
                                local b = c:FindFirstChild(pr[2])
                                local l = e.skel[pr[1]]
                                if a and b and l then
                                    l.From = w2v(a.Position)
                                    l.To   = w2v(b.Position)
                                    l.Visible = true
                                end
                            end
                        else
                            for _, l in pairs(e.skel) do l.Visible=false end
                        end
                    else
                        hide(e)
                    end
                else
                    hide(e)
                end
            end
        end
    end
end)

-- Checagem de visibilidade: raycast da câmera até o alvo.
-- Retorna true se o primeiro obstáculo for a própria cabeça do alvo.
local function isVisible(targetPart)
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

local function target()
    local best, bd = nil, cfg.fov
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Parent then
            local c = p.Character
            local hd = c and c:FindFirstChild("Head")
            local hm = c and c:FindFirstChildOfClass("Humanoid")
            if hd and hd.Parent and hm and hm.Parent and hm.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(hd.Position)
                if on then
                    local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                    if d < bd then
                        if isVisible(hd) then
                            bd = d
                            best = hd
                        end
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
    local ok = false
    if hookmetamethod and getrawmetatable and checkcaller then
        pcall(function()
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if cfg.silent and not checkcaller() and self == LP:GetMouse() then
                    if m == "Hit" or m == "get_Hit" then
                        local t = target()
                        if t then return CFrame.new(t.Position) end
                    end
                end
                return old(self, ...)
            end))
            setreadonly(mt, true)
            ok = true
        end)
    end
    if not ok then
        RunService.RenderStepped:Connect(function()
            if not cfg.silent then return end
            local t = target()
            if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position) end
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

LP.CharacterAdded:Connect(function()
    if cfg.fly then setFly(true) end
    if cfg.god then applyGod() end
end)
