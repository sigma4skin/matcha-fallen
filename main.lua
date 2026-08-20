local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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
Flags.FovColor = Color3.fromRGB(255, 255, 255)
Flags.FovAlpha = 1
Flags.SnaplineColor = Color3.fromRGB(255, 255, 255)
Flags.SnaplineAlpha = 1
Flags.CheaterDetectorColor = Color3.fromRGB(255, 13, 13)
Flags.CheaterDetectorAlpha = 1
Flags.DropsColor = Color3.fromRGB(110, 149, 255)
Flags.DropsAlpha = 1
Flags.BodybagColor = Color3.fromRGB(255, 100, 100)
Flags.BodybagAlpha = 1
Flags.StoneColor = Color3.new(0.5, 0.5, 0.5)
Flags.StoneAlpha = 1
Flags.MetalColor = Color3.new(1, 0.6, 0.1)
Flags.MetalAlpha = 1
Flags.PhosphateColor = Color3.new(1, 1, 0.5)
Flags.PhosphateAlpha = 1
Flags.WoolColor = Color3.new(0.92, 0.92, 0.92)
Flags.WoolAlpha = 1
Flags.TomatoColor = Color3.new(1, 0.18, 0.18)
Flags.TomatoAlpha = 1
Flags.PumpkinColor = Color3.new(1, 0.62, 0.13)
Flags.PumpkinAlpha = 1
Flags.CornColor = Color3.new(1, 1, 0.22)
Flags.CornAlpha = 1
Flags.MinicopterColor = Color3.fromRGB(24, 66, 255)
Flags.MinicopterAlpha = 1
Flags.RaidColor = Color3.fromRGB(255, 14, 14)
Flags.RaidAlpha = 1
Flags.BulletThickness = 1
Flags.FireRateMult = 1

local FovCheckRow, SnaplineRow, CheaterDetectorRow
local DropsRow, BodybagRow, WoolRow, TomatoRow, PumpkinRow, CornRow
local StoneRow, MetalRow, PhosphateRow, MiniRow, RaidRow

local function FetchRowColor(Row, DefaultColor)
    if Row and Row.GetColor then
        local Color, Alpha = Row:GetColor()
        if Color then
            return Color, 1 - (Alpha or 0)
        end
    end
    return DefaultColor, 1
end

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
    [51281722] = "Game Moderator",
    [7178750309] = "Game Moderator",
    [113179883] = "Game Moderator",
    [3122439095] = "Game Moderator",
    [991290934] = "Game Moderator",
    [3968854760] = "Game Moderator",
    [81993536] = "Game Moderator",
    [1004214871] = "Game Moderator",
    [3034930770] = "Game Moderator",
    [2364950171] = "Game Moderator",
    [1528346843] = "Game Moderator",
    [165053216] = "Game Moderator",
    [1127954045] = "Game Moderator",
    [3640120679] = "Game Moderator",
    [602009251] = "Game Moderator",
    [372791101] = "Game Moderator",
    [1378169111] = "Game Moderator",
    [3020799797] = "Game Moderator",
    [2567998467] = "Game Moderator",
    [4243907215] = "Game Moderator",
    [353983652] = "Game Moderator",
    [1406181681] = "Game Moderator",
    [2229169589] = "Game Moderator",
    [3004094651] = "Game Moderator",
    [839333692] = "Game Moderator",
    [979624578] = "Game Moderator",
    [1478885961] = "Game Moderator",
    [399754916] = "Game Moderator",
    [1193091081] = "Game Moderator",
    [4553863490] = "Game Moderator",
    [4225513035] = "Game Moderator",
    [41482597] = "Game Moderator",
    [2924549627] = "Game Moderator",
    [2732967856] = "Game Moderator",
    [1937516999] = "Game Moderator",
    [1374319325] = "Game Moderator",
    [1058831985] = "Game Moderator",
    [9621064456] = "Game Moderator",
    [584370127] = "Game Moderator",
    [813030262] = "Game Moderator",
    [3470393585] = "Game Moderator",
    [122915793] = "Game Moderator",
    [1534692727] = "Game Moderator",
    [7278178099] = "Game Moderator",
    [8593140875] = "Game Moderator",
    [2525997354] = "Game Moderator",
    [3126891654] = "Game Moderator",
    [1190967808] = "Game Moderator",
    [833946684] = "Game Moderator",
    [202751467] = "Game Moderator",
    [510349404] = "Game Moderator",
    [174212818] = "Contribution",
    [25548179] = "Lead Developer",
    [363101315] = "Lead Developer",
    [47983795] = "Co-Founder",
    [16681869] = "Founder",
}

