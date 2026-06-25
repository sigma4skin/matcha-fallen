local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Flags = {}

Flags.AimbotTargetPart = "Head"
Flags.AimbotFovRadius = 50
Flags.AimbotMaxDistance = 1000
Flags.ModCheckerBehavior = "Notify"
Flags.LootEspDistance = 500
Flags.NodeEspDistance = 500
Flags.MiniEspDistance = 500
Flags.PlantEspDistance = 500
Flags.RaidEspDistance = 2000

local BulletInfo = {
	["Pumpkin Launcher"] = { Speed = 80, Gravity = 0.16 },
	["Military M4A1"] = { Speed = 2100, Gravity = 0.55 },
	["Salvaged AK74u"] = { Speed = 1800, Gravity = 0.6 },
	["Nail Gun"] = { Speed = 165, Gravity = 0.25 },
	["Salvaged RPG"] = { Speed = 100, Gravity = 0.12 },
	["Salvaged Python"] = { Speed = 1800, Gravity = 0.6 },
	["Salvaged M14"] = { Speed = 2100, Gravity = 0.55 },
	["Salvaged SMG"] = { Speed = 1800, Gravity = 0.6 },
	["Salvaged P250"] = { Speed = 1400, Gravity = 0.6 },
	["Salvaged Sniper"] = { Speed = 2400, Gravity = 0.55 },
	["Wooden Bow"] = { Speed = 320, Gravity = 0.2 },
	["Salvaged Pipe Rifle"] = { Speed = 1700, Gravity = 0.6 },
	["Salvaged AK47"] = { Speed = 2100, Gravity = 0.55 },
	["Crossbow"] = { Speed = 420, Gravity = 0.2 },
	["Salvaged Pump Action"] = { Speed = 650, Gravity = 0.6 },
	["Military AA12"] = { Speed = 600, Gravity = 0.6 },
	["Salvaged Skorpion"] = { Speed = 1600, Gravity = 0.6 },
	["Military Barrett"] = { Speed = 2500, Gravity = 0.55 },
	["Military PKM"] = { Speed = 2400, Gravity = 0.55 },
	["Bruno's M4A1"] = { Speed = 2100, Gravity = 0.55 },
	["Military MP7"] = { Speed = 1900, Gravity = 0.6 },
	["Military USP"] = { Speed = 1500, Gravity = 0.6 },
	["Salvaged Shotgun"] = { Speed = 400, Gravity = 0.6 },
	["Salvaged Break Action"] = { Speed = 550, Gravity = 0.6 },
	["Military Grenade Launcher"] = { Speed = 85, Gravity = 0.15 },
	["Salvaged Grenade Launcher"] = { Speed = 85, Gravity = 0.15 },
	["Salvaged Double Barrel"] = { Speed = 550, Gravity = 0.6 },
	["Military M39"] = { Speed = 2400, Gravity = 0.52 },
}

local ModeratorIDs = {
	[51281722] = "Game Moderator", -- KittenBagelz
	[7178750309] = "Game Moderator", -- Rikumah
	[113179883] = "Game Moderator", -- DopeIlI
	[3122439095] = "Game Moderator", -- chancerocke
	[991290934] = "Game Moderator", -- Lexi34567812
	[3968854760] = "Game Moderator", -- puferyba
	[81993536] = "Game Moderator", -- aidenas2011
	[1004214871] = "Game Moderator", -- owner12310
	[3034930770] = "Game Moderator", -- Fan_hellrider
	[2364950171] = "Game Moderator", -- ilovetowerbattle_9
	[1528346843] = "Game Moderator", -- Hsixienn
	[165053216] = "Game Moderator", -- coolboyofawsome4
	[1127954045] = "Game Moderator", -- Kitty_1624
	[3640120679] = "Game Moderator", -- GamerMauriiYT
	[602009251] = "Game Moderator", -- Bajoogies_XD
	[372791101] = "Game Moderator", -- Xion_Light
	[1378169111] = "Game Moderator", -- Kaz_Elite
	[3020799797] = "Game Moderator", -- hello_myfriends45
	[2567998467] = "Game Moderator", -- joax009617
	[4243907215] = "Game Moderator", -- AaronElagant
	[353983652] = "Game Moderator", -- Puhgee
	[1406181681] = "Game Moderator", -- roblox_23193
	[2229169589] = "Game Moderator", -- fearedbyvamp
	[3004094651] = "Game Moderator", -- harrib_allsack54321
	[839333692] = "Game Moderator", -- Matheus06532
	[979624578] = "Game Moderator", -- B_BEAMO
	[1478885961] = "Game Moderator", -- fordjdj12
	[399754916] = "Game Moderator", -- sirfluf
	[1193091081] = "Game Moderator", -- Weerdeeg
	[4553863490] = "Game Moderator", -- giovannirv2
	[4225513035] = "Game Moderator", -- Waitwhatb40
	[41482597] = "Game Moderator", -- kerub131
	[2924549627] = "Game Moderator", -- rashhhh2
	[2732967856] = "Game Moderator", -- DontTouchZGrass
	[1937516999] = "Game Moderator", -- matheu09173
	[1374319325] = "Game Moderator", -- jostjohnyca
	[1058831985] = "Game Moderator", -- krisidisi23
	[9621064456] = "Game Moderator", -- MetaSile
	[584370127] = "Game Moderator", -- 1Newy1
	[813030262] = "Game Moderator", -- Prye4
	[3470393585] = "Game Moderator", -- k6ppo
	[122915793] = "Game Moderator", -- LionTooth99999
	[1534692727] = "Game Moderator", -- LUKASAJs
	[7278178099] = "Game Moderator", -- thecarrotman513
	[8593140875] = "Game Moderator", -- HurbertTheP3r73rt
	[2525997354] = "Game Moderator", -- BlackWhiteYT11
	[3126891654] = "Game Moderator", -- v6xzt
	[1190967808] = "Game Moderator", -- djvdhshscshs
	[833946684] = "Game Moderator", -- GamerGubbi
	[202751467] = "Game Moderator", -- lumbers2
	[510349404] = "Game Moderator", -- Kristian4209
	[174212818] = "Contribution", -- YTGonzo
	[25548179] = "Lead Developer", -- AsianAbrex
	[363101315] = "Lead Developer", -- Warm_Vibes
	[47983795] = "Co-Founder", -- ChickenBagelz
	[16681869] = "Founder", -- neddleduck
}

