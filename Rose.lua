-- Rose - FTAP (Fling Things and People) Cheat
-- Load via: loadstring(game:HttpGet("YOUR_RAW_URL"))()

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
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local State = { runtime = {}, flags = {}, connections = {}, refs = {} }
State.runtime.kick = false
State.runtime.kickHeight = 22
State.runtime.grabDelay = 0.05
State.runtime.rogdoll = false
State.runtime.loopKill = false
State.runtime.loopKillFast = false
State.runtime.espOn = true
State.runtime.traceOn = false
State.runtime.antiGrab = false
State.runtime.antiVoid = false
State.runtime.speed = false
State.runtime.walkSpeed = 16
State.runtime.fly = false
State.runtime.flySpeed = 60
State.runtime.noclip = false
State.runtime.fov = 70
State.runtime.fullBright = false
State.runtime.menuKeybind = Enum.KeyCode.RightShift

-- helpers
local function WaitChild(i, n, t) return i:FindFirstChild(n) or i:WaitForChild(n, t or 3) end
local function GetRoot(p) local c = p.Character; return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end
local function GetHum(p) local c = p.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function GetGrabEvents() return ReplicatedStorage:FindFirstChild("GrabEvents") end
local function GetPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.DisplayName) end
    end
    return t
end
local function FindPlayer(name)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.DisplayName == name or p.Name == name then return p end
    end
end

-- notify helper
local function Notify(title, desc, t)
    Library:Notify({ Title = title or "Rose", Description = desc or "", Time = t or 3 })
end

-- ================= SPEED / FLY / NOCLIP =================
RunService.Heartbeat:Connect(function()
    local hum = GetHum(LocalPlayer)
    if hum then
        if State.runtime.speed then hum.WalkSpeed = State.runtime.walkSpeed end
        if State.runtime.noclip then
            local c = LocalPlayer.Character
            if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end
    end
    if State.runtime.fly then
        local root = GetRoot(LocalPlayer)
        if root then
            local bv = root:FindFirstChild("Rose_Fly")
            if not bv then
                bv = Instance.new("BodyVelocity"); bv.Name = "Rose_Fly"; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Velocity = Vector3.zero; bv.Parent = root
            end
            local cam = Camera; local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * State.runtime.flySpeed
        end
    else
        local root = GetRoot(LocalPlayer)
        if root then local bv = root:FindFirstChild("Rose_Fly"); if bv then bv:Destroy() end end
    end
end)

-- ================= FULL BRIGHT / FOV =================
RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = State.runtime.fov
    if State.runtime.fullBright then
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
    end
end)

-- ================= ANTI-VOID =================
RunService.Heartbeat:Connect(function()
    if State.runtime.antiVoid then
        local root = GetRoot(LocalPlayer)
        if root and root.Position.Y < -50 then
            root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
            root.Velocity = Vector3.zero
        end
    end
end)

-- ================= ANTI-GRAB =================
RunService.Heartbeat:Connect(function()
    if State.runtime.antiGrab then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BodyPosition") or d:IsA("BodyGyro") or d:IsA("AlignPosition") or d:IsA("AlignOrientation") then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
end)

-- ================= ESP =================
local ESPs = {}
local function CreateESP(player)
    local box = Drawing.new("Square"); box.Thickness = 1; box.Color = Color3.fromRGB(255,80,120); box.Filled = false; box.Visible = false
    local name = Drawing.new("Text"); name.Size = 13; name.Color = Color3.fromRGB(255,255,255); name.Center = true; name.Outline = true; name.Visible = false
    local dist = Drawing.new("Text"); dist.Size = 12; dist.Color = Color3.fromRGB(220,220,220); dist.Center = true; dist.Outline = true; dist.Visible = false
    ESPs[player] = {Box = box, Name = name, Dist = dist}