local HeadHitboxSize = Vector3.new(1.15, 1.16, 1.16)

-- helper functions
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

local Cache =
    getgc({ "RecoilMult", "RangeMult", "SpeedMult", "AimSpreadMult", "HipSpreadMult", "FireRateMult", "SwayMult" })

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

local function EnableInstantBullet()
    applygc(Cache, "SpeedMult", 10)
end

local function DisableInstantBullet()
    applygc(Cache, "SpeedMult", 1)
end

local function ApplyFireRate(V)
    applygc(Cache, "FireRateMult", V - 1)
end

local function EnableNoSway()
    applygc(Cache, "SwayMult", -1)
end

local function DisableNoSway()
    applygc(Cache, "SwayMult", 1)
end

local function ResolveTargetPart(Character, Head, HumanoidRootPart)
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
    local MousePos = Vector2.new(Mouse.X, Mouse.Y)
    local LocalChar = LocalPlayer.Character
    if not LocalChar then
        return
    end
    local LocalRoot = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")

    for _, Player in Players:GetPlayers() do
        if Player == LocalPlayer then
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
            Model:FindFirstChild("Main")
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

-- ui
local Menu = loadstring(game:HttpGet("https://raw.githubusercontent.com/sigma4skin/matcha-fallen/main/ui.lua"))() or _G.UI

local Win = Menu.new({ Name = "Divine", Suffix = ".land", Key = "rshift" })

local White = Color3.fromRGB(255, 255, 255)
local function C(R, G, B) return Color3.fromRGB(R, G, B) end

do
    local Combat = Win:Tab("Combat")
    local Left = Combat:Panel({ Side = "left", Tabs = { "Aimbot" } })
    local Right = Combat:Panel({ Side = "right", Tabs = { "Gun Mods" } })

    local Aim = Left:Page("Aimbot")
    Aim:Toggle({ Name = "Aimbot", Key = "m2", Help = "Master switch for the aimbot",
        Callback = function(Bool)
            Flags.Aimbot = Bool
        end })
    Aim:Toggle({ Name = "Auto Prediction", Help = "Automatically adjusts prediction based on velocity and held weapon.",
        Callback = function(Bool)
            Flags.AutoPrediction = Bool
        end })
    Aim:Dropdown({ Name = "Target Part",
        Values = { "Head", "Humanoid Root Part", "Closest" },
        Default = "Head",
        Callback = function(V)
            Flags.AimbotTargetPart = V
        end })
    Aim:Slider({ Name = "Max Distance", Default = 1000, Min = 50, Max = 1500, Suffix = "m",
        Callback = function(V)
            Flags.AimbotMaxDistance = V
        end })
    Aim:Toggle({ Name = "Safezone Check",
        Callback = function(Bool)
            Flags.SafezoneCheck = Bool
        end })
    FovCheckRow = Aim:Toggle({ Name = "FOV Check", Color = White,
        Callback = function(Bool)
            Flags.AimbotFovCheck = Bool
        end })
    Aim:Slider({ Name = "FOV Radius", Default = 50, Min = 1, Max = 250, Suffix = "px",
        Callback = function(V)
            Flags.AimbotFovRadius = V
        end })
    SnaplineRow = Aim:Toggle({ Name = "Snapline", Color = White,
        Callback = function(Bool)
            Flags.Snapline = Bool
        end })

    local GunMods = Right:Page("Gun Mods")
    GunMods:Toggle({ Name = "No Recoil",
        Callback = function(Bool)
            if Bool then EnableNoRecoil() else DisableNoRecoil() end
        end })
    GunMods:Toggle({ Name = "Extend Range",
        Callback = function(Bool)
            if Bool then EnableExtendRange() else DisableExtendRange() end
        end })
    GunMods:Toggle({ Name = "Instant Bullet",
        Callback = function(Bool)
            if Bool then EnableInstantBullet() else DisableInstantBullet() end
        end })
    GunMods:Toggle({ Name = "No Spread",
        Callback = function(Bool)
            if Bool then EnableNoSpread() else DisableNoSpread() end
        end })
    GunMods:Toggle({ Name = "Fire Rate",
        Callback = function(Bool)
            Flags.FireRate = Bool
            if Bool then ApplyFireRate(Flags.FireRateMult) else ApplyFireRate(1) end
        end })
    GunMods:Slider({ Name = "Fire Rate Multiplier", Default = 1, Min = 0.1, Max = 1.5, Step = 0.1, Suffix = "x",
        Callback = function(V)
            Flags.FireRateMult = V
            if Flags.FireRate then ApplyFireRate(V) end
        end })
    GunMods:Toggle({ Name = "No Sway",
        Callback = function(Bool)
            if Bool then EnableNoSway() else DisableNoSway() end
        end })
    GunMods:Toggle({ Name = "Thick Bullet",
        Callback = function(Bool)
            Flags.ThickBullet = Bool
        end })
    GunMods:Slider({ Name = "Thickness", Default = 1, Min = 0.1, Max = 4, Step = 0.1, Suffix = "x",
        Callback = function(V)
            Flags.BulletThickness = V
        end })
