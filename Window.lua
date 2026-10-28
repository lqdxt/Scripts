local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local ParentGui = gethui and gethui() or CoreGui or player:WaitForChild("PlayerGui")

local C = {
 strip = Color3.fromRGB(32, 33, 36),
 stripHover = Color3.fromRGB(41, 42, 45),
 toolbar = Color3.fromRGB(53, 54, 58),
 hover = Color3.fromRGB(63, 65, 69),
 omnibox = Color3.fromRGB(32, 33, 36),
 chip = Color3.fromRGB(60, 64, 67),
 border = Color3.fromRGB(70, 72, 76),
 divider = Color3.fromRGB(32, 33, 36),
 sep = Color3.fromRGB(95, 99, 104),
 focus = Color3.fromRGB(138, 180, 248),
 text = Color3.fromRGB(232, 234, 237),
 dim = Color3.fromRGB(154, 160, 166),
 disabled = Color3.fromRGB(95, 99, 104),
 ntp = Color3.fromRGB(32, 33, 36),
 ntpBox = Color3.fromRGB(48, 49, 52),
 avatar = Color3.fromRGB(95, 99, 104),
 page = Color3.fromRGB(255, 255, 255),
 pageText = Color3.fromRGB(0, 0, 0),
 pageDim = Color3.fromRGB(95, 99, 104),
 msgText = Color3.fromRGB(32, 33, 36),
 link = Color3.fromRGB(0, 0, 238),
 accent = Color3.fromRGB(26, 115, 232),
 error = Color3.fromRGB(217, 48, 37),
 close = Color3.fromRGB(232, 17, 35),
 tabOn = Color3.fromRGB(53, 54, 58),
}

local PAGE_KEYS = {page = true, pageText = true, pageDim = true, msgText = true, link = true, accent = true, error = true, close = true}
local CHROME_KEYS = {"strip", "stripHover", "toolbar", "tabOn", "hover", "omnibox", "chip", "border", "divider", "sep",
 "focus", "text", "dim", "disabled", "ntp", "ntpBox", "avatar"}
local BaseColors: {[string]: Color3} = {}
for _, k in CHROME_KEYS do BaseColors[k] = C[k] end

local function NormalizePalette(over: {[string]: Color3}): {[string]: Color3}
 local out, used = {}, {}
 for k in PAGE_KEYS do used[C[k]:ToHex()] = true end
 for _, k in CHROME_KEYS do
  local c = over[k] or BaseColors[k]
  local r, g, b = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)
  while used[c:ToHex()] do
   b = (b + 1) % 256
   c = Color3.fromRGB(r, g, b)
  end
  used[c:ToHex()] = true
  out[k] = c
 end
 return out
end

local function RGB(r: number, g: number, b: number): Color3 return Color3.fromRGB(r, g, b) end

local Designs: {[string]: any} = {
 Chrome = {
  colors = {}, tabCurved = true, tabSeps = true, tabRadius = 8, sidebar = false,
  omniRadius = UDim.new(1, 0), btnRadius = UDim.new(1, 0),
  placeholder = "Search Google or type URL",
 },
 Firefox = {
  colors = {
   strip = RGB(28, 27, 34), stripHover = RGB(53, 52, 61), toolbar = RGB(43, 42, 51), tabOn = RGB(66, 65, 77),
   hover = RGB(82, 82, 94), omnibox = RGB(28, 27, 34), chip = RGB(66, 65, 77), border = RGB(82, 82, 94),
   divider = RGB(28, 27, 34), sep = RGB(91, 91, 102), focus = RGB(0, 221, 255), text = RGB(251, 251, 254),
   dim = RGB(191, 191, 201), disabled = RGB(91, 91, 102), ntp = RGB(28, 27, 34), ntpBox = RGB(43, 42, 51),
   avatar = RGB(91, 91, 102),
  },
  tabCurved = false, tabSeps = false, tabRadius = 6, sidebar = false,
  omniRadius = UDim.new(0, 6), btnRadius = UDim.new(0, 4),
  placeholder = "Search with DuckDuckGo or enter address",
  ntp = "tiles",
 },
 Zen = {
  colors = {
   strip = RGB(22, 22, 22), stripHover = RGB(36, 36, 36), toolbar = RGB(30, 30, 30), tabOn = RGB(48, 48, 48),
   hover = RGB(54, 54, 54), omnibox = RGB(44, 44, 44), chip = RGB(60, 60, 60), border = RGB(50, 50, 50),
   divider = RGB(30, 30, 30), sep = RGB(70, 70, 70), focus = RGB(255, 176, 136), text = RGB(235, 235, 235),
   dim = RGB(160, 160, 160), disabled = RGB(95, 95, 95), ntp = RGB(24, 24, 24), ntpBox = RGB(40, 40, 40),
   avatar = RGB(90, 90, 90),
  },
  tabCurved = false, tabSeps = false, tabRadius = 10, sidebar = true,
  omniRadius = UDim.new(0, 10), btnRadius = UDim.new(0, 8),
  placeholder = "Search with DuckDuckGo or enter address",
  ntp = "clock",
 },
 Brave = {
  colors = {
   strip = RGB(20, 21, 27), stripHover = RGB(36, 38, 50), toolbar = RGB(30, 32, 42), tabOn = RGB(30, 32, 42),
   hover = RGB(51, 54, 70), omnibox = RGB(20, 21, 27), chip = RGB(51, 54, 70), border = RGB(60, 63, 80),
   divider = RGB(20, 21, 27), sep = RGB(84, 88, 110), focus = RGB(255, 118, 84), text = RGB(240, 241, 245),
   dim = RGB(160, 164, 180), disabled = RGB(90, 94, 112), ntp = RGB(20, 21, 27), ntpBox = RGB(36, 38, 50),
   avatar = RGB(84, 88, 110),
  },
  tabCurved = true, tabSeps = true, tabRadius = 8, sidebar = false,
  omniRadius = UDim.new(1, 0), btnRadius = UDim.new(1, 0),
  placeholder = "Search Brave or type URL",
  ntp = "photo",
 },
 DuckDuckGo = {
  colors = {
   strip = RGB(24, 24, 24), stripHover = RGB(40, 40, 40), toolbar = RGB(37, 37, 37), tabOn = RGB(52, 52, 52),
   hover = RGB(62, 62, 62), omnibox = RGB(24, 24, 24), chip = RGB(62, 62, 62), border = RGB(70, 70, 70),
   divider = RGB(24, 24, 24), sep = RGB(90, 90, 90), focus = RGB(113, 149, 255), text = RGB(240, 240, 240),
   dim = RGB(170, 170, 170), disabled = RGB(100, 100, 100), ntp = RGB(24, 24, 24), ntpBox = RGB(45, 45, 45),
   avatar = RGB(95, 95, 95),
  },
  tabCurved = false, tabSeps = false, tabRadius = 8, sidebar = false,
  omniRadius = UDim.new(0, 8), btnRadius = UDim.new(0, 6),
  placeholder = "Search or enter address",
  ntp = "wordmark", wordmark = "DuckDuckGo", tagline = "Privacy, simplified.",
 },
 Waterfox = {
  colors = {
   strip = RGB(31, 34, 41), stripHover = RGB(49, 54, 66), toolbar = RGB(43, 47, 58), tabOn = RGB(60, 66, 82),
   hover = RGB(72, 79, 98), omnibox = RGB(31, 34, 41), chip = RGB(60, 66, 82), border = RGB(72, 79, 98),
   divider = RGB(31, 34, 41), sep = RGB(92, 99, 120), focus = RGB(0, 149, 221), text = RGB(249, 250, 252),
   dim = RGB(185, 191, 204), disabled = RGB(92, 99, 120), ntp = RGB(31, 34, 41), ntpBox = RGB(43, 47, 58),
   avatar = RGB(92, 99, 120),
  },
  tabCurved = false, tabSeps = false, tabRadius = 4, sidebar = false,
  omniRadius = UDim.new(0, 4), btnRadius = UDim.new(0, 4),
  placeholder = "Search with DuckDuckGo or enter address",
  ntp = "wordmark", wordmark = "Waterfox",
 },
}

local CurrentDesign = "Chrome"
local SIDE_W = 210
local Look = {tabCurved = Designs.Chrome.tabCurved, tabSeps = Designs.Chrome.tabSeps, placeholder = Designs.Chrome.placeholder, sidebar = false}
local CurrentPalette = NormalizePalette(Designs.Chrome.colors)
for k, c in CurrentPalette do C[k] = c end

local AllIcons = setmetatable({}, {__mode = "k"})
local HoverPairs = setmetatable({}, {__mode = "k"})
local CornerTargets: {UICorner} = {}

local FONT = Enum.Font.Roboto
local PAGE_FONT, PAGE_BOLD = Enum.Font.Arial, Enum.Font.ArialBold
local TAB_H, TOOL_H, TAB_BTN_H = 41, 40, 34
local MAX_TAB_W, MIN_TAB_W = 240, 36
local MAX_BLOCKS, MAX_LINKS, MAX_BLOCK_CHARS = 500, 80, 2000

local function Create(class: string, props: {[string]: any}, parent: Instance?): any
 local inst = Instance.new(class)
 for k, v in props do
  (inst :: any)[k] = v
 end
 inst.Parent = parent
 return inst
end

local function Hoverable(btn: GuiButton, normal: Color3, over: Color3)
 local pair = {normal = normal, over = over}
 HoverPairs[pair] = true
 btn.MouseEnter:Connect(function()
  TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = pair.over}):Play()
 end)
 btn.MouseLeave:Connect(function()
  TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = pair.normal}):Play()
 end)
end

type Icon = {root: Frame, parts: {Frame}, strokes: {UIStroke}, color: Color3}

local Icon = {}

function Icon.new(parent: GuiObject, size: number, color: Color3?): Icon
 local root = Create("Frame", {
  Name = "Icon",
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(size, size),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
 }, parent)
 local icon = {root = root, parts = {}, strokes = {}, color = color or C.text}
 AllIcons[icon] = true
 return icon
end

function Icon.line(icon: Icon, x1: number, y1: number, x2: number, y2: number, thick: number)
 local dx, dy = x2 - x1, y2 - y1
 local len = math.sqrt(dx * dx + dy * dy)
 local size = UDim2.fromOffset(len + thick, thick)
 local rot = math.deg(math.atan2(dy, dx))
 if dx == 0 then
  size, rot = UDim2.fromOffset(thick, len + thick), 0
 elseif dy == 0 then
  rot = 0
 end
 local f = Create("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
  Size = size,
  Rotation = rot,
  BackgroundColor3 = icon.color,
  BorderSizePixel = 0,
 }, icon.root)
 Create("UICorner", {CornerRadius = UDim.new(0.5, 0)}, f)
 table.insert(icon.parts, f)
end

function Icon.poly(icon: Icon, pts: {Vector2}, closed: boolean, thick: number)
 for i = 1, #pts - 1 do
  Icon.line(icon, pts[i].X, pts[i].Y, pts[i + 1].X, pts[i + 1].Y, thick)
 end
 if closed and #pts > 2 then
  Icon.line(icon, pts[#pts].X, pts[#pts].Y, pts[1].X, pts[1].Y, thick)
 end
end

function Icon.oval(icon: Icon, cx: number, cy: number, rx: number, ry: number, thick: number)
 local f = Create("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromOffset(cx, cy),
  Size = UDim2.fromOffset(2 * rx - thick, 2 * ry - thick),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
 }, icon.root)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, f)
 table.insert(icon.strokes, Create("UIStroke", {Color = icon.color, Thickness = thick}, f))
end

function Icon.dot(icon: Icon, cx: number, cy: number, r: number)
 local f = Create("Frame", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromOffset(cx, cy),
  Size = UDim2.fromOffset(r * 2, r * 2),
  BackgroundColor3 = icon.color,
  BorderSizePixel = 0,
 }, icon.root)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, f)
 table.insert(icon.parts, f)
end

function Icon.tint(icon: Icon, color: Color3)
 icon.color = color
 for _, f in icon.parts do f.BackgroundColor3 = color end
 for _, s in icon.strokes do s.Color = color end
end

function Icon.clear(icon: Icon)
 for _, c in icon.root:GetChildren() do c:Destroy() end
 table.clear(icon.parts)
 table.clear(icon.strokes)
end

local function Esc(s: string): string
 s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
 return s
end

local gui = Create("ScreenGui", {
 Name = "ChromeWindow",
 ResetOnSpawn = false,
 ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, ParentGui)

local window = Create("Frame", {
 Name = "Window",
 Size = UDim2.fromOffset(820, 520),
 AnchorPoint = Vector2.new(0.5, 0.5),
 Position = UDim2.fromScale(0.5, 0.5),
 BackgroundColor3 = C.strip,
 BorderSizePixel = 0,
}, gui)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, window)
Create("UIStroke", {Color = C.border, Thickness = 1}, window)

local uiScale = Create("UIScale", {Scale = 1}, window)
local BASE_W, BASE_H = 1000, 650
local MIN_SCALE, MAX_SCALE = 0.5, 1.5

local function ComputeScale(): number
 local cam = workspace.CurrentCamera
 local v = cam and cam.ViewportSize or Vector2.new(BASE_W, BASE_H)
 return math.clamp(math.min(v.X / BASE_W, v.Y / BASE_H), MIN_SCALE, MAX_SCALE)
end
uiScale.Scale = ComputeScale()

local tabBar = Create("Frame", {
 Name = "TabBar",
 Size = UDim2.new(1, 0, 0, TAB_H),
 BackgroundColor3 = C.strip,
 BorderSizePixel = 0,
}, window)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, tabBar)

local tabHolder = Create("Frame", {
 Name = "Tabs",
 Position = UDim2.fromOffset(8, 0),
 Size = UDim2.new(1, -150, 1, 0),
 BackgroundTransparency = 1,
}, tabBar)
Create("UIListLayout", {
 FillDirection = Enum.FillDirection.Horizontal,
 SortOrder = Enum.SortOrder.LayoutOrder,
 VerticalAlignment = Enum.VerticalAlignment.Bottom,
 Padding = UDim.new(0, 0),
}, tabHolder)

local zenSide = Create("Frame", {
 Name = "Sidebar", Position = UDim2.fromOffset(0, TAB_H), Size = UDim2.new(0, SIDE_W, 1, -TAB_H),
 BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
}, window)

local newTabHolder = Create("Frame", {
 Name = "NewTabHolder",
 LayoutOrder = 9999,
 Size = UDim2.fromOffset(36, TAB_BTN_H),
 BackgroundTransparency = 1,
}, tabHolder)

local newTabBtn = Create("TextButton", {
 Name = "NewTab",
 AnchorPoint = Vector2.new(0.5, 0.5),
 Position = UDim2.fromScale(0.5, 0.5),
 Size = UDim2.fromOffset(28, 28),
 BackgroundColor3 = C.strip,
 BorderSizePixel = 0,
 Text = "",
 AutoButtonColor = false,
}, newTabHolder)
table.insert(CornerTargets, Create("UICorner", {CornerRadius = UDim.new(1, 0)}, newTabBtn))
Hoverable(newTabBtn, C.strip, C.hover)
local newTabLabel = Create("TextLabel", {
 Name = "SideLabel", Position = UDim2.fromOffset(36, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
 Text = "New Tab", TextColor3 = C.dim, TextSize = 13, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, Visible = false,
}, newTabBtn)
do
 local plus = Icon.new(newTabBtn, 16)
 Icon.line(plus, 8, 3, 8, 13, 1.6)
 Icon.line(plus, 3, 8, 13, 8, 1.6)
end

local controls = Create("Frame", {
 Name = "Controls",
 Size = UDim2.fromOffset(138, 32),
 Position = UDim2.new(1, -138, 0, 0),
 BackgroundTransparency = 1,
}, tabBar)

local function ControlButton(x: number, hoverColor: Color3, hoverT: number, hoverIcon: Color3, topRight: boolean?): (TextButton, any)
 local b = Create("TextButton", {
  Size = UDim2.fromOffset(46, 32),
  Position = UDim2.fromOffset(x, 0),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
 }, controls)
 local shapes = {}
 local function shape(props)
  props.BackgroundColor3 = hoverColor
  props.BackgroundTransparency = 1
  props.BorderSizePixel = 0
  local f = Create("Frame", props, b)
  table.insert(shapes, f)
  return f
 end
 local bg = shape({Size = UDim2.fromScale(1, 1)})
 if topRight then
  Create("UICorner", {CornerRadius = UDim.new(0, 8)}, bg)
  shape({Size = UDim2.new(1, -8, 1, 0)})
  shape({Position = UDim2.fromOffset(0, 8), Size = UDim2.new(1, 0, 1, -8)})
 end
 local icon = Icon.new(b, 10)
 local info = TweenInfo.new(0.1)
 b.MouseEnter:Connect(function()
  for _, s in shapes do
   TweenService:Create(s, info, {BackgroundTransparency = hoverT}):Play()
  end
  Icon.tint(icon, hoverIcon)
 end)
 b.MouseLeave:Connect(function()
  for _, s in shapes do
   TweenService:Create(s, info, {BackgroundTransparency = 1}):Play()
  end
  Icon.tint(icon, C.text)
 end)
 return b, icon
end

local minBtn, minIcon = ControlButton(0, Color3.new(1, 1, 1), 0.9, C.text)
local maxBtn, maxIcon = ControlButton(46, Color3.new(1, 1, 1), 0.9, C.text)
local closeBtn, closeIcon = ControlButton(92, C.close, 0, Color3.new(1, 1, 1), true)

local function DrawMaxIcon(restored: boolean)
 local V = Vector2.new
 Icon.clear(maxIcon)
 if restored then
  Icon.poly(maxIcon, {V(2.5, 2.5), V(2.5, 0.5), V(9.5, 0.5), V(9.5, 7.5), V(7.5, 7.5)}, false, 1)
  Icon.poly(maxIcon, {V(0.5, 2.5), V(7.5, 2.5), V(7.5, 9.5), V(0.5, 9.5)}, true, 1)
 else
  Icon.poly(maxIcon, {V(0.5, 0.5), V(9.5, 0.5), V(9.5, 9.5), V(0.5, 9.5)}, true, 1)
 end
end
Icon.line(minIcon, 0, 5.5, 10, 5.5, 1)
DrawMaxIcon(false)
Icon.line(closeIcon, 0.5, 0.5, 9.5, 9.5, 1)
Icon.line(closeIcon, 9.5, 0.5, 0.5, 9.5, 1)

local toolbar = Create("Frame", {
 Name = "Toolbar",
 Position = UDim2.fromOffset(0, TAB_H),
 Size = UDim2.new(1, 0, 0, TOOL_H),
 BackgroundColor3 = C.toolbar,
 BorderSizePixel = 0,
}, window)
Create("Frame", {
 Name = "Divider",
 AnchorPoint = Vector2.new(0, 1),
 Position = UDim2.fromScale(0, 1),
 Size = UDim2.new(1, 0, 0, 1),
 BackgroundColor3 = C.divider,
 BorderSizePixel = 0,
}, toolbar)

local function ToolButton(pos: UDim2, size: number, iconSize: number, parent: GuiObject?, normal: Color3?): (TextButton, any)
 local base = normal or C.toolbar
 local b = Create("TextButton", {
  Position = pos,
  Size = UDim2.fromOffset(size, size),
  BackgroundColor3 = base,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
 }, parent or toolbar)
 table.insert(CornerTargets, Create("UICorner", {CornerRadius = UDim.new(1, 0)}, b))
 Hoverable(b, base, C.hover)
 return b, Icon.new(b, iconSize)
end

local backBtn, backIcon = ToolButton(UDim2.fromOffset(8, 6), 28, 16)
local fwdBtn, fwdIcon = ToolButton(UDim2.fromOffset(40, 6), 28, 16)
local reloadBtn, reloadIcon = ToolButton(UDim2.fromOffset(72, 6), 28, 16)

local omniFrame = Create("Frame", {
 Name = "Omnibox",
 Position = UDim2.fromOffset(108, 4),
 Size = UDim2.new(1, -184, 0, 32),
 BackgroundColor3 = C.omnibox,
 BorderSizePixel = 0,
}, toolbar)
Create("UICorner", {CornerRadius = UDim.new(1, 0)}, omniFrame)
local omniStroke = Create("UIStroke", {Color = C.focus, Thickness = 2, Enabled = false}, omniFrame)

local siteBtn, siteIcon = ToolButton(UDim2.fromOffset(4, 4), 24, 16, omniFrame, C.chip)
local starBtn, starIcon = ToolButton(UDim2.new(1, -28, 0, 4), 24, 16, omniFrame, C.omnibox)

local omnibox = Create("TextBox", {
 Name = "Address",
 Position = UDim2.fromOffset(36, 0),
 Size = UDim2.new(1, -72, 1, 0),
 BackgroundTransparency = 1,
 Text = "",
 PlaceholderText = Look.placeholder,
 PlaceholderColor3 = C.dim,
 TextColor3 = C.text,
 TextSize = 14,
 Font = FONT,
 TextXAlignment = Enum.TextXAlignment.Left,
 TextTruncate = Enum.TextTruncate.AtEnd,
 ClearTextOnFocus = false,
}, omniFrame)

local profileBtn, profileIcon = ToolButton(UDim2.new(1, -68, 0, 6), 28, 24)
local menuBtn, menuIcon = ToolButton(UDim2.new(1, -36, 0, 6), 28, 16)

do
 local V = Vector2.new
 Icon.line(backIcon, 3, 8, 13, 8, 1.6)
 Icon.poly(backIcon, {V(7.5, 3.5), V(3, 8), V(7.5, 12.5)}, false, 1.6)
 Icon.line(fwdIcon, 3, 8, 13, 8, 1.6)
 Icon.poly(fwdIcon, {V(8.5, 3.5), V(13, 8), V(8.5, 12.5)}, false, 1.6)

 local arc = {}
 for i = 0, 15 do
  local a = math.rad(-30 + i * 20)
  table.insert(arc, V(8 + 5 * math.cos(a), 8 + 5 * math.sin(a)))
 end
 Icon.poly(reloadIcon, arc, false, 1.6)
 Icon.poly(reloadIcon, {V(8.6, 0.6), V(11, 3), V(8.6, 5.4)}, false, 1.6)

 Icon.line(siteIcon, 2.5, 5, 7, 5, 1.4)
 Icon.line(siteIcon, 11, 5, 13.5, 5, 1.4)
 Icon.oval(siteIcon, 9, 5, 2, 2, 1.4)
 Icon.line(siteIcon, 2.5, 11, 5, 11, 1.4)
 Icon.line(siteIcon, 9, 11, 13.5, 11, 1.4)
 Icon.oval(siteIcon, 7, 11, 2, 2, 1.4)

 local star = {}
 for i = 0, 9 do
  local a = math.rad(-90 + i * 36)
  local r = if i % 2 == 0 then 6.4 else 2.8
  table.insert(star, V(8 + r * math.cos(a), 8.6 + r * math.sin(a)))
 end
 Icon.poly(starIcon, star, true, 1.2)

 Icon.dot(menuIcon, 8, 3.5, 1.5)
 Icon.dot(menuIcon, 8, 8, 1.5)
 Icon.dot(menuIcon, 8, 12.5, 1.5)

 local av = Create("Frame", {
  Size = UDim2.fromOffset(24, 24),
  BackgroundColor3 = C.avatar,
  BorderSizePixel = 0,
 }, profileIcon.root)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, av)
 for _, r in {{8, 4, 8, 8}, {6, 14, 12, 6}} do
  local part = Create("Frame", {
   Position = UDim2.fromOffset(r[1], r[2]),
   Size = UDim2.fromOffset(r[3], r[4]),
   BackgroundColor3 = C.text,
   BorderSizePixel = 0,
  }, av)
  Create("UICorner", {CornerRadius = UDim.new(1, 0)}, part)
 end
