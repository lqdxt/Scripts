local SRC = {}

local GetService = function(name)
 if SRC[name] then return SRC[name] end
 local ok, svc = pcall(game.GetService, game, name)
 if ok then
  SRC[name] = svc
  return svc
 end
 return nil
end

local cclosure = syn_newcclosure or newcclosure or function(f) return f end
local cloneref = cloneref or function(i) return i end
local protect = setstackhidden or sethiddenstack

if not hookmetamethod then
 warn("hookmetamethod required")
 return
end

local anticheatbypass = function(target)
 task.spawn(function() -- adonis first
  local x, y
  for _, v in getgc(true) do
   if type(v) == "table" then
    local a = rawget(v, "Detected")
    local b = rawget(v, "Kill") or rawget(v, "Kick")
    if typeof(a) == "function" and not x then
     x = a
     hookfunction(x, function() return true end)
    end
    if rawget(v, "Variables") and rawget(v, "Process")
     and typeof(b) == "function" and not y then
     y = b
     hookfunction(y, function() return end)
    end
   end
  end
  local rd = getrenv().debug
  if rd and rd.info then
   local o; o = hookfunction(rd.info, cclosure(function(...)
    local a = ...
    if x and a == x then
     return coroutine.yield(coroutine.running())
    end
    return o(...)
   end))
  end
 end)

 task.spawn(function()
  repeat task.wait() until game:IsLoaded()
  local floor, cos, sin, acos, pi = math.floor, math.cos, math.sin, math.acos, math.pi
  local mxm, stable = 0, 0
  while task.wait() do
   local c = gcinfo()
   if c >= mxm then mxm = c; stable = 0
   else stable += 1; if stable >= 10 then break end end
  end
  task.wait(0.5)

  local base, tk = gcinfo() + 250, 0
  local function getreturn()
   return floor(base + ((acos(cos(pi * tk)) / pi * 500) - 250) + sin(tk * 0.5) * 15)
  end

  local o1; o1 = hookfunction(getrenv().gcinfo, function(...)
   if not checkcaller() then return getreturn() end
   return o1(...)
  end)
  local o2; o2 = hookfunction(getrenv().collectgarbage, function(arg, ...)
   if not checkcaller() and arg == "count" then return getreturn() end
   local s, r = pcall(o2, arg, ...)
   return s and r or 0
  end)
  cloneref(GetService("RunService")).Stepped:Connect(function()
   local a = (acos(cos(pi * tk)) / pi * 500) - 250
   local b = (acos(cos(pi * (tk + 0.01))) / pi * 500) - 250
   tk += a > b and 0.09 or 0.015
  end)
 end)

 task.spawn(function()
  repeat task.wait() until game:IsLoaded()
  local rs = cloneref(GetService("RunService"))
  local sts = cloneref(GetService("Stats"))
  local total, tagBase = sts:GetTotalMemoryUsageMb(), sts:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Gui)
  local rnd1, rnd2 = 0, 0
  local rng = Random.new()
  rs.Stepped:Connect(function()
   rnd1 = rng:NextNumber(-12, 12)
   rnd2 = rng:NextNumber(-0.15, 0.15)
  end)

  local mbp; mbp = hookmetamethod(game, "__namecall", function(self, ...)
   local m = getnamecallmethod()
   if not checkcaller() and typeof(self) == "Instance" and self.ClassName == "Stats" then
    if m == "GetTotalMemoryUsageMb" or m == "getTotalMemoryUsageMb" then
     return total + rnd1
    elseif m == "GetMemoryUsageMbForTag" or m == "getMemoryUsageMbForTag" then
     return tagBase + rnd2
    end
   end
   return mbp(self, ...)
  end)

  local a; a = hookfunction(sts.GetTotalMemoryUsageMb, function(self, ...)
   if not checkcaller() then return total + rnd1 end
   return a(self, ...)
  end)
  local b; b = hookfunction(sts.GetMemoryUsageMbForTag, function(self, ...)
   if not checkcaller() then return tagBase + rnd2 end
   return b(self, ...)
  end)
 end)

 do
  local cnt = cloneref(GetService("ContentProvider"))
  local cg = cloneref(GetService("CoreGui"))
  local cgt = {}
  task.spawn(function()
   cnt:PreloadAsync({cg}, function(id)
    if not id:find("rbxassetid://") then table.insert(cgt, id) end
   end)
  end)

  local cloned = cloneref(game)
  local gt = {}
  for _, v in cloned:GetDescendants() do
   if v:IsA("ImageLabel") and not (v.Image:find("rbxassetid://") and v:IsDescendantOf(cg)) then
    table.insert(gt, v.Image)
   end
  end

  local rng = Random.new()
  local function shuffle(t)
   for i = #t, 2, -1 do
    local j = rng:NextInteger(1, i)
    t[i], t[j] = t[j], t[i]
   end
   return t
  end

  local cpb; cpb = hookmetamethod(game, "__namecall", function(self, n, ...)
   local m = getnamecallmethod()
   if not checkcaller() and (m == "preloadAsync" or m == "PreloadAsync")
    and self.ClassName == "ContentProvider" and n then
    if table.find(n, cg) then return cpb(self, shuffle(cgt), ...) end
    if table.find(n, cloned) then return cpb(self, shuffle(gt), ...) end
   end
   return cpb(self, n, ...)
  end)

  local plb; plb = hookfunction(cnt.PreloadAsync, function(a, b, c)
   if not checkcaller() and typeof(a) == "Instance"
    and typeof(b) == "table" then
    if table.find(b, cg) then return plb(a, shuffle(cgt), c) end
    if table.find(b, cloned) then return plb(a, shuffle(gt), c) end
   end
   return plb(a, b, c)
  end)
 end

 do
  local idf = cloneref(game).IsDescendantOf
  local tbb; tbb = hookmetamethod(game, "__namecall", function(self, ...)
   local m = getnamecallmethod()
   if not checkcaller() and typeof(self) == "Instance"
    and m == "GetFocusedTextBox" and self.ClassName == "UserInputService" then
    local tb = tbb(self, ...)
    if tb and typeof(tb) == "Instance" then
     local _, e = pcall(idf, tb, target or nil)
     if e and e:match("The current identity") then return nil end
    end
   end
   return tbb(self, ...)
  end)
 end

 do
  local refs, times, count = setmetatable({}, {__mode = "v"}), {}, 0
  local sod; sod = hookfunction(getrenv().newproxy, function(...)
   local px = sod(...)
   count += 1
   refs[count], times[count] = px, tick()
   return px
  end)
  cloneref(GetService("RunService")).Stepped:Connect(function()
   local now = tick()
   for i = count, 1, -1 do
    if refs[i] == nil or (now - (times[i] or 0)) > 60 then
     refs[i], times[i] = nil, nil
    end
   end
   while count > 0 and refs[count] == nil do count -= 1 end
  end)
 end
end

if protect then protect(anticheatbypass, true) end

return anticheatbypass