end

do
    local Esp = Win:Tab("ESP")
    local Left = Esp:Panel({ Side = "left", Tabs = { "Player", "Loot", "Plants" } })
    local Right = Esp:Panel({ Side = "right", Tabs = { "Nodes", "Misc" } })

    local PlayersPage = Left:Page("Player")
    PlayersPage:Toggle({ Name = "Armor Viewer",
        Callback = function(Bool)
            Flags.ArmorViewer = Bool
        end })
    CheaterDetectorRow = PlayersPage:Toggle({ Name = "Cheater Detector", Color = C(255, 13, 13),
        Help = "Detects unusual velocities and new accounts.",
        Callback = function(Bool)
            Flags.CheaterDetector = Bool
        end })

    local Loot = Left:Page("Loot")
    DropsRow = Loot:Toggle({ Name = "Dropped Items", Color = C(110, 149, 255),
        Callback = function(Bool)
            Flags.DropsEsp = Bool
        end })
    BodybagRow = Loot:Toggle({ Name = "Bodybag", Color = C(255, 100, 100),
        Callback = function(Bool)
            Flags.BodybagEsp = Bool
        end })
    Loot:Slider({ Name = "Loot Distance", Default = 500, Min = 50, Max = 1500, Suffix = "m",
        Callback = function(V)
            Flags.LootEspDistance = V
        end })

    local Plants = Left:Page("Plants")
    WoolRow = Plants:Toggle({ Name = "Wool ESP", Color = C(235, 235, 235),
        Callback = function(Bool)
            Flags.WoolEsp = Bool
        end })
    TomatoRow = Plants:Toggle({ Name = "Tomato ESP", Color = C(255, 46, 46),
        Callback = function(Bool)
            Flags.TomatoEsp = Bool
        end })
    PumpkinRow = Plants:Toggle({ Name = "Pumpkin ESP", Color = C(255, 158, 33),
        Callback = function(Bool)
            Flags.PumpkinEsp = Bool
        end })
    CornRow = Plants:Toggle({ Name = "Corn ESP", Color = C(255, 255, 56),
        Callback = function(Bool)
            Flags.CornEsp = Bool
        end })
    Plants:Slider({ Name = "Plant Distance", Default = 500, Min = 50, Max = 1500, Suffix = "m",
        Callback = function(V)
            Flags.PlantEspDistance = V
        end })

    local Nodes = Right:Page("Nodes")
    StoneRow = Nodes:Toggle({ Name = "Stone ESP", Color = C(128, 128, 128),
        Callback = function(Bool)
            Flags.StoneEsp = Bool
        end })
    MetalRow = Nodes:Toggle({ Name = "Metal ESP", Color = C(255, 153, 26),
        Callback = function(Bool)
            Flags.MetalEsp = Bool
        end })
    PhosphateRow = Nodes:Toggle({ Name = "Phosphate ESP", Color = C(255, 255, 128),
        Callback = function(Bool)
            Flags.PhosphateEsp = Bool
        end })
    Nodes:Slider({ Name = "Node Distance", Default = 500, Min = 50, Max = 1500, Suffix = "m",
        Callback = function(V)
            Flags.NodeEspDistance = V
        end })

    local MiscEsp = Right:Page("Misc")
    MiniRow = MiscEsp:Toggle({ Name = "Minicopter ESP", Color = C(24, 66, 255),
        Callback = function(Bool)
            Flags.MiniEsp = Bool
        end })
    MiscEsp:Slider({ Name = "Minicopter Distance", Default = 500, Min = 50, Max = 1500, Suffix = "m",
        Callback = function(V)
            Flags.MiniEspDistance = V
        end })
    RaidRow = MiscEsp:Toggle({ Name = "Raid ESP", Color = C(255, 14, 14),
        Callback = function(Bool)
            Flags.RaidEsp = Bool
        end })
    MiscEsp:Slider({ Name = "Raid Distance", Default = 2000, Min = 100, Max = 5000, Suffix = "m",
        Callback = function(V)
            Flags.RaidEspDistance = V
        end })
