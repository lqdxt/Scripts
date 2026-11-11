local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local TOGGLE_KEY = Enum.KeyCode.RightControl

local FLAGS = {
 {
  kind = "slider",
  label = "FPS Cap",
  category = "Performance",
  flag = "TaskSchedulerTargetFps",
  min = 30,
  max = 999,
  step = 1,
  value = 999,
  rec = true
 },
 {
  kind = "slider",
  label = "Graphics Quality",
  category = "Performance",
  flag = "DebugFRMQualityLevelOverride",
  min = 1,
  max = 21,
  step = 1,
  value = 1,
  rec = true
 },
 {
  kind = "slider",
  label = "Grass Max Distance",
  category = "Grass",
  flag = "FRMMaxGrassDistance",
  min = 0,
  max = 500,
  step = 5,
  value = 0,
  rec = true
 },
 {
  kind = "slider",
  label = "CSG LOD Distance",
  category = "Performance",
  flag = "CSGLevelOfDetailSwitchingDistance",
  min = 1,
  max = 500,
  step = 5,
  value = 1,
  rec = true
 },
 {
  kind = "toggle",
  label = "No Grass",
  category = "Grass",
  flag = "FRMMinGrassDistance",
  value = "0",
  rec = true
 },
 {
  kind = "toggle",
  label = "Reduce Grass Sway",
  category = "Grass",
  flag = "GrassMovementReducedMotionFactor",
  value = "1",
  rec = true
 },
 {
  kind = "toggle",
  label = "Fast GPU Light Cull",
  category = "Performance",
  flag = "FastGPULightCulling3",
  value = "true",
  rec = false
 },
 {
  kind = "toggle",
  label = "Perf Mode",
  category = "Performance",
  flag = "DebugPerfMode",
  value = "true",
  rec = false
 },
 {
  kind = "toggle",
  label = "Gray Sky",
  category = "Visuals",
  flag = "DebugSkyGray",
  value = "true",
  rec = false
 },
 {
  kind = "toggle",
  label = "No GUI Blur",
  category = "Visuals",
  flag = "RobloxGuiBlurIntensity",
  value = "0",
  rec = false
 },
 {
  kind = "toggle",
  label = "FPS Counter",
  category = "Debug",
  flag = "DebugDisplayFPS",
  value = "true",
  rec = false
 }
}

local DEFAULTS = {
 DebugFRMQualityLevelOverride = "0",
 TaskSchedulerTargetFps = "60",
 FRMMaxGrassDistance = "250",
 FRMMinGrassDistance = "100",
 CSGLevelOfDetailSwitchingDistance = "250",
 GrassMovementReducedMotionFactor = "0",
 FastGPULightCulling3 = "false",
 DebugPerfMode = "false",
 DebugSkyGray = "false",
 RobloxGuiBlurIntensity = "1",
 DebugDisplayFPS = "false",
}

local hasSet = typeof(setfflag) == "function"
local hasGet = typeof(getfflag) == "function"

local originals = {}
if hasGet then
 for _, d in ipairs(FLAGS) do
  local ok, v = pcall(getfflag, d.flag)
  if ok and v ~= nil and tostring(v) ~= "" then
   originals[d.flag] = tostring(v)
  end
 end
end

local function SetFFlag(flag, value)
 if not hasSet then return false end
 return (pcall(setfflag, flag, tostring(value)))
end