end
local function RemoveESP(player)
    local e = ESPs[player]
    if e then for _, d in pairs(e) do pcall(function() d:Remove() end) end; ESPs[player] = nil end
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    if not State.runtime.espOn then
        for _, e in pairs(ESPs) do for _, d in pairs(e) do d.Visible = false end end
        return
    end
    for player, e in pairs(ESPs) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local d = (Camera.CFrame.Position - root.Position).Magnitude
            if onScreen and d < 3000 then
                local head = char:FindFirstChild("Head")
                local hPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0)) or pos
                local fPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                local height = math.abs(hPos.Y - fPos.Y)
                local width = height * 0.5
                e.Box.Position = Vector2.new(pos.X - width/2, hPos.Y)
                e.Box.Size = Vector2.new(width, height)
                e.Box.Visible = true
                e.Name.Text = player.Name
                e.Name.Position = Vector2.new(pos.X, hPos.Y - 16)
                e.Name.Visible = true
                e.Dist.Text = string.format("%.0fm", d)
                e.Dist.Position = Vector2.new(pos.X, hPos.Y + height + 2)
                e.Dist.Visible = true
            else
                for _, dd in pairs(e) do dd.Visible = false end
            end
        else
            for _, dd in pairs(e) do dd.Visible = false end
        end
    end
end)

-- ================= KICK LOOP =================
local function KickLoop(playerName)
    local ge = GetGrabEvents()
    if not ge then Notify("Rose", "GrabEvents not found", 3); return end
    local setNO = ge:FindFirstChild("SetNetworkOwner")
    local destroyGL = ge:FindFirstChild("DestroyGrabLine")
    local createGL = ge:FindFirstChild("CreateGrabLine")
    if not setNO then Notify("Rose", "SetNetworkOwner not found", 3); return end
    local lastGrab = 0
    while State.runtime.kick do
        local target = FindPlayer(playerName)
        if not target or not target.Parent then break end
        local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tc = target.Character; local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if not tc or not th or th.Health <= 0 then
            RunService.Heartbeat:Wait(); continue
        end
        local tr = tc:FindFirstChild("HumanoidRootPart")
        if not (c and root) or not tr or not th or th.Health <= 0 then
            RunService.Heartbeat:Wait(); continue
        elseif (tr.Position - root.Position).Magnitude > 30 then
            pcall(function() c:PivotTo(tr.CFrame * CFrame.new(0,2,4)) end)
            RunService.Heartbeat:Wait(); continue
        end
        local kickPos = (root.CFrame * CFrame.new(0, State.runtime.kickHeight, 0)).Position
        -- align
        if not tr:FindFirstChild("RoseAlign") then
            for _, ch in pairs(tr:GetChildren()) do
                if (ch:IsA("BodyPosition") or ch:IsA("BodyGyro") or ch:IsA("AlignPosition") or ch:IsA("AlignOrientation")) and ch.Name ~= "RoseAlign" and ch.Name ~= "RoseRot" then
                    pcall(function() ch:Destroy() end)
                end
            end
            local att = Instance.new("Attachment", tr); att.Name = "RoseAtt0"
            local aatt = Instance.new("Attachment", Workspace.Terrain); aatt.Name = "RoseAtt1"
            local ap = Instance.new("AlignPosition"); ap.Name = "RoseAlign"; ap.Attachment0 = att; ap.Attachment1 = aatt
            ap.MaxForce = math.huge; ap.Responsiveness = 300; ap.Parent = tr
            local ao = Instance.new("AlignOrientation"); ao.Name = "RoseRot"; ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
            ao.MaxTorque = math.huge; ao.Responsiveness = 300; ao.Parent = tr
        end
        local ra = tr:FindFirstChild("RoseAlign")
        if ra and ra.Attachment1 then ra.Attachment1.WorldPosition = kickPos end
        local rr = tr:FindFirstChild("RoseRot"); if rr then rr.CFrame = CFrame.Angles(0,0,0) end
        pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.zero; tr.AssemblyAngularVelocity = Vector3.zero end)
        local now = tick()
        if now - lastGrab > State.runtime.grabDelay then
            pcall(function()
                for i = 1, 3 do setNO:FireServer(tr, tr.CFrame) end
            end)
            if createGL then pcall(function() createGL:FireServer(tr, kickPos) end) end
            if destroyGL then pcall(function() destroyGL:FireServer(tr) end) end
            pcall(function() tr.AssemblyLinearVelocity = Vector3.new(0,200,0) end)
            lastGrab = now
        end
        RunService.Heartbeat:Wait()
    end
    -- cleanup
    local target = FindPlayer(playerName)
    if target and target.Character then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            for _, n in ipairs({"RoseAlign","RoseRot","RoseAtt0","RoseAtt1"}) do
                local o = tr:FindFirstChild(n); if o then pcall(function() o:Destroy() end) end
            end
        end
    end
end

