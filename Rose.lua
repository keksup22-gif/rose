local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"

local function Sunapse_Load(path)
	local body = game:HttpGet(repo .. path)
	local fn, err = loadstring(body)
	assert(fn, "Sunapse loadstring fail " .. path .. ": " .. tostring(err))
	return fn()
end

local Library = Sunapse_Load("Library.lua")
local ThemeManager = Sunapse_Load("addons/ThemeManager.lua")
local SaveManager = Sunapse_Load("addons/SaveManager.lua")

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
Library.CornerRadius = 20
Library.Scheme.FontColor = Color3.fromHex("ffffff")
Library.Scheme.MainColor = Color3.fromHex("242424")
Library.Scheme.AccentColor = Color3.fromHex("ff6fae")
Library.Scheme.BackgroundColor = Color3.fromHex("151515")
Library.Scheme.OutlineColor = Color3.fromHex("373737")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local BeamTexture = "rbxassetid://11722493032"
local ScriptStartClock = os.clock()

local ExecutorName = (function()
	if identifyexecutor then
		local success, name = pcall(identifyexecutor)
		if success and name then
			return name
		end
	end
	if syn then
		return "Synapse"
	end
	if KRNL_LOADED then
		return "Krnl"
	end
	if fluxus then
		return "Fluxus"
	end
	return "Unknown"
end)()

local function GetAccountCreationDate()
	local success, accountAge = pcall(function()
		return LocalPlayer.AccountAge
	end)
	if not success or not accountAge then
		return "N/A"
	end
	local timestamp = os.time() - accountAge * 86400
	local success2, date = pcall(function()
		return os.date("%d.%m.%Y", timestamp)
	end)
	if success2 and date then
		return date
	end
	return "N/A"
end

local function GetAccountAge()
	local success, accountAge = pcall(function()
		return LocalPlayer.AccountAge
	end)
	if not success or not accountAge then
		return "N/A"
	end
	local years = math.floor(accountAge / 365)
	local months = math.floor(accountAge % 365 / 30)
	local days = accountAge % 30
	if years > 0 then
		return years .. "y " .. months .. "m"
	end
	if months > 0 then
		return months .. "m " .. days .. "d"
	end
	return days .. "d"
end

local GetPlayerNames, FindPlayerByName, GetNearestPlayer, GetSetNetworkOwnerEvent, GetDestroyGrabLineEvent
local GetOtherPlayers, TeleportBehind, FireSetNetworkOwner, FireDestroyGrabLine, SetLineLagActive, ClearLineLagActive
local KickLoop, PalletRagdoll, SnowballRagdoll, LoopKill, AntiKickLoop, BlobKill, DestroyVisual
local BlobBring, BlobKick, BlobLoopKick, BlobBypass, BlobGrabLoopKick, BlobLock, DestroyGucciLoop, RemoveAntiInputLoop
local IsEspTarget, AddEspBox, ClearEspBoxes, RefreshEspBoxes, WatchPacketNotify, StartAntiGrab, StopAntiGrab
local AntiExplosionStep, IsGrabBeam, ClearGrabBeams, DestroyAntiKickToys, StopAntiVoid
local StopAntiBurn, StartAntiBurn, StopAntiFreeze, ClearFreeze, WatchAntiFreeze, RemovePaintParts
local SetCharacterCollision, StopAntiPaint, StopAntiPoison, StopPcldBreak, StartPcldBreak, StopGucci, StartGucci
local GetBlobmen, DropBlobmanCreatures, ApplySkybox, RestoreSkybox, IsBlackholeName, ApplyBlackholeTexture
local RestoreBlackholeTextures, WatchBlackholes, StopWatchBlackholes, ApplyShader, RestoreShader
local StartJumpCircle, StopJumpCircle, CreateTraceBeam, StartAntiBlobman, StopAntiBlobman, StartLSD, StopLSD
local AntiOwnershipLoop

local State = {
	flags = {},
	connections = {},
	refs = {},
	temp = {},
	runtime = {},
}

State.runtime.target = nil
State.runtime.kick = false
State.runtime.blobKick = false
State.runtime.resonanceLoopKick = false
State.runtime.kickHeight = 22
State.runtime.grabDelay = 0.05
State.runtime.rogdoll = false
State.runtime.rogdollMethod = nil
State.runtime.loopKill = false
State.runtime.destroyGucci = false
State.runtime.antiInput = false
State.runtime.antiKick = false
State.runtime.loopKickBlob = false
State.runtime.loopApple = false
State.runtime.autoSit = false
State.runtime.traceOn = false
State.runtime.espOn = false
State.runtime.gucciAntiGrab = false
State.runtime.shurikenMinefield = false
State.runtime.autoAttacker = false
State.runtime.pktNotify = true
State.runtime.pktCooldown = false
State.runtime.destroyGucciTask = nil
State.runtime.antiInputTask = nil
State.runtime.antiKickTask = nil
State.runtime.loopKillTask = nil
State.runtime.kickTask = nil
State.runtime.rogdollTask = nil
State.runtime.traceConn = nil
State.runtime.traceBeam = nil
State.runtime.traceTarget = nil
State.runtime.espBoxes = {}
State.runtime.espColor = Color3.fromRGB(255, 255, 255)
State.runtime.notifyConns = {}
State.runtime.currentConfig = nil
State.runtime.kickCurrentTarget = nil
State.runtime.menuKeybind = Enum.KeyCode.RightShift

State.flags.antiGrab = false
State.flags.antiLoopTP = false
State.flags.antiLoopThreshold = 50
State.flags.antiExplosion = false
State.flags.antiLag = false
State.flags.autoLeave = false
State.flags.antiKickShuriken = false
State.flags.antiKickItem = false
State.flags.antiKickPalletka = false
State.flags.antiVoid = false
State.flags.antiBurn = false
State.flags.antiFreeze = false
State.flags.antiOwnership = false
State.flags.antiLoopKick = false
State.flags.antiPaint = false
State.flags.antiSticky = false
State.flags.antiSnowball = false
State.flags.antiBanana = false
State.flags.antiPoison = false
State.flags.pcldBreak = false
State.flags.gucci = false
State.flags.autoReset = false
State.flags.antiBlobman = false
State.flags.shaders = false
State.flags.jumpCircle = false
State.flags.traceGlobal = false
State.flags.customBlackhole = false

State.refs.antiGrabProc = false
State.connections.antiGrab = {}
State.refs.antiLoopLastSafeCF = nil
State.connections.antiLoop = nil
State.connections.antiExplode = nil
State.connections.antiLag = nil
State.refs.antiLagBeamScript = nil
State.connections.autoLeave = nil
State.connections.autoReset = nil
State.refs.antiKickItemName = "SpookyCandle1"
State.refs.antiKickItemNameOptions = { "SpookyCandle1", "ClockAlarm", "FoodPlate" }
State.connections.antiVoid = {}
State.refs.antiVoidOriginalFallenHeight = nil
State.refs.antiVoidLastSafePosition = nil
State.connections.antiBurn = {}
State.connections.antiFreeze = {}
State.refs.antiFreezeHeartbeat = nil
State.refs.antiOwnSelectedFood = "Pizza (Cheese)"
State.connections.antiLoopKick = nil
State.refs.antiLoopKickHouseName = "Green House"
State.refs.antiLoopKickRadius = 10
State.connections.antiPaint = {}
State.refs.antiStickyRunning = false
State.refs.antiSnowballRunning = false
State.refs.antiBananaRunning = false
State.connections.antiPoison = {}
State.refs.pcldActive = false
State.connections.gucci = nil
State.refs.gucciActive = false
State.refs.gucciVehicle = nil
State.refs.gucciType = "Invisible (Tractor)"
State.refs.antiBlobmanRunning = false
State.connections.antiBlobmanDesc = nil
State.connections.antiBlobmanHeartbeat = nil
State.connections.antiBlobmanLoop = nil
State.refs.currentSkybox = nil
State.refs.skyboxOrig = { saved = false }
State.refs.currentBlackhole = nil
State.refs.blackholeOrig = {}
State.connections.blackholeWatch = nil
State.refs.currentShaderTheme = nil
State.refs.ccEffect = nil
State.refs.bloomEffect = nil

State.refs.originalLight = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ClockTime = Lighting.ClockTime,
	TimeOfDay = Lighting.TimeOfDay,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	ExposureCompensation = Lighting.ExposureCompensation,
}

State.refs.jumpCircleOn = false
State.connections.jumpCircle = nil
State.refs.jumpCircleType = "Ritual 1"
State.refs.lineLagActive = false

local EspTargetNames = { "partesp", "playercharacterlocationdetector" }

local FoodAssets = {
	["Pizza (Cheese)"] = "FoodPizzaCheese",
	["Pizza (Pepperoni)"] = "FoodPizzaPepperoni",
	Burger = "FoodHamburger",
	Hotdog = "FoodHotdog",
	Banana = "FoodBanana",
	Donut = "FoodDonut",
	Cake = "FoodCakePink",
	Bread = "FoodBread",
	Mayonnaise = "FoodMayonnaise",
	["French Fries"] = "FoodFrenchFries",
	["Dippy Egg"] = "FoodDippyEgg",
	Coconut = "FoodCoconut",
	["Meat Stick"] = "FoodMeatStick",
	["Poison Mushroom"] = "FoodMushroomPoison",
}

local HousePositions = {
	["Green House"] = CFrame.new(-548.305054, -2.45424771, 79.3213348),
	["Pink House"] = CFrame.new(-475.493835, -2.70774508, -159.395279),
	["Witch House"] = CFrame.new(270.225922, -2.48055029, 458.186493),
	["Blue House"] = CFrame.new(501.939911, 88.2323608, -349.129211),
	["China House"] = CFrame.new(545.441833, 128.004593, -99.4881439),
}

local SkyboxPresets = {
	HD = {
		Bk = "http://www.roblox.com/asset/?id=16553658937",
		Dn = "http://www.roblox.com/asset/?id=16553660713",
		Ft = "http://www.roblox.com/asset/?id=16553662144",
		Lf = "http://www.roblox.com/asset/?id=16553664042",
		Rt = "http://www.roblox.com/asset/?id=16553665766",
		Up = "http://www.roblox.com/asset/?id=16553667750",
	},
	["Black Storm"] = {
		Bk = "rbxassetid://15502511288",
		Dn = "rbxassetid://15502508460",
		Ft = "rbxassetid://15502510289",
		Lf = "rbxassetid://15502507918",
		Rt = "rbxassetid://15502509398",
		Up = "rbxassetid://15502511911",
	},
	Snow = {
		Bk = "http://www.roblox.com/asset/?id=155657655",
		Dn = "http://www.roblox.com/asset/?id=155674246",
		Ft = "http://www.roblox.com/asset/?id=155657609",
		Lf = "http://www.roblox.com/asset/?id=155657671",
		Rt = "http://www.roblox.com/asset/?id=155657619",
		Up = "http://www.roblox.com/asset/?id=155674931",
	},
	["Blue Space"] = {
		Bk = "rbxassetid://15536110634",
		Dn = "rbxassetid://15536112543",
		Ft = "rbxassetid://15536116141",
		Lf = "rbxassetid://15536114370",
		Rt = "rbxassetid://15536118762",
		Up = "rbxassetid://15536117282",
	},
	Realistic = {
		Bk = "rbxassetid://653719502",
		Dn = "rbxassetid://653718790",
		Ft = "rbxassetid://653719067",
		Lf = "rbxassetid://653719190",
		Rt = "rbxassetid://653718931",
		Up = "rbxassetid://653719321",
	},
	Sunset = {
		Bk = "rbxassetid://600830446",
		Dn = "rbxassetid://600831635",
		Ft = "rbxassetid://600832720",
		Lf = "rbxassetid://600886090",
		Rt = "rbxassetid://600833862",
		Up = "rbxassetid://600835177",
	},
	Space = {
		Bk = "http://www.roblox.com/asset/?id=166509999",
		Dn = "http://www.roblox.com/asset/?id=166510057",
		Ft = "http://www.roblox.com/asset/?id=166510116",
		Lf = "http://www.roblox.com/asset/?id=166510092",
		Rt = "http://www.roblox.com/asset/?id=166510131",
		Up = "http://www.roblox.com/asset/?id=166510114",
	},
	Pink = {
		Bk = "rbxassetid://12216109205",
		Dn = "rbxassetid://12216109875",
		Ft = "rbxassetid://12216109489",
		Lf = "rbxassetid://12216110170",
		Rt = "rbxassetid://12216110471",
		Up = "rbxassetid://12216108877",
	},
	Galaxy = {
		Bk = "rbxassetid://15983968922",
		Dn = "rbxassetid://15983966825",
		Ft = "rbxassetid://15983965025",
		Lf = "rbxassetid://15983967420",
		Rt = "rbxassetid://15983966246",
		Up = "rbxassetid://15983964246",
	},
	["Roblox Default"] = {
		Bk = "rbxasset://textures/sky/sky512_bk.tex",
		Dn = "rbxasset://textures/sky/sky512_dn.tex",
		Ft = "rbxasset://textures/sky/sky512_ft.tex",
		Lf = "rbxasset://textures/sky/sky512_lf.tex",
		Rt = "rbxasset://textures/sky/sky512_rt.tex",
		Up = "rbxasset://textures/sky/sky512_up.tex",
	},
}

local BlackholeTextures = {
	Gargantua = "rbxassetid://5436396975",
	["Dark blue"] = "rbxassetid://78890931816939",
	Canopus = "rbxassetid://14559055920",
	["light blue"] = "rbxassetid://17769650925",
	white = "rbxassetid://11722493032",
	Galaxy = "rbxassetid://135988354771745",
}

local JumpCircleTextures = {
	["Ritual 1"] = "rbxassetid://117117534447665",
	["Ritual 2"] = "rbxassetid://8800230306",
}

local ShaderPresets = {
	["Ночь"] = {
		Brightness = 2,
		Ambient = Color3.fromRGB(60, 70, 130),
		OutdoorAmbient = Color3.fromRGB(70, 80, 150),
		ClockTime = 12,
		FogEnd = 100000,
		FogStart = 90000,
		ExposureCompensation = 0.3,
		CC = {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = -0.1,
			Tint = Color3.fromRGB(120, 140, 220),
		},
		Bloom = { Intensity = 0.6, Size = 32, Threshold = 0.7 },
	},
	["Вечер"] = {
		Brightness = 2.5,
		Ambient = Color3.fromRGB(170, 110, 75),
		OutdoorAmbient = Color3.fromRGB(190, 120, 85),
		ClockTime = 12,
		FogEnd = 100000,
		FogStart = 90000,
		ExposureCompensation = 0.4,
		CC = {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.2,
			Tint = Color3.fromRGB(255, 200, 160),
		},
		Bloom = { Intensity = 0.6, Size = 32, Threshold = 0.7 },
	},
	["Неон"] = {
		Brightness = 2.5,
		Ambient = Color3.fromRGB(80, 40, 120),
		OutdoorAmbient = Color3.fromRGB(90, 50, 140),
		ClockTime = 22,
		FogEnd = 1500,
		FogStart = 200,
		ExposureCompensation = 0.3,
		CC = {
			Brightness = 0,
			Contrast = 0.4,
			Saturation = 0.8,
			Tint = Color3.fromRGB(180, 100, 255),
		},
		Bloom = { Intensity = 1.3, Size = 44, Threshold = 0.35 },
	},
	["Холодный"] = {
		Brightness = 2.5,
		Ambient = Color3.fromRGB(120, 140, 180),
		OutdoorAmbient = Color3.fromRGB(140, 160, 200),
		ClockTime = 12,
		FogEnd = 100000,
		FogStart = 90000,
		ExposureCompensation = 0.1,
		CC = {
			Brightness = 0,
			Contrast = 0.1,
			Saturation = 0.1,
			Tint = Color3.fromRGB(150, 180, 255),
		},
		Bloom = { Intensity = 0.4, Size = 24, Threshold = 0.8 },
	},
	["Тёплый"] = {
		Brightness = 2.5,
		Ambient = Color3.fromRGB(180, 140, 100),
		OutdoorAmbient = Color3.fromRGB(200, 160, 120),
		ClockTime = 12,
		FogEnd = 100000,
		FogStart = 90000,
		ExposureCompensation = 0.2,
		CC = {
			Brightness = 0.02,
			Contrast = 0.1,
			Saturation = 0.3,
			Tint = Color3.fromRGB(255, 200, 150),
		},
		Bloom = { Intensity = 0.5, Size = 28, Threshold = 0.6 },
	},
}
local function WaitChild(instance, childName)
	return instance:FindFirstChild(childName) or instance:WaitForChild(childName, 3)
end

GetPlayerNames = function()
	local names = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(names, player.DisplayName)
		end
	end
	return names
end

FindPlayerByName = function(name)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.DisplayName == name or player.Name == name then
			return player
		end
	end
end

GetNearestPlayer = function(position)
	if not position then
		return nil
	end
	local bestDistance = math.huge
	local nearestPlayer = nil
	for _, player in ipairs(Players:GetPlayers()) do
		local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local distance = (rootPart.Position - position).Magnitude
			if distance < bestDistance then
				bestDistance = distance
				nearestPlayer = player
			end
		end
	end
	return nearestPlayer
end

GetSetNetworkOwnerEvent = function()
	local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents") or ReplicatedStorage:WaitForChild("GrabEvents", 10)
	return grabEvents and grabEvents:FindFirstChild("SetNetworkOwner")
end

GetDestroyGrabLineEvent = function()
	local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents") or ReplicatedStorage:WaitForChild("GrabEvents", 10)
	return grabEvents and grabEvents:FindFirstChild("DestroyGrabLine")
end

GetOtherPlayers = function()
	local others = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(others, player)
		end
	end
	return others
end

TeleportBehind = function(rootPart, targetRootPart)
	if not rootPart or not targetRootPart then
		return
	end
	pcall(function()
		rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 2)
		rootPart.AssemblyLinearVelocity = Vector3.zero
	end)
end

FireSetNetworkOwner = function(part)
	if not part then
		return
	end
	local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
	local setNetworkOwner = grabEvents and grabEvents:FindFirstChild("SetNetworkOwner")
	if setNetworkOwner then
		for i = 1, 5 do
			pcall(function()
				setNetworkOwner:FireServer(part, part.CFrame)
			end)
		end
	end
end

FireDestroyGrabLine = function(part)
	if not part then
		return
	end
	local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
	local destroyGrabLine = grabEvents and grabEvents:FindFirstChild("DestroyGrabLine")
	if destroyGrabLine then
		pcall(function()
			destroyGrabLine:FireServer(part)
		end)
	end
end

SetLineLagActive = function()
	State.refs.lineLagActive = true
end

ClearLineLagActive = function()
	State.refs.lineLagActive = false
end

KickLoop = function(playerName)
	local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents") or ReplicatedStorage:WaitForChild("GrabEvents", 10)
	if not grabEvents then
		Library:Notify({ Title = "Rose", Description = "GrabEvents not found", Time = 3 })
		return
	end
	local setNetworkOwner = grabEvents:FindFirstChild("SetNetworkOwner") or grabEvents:WaitForChild("SetNetworkOwner", 5)
	local createGrabLine = grabEvents:FindFirstChild("CreateGrabLine")
	local destroyGrabLine = grabEvents:FindFirstChild("DestroyGrabLine") or grabEvents:WaitForChild("DestroyGrabLine", 5)
	if not setNetworkOwner then
		Library:Notify({ Title = "Rose", Description = "SetNetworkOwner not found", Time = 3 })
		return
	end
	local lastGrab = 0

	while State.runtime.kick do
		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer or not targetPlayer.Parent then
			break
		end

		local character = LocalPlayer.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local targetCharacter = targetPlayer.Character
		local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

		if not targetCharacter or not targetHumanoid or targetHumanoid.Health <= 0 then
			pcall(function()
				targetCharacter = targetPlayer.CharacterAdded:Wait()
				targetHumanoid = targetCharacter:WaitForChild("Humanoid", 5)
			end)
			RunService.Heartbeat:Wait()
		else
			local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
			if not (character and rootPart) or not targetRootPart or not targetHumanoid or targetHumanoid.Health <= 0 then
				RunService.Heartbeat:Wait()
			elseif (targetRootPart.Position - rootPart.Position).Magnitude > 30 then
				pcall(function()
					character:PivotTo(targetRootPart.CFrame * CFrame.new(0, 2, 4))
				end)
				RunService.Heartbeat:Wait()
			else
				local kickPosition = (rootPart.CFrame * CFrame.new(0, State.runtime.kickHeight, 0)).Position

				if not targetRootPart:FindFirstChild("Kick2Align") then
					for _, child in pairs(targetRootPart:GetChildren()) do
						if child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
							if child.Name ~= "Kick2Align" and child.Name ~= "Kick2Rot" then
								pcall(function()
									child:Destroy()
								end)
							end
						end
					end

					local attachment = Instance.new("Attachment", targetRootPart)
					attachment.Name = "Kick2Att0"
					local anchorAttachment = Instance.new("Attachment", workspace.Terrain)
					anchorAttachment.Name = "Kick2Att1"
					local alignPosition = Instance.new("AlignPosition")
					alignPosition.Name = "Kick2Align"
					alignPosition.Attachment0 = attachment
					alignPosition.Attachment1 = anchorAttachment
					alignPosition.MaxForce = math.huge
					alignPosition.Responsiveness = 300
					alignPosition.Parent = targetRootPart
					local alignOrientation = Instance.new("AlignOrientation")
					alignOrientation.Name = "Kick2Rot"
					alignOrientation.Attachment0 = attachment
					alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
					alignOrientation.CFrame = CFrame.new()
					alignOrientation.MaxTorque = math.huge
					alignOrientation.Responsiveness = 300
					alignOrientation.Parent = targetRootPart
				end

				local kick2Align = targetRootPart:FindFirstChild("Kick2Align")
				if kick2Align and kick2Align.Attachment1 then
					kick2Align.Attachment1.WorldPosition = kickPosition
				end

				local kick2Rot = targetRootPart:FindFirstChild("Kick2Rot")
				if kick2Rot then
					kick2Rot.CFrame = CFrame.Angles(0, 0, 0)
				end

				pcall(function()
					targetHumanoid.PlatformStand = true
					targetRootPart.AssemblyLinearVelocity = Vector3.zero
					targetRootPart.AssemblyAngularVelocity = Vector3.zero
				end)

				local now = tick()
				if now - lastGrab > State.runtime.grabDelay then
					-- Fire network owner multiple times for reliability
					pcall(function()
						setNetworkOwner:FireServer(targetRootPart, targetRootPart.CFrame)
						setNetworkOwner:FireServer(targetRootPart, targetRootPart.CFrame)
						setNetworkOwner:FireServer(targetRootPart, targetRootPart.CFrame)
					end)

					-- Try to fire CreateGrabLine if available (not required for kick to work)
					if createGrabLine then
						pcall(function()
							createGrabLine:FireServer(targetRootPart, kickPosition)
						end)
					end

					-- DestroyGrabLine helps release
					if destroyGrabLine then
						pcall(function()
							destroyGrabLine:FireServer(targetRootPart)
						end)
					end

					-- Additional velocity push to help kick go up
					pcall(function()
						targetRootPart.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
					end)

					lastGrab = now
				end

				RunService.Heartbeat:Wait()
			end
		end
	end

	local targetPlayer = Players:FindFirstChild(playerName)
	if targetPlayer and targetPlayer.Character then
		local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRootPart then
			local kick2Align = targetRootPart:FindFirstChild("Kick2Align")
			if kick2Align then
				if kick2Align.Attachment1 then
					pcall(function()
						kick2Align.Attachment1:Destroy()
					end)
				end
				pcall(function()
					kick2Align:Destroy()
				end)
			end

			local kick2Rot = targetRootPart:FindFirstChild("Kick2Rot")
			if kick2Rot then
				pcall(function()
					kick2Rot:Destroy()
				end)
			end

			local kick2Att0 = targetRootPart:FindFirstChild("Kick2Att0")
			if kick2Att0 then
				pcall(function()
					kick2Att0:Destroy()
				end)
			end
		end
	end
end

PalletRagdoll = function(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer or not targetPlayer.Character then
		return
	end

	local grabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
	local spawnPosition = CFrame.new(0, 800000, 0)
	ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("PalletLightBrown", spawnPosition, Vector3.zero)

	local pallet
	repeat
		local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		pallet = toys and toys:FindFirstChild("PalletLightBrown")
		RunService.Heartbeat:Wait()
	until pallet or not State.runtime.rogdoll

	if not pallet then
		return
	end

	local soundPart = pallet:FindFirstChild("SoundPart")
	if not soundPart then
		return
	end
	soundPart.CanCollide = false
	soundPart.Anchored = false

	local function grabPart(part)
		grabEvents.SetNetworkOwner:FireServer(part, part.CFrame)
		grabEvents.CreateGrabLine:FireServer(part, Vector3.zero, part.Position, false)
		grabEvents.DestroyGrabLine:FireServer(part)
	end

	grabPart(soundPart)

	while State.runtime.rogdoll do
		for i = 1, 20 do
			RunService.Heartbeat:Wait()
		end

		local currentTarget = Players:FindFirstChild(playerName)
		if not currentTarget then
			break
		end

		local head = currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
		if head then
			soundPart.CFrame = CFrame.new(head.Position.X, head.Position.Y + 0.2, head.Position.Z)
			soundPart.AssemblyLinearVelocity = Vector3.zero
			soundPart.AssemblyAngularVelocity = Vector3.new(1000, 1000, 1000)
			grabPart(soundPart)
			soundPart.CanCollide = true

			for i = 1, 3 do
				RunService.Heartbeat:Wait()
			end

			soundPart.CanCollide = false
			soundPart.CFrame = spawnPosition
			soundPart.AssemblyAngularVelocity = Vector3.zero
		end
	end

	pcall(function()
		ReplicatedStorage.MenuToys.DestroyToy:FireServer(pallet)
	end)

	if pallet.Parent then
		pallet:Destroy()
	end
end

SnowballRagdoll = function(playerName)
	local spawnToy = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

	while State.runtime.rogdoll do
		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			task.wait(0.5)
		else
			local character = targetPlayer.Character
			local torso
			if character then
				torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
			end

			if torso then
				local offset = Vector3.new(math.random(-30, 30) / 100, math.random(-30, 30) / 100, math.random(-30, 30) / 100)

				pcall(function()
					spawnToy:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero)
				end)

				local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				if toys then
					for _, child in ipairs(toys:GetChildren()) do
						if child.Name == "BallSnowball" and child.Parent then
							local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
							if primaryPart then
								primaryPart.CFrame = torso.CFrame * CFrame.new(offset)
								primaryPart.AssemblyLinearVelocity = Vector3.zero
								primaryPart.AssemblyAngularVelocity = Vector3.zero
							end
						end
					end
				end
			end

			task.wait()
		end
	end
end

LoopKill = function(playerName)
	local grabEvents = ReplicatedStorage:WaitForChild("GrabEvents")

	while State.runtime.loopKill do
		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			task.wait(0.5)
		else
			local targetCharacter = targetPlayer.Character
			local character = LocalPlayer.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local targetRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
			local targetHumanoid = targetCharacter and targetCharacter:FindFirstChild("Humanoid")

			if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 and rootPart then
				local savedCFrame = rootPart.CFrame
				local startTime = tick()

				while tick() - startTime < 0.35 and State.runtime.loopKill and targetRootPart.Parent do
					rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 2)
					rootPart.Velocity = Vector3.zero

					pcall(function()
						grabEvents.SetNetworkOwner:FireServer(targetRootPart, rootPart.CFrame)
						targetHumanoid:ChangeState(Enum.HumanoidStateType.Dead)
						targetHumanoid.Health = 0
						grabEvents.CreateGrabLine:FireServer(targetRootPart, Vector3.zero, targetRootPart.Position, false)
						grabEvents.DestroyGrabLine:FireServer(targetRootPart)
					end)

					RunService.Heartbeat:Wait()
				end

				rootPart.CFrame = savedCFrame
				rootPart.Velocity = Vector3.zero
				task.wait(1.2)
			else
				task.wait(0.5)
			end
		end
	end
end

AntiKickLoop = function(playerName)
	local setNetworkOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner

	local function clearToy(toy)
		local soundPart = toy:FindFirstChild("SoundPart")
		if soundPart then
			setNetworkOwner:FireServer(soundPart, soundPart.CFrame)

			if soundPart:FindFirstChild("PartOwner") and soundPart.PartOwner.Value == LocalPlayer.Name then
				soundPart.CFrame = CFrame.new(0, 1000, 0)
			end
		end
	end

	while State.runtime.antiKick do
		local targetPlayer = Players:FindFirstChild(playerName)
		if targetPlayer then
			local toys = workspace:FindFirstChild(targetPlayer.Name .. "SpawnedInToys")
			if toys then
				for _, toyName in ipairs({ "NinjaKunai", "NinjaShuriken", "AntiKick" }) do
					local toy = toys:FindFirstChild(toyName)
					if toy then
						clearToy(toy)
					end
				end
			end
		end

		task.wait(0.1)
	end
