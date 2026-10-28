-- Rose - FTAP Cheat (Obsidian UI)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local function Rose_Load(path)
    local body = game:HttpGet(repo .. path)
    local fn, err = loadstring(body)
    assert(fn, "Rose loadstring fail " .. path .. ": " .. tostring(err))
    return fn()
end
local Library = Rose_Load("Library.lua")
local ThemeManager = Rose_Load("addons/ThemeManager.lua")
local SaveManager = Rose_Load("addons/SaveManager.lua")
local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.CornerRadius = 16
Library.Scheme.FontColor = Color3.fromHex("ffffff")
Library.Scheme.MainColor = Color3.fromHex("2b1f2e")
Library.Scheme.AccentColor = Color3.fromHex("ff6fae")
Library.Scheme.BackgroundColor = Color3.fromHex("1a121c")
Library.Scheme.OutlineColor = Color3.fromHex("3a2a3f")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local State = { runtime = {} }
local function R(k, v) State.runtime[k] = v end
local function G(k) return State.runtime[k] end
local defaults = {
    speed = false, walkSpeed = 16, fly = false, flySpeed = 60, noclip = false, antiVoid = false,
    antiGrab = false, kick = false, kickHeight = 22, loopKill = false, blobKick = false,
    rogdoll = false, espOn = true, fullBright = false, fov = 70, thirdPerson = false,
    pcldHighlight = false, lineLag = false, packetSpam = false, antiExplosion = false,
    antiBurn = false, antiFreeze = false, antiKick = false, antiPaint = false, antiSticky = false,
    antiSnowball = false, antiBanana = false, antiPoison = false, antiOwnership = false,
    antiBlobman = false, gucciAntiGrab = false,
}
for k, v in pairs(defaults) do State.runtime[k] = v end

local function GetRoot(p) local c = p.Character; return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end
local function GetHum(p) local c = p.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function GetGrabEvents() return ReplicatedStorage:FindFirstChild("GrabEvents") end
local function GetPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end
    return t
end
local function FindPlayer(name)
    for _, p in ipairs(Players:GetPlayers()) do if p.Name == name or p.DisplayName == name then return p end end
end
local function Notify(t, d, time) pcall(function() Library:Notify({ Title = t or "Rose", Description = d or "", Time = time or 3 }) end) end