local SoundIds = {
	["Neverlose"] = 6607204501,
}

local function LoadOffsets()
	local Success, Response = pcall(function()
		return game:HttpGet("https://offsets.imtheo.lol/Offsets.json")
	end)

	if not Success then
		warn("Failed to grab offsets.")
		return nil
	end

	local Decoded = HttpService:JSONDecode(Response)

	if Decoded and Decoded.Offsets then
		return Decoded.Offsets
	end

	return nil
end

local Offsets = LoadOffsets()

if not Offsets then
	warn("Failed to load offsets.")
end

-- gun mods
local Cache = getgc({ "RecoilMult", "RangeMult", "SpeedMult", "AimSpreadMult", "HipSpreadMult" })

local function EnableNoRecoil()
	applygc(Cache, "RecoilMult", -1)
end

local function DisableNoRecoil()
	applygc(Cache, "RecoilMult", 1)
end

local function EnableExtendRange()
	applygc(Cache, "RangeMult", 10)
end

local function DisableExtendRange()
	applygc(Cache, "RangeMult", 1)
end

local function EnableNoSpread()
	applygc(Cache, "AimSpreadMult", -1)
	applygc(Cache, "HipSpreadMult", -1)
end

local function DisableNoSpread()
	applygc(Cache, "AimSpreadMult", 1)
	applygc(Cache, "HipSpreadMult", 1)
end
-- end of gun mods

-- helper functions
local function ResolveTargetPart(Character, Head, HumanoidRootPart)
	local Mouse = LocalPlayer:GetMouse()
	local MousePos = Vector2.new(Mouse.X, Mouse.Y)
	local TargetPartName = Flags.AimbotTargetPart

	if TargetPartName == "Humanoid Root Part" then
		return HumanoidRootPart or Head
	elseif TargetPartName == "Closest" then
		local ClosestPartDist = math.huge
		local ClosestPart = Head
		for _, Part in Character:GetChildren() do
			if not Part:IsA("BasePart") then
				continue
			end

			if not Part.Position then
				continue
			end

			local PartScreen, PartOnScreen = WorldToScreen(Part.Position)
			if not PartOnScreen then
				continue
			end

			local dx = PartScreen.X - MousePos.X
			local dy = PartScreen.Y - MousePos.Y
			local PartDist = math.sqrt(dx * dx + dy * dy)

			if PartDist < ClosestPartDist then
				ClosestPartDist = PartDist
				ClosestPart = Part
			end
		end
		return ClosestPart
	else
		return Head
	end
end

local function FindClosestViableTarget()
	local ClosestTarget
	local ClosestDistance = math.huge
	local Mouse = LocalPlayer:GetMouse()
	local MousePos = Vector2.new(Mouse.X, Mouse.Y)
	local LocalChar = LocalPlayer.Character
	if not LocalChar then
		return
	end

	local LocalRoot = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")

	for _, Player in Players:GetPlayers() do
		if Player.Name == LocalPlayer.Name then -- if your looking at this i compare names not because its vibe coded but because matcha is shit and comparing 2 players always returns false
			continue
		end

		-- team check
		if Player.Team == LocalPlayer.Team then
			continue
		end

		local Char = Player.Character
		if not Char then
			continue
		end

		local Head = Char:FindFirstChild("Head")
		if not Head then
			continue
		end

		local Humanoid = Char:FindFirstChild("Humanoid")
		if not Humanoid then
			continue
		end

		if Humanoid.Health <= 0 then
			continue
		end

		local HumanoidRootPart = Char:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			continue
		end

		if Flags.SafezoneCheck then
			local Success, Value = pcall(function()
				return Player:GetAttribute("SafeZone")
			end)
			if not Success then
				continue
			end

			if Value then
				continue
			end
		end

		local TargetPart = ResolveTargetPart(Char, Head, HumanoidRootPart)
		if not TargetPart then
			continue
		end

		-- distance check
		if LocalRoot and (LocalRoot.Position - TargetPart.Position).Magnitude > Flags.AimbotMaxDistance then
			continue
		end

		local ScreenPos, OnScreen = WorldToScreen(TargetPart.Position)
		if not OnScreen then
			continue
		end

		local dx = ScreenPos.X - MousePos.X
		local dy = ScreenPos.Y - MousePos.Y
		local Distance = math.sqrt(dx * dx + dy * dy)
		if Flags.AimbotFovCheck and Distance > (Flags.AimbotFovRadius or 50) then
			continue
		end

		if Distance < ClosestDistance then
			ClosestDistance = Distance
			ClosestTarget = {
				Player = Player,
				Character = Char,
				Head = Head,
				HumanoidRootPart = HumanoidRootPart,
				Humanoid = Humanoid,
				TargetPart = TargetPart,
				ScreenDistance = Distance,
				ScreenPos = Vector2.new(ScreenPos.X, ScreenPos.Y),
			}
		end
	end

	return ClosestTarget
end

local function GetHeldWeapon(Char)
	if not Char then
		return "None"
	end

	for _, Model in Char:GetChildren() do
		if not Model:IsA("Model") then
			continue
		end
		if Model.Name == "Hair" or Model.Name == "HolsterModel" then
			continue
		end

		if
			Model:FindFirstChild("Detail")
			or Model:FindFirstChild("Main")
			or Model:FindFirstChild("Handle")
			or Model:FindFirstChild("Attachments")
			or Model:FindFirstChild("ArrowAttach")
			or Model:FindFirstChild("Attach")
		then
			return Model.Name
		end
	end
	return "None"
end

