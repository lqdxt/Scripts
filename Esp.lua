local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

export type PositionType = Vector3 | "Top" | "Bottom" | "Left" | "Right"
export type ParentType = Instance | ((target: Instance, instance: Instance) -> Instance?)
export type TargetType = Instance | { Instance } | (() -> (Instance | { Instance })?)
export type ConnectionResult = RBXScriptConnection | { RBXScriptConnection } | { any }

export type BillboardConfig = {
 Size: (UDim2 | (target: Instance, instance: Instance) -> UDim2)?,
 Position: (PositionType | (target: Instance, instance: Instance) -> PositionType)?,
 AlwaysOnTop: (boolean | (target: Instance, instance: Instance) -> boolean)?,
 Parent: ParentType?,
}

export type ESPConfig = {
 Target: TargetType?,
 Toggle: (boolean | () -> boolean)?,
 Adorn: ("Highlight" | "BoxHandleAdornment" | "Box")?,
 Tag: string?,
 AdornColor: (Color3 | (target: Instance, instance: Instance) -> Color3)?,
 LabelColor: (Color3 | (target: Instance, instance: Instance) -> Color3)?,
 Billboard: BillboardConfig?,
 Parent: ParentType?,
 Match: ((instance: Instance) -> boolean)?,
 Labels: { [string]: (target: Instance, instance: Instance) -> string }?,
 Loops: { (tracked: TrackedObject, dt: number) -> () }?,
 Connections: { (tracked: TrackedObject) -> ConnectionResult? }?,
}

export type TrackedObject = {
 Instance: Instance,
 Target: Instance,
 Adornment: Instance?,
 Billboard: BillboardGui?,
 Labels: { [string]: { Label: TextLabel, Func: (target: Instance, instance: Instance) -> string } },
 Cleanups: { any },
 Destroy: () -> (),
}

export type EspObject = {
 Name: string,
 Config: ESPConfig,
 Tracked: { [Instance]: TrackedObject },
 Connections: { RBXScriptConnection },
 ManualOverride: boolean?,
 IsEnabled: (self: EspObject) -> boolean,
 SetVisible: (self: EspObject, visible: boolean) -> (),
 SetEnabled: (self: EspObject, state: boolean) -> (),
 Toggle: (self: EspObject) -> boolean,
 AddInstance: (self: EspObject, inst: Instance) -> (),
 RemoveInstance: (self: EspObject, inst: Instance) -> (),
 Destroy: (self: EspObject) -> (),
}

local Esp = {}
Esp.Registered = {} :: { [string]: EspObject }
Esp.DefaultParent = nil :: ParentType?

local function GetTargetSize(target: Instance): Vector3
 if target:IsA("BasePart") then
  return target.Size
 elseif target:IsA("Model") then
  local _, size = target:GetBoundingBox()
  return size
 end
 return Vector3.new(2, 5, 2)
end

local function ResolveParent(val: any, target: Instance, instance: Instance, defaultParent: Instance): Instance
 if type(val) == "function" then
  local ok, res = pcall(val, target, instance)
  if ok and typeof(res) == "Instance" then
   return res
  end
 elseif typeof(val) == "Instance" then
  return val
 end

 if type(Esp.DefaultParent) == "function" then
  local ok, res = pcall(Esp.DefaultParent, target, instance)
  if ok and typeof(res) == "Instance" then
   return res
  end
 elseif typeof(Esp.DefaultParent) == "Instance" then
  return Esp.DefaultParent
 end

 return defaultParent
end

local function ResolveColor(val: any, target: Instance, instance: Instance, defaultColor: Color3): Color3
 if type(val) == "function" then
  local ok, res = pcall(val, target, instance)
  if ok and typeof(res) == "Color3" then
   return res
  end
 elseif typeof(val) == "Color3" then
  return val
 end
 return defaultColor
end

local function ResolveSize(val: any, target: Instance, instance: Instance, defaultSize: UDim2): UDim2
 if type(val) == "function" then
  local ok, res = pcall(val, target, instance)
  if ok and typeof(res) == "UDim2" then
   return res
  end
 elseif typeof(val) == "UDim2" then
  return val
 end
 return defaultSize
end