local function MakeInstanceEffect(roots, match, apply, restore)
 local saved = {}
 local conns = {}
 local token = 0

 local function Handle(inst)
  if saved[inst] ~= nil or not match(inst) then return end
  local ok, v = pcall(apply, inst)
  if ok then saved[inst] = { v } end
 end

 return function(on)
  token += 1
  local mine = token
  for _, c in ipairs(conns) do c:Disconnect() end
  table.clear(conns)

  if on then
   for _, root in ipairs(roots) do
    conns[#conns + 1] = root.DescendantAdded:Connect(Handle)
   end
   task.spawn(function()
    local n = 0
    for _, root in ipairs(roots) do
     for _, inst in ipairs(root:GetDescendants()) do
      if token ~= mine then return end
      Handle(inst)
      n += 1
      if n % 1500 == 0 then task.wait() end
     end
    end
   end)
  else
   for inst, s in pairs(saved) do
    pcall(restore, inst, s[1])
    saved[inst] = nil
   end
  end
 end
end

local function IsPart(i)
 return i:IsA("BasePart") and not i:IsA("Terrain")
end

local EMITTER_CLASSES = { "ParticleEmitter", "Trail", "Beam", "Fire", "Smoke", "Sparkles" }
local function IsEmitter(i)
 for _, c in ipairs(EMITTER_CLASSES) do
  if i:IsA(c) then return true end
 end
 return false
end

local NoMaterials = MakeInstanceEffect({ workspace }, IsPart,
 function(i)
  local s = { i.Material, i.MaterialVariant }
  i.Material = Enum.Material.SmoothPlastic
  i.MaterialVariant = ""
  return s
 end,
 function(i, s)
  i.Material = s[1]
  i.MaterialVariant = s[2]
 end)

local NoParticles = MakeInstanceEffect({ workspace }, IsEmitter,
 function(i)
  local v = i.Enabled
  i.Enabled = false
  return v
 end,
 function(i, v) i.Enabled = v end)

local NoDecals = MakeInstanceEffect({ workspace },
 function(i) return i:IsA("Decal") end,
 function(i)
  local v = i.Transparency
  i.Transparency = 1
  return v
 end,
 function(i, v) i.Transparency = v end)

local NoReflections = MakeInstanceEffect({ workspace }, IsPart,
 function(i)
  local v = i.Reflectance
  i.Reflectance = 0
  return v
 end,
 function(i, v) i.Reflectance = v end)

local NoPostFx = MakeInstanceEffect({ Lighting, workspace },
 function(i) return i:IsA("PostEffect") end,
 function(i)
  local v = i.Enabled
  i.Enabled = false
  return v
 end,
 function(i, v) i.Enabled = v end)

local PartShadows = MakeInstanceEffect({ workspace }, IsPart,
 function(i)
  local v = i.CastShadow
  i.CastShadow = false
  return v
 end,
 function(i, v) i.CastShadow = v end)

local globalShadowsOrig
local function NoShadows(on)
 PartShadows(on)
 pcall(function()
  if on then
   if globalShadowsOrig == nil then globalShadowsOrig = Lighting.GlobalShadows end
   Lighting.GlobalShadows = false
  elseif globalShadowsOrig ~= nil then
   Lighting.GlobalShadows = globalShadowsOrig
   globalShadowsOrig = nil
  end
 end)
end

local waterOrig
local function FlatWater(on)
 pcall(function()
  local t = workspace.Terrain
  if on then
   if not waterOrig then
    waterOrig = {
     WaterWaveSize = t.WaterWaveSize,
     WaterWaveSpeed = t.WaterWaveSpeed,
     WaterReflectance = t.WaterReflectance,
    }
   end
   t.WaterWaveSize = 0
   t.WaterWaveSpeed = 0
   t.WaterReflectance = 0
  elseif waterOrig then
   for k, v in pairs(waterOrig) do t[k] = v end
   waterOrig = nil
  end
 end)
end

local qualityOrig
local function LowQuality(on)
 pcall(function()
  local r = settings().Rendering
  if on then
   qualityOrig = qualityOrig or r.QualityLevel
   r.QualityLevel = Enum.QualityLevel.Level01
  elseif qualityOrig then
   r.QualityLevel = qualityOrig
   qualityOrig = nil
  end
 end)
end

local MAIN = {
 {
  label = "No Materials",
  category = "Textures & Materials",
  rec = true,
  apply = NoMaterials
 },
 {
  label = "No Particles",
  category = "Effects & Lighting",
  rec = true,
  apply = NoParticles
 },
 {
  label = "No Decals & Textures",
  category = "Textures & Materials",
  rec = false,
  apply = NoDecals
 },
 {
  label = "No Shadows",
  category = "Effects & Lighting",
  rec = true,
  apply = NoShadows
 },
 {
  label = "No Reflections",
  category = "Textures & Materials",
  rec = true,
  apply = NoReflections
 },
 {
  label = "No Post-Processing",
  category = "Effects & Lighting",
  rec = true,
  apply = NoPostFx
 },
 {
  label = "Flat Water",
  category = "World & Quality",
  rec = true,
  apply = FlatWater
 },
 {
  label = "Lowest Render Quality",
  category = "World & Quality",
  rec = true,
  apply = LowQuality
 }
}

local function GetParent()
 local ok, ui = pcall(function() return gethui and gethui() end)
 if ok and ui then return ui end
 local ok2 = pcall(function() return game:GetService("CoreGui").Name end)
 if ok2 then return game:GetService("CoreGui") end
 return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local parent = GetParent()
local old = parent:FindFirstChild("FFlagFPS")
if old then old:Destroy() end

local BG = Color3.fromRGB(24, 25, 31)
local BAR = Color3.fromRGB(32, 34, 43)
local ROW = Color3.fromRGB(38, 40, 50)
local TRACK = Color3.fromRGB(62, 66, 82)
local ACCENT = Color3.fromRGB(88, 140, 255)
local ON_COL = Color3.fromRGB(70, 200, 120)
local OFF_COL = Color3.fromRGB(100, 104, 122)
local TEXT = Color3.fromRGB(235, 237, 245)
local TEXT_DIM = Color3.fromRGB(170, 174, 192)
local STROKE = Color3.fromRGB(55, 58, 72)

local THEMES = {
 Dark = {
  BG = BG, BAR = BAR, ROW = ROW, TRACK = TRACK, OFF_COL = OFF_COL,
  TEXT = TEXT, TEXT_DIM = TEXT_DIM, STROKE = STROKE,
 },
 Light = {
  BG = Color3.fromRGB(232, 234, 241),
  BAR = Color3.fromRGB(220, 223, 233),
  ROW = Color3.fromRGB(247, 248, 252),
  TRACK = Color3.fromRGB(190, 195, 210),
  OFF_COL = Color3.fromRGB(168, 173, 190),
  TEXT = Color3.fromRGB(30, 33, 45),
  TEXT_DIM = Color3.fromRGB(95, 100, 120),
  STROKE = Color3.fromRGB(200, 204, 216),
 },
}
local THEME_KEYS = { "BG", "BAR", "ROW", "TRACK", "OFF_COL", "TEXT", "TEXT_DIM", "STROKE" }
local currentTheme = THEMES.Dark

local accentBound = {}
local accentRefreshers = {}
local function Accent(inst, prop)
 accentBound[#accentBound + 1] = { inst, prop }
 inst[prop] = ACCENT
end
local function SetAccent(c)
 ACCENT = c
 for _, b in ipairs(accentBound) do
  pcall(function() b[1][b[2]] = c end)
 end
 for _, f in ipairs(accentRefreshers) do pcall(f) end
end

local function Corner(inst, r)
 local c = Instance.new("UICorner")
 c.CornerRadius = r == "full" and UDim.new(1, 0) or UDim.new(0, r or 8)
 c.Parent = inst
 return c
end

local function Pointer(input)
 return input.UserInputType == Enum.UserInputType.MouseButton1
  or input.UserInputType == Enum.UserInputType.Touch
end

local function MakeDraggable(startInput, onMove, onEnd)
 local isMouse = startInput.UserInputType == Enum.UserInputType.MouseButton1
 local moveConn, endConn
 local finished = false

 local function Finish()
  if finished then return end
  finished = true
  moveConn:Disconnect()
  endConn:Disconnect()
  if onEnd then onEnd() end
 end

 moveConn = UIS.InputChanged:Connect(function(input)
  if input == startInput
   or (isMouse and input.UserInputType == Enum.UserInputType.MouseMovement) then
   onMove(input.Position)
  end
 end)

 endConn = UIS.InputEnded:Connect(function(input)
  if input == startInput
   or (isMouse and input.UserInputType == Enum.UserInputType.MouseButton1) then
   Finish()
  end
 end)
end

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local function PackColor(c)
 return math.round(c.R * 255) * 65536 + math.round(c.G * 255) * 256 + math.round(c.B * 255)
end

local function ApplyTheme(name)
 local t = THEMES[name]
 if not t or t == currentTheme then return end

 local map = {}
 for _, k in ipairs(THEME_KEYS) do
  map[PackColor(currentTheme[k])] = t[k]
 end

 local function Remap(inst, prop)
  local new = map[PackColor(inst[prop])]
  if new then inst[prop] = new end
 end

 for _, d in ipairs(gui:GetDescendants()) do
  if d:IsA("GuiObject") then Remap(d, "BackgroundColor3") end
  if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
   Remap(d, "TextColor3")
  end
  if d:IsA("TextBox") then Remap(d, "PlaceholderColor3") end
  if d:IsA("ImageLabel") or d:IsA("ImageButton") then Remap(d, "ImageColor3") end
  if d:IsA("UIStroke") then Remap(d, "Color") end
 end

 BG, BAR, ROW, TRACK, OFF_COL = t.BG, t.BAR, t.ROW, t.TRACK, t.OFF_COL
 TEXT, TEXT_DIM, STROKE = t.TEXT, t.TEXT_DIM, t.STROKE
 currentTheme = t
 SetAccent(ACCENT)
end

local function ScreenSize()
 local s = gui.AbsoluteSize
 if s.X > 0 and s.Y > 0 then return s end
 local cam = workspace.CurrentCamera
 return cam and cam.ViewportSize or Vector2.new(800, 450)
end

local function PosOf(inst)
 return Vector2.new(inst.Position.X.Offset, inst.Position.Y.Offset)
end

local W = math.min(580, math.max(ScreenSize().X - 20, 420))
local H = math.min(470, math.max(ScreenSize().Y - 40, 280))
local ORB = 52
local SIDE = 156

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(W, H)
main.Position = UDim2.fromOffset(
 math.max((ScreenSize().X - W) / 2, 0),
 math.max((ScreenSize().Y - H) / 2, 0)
)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Corner(main, 12)
local stroke = Instance.new("UIStroke")
stroke.Color = STROKE
stroke.Parent = main

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = main

-- Soft blurred shadow around the window (native UIShadow)
local shadowOk, shadow = pcall(function()
 local sh = Instance.new("UIShadow")
 sh.Color = Color3.new(0, 0, 0)
 sh.Transparency = 0.45
 sh.BlurRadius = UDim.new(0, 30)
 sh.Spread = UDim2.fromOffset(6, 6)
 sh.Offset = UDim2.fromOffset(0, 4)
 sh.ZIndex = -1
 sh.Parent = main
 return sh
end)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 40)
bar.BackgroundColor3 = BAR
bar.BorderSizePixel = 0
bar.Parent = main
Corner(bar, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(14, 0)
title.BackgroundTransparency = 1
title.Text = "FPS"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = TEXT
title.Parent = bar

local function Button(text, xOffset)
 local b = Instance.new("TextButton")
 b.Size = UDim2.fromOffset(30, 26)
 b.Position = UDim2.new(1, xOffset, 0, 7)
 b.BackgroundColor3 = ROW
 b.Text = text
 b.Font = Enum.Font.GothamBold
 b.TextSize = 14
 b.TextColor3 = TEXT
 b.Parent = bar
 Corner(b, 6)
 return b
end
local minBtn = Button("–", -78)
local closeBtn = Button("X", -42)

do
 local busy = false
 bar.InputBegan:Connect(function(input)
  if busy or not Pointer(input) then return end
  busy = true
  local startPos = input.Position
  local startAbs = PosOf(main)
  MakeDraggable(input, function(pos)
   local d = pos - startPos
   local s = ScreenSize()
   main.Position = UDim2.fromOffset(
    math.clamp(startAbs.X + d.X, 0, math.max(s.X - W, 0)),
    math.clamp(startAbs.Y + d.Y, 0, math.max(s.Y - 40, 0))
   )
  end, function()
   busy = false
  end)
 end)
end

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, SIDE - 16, 1, -56)
sidebar.Position = UDim2.fromOffset(8, 48)
sidebar.BackgroundColor3 = BAR
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Corner(sidebar, 10)
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.PaddingLeft = UDim.new(0, 8)
sidePad.PaddingRight = UDim.new(0, 8)
sidePad.Parent = sidebar
local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -SIDE, 1, -40)
content.Position = UDim2.fromOffset(SIDE, 40)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local tabCount = 0
local SelectTab
local currentTab
local CreateIcon

