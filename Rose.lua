-- Rose - FTAP Cheat (menu_lib based, self-contained)
-- Load via: loadstring(game:HttpGet("YOUR_RAW_URL"))()

-- ================= LOAD MENU LIB =================
local libSource
if readfile and pcall(readfile, "menu_lib.lua") then
    local ok, res = pcall(readfile, "menu_lib.lua")
    if ok and res and #res > 0 then libSource = res end
end
if not libSource then
    local ok, res = pcall(function() return game:HttpGet("https://endoris.x02.me/i/ZY5F.lua") end)
    if ok and res then libSource = res end
end
local func, err = loadstring(libSource or "")
if not func then warn("Rose lib loadstring fail: " .. tostring(err)); return end
local ok2, runErr = pcall(func)
if not ok2 then warn("Rose lib runtime fail: " .. tostring(runErr)); return end
if not library then warn("Rose: library is nil"); return end

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

-- defaults
for k, v in pairs({
    speed=false, walkSpeed=16, fly=false, flySpeed=60, noclip=false, antiVoid=false, antiGrab=false,
    kick=false, kickHeight=22, loopKill=false, loopKillFast=false, blobKick=false, rogdoll=false,
    espOn=true, fullBright=false, fov=70, thirdPerson=false, pcldHighlight=false,
    lineLag=false, packetSpam=false, antiExplosion=false, antiBurn=false, antiFreeze=false,
    antiKick=false, antiPaint=false, antiSticky=false, antiSnowball=false, antiBanana=false,
    antiPoison=false, antiOwnership=false, antiBlobman=false, gucciAntiGrab=false,
}) do State.runtime[k] = v end

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
local function Notify(t, d, time) pcall(function() library:Notification({Title=t or "Rose", Description=d or "", Time=time or 3}) end) end

-- Movement
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
            if not bv then bv = Instance.new("BodyVelocity"); bv.Name="Rose_Fly"; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero; bv.Parent=root end
            local cam = Camera; local dir = Vector3.zero
            local UIS = game:GetService("UserInputService")
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * G("flySpeed")
        end
    else
        local root = GetRoot(LocalPlayer)
        if root then local bv = root:FindFirstChild("Rose_Fly"); if bv then bv:Destroy() end end
    end
    if G("antiVoid") then
        local root = GetRoot(LocalPlayer)
        if root and root.Position.Y < -50 then root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z); root.Velocity = Vector3.zero end
    end
    if G("antiGrab") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BodyPosition") or d:IsA("BodyGyro") or d:IsA("AlignPosition") or d:IsA("AlignOrientation") then pcall(function() d:Destroy() end) end end end
    end
end)

RunService.RenderStepped:Connect(function()
    Camera.FieldOfView = G("fov")
    if G("fullBright") then Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=100000; Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255) end
    if G("thirdPerson") then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local root = GetRoot(LocalPlayer)
        if root then
            local offset = root.CFrame * CFrame.new(0, 2, 8)
            Camera.CFrame = CFrame.new(offset.Position, root.Position + Vector3.new(0,2,0))
        end
    end
    if G("pcldHighlight") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("playercharacterlocationdetector") or obj.Name:lower():find("partesp") then
                if obj:IsA("BasePart") then obj.Color=Color3.fromRGB(255,100,200); obj.Material=Enum.Material.Neon; obj.Transparency=0.3 end
            end
        end
    end
end)

-- ESP
local ESPs = {}
local function CreateESP(player)
    local box = Drawing.new("Square"); box.Thickness=1; box.Color=Color3.fromRGB(255,80,120); box.Filled=false; box.Visible=false
    local name = Drawing.new("Text"); name.Size=13; name.Color=Color3.fromRGB(255,255,255); name.Center=true; name.Outline=true; name.Visible=false
    local dist = Drawing.new("Text"); dist.Size=12; dist.Color=Color3.fromRGB(220,220,220); dist.Center=true; dist.Outline=true; dist.Visible=false
    ESPs[player] = {Box=box, Name=name, Dist=dist}