local function GetBulletInfo(WeaponName)
	if not WeaponName then
		return nil
	end
	return BulletInfo[WeaponName]
end

local function CalculateDrop(BulletSpeed, BulletGravity, Position, Origin)
	local Distance = (Origin - Position).Magnitude
	local TimeToHit = Distance / BulletSpeed
	local G = BulletGravity * -195
	local Drop = -0.5 * G * TimeToHit * TimeToHit
	if tostring(Drop):find("nan") then
		Drop = 0
	end
	return Drop
end

local function CalculateTargetPosition(BulletSpeed, BulletGravity, Velocity, Position, Origin)
	local MovePred = Velocity * ((Origin - Position).Magnitude / BulletSpeed)
	local Drop = CalculateDrop(BulletSpeed, BulletGravity, Position, Origin)
	return Position + Vector3.new(MovePred.X, MovePred.Y, MovePred.Z) + Vector3.new(0, Drop, 0)
end

local function CalculateTargetPositionNoYPred(BulletSpeed, BulletGravity, Velocity, Position, Origin)
	local MovePred = Velocity * ((Origin - Position).Magnitude / BulletSpeed)
	local Drop = CalculateDrop(BulletSpeed, BulletGravity, Position, Origin)
	return Position + Vector3.new(MovePred.X, 0, MovePred.Z) + Vector3.new(0, Drop, 0)
end

local function FindClosestArmorTarget()
	local ClosestTarget
	local ClosestDistance = math.huge
	local Mouse = LocalPlayer:GetMouse()
	local MousePos = Vector2.new(Mouse.X, Mouse.Y)
	local LocalChar = LocalPlayer.Character
	if not LocalChar then
		return nil
	end
	local LocalRoot = LocalChar:FindFirstChild("HumanoidRootPart")

	for _, Player in Players:GetPlayers() do
		if Player.Name == LocalPlayer.Name then
			continue
		end
		if Flags.TeamCheck and Player.Team == LocalPlayer.Team then
			continue
		end

		local Char = Player.Character
		if not Char then
			continue
		end
		local Head = Char:FindFirstChild("Head")
		if not Head then
			continue
		end
		local Humanoid = Char:FindFirstChild("Humanoid")
		if not Humanoid or Humanoid.Health <= 0 then
			continue
		end
		local HRP = Char:FindFirstChild("HumanoidRootPart")
		if not HRP then
			continue
		end

		if LocalRoot and (LocalRoot.Position - HRP.Position).Magnitude > (Flags.AimbotMaxDistance or 1000) then
			continue
		end

		local ScreenPos, OnScreen = WorldToScreen(Head.Position)
		if not OnScreen then
			continue
		end

		local dx = ScreenPos.X - MousePos.X
		local dy = ScreenPos.Y - MousePos.Y
		local Distance = math.sqrt(dx * dx + dy * dy)

		if Distance < ClosestDistance then
			ClosestDistance = Distance
			ClosestTarget = { Player = Player, Character = Char, Humanoid = Humanoid }
		end
	end

	return ClosestTarget
end

local function IsCheater(Player)
	if not Player then
		return false
	end

	local Success, Age = pcall(function()
		return memory_read("int", Player.Address + Offsets.Player.AccountAge)
	end)

	if not Success then
		warn("Failed to read account age")
		return false
	end

	if Age <= 60 then
		return true
	end

	local Char = Player.Character
	if not Char then
		return false
	end

	local Hrp = Char:FindFirstChild("HumanoidRootPart")
	if not Hrp then
		return false
	end

	local Velocity = Hrp.Velocity

	if Velocity.Y <= -1000 or Velocity.Y >= 1000 then
		return true
	end

	return false
end
-- end of helper functions

-- keybinds so i can call isenabled later
local AimbotKeybind

