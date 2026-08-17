local Menu = (function()

local floor, ceil, abs, min, max = math.floor, math.ceil, math.abs, math.min, math.max
local cos, sin, pi = math.cos, math.sin, math.pi
local sub, upper, lower, rep, byte, char = string.sub, string.upper, string.lower, string.rep, string.byte, string.char
local format, gsub, find = string.format, string.gsub, string.find
local concat, insert, remove, sort = table.concat, table.insert, table.remove, table.sort
local rgb, v2 = Color3.fromRGB, Vector2.new
local now = tick or os.clock

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function lerp(a, b, t) return a + (b - a) * t end

local function mix(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function ease(t)
    t = clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

local function to255(c) return floor(c * 255 + 0.5) end

local function hsv(h, s, v)
    h = (h % 1 + 1) % 1
    local i = floor(h * 6)
    local f = h * 6 - i
    local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return Color3.new(v, t, p) end
    if i == 1 then return Color3.new(q, v, p) end
    if i == 2 then return Color3.new(p, v, t) end
    if i == 3 then return Color3.new(p, q, v) end
    if i == 4 then return Color3.new(t, p, v) end
    return Color3.new(v, p, q)
end

local function tohsv(c)
    local r, g, b = c.R, c.G, c.B
    local hi, lo = max(r, g, b), min(r, g, b)
    local d = hi - lo
    local h = 0
    if d > 0 then
        if hi == r then h = ((g - b) / d) % 6
        elseif hi == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, hi > 0 and d / hi or 0, hi
end

local function hex(c) return format("%02X%02X%02X", to255(c.R), to255(c.G), to255(c.B)) end

local Theme = {
    head   = rgb( 16,  17,  19),
    body   = rgb( 21,  22,  24),
    panel  = rgb( 23,  24,  26),
    field  = rgb( 27,  28,  30),
    hover  = rgb( 32,  33,  36),
    stroke = rgb( 44,  45,  47),
    box    = rgb( 45,  46,  48),
    grip   = rgb( 43,  44,  46),
    accent = rgb(182, 128, 242),
    white  = rgb(236, 237, 239),
    dim    = rgb(161, 162, 164),
    help   = rgb(155, 138, 183),
    black  = rgb(  0,   0,   0),
}

local Paints = {
    { "accent", "Accent" }, { "white", "Text" }, { "dim", "Muted Text" },
    { "help", "Help Mark" }, { "head", "Title Bar" }, { "body", "Window" },
    { "panel", "Panels" }, { "field", "Controls" }, { "hover", "Hover" },
    { "stroke", "Outlines" }, { "box", "Checkbox" }, { "grip", "Grips" },
}

local Stock = {}
for slot, colour in pairs(Theme) do Stock[slot] = colour end

local Design = {
    win = 800,
    headH = 60, panelY = 70, panelH = 680, footH = 40,
    pad = 12, panelW = 382,
    tabX = 200, tabW = 120, underH = 2, underY = 58,
    titleX = 15, titleCap = 25, subCap = 14,
    subH = 35, ruleH = 3, subTextX = 11, subSplit = 4,
    top = 120, rowH = 22, gap = 12,
    boxX = 13, boxW = 22, labelX = 43, deepX = 37, nestX = 43,
    edge = 13, step = 13,
    keyW = 106, helpW = 22, swatchW = 20, swatchGap = 8,
    trackW = 250, trackH = 14,
    dropW = 200, dropH = 26, dropRow = 22, dropTextX = 9,
    dot = 2, dotGap = 2, dotEdge = 5,
    capH = 18, sliderTail = 10, dropTail = 2,
    fHead = 16, fSub = 14, fRow = 13, fField = 12, fSmall = 12, fHelp = 14,
    r = 3, rWin = 3, rPanel = 2,
    pickW = 176, pickH = 196,
    hotPad = 8, hotAdd = 24, hotRow = 18, hotField = 68, hotBin = 16, hotGear = 13,
    fHotAdd = 11, fHotKey = 10,
    hudPad = 14, hudHead = 46, hudRow = 22, hudChip = 17, hudGap = 22,
    fHud = 15, fBind = 13, fChip = 11,
}

local L = { capOff = 0.21, capDrop = 1, scale = 1 }

local Z = {
    shade = 1000000, body = 2000000, panel = 4000000, row = 5000000,
    chrome = 8000000, front = 9000000,
    drop = 21000000, sub = 24000000, hud = 35000000, notif = 40000000, tip = 45000000,
}

local screenW, screenH = 1920, 1080

local function screen()
    local cam = workspace and workspace.CurrentCamera
    if cam then
        local s = cam.ViewportSize
        if s and s.X > 0 then screenW, screenH = s.X, s.Y end
    end
    return screenW, screenH
end

local function px(v)
    if not v then return v end
    local n = floor(v * L.scale + 0.5)
    if v > 0 and n < 1 then return 1 end
    if v < 0 and n > -1 then return -1 end
    return n
end

local function rescale(zoom)
    local w, h = screen()
    L.scale = clamp(min(w / 2560, h / 1440) ^ 0.6 * (tonumber(zoom) or 1), 0.25, 4)
    for k, v in pairs(Design) do L[k] = px(v) end
    L.win = px(800)
    if L.helpW % 2 == 0 then L.helpW = L.helpW + 1 end
end

local Fonts = (Drawing and Drawing.Fonts) or {}
local FONT = Fonts.SystemBold or Fonts.System or 0

local Can = { corner = false, center = false, font = false, sides = false, fontsize = false }
if Drawing then
    local function probe(kind, fn)
        local ok, obj = pcall(Drawing.new, kind)
        if not ok or not obj then return false end
        pcall(function() obj.Visible = false end)
        local good = pcall(fn, obj)
        pcall(function() obj:Remove() end)
        return good
    end
    pcall(function()
        Can.corner = probe("Square", function(o) o.Corner = 2 end)
        Can.center = probe("Text", function(o) o.Center = true end)
        Can.font = probe("Text", function(o) o.Font = FONT end)
        Can.sides = probe("Circle", function(o) o.NumSides = 24 end)
        Can.fontsize = probe("Text", function(o) o.FontSize = 12 end)
    end)
end

local Pool = { sq = {}, tx = {}, ln = {}, ci = {}, im = {} }
local Cache = { sq = {}, tx = {}, ln = {}, ci = {}, im = {} }
local Used = { sq = 0, tx = 0, ln = 0, ci = 0, im = 0 }
local Class = { sq = "Square", tx = "Text", ln = "Line", ci = "Circle", im = "Image" }
local function take(kind)
    local i = Used[kind] + 1
    Used[kind] = i
    local obj = Pool[kind][i]
    if not obj then
        local ok, made = pcall(Drawing.new, Class[kind])
        if not ok or not made then return nil end
        obj = made
        Pool[kind][i] = obj
        Cache[kind][i] = {}
        if kind == "tx" then
            pcall(function() obj.Outline = false end)
            if Can.center then pcall(function() obj.Center = false end) end
        end
    end
    return obj, Cache[kind][i]
end

local function newFrame()
    for k in pairs(Pool) do Used[k] = 0 end
end

local function hideRest()
    for kind, list in pairs(Pool) do
        for i = Used[kind] + 1, #list do
            local obj, c = list[i], Cache[kind][i]
            if obj and c and c.vis ~= false then
                c.vis = false
                obj.Visible = false
            end
        end
    end
end

local function wipe()
    for kind, list in pairs(Pool) do
        for i = 1, #list do
            local obj = list[i]
            if obj then pcall(function() obj.Visible = false; obj:Remove() end) end
            list[i], Cache[kind][i] = nil, nil
        end
        Used[kind] = 0
    end
end

local function rect(x, y, w, h, color, z, radius, alpha)
    alpha = alpha or 1
    if w <= 0.2 or h <= 0.2 or alpha <= 0.005 then return end
    local o, c = take("sq")
    if not o then return end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.w ~= w or c.h ~= h then c.w, c.h = w, h; o.Size = v2(w, h) end
    if c.color ~= color then c.color = color; o.Color = color end
    if c.fill ~= true then c.fill = true; o.Filled = true end
    local corner = min(radius or 0, w / 2, h / 2)
    if c.corner ~= corner then c.corner = corner; if Can.corner then o.Corner = corner end end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function line(x1, y1, x2, y2, color, z, thick, alpha)
    alpha = alpha or 1
    if alpha <= 0.005 then return end
    local o, c = take("ln")
    if not o then return end
    if c.x1 ~= x1 or c.y1 ~= y1 then c.x1, c.y1 = x1, y1; o.From = v2(x1, y1) end
    if c.x2 ~= x2 or c.y2 ~= y2 then c.x2, c.y2 = x2, y2; o.To = v2(x2, y2) end
    if c.color ~= color then c.color = color; o.Color = color end
    if c.thick ~= thick then c.thick = thick; o.Thickness = thick or 1 end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function circ(x, y, radius, color, z, filled, thick, alpha)
    alpha = alpha or 1
    if alpha <= 0.005 or radius <= 0.2 then return end
    local o, c = take("ci")
    if not o then return end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.radius ~= radius then c.radius = radius; o.Radius = radius end
    if c.color ~= color then c.color = color; o.Color = color end
    local fill = filled ~= false
    if c.fill ~= fill then c.fill = fill; o.Filled = fill end
    if not fill and c.thick ~= thick then c.thick = thick; o.Thickness = thick or 1 end
    if c.sides ~= 28 then c.sides = 28; if Can.sides then o.NumSides = 28 end end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function img(data, x, y, w, h, z, alpha, radius)
    alpha = alpha or 1
    if not data or alpha <= 0.005 or w <= 0.2 or h <= 0.2 then return end
    local o, c = take("im")
    if not o then return end
    if c.data ~= data then c.data = data; pcall(function() o.Data = data end) end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.w ~= w or c.h ~= h then c.w, c.h = w, h; o.Size = v2(w, h) end
    local corner = radius or 0
    if c.corner ~= corner then c.corner = corner; pcall(function() o.Rounding = corner end) end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local Glyph = {}
do
    Glyph.other = 0.55
    local function set(chars, w)
        for i = 1, #chars do Glyph[byte(chars, i)] = w end
    end
    set(",.:;", 0.21) set("'", 0.23) set("ijl|", 0.24) set("I`", 0.27) set(" !", 0.28)
    set("()[]{}", 0.30) set("f", 0.32) set("t", 0.34) set("Jr", 0.35) set("\\", 0.38)
    set("/\"", 0.39) set("-", 0.40) set("*_", 0.41) set("s", 0.42) set("?z", 0.45)
    set("cx", 0.46) set("L", 0.47) set("vy", 0.48) set("Fk", 0.49) set("Ea", 0.51)
    set("STe", 0.53) set("$0123456789", 0.54) set("PYhnu", 0.56) set("BZ", 0.57)
    set("Ko", 0.58) set("#Xbdgpq", 0.59) set("R", 0.60) set("CV", 0.62) set("A", 0.65)
    set("+<=>GU^~", 0.69) set("D", 0.70) set("H", 0.71) set("w", 0.72) set("N", 0.75)
    set("OQ", 0.76) set("&", 0.80) set("%", 0.82) set("m", 0.86) set("M", 0.90)
    set("W", 0.94) set("@", 0.95)
end

local Widths, WidthCount = {}, 0

local function width(s, size)
    s = tostring(s)
    if s == "" then return 0 end
    local key = s .. "\1" .. size
    local known = Widths[key]
    if known then return known end
    local w, i, n = 0, 1, #s
    while i <= n do
        local b = byte(s, i)
        if b < 128 then
            w = w + (Glyph[b] or Glyph.other)
            i = i + 1
        else
            w = w + Glyph.other
            i = i + 1
            while i <= n and byte(s, i) >= 128 and byte(s, i) <= 191 do i = i + 1 end
        end
    end
    w = w * size
    if WidthCount >= 4096 then Widths, WidthCount = {}, 0 end
    Widths[key] = w
    WidthCount = WidthCount + 1
    return w
end


local function fit(s, room, size, tail)
    s = tostring(s)
    if room <= 4 then return "" end
    if width(s, size) <= room then return s end
    tail = tail or ""
    local lo, hi = 0, #s
    while lo < hi do
        local mid = floor((lo + hi + 1) / 2)
        if width(sub(s, 1, mid) .. tail, size) <= room then lo = mid else hi = mid - 1 end
    end
    if lo == 0 then return "" end
    return sub(s, 1, lo) .. tail
end

local function text(s, x, y, color, size, z, alpha)
    s = tostring(s)
    alpha = alpha or 1
    if alpha <= 0.005 or s == "" then return end
    local o, c = take("tx")
    if not o then return end
    if c.text ~= s then c.text = s; o.Text = s end
    if c.size ~= size then
        c.size = size
        o.Size = size
        if Can.fontsize then o.FontSize = size end
    end
    if c.font ~= FONT then c.font = FONT; if Can.font then o.Font = FONT end end
    if c.mid ~= false then c.mid = false; if Can.center then o.Center = false end end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.color ~= color then c.color = color; o.Color = color end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function runText(s, x, top, color, size, z, alpha)
    s = tostring(s)
    local pen = x
    for i = 1, #s do
        local b = byte(s, i)
        if b ~= 32 then text(sub(s, i, i), pen, top, color, size, z, alpha) end
        pen = pen + (Glyph[b] or Glyph.other) * size
    end
    return pen
end

local function textmid(s, cx, top, color, size, z, alpha)
    s = tostring(s)
    alpha = alpha or 1
    if alpha <= 0.005 or s == "" then return end
    local o, c = take("tx")
    if not o then return end
    if c.text ~= s then c.text = s; o.Text = s end
    if c.size ~= size then
        c.size = size
        o.Size = size
        if Can.fontsize then o.FontSize = size end
    end
    if c.font ~= FONT then c.font = FONT; if Can.font then o.Font = FONT end end
    local x, y = cx, top
    if Can.center then
        if c.mid ~= true then c.mid = true; o.Center = true end
        y = top + size / 2
    else
        if c.mid ~= false then c.mid = false end
        x = cx - width(s, size) / 2
    end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.color ~= color then c.color = color; o.Color = color end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function capTop(cap, size) return cap + L.capDrop - size * L.capOff end

local function label(s, x, cap, color, size, z, alpha)
    text(s, x, capTop(cap, size), color, size, z, alpha)
end

local function labelmid(s, cx, cap, color, size, z, alpha)
    textmid(s, cx, capTop(cap, size), color, size, z, alpha)
end

local function shade(x, y, w, h, z, alpha, spread)
    spread = spread or 5
    for i = spread, 1, -1 do
        local t = i / spread
        rect(x - i, y - i + 1, w + i * 2, h + i * 2, Theme.black, z + spread - i, 6 + i,
            (0.05 * (1 - t) + 0.018) * alpha)
    end
end

local function frame(x, y, w, h, fill, stroke, z, alpha, radius)
    radius = radius or L.r
    rect(x, y, w, h, stroke, z, radius, alpha)
    rect(x + 1, y + 1, w - 2, h - 2, fill, z + 1, max(0, radius - 2), alpha)
end

local dt = 1 / 60

local function glide(from, to, seconds)
    if from == nil then return to end
    if not seconds or seconds <= 0 then return to end
    local moved = lerp(from, to, 1 - 0.5 ^ (dt / (seconds * 0.33)))
    if abs(to - moved) < 0.0015 then return to end
    return moved
end

local function fade(owner, key, to, seconds)
    local v = glide(owner[key], to, seconds or 0.15)
    owner[key] = v
    return v
end

local bxor, band, rshift
if bit32 then
    bxor, band, rshift = bit32.bxor, bit32.band, bit32.rshift
else
    bxor = function(a, b)
        local out, bit = 0, 1
        for _ = 1, 32 do
            local x, y = a % 2, b % 2
            if x ~= y then out = out + bit end
            a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
        end
        return out
    end
    band = function(a, b)
        local out, bit = 0, 1
        for _ = 1, 32 do
            local x, y = a % 2, b % 2
            if x == 1 and y == 1 then out = out + bit end
            a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
        end
        return out
    end
    rshift = function(a, n) return floor(a / 2 ^ n) end
end

local CrcTable = {}
for i = 0, 255 do
    local c = i
    for _ = 1, 8 do
        if band(c, 1) == 1 then c = bxor(0xEDB88320, rshift(c, 1)) else c = rshift(c, 1) end
    end
    CrcTable[i] = c
end

local function crc32(s)
    local c = 0xFFFFFFFF
    for i = 1, #s do c = bxor(rshift(c, 8), CrcTable[band(bxor(c, byte(s, i)), 255)]) end
    return bxor(c, 0xFFFFFFFF)
end

local function adler32(s)
    local a, b = 1, 0
    for i = 1, #s do
        a = (a + byte(s, i)) % 65521
        b = (b + a) % 65521
    end
    return b * 65536 + a
end

local function be32(n)
    return char(floor(n / 16777216) % 256, floor(n / 65536) % 256, floor(n / 256) % 256, n % 256)
end

local function le16(n) return char(n % 256, floor(n / 256) % 256) end

local function zlib(raw)
    local out, at, n = { char(120, 1) }, 1, #raw
    while at <= n do
        local size = min(n - at + 1, 65535)
        local last = (at + size - 1 >= n) and 1 or 0
        out[#out + 1] = char(last) .. le16(size) .. le16(65535 - size) .. sub(raw, at, at + size - 1)
        at = at + size
    end
    out[#out + 1] = be32(adler32(raw))
    return concat(out)
end

local function chunk(tag, data) return be32(#data) .. tag .. data .. be32(crc32(tag .. data)) end

local function png(w, h, pixels)
    return char(137, 80, 78, 71, 13, 10, 26, 10)
        .. chunk("IHDR", be32(w) .. be32(h) .. char(8, 6, 0, 0, 0))
        .. chunk("IDAT", zlib(pixels))
        .. chunk("IEND", "")
end

local B64 = {}
for i = 1, 64 do
    B64[byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i)] = i - 1
end

local function unbase64(s)
    if base64decode then
        local ok, out = pcall(base64decode, s)
        if ok and type(out) == "string" and #out >= 576 then return out end
    end
    local out, n, hold, bits = {}, 0, 0, 0
    for i = 1, #s do
        local v = B64[byte(s, i)]
        if v then
            hold = hold * 64 + v
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                local place = 2 ^ bits
                local b = floor(hold / place)
                hold = hold - b * place
                n = n + 1
                out[n] = char(b)
            end
        end
    end
    return concat(out)
end

local function tint(mask, w, h, r, g, b)
    local head, rows, at = char(r, g, b), {}, 0
    for _ = 1, h do
        rows[#rows + 1] = char(0)
        local row = {}
        for i = 1, w do
            at = at + 1
            row[i] = head .. char(byte(mask, at) or 0)
        end
        rows[#rows + 1] = concat(row)
    end
    return png(w, h, concat(rows))
end

local BLADES = "AAAAAAAAAAEBAAAABkx7dTgAAAAAAAAAAAAAAAABLa9oAQAu1fv6+tkrAAAAAAAAAAAAAAA3790MABfj+vrDMgEAAAAAAAAAAAAAAAPR+X0BAYX5+sAJAAAAAAAAAAAAAAAAADz7+lcAAcX6+zYAAAEhQyUBAAAAAAAAAGP5+WkAAcv68wQAHLH6+/u2GwAAAAQKAFb6+rwBAZ/iNwAh3vr5+fn50gsAAXFuARf0+vsnATdEAATI+/rzm2Jx024BAcadAQGF+eoCAAECAgQwF1AvAQABCkQBAeTtFwAEk+4FAW7h7JUHAAEBAQEAAAAAAdP6wRoBASkEV/r6+vp/AUqYqYMfAAAAAYr5+fLGIQAArPr6+vnJATve+vruQwAAABbd+fn6nAEBqfn6+fe7AQBF+vr66RYAAAAer/f7+GYBTvj39fVRAAEDV6j6+ncBAAAAARIsEwAAAVm/vFUBAW4IAAF6+qYBAAABAAAAAAEBFgsBAQEAAdW9CQAD16IBAFGYGAESceXb8RgAAmYBA+b6gwEBlWgBAA3Z+ef4+vr5ggEKlfYOFvL64gIANgcAAAAl0vn4+PeHAwGG+vsnAZT5+xEAAAAAAAAABlF7ayIBAAHA+vkUAGP69ggAAAAAAAAAAAABAAAAAWL7+bsBAHL5tgEBAQAAAAAAAAAAAAtBmfn46S4AAsTrLQABAAAAAAAAAAAAACTL+fOwKQAASa4qAAAAAAAAAAAAAAAAAAABDwgBAAAAAAEAAAAAAAAA"
local KEYCAPS = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEDAAAAAAAAAAAAAAAAAAAAAAAAAwEAAAAADhQVFxcXGBgYGBgYGBcXFxYPAAAAAAyc6/X4+fn5+fr6+vr6+fn5+PfsmAoAAKj///Ly8vHx8vLx8fLy8fHy8vH//6MAAP72PxAQDxAQDg8QEQ4PEBEOEBA99f4AAP/vCwABAAAAAAAAAAEAAAABAAAI7f8AAP/xEgrixwEJ2M8DDOHIAQ3hyAIS7/8AAP/xEQjOsQEHxbwCCcqyAQvNsQAR7/8AAP/wFAAAAAAAAAAAAAAAAAAAAAAR7v8AAP/wEwACAAEBAAABAQAAAwMAAgAQ7v8AAP/wEwACBs7LAwXOzwUDztMHAgAQ7v8AAP/wEwABBsPDBAXGwAUDwMcHAQAQ7v8AAP/wEwACAAAAAAAAAAAAAAAAAgAQ7v8AAP/wEwAAAAwMDQ0NDQ0NDQ4AAAAQ7v8AAP/wFAAHu+7s7u7v7+7u7fHICAAR7v8AAP/wFgEKw/Lx9PT09PT08fG8CAET7v8AAP/vCgAAAAgJCgoLCwoKCQgAAAAG7f8AAP32RRMXFBAQEBAQEBAQEBAUFhNC9f0AAKD///X29vf39/f39/f39/f29vX//54AAAiO4u7w8fLy8vPz8/Py8vLx8O7hjQgAAAAABw4ODw8QEBAQEBAQEA8PDg4HAAAAAAEDAAAAAAAAAAAAAAAAAAAAAAAAAwEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
local COPYMARK = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAeS7f7///////////3ohAECAAAAAAAAAJb///Lz8/Pz8/Pz8/P//28ABAAAAAAAAPz3RxUYFhYWFhYWGRZa/94BAQEAAAAAAP/tBwAAAAAAAAAAAAAC0a8BAgEAAAAAAP/uEwECAQIFAQAAAAAAAAAAAAAAAwAAAP/uEQABAAAAAAcJCgoLCQoKCQkAAAEAAP/uEQACAQSD1eLl5ufn6Ofn5uPRbQAAAP/uEQAEAIv//////////////////28AAP/uEQAADu/3SB4gHh4eHh4eIB5n/d0AAP/uEQAAF/nuBQAAAAAAAAAAAAAe/+cAAP/uEQAAFvfvEQIDAgICAgICBAIq/+UAAP/uEwAAFvjvDwABAAAAAAAAAgAo/+YAAP/tCQEAFvjvDwABAAAAAAAAAgAo/+YAAPz1PgAAF/jvDwABAAAAAAAAAgAo/+YAAKH//7IBFvjvDwABAAAAAAAAAgAo/+YAAAuT7MQCFvnvDwABAAAAAAAAAgAo/+YAAAAADwMAF/jvDwABAAAAAAAAAgAo/+YAAAEDAAAAFvjvEQECAQEBAQEBAwEq/+UAAAAAAQIAF/juBgAAAAAAAAAAAAAg/+cAAAAAAAEAEPX1PBUVExMSEhISFRJX/uIAAAAAAAADAJb//fHx8PDw8PDw8O///3YAAAAAAAABAgmh+P/////////////xgwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
local Masks, Tinted = {}, {}

local function iconSheet(art, colour)
    local raw = Masks[art]
    if raw == nil then
        local ok, got = pcall(unbase64, art)
        raw = (ok and #got >= 576) and got or false
        Masks[art] = raw
    end
    if not raw then return nil end

    local shelf = Tinted[art]
    if not shelf then
        shelf = {}
        Tinted[art] = shelf
    end
    local r, g, b = to255(colour.R), to255(colour.G), to255(colour.B)
    local key = r * 65536 + g * 256 + b
    local sheet = shelf[key]
    if sheet == nil then
        local ok, made = pcall(tint, raw, 24, 24, r, g, b)
        sheet = ok and made or false
        shelf[key] = sheet
    end
    return sheet or nil
end

local function stamp(art, cx, cy, size, colour, z, alpha)
    if alpha <= 0.01 then return end
    local sheet = iconSheet(art, colour)
    if sheet then img(sheet, cx - size / 2, cy - size / 2, size, size, z, alpha) end
end

local function icon(art, cx, cy, size, cold, warm, t, z, alpha)
    if alpha <= 0.01 then return end
    local x, y = cx - size / 2, cy - size / 2
    if t < 0.996 then
        local sheet = iconSheet(art, cold)
        if sheet then img(sheet, x, y, size, size, z, alpha * (1 - t)) end
    end
    if t > 0.004 then
        local sheet = iconSheet(art, warm)
        if sheet then img(sheet, x, y, size, size, z + 1, alpha * t) end
    end
end

local Square, SquareCount = {}, 0

local function svSheet(hue)
    local step = floor((hue % 1) * 64 + 0.5) % 64
    local ready = Square[step]
    if ready ~= nil then return ready or nil end
    local ok, sheet = pcall(function()
        local rows = {}
        for y = 0, 63 do
            local v = 1 - (y + 0.5) / 64
            local row = { char(0) }
            for x = 0, 63 do
                local c = hsv(step / 64, (x + 0.5) / 64, v)
                row[x + 2] = char(to255(c.R), to255(c.G), to255(c.B), 255)
            end
            rows[y + 1] = concat(row)
        end
        return png(64, 64, concat(rows))
    end)
    if SquareCount > 12 then
        Square, SquareCount = {}, 0
    end
    Square[step] = ok and sheet or false
    SquareCount = SquareCount + 1
    return ok and sheet or nil
end

local Rainbow = nil

local function hueSheet()
    if Rainbow ~= nil then return Rainbow or nil end
    local ok, sheet = pcall(function()
        local rows = {}
        for y = 0, 127 do
            local c = hsv((y + 0.5) / 128, 1, 1)
            rows[y + 1] = char(0) .. rep(char(to255(c.R), to255(c.G), to255(c.B), 255), 4)
        end
        return png(4, 128, concat(rows))
    end)
    Rainbow = ok and sheet or false
    return ok and sheet or nil
end

local Faded, FadedCount = {}, 0

local function alphaSheet(color)
    local r, g, b = to255(color.R), to255(color.G), to255(color.B)
    local key = r * 65536 + g * 256 + b
    local ready = Faded[key]
    if ready ~= nil then return ready or nil end
    local ok, sheet = pcall(function()
        local row = { char(0) }
        for i = 0, 95 do row[i + 2] = char(r, g, b, to255((i + 0.5) / 96)) end
        local one = concat(row)
        return png(96, 2, one .. one)
    end)
    if FadedCount > 24 then
        Faded, FadedCount = {}, 0
    end
    Faded[key] = ok and sheet or false
    FadedCount = FadedCount + 1
    return ok and sheet or nil
end

local function host(name, fallback)
    local f = _G[name]
    if type(f) == "function" then return f end
    return fallback
end

local keyDown   = host("iskeypressed", function() return false end)
local m1Down    = host("ismouse1pressed", function() return false end)
local m2Down    = host("ismouse2pressed", function() return false end)
local focused   = host("isrbxactive", function() return true end)
local grabInput = host("setrobloxinput", function() end)
local toClip    = host("setclipboard", function() end)
local fromClip  = host("getclipboard", nil)

local Key, Order, Named = {}, {}, {}

local function bind(name, id, ch, shifted)
    if not Key[name] then Order[#Order + 1] = name end
    Key[name] = { id = id, down = false, hit = false, up = false, ch = ch, shifted = shifted }
    Named[id] = upper(sub(name, 1, 1)) .. sub(name, 2)
end

bind("m1", 0x01) bind("m2", 0x02)
bind("mouse3", 0x04) bind("mouse4", 0x05) bind("mouse5", 0x06)
bind("wheelup", 0x101) bind("wheeldown", 0x102)
bind("backspace", 0x08) bind("tab", 0x09) bind("enter", 0x0D)
bind("shift", 0x10) bind("ctrl", 0x11) bind("alt", 0x12)
bind("esc", 0x1B) bind("space", 0x20, " ", " ")
bind("pageup", 0x21) bind("pagedown", 0x22) bind("end", 0x23) bind("home", 0x24)
bind("left", 0x25) bind("up", 0x26) bind("right", 0x27) bind("down", 0x28)
bind("insert", 0x2D) bind("delete", 0x2E)
do
    local shifted = { ")", "!", "@", "#", "$", "%", "^", "&", "*", "(" }
    for i = 0, 9 do bind(tostring(i), 0x30 + i, tostring(i), shifted[i + 1]) end
end
for i = 0, 25 do
    local ch = char(97 + i)
    bind(ch, 0x41 + i, ch, upper(ch))
end
for i = 1, 12 do bind("f" .. i, 0x6F + i) end
bind("lshift", 0xA0) bind("rshift", 0xA1) bind("lctrl", 0xA2) bind("rctrl", 0xA3)
bind("semicolon", 0xBA, ";", ":") bind("plus", 0xBB, "=", "+") bind("comma", 0xBC, ",", "<")
bind("minus", 0xBD, "-", "_") bind("period", 0xBE, ".", ">") bind("slash", 0xBF, "/", "?")
bind("tilde", 0xC0, "`", "~") bind("lbracket", 0xDB, "[", "{") bind("backslash", 0xDC, "\\", "|")
bind("rbracket", 0xDD, "]", "}") bind("quote", 0xDE, "'", "\"")
Named[0xA0], Named[0xA1] = "LShift", "RShift"
Named[0xA2], Named[0xA3] = "LCtrl", "RCtrl"
Named[0x20], Named[0x0D], Named[0x1B], Named[0x2D] = "Space", "Enter", "Esc", "Insert"
Named[0x04], Named[0x05], Named[0x06] = "MMB", "MB4", "MB5"
Named[0x101], Named[0x102] = "WheelUp", "WheelDn"

local S = {
    open = false, show = 0, x = 0, y = 0, w = 800, h = 800,
    mx = 0, my = 0, hasMouse = false,
    tabs = {}, active = nil, items = {}, flags = {}, hud = true,
    popups = {}, notes = {},
    layer = 0, floor = 0, focus = nil, grab = nil,
    tookClick = false, tookRight = false, locked = false,
    dragging = false, dragX = 0, dragY = 0,
    slide = nil, caret = nil, pick = nil, bar = nil,
    alive = true, tip = nil, key = "f1", title = "menu", suffix = nil,
    binds = {}, frames = 0, lastError = nil,
}

local Mouse = nil
local lastTick = nil
local clipMirror = ""
local spin, wheel = 0, 0

pcall(function()
    local input = game:GetService("UserInputService")
    input.InputChanged:Connect(function(what)
        if what.UserInputType == Enum.UserInputType.MouseWheel then
            spin = what.Position.Z
        end
    end)
end)

local function pollKeys(everything)
    local live = focused() ~= false
    local function poll(k)
        local down
        if k.id > 0xFF then
            down = (k.id == 0x101 and wheel > 0) or (k.id == 0x102 and wheel < 0)
        else
            down = live and keyDown(k.id) == true or false
        end
        k.hit = down and not k.down
        k.up = (not down) and k.down
        k.down = down
    end
    if everything then
        for _, name in ipairs(Order) do
            if name ~= "m1" and name ~= "m2" then poll(Key[name]) end
        end
        return
    end
    local seen = {}
    local toggle = Key[S.key]
    if toggle then seen[toggle.id] = true; poll(toggle) end
    for _, name in ipairs({ "esc", "enter", "up", "down", "pageup", "pagedown",
                            "ctrl", "lctrl", "rctrl", "shift", "lshift", "rshift" }) do
        local k = Key[name]
        if k and not seen[k.id] then seen[k.id] = true; poll(k) end
    end
    for i = 1, #S.binds do
        local item = S.binds[i]
        local k = item.bind and Key[item.bind]
        if k and not seen[k.id] then seen[k.id] = true; poll(k) end
    end
end

local function readInput()
    wheel, spin = spin, 0
    local t = now()
    dt = clamp(t - (lastTick or t), 1 / 1000, 1 / 15)
    lastTick = t

    for _, name in ipairs(Order) do
        local k = Key[name]
        k.hit, k.up = false, false
    end

    local live = focused() ~= false
    if not Mouse then
        pcall(function() Mouse = game:GetService("Players").LocalPlayer:GetMouse() end)
    end
    if Mouse then
        local ok = pcall(function() S.mx, S.my = Mouse.X, Mouse.Y end)
        S.hasMouse = ok
    end

    local down1 = live and m1Down() == true
    Key.m1.hit = down1 and not Key.m1.down
    Key.m1.up = (not down1) and Key.m1.down
    Key.m1.down = down1

    local down2 = live and m2Down() == true
    Key.m2.hit = down2 and not Key.m2.down
    Key.m2.up = (not down2) and Key.m2.down
    Key.m2.down = down2

    pollKeys(S.focus ~= nil or S.grab ~= nil)
    S.tookClick, S.tookRight = false, false
end

local function inside(x, y, w, h)
    if not S.hasMouse then return false end
    return S.mx >= x and S.mx <= x + w and S.my >= y and S.my <= y + h
end

local function over(x, y, w, h)
    if S.locked or S.layer < S.floor then return false end
    return inside(x, y, w, h)
end

local function hit(x, y, w, h)
    if S.locked or S.tookClick or not Key.m1.hit or S.layer < S.floor then return false end
    if not inside(x, y, w, h) then return false end
    S.tookClick = true
    return true
end

local function rightHit(x, y, w, h)
    if S.locked or S.tookRight or not Key.m2.hit or S.layer < S.floor then return false end
    if not inside(x, y, w, h) then return false end
    S.tookRight = true
    return true
end

local function shiftHeld() return Key.shift.down or Key.lshift.down or Key.rshift.down end
local function ctrlHeld() return Key.ctrl.down or Key.lctrl.down or Key.rctrl.down end

local repeatKey, repeatAt = nil, 0

local function held(name)
    local k = Key[name]
    if not k then return false end
    if k.hit then repeatKey, repeatAt = name, now() + 0.4; return true end
    if k.down and repeatKey == name and now() >= repeatAt then
        repeatAt = now() + 0.035
        return true
    end
    return false
end

local function edit(obj, field, allow, cap)
    local value = obj[field] or ""
    obj.at = clamp(obj.at or #value, 0, #value)
    local at, anchor = obj.at, obj.mark
    local marked = anchor ~= nil and anchor ~= at
    local lo = marked and min(anchor, at) or at
    local hi = marked and max(anchor, at) or at
    local changed = false
    local extend = shiftHeld()

    local function cut()
        value = sub(value, 1, lo) .. sub(value, hi + 1)
        at, anchor, marked, changed = lo, nil, false, true
    end
    local function done()
        if cap and #value > cap then
            value = sub(value, 1, cap)
        end
        obj.at = clamp(at, 0, #value)
        obj.mark = anchor
        obj[field] = value
        return changed
    end

    if ctrlHeld() then
        if Key.a.hit then anchor, at, Key.a.hit = 0, #value, false
        elseif Key.c.hit then
            if marked then clipMirror = sub(value, lo + 1, hi); pcall(toClip, clipMirror) end
            Key.c.hit = false
        elseif Key.x.hit then
            if marked then clipMirror = sub(value, lo + 1, hi); pcall(toClip, clipMirror); cut() end
            Key.x.hit = false
        elseif Key.v.hit then
            Key.v.hit = false
            local paste = clipMirror
            if fromClip then
                local ok, got = pcall(fromClip)
                if ok and type(got) == "string" and got ~= "" then paste = got end
            end
            if paste ~= "" then
                paste = gsub(paste, "[\r\n]", "")
                if allow then
                    local kept, n = {}, 0
                    for at2 = 1, #paste do
                        local ch = sub(paste, at2, at2)
                        if find(ch, allow) then
                            n = n + 1
                            kept[n] = ch
                        end
                    end
                    paste = concat(kept)
                end
                if marked then cut() end
                value = sub(value, 1, at) .. paste .. sub(value, at + 1)
                at, changed = at + #paste, true
            end
        end
        return done()
    end

    if Key.left.hit or Key.right.hit or Key.home.hit or Key["end"].hit then
        local to = at
        if Key.left.hit then to = (marked and not extend) and lo or max(0, at - 1) end
        if Key.right.hit then to = (marked and not extend) and hi or min(#value, at + 1) end
        if Key.home.hit then to = 0 end
        if Key["end"].hit then to = #value end
        anchor = extend and (anchor or at) or nil
        at = to
        Key.left.hit, Key.right.hit, Key.home.hit, Key["end"].hit = false, false, false, false
        return done()
    end

    if Key.delete.hit then
        if marked then cut()
        elseif at < #value then
            value = sub(value, 1, at) .. sub(value, at + 2)
            anchor, changed = nil, true
        end
        Key.delete.hit = false
    end

    if held("backspace") then
        if marked then cut()
        elseif at > 0 then
            value = sub(value, 1, at - 1) .. sub(value, at + 1)
            at, anchor, changed = at - 1, nil, true
        end
    end

    if not changed then
        for _, name in ipairs(Order) do
            local k = Key[name]
            if k.ch then
                local typed = k.hit or (k.down and repeatKey == name and now() >= repeatAt)
                if typed then
                    local ch = (extend and k.shifted) or k.ch
                    if allow and not find(ch, allow) then
                        typed = false
                    elseif cap and not marked and #value >= cap then
                        typed = false
                    else
                        if marked then cut() end
                        value = sub(value, 1, at) .. ch .. sub(value, at + 1)
                        at, anchor, changed = at + 1, nil, true
                    end
                    if k.hit then
                        repeatKey, repeatAt, k.hit = name, now() + 0.4, false
                    else
                        repeatAt = now() + 0.035
                    end
                    if typed then break end
                end
            end
        end
    end
    return done()
end

local function commitNumber(item)
    if not item or not item.buf then return end
    local got = tonumber(item.buf)
    if got then item:Set(clamp(got, item.min, item.max)) end
    item.buf = nil
end

local function caretAt(obj, value, mx)
    value = tostring(value or "")
    local size = obj.size or 12
    local edge, best, gap = obj.left or 0, 0, abs(mx - (obj.left or 0))
    for i = 1, #value do
        edge = edge + width(sub(value, i, i), size)
        local d = abs(mx - edge)
        if d < gap then gap, best = d, i end
    end
    return best
end

local function drawEdit(obj, value, x, top, size, color, z, alpha, room, on)
    value = tostring(value or "")
    obj.left, obj.size = x, size
    local at = clamp(obj.at or #value, 0, #value)
    local first = 0
    while first < at and width(sub(value, first + 1, at), size) > room - 6 do
        first = first + 1
    end
    local last = first
    while last < #value and width(sub(value, first + 1, last + 1), size) <= room - 4 do
        last = last + 1
    end

    local anchor = on and obj.mark
    if anchor and anchor ~= at then
        local lo = clamp(min(anchor, at), first, last)
        local hi = clamp(max(anchor, at), first, last)
        if hi > lo then
            local a = x + width(sub(value, first + 1, lo), size)
            local b = x + width(sub(value, first + 1, hi), size)
            rect(a, top - 1, b - a, size + 3, Theme.accent, z, 2, 0.4 * alpha)
        end
    end

    runText(sub(value, first + 1, last), x, top, color, size, z + 1, alpha)

    if on and (not anchor or anchor == at) and floor(now() * 2) % 2 == 0 then
        local cx = x + width(sub(value, first + 1, clamp(at, first, last)), size)
        line(cx, top - 1, cx, top + size + 1, Theme.white, z + 2, 1, 0.9 * alpha)
    end
end

local function fire(fn, ...)
    if type(fn) == "function" then pcall(fn, ...) end
end

local function setFlag(item, v)
    if item.flag then S.flags[item.flag] = v end
end

local function swatch(owner, color, clear, index)
    local sw = { kind = "swatch", owner = owner, index = index }
    sw.color = color
    sw.alpha = 1 - (clear or 0)
    sw.hue, sw.sat, sw.val = tohsv(color)
    return sw
end

local function applyColor(target)
    target.color = hsv(target.hue, target.sat, target.val)
    if target.kind == "swatch" then
        fire(target.owner.onColor, target.color, 1 - target.alpha, target.index)
    else
        setFlag(target, target.color)
        fire(target.callback, target.color, 1 - target.alpha)
    end
end

local function commitHex(box)
    if type(box) ~= "table" or box.kind ~= "hex" then return end
    local raw = gsub(box.hex, "[^0-9a-fA-F]", "")
    if #raw == 3 then
        raw = rep(sub(raw, 1, 1), 2) .. rep(sub(raw, 2, 2), 2) .. rep(sub(raw, 3, 3), 2)
    end
    if #raw ~= 6 then return end
    local target = box.owner
    target.hue, target.sat, target.val = tohsv(rgb(tonumber(sub(raw, 1, 2), 16),
        tonumber(sub(raw, 3, 4), 16), tonumber(sub(raw, 5, 6), 16)))
    applyColor(target)
end

local function commitEntry(item)
    if type(item) ~= "table" then return end
    if item.kind == "hex" then commitHex(item) else commitNumber(item) end
end

local Page = {}

local function bindMode(want, fallback)
    want = lower(tostring(want or fallback))
    if want == "hold" or want == "toggle" or want == "always" then return want end
    return fallback
end

local function registerBind(item)
    if item.listed then return end
    item.listed = true
    S.binds[#S.binds + 1] = item
end

local function newItem(page, kind, cfg, height)
    local item = {
        kind = kind, page = page, name = cfg.Name or "Element",
        callback = cfg.Callback, flag = cfg.Flag, tip = cfg.Tip, onBind = cfg.OnBind,
        help = cfg.Help, pad = cfg.Pad, width = cfg.Width, boxH = cfg.Height,
        capGap = cfg.CapGap, nested = cfg.Nested and true or false,
        off = cfg.Disabled and true or false, quiet = cfg.NoList and true or false,
        h = height,
    }
    if cfg.Color then
        item.onColor = cfg.OnColor
        item.swatch = swatch(item, cfg.Color, cfg.Clear, 1)
        if cfg.Color2 then item.swatch2 = swatch(item, cfg.Color2, cfg.Clear2, 2) end
    end
    if cfg.Option then
        item.option = setmetatable({ items = {} }, { __index = Page })
        item.option.owner = item
    end
    if cfg.Key then
        local k = Key[lower(tostring(cfg.Key))]
        item.bind = k and lower(tostring(cfg.Key)) or nil
        item.bindMode = bindMode(cfg.KeyMode, "toggle")
        item.bindArmed = true
        item.showKey = true
        registerBind(item)
    end
    page.items[#page.items + 1] = item
    S.items[#S.items + 1] = item
    return item
end

local function syncToggle(item)
    local live = item.value and (item.bind == nil or item.bindOn) and true or false
    if item.on == live then return end
    item.on = live
    setFlag(item, live)
    fire(item.callback, live)
end

function Page:Toggle(cfg)
    local item = newItem(self, "toggle", cfg, L.rowH)
    item.value = cfg.Default and true or false
    item.on = item.value
    setFlag(item, item.value)
    function item:Set(v)
        v = v and true or false
        if self.value ~= v then self.value = v; syncToggle(self) end
    end
    function item:Get() return self.on end
    return item
end

function Page:Slider(cfg)
    local item = newItem(self, "slider", cfg, L.capH + L.trackH)
    item.min, item.max = cfg.Min or 0, cfg.Max or 100
    item.round, item.suffix = cfg.Round or 0, cfg.Suffix or ""
    item.value = cfg.Default or item.min
    setFlag(item, item.value)
    function item:Set(v)
        local q = 10 ^ self.round
        v = floor(clamp(v, self.min, self.max) * q + 0.5) / q
        if v ~= self.value then
            self.value = v
            setFlag(self, v)
            fire(self.callback, v)
        end
    end
    function item:Get() return self.value end
    return item
end

function Page:Dropdown(cfg)
    local item = newItem(self, "dropdown", cfg, L.capH + L.dropH)
    item.values = cfg.Values or {}
    item.many = cfg.Multi and true or false
    item.empty = cfg.Empty or "None"
    item.scroll = 0
    if item.many then
        item.pick = {}
        if type(cfg.Default) == "table" then
            for k, v in pairs(cfg.Default) do item.pick[k] = v and true or nil end
        elseif cfg.Default then
            item.pick[cfg.Default] = true
        end
    else
        item.pick = cfg.Default
    end
    function item:Set(v) self.pick = v; setFlag(self, v); fire(self.callback, v) end
    function item:Get() return self.pick end
    function item:SetValues(v) self.values = v or {} end
    return item
end

function Page:TextBox(cfg)
    local item = newItem(self, "textbox", cfg, L.capH + L.dropH)
    item.value = cfg.Default or ""
    item.ghost = cfg.Placeholder or ""
    item.at = #item.value
    function item:Set(v)
        self.value = tostring(v or "")
        self.at = #self.value
        setFlag(self, self.value)
        fire(self.callback, self.value)
    end
    function item:Get() return self.value end
    return item
end

function Page:Keybind(cfg)
    local item = newItem(self, "keybind", cfg, L.rowH)
    item.bind = cfg.Default and lower(tostring(cfg.Default)) or nil
    item.bindMode = bindMode(cfg.Mode, "hold")
    item.showKey = true
    registerBind(item)
    function item:Set(k) self.bind = k and lower(tostring(k)) or nil; self.on = false end
    function item:Get() return self.on and true or false end
    return item
end

function Page:Color(cfg)
    local item = newItem(self, "color", cfg, L.rowH)
    item.color = cfg.Default or Theme.accent
    item.alpha = 1 - (cfg.Clear or 0)
    item.hue, item.sat, item.val = tohsv(item.color)
    function item:Set(c)
        self.color = c
        self.hue, self.sat, self.val = tohsv(c)
        applyColor(self)
    end
    function item:Get() return self.color, 1 - self.alpha end
    return item
end

function Page:Button(cfg) return newItem(self, "button", cfg, L.dropH) end
function Page:Label(cfg) return newItem(self, "label", cfg, L.capH) end

local function newPanel(tab, cfg)
    local panel = {
        side = (lower(tostring(cfg.Side or "left")) == "right") and "right" or "left",
        order = {}, pages = {}, tab = tab, callback = cfg.Callback,
    }
    for _, name in ipairs(cfg.Tabs or { "Main" }) do
        local title = tostring(name)
        if not panel.pages[title] then
            local page = setmetatable({ items = {}, name = title, panel = panel, tab = tab }, { __index = Page })
            panel.pages[title] = page
            panel.order[#panel.order + 1] = title
        end
    end
    panel.open = tostring(cfg.Default or panel.order[1] or "")
    function panel:Page(name) return self.pages[tostring(name)] end
    function panel:Set(name)
        name = tostring(name)
        if self.pages[name] and self.open ~= name then
            self.open = name
            fire(self.callback, name)
        end
    end
    tab.panels[#tab.panels + 1] = panel
    return panel
end

local function measure(item)
    local capGap = px(item.capGap) or L.capH
    local pad = px(item.pad) or 0
    local kind = item.kind
    if kind == "toggle" or kind == "keybind" or kind == "color" then
        item.h = L.rowH + pad
    elseif kind == "slider" then
        item.h = capGap + L.trackH + (item.pad and pad or L.sliderTail)
    elseif kind == "dropdown" then
        item.h = capGap + (px(item.boxH) or L.dropH) + (item.pad and pad or L.dropTail)
    elseif kind == "textbox" then
        item.h = capGap + L.dropH + (item.pad and pad or L.dropTail)
    elseif kind == "label" then
        item.h = L.capH + pad
    elseif kind == "button" then
        item.h = L.dropH + pad
    end
    return item.h
end

local function stackHeight(page)
    local total, n = 0, #page.items
    for i, item in ipairs(page.items) do
        total = total + measure(item) + (i < n and L.gap or 0)
    end
    return total
end

local function openPopup(kind, item, x, y, stacked)
    while #S.popups > 0 and S.popups[#S.popups].dying do remove(S.popups) end
    local keep = stacked and #S.popups or 0
    for i = #S.popups, keep + 1, -1 do S.popups[i] = nil end
    S.popups[#S.popups + 1] = { kind = kind, item = item, ox = x - S.x, oy = y - S.y, t = 0 }
end

local function shutPopup()
    local top = S.popups[#S.popups]
    if top then top.dying = true end
end

local function popupOpen(item, kind)
    for i = 1, #S.popups do
        local p = S.popups[i]
        if p.item == item and p.kind == kind and not p.dying then return true end
    end
    return false
end

local function anyPopup()
    for i = 1, #S.popups do
        if not S.popups[i].dying then return true end
    end
    return false
end

local Row = {}

local function tipAt(s)
    if s and s ~= "" then S.tip = { s, S.mx, S.my } end
end

local function helpDot(item, right, y, alpha, z)
    local x = right - L.helpW
    local on = over(x, y, L.helpW, L.rowH)
    local glow = fade(item, "aHelp", on and 1 or 0, 0.13)
    frame(x, y, L.helpW, L.rowH, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.55 * glow), z + 6, alpha)
    labelmid("?", x + L.helpW / 2 + L.fHelp * 0.09, y + px(6), mix(Theme.help, Theme.white, glow),
        L.fHelp, z + 8, (0.95 + 0.05 * glow) * alpha)
    if on then tipAt(item.help) end
    return x - L.step
end

local function optionDot(item, right, y, alpha, z)
    local x = right - L.helpW
    local shown = popupOpen(item, "flyout")
    local on = over(x, y, L.helpW, L.rowH)
    local glow = fade(item, "aOption", (on or shown) and 1 or 0, 0.13)
    frame(x, y, L.helpW, L.rowH, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.55 * glow), z + 10, alpha)
    icon(BLADES, x + L.helpW / 2, y + L.rowH / 2, L.helpW - px(7), Theme.help, Theme.white,
        ease(glow), z + 12, (0.9 + 0.1 * glow) * alpha)
    if hit(x, y, L.helpW, L.rowH) then
        if shown then shutPopup() else openPopup("flyout", item, x + L.helpW, y) end
    end
    return x - L.step
end

local function drawSwatch(target, x, y, size, alpha, z)
    target.color = hsv(target.hue, target.sat, target.val)
    local shown = popupOpen(target, "color")
    local on = over(x, y, size, size)
    local glow = fade(target, "aSwatch", (on or shown) and 1 or 0, 0.13)
    local grow = px(1) * glow
    rect(x - grow, y - grow, size + grow * 2, size + grow * 2, target.color, z, L.rPanel,
        alpha * (0.35 + 0.65 * target.alpha))
    if hit(x, y, size, size) then
        if shown then shutPopup() else openPopup("color", target, x + size / 2, y + size + px(6)) end
    end
end

local function swatchPair(item, right, y, alpha, z)
    if not item.swatch then return right end
    local top = y + (L.rowH - L.swatchW) / 2
    local x = right - L.swatchW
    drawSwatch(item.swatch, x, top, L.swatchW, alpha, z + 30)
    if item.swatch2 then
        x = x - L.swatchGap - L.swatchW
        drawSwatch(item.swatch2, x, top, L.swatchW, alpha, z + 32)
    end
    return x - L.step
end

local function bindName(item)
    if item.bindMode == "always" then return "ALWAYS" end
    if not item.bind then return "---" end
    local k = Key[item.bind]
    return upper(k and Named[k.id] or item.bind)
end

local function dots(cx, cy, count, size, gap, color, z, alpha)
    local pitch = size + gap
    local x = floor(cx - (count * pitch - gap) / 2)
    local y = floor(cy - size / 2)
    for i = 0, count - 1 do rect(x + i * pitch, y, size, size, color, z + i, 0, alpha) end
end

local function hotMenu(item, x, y, w)
    if not rightHit(x, y, w, item.h) then return end
    if popupOpen(item, "hotkey") then
        shutPopup()
    else
        item.hotRow = item.bind ~= nil
        openPopup("hotkey", item, x + w - L.edge, y + item.h + px(5))
    end
end

local function bindChip(item, right, y, alpha, z)
    local x = right - L.keyW
    local listening = S.grab == item
    local on = over(x, y, L.keyW, L.rowH)
    local glow = fade(item, "aBind", (on or listening) and 1 or 0, 0.13)
    frame(x, y, L.keyW, L.rowH, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.6 * glow), z + 14, alpha)
    if listening then
        dots(x + L.keyW / 2, y + L.rowH / 2, 3, px(2), px(3), Theme.accent, z + 16, alpha)
    else
        labelmid(bindName(item), x + L.keyW / 2, y + px(6), Theme.white, L.fSmall,
            z + 16, (0.9 + 0.1 * glow) * alpha)
    end
    if hit(x, y, L.keyW, L.rowH) then S.grab, S.focus = item, nil end
    return x - L.step
end

local function rightEdge(item, x, w, y, alpha, z)
    local right = x + w - L.edge
    if item.help then right = helpDot(item, right, y, alpha, z)
    elseif item.option then right = optionDot(item, right, y, alpha, z) end
    right = swatchPair(item, right, y, alpha, z)
    if item.showKey then right = bindChip(item, right, y, alpha, z) end
    return right
end

function Row.toggle(item, x, y, w, alpha, z)
    local right = rightEdge(item, x, w, y, alpha, z)
    local bx = x + L.boxX
    local on = over(bx, y, L.boxW, L.boxW)
    local lit = ease(fade(item, "aFill", item.value and 1 or 0, 0.15))
    local glow = fade(item, "aBox", on and 1 or 0, 0.13)

    frame(bx, y, L.boxW, L.boxW, Theme.panel, mix(Theme.box, Theme.accent, max(lit, 0.45 * glow)),
        z, alpha)
    if lit > 0.02 then
        local inset = (1 - lit) * (L.boxW / 2)
        rect(bx + inset, y + inset, L.boxW - inset * 2, L.boxW - inset * 2,
            Theme.accent, z + 2, L.r, lit * alpha)
    end

    local tx = x + L.labelX
    local room = max(px(10), right - tx - px(6))
    local shade = mix(Theme.dim, Theme.white, fade(item, "aText", item.on and 1 or 0, 0.15))
    label(fit(item.name, room, L.fRow, "..."), tx, y + px(5) + 1, shade, L.fRow, z + 3, alpha)

    if hit(bx, y, L.boxW, L.boxW) or hit(tx, y, room, L.rowH) then item:Set(not item.value) end
    if item.tip and over(tx, y, room, L.rowH) then tipAt(item.tip) end
    hotMenu(item, x, y, w)
end

function Row.slider(item, x, y, w, alpha, z)
    local tx = x + (item.nested and L.nestX or L.deepX)
    local ty = y + (px(item.capGap) or L.capH)
    local shown = item.round > 0 and format("%." .. item.round .. "f", item.value)
        or tostring(floor(item.value + 0.5))
    local head = item.name .. ": "
    local top = capTop(y + px(1), L.fRow)
    local numX = tx + width(head, L.fRow)
    text(head, tx, top, Theme.white, L.fRow, z + 3, alpha)
    if S.focus == item and item.buf then
        item.left, item.size = numX, L.fRow
        runText(item.buf, numX, top, Theme.white, L.fRow, z + 4, alpha)
        if floor(now() * 2) % 2 == 0 then
            local cx = numX + width(sub(item.buf, 1, item.at or #item.buf), L.fRow)
            line(cx, top - 1, cx, top + L.fRow + 1, Theme.white, z + 6, 1, 0.9 * alpha)
        end
    else
        text(shown .. item.suffix, numX, top, Theme.white, L.fRow, z + 4, alpha)
    end

    local tw = px(item.width) or L.trackW
    frame(tx, ty, tw, L.trackH, Theme.panel, Theme.stroke, z, alpha)
    local span = max(1e-6, item.max - item.min)
    local full = fade(item, "aFill", clamp((item.value - item.min) / span, 0, 1), 0.18)
    if full > 0.001 then
        rect(tx + 1, ty + 1, max(2, (tw - 2) * full), L.trackH - 2, Theme.accent, z + 2,
            max(1, L.r - 1), alpha)
    end

    if Key.m1.hit and not S.tookClick and S.layer >= S.floor
        and inside(tx - 3, ty - 4, tw + 6, L.trackH + 8) then
        S.tookClick = true
        if shiftHeld() then
            commitNumber(S.focus ~= item and S.focus or nil)
            S.focus, S.grab, S.slide = item, nil, nil
            item.buf, item.at, item.mark = shown, #shown, nil
        else
            S.slide = item
        end
    end
    if S.slide == item then
        if not Key.m1.down then S.slide = nil
        else item:Set(item.min + span * clamp((S.mx - tx - 1) / (tw - 2), 0, 1)) end
    end
    if item.help then helpDot(item, x + w - L.edge, ty - px(4), alpha, z) end
    if item.tip and over(tx, ty, tw, L.trackH) then tipAt(item.tip) end
    hotMenu(item, x, y, w)
end

local function dropText(item)
    if item.many then
        local out, n = {}, 0
        for _, v in ipairs(item.values) do
            if item.pick and item.pick[v] then n = n + 1; out[n] = tostring(v) .. "," end
        end
        if n == 0 then return item.empty end
        return concat(out, " ")
    end
    if item.pick == nil or item.pick == "" then return item.empty end
    return tostring(item.pick)
end

local function grip(bx, bw, by, bh, color, z, alpha)
    local size = max(1, L.dot)
    local pitch = size + max(1, L.dotGap)
    local span = pitch * 2 + size
    local x = floor(bx + bw - L.dotEdge - span)
    local y = floor(by + (bh - span) / 2)
    for col = 0, 2 do
        for row = 0, 2 do
            rect(x + col * pitch, y + row * pitch, size, size, color, z + col * 3 + row, 0, alpha)
        end
    end
end

function Row.dropdown(item, x, y, w, alpha, z)
    local bw = px(item.width) or L.dropW
    local bh = px(item.boxH) or L.dropH
    local bx = x + (item.nested and L.nestX or L.deepX)
    local by = y + (px(item.capGap) or L.capH)
    label(item.name, bx, y + px(1) + 1, Theme.white, L.fRow, z + 3, alpha)

    local shown = popupOpen(item, "list")
    local on = over(bx, by, bw, bh)
    local glow = fade(item, "aBox", (on or shown) and 1 or 0, 0.13)
    frame(bx, by, bw, bh, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.55 * glow), z, alpha)
    local room = bw - L.dropTextX - (L.dotEdge + L.dot * 3 + L.dotGap * 2) - px(6)
    label(fit(dropText(item), room, L.fField, "..."), bx + L.dropTextX,
        by + px(7) - (L.dropH - bh) / 2 + 1, Theme.white, L.fField, z + 4,
        (0.92 + 0.08 * glow) * alpha)
    grip(bx, bw, by, bh, mix(Theme.grip, Theme.accent, glow), z + 20, alpha)

    if hit(bx, by, bw, bh) then
        if shown then shutPopup() else openPopup("list", item, bx, by + bh + px(3)) end
    end
    hotMenu(item, x, y, w)
    if item.help then helpDot(item, x + w - L.edge, by + (bh - L.rowH) / 2, alpha, z) end
    if on and item.tip then tipAt(item.tip) end
end

function Row.textbox(item, x, y, w, alpha, z)
    local bw = px(item.width) or L.dropW
    local bx = x + (item.nested and L.nestX or L.deepX)
    local by = y + (px(item.capGap) or L.capH)
    label(item.name, bx, y + px(1), Theme.white, L.fRow, z + 3, alpha)

    local typing = S.focus == item
    local on = over(bx, by, bw, L.dropH)
    local glow = fade(item, "aBox", (on or typing) and 1 or 0, 0.13)
    frame(bx, by, bw, L.dropH, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.6 * glow), z, alpha)
    if typing or item.value ~= "" then
        drawEdit(item, item.value, bx + L.dropTextX, capTop(by + px(7) + 1, L.fField), L.fField,
            Theme.white, z + 5, alpha, bw - L.dropTextX * 2, typing)
    else
        label(item.ghost, bx + L.dropTextX, by + px(7) + 1, Theme.dim, L.fField, z + 5,
            0.7 * alpha)
    end
    if hit(bx, by, bw, L.dropH) then
        S.focus, S.grab = item, nil
        item.left, item.size = bx + L.dropTextX, L.fField
        item.at = caretAt(item, item.value, S.mx)
        item.mark = item.at
        S.caret = item
    end
    if S.caret == item then
        if not Key.m1.down then S.caret = nil
        else item.at = caretAt(item, item.value, S.mx) end
    end
    hotMenu(item, x, y, w)
end

function Row.keybind(item, x, y, w, alpha, z)
    local right = x + w - L.edge
    if item.help then right = helpDot(item, right, y, alpha, z) end
    bindChip(item, right, y, alpha, z)
    label(item.name, x + L.labelX, y + px(5), Theme.white, L.fRow, z + 3, alpha)
    hotMenu(item, x, y, w)
end

function Row.color(item, x, y, w, alpha, z)
    local right = x + w - L.edge
    if item.help then right = helpDot(item, right, y, alpha, z) end
    drawSwatch(item, right - L.swatchW, y + (L.rowH - L.swatchW) / 2, L.swatchW, alpha, z)
    label(item.name, x + L.labelX, y + px(5), Theme.white, L.fRow, z + 3, alpha)
end

function Row.label(item, x, y, w, alpha, z)
    label(item.name, x + (item.nested and L.nestX or L.deepX), y + px(1),
        Theme.white, L.fRow, z + 3, alpha)
end

function Row.button(item, x, y, w, alpha, z)
    local bx = x + L.deepX
    local bw = px(item.width) or L.dropW
    local on = over(bx, y, bw, L.dropH)
    local glow = fade(item, "aBox", on and 1 or 0, 0.13)
    frame(bx, y, bw, L.dropH, mix(Theme.field, Theme.hover, glow),
        mix(Theme.stroke, Theme.accent, 0.6 * glow), z, alpha)
    labelmid(item.name, bx + bw / 2, y + px(8), mix(Theme.white, Theme.accent, glow),
        L.fField, z + 3, alpha)
    if hit(bx, y, bw, L.dropH) then fire(item.callback) end
    if on and item.tip then tipAt(item.tip) end
end

local function drawStack(page, x, y, w, alpha, z)
    local top = y
    for i, item in ipairs(page.items) do
        measure(item)
        local paint = Row[item.kind]
        if paint then
            S.locked = item.off
            paint(item, x, top, w, item.off and alpha * 0.45 or alpha, z + (i - 1) * 40)
            S.locked = false
        end
        top = top + item.h + L.gap
    end
end

local Pop = {}

function Pop.list(pop, alpha, t, z)
    local item = pop.item
    local count = #item.values
    local bw = px(item.width) or L.dropW
    local rowH = L.dropRow
    local full = clamp(count * rowH + px(8), rowH, px(240))
    local w, h = screen()
    local x = clamp(S.x + pop.ox, 6, max(6, w - bw - 6))
    local y = clamp(S.y + pop.oy, 6, max(6, h - full - 6))
    local grown = floor(full * t)

    shade(x, y, bw, grown, z - 60, alpha, 5)
    frame(x, y, bw, grown, Theme.field, Theme.stroke, z, alpha)
    pop.box = { x, y, bw, grown }
    if grown < rowH then return end

    local fits = max(1, floor((full - px(8)) / rowH))
    local scrolls = count > fits
    if scrolls then
        local span = full - px(8)
        local most = count - fits
        item.scroll = clamp(item.scroll or 0, 0, most)
        if Key.up.hit and over(x, y, bw, grown) then item.scroll = item.scroll - 1 end
        if Key.down.hit and over(x, y, bw, grown) then item.scroll = item.scroll + 1 end
        item.scroll = clamp(item.scroll, 0, most)
        local knob = max(px(16), span * fits / count)
        local at = y + px(4) + (span - knob) * (item.scroll / most)
        if Key.m1.hit and not S.tookClick and inside(x + bw - px(12), y, px(12), grown) then
            S.tookClick, S.bar = true, item
        end
        if S.bar == item then
            if not Key.m1.down then S.bar = nil
            else
                local place = clamp((S.my - y - px(4) - knob / 2) / max(1, span - knob), 0, 1)
                item.scroll = floor(place * most + 0.5)
                at = y + px(4) + (span - knob) * (item.scroll / most)
            end
        end
        rect(x + bw - px(7), y + px(4), px(3), span, Theme.panel, z + 6, 1, alpha)
        rect(x + bw - px(7), at, px(3), knob, S.bar == item and Theme.white or Theme.accent,
            z + 7, 1, alpha)
    end

    local rowW = bw - px(8) - (scrolls and px(8) or 0)
    for i = 1, fits do
        local value = item.values[i + floor(item.scroll or 0)]
        if value ~= nil then
            local top = y + px(4) + (i - 1) * rowH
            if top + rowH <= y + grown - px(3) then
                local key = tostring(value)
                local chosen = item.many and (item.pick and item.pick[value] and true or false)
                    or (item.pick == value)
                local on = over(x + px(4), top, rowW, rowH)
                item.rowFade = item.rowFade or {}
                item.pickFade = item.pickFade or {}
                local glow = fade(item.rowFade, key, on and 1 or 0, 0.13)
                local mark = ease(fade(item.pickFade, key, chosen and 1 or 0, 0.15))
                local rz = z + 10 + i * 4
                if glow > 0.01 then
                    rect(x + px(4), top, rowW, rowH, Theme.white, rz, max(1, L.r - 1),
                        0.045 * glow * alpha)
                end
                label(fit(key, rowW - px(16), L.fField), x + px(12), top + px(6),
                    mix(mix(Theme.dim, Theme.white, glow), Theme.accent, mark),
                    L.fField, rz + 2, (0.8 + 0.2 * max(glow, mark)) * alpha)
                if hit(x + px(4), top, rowW, rowH) then
                    if item.many then
                        item.pick = item.pick or {}
                        item.pick[value] = (not item.pick[value]) or nil
                        item:Set(item.pick)
                    else
                        item:Set(value)
                        shutPopup()
                    end
                end
            end
        end
    end
end

function Pop.flyout(pop, alpha, t, z)
    local page = pop.item.option
    if not page then return end
    local bw = px(200)
    local full = clamp(stackHeight(page) + L.gap, L.rowH, px(320))
    local w, h = screen()
    local x = clamp(S.x + pop.ox + px(6), 6, max(6, w - bw - 6))
    local y = clamp(S.y + pop.oy - px(6), 6, max(6, h - full - 6))
    local grown = floor(full * t)
    shade(x, y, bw, grown, z - 60, alpha, 6)
    frame(x, y, bw, grown, Theme.panel, Theme.stroke, z, alpha)
    pop.box = { x, y, bw, grown }
    if t > 0.94 then drawStack(page, x, y + floor(L.gap / 2), bw, alpha, z + 20) end
end

local Modes = { { "hold", "Hold" }, { "toggle", "Toggle" }, { "always", "Always" } }

local function modeTitle(mode)
    for i = 1, #Modes do
        if Modes[i][1] == mode then return Modes[i][2] end
    end
    return Modes[1][2]
end

local function modeSet(item, mode)
    if item.bindMode == mode then return end
    item.bindMode, item.bindOn = mode, false
    if item.kind ~= "keybind" then
        syncToggle(item)
    elseif item.on then
        item.on = false
        setFlag(item, false)
        fire(item.callback, false)
    end
end

local function modeList(item)
    local drop = item.modeDrop
    if not drop then
        drop = { values = { "Hold", "Toggle", "Always" }, empty = "...", width = 68 }
        function drop:Set(picked)
            self.pick = picked
            for i = 1, #Modes do
                if Modes[i][2] == picked then modeSet(item, Modes[i][1]) end
            end
        end
        item.modeDrop = drop
    end
    drop.pick = modeTitle(item.bindMode)
    return drop
end

local function keyText(item)
    if S.grab == item then return "..." end
    if not item.bind then return nil end
    local k = Key[item.bind]
    return upper(k and Named[k.id] or item.bind)
end

local function chevron(cx, cy, radius, turn, colour, z, alpha)
    local angle = turn * pi
    local cosA, sinA = cos(angle), sin(angle)
    local rise = radius * 0.55
    local function spin(ox, oy)
        return cx + ox * cosA - oy * sinA, cy + ox * sinA + oy * cosA
    end
    local lx, ly = spin(-radius, -rise)
    local tipX, tipY = spin(0, rise)
    local rx, ry = spin(radius, -rise)
    line(lx, ly, tipX, tipY, colour, z, 1.4, alpha)
    line(tipX, tipY, rx, ry, colour, z + 1, 1.4, alpha)
end

local function trashCan(cx, cy, size, colour, z, alpha)
    local half = size / 2
    local lid = cy - half * 0.52
    local bodyW = size * 0.58
    local bottom = cy + half * 0.78
    local thick = max(1, px(1.2))
    line(cx - half * 0.78, lid, cx + half * 0.78, lid, colour, z, thick, alpha)
    line(cx - size * 0.16, lid - half * 0.26, cx + size * 0.16, lid - half * 0.26,
        colour, z + 1, thick, alpha)
    line(cx - bodyW / 2, lid, cx - bodyW / 2 + size * 0.06, bottom, colour, z + 2, thick, alpha)
    line(cx + bodyW / 2, lid, cx + bodyW / 2 - size * 0.06, bottom, colour, z + 3, thick, alpha)
    line(cx - bodyW / 2 + size * 0.06, bottom, cx + bodyW / 2 - size * 0.06, bottom,
        colour, z + 4, thick, alpha)
end

function Pop.hotkey(pop, alpha, t, z)
    local item = pop.item
    local grabbing = S.grab == item
    local wantRow = grabbing or item.bind ~= nil or item.hotRow
    local rowMix = ease(fade(item, "aHotRow", wantRow and 1 or 0, 0.16))

    local pad, addH, rowH = L.hotPad, L.hotAdd, L.hotRow
    local key = keyText(item)
    local boxH = rowH + px(4)
    local boxW = max(boxH, width(key or "", L.fHotKey) + px(12))
    local fieldW, binW = L.hotField, L.hotBin
    local gearW = item.option and L.hotGear or 0
    local panelW = pad * 2 + boxW + px(6) + fieldW + px(14) + binW
        + (gearW > 0 and gearW + px(9) or 0)
    local fullH = pad + addH + (pad + rowH) * rowMix + pad

    local w, h = screen()
    local x = clamp(S.x + pop.ox - panelW, 6, max(6, w - panelW - 6))
    local y = clamp(S.y + pop.oy, 6, max(6, h - fullH - 6))
    local grown = floor(fullH * t)

    shade(x, y, panelW, grown, z - 60, alpha, 8)
    frame(x, y, panelW, grown, Theme.panel, Theme.stroke, z, alpha)
    pop.box = { x, y, panelW, grown }
    if t < 0.5 then return end

    local inner = (t - 0.5) / 0.5 * alpha
    local ax, ay, aw = x + pad, y + pad, panelW - pad * 2
    local addGlow = fade(item, "aHotAdd", over(ax, ay, aw, addH) and 1 or 0, 0.13)
    rect(ax, ay, aw, addH, mix(Theme.field, Theme.hover, addGlow), z + 10, px(4), inner)
    labelmid("Add hotkey", ax + aw / 2, ay + (addH - L.fHotAdd) / 2 + px(1),
        mix(Theme.dim, Theme.white, addGlow), L.fHotAdd, z + 12,
        (0.8 + 0.2 * addGlow) * inner)
    if hit(ax, ay, aw, addH) then
        item.hotRow = true
        registerBind(item)
    end
    if rowMix <= 0.01 then return end

    local ry = y + pad + addH + pad
    local ra = inner * rowMix
    local by = ry - px(2)
    local boxGlow = fade(item, "aHotBox",
        (grabbing or over(ax, by, boxW, boxH)) and 1 or 0, 0.13)
    rect(ax, by, boxW, boxH, mix(Theme.field, Theme.accent, boxGlow * 0.35), z + 10, px(2), ra)
    if key then
        labelmid(key, ax + boxW / 2 + 0.45, by + (boxH - L.fHotKey) / 2 + px(1),
            grabbing and Theme.accent or Theme.white, L.fHotKey, z + 12,
            (0.75 + 0.25 * boxGlow) * ra)
    end
    if hit(ax, by, boxW, boxH) then
        S.grab, S.focus = item, nil
        registerBind(item)
    end

    local binX = x + panelW - pad - binW
    local binGlow = fade(item, "aHotBin", over(binX, ry, binW, rowH) and 1 or 0, 0.13)
    trashCan(binX + binW / 2, ry + rowH / 2, px(14), mix(Theme.dim, Theme.white, binGlow),
        z + 14, (0.8 + 0.2 * binGlow) * ra)
    if hit(binX, ry, binW, rowH) then
        if grabbing then S.grab = nil end
        item.bind, item.hotRow, item.bindOn = nil, nil, false
        if item.kind ~= "keybind" then
            syncToggle(item)
        elseif item.on then
            item.on = false
            setFlag(item, false)
            fire(item.callback, false)
        end
        return
    end

    if gearW > 0 then
        local gx, gy = binX - px(9) - gearW, ry + (rowH - gearW) / 2
        local gearGlow = fade(item, "aHotGear", over(gx, gy, gearW, gearW) and 1 or 0, 0.13)
        icon(BLADES, gx + gearW / 2, gy + gearW / 2, gearW, Theme.help, Theme.white, ease(gearGlow),
            z + 40, (0.85 + 0.15 * gearGlow) * ra)
        if hit(gx, gy, gearW, gearW) then
            if popupOpen(item, "flyout") then shutPopup()
            else openPopup("flyout", item, gx + gearW, gy, true) end
        end
    end

    local drop = modeList(item)
    local fx = ax + boxW + px(10)
    local open = popupOpen(drop, "list")
    local fieldGlow = fade(item, "aHotField",
        (open or over(fx, ry, fieldW, rowH)) and 1 or 0, 0.13)
    local turn = ease(fade(item, "aHotTurn", open and 1 or 0, 0.15))
    rect(fx, ry, fieldW, rowH, mix(Theme.field, Theme.hover, fieldGlow), z + 10, px(3), ra)
    labelmid(modeTitle(item.bindMode), fx + (fieldW - px(12)) / 2,
        ry + (rowH - L.fHotAdd) / 2 + px(1), mix(Theme.dim, Theme.white, fieldGlow),
        L.fHotAdd, z + 12, (0.8 + 0.2 * fieldGlow) * ra)
    chevron(fx + fieldW - px(10), ry + rowH / 2, px(4), turn,
        mix(Theme.dim, Theme.accent, fieldGlow), z + 30, (0.7 + 0.3 * fieldGlow) * ra)
    if hit(fx, ry, fieldW, rowH) then
        if open then shutPopup()
        else openPopup("list", drop, fx, y + fullH + px(3), true) end
    end
end

function Pop.color(pop, alpha, t, z)
    local target = pop.item
    local pw, ph = L.pickW, L.pickH
    local w, h = screen()
    local x = clamp(S.x + pop.ox - pw / 2, 6, max(6, w - pw - 6))
    local y = clamp(S.y + pop.oy, 6, max(6, h - ph - 6))
    shade(x, y, pw, floor(ph * t), z - 60, alpha, 6)
    frame(x, y, pw, floor(ph * t), Theme.field, Theme.stroke, z, alpha)
    pop.box = { x, y, pw, floor(ph * t) }
    if t < 0.94 then return end
    z = z + 10

    local pad = px(8)
    local fx, fy, fw = x + pad, y + pad, px(132)
    local hx, hw = x + pw - px(28), px(20)
    local ax, ay, aw, ah = x + pad, y + px(148), pw - pad * 2, px(12)
    local ry, rh = y + px(168), px(20)

    if not Key.m1.down then S.pick = nil
    elseif S.pick == nil and Key.m1.hit then
        if inside(fx, fy, fw, fw) then S.pick, S.tookClick = "sv", true
        elseif inside(hx - 4, fy, hw + 8, fw) then S.pick, S.tookClick = "hue", true
        elseif inside(ax - 4, ay - 4, aw + 8, ah + 8) then S.pick, S.tookClick = "alpha", true end
    end
    if S.pick == "sv" then
        target.sat = clamp((S.mx - fx) / fw, 0, 1)
        target.val = clamp(1 - (S.my - fy) / fw, 0, 1)
        applyColor(target)
    elseif S.pick == "hue" then
        target.hue = clamp((S.my - fy) / fw, 0, 1)
        applyColor(target)
    elseif S.pick == "alpha" then
        target.alpha = clamp((S.mx - ax) / aw, 0, 1)
        applyColor(target)
    end

    local sheet = svSheet(target.hue)
    if sheet then img(sheet, fx, fy, fw, fw, z, alpha, L.rPanel)
    else rect(fx, fy, fw, fw, hsv(target.hue, 1, 1), z, L.rPanel, alpha) end
    local dx, dy = fx + target.sat * fw, fy + (1 - target.val) * fw
    circ(dx, dy, px(6), Theme.black, z + 2, false, 2, 0.45 * alpha)
    circ(dx, dy, px(5), Theme.white, z + 3, false, 1.6, alpha)

    local strip = hueSheet()
    if strip then img(strip, hx, fy, hw, fw, z + 4, alpha, L.rPanel) end
    rect(hx - px(2), fy + target.hue * fw - 1, hw + px(4), px(2), Theme.white, z + 5, 1, alpha)

    local live = hsv(target.hue, target.sat, target.val)
    rect(ax, ay, aw, ah, Theme.panel, z + 6, L.r, alpha)
    local ramp = alphaSheet(live)
    if ramp then img(ramp, ax + 1, ay + 1, aw - 2, ah - 2, z + 7, alpha, L.rPanel) end
    rect(ax + target.alpha * aw - 1, ay - px(2), px(2), ah + px(4), Theme.white, z + 8, 1, alpha)

    local markX, markW = x + pw - pad - px(18), px(18)
    local hexX = x + pad
    local hexW = markX - px(6) - hexX
    local textX = hexX + px(28)
    local textW = hexW - px(34)

    local box = target.hexBox
    if not box then
        box = { kind = "hex", owner = target, hex = "", at = 0, mark = nil }
        target.hexBox = box
    end
    local typing = S.focus == box
    if not typing then box.hex = hex(live) end

    local on = over(hexX, ry, hexW, rh)
    local glow = fade(target, "aHex", (on or typing) and 1 or 0, 0.15)
    rect(hexX, ry, hexW, rh, mix(Theme.body, Theme.panel, glow), z + 9, px(4), alpha)
    rect(hexX + px(6), ry + rh / 2 - px(4), px(8), px(8), live, z + 10, px(2), alpha)
    text("#", hexX + px(19), ry + px(3), Theme.dim, L.fField, z + 11,
        (0.55 + 0.25 * glow) * alpha)
    drawEdit(box, box.hex, textX, ry + px(3), L.fField, Theme.white, z + 12,
        (0.85 + 0.1 * glow) * alpha, textW, typing)

    if hit(hexX, ry, hexW, rh) then
        box.left, box.size = textX, L.fField
        if typing then
            box.at = caretAt(box, box.hex, S.mx)
            box.mark = box.at
        else
            commitEntry(S.focus)
            box.at, box.mark = #box.hex, 0
        end
        S.focus, S.grab = box, nil
        S.caret = box
    end
    if S.caret == box then
        if not Key.m1.down then S.caret = nil
        else box.at = caretAt(box, box.hex, S.mx) end
    end
    if on and not typing then tipAt("type a hex colour") end

    local lit = over(markX, ry, markW, rh)
    local mark = fade(target, "aCopy", lit and 1 or 0, 0.15)
    icon(COPYMARK, markX + markW / 2, ry + rh / 2, px(14), Theme.dim, Theme.accent,
        ease(mark), z + 16, (0.6 + 0.35 * mark) * alpha)
    if hit(markX, ry, markW, rh) then pcall(toClip, "#" .. hex(live)) end
end

local function drawPopups()
    for i = #S.popups, 1, -1 do
        local pop = S.popups[i]
        pop.t = glide(pop.t, pop.dying and 0 or 1, 0.2)
        if pop.dying and pop.t < 0.02 then
            for j = #S.popups, i, -1 do S.popups[j] = nil end
        end
    end
    local count = #S.popups
    if count == 0 then return end

    local top = S.popups[count]
    local shielded = count > 1 and not top.dying and top.box
        and inside(top.box[1] - 2, top.box[2] - 2, top.box[3] + 4, top.box[4] + 4)

    for i = 1, count do
        local pop = S.popups[i]
        if pop then
            local base = (i == 1) and Z.drop or Z.sub
            S.layer = (pop.dying or (shielded and i < count)) and -1 or base
            local paint = Pop[pop.kind]
            if paint then paint(pop, pop.t * S.show, ease(pop.t), base) end
        end
    end

    if top and Key.m1.hit and not S.tookClick and not top.dying and top.box then
        local b = top.box
        if not inside(b[1] - 3, b[2] - 3, b[3] + 6, b[4] + 6) then
            shutPopup()
            S.tookClick = true
        end
    end
    S.layer = 0
end

local function header(x, y, w, alpha)
    rect(x, y, w, L.headH, Theme.head, Z.chrome, L.rWin, alpha)
    rect(x, y + L.headH - L.rWin, w, L.rWin, Theme.head, Z.chrome + 1, 0, alpha)

    if S.suffix then
        label(S.title .. S.suffix, x + L.titleX, y + L.titleCap, Theme.accent, L.fHead,
            Z.front, alpha)
    end
    label(S.title, x + L.titleX, y + L.titleCap, Theme.white, L.fHead, Z.front + 1, alpha)

    local at = 1
    for i, tab in ipairs(S.tabs) do
        if S.active == tab then at = i end
    end
    local slide = fade(S, "aTab", at, 0.2)

    for i, tab in ipairs(S.tabs) do
        local cx = x + L.tabX + (i - 1) * L.tabW
        local live = clamp(1 - abs(slide - i), 0, 1)
        local on = over(cx, y, L.tabW, L.headH)
        local glow = fade(tab, "aHover", on and 1 or 0, 0.13)
        labelmid(tab.name, cx + L.tabW / 2, y + L.titleCap,
            mix(mix(Theme.white, Theme.dim, 0.25 * (1 - glow) * (1 - live)), Theme.accent, live),
            L.fHead, Z.front + 10 + i, alpha)
        if hit(cx, y, L.tabW, L.headH) then S.active = tab end
    end

    rect(x + L.tabX + (slide - 1) * L.tabW, y + L.underY, L.tabW, L.underH,
        Theme.accent, Z.front + 3, 1, alpha)
end

local function panelHead(panel, x, y, alpha, side)
    local count = max(1, #panel.order)
    local cell = (L.panelW - L.subSplit * (count - 1)) / count
    local at = 1
    for i, name in ipairs(panel.order) do
        if name == panel.open then at = i end
    end
    local slide = fade(panel, "aTab", at, 0.2)

    for i = 1, count - 1 do
        rect(x + i * cell + (i - 1) * L.subSplit, y, L.subSplit, L.subH, Theme.body,
            Z.panel + 120 + side * 10 + i, 0, alpha)
    end
    for i, name in ipairs(panel.order) do
        local cx = x + (i - 1) * (cell + L.subSplit)
        local live = clamp(1 - abs(slide - i), 0, 1)
        local on = over(cx, y, cell, L.subH)
        local glow = fade(panel, "aHover" .. i, on and 1 or 0, 0.13)
        label(fit(name, cell - L.subTextX * 2, L.fSub, "..."), cx + L.subTextX, y + L.subCap,
            mix(mix(Theme.white, Theme.dim, 0.3 * (1 - glow) * (1 - live)), Theme.accent, live),
            L.fSub, Z.panel + 20 + side * 10 + i, alpha)
        if hit(cx, y, cell, L.subH) then panel:Set(name) end
    end
    rect(x, y + L.subH, L.panelW, L.ruleH, Theme.accent, Z.panel + 4 + side, 0, alpha)
end

local function drawPanel(panel, x, y, alpha)
    local right = panel.side == "right"
    local side = right and 2 or 0
    local px0 = x + L.pad + (right and (L.panelW + L.pad) or 0)
    local py0 = y + L.panelY
    rect(px0, py0, L.panelW, L.panelH, Theme.panel, Z.panel + side, L.rPanel, alpha)
    panelHead(panel, px0, py0, alpha, side)

    local page = panel.pages[panel.open]
    if not page then return end
    local shown = ease(fade(page, "aShow", 1, 0.16))
    drawStack(page, px0, y + L.top + (1 - shown) * px(6), L.panelW, shown * alpha,
        Z.row + (right and 4000 or 0))
    for name, other in pairs(panel.pages) do
        if name ~= panel.open then other.aShow = 0 end
    end
end

local function dragWindow(x, y, w)
    if Key.m1.hit and not S.tookClick and S.floor == 0 and inside(x, y, w, L.headH) then
        S.dragging = true
        S.dragX, S.dragY = S.mx - S.x, S.my - S.y
        S.tookClick = true
    end
    if not S.dragging then return end
    if not Key.m1.down then S.dragging = false; return end
    local w2, h2 = screen()
    S.x = clamp(S.mx - S.dragX, px(40) - S.w, w2 - px(40))
    S.y = clamp(S.my - S.dragY, 0, h2 - L.headH)
end

local function drawWindow(alpha)
    if alpha < 0.015 then return end
    local x, y, w, h = S.x, S.y, S.w, S.h
    shade(x, y, w, h, Z.shade, alpha * 0.85, 7)
    rect(x, y, w, h, Theme.body, Z.body, L.rWin, alpha)
    header(x, y, w, alpha)

    if S.active then
        for _, panel in ipairs(S.active.panels) do drawPanel(panel, x, y, alpha) end
    end
    for _, tab in ipairs(S.tabs) do
        if tab ~= S.active then
            for _, panel in ipairs(tab.panels) do
                for _, page in pairs(panel.pages) do page.aShow = 0 end
            end
        end
    end

    local fy = y + h - L.footH
    rect(x, fy, w, L.footH, Theme.panel, Z.chrome + 10, L.rWin, alpha)
    rect(x, fy, w, L.rWin, Theme.panel, Z.chrome + 11, 0, alpha)
    dragWindow(x, y, w)
end

local function drawNotes()
    local w = screen()
    local top = px(10)
    for i = #S.notes, 1, -1 do
        local note = S.notes[i]
        if not note.gone and now() - note.born >= note.life then note.gone = true end
        note.slip = glide(note.slip, note.gone and 1 or 0, 0.18)
        note.show = glide(note.show, note.gone and 0 or 1, 0.16)
        if note.gone and note.show < 0.03 then
            remove(S.notes, i)
        else
            local nw = px(max(150, width(note.title, L.fField) + 40))
            local nh = note.body and px(44) or px(28)
            local x = w - px(12) - nw + ease(note.slip) * (nw + px(20))
            local nz = Z.notif + i * 20
            shade(x, top, nw, nh, nz - 10, note.show * 0.6, 4)
            frame(x, top, nw, nh, Theme.panel, Theme.stroke, nz, note.show)
            rect(x + 1, top + 1, px(2), nh - 2, Theme.accent, nz + 2, 1, note.show)
            label(note.title, x + px(12), top + px(10), Theme.white, L.fField,
                nz + 3, note.show)
            if note.body then
                label(note.body, x + px(12), top + px(27), Theme.dim, L.fSmall,
                    nz + 4, note.show)
            end
            top = top + nh + px(8)
        end
    end
end

local function chipText(item)
    local k = item.bind and Key[item.bind]
    return upper(k and Named[k.id] or tostring(item.bind or ""))
end

local function chipWidth(item)
    return px(9) * 2 + width(chipText(item), L.fChip)
end

local function drawBindList()
    if not S.hud or not S.active then return end

    local live, count = {}, 0
    for i = 1, #S.binds do
        local item = S.binds[i]
        if item.bind and not item.quiet and item.on then
            count = count + 1
            live[count] = item
        end
    end

    local pad, headH, rowH = L.hudPad, L.hudHead, L.hudRow
    local widest = width("Key binds", L.fHud) + L.hudGap + px(18)
    for i = 1, count do
        local need = width(live[i].name, L.fBind) + px(24) + chipWidth(live[i])
        if need > widest then widest = need end
    end

    local w, h = screen()
    local bw = widest + pad * 2
    local bh = headH + count * rowH + (count > 0 and px(10) or px(2))
    S.hudX = clamp(S.hudX or px(24), 4, max(4, w - bw - 4))
    S.hudY = clamp(S.hudY or px(24), 4, max(4, h - bh - 4))
    local x, y = S.hudX, S.hudY

    if not anyPopup() and Key.m1.hit and not S.tookClick and inside(x, y, bw, headH) then
        S.tookClick, S.hudDrag = true, { S.mx - x, S.my - y }
    end
    if S.hudDrag then
        if not Key.m1.down then
            S.hudDrag = nil
        else
            S.hudX = clamp(S.mx - S.hudDrag[1], 4, max(4, w - bw - 4))
            S.hudY = clamp(S.my - S.hudDrag[2], 4, max(4, h - bh - 4))
            x, y = S.hudX, S.hudY
        end
    end

    shade(x, y, bw, bh, Z.hud - 100, 1, 7)
    frame(x, y, bw, bh, Theme.body, Theme.stroke, Z.hud, 1, px(9))
    label("Key binds", x + pad, y + px(17), Theme.white, L.fHud, Z.hud + 4, 1)

    local mark = px(18)
    stamp(KEYCAPS, x + bw - pad - mark / 2, y + px(22), mark, Theme.accent, Z.hud + 6, 1)

    for i = 1, count do
        local item = live[i]
        local ry = y + headH + (i - 1) * rowH
        label(item.name, x + pad, ry + (rowH - L.fBind * 0.72) / 2, Theme.white, L.fBind,
            Z.hud + 10 + i * 6, 1)

        local key = chipText(item)
        local cw = chipWidth(item)
        local cx = x + bw - pad - cw
        local cy = ry + (rowH - L.hudChip) / 2
        rect(cx, cy, cw, L.hudChip, Theme.accent, Z.hud + 12 + i * 6, px(5), 0.95)
        label(key, cx + px(9), cy + (L.hudChip - L.fChip * 0.72) / 2, Theme.white, L.fChip,
            Z.hud + 14 + i * 6, 1)
    end
end

local function drawTip()
    if not S.tip then return end
    local body, mx, my = S.tip[1], S.tip[2], S.tip[3]
    local tw = width(body, L.fSmall) + px(8)
    local th = px(19)
    local w, h = screen()
    local x = clamp(mx + px(14), 4, w - tw - 4)
    local y = clamp(my + px(18), 4, h - th - 4)
    shade(x, y, tw, th, Z.tip - 100, 1, 4)
    frame(x, y, tw, th, Theme.panel, Theme.stroke, Z.tip, 0.99)
    runText(body, x + floor(px(8) / 2), capTop(y + px(4) + 1, L.fSmall), Theme.white,
        L.fSmall, Z.tip + 3, 1)
end

local function runBinds()
    if S.grab or S.focus then return end
    for i = 1, #S.binds do
        local item = S.binds[i]
        if item.bindMode == "always" then
            if item.kind == "keybind" then
                if not item.on then
                    item.on = true
                    setFlag(item, true)
                    fire(item.callback, true)
                end
            elseif not item.bindOn then
                item.bindOn = true
                syncToggle(item)
            end
        end
        local k = item.bindMode ~= "always" and item.bind and Key[item.bind]
        if k then
            if item.bindArmed then
                if not k.down then item.bindArmed = nil end
            elseif item.kind == "keybind" then
                local live = item.on
                if item.bindMode == "toggle" then
                    if k.hit then live = not item.on end
                else
                    live = k.down
                end
                if live ~= item.on then
                    item.on = live
                    setFlag(item, live)
                    fire(item.callback, live)
                end
            elseif item.bindMode == "hold" then
                if item.bindOn ~= k.down then item.bindOn = k.down; syncToggle(item) end
            elseif k.hit then
                item.bindOn = not item.bindOn
                syncToggle(item)
            end
        end
    end
end

local function grabKey()
    if not S.grab then return end
    local item = S.grab
    for _, name in ipairs(Order) do
        local k = Key[name]
        if k.hit and name ~= "m1" and name ~= "m2" then
            item.bind = (name == "esc") and nil or name
            item.bindArmed = true
            item.bindOn = false
            if item.bind then registerBind(item) end
            S.grab, k.hit = nil, false
            Key.m1.hit, Key.m2.hit = false, false
            fire(item.onBind, item.bind)
            break
        end
    end
end

local function typing()
    if S.grab then return end
    local target = S.focus
    if type(target) ~= "table" then return end
    if target.kind == "hex" then
        if Key.esc.hit or Key.enter.hit then
            if Key.enter.hit then commitHex(target) end
            S.focus = nil
            Key.esc.hit, Key.enter.hit = false, false
            return
        end
        edit(target, "hex", "[0-9a-fA-F]", 6)
        return
    end
    if target.buf then
        if Key.esc.hit or Key.enter.hit then
            if Key.enter.hit then commitNumber(target) end
            target.buf, S.focus = nil, nil
            Key.esc.hit, Key.enter.hit = false, false
            return
        end
        edit(target, "buf", "[%d%.%-]")
        return
    end
    if Key.esc.hit or Key.enter.hit then
        S.focus = nil
        Key.esc.hit, Key.enter.hit = false, false
        return
    end
    if edit(target, "value") then
        setFlag(target, target.value)
        fire(target.callback, target.value)
    end
end

local function frame()
    S.frames = S.frames + 1
    readInput()
    S.tip = nil
    S.layer, S.floor = 0, 0
    if anyPopup() then S.floor = Z.drop end

    local toggle = Key[S.key]
    if toggle and toggle.hit and not S.grab and not S.focus then S.open = not S.open end
    S.show = glide(S.show, S.open and 1 or 0, 0.26)

    local capture = S.open and S.show > 0.02
    if S.capturing ~= capture then
        S.capturing = capture
        pcall(grabInput, not capture)
    end

    newFrame()
    drawBindList()
    drawPopups()
    drawWindow(S.show)
    drawNotes()
    drawTip()

    runBinds()
    grabKey()
    typing()
    if Key.m1.hit and not S.tookClick and type(S.focus) == "table" then
        commitEntry(S.focus)
        S.focus = nil
    end
    hideRest()
end

local function report(msg)
    msg = tostring(msg)
    if S.lastError == msg then return end
    S.lastError = msg
    local out = (type(warn) == "function") and warn or print
    pcall(out, "[menu] " .. msg)
end

local function step()
    local ok, err = pcall(frame)
    if not ok then
        report(err)
        pcall(hideRest)
    end
end

local function kill()
    S.alive = false
    wipe()
    S.tabs, S.items, S.notes, S.binds = {}, {}, {}, {}
    for k in pairs(S.flags) do S.flags[k] = nil end
    S.active, S.focus, S.grab = nil, nil, nil
    for i = #S.popups, 1, -1 do S.popups[i] = nil end
    pcall(grabInput, true)
    if _G.__menu == S then _G.__menu = nil end
end

local Menu = {}

function Menu.notify(title, body, life)
    S.notes[#S.notes + 1] = {
        title = tostring(title or ""), body = body and tostring(body) or nil,
        life = tonumber(life) or 4, born = now(), slip = 1, show = 0,
    }
end

function Menu.new(cfg)
    cfg = cfg or {}
    S.tabs, S.items, S.binds = {}, {}, {}
    for k in pairs(S.flags) do S.flags[k] = nil end
    S.active, S.focus, S.grab = nil, nil, nil
    for i = #S.popups, 1, -1 do S.popups[i] = nil end

    rescale(cfg.Scale)
    iconSheet(BLADES, Theme.help)
    iconSheet(BLADES, Theme.white)
    iconSheet(KEYCAPS, Theme.accent)
    iconSheet(COPYMARK, Theme.dim)
    iconSheet(COPYMARK, Theme.accent)
    S.title = tostring(cfg.Name or "menu")
    S.suffix = cfg.Suffix and tostring(cfg.Suffix) or nil
    S.key = lower(tostring(cfg.Key or "f1"))
    if not Key[S.key] then S.key = "f1" end

    local w, h = screen()
    S.w = clamp(cfg.Width and px(cfg.Width) or L.win, 200, max(200, w - 20))
    S.h = clamp(cfg.Height and px(cfg.Height) or L.win, 160, max(160, h - 20))
    S.x = floor(clamp((w - S.w) / 2, 6, max(6, w - S.w - 6)))
    S.y = floor(clamp((h - S.h) / 2, 6, max(6, h - S.h - 6)))
    S.open = cfg.Open ~= false

    local win = {}

    function win:Tab(name)
        local tab = { name = tostring(name or "Tab"), panels = {} }
        function tab:Panel(c) return newPanel(tab, c or {}) end
        S.tabs[#S.tabs + 1] = tab
        if not S.active then S.active = tab end
        return tab
    end

    function win:Show(on) S.open = on and true or false end
    function win:Flags() return S.flags end
    function win:Unload() kill() end
    return win
end

Menu.flags = S.flags
Menu.unload = kill
Menu.step = step
Menu.theme = Theme
Menu.metrics = L
Menu.stock = Stock
Menu.paints = Paints

function Menu.binds(on)
    S.hud = on and true or false
end

function Menu.key(k)
    k = lower(tostring(k or ""))
    if Key[k] then S.key = k end
    return S.key
end

function Menu.paint(slot, colour)
    if Theme[slot] == nil then return end
    Theme[slot] = colour
end

if _G.__menu then pcall(_G.__menu.stop) end
_G.__menu = { stop = kill, state = S }

if task and task.spawn then
    task.spawn(function()
        while S.alive do
            step()
            if task.wait then task.wait() elseif wait then wait() else break end
        end
    end)
end

return Menu

end)();