-- Movement / defence loop
RunService.Heartbeat:Connect(function()
    local hum = GetHum(LocalPlayer)
    if hum then
        if G("speed") then hum.WalkSpeed = G("walkSpeed") end
        if G("noclip") then
            local c = LocalPlayer.Character
            if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end
    end
    if G("fly") then
        local root = GetRoot(LocalPlayer)
        if root then
            local bv = root:FindFirstChild("Rose_Fly")
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name = "Rose_Fly"; bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.Velocity = Vector3.zero; bv.Parent = root end
            local UIS = game:GetService("UserInputService"); local cam = Camera; local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * G("flySpeed")
        end
    else
        local root = GetRoot(LocalPlayer); if root then local bv = root:FindFirstChild("Rose_Fly"); if bv then bv:Destroy() end end
    end
    if G("antiVoid") then
        local root = GetRoot(LocalPlayer); if root and root.Position.Y < -50 then root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z); root.Velocity = Vector3.zero end
    end
    if G("antiGrab") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BodyPosition") or d:IsA("BodyGyro") or d:IsA("AlignPosition") or d:IsA("AlignOrientation") then pcall(function() d:Destroy() end) end end end
    end
    if G("antiExplosion") then
        local root = GetRoot(LocalPlayer); if root then local v = root.Velocity; if v.Magnitude > 150 then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end end
    end
    if G("antiBurn") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then pcall(function() d:Destroy() end) end end; local h = c:FindFirstChildOfClass("Humanoid"); if h and h.Health < h.MaxHealth then pcall(function() h.Health = h.MaxHealth end) end end
    end
    if G("antiFreeze") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if d.Name:lower():find("freeze") or d.Name:lower():find("ice") then pcall(function() d:Destroy() end) end end; local r = c:FindFirstChild("HumanoidRootPart"); if r then r.Anchored = false end end
    end
    if G("antiKick") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "NinjaShuriken" or obj.Name == "NinjaKunai" then
                local owner = obj:FindFirstAncestorWhichIsA("Model"); if not owner or owner.Name ~= LocalPlayer.Name then pcall(function() obj:Destroy() end) end
            end
        end
    end
    if G("antiBlobman") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local toys = Workspace:FindFirstChild(p.Name .. "SpawnedInToys")
                if toys then for _, c2 in ipairs(toys:GetChildren()) do
                    if c2.Name == "CreatureBlobman" then pcall(function()
                        if ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy") then ReplicatedStorage.MenuToys.DestroyToy:FireServer(c2) end
                        c2:Destroy()
                    end) end
                end end
            end
        end
    end
    if G("antiPaint") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") and (d.Name:lower():find("paint") or d:FindFirstChild("Paint")) then pcall(function() d:Destroy() end) end end end
    end
    if G("antiPoison") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if d.Name:lower():find("poison") then pcall(function() d:Destroy() end) end end; local h = c:FindFirstChildOfClass("Humanoid"); if h then pcall(function() h.Health = h.MaxHealth end) end end
    end
    if G("antiSticky") then
        local c = LocalPlayer.Character; if c then for _, d in ipairs(c:GetDescendants()) do if (d:IsA("WeldConstraint") or d:IsA("HingeConstraint") or d:IsA("SpringConstraint")) and d.Name:lower():find("stick") then pcall(function() d:Destroy() end) end end end
    end
    if G("antiSnowball") or G("antiBanana") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (G("antiSnowball") and obj.Name == "BallSnowball") or (G("antiBanana") and obj.Name:lower():find("banana")) then
                local anc = obj:FindFirstAncestor(LocalPlayer.Name .. "SpawnedInToys"); if not anc then pcall(function() obj:Destroy() end) end
            end
        end
    end
    if G("antiOwnership") then
        local root = GetRoot(LocalPlayer); if root then local ge = GetGrabEvents(); local so = ge and ge:FindFirstChild("SetNetworkOwner"); if so then pcall(function() so:FireServer(root, root.CFrame) end) end end
    end
    if G("gucciAntiGrab") then
        local c = LocalPlayer.Character; if c then
            local root = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local grabbed = false
                for _, d in ipairs(c:GetDescendants()) do if (d:IsA("AlignPosition") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and d.Name ~= "RoseAlign" then grabbed = true; break end end
                if grabbed then
                    local best, bd = nil, math.huge
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if (obj:IsA("VehicleSeat") or obj:IsA("Seat")) and obj.Occupant == nil then
                            local dd = (obj.Position - root.Position).Magnitude; if dd < bd and dd < 80 then bd = dd; best = obj end
                        end
                    end
                    if best then pcall(function() hum.Sit = true; root.CFrame = best.CFrame; best:Sit(hum) end)
                    else pcall(function() root.CFrame = root.CFrame + Vector3.new(0, 15, 0); root.Velocity = Vector3.zero end) end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = G("fov")
    if G("fullBright") then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) end
    if G("thirdPerson") then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local root = GetRoot(LocalPlayer); if root then local offset = root.CFrame * CFrame.new(0, 2, 8); Camera.CFrame = CFrame.new(offset.Position, root.Position + Vector3.new(0, 2, 0)) end
    end
    if G("pcldHighlight") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("playercharacterlocationdetector") or obj.Name:lower():find("partesp") then
                if obj:IsA("BasePart") then obj.Color = Color3.fromRGB(255, 100, 200); obj.Material = Enum.Material.Neon; obj.Transparency = 0.3 end
            end
        end
    end
end)

-- ESP via Highlight
local function EnsureHighlight(char)
    if not char then return end
    local hl = char:FindFirstChild("RoseHL")
    if not hl then hl = Instance.new("Highlight"); hl.Name = "RoseHL"; hl.FillTransparency = 0.5; hl.OutlineTransparency = 0; hl.Parent = char end
    return hl
end
RunService.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = EnsureHighlight(p.Character)
            if hl then
                if G("espOn") then
                    hl.Enabled = true
                    local tm = (p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team)
                    hl.FillColor = tm and Color3.fromRGB(60, 180, 255) or Color3.fromRGB(255, 60, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    hl.Enabled = false
                end
            end
        end
    end
end)

-- Packet spam / line lag
RunService.Heartbeat:Connect(function()
    if G("lineLag") then
        local ge = GetGrabEvents(); if ge then
            local root = GetRoot(LocalPlayer)
            if root then pcall(function()
                if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(root, Vector3.zero, root.Position, false) end
                if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(root) end
            end) end
        end
    end
    if G("packetSpam") then
        local big = string.rep("A", 50000)
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then pcall(function() remote:FireServer(big) end) end
        end
    end
end)