-- ================= LOOP KILL (FAST) =================
local function LoopKillFast(playerName)
    local ge = GetGrabEvents()
    if not ge then return end
    while State.runtime.loopKillFast do
        local target = FindPlayer(playerName)
        if not target then task.wait(0.3); continue end
        local tc = target.Character; local c = LocalPlayer.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 and root then
            local saved = root.CFrame
            local t0 = tick()
            while tick() - t0 < 0.15 and State.runtime.loopKillFast and tr.Parent do
                root.CFrame = tr.CFrame * CFrame.new(0,0,1.5)
                root.Velocity = Vector3.zero
                pcall(function()
                    ge.SetNetworkOwner:FireServer(tr, root.CFrame)
                    th:ChangeState(Enum.HumanoidStateType.Dead)
                    th.Health = 0
                    if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false) end
                    if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(tr) end
                end)
                RunService.Heartbeat:Wait()
            end
            root.CFrame = saved; root.Velocity = Vector3.zero
            task.wait(0.4)
        else
            task.wait(0.3)
        end
    end
end

-- ================= LOOP KILL =================
local function LoopKill(playerName)
    local ge = GetGrabEvents()
    if not ge then return end
    while State.runtime.loopKill do
        local target = FindPlayer(playerName)
        if not target then task.wait(0.5); continue end
        local tc = target.Character; local c = LocalPlayer.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 and root then
            local saved = root.CFrame
            local t0 = tick()
            while tick() - t0 < 0.35 and State.runtime.loopKill and tr.Parent do
                root.CFrame = tr.CFrame * CFrame.new(0,0,2)
                root.Velocity = Vector3.zero
                pcall(function()
                    ge.SetNetworkOwner:FireServer(tr, root.CFrame)
                    th:ChangeState(Enum.HumanoidStateType.Dead)
                    th.Health = 0
                    if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false) end
                    if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(tr) end
                end)
                RunService.Heartbeat:Wait()
            end
            root.CFrame = saved; root.Velocity = Vector3.zero
            task.wait(1.2)
        else
            task.wait(0.5)
        end
    end
end

-- ================= RAGDOLL (Pallet) =================
local function PalletRagdoll(playerName)
    local target = FindPlayer(playerName)
    if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local ge = GetGrabEvents()
    if not ge then return end
    local spawnPos = CFrame.new(0, 800000, 0)
    pcall(function() ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", spawnPos, Vector3.zero) end)
    local pallet
    local t0 = tick()
    repeat
        local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        pallet = toys and toys:FindFirstChild("PalletLightBrown")
        RunService.Heartbeat:Wait()
    until pallet or not State.runtime.rogdoll or tick() - t0 > 10
    if not pallet then return end
    local soundPart = pallet:FindFirstChild("SoundPart")
    if not soundPart then return end
    soundPart.CanCollide = false; soundPart.Anchored = false
    local function grabPart(part)
        pcall(function()
            ge.SetNetworkOwner:FireServer(part, part.CFrame)
            if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false) end
            if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(part) end
        end)
    end
    grabPart(soundPart)
    while State.runtime.rogdoll do
        for i = 1, 20 do RunService.Heartbeat:Wait() end
        local ct = Players:FindFirstChild(playerName)
        if not ct then break end
        local head = ct.Character and ct.Character:FindFirstChild("Head")
        if head then
            soundPart.CFrame = CFrame.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)
            soundPart.AssemblyLinearVelocity = Vector3.zero
            soundPart.AssemblyAngularVelocity = Vector3.new(1000,1000,1000)
            grabPart(soundPart); soundPart.CanCollide = true
            for i = 1, 3 do RunService.Heartbeat:Wait() end
            soundPart.CanCollide = false; soundPart.CFrame = spawnPos; soundPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
    pcall(function() ReplicatedStorage.MenuToys.DestroyToy:FireServer(pallet) end)
    if pallet.Parent then pallet:Destroy() end
end

-- ================= SNOWBALL RAGDOLL =================
local function SnowballRagdoll(playerName)
    local spawnToy = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    while State.runtime.rogdoll do
        local target = Players:FindFirstChild(playerName)
        if not target then task.wait(0.5)
        else
            local tc = target.Character
            local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
            if torso then
                local offset = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
                pcall(function() spawnToy:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero) end)
                local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
                if toys then
                    for _, child in ipairs(toys:GetChildren()) do
                        if child.Name == "BallSnowball" and child.Parent then
                            local pp = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                            if pp then pp.CFrame = torso.CFrame * CFrame.new(offset); pp.AssemblyLinearVelocity = Vector3.zero; pp.AssemblyAngularVelocity = Vector3.zero end
                        end
                    end
                end
            end
            task.wait()
        end
    end