end

local function FireBlobmanCreature(blobman, targetPart, side, mode)
	local detector = blobman:FindFirstChild(side .. "Detector")
	if not detector then
		return
	end
	local blobmanScript = blobman.BlobmanSeatAndOwnerScript

	if mode == "Default" then
		blobmanScript.CreatureGrab:FireServer(detector, targetPart, detector[side .. "Weld"])
	elseif mode == "DDrop" then
		blobmanScript.CreatureDrop:FireServer(detector[side .. "Weld"])
	elseif mode == "Release" then
		blobmanScript.CreatureRelease:FireServer(detector[side .. "Weld"], targetPart)
	end
end

local function WaitForSeatParent()
	local humanoid
	repeat
		humanoid = WaitChild(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(), "Humanoid")
		if not humanoid or not humanoid.SeatPart then
			task.wait()
		end
	until humanoid and humanoid.SeatPart
	return humanoid.SeatPart.Parent
end

BlobKill = function(playerName)
	local blobman = WaitForSeatParent()

	local function fireNetworkOwner(part)
		ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, part.CFrame)
	end

	local running = true
	while running do
		local character = LocalPlayer.Character
		local humanoid = character and WaitChild(character, "Humanoid")
		local inBlobmanSeat = humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent == blobman
		if not inBlobmanSeat then
			break
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if targetPlayer and targetPlayer.Character then
			local targetHumanoid = WaitChild(targetPlayer.Character, "Humanoid", 2)
			local targetRootPart = WaitChild(targetPlayer.Character, "HumanoidRootPart", 2)

			if targetHumanoid and targetRootPart and targetHumanoid.Health > 0 then
				local leftDetector = blobman:FindFirstChild("LeftDetector")

				if leftDetector and leftDetector:FindFirstChild("LeftWeld") then
					local rootPart = WaitChild(character, "HumanoidRootPart")
					local savedCFrame = rootPart.CFrame

					while targetHumanoid.SeatPart do
						task.spawn(fireNetworkOwner, targetRootPart)
						task.wait()
					end

					for i = 1, 4 do
						if not humanoid.SeatPart then
							running = false
							break
						end

						rootPart.CFrame = targetRootPart.CFrame - Vector3.new(0, 10, 0)
						FireBlobmanCreature(blobman, targetRootPart, "Left", "Default")
						task.wait(0.05)
						FireBlobmanCreature(blobman, targetRootPart, "Left", "Release")
						targetHumanoid.Health = 0
						task.wait()
					end

					rootPart.CFrame = savedCFrame
				end
			end
		end

		task.wait()
	end
end

DestroyVisual = function(playerName)
	local blobman = WaitForSeatParent()

	local function fireNetworkOwner(part)
		ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(part, part.CFrame)
	end

	local function attempt()
		local character = LocalPlayer.Character
		local rootPart = WaitChild(character, "HumanoidRootPart")
		local humanoid = WaitChild(character, "Humanoid")
		if not humanoid.SeatPart or humanoid.SeatPart.Parent ~= blobman then
			return false
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer or not targetPlayer.Character then
			return false
		end

		local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
		local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not (targetHumanoid and targetRootPart) then
			return false
		end

		local leftDetector = blobman:FindFirstChild("LeftDetector")
		if not (leftDetector and leftDetector.LeftWeld) then
			return false
		end

		local savedCFrame = rootPart.CFrame
		task.spawn(fireNetworkOwner, targetRootPart)
		task.wait(0.1)

		for i = 1, 3 do
			rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2.5)
			FireBlobmanCreature(blobman, targetRootPart, "Left", "Default")
			task.wait(0.08)
			FireBlobmanCreature(blobman, targetRootPart, "Left", "Release")
			targetHumanoid.Health = targetHumanoid.MaxHealth
			task.wait(0.08)
		end

		rootPart.CFrame = savedCFrame
		return true
	end

	if not attempt() then
		task.wait(0.5)
		attempt()
	end
end

BlobBring = function(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer or targetPlayer == LocalPlayer then
		return
	end

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local seatPart = humanoid.SeatPart
	if not seatPart then
		return
	end

	local targetRootPart = (targetPlayer.Character or targetPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
	local leftDetector = seatPart.Parent:WaitForChild("LeftDetector")
	local leftWeld = leftDetector:WaitForChild("LeftWeld")
	local creatureGrab = seatPart.Parent.BlobmanSeatAndOwnerScript:WaitForChild("CreatureGrab")
	local savedCFrame = rootPart.CFrame
	local hiddenParts = {}

	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			hiddenParts[descendant] = descendant.Transparency
			descendant.Transparency = 1
		end
	end

	rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 0, 2.5)
	task.wait()
	creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)

	task.delay(0.1, function()
		creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)
	end)

	task.delay(0.2, function()
		rootPart.CFrame = savedCFrame

		for part, transparency in pairs(hiddenParts) do
			if part.Parent then
				part.Transparency = transparency
			end
		end
	end)
end


BlobKick = function(playerName)
	-- Blob kick hold pipeline
	if not playerName or playerName == LocalPlayer.Name then
		Library:Notify({ Title = "Rose", Description = "Select player", Time = 2 })
		return
	end

	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer or targetPlayer == LocalPlayer then
		Library:Notify({ Title = "Rose", Description = "Player not found", Time = 2 })
		return
	end

	local character = LocalPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	local seatPart = humanoid.SeatPart
	if not seatPart or not seatPart.Parent or seatPart.Parent.Name ~= "CreatureBlobman" then
		Library:Notify({ Title = "Rose", Description = "Sit in Blobman first", Time = 3 })
		return
	end

	local function getComps()
		local char = LocalPlayer.Character
		if not char then return nil end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return nil end
		local seat = hum.SeatPart
		if not seat or not seat.Parent or seat.Parent.Name ~= "CreatureBlobman" then return nil end
		local blob = seat.Parent
		local sc = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
		local rd = blob:FindFirstChild("RightDetector")
		local ld = blob:FindFirstChild("LeftDetector")
		if not sc or not rd then return nil end
		local rw = rd:FindFirstChild("RightWeld")
		local ro = rd:FindFirstChild("RightAlignOrientation")
		local grab = sc:FindFirstChild("CreatureGrab")
		local drop = sc:FindFirstChild("CreatureDrop")
		local rel = sc:FindFirstChild("CreatureRelease")
		if not rw or not grab or not drop then return nil end
		return {
			root = root,
			hum = hum,
			blob = blob,
			grab = grab,
			drop = drop,
			release = rel,
			rightDet = rd,
			rightWeld = rw,
			rightOri = ro,
			leftDet = ld,
			leftWeld = ld and ld:FindFirstChild("LeftWeld"),
		}
	end

	local function sno(part)
		local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
		local so = ge and ge:FindFirstChild("SetNetworkOwner")
		if not so or not part then return false end
		for _ = 1, 6 do
			pcall(function()
				so:FireServer(part, part.CFrame)
			end)
		end
		return true
	end

	local function createAlign(part)
		local att = part:FindFirstChild("RootAttachment")
		if not att then
			att = Instance.new("Attachment")
			att.Name = "RootAttachment"
			att.Parent = part
		end
		local ap = Instance.new("AlignPosition")
		ap.Name = "RSCAlignPos"
		ap.Mode = Enum.PositionAlignmentMode.OneAttachment
		ap.ApplyAtCenterOfMass = true
		ap.MaxForce = 1e9
		ap.Responsiveness = 200
		ap.Attachment0 = att
		ap.Parent = part
		local ao = Instance.new("AlignOrientation")
		ao.Name = "RSCAlignOri"
		ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
		ao.MaxTorque = 1e9
		ao.Responsiveness = 200
		ao.Attachment0 = att
		ao.Parent = part
		return ap, ao
	end

	-- Release: spam grab until network owned
	local function releaseTarget(tRoot, comps)
		if not tRoot or not comps then return false end
		local t0 = tick()
		pcall(function() comps.rightWeld.Enabled = false end)
		while tick() - t0 < 0.7 do
			if not tRoot.Parent then return false end
			pcall(function()
				comps.grab:FireServer(nil, tRoot, comps.rightWeld)
			end)
			sno(tRoot)
			task.wait(0.02)
		end
		return true
	end

	local comps = getComps()
	if not comps then
		Library:Notify({ Title = "Rose", Description = "Blob parts missing", Time = 3 })
		return
	end

	State.runtime.blobKick = true
	Library:Notify({ Title = "Rose", Description = "Blob Kick ON", Time = 2 })

	while State.runtime.blobKick do
		comps = getComps()
		if not comps then
			Library:Notify({ Title = "Rose", Description = "Left blob", Time = 2 })
			break
		end

		targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer or targetPlayer == LocalPlayer then break end

		local tChar = targetPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		if not tRoot or not tHum or tHum.Health <= 0 then
			task.wait(0.15)
		else
			local assembly = tRoot.AssemblyRootPart or tRoot
			if assembly.Massless or tHum.SeatPart then
				task.wait(0.12)
			else
				-- 1) drop current weld (kick start)
				pcall(function()
					comps.drop:FireServer(comps.rightWeld)
					if comps.leftWeld then
						comps.drop:FireServer(comps.leftWeld)
					end
				end)

				-- 2) take ownership
				releaseTarget(tRoot, comps)

				-- 3) place target in front (offset 0,5,-20 relative)
				local placeCF = comps.root.CFrame * CFrame.new(0, 5, -20)
				pcall(function()
					comps.rightWeld.Enabled = false
					if comps.rightOri then
						comps.rightOri.Enabled = false
						comps.rightOri.Attachment0 = nil
					end
					comps.rightWeld.Attachment0 = nil
					tRoot.CFrame = placeCF
					tRoot.AssemblyLinearVelocity = Vector3.zero
				end)

				local ap, ao = createAlign(tRoot)
				ap.Position = placeCF.Position
				ao.CFrame = placeCF - placeCF.Position

				task.wait(0.35)

				-- 4) grab: nil, root, rightWeld
				pcall(function()
					comps.grab:FireServer(nil, tRoot, comps.rightWeld)
				end)
				task.wait()
				pcall(function()
					comps.grab:FireServer(nil, tRoot, comps.rightWeld)
				end)

				-- grab self root (after targets)
				pcall(function()
					comps.grab:FireServer(nil, comps.root, comps.rightWeld)
				end)

				-- 5) hold 1.8s
				local holdEnd = os.clock() + 1.8
				while os.clock() < holdEnd and State.runtime.blobKick do
					if tRoot.Parent then
						pcall(function()
							tRoot.CFrame = placeCF
							tRoot.AssemblyLinearVelocity = Vector3.zero
							if ap and ap.Parent then
								ap.Position = placeCF.Position
							end
						end)
					end
					RunService.Heartbeat:Wait()
				end

				-- cleanup aligns / re-enable weld
				pcall(function()
					if ap and ap.Parent then ap:Destroy() end
					if ao and ao.Parent then ao:Destroy() end
					if comps.rightWeld and comps.rightWeld.Parent then
						comps.rightWeld.Attachment0 = nil
						comps.rightWeld.Enabled = true
					end
				end)

				task.wait(0.1)
			end
		end
	end

	State.runtime.blobKick = false
State.runtime.resonanceLoopKick = false
	Library:Notify({ Title = "Rose", Description = "Blob Kick OFF", Time = 2 })
end


BlobLoopKick = function(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer or targetPlayer == LocalPlayer then
		return
	end

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local seatPart = humanoid.SeatPart
	if not seatPart then
		return
	end

	local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
	local targetHumanoid = targetCharacter:WaitForChild("Humanoid")
	local targetRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
	local leftDetector = seatPart.Parent:WaitForChild("LeftDetector")
	local leftWeld = leftDetector:WaitForChild("LeftWeld")
	local rightDetector = seatPart.Parent:WaitForChild("RightDetector")
	local rightWeld = rightDetector:WaitForChild("RightWeld")
	local blobmanScript = seatPart.Parent.BlobmanSeatAndOwnerScript
	local creatureGrab = blobmanScript:WaitForChild("CreatureGrab")
	local creatureDrop = blobmanScript:WaitForChild("CreatureDrop")
	local savedCFrame = rootPart.CFrame

	rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, -5, 0)
	task.wait(0.1)
	creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)
	task.wait(0.5)
	creatureDrop:FireServer(leftWeld, targetRootPart)
	task.wait(0.2)

	local bodyPosition = Instance.new("BodyPosition", targetRootPart)
	bodyPosition.Position = Vector3.new(0, 999000000, 0)
	bodyPosition.MaxForce = Vector3.new(999000000, 999000000, 999000000)
	creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)
	task.wait(0.5)
	creatureDrop:FireServer(leftWeld, targetRootPart)
	task.wait(0.5)

	while targetPlayer.Parent and targetHumanoid.Health > 0 do
		creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)
		task.wait()
		creatureDrop:FireServer(leftWeld, targetRootPart)
		task.wait()
		creatureGrab:FireServer(rightDetector, targetRootPart, rightWeld)
		task.wait()
		creatureDrop:FireServer(rightWeld, targetRootPart)
		task.wait()
		creatureGrab:FireServer(leftDetector, targetRootPart, leftWeld)
		creatureGrab:FireServer(rightDetector, targetRootPart, rightWeld)
		task.wait()
		creatureDrop:FireServer(leftWeld, targetRootPart)
		creatureDrop:FireServer(rightWeld, targetRootPart)
		task.wait()
	end

	bodyPosition:Destroy()
	rootPart.CFrame = savedCFrame
end


BlobBypass = function(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if not targetPlayer or targetPlayer == LocalPlayer then
		return
	end

	local seatPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid").SeatPart
	if not seatPart then
		return
	end

	local character = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local leftDetector = seatPart.Parent:WaitForChild("LeftDetector")
	local leftWeld = leftDetector:WaitForChild("LeftWeld")
	local blobmanScript = seatPart.Parent.BlobmanSeatAndOwnerScript
	local creatureGrab = blobmanScript:WaitForChild("CreatureGrab")
	local creatureDrop = blobmanScript:WaitForChild("CreatureDrop")
	task.wait(0.05)

	while targetPlayer.Parent and humanoid.Health > 0 do
		for i = 1, 20 do
			creatureGrab:FireServer(leftDetector, rootPart, leftWeld)
		end

		creatureDrop:FireServer(leftWeld, rootPart)
		creatureDrop:FireServer(leftWeld, rootPart)
		task.wait(0.01)
	end
end


BlobGrabLoopKick = function(playerName)
	if not Players:FindFirstChild(playerName) then
		return
	end

	local seatPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid").SeatPart
	if not seatPart or seatPart.Parent.Name ~= "CreatureBlobman" then
		return
	end

	local blobman = seatPart.Parent
	local rootPart = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart
	local rightDetector = blobman:WaitForChild("RightDetector")
	local blobmanScript = blobman:WaitForChild("BlobmanSeatAndOwnerScript")
	local creatureGrab = blobmanScript:WaitForChild("CreatureGrab")
	local creatureDrop = blobmanScript:WaitForChild("CreatureDrop")
	local grabEvents = ReplicatedStorage:WaitForChild("GrabEvents")
	local savedCFrame = rootPart.CFrame
	local lifted = false
	local lastAction = 0
	local liftStart = 0

	while State.runtime.loopKickBlob do
		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			break
		end

		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local currentSeat = humanoid and humanoid.SeatPart
		if not currentSeat or currentSeat.Parent.Name ~= "CreatureBlobman" then
			break
		end

		local currentBlobman = currentSeat.Parent
		rootPart = currentBlobman:FindFirstChild("HumanoidRootPart") or currentBlobman.PrimaryPart
		local targetRootPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid")

		if targetRootPart and targetHumanoid and targetHumanoid.Health > 0 then
			targetRootPart.Velocity = Vector3.zero

			if not lifted then
				rootPart.CFrame = targetRootPart.CFrame
				rootPart.Velocity = Vector3.zero

				if tick() - lastAction >= 0.002 then
					lastAction = tick()
					pcall(function()
						targetHumanoid.PlatformStand = true
						targetHumanoid.Sit = true
						grabEvents.SetNetworkOwner:FireServer(targetRootPart, rootPart.CFrame)
						grabEvents.DestroyGrabLine:FireServer(targetRootPart)
					end)
				end

				if liftStart == 0 then
					liftStart = tick()
				end

				if tick() - liftStart > 0.35 then
					rootPart.CFrame = savedCFrame
					rootPart.Velocity = Vector3.zero
					lifted = true
					liftStart = 0
				end
			else
				rootPart.CFrame = savedCFrame
				rootPart.Velocity = Vector3.zero
				local liftedCFrame = savedCFrame * CFrame.new(0, 23, 0)
				targetRootPart.CFrame = liftedCFrame
				targetHumanoid.PlatformStand = true
				targetHumanoid.Sit = true

				if tick() - lastAction >= 0.002 then
					lastAction = tick()
					pcall(function()
						grabEvents.SetNetworkOwner:FireServer(targetRootPart, liftedCFrame)
						grabEvents.DestroyGrabLine:FireServer(targetRootPart)
						local rightWeld = rightDetector:FindFirstChild("RightWeld") or rightDetector:FindFirstChildWhichIsA("Weld")
						if rightWeld then
							creatureDrop:FireServer(rightWeld)
							creatureGrab:FireServer(rightDetector, targetRootPart, rightWeld)
						end
					end)
				end
			end
		else
			lifted = false
			liftStart = 0
		end

		RunService.Heartbeat:Wait()
	end

	if rootPart then
		rootPart.CFrame = savedCFrame
		rootPart.Velocity = Vector3.zero
	end
end


BlobLock = {
	Running = false,
	MyBlob = nil,
	StartPos = nil,
	LastTP = 0,
	Time = 0,
	TP = function(self, targetRootPart)
		local character = LocalPlayer.Character
		local rootPart = character and WaitChild(character, "HumanoidRootPart", 2)
		if not rootPart then
			return
		end

		self.StartPos = rootPart.CFrame
		rootPart.CFrame = targetRootPart.CFrame + Vector3.new(0, 5, 0)
		task.wait(0.05)

		for i = 1, 3 do
			ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetRootPart, targetRootPart.CFrame)
			task.wait()
		end

		task.wait(0.1)
		rootPart.CFrame = self.StartPos
		self.LastTP = tick()
	end,
	Start = function(self, playerName)
		if self.Running then
			return
		end

		local targetPlayer = Players:FindFirstChild(playerName)
		if not targetPlayer then
			return
		end
		self.Running = true

		task.spawn(function()
			local targetRootPart = targetPlayer.Character and WaitChild(targetPlayer.Character, "HumanoidRootPart", 2)
			if targetRootPart then
				self:TP(targetRootPart)
			end

			local function step()
				local character = LocalPlayer.Character
				if not character then
					return true
				end

				local rootPart = WaitChild(character, "HumanoidRootPart", 2)
				local humanoid = WaitChild(character, "Humanoid", 2)

				if not rootPart or not humanoid or not humanoid.SeatPart then
					return false
				end

				self.MyBlob = humanoid.SeatPart.Parent
				local currentTarget = Players:FindFirstChild(playerName)

				if not currentTarget or not currentTarget.Character then
					return false
				end

				local targetHumanoid = WaitChild(currentTarget.Character, "Humanoid", 2)
				local targetRootPart = WaitChild(currentTarget.Character, "HumanoidRootPart", 2)

				if targetHumanoid and targetRootPart and targetHumanoid.Health ~= 0 then
					local distance = (rootPart.Position - targetRootPart.Position).Magnitude
					local shouldTeleport = distance > 15

					if shouldTeleport then
						shouldTeleport = tick() - self.LastTP > 0.5
					end

					if shouldTeleport then
						self:TP(targetRootPart)
					end

					if self.MyBlob and self.MyBlob.Parent then
						task.defer(function()
							if targetRootPart:GetNetworkOwner() == LocalPlayer then
								if tick() - self.Time > 0.5 then
									targetHumanoid.Sit = true
									task.wait(0.16)
									targetHumanoid.Sit = false
									self.Time = tick()
								end

								local leftDetector = self.MyBlob:FindFirstChild("LeftDetector")
								if leftDetector then
									targetRootPart.CFrame = leftDetector.CFrame
								end

								for _, child in ipairs(currentTarget.Character:GetChildren()) do
									if child:IsA("BasePart") then
										child.Velocity = Vector3.zero
									end
								end

								if distance < 40 and targetHumanoid.SeatPart then
									ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(targetRootPart, targetRootPart.CFrame)
								end
							end
						end)

						local leftDetector = self.MyBlob:FindFirstChild("LeftDetector")
						if leftDetector then
							local blobmanScript = self.MyBlob.BlobmanSeatAndOwnerScript
							blobmanScript.CreatureGrab:FireServer(leftDetector, targetRootPart, leftDetector.LeftWeld)
							task.wait(0.005)
							blobmanScript.CreatureRelease:FireServer(leftDetector.LeftWeld, targetRootPart)
						end
					end
				end

				return true
			end

			while self.Running do
				task.wait()

				if not step() then
					self:Stop()
					break
				end
			end
		end)
	end,
	Stop = function(self)
		self.Running = false
		self.MyBlob = nil
	end,
}


local function RemoveBlobmanFromPlayer(player)
	if not player or player == LocalPlayer then
		return
	end
	local myToys = LocalPlayer.Name .. "SpawnedInToys"
	local destroyToy = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("DestroyToy")
	local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	local toys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
	if not toys then
		return
	end

	for _, child in ipairs(toys:GetChildren()) do
		if child.Name == "CreatureBlobman" then
			-- never own folder / seat
			if child.Parent and child.Parent.Name == myToys then
				-- skip
			elseif myHum and myHum.SeatPart and myHum.SeatPart.Parent == child then
				-- skip
			else
				pcall(function()
					if destroyToy then
						destroyToy:FireServer(child)
					end
				end)
				task.wait(0.05)
				pcall(function()
					if child.Parent then
						child:Destroy()
					end
				end)
			end
		end
	end
end


DestroyGucciLoop = function()
	while State.runtime.destroyGucci do
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				pcall(RemoveBlobmanFromPlayer, player)
			end
		end
		task.wait(0.8)
	end
end


RemoveAntiInputLoop = function()
	local holdableNames = {
		FoodHamburger = true,
		FoodCoconut = true,
		FoodPizzaCheese = true,
		FoodPizzaPepperoni = true,
		FoodHotdog = true,
		FoodMushroomPoison = true,
		FoodBread = true,
		FoodDippyEgg = true,
		FoodMayonnaise = true,
		FoodFrenchFries = true,
		FoodMeatStick = true,
		FoodDonut = true,
		FoodCakePink = true,
		InstrumentGuitarBanjo = true,
		InstrumentGuitarViolin = true,
		InstrumentGuitarUkulele = true,
		InstrumentWoodwindSaxophone = true,
		InstrumentBrassTrumpet = true,
		InstrumentDrumBongos = true,
		InstrumentDrumSnare = true,
		InstrumentPianoMelodica = true,
		InstrumentVoiceMicrophone = true,
		CupMugWhite = true,
		CupMugBrown = true,
		PoopPile = true,
		PoopPileSparkle = true,
	}

	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local holdables = {}

	local connection = workspace.DescendantAdded:Connect(function(descendant)
		if holdableNames[descendant.Name] and descendant:IsA("Model") then
			task.spawn(function()
				if descendant:WaitForChild("HoldPart", 3) then
					table.insert(holdables, descendant)
				end
			end)
		end
	end)

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if holdableNames[descendant.Name] and descendant:IsA("Model") and descendant:FindFirstChild("HoldPart") then
			table.insert(holdables, descendant)
		end
	end

	while State.runtime.antiInput do
		for i = #holdables, 1, -1 do
			local holdable = holdables[i]

			if not holdable or not holdable.Parent or not holdable:FindFirstChild("HoldPart") then
				table.remove(holdables, i)
			else
				local holdPart = holdable.HoldPart

				pcall(function()
					holdPart.HoldItemRemoteFunction:InvokeServer(holdable, character)
				end)

				task.wait()

				pcall(function()
					holdPart.DropItemRemoteFunction:InvokeServer(holdable, CFrame.new(rootPart.Position + Vector3.new(0, -2000, 0)), Vector3.zero)
				end)
			end
		end

		task.wait()
	end

	connection:Disconnect()
end

IsEspTarget = function(instance)
	if not instance:IsA("BasePart") then
		return false
	end

	for _, targetName in ipairs(EspTargetNames) do
		if string.lower(instance.Name) == string.lower(targetName) then
			return true
		end
	end

	return false
end

AddEspBox = function(adornee)
	if State.runtime.espBoxes[adornee] then
		State.runtime.espBoxes[adornee].Color3 = State.runtime.espColor
		return
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = adornee
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Color3 = State.runtime.espColor
	box.Transparency = 0.5
	box.Size = adornee.Size
	box.Parent = game.CoreGui
	State.runtime.espBoxes[adornee] = box

	adornee.AncestryChanged:Connect(function(_, parent)
		if not parent and State.runtime.espBoxes[adornee] then
			State.runtime.espBoxes[adornee]:Destroy()
			State.runtime.espBoxes[adornee] = nil
		end
	end)
end

ClearEspBoxes = function()
	for _, box in pairs(State.runtime.espBoxes) do
		if box then
			box:Destroy()
		end
	end

	State.runtime.espBoxes = {}
end

RefreshEspBoxes = function()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if State.runtime.espOn and IsEspTarget(descendant) then
			AddEspBox(descendant)
		end
	end
end

WatchPacketNotify = function()
	ReplicatedStorage.GrabEvents.ExtendGrabLine.OnClientEvent:Connect(function(source, payload)
		if typeof(payload) == "string" and not State.runtime.pktCooldown and State.runtime.pktNotify then
			State.runtime.pktCooldown = true
			local length = string.len(payload)

			if length > 300 then
				local sizeMB = math.round(length / 1024 / 1024 * 1000) / 1000

				Library:Notify({
					Title = "Rose",
					Description = "PACKET LAG\nSource: " .. tostring(source):sub(1, 20) .. "\nSize: " .. sizeMB .. " MB",
					Time = 5,
				})
			end

			task.delay(5, function()
				State.runtime.pktCooldown = false
			end)
		end
	end)
end

local function SetRagdollConstraintsEnabled(character)
	for _, child in pairs(character:GetChildren()) do
		if child:IsA("BasePart") and child:FindFirstChild("BallSocketConstraint") and child.Name ~= "Head" then
			child.BallSocketConstraint.Enabled = true

			if child:FindFirstChild("RagdollLimbPart") then
				child.RagdollLimbPart.WeldConstraint.Enabled = true
			end
		end
	end
end

local function DisableRagdollConstraints(character)
	for _, child in pairs(character:GetChildren()) do
		if child:IsA("BasePart") and child:FindFirstChild("BallSocketConstraint") and child.Name ~= "Head" then
			child.BallSocketConstraint.Enabled = false

			if child:FindFirstChild("RagdollLimbPart") then
				child.RagdollLimbPart.WeldConstraint.Enabled = false
			end
		end
	end
end

local function EscapeGrab(head, humanoid, rootPart)
	local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
	local struggle = characterEvents and characterEvents:FindFirstChild("Struggle")
	local ragdollRemote = characterEvents and characterEvents:FindFirstChild("RagdollRemote")
	rootPart.Anchored = true

	task.spawn(function()
		while head:FindFirstChild("PartOwner") or (LocalPlayer:FindFirstChild("IsHeld") and LocalPlayer.IsHeld.Value) do
			if struggle then
				pcall(function()
					struggle:FireServer(LocalPlayer)
				end)
			end

			if ragdollRemote then
				pcall(function()
					ragdollRemote:FireServer(rootPart, 0)
				end)
			end

			pcall(function()
				rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * humanoid.WalkSpeed / 60
				humanoid.PlatformStand = false
				humanoid.Sit = false
				humanoid.AutoRotate = true
			end)

			task.wait()
		end

		pcall(function()
			rootPart.Anchored = false
		end)

		task.spawn(function()
			task.wait(0.3)
			local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
			local destroyGrabLine = grabEvents and grabEvents:FindFirstChild("DestroyGrabLine")

			if destroyGrabLine then
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character then
						local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
						local otherHead = player.Character:FindFirstChild("Head")

						if otherRoot then
							for i = 1, 3 do
								pcall(function()
									destroyGrabLine:FireServer(otherRoot)
								end)
							end
						end

						if otherHead then
							pcall(function()
								destroyGrabLine:FireServer(otherHead)
							end)
						end

						for _, descendant in ipairs(player.Character:GetDescendants()) do
							if descendant.Name == "PartOwner" then
								pcall(function()
									destroyGrabLine:FireServer(descendant.Parent)
								end)
							end
						end
					end
				end
			end
		end)

		State.refs.antiGrabProc = false
	end)