end

do
    local Movement = Win:Tab("Movement")
    local Left = Movement:Panel({ Side = "left", Tabs = { "Movement" } })
    local Right = Movement:Panel({ Side = "right", Tabs = { } })

    local Move = Left:Page("Movement")
    Move:Toggle({ Name = "Bunny Hop",
        Callback = function(Bool)
            Flags.BHop = Bool
        end })
end

do
    local Misc = Win:Tab("Misc")
    local Left = Misc:Panel({ Side = "left", Tabs = { "Mod Checker" } })
    local Right = Misc:Panel({ Side = "right", Tabs = { } })

    local ModChecker = Left:Page("Mod Checker")
    ModChecker:Toggle({ Name = "Mod Checker",
        Callback = function(Bool)
            Flags.ModChecker = Bool
        end })
    ModChecker:Dropdown({ Name = "Mod Checker Behavior",
        Values = { "Notify", "Kick" },
        Default = "Notify",
        Help = "Kick Behavior will crash your Roblox!",
        Callback = function(V)
            Flags.ModCheckerBehavior = V
        end })
end

do
    local Settings = Win:Tab("Settings")
    local Left = Settings:Panel({ Side = "left", Tabs = { "Palette", "Binds" } })
    local Right = Settings:Panel({ Side = "right", Tabs = { "Config", } })

    local Paint = Left:Page("Palette")
    local Swatches = {}
    for I, Slot in ipairs(Menu.paints) do
        Swatches[I] = Paint:Color({
            Name = Slot[2],
            Default = Menu.theme[Slot[1]],
            Callback = function(Colour) Menu.paint(Slot[1], Colour) end,
        })
    end
    Paint:Button({
        Name = "Reset Palette",
        Callback = function()
            for I, Slot in ipairs(Menu.paints) do
                Swatches[I]:Set(Menu.stock[Slot[1]])
            end
        end,
    })

    local Binds = Left:Page("Binds")
    Binds:Keybind({
        Name = "Menu Key",
        Default = "rshift",
        NoList = true,
        OnBind = function(Key) Menu.key(Key) end,
    })
    Binds:Toggle({
        Name = "Show Binds",
        Default = true,
        Help = "Draw the bind list on screen",
        Callback = function(On) Menu.binds(On) end,
    })

    local Config = Right:Page("Config")
    Config:TextBox({ Name = "Config Name", Default = "default", Placeholder = "name" })
    Config:Button({ Name = "Save", Width = 123 })
    Config:Button({ Name = "Load", Width = 123 })
    Config:Button({ Name = "Delete", Width = 123 })
end

Menu.notify("Divine.land", "Press RightShift to toggle", 4)
-- end of ui