end

local content = Create("Frame", {
 Name = "Content",
 Position = UDim2.fromOffset(0, TAB_H + TOOL_H),
 Size = UDim2.new(1, 0, 1, -(TAB_H + TOOL_H)),
 BackgroundColor3 = C.page,
 BorderSizePixel = 0,
}, window)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, content)
local topFill = Create("Frame", {
 Name = "TopFill",
 Size = UDim2.new(1, 0, 0, 12),
 BackgroundColor3 = C.page,
 BorderSizePixel = 0,
 ZIndex = 0,
}, content)

local SETTINGS_TOP = TAB_H + TOOL_H
local settings = Create("Frame", {
 Name = "Settings", Position = UDim2.fromOffset(0, SETTINGS_TOP), Size = UDim2.new(1, 0, 1, -SETTINGS_TOP),
 BackgroundColor3 = C.ntp, BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, window)
Create("UICorner", {CornerRadius = UDim.new(0, 8)}, settings)
Create("Frame", {Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = C.ntp, BorderSizePixel = 0, ZIndex = 0}, settings)

local settingsSide = Create("Frame", {
 Name = "Sidebar", Size = UDim2.new(0, 200, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
}, settings)
Create("Frame", {
 AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
 BackgroundColor3 = C.border, BorderSizePixel = 0,
}, settingsSide)
Create("TextLabel", {
 Position = UDim2.fromOffset(20, 14), Size = UDim2.new(1, -40, 0, 32), BackgroundTransparency = 1,
 Text = "Settings", TextColor3 = C.text, TextSize = 22, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
}, settingsSide)
local settingsTabList = Create("Frame", {
 Position = UDim2.fromOffset(10, 60), Size = UDim2.new(1, -20, 1, -70), BackgroundTransparency = 1,
}, settingsSide)
Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, settingsTabList)

local settingsMain = Create("Frame", {
 Name = "Main", Position = UDim2.fromOffset(200, 0), Size = UDim2.new(1, -200, 1, 0), BackgroundTransparency = 1,
}, settings)
local settingsTitle = Create("TextLabel", {
 Position = UDim2.fromOffset(24, 14), Size = UDim2.new(1, -90, 0, 32), BackgroundTransparency = 1,
 Text = "", TextColor3 = C.text, TextSize = 22, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
}, settingsMain)
local settingsClose = Create("TextButton", {
 AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16), Size = UDim2.fromOffset(28, 28),
 BackgroundColor3 = C.ntp, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
}, settingsMain)
Create("UICorner", {CornerRadius = UDim.new(1, 0)}, settingsClose)
Hoverable(settingsClose, C.ntp, C.hover)
do
 local x = Icon.new(settingsClose, 16, C.text)
 Icon.line(x, 3.5, 3.5, 12.5, 12.5, 1.6)
 Icon.line(x, 12.5, 3.5, 3.5, 12.5, 1.6)
end
local settingsPages = Create("Frame", {
 Position = UDim2.fromOffset(0, 60), Size = UDim2.new(1, 0, 1, -60), BackgroundTransparency = 1,
}, settingsMain)

type SettingsTab = {name: string, button: TextButton, page: ScrollingFrame}
local settingsTabs: {SettingsTab} = {}
local activeSettingsTab: SettingsTab? = nil

local function SelectSettingsTab(t: SettingsTab)
 activeSettingsTab = t
 for _, o in settingsTabs do
  local on = o == t
  o.page.Visible = on
  o.button.BackgroundTransparency = if on then 0 else 1
  o.button.TextColor3 = if on then C.text else C.dim
 end
 settingsTitle.Text = t.name
end

local function CreateTab(name: string): SettingsTab
 local button = Create("TextButton", {
  LayoutOrder = #settingsTabs + 1, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.chip, BackgroundTransparency = 1,
  BorderSizePixel = 0, AutoButtonColor = false, Text = name, TextColor3 = C.dim, TextSize = 15, Font = FONT,
  TextXAlignment = Enum.TextXAlignment.Left,
 }, settingsTabList)
 Create("UICorner", {CornerRadius = UDim.new(0, 8)}, button)
 Create("UIPadding", {PaddingLeft = UDim.new(0, 14)}, button)
 local page = Create("ScrollingFrame", {
  Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
  ScrollBarThickness = 6, ScrollBarImageColor3 = Color3.fromRGB(193, 193, 193), CanvasSize = UDim2.new(),
  AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
 }, settingsPages)
 Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)}, page)
 Create("UIPadding", {
  PaddingLeft = UDim.new(0, 24), PaddingRight = UDim.new(0, 24), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 16),
 }, page)
 local tab: SettingsTab = {name = name, button = button, page = page}
 table.insert(settingsTabs, tab)
 button.MouseButton1Click:Connect(function() SelectSettingsTab(tab) end)
 if #settingsTabs == 1 then SelectSettingsTab(tab) end
 return tab
end