end

StartAntiGrab = function(character)
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local head = character:FindFirstChild("Head")
	if not (rootPart and humanoid and head) then
		return
	end

	DisableRagdollConstraints(character)
	local antiGrab = State.connections.antiGrab

	if antiGrab.Head then
		antiGrab.Head:Disconnect()
	end

	antiGrab.Head = head.ChildAdded:Connect(function(child)
		if child.Name ~= "PartOwner" or State.refs.antiGrabProc then
			return
		end

		State.refs.antiGrabProc = true
		humanoid.Sit = false
		EscapeGrab(head, humanoid, rootPart)
	end)

	if antiGrab.Hum then
		antiGrab.Hum:Disconnect()
	end

	antiGrab.Hum = humanoid.Changed:Connect(function(property)
		if property == "Sit" and humanoid.Sit then
			if not (humanoid.SeatPart and humanoid.SeatPart.Parent and humanoid.SeatPart.Parent.Name == "CreatureBlobman") then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				humanoid.Sit = false
			end
		end
	end)
end

StopAntiGrab = function()
	for _, connection in pairs(State.connections.antiGrab) do
		if connection then
			connection:Disconnect()
		end
	end

	State.connections.antiGrab = {}
	State.refs.antiGrabProc = false
end

AntiExplosionStep = function()
	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local ragdolled = humanoid and humanoid:FindFirstChild("Ragdolled")

	if ragdolled and ragdolled.Value then
		local gameCorrectionEvents = ReplicatedStorage:FindFirstChild("GameCorrectionEvents")
		local stopAllVelocity = gameCorrectionEvents and gameCorrectionEvents:FindFirstChild("StopAllVelocity")

		if stopAllVelocity then
			pcall(function()
				stopAllVelocity:FireServer()
			end)
		end

		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				pcall(function()
					descendant.AssemblyLinearVelocity = Vector3.zero
					descendant.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
	end
end

IsGrabBeam = function(instance)
	if instance:IsA("Beam") then
		return true
	end

	local lowerName = string.lower(instance.Name)
	return lowerName:find("grabbeam") ~= nil or lowerName:find("grabline") ~= nil
end

ClearGrabBeams = function()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if IsGrabBeam(descendant) then
			pcall(function()
				descendant:Destroy()
			end)
		end
	end
end

DestroyAntiKickToys = function()
	local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
	local destroyToy = menuToys and menuToys:FindFirstChild("DestroyToy")

	if toys and destroyToy then
		for _, child in pairs(toys:GetChildren()) do
			if child.Name == "AntiKick" or child.Name == "AntiKickItem" or child.Name == "NinjaShuriken" or child.Name == "SpookyCandle1" or child.Name == "ClockAlarm" or child.Name == "FoodPlate" then
				pcall(function()
					destroyToy:FireServer(child)
				end)
			end
		end
	end
end

StopAntiVoid = function()
	for _, connection in ipairs(State.connections.antiVoid) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	State.connections.antiVoid = {}

	if State.refs.antiVoidOriginalFallenHeight ~= nil then
		workspace.FallenPartsDestroyHeight = State.refs.antiVoidOriginalFallenHeight
		State.refs.antiVoidOriginalFallenHeight = nil
	end
end

local function FindExtinguishPart()
	local direct = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Hole") and workspace.Map.Hole:FindFirstChild("PoisonBigHole") and workspace.Map.Hole.PoisonBigHole:FindFirstChild("ExtinguishPart")
	if direct and direct:IsA("BasePart") then
		return direct
	end

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "ExtinguishPart" then
			return descendant
		end
	end
end

StopAntiBurn = function()
	for _, connection in ipairs(State.connections.antiBurn) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	State.connections.antiBurn = {}
end

StartAntiBurn = function(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then
		return
	end

	local extinguishPart = FindExtinguishPart()

	if extinguishPart and extinguishPart:IsA("BasePart") then
		extinguishPart.Size = Vector3.new(0.5, 0.5, 0.5)
		extinguishPart.Transparency = 1
		local tex = extinguishPart:FindFirstChild("Tex")

		if tex and tex:IsA("Decal") then
			tex.Transparency = 1
		end
	end

	local function extinguish()
		local firePlayerPart = character:FindFirstChild("FirePlayerPart", true)
		if not firePlayerPart or not extinguishPart then
			return
		end

		local savedCFrame = extinguishPart.CFrame
		local savedSize = extinguishPart.Size

		task.spawn(function()
			while firePlayerPart and firePlayerPart.Parent do
				local fireDebounce = humanoid:FindFirstChild("FireDebounce")
				local canBurn = firePlayerPart:FindFirstChild("CanBurn")

				if (fireDebounce and fireDebounce.Value) or (canBurn and canBurn.Value) then
					if canBurn then
						canBurn.Value = false
					end

					if fireDebounce then
						fireDebounce.Value = false
					end

					extinguishPart.CFrame = firePlayerPart.CFrame * CFrame.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))

					if firetouchinterest then
						firetouchinterest(firePlayerPart, extinguishPart, 0)
						task.wait()
						firetouchinterest(firePlayerPart, extinguishPart, 1)
					else
						task.wait(0.05)
					end
				else
					break
				end
			end

			pcall(function()
				extinguishPart.CFrame = savedCFrame
				extinguishPart.Size = savedSize
			end)
		end)
	end

	local fireDebounce = humanoid:FindFirstChild("FireDebounce")
	if fireDebounce then
		table.insert(State.connections.antiBurn, fireDebounce:GetPropertyChangedSignal("Value"):Connect(function()
			if fireDebounce.Value then
				extinguish()
			end
		end))

		if fireDebounce.Value then
			extinguish()
		end
	end

	local firePlayerPart = character:FindFirstChild("FirePlayerPart", true)
	if firePlayerPart and firePlayerPart:FindFirstChild("CanBurn") then
		table.insert(State.connections.antiBurn, firePlayerPart.CanBurn:GetPropertyChangedSignal("Value"):Connect(function()
			if firePlayerPart.CanBurn.Value then
				extinguish()
			end
		end))

		if firePlayerPart.CanBurn.Value then
			extinguish()
		end
	end
end

StopAntiFreeze = function()
	for _, connection in ipairs(State.connections.antiFreeze) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	State.connections.antiFreeze = {}

	if State.refs.antiFreezeHeartbeat then
		pcall(function()
			State.refs.antiFreezeHeartbeat:Disconnect()
		end)

		State.refs.antiFreezeHeartbeat = nil
	end
end

ClearFreeze = function(character)
	pcall(function()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not rootPart then
			return
		end

		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				for _, child in ipairs(descendant:GetChildren()) do
					if child:IsA("BodyPosition") or child:IsA("BodyGyro") or child.Name == "FreezeGrabBodyPosition" or child.Name == "FreezeGrabBodyGyro" then
						child:Destroy()
					end
				end

				descendant.Anchored = false
				descendant.AssemblyLinearVelocity = Vector3.zero
				descendant.AssemblyAngularVelocity = Vector3.zero
			end
		end

		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end)
end

WatchAntiFreeze = function(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	table.insert(State.connections.antiFreeze, character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BodyPosition") or descendant:IsA("BodyGyro") or descendant.Name == "FreezeGrabBodyPosition" or descendant.Name == "FreezeGrabBodyGyro" then
			ClearFreeze(character)
		end
	end))

	table.insert(State.connections.antiFreeze, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
		if humanoid.PlatformStand then
			ClearFreeze(character)
		end
	end))
end

RemovePaintParts = function()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "PaintPlayerPart" then
			pcall(function()
				descendant:Destroy()
			end)
		end
	end
end

SetCharacterCollision = function(enabled)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("BasePart") then
			child.CanTouch = enabled
			child.CanQuery = enabled
		end
	end
end

StopAntiPaint = function()
	for _, connection in ipairs(State.connections.antiPaint) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	State.connections.antiPaint = {}
	SetCharacterCollision(true)
end

StopAntiPoison = function()
	for _, connection in ipairs(State.connections.antiPoison) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	State.connections.antiPoison = {}
end

StopPcldBreak = function()
	State.refs.pcldActive = false
end

StartPcldBreak = function()
	StopPcldBreak()
	State.refs.pcldActive = true

	task.spawn(function()
		local firstDeath = true

		while State.refs.pcldActive do
			local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local rootPart = character:WaitForChild("HumanoidRootPart", 5)
			local humanoid = character:WaitForChild("Humanoid", 5)

			if not rootPart or not humanoid then
				task.wait(0.5)
			else
				if humanoid.Health <= 0 then
					character = LocalPlayer.CharacterAdded:Wait()
					rootPart = character:WaitForChild("HumanoidRootPart", 5)
					humanoid = character:WaitForChild("Humanoid", 5)
				end

				if rootPart and humanoid then
					if firstDeath then
						local savedCFrame = rootPart.CFrame
						rootPart.CFrame = CFrame.new(rootPart.Position.X, 50000, rootPart.Position.Z)
						task.wait(0.05)
						humanoid.Health = 0
						local respawned = LocalPlayer.CharacterAdded:Wait()
						if not State.refs.pcldActive then
							break
						end

						local newRootPart = respawned:WaitForChild("HumanoidRootPart", 5)
						local newHumanoid = respawned:WaitForChild("Humanoid", 5)

						if newRootPart and newHumanoid then
							task.wait(0.1)
							newRootPart.CFrame = savedCFrame
							task.wait(0.05)
							newHumanoid.Health = 0
						end

						firstDeath = false
						character = LocalPlayer.CharacterAdded:Wait()
						if not State.refs.pcldActive then
							break
						end

						local nextHumanoid = character:WaitForChild("Humanoid", 5)
						if nextHumanoid then
							nextHumanoid.Died:Wait()
						end
					else
						task.wait(0.1)
						humanoid.Health = 0
						pcall(function()
							character:BreakJoints()
						end)
						character = LocalPlayer.CharacterAdded:Wait()
						if not State.refs.pcldActive then
							break
						end

						local nextHumanoid = character:WaitForChild("Humanoid", 5)
						if nextHumanoid then
							nextHumanoid.Died:Wait()
						end
					end
				end
			end
		end
	end)
end

StopGucci = function()
	State.refs.gucciActive = false

	if State.connections.gucci then
		State.connections.gucci:Disconnect()
		State.connections.gucci = nil
	end

	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	if State.refs.gucciVehicle and State.refs.gucciVehicle.Parent then
		pcall(function()
			ReplicatedStorage.MenuToys.DestroyToy:FireServer(State.refs.gucciVehicle)
		end)
	end

	State.refs.gucciVehicle = nil
end

StartGucci = function(gucciType)
	StopGucci()
	State.refs.gucciActive = true

	task.spawn(function()
		local character = LocalPlayer.Character
		local rootPart = character and character:WaitForChild("HumanoidRootPart", 3)
		local humanoid = character and character:WaitForChild("Humanoid", 3)
		if not rootPart or not humanoid then
			return
		end

		local savedCFrame = rootPart.CFrame
		local vehicleSeat = nil
		local isTrain = false

		if gucciType == "Anti Kill (Train)" then
			isTrain = true
			local alwaysHere = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("AlwaysHereTweenedObjects")
			local train = alwaysHere and alwaysHere:FindFirstChild("Train")

			if train then
				for _, descendant in ipairs(train:GetDescendants()) do
					if descendant:IsA("Seat") then
						vehicleSeat = descendant
						break
					end
				end
			end

			if not vehicleSeat then
				return
			end
		else
			local toyName = gucciType == "Godmode (Blobman)" and "CreatureBlobman" or "TractorGreen"

			pcall(function()
				ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer(toyName, CFrame.new(0, 50000, 0), Vector3.zero)
			end)

			local toys = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5)

			if toys then
				local toy = toys:WaitForChild(toyName, 5)

				if toy then
					State.refs.gucciVehicle = toy
					vehicleSeat = toy:WaitForChild("VehicleSeat", 3) or toy:FindFirstChildWhichIsA("VehicleSeat", true) or toy:FindFirstChildWhichIsA("Seat", true)
				end
			end
		end

		if not vehicleSeat then
			return
		end

		local startTime = tick()

		while vehicleSeat.Occupant ~= humanoid and tick() - startTime < 3 and State.refs.gucciActive do
			if not isTrain then
				vehicleSeat.CFrame = CFrame.new(0, 50000, 0)
			end

			rootPart.CFrame = vehicleSeat.CFrame + Vector3.new(0, 2, 0)
			vehicleSeat:Sit(humanoid)
			task.wait(0.05)
		end

		if not State.refs.gucciActive then
			return
		end

		rootPart.CFrame = savedCFrame

		State.connections.gucci = RunService.Heartbeat:Connect(function()
			if not rootPart or not rootPart.Parent or not humanoid then
				return
			end

			pcall(function()
				ReplicatedStorage.CharacterEvents.RagdollRemote:FireServer(rootPart, 0)
			end)

			if not isTrain and vehicleSeat and vehicleSeat.Parent then
				vehicleSeat.CFrame = CFrame.new(0, 50000, 0)
				vehicleSeat.AssemblyLinearVelocity = Vector3.zero
				vehicleSeat.AssemblyAngularVelocity = Vector3.zero
			end

			if humanoid.Sit then
				rootPart.CFrame = savedCFrame
			else
				savedCFrame = rootPart.CFrame
			end
		end)
	end)
end

GetBlobmen = function()
	local blobmen = {}
	local plotItems = workspace:FindFirstChild("PlotItems")

	if plotItems then
		for _, plot in pairs(plotItems:GetChildren()) do
			if plot.Name ~= "PlayersInPlots" then
				for _, child in pairs(plot:GetChildren()) do
					if child.Name == "CreatureBlobman" then
						table.insert(blobmen, child)
					end
				end
			end
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		local toys = workspace:FindFirstChild(player.Name .. "SpawnedInToys")

		if toys then
			for _, child in pairs(toys:GetChildren()) do
				if child.Name == "CreatureBlobman" then
					table.insert(blobmen, child)
				end
			end
		end
	end

	for _, child in pairs(workspace:GetChildren()) do
		if child.Name == "CreatureBlobman" then
			table.insert(blobmen, child)
		end
	end

	return blobmen
end

DropBlobmanCreatures = function(blobman, targetRootPart)
	local blobmanScript = blobman:FindFirstChild("BlobmanSeatAndOwnerScript")
	if not blobmanScript then
		return
	end

	local creatureDrop = blobmanScript:FindFirstChild("CreatureDrop")
	if not creatureDrop then
		return
	end

	local rightDetector = blobman:FindFirstChild("RightDetector")
	local leftDetector = blobman:FindFirstChild("LeftDetector")

	if rightDetector then
		local rightWeld = rightDetector:FindFirstChild("RightWeld")

		if rightWeld then
			pcall(function()
				creatureDrop:FireServer(rightWeld, targetRootPart)
			end)
		end
	end

	if leftDetector then
		local leftWeld = leftDetector:FindFirstChild("LeftWeld")

		if leftWeld then
			pcall(function()
				creatureDrop:FireServer(leftWeld, targetRootPart)
			end)
		end
	end

	local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")

	if characterEvents then
		local struggle = characterEvents:FindFirstChild("Struggle")

		if struggle then
			pcall(function()
				struggle:FireServer(LocalPlayer)
			end)
		end
	end
end
local function SaveOriginalSkybox()
	if State.refs.skyboxOrig.saved then
		return
	end

	local sky = Lighting:FindFirstChildOfClass("Sky")

	if sky then
		State.refs.skyboxOrig.originalSky = sky
		State.refs.skyboxOrig.originalBk = sky.SkyboxBk
		State.refs.skyboxOrig.originalDn = sky.SkyboxDn
		State.refs.skyboxOrig.originalFt = sky.SkyboxFt
		State.refs.skyboxOrig.originalLf = sky.SkyboxLf
		State.refs.skyboxOrig.originalRt = sky.SkyboxRt
		State.refs.skyboxOrig.originalUp = sky.SkyboxUp
	end

	State.refs.skyboxOrig.saved = true
end

ApplySkybox = function(presetName)
	if State.refs.currentSkybox == presetName then
		return
	end

	SaveOriginalSkybox()
	local preset = SkyboxPresets[presetName] or SkyboxPresets.HD
	local sky = Lighting:FindFirstChildOfClass("Sky")

	if not sky then
		sky = Instance.new("Sky")
		sky.Parent = Lighting
	end

	sky.SkyboxBk = preset.Bk
	sky.SkyboxDn = preset.Dn
	sky.SkyboxFt = preset.Ft
	sky.SkyboxLf = preset.Lf
	sky.SkyboxRt = preset.Rt
	sky.SkyboxUp = preset.Up
	sky.StarCount = 3000
	sky.SunAngularSize = 11
	sky.MoonAngularSize = 11
	State.refs.currentSkybox = presetName
end

RestoreSkybox = function()
	if not State.refs.currentSkybox then
		return
	end

	local original = State.refs.skyboxOrig

	if original.originalSky then
		original.originalSky.SkyboxBk = original.originalBk or ""
		original.originalSky.SkyboxDn = original.originalDn or ""
		original.originalSky.SkyboxFt = original.originalFt or ""
		original.originalSky.SkyboxLf = original.originalLf or ""
		original.originalSky.SkyboxRt = original.originalRt or ""
		original.originalSky.SkyboxUp = original.originalUp or ""

		if not original.originalSky.Parent then
			original.originalSky.Parent = Lighting
		end
	else
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Sky") then
				child:Destroy()
			end
		end
	end

	State.refs.currentSkybox = nil
end

local BlackholeNames = {
	blackholekick = true,
	blackholekicktweens = true,
	["blackholekicktweens(old)"] = true,
	jhole = true,
	blackhole = true,
	black_hole = true,
	voidhole = true,
	singularity = true,
}

IsBlackholeName = function(name)
	if not name then
		return false
	end

	return BlackholeNames[name:lower()] == true
end

ApplyBlackholeTexture = function(instance, texture)
	if not instance or not texture then
		return
	end

	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("Decal") or descendant:IsA("Texture") then
			if not State.refs.blackholeOrig[descendant] then
				State.refs.blackholeOrig[descendant] = descendant.Texture
			end

			descendant.Texture = texture
		elseif descendant:IsA("ParticleEmitter") then
			if not State.refs.blackholeOrig[descendant] then
				State.refs.blackholeOrig[descendant] = descendant.Texture
			end

			descendant.Texture = texture
		elseif descendant:IsA("ImageLabel") then
			if not State.refs.blackholeOrig[descendant] then
				State.refs.blackholeOrig[descendant] = descendant.Image
			end

			descendant.Image = texture
		elseif descendant:IsA("SurfaceAppearance") then
			if not State.refs.blackholeOrig[descendant] then
				State.refs.blackholeOrig[descendant] = descendant.ColorMap
			end

			descendant.ColorMap = texture
		end
	end

	if instance:IsA("BasePart") then
		for _, child in ipairs(instance:GetChildren()) do
			if child:IsA("Decal") or child:IsA("Texture") then
				if not State.refs.blackholeOrig[child] then
					State.refs.blackholeOrig[child] = child.Texture
				end

				child.Texture = texture
			end
		end
	end
end

RestoreBlackholeTextures = function()
	for instance, original in pairs(State.refs.blackholeOrig) do
		if instance and instance.Parent then
			pcall(function()
				if instance:IsA("Decal") or instance:IsA("Texture") then
					instance.Texture = original
				elseif instance:IsA("ParticleEmitter") then
					instance.Texture = original
				elseif instance:IsA("ImageLabel") then
					instance.Image = original
				elseif instance:IsA("SurfaceAppearance") then
					instance.ColorMap = original
				end
			end)
		end
	end

	State.refs.blackholeOrig = {}
end

WatchBlackholes = function()
	if State.connections.blackholeWatch then
		return
	end

	local function applyToBlackhole(instance)
		if not State.refs.currentBlackhole or not IsBlackholeName(instance.Name) then
			return
		end

		local texture = BlackholeTextures[State.refs.currentBlackhole]
		if not texture then
			return
		end

		task.wait(0.1)
		pcall(function()
			ApplyBlackholeTexture(instance, texture)
		end)
	end

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if IsBlackholeName(descendant.Name) then
			local texture = BlackholeTextures[State.refs.currentBlackhole]

			if texture then
				pcall(function()
					ApplyBlackholeTexture(descendant, texture)
				end)
			end
		end
	end

	State.connections.blackholeWatch = workspace.DescendantAdded:Connect(applyToBlackhole)
end

StopWatchBlackholes = function()
	if State.connections.blackholeWatch then
		State.connections.blackholeWatch:Disconnect()
		State.connections.blackholeWatch = nil
	end
end

ApplyShader = function(themeName)
	local preset = ShaderPresets[themeName]
	if not preset then
		return
	end

	State.refs.currentShaderTheme = themeName
	Lighting.Brightness = preset.Brightness
	Lighting.Ambient = preset.Ambient
	Lighting.OutdoorAmbient = preset.OutdoorAmbient

	if preset.ClockTime then
		Lighting.ClockTime = preset.ClockTime
	end

	Lighting.FogEnd = preset.FogEnd

	if preset.FogStart then
		Lighting.FogStart = preset.FogStart
	end

	if preset.ExposureCompensation then
		Lighting.ExposureCompensation = preset.ExposureCompensation
	end

	Lighting.GlobalShadows = false
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if atmosphere then
		atmosphere.Enabled = false
	end

	if preset.CC then
		if not State.refs.ccEffect then
			State.refs.ccEffect = Instance.new("ColorCorrectionEffect")
			State.refs.ccEffect.Parent = Lighting
		end

		State.refs.ccEffect.Brightness = preset.CC.Brightness
		State.refs.ccEffect.Contrast = preset.CC.Contrast
		State.refs.ccEffect.Saturation = preset.CC.Saturation
		State.refs.ccEffect.TintColor = preset.CC.Tint
		State.refs.ccEffect.Enabled = true
	end

	if preset.Bloom then
		if not State.refs.bloomEffect then
			State.refs.bloomEffect = Instance.new("BloomEffect")
			State.refs.bloomEffect.Parent = Lighting
		end

		State.refs.bloomEffect.Intensity = preset.Bloom.Intensity
		State.refs.bloomEffect.Size = preset.Bloom.Size
		State.refs.bloomEffect.Threshold = preset.Bloom.Threshold
		State.refs.bloomEffect.Enabled = true
	elseif State.refs.bloomEffect then
		State.refs.bloomEffect.Enabled = false
	end
end

RestoreShader = function()
	local original = State.refs.originalLight
	Lighting.Brightness = original.Brightness
	Lighting.Ambient = original.Ambient
	Lighting.OutdoorAmbient = original.OutdoorAmbient
	Lighting.ClockTime = original.ClockTime or 14

	if original.TimeOfDay then
		Lighting.TimeOfDay = original.TimeOfDay
	end

	Lighting.FogEnd = original.FogEnd
	Lighting.FogStart = original.FogStart
	Lighting.ExposureCompensation = original.ExposureCompensation
	Lighting.GlobalShadows = true
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

	if atmosphere then
		atmosphere.Enabled = true
	end

	if State.refs.ccEffect then
		State.refs.ccEffect:Destroy()
		State.refs.ccEffect = nil
	end

	if State.refs.bloomEffect then
		State.refs.bloomEffect:Destroy()
		State.refs.bloomEffect = nil
	end

	State.refs.currentShaderTheme = nil
end

task.spawn(function()
	while task.wait(0.2) do
		local preset = State.refs.currentShaderTheme and ShaderPresets[State.refs.currentShaderTheme]

		if preset then
			Lighting.Brightness = preset.Brightness
			Lighting.Ambient = preset.Ambient
			Lighting.OutdoorAmbient = preset.OutdoorAmbient

			if preset.ClockTime then
				Lighting.ClockTime = preset.ClockTime
			end

			if preset.ExposureCompensation then
				Lighting.ExposureCompensation = preset.ExposureCompensation
			end

			Lighting.GlobalShadows = false
			Lighting.FogEnd = preset.FogEnd

			if preset.FogStart then
				Lighting.FogStart = preset.FogStart
			end

			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

			if atmosphere then
				atmosphere.Enabled = false
			end

			if State.refs.ccEffect and preset.CC then
				State.refs.ccEffect.Enabled = true
			end

			if State.refs.bloomEffect and preset.Bloom then
				State.refs.bloomEffect.Enabled = true
			end
		end
	end
end)

local function SpawnJumpCircle(position)
	if not State.refs.jumpCircleOn then
		return
	end

	local texture = JumpCircleTextures[State.refs.jumpCircleType]
	if not texture then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { LocalPlayer.Character }
	local hit = workspace:Raycast(position + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), raycastParams)
	hit = hit and hit.Position + Vector3.new(0, 0.05, 0) or position

	local circlePart = Instance.new("Part")
	circlePart.Anchored = true
	circlePart.CanCollide = false
	circlePart.CanQuery = false
	circlePart.CanTouch = false
	circlePart.Transparency = 1
	circlePart.Size = Vector3.new(3, 0.1, 3)
	circlePart.CFrame = CFrame.new(hit)
	circlePart.Parent = workspace

	local topDecal = Instance.new("Decal")
	topDecal.Face = Enum.NormalId.Top
	topDecal.Texture = texture
	topDecal.Transparency = 0
	topDecal.Parent = circlePart

	local bottomDecal = Instance.new("Decal")
	bottomDecal.Face = Enum.NormalId.Bottom
	bottomDecal.Texture = texture
	bottomDecal.Transparency = 0
	bottomDecal.Parent = circlePart

	task.spawn(function()
		local startTime = tick()

		while tick() - startTime < 1 do
			local size = 3 + 7 * (tick() - startTime) / 1
			circlePart.Size = Vector3.new(size, 0.1, size)
			task.wait()
		end

		circlePart.Size = Vector3.new(10, 0.1, 10)
		task.wait(0.1)

		local fadeStart = tick()

		while tick() - fadeStart < 0.4 do
			local transparency = (tick() - fadeStart) / 0.4
			topDecal.Transparency = transparency
			bottomDecal.Transparency = transparency
			task.wait()
		end

		pcall(function()
			circlePart:Destroy()
		end)
	end)
end