local function ResolvePosition(val: any, target: Instance, instance: Instance, defaultOffset: Vector3): Vector3
 if type(val) == "function" then
  local ok, res = pcall(val, target, instance)
  if ok then
   val = res
  end
 end

 if typeof(val) == "Vector3" then
  return val
 elseif type(val) == "string" then
  local size = GetTargetSize(target)
  local padding = 1.2

  if val == "Top" then
   return Vector3.new(0, (size.Y / 2) + padding, 0)
  elseif val == "Bottom" then
   return Vector3.new(0, -((size.Y / 2) + padding), 0)
  elseif val == "Left" then
   return Vector3.new(-((size.X / 2) + padding), 0, 0)
  elseif val == "Right" then
   return Vector3.new((size.X / 2) + padding, 0, 0)
  end
 end

 return defaultOffset
end

local function ResolveAlwaysOnTop(val: any, target: Instance, instance: Instance, defaultVal: boolean): boolean
 if type(val) == "function" then
  local ok, res = pcall(val, target, instance)
  if ok and type(res) == "boolean" then
   return res
  end
 elseif type(val) == "boolean" then
  return val
 end
 return defaultVal
end

local function CreateTrackedEsp(config: ESPConfig, instance: Instance): TrackedObject?
 if config.Match then
  local ok, matched = pcall(config.Match, instance)
  if not ok or not matched then
   return nil
  end
 end

 local target = instance
 if not target or not (target:IsA("PVInstance") or target:IsA("BasePart")) then
  return nil
 end

 local tracked: TrackedObject = {
  Instance = instance,
  Target = target,
  Cleanups = {},
  Labels = {},
  Destroy = function() end,
 }

 local initialAdornColor = ResolveColor(config.AdornColor, target, instance, Color3.fromRGB(255, 0, 0))

 if config.Adorn == "Highlight" then
  local highlight = Instance.new("Highlight")
  highlight.Name = "ESP_Highlight"
  highlight.Adornee = target
  highlight.FillColor = initialAdornColor
  highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
  highlight.FillTransparency = 0.5
  highlight.OutlineTransparency = 0
  highlight.Parent = ResolveParent(config.Parent, target, instance, target)
  
  if config.Tag then
   CollectionService:AddTag(highlight, config.Tag)
  end

  tracked.Adornment = highlight
  table.insert(tracked.Cleanups, highlight)

 elseif config.Adorn == "BoxHandleAdornment" or config.Adorn == "Box" then
  local adorneePart = target:IsA("BasePart") and target or (target:IsA("Model") and target.PrimaryPart)
  if adorneePart then
   local box = Instance.new("BoxHandleAdornment")
   box.Name = "ESP_Box"
   box.Adornee = adorneePart
   box.Size = adorneePart.Size
   box.Color3 = initialAdornColor
   box.Transparency = 0.4
   box.AlwaysOnTop = true
   box.ZIndex = 5
   box.Parent = ResolveParent(config.Parent, target, instance, adorneePart)

   if config.Tag then
    CollectionService:AddTag(box, config.Tag)
   end

   tracked.Adornment = box
   table.insert(tracked.Cleanups, box)
  end
 end

 if config.Labels and next(config.Labels) then
  local bbConfig = config.Billboard or {}
  local adorneePart = target:IsA("BasePart") and target or (target:IsA("Model") and target.PrimaryPart or target)

  local initialSize = ResolveSize(bbConfig.Size, target, instance, UDim2.new(0, 200, 0, 100))
  local initialOffset = ResolvePosition(bbConfig.Position, target, instance, Vector3.new(0, 3.5, 0))
  local initialAlwaysOnTop = ResolveAlwaysOnTop(bbConfig.AlwaysOnTop, target, instance, true)

  local billboard = Instance.new("BillboardGui")
  billboard.Name = "ESP_Billboard"
  billboard.Adornee = adorneePart
  billboard.Size = initialSize
  billboard.StudsOffset = initialOffset
  billboard.AlwaysOnTop = initialAlwaysOnTop

  local listLayout = Instance.new("UIListLayout")
  listLayout.SortOrder = Enum.SortOrder.LayoutOrder
  listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
  listLayout.Padding = UDim.new(0, 2)
  listLayout.Parent = billboard

  local initialLabelColor = ResolveColor(config.LabelColor, target, instance, Color3.fromRGB(255, 255, 255))

  for name, labelFunc in pairs(config.Labels) do
   local textLabel = Instance.new("TextLabel")
   textLabel.Name = name
   textLabel.BackgroundTransparency = 1
   textLabel.Size = UDim2.new(1, 0, 0, 14)
   textLabel.Font = Enum.Font.SourceSansBold
   textLabel.TextSize = 14
   textLabel.TextColor3 = initialLabelColor
   textLabel.TextStrokeTransparency = 0.2
   textLabel.Text = ""
   textLabel.Parent = billboard

   tracked.Labels[name] = {
    Label = textLabel,
    Func = labelFunc,
   }
  end

  local billboardParent = ResolveParent(bbConfig.Parent or config.Parent, target, instance, target)
  billboard.Parent = billboardParent

  if config.Tag then
   CollectionService:AddTag(billboard, config.Tag)
  end

  tracked.Billboard = billboard
  table.insert(tracked.Cleanups, billboard)
 end

 local function RegisterCleanup(item: any)
  if typeof(item) == "RBXScriptConnection" or typeof(item) == "Instance" then
   table.insert(tracked.Cleanups, item)
  elseif type(item) == "table" then
   for _, subItem in ipairs(item) do
    RegisterCleanup(subItem)
   end
  end
 end

 if config.Connections then
  for _, connEntry in ipairs(config.Connections) do
   if type(connEntry) == "function" then
    local ok, res = pcall(connEntry, tracked)
    if ok and res then
     RegisterCleanup(res)
    end
   else
    RegisterCleanup(connEntry)
   end
  end
 end

 local isCleaned = false
 local function Destroy()
  if isCleaned then return end
  isCleaned = true

  for _, item in ipairs(tracked.Cleanups) do
   if typeof(item) == "Instance" then
    item:Destroy()
   elseif typeof(item) == "RBXScriptConnection" then
    item:Disconnect()
   elseif type(item) == "table" and type(item.Disconnect) == "function" then
    item:Disconnect()
   end
  end
  table.clear(tracked.Cleanups)
 end

 tracked.Destroy = Destroy

 local ancestry_con = target.AncestryChanged:Connect(function(_, parent)
  if not parent then
   Destroy()
  end
 end)
 table.insert(tracked.Cleanups, ancestry_con)

 return tracked