do -- targetting
    local ThickBulletLastUpdate = 0
    local THICK_BULLET_INTERVAL = 2
    local LockedTarget

    RunService.Heartbeat:Connect(function()
        local Now = tick()
        local Camera = Workspace.CurrentCamera
        local LocalChar = LocalPlayer.Character
        if not LocalChar then
            return
        end

        if Flags.Aimbot then
            if not LockedTarget or not LockedTarget.Humanoid or LockedTarget.Humanoid.Health <= 0 then
                LockedTarget = FindClosestViableTarget()
            end

            if not LockedTarget or not LockedTarget.TargetPart then
                return
            end

            local TargetPos = LockedTarget.TargetPart.Position
            local HeldWeapon = GetHeldWeapon(LocalChar)
            local Info = GetBulletInfo(HeldWeapon)

            if not Info or not Flags.AutoPrediction then
                Camera.lookAt(Camera.Position, TargetPos)
                return
            end

            if HeldWeapon == "Wooden Bow" or HeldWeapon == "Crossbow" then
                TargetPos = CalculateTargetPositionNoYPred(
                    Info.Speed,
                    Info.Gravity,
                    LockedTarget.TargetPart.Velocity,
                    TargetPos,
                    Camera.Position
                )
            else
                TargetPos = CalculateTargetPosition(
                    Info.Speed,
                    Info.Gravity,
                    LockedTarget.TargetPart.Velocity,
                    TargetPos,
                    Camera.Position
                )
            end

            Camera.lookAt(Camera.Position, TargetPos)
        else
            LockedTarget = nil
        end

        if Now - ThickBulletLastUpdate >= THICK_BULLET_INTERVAL then
            ThickBulletLastUpdate = Now
            if Flags.ThickBullet then
                for _, Player in Players:GetPlayers() do
                    if Player == LocalPlayer then
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
                        Head.Size = HeadHitboxSize
                        continue
                    end

                    Head.Size = HeadHitboxSize * Flags.BulletThickness
                    memory_write("float", Head.Address + Offsets.BasePart.Transparency, 0.99)
                end
            else
                for _, Player in Players:GetPlayers() do
                    if Player == LocalPlayer then
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

                    Head.Size = HeadHitboxSize
                end
            end
        end
    end)

    do -- targetting visuals
        local FovCircle = Drawing.new("Circle")
        FovCircle.Thickness = 1
        FovCircle.NumSides = 120
		FovCircle.ZIndex = 5
        local FovCircleOutline = Drawing.new("Circle")
        FovCircleOutline.Thickness = 3
        FovCircleOutline.NumSides = 120

        local Snapline = Drawing.new("Line")
        Snapline.Thickness = 1
        local SnaplineOutline = Drawing.new("Line")
        SnaplineOutline.Thickness = 3

        -- vars for armor viewer
        local ArmorViewerLastUpdate = 0
        local ARMOR_VIEWER_INTERVAL = 2

        local BoxCount = 8
        local BoxSize = 64
        local BoxSpacing = 5
        local TopMargin = 55
        local BoxRounding = 10
        local BgColor = Color3.fromRGB(71, 71, 71)
        local BgTransparency = 0.75

        local ImageCache = {}
        local ImageBaseUrl = "https://raw.githubusercontent.com/sigma4skin/matcha-fallen/main/armor_images/"

        local SlotCache = {}
        local ArmorViewerTarget

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

        -- functions for armor viewer
        local function GetImage(ArmorId)
            if not ArmorId then
                return nil
            end
            local Cached = ImageCache[ArmorId]
            if Cached ~= nil then
                return Cached or nil
            end
            ImageCache[ArmorId] = false
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
            for _, Slot in SlotCache do
                if Slot and not Slot.Icon then
                    local Img = ImageCache[Slot.ArmorId]
                    if Img then
                        Slot.Icon = Img
                    end
                end
            end
        end

        local function HideAllSlots()
            for i = 1, BoxCount do
                SlotDrawings[i].Bg.Visible = false
                SlotDrawings[i].Img.Visible = false
                SlotDrawings[i].LastIcon = nil
            end
        end

        RunService.RenderStepped:Connect(function()
            local Now = tick()
            local MousePos = Vector2.new(Mouse.X, Mouse.Y)

            if Flags.AimbotFovCheck then
                local color, alpha = FetchRowColor(FovCheckRow, Flags.FovColor)
                FovCircleOutline.Position = MousePos
                FovCircleOutline.Radius = Flags.AimbotFovRadius
                FovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
                FovCircleOutline.Transparency = alpha
                FovCircleOutline.Visible = true

                FovCircle.Position = MousePos
                FovCircle.Radius = Flags.AimbotFovRadius
                FovCircle.Color = color
                FovCircle.Transparency = alpha
                FovCircle.ZIndex = 5
                FovCircle.Outline = true
                FovCircle.Visible = true
            else
                FovCircle.Visible = false
                FovCircleOutline.Visible = false
            end

            if Flags.Snapline and Flags.Aimbot and LockedTarget then
                local ScreenPos, OnScreen = WorldToScreen(LockedTarget.TargetPart.Position)
                if not OnScreen then
                    Snapline.Visible = false
                    SnaplineOutline.Visible = false
                    return
                end
                local color, alpha = FetchRowColor(SnaplineRow, Flags.SnaplineColor)
                Snapline.From = MousePos
                Snapline.To = ScreenPos
                Snapline.Color = color
                Snapline.Transparency = alpha
                Snapline.ZIndex = 5
                Snapline.Visible = true

                SnaplineOutline.From = MousePos
                SnaplineOutline.To = ScreenPos
                SnaplineOutline.Color = Color3.fromRGB(0, 0, 0)
                SnaplineOutline.Transparency = alpha
                SnaplineOutline.Visible = true
            else
                Snapline.Visible = false
                SnaplineOutline.Visible = false
            end

            -- armor viewer stuff
            if Flags.ArmorViewer then
                local Camera = Workspace.CurrentCamera
                if not Camera then
                    HideAllSlots()
                    return
                end
                local Viewport = Camera.ViewportSize

                local CurrentTarget = LockedTarget

                if not CurrentTarget or not CurrentTarget.Character then
                    CurrentTarget = FindClosestViableTarget()
                end

                if not CurrentTarget or not CurrentTarget.Character then
                    ArmorViewerTarget = nil
                    SlotCache = {}
                    HideAllSlots()
                else
                    if ArmorViewerTarget ~= CurrentTarget or Now - ArmorViewerLastUpdate >= ARMOR_VIEWER_INTERVAL then
                        ArmorViewerLastUpdate = Now
                        ArmorViewerTarget = CurrentTarget
                        RebuildSlotCache(CurrentTarget.Character)
                    end

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

                        if Slot and Slot.Icon then
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
                end
            else
                if ArmorViewerTarget ~= nil then
                    ArmorViewerTarget = nil
                    SlotCache = {}
                end
                HideAllSlots()
            end
        end)
    end