local function CreatePage()
 local page = Instance.new("Frame")
 page.Size = UDim2.fromScale(1, 1)
 page.BackgroundTransparency = 1
 page.Visible = false
 page.Parent = content

 local list = Instance.new("ScrollingFrame")
 list.Size = UDim2.new(1, -20, 1, -66)
 list.Position = UDim2.fromOffset(10, 8)
 list.BackgroundTransparency = 1
 list.BorderSizePixel = 0
 list.ScrollBarThickness = 3
 list.CanvasSize = UDim2.new()
 list.AutomaticCanvasSize = Enum.AutomaticSize.Y
 list.Parent = page
 local layout = Instance.new("UIListLayout")
 layout.Padding = UDim.new(0, 6)
 layout.SortOrder = Enum.SortOrder.LayoutOrder
 layout.Parent = list

 return page, list
end

local function AddTab(name, iconName)
 tabCount += 1
 local page, list = CreatePage()

 local b = Instance.new("TextButton")
 b.Size = UDim2.new(1, 0, 0, 34)
 b.LayoutOrder = tabCount
 b.BackgroundColor3 = ROW
 b.Text = name
 b.Font = Enum.Font.GothamBold
 b.TextSize = 13
 b.TextColor3 = TEXT_DIM
 b.AutoButtonColor = false
 b.Parent = sidebar
 Corner(b, 8)
 b.MouseButton1Click:Connect(function() SelectTab(name) end)

 local icon, iconProp = CreateIcon(b, iconName)
 local label
 if icon then
  b.Text = ""
  label = Instance.new("TextLabel")
  label.Size = UDim2.new(1, -36, 1, 0)
  label.Position = UDim2.fromOffset(36, 0)
  label.BackgroundTransparency = 1
  label.Text = name
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.Font = Enum.Font.GothamBold
  label.TextSize = 13
  label.TextColor3 = TEXT_DIM
  label.Parent = b
 end

 tabs[name] = { page = page, btn = b, icon = icon, iconProp = iconProp, label = label }
 return page, list
end

SelectTab = function(name)
 currentTab = name
 for n, t in pairs(tabs) do
  local active = n == name
  local col = active and Color3.new(1, 1, 1) or TEXT_DIM
  t.page.Visible = active
  t.btn.BackgroundColor3 = active and ACCENT or ROW
  t.btn.TextColor3 = col
  if t.icon then t.icon[t.iconProp] = col end
  if t.label then t.label.TextColor3 = col end
 end
end

accentRefreshers[#accentRefreshers + 1] = function()
 if currentTab then SelectTab(currentTab) end
end

local function Button2(page, text, xScale, color)
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0.5, -15, 0, 38)
 b.Position = UDim2.new(xScale, xScale == 0 and 10 or 5, 1, -50)
 b.BackgroundColor3 = color
 b.Text = text
 b.Font = Enum.Font.GothamBold
 b.TextSize = 13
 b.TextColor3 = Color3.new(1, 1, 1)
 b.Parent = page
 Corner(b, 8)
 return b
end

local IconModule
do
 local function Try(url, setLucide)
  local ok, mod = pcall(function()
   return loadstring(game:HttpGet(url))()
  end)
  if ok and typeof(mod) == "table" then
   if setLucide and mod.SetProvider then pcall(mod.SetProvider, "lucide") end
   return mod
  end
 end
 IconModule = Try("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua", true)
  or Try("https://raw.githubusercontent.com/notpoiu/lucide-roblox-direct/refs/heads/main/source.lua", false)
end

local function GetIcon(name)
 if not IconModule or not IconModule.GetAsset then return nil end
 local ok, icon = pcall(IconModule.GetAsset, name)
 if not ok or not icon then return nil end

 if IconModule.GetFontAsset then
  local fok, font = pcall(IconModule.GetFontAsset, name)
  if fok and font and font.FontFace and font.Text then
   local merged = table.clone(icon)
   merged.FontFace = font.FontFace
   merged.Text = font.Text
   return merged
  end
 end
 return icon
end

function CreateIcon(parent, name)
 local icon = GetIcon(name)
 if not icon then return nil end

 local inst, colorProp
 if icon.FontFace then
  inst = Instance.new("TextLabel")
  inst.FontFace = icon.FontFace
  inst.RichText = false
  inst.Text = icon.Text
  inst.TextScaled = true
  local pad = Instance.new("UIPadding")
  pad.PaddingLeft = UDim.new(-0.5, -0.5)
  pad.PaddingRight = UDim.new(-0.5, 0)
  pad.Parent = inst
  colorProp = "TextColor3"
 else
  inst = Instance.new("ImageLabel")
  inst.ScaleType = Enum.ScaleType.Fit
  inst.Image = icon.Url or ""
  inst.ImageRectOffset = icon.ImageRectOffset or Vector2.zero
  inst.ImageRectSize = icon.ImageRectSize or Vector2.zero
  colorProp = "ImageColor3"
 end

 inst.BackgroundTransparency = 1
 inst.AnchorPoint = Vector2.new(0, 0.5)
 inst.Position = UDim2.new(0, 10, 0.5, 0)
 inst.Size = UDim2.fromOffset(18, 18)
 inst.Parent = parent
 return inst, colorProp
