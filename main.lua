local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Flags = {}

Flags.AimbotTargetPart = "Head"
Flags.AimbotFovRadius = 50
Flags.AimbotMaxDistance = 1000

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

-- gun mods
local Cache = getgc({ "RecoilMult", "RangeMult", "SpeedMult", "AimSpreadMult", "HipSpreadMult" })

local function EnableNoRecoil()
	applygc(Cache, "RecoilMult", -1)
end

local function DisableNoRecoil()
	applygc(Cache, "RecoilMult", 1)
end

local function EnableInstantBullet()
	applygc(Cache, "SpeedMult", 100)
end

local function DisableInstantBullet()
	applygc(Cache, "SpeedMult", 1)
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
        Combat:Toggle("InstantBullet", "Instant Bullet", false, function(Bool)
            Flags.InstantBullet = Bool
            if Bool then
                EnableInstantBullet()
            else
                DisableInstantBullet()
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
    elseif Visuals.page == 1 then
		-- todo later maybe if matcha doesnt piss me off that much
    end

	-- movement section
	local Movement = Tab:Section("Movement", "Left", { "No Clip" })

	if Movement.page == 0 then
		
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
			if not Info then
				Camera.lookAt(Camera.Position, Flags.LockedTarget.TargetPart.Position)
				return
			end

			if Flags.InstantBullet then
				local Drop =
					CalculateDrop(Info.Speed, Info.Gravity, Flags.LockedTarget.TargetPart.Position, Camera.Position)
				TargetPos = Flags.LockedTarget.TargetPart.Position + Vector3.new(0, Drop, 0)
			else 
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
			end
			Camera.lookAt(Camera.Position, TargetPos)
		else
			Flags.LockedTarget = nil
		end
	end) -- end of targetting loop

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
		local BgTransparency = 0.55

		-- image cache
		local ImageCache = {}
		local ImageBaseUrl = "https://raw.githubusercontent.com/sigma4skin/matcha-fallen/main/armor_images/"

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
		local SlotCacheTarget = nil

		local function RebuildSlotCache()
			SlotCache = {}
			if not Flags.LockedTarget then
				return
			end

			local Char = Flags.LockedTarget.Character
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

		-- throttled cache refresh vars
		local SlotCacheLastUpdate = 0
		local SLOT_CACHE_INTERVAL = 1 -- refresh slot cache every second (if your looking at these and your fps is shit change these)

		RunService.RenderStepped:Connect(function() -- visuals loop
			local Camera = Workspace.CurrentCamera
			if not Camera then
				HideAllSlots()
				return
			end

			local Viewport = Camera.ViewportSize
			local Now = tick()

			-- refresh slot cache on interval
			if SlotCacheTarget ~= Flags.LockedTarget or Now - SlotCacheLastUpdate >= SLOT_CACHE_INTERVAL then
				SlotCacheLastUpdate = Now
				SlotCacheTarget = Flags.LockedTarget
				RebuildSlotCache()
			end

			-- armor viewer
			if Flags.ArmorViewer and Flags.LockedTarget then
				UpdateSlotCacheImages()

				local ActiveCount = #SlotCache
				if ActiveCount == 0 then
					HideAllSlots()
					return
				end

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
		end) -- end of visuals loop
	end
end