end

do
    local Cheaters = {}
    local CheaterLabels = {}

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

    local CheaterDetectorLastUpdate = 0
    local CHEATER_DETECTOR_INTERVAL = 3

    RunService.RenderStepped:Connect(function()
        local Now = tick()

        if Flags.CheaterDetector then
            if Now - CheaterDetectorLastUpdate >= CHEATER_DETECTOR_INTERVAL then
                CheaterDetectorLastUpdate = Now
                for _, Player in Players:GetPlayers() do
                    if not Player or Player == LocalPlayer then
                        continue
                    end
                    if Cheaters[Player.Name] == nil then
                        Cheaters[Player.Name] = IsCheater(Player)
                    end
                end
            end

            local color, alpha = FetchRowColor(CheaterDetectorRow, Flags.CheaterDetectorColor)
            local LabelIndex = 0
            for _, Player in Players:GetPlayers() do
                if not Player or Player == LocalPlayer then
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
                Label.Color = color
                Label.Transparency = alpha
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
    end)
end

do
    RunService.Heartbeat:Connect(function()
        local Char = LocalPlayer.Character
        local Humanoid = Char and Char:FindFirstChild("Humanoid")

        local InAir = Humanoid and memory_read("int", Humanoid.Address + Offsets.Humanoid.FloorMaterial) == 1792

        if Flags.BHop and not InAir and iskeypressed(32) and isrbxactive() then
            memory_write("byte", Humanoid.Address + Offsets.Humanoid.Jump, 1)
        end
    end)
end