end

local function CreateToggle(row, y)
 local pill = Instance.new("TextButton")
 pill.Size = UDim2.fromOffset(42, 22)
 pill.Position = UDim2.new(1, -54, 0, y)
 pill.BackgroundColor3 = OFF_COL
 pill.Text = ""
 pill.AutoButtonColor = false
 pill.Parent = row
 Corner(pill, "full")

 local knob = Instance.new("Frame")
 knob.Size = UDim2.fromOffset(16, 16)
 knob.AnchorPoint = Vector2.new(0, 0.5)
 knob.Position = UDim2.new(0, 3, 0.5, 0)
 knob.BackgroundColor3 = Color3.new(1, 1, 1)
 knob.BorderSizePixel = 0
 knob.Parent = pill
 Corner(knob, "full")

 local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad)
 local function Render(on)
  TweenService:Create(pill, info, { BackgroundColor3 = on and ON_COL or OFF_COL }):Play()
  TweenService:Create(knob, info, {
   Position = on and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
  }):Play()
 end
 return pill, Render
end

local function SetRow(r, on)
 r.on = on
 if r.renderPill then r.renderPill(on) end
 r.apply(on)
end

local function CreateSlider(row, r, list)
 local valueLabel = Instance.new("TextLabel")
 valueLabel.Size = UDim2.fromOffset(52, 22)
 valueLabel.Position = UDim2.new(1, -66, 0, 9)
 valueLabel.BackgroundTransparency = 1
 valueLabel.Font = Enum.Font.GothamBold
 valueLabel.TextSize = 13
 Accent(valueLabel, "TextColor3")
 valueLabel.TextXAlignment = Enum.TextXAlignment.Right
 valueLabel.Parent = row

 local track = Instance.new("Frame")
 track.AnchorPoint = Vector2.new(0, 0.5)
 track.Size = UDim2.new(1, -40, 0, 6)
 track.Position = UDim2.new(0, 20, 0, 48)
 track.BackgroundColor3 = TRACK
 track.BorderSizePixel = 0
 track.Parent = row
 Corner(track, "full")

 local fill = Instance.new("Frame")
 fill.Size = UDim2.new(0, 0, 1, 0)
 Accent(fill, "BackgroundColor3")
 fill.BorderSizePixel = 0
 fill.Parent = track
 Corner(fill, "full")

 local knobHit = Instance.new("TextButton")
 knobHit.AnchorPoint = Vector2.new(0.5, 0.5)
 knobHit.Size = UDim2.fromOffset(34, 34)
 knobHit.BackgroundTransparency = 1
 knobHit.Text = ""
 knobHit.AutoButtonColor = false
 knobHit.Parent = track

 local knob = Instance.new("Frame")
 knob.AnchorPoint = Vector2.new(0.5, 0.5)
 knob.Size = UDim2.fromOffset(18, 18)
 knob.Position = UDim2.fromScale(0.5, 0.5)
 knob.BackgroundColor3 = Color3.new(1, 1, 1)
 knob.BorderSizePixel = 0
 knob.Parent = knobHit
 Corner(knob, "full")
 local knobStroke = Instance.new("UIStroke")
 Accent(knobStroke, "Color")
 knobStroke.Thickness = 2
 knobStroke.Parent = knob

 local function AlphaOf(v)
  return (v - r.min) / (r.max - r.min)
 end

 local function Render()
  local a = AlphaOf(r.value)
  fill.Size = UDim2.new(a, 0, 1, 0)
  knobHit.Position = UDim2.new(a, 0, 0.5, 0)
  valueLabel.Text = tostring(r.value)
 end

 local function SetFromX(x)
  local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
  local v = r.min + a * (r.max - r.min)
  v = math.clamp(math.floor(v / r.step + 0.5) * r.step, r.min, r.max)
  if v ~= r.value then
   r.value = v
   r.on = true
   Render()
   if r.onSlider then r.onSlider(v) end
  end
 end

 local busy = false
 knobHit.InputBegan:Connect(function(input)
  if busy or not Pointer(input) then return end
  busy = true
  list.ScrollingEnabled = false
  local knobX = track.AbsolutePosition.X + track.AbsoluteSize.X * AlphaOf(r.value)
  local grab = input.Position.X - knobX
  MakeDraggable(input, function(pos)
   SetFromX(pos.X - grab)
  end, function()
   busy = false
   list.ScrollingEnabled = true
  end)
 end)

 Render()
end

local ASSET_DIR = "FpsBooster"
local CARET_PATH = ASSET_DIR .. "/Caret.png"
local CARET_URL = "https://raw.githubusercontent.com/lqdxt/LqExplorer/main/images/Caret.png"

local function LoadCaret()
 local canFs = typeof(isfolder) == "function" and typeof(makefolder) == "function"
  and typeof(isfile) == "function" and typeof(writefile) == "function"
  and typeof(readfile) == "function" and typeof(getcustomasset) == "function"
 if not canFs then return nil end
 local ok, asset = pcall(function()
  if not isfolder(ASSET_DIR) then makefolder(ASSET_DIR) end
  if not isfile(CARET_PATH) or #readfile(CARET_PATH) == 0 then
   writefile(CARET_PATH, game:HttpGet(CARET_URL))
  end
  return getcustomasset(CARET_PATH)
 end)
 if ok and type(asset) == "string" and asset ~= "" then return asset end
 return nil
end

local caretAsset = LoadCaret()

