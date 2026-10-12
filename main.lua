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
                        if d < bd then
                            if isVisible(part) then
                                bd = d
                                best = part
                            end
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