do
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

    local function GetDropEntries()
        local Entries = {}
        local Drops = workspace:FindFirstChild("Drops")
        if not Drops then
            return Entries
        end
        local color, alpha = FetchRowColor(DropsRow, Flags.DropsColor)
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
                Color = color,
                Alpha = alpha,
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
        local color, alpha = FetchRowColor(BodybagRow, Flags.BodybagColor)
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
                Color = color,
                Alpha = alpha,
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
                local color, alpha = FetchRowColor(StoneRow, Flags.StoneColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Stone Node",
                    Color = color,
                    Alpha = alpha,
                    MaxDistance = Flags.NodeEspDistance,
                })
            elseif Flags.MetalEsp and Node.Name == "Metal_Node" then
                local color, alpha = FetchRowColor(MetalRow, Flags.MetalColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Metal Node",
                    Color = color,
                    Alpha = alpha,
                    MaxDistance = Flags.NodeEspDistance,
                })
            elseif Flags.PhosphateEsp and Node.Name == "Phosphate_Node" then
                local color, alpha = FetchRowColor(PhosphateRow, Flags.PhosphateColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Phosphate Node",
                    Color = color,
                    Alpha = alpha,
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
                local color, alpha = FetchRowColor(WoolRow, Flags.WoolColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Wool",
                    Color = color,
                    Alpha = alpha,
                    MaxDistance = Flags.PlantEspDistance,
                })
            elseif Flags.TomatoEsp and Plant.Name == "Tomato Plant" then
                local color, alpha = FetchRowColor(TomatoRow, Flags.TomatoColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Tomato",
                    Color = color,
                    Alpha = alpha,
                    MaxDistance = Flags.PlantEspDistance,
                })
            elseif Flags.PumpkinEsp and Plant.Name == "Pumpkin Plant" then
                local color, alpha = FetchRowColor(PumpkinRow, Flags.PumpkinColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Pumpkin",
                    Color = color,
                    Alpha = alpha,
                    MaxDistance = Flags.PlantEspDistance,
                })
            elseif Flags.CornEsp and Plant.Name == "Corn Plant" then
                local color, alpha = FetchRowColor(CornRow, Flags.CornColor)
                table.insert(Entries, {
                    Position = BasePart.Position + Vector3.new(0, 1, 0),
                    Text = "Corn",
                    Color = color,
                    Alpha = alpha,
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
        local color, alpha = FetchRowColor(MiniRow, Flags.MinicopterColor)
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
                Color = color,
                Alpha = alpha,
                MaxDistance = Flags.MiniEspDistance,
            })
        end
        return Entries
    end

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
        local color, alpha = FetchRowColor(RaidRow, Flags.RaidColor)
        for _, Cached in RaidCache do
            local TimeLeft = math.ceil(RAID_EXPIRE_TIME - (Now - Cached.Time))
            table.insert(Entries, {
                Position = Cached.Position + Vector3.new(0, 1, 0),
                Text = "Raid (" .. TimeLeft .. "s)",
                Color = color,
                Alpha = alpha,
                MaxDistance = Flags.RaidEspDistance,
            })
        end
        return Entries
    end

    local EspCache = {}
    local EspCacheLastUpdate = 0
    local ESP_CACHE_INTERVAL = 2
    local EspDrawLastUpdate = 0
    local ESP_DRAW_INTERVAL = 0.015

    local function RebuildEspCache()
        local NewCache = {}
        if Flags.DropsEsp then
            for _, E in GetDropEntries() do
                table.insert(NewCache, E)
            end
        end
        if Flags.BodybagEsp then
            for _, E in GetBodybagEntries() do
                table.insert(NewCache, E)
            end
        end
        if Flags.StoneEsp or Flags.MetalEsp or Flags.PhosphateEsp then
            for _, E in GetNodeEntries() do
                table.insert(NewCache, E)
            end
        end
        if Flags.WoolEsp or Flags.TomatoEsp or Flags.PumpkinEsp or Flags.CornEsp then
            for _, E in GetPlantEntries() do
                table.insert(NewCache, E)
            end
        end
        if Flags.MiniEsp then
            for _, E in GetMiniEntries() do
                table.insert(NewCache, E)
            end
        end
        EspCache = NewCache
    end

    RunService.RenderStepped:Connect(function()
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

        if Now - EspCacheLastUpdate >= ESP_CACHE_INTERVAL then
            EspCacheLastUpdate = Now
            task.spawn(RebuildEspCache)
        end

        if Now - EspDrawLastUpdate < ESP_DRAW_INTERVAL then
            return
        end
        EspDrawLastUpdate = Now

        local AllEntries = {}
        for _, E in EspCache do
            table.insert(AllEntries, E)
        end
        if Flags.RaidEsp then
            for _, E in GetRaidEntries() do
                table.insert(AllEntries, E)
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
            Label.Transparency = Entry.Alpha
            Label.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
            Label.Visible = true
        end

        for I = LabelIndex + 1, #EspPool do
            if EspPool[I] then
                EspPool[I].Visible = false
            end
        end
    end)
end

do
    local ModCheckerLastCheck = 0
    local MOD_CHECKER_INTERVAL = 3
    local SeenMods = {}

    RunService.Heartbeat:Connect(function()
        local Now = tick()
        if Flags.ModChecker then
            if Now - ModCheckerLastCheck >= MOD_CHECKER_INTERVAL then
                ModCheckerLastCheck = Now
                for _, Player in Players:GetPlayers() do
                    if not Player or Player == LocalPlayer then
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
                        notify(
                            ModeratorIDs[UserId] .. " (" .. Player.Name .. ") joined your game!",
                            "Moderator Alert",
                            5
                        )
                        SeenMods[UserId] = true
                    elseif Flags.ModCheckerBehavior == "Kick" then
                        memory_write("string", game.Workspace.Address, "BLAH")
                    end
                end
            end
        end
    end)
end