-- Kick function
local function DoKick(targetName)
    local ge = GetGrabEvents(); if not ge then return end
    local setNO = ge:FindFirstChild("SetNetworkOwner"); if not setNO then return end
    local lastGrab = 0
    while G("kick") do
        local target = FindPlayer(targetName); if not target or not target.Parent then break end
        local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tc = target.Character; local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if not tc or not th or th.Health <= 0 then RunService.Heartbeat:Wait(); continue end
        local tr = tc:FindFirstChild("HumanoidRootPart")
        if not (c and root) or not tr then RunService.Heartbeat:Wait(); continue end
        if (tr.Position - root.Position).Magnitude > 30 then pcall(function() c:PivotTo(tr.CFrame * CFrame.new(0, 2, 4)) end); RunService.Heartbeat:Wait(); continue end
        local kickPos = (root.CFrame * CFrame.new(0, G("kickHeight"), 0)).Position
        if not tr:FindFirstChild("RoseAlign") then
            for _, ch in pairs(tr:GetChildren()) do if (ch:IsA("BodyPosition") or ch:IsA("BodyGyro") or ch:IsA("AlignPosition") or ch:IsA("AlignOrientation")) and ch.Name ~= "RoseAlign" and ch.Name ~= "RoseRot" then pcall(function() ch:Destroy() end) end end
            local att = Instance.new("Attachment", tr); att.Name = "RoseAtt0"
            local aatt = Instance.new("Attachment", Workspace.Terrain); aatt.Name = "RoseAtt1"
            local ap = Instance.new("AlignPosition"); ap.Name = "RoseAlign"; ap.Attachment0 = att; ap.Attachment1 = aatt; ap.MaxForce = math.huge; ap.Responsiveness = 300; ap.Parent = tr
            local ao = Instance.new("AlignOrientation"); ao.Name = "RoseRot"; ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque = math.huge; ao.Responsiveness = 300; ao.Parent = tr
        end
        local ra = tr:FindFirstChild("RoseAlign"); if ra and ra.Attachment1 then ra.Attachment1.WorldPosition = kickPos end
        local rr = tr:FindFirstChild("RoseRot"); if rr then rr.CFrame = CFrame.Angles(0, 0, 0) end
        pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.zero; tr.AssemblyAngularVelocity = Vector3.zero end)
        local now = tick()
        if now - lastGrab > 0.05 then
            pcall(function() for i = 1, 3 do setNO:FireServer(tr, tr.CFrame) end end)
            local cg = ge:FindFirstChild("CreateGrabLine"); if cg then pcall(function() cg:FireServer(tr, kickPos) end) end
            local dg = ge:FindFirstChild("DestroyGrabLine"); if dg then pcall(function() dg:FireServer(tr) end) end
            pcall(function() tr.AssemblyLinearVelocity = Vector3.new(0, 200, 0) end)
            lastGrab = now
        end
        RunService.Heartbeat:Wait()
    end
end

-- LoopKill function
local function DoLoopKill(targetName)
    local ge = GetGrabEvents(); if not ge then return end
    while G("loopKill") do
        local target = FindPlayer(targetName); if not target then task.wait(0.5); continue end
        local tc = target.Character; local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart"); local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 and root then
            local saved = root.CFrame; local t0 = tick()
            while tick() - t0 < 0.35 and G("loopKill") and tr.Parent do
                root.CFrame = tr.CFrame * CFrame.new(0, 0, 2); root.Velocity = Vector3.zero
                pcall(function() ge.SetNetworkOwner:FireServer(tr, root.CFrame); th:ChangeState(Enum.HumanoidStateType.Dead); th.Health = 0 end)
                RunService.Heartbeat:Wait()
            end
            root.CFrame = saved; root.Velocity = Vector3.zero; task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
end

-- UI
local window = Library:CreateWindow({ Title = "Rose", Footer = "FTAP Cheat", Center = true, AutoShow = true })
local tabMain = window:AddTab("Main")
local tabFling = window:AddTab("Fling")
local tabVis = window:AddTab("Visuals")
local tabFun = window:AddTab("Fun")
local tabDef = window:AddTab("Defence")
local tabSet = window:AddTab("Settings")

local gMove = tabMain:AddLeftGroupbox("Movement")
gMove:AddToggle("Speed", { Text = "Speed", Default = false, Callback = function(v) R("speed", v) end })
gMove:AddSlider("WalkSpeed", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0, Callback = function(v) R("walkSpeed", v) end })
gMove:AddToggle("Fly", { Text = "Fly", Default = false, Callback = function(v) R("fly", v) end })
gMove:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 20, Max = 400, Rounding = 0, Callback = function(v) R("flySpeed", v) end })
gMove:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = function(v) R("noclip", v) end })
gMove:AddToggle("AntiVoid", { Text = "Anti-Void", Default = false, Callback = function(v) R("antiVoid", v) end })
gMove:AddToggle("AntiGrab", { Text = "Anti-Grab", Default = false, Callback = function(v) R("antiGrab", v) end })