UI.AddTab("Fallen", function(Tab)
	-- combat section
	local Combat = Tab:Section("Combat", "Left", { "Aimbot", "Gun Mods" })

	if Combat.page == 0 then
		-- aimbot
		Combat:Toggle("AimbotOn", "Aimbot", false, function(Bool)
			Flags.Aimbot = Bool
		end)
		AimbotKeybind = Combat:Keybind("AimbotKeybind", Enum.KeyCode.MouseButton2, "hold")
		AimbotKeybind:AddToHotkey("Aimbot", "AimbotOn")
		Combat:Toggle("AutoPrediction", "Auto Prediction", false, function(Bool)
			Flags.AutoPrediction = Bool
		end)
		Combat:Tip("Auto Prediction automatically adjusts prediction on velocity and held weapon.")
		Combat:Combo("TargetPart", "Target Part", { "Head", "Humanoid Root Part", "Closest" }, 0, function(Idx, Text)
			Flags.AimbotTargetPart = Text
		end)
		Combat:SliderInt("AimbotMaxDistance", "Max Distance", 50, 1500, 1000, function(V)
			Flags.AimbotMaxDistance = V
		end)
		Combat:Toggle("TeamCheck", "Team Check", false, function(Bool)
			Flags.TeamCheck = Bool
		end)
		Combat:Toggle("SafezoneCheck", "Safezone Check", false, function(Bool)
			Flags.SafezoneCheck = Bool
		end)
		Combat:Toggle("FovCheck", "FOV Check", false, function(Bool)
			Flags.AimbotFovCheck = Bool
		end)
		Combat:SliderInt("FovCheckRadius", "FOV Radius", 10, 250, 50, function(V)
			Flags.AimbotFovRadius = V
		end)
		Combat:Toggle("Snapline", "Snapline", false, function(Bool)
			Flags.Snapline = Bool
		end)
	elseif Combat.page == 1 then
		-- gun mods
		Combat:Toggle("NoRecoil", "No Recoil", false, function(Bool)
			if Bool then
				EnableNoRecoil()
			else
				DisableNoRecoil()
			end
		end)
		Combat:Toggle("ExtendRange", "Extend Range", false, function(Bool)
			if Bool then
				EnableExtendRange()
			else
				DisableExtendRange()
			end
		end)
		Combat:Toggle("NoSpread", "No Spread", false, function(Bool)
			if Bool then
				EnableNoSpread()
			else
				DisableNoSpread()
			end
		end)
	end

	-- visuals section
	local Visuals = Tab:Section("Visuals", "Right", { "Player", "AI" })

	if Visuals.page == 0 then
		Visuals:Toggle("ArmorViewer", "Armor Viewer", false, function(Bool)
			Flags.ArmorViewer = Bool
		end)
		Visuals:Toggle("CheaterDetector", "Cheater Detector", false, function(Bool)
			Flags.CheaterDetector = Bool
		end)
		Visuals:Tip("Detects unusual velocities and new accounts.")
	elseif Visuals.page == 1 then
		-- todo later maybe if matcha doesnt piss me off that much
	end

	-- movement section
	local Movement = Tab:Section("Movement", "Right", { "Movement", "Noclip" })
	if Movement.page == 0 then
		Movement:Toggle("BHop", "Bunny Hop", false, function(Bool)
			Flags.BHop = Bool
		end)
	elseif Movement.page == 1 then
		Movement:Toggle("CardNoclip", "Card Noclip", false, function(Bool)
			Flags.CardNoclip = Bool

			for _, Part in workspace.RocketFactoryPinkCardInvisWalls:GetChildren() do
				Part.CanCollide = not Bool
			end

			for _, Part in workspace.Monuments:GetDescendants() do
				if Part:IsA("MeshPart") and Part.Name:find("FallenShippingContainer") then
					Part.CanCollide = not Bool
				end
			end
		end)
		Movement:Tip(
			"Only allows you to Noclip through shipping containers and invisible walls at Rocket Factory Pink Card."
		)
	end

	-- misc section
	local Misc = Tab:Section("Misc", "Left", { "Mod Checker" })

	if Misc.page == 0 then
		Misc:Toggle("ModChecker", "Mod Checker", false, function(Bool)
			Flags.ModChecker = Bool
		end)
		Misc:Tip("Kick Behavior will crash your roblox!")
		Misc:Combo("ModCheckerBehavior", "Mod Checker Behavior", { "Notify", "Kick" }, 0, function(Idx, Text)
			Flags.ModCheckerBehavior = Text
		end)
	end

	-- misc esp section
	local MiscEsp = Tab:Section("Misc ESP", "Right", { "Loot", "Nodes", "Plants", "Misc" })

	if MiscEsp.page == 0 then
		MiscEsp:Toggle("DropsEsp", "Dropped Items", false, function(Bool)
			Flags.DropsEsp = Bool
		end)
		MiscEsp:Toggle("BodybagEsp", "Bodybag", false, function(Bool)
			Flags.BodybagEsp = Bool
		end)
		MiscEsp:SliderInt("LootEspDistance", "Distance", 100, 1500, 500, function(V)
			Flags.LootEspDistance = V
		end)
	elseif MiscEsp.page == 1 then
		MiscEsp:Toggle("StoneEsp", "Stone ESP", false, function(Bool)
			Flags.StoneEsp = Bool
		end)
		MiscEsp:Toggle("MetalEsp", "Metal ESP", false, function(Bool)
			Flags.MetalEsp = Bool
		end)
		MiscEsp:Toggle("PhosphateEsp", "Phosphate ESP", false, function(Bool)
			Flags.PhosphateEsp = Bool
		end)
		MiscEsp:SliderInt("NodeEspDistance", "Distance", 100, 1500, 500, function(V)
			Flags.NodeEspDistance = V
		end)
	elseif MiscEsp.page == 2 then
		-- plant shi (only doing wool, tomato, pumpkin, corn)
		MiscEsp:Toggle("WoolEsp", "Wool ESP", false, function(Bool)
			Flags.WoolEsp = Bool
		end)
		MiscEsp:Toggle("TomatoEsp", "Tomato ESP", false, function(Bool)
			Flags.TomatoEsp = Bool
		end)
		MiscEsp:Toggle("PumpkinEsp", "Pumpkin ESP", false, function(Bool)
			Flags.PumpkinEsp = Bool
		end)
		MiscEsp:Toggle("CornEsp", "Corn ESP", false, function(Bool)
			Flags.CornEsp = Bool
		end)
		MiscEsp:SliderInt("PlantEspDistance", "Distance", 100, 1500, 500, function(V)
			Flags.PlantEspDistance = V
		end)
	elseif MiscEsp.page == 3 then
		MiscEsp:Toggle("MiniEsp", "Minicopter ESP", false, function(Bool)
			Flags.MiniEsp = Bool
		end)
		MiscEsp:SliderInt("MiniEspDistance", "Minicopter Distance", 100, 1500, 500, function(V)
			Flags.MiniEspDistance = V
		end)
		MiscEsp:Toggle("RaidEsp", "Raid ESP", false, function(Bool)
			Flags.RaidEsp = Bool
		end)
		MiscEsp:SliderInt("RaidEspDistance", "Raid Distance", 500, 5000, 2000, function(V)
			Flags.RaidEspDistance = V
		end)
	end
end)
-- end of ui

do
	RunService.Heartbeat:Connect(function(Dt) -- targetting loop
		local Camera = Workspace.CurrentCamera
		local Char = LocalPlayer.Character
		if not Char then
			return
		end

		if Flags.Aimbot and AimbotKeybind:IsEnabled() then
			if not Flags.LockedTarget or not Flags.LockedTarget.Humanoid or Flags.LockedTarget.Humanoid.Health <= 0 then
				Flags.LockedTarget = FindClosestViableTarget()
			end

			if not Flags.LockedTarget or not Flags.LockedTarget.TargetPart then
				return
			end

			local TargetPos = Flags.LockedTarget.TargetPart.Position
			local HeldWeapon = GetHeldWeapon(Char)
			local Info = GetBulletInfo(HeldWeapon)
			if not Info or not Flags.AutoPrediction then
				Camera.lookAt(Camera.Position, Flags.LockedTarget.TargetPart.Position)
				return
			end

			if HeldWeapon == "Wooden Bow" or HeldWeapon == "Crossbow" then
				TargetPos = CalculateTargetPositionNoYPred(
					Info.Speed,
					Info.Gravity,
					Flags.LockedTarget.TargetPart.Velocity,
					Flags.LockedTarget.TargetPart.Position,
					Camera.Position
				)
			else
				TargetPos = CalculateTargetPosition(
					Info.Speed,
					Info.Gravity,
					Flags.LockedTarget.TargetPart.Velocity,
					Flags.LockedTarget.TargetPart.Position,
					Camera.Position
				)
			end
			Camera.lookAt(Camera.Position, TargetPos)
		else
			Flags.LockedTarget = nil
		end
	end) -- end of targetting loop
