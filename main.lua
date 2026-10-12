local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")
local TPS        = game:GetService("TeleportService")
local LP         = Players.LocalPlayer
local Camera     = Workspace.CurrentCamera

local cfg = {
    aim=false, aimPart="Head", silent=false, trigger=false, aimVisible=false,
    fovCircle=false, fov=150, smooth=50,
    esp=false, box=true, skel=true, name=true, hp=true, dist=true,
    fly=false, spd=60, speed=false, speedVal=0, god=false, rapid=false, tpEnemy=false,
}

-- CARREGAR KAVO
local Library
local ok, err = pcall(function()
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

if not ok or not Library then
    warn("[Evil] Falha ao carregar Kavo: " .. tostring(err))
    return
end

local CURRENT_THEME = "DarkTheme"

local Window
local function buildWindow(theme)
    local Win = Library:CreateLib("Evil", theme)

    local CombatTab  = Win:NewTab("Combat")
    local ExploitTab = Win:NewTab("Exploits")
    local VisualTab  = Win:NewTab("Visuals")
    local ColorTab   = Win:NewTab("Colors")
    local ConfigTab  = Win:NewTab("Config")

    local AimS = CombatTab:NewSection("Aimbot")
    AimS:NewToggle("Aimbot", "Ativa aimbot", function(v) cfg.aim = v end)
    AimS:NewDropdown("Aim Part", "Head / Neck / Body", {"Head","Neck","Body"}, function(v) cfg.aimPart = v end)
    AimS:NewSlider("FOV", "FOV size", 600, 30, function(v) cfg.fov = v end)
    AimS:NewSlider("Smooth", "Suavização", 100, 1, function(v) cfg.smooth = v end)
    AimS:NewToggle("Aim Visible", "Só alvo visível", function(v) cfg.aimVisible = v end)
    AimS:NewToggle("FOV Circle", "Mostra círculo", function(v) cfg.fovCircle = v end)

    local SilentS = CombatTab:NewSection("Silent / Trigger")
    SilentS:NewToggle("Silent Aim", "Hook no mouse", function(v) cfg.silent = v end)
    SilentS:NewToggle("Triggerbot", "Atira sozinho", function(v) cfg.trigger = v end)

    local VisS = VisualTab:NewSection("ESP")
    VisS:NewToggle("ATIVAR ESP", "Ativa ESP", function(v) cfg.esp = v end)
    VisS:NewToggle("Box", "", function(v) cfg.box = v end)
    VisS:NewToggle("Skeleton", "", function(v) cfg.skel = v end)
    VisS:NewToggle("Name", "", function(v) cfg.name = v end)
    VisS:NewToggle("Health", "", function(v) cfg.hp = v end)
    VisS:NewToggle("Distance", "", function(v) cfg.dist = v end)

    local MoveS = ExploitTab:NewSection("Movement")
    MoveS:NewToggle("Fly [WASD+Space]", "", function(v) cfg.fly = v; if setFly then setFly(v) end end)
    MoveS:NewSlider("Fly Speed", "", 300, 10, function(v) cfg.spd = v end)
    MoveS:NewToggle("Speed", "", function(v) cfg.speed = v end)
    MoveS:NewSlider("Speed Value", "", 30, 0, function(v) cfg.speedVal = v end)

    local CS = ExploitTab:NewSection("Combat")
    CS:NewToggle("Godmode", "", function(v) cfg.god = v end)
    CS:NewToggle("Rapid Fire", "", function(v) cfg.rapid = v; if applyRapid then applyRapid(v) end end)

    local TS = ExploitTab:NewSection("Teleport")
    TS:NewToggle("TP to Enemy", "", function(v)
        if v then
            local t = target and target()
            if t then
                local c = LP.Character
                local hr = c and c:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = CFrame.new(t.Position + Vector3.new(0,3,0)) end
            end
            task.delay(0.3, function() cfg.tpEnemy = false end)
        end
        cfg.tpEnemy = false
    end)
    TS:NewButton("Rejoin", "", function() TPS:Teleport(game.PlaceId, LP) end)

    local ColorS = ColorTab:NewSection("Theme")
    ColorS:NewDropdown("Theme", "Troca tema (recria UI)", {"DarkTheme","BloodTheme","GrapeTheme","Synapse","Midnight","Serpent"}, function(v)
        CURRENT_THEME = v
        pcall(function() Library:Destroy() end)
        task.wait(0.3)
        Window = buildWindow(v)
    end)

    local CfgS = ConfigTab:NewSection("Config")
    CfgS:NewButton("Exit", "Fecha a UI", function()
        pcall(function() Library:Destroy() end)
    end)

    return Win
end

Window = buildWindow(CURRENT_THEME)

-- Se o Kavo não abriu a UI por algum motivo, tenta reabrir
pcall(function() Library:ToggleUI() end)

-- Bind para abrir/fechar com RightShift
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function() Library:ToggleUI() end)
    end
end)

local applyRapid, setFly
local isVisible, target

-- ESP
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
                            if t then return oldNamecall(self, Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)) end
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
