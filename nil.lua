local Nil = {}
Nil.ClassName = "Nil"
Nil.Name = "nil"
Nil.PollInterval = 0.5

local GC_CACHE_TTL = 0.25

local Registry: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local gcCache: { Instance }? = nil
local gcCacheTime = 0

function Nil.Track<T>(inst: T): T
 if typeof(inst) == "Instance" then
  Registry[inst :: any] = true
  gcCache = nil
 end
 return inst
end

function Nil.new(className: string, parent: Instance?): Instance
 local inst = Instance.new(className)
 if parent then
  inst.Parent = parent
 end
 Nil.Track(inst)
 return inst
end

local function FromGetNilInstances(): { Instance }?
 if type(getnilinstances) ~= "function" then
  return nil
 end
 local ok, result = pcall(getnilinstances)
 if ok and type(result) == "table" then
  return result
 end
 return nil
end

local function FromGC(): { Instance }?
 if type(getgc) ~= "function" then
  return nil
 end
 local ok, gc = pcall(getgc, true)
 if not ok or type(gc) ~= "table" then
  return nil
 end
 local out = {}
 for _, obj in pairs(gc) do
  if typeof(obj) == "Instance" then
   local sc, parent = pcall(function()
    return obj.Parent
   end)
   if sc and parent == nil then
    table.insert(out, obj)
   end
  end
 end
 return out
end

local function FromRegistry(): { Instance }
 local out = {}
 for inst in pairs(Registry) do
  local sc, parent = pcall(function()
   return inst.Parent
  end)
  if sc and parent == nil then
   table.insert(out, inst)
  end
 end
 return out
end

local function GetNilInstances(force: boolean?): { Instance }
 local direct = FromGetNilInstances()
 if direct then
  return direct
 end

 local now = os.clock()
 if not force and gcCache and now - gcCacheTime < GC_CACHE_TTL then
  return gcCache
 end

 local scanned = FromGC()
 if scanned then
  gcCache, gcCacheTime = scanned, now
  return scanned
 end

 return FromRegistry()
end

local function create_signal()
 local BindableEvent = Instance.new("BindableEvent")
 return {
  Event = BindableEvent.Event,
  Fire = function(_self, ...)
   BindableEvent:Fire(...)
  end,
  Destroy = function(_self)
   BindableEvent:Destroy()
  end,
 }
end

local ChildAddedSignal = create_signal()
local ChildRemovedSignal = create_signal()

local knownNilSet: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any
local seeded = false
local watcherToken: {}? = nil

local function poll()
 local current = GetNilInstances(true)
 local currentSet: { [Instance]: boolean } = setmetatable({}, { __mode = "k" }) :: any

 for _, inst in ipairs(current) do
  if typeof(inst) == "Instance" then
   currentSet[inst] = true
   if seeded and not knownNilSet[inst] then
    ChildAddedSignal:Fire(inst)
   end
  end
 end

 if seeded then
  for inst in pairs(knownNilSet) do
   if not currentSet[inst] then
    ChildRemovedSignal:Fire(inst)
   end
  end
 end

 knownNilSet = currentSet
 seeded = true
end

local function StartWatcher()
 if watcherToken then
  return
 end
 local token = {}
 watcherToken = token

 task.spawn(function()
  pcall(poll)
  while watcherToken == token do
   task.wait(Nil.PollInterval)
   if watcherToken ~= token then
    break
   end
   pcall(poll)
  end
 end)
end

function Nil:Stop()
 watcherToken = nil
 seeded = false
 knownNilSet = setmetatable({}, { __mode = "k" }) :: any
end

function Nil:GetChildren(): { Instance }
 return table.clone(GetNilInstances())
end

function Nil:GetDescendants(): { Instance }
 local descendants = {}
 for _, root in ipairs(GetNilInstances()) do
  table.insert(descendants, root)
  pcall(function()
   for _, child in ipairs(root:GetDescendants()) do
    table.insert(descendants, child)
   end
  end)
 end
 return descendants
end

function Nil:FindFirstChild(name: string, recursive: boolean?): Instance?
 if type(name) ~= "string" then
  return nil
 end
 local pool = recursive and Nil:GetDescendants() or GetNilInstances()
 for _, inst in ipairs(pool) do
  local success, instName = pcall(function()
   return inst.Name
  end)
  if success and instName == name then
   return inst
  end
 end
 return nil
end

function Nil:FindFirstChildOfClass(class: string, recursive: boolean?): Instance?
 if type(class) ~= "string" then
  return nil
 end
 local pool = recursive and Nil:GetDescendants() or GetNilInstances()
 for _, inst in ipairs(pool) do
  local success, className = pcall(function()
   return inst.ClassName
  end)
  if success and className == class then
   return inst
  end
 end
 return nil
end

function Nil:FindFirstChildWhichIsA(class: string, recursive: boolean?): Instance?
 if type(class) ~= "string" then
  return nil
 end
 local pool = recursive and Nil:GetDescendants() or GetNilInstances()
 for _, inst in ipairs(pool) do
  local success, isA = pcall(inst.IsA, inst, class)
  if success and isA then
   return inst
  end
 end
 return nil
end

function Nil:WaitForChild(name: string, timeout: number?): Instance?
 if type(name) ~= "string" then
  return nil
 end

 local found = Nil:FindFirstChild(name, false)
 if found then
  return found
 end

 StartWatcher()

 local thread = coroutine.running()
 local done = false
 local connection: RBXScriptConnection? = nil

 local function finish(result: Instance?)
  if done then
   return
  end
  done = true
  if connection then
   connection:Disconnect()
  end
  task.spawn(thread, result)
 end

 connection = ChildAddedSignal.Event:Connect(function(inst)
  local ok, instName = pcall(function()
   return inst.Name
  end)
  if ok and instName == name then
   finish(inst)
  end
 end)

 task.delay(5, function()
  if not done and (timeout == nil or timeout > 5) then
   warn(string.format("Infinite yield possible on 'Nil:WaitForChild(\"%s\")'", name))
  end
 end)

 if type(timeout) == "number" then
  task.delay(timeout, finish, nil)
 end

 return coroutine.yield()
end

function Nil:ClearAllChildren()
 for _, inst in ipairs(Nil:GetChildren()) do
  pcall(function()
   inst:Destroy()
  end)
 end
 gcCache = nil
end

return setmetatable({}, {
 __index = function(_, key)
  if key == "ChildAdded" then
   StartWatcher()
   return ChildAddedSignal.Event
  elseif key == "ChildRemoved" then
   StartWatcher()
   return ChildRemovedSignal.Event
  end

  local member = Nil[key]
  if member ~= nil then
   return member
  end

  return Nil:FindFirstChild(tostring(key))
 end,

 __newindex = function(_, key, value)
  Nil[key] = value
 end,

 __call = function(_, name, recursive)
  return Nil:FindFirstChild(name, recursive)
 end,

 __tostring = function()
  return "Nil"
 end,
})