end

do
	local FovCircle = Drawing.new("Circle")
	FovCircle.Thickness = 1
	FovCircle.NumSides = 120
	local FovCircleOutline = Drawing.new("Circle")
	FovCircleOutline.Thickness = 1
	FovCircle.NumSides = FovCircle.NumSides

	local Snapline = Drawing.new("Line")
	Snapline.Thickness = 1
	local SnaplineOutline = Drawing.new("Line")
	SnaplineOutline.Thickness = 3

	RunService.RenderStepped:Connect(function() -- targetting visuals
		local Mouse = LocalPlayer:GetMouse()
		local MousePos = Vector2.new(Mouse.X, Mouse.Y)

		if Flags.Aimbot and Flags.AimbotFovCheck then
			FovCircleOutline.Position = MousePos
			FovCircleOutline.Radius = Flags.AimbotFovRadius - 1
			FovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
			FovCircleOutline.Visible = true

			FovCircleOutline.Position = MousePos
			FovCircleOutline.Radius = Flags.AimbotFovRadius + 1
			FovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
			FovCircleOutline.Visible = true

			FovCircle.Position = MousePos
			FovCircle.Radius = Flags.AimbotFovRadius
			FovCircle.Color = Color3.fromRGB(255, 255, 255)
			FovCircle.ZIndex = 5
			FovCircle.Outline = true
			FovCircle.Visible = true
		elseif not Flags.AimbotFovCheck or not Flags.Aimbot then
			FovCircle.Visible = false
			FovCircleOutline.Visible = false
		end
		if Flags.Snapline and Flags.Aimbot and AimbotKeybind:IsEnabled() and Flags.LockedTarget then
			local ScreenPos, OnScreen = WorldToScreen(Flags.LockedTarget.TargetPart.Position)
			if not OnScreen then
				return
			end

			Snapline.From = MousePos
			Snapline.To = ScreenPos
			Snapline.Color = Color3.fromRGB(255, 255, 255)
			Snapline.ZIndex = 5
			Snapline.Visible = true

			SnaplineOutline.From = MousePos
			SnaplineOutline.To = ScreenPos
			SnaplineOutline.Color = Color3.fromRGB(0, 0, 0)
			SnaplineOutline.Visible = true
		elseif Flags.Snapline and not Flags.LockedTarget then
			Snapline.Visible = false
			SnaplineOutline.Visible = false
		end
	end)
end