local function CreateDropdown(row, r, list)
 local options = r.options or {}
 local ITEM_H, MAX_SHOW = 28, 6

 local btn = Instance.new("TextButton")
 btn.Size = UDim2.fromOffset(150, 26)
 btn.Position = UDim2.new(1, -164, 0, 7)
 btn.BackgroundColor3 = BAR
 btn.BorderSizePixel = 0
 btn.Text = ""
 btn.AutoButtonColor = false
 btn.Parent = row
 Corner(btn, 6)

 local valueText = Instance.new("TextLabel")
 valueText.Size = UDim2.new(1, -32, 1, 0)
 valueText.Position = UDim2.fromOffset(10, 0)
 valueText.BackgroundTransparency = 1
 valueText.Text = tostring(r.value)
 valueText.TextXAlignment = Enum.TextXAlignment.Left
 valueText.TextTruncate = Enum.TextTruncate.AtEnd
 valueText.Font = Enum.Font.Gotham
 valueText.TextSize = 13
 valueText.TextColor3 = TEXT
 valueText.Parent = btn

 local caret, closedRot, openRot
 if caretAsset then
  caret = Instance.new("ImageLabel")
  caret.Image = caretAsset
  caret.ImageColor3 = TEXT_DIM
  caret.ScaleType = Enum.ScaleType.Fit
  closedRot, openRot = 90, -90
 else
  caret = Instance.new("TextLabel")
  caret.Text = "▼"
  caret.Font = Enum.Font.Gotham
  caret.TextSize = 9
  caret.TextColor3 = TEXT_DIM
  closedRot, openRot = 0, 180
 end
 caret.BackgroundTransparency = 1
 caret.AnchorPoint = Vector2.new(0.5, 0.5)
 caret.Position = UDim2.new(1, -16, 0.5, 0)
 caret.Size = UDim2.fromOffset(12, 12)
 caret.Rotation = closedRot
 caret.Parent = btn

 local blocker = Instance.new("TextButton")
 blocker.Size = UDim2.fromScale(1, 1)
 blocker.BackgroundTransparency = 1
 blocker.Text = ""
 blocker.AutoButtonColor = false
 blocker.ZIndex = 60
 blocker.Visible = false
 blocker.Parent = main

 local popup = Instance.new("ScrollingFrame")
 popup.BackgroundColor3 = BAR
 popup.BorderSizePixel = 0
 popup.ScrollBarThickness = 3
 popup.CanvasSize = UDim2.new()
 popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
 popup.ZIndex = 61
 popup.Visible = false
 popup.Parent = main
 Corner(popup, 8)
 local popupStroke = Instance.new("UIStroke")
 popupStroke.Color = STROKE
 popupStroke.Parent = popup
 local popupPad = Instance.new("UIPadding")
 popupPad.PaddingTop = UDim.new(0, 3)
 popupPad.PaddingBottom = UDim.new(0, 3)
 popupPad.PaddingLeft = UDim.new(0, 4)
 popupPad.PaddingRight = UDim.new(0, 4)
 popupPad.Parent = popup
 local popupLayout = Instance.new("UIListLayout")
 popupLayout.Padding = UDim.new(0, 2)
 popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
 popupLayout.Parent = popup

 local optionBtns = {}
 local open = false
 local caretInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad)

 local function Style(ob, hover)
  local sel = ob.Text == tostring(r.value)
  ob.BackgroundColor3 = sel and ACCENT or ROW
  ob.BackgroundTransparency = (sel or hover) and 0 or 1
  ob.TextColor3 = sel and Color3.new(1, 1, 1) or (hover and TEXT or TEXT_DIM)
 end

 local function Highlight()
  for _, ob in ipairs(optionBtns) do Style(ob, false) end
 end

 local function SetOpen(state)
  if state == open then return end
  open = state
  TweenService:Create(caret, caretInfo, { Rotation = state and openRot or closedRot }):Play()
  blocker.Visible = state
  popup.Visible = state
  if not state then return end

  local s = uiScale.Scale
  local origin = main.AbsolutePosition
  local screen = ScreenSize()
  blocker.Position = UDim2.fromOffset(-origin.X / s, -origin.Y / s)
  blocker.Size = UDim2.fromOffset(screen.X / s, screen.Y / s)

  local w = btn.AbsoluteSize.X / s
  local h = math.min(#options, MAX_SHOW) * ITEM_H + 6
  local x = (btn.AbsolutePosition.X - origin.X) / s
  local btnY = (btn.AbsolutePosition.Y - origin.Y) / s
  local y = btnY + btn.AbsoluteSize.Y / s + 4
  if origin.Y + (y + h) * s > screen.Y then
   y = btnY - 4 - h
  end
  popup.Size = UDim2.fromOffset(w, h)
  popup.Position = UDim2.fromOffset(x, y)
  popup.CanvasPosition = Vector2.zero
 end

 local function SetValue(v)
  r.value = v
  valueText.Text = tostring(v)
  Highlight()
 end
 r.setValue = SetValue
 accentRefreshers[#accentRefreshers + 1] = Highlight

 for i, opt in ipairs(options) do
  local ob = Instance.new("TextButton")
  ob.Size = UDim2.new(1, 0, 0, ITEM_H - 2)
  ob.LayoutOrder = i
  ob.BorderSizePixel = 0
  ob.Text = tostring(opt)
  ob.Font = Enum.Font.Gotham
  ob.TextSize = 13
  ob.AutoButtonColor = false
  ob.Parent = popup
  Corner(ob, 6)
  optionBtns[#optionBtns + 1] = ob
  Style(ob, false)
  ob.MouseEnter:Connect(function() Style(ob, true) end)
  ob.MouseLeave:Connect(function() Style(ob, false) end)
  ob.MouseButton1Click:Connect(function()
   SetValue(opt)
   SetOpen(false)
   r.on = true
   if r.onChange then r.onChange(opt) end
  end)
 end

 btn.MouseButton1Click:Connect(function() SetOpen(not open) end)
 blocker.MouseButton1Click:Connect(function() SetOpen(false) end)
 main:GetPropertyChangedSignal("Visible"):Connect(function()
  if not main.Visible then SetOpen(false) end
 end)
 if list then
  list:GetPropertyChangedSignal("CanvasPosition"):Connect(function() SetOpen(false) end)
 end
end

local HUE_SEQ = {}
for i = 0, 6 do
 HUE_SEQ[#HUE_SEQ + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))
end

local function CreateColorPicker(row, r, list)
 local MAP_W, MAP_H, BAR_W, PAD, GAP = 176, 140, 16, 8, 6
 local POP_W = PAD * 2 + MAP_W + GAP + BAR_W
 local POP_H = PAD * 3 + MAP_H + 24
 local h, sat, val = r.value:ToHSV()

 local btn = Instance.new("TextButton")
 btn.Size = UDim2.fromOffset(150, 26)
 btn.Position = UDim2.new(1, -164, 0, 7)
 btn.BorderSizePixel = 0
 btn.AutoButtonColor = false
 btn.Font = Enum.Font.GothamBold
 btn.TextSize = 12
 btn.Parent = row
 Corner(btn, 6)

 local popup = Instance.new("Frame")
 popup.Size = UDim2.fromOffset(POP_W, POP_H)
 popup.BackgroundColor3 = BAR
 popup.BorderSizePixel = 0
 popup.ZIndex = 61
 popup.Visible = false
 popup.Parent = main
 Corner(popup, 8)
 local popupStroke = Instance.new("UIStroke")
 popupStroke.Color = STROKE
 popupStroke.Parent = popup

 local sv = Instance.new("TextButton")
 sv.Size = UDim2.fromOffset(MAP_W, MAP_H)
 sv.Position = UDim2.fromOffset(PAD, PAD)
 sv.BorderSizePixel = 0
 sv.Text = ""
 sv.AutoButtonColor = false
 sv.Parent = popup
 Corner(sv, 4)

 local white = Instance.new("Frame")
 white.Size = UDim2.fromScale(1, 1)
 white.BackgroundColor3 = Color3.new(1, 1, 1)
 white.BorderSizePixel = 0
 white.Parent = sv
 Corner(white, 4)
 local wg = Instance.new("UIGradient")
 wg.Transparency = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
 })
 wg.Parent = white

 local black = Instance.new("Frame")
 black.Size = UDim2.fromScale(1, 1)
 black.BackgroundColor3 = Color3.new(0, 0, 0)
 black.BorderSizePixel = 0
 black.Parent = sv
 Corner(black, 4)
 local bg = Instance.new("UIGradient")
 bg.Rotation = 90
 bg.Transparency = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
 })
 bg.Parent = black

 local svCursor = Instance.new("Frame")
 svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
 svCursor.Size = UDim2.fromOffset(10, 10)
 svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
 svCursor.BorderSizePixel = 0
 svCursor.Parent = sv
 Corner(svCursor, "full")
 local svCursorStroke = Instance.new("UIStroke")
 svCursorStroke.Color = Color3.new(0, 0, 0)
 svCursorStroke.Thickness = 1.5
 svCursorStroke.Parent = svCursor

 local hueBar = Instance.new("TextButton")
 hueBar.Size = UDim2.fromOffset(BAR_W, MAP_H)
 hueBar.Position = UDim2.fromOffset(PAD + MAP_W + GAP, PAD)
 hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
 hueBar.BorderSizePixel = 0
 hueBar.Text = ""
 hueBar.AutoButtonColor = false
 hueBar.Parent = popup
 Corner(hueBar, 4)
 local hg = Instance.new("UIGradient")
 hg.Color = ColorSequence.new(HUE_SEQ)
 hg.Rotation = 90
 hg.Parent = hueBar

 local hueCursor = Instance.new("Frame")
 hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
 hueCursor.Size = UDim2.new(1, 4, 0, 4)
 hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
 hueCursor.BorderSizePixel = 0
 hueCursor.Parent = hueBar
 Corner(hueCursor, 2)
 local hueCursorStroke = Instance.new("UIStroke")
 hueCursorStroke.Color = Color3.new(0, 0, 0)
 hueCursorStroke.Parent = hueCursor

 local info = Instance.new("Frame")
 info.Size = UDim2.new(1, -PAD * 2, 0, 24)
 info.Position = UDim2.fromOffset(PAD, PAD * 2 + MAP_H)
 info.BackgroundTransparency = 1
 info.Parent = popup

 local function MakeBox(xScale, xOff)
  local box = Instance.new("TextBox")
  box.Size = UDim2.new(0.5, -3, 1, 0)
  box.Position = UDim2.new(xScale, xOff, 0, 0)
  box.BackgroundColor3 = ROW
  box.BorderSizePixel = 0
  box.TextColor3 = TEXT
  box.Font = Enum.Font.Gotham
  box.TextSize = 12
  box.ClearTextOnFocus = false
  box.Parent = info
  Corner(box, 6)
  local st = Instance.new("UIStroke")
  st.Thickness = 1.5
  st.Transparency = 1
  st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  st.Parent = box
  Accent(st, "Color")
  box.Focused:Connect(function() st.Transparency = 0 end)
  box.FocusLost:Connect(function() st.Transparency = 1 end)
  return box
 end
 local hexBox = MakeBox(0, 0)
 local rgbBox = MakeBox(0.5, 3)

 local function Byte(x) return math.floor(x * 255 + 0.5) end

 local function Display()
  local c = Color3.fromHSV(h, sat, val)
  btn.BackgroundColor3 = c
  btn.Text = "#" .. c:ToHex()
  local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
  btn.TextColor3 = lum > 0.6 and Color3.fromRGB(25, 27, 35) or Color3.new(1, 1, 1)
  sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
  svCursor.Position = UDim2.fromScale(sat, 1 - val)
  hueCursor.Position = UDim2.fromScale(0.5, h)
  hexBox.Text = "#" .. c:ToHex()
  rgbBox.Text = Byte(c.R) .. ", " .. Byte(c.G) .. ", " .. Byte(c.B)
  return c
 end

 local function Commit()
  local c = Display()
  r.value = c
  r.on = true
  if r.onChange then r.onChange(c) end
 end

 local function SetColor(c)
  h, sat, val = c:ToHSV()
  Commit()
 end

 r.setValue = function(c)
  r.value = c
  h, sat, val = c:ToHSV()
  Display()
 end
 accentRefreshers[#accentRefreshers + 1] = function() Display() end

 hexBox.FocusLost:Connect(function()
  local ok, c = pcall(Color3.fromHex, hexBox.Text)
  if ok and typeof(c) == "Color3" then SetColor(c) else Display() end
 end)
 rgbBox.FocusLost:Connect(function()
  local rr, gg, bb = string.match(rgbBox.Text, "(%d+)%D+(%d+)%D+(%d+)")
  if rr then
   SetColor(Color3.fromRGB(math.min(tonumber(rr), 255), math.min(tonumber(gg), 255), math.min(tonumber(bb), 255)))
  else
   Display()
  end
 end)

 local function ToScreen(pos)
  return Vector2.new(pos.X, pos.Y)
 end

 sv.InputBegan:Connect(function(input)
  if not Pointer(input) then return end
  local function Move(pos)
   local p, a, sz = ToScreen(pos), sv.AbsolutePosition, sv.AbsoluteSize
   sat = math.clamp((p.X - a.X) / math.max(sz.X, 1), 0, 1)
   val = 1 - math.clamp((p.Y - a.Y) / math.max(sz.Y, 1), 0, 1)
   Commit()
  end
  Move(input.Position)
  MakeDraggable(input, Move)
 end)

 hueBar.InputBegan:Connect(function(input)
  if not Pointer(input) then return end
  local function Move(pos)
   local p, a, sz = ToScreen(pos), hueBar.AbsolutePosition, hueBar.AbsoluteSize
   h = math.clamp((p.Y - a.Y) / math.max(sz.Y, 1), 0, 1)
   Commit()
  end
  Move(input.Position)
  MakeDraggable(input, Move)
 end)

 local open = false
 local outsideConn

 local function Inside(inst, p)
  local a, sz = inst.AbsolutePosition, inst.AbsoluteSize
  return p.X >= a.X and p.X <= a.X + sz.X and p.Y >= a.Y and p.Y <= a.Y + sz.Y
 end

 local function SetOpen(state)
  if state == open then return end
  open = state
  popup.Visible = state
  if outsideConn then outsideConn:Disconnect() outsideConn = nil end
  if not state then return end

  local sc = uiScale.Scale
  local origin = main.AbsolutePosition
  local screen = ScreenSize()
  local bx = (btn.AbsolutePosition.X - origin.X) / sc
  local by = (btn.AbsolutePosition.Y - origin.Y) / sc
  local x = bx + btn.AbsoluteSize.X / sc - POP_W
  local y = by + btn.AbsoluteSize.Y / sc + 4
  if origin.Y + (y + POP_H) * sc > screen.Y then
   y = by - 4 - POP_H
  end
  popup.Position = UDim2.fromOffset(x, y)

  outsideConn = UIS.InputBegan:Connect(function(input)
   if not Pointer(input) then return end
   local p = ToScreen(input.Position)
   if Inside(popup, p) or Inside(btn, p) then return end
   SetOpen(false)
  end)
 end

 btn.MouseButton1Click:Connect(function() SetOpen(not open) end)
 main:GetPropertyChangedSignal("Visible"):Connect(function()
  if not main.Visible then SetOpen(false) end
 end)
 if list then
  list:GetPropertyChangedSignal("CanvasPosition"):Connect(function() SetOpen(false) end)
 end

 Display()
end

local bindingKey = false

local function CreateKeybind(row, r)
 local btn = Instance.new("TextButton")
 btn.Size = UDim2.fromOffset(150, 26)
 btn.Position = UDim2.new(1, -164, 0, 7)
 btn.BackgroundColor3 = BAR
 btn.BorderSizePixel = 0
 btn.AutoButtonColor = false
 btn.Text = tostring(r.value or "")
 btn.TextColor3 = TEXT
 btn.TextXAlignment = Enum.TextXAlignment.Left
 btn.Font = Enum.Font.Gotham
 btn.TextSize = 13
 btn.Parent = row
 Corner(btn, 6)

 local pad = Instance.new("UIPadding")
 pad.PaddingLeft = UDim.new(0, 8)
 pad.PaddingRight = UDim.new(0, 8)
 pad.Parent = btn

 local stroke = Instance.new("UIStroke")
 Accent(stroke, "Color")
 stroke.Thickness = 1.5
 stroke.Transparency = 1
 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 stroke.Parent = btn

 local conn
 local overSelf = false
 btn.InputBegan:Connect(function(input)
  local t = input.UserInputType
  if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
   overSelf = true
  end
 end)
 local function StopListening()
  if conn then conn:Disconnect() conn = nil end
  stroke.Transparency = 1
  task.defer(function() bindingKey = false end)
 end

 r.setValue = function(v)
  r.value = v
  btn.Text = tostring(v)
 end

 btn.MouseButton1Click:Connect(function()
  if conn then
   btn.Text = tostring(r.value or "")
   StopListening()
   return
  end
  bindingKey = true
  btn.Text = "..."
  stroke.Transparency = 0
  overSelf = false
  conn = UIS.InputBegan:Connect(function(input)
   local t = input.UserInputType
   if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
    task.defer(function()
     if conn and not overSelf then
      btn.Text = tostring(r.value or "")
      StopListening()
     end
     overSelf = false
    end)
    return
   end
   if t ~= Enum.UserInputType.Keyboard then return end
   if input.KeyCode == Enum.KeyCode.Unknown then return end
   StopListening()
   r.on = true
   if r.onChange then
    r.onChange(input.KeyCode.Name)
   else
    r.setValue(input.KeyCode.Name)
   end
  end)
 end)

 main:GetPropertyChangedSignal("Visible"):Connect(function()
  if not main.Visible and conn then
   btn.Text = tostring(r.value or "")
   StopListening()
  end
 end)
end

local function CreateTextbox(row, r)
 if r.keybind then return CreateKeybind(row, r) end
 local box = Instance.new("TextBox")
 box.Size = UDim2.fromOffset(150, 26)
 box.Position = UDim2.new(1, -164, 0, 7)
 box.BackgroundColor3 = BAR
 box.BorderSizePixel = 0
 box.Text = tostring(r.value or "")
 box.PlaceholderText = r.placeholder or ""
 box.PlaceholderColor3 = OFF_COL
 box.TextColor3 = TEXT
 box.TextXAlignment = Enum.TextXAlignment.Left
 box.Font = Enum.Font.Gotham
 box.TextSize = 13
 box.ClearTextOnFocus = false
 box.ClipsDescendants = true
 box.Parent = row
 Corner(box, 6)

 local pad = Instance.new("UIPadding")
 pad.PaddingLeft = UDim.new(0, 8)
 pad.PaddingRight = UDim.new(0, 8)
 pad.Parent = box

 local stroke = Instance.new("UIStroke")
 Accent(stroke, "Color")
 stroke.Thickness = 1.5
 stroke.Transparency = 1
 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 stroke.Parent = box

 box.Focused:Connect(function()
  stroke.Transparency = 0
 end)

 box.FocusLost:Connect(function()
  stroke.Transparency = 1
  if r.numeric then
   local n = tonumber(box.Text)
   if n == nil then
    box.Text = tostring(r.value or "")
    return
   end
   if r.min then n = math.max(n, r.min) end
   if r.max then n = math.min(n, r.max) end
   r.value = n
   box.Text = tostring(n)
  else
   r.value = box.Text
  end
  r.on = true
  if r.onChange then r.onChange(r.value) end
 end)

 r.setValue = function(v)
  r.value = v
  box.Text = tostring(v)
 end
end

local function BuildRows(list, defs, handlers)
 local rows = {}

 local order, groups = {}, {}
 for _, d in ipairs(defs) do
  local c = d.category or ""
  if not groups[c] then
   groups[c] = {}
   order[#order + 1] = c
  end
  table.insert(groups[c], d)
 end
 local items = {}
 for _, c in ipairs(order) do
  if c ~= "" then items[#items + 1] = { header = c } end
  for _, d in ipairs(groups[c]) do items[#items + 1] = { def = d } end
 end

 for i, item in ipairs(items) do
  if item.header then
   local h = Instance.new("TextLabel")
   h.Size = UDim2.new(1, -6, 0, i == 1 and 20 or 28)
   h.LayoutOrder = i
   h.BackgroundTransparency = 1
   h.Text = string.upper(item.header)
   h.TextXAlignment = Enum.TextXAlignment.Left
   h.TextYAlignment = i == 1 and Enum.TextYAlignment.Center or Enum.TextYAlignment.Bottom
   h.Font = Enum.Font.GothamBold
   h.TextSize = 11
   h.TextColor3 = TEXT_DIM
   h.Parent = list
   local hp = Instance.new("UIPadding")
   hp.PaddingLeft = UDim.new(0, 4)
   hp.PaddingBottom = UDim.new(0, 2)
   hp.Parent = h
   continue
  end
  local d = item.def
  local isSlider = d.kind == "slider"
  local row = Instance.new("Frame")
  row.Size = UDim2.new(1, -6, 0, isSlider and 68 or 40)
  row.LayoutOrder = i
  row.BackgroundColor3 = ROW
  row.BorderSizePixel = 0
  row.Parent = list
  Corner(row, 8)

  local name = Instance.new("TextLabel")
  local isWide = d.kind == "dropdown" or d.kind == "textbox" or d.kind == "color"
  name.Size = UDim2.new(1, isSlider and -130 or (isWide and -180 or -76), 0, 22)
  name.Position = UDim2.fromOffset(14, 9)
  name.BackgroundTransparency = 1
  name.Text = d.label
  name.TextXAlignment = Enum.TextXAlignment.Left
  name.Font = Enum.Font.Gotham
  name.TextSize = 13
  name.TextColor3 = TEXT
  name.Parent = row

  local isToggle = not (isSlider or isWide)
  local pill, renderPill
  if isToggle then
   pill, renderPill = CreateToggle(row, 9)
  end

  local r = {
   flag = d.flag, value = d.value, rec = d.rec, on = false,
   min = d.min, max = d.max, step = d.step,
   options = d.options, placeholder = d.placeholder, numeric = d.numeric, keybind = d.keybind,
   renderPill = renderPill,
  }
  local apply, onSlider, onChange = handlers(d, r)
  r.apply = apply or function() end
  r.onSlider = onSlider
  r.onChange = onChange
  rows[#rows + 1] = r

  if isSlider then
   CreateSlider(row, r, list)
  elseif d.kind == "dropdown" then
   CreateDropdown(row, r, list)
  elseif d.kind == "color" then
   CreateColorPicker(row, r, list)
  elseif d.kind == "textbox" then
   CreateTextbox(row, r)
  else
   pill.MouseButton1Click:Connect(function()
    SetRow(r, not r.on)
   end)
  end
 end
 return rows
end

local function AddBottom(page, rows, recText)
 local applyBtn = Button2(page, recText, 0, ACCENT)
 Accent(applyBtn, "BackgroundColor3")
 local resetBtn = Button2(page, "Reset all", 0.5, Color3.fromRGB(90, 94, 112))

 applyBtn.MouseButton1Click:Connect(function()
  for _, r in ipairs(rows) do
   if r.rec then SetRow(r, true) end
  end
 end)

 resetBtn.MouseButton1Click:Connect(function()
  for _, r in ipairs(rows) do
   if r.on then SetRow(r, false) end
  end
 end)
end

do
 local page, list = AddTab("Main", "house")
 local rows = BuildRows(list, MAIN, function(d)
  return d.apply, nil
 end)
 AddBottom(page, rows, "Enable recommended")
end

if hasSet then
 local page, list = AddTab("Fast Flags", "flag")
 local rows = BuildRows(list, FLAGS, function(d, r)
  local function apply(on)
   if on then
    SetFFlag(r.flag, r.value)
   else
    SetFFlag(r.flag, originals[r.flag] or DEFAULTS[r.flag])
   end
  end
  local function onSlider(v)
   SetFFlag(r.flag, v)
  end
  local function onChange(v)
   SetFFlag(r.flag, v)
  end
  return apply, onSlider, onChange
 end)
 AddBottom(page, rows, "Apply recommended")
end

local DIGIT_NAMES = { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }

local function FindKey(text)
 text = string.lower((string.gsub(text, "%s+", "")))
 if text == "" then return nil end
 if string.match(text, "^%d$") then
  text = string.lower(DIGIT_NAMES[tonumber(text) + 1])
 end
 for _, key in ipairs(Enum.KeyCode:GetEnumItems()) do
  if key ~= Enum.KeyCode.Unknown and string.lower(key.Name) == text then
   return key
  end
 end
 return nil
end

local SETTINGS_DEFS = {
 {
  kind = "dropdown",
  label = "Theme",
  category = "Interface",
  options = { "Dark", "Light" },
  value = "Dark",
  rec = false
 },
 {
  kind = "color",
  label = "Accent Color",
  category = "Interface",
  value = Color3.fromRGB(88, 140, 255),
  rec = false
 },
 {
  kind = "dropdown",
  label = "UI Scale",
  category = "Interface",
  options = { "50%", "75%", "100%", "150%", "175%" },
  value = "100%",
  rec = false
 },
 {
  kind = "textbox",
  label = "Toggle Key",
  category = "Interface",
  keybind = true,
  value = "RightControl",
  rec = false
 },
 {
  kind = "textbox",
  label = "Window Title",
  category = "Interface",
  placeholder = "Title...",
  value = "FPS",
  rec = false
 }
}

do
 local page, list = AddTab("Settings", "settings")
 BuildRows(list, SETTINGS_DEFS, function(d, r)
  local function onChange(v)
   if d.label == "Theme" then
    ApplyTheme(v)
   elseif d.label == "Accent Color" then
    SetAccent(v)
   elseif d.label == "UI Scale" then
    local pct = tonumber((string.gsub(v, "%%", "")))
    if pct then uiScale.Scale = pct / 100 end
   elseif d.label == "Toggle Key" then
    local key = FindKey(v)
    if key then
     TOGGLE_KEY = key
     r.setValue(key.Name)
    else
     r.setValue(TOGGLE_KEY.Name)
    end
   elseif d.label == "Window Title" then
    title.Text = v ~= "" and v or "FPS"
   end
  end
  local function apply(on)
  end
  return apply, nil, onChange
 end)
end

SelectTab("Main")

local orb = Instance.new("Frame")
orb.Size = UDim2.fromOffset(ORB, ORB)
Accent(orb, "BackgroundColor3")
orb.BorderSizePixel = 0
orb.Active = true
orb.Visible = false
orb.Parent = gui
Corner(orb, "full")
local orbStroke = Instance.new("UIStroke")
orbStroke.Color = Color3.fromRGB(190, 210, 255)
orbStroke.Transparency = 0.4
orbStroke.Thickness = 2
orbStroke.Parent = orb
local orbLabel = Instance.new("TextLabel")
orbLabel.Size = UDim2.fromScale(1, 1)
orbLabel.BackgroundTransparency = 1
orbLabel.Text = "FPS"
orbLabel.Font = Enum.Font.GothamBold
orbLabel.TextSize = 14
orbLabel.TextColor3 = Color3.new(1, 1, 1)
orbLabel.Parent = orb

local minimized = false
local uiVisible = true

local function Refresh()
 main.Visible = uiVisible and not minimized
 orb.Visible = uiVisible and minimized
end

local function Minimize()
 local p = PosOf(main)
 local s = ScreenSize()
 orb.Position = UDim2.fromOffset(
  math.clamp(p.X, 0, math.max(s.X - ORB, 0)),
  math.clamp(p.Y, 0, math.max(s.Y - ORB, 0))
 )
 minimized = true
 Refresh()
end

local function Restore()
 local o = PosOf(orb)
 local s = ScreenSize()
 main.Position = UDim2.fromOffset(
  math.clamp(o.X, 0, math.max(s.X - W, 0)),
  math.clamp(o.Y, 0, math.max(s.Y - H, 0))
 )
 minimized = false
 Refresh()
end

do
 local busy = false
 orb.InputBegan:Connect(function(input)
  if busy or not Pointer(input) then return end
  busy = true
  local startPos = input.Position
  local startAbs = PosOf(orb)
  local moved = false
  MakeDraggable(input, function(pos)
   local d = pos - startPos
   if not moved and d.Magnitude > 8 then moved = true end
   if moved then
    local s = ScreenSize()
    orb.Position = UDim2.fromOffset(
     math.clamp(startAbs.X + d.X, 0, math.max(s.X - ORB, 0)),
     math.clamp(startAbs.Y + d.Y, 0, math.max(s.Y - ORB, 0))
    )
   end
  end, function()
   busy = false
   if not moved then Restore() end
  end)
 end)
end

minBtn.MouseButton1Click:Connect(Minimize)
closeBtn.MouseButton1Click:Connect(function()
 gui:Destroy()
end)

local keyConn = UIS.InputBegan:Connect(function(input)
 if input.KeyCode == TOGGLE_KEY and not bindingKey and not UIS:GetFocusedTextBox() then
  uiVisible = not uiVisible
  Refresh()
 end
end)
gui.Destroying:Connect(function()
 keyConn:Disconnect()
end)

Refresh()