end

function Esp.MakeEsp(espName: string)
 return function(config: ESPConfig): EspObject
  if Esp.Registered[espName] then
   Esp.Registered[espName]:Destroy()
  end

  local self: EspObject = {
   Name = espName,
   Config = config,
   Tracked = {},
   Connections = {},
   ManualOverride = nil,
   IsEnabled = function(s) return true end,
   SetVisible = function(s, v) end,
   SetEnabled = function(s, st) end,
   Toggle = function(s) return true end,
   AddInstance = function(s, i) end,
   RemoveInstance = function(s, i) end,
   Destroy = function(s) end,
  }

  function self:IsEnabled(): boolean
   if self.ManualOverride ~= nil then
    return self.ManualOverride
   end

   if type(config.Toggle) == "function" then
    local ok, res = pcall(config.Toggle)
    return ok and res == true
   elseif type(config.Toggle) == "boolean" then
    return config.Toggle
   end

   return true
  end

  function self:SetVisible(visible: boolean)
   for _, tracked in pairs(self.Tracked) do
    if tracked.Adornment then
     if tracked.Adornment:IsA("Highlight") then
      tracked.Adornment.Enabled = visible
     elseif tracked.Adornment:IsA("BoxHandleAdornment") then
      tracked.Adornment.Visible = visible
     end
    end
    if tracked.Billboard then
     tracked.Billboard.Enabled = visible
    end
   end
  end

  function self:SetEnabled(state: boolean)
   self.ManualOverride = state
   self:SetVisible(state)
  end

  function self:Toggle(): boolean
   local nextState = not self:IsEnabled()
   self:SetEnabled(nextState)
   return nextState
  end

  function self:AddInstance(inst: Instance)
   if self.Tracked[inst] then return end
   local tracked = CreateTrackedEsp(config, inst)
   if tracked then
    self.Tracked[inst] = tracked
   end
  end

  function self:RemoveInstance(inst: Instance)
   local tracked = self.Tracked[inst]
   if tracked then
    tracked.Destroy()
    self.Tracked[inst] = nil
   end
  end

  if config.Target then
   local resolvedTarget = if type(config.Target) == "function" then config.Target() else config.Target

   if typeof(resolvedTarget) == "Instance" then
    local targetFolder = resolvedTarget
    local function tryAdd(desc: Instance)
     if desc:IsA("Model") or desc:IsA("BasePart") then
      task.delay(0.1, function()
       if desc.Parent then
        self:AddInstance(desc)
       end
      end)
     end
    end

    for _, child in ipairs(targetFolder:GetChildren()) do
     tryAdd(child)
    end

    local added_con = targetFolder.DescendantAdded:Connect(tryAdd)
    local removed_con = targetFolder.DescendantRemoving:Connect(function(desc)
     self:RemoveInstance(desc)
    end)

    table.insert(self.Connections, added_con)
    table.insert(self.Connections, removed_con)
   elseif type(resolvedTarget) == "table" then
    for _, inst in ipairs(resolvedTarget) do
     if typeof(inst) == "Instance" then
      self:AddInstance(inst)
     end
    end
   end
  end

  local lastActiveState = false
  local render_con = RunService.RenderStepped:Connect(function(dt: number)
   local active = self:IsEnabled()

   if active ~= lastActiveState then
    self:SetVisible(active)
    lastActiveState = active
   end

   if not active then return end

   for inst, tracked in pairs(self.Tracked) do
    if not tracked.Target or not tracked.Target.Parent then
     self:RemoveInstance(inst)
     continue
    end

    if tracked.Adornment and config.AdornColor then
     local color = ResolveColor(config.AdornColor, tracked.Target, inst, Color3.new(1, 1, 1))
     if tracked.Adornment:IsA("Highlight") then
      tracked.Adornment.FillColor = color
     elseif tracked.Adornment:IsA("BoxHandleAdornment") then
      tracked.Adornment.Color3 = color
     end
    end

    if tracked.Billboard and config.Billboard then
     local bb = config.Billboard
     if bb.Size then
      tracked.Billboard.Size = ResolveSize(bb.Size, tracked.Target, inst, UDim2.new(0, 200, 0, 100))
     end
     if bb.Position then
      tracked.Billboard.StudsOffset = ResolvePosition(bb.Position, tracked.Target, inst, Vector3.new(0, 3.5, 0))
     end
     if bb.AlwaysOnTop ~= nil then
      tracked.Billboard.AlwaysOnTop = ResolveAlwaysOnTop(bb.AlwaysOnTop, tracked.Target, inst, true)
     end
    end

    local labelColor = config.LabelColor and ResolveColor(config.LabelColor, tracked.Target, inst, Color3.new(1, 1, 1))
    for name, item in pairs(tracked.Labels) do
     if labelColor then
      item.Label.TextColor3 = labelColor
     end
     local ok, textStr = pcall(item.Func, tracked.Target, inst)
     item.Label.Text = ok and tostring(textStr) or ""
    end

    if config.Loops then
     for _, loopFunc in ipairs(config.Loops) do
      pcall(loopFunc, tracked, dt)
     end
    end
   end
  end)
  table.insert(self.Connections, render_con)

  function self:Destroy()
   for _, conn in ipairs(self.Connections) do
    conn:Disconnect()
   end
   for _, tracked in pairs(self.Tracked) do
    tracked.Destroy()
   end
   table.clear(self.Tracked)
   Esp.Registered[espName] = nil
  end

  Esp.Registered[espName] = self
  return self
 end
end

function Esp.Toggle(espName: string): boolean?
 local esp = Esp.Registered[espName]
 return if esp then esp:Toggle() else nil
end

function Esp.SetEnabled(espName: string, state: boolean)
 local esp = Esp.Registered[espName]
 if esp then
  esp:SetEnabled(state)
 end
end

function Esp.ToggleAll(state: boolean)
 for _, esp in pairs(Esp.Registered) do
  esp:SetEnabled(state)
 end
end

return Esp