local function CreateButton(name: string, callback: () -> (), tab: SettingsTab): TextButton
 local order = #tab.page:GetChildren()
 local b = Create("TextButton", {
  LayoutOrder = order, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.ntpBox, BorderSizePixel = 0,
  AutoButtonColor = false, Text = name, TextColor3 = C.text, TextSize = 15, Font = FONT,
  TextXAlignment = Enum.TextXAlignment.Left,
 }, tab.page)
 Create("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
 Create("UIPadding", {PaddingLeft = UDim.new(0, 16)}, b)
 Create("UIStroke", {Color = C.focus, Thickness = 2, Enabled = false, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, b)
 Hoverable(b, C.ntpBox, C.hover)
 b.MouseButton1Click:Connect(function() callback() end)
 return b
end

local function SetButtonActive(button: TextButton, active: boolean)
 local st = button:FindFirstChildOfClass("UIStroke")
 if st then
  st.Color = C.focus
  st.Enabled = active
 end
end

local function CloseSettings() settings.Visible = false end
settingsClose.MouseButton1Click:Connect(CloseSettings)
menuBtn.MouseButton1Click:Connect(function() settings.Visible = not settings.Visible end)

local function UrlDecode(s: string): string
 s = s:gsub("+", " ")
 s = s:gsub("%%(%x%x)", function(h)
  return string.char(tonumber(h, 16) :: number)
 end)
 return s
end

local function HostOf(url: string): string
 local host = url:match("^%a[%w+.-]*://([^/?#]+)") or url
 host = host:gsub("^www%.", "")
 return host
end

local function IsLocal(raw: string): boolean
 local host = raw:match("^%a[%w+.-]*://([^/?#:]+)") or raw:match("^%[([^%]]+)%]") or raw:match("^([^/?#:]+)") or ""
 host = host:lower()
 if host == "localhost" then return true end
 if host:match("^127%.") then return true end
 if host == "0.0.0.0" then return true end
 if host == "::1" then return true end
 return false
end

local Engine = (function()
 local E = {}
 local reqFunc = request or http_request or (syn and syn.request)
 local getAsset = getcustomasset or getsynasset
 local MAX_IMAGES = 80
 local USE_IMAGE_PROXY = true

 local NAMED = {
  black = {0, 0, 0}, white = {255, 255, 255}, red = {255, 0, 0}, green = {0, 128, 0},
  blue = {0, 0, 255}, yellow = {255, 255, 0}, gray = {128, 128, 128}, grey = {128, 128, 128},
  silver = {192, 192, 192}, maroon = {128, 0, 0}, purple = {128, 0, 128}, fuchsia = {255, 0, 255},
  magenta = {255, 0, 255}, lime = {0, 255, 0}, olive = {128, 128, 0}, navy = {0, 0, 128},
  teal = {0, 128, 128}, aqua = {0, 255, 255}, cyan = {0, 255, 255}, orange = {255, 165, 0},
  pink = {255, 192, 203}, brown = {165, 42, 42}, gold = {255, 215, 0}, indigo = {75, 0, 130},
  violet = {238, 130, 238}, crimson = {220, 20, 60}, coral = {255, 127, 80}, salmon = {250, 128, 114},
  tomato = {255, 99, 71}, khaki = {240, 230, 140}, beige = {245, 245, 220}, ivory = {255, 255, 240},
  lavender = {230, 230, 250}, turquoise = {64, 224, 208}, tan = {210, 180, 140},
  darkgray = {169, 169, 169}, darkgrey = {169, 169, 169}, lightgray = {211, 211, 211},
  lightgrey = {211, 211, 211}, dimgray = {105, 105, 105}, dimgrey = {105, 105, 105},
  darkred = {139, 0, 0}, darkgreen = {0, 100, 0}, darkblue = {0, 0, 139}, lightblue = {173, 216, 230},
  lightgreen = {144, 238, 144}, skyblue = {135, 206, 235}, royalblue = {65, 105, 225},
  steelblue = {70, 130, 180}, slategray = {112, 128, 144}, slategrey = {112, 128, 144},
  whitesmoke = {245, 245, 245}, orangered = {255, 69, 0}, firebrick = {178, 34, 34},
  forestgreen = {34, 139, 34}, seagreen = {46, 139, 87}, chocolate = {210, 105, 30},
  hotpink = {255, 105, 180}, deeppink = {255, 20, 147}, darkorange = {255, 140, 0},
  midnightblue = {25, 25, 112}, dodgerblue = {30, 144, 255}, rebeccapurple = {102, 51, 153},
  aliceblue = {240, 248, 255}, gainsboro = {220, 220, 220}, snow = {255, 250, 250},
  honeydew = {240, 255, 240}, mintcream = {245, 255, 250}, azure = {240, 255, 255},
  lightyellow = {255, 255, 224}, lightpink = {255, 182, 193}, plum = {221, 160, 221},
  orchid = {218, 112, 214}, sienna = {160, 82, 45}, peru = {205, 133, 63}, wheat = {245, 222, 179},
  darkslategray = {47, 79, 79}, darkslategrey = {47, 79, 79}, cornflowerblue = {100, 149, 237},
  deepskyblue = {0, 191, 255}, limegreen = {50, 205, 50}, springgreen = {0, 255, 127},
  darkviolet = {148, 0, 211}, mediumpurple = {147, 112, 219}, slateblue = {106, 90, 205},
 }

 local function hsl(h, s, l)
  local v = l + s * math.min(l, 1 - l)
  local sv = (v == 0) and 0 or 2 * (1 - l / v)
  return Color3.fromHSV(((h % 360) / 360), math.clamp(sv, 0, 1), math.clamp(v, 0, 1))
 end

 local function ParseColor(raw)
  if type(raw) ~= "string" then return nil end
  local s = raw:lower()
  s = s:gsub("!important", "")
  s = s:match("^%s*(.-)%s*$")
  if s == "" or s == "transparent" or s == "inherit" or s == "currentcolor" or s == "initial" or s == "unset" then
   return nil
  end

  local hex = s:match("^#(%x+)$")
  if hex then
   if #hex == 3 or #hex == 4 then
    local r, g, b = hex:sub(1, 1), hex:sub(2, 2), hex:sub(3, 3)
    if #hex == 4 and tonumber(hex:sub(4, 4) .. hex:sub(4, 4), 16) < 100 then return nil end
    return Color3.fromRGB(tonumber(r .. r, 16), tonumber(g .. g, 16), tonumber(b .. b, 16))
   elseif #hex == 6 or #hex == 8 then
    if #hex == 8 and tonumber(hex:sub(7, 8), 16) < 100 then return nil end
    return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
   end
   return nil
  end

  local fn, args = s:match("^([%a%-]+)%((.*)%)$")
  if fn then
   if fn == "light-dark" then
    local first = args:match("^%s*([^,]+)")
    if first and first:find("%(") then
     first = args:match("^%s*(%a+%b())")
    end
    return ParseColor(first)
   end
   args = args:gsub("[,/]", " ")
   local nums = {}
   for tok in args:gmatch("%S+") do
    local n, pct = tok:match("^(%-?[%d%.]+)(%%?)$")
    if n and tonumber(n) then
     table.insert(nums, {tonumber(n), pct == "%"})
    elseif tok:match("^[%d%.]+deg$") then
     table.insert(nums, {tonumber(tok:match("^([%d%.]+)")), false})
    end
   end
   if #nums < 3 then return nil end
   if #nums >= 4 then
    local a = nums[4][2] and nums[4][1] / 100 or nums[4][1]
    if a < 0.4 then return nil end
   end
   if fn == "rgb" or fn == "rgba" then
    local function ch(t) return math.clamp(t[2] and t[1] * 2.55 or t[1], 0, 255) end
    return Color3.fromRGB(math.floor(ch(nums[1]) + 0.5), math.floor(ch(nums[2]) + 0.5), math.floor(ch(nums[3]) + 0.5))
   elseif fn == "hsl" or fn == "hsla" then
    return hsl(nums[1][1], math.clamp(nums[2][1] / 100, 0, 1), math.clamp(nums[3][1] / 100, 0, 1))
   end
   return nil
  end

  local n = NAMED[s]
  if n then return Color3.fromRGB(n[1], n[2], n[3]) end
  if s:match("^%x%x%x%x%x%x$") then
   return Color3.fromRGB(tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16))
  end
  return nil
 end

 local function FindColor(v)
  local c = ParseColor(v)
  if c then return c end
  for _, pat in ipairs({"rgba?%b()", "hsla?%b()", "#%x+"}) do
   local m = v:match(pat)
   if m then
    local c2 = ParseColor(m)
    if c2 then return c2 end
   end
  end
  for w in v:gmatch("%a+") do
   local n = NAMED[w]
   if n then return Color3.fromRGB(n[1], n[2], n[3]) end
  end
  return nil
 end

 local function Lum(c)
  local function ch(v)
   if v <= 0.03928 then return v / 12.92 end
   return ((v + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * ch(c.R) + 0.7152 * ch(c.G) + 0.0722 * ch(c.B)
 end

 local function Contrast(a, b)
  local la, lb = Lum(a), Lum(b)
  if la < lb then la, lb = lb, la end
  return (la + 0.05) / (lb + 0.05)
 end

 local function Readable(fg, bg, isLink)
  if Contrast(fg, bg) >= 2.5 then return fg end
  if isLink then
   if Contrast(C.focus, bg) >= 3 then return C.focus end
   if Contrast(C.link, bg) >= 3 then return C.link end
  end
  local black, white = Color3.new(0, 0, 0), Color3.new(1, 1, 1)
  if Contrast(black, bg) >= Contrast(white, bg) then return black end
  return white
 end

 E.Lum, E.Contrast, E.Readable, E.ParseColor = Lum, Contrast, Readable, ParseColor

 local function NormalizePath(path)
  local trailing = path:sub(-1) == "/" or path:match("/%.%.?$") ~= nil
  local out = {}
  for seg in path:gmatch("[^/]+") do
   if seg == ".." then
    table.remove(out)
   elseif seg ~= "." then
    table.insert(out, seg)
   end
  end
  local r = "/" .. table.concat(out, "/")
  if trailing and #out > 0 then r = r .. "/" end
  return r
 end

 local function DecodeUrlComponent(s)
  s = s:gsub("%+", " ")
  s = s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
  return s
 end

 local function ResolveUrl(base, href)
  href = href:match("^%s*(.-)%s*$") or ""
  if href == "" or href:sub(1, 1) == "#" then return nil end

  local target = href:match("[?&]uddg=([^&]+)")
  if target and (href:find("duckduckgo.com/l/", 1, true) or href:find("^//duckduckgo.com/l/")) then
   return DecodeUrlComponent(target)
  end

  href = href:gsub("#.*$", "")
  href = href:gsub(" ", "%%20")
  if href == "" then return nil end

  if href:sub(1, 2) == "//" then
   return (base:match("^(%a[%w+.-]*):") or "https") .. ":" .. href
  end
  local scheme = href:match("^(%a[%w+.-]*):")
  if scheme then
   scheme = scheme:lower()
   if scheme == "http" or scheme == "https" then return href end
   return nil
  end

  local origin, rest = base:match("^(https?://[^/?#]+)(.*)$")
  if not origin then return nil end
  local path = rest:match("^([^?#]*)") or ""
  if href:sub(1, 1) == "?" then return origin .. (path == "" and "/" or path) .. href end

  local p, q = href:match("^([^?]*)(.*)$")
  if p:sub(1, 1) == "/" then return origin .. NormalizePath(p) .. q end
  local dir = path:match("^(.*/)") or "/"
  return origin .. NormalizePath(dir .. p) .. q
 end

 local NAMED_ENT = {
  nbsp = " ", lt = "<", gt = ">", quot = '"', apos = "'", copy = "©", reg = "®", trade = "™",
  mdash = "—", ndash = "–", hellip = "…", rsquo = "’", lsquo = "‘", rdquo = "”", ldquo = "“",
  bull = "•", middot = "·", laquo = "«", raquo = "»", rarr = "→", larr = "←", uarr = "↑", darr = "↓",
  euro = "€", pound = "£", yen = "¥", cent = "¢", deg = "°", times = "×", divide = "÷",
  plusmn = "±", frac12 = "½", sect = "§", para = "¶", ensp = " ", emsp = " ", thinsp = " ",
  check = "✓", hearts = "♥", infin = "∞", ne = "≠", le = "≤", ge = "≥",
 }

 local function DecodeEntities(s)
  if not s:find("&", 1, true) then return s end
  s = s:gsub("&#(%d+);", function(n)
   local cp = tonumber(n)
   if cp and cp > 0 and cp < 0x110000 then return utf8.char(cp) end
   return ""
  end)
  s = s:gsub("&#[xX](%x+);", function(n)
   local cp = tonumber(n, 16)
   if cp and cp > 0 and cp < 0x110000 then return utf8.char(cp) end
   return ""
  end)
  s = s:gsub("&(%a[%w]*);", function(name)
   return NAMED_ENT[name:lower()]
  end)
  s = s:gsub("&amp;", "&")
  return s
 end

 local function ParseAttrs(tag)
  local attrs = {}
  local pos = tag:find("%s")
  if not pos then return attrs end
  local n = #tag
  while pos <= n do
   local s, e, name = tag:find("^[%s/]*([^%s=/>\"']+)", pos)
   if not s then break end
   pos = e + 1
   local value = ""
   local _, e2 = tag:find("^%s*=%s*", pos)
   if e2 then
    pos = e2 + 1
    local q = tag:sub(pos, pos)
    if q == '"' or q == "'" then
     local close = tag:find(q, pos + 1, true)
     if close then
      value = tag:sub(pos + 1, close - 1)
      pos = close + 1
     else
      value = tag:sub(pos + 1)
      pos = n + 1
     end
    else
     local _, e3, v = tag:find("^([^%s>]+)", pos)
     if v then
      value = v
      pos = e3 + 1
     end
    end
   end
   attrs[name:lower()] = value
  end
  return attrs
 end

 local function StripTag(html, tag)
  local lower = html:lower()
  local openpat = "<" .. tag .. "[^%w%-]"
  local close = "</" .. tag .. ">"
  local out, pos = {}, 1
  while true do
   local s = lower:find(openpat, pos)
   if not s then break end
   local e = lower:find(close, s, true)
   table.insert(out, html:sub(pos, s - 1))
   if not e then
    pos = #html + 1
    break
   end
   pos = e + #close
  end
  table.insert(out, html:sub(pos))
  return table.concat(out)
 end

 local function FindTagEnd(html, from)
  local i = from
  local n = #html
  while i <= n do
   local c = html:sub(i, i)
   if c == ">" then
    return i
   elseif c == '"' then
    local q = html:find('"', i + 1, true)
    i = q and q + 1 or n + 1
   elseif c == "'" then
    local q = html:find("'", i + 1, true)
    i = q and q + 1 or n + 1
   else
    i = i + 1
   end
  end
  return nil
 end

 local function StripCdata(html)
  html = html:gsub("<!%[CDATA%[.-%]%]>", "")
  html = html:gsub("<!%-%-%[.-%]%]%->", "")
  return html
 end

 local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
 local B64IDX = {}
 for i = 1, 64 do B64IDX[B64:byte(i)] = i - 1 end
 B64IDX[45] = 62
 B64IDX[95] = 63

 local function Base64Decode(s)
  local native = (crypt and crypt.base64decode) or base64_decode or base64decode or (base64 and base64.decode)
  if native then
   local ok, res = pcall(native, s)
   if ok and type(res) == "string" and #res > 0 then return res end
  end
  s = s:gsub("[^%w%+/%-_]", "")
  local out, n = {}, 0
  local buf, bits = 0, 0
  for i = 1, #s do
   buf = buf * 64 + (B64IDX[s:byte(i)] or 0)
   bits = bits + 6
   if bits >= 8 then
    bits = bits - 8
    local p = 2 ^ bits
    n = n + 1
    out[n] = string.char(math.floor(buf / p) % 256)
    buf = buf % p
   end
  end
  return table.concat(out)
 end

 local function be32(s, i)
  local a, b, c, d = s:byte(i, i + 3)
  return ((a * 256 + b) * 256 + c) * 256 + d
 end

 local function JpegSize(b)
  local n = #b
  local i = 3
  while i + 9 <= n do
   if b:byte(i) ~= 0xFF then return nil end
   local m = b:byte(i + 1)
   if m == 0xFF then
    i = i + 1
   elseif m == 0xD8 or m == 0x01 or (m >= 0xD0 and m <= 0xD9) then
    i = i + 2
   else
    local len = b:byte(i + 2) * 256 + b:byte(i + 3)
    if m >= 0xC0 and m <= 0xCF and m ~= 0xC4 and m ~= 0xC8 and m ~= 0xCC then
     local h = b:byte(i + 5) * 256 + b:byte(i + 6)
     local w = b:byte(i + 7) * 256 + b:byte(i + 8)
     return w, h
    end
    i = i + 2 + len
   end
  end
  return nil
 end

 local function SniffImage(body)
  if body:sub(1, 8) == "\137PNG\r\n\26\n" and #body >= 24 then
   return "png", be32(body, 17), be32(body, 21)
  end
  if body:sub(1, 3) == "\255\216\255" then
   local w, h = JpegSize(body)
   return "jpg", w, h
  end
  return nil
 end

 local function DecodeDataUri(uri)
  local mime, meta, data = uri:match("^data:([^;,]*)(;?[^,]*),(.*)$")
  if not data then return nil end
  mime = mime:lower()
  if not (mime:find("png") or mime:find("jpe?g")) then return nil end
  if meta:find("base64", 1, true) then
   return Base64Decode(data)
  end
  return DecodeUrlComponent(data)
 end

 local CACHE_DIR = "BrowserWindow_cache"
 local MAX_CACHE_FILES = 200
 local imgCache = {}
 local EXTS = {"png", "jpg"}

 local function EnsureCacheDir()
  if isfolder and makefolder and not isfolder(CACHE_DIR) then
   pcall(makefolder, CACHE_DIR)
  end
 end
 EnsureCacheDir()

 local function HashUrl(s)
  if #s > 512 then s = s:sub(1, 256) .. #s .. s:sub(-256) end
  local h1, h2 = 5381, 52711
  for i = 1, #s do
   local b = s:byte(i)
   h1 = (h1 * 33 + b) % 4294967296
   h2 = (h2 * 31 + b + i) % 4294967296
  end
  return ("%08x%08x"):format(h1, h2)
 end

 local function TrimCache()
  if not (listfiles and delfile and isfolder and isfolder(CACHE_DIR)) then return end
  local files = listfiles(CACHE_DIR)
  if #files <= MAX_CACHE_FILES then return end
  for i = 1, #files - MAX_CACHE_FILES do
   pcall(delfile, files[i])
  end
 end
 TrimCache()

 local function Fetch(u, accept)
  local origin = u:match("^(https?://[^/?#]+)")
  local ok, res = pcall(reqFunc, {
   Url = u, Method = "GET",
   Headers = {Accept = accept, Referer = origin and (origin .. "/") or nil},
  })
  if not ok or type(res) ~= "table" or res.Success == false then return nil end
  local body = res.Body or res.body
  if type(body) ~= "string" or #body == 0 or #body > 16000000 then return nil end
  return body
 end

 local function Download(url)
  if imgCache[url] then return imgCache[url] end
  EnsureCacheDir()
  local key = HashUrl(url)

  for _, ext in ipairs(EXTS) do
   local path = CACHE_DIR .. "/" .. key .. "." .. ext
   if isfile(path) then
    local okR, data = pcall(readfile, path)
    local okA, asset = pcall(getAsset, path)
    if okR and okA and data and #data > 0 then
     local _, w, h = SniffImage(data)
     imgCache[url] = {asset = asset, w = w, h = h}
     return imgCache[url]
    end
   end
  end

  local body
  if url:sub(1, 5) == "data:" then
   body = DecodeDataUri(url)
   if not body or #body == 0 then
    imgCache[url] = {unsupported = true}
    return imgCache[url]
   end
  else
   body = Fetch(url, "image/png,image/jpeg,*/*;q=0.5")
   if not body then return nil end
  end

  local ext, w, h = SniffImage(body)
  if not ext and USE_IMAGE_PROXY and url:sub(1, 5) ~= "data:" then
   local purl = "https://wsrv.nl/?url=" .. HttpService:UrlEncode(url) .. "&output=png&w=1200&we"
   local pbody = Fetch(purl, "image/png,*/*;q=0.5")
   if pbody then
    local e2, w2, h2 = SniffImage(pbody)
    if e2 then ext, w, h, body = e2, w2, h2, pbody end
   end
  end
  if not ext then
   imgCache[url] = {unsupported = true}
   return imgCache[url]
  end

  local path = CACHE_DIR .. "/" .. key .. "." .. ext
  if not pcall(writefile, path, body) then return nil end
  local okA, asset = pcall(getAsset, path)
  if not okA then return nil end

  imgCache[url] = {asset = asset, w = w, h = h}
  return imgCache[url]
 end

 local inflight, MAX_INFLIGHT = 0, 6

 function E.FetchImage(url, cb, alive)
  if imgCache[url] then return cb(imgCache[url]) end
  if not (reqFunc and writefile and getAsset and isfile and readfile) then return cb(nil) end
  task.spawn(function()
   while inflight >= MAX_INFLIGHT do
    task.wait(0.05)
    if alive and not alive() then return end
   end
   if alive and not alive() then return end
   inflight = inflight + 1
   local ok, result = pcall(Download, url)
   inflight = inflight - 1
   if ok then cb(result) else cb(nil) end
  end)
 end

 local function PickSrcset(srcset)
  if not srcset or srcset == "" then return nil end
  local best, bestScore
  for cand in (srcset .. ", "):gmatch("%s*(.-)%s*,%s+") do
   local url, desc = cand:match("^(%S+)%s*(%S*)$")
   if url then
    local est = 400
    local nw = desc:match("^(%d+)w$")
    local nx = desc:match("^([%d%.]+)x$")
    if nw then est = tonumber(nw) elseif nx then est = tonumber(nx) * 400 end
    local score = math.abs(est - 800)
    if not best or score < bestScore then best, bestScore = url, score end
   end
  end
  if not best then
   best = srcset:match("^%s*(%S+)")
  end
  return best
 end

 local function LooksLikePlaceholder(src)
  local l = src:lower()
  if l:sub(1, 15) == "data:image/gif;" or l:sub(1, 14) == "data:image/svg" then return true end
  if l:find("1x1", 1, true) or l:find("blank.", 1, true) or l:find("spacer", 1, true)
   or l:find("placeholder", 1, true) or l:find("pixel.gif", 1, true) then
   return true
  end
  return false
 end

 local function PickImageSrc(attrs, pictureSrcset)
  for _, k in ipairs({"data-src", "data-lazy-src", "data-original", "data-lazy", "data-echo", "data-hi-res-src", "data-lazy-load"}) do
   local v = attrs[k]
   if v and v ~= "" and not v:find("^%s*{") then return DecodeEntities(v) end
  end
  local src = attrs.src
  if src and src ~= "" and not LooksLikePlaceholder(src) then return DecodeEntities(src) end
  local ss = attrs.srcset or attrs["data-srcset"] or attrs["data-lazy-srcset"]
  local pick = PickSrcset(ss and DecodeEntities(ss))
  if pick then return pick end
  pick = PickSrcset(pictureSrcset and DecodeEntities(pictureSrcset))
  if pick then return pick end
  return nil
 end

 local PROPS = {
  color = true, background = true, ["background-color"] = true, ["font-size"] = true,
  ["font-weight"] = true, ["font-style"] = true, ["text-decoration"] = true,
  ["text-decoration-line"] = true, ["text-align"] = true, display = true, visibility = true,
  ["white-space"] = true, ["text-transform"] = true, ["font-family"] = true, opacity = true,
  width = true, height = true, left = true, top = true, ["text-indent"] = true,
  ["background-image"] = true, flex = true, ["flex-grow"] = true, ["flex-direction"] = true,
  ["grid-template-columns"] = true, float = true,
 }

 local INLINE_DISP = {
  inline = true, ["inline-block"] = true, ["inline-flex"] = true, ["inline-grid"] = true,
  contents = true, ["inline-table"] = true,
 }

 local function ParseDecls(body)
  local decls, imp, vars = {}, {}, {}
  for prop, val in body:gmatch("([%w%-]+)%s*:%s*([^;]+)") do
   prop = prop:lower()
   val = val:match("^%s*(.-)%s*$")
   local important = false
   if val:find("!important", 1, true) then
    val = val:gsub("%s*!important", "")
    important = true
   end
   if prop:sub(1, 2) == "--" then
    vars[prop] = val
   elseif PROPS[prop] then
    if important then imp[prop] = val else decls[prop] = val end
   end
  end
  return decls, imp, vars
 end

 local function MatchBrace(s, open)
  local depth = 0
  local i = open
  local n = #s
  while i <= n do
   local c = s:byte(i)
   if c == 123 then
    depth = depth + 1
   elseif c == 125 then
    depth = depth - 1
    if depth == 0 then return i end
   elseif c == 34 or c == 39 then
    local q = s:find(string.char(c), i + 1, true)
    if q then i = q end
   end
   i = i + 1
  end
  return n
 end

 local function MediaApplies(q)
  q = q:lower()
  if q:find("print", 1, true) or q:find("speech", 1, true) then return false end
  if q:find("prefers%-color%-scheme%s*:%s*dark") or q:find("prefers%-reduced") or q:find("forced%-colors")
   or q:find("hover%s*:%s*none") or q:find("pointer%s*:%s*coarse") or q:find("orientation%s*:%s*portrait") then
   return false
  end
  local VW = 820
  for kind, num, unit in q:gmatch("(m[ia][nx])%-width%s*:%s*([%d%.]+)(%a*)") do
   local px = tonumber(num) or 0
   if unit == "em" or unit == "rem" then px = px * 16 end
   if kind == "min" and VW < px then return false end
   if kind == "max" and VW > px then return false end
  end
  return true
 end

 local function ParseSelector(sel)
  sel = sel:match("^%s*(.-)%s*$")
  if sel == "" then return nil end
  if sel == ":root" then sel = "html" end
  if sel:find("[%[:%+~%(%)@|\\&]") then return nil end
  sel = sel:gsub("%s*>%s*", " > ")
  local parts, spec = {}, 0
  local nextChild = false
  for tok in sel:gmatch("%S+") do
   if tok == ">" then
    nextChild = true
   else
    local comp = {classes = {}, child = nextChild}
    nextChild = false
    local tag = tok:match("^([%a%*][%w%-]*)")
    if tag and tag ~= "*" then
     comp.tag = tag:lower()
     spec = spec + 1
    end
    for kind, name in tok:gmatch("([%.#])([%w%-_]+)") do
     if kind == "." then
      table.insert(comp.classes, name)
      spec = spec + 10
     else
      comp.id = name
      spec = spec + 100
     end
    end
    table.insert(parts, comp)
   end
  end
  if #parts == 0 then return nil end
  return parts, spec
 end

 local function Bucket(map, key)
  local b = map[key]
  if not b then
   b = {}
   map[key] = b
  end
  return b
 end

 local function AddRule(prelude, body, S)
  local decls, imp, vars = ParseDecls(body)
  local hasDecl = next(decls) ~= nil or next(imp) ~= nil
  local hasVars = next(vars) ~= nil
  if not hasDecl and not hasVars then return end
  for sel in prelude:gmatch("[^,]+") do
   local trimmed = sel:match("^%s*(.-)%s*$")
   if hasVars and (trimmed == ":root" or trimmed == "html" or trimmed == "body" or trimmed == "*") then
    for k, v in pairs(vars) do S.vars[k] = v end
   end
   if hasDecl then
    local parts, spec = ParseSelector(trimmed)
    if parts then
     S.order = S.order + 1
     local rule = {parts = parts, spec = spec, order = S.order, decls = decls, imp = imp}
     local last = parts[#parts]
     if last.id then
      table.insert(Bucket(S.byId, last.id), rule)
     elseif #last.classes > 0 then
      table.insert(Bucket(S.byClass, last.classes[1]), rule)
     elseif last.tag then
      table.insert(Bucket(S.byTag, last.tag), rule)
     else
      table.insert(S.any, rule)
     end
     S.has = true
    end
   end
  end
 end

 local function ParseCss(css, S, depth)
  css = css:gsub("/%*.-%*/", "")
  local pos, n = 1, #css
  while pos <= n do
   S.count = S.count + 1
   if S.count % 400 == 0 then task.wait() end
   local ob = css:find("{", pos, true)
   local sc = css:find(";", pos, true)
   if not ob then break end
   if sc and sc < ob then
    pos = sc + 1
   else
    local prelude = css:sub(pos, ob - 1):match("^%s*(.-)%s*$")
    local cb = MatchBrace(css, ob)
    local body = css:sub(ob + 1, cb - 1)
    pos = cb + 1
    if prelude:sub(1, 1) == "@" then
     local name = prelude:match("^@([%w%-]+)")
     if depth < 4 and ((name == "media" and MediaApplies(prelude)) or name == "supports" or name == "layer") then
      ParseCss(body, S, depth + 1)
     end
    else
     AddRule(prelude, body, S)
    end
   end
  end
 end

 local function NewCssState()
  return {byId = {}, byClass = {}, byTag = {}, any = {}, vars = {}, order = 0, count = 0, has = false}
 end

 local function CompoundMatches(c, e)
  if c.tag and c.tag ~= e.name then return false end
  if c.id and c.id ~= e.id then return false end
  for _, cl in ipairs(c.classes) do
   if not e.classSet[cl] then return false end
  end
  return true
 end

 local function SelectorMatches(parts, idx, e)
  if not CompoundMatches(parts[idx], e) then return false end
  if idx == 1 then return true end
  if parts[idx].child then
   local p = e.parent
   return p ~= nil and SelectorMatches(parts, idx - 1, p)
  end
  local p = e.parent
  while p do
   if SelectorMatches(parts, idx - 1, p) then return true end
   p = p.parent
  end
  return false
 end

 local function MatchedRules(S, e)
  local out = {}
  local function try(list)
   if not list then return end
   for _, r in ipairs(list) do
    if SelectorMatches(r.parts, #r.parts, e) then table.insert(out, r) end
   end
  end
  try(S.any)
  try(S.byTag[e.name])
  if e.id then try(S.byId[e.id]) end
  for cl, _ in pairs(e.classSet) do try(S.byClass[cl]) end
  table.sort(out, function(a, b)
   if a.spec ~= b.spec then return a.spec < b.spec end
   return a.order < b.order
  end)
  return out
 end

 local function ResolveVars(v, vars)
  if not v:find("var(", 1, true) then return v end
  for _ = 1, 4 do
   local before = v
   v = v:gsub("var%(%s*(%-%-[%w_%-]+)%s*,?%s*([^%)]*)%)", function(name, fb)
    local r = vars[name]
    if r then return r end
    if fb ~= "" then return fb end
    return ""
   end)
   if v == before or not v:find("var(", 1, true) then break end
  end
  return v
 end

 local SIZE_KW = {
  ["xx-small"] = 9, ["x-small"] = 10, small = 13, medium = 16, large = 18, ["x-large"] = 24, ["xx-large"] = 32,
 }

 local function ParseSize(v, parentFs)
  if SIZE_KW[v] then return SIZE_KW[v] end
  if v == "smaller" then return math.max(9, parentFs * 0.83) end
  if v == "larger" then return math.min(64, parentFs * 1.2) end
  local n, unit = v:match("^([%d%.]+)(%a*%%?)$")
  n = tonumber(n)
  if not n then return nil end
  local px
  if unit == "px" or unit == "" then px = n
  elseif unit == "pt" then px = n * 1.333
  elseif unit == "em" then px = n * parentFs
  elseif unit == "rem" then px = n * 16
  elseif unit == "%" then px = n / 100 * parentFs
  elseif unit == "ex" then px = n * parentFs * 0.5
  else return nil end
  if px <= 0 then return 0 end
  return math.clamp(px, 9, 64)
 end

 local function ApplyProp(st, prop, val, p)
  local orig = val
  if orig:find("&", 1, true) then orig = DecodeEntities(orig) end
  val = val:lower()
  if val == "initial" or val == "unset" or val == "revert" then return end
  if val == "inherit" then
   if prop == "color" then st.color = p.color
   elseif prop == "font-size" then st.fs = p.fs
   elseif prop == "font-weight" then st.bold = p.bold
   elseif prop == "text-decoration" or prop == "text-decoration-line" then
    st.underline, st.strike = p.underline, p.strike
   elseif prop == "text-align" then st.align = p.align end
   return
  end

  if prop == "color" then
   if val == "currentcolor" then return end
   local c = ParseColor(val)
   if c then st.color = c end
  elseif prop == "background" or prop == "background-color" or prop == "background-image" then
   if prop ~= "background-image" then
    if val == "transparent" or val == "none" then
     st.bg = nil
    else
     local c = FindColor(val)
     if c then st.bg = c end
    end
   end
   if prop ~= "background-color" then
    local u = orig:match("[uU][rR][lL]%(%s*['\"]?([^'\")]+)['\"]?%s*%)")
    if u then st.bgUrl = u elseif val == "none" then st.bgUrl = nil end
   end
  elseif prop == "font-size" then
   local n = ParseSize(val, p.fs)
   if n then
    if n <= 0 then st.hideCss = true else st.fs = n end
   end
  elseif prop == "font-weight" then
   if val == "bold" or val == "bolder" then st.bold = true
   elseif val == "normal" or val == "lighter" then st.bold = false
   else
    local n = tonumber(val)
    if n then st.bold = n >= 600 end
   end
  elseif prop == "font-style" then
   st.italic = (val:find("italic", 1, true) or val:find("oblique", 1, true)) ~= nil
  elseif prop == "text-decoration" or prop == "text-decoration-line" then
   st.underline = val:find("underline", 1, true) ~= nil
   st.strike = val:find("line-through", 1, true) ~= nil
  elseif prop == "text-align" then
   if val == "center" then st.align = "center"
   elseif val == "right" or val == "end" then st.align = "right"
   elseif val == "left" or val == "start" or val == "justify" then st.align = "left" end
  elseif prop == "display" then
   if val == "none" then
    st.hideCss = true
   else
    st.disp = val:match("^%S+")
    st.flex = (val:find("flex", 1, true) or val:find("grid", 1, true)) ~= nil
   end
  elseif prop == "visibility" then
   if val == "hidden" or val == "collapse" then st.hideCss = true end
  elseif prop == "opacity" then
   local o = tonumber(val)
   if o and o <= 0.01 then st.hideCss = true end
  elseif prop == "white-space" then
   st.pre = val == "pre" or val == "pre-wrap" or val == "pre-line" or val == "break-spaces"
  elseif prop == "text-transform" then
   st.upper = val == "uppercase"
  elseif prop == "font-family" then
   st.mono = (val:find("mono", 1, true) or val:find("courier", 1, true) or val:find("consolas", 1, true)
    or val:find("menlo", 1, true)) ~= nil
  elseif prop == "width" or prop == "height" then
   local n = tonumber(val:match("^([%d%.]+)px$") or val:match("^([%d%.]+)$"))
   if n and n <= 1 then
    if prop == "width" then st.w1 = true else st.h1 = true end
   end
   if prop == "width" then
    local pc = tonumber(val:match("^([%d%.]+)%%$"))
    if pc then st.wpct = pc / 100 elseif n then st.wpx = n end
   end
  elseif prop == "flex" or prop == "flex-grow" then
   if val == "none" then
    st.grow = 0
   elseif val == "auto" then
    st.grow = 1
   else
    local g = tonumber(val:match("^([%d%.]+)"))
    if g then st.grow = g end
   end
  elseif prop == "flex-direction" then
   if val:find("column", 1, true) then st.colDir = true else st.colDir = nil end
  elseif prop == "grid-template-columns" then
   local n2 = tonumber(val:match("repeat%(%s*(%d+)"))
   if not n2 then
    if val:find("auto-fit", 1, true) or val:find("auto-fill", 1, true) then
     n2 = 3
    else
     local stripped = val:gsub("%b()", "x")
     local cnt = 0
     for _ in stripped:gmatch("%S+") do cnt = cnt + 1 end
     n2 = cnt
    end
   end
   if n2 and n2 >= 1 then st.gridN = math.min(n2, 6) end
  elseif prop == "float" then
   if val == "left" or val == "right" then st.float = val else st.float = nil end
  elseif prop == "left" or prop == "top" or prop == "text-indent" then
   local neg = tonumber(val:match("^%-([%d%.]+)"))
   if neg and neg >= 500 then st.hideCss = true end
  end
 end

 local BLOCK_TAGS = {
  p = true, div = true, tr = true, ul = true, ol = true, table = true, section = true, article = true,
  header = true, footer = true, nav = true, main = true, blockquote = true, pre = true, form = true,
  dd = true, dt = true, dl = true, tbody = true, thead = true, tfoot = true, aside = true, td = true,
  th = true, li = true, h1 = true, h2 = true, h3 = true, h4 = true, h5 = true, h6 = true,
  caption = true, figure = true, figcaption = true, address = true, details = true, summary = true,
  fieldset = true, legend = true, center = true, marquee = true, body = true, html = true,
  hgroup = true, menu = true, dir = true, textarea = true,
 }

 local VOID = {
  area = true, base = true, br = true, col = true, embed = true, hr = true, img = true, input = true,
  link = true, meta = true, param = true, source = true, track = true, wbr = true,
 }

 local CLOSES = {
  li = {li = true},
  dt = {dt = true, dd = true},
  dd = {dt = true, dd = true},
  option = {option = true},
  tr = {td = true, th = true, tr = true},
  td = {td = true, th = true},
  th = {td = true, th = true},
  tbody = {td = true, th = true, tr = true, thead = true, tbody = true, tfoot = true},
  thead = {td = true, th = true, tr = true, thead = true, tbody = true, tfoot = true},
  tfoot = {td = true, th = true, tr = true, thead = true, tbody = true, tfoot = true},
 }
 local P_SET = {p = true}

 local UA = {
  h1 = {fsMul = 2, bold = true}, h2 = {fsMul = 1.5, bold = true}, h3 = {fsMul = 1.17, bold = true},
  h4 = {bold = true}, h5 = {fsMul = 0.83, bold = true}, h6 = {fsMul = 0.67, bold = true},
  b = {bold = true}, strong = {bold = true}, th = {bold = true, align = "center"},
  i = {italic = true}, em = {italic = true}, cite = {italic = true}, dfn = {italic = true},
  var = {italic = true}, address = {italic = true},
  u = {underline = true}, ins = {underline = true},
  s = {strike = true}, strike = {strike = true}, del = {strike = true},
  code = {mono = true}, kbd = {mono = true}, samp = {mono = true}, tt = {mono = true},
  pre = {mono = true, pre = true},
  small = {fsMul = 0.83}, big = {fsMul = 1.17}, sub = {fsMul = 0.75}, sup = {fsMul = 0.75},
  mark = {bg = Color3.fromRGB(255, 255, 0), color = Color3.new(0, 0, 0)},
  center = {align = "center"}, caption = {align = "center"},
 }
 local FONT_SIZES = {10, 13, 16, 18, 24, 32, 48}

 local function Collapse(s)
  s = s:gsub("%s+", " ")
  return s:match("^%s*(.-)%s*$") or ""
 end

 local function SafeCut(t, n)
  if n <= 0 then return "" end
  if #t <= n then return t end
  local i = n
  while i > 0 do
   local b = t:byte(i + 1)
   if b and b >= 0x80 and b < 0xC0 then i = i - 1 else break end
  end
  return t:sub(1, i)
 end

 local STRIP = {
  "script", "style", "svg", "title", "template", "head", "canvas", "audio", "object",
  "embed", "math", "iframe", "frame", "frameset", "noframes",
 }

 function E.HTML(html, baseUrl, extraCss)
  local rawTitle = html:match("<[tT][iI][tT][lL][eE][^>]*>(.-)</[tT][iI][tT][lL][eE]>")
  local title = rawTitle and Collapse(DecodeEntities(rawTitle)) or nil
  if title == "" then title = nil end

  html = html:gsub("<!%-%-.-%-%->", "")
  html = StripCdata(html)

  local baseTag = html:match("<[bB][aA][sS][eE]%s[^>]*>")
  if baseTag then
   local a = ParseAttrs(baseTag:sub(2, -2))
   if a.href then baseUrl = ResolveUrl(baseUrl, DecodeEntities(a.href)) or baseUrl end
  end

  local cssParts = {}
  if extraCss and extraCss ~= "" then table.insert(cssParts, extraCss) end
  for attrText, body in html:gmatch("<[sS][tT][yY][lL][eE]([^>]*)>(.-)</[sS][tT][yY][lL][eE]>") do
   local a = ParseAttrs("style " .. attrText)
   if not a.media or MediaApplies(a.media) then table.insert(cssParts, body) end
  end
  local S = NewCssState()
  local css = table.concat(cssParts, "\n")
  if #css > 700000 then css = css:sub(1, 700000) end
  if #css > 0 then ParseCss(css, S, 0) end

  for _, tag in ipairs(STRIP) do
   html = StripTag(html, tag)
  end

  local function Run(honor)
   local blocks, links, seen = {}, {}, {}
   local buf, bufBlock = {}, nil
   local pageBg, htmlHasBg = nil, false
   local linkColor = C.link
   local curForm, curSelect, curOption, curTextarea, curButton = nil, nil, nil, nil, nil
   local looseForm = {fields = {}, loose = true}
   local ctxStack = {}
   local bgCount = 0
   local beginCol
   local pictureSrcset = nil
   local imgCount, lastImg = 0, nil
   local nextGroup = 0
   local tagCount = 0

   local root = {name = "#root", attrs = {}, classSet = {}, block = true, st = {color = C.pageText, fs = 16}}
   local stack = {root}

   local function BlockOf(e)
    while e and not e.block do e = e.parent end
    return e or root
   end

   local function BlockBg(be)
    local x = be
    while x and x ~= root and x.name ~= "html" and x.name ~= "body" do
     if x.st.bg then return x.st.bg end
     x = x.parent
    end
    return nil
   end

   local function GroupsOf(e)
    local out, skip = nil, nil
    local x = e
    while x do
     if x.name == "summary" and x.parent and x.parent.name == "details" then skip = x.parent end
     if x.name == "details" and x ~= skip and x.group then
      out = out or {}
      table.insert(out, x.group)
     end
     x = x.parent
    end
    return out
   end

   local function LinkHrefOf(e)
    local x = e
    while x do
     if x.name == "a" and x.href then return x.href end
     x = x.parent
    end
    return nil
   end

   local function ApplyDeclSet(st, set, p)
    if set.background then
     ApplyProp(st, "background", ResolveVars(set.background, S.vars), p)
    end
    for prop, val in pairs(set) do
     if prop ~= "background" then ApplyProp(st, prop, ResolveVars(val, S.vars), p) end
    end
   end

   local function ComputeStyle(e, parent)
    local p = parent.st
    local st = {
     color = p.color, fs = p.fs, bold = p.bold, italic = p.italic, underline = p.underline,
     strike = p.strike, align = p.align, pre = p.pre, mono = p.mono, upper = p.upper,
     hidden = p.hidden, link = p.link,
    }
    local name, attrs = e.name, e.attrs
    local ua = UA[name]
    if ua then
     if ua.fsMul then st.fs = p.fs * ua.fsMul end
     if ua.bold then st.bold = true end
     if ua.italic then st.italic = true end
     if ua.underline then st.underline = true end
     if ua.strike then st.strike = true end
     if ua.mono then st.mono = true end
     if ua.pre then st.pre = true end
     if ua.align then st.align = ua.align end
     if ua.bg then st.bg = ua.bg end
     if ua.color then st.color = ua.color end
    end
    if name == "a" and attrs.href then
     st.link = true
     st.color = linkColor
     st.underline = true
    end
    local al = attrs.align
    if al then
     al = al:lower()
     if al == "center" or al == "right" or al == "left" then st.align = al end
    end
    if attrs.width and (name == "td" or name == "th" or name == "col") then
     local pc = tonumber(attrs.width:match("^%s*([%d%.]+)%%%s*$"))
     local px = tonumber(attrs.width:match("^%s*(%d+)%s*$"))
     if pc then st.wpct = pc / 100 elseif px then st.wpx = px end
    end
    if attrs.bgcolor then
     local c = ParseColor(attrs.bgcolor)
     if c then st.bg = c end
    end
    if name == "font" then
     if attrs.color then
      local c = ParseColor(attrs.color)
      if c then st.color = c end
     end
     local sz = attrs.size
     if sz then
      local rel, digit = sz:match("^%s*([%+%-]?)(%d)%s*$")
      if digit then
       local idx = tonumber(digit)
       if rel == "+" then idx = 3 + idx elseif rel == "-" then idx = 3 - idx end
       st.fs = FONT_SIZES[math.clamp(idx, 1, 7)]
      end
     end
    elseif name == "body" and attrs.text then
     local c = ParseColor(attrs.text)
     if c then st.color = c end
    end
    if honor then
     if attrs.hidden ~= nil then st.hidden = true end
     if name == "dialog" and attrs.open == nil then st.hidden = true end
    end
    if S.has then
     local matched = MatchedRules(S, e)
     for _, r in ipairs(matched) do ApplyDeclSet(st, r.decls, p) end
     for _, r in ipairs(matched) do
      if next(r.imp) then ApplyDeclSet(st, r.imp, p) end
     end
    end
    if attrs.style then
     local d, imp = ParseDecls(attrs.style)
     ApplyDeclSet(st, d, p)
     ApplyDeclSet(st, imp, p)
    end
    if honor and (st.hideCss or (st.w1 and st.h1)) then st.hidden = true end
    return st
   end

   local function MakeEntry(name, attrs)
    local parent = stack[#stack]
    local e = {name = name, attrs = attrs, id = attrs.id, classSet = {}, parent = parent}
    if attrs.class then
     for cl in attrs.class:gmatch("%S+") do e.classSet[cl] = true end
    end
    e.st = ComputeStyle(e, parent)
    local b = BLOCK_TAGS[name] == true
    local d = e.st.disp
    if d then
     if INLINE_DISP[d] then b = false elseif d ~= "none" then b = true end
    end
    if parent.st.flex and not INLINE_DISP[d or ""] then b = true end
    e.block = b
    if name == "a" and attrs.href then
     e.href = ResolveUrl(baseUrl, DecodeEntities(attrs.href))
    end
    return e
   end

   local function flush()
    local segs, be = buf, bufBlock
    buf, bufBlock = {}, nil
    if #segs == 0 or not be or be.st.hidden then return end

    if be.st.pre then
     segs[1].t = segs[1].t:gsub("^\n+", "")
     segs[#segs].t = segs[#segs].t:gsub("\n+$", "")
    else
     while #segs > 0 and (segs[1].nl or not segs[1].t:find("%S")) do table.remove(segs, 1) end
     while #segs > 0 and (segs[#segs].nl or not segs[#segs].t:find("%S")) do table.remove(segs) end
     if #segs == 0 then return end
     segs[1].t = segs[1].t:gsub("^%s+", "")
     segs[#segs].t = segs[#segs].t:gsub("%s+$", "")
    end

    local bg = BlockBg(be)
    local base = pageBg or C.page
    if bg and bg == base then bg = nil end
    local effBg = bg or base
    local baseColor = Readable(be.st.color or C.pageText, effBg, be.st.link)
    local baseHex = baseColor:ToHex()

    local parts, plain = {}, {}
    local total = 0
    for _, sg in ipairs(segs) do
     local t = sg.t
     local cut = false
     if total + #t > MAX_BLOCK_CHARS then
      t = SafeCut(t, MAX_BLOCK_CHARS - total) .. "…"
      cut = true
     end
     total = total + #t
     if sg.nl then
      table.insert(parts, "\n")
     else
      local st = sg.st
      local s = Esc(t)
      if st.bold and not be.st.bold then s = "<b>" .. s .. "</b>" end
      if st.italic then s = "<i>" .. s .. "</i>" end
      if st.underline then s = "<u>" .. s .. "</u>" end
      if st.strike then s = "<s>" .. s .. "</s>" end
      if sg.bg then s = '<mark color="#' .. sg.bg:ToHex() .. '" transparency="0">' .. s .. "</mark>" end
      local fa = {}
      local hex = Readable(st.color or C.pageText, sg.bg or effBg, st.link):ToHex()
      if hex ~= baseHex then table.insert(fa, 'color="#' .. hex .. '"') end
      if math.floor(st.fs + 0.5) ~= math.floor(be.st.fs + 0.5) then
       table.insert(fa, 'size="' .. math.clamp(math.floor(st.fs + 0.5), 8, 72) .. '"')
      end
      if st.mono and not be.st.mono then table.insert(fa, 'face="RobotoMono"') end
      if #fa > 0 then s = "<font " .. table.concat(fa, " ") .. ">" .. s .. "</font>" end
      table.insert(parts, s)
     end
     table.insert(plain, t)
     if cut then break end
    end
    local plainText = table.concat(plain)
    if not plainText:find("%S") then return end

    local blockHref, uniform, first = nil, true, true
    for _, sg in ipairs(segs) do
     if (not sg.nl) and sg.t:find("%S") then
      if first then
       blockHref = sg.href
       first = false
      elseif sg.href ~= blockHref then
       uniform = false
      end
     end
    end
    if not uniform then blockHref = nil end

    if not blockHref then
     local curHref, curText = nil, {}
     local function commit()
      if curHref and #links < MAX_LINKS and not seen[curHref] then
       local txt = Collapse(table.concat(curText))
       if txt ~= "" then
        seen[curHref] = true
        table.insert(links, {text = txt, url = curHref})
       end
      end
      curText = {}
     end
     for _, sg in ipairs(segs) do
      if sg.href ~= curHref then
       commit()
       curHref = sg.href
      end
      if curHref then table.insert(curText, sg.t) end
     end
     commit()
    end

    local indent = 0
    local x = be
    while x do
     if x.name == "ul" or x.name == "ol" then indent = indent + 20
     elseif x.name == "blockquote" or x.name == "dd" then indent = indent + 24 end
     x = x.parent
    end

    local bullet = nil
    x = be
    while x do
     if x.name == "li" then
      if x.pend then
       x.pend = false
       if x.ordered and x.num then
        bullet = tostring(x.num) .. "."
       else
        local depth = 0
        local y = x.parent
        while y do
         if y.name == "ul" or y.name == "ol" then depth = depth + 1 end
         y = y.parent
        end
        bullet = (depth <= 1 and "•") or (depth == 2 and "◦") or "▪"
       end
      end
      break
     end
     x = x.parent
    end

    local block = {
     kind = "text", tag = be.name, rich = table.concat(parts), plain = plainText,
     size = be.st.fs, bold = be.st.bold, mono = be.st.mono, color = baseColor, bg = bg,
     align = be.st.align or "left", indent = indent, bullet = bullet, href = blockHref,
    }

    x = be
    while x do
     if x.name == "summary" then
      local d = x.parent
      if d and d.name == "details" and d.group then
       d.hasSummary = true
       block.kind = "summary"
       block.gid = d.group
       block.open = d.attrs.open ~= nil
       block.href = nil
      end
      break
     end
     x = x.parent
    end

    x = be
    while x do
     if x.name == "marquee" then
      block.marquee = {
       dir = (x.attrs.direction or "left"):lower(),
       amount = tonumber(x.attrs.scrollamount) or 6,
       delay = tonumber(x.attrs.scrolldelay) or 85,
      }
      block.href = nil
      break
     end
     x = x.parent
    end

    block.groups = GroupsOf(be)
    lastImg = nil
    if #blocks < MAX_BLOCKS then table.insert(blocks, block) end
   end

   local endRow
   local function addText(raw)
    local e = stack[#stack]
    if e.st.hidden or raw == "" then return end

    if curSelect then
     if curOption then
      local t = raw:gsub("%s+", " ")
      curOption.text = curOption.text .. DecodeEntities(t)
     end
     return
    end
    if curTextarea then
     curTextarea.value = curTextarea.value .. DecodeEntities(raw)
     return
    end
    if curButton then
     local t = raw:gsub("%s+", " ")
     curButton.text = curButton.text .. DecodeEntities(t)
     return
    end

    local t
    if e.st.pre then
     t = raw:gsub("\r\n?", "\n")
     t = t:gsub("\t", "    ")
    else
     t = raw:gsub("%s+", " ")
     if t == " " and #buf == 0 then return end
     if #buf > 0 and buf[#buf].nl then t = t:gsub("^ ", "") end
    end
    t = DecodeEntities(t)
    if e.st.upper then t = t:upper() end
    if t == "" then return end

    if e.floatRow then
     local fr = e.floatRow
     e.floatRow = nil
     endRow(fr)
    end
    if e.rowCtx and not e.rowCtx.curCol then beginCol(e.rowCtx, nil) end

    local be = BlockOf(e)
    if #buf == 0 then bufBlock = be end

    local sbg = nil
    local x = e
    while x and not x.block do
     if x.st.bg then
      sbg = x.st.bg
      break
     end
     x = x.parent
    end
    table.insert(buf, {t = t, st = e.st, bg = sbg, href = LinkHrefOf(e)})
   end

   local function register(f)
    f.form = curForm or looseForm
    table.insert(f.form.fields, f)
   end

   local function emit(block, e)
    block.groups = GroupsOf(e)
    if #blocks < MAX_BLOCKS then table.insert(blocks, block) end
   end

   local function ColLen(list)
    local n = 0
    for _, b in ipairs(list) do
     if b.kind == "text" or b.kind == "summary" then
      n = n + #(b.plain or "")
     elseif b.kind == "row" then
      for _, c in ipairs(b.cols) do n = n + (c.len or 0) end
     elseif b.kind ~= "hr" then
      n = n + 40
     end
    end
    return n
   end

   local function endCol(ctx)
    local col = ctx.curCol
    if not col then return end
    flush()
    ctx.curCol = nil
    blocks = ctx.scratch
    if #col.blocks > 0 then
     col.len = ColLen(col.blocks)
     table.insert(ctx.cols, col)
    end
   end

   beginCol = function(ctx, e)
    endCol(ctx)
    local col = {blocks = {}, len = 0}
    if e then
     local st = e.st
     col.frac = st.wpct or (st.wpx and math.clamp(st.wpx / 780, 0.05, 1)) or nil
     col.grow = st.grow
    end
    ctx.curCol = col
    blocks = col.blocks
   end

   local function beginRow(e, kind, gridN)
    flush()
    local ctx = {saved = blocks, scratch = {}, cols = {}, entry = e, kind = kind, gridN = gridN}
    blocks = ctx.scratch
    table.insert(ctxStack, ctx)
    return ctx
   end

   local function finalizeRow(ctx)
    endCol(ctx)
    ctx.done = true
    blocks = ctx.saved
    for _, b in ipairs(ctx.scratch) do table.insert(blocks, b) end
    local cols = ctx.cols
    if #cols == 0 then return end
    local function flat(list)
     for _, c in ipairs(list) do
      for _, b in ipairs(c.blocks) do table.insert(blocks, b) end
     end
    end
    if #cols == 1 or (#cols > 8 and not ctx.gridN) then
     flat(cols)
     return
    end
    local per = ctx.gridN and math.min(ctx.gridN, 8) or #cols
    local i = 1
    while i <= #cols do
     local chunk = {}
     for j = i, math.min(i + per - 1, #cols) do table.insert(chunk, cols[j]) end
     if #chunk == 1 then
      flat(chunk)
     else
      table.insert(blocks, {kind = "row", cols = chunk, rowKind = ctx.kind, groups = GroupsOf(ctx.entry)})
     end
     i = i + per
    end
   end

   endRow = function(ctx)
    if ctx.done then return end
    while #ctxStack > 0 do
     local c = table.remove(ctxStack)
     finalizeRow(c)
     if c == ctx then break end
    end
   end

   local function finishSelect(f, e)
    for _, o in ipairs(f.options) do
     o.text = o.text:match("^%s*(.-)%s*$") or ""
     if o.value == nil then o.value = o.text end
    end
    local sel = 1
    for i, o in ipairs(f.options) do
     if o.selected then
      sel = i
      break
     end
    end
    f.selectedIndex = sel
    f.value = f.options[sel].value
    register(f)
    flush()
    emit({kind = "select", field = f}, e)
   end

   local function closeEntry(e)
    local n = e.name
    if e.block then flush() end
    if e.colCtx then endCol(e.colCtx) end
    if e.floatRow then
     local fr = e.floatRow
     e.floatRow = nil
     endRow(fr)
    end
    if e.rowCtx then endRow(e.rowCtx) end
    if n == "form" then
     curForm = nil
    elseif n == "option" then
     curOption = nil
    elseif n == "select" then
     local f = curSelect
     curSelect, curOption = nil, nil
     if f and #f.options > 0 and not e.st.hidden then finishSelect(f, e) end
    elseif n == "textarea" then
     local f = curTextarea
     curTextarea = nil
     if f and not e.st.hidden then
      f.value = f.value:gsub("^\n", "")
      register(f)
      flush()
      emit({kind = "input", field = f}, e)
     end
    elseif n == "button" then
     local f = curButton
     curButton = nil
     if f and not e.st.hidden then
      f.label = Collapse(f.text)
      if f.label == "" then f.label = (f.value and f.value ~= "") and f.value or "Submit" end
      register(f)
      flush()
      emit({kind = "input", field = f}, e)
     end
    elseif n == "details" then
     if not e.hasSummary and e.group then
      local col = Readable(C.pageText, pageBg or C.page)
      table.insert(blocks, math.min(e.startIdx or (#blocks + 1), #blocks + 1), {
       kind = "summary", rich = "Details", plain = "Details", gid = e.group, open = e.attrs.open ~= nil,
       size = 16, color = col, bold = false, align = "left", indent = 0, groups = GroupsOf(e.parent),
      })
     end
    elseif n == "picture" then
     pictureSrcset = nil
    end
   end

   local function popIf(set)
    while #stack > 1 and set[stack[#stack].name] do
     closeEntry(table.remove(stack))
    end
   end

   local function closeTag(name)
    local idx = nil
    for i = #stack, 2, -1 do
     if stack[i].name == name then
      idx = i
      break
     end
    end
    if not idx then return end
    for _ = #stack, idx, -1 do
     closeEntry(table.remove(stack))
    end
   end

   local function dimAttr(v)
    if not v then return nil end
    return tonumber(v:match("^%s*(%d+)%s*[px]*%s*$"))
   end

   local function emitImage(attrs, e)
    if e.st.hidden then return end
    local raw = PickImageSrc(attrs, pictureSrcset)
    if not raw then return end
    local url
    if raw:sub(1, 5):lower() == "data:" then
     url = raw
    else
     url = ResolveUrl(baseUrl, raw)
    end
    if not url then return end
    local w, h = dimAttr(attrs.width), dimAttr(attrs.height)
    if (w and w <= 2) or (h and h <= 2) then return end
    if imgCount >= MAX_IMAGES or #blocks >= MAX_BLOCKS or lastImg == url then return end
    flush()
    imgCount = imgCount + 1
    lastImg = url
    table.insert(blocks, {
     kind = "img", url = url, alt = Collapse(DecodeEntities(attrs.alt or "")), w = w, h = h,
     href = LinkHrefOf(e), groups = GroupsOf(e),
    })
   end

   local TEXT_TYPES = {
    text = true, search = true, email = true, url = true, tel = true, number = true,
    date = true, time = true, month = true, week = true, ["datetime-local"] = true,
   }

   local function handleInput(attrs, e)
    local ty = (attrs.type or "text"):lower()
    local f = {
     type = ty, name = attrs.name and DecodeEntities(attrs.name),
     value = attrs.value and DecodeEntities(attrs.value),
     placeholder = attrs.placeholder and DecodeEntities(attrs.placeholder),
     disabled = attrs.disabled ~= nil,
    }
    if ty == "hidden" then
     register(f)
     return
    end
    if e.st.hidden then return end
    if TEXT_TYPES[ty] then
     f.type = "text"
    elseif ty == "password" then
     f.type = "password"
    elseif ty == "checkbox" or ty == "radio" then
     f.checked = attrs.checked ~= nil
     f.value = f.value or "on"
    elseif ty == "range" then
     f.min = tonumber(attrs.min) or 0
     f.max = tonumber(attrs.max) or 100
     f.step = tonumber(attrs.step)
     f.value = f.value or tostring((f.min + f.max) / 2)
    elseif ty == "submit" or ty == "image" then
     f.type = "submit"
     f.label = (f.value and f.value ~= "") and f.value or "Submit"
    else
     return
    end
    register(f)
    flush()
    emit({kind = "input", field = f}, e)
   end

   local function openTag(name, attrs, selfClose)
    if BLOCK_TAGS[name] then popIf(P_SET) end
    local closes = CLOSES[name]
    if closes then popIf(closes) end

    local e = MakeEntry(name, attrs)
    if e.block then flush() end

    local par = stack[#stack]
    if par.floatRow and not (e.st.float and e.block) then
     local fr = par.floatRow
     par.floatRow = nil
     endRow(fr)
    end
    if par.rowCtx then
     if e.block or name == "img" or name == "input" then
      beginCol(par.rowCtx, e)
      e.colCtx = par.rowCtx
     end
    elseif e.st.float and e.block and #ctxStack < 4 and not e.st.hidden then
     if not par.floatRow then par.floatRow = beginRow(par, "float", nil) end
     beginCol(par.floatRow, e)
     e.colCtx = par.floatRow
    end

    if name == "br" then
     if not e.st.hidden and #buf > 0 and not curSelect and not curButton then
      table.insert(buf, {t = "\n", nl = true, st = e.st})
     end
     return
    elseif name == "hr" then
     if not e.st.hidden then
      flush()
      emit({kind = "hr"}, e)
     end
     return
    elseif name == "img" then
     emitImage(attrs, e)
     return
    elseif name == "input" then
     handleInput(attrs, e)
     return
    elseif name == "source" then
     local top = stack[#stack]
     if top.name == "picture" and attrs.srcset and not pictureSrcset then
      local ty = (attrs.type or ""):lower()
      if ty == "" or ty:find("png", 1, true) or ty:find("jp", 1, true) then
       pictureSrcset = attrs.srcset
      end
     end
     return
    elseif VOID[name] or selfClose or #stack > 200 then
     return
    end

    table.insert(stack, e)

    if e.block and not e.st.hidden and #ctxStack < 4 then
     if name == "tr" then
      e.rowCtx = beginRow(e, "table", nil)
     elseif e.st.gridN or (e.st.flex and not e.st.colDir) then
      e.rowCtx = beginRow(e, "flex", e.st.gridN)
     end
    end

    if name == "html" or name == "body" then
     local bgc = e.st.bg
     if name == "html" then
      if bgc then
       pageBg = bgc
       htmlHasBg = true
      end
     else
      if bgc and not htmlHasBg then pageBg = bgc end
      if attrs.link then
       local c = ParseColor(attrs.link)
       if c then linkColor = c end
      end
     end
    elseif name == "ul" or name == "ol" then
     e.count = (name == "ol" and tonumber(attrs.start) or 1) - 1
    elseif name == "li" then
     local lst = nil
     for i = #stack - 1, 1, -1 do
      local n2 = stack[i].name
      if n2 == "ul" or n2 == "ol" then
       lst = stack[i]
       break
      end
     end
     if lst then
      lst.count = (lst.count or 0) + 1
      e.num = lst.count
      e.ordered = lst.name == "ol"
     end
     e.pend = true
    elseif name == "form" then
     local action = attrs.action and ResolveUrl(baseUrl, DecodeEntities(attrs.action)) or baseUrl
     curForm = {action = action, method = (attrs.method or "get"):lower(), fields = {}}
    elseif name == "select" then
     curSelect = {
      type = "select", name = attrs.name and DecodeEntities(attrs.name), options = {},
      disabled = attrs.disabled ~= nil,
     }
    elseif name == "option" then
     if curSelect then
      curOption = {value = attrs.value and DecodeEntities(attrs.value), text = "", selected = attrs.selected ~= nil}
      table.insert(curSelect.options, curOption)
     end
    elseif name == "textarea" then
     curTextarea = {
      type = "textarea", name = attrs.name and DecodeEntities(attrs.name), value = "",
      placeholder = attrs.placeholder and DecodeEntities(attrs.placeholder), disabled = attrs.disabled ~= nil,
     }
    elseif name == "button" then
     local ty = (attrs.type or "submit"):lower()
     if curForm and ty == "submit" and not e.st.hidden then
      curButton = {
       type = "submit", name = attrs.name and DecodeEntities(attrs.name),
       value = attrs.value and DecodeEntities(attrs.value) or "", text = "",
      }
     end
    elseif name == "details" then
     nextGroup = nextGroup + 1
     e.group = nextGroup
     e.startIdx = #blocks + 1
    elseif name == "picture" then
     pictureSrcset = nil
    elseif name == "video" then
     if attrs.poster then
      emitImage({src = attrs.poster, alt = "", width = attrs.width, height = attrs.height}, e)
     end
     e.st.hidden = true
    elseif name == "progress" or name == "meter" then
     if not e.st.hidden then
      local v, m = tonumber(attrs.value), tonumber(attrs.max)
      if name == "meter" and tonumber(attrs.min) and v then
       local lo = tonumber(attrs.min)
       m = (m or 1) - lo
       v = v - lo
      end
      flush()
      emit({kind = "progress", value = v, max = m or 1}, e)
     end
     e.st.hidden = true
    end

    local bgu = e.st.bgUrl
    if bgu and e.block and not e.st.hidden and name ~= "body" and name ~= "html" and bgCount < 8 then
     local low = bgu:lower()
     local skip = false
     for _, w in ipairs({"sprite", "icon", "pattern", "texture", "noise", "bullet", "arrow"}) do
      if low:find(w, 1, true) then skip = true end
     end
     if not skip then
      bgCount = bgCount + 1
      emitImage({src = bgu, alt = ""}, e)
     end
    end
   end

   local pos, n = 1, #html
   while pos <= n do
    local s = html:find("<", pos, true)
    if not s then
     addText(html:sub(pos))
     break
    end
    if s > pos then addText(html:sub(pos, s - 1)) end
    if not html:sub(s + 1, s + 1):match("[%a/!?]") then
     addText("<")
     pos = s + 1
    else
     local te = FindTagEnd(html, s + 1)
     if not te then break end
     local tag = html:sub(s + 1, te - 1)
     pos = te + 1
     tagCount = tagCount + 1
     if tagCount % 600 == 0 then task.wait() end
     local name = tag:match("^/?%s*([%a][%w:%-]*)")
     if name then
      name = name:lower()
      if tag:sub(1, 1) == "/" then
       closeTag(name)
      else
       openTag(name, ParseAttrs(tag), tag:sub(-1) == "/")
      end
     end
    end
   end
   flush()
   while #ctxStack > 0 do finalizeRow(table.remove(ctxStack)) end
   return blocks, links, {bg = pageBg}
  end

  local blocks, links, info = Run(true)
  if #blocks == 0 then
   local b2, l2, i2 = Run(false)
   if #b2 > 0 then blocks, links, info = b2, l2, i2 end
  end
  return title, blocks, links, info
 end

 function E.FetchStylesheets(html, baseUrl, alive)
  if not reqFunc then return "" end
  html = html:gsub("<!%-%-.-%-%->", "")
  local base = baseUrl
  local bt = html:match("<[bB][aA][sS][eE]%s[^>]*>")
  if bt then
   local a = ParseAttrs(bt:sub(2, -2))
   if a.href then base = ResolveUrl(baseUrl, DecodeEntities(a.href)) or baseUrl end
  end
  local urls = {}
  for tag in html:gmatch("<[lL][iI][nN][kK]%s[^>]*>") do
   local a = ParseAttrs(tag:sub(2, -2))
   local rel = (a.rel or ""):lower()
   local media = (a.media or ""):lower()
   if rel:find("stylesheet", 1, true) and not rel:find("alternate", 1, true)
    and a.href and a.href ~= "" and not media:find("print", 1, true) then
    local u = ResolveUrl(base, DecodeEntities(a.href))
    if u then
     table.insert(urls, u)
     if #urls >= 4 then break end
    end
   end
  end
  if #urls == 0 then return "" end

  local results, pending = {}, #urls
  for i, u in ipairs(urls) do
   task.spawn(function()
    local ok, res = pcall(reqFunc, {Url = u, Method = "GET", Headers = {Accept = "text/css,*/*;q=0.1"}})
    if ok and type(res) == "table" then
     local b = res.Body or res.body
     if type(b) == "string" and #b <= 400000 then results[i] = b end
    end
    pending = pending - 1
   end)
  end
  local deadline = os.clock() + 5
  while pending > 0 and os.clock() < deadline and (not alive or alive()) do
   task.wait(0.05)
  end
  local ordered = {}
  for i = 1, #urls do ordered[i] = results[i] or "" end
  return table.concat(ordered, "\n")
 end

 return E
end)()

type Block = {[string]: any}
type Link = {text: string, url: string}

type Tab = {
 title: string,
 history: {string},
 index: number,
 loadId: number,
 hover: boolean,
 button: TextButton,
 label: TextLabel,
 closeBtn: TextButton,
 shapes: {Frame},
 flares: {Frame},
 sep: Frame,
 page: Frame,
 ntp: Frame,
 ntpLabel: TextLabel?,
 scroll: ScrollingFrame,
 bg: Color3?,
}

local tabs: {Tab} = {}
local active: Tab? = nil
local nextOrder = 1
local Navigate: (Tab, string) -> ()

local function CurrentUrl(tab: Tab): string
 return tab.history[tab.index] or ""
end

local tabW = MAX_TAB_W

local function DisplayUrl(url: string): string
 local s = url:gsub("^https?://", "")
 s = s:gsub("^www%.", "")
 if s:match("^[^/]*/$") then s = s:sub(1, -2) end
 return s
end

local function UpdateSeparators()
 for i, t in tabs do
  local nxt = tabs[i + 1]
  local hot = t == active or t.hover or (nxt ~= nil and (nxt == active or nxt.hover))
  t.sep.Visible = Look.tabSeps and nxt ~= nil and not hot
 end
end

local function StyleTab(t: Tab)
 local on = (t == active)
 local lit = on or t.hover
 for _, s in t.shapes do
  s.BackgroundColor3 = if on then C.tabOn else C.stripHover
  s.BackgroundTransparency = if lit then 0 else 1
 end
 for _, f in t.flares do f.Visible = on and Look.tabCurved end
 t.label.TextColor3 = if on then C.text else C.dim
 t.label.Visible = tabW >= 56
 t.closeBtn.Visible = if on then tabW >= 44 else tabW >= 84
 t.button.ZIndex = if on then 3 elseif t.hover then 2 else 1
end

local function RelayoutTabs()
 if Look.sidebar then
  tabW = SIDE_W - 16
 else
  local available = tabHolder.AbsoluteSize.X / uiScale.Scale - 40
  tabW = math.clamp(math.floor(available / math.max(#tabs, 1)), MIN_TAB_W, MAX_TAB_W)
 end
 for _, t in tabs do
  t.button.Size = UDim2.fromOffset(tabW, TAB_BTN_H)
  StyleTab(t)
 end
 UpdateSeparators()
end

local function RefreshToolbar()
 local tab = active
 if not tab then return end
 omnibox.Text = DisplayUrl(CurrentUrl(tab))
 Icon.tint(backIcon, if tab.index > 1 then C.text else C.disabled)
 Icon.tint(fwdIcon, if tab.index < #tab.history then C.text else C.disabled)
end

local function ApplyPageBg(tab: Tab)
 if tab ~= active then return end
 local bg = tab.bg or C.page
 content.BackgroundColor3 = bg
 topFill.BackgroundColor3 = bg
end

local function ApplyTabShape(t: Tab)
 local body, filler = t.shapes[1], t.shapes[2]
 if not body then return end
 local corner = body:FindFirstChildOfClass("UICorner")
 local D = Designs[CurrentDesign]
 if Look.tabCurved then
  body.Position = UDim2.new()
  body.Size = UDim2.fromScale(1, 1)
  if corner then corner.CornerRadius = UDim.new(0, D.tabRadius) end
  if filler then filler.Visible = true end
 else
  if Look.sidebar then
   body.Position = UDim2.new()
   body.Size = UDim2.fromScale(1, 1)
  else
   body.Position = UDim2.fromOffset(2, 2)
   body.Size = UDim2.new(1, -4, 1, -8)
  end
  if corner then corner.CornerRadius = UDim.new(0, D.tabRadius) end
  if filler then filler.Visible = false end
 end
end

local function ApplyLayout()
 local side = Look.sidebar
 local x = if side then SIDE_W else 0
 zenSide.Visible = side
 toolbar.Position = UDim2.fromOffset(x, TAB_H)
 toolbar.Size = UDim2.new(1, -x, 0, TOOL_H)
 content.Position = UDim2.fromOffset(x, TAB_H + TOOL_H)
 content.Size = UDim2.new(1, -x, 1, -(TAB_H + TOOL_H))
 settings.Position = UDim2.fromOffset(x, SETTINGS_TOP)
 settings.Size = UDim2.new(1, -x, 1, -SETTINGS_TOP)

 local list = tabHolder:FindFirstChildOfClass("UIListLayout")
 local plusIcon = newTabBtn:FindFirstChild("Icon")
 if side then
  tabHolder.Parent = zenSide
  tabHolder.Position = UDim2.fromOffset(8, 8)
  tabHolder.Size = UDim2.new(1, -16, 1, -16)
  if list then
   list.FillDirection = Enum.FillDirection.Vertical
   list.VerticalAlignment = Enum.VerticalAlignment.Top
   list.Padding = UDim.new(0, 4)
  end
  newTabHolder.Size = UDim2.fromOffset(SIDE_W - 16, TAB_BTN_H)
  newTabBtn.AnchorPoint = Vector2.new(0, 0.5)
  newTabBtn.Position = UDim2.fromScale(0, 0.5)
  newTabBtn.Size = UDim2.new(1, 0, 0, 30)
  newTabLabel.Visible = true
  if plusIcon then
   plusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
   plusIcon.Position = UDim2.new(0, 18, 0.5, 0)
  end
 else
  tabHolder.Parent = tabBar
  tabHolder.Position = UDim2.fromOffset(8, 0)
  tabHolder.Size = UDim2.new(1, -150, 1, 0)
  if list then
   list.FillDirection = Enum.FillDirection.Horizontal
   list.VerticalAlignment = Enum.VerticalAlignment.Bottom
   list.Padding = UDim.new(0, 0)
  end
  newTabHolder.Size = UDim2.fromOffset(36, TAB_BTN_H)
  newTabBtn.AnchorPoint = Vector2.new(0.5, 0.5)
  newTabBtn.Position = UDim2.fromScale(0.5, 0.5)
  newTabBtn.Size = UDim2.fromOffset(28, 28)
  newTabLabel.Visible = false
  if plusIcon then
   plusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
   plusIcon.Position = UDim2.fromScale(0.5, 0.5)
  end
 end
end

local WHITE = Color3.new(1, 1, 1)
local FALLBACK_PHOTOS = {
 "https://freestocks.org/fs/wp-content/uploads/2023/09/inside_of_a_temperate_mixed_forest-1024x683.jpg",
 "https://freestocks.org/fs/wp-content/uploads/2023/09/wild_blueberries_bush_closeup_5-1024x683.jpg",
 "https://freestocks.org/fs/wp-content/uploads/2023/09/wild_blueberries_bush_2-1024x683.jpg",
 "https://freestocks.org/fs/wp-content/uploads/2023/09/wild_blueberries_in_a_bucket-1024x683.jpg",
 "https://freestocks.org/fs/wp-content/uploads/2023/09/black_pug_playing_at_the_beach_11-1024x683.jpg",
 "https://freestocks.org/fs/wp-content/uploads/2023/09/black_pug_playing_at_the_beach_6-1024x683.jpg",
}
local photoList: {string}? = nil

local function GetPhotos(cb: ({string}) -> ())
 if photoList then return cb(photoList) end
 task.spawn(function()
  local list: {string} = {}
  local reqF = request or http_request or (syn and syn.request)
  if reqF then
   local ok, res = pcall(reqF, {Url = "https://freestocks.org/category/nature/", Method = "GET"})
   if ok and type(res) == "table" then
    local body = res.Body or res.body
    if type(body) == "string" then
     local seen = {}
     for u in body:gmatch("https://freestocks%.org/fs/wp%-content/uploads/%d+/%d+/[%w_%-]+%-1024x683%.jpg") do
      if not seen[u] then
       seen[u] = true
       table.insert(list, u)
      end
      if #list >= 30 then break end
     end
    end
   end
  end
  if #list == 0 then list = FALLBACK_PHOTOS end
  photoList = list
  cb(list)
 end)
end

local function FetchSiteIcon(url: string, cb: (string?) -> (), alive: () -> boolean)
 local host = HostOf(url)
 local origin = url:match("^(https?://[^/?#]+)") or ("https://" .. host)
 local sources = {
  "https://www.google.com/s2/favicons?domain=" .. host .. "&sz=128",
  "https://icons.duckduckgo.com/ip3/" .. host .. ".ico",
  origin .. "/favicon.ico",
 }
 task.spawn(function()
  for _, src in sources do
   if not alive() then return end
   local got: string? = nil
   local done = false
   Engine.FetchImage(src, function(info)
    if info and info.asset and not info.unsupported then got = info.asset end
    done = true
   end, alive)
   local deadline = os.clock() + 12
   while not done and os.clock() < deadline and alive() do task.wait(0.05) end
   if got then return cb(got) end
  end
  cb(nil)
 end)
end

local function NtpText(parent: Instance, text: string, size: number, color: Color3, y: number, h: number): TextLabel
 return Create("TextLabel", {
  AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.42, y), Size = UDim2.new(1, -40, 0, h),
  BackgroundTransparency = 1, Text = text, TextColor3 = color, TextSize = size, Font = FONT, ZIndex = 3,
 }, parent)
end

local function NtpClock(parent: Instance, color: Color3, dim: Color3)
 local time = NtpText(parent, "", 72, color, -56, 80)
 local date = NtpText(parent, "", 16, dim, -34, 22)
 task.spawn(function()
  while time.Parent do
   time.Text = os.date("%H:%M")
   date.Text = os.date("%A, %B %d")
   task.wait(10)
  end
 end)
end

local NTP_BUILDERS: {[string]: (Tab, Frame, Frame, any) -> ()} = {
 tiles = function(t, front, back, D)
  local sites = {
   {"Wikipedia", "https://www.wikipedia.org"}, {"GitHub", "https://github.com"},
   {"Reddit", "https://www.reddit.com"}, {"YouTube", "https://www.youtube.com"},
  }
  local row = Create("Frame", {
   AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.42, 56), Size = UDim2.fromOffset(#sites * 96, 104),
   BackgroundTransparency = 1, ZIndex = 3,
  }, front)
  Create("UIListLayout", {
   FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
   HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 16),
  }, row)
  for i, site in sites do
   local cell = Create("Frame", {LayoutOrder = i, Size = UDim2.fromOffset(80, 104), BackgroundTransparency = 1, ZIndex = 3}, row)
   local b = Create("TextButton", {
    Size = UDim2.fromOffset(80, 72), BackgroundColor3 = C.ntpBox, BorderSizePixel = 0, AutoButtonColor = false,
    Text = site[1]:sub(1, 1), TextColor3 = C.text, TextSize = 28, Font = FONT, ZIndex = 3,
   }, cell)
   Create("UICorner", {CornerRadius = UDim.new(0, 12)}, b)
   Hoverable(b, C.ntpBox, C.hover)
   local icon = Create("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(40, 40),
    BackgroundTransparency = 1, Image = "", Visible = false, ScaleType = Enum.ScaleType.Fit, ZIndex = 4,
   }, b)
   Create("UICorner", {CornerRadius = UDim.new(0, 8)}, icon)
   FetchSiteIcon(site[2], function(asset)
    if asset and icon.Parent then
     icon.Image = asset
     icon.Visible = true
     b.Text = ""
    end
   end, function() return icon.Parent ~= nil end)
   Create("TextLabel", {
    Position = UDim2.fromOffset(0, 78), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
    Text = site[1], TextColor3 = C.dim, TextSize = 12, Font = FONT, ZIndex = 3,
   }, cell)
   b.MouseButton1Click:Connect(function() Navigate(t, site[2]) end)
  end
 end,

 clock = function(t, front, back, D)
  NtpClock(front, C.text, C.dim)
 end,

 wordmark = function(t, front, back, D)
  NtpText(front, D.wordmark or "", 44, C.focus, -48, 56)
  if D.tagline then NtpText(front, D.tagline, 15, C.dim, -28, 20) end
 end,

 photo = function(t, front, back, D)
  local img = Create("ImageLabel", {
   Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, Image = "", ZIndex = 2,
  }, back)
  Create("UICorner", {CornerRadius = UDim.new(0, 8)}, img)
  local shade = Create("Frame", {
   Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5,
   BorderSizePixel = 0, ZIndex = 2,
  }, back)
  Create("UICorner", {CornerRadius = UDim.new(0, 8)}, shade)
  NtpClock(front, WHITE, Color3.fromRGB(225, 225, 225))
  Create("TextLabel", {
   AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -12), Size = UDim2.fromOffset(240, 16),
   BackgroundTransparency = 1, Text = "Photo: freestocks.org", TextColor3 = Color3.fromRGB(215, 215, 215),
   TextSize = 11, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
  }, front)
  GetPhotos(function(list)
   if not img.Parent then return end
   local url = list[math.random(#list)]
   Engine.FetchImage(url, function(info)
    if img.Parent and info and info.asset then img.Image = info.asset end
   end, function() return img.Parent ~= nil end)
  end)
 end,
}

local function ApplyNtpDecor(t: Tab)
 for _, n in {"DecorBack", "Decor"} do
  local old = t.ntp:FindFirstChild(n)
  if old then old:Destroy() end
 end
 local box = t.ntp:FindFirstChildOfClass("TextButton")
 local D = Designs[CurrentDesign]
 local builder = D.ntp and NTP_BUILDERS[D.ntp]
 if box then box.BackgroundTransparency = if D.ntp == "photo" then 0.15 else 0 end
 if not builder then return end
 local back = Create("Frame", {Name = "DecorBack", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2}, t.ntp)
 local front = Create("Frame", {Name = "Decor", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3}, t.ntp)
 builder(t, front, back, D)
end

local function RecolorTree(root: Instance, map: {[string]: Color3}, skip: {[Instance]: boolean})
 local function conv(c: Color3): Color3?
  return map[c:ToHex()]
 end
 local function visit(inst: Instance)
  if inst:IsA("UIStroke") then
   local n = conv(inst.Color)
   if n then inst.Color = n end
  elseif inst:IsA("GuiObject") then
   local n = conv(inst.BackgroundColor3)
   if n then inst.BackgroundColor3 = n end
   if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
    local t = conv(inst.TextColor3)
    if t then inst.TextColor3 = t end
    if inst:IsA("TextBox") then
     local p = conv(inst.PlaceholderColor3)
     if p then inst.PlaceholderColor3 = p end
    end
   elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
    local i = conv(inst.ImageColor3)
    if i then inst.ImageColor3 = i end
   end
  end
  for _, child in inst:GetChildren() do
   if not skip[child] then visit(child) end
  end
 end
 visit(root)
end

local function ApplyDesign(name: string)
 local D = Designs[name]
 if not D then return end
 local new = NormalizePalette(D.colors)
 local map: {[string]: Color3} = {}
 for k, oc in CurrentPalette do
  map[oc:ToHex()] = new[k]
 end

 local skip: {[Instance]: boolean} = {}
 for _, t in tabs do
  skip[t.scroll] = true
  local ap = t.page:FindFirstChild("AudioPlayer")
  if ap then skip[ap] = true end
 end
 RecolorTree(window, map, skip)

 for ic in AllIcons do
  if not ic.root:FindFirstAncestor("AudioPlayer") then
   local n = map[ic.color:ToHex()]
   if n then ic.color = n end
  end
 end
 for p in HoverPairs do
  local a, b = map[p.normal:ToHex()], map[p.over:ToHex()]
  if a then p.normal = a end
  if b then p.over = b end
 end

 CurrentPalette = new
 CurrentDesign = name
 for k, c in new do C[k] = c end
 Look.tabCurved = D.tabCurved
 Look.tabSeps = D.tabSeps
 Look.placeholder = D.placeholder
 Look.sidebar = D.sidebar == true
 ApplyLayout()

 local omniCorner = omniFrame:FindFirstChildOfClass("UICorner")
 if omniCorner then omniCorner.CornerRadius = D.omniRadius end
 for _, c in CornerTargets do c.CornerRadius = D.btnRadius end
 omnibox.PlaceholderText = D.placeholder
 for _, t in tabs do
  ApplyTabShape(t)
  StyleTab(t)
  if t.ntpLabel then t.ntpLabel.Text = D.placeholder end
  ApplyNtpDecor(t)
 end
 RelayoutTabs()
 task.defer(RelayoutTabs)
 UpdateSeparators()
 RefreshToolbar()
end

local designTab = CreateTab("Design")
local designButtons: {[string]: TextButton} = {}
for _, name in {"Firefox", "Zen", "Brave", "DuckDuckGo", "Waterfox"} do
 designButtons[name] = CreateButton(name, function()
  ApplyDesign(name)
  for n, b in designButtons do SetButtonActive(b, n == name) end
 end, designTab)
end

local function SelectTab(tab: Tab)
 CloseSettings()
 active = tab
 for _, t in tabs do
  t.page.Visible = (t == tab)
  StyleTab(t)
 end
 UpdateSeparators()
 RefreshToolbar()
 ApplyPageBg(tab)
end

local function ClearPage(tab: Tab)
 local oldPlayer = tab.page:FindFirstChild("AudioPlayer")
 if oldPlayer then oldPlayer:Destroy() end
 tab.scroll.Visible = true
 for _, child in tab.scroll:GetChildren() do
  if child:IsA("GuiObject") then child:Destroy() end
 end
 tab.scroll.CanvasPosition = Vector2.zero
 tab.ntp.Visible = false
 tab.bg = nil
 ApplyPageBg(tab)
end

local function AddLabel(tab: Tab, order: number, text: string, size: number, font: Enum.Font, color: Color3)
 return Create("TextLabel", {
  LayoutOrder = order,
  Size = UDim2.new(1, 0, 0, 0),
  AutomaticSize = Enum.AutomaticSize.Y,
  BackgroundTransparency = 1,
  Text = text,
  TextSize = size,
  Font = font,
  TextColor3 = color,
  TextWrapped = true,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Top,
 }, tab.scroll)
end

local function ShowMessage(tab: Tab, title: string, sub: string?, isError: boolean?)
 ClearPage(tab)
 AddLabel(tab, 1, title, 24, FONT, C.msgText)
 if sub then AddLabel(tab, 2, sub, 15, FONT, C.pageDim) end
end

local function ShowNewTab(tab: Tab)
 ClearPage(tab)
 tab.ntp.Visible = true
end

local AUDIO_DIR = "BrowserWindow_cache"
local audioAsset = getcustomasset or getsynasset
local AUDIO_SPEEDS = {0.5, 0.75, 1, 1.5, 1.75, 2}

local function FmtTime(t: number): string
 t = math.max(0, math.floor(t))
 return ("%d:%02d"):format(t // 60, t % 60)
end

local function IsMp3(ct: string, url: string): boolean
 if ct:find("audio/mpeg", 1, true) or ct:find("audio/mp3", 1, true) then return true end
 if ct == "" or ct:find("octet-stream", 1, true) then
  local path = url:gsub("[?#].*$", "")
  return path:lower():match("%.mp3$") ~= nil
 end
 return false
end

local function ShowAudio(tab: Tab, url: string, body: string)
 if not (writefile and audioAsset) then
  ShowMessage(tab, "Can't play audio", "Your executor does not support writefile/getcustomasset.", true)
  return
 end
 pcall(function()
  if isfolder and makefolder and not isfolder(AUDIO_DIR) then makefolder(AUDIO_DIR) end
 end)
 local h1 = 5381
 for i = 1, #url do h1 = (h1 * 33 + url:byte(i)) % 4294967296 end
 local path = ("%s/audio_%08x_%d.mp3"):format(AUDIO_DIR, h1, #body)
 local okW = pcall(writefile, path, body)
 local okA, asset = false, nil
 if okW then okA, asset = pcall(audioAsset, path) end
 if not (okW and okA) then
  ShowMessage(tab, "Can't play audio", "Failed to load the audio file.", true)
  return
 end

 ClearPage(tab)
 tab.bg = Color3.new(0, 0, 0)
 ApplyPageBg(tab)
 tab.scroll.Visible = false

 local V2n = Vector2.new
 local INK = Color3.fromRGB(32, 33, 36)
 local PILL_W, PILL_H = 300, 54

 local root = Create("Frame", {
  Name = "AudioPlayer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
  BorderSizePixel = 0, ClipsDescendants = true,
 }, tab.page)

 local sound = Create("Sound", {SoundId = asset, Volume = 1, Looped = false, PlaybackSpeed = 1}, root)

 local pill = Create("Frame", {
  Name = "Pill", AnchorPoint = V2n(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
  Size = UDim2.fromOffset(PILL_W, PILL_H), BackgroundColor3 = Color3.fromRGB(241, 243, 244),
  BorderSizePixel = 0, ZIndex = 1,
 }, root)
 Create("UICorner", {CornerRadius = UDim.new(0.5, 0)}, pill)

 local function IconButton(cx: number, size: number): (TextButton, any)
  local b = Create("TextButton", {
   AnchorPoint = V2n(0.5, 0.5), Position = UDim2.fromOffset(cx, PILL_H / 2), Size = UDim2.fromOffset(size, size),
   BackgroundColor3 = Color3.fromRGB(222, 224, 226), BackgroundTransparency = 1, BorderSizePixel = 0,
   AutoButtonColor = false, Text = "",
  }, pill)
  Create("UICorner", {CornerRadius = UDim.new(1, 0)}, b)
  b.MouseEnter:Connect(function() b.BackgroundTransparency = 0 end)
  b.MouseLeave:Connect(function() b.BackgroundTransparency = 1 end)
  return b, Icon.new(b, 16, INK)
 end

 local function Cols(icon: any, x0: number, x1: number, hOf: (number) -> number, cy: number)
  for x = x0, x1 - 1 do
   local hgt = math.max(hOf(x + 0.5), 0.1)
   local f = Create("Frame", {
    AnchorPoint = V2n(0, 0.5), Position = UDim2.fromOffset(x, cy), Size = UDim2.fromOffset(1.2, hgt),
    BackgroundColor3 = icon.color, BorderSizePixel = 0,
   }, icon.root)
   table.insert(icon.parts, f)
  end
 end

 local function Rect(icon: any, x: number, y: number, w: number, hgt: number)
  local f = Create("Frame", {
   Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, hgt),
   BackgroundColor3 = icon.color, BorderSizePixel = 0,
  }, icon.root)
  table.insert(icon.parts, f)
 end

 local function Arc(icon: any, cx: number, cy: number, r: number, a0: number, a1: number, thick: number)
  local pts = {}
  for i = 0, 8 do
   local a = math.rad(a0 + (a1 - a0) * i / 8)
   table.insert(pts, V2n(cx + r * math.cos(a), cy + r * math.sin(a)))
  end
  Icon.poly(icon, pts, false, thick)
 end

 local playBtn, playIcon = IconButton(27, 28)
 local function DrawPlay(playing: boolean)
  Icon.clear(playIcon)
  if playing then
   Rect(playIcon, 3, 2, 3.4, 12)
   Rect(playIcon, 9.6, 2, 3.4, 12)
  else
   Cols(playIcon, 3, 13, function(x) return 12 * (1 - (x - 3) / 10) end, 8)
  end
 end
 DrawPlay(false)

 local timeLbl = Create("TextLabel", {
  Position = UDim2.fromOffset(47, 0), Size = UDim2.fromOffset(80, PILL_H), BackgroundTransparency = 1,
  Text = "0:00 / 0:00", TextColor3 = INK, TextSize = 14, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
 }, pill)

 local SL_X, SL_W, KNOB = 130, 80, 12
 local hit = Create("TextButton", {
  Position = UDim2.fromOffset(SL_X, 0), Size = UDim2.fromOffset(SL_W, PILL_H), BackgroundTransparency = 1,
  Text = "", AutoButtonColor = false,
 }, pill)
 local track = Create("Frame", {
  AnchorPoint = V2n(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 4),
  BackgroundColor3 = Color3.fromRGB(90, 90, 90), BorderSizePixel = 0, Active = false,
 }, hit)
 Create("UICorner", {CornerRadius = UDim.new(0.5, 0)}, track)
 local fill = Create("Frame", {
  Size = UDim2.fromOffset(KNOB / 2, 4), BackgroundColor3 = Color3.fromRGB(26, 26, 26), BorderSizePixel = 0,
 }, track)
 Create("UICorner", {CornerRadius = UDim.new(0.5, 0)}, fill)
 local knob = Create("Frame", {
  AnchorPoint = V2n(0.5, 0.5), Position = UDim2.fromOffset(KNOB / 2, 2), Size = UDim2.fromOffset(KNOB, KNOB),
  BackgroundColor3 = Color3.fromRGB(26, 26, 26), BorderSizePixel = 0,
 }, track)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
 local function SetFrac(fr: number)
  local px = KNOB / 2 + math.clamp(fr, 0, 1) * (SL_W - KNOB)
  knob.Position = UDim2.fromOffset(px, 2)
  fill.Size = UDim2.fromOffset(px, 4)
 end

 local volBtn, volIcon = IconButton(242, 28)
 local muted = false
 local function DrawVol()
  Icon.clear(volIcon)
  Rect(volIcon, 1.5, 6, 3, 4)
  Cols(volIcon, 4, 8, function(x) return 4 + (x - 4) * 2.2 end, 8)
  if muted then
   Icon.line(volIcon, 10, 5.5, 14.5, 10.5, 1.5)
   Icon.line(volIcon, 14.5, 5.5, 10, 10.5, 1.5)
  else
   Arc(volIcon, 8, 8, 3.6, -50, 50, 1.8)
   Arc(volIcon, 8, 8, 6.4, -50, 50, 1.6)
  end
 end
 DrawVol()

 local moreBtn, moreIcon = IconButton(274, 28)
 for i = 0, 2 do Icon.dot(moreIcon, 8, 3.5 + i * 4.5, 1.3) end

 local backdrop = Create("TextButton", {
  Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
  Visible = false, ZIndex = 0,
 }, root)
 local MENU_W, ROW_H = 200, 40
 local MENU_X, MENU_Y = PILL_W / 2, PILL_H / 2 + 6
 local MAX_ROWS = 5
 local function NewMenu(w: number, rows: number, dy: number)
  local m = Create("ScrollingFrame", {
   AnchorPoint = V2n(0.5, 1), Position = UDim2.new(0, SL_X + SL_W / 2, 0, -6),
   Size = UDim2.fromOffset(w, math.min(rows, MAX_ROWS) * ROW_H + 8), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
   BorderSizePixel = 0, Visible = false, ZIndex = 10,
   CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
   ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = if rows > MAX_ROWS then 6 else 0,
   ScrollBarImageColor3 = Color3.fromRGB(193, 193, 193), TopImage = "", BottomImage = "",
  }, pill)
  Create("UICorner", {CornerRadius = UDim.new(0, 8)}, m)
  Create("UIStroke", {Color = Color3.fromRGB(218, 220, 224), Thickness = 1}, m)
  local sh = Create("Frame", {
   AnchorPoint = m.AnchorPoint, Position = m.Position, Size = m.Size,
   BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Visible = false, ZIndex = 9,
  }, pill)
  Create("UICorner", {CornerRadius = UDim.new(0, 8)}, sh)
  local okSh = pcall(function()
   local u = Instance.new("UIShadow")
   u.Color = Color3.new(0, 0, 0)
   u.Transparency = 0.75
   u.BlurRadius = UDim.new(0, 12)
   u.Offset = UDim2.fromOffset(0, 4)
   u.Spread = UDim2.fromOffset(0, 0)
   u.Parent = sh
  end)
  if not okSh then
   for i = 1, 7 do
    local layer = Create("Frame", {
     AnchorPoint = V2n(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 3),
     Size = UDim2.new(1, i * 2, 1, i * 2), BackgroundColor3 = Color3.new(0, 0, 0),
     BackgroundTransparency = 0.95, BorderSizePixel = 0, ZIndex = 8,
    }, sh)
    Create("UICorner", {CornerRadius = UDim.new(0, 8 + i)}, layer)
   end
  end
  m:GetPropertyChangedSignal("Visible"):Connect(function() sh.Visible = m.Visible end)
  Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}, m)
  Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, m)
  return m
 end
 local function Row(menu: GuiObject, order: number, text: string, indent: number): (TextButton, TextLabel)
  local r = Create("TextButton", {
   LayoutOrder = order, Size = UDim2.new(1, 0, 0, ROW_H), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
   BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 10,
  }, menu)
  local lbl = Create("TextLabel", {
   Position = UDim2.fromOffset(indent, 0), Size = UDim2.new(1, -indent - 12, 1, 0), BackgroundTransparency = 1,
   Text = text, TextColor3 = INK, TextSize = 14, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
  }, r)
  Hoverable(r, Color3.fromRGB(255, 255, 255), Color3.fromRGB(241, 243, 244))
  return r, lbl
 end

 local menu = NewMenu(MENU_W, 1, 0)
 local speedRow, speedLbl = Row(menu, 1, "Playback speed", 52)
 speedLbl.TextSize = 16
 local spIcon = Icon.new(speedRow, 20, INK)
 spIcon.root.Position = UDim2.fromOffset(24, ROW_H / 2)
 for i = 0, 9 do
  local a = i * 36
  Arc(spIcon, 10, 10, 8, a, a + 22, 2)
 end
 Cols(spIcon, 7, 13, function(x) return 8 * (1 - (x - 7) / 6) end, 10)

 local speedMenu = NewMenu(120, #AUDIO_SPEEDS, ROW_H + 8 + 6)
 local speedRows: {[number]: any} = {}
 local curSpeed = 1
 local function PaintSpeeds()
  for _, e in speedRows do e.check.root.Visible = (e.speed == curSpeed) end
 end
 for i, sp in AUDIO_SPEEDS do
  local r = Row(speedMenu, i, tostring(sp), 38)
  local ck = Icon.new(r, 14, INK)
  ck.root.Position = UDim2.fromOffset(15, ROW_H / 2)
  Icon.poly(ck, {V2n(2, 7.5), V2n(5.5, 11), V2n(12, 3.5)}, false, 1.7)
  table.insert(speedRows, {speed = sp, check = ck})
  r.MouseButton1Click:Connect(function()
   curSpeed = sp
   sound.PlaybackSpeed = sp
   PaintSpeeds()
   menu.Visible = false
   speedMenu.Visible = false
   backdrop.Visible = false
  end)
 end
 PaintSpeeds()

 local function CloseMenus()
  menu.Visible = false
  speedMenu.Visible = false
  backdrop.Visible = false
 end
 backdrop.MouseButton1Click:Connect(CloseMenus)
 moreBtn.MouseButton1Click:Connect(function()
  if menu.Visible then
   CloseMenus()
  else
   menu.Visible = true
   speedMenu.Visible = false
   backdrop.Visible = true
  end
 end)
 speedRow.MouseButton1Click:Connect(function()
  menu.Visible = false
  speedMenu.Visible = true
 end)

 playBtn.MouseButton1Click:Connect(function()
  if sound.Playing then
   sound:Pause()
  else
   if sound.TimeLength > 0 and sound.TimePosition >= sound.TimeLength - 0.05 then
    sound.TimePosition = 0
   end
   sound:Play()
  end
 end)
 volBtn.MouseButton1Click:Connect(function()
  muted = not muted
  sound.Volume = if muted then 0 else 1
  DrawVol()
 end)
 sound.Ended:Connect(function()
  sound.TimePosition = 0
 end)

 local dragging = false
 local function Seek(x: number)
  local len = sound.TimeLength
  local span = SL_W - KNOB
  local fr = math.clamp((x - hit.AbsolutePosition.X - KNOB / 2) / math.max(span, 1), 0, 1)
  SetFrac(fr)
  if len > 0 then sound.TimePosition = fr * len end
 end
 hit.InputBegan:Connect(function(input: InputObject)
  local t = input.UserInputType
  if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
  dragging = true
  Seek(input.Position.X)
  local c1: RBXScriptConnection? = nil
  local c2: RBXScriptConnection? = nil
  c1 = UserInputService.InputChanged:Connect(function(i: InputObject)
   local it = i.UserInputType
   if dragging and (it == Enum.UserInputType.MouseMovement or it == Enum.UserInputType.Touch) then
    Seek(i.Position.X)
   end
  end)
  c2 = UserInputService.InputEnded:Connect(function(i: InputObject)
   local it = i.UserInputType
   if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.Touch then
    dragging = false
    if c1 then c1:Disconnect() end
    if c2 then c2:Disconnect() end
   end
  end)
 end)

 local lastPlaying = false
 local conn: RBXScriptConnection? = nil
 conn = RunService.Heartbeat:Connect(function()
  if not root.Parent then
   if conn then conn:Disconnect() end
   return
  end
  local playing = sound.Playing
  if playing ~= lastPlaying then
   lastPlaying = playing
   DrawPlay(playing)
  end
  local len, pos = sound.TimeLength, sound.TimePosition
  timeLbl.Text = FmtTime(pos) .. " / " .. FmtTime(len)
  if not dragging then
   SetFrac(if len > 0 then pos / len else 0)
  end
 end)
end

local ALIGN = {
 left = Enum.TextXAlignment.Left,
 center = Enum.TextXAlignment.Center,
 right = Enum.TextXAlignment.Right,
}

local function RenderPage(tab: Tab, blocks: {Block}, links: {Link}, note: string?, info: any?)
 ClearPage(tab)
 tab.bg = info and info.bg or nil
 ApplyPageBg(tab)

 local pageBg: Color3 = tab.bg or C.page
 local dark = Engine.Lum(pageBg) < 0.35
 local textColor = Engine.Readable(C.pageText, pageBg)
 local dimColor = if dark then Color3.fromRGB(170, 174, 180) else C.pageDim
 local cc = {
  bg = if dark then Color3.fromRGB(53, 54, 58) else Color3.fromRGB(241, 243, 244),
  stroke = if dark then Color3.fromRGB(95, 99, 104) else Color3.fromRGB(176, 180, 185),
  text = if dark then C.text else Color3.fromRGB(32, 33, 36),
  sel = if dark then Color3.fromRGB(70, 75, 85) else Color3.fromRGB(208, 224, 250),
 }
 local V2n = Vector2.new

 local order = 0
 local function NextO(): number
  order += 1
  return order
 end
 local host: Instance = tab.scroll
 local RenderBlocks: (any, Instance) -> ()

 local items: {any} = {}
 local gopen: {[number]: boolean} = {}
 local function RefreshGroups()
  for _, it in items do
   local vis = true
   for _, g in it.groups do
    if not gopen[g] then
     vis = false
     break
    end
   end
   it.gui.Visible = vis
  end
 end

 local function Rounded(inst: GuiObject, r: number?)
  Create("UICorner", {CornerRadius = UDim.new(0, r or 6)}, inst)
 end

 local function Stroke(inst: GuiObject)
  Create("UIStroke", {Color = cc.stroke, Thickness = 1}, inst)
 end

 local function SubmitForm(form: any, submitter: any?, flash: (() -> ())?)
  if form.loose then return end
  if form.method ~= "get" then
   if flash then flash() end
   return
  end
  local out = {}
  local function add(k: string, v: string)
   table.insert(out, HttpService:UrlEncode(k) .. "=" .. HttpService:UrlEncode(v))
  end
  for _, f in form.fields do
   local nm = f.name
   if nm and nm ~= "" and not f.disabled then
    local ty = f.type
    if ty == "checkbox" or ty == "radio" then
     if f.checked then add(nm, f.value or "on") end
    elseif ty == "submit" then
     if f == submitter then add(nm, f.value or "") end
    elseif ty ~= "password" then
     add(nm, f.value or "")
    end
   end
  end
  local base = form.action:gsub("#.*$", "")
  base = base:gsub("%?.*$", "")
  Navigate(tab, base .. (if #out > 0 then "?" .. table.concat(out, "&") else ""))
 end

 local function BuildText(b: any)
  local isBtn = b.href ~= nil
  local text = b.rich
  if b.bullet then text = b.bullet .. "  " .. text end
  local props: {[string]: any} = {
   LayoutOrder = NextO(),
   Size = UDim2.new(1, 0, 0, 0),
   AutomaticSize = Enum.AutomaticSize.Y,
   BackgroundTransparency = if b.bg then 0 else 1,
   BorderSizePixel = 0,
   Text = text,
   RichText = true,
   TextSize = math.clamp(math.floor(b.size + 0.5), 9, 72),
   Font = if b.mono then Enum.Font.RobotoMono elseif b.bold then PAGE_BOLD else PAGE_FONT,
   TextColor3 = b.color,
   TextWrapped = true,
   TextXAlignment = ALIGN[b.align] or Enum.TextXAlignment.Left,
   TextYAlignment = Enum.TextYAlignment.Top,
  }
  if b.bg then props.BackgroundColor3 = b.bg end
  if isBtn then props.AutoButtonColor = false end
  local inst = Create(if isBtn then "TextButton" else "TextLabel", props, host)
  local pad = if b.bg then 8 else 0
  if (b.indent or 0) > 0 or b.bg then
   Create("UIPadding", {
    PaddingLeft = UDim.new(0, (b.indent or 0) + pad),
    PaddingRight = UDim.new(0, pad),
    PaddingTop = UDim.new(0, if b.bg then 4 else 0),
    PaddingBottom = UDim.new(0, if b.bg then 4 else 0),
   }, inst)
  end
  if isBtn then
   inst.MouseButton1Click:Connect(function() Navigate(tab, b.href) end)
  end
  return inst
 end

 local function BuildMarquee(b: any)
  local size = math.clamp(math.floor(b.size + 0.5), 9, 72)
  local holder = Create("Frame", {
   LayoutOrder = NextO(),
   Size = UDim2.new(1, 0, 0, math.ceil(size * 1.5)),
   BackgroundTransparency = if b.bg then 0 else 1,
   BackgroundColor3 = b.bg or Color3.new(1, 1, 1),
   BorderSizePixel = 0,
   ClipsDescendants = true,
  }, host)
  local label = Create("TextLabel", {
   Size = UDim2.new(0, 0, 1, 0),
   AutomaticSize = Enum.AutomaticSize.X,
   BackgroundTransparency = 1,
   Text = b.rich,
   RichText = true,
   TextSize = size,
   Font = if b.bold then PAGE_BOLD else PAGE_FONT,
   TextColor3 = b.color,
   TextWrapped = false,
   TextXAlignment = Enum.TextXAlignment.Left,
   TextYAlignment = Enum.TextYAlignment.Center,
  }, holder)
  local m = b.marquee
  local speed = math.clamp(m.amount * 1000 / math.max(m.delay, 20), 20, 400)
  local toRight = m.dir == "right"
  local x, started = 0, false
  local conn: RBXScriptConnection? = nil
  conn = RunService.Heartbeat:Connect(function(dt: number)
   if not holder.Parent then
    if conn then conn:Disconnect() end
    return
   end
   local s = uiScale.Scale
   local hw, w = holder.AbsoluteSize.X / s, label.AbsoluteSize.X / s
   if hw <= 0 or w <= 0 then return end
   if not started then
    started = true
    x = if toRight then -w else hw
   end
   if toRight then
    x += speed * dt
    if x > hw then x = -w end
   else
    x -= speed * dt
    if x < -w then x = hw end
   end
   label.Position = UDim2.fromOffset(x, 0)
  end)
  return holder
 end

 local function BuildHr()
  return Create("Frame", {
   LayoutOrder = NextO(),
   Size = UDim2.new(1, 0, 0, 1),
   BackgroundColor3 = if dark then Color3.fromRGB(95, 99, 104) else Color3.fromRGB(205, 208, 212),
   BorderSizePixel = 0,
  }, host)
 end

 local function BuildProgress(b: any)
  local holder = Create("Frame", {LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1}, host)
  local track = Create("Frame", {
   Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = cc.bg, BorderSizePixel = 0, ClipsDescendants = true,
  }, holder)
  Create("UISizeConstraint", {MaxSize = Vector2.new(320, 10)}, track)
  Rounded(track, 5)
  local fill = Create("Frame", {
   Size = UDim2.fromScale(if b.value then math.clamp(b.value / math.max(b.max, 1e-6), 0, 1) else 0.3, 1),
   BackgroundColor3 = C.accent, BorderSizePixel = 0,
  }, track)
  Rounded(fill, 5)
  if not b.value then
   local t0 = os.clock()
   local conn: RBXScriptConnection? = nil
   conn = RunService.Heartbeat:Connect(function()
    if not holder.Parent then
     if conn then conn:Disconnect() end
     return
    end
    local f = ((os.clock() - t0) % 1.4) / 1.4
    fill.Position = UDim2.fromScale(-0.3 + f * 1.3, 0)
   end)
  end
  return holder
 end

 local function BuildImage(b: any)
  local props: {[string]: any} = {
   LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0,
  }
  if b.href then
   props.AutoButtonColor = false
   props.Text = ""
  end
  local holder = Create(if b.href then "TextButton" else "Frame", props, host)
  if b.href then
   holder.MouseButton1Click:Connect(function() Navigate(tab, b.href) end)
  end
  local ph = Create("TextLabel", {
   Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Loading image…", TextSize = 13,
   Font = FONT, TextColor3 = dimColor, TextXAlignment = Enum.TextXAlignment.Left,
  }, holder)

  Engine.FetchImage(b.url, function(imgInfo)
   if not holder.Parent then return end
   ph:Destroy()
   if not imgInfo or imgInfo.unsupported then
    if b.alt ~= "" then
     holder.Size = UDim2.new(1, 0, 0, 0)
     holder.AutomaticSize = Enum.AutomaticSize.Y
     Create("TextLabel", {
      Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
      Text = "[" .. b.alt .. "]", TextSize = 14, Font = PAGE_FONT, TextColor3 = dimColor,
      TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
     }, holder)
    else
     holder:Destroy()
    end
    return
   end

   local img = Create("ImageLabel", {
    BackgroundTransparency = 1, Image = imgInfo.asset, ScaleType = Enum.ScaleType.Stretch,
    Size = UDim2.fromOffset(0, 0),
   }, holder)
   local iw, ih = imgInfo.w, imgInfo.h
   if not (iw and ih and iw > 0 and ih > 0) then
    img.Size = UDim2.new(1, 0, 1, 0)
    img.ScaleType = Enum.ScaleType.Fit
    holder.Size = UDim2.new(1, 0, 0, math.min(b.h or 240, 400))
    return
   end
   local ratio = ih / iw
   local lastW = -1
   local function layout()
    local avail = holder.AbsoluteSize.X / uiScale.Scale
    if avail <= 0 or avail == lastW then return end
    lastW = avail
    local dw = math.min(avail, b.w or iw)
    local dh = dw * ratio
    img.Size = UDim2.fromOffset(dw, dh)
    holder.Size = UDim2.new(1, 0, 0, dh)
   end
   holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
   layout()
  end, function() return holder.Parent ~= nil end)
  return holder
 end

 local function BuildSelect(b: any)
  local f = b.field
  local holder = Create("Frame", {
   LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
  }, host)
  Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}, holder)

  local btn = Create("TextButton", {
   LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = cc.bg, BorderSizePixel = 0,
   AutoButtonColor = false, Text = "",
  }, holder)
  Rounded(btn)
  Stroke(btn)
  Create("UISizeConstraint", {MaxSize = Vector2.new(360, 32)}, btn)
  local lbl = Create("TextLabel", {
   Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0), BackgroundTransparency = 1,
   Text = f.options[f.selectedIndex].text, TextColor3 = cc.text, TextSize = 15, Font = PAGE_FONT,
   TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
  }, btn)
  local ic = Icon.new(btn, 12, cc.text)
  ic.root.Position = UDim2.new(1, -16, 0.5, 0)
  Icon.poly(ic, {V2n(2, 4), V2n(6, 8), V2n(10, 4)}, false, 1.5)

  local rowH = 28
  local list = Create("ScrollingFrame", {
   LayoutOrder = 2, Size = UDim2.new(1, 0, 0, math.min(#f.options * rowH, 224)), BackgroundColor3 = cc.bg,
   BorderSizePixel = 0, Visible = false, ScrollBarThickness = 6, CanvasSize = UDim2.new(),
   AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
  }, holder)
  Create("UISizeConstraint", {MaxSize = Vector2.new(360, math.huge)}, list)
  Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, list)
  Stroke(list)

  local optBtns = {}
  local function paint()
   for i, ob in optBtns do
    ob.BackgroundColor3 = if i == f.selectedIndex then cc.sel else cc.bg
   end
  end
  for i, o in f.options do
   local ob = Create("TextButton", {
    LayoutOrder = i, Size = UDim2.new(1, 0, 0, rowH), BackgroundColor3 = cc.bg, BorderSizePixel = 0,
    AutoButtonColor = false, Text = o.text, TextColor3 = cc.text, TextSize = 14, Font = PAGE_FONT,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
   }, list)
   Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, ob)
   ob.MouseButton1Click:Connect(function()
    f.selectedIndex = i
    f.value = o.value
    lbl.Text = o.text
    list.Visible = false
    ic.root.Rotation = 0
    paint()
   end)
   table.insert(optBtns, ob)
  end
  paint()
  btn.MouseButton1Click:Connect(function()
   if f.disabled then return end
   list.Visible = not list.Visible
   ic.root.Rotation = if list.Visible then 180 else 0
  end)
  return holder
 end

 local function BuildInput(b: any)
  local f = b.field
  local ty = f.type

  if ty == "text" or ty == "textarea" then
   local multi = ty == "textarea"
   local box = Create("TextBox", {
    LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, if multi then 90 else 32),
    BackgroundColor3 = cc.bg, BorderSizePixel = 0, Text = f.value or "",
    PlaceholderText = f.placeholder or "", PlaceholderColor3 = dimColor, TextColor3 = cc.text,
    TextSize = 15, Font = PAGE_FONT, TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false, MultiLine = multi, TextWrapped = multi,
    TextYAlignment = if multi then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center,
   }, host)
   Create("UISizeConstraint", {MaxSize = Vector2.new(400, math.huge)}, box)
   Create("UIPadding", {
    PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, if multi then 6 else 0),
   }, box)
   Rounded(box)
   Stroke(box)
   box:GetPropertyChangedSignal("Text"):Connect(function() f.value = box.Text end)
   box.FocusLost:Connect(function(enter: boolean)
    f.value = box.Text
    if enter and not multi then SubmitForm(f.form, nil, nil) end
   end)
   return box

  elseif ty == "password" then
   return Create("TextLabel", {
    LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
    Text = "(password fields aren't supported)", TextSize = 13, Font = PAGE_FONT, TextColor3 = dimColor,
    TextXAlignment = Enum.TextXAlignment.Left,
   }, host)

  elseif ty == "checkbox" or ty == "radio" then
   local radio = ty == "radio"
   local row = Create("TextButton", {
    LayoutOrder = NextO(), Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Text = "",
    AutoButtonColor = false,
   }, host)
   local boxF = Create("Frame", {
    Position = UDim2.fromOffset(0, 3), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = cc.bg, BorderSizePixel = 0,
   }, row)
   Create("UICorner", {CornerRadius = if radio then UDim.new(1, 0) else UDim.new(0, 4)}, boxF)
   Stroke(boxF)
   local mark = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = C.accent, BorderSizePixel = 0,
   }, boxF)
   Create("UICorner", {CornerRadius = if radio then UDim.new(1, 0) else UDim.new(0, 2)}, mark)
   f.visual = function() mark.Visible = f.checked == true end
   f.visual()
   row.MouseButton1Click:Connect(function()
    if f.disabled then return end
    if radio then
     for _, o in f.form.fields do
      if o ~= f and o.type == "radio" and o.name == f.name then
       o.checked = false
       if o.visual then o.visual() end
      end
     end
     f.checked = true
    else
     f.checked = not f.checked
    end
    f.visual()
   end)
   return row

  elseif ty == "range" then
   local holder = Create("Frame", {LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1}, host)
   Create("UISizeConstraint", {MaxSize = Vector2.new(320, 26)}, holder)
   local track = Create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, -48, 0, 4),
    BackgroundColor3 = cc.stroke, BorderSizePixel = 0,
   }, holder)
   Rounded(track, 2)
   local fill = Create("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.accent, BorderSizePixel = 0}, track)
   Rounded(fill, 2)
   local knob = Create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(16, 16),
    BackgroundColor3 = C.accent, BorderSizePixel = 0,
   }, track)
   Create("UICorner", {CornerRadius = UDim.new(1, 0)}, knob)
   local valLbl = Create("TextLabel", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(42, 20),
    BackgroundTransparency = 1, Text = "", TextColor3 = cc.text, TextSize = 13, Font = PAGE_FONT,
   }, holder)
   local hit = Create("TextButton", {
    Size = UDim2.new(1, -48, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
   }, holder)

   local span = math.max(f.max - f.min, 1e-9)
   local function show(v: number)
    local fr = math.clamp((v - f.min) / span, 0, 1)
    fill.Size = UDim2.fromScale(fr, 1)
    knob.Position = UDim2.fromScale(fr, 0.5)
    valLbl.Text = tostring(math.floor(v * 100 + 0.5) / 100)
   end
   show(tonumber(f.value) or f.min)

   local function update(x: number)
    local w = hit.AbsoluteSize.X
    if w <= 0 then return end
    local fr = math.clamp((x - hit.AbsolutePosition.X) / w, 0, 1)
    local v = f.min + fr * (f.max - f.min)
    if f.step and f.step > 0 then
     v = f.min + math.floor((v - f.min) / f.step + 0.5) * f.step
    end
    v = math.clamp(v, f.min, f.max)
    f.value = tostring(math.floor(v * 1000 + 0.5) / 1000)
    show(v)
   end

   local dragging = false
   local c1: RBXScriptConnection? = nil
   local c2: RBXScriptConnection? = nil
   hit.InputBegan:Connect(function(input: InputObject)
    local t = input.UserInputType
    if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
    dragging = true
    update(input.Position.X)
    c1 = UserInputService.InputChanged:Connect(function(i: InputObject)
     local it = i.UserInputType
     if dragging and (it == Enum.UserInputType.MouseMovement or it == Enum.UserInputType.Touch) then
      update(i.Position.X)
     end
    end)
    c2 = UserInputService.InputEnded:Connect(function(i: InputObject)
     local it = i.UserInputType
     if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.Touch then
      dragging = false
      if c1 then c1:Disconnect() end
      if c2 then c2:Disconnect() end
     end
    end)
   end)
   return holder

  elseif ty == "submit" then
   local label = f.label or "Submit"
   local btn = Create("TextButton", {
    LayoutOrder = NextO(), Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = cc.bg, BorderSizePixel = 0, AutoButtonColor = false, Text = label,
    TextColor3 = cc.text, TextSize = 15, Font = PAGE_FONT,
   }, host)
   Create("UIPadding", {PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)}, btn)
   Rounded(btn)
   Stroke(btn)
   Hoverable(btn, cc.bg, cc.sel)
   btn.MouseButton1Click:Connect(function()
    SubmitForm(f.form, f, function()
     btn.Text = "POST forms aren't supported"
     task.delay(1.6, function()
      if btn.Parent then btn.Text = label end
     end)
    end)
   end)
   return btn
  end
  return nil
 end

 local function BuildSummary(b: any)
  local gid = b.gid
  if gopen[gid] == nil then gopen[gid] = b.open == true end
  local btn = Create("TextButton", {
   LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
   BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
  }, host)
  local ic = Icon.new(btn, 12, b.color)
  ic.root.Position = UDim2.fromOffset(8, 12)
  Icon.poly(ic, {V2n(4, 2), V2n(8, 6), V2n(4, 10)}, false, 1.6)
  ic.root.Rotation = if gopen[gid] then 90 else 0
  Create("TextLabel", {
   Position = UDim2.fromOffset(22, 0), Size = UDim2.new(1, -22, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
   BackgroundTransparency = 1, Text = b.rich, RichText = true,
   TextSize = math.clamp(math.floor(b.size + 0.5), 9, 72),
   Font = if b.bold then PAGE_BOLD else PAGE_FONT, TextColor3 = b.color, TextWrapped = true,
   TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
  }, btn)
  btn.MouseButton1Click:Connect(function()
   gopen[gid] = not gopen[gid]
   ic.root.Rotation = if gopen[gid] then 90 else 0
   RefreshGroups()
  end)
  return btn
 end


 local function BuildRow(b: any)
  local rowF = Create("Frame", {
   LayoutOrder = NextO(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
   BackgroundTransparency = 1,
  }, host)
  Create("UIListLayout", {
   FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
   Padding = UDim.new(0, 12), VerticalAlignment = Enum.VerticalAlignment.Top,
  }, rowF)
  local n = #b.cols
  local fr: {number} = {}
  local fixed, free, sumW = 0, 0, 0
  local weights: {number} = {}
  for i, c in b.cols do
   if c.frac then
    fr[i] = c.frac
    fixed += c.frac
   else
    free += 1
    local w = if b.rowKind == "table" then 1 else (c.grow or math.sqrt(math.max(c.len or 0, 6)))
    if w <= 0 then w = 0.1 end
    weights[i] = w
    sumW += w
   end
  end
  local remain = math.max(1 - fixed, 0.12 * free)
  local total = 0
  for i = 1, n do
   if not fr[i] then fr[i] = math.max(remain * weights[i] / math.max(sumW, 1e-6), 0.08) end
   total += fr[i]
  end
  local gapEach = 12 * (n - 1) / n
  for i, c in b.cols do
   local cf = Create("Frame", {
    LayoutOrder = i, Size = UDim2.new(fr[i] / total, -gapEach, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
   }, rowF)
   Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)}, cf)
   RenderBlocks(c.blocks, cf)
  end
  return rowF
 end

 RenderBlocks = function(list: any, parent: Instance)
  local savedHost, savedOrder = host, order
  local topLevel = parent == tab.scroll
  host = parent
  if not topLevel then order = 0 end
  for _, b in list do
   local k = b.kind
   local made: GuiObject? = nil
   if k == "text" then
    made = if b.marquee then BuildMarquee(b) else BuildText(b)
   elseif k == "summary" then
    made = BuildSummary(b)
   elseif k == "img" then
    made = BuildImage(b)
   elseif k == "select" then
    made = BuildSelect(b)
   elseif k == "input" then
    made = BuildInput(b)
   elseif k == "hr" then
    made = BuildHr()
   elseif k == "progress" then
    made = BuildProgress(b)
   elseif k == "row" then
    made = BuildRow(b)
   end
   if made and b.groups and #b.groups > 0 then
    table.insert(items, {gui = made, groups = b.groups})
   end
  end
  host = savedHost
  if not topLevel then order = savedOrder end
 end

 if note then
  AddLabel(tab, NextO(), note, 13, FONT, C.error)
 end
 if #blocks == 0 and #links == 0 then
  AddLabel(tab, NextO(), "This page has no readable text content.", 15, FONT, dimColor)
 end

 RenderBlocks(blocks, tab.scroll)

 if #links > 0 then
  AddLabel(tab, NextO(), "Links", 24, PAGE_BOLD, textColor)
  local linkColor = Engine.Readable(C.link, pageBg, true)
  local dimHex = dimColor:ToHex()
  for _, l in links do
   local btn = Create("TextButton", {
    LayoutOrder = NextO(),
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Text = "<u>" .. Esc(l.text) .. "</u>  <font color=\"#" .. dimHex .. "\">" .. Esc(HostOf(l.url)) .. "</font>",
    RichText = true,
    TextSize = 16,
    Font = PAGE_FONT,
    TextColor3 = linkColor,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    AutoButtonColor = false,
   }, host)
   btn.MouseButton1Click:Connect(function()
    Navigate(tab, l.url)
   end)
  end
 end

 RefreshGroups()
end

local function LoadPage(tab: Tab)
 local url = CurrentUrl(tab)
 tab.loadId += 1
 local id = tab.loadId

 if url == "" then
  tab.title = "New Tab"
  tab.label.Text = "New Tab"
  ShowNewTab(tab)
  return
 end

 tab.label.Text = "Loading…"
 ShowMessage(tab, "Loading…", url)

 task.spawn(function()
  local reqFunc = request or http_request or (syn and syn.request)
  if tab.loadId ~= id or not tab.page.Parent then return end
  if not reqFunc then
   tab.label.Text = HostOf(url)
   ShowMessage(tab, "Can't load pages", "Your executor does not support the request() function.", true)
   return
  end

  local ok, res = pcall(function()
   return reqFunc({
    Url = url,
    Method = "GET"
   })
  end)
  if tab.loadId ~= id or not tab.page.Parent then return end

  local host = HostOf(url)

  if (not ok or type(res) ~= "table") and url:find("//localhost", 1, true) then
   local altUrl = url:gsub("//localhost", "//127.0.0.1", 1)
   local ok2, res2 = pcall(function()
    return reqFunc({ Url = altUrl, Method = "GET" })
   end)
   if ok2 and type(res2) == "table" then
    ok, res = ok2, res2
   end
  end

  local function isConnErr(msg: string): boolean
   msg = msg:lower()
   return msg:find("connect") ~= nil or msg:find("refused") ~= nil
    or msg:find("timeout") ~= nil or msg:find("unreachable") ~= nil
    or msg:find("fail") ~= nil
  end

  if not ok or type(res) ~= "table" then
   local errStr = tostring(res)
   local extra = isConnErr(errStr) and IsLocal(url)
    and "\n\nCheck the server is running on this port. If your executor blocks loopback, try your machine's LAN IP (e.g. 192.168.x.x) instead."
    or ""
   tab.label.Text = host
   ShowMessage(tab, "This site can’t be reached", errStr .. extra, true)
   return
  end

  if not res.Success and (not res.StatusCode or res.StatusCode == 0) then
   local errStr = tostring(res.StatusMessage or "Connection failed")
   local extra = isConnErr(errStr) and IsLocal(url)
    and "\n\nCheck the server is running on this port. If your executor blocks loopback, try your machine's LAN IP (e.g. 192.168.x.x) instead."
    or ""
   tab.label.Text = host
   ShowMessage(tab, "This site can’t be reached", errStr .. extra, true)
   return
  end

  local headers = res.Headers or res.headers or {}
  local contentType = ""
  for k, v in headers do
   if k:lower() == "content-type" then
    contentType = v
    break
   end
  end

  local note = nil
  if not res.Success and res.StatusCode and res.StatusCode > 0 then
   note = ("HTTP %d %s"):format(res.StatusCode, res.StatusMessage or "")
  end

  local ct = string.lower(contentType)
  local body: string = res.Body or res.body or ""
  if IsMp3(ct, url) then
   tab.title = host
   tab.label.Text = (url:gsub("[?#].*$", ""):match("([^/]+)$")) or host
   ShowAudio(tab, url, body)
  elseif ct == "" or ct:find("html", 1, true) then
   local function alive(): boolean
    return tab.loadId == id and tab.page.Parent ~= nil
   end
   local css = Engine.FetchStylesheets(body, url, alive)
   if not alive() then return end
   local title, blocks, links, info = Engine.HTML(body, url, css)
   if not alive() then return end
   tab.title = title or host
   tab.label.Text = tab.title
   RenderPage(tab, blocks, links, note, info)
  elseif ct:find("text", 1, true) or ct:find("json", 1, true) or ct:find("xml", 1, true) then
   tab.title = host
   tab.label.Text = host
   local blocks: {Block} = {}
   for i = 1, #body, MAX_BLOCK_CHARS do
    if #blocks >= MAX_BLOCKS then break end
    local chunk = body:sub(i, i + MAX_BLOCK_CHARS - 1)
    table.insert(blocks, {
     kind = "text", tag = "pre", rich = Esc(chunk), plain = chunk, size = 14, mono = true,
     color = C.pageText, align = "left", indent = 0,
    })
   end
   RenderPage(tab, blocks, {}, note, nil)
  else
   tab.label.Text = host
   ShowMessage(tab, "Can't display this content", "Content type: " .. ct)
  end
 end)
end

Navigate = function(tab: Tab, raw: string)
 raw = raw:match("^%s*(.-)%s*$") or ""
 if raw == "" then return end
 CloseSettings()
 local url = raw
 if not url:find("^%a[%w+.-]*://") then
  if IsLocal(url) then
   url = "http://" .. url
  elseif url:find("%.") and not url:find("%s") then
   url = "https://" .. url
  else
   url = "https://html.duckduckgo.com/html/?q=" .. HttpService:UrlEncode(raw)
  end
 end
 for i = #tab.history, tab.index + 1, -1 do
  table.remove(tab.history, i)
 end
 table.insert(tab.history, url)
 tab.index = #tab.history
 LoadPage(tab)
 if tab == active then RefreshToolbar() end
end

local function CloseTab(tab: Tab)
 local i = table.find(tabs, tab)
 if not i then return end
 table.remove(tabs, i)
 tab.button:Destroy()
 tab.page:Destroy()
 if #tabs == 0 then
  gui:Destroy()
  return
 end
 RelayoutTabs()
 if active == tab then
  SelectTab(tabs[math.min(i, #tabs)])
 end
end

local function NewTab(url: string?)
 local button = Create("TextButton", {
  LayoutOrder = nextOrder,
  Size = UDim2.fromOffset(tabW, TAB_BTN_H),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
 }, tabHolder)
 nextOrder += 1

 local shapes: {Frame} = {}
 local function Shape(props: {[string]: any}): Frame
  props.BackgroundTransparency = 1
  props.BorderSizePixel = 0
  local f = Create("Frame", props, button)
  table.insert(shapes, f)
  return f
 end
 local body = Shape({Size = UDim2.fromScale(1, 1)})
 Create("UICorner", {CornerRadius = UDim.new(0, 8)}, body)
 Shape({Position = UDim2.new(0, 0, 1, -8), Size = UDim2.new(1, 0, 0, 8)})

 local flares: {Frame} = {}
 for _, left in {true, false} do
  local clip = Create("Frame", {
   Position = if left then UDim2.new(0, -8, 1, -8) else UDim2.new(1, 0, 1, -8),
   Size = UDim2.fromOffset(8, 8),
   BackgroundColor3 = C.tabOn,
   BorderSizePixel = 0,
   ClipsDescendants = true,
   Visible = false,
  }, button)
  local dot = Create("Frame", {
   Position = if left then UDim2.fromOffset(-8, -8) else UDim2.fromOffset(0, -8),
   Size = UDim2.fromOffset(16, 16),
   BackgroundColor3 = C.strip,
   BorderSizePixel = 0,
  }, clip)
  Create("UICorner", {CornerRadius = UDim.new(1, 0)}, dot)
  table.insert(flares, clip)
 end

 local fav = Icon.new(button, 16, C.dim)
 fav.root.AnchorPoint = Vector2.new(0, 0.5)
 fav.root.Position = UDim2.new(0, 12, 0.5, 1)
 Icon.oval(fav, 8, 8, 6.5, 6.5, 1.2)
 Icon.oval(fav, 8, 8, 2.8, 6.5, 1.2)
 Icon.line(fav, 1.5, 8, 14.5, 8, 1.2)

 local label = Create("TextLabel", {
  Position = UDim2.fromOffset(36, 0),
  Size = UDim2.new(1, -64, 1, 0),
  BackgroundTransparency = 1,
  Text = "New Tab",
  TextSize = 12,
  Font = FONT,
  TextColor3 = C.dim,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextTruncate = Enum.TextTruncate.AtEnd,
 }, button)

 local x = Create("TextButton", {
  AnchorPoint = Vector2.new(1, 0.5),
  Position = UDim2.new(1, -8, 0.5, 1),
  Size = UDim2.fromOffset(16, 16),
  BackgroundColor3 = C.hover,
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
 }, button)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, x)
 local xIcon = Icon.new(x, 16, C.dim)
 Icon.line(xIcon, 4.5, 4.5, 11.5, 11.5, 1.2)
 Icon.line(xIcon, 11.5, 4.5, 4.5, 11.5, 1.2)
 x.MouseEnter:Connect(function()
  x.BackgroundTransparency = 0
  Icon.tint(xIcon, C.text)
 end)
 x.MouseLeave:Connect(function()
  x.BackgroundTransparency = 1
  Icon.tint(xIcon, C.dim)
 end)

 local sep = Create("Frame", {
  Position = UDim2.new(1, -1, 0, 9),
  Size = UDim2.fromOffset(1, 16),
  BackgroundColor3 = C.sep,
  BorderSizePixel = 0,
 }, button)

 local page = Create("Frame", {
  Size = UDim2.fromScale(1, 1),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  Visible = false,
 }, content)

 local ntp = Create("Frame", {
  Name = "NewTabPage",
  Size = UDim2.fromScale(1, 1),
  BackgroundColor3 = C.ntp,
  BorderSizePixel = 0,
  Visible = false,
 }, page)
 Create("UICorner", {CornerRadius = UDim.new(0, 8)}, ntp)
 Create("Frame", {
  Size = UDim2.new(1, 0, 0, 16),
  BackgroundColor3 = C.ntp,
  BorderSizePixel = 0,
 }, ntp)
 local box = Create("TextButton", {
  AnchorPoint = Vector2.new(0.5, 0.5),
  Position = UDim2.fromScale(0.5, 0.42),
  ZIndex = 3,
  Size = UDim2.new(0.7, 0, 0, 44),
  BackgroundColor3 = C.ntpBox,
  BorderSizePixel = 0,
  Text = "",
  AutoButtonColor = false,
 }, ntp)
 Create("UICorner", {CornerRadius = UDim.new(1, 0)}, box)
 Create("UISizeConstraint", {MinSize = Vector2.new(0, 44), MaxSize = Vector2.new(584, 44)}, box)
 local ntpLabel = Create("TextLabel", {
  Position = UDim2.fromOffset(52, 0),
  Size = UDim2.new(1, -64, 1, 0),
  BackgroundTransparency = 1,
  Text = Look.placeholder,
  TextColor3 = C.dim,
  TextSize = 16,
  Font = FONT,
  TextXAlignment = Enum.TextXAlignment.Left,
 }, box)
 local mag = Icon.new(box, 20, C.dim)
 mag.root.AnchorPoint = Vector2.new(0, 0.5)
 mag.root.Position = UDim2.new(0, 16, 0.5, 0)
 Icon.oval(mag, 8.5, 8.5, 5.5, 5.5, 1.6)
 Icon.line(mag, 12.5, 12.5, 17, 17, 1.6)
 box.MouseButton1Click:Connect(function() omnibox:CaptureFocus() end)

 local scroll = Create("ScrollingFrame", {
  Size = UDim2.fromScale(1, 1),
  BackgroundTransparency = 1,
  BorderSizePixel = 0,
  ScrollBarThickness = 12,
  ScrollBarImageColor3 = Color3.fromRGB(193, 193, 193),
  ScrollingDirection = Enum.ScrollingDirection.Y,
  CanvasSize = UDim2.new(),
  AutomaticCanvasSize = Enum.AutomaticSize.Y,
 }, page)
 Create("UIListLayout", {
  SortOrder = Enum.SortOrder.LayoutOrder,
  Padding = UDim.new(0, 12),
 }, scroll)
 Create("UIPadding", {
  PaddingTop = UDim.new(0, 16),
  PaddingBottom = UDim.new(0, 24),
  PaddingLeft = UDim.new(0, 16),
  PaddingRight = UDim.new(0, 16),
 }, scroll)

 local tab: Tab = {
  title = "New Tab",
  history = {},
  index = 0,
  loadId = 0,
  hover = false,
  button = button,
  label = label,
  closeBtn = x,
  shapes = shapes,
  flares = flares,
  sep = sep,
  page = page,
  ntp = ntp,
  ntpLabel = ntpLabel,
  scroll = scroll,
 }
 table.insert(tabs, tab)
 ApplyTabShape(tab)
 ApplyNtpDecor(tab)
 RelayoutTabs()

 button.MouseButton1Click:Connect(function() SelectTab(tab) end)
 x.MouseButton1Click:Connect(function() CloseTab(tab) end)

 SelectTab(tab)
 LoadPage(tab)
 if url then Navigate(tab, url) end
 return tab
end

omnibox.Focused:Connect(function()
 omniStroke.Enabled = true
 local tab = active
 if not tab then return end
 omnibox.Text = CurrentUrl(tab)
 task.defer(function()
  omnibox.CursorPosition = #omnibox.Text + 1
  omnibox.SelectionStart = 1
 end)
end)

omnibox.FocusLost:Connect(function(enter: boolean)
 omniStroke.Enabled = false
 if enter and active then Navigate(active, omnibox.Text) end
 RefreshToolbar()
end)

backBtn.MouseButton1Click:Connect(function()
 local t = active
 if t and t.index > 1 then
  t.index -= 1
  LoadPage(t)
  RefreshToolbar()
 end
end)

fwdBtn.MouseButton1Click:Connect(function()
 local t = active
 if t and t.index < #t.history then
  t.index += 1
  LoadPage(t)
  RefreshToolbar()
 end
end)

reloadBtn.MouseButton1Click:Connect(function()
 if active then LoadPage(active) end
end)

newTabBtn.MouseButton1Click:Connect(function() NewTab() end)
tabHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(RelayoutTabs)

local DRAG_MARGIN = 80
local DRAG_THRESHOLD = 4
local EDGE, CORNER = 14, 90
local PREVIEW_INSET = 6
local TWEEN = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local minimized = false
local dockZone: string? = nil
local normal = {size = window.Size, pos = window.Position, anchor = window.AnchorPoint}
local preMinSize = window.Size
local dockTween: Tween? = nil

local function CancelTween()
 if dockTween then dockTween:Cancel() dockTween = nil end
end

local function ZoneRect(zone: string): (number, number, number, number)
 local v = gui.AbsoluteSize
 if zone == "T" then return 0, 0, v.X, v.Y end
 local hw, hh = math.floor(v.X / 2), math.floor(v.Y / 2)
 local left = zone:sub(1, 1) == "L"
 local x = left and 0 or hw
 local w = left and hw or v.X - hw
 if #zone == 1 then return x, 0, w, v.Y end
 local top = zone:sub(2, 2) == "T"
 local y = top and 0 or hh
 local h = top and hh or v.Y - hh
 return x, y, w, h
end

local function ZoneAt(p: Vector2): string?
 local v = gui.AbsoluteSize
 local nl, nr = p.X <= EDGE, p.X >= v.X - EDGE
 local nt, nb = p.Y <= EDGE, p.Y >= v.Y - EDGE
 if not (nl or nr or nt or nb) then return nil end

 local cornerY = p.Y <= CORNER or p.Y >= v.Y - CORNER
 local cornerX = p.X <= CORNER or p.X >= v.X - CORNER
 if ((nl or nr) and cornerY) or ((nt or nb) and cornerX) then
  return (p.X < v.X / 2 and "L" or "R") .. (p.Y < v.Y / 2 and "T" or "B")
 end
 if nl then return "L" end
 if nr then return "R" end
 if nt then return "T" end
 return nil
end

local function ToTopLeftAnchor()
 if window.AnchorPoint ~= Vector2.zero then
  local p = window.AbsolutePosition
  window.AnchorPoint = Vector2.zero
  window.Position = UDim2.fromOffset(p.X, p.Y)
 end
end

local function ApplyDock(zone: string, animate: boolean?)
 CancelTween()
 local x, y, w, h = ZoneRect(zone)
 local s = uiScale.Scale
 local goalPos = UDim2.fromOffset(x, y)
 local goalSize = UDim2.fromOffset(w / s, h / s)
 if animate then
  ToTopLeftAnchor()
  dockTween = TweenService:Create(window, TWEEN, {Position = goalPos, Size = goalSize})
  dockTween:Play()
 else
  window.AnchorPoint = Vector2.zero
  window.Position = goalPos
  window.Size = goalSize
 end
end

local function SetMinimized(on: boolean)
 if on == minimized then return end
 minimized = on
 toolbar.Visible = not on
 content.Visible = not on
 CancelTween()
 if on then
  preMinSize = window.Size
  window.Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, TAB_H)
 elseif dockZone then
  ApplyDock(dockZone, false)
 else
  window.Size = preMinSize
 end
end

local function Undock()
 if not dockZone then return end
 CancelTween()
 dockZone = nil
 DrawMaxIcon(false)
 window.AnchorPoint = normal.anchor
 window.Position = normal.pos
 preMinSize = normal.size
 window.Size = if minimized
 then UDim2.new(normal.size.X.Scale, normal.size.X.Offset, 0, TAB_H)
  else normal.size
end

local function Dock(zone: string)
 SetMinimized(false)
 if not dockZone then
  normal = {size = window.Size, pos = window.Position, anchor = window.AnchorPoint}
 end
 dockZone = zone
 DrawMaxIcon(true)
 ApplyDock(zone, true)
end

local function Reapply()
 if not dockZone then return end
 ApplyDock(dockZone, false)
 if minimized then
  window.Size = UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, TAB_H)
 end
end

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() SetMinimized(not minimized) end)
maxBtn.MouseButton1Click:Connect(function()
 if minimized then return end
 if dockZone then Undock() else Dock("T") end
end)

local function OnViewportChanged()
 uiScale.Scale = ComputeScale()
 task.defer(Reapply)
end
local function WatchCamera()
 local cam = workspace.CurrentCamera
 if cam then
  cam:GetPropertyChangedSignal("ViewportSize"):Connect(OnViewportChanged)
 end
end
WatchCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
 WatchCamera()
 OnViewportChanged()
end)

local preview = Create("Frame", {
 Name = "DockPreview",
 BackgroundColor3 = C.accent,
 BackgroundTransparency = 0.82,
 BorderSizePixel = 0,
 Visible = false,
 ZIndex = 10,
}, gui)
Create("UICorner", {CornerRadius = UDim.new(0, 10)}, preview)
Create("UIStroke", {Color = C.accent, Thickness = 2, Transparency = 0.25}, preview)

local previewZone: string? = nil
local previewTween: Tween? = nil

local function SetPreview(zone: string?)
 if zone == previewZone then return end
 local wasShown = previewZone ~= nil
 previewZone = zone
 if previewTween then
  previewTween:Cancel()
  previewTween = nil
 end
 if not zone then
  preview.Visible = false
  return
 end
 local x, y, w, h = ZoneRect(zone)
 local i = PREVIEW_INSET
 local goal = {
  Position = UDim2.fromOffset(x + i, y + i),
  Size = UDim2.fromOffset(math.max(w - i * 2, 0), math.max(h - i * 2, 0)),
 }
 if not wasShown then
  local p, s = window.AbsolutePosition, window.AbsoluteSize
  preview.Position = UDim2.fromOffset(p.X, p.Y)
  preview.Size = UDim2.fromOffset(s.X, s.Y)
  preview.Visible = true
 end
 previewTween = TweenService:Create(preview, TWEEN, goal)
 previewTween:Play()
end

local dragInput: InputObject? = nil
local dragMoved = false
local dragStart = Vector2.zero
local startPos = window.Position
local startAbs = Vector2.zero
local startSize = Vector2.zero

local function V2(input: InputObject): Vector2
 return Vector2.new(input.Position.X, input.Position.Y)
end

local function OverInteractive(pos: Vector2): boolean
 local function inside(g: GuiObject): boolean
  local p, s = g.AbsolutePosition, g.AbsoluteSize
  return pos.X >= p.X and pos.X <= p.X + s.X and pos.Y >= p.Y and pos.Y <= p.Y + s.Y
 end
 if inside(controls) or inside(newTabBtn) then return true end
 for _, t in tabs do
  if inside(t.button) then return true end
 end
 return false
end

local function ClampAbs(x: number, y: number, size: Vector2): (number, number)
 local view = gui.AbsoluteSize
 x = math.clamp(x, DRAG_MARGIN - size.X, view.X - DRAG_MARGIN)
 y = math.clamp(y, 0, math.max(0, view.Y - TAB_H * uiScale.Scale))
 return x, y
end

type Edges = {l: boolean, r: boolean, t: boolean, b: boolean}

local resizeInput: InputObject? = nil
local resizeEdges: Edges? = nil
local rStartPtr = Vector2.zero
local rStartPos = Vector2.zero
local rStartSize = Vector2.zero

local MIN_W, MIN_H = 380, 240
local RESIZE_IN = 3
local RESIZE_OUT = 6
local RESIZE_CORNER = 14

local function ResizeEdgesAt(p: Vector2): Edges?
 if dockZone or minimized then return nil end
 local pos, size = window.AbsolutePosition, window.AbsoluteSize
 local x, y = p.X - pos.X, p.Y - pos.Y
 local O, I, K = RESIZE_OUT, RESIZE_IN, RESIZE_CORNER
 if x < -O or y < -O or x > size.X + O or y > size.Y + O then return nil end

 local l0, r0 = x <= I, x >= size.X - I
 local t0, b0 = y <= I, y >= size.Y - I
 if not (l0 or r0 or t0 or b0) then return nil end

 local e = {l = l0, r = r0, t = t0, b = b0}
 if l0 or r0 then
  if y <= K then e.t = true elseif y >= size.Y - K then e.b = true end
 end
 if t0 or b0 then
  if x <= K then e.l = true elseif x >= size.X - K then e.r = true end
 end
 return e
end

UserInputService.InputBegan:Connect(function(input: InputObject)
 if resizeInput or dragInput then return end
 local t = input.UserInputType
 if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end

 local p = V2(input)
 local e = ResizeEdgesAt(p)
 if not e then return end

 local corner = (e.l or e.r) and (e.t or e.b)
 local c, cs = controls.AbsolutePosition, controls.AbsoluteSize
 local overControls = p.X >= c.X and p.X <= c.X + cs.X and p.Y >= c.Y and p.Y <= c.Y + cs.Y
 if overControls and not corner then return end

 CancelTween()
 ToTopLeftAnchor()
 resizeInput, resizeEdges = input, e
 rStartPtr = p
 rStartPos = window.AbsolutePosition
 rStartSize = window.AbsoluteSize
end)

UserInputService.InputChanged:Connect(function(input: InputObject)
 local ri, e = resizeInput, resizeEdges
 if not ri or not e then return end

 local mine
 if ri.UserInputType == Enum.UserInputType.Touch then
  mine = (input == ri)
 else
  mine = (input.UserInputType == Enum.UserInputType.MouseMovement)
 end
 if not mine then return end

 local view = gui.AbsoluteSize
 local pt = V2(input)
 pt = Vector2.new(math.clamp(pt.X, 0, view.X), math.clamp(pt.Y, 0, view.Y))
 local d = pt - rStartPtr

 local s = uiScale.Scale
 local minW, minH = MIN_W * s, MIN_H * s
 local right = rStartPos.X + rStartSize.X
 local bottom = rStartPos.Y + rStartSize.Y
 local x, y, w, h = rStartPos.X, rStartPos.Y, rStartSize.X, rStartSize.Y

 if e.l then
  x = math.min(math.max(rStartPos.X + d.X, math.min(0, rStartPos.X)), right - minW)
  w = right - x
 elseif e.r then
  w = math.max(minW, rStartSize.X + d.X)
 end
 if e.t then
  y = math.min(math.max(rStartPos.Y + d.Y, 0), bottom - minH)
  h = bottom - y
 elseif e.b then
  h = math.max(minH, rStartSize.Y + d.Y)
 end

 window.Position = UDim2.fromOffset(x, y)
 window.Size = UDim2.fromOffset(w / s, h / s)
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
 local ri = resizeInput
 if not ri then return end
 if input == ri
  or (ri.UserInputType == Enum.UserInputType.MouseButton1
   and input.UserInputType == Enum.UserInputType.MouseButton1) then
  resizeInput, resizeEdges = nil, nil
 end
end)

local function RestoreForDrag(pointer: Vector2)
 local abs, size = window.AbsolutePosition, window.AbsoluteSize
 local s, view = uiScale.Scale, gui.AbsoluteSize
 local fx = if size.X > 0 then math.clamp((pointer.X - abs.X) / size.X, 0, 1) else 0.5
 local fy = math.clamp(pointer.Y - abs.Y, 0, TAB_H * s)

 local ns = normal.size
 local w = (ns.X.Scale * view.X + ns.X.Offset) * s
 local h = (ns.Y.Scale * view.Y + ns.Y.Offset) * s

 Undock()
 local left, top = pointer.X - fx * w, pointer.Y - fy
 window.AnchorPoint = Vector2.zero
 window.Position = UDim2.fromOffset(left, top)

 startPos = window.Position
 startAbs = Vector2.new(left, top)
 startSize = Vector2.new(w, if minimized then TAB_H * s else h)
 dragStart = pointer
end

tabBar.InputBegan:Connect(function(input: InputObject)
 if dragInput then return end
 if resizeInput or ResizeEdgesAt(V2(input)) then return end
 local t = input.UserInputType
 if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
 if OverInteractive(V2(input)) then return end

 CancelTween()
 dragInput = input
 dragMoved = false
 dragStart = V2(input)
 startPos = window.Position
 startAbs = window.AbsolutePosition
 startSize = window.AbsoluteSize
end)

UserInputService.InputChanged:Connect(function(input: InputObject)
 local di = dragInput
 if not di then return end

 local mine
 if di.UserInputType == Enum.UserInputType.Touch then
  mine = (input == di)
 else
  mine = (input.UserInputType == Enum.UserInputType.MouseMovement)
 end
 if not mine then return end

 local pointer = V2(input)

 if not dragMoved then
  if (pointer - dragStart).Magnitude < DRAG_THRESHOLD then return end
  dragMoved = true
  if dockZone then RestoreForDrag(pointer) end
 end

 local d = pointer - dragStart
 local x, y = ClampAbs(startAbs.X + d.X, startAbs.Y + d.Y, startSize)
 window.Position = UDim2.new(
  startPos.X.Scale, startPos.X.Offset + (x - startAbs.X),
  startPos.Y.Scale, startPos.Y.Offset + (y - startAbs.Y)
 )

 SetPreview(ZoneAt(pointer))
end)

UserInputService.InputEnded:Connect(function(input: InputObject)
 local di = dragInput
 if not di then return end
 if input == di
  or (di.UserInputType == Enum.UserInputType.MouseButton1
   and input.UserInputType == Enum.UserInputType.MouseButton1) then
  local zone, moved = previewZone, dragMoved
  dragInput, dragMoved = nil, false
  SetPreview(nil)
  if moved and zone then Dock(zone) end
 end
end)

local function ClampNow()
 if dragInput or resizeInput or dockZone then return end
 local p, sz = window.AbsolutePosition, window.AbsoluteSize
 local x, y = ClampAbs(p.X, p.Y, sz)
 if x ~= p.X or y ~= p.Y then
  local pos = window.Position
  window.Position = UDim2.new(
   pos.X.Scale, pos.X.Offset + (x - p.X),
   pos.Y.Scale, pos.Y.Offset + (y - p.Y)
  )
 end
end

gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
 task.defer(function()
  Reapply()
  ClampNow()
 end)
end)
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(ClampNow) end)

UserInputService.InputChanged:Connect(function(input: InputObject)
 if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
 local p = V2(input)
 local changed = false
 for _, t in tabs do
  local ap, s = t.button.AbsolutePosition, t.button.AbsoluteSize
  local over = p.X >= ap.X and p.X <= ap.X + s.X and p.Y >= ap.Y and p.Y <= ap.Y + s.Y
  if over ~= t.hover then
   t.hover = over
   changed = true
   StyleTab(t)
  end
 end
 if changed then UpdateSeparators() end
end)

NewTab()