end

-- ================= TELEPORT =================
local function TeleportTo(playerName)
    local target = FindPlayer(playerName)
    if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    local root = GetRoot(LocalPlayer)
    if tr and root then
        root.CFrame = tr.CFrame * CFrame.new(0,0,3)
        root.Velocity = Vector3.zero
        Notify("Rose","Teleported to " .. target.Name,2)
    end
end

-- ================= UI =================
local window = Library:CreateWindow({ Title = "Rose", Footer = "FTAP Cheat", Center = true, AutoShow = true })
local tab = window:AddTab("Main")
local tab2 = window:AddTab("Fling")
local tab3 = window:AddTab("Visuals")
local tabF = window:AddTab("Fun")
local tabD = window:AddTab("Defence")
local tab4 = window:AddTab("Settings")

-- Movement group
local gMove = tab:AddLeftGroupbox("Movement")
gMove:AddToggle("SpeedToggle", { Text = "Speed", Default = false, Callback = function(v) State.runtime.speed = v end })
gMove:AddSlider("SpeedSlider", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0, Callback = function(v) State.runtime.walkSpeed = v end })
gMove:AddToggle("FlyToggle", { Text = "Fly", Default = false, Callback = function(v) State.runtime.fly = v end })
gMove:AddSlider("FlySpeedSlider", { Text = "Fly Speed", Default = 60, Min = 20, Max = 400, Rounding = 0, Callback = function(v) State.runtime.flySpeed = v end })
gMove:AddToggle("NoclipToggle", { Text = "Noclip", Default = false, Callback = function(v) State.runtime.noclip = v end })
gMove:AddToggle("AntiVoidToggle", { Text = "Anti-Void", Default = false, Callback = function(v) State.runtime.antiVoid = v end })
gMove:AddToggle("AntiGrabToggle", { Text = "Anti-Grab", Default = false, Callback = function(v) State.runtime.antiGrab = v end })

-- ================= BLOB KICK (from Sunapse) =================
local function BlobKick(playerName)
    local target = FindPlayer(playerName)
    if not target or target == LocalPlayer then Notify("Rose","Player not found",2); return end
    local c = LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local seat = hum.SeatPart
    if not seat or not seat.Parent or seat.Parent.Name ~= "CreatureBlobman" then
        Notify("Rose","Sit in Blobman first",3); return
    end
    local blob = seat.Parent
    local sc = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
    local rd = blob:FindFirstChild("RightDetector")
    if not sc or not rd then Notify("Rose","Blob parts missing",3); return end
    local rw = rd:FindFirstChild("RightWeld")
    local grab = sc:FindFirstChild("CreatureGrab")
    local drop = sc:FindFirstChild("CreatureDrop")
    if not rw or not grab or not drop then Notify("Rose","Blob parts missing",3); return end
    State.runtime.blobKick = true
    Notify("Rose","Blob Kick ON",2)
    while State.runtime.blobKick do
        local tc = target.Character
        local tr = tc and tc:FindFirstChild("HumanoidRootPart")
        local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if not tr or not th or th.Health <= 0 then task.wait(0.15)
        else
            local assembly = tr.AssemblyRootPart or tr
            if not (assembly.Massless or th.SeatPart) then
                pcall(function() drop:FireServer(rw) end)
                -- take ownership
                local ge = GetGrabEvents()
                if ge and ge:FindFirstChild("SetNetworkOwner") then
                    for i = 1, 6 do pcall(function() ge.SetNetworkOwner:FireServer(tr, tr.CFrame) end) end
                end
                task.wait(0.35)
                pcall(function()
                    rw.Enabled = false
                    if rd:FindFirstChild("RightAlignOrientation") then rd.RightAlignOrientation.Enabled = false; rd.RightAlignOrientation.Attachment0 = nil end
                    rw.Attachment0 = nil
                    tr.CFrame = root.CFrame * CFrame.new(0,5,-20)
                    tr.AssemblyLinearVelocity = Vector3.zero
                end)
                local ap = Instance.new("AlignPosition"); ap.Name="RoseAlignPos"; ap.Mode=Enum.PositionAlignmentMode.OneAttachment
                ap.ApplyAtCenterOfMass=true; ap.MaxForce=1e9; ap.Responsiveness=200; ap.Attachment0= (tr:FindFirstChild("RootAttachment") or Instance.new("Attachment", tr)); ap.Parent=tr
                local ao = Instance.new("AlignOrientation"); ao.Name="RoseAlignOri"; ao.Mode=Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque=1e9; ao.Responsiveness=200; ao.Attachment0=tr:FindFirstChild("RootAttachment"); ao.Parent=tr
                local placeCF = root.CFrame * CFrame.new(0,5,-20)
                ap.Position = placeCF.Position; ao.CFrame = placeCF - placeCF.Position
                task.wait(0.35)
                pcall(function() grab:FireServer(nil, tr, rw) end)
                task.wait(); pcall(function() grab:FireServer(nil, tr, rw) end)
                pcall(function() grab:FireServer(nil, root, rw) end)
                local holdEnd = os.clock() + 1.8
                while os.clock() < holdEnd and State.runtime.blobKick do
                    if tr.Parent then
                        pcall(function()
                            tr.CFrame = placeCF
                            tr.AssemblyLinearVelocity = Vector3.zero
                            if ap.Parent then ap.Position = placeCF.Position end
                        end)
                    end
                    RunService.Heartbeat:Wait()
                end
                pcall(function()
                    if ap.Parent then ap:Destroy() end
                    if ao.Parent then ao:Destroy() end
                    if rw and rw.Parent then rw.Attachment0 = nil; rw.Enabled = true end
                end)
                task.wait(0.1)
            end
        end
    end
    State.runtime.blobKick = false
    Notify("Rose","Blob Kick OFF",2)