local gFling = tabFling:AddLeftGroupbox("Fling")
local targetName = (GetPlayerNames()[1]) or ""
gFling:AddDropdown("Target", { Text = "Target", Values = GetPlayerNames(), Default = targetName })
gFling:AddToggle("Kick", { Text = "Kick (hold)", Default = false, Callback = function(v) R("kick", v) if v then task.spawn(function() DoKick(targetName) end) end end })
gFling:AddSlider("KickHeight", { Text = "Kick Height", Default = 22, Min = 5, Max = 100, Rounding = 0, Callback = function(v) R("kickHeight", v) end })
gFling:AddToggle("LoopKill", { Text = "Loop Kill", Default = false, Callback = function(v) R("loopKill", v) if v then task.spawn(function() DoLoopKill(targetName) end) end end })
gFling:AddButton("Kick All", { Text = "Kick All", Func = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then R("kick", true) end end Notify("Rose", "Kicking all", 2) end })
gFling:AddButton("Teleport", { Text = "Teleport to Target", Func = function()
    local target = FindPlayer(targetName); if not target or not target.Character then Notify("Rose", "Player not found", 2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart"); local root = GetRoot(LocalPlayer)
    if tr and root then root.CFrame = tr.CFrame * CFrame.new(0, 0, 3); root.Velocity = Vector3.zero; Notify("Rose", "Teleported", 2) end
end })

local gVis = tabVis:AddLeftGroupbox("Visuals")
gVis:AddToggle("ESP", { Text = "ESP", Default = true, Callback = function(v) R("espOn", v) end })
gVis:AddToggle("FullBright", { Text = "FullBright", Default = false, Callback = function(v) R("fullBright", v) end })
gVis:AddSlider("FOV", { Text = "FOV", Default = 70, Min = 50, Max = 120, Rounding = 0, Callback = function(v) R("fov", v) end })

local gFun = tabFun:AddLeftGroupbox("Fun")
gFun:AddToggle("ThirdPerson", { Text = "Third Person", Default = false, Callback = function(v) R("thirdPerson", v) end })
gFun:AddToggle("PCLD", { Text = "PCLD Highlight", Default = false, Callback = function(v) R("pcldHighlight", v) end })
gFun:AddToggle("LineLag", { Text = "Line Lag", Default = false, Callback = function(v) R("lineLag", v) end })
gFun:AddToggle("PacketSpam", { Text = "Packet Spam", Default = false, Callback = function(v) R("packetSpam", v) end })
gFun:AddButton("Pose", { Text = "Pose (sit on me)", Func = function()
    local target = FindPlayer(targetName); if not target or not target.Character then Notify("Rose", "Player not found", 2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart"); local root = GetRoot(LocalPlayer)
    if tr and root then tr.CFrame = root.CFrame * CFrame.new(0, 2, -1.5); tr.Velocity = Vector3.zero
        local th = target.Character:FindFirstChildOfClass("Humanoid"); if th then th.PlatformStand = true end
        Notify("Rose", "Posed", 2) end
end })
gFun:AddButton("Unpose", { Text = "Unpose", Func = function()
    local target = FindPlayer(targetName); if not target or not target.Character then return end
    local th = target.Character:FindFirstChildOfClass("Humanoid"); if th then th.PlatformStand = false end
    Notify("Rose", "Unposed", 2)
end })

local gDef = tabDef:AddLeftGroupbox("Defence")
local function defToggle(name, key)
    gDef:AddToggle(name, { Text = name, Default = false, Callback = function(v) R(key, v) end })
end
defToggle("Anti-Grab", "antiGrab")
defToggle("Anti-Void", "antiVoid")
defToggle("Anti-Explosion", "antiExplosion")
defToggle("Anti-Burn", "antiBurn")
defToggle("Anti-Freeze", "antiFreeze")
defToggle("Anti-Kick", "antiKick")
defToggle("Anti-Paint", "antiPaint")
defToggle("Anti-Sticky", "antiSticky")
defToggle("Anti-Snowball", "antiSnowball")
defToggle("Anti-Banana", "antiBanana")
defToggle("Anti-Poison", "antiPoison")
defToggle("Anti-Ownership", "antiOwnership")
defToggle("Anti-Blobman", "antiBlobman")
defToggle("Gucci Anti-Grab", "gucciAntiGrab")

local gSet = tabSet:AddLeftGroupbox("Settings")
gSet:AddLabel("Rose v4 - FTAP Cheat")
gSet:AddButton("Unload", { Text = "Unload", Func = function() Library:Unload() end })

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("Rose")
SaveManager:SetFolder("Rose")
SaveManager:BuildConfigSection(tabSet)
ThemeManager:ApplyToTab(tabSet)

Notify("Rose", "Loaded v4. Enjoy!", 5)
print("[Rose] loaded v4")