do
	-- armor viewer vars
	local BoxCount = 8
	local BoxSize = 64 -- width and height of each box
	local BoxSpacing = 5 -- gap between boxes
	local TopMargin = 55 -- distance from top of screen
	local BoxRounding = 10
	local BgColor = Color3.fromRGB(71, 71, 71) -- remember to do 0.45 transparency cus no color4 (fuck matcha)
	local BgTransparency = 0.75

	-- image cache
	local ImageCache = {}
	local ImageBaseUrl = "https://raw.githubusercontent.com/sigma4skin/matcha-fallen/main/armor_images/"

	-- cheaters cache
	local Cheaters = {}
	local CheaterLabels = {}

	local SlotDrawings = {}
	for i = 1, BoxCount do
		local Bg = Drawing.new("Square")
		Bg.Filled = true
		Bg.Visible = false
		Bg.Transparency = BgTransparency
		Bg.Color = BgColor
		Bg.Corner = BoxRounding
		Bg.ZIndex = 4

		local Img = Drawing.new("Image")
		Img.Visible = false
		Img.ZIndex = 5

		SlotDrawings[i] = { Bg = Bg, Img = Img, LastIcon = nil }
	end

	local function HideAllSlots()
		for i = 1, BoxCount do
			SlotDrawings[i].Bg.Visible = false
			SlotDrawings[i].Img.Visible = false
			SlotDrawings[i].LastIcon = nil
		end
	end

	local function GetOrCreateLabel(Index)
		if not CheaterLabels[Index] then
			local Label = Drawing.new("Text")
			Label.Text = "CHEATER"
			Label.Color = Color3.fromRGB(255, 13, 13)
			Label.Outline = true
			Label.Font = Drawing.Fonts.UI
			Label.Size = 14
			Label.Center = true
			Label.Visible = false
			Label.ZIndex = 10
			CheaterLabels[Index] = Label
		end
		return CheaterLabels[Index]
	end

	local function HideAllCheaterLabels()
		for _, Label in CheaterLabels do
			Label.Visible = false
		end
	end

	-- caching helper functions for armor viewer
	local function GetImage(ArmorId)
		if not ArmorId then
			return nil
		end

		local Cached = ImageCache[ArmorId]
		if Cached ~= nil then
			return Cached or nil
		end

		ImageCache[ArmorId] = false

		-- fetch from github
		local Url = ImageBaseUrl .. ArmorId .. ".png"
		task.spawn(function()
			local Ok, Data = pcall(function()
				return game:HttpGet(Url)
			end)

			if not Ok or not Data then
				ImageCache[ArmorId] = false
				warn("Failed to load image for ", ArmorId)
				return
			end

			ImageCache[ArmorId] = Data
		end)

		return nil
	end

	-- caching shit
	local SlotCache = {}
	local SlotCacheTargetChar = nil

	local function RebuildSlotCache(Char)
		SlotCache = {}
		if not Char then
			return
		end

		local Seen = {}
		local Idx = 1

		for _, Child in Char:GetChildren() do
			if Idx > BoxCount then
				break
			end

			local ArmorId = Child.Name:match("^Armor_%d+")
			if ArmorId and not Seen[ArmorId] then
				Seen[ArmorId] = true
				SlotCache[Idx] = { ArmorId = ArmorId, Icon = GetImage(ArmorId) }
				Idx += 1
			end
		end
	end

	local function UpdateSlotCacheImages()
		for I, Slot in SlotCache do
			if Slot and not Slot.Icon then
				local Img = ImageCache[Slot.ArmorId]
				if Img then
					Slot.Icon = Img
				end
			end
		end
	end

	-- throttled cache refresh vars (armor viewer)
	local SlotCacheLastUpdate = 0
	local SLOT_CACHE_INTERVAL = 1 -- refresh slot cache every second (if your looking at these and your fps is shit change these)
	local TargetLastUpdate = 0
	local TARGET_INTERVAL = 0.5

	local ArmorTarget = nil

	-- throttled cache refresh vars (cheater detector)
	local CheaterDetectorLastUpdate = 0
	local CHEATER_DETECTOR_INTERVAL = 3

	RunService.RenderStepped:Connect(function() -- visuals loop
		local Camera = Workspace.CurrentCamera
		if not Camera then
			HideAllSlots()
			return
		end

		local Viewport = Camera.ViewportSize
		local Now = tick()

		if Flags.LockedTarget and Flags.LockedTarget.Character then
			ArmorTarget = Flags.LockedTarget
		elseif Now - TargetLastUpdate >= TARGET_INTERVAL then
			TargetLastUpdate = Now
			ArmorTarget = FindClosestArmorTarget()
		end

		-- refresh slot cache when target changes or interval elapsed
		local CurrentChar = ArmorTarget and ArmorTarget.Character or nil
		if SlotCacheTargetChar ~= CurrentChar or Now - SlotCacheLastUpdate >= SLOT_CACHE_INTERVAL then
			SlotCacheLastUpdate = Now
			SlotCacheTargetChar = CurrentChar
			RebuildSlotCache(CurrentChar)
		end

		-- armor viewer
		if Flags.ArmorViewer and ArmorTarget then
			UpdateSlotCacheImages()

			local TotalWidth = BoxCount * BoxSize + (BoxCount - 1) * BoxSpacing
			local StartX = (Viewport.X - TotalWidth) / 2
			local Y = TopMargin

			for I = 1, BoxCount do
				local Slot = SlotCache[I]
				local Draw = SlotDrawings[I]
				local X = StartX + (I - 1) * (BoxSize + BoxSpacing)

				Draw.Bg.Position = Vector2.new(X, Y)
				Draw.Bg.Size = Vector2.new(BoxSize, BoxSize)
				Draw.Bg.Visible = true

				if Slot ~= nil and Slot.Icon ~= nil then
					if Draw.LastIcon ~= Slot.Icon then
						Draw.Img.Data = Slot.Icon
						Draw.LastIcon = Slot.Icon
					end
					Draw.Img.Position = Vector2.new(X + 2, Y + 2)
					Draw.Img.Size = Vector2.new(BoxSize - 4, BoxSize - 4)
					Draw.Img.Visible = true
				else
					Draw.Img.Visible = false
					Draw.LastIcon = nil
				end
			end
		else
			HideAllSlots()
		end

		-- cheater detector cache update
		if Flags.CheaterDetector and Now - CheaterDetectorLastUpdate >= CHEATER_DETECTOR_INTERVAL then
			CheaterDetectorLastUpdate = Now
			for _, Player in Players:GetPlayers() do
				if not Player or Player.Name == LocalPlayer.Name then
					continue
				end
				if Cheaters[Player.Name] == nil then
					Cheaters[Player.Name] = IsCheater(Player)
				end
			end
		end

		-- cheater detector
		if Flags.CheaterDetector then
			local LabelIndex = 0

			for _, Player in Players:GetPlayers() do
				if not Player or Player.Name == LocalPlayer.Name then
					continue
				end
				if not Cheaters[Player.Name] then
					continue
				end

				local Char = Player.Character
				if not Char then
					continue
				end
				local Head = Char:FindFirstChild("Head")
				if not Head then
					continue
				end
				local Humanoid = Char:FindFirstChild("Humanoid")
				if not Humanoid then
					continue
				end
				if Humanoid.Health <= 0 then
					continue
				end

				local ScreenPos, OnScreen = WorldToScreen(Head.Position + Vector3.new(0, 2.5, 0))
				if not OnScreen then
					continue
				end

				LabelIndex += 1
				local Label = GetOrCreateLabel(LabelIndex)
				Label.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
				Label.Visible = true
			end

			for I = LabelIndex + 1, #CheaterLabels do
				CheaterLabels[I].Visible = false
			end
		else
			HideAllCheaterLabels()
			Cheaters = {}
		end
	end) -- end of visuals loop
end

do
	local CardNoclipLastUpdate = 0
	local CARD_NOCLIP_INTERVAL = 3

	RunService.Heartbeat:Connect(function(Dt) -- movement loop
		local Char = LocalPlayer.Character
		local Humanoid = Char and Char:FindFirstChild("Humanoid")
		local Now = tick()

		if Flags.CardNoclip then
			if Now - CardNoclipLastUpdate >= CARD_NOCLIP_INTERVAL then
				for _, Part in workspace.RocketFactoryPinkCardInvisWalls:GetChildren() do
					Part.CanCollide = not Flags.CardNoclip
				end
				for _, Part in workspace.Monuments:GetDescendants() do
					if Part:IsA("MeshPart") and Part.Name:find("FallenShippingContainer") then
						Part.CanCollide = not Flags.CardNoclip
					end
				end
			end
		end

		local InAir = Humanoid and memory_read("int", Humanoid.Address + Offsets.Humanoid.FloorMaterial) == 1792 -- number for air

		if Flags.BHop and not InAir and iskeypressed(32) then
			memory_write("byte", Humanoid.Address + Offsets.Humanoid.Jump, 1)
		end
	end) -- end of movement loop