local function HookJumpCircle(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	humanoid.StateChanged:Connect(function(_, newState)
		if not State.refs.jumpCircleOn then
			return
		end

		if newState == Enum.HumanoidStateType.Landed then
			local rootPart = character:FindFirstChild("HumanoidRootPart")

			if rootPart then
				SpawnJumpCircle(rootPart.Position - Vector3.new(0, 2.5, 0))
			end
		end
	end)
end

StartJumpCircle = function()
	if LocalPlayer.Character then
		HookJumpCircle(LocalPlayer.Character)
	end

	if State.connections.jumpCircle then
		State.connections.jumpCircle:Disconnect()
	end

	State.connections.jumpCircle = LocalPlayer.CharacterAdded:Connect(function(character)
		task.wait(0.5)

		if State.refs.jumpCircleOn then
			HookJumpCircle(character)
		end
	end)
end

StopJumpCircle = function()
	State.refs.jumpCircleOn = false

	if State.connections.jumpCircle then
		State.connections.jumpCircle:Disconnect()
		State.connections.jumpCircle = nil
	end
end

CreateTraceBeam = function(targetName, isEnabled)
	if not Players:FindFirstChild(targetName) then
		return
	end

	local startPart = Instance.new("Part", workspace)
	startPart.Anchored = true
	startPart.CanCollide = false
	startPart.Transparency = 1
	startPart.Size = Vector3.new(0.1, 0.1, 0.1)
	startPart.CanQuery = false
	startPart.CanTouch = false

	local endPart = Instance.new("Part", workspace)
	endPart.Anchored = true
	endPart.CanCollide = false
	endPart.Transparency = 1
	endPart.Size = Vector3.new(0.1, 0.1, 0.1)
	endPart.CanQuery = false
	endPart.CanTouch = false

	local startAttachment = Instance.new("Attachment", startPart)
	local endAttachment = Instance.new("Attachment", endPart)

	local beam = Instance.new("Beam", workspace)
	beam.Texture = BeamTexture
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.TextureLength = 2
	beam.TextureSpeed = 4
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Width0 = 3
	beam.Width1 = 3
	beam.Segments = 10
	beam.Attachment0 = startAttachment
	beam.Attachment1 = endAttachment

	return RunService.RenderStepped:Connect(function()
		local traceTarget = State.runtime.traceTarget

		if not isEnabled() or not traceTarget or not Players:FindFirstChild(traceTarget) then
			beam:Destroy()
			startPart:Destroy()
			endPart:Destroy()
			return
		end

		local targetPlayer = Players:FindFirstChild(traceTarget)
		local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetRootPart = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")

		if rootPart and targetRootPart then
			startPart.Position = rootPart.Position
			endPart.Position = targetRootPart.Position
		end
	end), beam
end

AntiOwnershipLoop = function()
	local menuToys = ReplicatedStorage:WaitForChild("MenuToys", 10)
	local spawnToyRemoteFunction = menuToys and menuToys:WaitForChild("SpawnToyRemoteFunction", 10)
	local destroyToy = menuToys and menuToys:WaitForChild("DestroyToy", 10)
	local holdEvents = ReplicatedStorage:WaitForChild("HoldEvents", 10)
	local useItem = holdEvents and holdEvents:WaitForChild("Use", 10)
	local canSpawnToy = LocalPlayer:WaitForChild("CanSpawnToy", 10)

	if not spawnToyRemoteFunction or not useItem then
		return
	end

	local function findOwnPlot()
		local plotItems = workspace:FindFirstChild("PlotItems")
		local playersInPlots = plotItems and plotItems:FindFirstChild("PlayersInPlots")

		if not (playersInPlots and playersInPlots:FindFirstChild(LocalPlayer.Name)) then
			return false
		end

		local plots = workspace:FindFirstChild("Plots")
		if not plots then
			return false
		end

		for _, plot in pairs(plots:GetChildren()) do
			local plotSign = plot:FindFirstChild("PlotSign")
			plotSign = plotSign and plotSign:FindFirstChild("ThisPlotsOwners")

			if plotSign then
				for _, owner in pairs(plotSign:GetChildren()) do
					if owner.Value == LocalPlayer.Name then
						local container = plotItems:FindFirstChild(plot.Name)
						if container then
							return true, container
						end
					end
				end
			end
		end

		return false
	end

	local function getContainer()
		local owned, plot = findOwnPlot()
		if owned and plot then
			return plot
		end

		return workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	end

	local function getSelectedFoodAsset()
		return FoodAssets[State.refs.antiOwnSelectedFood] or "FoodHamburger"
	end

	local function getRootPart()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			return LocalPlayer.Character.HumanoidRootPart
		end

		return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart", 5)
	end

	local function spawnFood(assetName)
		local startTime = tick()

		while canSpawnToy and not canSpawnToy.Value do
			if not State.flags.antiOwnership or tick() - startTime > 3 then
				break
			end

			RunService.Heartbeat:Wait()
		end

		local rootPart = getRootPart()
		if not rootPart then
			return nil
		end

		task.spawn(function()
			pcall(function()
				spawnToyRemoteFunction:InvokeServer(assetName, rootPart.CFrame * CFrame.new(0, 5, -5), Vector3.zero)
			end)
		end)

		local waitStart = tick()

		repeat
			RunService.Heartbeat:Wait()
			local container = getContainer()
			local item = container and container:FindFirstChild(assetName)

			if item then
				return item
			end
		until not State.flags.antiOwnership or tick() - waitStart > 2

		return nil
	end

	local function hideItemParts(item)
		if not item then
			return
		end

		for _, descendant in ipairs(item:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			end
		end
	end

	local function isOwned(holdPart, character)
		local rigidConstraint = holdPart:FindFirstChild("RigidConstraint")
		if rigidConstraint and rigidConstraint.Attachment1 and rigidConstraint.Attachment1:IsDescendantOf(character) then
			return true
		end

		local holdingPlayer = holdPart:FindFirstChild("HoldingPlayer")
		return holdingPlayer ~= nil and holdingPlayer.Value == LocalPlayer
	end

	local function tryHold(item, holdPart, holdRemote, character)
		local startTime = tick()

		while item.Parent and State.flags.antiOwnership and tick() - startTime < 3 do
			if isOwned(holdPart, character) then
				return true
			end

			task.spawn(function()
				pcall(function()
					holdRemote:InvokeServer(item, character)
				end)
			end)

			hideItemParts(item)
			local waitStart = tick()

			repeat
				RunService.Heartbeat:Wait()

				if isOwned(holdPart, character) then
					return true
				end
			until tick() - waitStart > 0.5 or not item.Parent or not State.flags.antiOwnership
		end

		return false
	end

	local function handleItem(item, character)
		local holdPart = item:WaitForChild("HoldPart", 3)
		if not holdPart then
			return false
		end

		local holdRemote = holdPart:FindFirstChild("HoldItemRemoteFunction")
		if not holdRemote then
			return false
		end

		if not tryHold(item, holdPart, holdRemote, character) then
			pcall(function()
				destroyToy:FireServer(item)
			end)

			task.wait(0.1)
			return false
		end

		while State.flags.antiOwnership and item.Parent do
			local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

			if not humanoid or humanoid.Health <= 0 then
				break
			end

			local holdingPlayer = holdPart:FindFirstChild("HoldingPlayer")
			if holdingPlayer and holdingPlayer.Value and holdingPlayer.Value ~= LocalPlayer then
				break
			end

			if not isOwned(holdPart, character) then
				break
			end

			hideItemParts(item)
			pcall(function()
				useItem:FireServer(item)
			end)

			task.wait(0.1)
		end

		if item and item.Parent and not State.flags.antiOwnership then
			pcall(function()
				destroyToy:FireServer(item)
			end)
		end

		task.wait(0.05)
		return true
	end

	while State.flags.antiOwnership do
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			task.wait(0.1)
		else
			local foodAsset = getSelectedFoodAsset()
			local container = getContainer()
			local item = container and container:FindFirstChild(foodAsset)

			if not item then
				item = spawnFood(foodAsset)
			end

			if item then
				handleItem(item, character)
			else
				task.wait(0.05)
			end
		end
	end
end

StartAntiBlobman = function()
	State.refs.antiBlobmanRunning = true
	local character = LocalPlayer.Character

	if character and character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("TruePositionPart") then
		local truePositionPart = Instance.new("Part")
		truePositionPart.Parent = character
		truePositionPart.Name = "TruePositionPart"
		truePositionPart.Anchored = true
		truePositionPart.Transparency = 1
		truePositionPart.CanCollide = false
		truePositionPart.Size = Vector3.new(0.1, 0.1, 0.1)
		truePositionPart.CFrame = CFrame.new(0, -10000000, 0)
	end

	State.connections.antiBlobmanDesc = workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "CreatureBlobman" and State.refs.antiBlobmanRunning then
			task.defer(function()
				local leftDetector = descendant:WaitForChild("LeftDetector", 3)
				local rightDetector = descendant:WaitForChild("RightDetector", 3)
				local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

				if rootPart and descendant:FindFirstChild("Head") then
					if (descendant.Head.Position - rootPart.Position).Magnitude <= 15 then
						if leftDetector then
							pcall(function()
								leftDetector:Destroy()
							end)
						end

						if rightDetector then
							pcall(function()
								rightDetector:Destroy()
							end)
						end
					end
				end
			end)
		end
	end)

	State.connections.antiBlobmanHeartbeat = RunService.Heartbeat:Connect(function()
		local character = LocalPlayer.Character
		if not character then
			return
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

		local truePositionPart = character:FindFirstChild("TruePositionPart")

		if truePositionPart then
			local rootAttachment = rootPart:FindFirstChild("RootAttachment")

			if rootAttachment and rootAttachment.Parent == rootPart then
				pcall(function()
					rootAttachment.Parent = truePositionPart
				end)
			end
		end

		local massChanged = false

		for _, child in pairs(character:GetChildren()) do
			if child:IsA("Part") and child.Massless then
				child.Massless = false
				massChanged = true
			end
		end

		if massChanged then
			rootPart.AssemblyLinearVelocity = Vector3.new(0, 15000000, 0)

			for _, blobman in ipairs(GetBlobmen()) do
				pcall(function()
					DropBlobmanCreatures(blobman, rootPart)
				end)
			end
		end
	end)

	State.connections.antiBlobmanLoop = RunService.Heartbeat:Connect(function()
		local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then
			return
		end

		for _, blobman in ipairs(GetBlobmen()) do
			local head = blobman:FindFirstChild("Head")

			if head and (head.Position - rootPart.Position).Magnitude <= 15 then
				local leftDetector = blobman:FindFirstChild("LeftDetector")
				local rightDetector = blobman:FindFirstChild("RightDetector")

				if leftDetector and leftDetector.Parent then
					pcall(function()
						leftDetector:Destroy()
					end)
				end

				if rightDetector and rightDetector.Parent then
					pcall(function()
						rightDetector:Destroy()
					end)
				end
			end
		end
	end)
end

StopAntiBlobman = function()
	State.refs.antiBlobmanRunning = false

	if State.connections.antiBlobmanDesc then
		State.connections.antiBlobmanDesc:Disconnect()
		State.connections.antiBlobmanDesc = nil
	end

	if State.connections.antiBlobmanHeartbeat then
		State.connections.antiBlobmanHeartbeat:Disconnect()
		State.connections.antiBlobmanHeartbeat = nil
	end

	if State.connections.antiBlobmanLoop then
		State.connections.antiBlobmanLoop:Disconnect()
		State.connections.antiBlobmanLoop = nil
	end

	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local truePositionPart = character and character:FindFirstChild("TruePositionPart")

	if rootPart and truePositionPart then
		local rootAttachment = truePositionPart:FindFirstChild("RootAttachment")

		if rootAttachment then
			pcall(function()
				rootAttachment.Parent = rootPart
			end)
		end

		pcall(function()
			truePositionPart:Destroy()
		end)
	end
end

local LsdState = {
	active = false,
	conns = {},
	cc = nil,
	blur = nil,
	overlays = {},
	hue = 0,
	time = 0,
	blurTask = nil,
}

StartLSD = function()
	if LsdState.active then
		return
	end

	LsdState.active = true

	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "RoseLSD_CC"
	colorCorrection.Brightness = 0.05
	colorCorrection.Contrast = 0.15
	colorCorrection.Saturation = 0.4
	colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
	colorCorrection.Parent = Lighting
	LsdState.cc = colorCorrection

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "RoseLSD_Blur"
	blurEffect.Size = 0
	blurEffect.Parent = Lighting
	LsdState.blur = blurEffect

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RoseLSD_Overlay"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999998
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	local rainbowFrame = Instance.new("Frame")
	rainbowFrame.Name = "Rainbow"
	rainbowFrame.Size = UDim2.new(1, 0, 1, 0)
	rainbowFrame.Position = UDim2.new(0, 0, 0, 0)
	rainbowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	rainbowFrame.BackgroundTransparency = 0.92
	rainbowFrame.BorderSizePixel = 0
	rainbowFrame.ZIndex = 1
	rainbowFrame.Parent = screenGui

	local rainbowGradient = Instance.new("UIGradient", rainbowFrame)
	rainbowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 200, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(80, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 200)),
	})
	rainbowGradient.Rotation = 0
	LsdState.rainbowGradient = rainbowGradient
	table.insert(LsdState.overlays, rainbowFrame)

	for i = 1, 5 do
		local waveFrame = Instance.new("Frame")
		waveFrame.Name = "Wave" .. i
		waveFrame.Size = UDim2.new(1, 0, 0, 80 + i * 30)
		waveFrame.Position = UDim2.new(0, 0, i * 0.2 - 0.3, 0)
		waveFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		waveFrame.BackgroundTransparency = 0.94
		waveFrame.BorderSizePixel = 0
		waveFrame.ZIndex = 2
		waveFrame.Parent = screenGui

		local waveGradient = Instance.new("UIGradient", waveFrame)
		waveGradient.Rotation = 90
		waveGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		})
		waveGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 100)),
		})
		table.insert(LsdState.overlays, waveFrame)
	end

	LsdState.screenGui = screenGui

	LsdState.conns.render = RunService.RenderStepped:Connect(function(deltaTime)
		if not LsdState.active then
			return
		end

		LsdState.hue = (LsdState.hue + deltaTime * 0.15) % 1
		LsdState.time = LsdState.time + deltaTime

		if LsdState.cc then
			LsdState.cc.TintColor = Color3.fromHSV(LsdState.hue, 0.55, 1)
		end

		if LsdState.rainbowGradient then
			LsdState.rainbowGradient.Rotation = (LsdState.rainbowGradient.Rotation + deltaTime * 40) % 360
		end

		for i, overlay in ipairs(LsdState.overlays) do
			if overlay.Name:sub(1, 4) == "Wave" then
				overlay.Position = UDim2.new(0, 0, (LsdState.time * 0.35 + i * 0.15) % 1 * 1.4 - 0.2, 0)
			end
		end

		local camera = workspace.CurrentCamera

		if camera then
			camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, math.rad(math.sin(LsdState.time * 1.8) * 6 * deltaTime * 60 * 0.05))
		end
	end)

	LsdState.blurTask = task.spawn(function()
		while LsdState.active do
			task.wait(math.random(3, 6))

			if not LsdState.active or not LsdState.blur then
				break
			end

			TweenService:Create(LsdState.blur, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 24 }):Play()
			task.wait(1.5)

			if not LsdState.active or not LsdState.blur then
				break
			end

			TweenService:Create(LsdState.blur, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Size = 0 }):Play()
			task.wait(1.5)
		end
	end)
end

StopLSD = function()
	if not LsdState.active then
		return
	end

	LsdState.active = false

	if LsdState.conns.render then
		LsdState.conns.render:Disconnect()
		LsdState.conns.render = nil
	end

	if LsdState.blurTask then
		pcall(task.cancel, LsdState.blurTask)
		LsdState.blurTask = nil
	end

	if LsdState.cc then
		pcall(function()
			LsdState.cc:Destroy()
		end)

		LsdState.cc = nil
	end

	if LsdState.blur then
		pcall(function()
			LsdState.blur:Destroy()
		end)

		LsdState.blur = nil
	end

	if LsdState.screenGui then
		pcall(function()
			LsdState.screenGui:Destroy()
		end)

		LsdState.screenGui = nil
	end

	LsdState.overlays = {}
	LsdState.hue = 0
	LsdState.time = 0
end


local Window = Library:CreateWindow({
	Title = "Rose",
	Footer = "Rose  ·  v1.1",
	NotifySide = "Right",
	ShowCustomCursor = true,
	Center = true,
	AutoShow = true,
	Resizable = false,
})

-- Watermark: Rose | FPS | ping | user
task.spawn(function()
	local function getUiParent()
		local ok, hui = pcall(function()
			return gethui and gethui()
		end)
		if ok and hui then
			return hui
		end
		local cg = game:GetService("CoreGui")
		local ok2 = pcall(function()
			return cg
		end)
		if ok2 then
			return cg
		end
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	local parent = getUiParent()
	local gui = Instance.new("ScreenGui")
	gui.Name = "SunapseWatermark"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 999999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function()
		gui.Parent = parent
	end)
	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 10)
	bar.Size = UDim2.fromOffset(0, 28)
	bar.AutomaticSize = Enum.AutomaticSize.X
	bar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	bar.BackgroundTransparency = 0.15
	bar.BorderSizePixel = 0
	bar.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = bar

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 111, 174)
	stroke.Transparency = 0.75
	stroke.Thickness = 1
	stroke.Parent = bar

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.Parent = bar

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 0)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = bar

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.fromOffset(0, 20)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(235, 235, 240)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "✦  Rose  |  -- fps  |  -- ms  |  " .. LocalPlayer.Name
	label.Parent = bar

	local frames = 0
	local lastFpsUpdate = os.clock()
	local fps = 0
	local pingMs = 0

	RunService.RenderStepped:Connect(function()
		frames += 1
		local now = os.clock()
		if now - lastFpsUpdate >= 0.5 then
			fps = math.floor(frames / (now - lastFpsUpdate) + 0.5)
			frames = 0
			lastFpsUpdate = now
			pcall(function()
				local stats = game:GetService("Stats")
				local net = stats:FindFirstChild("Network")
				local item = net and net:FindFirstChild("ServerStatsItem")
				local pingItem = item and item:FindFirstChild("Data Ping")
				if pingItem and pingItem.GetValueString then
					local str = pingItem:GetValueString()
					local n = tonumber((str or ""):match("(%d+)"))
					if n then
						pingMs = n
					end
				elseif LocalPlayer.GetNetworkPing then
					pingMs = math.floor(LocalPlayer:GetNetworkPing() * 1000 + 0.5)
				end
			end)
			-- всегда ник аккаунта, кто запустил скрипт
			local who = (Players.LocalPlayer and Players.LocalPlayer.Name) or LocalPlayer.Name
			label.Text = string.format(
				"✦  Rose  |  %d fps  |  %d ms  |  %s",
				fps,
				pingMs,
				who
			)
		end
	end)
end)

task.spawn(function()
	task.wait(0.6)
	local screenGui = Library.ScreenGui

	if not screenGui then
		local coreGui = game:GetService("CoreGui")

		for _, child in ipairs(coreGui:GetChildren()) do
			if child:IsA("ScreenGui") and child:FindFirstChild("Main") then
				screenGui = child
				break
			end
		end
	end

	if not screenGui then
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

		for _, child in ipairs(playerGui:GetChildren()) do
			if child:IsA("ScreenGui") and child:FindFirstChild("Main") then
				screenGui = child
				break
			end
		end
	end

	if not screenGui then
		return
	end

	local main = screenGui:FindFirstChild("Main")
	if not main then
		return
	end

	local topbar = main:FindFirstChild("Topbar") or main:FindFirstChild("TopBar")
	if not topbar then
		return
	end

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "SunapseIconFrame"
	iconFrame.Size = UDim2.new(0, 28, 0, 28)
	iconFrame.Position = UDim2.new(0, 8, 0.5, 0)
	iconFrame.AnchorPoint = Vector2.new(0, 0.5)
	iconFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
	iconFrame.BorderSizePixel = 0
	iconFrame.ZIndex = 5
	iconFrame.Parent = topbar
	Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(1, 0)

	local iconStroke = Instance.new("UIStroke", iconFrame)
	iconStroke.Color = Color3.fromRGB(255, 111, 174)
	iconStroke.Thickness = 1
	iconStroke.Transparency = 0.4

	local iconImage = Instance.new("ImageLabel", iconFrame)
	iconImage.Size = UDim2.new(1, -2, 1, -2)
	iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
	iconImage.BackgroundTransparency = 1
	iconImage.Image = "rbxassetid://95080673394037"
	iconImage.ScaleType = Enum.ScaleType.Crop
	iconImage.ZIndex = 6
	iconImage.Parent = iconFrame
	Instance.new("UICorner", iconImage).CornerRadius = UDim.new(1, 0)
end)