end
local function RemoveESP(player)
    local e = ESPs[player]; if e then for _, d in pairs(e) do pcall(function() d:Remove() end) end; ESPs[player]=nil end
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.RenderStepped:Connect(function()
    if not G("espOn") then for _, e in pairs(ESPs) do for _, d in pairs(e) do d.Visible=false end end; return end
    for player, e in pairs(ESPs) do
        local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local d = (Camera.CFrame.Position - root.Position).Magnitude
            if onScreen and d < 3000 then
                local head = char:FindFirstChild("Head")
                local hPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0)) or pos
                local fPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                local height = math.abs(hPos.Y - fPos.Y); local width = height * 0.5
                e.Box.Position = Vector2.new(pos.X - width/2, hPos.Y); e.Box.Size = Vector2.new(width, height); e.Box.Visible = true
                e.Name.Text = player.Name; e.Name.Position = Vector2.new(pos.X, hPos.Y - 16); e.Name.Visible = true
                e.Dist.Text = string.format("%.0fm", d); e.Dist.Position = Vector2.new(pos.X, hPos.Y + height + 2); e.Dist.Visible = true
            else for _, dd in pairs(e) do dd.Visible = false end end
        else for _, dd in pairs(e) do dd.Visible = false end end
    end
end)

-- KickLoop
local function KickLoop(playerName)
    local ge = GetGrabEvents(); if not ge then Notify("Rose","GrabEvents not found",3); return end
    local setNO = ge:FindFirstChild("SetNetworkOwner"); local destroyGL = ge:FindFirstChild("DestroyGrabLine"); local createGL = ge:FindFirstChild("CreateGrabLine")
    if not setNO then Notify("Rose","SetNetworkOwner not found",3); return end
    local lastGrab = 0
    while G("kick") do
        local target = FindPlayer(playerName); if not target or not target.Parent then break end
        local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tc = target.Character; local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if not tc or not th or th.Health <= 0 then RunService.Heartbeat:Wait(); continue end
        local tr = tc:FindFirstChild("HumanoidRootPart")
        if not (c and root) or not tr then RunService.Heartbeat:Wait(); continue end
        if (tr.Position - root.Position).Magnitude > 30 then pcall(function() c:PivotTo(tr.CFrame * CFrame.new(0,2,4)) end); RunService.Heartbeat:Wait(); continue end
        local kickPos = (root.CFrame * CFrame.new(0, G("kickHeight"), 0)).Position
        if not tr:FindFirstChild("RoseAlign") then
            for _, ch in pairs(tr:GetChildren()) do
                if (ch:IsA("BodyPosition") or ch:IsA("BodyGyro") or ch:IsA("AlignPosition") or ch:IsA("AlignOrientation")) and ch.Name ~= "RoseAlign" and ch.Name ~= "RoseRot" then pcall(function() ch:Destroy() end) end
            end
            local att = Instance.new("Attachment", tr); att.Name = "RoseAtt0"
            local aatt = Instance.new("Attachment", Workspace.Terrain); aatt.Name = "RoseAtt1"
            local ap = Instance.new("AlignPosition"); ap.Name = "RoseAlign"; ap.Attachment0 = att; ap.Attachment1 = aatt; ap.MaxForce = math.huge; ap.Responsiveness = 300; ap.Parent = tr
            local ao = Instance.new("AlignOrientation"); ao.Name = "RoseRot"; ao.Attachment0 = att; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque = math.huge; ao.Responsiveness = 300; ao.Parent = tr
        end
        local ra = tr:FindFirstChild("RoseAlign"); if ra and ra.Attachment1 then ra.Attachment1.WorldPosition = kickPos end
        local rr = tr:FindFirstChild("RoseRot"); if rr then rr.CFrame = CFrame.Angles(0,0,0) end
        pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.zero; tr.AssemblyAngularVelocity = Vector3.zero end)
        local now = tick()
        if now - lastGrab > 0.05 then
            pcall(function() for i = 1, 3 do setNO:FireServer(tr, tr.CFrame) end end)
            if createGL then pcall(function() createGL:FireServer(tr, kickPos) end) end
            if destroyGL then pcall(function() destroyGL:FireServer(tr) end) end
            pcall(function() tr.AssemblyLinearVelocity = Vector3.new(0, 200, 0) end)
            lastGrab = now
        end
        RunService.Heartbeat:Wait()
    end