end

do
	-- general text esp pool
	local EspPool = {}

	local function GetOrCreateEspLabel(Index)
		if not EspPool[Index] then
			local Label = Drawing.new("Text")
			Label.Color = Color3.fromRGB(255, 255, 255)
			Label.Outline = true
			Label.Font = Drawing.Fonts.UI
			Label.Size = 14
			Label.Center = true
			Label.Visible = false
			Label.ZIndex = 8
			EspPool[Index] = Label
		end
		return EspPool[Index]
	end

	local function HideAllEspLabels()
		for _, Label in EspPool do
			Label.Visible = false
		end
	end

	-- each esp source returns a list of { Position, Text, Color, MaxDistance } entries
	local function GetDropEntries()
		local Entries = {}
		local Drops = workspace:FindFirstChild("Drops")
		if not Drops then
			return Entries
		end

		for _, Item in Drops:GetChildren() do
			if not Item:IsA("Model") then
				continue
			end
			local Root = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart")
			if not Root then
				continue
			end
			local Ok, Pos = pcall(function()
				return Root.Position
			end)
			if not Ok or not Pos then
				continue
			end
			table.insert(Entries, {
				Position = Pos,
				Text = Item.Name,
				Color = Color3.fromRGB(110, 149, 255),
				MaxDistance = Flags.LootEspDistance,
			})
		end

		return Entries
	end

	local function GetBodybagEntries()
		local Entries = {}
		local Bodybags = Workspace.Bases.Loners:FindFirstChild("Body Bag")
		if not Bodybags then
			return Entries
		end

		for _, Bag in Bodybags:GetChildren() do
			if not Bag:IsA("Model") then
				continue
			end
			local Main = Bag:FindFirstChild("Main")
			if not Main then
				continue
			end
			table.insert(Entries, {
				Position = Main.Position + Vector3.new(0, 1, 0),
				Text = "Bodybag",
				Color = Color3.fromRGB(255, 100, 100),
				MaxDistance = Flags.LootEspDistance,
			})
		end

		return Entries
	end

	local function GetNodeEntries()
		local Entries = {}
		local Nodes = Workspace:FindFirstChild("Nodes")
		if not Nodes then
			return Entries
		end

		for _, Node in Nodes:GetChildren() do
			if not Node:IsA("Model") then
				continue
			end
			local BasePart = Node.PrimaryPart or Node:FindFirstChildWhichIsA("BasePart")
			if not BasePart then
				continue
			end

			if Flags.StoneEsp and Node.Name == "Stone_Node" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Stone Node",
					Color = Color3.new(0.5, 0.5, 0.5),
					MaxDistance = Flags.NodeEspDistance,
				})
			elseif Flags.MetalEsp and Node.Name == "Metal_Node" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Metal Node",
					Color = Color3.new(1, 0.6, 0.1),
					MaxDistance = Flags.NodeEspDistance,
				})
			elseif Flags.PhosphateEsp and Node.Name == "Phosphate_Node" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Phosphate Node",
					Color = Color3.new(1, 1, 0.5),
					MaxDistance = Flags.NodeEspDistance,
				})
			end
		end

		return Entries
	end

	local function GetPlantEntries()
		local Entries = {}
		local Plants = Workspace:FindFirstChild("Plants")
		if not Plants then
			return Entries
		end

		for _, Plant in Plants:GetChildren() do
			if not Plant:IsA("Model") then
				continue
			end
			local BasePart = Plant.PrimaryPart or Plant:FindFirstChildWhichIsA("BasePart")
			if not BasePart then
				continue
			end

			if Flags.WoolEsp and Plant.Name == "Wool Plant" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Wool",
					Color = Color3.new(0.925490, 0.925490, 0.925490),
					MaxDistance = Flags.PlantEspDistance,
				})
			elseif Flags.TomatoEsp and Plant.Name == "Tomato Plant" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Tomato",
					Color = Color3.new(1, 0.188235, 0.188235),
					MaxDistance = Flags.PlantEspDistance,
				})
			elseif Flags.PumpkinEsp and Plant.Name == "Pumpkin Plant" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Pumpkin",
					Color = Color3.new(1, 0.627450, 0.137254),
					MaxDistance = Flags.PlantEspDistance,
				})
			elseif Flags.CornEsp and Plant.Name == "Corn Plant" then
				table.insert(Entries, {
					Position = BasePart.Position + Vector3.new(0, 1, 0),
					Text = "Corn",
					Color = Color3.new(1, 1, 0.219607),
					MaxDistance = Flags.PlantEspDistance,
				})
			end
		end

		return Entries
	end

	local function GetMiniEntries()
		local Entries = {}
		local Minis = Workspace.Bases.Loners:FindFirstChild("Salvaged Flycopter")
		if not Minis then
			return Entries
		end

		for _, Mini in Minis:GetChildren() do
			if not Mini:IsA("Model") then
				continue
			end
			local BasePart = Mini.PrimaryPart or Mini:FindFirstChildWhichIsA("BasePart")
			if not BasePart then
				continue
			end
			table.insert(Entries, {
				Position = BasePart.Position + Vector3.new(0, 1, 0),
				Text = "Minicopter",
				Color = Color3.fromRGB(24, 66, 255),
				MaxDistance = Flags.MiniEspDistance,
			})
		end

		return Entries
	end

	-- raid esp
	local RaidCache = {}
	local RAID_EXPIRE_TIME = 30

	local function CleanRaidCache()
		local Now = tick()
		for I = #RaidCache, 1, -1 do
			if Now - RaidCache[I].Time >= RAID_EXPIRE_TIME then
				table.remove(RaidCache, I)
			end
		end
	end

	local function UpdateRaidCache()
		local VFX = Workspace:FindFirstChild("VFX")
		if not VFX then
			return
		end
		local Now = tick()

		for _, Item in VFX:GetChildren() do
			if not Item.Name:find("Explosion") then
				continue
			end

			local BasePart
			if Item:IsA("BasePart") then
				BasePart = Item
			elseif Item:IsA("Model") then
				BasePart = Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart")
			end

			if not BasePart then
				continue
			end

			local Ok, Pos = pcall(function()
				return BasePart.Position
			end)

			if not Ok or not Pos then
				continue
			end

			local AlreadyCached = false
			for _, Cached in RaidCache do
				if Cached.Position and (Cached.Position - Pos).Magnitude < 20 then
					Cached.Time = Now
					AlreadyCached = true
					break
				end
			end

			if not AlreadyCached then
				table.insert(RaidCache, { Position = Pos, Time = Now })
			end
		end
	end

	local function GetRaidEntries()
		local Entries = {}
		CleanRaidCache()
		UpdateRaidCache()
		local Now = tick()

		for _, Cached in RaidCache do
			local TimeLeft = math.ceil(RAID_EXPIRE_TIME - (Now - Cached.Time))
			table.insert(Entries, {
				Position = Cached.Position + Vector3.new(0, 1, 0),
				Text = "Raid (" .. TimeLeft .. "s)",
				Color = Color3.fromRGB(255, 14, 14),
				MaxDistance = Flags.RaidEspDistance,
			})
		end

		return Entries
	end
	-- end of raid esp

	local EspCache = {}
	local EspCacheLastUpdate = 0
	local ESP_CACHE_INTERVAL = 2

	local EspDrawLastUpdate = 0
	local ESP_DRAW_INTERVAL = 0.015

	local function RebuildEspCache()
		local NewCache = {}

		if Flags.DropsEsp then
			for _, Entry in GetDropEntries() do
				table.insert(NewCache, Entry)
			end
		end

		if Flags.BodybagEsp then
			for _, Entry in GetBodybagEntries() do
				table.insert(NewCache, Entry)
			end
		end

		if Flags.StoneEsp or Flags.MetalEsp or Flags.PhosphateEsp then
			for _, Entry in GetNodeEntries() do
				table.insert(NewCache, Entry)
			end
		end

		if Flags.WoolEsp or Flags.TomatoEsp or Flags.PumpkinEsp or Flags.CornEsp then
			for _, Entry in GetPlantEntries() do
				table.insert(NewCache, Entry)
			end
		end

		if Flags.MiniEsp then
			for _, Entry in GetMiniEntries() do
				table.insert(NewCache, Entry)
			end
		end

		EspCache = NewCache
	end

	RunService.RenderStepped:Connect(function() -- misc esp loop
		local Now = tick()
		local Char = LocalPlayer.Character
		local Root = Char and Char:FindFirstChild("HumanoidRootPart")

		local AnyEnabled = Flags.DropsEsp
			or Flags.BodybagEsp
			or Flags.StoneEsp
			or Flags.MetalEsp
			or Flags.PhosphateEsp
			or Flags.MiniEsp
			or Flags.WoolEsp
			or Flags.TomatoEsp
			or Flags.PumpkinEsp
			or Flags.CornEsp
			or Flags.RaidEsp

		if not AnyEnabled then
			HideAllEspLabels()
			EspCache = {}
			return
		end

		-- slow workspace rescan
		if Now - EspCacheLastUpdate >= ESP_CACHE_INTERVAL then
			EspCacheLastUpdate = Now
			task.spawn(RebuildEspCache)
		end

		-- fast draw
		if Now - EspDrawLastUpdate < ESP_DRAW_INTERVAL then
			return
		end
		EspDrawLastUpdate = Now

		local AllEntries = {}
		for _, Entry in EspCache do
			table.insert(AllEntries, Entry)
		end
		if Flags.RaidEsp then
			for _, Entry in GetRaidEntries() do
				table.insert(AllEntries, Entry)
			end
		end

		local LabelIndex = 0

		for _, Entry in AllEntries do
			local Dist = Root and (Root.Position - Entry.Position).Magnitude
			if Dist and Dist > Entry.MaxDistance then
				continue
			end

			local ScreenPos, OnScreen = WorldToScreen(Entry.Position)
			if not OnScreen then
				continue
			end

			LabelIndex += 1
			local Label = GetOrCreateEspLabel(LabelIndex)
			Label.Text = Entry.Text .. " (" .. math.floor(Dist) .. "m)"
			Label.Color = Entry.Color
			Label.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
			Label.Visible = true
		end

		for I = LabelIndex + 1, #EspPool do
			if EspPool[I] then
				EspPool[I].Visible = false
			end
		end
	end) -- end of misc esp loop
end

do
	local ModCheckerLastCheck = 0
	local MOD_CHECKER_INTERVAL = 3
	local SeenMods = {}

	RunService.Heartbeat:Connect(function(Dt) -- misc loop
		local Now = tick()

		if Flags.ModChecker then
			if Now - ModCheckerLastCheck >= MOD_CHECKER_INTERVAL then
				ModCheckerLastCheck = Now
				for _, Player in Players:GetPlayers() do
					if not Player or Player.Name == LocalPlayer.Name then
						continue
					end

					local Success, UserId = pcall(function()
						return memory_read("uintptr_t", Player.Address + Offsets.Player.UserId)
					end)

					if not Success then
						warn("fuck failed to load userid for mod checker")
					end

					if not ModeratorIDs[UserId] or SeenMods[UserId] then
						continue
					end

					if Flags.ModCheckerBehavior == "Notify" then
						notify(ModeratorIDs[UserId] .. " (" .. Player.Name .. ") joined your game!", "Blaze", 5)
						SeenMods[UserId] = true
					elseif Flags.ModCheckerBehavior == "Kick" then
						memory_write("string", game.Workspace.Address, "BLAH")
					end
				end
			end
		end
	end)
end