local Tabs = {
	Home = Window:AddTab("Home", "house"),
	Player = Window:AddTab("Player", "shield"),
	Movement = Window:AddTab("Movement", "move"),
	Target = Window:AddTab("Target", "crosshair"),
	Blobman = Window:AddTab("Blobman", "ghost"),
	Visual = Window:AddTab("Visual", "eye"),
	Server = Window:AddTab("Server", "server"),
	Fun = Window:AddTab("Fun", "gamepad-2"),
	Custom = Window:AddTab("Custom", "sparkles"),
	Keybind = Window:AddTab("Keybind", "keyboard"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

do
	local welcomeBox = Tabs.Home:AddGroupbox({ Side = "Left", Name = "Welcome" })
	welcomeBox:AddLabel("Rose")
	welcomeBox:AddLabel("FTAP utility build. Pick a target, use defense toggles, blob tools on Blobman tab.", true)
	welcomeBox:AddLabel("Build: Rose  ·  v1.1", true)
end

do
	local infoBox = Tabs.Home:AddGroupbox({ Side = "Right", Name = "Information" })
	infoBox:AddLabel("Display Name:  " .. LocalPlayer.DisplayName)
	infoBox:AddLabel("Username:  @" .. LocalPlayer.Name)
	infoBox:AddLabel("Account created:  " .. GetAccountCreationDate() .. " (" .. GetAccountAge() .. " ago)")
	infoBox:AddLabel("Executor:  " .. ExecutorName)
	local uptimeLabel = infoBox:AddLabel("Script uptime:  00:00:00")

	task.spawn(function()
		while true do
			task.wait(1)
			local elapsed = math.floor(os.clock() - ScriptStartClock)
			uptimeLabel:SetText(string.format("Script uptime:  %02d:%02d:%02d", math.floor(elapsed / 3600), math.floor(elapsed % 3600 / 60), elapsed % 60))
		end
	end)
end

do
	local protectionBox = Tabs.Player:AddGroupbox({ Side = "Left", Name = "Protection" })

	protectionBox:AddToggle("AntiGrab", {
		Text = "Anti Grab [BEST]",
		Default = false,
		Callback = function(enabled)
			if enabled then
				StopAntiGrab()

				if LocalPlayer.Character then
					StartAntiGrab(LocalPlayer.Character)
				end

				State.connections.antiGrab.CharAdded = LocalPlayer.CharacterAdded:Connect(function(character)
					task.wait(0.5)
					StartAntiGrab(character)
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Grab ON", Time = 2 })
			else
				StopAntiGrab()
				local character = LocalPlayer.Character

				if character then
					SetRagdollConstraintsEnabled(character)
					local rootPart = character:FindFirstChild("HumanoidRootPart")

					if rootPart then
						rootPart.Anchored = false
					end
				end

				Library:Notify({ Title = "Rose", Description = "Anti Grab OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiLoopTP", {
		Text = "Anti Loop TP",
		Default = false,
		Callback = function(enabled)
			if enabled then
				State.refs.antiLoopLastSafeCF = nil

				if State.connections.antiLoop then
					State.connections.antiLoop:Disconnect()
				end

				State.connections.antiLoop = RunService.Heartbeat:Connect(function()
					local character = LocalPlayer.Character
					local rootPart = character and character:FindFirstChild("HumanoidRootPart")
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					if not rootPart or not humanoid then
						return
					end

					local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
					local speed = rootPart.AssemblyLinearVelocity.Magnitude

					if grounded and speed < 150 then
						State.refs.antiLoopLastSafeCF = rootPart.CFrame
					end

					if not State.refs.antiLoopLastSafeCF then
						return
					end

					if (rootPart.Position - State.refs.antiLoopLastSafeCF.Position).Magnitude > State.flags.antiLoopThreshold or speed > 350 then
						pcall(function()
							humanoid.Sit = false
							humanoid.PlatformStand = false
						end)

						local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
						local struggle = characterEvents and characterEvents:FindFirstChild("Struggle")

						if struggle then
							pcall(function()
								struggle:FireServer(LocalPlayer)
							end)
						end

						rootPart.AssemblyLinearVelocity = Vector3.zero
						rootPart.AssemblyAngularVelocity = Vector3.zero
						rootPart.CFrame = State.refs.antiLoopLastSafeCF
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Loop TP ON", Time = 2 })
			else
				if State.connections.antiLoop then
					State.connections.antiLoop:Disconnect()
				end

				State.connections.antiLoop = nil
				State.refs.antiLoopLastSafeCF = nil
				Library:Notify({ Title = "Rose", Description = "Anti Loop TP OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddSlider("AntiLoopThreshold", {
		Text = "Anti Loop Threshold",
		Default = 50,
		Min = 20,
		Max = 200,
		Rounding = 0,
		Callback = function(value)
			State.flags.antiLoopThreshold = value
		end,
	})

	protectionBox:AddToggle("AntiExplosion", {
		Text = "Anti Explosion",
		Default = false,
		Callback = function(enabled)
			if State.connections.antiExplode then
				State.connections.antiExplode:Disconnect()
			end

			if enabled then
				State.connections.antiExplode = RunService.Heartbeat:Connect(AntiExplosionStep)
				Library:Notify({ Title = "Rose", Description = "Anti Explosion ON", Time = 2 })
			else
				State.connections.antiExplode = nil
				Library:Notify({ Title = "Rose", Description = "Anti Explosion OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiLag", {
		Text = "Anti Lag",
		Default = false,
		Callback = function(enabled)
			if enabled then
				local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
				local beamMoveScript = playerScripts and playerScripts:FindFirstChild("CharacterAndBeamMove")

				if beamMoveScript then
					State.refs.antiLagBeamScript = beamMoveScript

					pcall(function()
						beamMoveScript.Disabled = true
					end)
				end

				ClearGrabBeams()

				if State.connections.antiLag then
					State.connections.antiLag:Disconnect()
				end

				State.connections.antiLag = workspace.DescendantAdded:Connect(function(descendant)
					if IsGrabBeam(descendant) then
						pcall(function()
							descendant:Destroy()
						end)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Lag ON", Time = 2 })
			else
				if State.connections.antiLag then
					State.connections.antiLag:Disconnect()
					State.connections.antiLag = nil
				end

				if State.refs.antiLagBeamScript then
					pcall(function()
						State.refs.antiLagBeamScript.Disabled = false
					end)

					State.refs.antiLagBeamScript = nil
				end

				Library:Notify({ Title = "Rose", Description = "Anti Lag OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AutoLeave", {
		Text = "Auto Leave (Anti-Ban)",
		Default = false,
		Callback = function(enabled)
			if State.connections.autoLeave then
				State.connections.autoLeave:Disconnect()
				State.connections.autoLeave = nil
			end

			if enabled then
				local recent = {}
				local gameCorrectionEvents = ReplicatedStorage:FindFirstChild("GameCorrectionEvents")
				local notifyEvent = gameCorrectionEvents and gameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")
				if not notifyEvent then
					return
				end

				State.connections.autoLeave = notifyEvent.OnClientEvent:Connect(function(message)
					if message == "Flying" then
						local now = os.clock()
						table.insert(recent, now)

						for i = #recent, 1, -1 do
							if now - recent[i] > 1 then
								table.remove(recent, i)
							end
						end

						if #recent >= 3 then
							LocalPlayer:Kick("Rose Safety")
						end
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Auto Leave ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Auto Leave OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiKickShuriken", {
		Text = "Anti Kick Shuriken",
		Default = false,
		Callback = function(enabled)
			State.flags.antiKickShuriken = enabled

			if enabled then
				Library:Notify({ Title = "Rose", Description = "Anti Kick Shuriken ON", Time = 2 })

				task.spawn(function()
					local setNetworkOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
					local stickyPartEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
					local spawnToyRemoteFunction = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
					local canSpawnToy = LocalPlayer:WaitForChild("CanSpawnToy")

					local function getRootPart()
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							return LocalPlayer.Character.HumanoidRootPart
						end
						return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
					end

					local function getMainPart(toy)
						return toy:FindFirstChild("StickyPart") or toy:FindFirstChild("HoldPart") or toy:FindFirstChild("Main") or toy:FindFirstChildWhichIsA("BasePart")
					end

					local function pinToy(toy)
						local mainPart = getMainPart(toy)
						if not toy or not mainPart then
							return
						end

						local rootPart = getRootPart()
						if not rootPart then
							return
						end

						local soundPart = toy:FindFirstChild("SoundPart") or mainPart
						local unowned = not soundPart:FindFirstChild("PartOwner") or soundPart.PartOwner.Value ~= LocalPlayer.Name

						if unowned then
							pcall(function()
								setNetworkOwner:FireServer(soundPart, soundPart.CFrame)
							end)
						end

						local firePlayerPart = rootPart:FindFirstChild("FirePlayerPart") or rootPart:WaitForChild("FirePlayerPart", 5)

						if firePlayerPart then
							pcall(function()
								stickyPartEvent:FireServer(mainPart, firePlayerPart, CFrame.new(0, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966))
							end)

							if not mainPart:FindFirstChild("LocalFakeWeld") then
								mainPart.CFrame = firePlayerPart.CFrame * CFrame.Angles(0, 1.5707963267948966, 1.5707963267948966)
								local weldConstraint = Instance.new("WeldConstraint")
								weldConstraint.Name = "LocalFakeWeld"
								weldConstraint.Part0 = mainPart
								weldConstraint.Part1 = firePlayerPart
								weldConstraint.Parent = mainPart
							end
						end

						for _, child in pairs(toy:GetChildren()) do
							if child:IsA("BasePart") then
								child.CanTouch = false
								child.CanCollide = false
								child.CanQuery = false

								if child.Name == "StickyPart" or child.Name == "SoundPart" or child.Name == "Hitbox" or child.Transparency == 1 then
									child.Transparency = 1
								else
									child.Transparency = 0.8
								end
							end
						end
					end

					local function spawnToy(toyName)
						local startTime = tick()

						while not canSpawnToy.Value do
							if not State.flags.antiKickShuriken or tick() - startTime > 5 then
								return nil
							end
							task.wait(0.1)
						end

						local rootPart = getRootPart()

						if rootPart then
							task.spawn(function()
								pcall(function()
									spawnToyRemoteFunction:InvokeServer(toyName, rootPart.CFrame * CFrame.new(0, 5, -5), Vector3.zero)
								end)
							end)
						end

						local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
						if toys then
							return toys:WaitForChild(toyName, 2)
						end
					end

					while State.flags.antiKickShuriken do
						task.wait(0.1)

						local character = LocalPlayer.Character
						local humanoid = character and character:FindFirstChild("Humanoid")

						if humanoid and humanoid.Health > 0 then
							local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
							local antiKick = toys and (toys:FindFirstChild("AntiKick") or toys:FindFirstChild("NinjaShuriken"))

							if not antiKick then
								antiKick = spawnToy("NinjaShuriken")

								if antiKick then
									antiKick.Name = "AntiKick"
								end
							end

							if antiKick then
								pinToy(antiKick)
							end
						end
					end

					DestroyAntiKickToys()
				end)
			else
				DestroyAntiKickToys()
				Library:Notify({ Title = "Rose", Description = "Anti Kick Shuriken OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiKickItem", {
		Text = "Anti Kick Item",
		Default = false,
		Callback = function(enabled)
			State.flags.antiKickItem = enabled

			if enabled then
				Library:Notify({ Title = "Rose", Description = "Anti Kick Item ON", Time = 2 })

				task.spawn(function()
					local setNetworkOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
					local spawnToyRemoteFunction = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")
					local canSpawnToy = LocalPlayer:WaitForChild("CanSpawnToy")

					local function getRootPart()
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							return LocalPlayer.Character.HumanoidRootPart
						end
						return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
					end

					local function waitChild(instance, childName, timeout)
						return instance:FindFirstChild(childName) or instance:WaitForChild(childName, timeout)
					end

					local function spawnItem(itemName)
						local startTime = tick()

						while not canSpawnToy.Value do
							if not State.flags.antiKickItem or tick() - startTime > 5 then
								return nil
							end
							task.wait(0.1)
						end

						local rootPart = getRootPart()
						if not rootPart then
							return nil
						end

						pcall(function()
							spawnToyRemoteFunction:InvokeServer(itemName, rootPart.CFrame * CFrame.new(0, 5, -5), Vector3.zero)
						end)

						local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
						if toys then
							return toys:WaitForChild(itemName, 3)
						end
					end

					local function claimNetworkOwner(part)
						pcall(function()
							setNetworkOwner:FireServer(part, part.CFrame)
						end)
					end

					local function isOwned(part)
						local owner = part and part:FindFirstChild("PartOwner")
						return owner ~= nil and owner.Value == LocalPlayer.Name
					end

					local function getMainPart(item, itemName)
						if itemName == "SpookyCandle1" then
							return waitChild(item, "Hitbox", 0.5)
						end
						return item:FindFirstChild("Hitbox") or item:FindFirstChild("SoundPart") or item:FindFirstChild("Main") or item:FindFirstChildWhichIsA("BasePart")
					end

					local function ensureItem(itemName)
						local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

						if toys then
							for _, child in pairs(toys:GetChildren()) do
								if child.Name == "AntiKickItem" then
									pcall(function()
										local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
										local destroyToy = menuToys and menuToys:FindFirstChild("DestroyToy")

										if destroyToy then
											destroyToy:FireServer(child)
										end
									end)
								end
							end
						end

						local item = spawnItem(itemName)
						if not item then
							return nil
						end

						local mainPart = getMainPart(item, itemName)
						if not mainPart then
							return nil
						end

						claimNetworkOwner(mainPart)

						for _, child in pairs(item:GetChildren()) do
							if child:IsA("BasePart") then
								child.CanCollide = false
								child.CanQuery = false
								child.Transparency = 0.8
							end
						end

						local rootPart = getRootPart()

						if rootPart then
							local firePlayerPart = rootPart:FindFirstChild("FirePlayerPart") or rootPart
							local weld

							if itemName == "SpookyCandle1" then
								mainPart.CFrame = rootPart.CFrame * CFrame.new(0, 1, 0)
								weld = Instance.new("Weld")
								weld.C0 = CFrame.new(0, 1, 0)
								weld.C1 = CFrame.new(0, 0, 0)
							else
								mainPart.CFrame = rootPart.CFrame
								weld = Instance.new("WeldConstraint")
							end

							weld.Name = "WeldBlabla"
							weld.Part0 = mainPart
							weld.Part1 = firePlayerPart
							weld.Parent = mainPart
						end

						item.Name = "AntiKickItem"
						return item, mainPart
					end

					while State.flags.antiKickItem do
						task.wait(0.05)

						local character = LocalPlayer.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")

						if humanoid and humanoid.Health > 0 then
							local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
							local itemName = State.refs.antiKickItemName
							local item = toys and toys:FindFirstChild("AntiKickItem")
							local mainPart = item and getMainPart(item, itemName)

							if not item or not mainPart then
								item, mainPart = ensureItem(itemName)
							end

							if item and mainPart then
								if not isOwned(mainPart) then
									claimNetworkOwner(mainPart)
								end

								local rootPart = getRootPart()

								if rootPart then
									local firePlayerPart = rootPart:FindFirstChild("FirePlayerPart") or rootPart
									local weldBlabla = mainPart:FindFirstChild("WeldBlabla")

									if itemName == "SpookyCandle1" then
										if not weldBlabla then
											mainPart.CFrame = rootPart.CFrame * CFrame.new(0, 1, 0)
											local weld = Instance.new("Weld")
											weld.Name = "WeldBlabla"
											weld.C0 = CFrame.new(0, 1, 0)
											weld.C1 = CFrame.new(0, 0, 0)
											weld.Part0 = mainPart
											weld.Part1 = firePlayerPart
											weld.Parent = mainPart
										elseif weldBlabla.Part1 ~= firePlayerPart then
											weldBlabla.Part1 = firePlayerPart
										end
									elseif not weldBlabla then
										mainPart.CFrame = rootPart.CFrame
										local weldConstraint = Instance.new("WeldConstraint")
										weldConstraint.Name = "WeldBlabla"
										weldConstraint.Part0 = mainPart
										weldConstraint.Part1 = firePlayerPart
										weldConstraint.Parent = mainPart
									elseif weldBlabla.Part1 ~= firePlayerPart then
										weldBlabla.Enabled = false
										mainPart.CFrame = rootPart.CFrame
										weldBlabla.Part1 = firePlayerPart
										weldBlabla.Enabled = true
									end
								end
							end
						end
					end

					DestroyAntiKickToys()
				end)
			else
				DestroyAntiKickToys()
				Library:Notify({ Title = "Rose", Description = "Anti Kick Item OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddDropdown("AntiKickItemType", {
		Values = State.refs.antiKickItemNameOptions,
		Default = "SpookyCandle1",
		Text = "Anti Kick Item Type",
		Callback = function(itemName)
			State.refs.antiKickItemName = itemName
		end,
	})

	protectionBox:AddToggle("AntiKickPalletka", {
		Text = "Anti Kick Palletka",
		Default = false,
		Callback = function(enabled)
			State.flags.antiKickPalletka = enabled

			if enabled then
				task.spawn(function()
					while State.flags.antiKickPalletka do
						local character = LocalPlayer.Character

						if not character then
							task.wait(0.5)
						else
							local rootPart = character:FindFirstChild("HumanoidRootPart")

							if not rootPart then
								task.wait(0.5)
							else
								local spawnToyRemoteFunction = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")

								if not spawnToyRemoteFunction then
									task.wait(1)
								else
									local canSpawnToy = LocalPlayer:FindFirstChild("CanSpawnToy")

									if not canSpawnToy then
										task.wait(1)
									elseif not canSpawnToy.Value then
										task.wait(0.5)
									else
										local spawnCFrame = rootPart.CFrame * CFrame.new(0, 4, 0)
										local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

										if not toys then
											task.wait(1)
										else
											local pallet = nil

											local connection = toys.ChildAdded:Connect(function(child)
												if child.Name == "PalletLightBrown" then
													pallet = child

													pcall(function()
														child:PivotTo(spawnCFrame)
													end)

													pcall(function()
														for _, descendant in pairs(child:GetDescendants()) do
															if descendant:IsA("BasePart") then
																descendant.Anchored = true
																descendant.CanCollide = false
															end
														end
													end)
												end
											end)

											pcall(function()
												spawnToyRemoteFunction:InvokeServer("PalletLightBrown", spawnCFrame, Vector3.zero)
											end)

											local startTime = tick()

											repeat
												task.wait()
											until pallet or tick() - startTime > 1

											if connection then
												connection:Disconnect()
											end

											if pallet then
												local setNetworkOwner = GetSetNetworkOwnerEvent()

												if setNetworkOwner then
													pcall(function()
														setNetworkOwner:FireServer(pallet, spawnCFrame)
													end)
												end

												pcall(function()
													pallet:PivotTo(spawnCFrame)
												end)

												task.wait(0.5)

												pcall(function()
													pallet:Destroy()
												end)
											end

											task.wait(0.1)
										end
									end
								end
							end
						end
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Kick Palletka ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Anti Kick Palletka OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiVoid", {
		Text = "Anti Void",
		Default = false,
		Callback = function(enabled)
			State.flags.antiVoid = enabled

			if enabled then
				State.refs.antiVoidOriginalFallenHeight = workspace.FallenPartsDestroyHeight
				workspace.FallenPartsDestroyHeight = -50000
				State.refs.antiVoidLastSafePosition = CFrame.new(0, 10, 0)

				table.insert(State.connections.antiVoid, RunService.Heartbeat:Connect(function()
					local character = LocalPlayer.Character
					if not character then
						return
					end

					local rootPart = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if not rootPart then
						return
					end

					if rootPart.Position.Y > -100 then
						State.refs.antiVoidLastSafePosition = rootPart.CFrame
					end

					if rootPart.Position.Y < -800 then
						rootPart.CFrame = CFrame.new(0, 10, 0)
						rootPart.AssemblyLinearVelocity = Vector3.zero
						rootPart.AssemblyAngularVelocity = Vector3.zero

						if humanoid then
							humanoid.PlatformStand = false
						end

						Library:Notify({ Title = "Rose", Description = "Anti Void: teleported", Time = 3 })
					end
				end))

				table.insert(State.connections.antiVoid, workspace.ChildRemoved:Connect(function(child)
					if child.Name == LocalPlayer.Name then
						StopAntiVoid()
						State.flags.antiVoid = false

						if Toggles.AntiVoid then
							Toggles.AntiVoid:SetValue(false)
						end
					end
				end))

				Library:Notify({ Title = "Rose", Description = "Anti Void ON", Time = 2 })
			else
				StopAntiVoid()
				Library:Notify({ Title = "Rose", Description = "Anti Void OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiBurn", {
		Text = "Anti Burn",
		Default = false,
		Callback = function(enabled)
			if enabled then
				StopAntiBurn()

				if LocalPlayer.Character then
					StartAntiBurn(LocalPlayer.Character)
				end

				table.insert(State.connections.antiBurn, LocalPlayer.CharacterAdded:Connect(StartAntiBurn))
				Library:Notify({ Title = "Rose", Description = "Anti Burn ON", Time = 2 })
			else
				StopAntiBurn()
				Library:Notify({ Title = "Rose", Description = "Anti Burn OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddToggle("AntiFreeze", {
		Text = "Anti Freeze",
		Default = false,
		Callback = function(enabled)
			if enabled then
				StopAntiFreeze()

				if LocalPlayer.Character then
					WatchAntiFreeze(LocalPlayer.Character)
					ClearFreeze(LocalPlayer.Character)
				end

				table.insert(State.connections.antiFreeze, LocalPlayer.CharacterAdded:Connect(function(character)
					WatchAntiFreeze(character)
					ClearFreeze(character)
				end))

				State.refs.antiFreezeHeartbeat = RunService.Heartbeat:Connect(function()
					local character = LocalPlayer.Character
					if not character then
						return
					end

					local humanoid = character:FindFirstChildOfClass("Humanoid")
					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if not humanoid or not rootPart then
						return
					end

					if humanoid.PlatformStand or rootPart.Anchored then
						ClearFreeze(character)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Freeze ON", Time = 2 })
			else
				StopAntiFreeze()
				Library:Notify({ Title = "Rose", Description = "Anti Freeze OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddDropdown("AntiOwnFood", {
		Values = {
			"Pizza (Cheese)",
			"Pizza (Pepperoni)",
			"Burger",
			"Hotdog",
			"Banana",
			"Donut",
			"Cake",
			"Bread",
			"Mayonnaise",
			"French Fries",
			"Dippy Egg",
			"Coconut",
			"Meat Stick",
			"Poison Mushroom",
		},
		Default = "Pizza (Cheese)",
		Text = "Anti Own Food",
		Callback = function(food)
			State.refs.antiOwnSelectedFood = food
		end,
	})

	protectionBox:AddToggle("AntiOwnership", {
		Text = "Anti Ownership",
		Default = false,
		Callback = function(enabled)
			State.flags.antiOwnership = enabled

			if enabled then
				task.spawn(AntiOwnershipLoop)
				Library:Notify({ Title = "Rose", Description = "Anti Ownership ON", Time = 2 })
			else
				local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				local menuToys = ReplicatedStorage:FindFirstChild("MenuToys")
				local destroyToy = menuToys and menuToys:FindFirstChild("DestroyToy")

				if toys and destroyToy then
					for _, child in pairs(toys:GetChildren()) do
						if string.sub(child.Name, 1, 4) == "Food" then
							pcall(function()
								destroyToy:FireServer(child)
							end)
						end
					end
				end

				Library:Notify({ Title = "Rose", Description = "Anti Ownership OFF", Time = 2 })
			end
		end,
	})

	protectionBox:AddDropdown("AntiLoopHouse", {
		Values = { "Green House", "Pink House", "Witch House", "Blue House", "China House" },
		Default = "Green House",
		Text = "Anti Loop House",
		Callback = function(houseName)
			State.refs.antiLoopKickHouseName = houseName
		end,
	})

	protectionBox:AddToggle("AntiLoopKick", {
		Text = "Anti Loop Kick",
		Default = false,
		Callback = function(enabled)
			State.flags.antiLoopKick = enabled

			if enabled then
				local houseCFrame = HousePositions[State.refs.antiLoopKickHouseName]
				if not houseCFrame then
					return
				end

				local housePosition = houseCFrame.Position

				if State.connections.antiLoopKick then
					State.connections.antiLoopKick:Disconnect()
				end

				State.connections.antiLoopKick = RunService.Heartbeat:Connect(function()
					local character = LocalPlayer.Character
					if not character then
						return
					end

					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if not rootPart then
						return
					end

					if State.refs.antiLoopKickRadius < (rootPart.Position - housePosition).Magnitude then
						character:PivotTo(houseCFrame)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Loop Kick ON", Time = 2 })
			else
				if State.connections.antiLoopKick then
					State.connections.antiLoopKick:Disconnect()
					State.connections.antiLoopKick = nil
				end

				local character = LocalPlayer.Character

				if character and character:FindFirstChild("HumanoidRootPart") then
					character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end

				Library:Notify({ Title = "Rose", Description = "Anti Loop Kick OFF", Time = 2 })
			end
		end,
	})
end
do
	local safetyBox = Tabs.Player:AddGroupbox({ Side = "Right", Name = "Safety" })

	safetyBox:AddToggle("AntiPaint", {
		Text = "Anti Paint",
		Default = false,
		Callback = function(enabled)
			if enabled then
				RemovePaintParts()

				table.insert(State.connections.antiPaint, workspace.DescendantAdded:Connect(function(descendant)
					if descendant:IsA("BasePart") and descendant.Name == "PaintPlayerPart" then
						task.defer(function()
							if descendant and descendant.Parent then
								pcall(function()
									descendant:Destroy()
								end)
							end
						end)
					end
				end))

				SetCharacterCollision(false)
				Library:Notify({ Title = "Rose", Description = "Anti Paint ON", Time = 2 })
			else
				StopAntiPaint()
				Library:Notify({ Title = "Rose", Description = "Anti Paint OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AntiSticky", {
		Text = "Anti Sticky",
		Default = false,
		Callback = function(enabled)
			if enabled then
				State.refs.antiStickyRunning = true
				local stickyTouchScript = LocalPlayer.PlayerScripts:FindFirstChild("StickyPartsTouchDetection")

				if stickyTouchScript then
					stickyTouchScript.Disabled = true
				end

				local setNetworkOwner = GetSetNetworkOwnerEvent()
				local destroyGrabLine = GetDestroyGrabLineEvent()

				task.spawn(function()
					while State.refs.antiStickyRunning do
						local character = LocalPlayer.Character

						if character then
							for _, descendant in ipairs(character:GetDescendants()) do
								if not State.refs.antiStickyRunning then
									break
								end

								if descendant.Name == "StickyWeld" and descendant:IsA("Weld") and descendant.Part1 then
									local parent = descendant.Parent

									if parent and parent:IsA("BasePart") then
										if setNetworkOwner then
											pcall(function()
												setNetworkOwner:FireServer(parent, parent.CFrame)
											end)
										end

										if destroyGrabLine then
											pcall(function()
												destroyGrabLine:FireServer(parent)
											end)
										end

										pcall(function()
											descendant.Part1 = nil
										end)

										pcall(function()
											descendant:Destroy()
										end)

										pcall(function()
											parent.Anchored = true
										end)

										pcall(function()
											parent.CFrame = CFrame.new(0, -500, 0)
										end)

										task.spawn(function()
											task.wait(0.5)

											pcall(function()
												parent:Destroy()
											end)
										end)
									end
								end
							end
						end

						task.wait(0.2)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Sticky ON", Time = 2 })
			else
				State.refs.antiStickyRunning = false
				Library:Notify({ Title = "Rose", Description = "Anti Sticky OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AntiSnowball", {
		Text = "Anti Snowball",
		Default = false,
		Callback = function(enabled)
			if enabled then
				State.refs.antiSnowballRunning = true
				local characterEvents = ReplicatedStorage:FindFirstChild("CharacterEvents")
				local ragdollRemote = characterEvents and (characterEvents:FindFirstChild("RagdollRemote") or characterEvents:WaitForChild("RagdollRemote", 5))

				task.spawn(function()
					while State.refs.antiSnowballRunning do
						local character = LocalPlayer.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")
						local rootPart = character and character:FindFirstChild("HumanoidRootPart")

						if humanoid and rootPart and humanoid.Health > 0 then
							local state = humanoid:GetState()

							if humanoid.PlatformStand or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown then
								if ragdollRemote then
									pcall(function()
										ragdollRemote:FireServer(rootPart, 0)
									end)
								end

								pcall(function()
									humanoid:ChangeState(Enum.HumanoidStateType.Running)
								end)
							end
						end

						task.wait(0.1)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Snowball ON", Time = 2 })
			else
				State.refs.antiSnowballRunning = false
				Library:Notify({ Title = "Rose", Description = "Anti Snowball OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AntiBanana", {
		Text = "Anti Banana",
		Default = false,
		Callback = function(enabled)
			if enabled then
				State.refs.antiBananaRunning = true

				task.spawn(function()
					while State.refs.antiBananaRunning do
						local character = LocalPlayer.Character

						if character then
							local humanoid = character:FindFirstChildOfClass("Humanoid")
							local rootPart = character:FindFirstChild("HumanoidRootPart")

							if humanoid and rootPart and humanoid.Health > 0 then
								humanoid.Sit = true
								humanoid:ChangeState(Enum.HumanoidStateType.Running)
								local camera = workspace.CurrentCamera
								local lookVector = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
								rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z))
							end
						end

						task.wait()
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Anti Banana ON", Time = 2 })
			else
				State.refs.antiBananaRunning = false
				Library:Notify({ Title = "Rose", Description = "Anti Banana OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AntiPoison", {
		Text = "Anti Poison",
		Default = false,
		Callback = function(enabled)
			if enabled then
				local setNetworkOwner = GetSetNetworkOwnerEvent()

				local function isPoison(instance)
					local lowerName = instance.Name:lower()
					return lowerName:find("poison") or lowerName:find("mushroom") or lowerName:find("foodmush")
				end

				local function clearPoisonParts()
					for _, descendant in ipairs(workspace:GetDescendants()) do
						if descendant:IsA("BasePart") and isPoison(descendant) then
							if setNetworkOwner then
								pcall(function()
									setNetworkOwner:FireServer(descendant, descendant.CFrame)
								end)
							end

							pcall(function()
								descendant:Destroy()
							end)
						end
					end
				end

				clearPoisonParts()

				table.insert(State.connections.antiPoison, workspace.DescendantAdded:Connect(function(descendant)
					if descendant:IsA("BasePart") and isPoison(descendant) then
						task.defer(function()
							if setNetworkOwner and descendant and descendant.Parent then
								pcall(function()
									setNetworkOwner:FireServer(descendant, descendant.CFrame)
								end)
							end

							if descendant and descendant.Parent then
								pcall(function()
									descendant:Destroy()
								end)
							end
						end)
					end
				end))

				table.insert(State.connections.antiPoison, RunService.Heartbeat:Connect(function()
					local character = LocalPlayer.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if humanoid and humanoid.Health > 0 and humanoid.Health < humanoid.MaxHealth then
						pcall(function()
							humanoid.Health = humanoid.MaxHealth
						end)
					end

					if character then
						for _, descendant in ipairs(character:GetDescendants()) do
							local lowerName = descendant.Name:lower()

							if lowerName:find("poison") or lowerName:find("sick") or lowerName:find("toxic") then
								if descendant:IsA("BoolValue") then
									pcall(function()
										descendant.Value = false
									end)
								end

								if descendant:IsA("NumberValue") or descendant:IsA("IntValue") then
									pcall(function()
										descendant.Value = 0
									end)
								end

								if descendant:IsA("StringValue") then
									pcall(function()
										descendant.Value = ""
									end)
								end
							end
						end
					end
				end))

				Library:Notify({ Title = "Rose", Description = "Anti Poison ON", Time = 2 })
			else
				StopAntiPoison()
				Library:Notify({ Title = "Rose", Description = "Anti Poison OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("PCLDBreak", {
		Text = "Auto PCLD Break",
		Default = false,
		Callback = function(enabled)
			if enabled then
				StartPcldBreak()
				Library:Notify({ Title = "Rose", Description = "PCLD Break ON", Time = 2 })
			else
				StopPcldBreak()
				Library:Notify({ Title = "Rose", Description = "PCLD Break OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddDropdown("GucciType", {
		Values = { "Invisible (Tractor)", "Godmode (Blobman)", "Anti Kill (Train)" },
		Default = "Invisible (Tractor)",
		Text = "Gucci Type",
		Callback = function(gucciType)
			State.refs.gucciType = gucciType

			if State.flags.gucci then
				StartGucci(gucciType)
			end
		end,
	})

	safetyBox:AddToggle("GucciAntiGrab", {
		Text = "Gucci Anti-Grab (vehicle)",
		Default = false,
		Callback = function(enabled)
			State.runtime.gucciAntiGrab = enabled
			Library:Notify({ Title = "Rose", Description = "Gucci Anti-Grab " .. (enabled and "ON" or "OFF"), Time = 2 })
		end,
	})

	safetyBox:AddToggle("Gucci", {
		Text = "Gucci Mode",
		Default = false,
		Callback = function(enabled)
			State.flags.gucci = enabled

			if enabled then
				StartGucci(State.refs.gucciType)
			else
				StopGucci()
				Library:Notify({ Title = "Rose", Description = "Gucci OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AutoReset", {
		Text = "Auto Reset (Anti-Ban)",
		Default = false,
		Callback = function(enabled)
			if State.connections.autoReset then
				State.connections.autoReset:Disconnect()
				State.connections.autoReset = nil
			end

			if enabled then
				local gameCorrectionEvents = ReplicatedStorage:FindFirstChild("GameCorrectionEvents")
				local notifyEvent = gameCorrectionEvents and gameCorrectionEvents:FindFirstChild("GameCorrectionsNotify")

				if notifyEvent then
					State.connections.autoReset = notifyEvent.OnClientEvent:Connect(function(message)
						if message == "Flying" then
							local character = LocalPlayer.Character
							local humanoid = character and character:FindFirstChildOfClass("Humanoid")

							if humanoid then
								Library:Notify({ Title = "Rose", Description = "Auto Reset: preventing ban", Time = 3 })

								pcall(function()
									character:BreakJoints()
								end)

								pcall(function()
									humanoid.Health = 0
								end)
							end
						end
					end)
				end

				Library:Notify({ Title = "Rose", Description = "Auto Reset ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Auto Reset OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AutoAttacker", {
		Text = "Auto Attacker (Endoris)",
		Default = false,
		Callback = function(enabled)
			State.runtime.autoAttacker = enabled

			if enabled then
				if LocalPlayer.Character then
					local head = LocalPlayer.Character:FindFirstChild("Head")
					if head then
						head.ChildAdded:Connect(function(child)
							if not State.runtime.autoAttacker then return end
							if child.Name ~= "PartOwner" then return end
							local holderName = tostring(child.Value)
							local holder = Players:FindFirstChild(holderName)
							if not holder or not holder.Character then return end
							if holder == LocalPlayer then return end
							local hrp = holder.Character:FindFirstChild("HumanoidRootPart")
							local hum = holder.Character:FindFirstChildOfClass("Humanoid")
							if not hrp or not hum or hum.Health <= 0 then return end
							local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if not myRoot then return end
							local diff = hrp.Position - myRoot.Position
							local look = diff.Magnitude > 0.1 and diff.Unit or Vector3.new(0, 0, 1)
							local bv = Instance.new("BodyVelocity", hrp)
							bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							bv.Velocity = Vector3.new(look.X, 0.5, look.Z) * 100
							task.wait(0.1)
							bv:Destroy()
							local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
							local dg = ge and ge:FindFirstChild("DestroyGrabLine")
							if dg then pcall(function() dg:FireServer(hrp) end) end
						end)
					end
				end
				Library:Notify({ Title = "Rose", Description = "Auto Attacker ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Auto Attacker OFF", Time = 2 })
			end
		end,
	})

	safetyBox:AddToggle("AntiBlobman", {
		Text = "Anti Blobman",
		Default = false,
		Callback = function(enabled)
			State.flags.antiBlobman = enabled

			if enabled then
				StartAntiBlobman()
				Library:Notify({ Title = "Rose", Description = "Anti Blobman ON", Time = 2 })
			else
				StopAntiBlobman()
				Library:Notify({ Title = "Rose", Description = "Anti Blobman OFF", Time = 2 })
			end
		end,
	})
end

do
	local targetBox = Tabs.Target:AddGroupbox({ Side = "Left", Name = "Target" })

	local TargetPlayer = targetBox:AddDropdown("TargetPlayer", {
		Values = GetPlayerNames(),
		Default = 1,
		Text = "Player",
		Callback = function(name)
			local player = FindPlayerByName(name)
			State.runtime.target = player and player.Name or name

			if State.runtime.kick and State.refs.restartKick then
				pcall(State.refs.restartKick)
			end

			if State.runtime.rogdoll and State.refs.restartRagdoll then
				pcall(State.refs.restartRagdoll)
			end

			if State.flags.traceGlobal then
				State.runtime.traceTarget = State.runtime.target
			end
		end,
	})

	if GetPlayerNames()[1] then
		local player = FindPlayerByName(GetPlayerNames()[1])
		State.runtime.target = player and player.Name or GetPlayerNames()[1]
	end

	targetBox:AddButton({
		Text = "Refresh List",
		Func = function()
			local names = GetPlayerNames()
			TargetPlayer:SetValues(names)

			if #names > 0 and (not State.runtime.target or not Players:FindFirstChild(State.runtime.target)) then
				TargetPlayer:SetValue(names[1])
				local player = FindPlayerByName(names[1])
				State.runtime.target = player and player.Name or names[1]
			end
		end,
	})

	Players.PlayerAdded:Connect(function()
		task.wait(0.5)
		TargetPlayer:SetValues(GetPlayerNames())
	end)

	Players.PlayerRemoving:Connect(function(player)
		if player.Name == State.runtime.target then
			State.runtime.target = nil
		end

		task.wait(0.5)
		TargetPlayer:SetValues(GetPlayerNames())
	end)
end

do
	local targetActionsBox = Tabs.Target:AddGroupbox({ Side = "Left", Name = "Target Actions" })

	targetActionsBox:AddToggle("TgtDestroyGucci", {
		Text = "Destroy Gucci",
		Default = false,
		Callback = function(enabled)
			State.runtime.destroyGucci = enabled

			if enabled then
				State.runtime.destroyGucciTask = task.spawn(DestroyGucciLoop)
			elseif State.runtime.destroyGucciTask then
				pcall(task.cancel, State.runtime.destroyGucciTask)
				State.runtime.destroyGucciTask = nil
			end
		end,
	})

	targetActionsBox:AddToggle("TgtRemoveAntiInput", {
		Text = "Remove All Anti Input",
		Default = false,
		Callback = function(enabled)
			State.runtime.antiInput = enabled

			if enabled then
				State.runtime.antiInputTask = task.spawn(RemoveAntiInputLoop)
			elseif State.runtime.antiInputTask then
				pcall(task.cancel, State.runtime.antiInputTask)
				State.runtime.antiInputTask = nil
			end
		end,
	})
end

do
	local kickBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Kick & Ragdoll" })

	local function clearKickConstraints()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

				if rootPart then
					for _, child in ipairs(rootPart:GetChildren()) do
						if child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("AlignPosition") or child:IsA("AlignOrientation") or child.Name:find("Kick2") or child.Name:find("Kick3") then
							pcall(function()
								child:Destroy()
							end)
						end
					end
				end
			end
		end
	end

	local function restartKick()
		if State.runtime.kickTask then
			pcall(task.cancel, State.runtime.kickTask)
			State.runtime.kickTask = nil
		end

		clearKickConstraints()
		if not State.runtime.kick then
			return
		end

		if not State.runtime.target or State.runtime.target == "" or not Players:FindFirstChild(State.runtime.target) then
			Library:Notify({ Title = "Rose", Description = "Select target", Time = 3 })
			return
		end

		State.runtime.kickCurrentTarget = State.runtime.target
		local target = State.runtime.target

		State.runtime.kickTask = task.spawn(function()
			KickLoop(target)
		end)
	end

	local function restartRagdoll()
		if State.runtime.rogdollTask then
			pcall(task.cancel, State.runtime.rogdollTask)
			State.runtime.rogdollTask = nil
		end

		if not State.runtime.rogdoll then
			return
		end

		if not State.runtime.target or State.runtime.target == "" or not Players:FindFirstChild(State.runtime.target) then
			Library:Notify({ Title = "Rose", Description = "Select target", Time = 3 })
			return
		end

		if not State.runtime.rogdollMethod or State.runtime.rogdollMethod == "" then
			Library:Notify({ Title = "Rose", Description = "Ragdoll method", Time = 3 })
			return
		end

		local target = State.runtime.target
		local method = State.runtime.rogdollMethod

		State.runtime.rogdollTask = task.spawn(function()
			if method == "Pallet Rogdoll" then
				PalletRagdoll(target)
			elseif method == "Snowball Rogdoll" then
				SnowballRagdoll(target)
			end
		end)
	end

	State.refs.restartKick = restartKick
	State.refs.restartRagdoll = restartRagdoll

	kickBox:AddToggle("KickToggle", {
		Text = "Kick",
		Default = false,
		Callback = function(enabled)
			State.runtime.kick = enabled

			if enabled then
				restartKick()
			else
				if State.runtime.kickTask then
					pcall(task.cancel, State.runtime.kickTask)
					State.runtime.kickTask = nil
				end

				clearKickConstraints()
				State.runtime.kickCurrentTarget = nil
			end
		end,
	})

	kickBox:AddToggle("SpamKick", {
		Text = "Spam Kick (Strong / Krampus)",
		Default = false,
		Callback = function(enabled)
			State.runtime.spamKick = enabled

			if enabled then
				if not State.runtime.target or State.runtime.target == "" then
					Library:Notify({ Title = "Rose", Description = "Select target first", Time = 3 })
					if Toggles.SpamKick then Toggles.SpamKick:SetValue(false) end
					return
				end

				task.spawn(function()
					local ge = GetGrabEvents()
					if not ge then return end
					local setNO = ge:FindFirstChild("SetNetworkOwner")
					if not setNO then return end

					while State.runtime.spamKick and State.runtime.target and State.runtime.target ~= "" do
						local target = Players:FindFirstChild(State.runtime.target)
						if not target or not target.Character then
							task.wait(0.5)
							continue
						end

						local character = LocalPlayer.Character
						local rootPart = character and character:FindFirstChild("HumanoidRootPart")
						local targetCharacter = target.Character
						local targetRootPart = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
						local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")

						if not (rootPart and targetRootPart and targetHumanoid and targetHumanoid.Health > 0) then
							task.wait(0.3)
							continue
						end

						rootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, -20, 0)

						pcall(function()
							targetHumanoid.PlatformStand = true
							targetHumanoid.Sit = true
						end)

						for _, child in ipairs(targetRootPart:GetChildren()) do
							if child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
								pcall(function() child:Destroy() end)
							end
						end

						local att = Instance.new("Attachment", targetRootPart)
						local wAtt = Instance.new("Attachment", workspace.Terrain)
						local ap = Instance.new("AlignPosition")
						ap.Attachment0 = att
						ap.Attachment1 = wAtt
						ap.RigidityEnabled = true
						ap.MaxForce = 9e9
						ap.MaxVelocity = 9e9
						ap.Responsiveness = 9e9
						ap.Parent = targetRootPart

						local ao = Instance.new("AlignOrientation")
						ao.Attachment0 = att
						ao.Attachment1 = wAtt
						ao.MaxTorque = 9e9
						ao.MaxAngularVelocity = 9e9
						ao.Responsiveness = 9e9
						ao.Parent = targetRootPart

						for i = 1, 8 do
							if not State.runtime.spamKick then break end
							pcall(function()
								for j = 1, 3 do setNO:FireServer(targetRootPart, targetRootPart.CFrame) end
							end)
							local dg = ge:FindFirstChild("DestroyGrabLine")
							if dg then pcall(function() dg:FireServer(targetRootPart) end) end
							pcall(function() wAtt.Position = (rootPart.CFrame * CFrame.new(0, 25, 0)).Position end)
							task.wait(0.05)
						end

						pcall(function() ap:Destroy(); ao:Destroy(); att:Destroy(); wAtt:Destroy() end)
						pcall(function() targetRootPart.AssemblyLinearVelocity = Vector3.zero end)
						task.wait(0.3)
					end
				end)
			end
		end,
	})

	kickBox:AddSlider("KickHeight", {
		Text = "Kick Height",
		Default = 22,
		Min = 15,
		Max = 25,
		Rounding = 0,
		Callback = function(value)
			State.runtime.kickHeight = value
		end,
	})

	kickBox:AddSlider("GrabDelay", {
		Text = "Grab Delay",
		Default = 0.05,
		Min = 0.001,
		Max = 1,
		Rounding = 3,
		Callback = function(value)
			State.runtime.grabDelay = value
		end,
	})

	kickBox:AddToggle("LoopKill", {
		Text = "Loop Kill",
		Default = false,
		Callback = function(enabled)
			State.runtime.loopKill = enabled

			if enabled and State.runtime.target and State.runtime.target ~= "" then
				State.runtime.loopKillTask = task.spawn(function()
					LoopKill(State.runtime.target)
				end)
			elseif enabled then
				State.runtime.loopKill = false
			elseif State.runtime.loopKillTask then
				pcall(task.cancel, State.runtime.loopKillTask)
				State.runtime.loopKillTask = nil
			end
		end,
	})

	kickBox:AddButton({
		Text = "Sky Kick (up)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 5 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.new(0, 500, 0) end)
			Library:Notify({ Title = "Rose", Description = "Sky kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Void Kick (down)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 5 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.new(0, -500, 0) end)
			Library:Notify({ Title = "Rose", Description = "Void kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Spin Kick",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 5 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			pcall(function()
				th.PlatformStand = true
				for i = 1, 20 do
					tr.CFrame = tr.CFrame * CFrame.Angles(0, math.rad(30), 0)
					tr.AssemblyAngularVelocity = Vector3.new(0, 100, 0)
					task.wait(0.05)
				end
				tr.AssemblyAngularVelocity = Vector3.zero
			end)
			Library:Notify({ Title = "Rose", Description = "Spin kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Multi Kick (all players)",
		Func = function()
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					local tr = p.Character:FindFirstChild("HumanoidRootPart")
					local th = p.Character:FindFirstChildOfClass("Humanoid")
					if tr and th and th.Health > 0 then
						local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
						local so = ge and ge:FindFirstChild("SetNetworkOwner")
						if so then for i = 1, 3 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
						pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.new(0, 300, 0) end)
					end
				end
			end
			Library:Notify({ Title = "Rose", Description = "Multi kicked all", Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Ground Kick (Shuriken)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			local spawnToy = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
			if not spawnToy then Library:Notify({ Title = "Rose", Description = "SpawnToy not found", Time = 2 }); return end
			-- spawn shurikens on target and fling
			for i = 1, 5 do
				task.spawn(function()
					pcall(function()
						spawnToy:InvokeServer("NinjaShuriken", tr.CFrame * CFrame.new(0, 0, 0), Vector3.zero)
					end)
					task.wait(0.1)
					local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
					local shuriken = toys and toys:FindFirstChild("NinjaShuriken")
					if shuriken then
						local sp = shuriken:FindFirstChild("SoundPart") or shuriken:FindFirstChild("Hitbox") or shuriken:FindFirstChildWhichIsA("BasePart")
						if sp then
							local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
							local so = ge and ge:FindFirstChild("SetNetworkOwner")
							if so then pcall(function() so:FireServer(sp, sp.CFrame) end) end
							pcall(function()
								sp.CFrame = tr.CFrame
								sp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
								th.PlatformStand = true
								tr.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
							end)
							task.wait(0.05)
							pcall(function()
								sp.CFrame = tr.CFrame * CFrame.new(0, -5, 0)
								tr.AssemblyLinearVelocity = Vector3.new(0, -100, 0)
							end)
						end
					end
				end)
			end
			Library:Notify({ Title = "Rose", Description = "Ground kick (shuriken) on " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddToggle("ShurikenMinefield", {
		Text = "Shuriken Minefield (kick on touch)",
		Default = false,
		Callback = function(enabled)
			State.runtime.shurikenMinefield = enabled
			if enabled then
				task.spawn(function()
					local spawnToy = ReplicatedStorage:FindFirstChild("MenuToys") and ReplicatedStorage.MenuToys:FindFirstChild("SpawnToyRemoteFunction")
					if not spawnToy then Library:Notify({ Title = "Rose", Description = "SpawnToy not found", Time = 2 }); return end
					while State.runtime.shurikenMinefield do
						local target = Players:FindFirstChild(State.runtime.target or "")
						local pos = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position)
						if pos then
							-- spawn shuriken on ground
							pcall(function()
								spawnToy:InvokeServer("NinjaShuriken", CFrame.new(pos.X, pos.Y - 3, pos.Z), Vector3.zero)
							end)
							task.wait(0.3)
							local toys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
							local shuriken = toys and toys:FindFirstChild("NinjaShuriken")
							if shuriken then
								local sp = shuriken:FindFirstChild("SoundPart") or shuriken:FindFirstChild("Hitbox") or shuriken:FindFirstChildWhichIsA("BasePart")
								if sp then
									-- claim ownership
									local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
									local so = ge and ge:FindFirstChild("SetNetworkOwner")
									if so then pcall(function() so:FireServer(sp, sp.CFrame) end) end
									-- make it a mine: when touched, kick
									sp.Touched:Connect(function(hit)
										if not State.runtime.shurikenMinefield then return end
										local char = hit:FindFirstAncestorOfClass("Model")
										local plr = char and Players:GetPlayerFromCharacter(char)
										if plr and plr ~= LocalPlayer then
											local hrp = char:FindFirstChild("HumanoidRootPart")
											local hum = char:FindFirstChildOfClass("Humanoid")
											if hrp and hum and hum.Health > 0 then
												pcall(function()
													hum.PlatformStand = true
													hrp.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
												end)
												local ge2 = ReplicatedStorage:FindFirstChild("GrabEvents")
												local dg = ge2 and ge2:FindFirstChild("DestroyGrabLine")
												if dg then pcall(function() dg:FireServer(hrp) end) end
											end
										end
									end)
								end
							end
						end
						task.wait(0.5)
					end
				end)
				Library:Notify({ Title = "Rose", Description = "Shuriken Minefield ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Shuriken Minefield OFF", Time = 2 })
			end
		end,
	})

	kickBox:AddButton({
		Text = "Heaven Kick (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				root.CFrame = CFrame.new(0, 999999999999, 0)
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganHeaven"
				bv.MaxForce = Vector3.new(0, math.huge, 0)
				bv.Velocity = Vector3.new(0, 99999999999999, 0)
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			end)
			Library:Notify({ Title = "Rose", Description = "Heaven kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Hell Kick (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				for _, part in ipairs(target.Character:GetDescendants()) do
					if part:IsA("BasePart") and not part.Anchored then part.CanCollide = false end
				end
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganSpy"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.new(0, -100000000, 0)
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			end)
			Library:Notify({ Title = "Rose", Description = "Hell kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "China Kick (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				root.CFrame = CFrame.new(591, 153, -101)
			end)
			Library:Notify({ Title = "Rose", Description = "China kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Ragdoll Kick (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if not root or not hum then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganSpy"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.new(0, -20, 0)
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
				hum.PlatformStand = true
			end)
			Library:Notify({ Title = "Rose", Description = "Ragdoll kicked " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Fling (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				local away = myRoot and (root.Position - myRoot.Position).Unit or Vector3.new(0,0,1)
				away = Vector3.new(away.X, 0, away.Z) * 90000
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganFling"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = away
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			end)
			Library:Notify({ Title = "Rose", Description = "Flung " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Kill (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				local away = myRoot and (root.Position - myRoot.Position).Unit or Vector3.new(0,0,1)
				away = Vector3.new(away.X, 0, away.Z) * 99999999999999
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganFling"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = away
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			end)
			Library:Notify({ Title = "Rose", Description = "Killed " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Send to Heaven (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			pcall(function()
				if so then so:FireServer(root, root.CFrame) end
				if dg then dg:FireServer(root) end
				root.CFrame = CFrame.new(0, 200, 0)
				local bv = Instance.new("BodyVelocity")
				bv.Name = "RinneganHeaven"
				bv.MaxForce = Vector3.new(0, math.huge, 0)
				bv.Velocity = Vector3.new(0, 200, 0)
				bv.P = 12500
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			end)
			Library:Notify({ Title = "Rose", Description = "Sent " .. target.Name .. " to heaven", Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "GrabLine Spam (XOCU)",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local th = target.Character:FindFirstChild("Head")
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			if not (th and tr) then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local cg = ge and ge:FindFirstChild("CreateGrabLine")
			if not cg then Library:Notify({ Title = "Rose", Description = "CreateGrabLine not found", Time = 2 }); return end
			for i = 1, 10 do
				pcall(function() cg:FireServer(th, th.CFrame) end)
				pcall(function() cg:FireServer(tr, tr.CFrame) end)
			end
			Library:Notify({ Title = "Rose", Description = "GrabLine spam sent", Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Ownership Kick",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local root = target.Character:FindFirstChild("HumanoidRootPart")
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if not root or not hum then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			-- spam ownership to take control
			for i = 1, 20 do
				pcall(function() so:FireServer(root, root.CFrame) end)
			end
			task.wait(0.1)
			pcall(function()
				hum.PlatformStand = true
				if dg then dg:FireServer(root) end
				root.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
				root.AssemblyAngularVelocity = Vector3.new(50, 50, 50)
			end)
			-- repeat ownership spam
			task.spawn(function()
				for i = 1, 10 do
					task.wait(0.1)
					pcall(function() so:FireServer(root, root.CFrame) end)
					pcall(function() root.AssemblyLinearVelocity = Vector3.new(0, 500, 0) end)
				end
			end)
			Library:Notify({ Title = "Rose", Description = "Ownership kick on " .. target.Name, Time = 2 })
		end,
	})

	kickBox:AddButton({
		Text = "Destroy Server",
		Func = function()
			task.spawn(function()
				SetLineLagActive()
				task.wait(1)
				local others = GetOtherPlayers()

				if #others == 0 then
					ClearLineLagActive()
					Library:Notify({ Title = "Rose", Description = "No players to destroy", Time = 3 })
					return
				end

				local character = LocalPlayer.Character
				local rootPart = character and character:FindFirstChild("HumanoidRootPart")
				if not rootPart then
					ClearLineLagActive()
					return
				end

				local targets = {}

				for _, player in ipairs(others) do
					local otherRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if otherRoot then
						table.insert(targets, { player = player, hrp = otherRoot })
					end
				end

				for _, target in ipairs(targets) do
					TeleportBehind(rootPart, target.hrp)
					task.wait(0.2)
					FireSetNetworkOwner(target.hrp)
					task.wait()
				end

				local angleStep = 6.2831853071795862 / #targets

				for i, target in ipairs(targets) do
					local angle = (i - 1) * angleStep
					local x = math.cos(angle) * 40
					local z = math.sin(angle) * 40

					pcall(function()
						target.hrp.CFrame = CFrame.new(x, 35, z)
						target.hrp.AssemblyLinearVelocity = Vector3.zero
					end)

					local bodyPosition = Instance.new("BodyPosition")
					bodyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
					bodyPosition.P = 40000000
					bodyPosition.Position = Vector3.new(x, 35, z)
					bodyPosition.Parent = target.hrp

					task.delay(2, function()
						pcall(function()
							bodyPosition:Destroy()
						end)
					end)

					task.wait()
				end

				for i = 1, 8 do
					for _, target in ipairs(targets) do
						FireDestroyGrabLine(target.hrp)
					end

					task.wait(0.3)
				end

				ClearLineLagActive()
				Library:Notify({ Title = "Rose", Description = "Destroy Server executed on " .. #targets .. " players", Time = 4 })
			end)
		end,
	})

	local controlBox = Tabs.Target:AddGroupbox({ Side = "Left", Name = "Target Control (XOCU)" })
	local freezeState = false
	local blockState = false

	controlBox:AddToggle("FreezeTarget", {
		Text = "Freeze Target",
		Default = false,
		Callback = function(enabled)
			freezeState = enabled
			local target = Players:FindFirstChild(State.runtime.target or "")
			if target and target.Character then
				local hrp = target.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.Anchored = enabled end
			end
			Library:Notify({ Title = "Rose", Description = "Freeze " .. (enabled and "ON" or "OFF"), Time = 2 })
		end,
	})

	controlBox:AddToggle("AnchorTarget", {
		Text = "Anchor Target (no fall)",
		Default = false,
		Callback = function(enabled)
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local hrp = target.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Anchored = enabled
				Library:Notify({ Title = "Rose", Description = "Anchor " .. (enabled and "ON" or "OFF"), Time = 2 })
			end
		end,
	})

	controlBox:AddToggle("BlockTarget", {
		Text = "Block Target (BodyVelocity)",
		Default = false,
		Callback = function(enabled)
			blockState = enabled
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then return end
			local hrp = target.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			if enabled then
				if not hrp:FindFirstChild("RoseBlock") then
					local bv = Instance.new("BodyVelocity")
					bv.Name = "RoseBlock"
					bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bv.Velocity = Vector3.zero
					bv.Parent = hrp
				end
			else
				local bv = hrp:FindFirstChild("RoseBlock")
				if bv then bv:Destroy() end
			end
			Library:Notify({ Title = "Rose", Description = "Block " .. (enabled and "ON" or "OFF"), Time = 2 })
		end,
	})

	local pclKickBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "PCLD Kick" })

	pclKickBox:AddButton({
		Text = "PCLD-Independent Kick",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			-- does NOT rely on PSLD: uses direct HRP velocity + ownership spam
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 10 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			pcall(function()
				th.PlatformStand = true
				th.Sit = false
				tr.Anchored = false
				-- direct velocity (no PSLD needed)
				tr.AssemblyLinearVelocity = Vector3.new(0, 250, 0)
				tr.AssemblyAngularVelocity = Vector3.new(0, 50, 0)
			end)
			-- also apply align for stronger effect
			local att = Instance.new("Attachment", tr)
			local wAtt = Instance.new("Attachment", workspace.Terrain)
			local ap = Instance.new("AlignPosition")
			ap.Attachment0 = att; ap.Attachment1 = wAtt
			ap.MaxForce = math.huge; ap.Responsiveness = 200; ap.Parent = tr
			wAtt.WorldPosition = tr.Position + Vector3.new(0, 50, 0)
			task.delay(0.5, function()
				pcall(function() ap:Destroy(); att:Destroy(); wAtt:Destroy() end)
				pcall(function() tr.AssemblyLinearVelocity = Vector3.zero end)
			end)
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			if dg then pcall(function() dg:FireServer(tr) end) end
			Library:Notify({ Title = "Rose", Description = "PCLD-independent kick on " .. target.Name, Time = 2 })
		end,
		Tooltip = "Кикает без зависимости от PSLD (прямая velocity + align)",
	})
	pclKickBox:AddButton({
		Text = "PCLD Break Kick",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			-- break opponent's PCLD parts
			for _, obj in ipairs(target.Character:GetDescendants()) do
				if obj.Name:lower():find("playercharacterlocationdetector") or obj.Name:lower():find("partesp") then
					local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
					local so = ge and ge:FindFirstChild("SetNetworkOwner")
					if so then pcall(function() so:FireServer(obj, obj.CFrame) end) end
					pcall(function() obj:Destroy() end)
				end
			end
			-- also check spawned toys
			local toys = Workspace:FindFirstChild(target.Name .. "SpawnedInToys")
			if toys then
				for _, c in ipairs(toys:GetDescendants()) do
					if c.Name:lower():find("playercharacterlocationdetector") or c.Name:lower():find("partesp") then
						pcall(function() c:Destroy() end)
					end
				end
			end
			task.wait(0.2)
			-- kick
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 5 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.new(0, 200, 0) end)
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			if dg then pcall(function() dg:FireServer(tr) end) end
			Library:Notify({ Title = "Rose", Description = "PCLD Break Kick on " .. target.Name, Time = 2 })
		end,
	})

	pclKickBox:AddButton({
		Text = "Break Opponent PCLD",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local count = 0
			for _, obj in ipairs(target.Character:GetDescendants()) do
				if obj.Name:lower():find("playercharacterlocationdetector") or obj.Name:lower():find("partesp") then
					pcall(function() obj:Destroy() end); count = count + 1
				end
			end
			local toys = Workspace:FindFirstChild(target.Name .. "SpawnedInToys")
			if toys then
				for _, c in ipairs(toys:GetDescendants()) do
					if c.Name:lower():find("playercharacterlocationdetector") or c.Name:lower():find("partesp") then
						pcall(function() c:Destroy() end); count = count + 1
					end
				end
			end
			Library:Notify({ Title = "Rose", Description = "Broke " .. count .. " PCLD parts", Time = 2 })
		end,
	})

	local autoDefBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Auto Defense (XOCU)" })
	local autoDefMode = "Fling"
	local autoDefActive = false
	local autoDefConn = nil
	local crazyline = false
	local crazylineTask = nil

	autoDefBox:AddDropdown("AutoDefMode", {
		Values = { "Fling", "Kill", "Send to Heaven", "Kick", "Ragdoll", "Hell", "China", "GrabLine" },
		Default = "Fling",
		Text = "Attack Mode",
		Callback = function(m) autoDefMode = m end,
	})

	local function getAttacker()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("Head") then return nil end
		local owner = char.Head:FindFirstChild("PartOwner")
		if not owner or not owner:IsA("StringValue") then return nil end
		return Players:FindFirstChild(owner.Value)
	end

	local function performMode(attacker, mode)
		if not attacker or not attacker.Character then return end
		local root = attacker.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
		local so = ge and ge:FindFirstChild("SetNetworkOwner")
		local dg = ge and ge:FindFirstChild("DestroyGrabLine")
		local cg = ge and ge:FindFirstChild("CreateGrabLine")
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		pcall(function()
			if so then so:FireServer(root, root.CFrame) end
			if dg then dg:FireServer(root) end
			if mode == "Fling" then
				local away = myRoot and (root.Position - myRoot.Position).Unit or Vector3.new(0, 0, 1)
				away = Vector3.new(away.X, 0, away.Z) * 90000
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganFling"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = away; bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			elseif mode == "Kill" then
				local away = myRoot and (root.Position - myRoot.Position).Unit or Vector3.new(0, 0, 1)
				away = Vector3.new(away.X, 0, away.Z) * 99999999999999
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganFling"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = away; bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			elseif mode == "Send to Heaven" then
				root.CFrame = CFrame.new(0, 200, 0)
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganHeaven"; bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Velocity = Vector3.new(0, 200, 0); bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			elseif mode == "Kick" then
				root.CFrame = CFrame.new(0, 999999999999, 0)
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganHeaven"; bv.MaxForce = Vector3.new(0, math.huge, 0); bv.Velocity = Vector3.new(0, 99999999999999, 0); bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			elseif mode == "Ragdoll" then
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganSpy"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0, -20, 0); bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
				local hum = attacker.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = true end
			elseif mode == "Hell" then
				for _, part in ipairs(attacker.Character:GetDescendants()) do if part:IsA("BasePart") and not part.Anchored then part.CanCollide = false end end
				local bv = Instance.new("BodyVelocity"); bv.Name = "RinneganSpy"; bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0, -100000000, 0); bv.P = 12500; bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.01)
			elseif mode == "China" then
				root.CFrame = CFrame.new(591, 153, -101)
			elseif mode == "GrabLine" then
				if not crazylineTask then
					crazyline = true
					crazylineTask = task.spawn(function()
						while crazyline do
							local char = LocalPlayer.Character
							if char then
								local head = char:FindFirstChild("Head")
								if head then
									local owner = head:FindFirstChild("PartOwner")
									if owner and owner:IsA("StringValue") then
										local att = Players:FindFirstChild(owner.Value)
										if att and att.Character then
											local aHead = att.Character:FindFirstChild("Head")
											local aHRP = att.Character:FindFirstChild("HumanoidRootPart")
											if aHead and aHRP and cg then
												for i = 1, 10 do pcall(function() cg:FireServer(aHead, aHead.CFrame) end) end
												for i = 1, 10 do pcall(function() cg:FireServer(aHRP, aHRP.CFrame) end) end
											end
										end
									end
								end
							end
							task.wait(0.01)
						end
					end)
				end
			end
		end)
	end

	autoDefBox:AddToggle("AutoDefense", {
		Text = "Auto Defense (on grab)",
		Default = false,
		Callback = function(enabled)
			autoDefActive = enabled
			if enabled then
				if autoDefConn then autoDefConn:Disconnect() end
				autoDefConn = RunService.Heartbeat:Connect(function()
					if not autoDefActive then return end
					local attacker = getAttacker()
					if not attacker then return end
					performMode(attacker, autoDefMode)
				end)
				Library:Notify({ Title = "Rose", Description = "Auto Defense ON", Time = 2 })
			else
				if autoDefConn then autoDefConn:Disconnect(); autoDefConn = nil end
				crazyline = false
				if crazylineTask then pcall(task.cancel, crazylineTask); crazylineTask = nil end
				Library:Notify({ Title = "Rose", Description = "Auto Defense OFF", Time = 2 })
			end
		end,
	})

	local deathAuraBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Death Aura (XOCU)" })
	local deathAuraActive = false
	local deathAuraConn = nil

	deathAuraBox:AddToggle("DeathAura", {
		Text = "Death Aura",
		Default = false,
		Callback = function(enabled)
			deathAuraActive = enabled
			if enabled then
				if deathAuraConn then deathAuraConn:Disconnect() end
				deathAuraConn = RunService.Heartbeat:Connect(function()
					if not deathAuraActive then return end
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character then
							local char = plr.Character
							local hrp = char:FindFirstChild("HumanoidRootPart")
							local head = char:FindFirstChild("Head")
							local hum = char:FindFirstChildOfClass("Humanoid")
							local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp and head and hum and hum.Health > 0 and myRoot then
								if (hrp.Position - myRoot.Position).Magnitude <= 25 then
									pcall(function()
										local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
										local so = ge and ge:FindFirstChild("SetNetworkOwner")
										local dg = ge and ge:FindFirstChild("DestroyGrabLine")
										if so then so:FireServer(hrp, hrp.CFrame) end
										task.wait(0.1)
										if dg then dg:FireServer(hrp) end
										if head:FindFirstChild("PartOwner") and head.PartOwner.Value == LocalPlayer.Name then
											for _, part in ipairs(char:GetChildren()) do
												if part:IsA("BasePart") then
													part.CFrame = CFrame.new(-1000000000, 1000000000, -1000000000)
												end
											end
											task.wait()
											for _, part in ipairs(char:GetChildren()) do
												if part:IsA("BasePart") then
													part.CFrame = CFrame.new(-1000000000, 1000000000, -1000000000)
												end
											end
											local bv = Instance.new("BodyVelocity")
											bv.Velocity = Vector3.new(0, -9999999, 0)
											bv.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
											bv.P = 100000075
											bv.Parent = hrp
											hum.Sit = false
											hum.Jump = true
											hum.BreakJointsOnDeath = false
											hum:ChangeState(Enum.HumanoidStateType.Dead)
											game:GetService("Debris"):AddItem(bv, 2)
										end
									end)
								end
							end
						end
					end)
				Library:Notify({ Title = "Rose", Description = "Death Aura ON", Time = 2 })
			else
				if deathAuraConn then deathAuraConn:Disconnect(); deathAuraConn = nil end
				Library:Notify({ Title = "Rose", Description = "Death Aura OFF", Time = 2 })
			end
		end,
	})

	local hellAuraBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Hell Send Aura (XOCU)" })
	local hellAuraActive = false
	local hellAuraConn = nil
	local hellAuraRadius = 25

	hellAuraBox:AddSlider("HellAuraRadius", {
		Text = "Aura Radius",
		Default = 25,
		Min = 5,
		Max = 100,
		Rounding = 0,
		Callback = function(v) hellAuraRadius = v end,
	})

	hellAuraBox:AddToggle("HellSendAura", {
		Text = "Hell Send Aura",
		Default = false,
		Callback = function(enabled)
			hellAuraActive = enabled
			if enabled then
				if hellAuraConn then hellAuraConn:Disconnect() end
				hellAuraConn = RunService.Heartbeat:Connect(function()
					if not hellAuraActive then return end
					local myChar = LocalPlayer.Character
					local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
					if not myRoot then return end
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character then
							local char = plr.Character
							local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
							if torso and (torso.Position - myRoot.Position).Magnitude <= hellAuraRadius then
								local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
								local so = ge and ge:FindFirstChild("SetNetworkOwner")
								if so then pcall(function() so:FireServer(torso, myRoot.CFrame) end) end
								for _, part in ipairs(char:GetDescendants()) do
									if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
								end
								local bp = torso:FindFirstChild("HellAuraPos") or Instance.new("BodyPosition")
								bp.Name = "HellAuraPos"
								bp.MaxForce = Vector3.new(100000, 100000, 100000)
								bp.D = 500; bp.P = 50000; bp.Parent = torso
								local bg = torso:FindFirstChild("HellAuraGyro") or Instance.new("BodyGyro")
								bg.Name = "HellAuraGyro"
								bg.MaxTorque = Vector3.new(100000, 100000, 100000)
								bg.D = 500; bg.P = 50000; bg.Parent = torso
								local look = Camera.CFrame.LookVector
								bp.Position = myRoot.Position + look * 15 + Vector3.new(0, 5, 0)
								bg.CFrame = CFrame.new(torso.Position, myRoot.Position)
							end
						end
					end)
				end)
				Library:Notify({ Title = "Rose", Description = "Hell Send Aura ON", Time = 2 })
			else
				if hellAuraConn then hellAuraConn:Disconnect(); hellAuraConn = nil end
				Library:Notify({ Title = "Rose", Description = "Hell Send Aura OFF", Time = 2 })
			end
		end,
	})

	local desyncBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Desync" })
	local desyncActive = false
	local desyncConn = nil

	desyncBox:AddToggle("Desync", {
		Text = "Desync (client-side)",
		Default = false,
		Callback = function(enabled)
			desyncActive = enabled
			local character = LocalPlayer.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if enabled then
				if rootPart then
					-- desync: push character far on client, server stays
					local saved = rootPart.CFrame
					rootPart.CFrame = saved + Vector3.new(0, 1000, 0)
				end
				Library:Notify({ Title = "Rose", Description = "Desync ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Desync OFF", Time = 2 })
			end
		end,
	})

	desyncBox:AddButton({
		Text = "Desync Kick",
		Func = function()
			local target = Players:FindFirstChild(State.runtime.target or "")
			if not target or not target.Character then Library:Notify({ Title = "Rose", Description = "Select target", Time = 2 }); return end
			local tr = target.Character:FindFirstChild("HumanoidRootPart")
			local th = target.Character:FindFirstChildOfClass("Humanoid")
			if not tr or not th then return end
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			local so = ge and ge:FindFirstChild("SetNetworkOwner")
			if so then for i = 1, 10 do pcall(function() so:FireServer(tr, tr.CFrame) end) end end
			-- desync: teleport locally without server sync
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local saved = root.CFrame
				root.CFrame = tr.CFrame * CFrame.new(0, 0, 2)
				task.wait(0.1)
				root.CFrame = saved
			end
			pcall(function() th.PlatformStand = true; tr.AssemblyLinearVelocity = Vector3.new(0, 200, 0) end)
			local dg = ge and ge:FindFirstChild("DestroyGrabLine")
			if dg then pcall(function() dg:FireServer(tr) end) end
			Library:Notify({ Title = "Rose", Description = "Desync kicked " .. target.Name, Time = 2 })
		end,
	})

	local ragdollBox = Tabs.Target:AddGroupbox({ Side = "Right", Name = "Ragdoll" })

	ragdollBox:AddToggle("Ragdoll", {
		Text = "Ragdoll",
		Default = false,
		Callback = function(enabled)
			State.runtime.rogdoll = enabled

			if enabled then
				restartRagdoll()
			else
				if State.runtime.rogdollTask then
					pcall(task.cancel, State.runtime.rogdollTask)
					State.runtime.rogdollTask = nil
				end

				local targetPlayer = Players:FindFirstChild(State.runtime.target or "")

				if targetPlayer and targetPlayer.Character then
					local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

					if rootPart then
						for _, child in ipairs(rootPart:GetChildren()) do
							if child:IsA("BodyPosition") or child:IsA("BodyGyro") then
								pcall(function()
									child:Destroy()
								end)
							end
						end
					end
				end
			end
		end,
	})

	ragdollBox:AddDropdown("RagdollMethod", {
		Values = { "Pallet Rogdoll", "Snowball Rogdoll" },
		Default = 1,
		Text = "Method",
		Callback = function(method)
			State.runtime.rogdollMethod = method

			if State.runtime.rogdoll then
				restartRagdoll()
			end
		end,
	})
end

do
	-- ════════════════════════════════════════
	--   MOVEMENT TAB  (was empty — now fixed)
	-- ════════════════════════════════════════
	local moveBox = Tabs.Movement:AddGroupbox({ Side = "Left", Name = "Speed & Jump" })

	-- WalkSpeed
	local currentSpeed = 16
	moveBox:AddSlider("WalkSpeed", {
		Text = "Walk Speed",
		Default = 16,
		Min = 1,
		Max = 300,
		Rounding = 0,
		Callback = function(value)
			currentSpeed = value
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = value
			end
		end,
	})

	-- JumpPower
	moveBox:AddSlider("JumpPower", {
		Text = "Jump Power",
		Default = 50,
		Min = 1,
		Max = 500,
		Rounding = 0,
		Callback = function(value)
			local character = LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.JumpPower = value
				humanoid.UseJumpPower = true
			end
		end,
	})

	-- Keep speed on respawn
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			if currentSpeed ~= 16 then
				hum.WalkSpeed = currentSpeed
			end
		end
	end)

	-- Noclip
	local noclipActive = false
	local noclipConn = nil
	moveBox:AddToggle("Noclip", {
		Text = "Noclip",
		Default = false,
		Callback = function(enabled)
			noclipActive = enabled
			if enabled then
				noclipConn = RunService.Stepped:Connect(function()
					if not noclipActive then return end
					local character = LocalPlayer.Character
					if not character then return end
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end)
				Library:Notify({ Title = "Rose", Description = "Noclip ON", Time = 2 })
			else
				if noclipConn then
					noclipConn:Disconnect()
					noclipConn = nil
				end
				Library:Notify({ Title = "Rose", Description = "Noclip OFF", Time = 2 })
			end
		end,
	})

	-- TP to Target
	local smoothFlyState = false
	local smoothFlyConn = nil
	local smoothFlyBV = nil
	local smoothFlyBG = nil
	local smoothFlySpeed = 50

	local moveBoxFlight = Tabs.Movement:AddGroupbox({ Side = "Right", Name = "Smooth Fly (XOCU)" })
	moveBoxFlight:AddSlider("SmoothFlySpeed", {
		Text = "Speed",
		Default = 50,
		Min = 5,
		Max = 300,
		Rounding = 0,
		Callback = function(v) smoothFlySpeed = v end,
	})
	moveBoxFlight:AddToggle("SmoothFly", {
		Text = "Smooth Fly",
		Default = false,
		Callback = function(enabled)
			smoothFlyState = enabled
			local character = LocalPlayer.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if enabled then
				if not rootPart or not humanoid then
					Library:Notify({ Title = "Rose", Description = "No character", Time = 2 })
					smoothFlyState = false
					if Toggles.SmoothFly then Toggles.SmoothFly:SetValue(false) end
					return
				end
				humanoid.PlatformStand = true
				smoothFlyBV = Instance.new("BodyVelocity")
				smoothFlyBV.Velocity = Vector3.zero
				smoothFlyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				smoothFlyBV.P = 10000
				smoothFlyBV.Parent = rootPart
				smoothFlyBG = Instance.new("BodyGyro")
				smoothFlyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				smoothFlyBG.P = 10000
				smoothFlyBG.CFrame = rootPart.CFrame
				smoothFlyBG.Parent = rootPart
				local UIS = game:GetService("UserInputService")
				local curVel = Vector3.zero
				smoothFlyConn = RunService.Heartbeat:Connect(function()
					if not smoothFlyState then return end
					local ct = getFlightTarget and getFlightTarget() or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
					if not ct or not ct.Parent then return end
					if smoothFlyBV and smoothFlyBV.Parent ~= ct then
						-- re-attach
						if smoothFlyBV.Parent then smoothFlyBV:Destroy() end
						if smoothFlyBG.Parent then smoothFlyBG:Destroy() end
						smoothFlyBV = Instance.new("BodyVelocity"); smoothFlyBV.MaxForce = Vector3.new(1e9,1e9,1e9); smoothFlyBV.P=10000; smoothFlyBV.Parent=ct
						smoothFlyBG = Instance.new("BodyGyro"); smoothFlyBG.MaxTorque = Vector3.new(1e9,1e9,1e9); smoothFlyBG.P=10000; smoothFlyBG.Parent=ct
					end
					local cam = workspace.CurrentCamera
					local moveDir = Vector3.zero
					if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
					if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0,1,0) end
					if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
					local targetVel = moveDir * smoothFlySpeed
					curVel = curVel:Lerp(targetVel, 0.2)
					if smoothFlyBV and smoothFlyBV.Parent then smoothFlyBV.Velocity = curVel end
					if smoothFlyBG and smoothFlyBG.Parent then smoothFlyBG.CFrame = cam.CFrame end
				end)
				Library:Notify({ Title = "Rose", Description = "Smooth Fly ON", Time = 2 })
			else
				smoothFlyState = false
				if smoothFlyConn then smoothFlyConn:Disconnect(); smoothFlyConn = nil end
				if smoothFlyBV and smoothFlyBV.Parent then smoothFlyBV:Destroy(); smoothFlyBV = nil end
				if smoothFlyBG and smoothFlyBG.Parent then smoothFlyBG:Destroy(); smoothFlyBG = nil end
				if humanoid then humanoid.PlatformStand = false end
				Library:Notify({ Title = "Rose", Description = "Smooth Fly OFF", Time = 2 })
			end
		end,
	})

	LocalPlayer.CharacterAdded:Connect(function()
		smoothFlyState = false
		if smoothFlyConn then smoothFlyConn:Disconnect(); smoothFlyConn = nil end
		if smoothFlyBV and smoothFlyBV.Parent then smoothFlyBV:Destroy(); smoothFlyBV = nil end
		if smoothFlyBG and smoothFlyBG.Parent then smoothFlyBG:Destroy(); smoothFlyBG = nil end
	end)

	local moveBox2 = Tabs.Movement:AddGroupbox({ Side = "Left", Name = "Teleport" })

	moveBox2:AddButton({
		Text = "TP to Target",
		Func = function()
			local target = State.runtime.target
			if not target or target == "" then
				Library:Notify({ Title = "Rose", Description = "Select target first", Time = 3 })
				return
			end
			local targetPlayer = Players:FindFirstChild(target)
			local targetRoot = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if myRoot and targetRoot then
				myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
				Library:Notify({ Title = "Rose", Description = "Teleported to " .. target, Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Target or your character not found", Time = 3 })
			end
		end,
	})

	-- Fly
	local flyActive = false
	local flyBodyVelocity = nil
	local flyBodyGyro = nil
	local flySpeed = 50
	local flyConn = nil

	moveBox2:AddSlider("FlySpeed", {
		Text = "Fly Speed",
		Default = 50,
		Min = 5,
		Max = 300,
		Rounding = 0,
		Callback = function(v)
			flySpeed = v
		end,
	})

	moveBox2:AddToggle("FlyToggle", {
		Text = "Fly",
		Default = false,
		Callback = function(enabled)
			flyActive = enabled
			local character = LocalPlayer.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if enabled then
				if not rootPart or not humanoid then
					Library:Notify({ Title = "Rose", Description = "No character", Time = 2 })
					flyActive = false
					if Toggles.FlyToggle then Toggles.FlyToggle:SetValue(false) end
					return
				end

				humanoid.PlatformStand = true

				flyBodyVelocity = Instance.new("BodyVelocity")
				flyBodyVelocity.Velocity = Vector3.zero
				flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				flyBodyVelocity.Parent = rootPart

				flyBodyGyro = Instance.new("BodyGyro")
				flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				flyBodyGyro.P = 1e4
				flyBodyGyro.CFrame = rootPart.CFrame
				flyBodyGyro.Parent = rootPart

				local UserInputService = game:GetService("UserInputService")
				flyConn = RunService.Heartbeat:Connect(function()
					if not flyActive then return end
					local cam = workspace.CurrentCamera
					local cf = cam.CFrame
					local vel = Vector3.zero
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
					if flyBodyVelocity and flyBodyVelocity.Parent then
						flyBodyVelocity.Velocity = vel.Magnitude > 0 and vel.Unit * flySpeed or Vector3.zero
					end
					if flyBodyGyro and flyBodyGyro.Parent then
						flyBodyGyro.CFrame = cf
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Fly ON (WASD+Space/Ctrl)", Time = 2 })
			else
				flyActive = false
				if flyConn then flyConn:Disconnect(); flyConn = nil end
				if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
				if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy(); flyBodyGyro = nil end
				if humanoid then humanoid.PlatformStand = false end
				Library:Notify({ Title = "Rose", Description = "Fly OFF", Time = 2 })
			end
		end,
	})

	-- Clean up fly on character respawn
	LocalPlayer.CharacterAdded:Connect(function()
		flyActive = false
		if flyConn then flyConn:Disconnect(); flyConn = nil end
		if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
		if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy(); flyBodyGyro = nil end
		if Toggles.FlyToggle then Toggles.FlyToggle:SetValue(false) end
	end)
end

do
	local blobBox = Tabs.Blobman:AddGroupbox({ Side = "Left", Name = "Blobman" })
	local blobTarget = nil

	local BlobPlayer = blobBox:AddDropdown("BlobPlayer", {
		Values = GetPlayerNames(),
		Default = 1,
		Text = "Player",
		Callback = function(name)
			local player = FindPlayerByName(name)
			blobTarget = player and player.Name or name
		end,
	})

	if GetPlayerNames()[1] then
		local player = FindPlayerByName(GetPlayerNames()[1])
		blobTarget = player and player.Name or GetPlayerNames()[1]
	end

	blobBox:AddButton({
		Text = "Refresh List",
		Func = function()
			local names = GetPlayerNames()
			BlobPlayer:SetValues(names)

			if #names > 0 and (not blobTarget or not Players:FindFirstChild(blobTarget)) then
				BlobPlayer:SetValue(names[1])
				local player = FindPlayerByName(names[1])
				blobTarget = player and player.Name or names[1]
			end
		end,
	})

	local blobSettingsBox = Tabs.Blobman:AddGroupbox({ Side = "Left", Name = "Blobman Settings" })

	blobSettingsBox:AddToggle("BlobDestroyGucci", {
		Text = "Destroy Gucci",
		Default = false,
		Callback = function(enabled)
			State.runtime.destroyGucci = enabled

			if enabled then
				State.runtime.destroyGucciTask = task.spawn(DestroyGucciLoop)
			elseif State.runtime.destroyGucciTask then
				pcall(task.cancel, State.runtime.destroyGucciTask)
				State.runtime.destroyGucciTask = nil
			end
		end,
	})

	blobSettingsBox:AddToggle("BlobRemoveAntiInput", {
		Text = "Remove All Anti Input",
		Default = false,
		Callback = function(enabled)
			State.runtime.antiInput = enabled

			if enabled then
				State.runtime.antiInputTask = task.spawn(RemoveAntiInputLoop)
			elseif State.runtime.antiInputTask then
				pcall(task.cancel, State.runtime.antiInputTask)
				State.runtime.antiInputTask = nil
			end
		end,
	})

	blobSettingsBox:AddToggle("BlobLeaveJoinNotify", {
		Text = "Leave/Join Notify",
		Default = false,
		Callback = function(enabled)
			if enabled then
				if not blobTarget or blobTarget == "" then
					return
				end

				local player = Players:FindFirstChild(blobTarget)

				if player then
					Library:Notify({ Title = "Rose", Description = player.DisplayName .. " is in game", Time = 3 })
				end

				State.runtime.notifyConns.blobAdd = Players.PlayerAdded:Connect(function(joined)
					if joined.Name == blobTarget then
						Library:Notify({ Title = "Rose", Description = joined.DisplayName .. " joined", Time = 3 })
					end
				end)

				State.runtime.notifyConns.blobRem = Players.PlayerRemoving:Connect(function(left)
					if left.Name == blobTarget then
						Library:Notify({ Title = "Rose", Description = left.DisplayName .. " left", Time = 3 })
					end
				end)
			else
				if State.runtime.notifyConns.blobAdd then
					State.runtime.notifyConns.blobAdd:Disconnect()
					State.runtime.notifyConns.blobAdd = nil
				end

				if State.runtime.notifyConns.blobRem then
					State.runtime.notifyConns.blobRem:Disconnect()
					State.runtime.notifyConns.blobRem = nil
				end
			end
		end,
	})

	local blobMethodsBox = Tabs.Blobman:AddGroupbox({ Side = "Right", Name = "Blobman Methods" })
	local selectedMethod = "Kick"

	blobMethodsBox:AddToggle("BlobRemoveAntiKick", {
		Text = "Remove Anti Kick",
		Default = false,
		Callback = function(enabled)
			State.runtime.antiKick = enabled

			if enabled and blobTarget and blobTarget ~= "" then
				State.runtime.antiKickTask = task.spawn(function()
					AntiKickLoop(blobTarget)
				end)
			elseif enabled then
				State.runtime.antiKick = false
			elseif State.runtime.antiKickTask then
				pcall(task.cancel, State.runtime.antiKickTask)
				State.runtime.antiKickTask = nil
			end
		end,
	})

	blobMethodsBox:AddToggle("ResonanceLoopKick", {
		Text = "Loop Kick (Resonance)",
		Default = false,
		Callback = function(enabled)
			State.runtime.resonanceLoopKick = enabled

			if enabled then
				if not blobTarget or blobTarget == "" then
					Library:Notify({ Title = "Rose", Description = "Select player", Time = 2 })
					if Toggles.ResonanceLoopKick then Toggles.ResonanceLoopKick:SetValue(false) end
					return
				end

				task.spawn(function()
					local function getChar(p) return p and p.Character end
					local function getRoot(c) return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end
					local function getHum(c) return c and c:FindFirstChildOfClass("Humanoid") end
					local function SNO(part)
						local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
						local so = ge and ge:FindFirstChild("SetNetworkOwner")
						if so and part then pcall(function() so:FireServer(part, part.CFrame) end) end
					end
					local function getBlobComps(blob)
						local sc = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
						return {
							CreatureGrab = sc and sc:FindFirstChild("CreatureGrab"),
							CreatureDrop = sc and sc:FindFirstChild("CreatureDrop"),
							CreatureRelease = sc and sc:FindFirstChild("CreatureRelease"),
							RightWeld = blob:FindFirstChild("RightDetector") and blob.RightDetector:FindFirstChild("RightWeld"),
							RightOri = blob:FindFirstChild("RightDetector") and blob.RightDetector:FindFirstChild("RightAlignOrientation"),
							LeftWeld = blob:FindFirstChild("LeftDetector") and blob.LeftDetector:FindFirstChild("LeftWeld"),
						}
					end
					local function Teleport(part, cf)
						if part then pcall(function() part.CFrame = cf; part.AssemblyLinearVelocity = Vector3.zero end) end
					end
					local function CreateAlign(part)
						local att = part:FindFirstChild("RootAttachment") or Instance.new("Attachment", part)
						att.Name = "RootAttachment"
						local ap = Instance.new("AlignPosition"); ap.Name = "RoseAP"; ap.Mode = Enum.PositionAlignmentMode.OneAttachment
						ap.ApplyAtCenterOfMass = true; ap.MaxForce = 1e9; ap.Responsiveness = 200; ap.Attachment0 = att; ap.Parent = part
						local ao = Instance.new("AlignOrientation"); ao.Name = "RoseAO"; ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
						ao.MaxTorque = 1e9; ao.Responsiveness = 200; ao.Attachment0 = att; ao.Parent = part
						return ap, ao
					end
					local function Grab(part)
						local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
						local cg = ge and ge:FindFirstChild("CreateGrabLine")
						if cg and part then pcall(function() cg:FireServer(part, Vector3.zero, part.Position, false) end) end
					end
					local function RNO(part)
						local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
						local dg = ge and ge:FindFirstChild("DestroyGrabLine")
						if dg and part then pcall(function() dg:FireServer(part) end) end
					end
					local function ToggleMotor6D(char, enabled)
						for _, d in ipairs(char:GetDescendants()) do
							if d:IsA("Motor6D") then pcall(function() d.Enabled = enabled end) end
						end
					end
					local function RepositionLimbs(char)
						for _, d in ipairs(char:GetDescendants()) do
							if d:IsA("BasePart") and d.Name:find("Leg") or d.Name:find("Arm") then
								pcall(function() d.CFrame = d.CFrame end)
							end
						end
					end

					while State.runtime.resonanceLoopKick do
						local target = Players:FindFirstChild(blobTarget)
						if not target or not target.Character then task.wait(0.5); continue end
						local myChar = LocalPlayer.Character
						local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
						local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
						local tChar = target.Character
						local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
						local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
						if not (myRoot and myHum and tRoot and tHum and tHum.Health > 0) then task.wait(0.5); continue end
						if not myHum.SeatPart then
							-- need to be in blobman
							local blob = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys") and workspace[LocalPlayer.Name .. "SpawnedInToys"]:FindFirstChild("CreatureBlobman")
							if blob and blob:FindFirstChild("VehicleSeat") then
								repeat
									myRoot.CFrame = blob.VehicleSeat.CFrame + Vector3.new(0, 1, 0)
									blob.VehicleSeat:Sit(myHum)
									task.wait()
								until myHum.SeatPart == blob.VehicleSeat or not State.runtime.resonanceLoopKick
							else
								task.wait(1); continue
							end
						end
						local blob = myHum.SeatPart and myHum.SeatPart.Parent
						if not blob or blob.Name ~= "CreatureBlobman" then task.wait(0.5); continue end
						local comps = getBlobComps(blob)
						if not (comps.CreatureGrab and comps.CreatureDrop and comps.CreatureRelease and comps.RightWeld and comps.RightOri) then task.wait(0.5); continue end
						comps.RightWeld.Enabled = false
						comps.RightOri.Enabled = false
						if SNO(tRoot) then
							tHum.Sit = true
							task.delay(0.5, function() pcall(function() tHum.Sit = false end) end)
							local offset = CFrame.new(2, 5, -3)
							local placeCF = myRoot.CFrame * offset
							Teleport(tRoot, placeCF)
							local ap, ao = CreateAlign(tRoot)
							if ap then ap.Position = placeCF.Position end
							task.delay(0.2, function()
								Grab(tRoot)
								RNO(tRoot)
							end)
							comps.CreatureDrop:FireServer(comps.RightWeld)
							comps.CreatureDrop:FireServer(comps.LeftWeld)
							task.wait(0.06)
							local ra = tRoot:FindFirstChild("RootAttachment")
							if ra then ra.Parent = myChar end
							while State.runtime.resonanceLoopKick and tRoot.Parent and tHum.Health > 0 and not tHum.SeatPart do
								task.spawn(function()
									tHum.RequiresNeck = false
									ToggleMotor6D(myChar, false)
									RepositionLimbs(myChar)
								end)
								task.wait()
							end
							pcall(function() if ap and ap.Parent then ap:Destroy() end; if ao and ao.Parent then ao:Destroy() end end)
							if ra and ra.Parent then ra.Parent = tRoot end
							ToggleMotor6D(myChar, true)
						end
						task.wait(0.5)
					end
					Library:Notify({ Title = "Rose", Description = "Resonance Loop Kick OFF", Time = 2 })
				end)
			else
				Library:Notify({ Title = "Rose", Description = "Resonance Loop Kick OFF", Time = 2 })
			end
		end,
	})

	blobMethodsBox:AddToggle("BlobAutoSit", {
		Text = "Auto Sit Blobman",
		Default = false,
		Callback = function(enabled)
			State.runtime.autoSit = enabled

			if enabled then
				task.spawn(function()
					while State.runtime.autoSit do
						local character = LocalPlayer.Character
						local rootPart = character and character:FindFirstChild("HumanoidRootPart")
						local humanoid = character and character:FindFirstChild("Humanoid")

						if not rootPart or not humanoid or humanoid.SeatPart then
							task.wait(0.5)
						else
							local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
							local creatureBlobman = toys and toys:FindFirstChild("CreatureBlobman")

							if not creatureBlobman then
								pcall(function()
									ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", rootPart.CFrame, Vector3.zero)
								end)

								toys = toys or workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5)
								creatureBlobman = toys and toys:WaitForChild("CreatureBlobman", 5)
							end

							if creatureBlobman then
								local vehicleSeat = creatureBlobman:WaitForChild("VehicleSeat", 5)

								if vehicleSeat then
									local startTime = tick()

									repeat
										if not humanoid.SeatPart then
											rootPart.CFrame = vehicleSeat.CFrame + Vector3.new(0, 1, 0)
											rootPart.Velocity = Vector3.zero
											vehicleSeat:Sit(humanoid)
										end

										RunService.Heartbeat:Wait()
									until humanoid.SeatPart == vehicleSeat or tick() - startTime > 1.5 or not State.runtime.autoSit
								end
							end

							task.wait(0.5)
						end
					end
				end)
			end
		end,
	})

	blobMethodsBox:AddDropdown("BlobMethod", {
		Values = { "Kick", "Bring", "Lock" },
		Default = "Kick",
		Text = "Selected Method",
		Callback = function(method)
			selectedMethod = method
		end,
	})

	blobMethodsBox:AddButton({
		Text = "Apply / Start",
		Func = function()
			if not blobTarget or blobTarget == "" then
				Library:Notify({ Title = "Rose", Description = "Select player", Time = 2 })
				return
			end
			State.runtime.blobKick = false
State.runtime.resonanceLoopKick = false
			State.runtime.loopKickBlob = false
			task.wait(0.05)
			if selectedMethod == "Kick" then
				task.spawn(BlobKick, blobTarget)
			elseif selectedMethod == "Bring" then
				task.spawn(BlobBring, blobTarget)
			elseif selectedMethod == "Lock" then
				BlobLock:Start(blobTarget)
			else
				task.spawn(BlobKick, blobTarget)
			end
		end,
	})

	blobMethodsBox:AddButton({
		Text = "STOP",
		Func = function()
			State.runtime.blobKick = false
State.runtime.resonanceLoopKick = false
			State.runtime.loopKickBlob = false
			pcall(function() BlobLock:Stop() end)
			Library:Notify({ Title = "Rose", Description = "Stopped", Time = 2 })
		end,
	})

	blobMethodsBox:AddButton({
		Text = "Destroy Visual",
		Func = function()
			if blobTarget and blobTarget ~= "" then
				task.spawn(function()
					DestroyVisual(blobTarget)
				end)
			end
		end,
	})

	blobMethodsBox:AddToggle("LoopApple", {
		Text = "Loop Apple Method",
		Default = false,
		Callback = function(enabled)
			State.runtime.loopApple = enabled

			if enabled then
				if not blobTarget or blobTarget == "" then
					return
				end

				task.spawn(function()
					if selectedMethod == "Loop Kick (Grab+Blob)" then
						State.runtime.loopKickBlob = true

						task.spawn(function()
							BlobGrabLoopKick(blobTarget)
						end)

						while State.runtime.loopApple do
							task.wait(0.1)
						end

						State.runtime.loopKickBlob = false
					elseif selectedMethod == "Lock" then
						BlobLock:Start(blobTarget)

						while State.runtime.loopApple and BlobLock.Running do
							task.wait(0.1)
						end

						BlobLock:Stop()
					else
						while State.runtime.loopApple do
							if selectedMethod == "Bring" then
								BlobBring(blobTarget)
							elseif selectedMethod == "Kick" then
								BlobKick(blobTarget)
							elseif selectedMethod == "Loop Kick" then
								BlobLoopKick(blobTarget)
							elseif selectedMethod == "Bypass" then
								BlobBypass(blobTarget)
							elseif selectedMethod == "Blob Kill" then
								task.spawn(function()
									BlobKill(blobTarget)
								end)
							end

							task.wait(1)
						end
					end
				end)
			else
				State.runtime.loopKickBlob = false
				BlobLock:Stop()
			end
		end,
	})
end
-- Gucci Anti-Grab (vehicle-based) logic
RunService.Heartbeat:Connect(function()
	if not State.runtime.gucciAntiGrab then return end
	local c = LocalPlayer.Character; if not c then return end
	local root = c:FindFirstChild("HumanoidRootPart"); local hum = c:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local grabbed = false
	for _, d in ipairs(c:GetDescendants()) do
		if (d:IsA("AlignPosition") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and d.Name ~= "RoseAlign" then grabbed = true; break end
	end
	if not grabbed then return end
	local best, bd = nil, math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if (obj:IsA("VehicleSeat") or obj:IsA("Seat")) and obj.Occupant == nil then
			local dd = (obj.Position - root.Position).Magnitude
			if dd < bd and dd < 80 then bd = dd; best = obj end
		end
	end
	if best then pcall(function() hum.Sit = true; root.CFrame = best.CFrame; best:Sit(hum) end)
	else pcall(function() root.CFrame = root.CFrame + Vector3.new(0, 15, 0); root.Velocity = Vector3.zero end) end
end)

do
	local packetBox = Tabs.Server:AddGroupbox({ Side = "Left", Name = "Packet Lag" })
	local packetSize = 1
	local packetThread = nil

	local function packetBytes()
		return packetSize * 1000000
	end

	packetBox:AddSlider("PacketLagSize", {
		Text = "Packet Size (MB)",
		Default = 1,
		Min = 1,
		Max = 20,
		Rounding = 0,
		Callback = function(value)
			packetSize = value
		end,
		Tooltip = "Размер одного пакета в мегабайтах (1 MB = 1 000 000 символов)",
	})

	packetBox:AddButton({
		Text = "Send Packet Lag (Once)",
		Func = function()
			local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
			local extendGrabLine = grabEvents and grabEvents:FindFirstChild("ExtendGrabLine")
			if not extendGrabLine then
				Library:Notify({ Title = "Rose", Description = "ExtendGrabLine not found", Time = 3 })
				return
			end

			local size = packetBytes()

			if pcall(function()
				extendGrabLine:FireServer(string.rep("A", size))
			end) then
				Library:Notify({ Title = "Rose", Description = "Packet sent! Size: " .. packetSize .. " MB", Time = 3 })
			else
				Library:Notify({ Title = "Rose", Description = "Failed to send packet", Time = 3 })
			end
		end,
		Tooltip = "Отправляет один огромный пакет через ExtendGrabLine",
	})

	packetBox:AddToggle("PacketLagLoop", {
		Text = "Packet Lag (Loop)",
		Default = false,
		Callback = function(enabled)
			if packetThread then
				pcall(task.cancel, packetThread)
				packetThread = nil
			end

			if enabled then
				packetThread = task.spawn(function()
					local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
					local extendGrabLine = grabEvents and grabEvents:FindFirstChild("ExtendGrabLine")

					if not extendGrabLine then
						if Toggles.PacketLagLoop then
							Toggles.PacketLagLoop:SetValue(false)
						end

						Library:Notify({ Title = "Rose", Description = "ExtendGrabLine not found", Time = 3 })
						return
					end

					while Toggles.PacketLagLoop.Value do
						task.wait(0.5)

						pcall(function()
							extendGrabLine:FireServer(string.rep("A", packetBytes()))
						end)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Packet Lag Loop ON", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Packet Lag Loop OFF", Time = 2 })
			end
		end,
		Tooltip = "Каждые 0.5 сек отправляет огромный пакет — сильный лaг",
	})

	local lineBox = Tabs.Server:AddGroupbox({ Side = "Right", Name = "Line Lag" })
	local lineLevel = 5
	local lineCount = 50
	local lineThread = nil

	local function updateLineCount()
		lineCount = math.floor(lineLevel * 10)
	end

	updateLineCount()

	lineBox:AddSlider("LineLagLevel", {
		Text = "Line Lag Level (1-10)",
		Default = 5,
		Min = 1,
		Max = 10,
		Rounding = 0,
		Callback = function(value)
			lineLevel = value
			updateLineCount()
		end,
		Tooltip = "Уровень 1-10 (level × 10 линий за раз)",
	})

	lineBox:AddToggle("LineLag", {
		Text = "Line Lag",
		Default = false,
		Callback = function(enabled)
			if lineThread then
				pcall(task.cancel, lineThread)
				lineThread = nil
			end

			if enabled then
				lineThread = task.spawn(function()
					local grabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
					local createLine = grabEvents and grabEvents:FindFirstChild("CreateLine")

					if not createLine then
						if Toggles.LineLag then
							Toggles.LineLag:SetValue(false)
						end

						Library:Notify({ Title = "Rose", Description = "CreateLine not found", Time = 3 })
						return
					end

					local spawnLocation = workspace:FindFirstChild("SpawnLocation")

					if not spawnLocation then
						if Toggles.LineLag then
							Toggles.LineLag:SetValue(false)
						end

						Library:Notify({ Title = "Rose", Description = "SpawnLocation not found", Time = 3 })
						return
					end

					while Toggles.LineLag.Value do
						for i = 1, lineCount do
							pcall(function()
								createLine:FireServer(spawnLocation, CFrame.new(0, 9e9, 0))
							end)
						end

						task.wait(1)
					end
				end)

				Library:Notify({ Title = "Rose", Description = "Line Lag ON (" .. lineCount .. " lines/sec)", Time = 2 })
			else
				Library:Notify({ Title = "Rose", Description = "Line Lag OFF", Time = 2 })
			end
		end,
		Tooltip = "Спамит CreateLine на высоту 9e9 — очень сильно лагает сервер",
	})
end

do
	local funVisualBox = Tabs.Fun:AddGroupbox({ Side = "Left", Name = "Visual" })

	funVisualBox:AddToggle("LSD", {
		Text = "LSD (screen warp + rainbow)",
		Default = false,
		Tooltip = "Включает радужное искажение экрана с плавным blur",
		Callback = function(enabled)
			if enabled then
				StartLSD()
				Library:Notify({ Title = "Rose", Description = "LSD ON", Time = 3 })
			else
				StopLSD()
				Library:Notify({ Title = "Rose", Description = "LSD OFF", Time = 2 })
			end
		end,
	})

	local coconutBox = Tabs.Fun:AddGroupbox({ Side = "Right", Name = "Coconut" })
	local coconutAmount = 10
	local coconutDamping = 100

	local function pinCoconutBody(toy, index, rootPart)
		local soundPart = toy:FindFirstChild("SoundPart")
		local holdPart = toy:FindFirstChild("HoldPart")
		local rigidConstraint = holdPart and holdPart:FindFirstChild("RigidConstraint")
		local partOwner = soundPart and soundPart:FindFirstChild("PartOwner")

		if not (soundPart and holdPart and rigidConstraint) then
			return
		end

		if partOwner and partOwner.Value == LocalPlayer.Name then
			local cFrame

			if index == 1 then
				cFrame = rootPart.CFrame * CFrame.new(-0.4, 0.3, -0.55)
			elseif index == 2 then
				cFrame = rootPart.CFrame * CFrame.new(0.4, 0.3, -0.55)
			elseif index == 3 then
				cFrame = rootPart.CFrame * CFrame.new(-0.35, -1.1, 0.45)
			else
				cFrame = rootPart.CFrame * CFrame.new(0.35, -1.1, 0.45)
			end

			soundPart.CFrame = cFrame
			soundPart.Velocity = Vector3.zero
		else
			ReplicatedStorage.GrabEvents.SetNetworkOwner:FireServer(soundPart, soundPart.CFrame)
		end

		if rigidConstraint.Attachment1 then
			ReplicatedStorage.MenuToys.DestroyToy:FireServer(toy)
		end

		for _, child in ipairs(toy:GetChildren()) do
			if child:IsA("BasePart") then
				child.CanCollide = false
				child.CanQuery = false

				if child.Transparency ~= 1 then
					child.Transparency = 0
				end
			end
		end
	end

	coconutBox:AddToggle("CoconutPenis", {
		Text = "Coconut Penis",
		Tooltip = "Makes a dick out of coconuts",
		Default = false,
		Callback = function(enabled)
			if enabled then
				task.spawn(function()
					local setNetworkOwner = ReplicatedStorage.GrabEvents.SetNetworkOwner
					local spawnToyRemoteFunction = ReplicatedStorage.MenuToys.SpawnToyRemoteFunction
					local destroyToy = ReplicatedStorage.MenuToys.DestroyToy
					local offsets = { CFrame.new(-0.45, -1.2, -0.7), CFrame.new(0.45, -1.2, -0.7), CFrame.new(0, -1, 0.8) }

					while Toggles.CoconutPenis.Value do
						local character = LocalPlayer.Character
						local rootPart = character and character:FindFirstChild("HumanoidRootPart")

						if not rootPart then
							task.wait(0.1)
						else
							local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

							if not toys then
								task.wait(0.1)
							else
								local coconuts = {}

								for _, child in ipairs(toys:GetChildren()) do
									if child.Name == "FoodCoconut" then
										table.insert(coconuts, child)
									end
								end

								if #coconuts < coconutAmount + 2 then
									task.spawn(function()
										spawnToyRemoteFunction:InvokeServer("FoodCoconut", rootPart.CFrame * CFrame.new(-5, 0, 10), Vector3.zero)
									end)
								end

								for i, coconut in ipairs(coconuts) do
									local soundPart = coconut:FindFirstChild("SoundPart")
									local holdPart = coconut:FindFirstChild("HoldPart")
									local rigidConstraint = holdPart and holdPart:FindFirstChild("RigidConstraint")
									local partOwner = soundPart and soundPart:FindFirstChild("PartOwner")

									if soundPart and holdPart and rigidConstraint then
										if partOwner and partOwner.Value == LocalPlayer.Name then
											if i <= 2 then
												soundPart.CFrame = rootPart.CFrame * offsets[i] * CFrame.new(rootPart.Velocity / coconutDamping)
											else
												soundPart.CFrame = rootPart.CFrame * offsets[3] * CFrame.new(rootPart.Velocity / coconutDamping) * CFrame.new(0, 0, offsets[3].Z - i + 0.2)
											end

											soundPart.Velocity = Vector3.zero
										else
											setNetworkOwner:FireServer(soundPart, soundPart.CFrame)
										end

										if rigidConstraint.Attachment1 then
											destroyToy:FireServer(coconut)
										end

										for _, child in ipairs(coconut:GetChildren()) do
											if child:IsA("BasePart") then
												child.CanCollide = false
												child.CanQuery = false

												if child.Transparency ~= 1 then
													child.Transparency = 0
												end
											end
										end
									end
								end

								task.wait(0.01)
							end
						end
					end
				end)
			end
		end,
	})

	coconutBox:AddToggle("CoconutBody", {
		Text = "Coconut Boobs and Ass",
		Tooltip = "Places coconuts on your chest and ass",
		Default = false,
		Callback = function(enabled)
			if enabled then
				task.spawn(function()
					while Toggles.CoconutBody.Value do
						local character = LocalPlayer.Character
						local rootPart = character and character:FindFirstChild("HumanoidRootPart")

						if not rootPart then
							task.wait(0.1)
						else
							local toys = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")

							if not toys then
								task.wait(0.1)
							else
								local coconuts = {}

								for _, child in ipairs(toys:GetChildren()) do
									if child.Name == "FoodCoconut" then
										table.insert(coconuts, child)
									end
								end

								if #coconuts < 4 then
									for i = 1, 4 - #coconuts do
										task.spawn(function()
											ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("FoodCoconut", rootPart.CFrame * CFrame.new(-5, 0, 10), Vector3.zero)
										end)
									end
								end

								for i = 1, math.min(4, #coconuts) do
									pinCoconutBody(coconuts[i], i, rootPart)
								end

								task.wait(0.01)
							end
						end
					end
				end)
			end
		end,
	})

	coconutBox:AddSlider("CoconutAmount", {
		Text = "Coconut Amount",
		Default = 10,
		Min = 3,
		Max = 25,
		Rounding = 0,
		Callback = function(value)
			coconutAmount = value
		end,
	})

	coconutBox:AddSlider("CoconutDamping", {
		Text = "Damping",
		Default = 100,
		Min = 1,
		Max = 500,
		Rounding = 0,
		Callback = function(value)
			coconutDamping = value
		end,
	})
end

do
	local cameraBox = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "Camera" })

	cameraBox:AddSlider("FOV", {
		Text = "Field of view",
		Default = Camera.FieldOfView,
		Min = 30,
		Max = 120,
		Rounding = 0,
		Callback = function(value)
			pcall(function()
				Camera.FieldOfView = value
			end)
		end,
	})

	cameraBox:AddToggle("ThirdPerson", {
		Text = "Third person",
		Default = false,
		Callback = function(enabled)
			if enabled then
				LocalPlayer.CameraMode = Enum.CameraMode.Classic
				LocalPlayer.CameraMaxZoomDistance = 1000
				LocalPlayer.CameraMinZoomDistance = 0.5
			else
				LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
				LocalPlayer.CameraMaxZoomDistance = 0.5
				LocalPlayer.CameraMinZoomDistance = 0.5
			end
		end,
	})

	local timeBox = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "Time" })

	timeBox:AddSlider("TimeOfDay", {
		Text = "Time of day",
		Default = math.floor(Lighting.ClockTime),
		Min = 0,
		Max = 24,
		Rounding = 0,
		Callback = function(value)
			pcall(function()
				Lighting.ClockTime = value
			end)
		end,
	})

	local skyBox = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "Skybox" })

	skyBox:AddToggle("CustomSky", {
		Text = "Custom Skybox",
		Default = false,
		Callback = function(enabled)
			if enabled then
				ApplySkybox(State.refs.currentSkybox or "HD")
				Library:Notify({ Title = "Rose", Description = "Skybox ON", Time = 2 })
			else
				RestoreSkybox()
				Library:Notify({ Title = "Rose", Description = "Skybox OFF", Time = 2 })
			end
		end,
	})

	skyBox:AddDropdown("SkyPreset", {
		Values = {
			"HD",
			"Black Storm",
			"Snow",
			"Blue Space",
			"Realistic",
			"Sunset",
			"Space",
			"Pink",
			"Galaxy",
			"Roblox Default",
		},
		Default = "HD",
		Text = "Select skybox",
		Callback = function(presetName)
			ApplySkybox(presetName)
		end,
	})

	local blackholeBox = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "Blackhole" })

	blackholeBox:AddToggle("CustomBlackhole", {
		Text = "Custom Blackhole",
		Default = false,
		Callback = function(enabled)
			State.flags.customBlackhole = enabled

			if enabled then
				State.refs.currentBlackhole = State.refs.currentBlackhole or "Gargantua"
				WatchBlackholes()
				Library:Notify({ Title = "Rose", Description = "Blackhole ON", Time = 2 })
			else
				StopWatchBlackholes()
				RestoreBlackholeTextures()
				Library:Notify({ Title = "Rose", Description = "Blackhole OFF", Time = 2 })
			end
		end,
	})

	blackholeBox:AddDropdown("BlackholePreset", {
		Values = { "Gargantua", "Dark blue", "Canopus", "light blue", "white", "Galaxy" },
		Default = "Gargantua",
		Text = "Select blackhole",
		Callback = function(presetName)
			State.refs.currentBlackhole = presetName

			if State.flags.customBlackhole then
				local texture = BlackholeTextures[presetName]

				if texture then
					for _, descendant in ipairs(workspace:GetDescendants()) do
						if IsBlackholeName(descendant.Name) then
							pcall(function()
								ApplyBlackholeTexture(descendant, texture)
							end)
						end
					end
				end
			end
		end,
	})

	local shaderBox = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "Shaders" })

	shaderBox:AddToggle("Shaders", {
		Text = "Shaders",
		Default = false,
		Callback = function(enabled)
			if enabled then
				ApplyShader(State.refs.currentShaderTheme or "Ночь")
				Library:Notify({ Title = "Rose", Description = "Shaders ON", Time = 2 })
			else
				RestoreShader()
				Library:Notify({ Title = "Rose", Description = "Shaders OFF", Time = 2 })
			end

			State.flags.shaders = enabled
		end,
	})

	shaderBox:AddDropdown("ShaderTheme", {
		Values = { "Ночь", "Вечер", "Неон", "Холодный", "Тёплый" },
		Default = "Ночь",
		Text = "Theme",
		Callback = function(themeName)
			if State.flags.shaders then
				ApplyShader(themeName)
			end
		end,
	})

	local effectsBox = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "Effects" })

	effectsBox:AddToggle("JumpCircle", {
		Text = "Jump Circle",
		Default = false,
		Callback = function(enabled)
			State.refs.jumpCircleOn = enabled

			if enabled then
				StartJumpCircle()
				Library:Notify({ Title = "Rose", Description = "Jump Circle ON", Time = 2 })
			else
				StopJumpCircle()
				Library:Notify({ Title = "Rose", Description = "Jump Circle OFF", Time = 2 })
			end
		end,
	})

	effectsBox:AddDropdown("JumpCircleType", {
		Values = { "Ritual 1", "Ritual 2" },
		Default = "Ritual 1",
		Text = "Ritual",
		Callback = function(circleType)
			State.refs.jumpCircleType = circleType
		end,
	})

	local traceBox = Tabs.Visual:AddGroupbox({ Side = "Right", Name = "Trace" })

	traceBox:AddToggle("TraceGlobal", {
		Text = "Trace to Target",
		Default = false,
		Callback = function(enabled)
			State.flags.traceGlobal = enabled

			if enabled then
				State.runtime.traceTarget = State.runtime.target

				if State.runtime.traceTarget and State.runtime.traceTarget ~= "" then
					local traceConn, traceBeam = CreateTraceBeam(State.runtime.traceTarget, function()
						return State.flags.traceGlobal
					end)

					State.runtime.traceConn = traceConn
					State.runtime.traceBeam = traceBeam
				else
					Library:Notify({ Title = "Rose", Description = "Select target first", Time = 3 })
					State.flags.traceGlobal = false
					Toggles.TraceGlobal:SetValue(false)
				end
			else
				if State.runtime.traceConn then
					State.runtime.traceConn:Disconnect()
					State.runtime.traceConn = nil
				end

				if State.runtime.traceBeam then
					State.runtime.traceBeam:Destroy()
					State.runtime.traceBeam = nil
				end
			end
		end,
	})

	local espBox = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "ESP" })

	espBox:AddToggle("PCLDEsp", {
		Text = "PCLD ESP",
		Default = false,
		Callback = function(enabled)
			State.runtime.espOn = enabled

			if enabled then
				workspace.DescendantAdded:Connect(function(descendant)
					if State.runtime.espOn and IsEspTarget(descendant) then
						AddEspBox(descendant)
					end
				end)

				RefreshEspBoxes()
			else
				ClearEspBoxes()
			end
		end,
	})

	local nameEspRunning = false
	local nameEspLabels = {}

	espBox:AddToggle("NameEsp", {
		Text = "Name ESP",
		Default = false,
		Callback = function(enabled)
			nameEspRunning = enabled

			local function addLabel(player)
				if player == LocalPlayer or not player.Character then
					return
				end

				local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if not rootPart or nameEspLabels[player] then
					return
				end

				local billboard = Instance.new("BillboardGui", rootPart)
				billboard.Size = UDim2.new(0, 180, 0, 32)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				billboard.Adornee = rootPart

				local label = Instance.new("TextLabel", billboard)
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = player.DisplayName
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextStrokeTransparency = 1
				label.TextSize = 14
				label.Font = Enum.Font.GothamBold
				nameEspLabels[player] = billboard
			end

			if enabled then
				for _, player in ipairs(Players:GetPlayers()) do
					addLabel(player)
				end

				Players.PlayerAdded:Connect(function(player)
					player.CharacterAdded:Connect(function()
						task.wait(0.5)

						if nameEspRunning then
							addLabel(player)
						end
					end)
				end)
			else
				for _, billboard in pairs(nameEspLabels) do
					pcall(function()
						billboard:Destroy()
					end)
				end

				nameEspLabels = {}
			end
		end,
	})

	local notifyBox = Tabs.Visual:AddGroupbox({ Side = "Left", Name = "Notifications" })

	notifyBox:AddToggle("PacketNotify", {
		Text = "Packet Lag Notify",
		Default = true,
		Callback = function(enabled)
			State.runtime.pktNotify = enabled

			if enabled and not State.runtime.pktCooldown then
				pcall(WatchPacketNotify)
			end
		end,
	})

	notifyBox:AddToggle("VisualLeaveJoinNotify", {
		Text = "Leave/Join Notify (Target)",
		Default = false,
		Callback = function(enabled)
			if enabled then
				local target = State.runtime.target

				if not target or target == "" then
					Library:Notify({ Title = "Rose", Description = "Select target in Target tab first", Time = 3 })

					if Toggles.VisualLeaveJoinNotify then
						Toggles.VisualLeaveJoinNotify:SetValue(false)
					end

					return
				end

				local player = Players:FindFirstChild(target)

				if player then
					Library:Notify({ Title = "Rose", Description = player.DisplayName .. " is in game", Time = 3 })
				end

				State.runtime.notifyConns.visualAdd = Players.PlayerAdded:Connect(function(joined)
					if joined.Name == State.runtime.target then
						Library:Notify({ Title = "Rose", Description = joined.DisplayName .. " joined", Time = 3 })
					end
				end)

				State.runtime.notifyConns.visualRem = Players.PlayerRemoving:Connect(function(left)
					if left.Name == State.runtime.target then
						Library:Notify({ Title = "Rose", Description = left.DisplayName .. " left", Time = 3 })
					end
				end)
			else
				if State.runtime.notifyConns.visualAdd then
					State.runtime.notifyConns.visualAdd:Disconnect()
					State.runtime.notifyConns.visualAdd = nil
				end

				if State.runtime.notifyConns.visualRem then
					State.runtime.notifyConns.visualRem:Disconnect()
					State.runtime.notifyConns.visualRem = nil
				end
			end
		end,
	})
end

do
	-- Custom tab (from Endoris + Vovange)
	local kunaiGui = nil
	local kunaiLabel = nil
	local function ensureKunaiGui()
		if kunaiGui then return end
		kunaiGui = Instance.new("ScreenGui")
		kunaiGui.Name = "KunaiMessageGui"
		kunaiGui.ResetOnSpawn = false
		kunaiGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		kunaiLabel = Instance.new("TextLabel")
		kunaiLabel.Size = UDim2.new(0, 480, 0, 38)
		kunaiLabel.Position = UDim2.new(0, 16, 1, -60)
		kunaiLabel.AnchorPoint = Vector2.new(0, 1)
		kunaiLabel.BackgroundTransparency = 1
		kunaiLabel.TextColor3 = Color3.fromRGB(255, 240, 120)
		kunaiLabel.Font = Enum.Font.Code
		kunaiLabel.TextSize = 18
		kunaiLabel.TextXAlignment = Enum.TextXAlignment.Left
		kunaiLabel.TextTransparency = 1
		kunaiLabel.RichText = true
		kunaiLabel.Parent = kunaiGui
	end
	local function typeKunaiMessage(msg, charDelay)
		charDelay = charDelay or 0.038
		ensureKunaiGui()
		kunaiLabel.Text = ""
		local tw = TweenService:Create(kunaiLabel, TweenInfo.new(0.3, Enum.EasingStyle.Linear), { TextTransparency = 0 })
		tw:Play()
		task.spawn(function()
			for i = 1, #msg do
				kunaiLabel.Text = msg:sub(1, i)
				task.wait(charDelay)
			end
			task.wait(2.5)
			TweenService:Create(kunaiLabel, TweenInfo.new(0.6, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
		end)
	end

	local customBox = Tabs.Custom:AddGroupbox({ Side = "Left", Name = "Kunai Message (Endoris)" })
	customBox:AddInput("KunaiMsg", { Default = "Hello from Rose!", Text = "Message", Placeholder = "Type message...", Callback = function() end })
	customBox:AddButton({ Text = "Show Kunai Message", Func = function()
		local msg = Options.KunaiMsg and Options.KunaiMsg.Value or "Hello from Rose!"
		typeKunaiMessage(msg, 0.038)
	end })

	local assetBox = Tabs.Custom:AddGroupbox({ Side = "Right", Name = "Custom Assets (Vovange)" })
	assetBox:AddLabel("Helpers: safeGetCustomAsset, safeMakeFolder")
	assetBox:AddButton({ Text = "Make folder 'RoseAssets'", Func = function()
		if makefolder and not isfolder("RoseAssets") then makefolder("RoseAssets") end
		Library:Notify({ Title = "Rose", Description = "Folder ready", Time = 2 })
	end })
end

do
	local menuBox = Tabs["UI Settings"]:AddGroupbox({ Side = "Left", Name = "Menu" })

	menuBox:AddButton({
		Text = "Diagnose GrabEvents",
		Func = function()
			local ge = ReplicatedStorage:FindFirstChild("GrabEvents")
			if not ge then Library:Notify({ Title = "Rose", Description = "GrabEvents NOT FOUND", Time = 3 }); return end
			local names = {}
			for _, c in ipairs(ge:GetChildren()) do table.insert(names, c.Name .. " (" .. c.ClassName .. ")") end
			Library:Notify({ Title = "Rose", Description = table.concat(names, ", "), Time = 10 })
			print("[Rose Diagnose] GrabEvents:")
			for _, n in ipairs(names) do print("  " .. n) end
		end,
	})

	menuBox:AddButton({
		Text = "Unload",
		Func = function()
			Library:Unload()
		end,
	})

	menuBox:AddToggle("KeybindMenuOpen", {
		Default = Library.KeybindFrame.Visible,
		Text = "Open Keybind Menu",
		Callback = function(visible)
			Library.KeybindFrame.Visible = visible
		end,
	})

	menuBox:AddToggle("ShowCustomCursor", {
		Text = "Custom Cursor",
		Default = Library.ShowCustomCursor,
		Callback = function(showCustomCursor)
			Library.ShowCustomCursor = showCustomCursor
		end,
	})

	menuBox:AddToggle("AlwaysOnTop", {
		Text = "Always On Top",
		Default = Window.AlwaysOnTop,
		Callback = function(value)
			Window:SetAlwaysOnTop(value)
		end,
	})

	menuBox:AddDropdown("NotificationSide", {
		Values = { "Left", "Right" },
		Default = "Right",
		Text = "Notification Side",
		Callback = function(side)
			Library:SetNotifySide(side)
		end,
	})

	menuBox:AddDropdown("DPIDropdown", {
		Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
		Default = "100%",
		Text = "DPI Scale",
		Callback = function(value)
			Library:SetDPIScale(tonumber(value:gsub("%%", "")))
		end,
	})

	menuBox:AddSlider("UICornerSlider", {
		Text = "Corner Radius",
		Default = 20,
		Min = 0,
		Max = 20,
		Rounding = 0,
		Callback = function(value)
			Window:SetCornerRadius(value)
		end,
	})

	menuBox:AddDivider()
	menuBox:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
end

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("SunapseHub")
SaveManager:SetFolder("SunapseHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Window:SetCornerRadius(20)

task.spawn(function()
	task.wait(0.3)
	pcall(WatchPacketNotify)

	workspace.ChildAdded:Connect(function(child)
		if not child.Name or not BlackholeNames[child.Name:lower()] then
			return
		end

		task.wait(0.1)

		local position
		if child:IsA("BasePart") then
			position = child.Position
		else
			local basePart = child:FindFirstChildWhichIsA("BasePart", true)
			position = basePart and basePart.Position
		end

		if not position then
			return
		end

		local nearestPlayer = GetNearestPlayer(position)

		if nearestPlayer and nearestPlayer ~= LocalPlayer then
			Library:Notify({ Title = "Rose", Description = nearestPlayer.DisplayName .. " got kicked!", Time = 3 })
		elseif nearestPlayer == LocalPlayer then
			Library:Notify({ Title = "Rose", Description = "You got kicked!", Time = 3 })
		else
			Library:Notify({ Title = "Rose", Description = "Someone got kicked!", Time = 3 })
		end
	end)
end)

print("[Rose] v1.1 loaded — rose.lol")