end

-- LoopKill
local function LoopKill(playerName)
    local ge = GetGrabEvents(); if not ge then return end
    while G("loopKill") do
        local target = FindPlayer(playerName); if not target then task.wait(0.5); continue end
        local tc = target.Character; local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart"); local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 and root then
            local saved = root.CFrame; local t0 = tick()
            while tick() - t0 < 0.35 and G("loopKill") and tr.Parent do
                root.CFrame = tr.CFrame * CFrame.new(0,0,2); root.Velocity = Vector3.zero
                pcall(function()
                    ge.SetNetworkOwner:FireServer(tr, root.CFrame); th:ChangeState(Enum.HumanoidStateType.Dead); th.Health = 0
                    if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false) end
                    if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(tr) end
                end)
                RunService.Heartbeat:Wait()
            end
            root.CFrame = saved; root.Velocity = Vector3.zero; task.wait(1.2)
        else task.wait(0.5) end
    end
end

-- LoopKillFast
local function LoopKillFast(playerName)
    local ge = GetGrabEvents(); if not ge then return end
    while G("loopKillFast") do
        local target = FindPlayer(playerName); if not target then task.wait(0.3); continue end
        local tc = target.Character; local c = LocalPlayer.Character; local root = c and c:FindFirstChild("HumanoidRootPart")
        local tr = tc and tc:FindFirstChild("HumanoidRootPart"); local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if tr and th and th.Health > 0 and root then
            local saved = root.CFrame; local t0 = tick()
            while tick() - t0 < 0.15 and G("loopKillFast") and tr.Parent do
                root.CFrame = tr.CFrame * CFrame.new(0,0,1.5); root.Velocity = Vector3.zero
                pcall(function()
                    ge.SetNetworkOwner:FireServer(tr, root.CFrame); th:ChangeState(Enum.HumanoidStateType.Dead); th.Health = 0
                    if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(tr, Vector3.zero, tr.Position, false) end
                    if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(tr) end
                end)
                RunService.Heartbeat:Wait()
            end
            root.CFrame = saved; root.Velocity = Vector3.zero; task.wait(0.4)
        else task.wait(0.3) end
    end
end