end

-- Kick All
local function KickAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            State.runtime.kick = true
            task.spawn(function() KickLoop(p.Name) end)
        end
    end
    Notify("Rose","Kicking all players",2)
end

-- Fling group
local gFling = tab2:AddLeftGroupbox("Fling")
local playerList = gFling:AddDropdown("TargetPlayer", { Text = "Target", Values = GetPlayerNames(), Default = 1 })
gFling:AddButton("Refresh", { Text = "Refresh Players", Func = function() Options.TargetPlayer:SetValues(GetPlayerNames()) end })
gFling:AddToggle("KickToggle", { Text = "Kick (hold)", Default = false, Callback = function(v)
    State.runtime.kick = v
    if v then
        local name = Options.TargetPlayer.Value
        task.spawn(function() KickLoop(name) end)
    end
end })
gFling:AddSlider("KickHeight", { Text = "Kick Height", Default = 22, Min = 5, Max = 100, Rounding = 0, Callback = function(v) State.runtime.kickHeight = v end })
gFling:AddToggle("LoopKillToggle", { Text = "Loop Kill", Default = false, Callback = function(v)
    State.runtime.loopKill = v
    if v then
        local name = Options.TargetPlayer.Value
        task.spawn(function() LoopKill(name) end)
    end
end })
gFling:AddToggle("LoopKillFastToggle", { Text = "Loop Kill (Fast)", Default = false, Callback = function(v)
    State.runtime.loopKillFast = v
    if v then
        local name = Options.TargetPlayer.Value
        task.spawn(function() LoopKillFast(name) end)
    end
end })
gFling:AddToggle("BlobKickToggle", { Text = "Blob Kick (in blobman)", Default = false, Callback = function(v)
    State.runtime.blobKick = v
    if v then
        local name = Options.TargetPlayer.Value
        task.spawn(function() BlobKick(name) end)
    end
end })
gFling:AddButton("Kick All", { Text = "Kick All Players", Func = function() KickAll() end })
gFling:AddToggle("RogdollToggle", { Text = "Ragdoll (Pallet)", Default = false, Callback = function(v)
    State.runtime.rogdoll = v
    if v then
        local name = Options.TargetPlayer.Value
        local method = Options.RagdollMethod.Value
        task.spawn(function()
            if method == "Pallet" then PalletRagdoll(name) else SnowballRagdoll(name) end
        end)
    end
end })
gFling:AddDropdown("RagdollMethod", { Text = "Ragdoll Method", Values = {"Pallet","Snowball"}, Default = 1 })
gFling:AddButton("Teleport", { Text = "Teleport to Target", Func = function()
    TeleportTo(Options.TargetPlayer.Value)
end })