-- BlobKick
local function BlobKick(playerName)
    local target = FindPlayer(playerName); if not target or target == LocalPlayer then Notify("Rose","Player not found",2); return end
    local c = LocalPlayer.Character; local hum = c and c:FindFirstChildOfClass("Humanoid"); local root = c and c:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local seat = hum.SeatPart
    if not seat or not seat.Parent or seat.Parent.Name ~= "CreatureBlobman" then Notify("Rose","Sit in Blobman first",3); return end
    local blob = seat.Parent; local sc = blob:FindFirstChild("BlobmanSeatAndOwnerScript"); local rd = blob:FindFirstChild("RightDetector")
    if not sc or not rd then Notify("Rose","Blob parts missing",3); return end
    local rw = rd:FindFirstChild("RightWeld"); local grab = sc:FindFirstChild("CreatureGrab"); local drop = sc:FindFirstChild("CreatureDrop")
    if not rw or not grab or not drop then Notify("Rose","Blob parts missing",3); return end
    R("blobKick", true); Notify("Rose","Blob Kick ON",2)
    while G("blobKick") do
        local tc = target.Character; local tr = tc and tc:FindFirstChild("HumanoidRootPart"); local th = tc and tc:FindFirstChildOfClass("Humanoid")
        if not tr or not th or th.Health <= 0 then task.wait(0.15)
        else
            local assembly = tr.AssemblyRootPart or tr
            if not (assembly.Massless or th.SeatPart) then
                pcall(function() drop:FireServer(rw) end)
                local ge = GetGrabEvents()
                if ge and ge:FindFirstChild("SetNetworkOwner") then for i = 1, 6 do pcall(function() ge.SetNetworkOwner:FireServer(tr, tr.CFrame) end) end end
                task.wait(0.35)
                pcall(function() rw.Enabled = false; if rd:FindFirstChild("RightAlignOrientation") then rd.RightAlignOrientation.Enabled = false; rd.RightAlignOrientation.Attachment0 = nil end; rw.Attachment0 = nil; tr.CFrame = root.CFrame * CFrame.new(0,5,-20); tr.AssemblyLinearVelocity = Vector3.zero end)
                local att = tr:FindFirstChild("RootAttachment") or Instance.new("Attachment", tr); att.Name = "RootAttachment"
                local ap = Instance.new("AlignPosition"); ap.Name = "RoseAlignPos"; ap.Mode = Enum.PositionAlignmentMode.OneAttachment; ap.ApplyAtCenterOfMass = true; ap.MaxForce = 1e9; ap.Responsiveness = 200; ap.Attachment0 = att; ap.Parent = tr
                local ao = Instance.new("AlignOrientation"); ao.Name = "RoseAlignOri"; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment; ao.MaxTorque = 1e9; ao.Responsiveness = 200; ao.Attachment0 = att; ao.Parent = tr
                local placeCF = root.CFrame * CFrame.new(0,5,-20)
                ap.Position = placeCF.Position; ao.CFrame = placeCF - placeCF.Position
                task.wait(0.35)
                pcall(function() grab:FireServer(nil, tr, rw) end); task.wait(); pcall(function() grab:FireServer(nil, tr, rw) end); pcall(function() grab:FireServer(nil, root, rw) end)
                local holdEnd = os.clock() + 1.8
                while os.clock() < holdEnd and G("blobKick") do
                    if tr.Parent then pcall(function() tr.CFrame = placeCF; tr.AssemblyLinearVelocity = Vector3.zero; if ap.Parent then ap.Position = placeCF.Position end end) end
                    RunService.Heartbeat:Wait()
                end
                pcall(function() if ap.Parent then ap:Destroy() end; if ao.Parent then ao:Destroy() end; if rw and rw.Parent then rw.Attachment0 = nil; rw.Enabled = true end end)
                task.wait(0.1)
            end
        end
    end
    R("blobKick", false); Notify("Rose","Blob Kick OFF",2)
end

-- Ragdoll Pallet
local function PalletRagdoll(playerName)
    local target = FindPlayer(playerName); if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local ge = GetGrabEvents(); if not ge then return end
    local spawnPos = CFrame.new(0, 800000, 0)
    pcall(function() ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", spawnPos, Vector3.zero) end)
    local pallet, t0 = nil, tick()
    repeat
        local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        pallet = toys and toys:FindFirstChild("PalletLightBrown")
        RunService.Heartbeat:Wait()
    until pallet or not G("rogdoll") or tick() - t0 > 10
    if not pallet then return end
    local soundPart = pallet:FindFirstChild("SoundPart"); if not soundPart then return end
    soundPart.CanCollide = false; soundPart.Anchored = false
    local function grabPart(part) pcall(function() ge.SetNetworkOwner:FireServer(part, part.CFrame); if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false) end; if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(part) end end) end
    grabPart(soundPart)
    while G("rogdoll") do
        for i = 1, 20 do RunService.Heartbeat:Wait() end
        local ct = Players:FindFirstChild(playerName); if not ct then break end
        local head = ct.Character and ct.Character:FindFirstChild("Head")
        if head then
            soundPart.CFrame = CFrame.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)
            soundPart.AssemblyLinearVelocity = Vector3.zero; soundPart.AssemblyAngularVelocity = Vector3.new(1000,1000,1000)
            grabPart(soundPart); soundPart.CanCollide = true
            for i = 1, 3 do RunService.Heartbeat:Wait() end
            soundPart.CanCollide = false; soundPart.CFrame = spawnPos; soundPart.AssemblyAngularVelocity = Vector3.zero
        end
    end
    pcall(function() ReplicatedStorage.MenuToys.DestroyToy:FireServer(pallet) end)
    if pallet.Parent then pallet:Destroy() end
end

-- Snowball ragdoll
local function SnowballRagdoll(playerName)
    local spawnToy = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
    while G("rogdoll") do
        local target = Players:FindFirstChild(playerName)
        if not target then task.wait(0.5)
        else
            local tc = target.Character; local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
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

-- Teleport
local function TeleportTo(playerName)
    local target = FindPlayer(playerName); if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart"); local root = GetRoot(LocalPlayer)
    if tr and root then root.CFrame = tr.CFrame * CFrame.new(0,0,3); root.Velocity = Vector3.zero; Notify("Rose","Teleported",2) end
end

-- Kick All
local function KickAll()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            R("kick", true)
            task.spawn(function() KickLoop(p.Name) end)
        end
    end
    Notify("Rose","Kicking all",2)
end

-- Pose
local function PosePlayer(playerName)
    local target = FindPlayer(playerName); if not target or not target.Character then Notify("Rose","Player not found",2); return end
    local tr = target.Character:FindFirstChild("HumanoidRootPart"); local root = GetRoot(LocalPlayer)
    if tr and root then
        tr.CFrame = root.CFrame * CFrame.new(0, 2, -1.5); tr.Velocity = Vector3.zero
        local th = target.Character:FindFirstChildOfClass("Humanoid"); if th then th.PlatformStand = true end
        Notify("Rose","Posed " .. target.Name,2)
    end
end
local function UnposePlayer(playerName)
    local target = FindPlayer(playerName); if not target or not target.Character then return end
    local th = target.Character:FindFirstChildOfClass("Humanoid"); if th then th.PlatformStand = false end
    Notify("Rose","Unposed",2)
end

-- Line lag / packet spam
RunService.Heartbeat:Connect(function()
    if G("lineLag") then
        local ge = GetGrabEvents(); if not ge then return end
        local root = GetRoot(LocalPlayer); if not root then return end
        for i = 1, 20 do
            pcall(function()
                if ge.CreateGrabLine then ge.CreateGrabLine:FireServer(root, Vector3.zero, root.Position, false) end
                if ge.DestroyGrabLine then ge.DestroyGrabLine:FireServer(root) end
                if ge.ExtendGrabLine then ge.ExtendGrabLine:FireServer(root) end
            end)
        end
    end
    if G("packetSpam") then
        local big = string.rep("A", 50000)
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then pcall(function() remote:FireServer(big) end) end
        end
        local ge = GetGrabEvents()
        if ge then for _, r in ipairs(ge:GetChildren()) do if r:IsA("RemoteEvent") then pcall(function() r:FireServer(big) end) end end end
    end
end)