-- Visuals group
local gVis = tab3:AddLeftGroupbox("Visuals")
gVis:AddToggle("ESPToggle", { Text = "ESP", Default = true, Callback = function(v) State.runtime.espOn = v end })
gVis:AddToggle("FullBrightToggle", { Text = "FullBright", Default = false, Callback = function(v) State.runtime.fullBright = v end })
gVis:AddSlider("FOVSlider", { Text = "FOV", Default = 70, Min = 50, Max = 120, Rounding = 0, Callback = function(v) State.runtime.fov = v end })

-- ================= DEFENCE LOGIC =================
State.runtime.antiExplosion = false
State.runtime.antiPaint = false
State.runtime.antiSticky = false
State.runtime.antiSnowball = false
State.runtime.antiBanana = false
State.runtime.antiPoison = false
State.runtime.antiOwnership = false
State.runtime.antiBlobman = false
State.runtime.antiKick = false
State.runtime.antiBurn = false
State.runtime.antiFreeze = false
State.runtime.gucciAntiGrab = false
State.runtime.thirdPerson = false
State.runtime.poseTarget = nil
State.runtime.pcldHighlight = false
State.runtime.lineLag = false
State.runtime.packetSpam = false
State.runtime.gucciType = "Blobman"

-- anti-explosion: remove explosion effects / velocity spikes
RunService.Heartbeat:Connect(function()
    if State.runtime.antiExplosion then
        local root = GetRoot(LocalPlayer)
        if root then
            local vel = root.Velocity
            if vel.Magnitude > 150 then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end
        end
    end
end)

-- anti-kick: destroy ninja kunai/shuriken toys targeting you
RunService.Heartbeat:Connect(function()
    if State.runtime.antiKick then
        local myToys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        -- destroy incoming shurikens from others
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "NinjaShuriken" or obj.Name == "NinjaKunai" then
                local owner = obj:FindFirstAncestorWhichIsA("Model")
                if owner and owner.Name ~= LocalPlayer.Name then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end)