-- Anti defence extras
RunService.Heartbeat:Connect(function()
    if G("antiExplosion") then
        local root = GetRoot(LocalPlayer)
        if root then local vel = root.Velocity; if vel.Magnitude > 150 then root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end end
    end
    if G("antiKick") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "NinjaShuriken" or obj.Name == "NinjaKunai" then
                local owner = obj:FindFirstAncestorWhichIsA("Model")
                if not owner or owner.Name ~= LocalPlayer.Name then pcall(function() obj:Destroy() end) end
            end
        end
    end
    if G("antiBlobman") then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local toys = Workspace:FindFirstChild(p.Name .. "SpawnedInToys")
                if toys then for _, c in ipairs(toys:GetChildren()) do
                    if c.Name == "CreatureBlobman" then pcall(function()
                        if ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy") then ReplicatedStorage.MenuToys.DestroyToy:FireServer(c) end
                        c:Destroy()
                    end) end
                end end
            end
        end
    end
    if G("antiPaint") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") and (d.Name:lower():find("paint") or d:FindFirstChild("Paint")) then pcall(function() d:Destroy() end) end end end
    end
    if G("antiPoison") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if d.Name:lower():find("poison") then pcall(function() d:Destroy() end) end end
            local hum = c:FindFirstChildOfClass("Humanoid"); if hum then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end
    if G("antiSticky") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if (d:IsA("WeldConstraint") or d:IsA("HingeConstraint") or d:IsA("SpringConstraint")) and d.Name:lower():find("stick") then pcall(function() d:Destroy() end) end end end
    end
    if G("antiSnowball") or G("antiBanana") then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if (G("antiSnowball") and obj.Name == "BallSnowball") or (G("antiBanana") and obj.Name:lower():find("banana")) then
                local anc = obj:FindFirstAncestor(LocalPlayer.Name .. "SpawnedInToys")
                if not anc then pcall(function() obj:Destroy() end) end
            end
        end
    end
    if G("antiOwnership") then
        local root = GetRoot(LocalPlayer)
        if root then local ge = GetGrabEvents(); local so = ge and ge:FindFirstChild("SetNetworkOwner"); if so then pcall(function() so:FireServer(root, root.CFrame) end) end end
    end
    if G("antiBurn") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then pcall(function() d:Destroy() end) end end
            local hum = c:FindFirstChildOfClass("Humanoid"); if hum and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
        end
    end
    if G("antiFreeze") then
        local c = LocalPlayer.Character
        if c then for _, d in ipairs(c:GetDescendants()) do if d.Name:lower():find("freeze") or d.Name:lower():find("ice") then pcall(function() d:Destroy() end) end end
            local root = c:FindFirstChild("HumanoidRootPart"); if root then root.Anchored = false end
        end
    end
    if G("gucciAntiGrab") then
        local c = LocalPlayer.Character
        if c then
            local root = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local grabbed = false
                for _, d in ipairs(c:GetDescendants()) do
                    if (d:IsA("AlignPosition") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and d.Name ~= "RoseAlign" then grabbed = true; break end
                end
                if grabbed then
                    local best, bd = nil, math.huge
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if (obj:IsA("VehicleSeat") or obj:IsA("Seat")) and obj.Occupant == nil then
                            local dd = (obj.Position - root.Position).Magnitude
                            if dd < bd and dd < 80 then bd = dd; best = obj end
                        end
                    end
                    if best then pcall(function() hum.Sit = true; root.CFrame = best.CFrame; best:Sit(hum) end)
                    else pcall(function() root.CFrame = root.CFrame + Vector3.new(0, 15, 0); root.Velocity = Vector3.zero end) end
                end
            end
        end
    end
end)

-- ================= UI =================
local window = library:Window({Text = "Rose"})
local tabMain = window:Tab({Text = "Main"})
local tabFling = window:Tab({Text = "Fling"})
local tabVis = window:Tab({Text = "Visuals"})
local tabFun = window:Tab({Text = "Fun"})
local tabDef = window:Tab({Text = "Defence"})
local tabSet = window:Tab({Text = "Settings"})

-- Main
local sMove = tabMain:Section({Text = "Movement", Side = "Left"})
sMove:Toggle({Text = "Speed", Flag = "Speed", Callback = function(v) R("speed", v) end})
sMove:Slider({Text = "WalkSpeed", Flag = "WalkSpeed", Min = 16, Max = 300, Default = 16, Callback = function(v) R("walkSpeed", v) end})
sMove:Toggle({Text = "Fly", Flag = "Fly", Callback = function(v) R("fly", v) end})
sMove:Slider({Text = "Fly Speed", Flag = "FlySpeed", Min = 20, Max = 400, Default = 60, Callback = function(v) R("flySpeed", v) end})
sMove:Toggle({Text = "Noclip", Flag = "Noclip", Callback = function(v) R("noclip", v) end})
sMove:Toggle({Text = "Anti-Void", Flag = "AntiVoid", Callback = function(v) R("antiVoid", v) end})
sMove:Toggle({Text = "Anti-Grab", Flag = "AntiGrab", Callback = function(v) R("antiGrab", v) end})

-- Fling
local sFling = tabFling:Section({Text = "Fling", Side = "Left"})
local targetName = GetPlayerNames()[1] or ""
sFling:Dropdown({Text = "Target", Flag = "Target", List = GetPlayerNames(), Default = targetName})
sFling:Button({Text = "Refresh Players", Callback = function()
    -- re-open dropdown not supported; notify
    Notify("Rose", "Re-execute script to refresh list", 2)
end})
sFling:Toggle({Text = "Kick (hold)", Flag = "Kick", Callback = function(v)
    R("kick", v); if v then task.spawn(function() KickLoop(targetName) end) end
end})
sFling:Slider({Text = "Kick Height", Flag = "KickHeight", Min = 5, Max = 100, Default = 22, Callback = function(v) R("kickHeight", v) end})
sFling:Toggle({Text = "Loop Kill", Flag = "LoopKill", Callback = function(v)
    R("loopKill", v); if v then task.spawn(function() LoopKill(targetName) end) end
end})
sFling:Toggle({Text = "Loop Kill (Fast)", Flag = "LoopKillFast", Callback = function(v)
    R("loopKillFast", v); if v then task.spawn(function() LoopKillFast(targetName) end) end
end})
sFling:Toggle({Text = "Blob Kick (in blobman)", Flag = "BlobKick", Callback = function(v)
    R("blobKick", v); if v then task.spawn(function() BlobKick(targetName) end) end
end})
sFling:Button({Text = "Kick All", Callback = function() KickAll() end})
sFling:Toggle({Text = "Ragdoll (Pallet)", Flag = "Rogdoll", Callback = function(v)
    R("rogdoll", v); if v then task.spawn(function() PalletRagdoll(targetName) end) end
end})
sFling:Button({Text = "Ragdoll (Snowball)", Callback = function() R("rogdoll", true); task.spawn(function() SnowballRagdoll(targetName) end) end})
sFling:Button({Text = "Teleport to Target", Callback = function() TeleportTo(targetName) end})

-- Visuals
local sVis = tabVis:Section({Text = "Visuals", Side = "Left"})
sVis:Toggle({Text = "ESP", Flag = "ESP", Callback = function(v) R("espOn", v) end})
sVis:Toggle({Text = "FullBright", Flag = "FullBright", Callback = function(v) R("fullBright", v) end})
sVis:Slider({Text = "FOV", Flag = "FOV", Min = 50, Max = 120, Default = 70, Callback = function(v) R("fov", v) end})

-- Fun
local sFun = tabFun:Section({Text = "Fun", Side = "Left"})
sFun:Toggle({Text = "Third Person", Flag = "ThirdPerson", Callback = function(v) R("thirdPerson", v) end})
sFun:Toggle({Text = "PCLD Highlight", Flag = "PCLD", Callback = function(v) R("pcldHighlight", v) end})
sFun:Toggle({Text = "Line Lag", Flag = "LineLag", Callback = function(v) R("lineLag", v) end})
sFun:Toggle({Text = "Packet Spam", Flag = "PacketSpam", Callback = function(v) R("packetSpam", v) end})
sFun:Button({Text = "Pose (sit on me)", Callback = function() PosePlayer(targetName) end})
sFun:Button({Text = "Unpose", Callback = function() UnposePlayer(targetName) end})

-- Defence
local sDef = tabDef:Section({Text = "Defence", Side = "Left"})
local function defToggle(name, key)
    sDef:Toggle({Text = name, Flag = name, Callback = function(v) R(key, v) end})
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

-- Settings
local sSet = tabSet:Section({Text = "Settings", Side = "Left"})
sSet:Label({Text = "Rose v2 - FTAP Cheat"})
sSet:Button({Text = "Unload", Callback = function() end})

Notify("Rose", "Loaded (menu_lib). Enjoy!", 5)
print("[Rose] loaded v2")