-- anti-blobman: destroy other players' blobmen
RunService.Heartbeat:Connect(function()
    if State.runtime.antiBlobman then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local toys = Workspace:FindFirstChild(p.Name .. "SpawnedInToys")
                if toys then
                    for _, c in ipairs(toys:GetChildren()) do
                        if c.Name == "CreatureBlobman" then
                            pcall(function()
                                if ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy") then
                                    ReplicatedStorage.MenuToys.DestroyToy:FireServer(c)
                                end
                                c:Destroy()
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- anti-paint: remove paint parts on character
RunService.Heartbeat:Connect(function()
    if State.runtime.antiPaint then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") and (d.Name:lower():find("paint") or d:FindFirstChild("Paint")) then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
end)

-- anti-poison: remove poison status / mushroom effects
RunService.Heartbeat:Connect(function()
    if State.runtime.antiPoison then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d.Name:lower():find("poison") then pcall(function() d:Destroy() end) end
            end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end
end)

-- anti-sticky: remove sticky constraints
RunService.Heartbeat:Connect(function()
    if State.runtime.antiSticky then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("WeldConstraint") or d:IsA("HingeConstraint") or d:IsA("SpringConstraint") then
                    if d.Name:lower():find("stick") then pcall(function() d:Destroy() end) end
                end
            end
        end
    end
end)

-- anti-snowball / anti-banana: destroy incoming projectiles
RunService.Heartbeat:Connect(function()
    if State.runtime.antiSnowball or State.runtime.antiBanana then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (State.runtime.antiSnowball and obj.Name == "BallSnowball") or (State.runtime.antiBanana and obj.Name:lower():find("banana")) then
                local anc = obj:FindFirstAncestor(LocalPlayer.Name .. "SpawnedInToys")
                if not anc then pcall(function() obj:Destroy() end) end
            end
        end
    end
end)

-- anti-ownership: reclaim network ownership of your character
RunService.Heartbeat:Connect(function()
    if State.runtime.antiOwnership then
        local root = GetRoot(LocalPlayer)
        if root then
            local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
            local so = ge and ge:FindFirstChild("SetNetworkOwner")
            if so then pcall(function() so:FireServer(root, root.CFrame) end) end
        end
    end
end)

-- anti-burn: heal + remove fire
RunService.Heartbeat:Connect(function()
    if State.runtime.antiBurn then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then pcall(function() d:Destroy() end) end
            end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end
end)

-- anti-freeze: remove ice/freeze effects
RunService.Heartbeat:Connect(function()
    if State.runtime.antiFreeze then
        local c = LocalPlayer.Character
        if c then
            for _, d in ipairs(c:GetDescendants()) do
                if d.Name:lower():find("freeze") or d.Name:lower():find("ice") then pcall(function() d:Destroy() end) end
            end
            local root = c:FindFirstChild("HumanoidRootPart")
            if root then root.Anchored = false end
        end
    end
end)

-- ================= GUCCI ANTI-GRAB =================
local function FindNearestVehicleSeat(pos)
    local best, bd = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
            if obj.Occupant == nil then
                local d = (obj.Position - pos).Magnitude
                if d < bd and d < 80 then bd = d; best = obj end
            end
        end
    end
    return best
end

RunService.Heartbeat:Connect(function()
    if not State.runtime.gucciAntiGrab then return end
    local c = LocalPlayer.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    -- detect grab: foreign AlignPosition/BodyPosition on character
    local grabbed = false
    for _, d in ipairs(c:GetDescendants()) do
        if (d:IsA("AlignPosition") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and d.Name ~= "RoseAlign" then
            grabbed = true; break
        end
    end
    if not grabbed then return end
    -- try to sit in nearest vehicle seat to break grab
    local seat = FindNearestVehicleSeat(root.Position)
    if seat then
        pcall(function()
            hum.Sit = true
            root.CFrame = seat.CFrame
            seat:Sit(hum)
        end)
    else
        -- fallback: teleport up and zero velocity
        pcall(function()
            root.CFrame = root.CFrame + Vector3.new(0, 15, 0)
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end)
    end
end)

-- ================= THIRD PERSON =================
RunService.RenderStepped:Connect(function()
    if State.runtime.thirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        -- push camera back
        local cam = Camera
        if cam then
            local root = GetRoot(LocalPlayer)
            if root then
                local offset = root.CFrame * CFrame.new(0, 2, 8)
                cam.CFrame = CFrame.new(offset.Position, root.Position + Vector3.new(0,2,0))
            end
        end
    end
end)

-- ================= PCLD HIGHLIGHT =================
RunService.RenderStepped:Connect(function()
    if not State.runtime.pcldHighlight then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("playercharacterlocationdetector") or obj.Name:lower():find("partesp") then
            if obj:IsA("BasePart") then
                obj.Color = Color3.fromRGB(255, 100, 200)
                obj.Material = Enum.Material.Neon
                obj.Transparency = 0.3
            end
        end
    end
end)

-- ================= POSE (sit others on you) =================
local function PosePlayer(playerName)
    local target = FindPlayer(playerName)
    if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    local root = GetRoot(LocalPlayer)
    if tr and root then
        -- teleport target onto your shoulder/lap
        tr.CFrame = root.CFrame * CFrame.new(0, 2, -1.5)
        tr.Velocity = Vector3.zero
        -- disable their movement
        local th = target.Character:FindFirstChildOfClass("Humanoid")
        if th then th.PlatformStand = true end
        Notify("Rose","Posed " .. target.Name .. " on you",2)
    end
end

local function UnposePlayer(playerName)
    local target = FindPlayer(playerName)
    if not target or not target.Character then return end
    local th = target.Character:FindFirstChildOfClass("Humanoid")
    if th then th.PlatformStand = false end
    Notify("Rose","Unposed " .. (target.Name or ""),2)
end

-- ================= LINE LAG =================
RunService.Heartbeat:Connect(function()
    if not State.runtime.lineLag then return end
    local ge = GetGrabEvents()
    if not ge then return end
    local c = LocalPlayer.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return end
    -- spam create/destroy grab lines on self to lag
    for i = 1, 20 do
        pcall(function()
            if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(root, Vector3.zero, root.Position, false) end
            if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(root) end
            if ge.ExtendGrabLine then ge.ExtendGrabLine:FireServer(root) end
        end)
    end
end)

-- ================= PACKET SPAM =================
RunService.Heartbeat:Connect(function()
    if not State.runtime.packetSpam then return end
    local ge = GetGrabEvents()
    local big = string.rep("A", 50000)
    -- spam large payloads across available remotes
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(big) end)
        end
    end
    if ge then
        for _, r in ipairs(ge:GetChildren()) do
            if r:IsA("RemoteEvent") then
                pcall(function() r:FireServer(big) end)
            end
        end
    end
end)

-- Fun UI
local gFun = tabF:AddLeftGroupbox("Fun")
gFun:AddToggle("ThirdPerson", { Text = "Third Person", Default = false, Callback = function(v) State.runtime.thirdPerson = v end })
gFun:AddToggle("PCLDHighlight", { Text = "PCLD Highlight", Default = false, Callback = function(v) State.runtime.pcldHighlight = v end })
gFun:AddToggle("LineLag", { Text = "Line Lag", Default = false, Callback = function(v) State.runtime.lineLag = v end })
gFun:AddToggle("PacketSpam", { Text = "Packet Spam (MB/s)", Default = false, Callback = function(v) State.runtime.packetSpam = v end })
local poseDrop = gFun:AddDropdown("PoseTarget", { Text = "Pose Target", Values = GetPlayerNames(), Default = 1 })
gFun:AddButton("Refresh", { Text = "Refresh Players", Func = function() Options.PoseTarget:SetValues(GetPlayerNames()) end })
gFun:AddButton("Pose", { Text = "Sit on me", Func = function() PosePlayer(Options.PoseTarget.Value) end })
gFun:AddButton("Unpose", { Text = "Release", Func = function() UnposePlayer(Options.PoseTarget.Value) end })

-- Defence UI
local gDef = tabD:AddLeftGroupbox("Defence")
gDef:AddToggle("AntiGrabD", { Text = "Anti-Grab", Default = false, Callback = function(v) State.runtime.antiGrab = v end })
gDef:AddToggle("AntiVoidD", { Text = "Anti-Void", Default = false, Callback = function(v) State.runtime.antiVoid = v end })
gDef:AddToggle("AntiExplosionD", { Text = "Anti-Explosion", Default = false, Callback = function(v) State.runtime.antiExplosion = v end })
gDef:AddToggle("AntiBurnD", { Text = "Anti-Burn", Default = false, Callback = function(v) State.runtime.antiBurn = v end })
gDef:AddToggle("AntiFreezeD", { Text = "Anti-Freeze", Default = false, Callback = function(v) State.runtime.antiFreeze = v end })
gDef:AddToggle("AntiKickD", { Text = "Anti-Kick", Default = false, Callback = function(v) State.runtime.antiKick = v end })
gDef:AddToggle("AntiPaintD", { Text = "Anti-Paint", Default = false, Callback = function(v) State.runtime.antiPaint = v end })
gDef:AddToggle("AntiStickyD", { Text = "Anti-Sticky", Default = false, Callback = function(v) State.runtime.antiSticky = v end })
gDef:AddToggle("AntiSnowballD", { Text = "Anti-Snowball", Default = false, Callback = function(v) State.runtime.antiSnowball = v end })
gDef:AddToggle("AntiBananaD", { Text = "Anti-Banana", Default = false, Callback = function(v) State.runtime.antiBanana = v end })
gDef:AddToggle("AntiPoisonD", { Text = "Anti-Poison", Default = false, Callback = function(v) State.runtime.antiPoison = v end })
gDef:AddToggle("AntiOwnershipD", { Text = "Anti-Ownership", Default = false, Callback = function(v) State.runtime.antiOwnership = v end })
gDef:AddToggle("AntiBlobmanD", { Text = "Anti-Blobman", Default = false, Callback = function(v) State.runtime.antiBlobman = v end })
gDef:AddToggle("GucciAntiGrabD", { Text = "Gucci Anti-Grab (vehicle)", Default = false, Callback = function(v) State.runtime.gucciAntiGrab = v end })
gDef:AddDropdown("GucciTypeD", { Text = "Gucci Vehicle", Values = {"Blobman","Train","Tractor","Any"}, Default = 1, Callback = function(v) State.runtime.gucciType = v end })

-- Settings group
local gSet = tab4:AddLeftGroupbox("Settings")
gSet:AddLabel("Rose v1.0 - FTAP Cheat")
gSet:AddButton("Unload", { Text = "Unload Script", Func = function() Library:Unload() end })

-- keybind for menu
Library.ToggleKeybind = Options and Options.MenuKeybind
local menuKey = gSet:AddKeybind("MenuKeybind", { Text = "Menu Key", Default = "RightShift", Mode = "Toggle", Callback = function() end })
menuKey:OnClick(function() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("Rose")
SaveManager:SetFolder("Rose")
SaveManager:BuildConfigSection(tab4)
ThemeManager:ApplyToTab(tab4)

Notify("Rose", "Loaded successfully. Enjoy!", 5)
print("[Rose] loaded")
