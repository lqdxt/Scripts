--[[
 LocalDataStoreService
 local storage using the executor's file functions.

 Requires: writefile, readfile, isfile, makefolder, isfolder
 Optional: delfile, listfiles (needed for Destroy / ListDataStoresAsync)

 Usage:
  local DataStoreService = LocalDataStoreService

  local store = DataStoreService:GetDataStore("MyScript") - scope "global"
  local store2 = DataStoreService:GetDataStore("MyScript", "Settings")

  store:SetAsync("Volume", 0.8)
  local value, keyInfo = store:GetAsync("Volume")
  store:UpdateAsync("Coins", function(old, info) return (old or 0) + 5 end)
  store:IncrementAsync("Kills", 1)
  local old, info = store:RemoveAsync("Volume")

  local pages = store:ListKeysAsync("Player_", 50)
  while true do
   for _, key in ipairs(pages:GetCurrentPage()) do print(key.KeyName) end
   if pages.IsFinished then break end
   pages:AdvanceToNextPageAsync()
  end

  local board = DataStoreService:GetOrderedDataStore("Leaderboard")
  board:SetAsync("Alice", 120)
  local top = board:GetSortedAsync(false, 10) - items are { key =, value = }

 Options (GetDataStore's third argument, a plain table): Folder,
  Autosave (default true), AutosaveDelay (default 1).
 LocalDataStoreService.RootFolder changes the default folder.

 Notes:
  - Values must be JSON safe: valid UTF 8 strings, finite numbers, booleans,
    and tables that are pure arrays or string-keyed dictionaries
    (no cycles, nesting <= 100, no Instances/Vector3/functions).
    SetAsync errors immediately otherwise.
  - Get/Set copy tables, so editing a returned table does nothing until
    you SetAsync it back.
  - Saves go to "<name>.json.tmp" first, are read back and verified, then
    written to "<name>.json". Load falls back to the .tmp copy if the main
    file is missing/corrupt (e.g. crash mid write).
  - Files written by the older flat format still load; they are upgraded on
    the next save.
]]

local HttpService = game:GetService("HttpService")

local LocalDataStoreService = {}
LocalDataStoreService.RootFolder = "LocalDataStore"

local Store = {}
Store.__index = Store

local DataStore = {}
DataStore.__index = DataStore

local OrderedDataStore = setmetatable({}, { __index = DataStore })
OrderedDataStore.__index = OrderedDataStore

local KeyInfo = {}
KeyInfo.__index = KeyInfo

local Pages = {}
Pages.__index = Pages

local EXT = ".json"
local TMP_EXT = ".tmp"
local ORDERED_FOLDER = "Ordered"
local DEFAULT_SCOPE = "global"
local DEFAULT_PAGE_SIZE = 50
local FORMAT = 2
local MAX_DEPTH = 100
local MAX_RETRIES = 5
local MAX_NAME_LENGTH = 80

local RESERVED = { con = true, prn = true, aux = true, nul = true }
for i = 1, 9 do
 RESERVED["com" .. i] = true
 RESERVED["lpt" .. i] = true
end

local open = {}

local function Spawn(fn, ...)
 if type(task) == "table" and task.spawn then
  return task.spawn(fn, ...)
 end
 return coroutine.wrap(fn)(...)
end

local function Delay(seconds, fn)
 if type(task) == "table" and task.delay then
  return task.delay(seconds, fn)
 end
 return delay(seconds, fn)
end

local function Now()
 local ok, ms = pcall(function()
  return DateTime.now().UnixTimestampMillis
 end)
 if ok and type(ms) == "number" then
  return ms
 end
 return os.time() * 1000
end

local function ShallowClone(list)
 local copy = {}
 for i, v in ipairs(list) do
  copy[i] = v
 end
 return copy
end

local function IndexOf(list, value)
 for i, v in ipairs(list) do
  if v == value then
   return i
  end
 end
 return nil
end

local function HasFS()
 return type(writefile) == "function"
  and type(readfile) == "function"
  and type(isfile) == "function"
  and type(makefolder) == "function"
  and type(isfolder) == "function"
end

local function SafeIsFile(path)
 local ok, result = pcall(isfile, path)
 return ok and result == true
end

local function SafeIsFolder(path)
 local ok, result = pcall(isfolder, path)
 return ok and result == true
end

local function SafeRead(path)
 if not SafeIsFile(path) then
  return nil
 end
 local ok, raw = pcall(readfile, path)
 if ok and type(raw) == "string" then
  return raw
 end
 return nil
end

local function EnsureFolder(path)
 local built
 for segment in tostring(path):gmatch("[^/\\]+") do
  built = built and (built .. "/" .. segment) or segment
  if not SafeIsFolder(built) then
   pcall(makefolder, built)
  end
 end
 return SafeIsFolder(path)
end

local function Hash(text)
 local h = 5381
 for i = 1, #text do
  h = (h * 33 + text:byte(i)) % 4294967296
 end
 return string.format("%08x", h)
end

local function SafeFileName(name)
 local clean = name:gsub("[^%w%-%_%. ]", "_")
 clean = clean:gsub("^[%.%s]+", "_")
 clean = clean:gsub("[%.%s]+$", "_")

 local base = clean:lower():match("^([^%.]+)")
 if base and RESERVED[base] then
  clean = "_" .. clean
 end
 if #clean > MAX_NAME_LENGTH then
  clean = clean:sub(1, MAX_NAME_LENGTH)
 end

 if clean ~= name then
  clean = clean .. "_" .. Hash(name)
 end
 return clean
end

local function NormalizeFolder(folder)
 folder = tostring(folder):gsub("\\", "/")
 local parts = {}
 for segment in folder:gmatch("[^/]+") do
  assert(segment ~= ".." and segment ~= ".", "Folder may not contain '.' or '..' segments.")
  table.insert(parts, segment)
 end
 assert(#parts > 0, "Folder can't be empty.")
 return table.concat(parts, "/")
end

local function DeepCopy(value)
 if type(value) ~= "table" then
  return value
 end
 local copy = {}
 for k, v in pairs(value) do
  copy[k] = DeepCopy(v)
 end
 return copy
end

local function IsArray(t)
 local count = 0
 for k in pairs(t) do
  if type(k) ~= "number" then
   return false
  end
  count += 1
 end
 for i = 1, count do
  if t[i] == nil then
   return false
  end
 end
 return count > 0
end

local function IsInteger(value)
 return type(value) == "number"
  and value == math.floor(value)
  and value ~= math.huge
  and value ~= -math.huge
end

local function Validate(value, path, seen, depth)
 local t = type(value)

 if t == "boolean" then
  return true
 end

 if t == "string" then
  if utf8 and utf8.len(value) == nil then
   return false, path .. " is not valid UTF-8"
  end
  return true
 end

 if t == "number" then
  if value ~= value or value == math.huge or value == -math.huge then
   return false, path .. " is NaN or infinite"
  end
  return true
 end

 if t == "table" then
  if depth > MAX_DEPTH then
   return false, path .. " is nested more than " .. MAX_DEPTH .. " levels deep"
  end
  if seen[value] then
   return false, path .. " is a cyclic reference"
  end
  seen[value] = true

  local count, allStrings = 0, true
  for k in pairs(value) do
   count += 1
   if type(k) ~= "string" then
    allStrings = false
   elseif utf8 and utf8.len(k) == nil then
    return false, path .. " has a key that is not valid UTF-8"
   end
  end

  if count > 0 and not allStrings and not IsArray(value) then
   return false, path .. " must be a pure array or a string-keyed dictionary"
  end

  for k, v in pairs(value) do
   local ok, reason = Validate(v, path .. "." .. tostring(k), seen, depth + 1)
   if not ok then
    return false, reason
   end
  end

  seen[value] = nil
  return true
 end

 return false, path .. " is a " .. t .. " (not JSON-serializable)"
end

local function CheckValue(value, label)
 local ok, reason = Validate(value, label, {}, 1)
 if not ok then
  error(reason, 3)
 end
end

local function NormalizeKey(key)
 local t = type(key)
 if t == "string" then
  return key
 elseif t == "number" then
  assert(key == key, "Key can't be NaN.")
  return tostring(key)
 end
 error("Key must be a string or number, got " .. t, 3)
end

local function ApplyDefaults(data, defaults, deep)
 for key, default in pairs(defaults) do
  local current = data[key]
  if current == nil then
   data[key] = DeepCopy(default)
  elseif deep and type(current) == "table" and type(default) == "table"
   and not IsArray(current) and not IsArray(default) then
   ApplyDefaults(current, default, true)
  end
 end
end

local function Stringify(data)
 local out = {}
 for k, v in pairs(data) do
  out[tostring(k)] = v
 end
 return out
end

local function TryDecode(raw)
 if type(raw) ~= "string" or #raw == 0 then
  return nil
 end
 raw = raw:gsub("^\239\187\191", "")
 local ok, result = pcall(HttpService.JSONDecode, HttpService, raw)
 if ok and type(result) == "table" then
  return Stringify(result)
 end
 return nil
end

local function Decode(raw)
 local t = TryDecode(raw)
 if not t then
  return nil
 end
 if t._format == FORMAT and type(t.data) == "table" and type(t.info) == "table" then
  return Stringify(t.data), Stringify(t.info), tonumber(t.seq) or 0
 end
 return t, {}, 0
end

local function ValidRecord(rec)
 return type(rec) == "table"
  and type(rec.Version) == "string"
  and type(rec.CreatedTime) == "number"
  and type(rec.UpdatedTime) == "number"
end

local function ReadMetadata(options)
 if options == nil then
  return nil
 end
 local ok, meta = pcall(function()
  return options:GetMetadata()
 end)
 if ok then
  return meta
 end
 if type(options) == "table" then
  return options.Metadata
 end
 return nil
end

local function AssertInteger(value)
 assert(IsInteger(value), "OrderedDataStore values must be integers.")
end

function KeyInfo:GetUserIds()
 return DeepCopy(self._userIds)
end

function KeyInfo:GetMetadata()
 return DeepCopy(self._metadata)
end

local function MakeKeyInfo(rec)
 return setmetatable({
  Version = rec.Version,
  CreatedTime = rec.CreatedTime,
  UpdatedTime = rec.UpdatedTime,
  _userIds = DeepCopy(rec.UserIds or {}),
  _metadata = DeepCopy(rec.Metadata or {}),
 }, KeyInfo)
end

function Pages:_Load()
 local page = {}
 local last = math.min(self._start + self._size - 1, #self._items)
 for i = self._start, last do
  page[#page + 1] = self._items[i]
 end
 self._page = page
 self.IsFinished = last >= #self._items
 self.Cursor = (not self.IsFinished) and tostring(last + 1) or nil
end

function Pages:GetCurrentPage()
 return self._page
end

function Pages:AdvanceToNextPageAsync()
 assert(not self.IsFinished, "There are no more pages.")
 self._start += self._size
 self:_Load()
end

local function NewPages(items, pageSize, cursor)
 pageSize = math.floor(tonumber(pageSize) or 0)
 if pageSize < 1 then
  pageSize = DEFAULT_PAGE_SIZE
 end
 local self = setmetatable({
  _items = items,
  _size = pageSize,
  _start = math.max(1, math.floor(tonumber(cursor) or 1)),
 }, Pages)
 self:_Load()
 return self
end

local function OpenStore(name, defaults, options, subfolder)
 assert(type(name) == "string" and #name > 0, "Key name can't be empty.")
 LocalDataStoreService.Supported = HasFS()
 assert(LocalDataStoreService.Supported, "Executor lacks required file functions.")

 options = options or {}
 defaults = defaults or {}
 assert(type(defaults) == "table", "Defaults must be a table.")
 CheckValue(defaults, "Defaults")

 local folder = NormalizeFolder(options.Folder or LocalDataStoreService.RootFolder)
 if subfolder then
  folder = folder .. "/" .. subfolder
 end
 local safeName = SafeFileName(name)
 local path = folder .. "/" .. safeName .. EXT

 if open[path] then
  return open[path]
 end

 local delaySeconds = tonumber(options.AutosaveDelay) or 1
 if delaySeconds ~= delaySeconds or delaySeconds < 0 then
  delaySeconds = 1
 end

 local self = setmetatable({}, Store)
 self.Name = safeName
 self.Folder = folder
 self.Path = path
 self.TmpPath = path .. TMP_EXT
 self.Autosave = options.Autosave ~= false
 self.AutosaveDelay = delaySeconds
 self.DeepDefaults = options.DeepDefaults == true
 self.Defaults = DeepCopy(defaults)
 self.Data = {}
 self.Info = {}
 self._seq = 0
 self._dirty = false
 self._pending = false
 self._destroyed = false
 self._retries = 0
 self._listeners = {}

 if not EnsureFolder(self.Folder) then
  warn(("Couldn't create folder '%s'; saving may fail."):format(self.Folder))
 end
 self:Load()

 open[path] = self
 return self
end

function Store:Load()
 local data, info, seq
 local mainRaw = SafeRead(self.Path)

 if mainRaw and #mainRaw > 0 then
  data, info, seq = Decode(mainRaw)
  if not data then
   warn(("'%s' is corrupted, trying last save."):format(self.Name))
   pcall(writefile, ("%s.%d.bad"):format(self.Path, os.time()), mainRaw)
  end
 end

 if not data then
  local tmpRaw = SafeRead(self.TmpPath)
  data, info, seq = Decode(tmpRaw)
  if data and mainRaw ~= nil then
   warn(("'%s' recovered from last save."):format(self.Name))
  end
 end

 data = data or {}
 info = info or {}
 ApplyDefaults(data, self.Defaults, self.DeepDefaults)

 self.Data = data
 self.Info = {}
 self._seq = seq or 0
 for key in pairs(data) do
  local rec = info[key]
  if ValidRecord(rec) then
   self.Info[key] = rec
  else
   self:_Stamp(key)
  end
 end
 self._dirty = false
 return data
end

function Store:Save()
 if self._destroyed then
  return false
 end

 local ok, encoded = pcall(HttpService.JSONEncode, HttpService, {
  _format = FORMAT,
  seq = self._seq,
  data = self.Data,
  info = self.Info,
 })
 if not ok then
  warn(("Failed to encode '%s': %s"):format(self.Name, tostring(encoded)))
  return false
 end

 if not SafeIsFolder(self.Folder) then
  EnsureFolder(self.Folder)
 end

 local wroteTmp, tmpErr = pcall(writefile, self.TmpPath, encoded)
 if not wroteTmp then
  warn(("Failed to write '%s': %s"):format(self.Name, tostring(tmpErr)))
  return false
 end
 if SafeRead(self.TmpPath) ~= encoded then
  warn(("Verification of '%s' failed (disk full or file locked?)."):format(self.Name))
  return false
 end

 local wrote, err = pcall(writefile, self.Path, encoded)
 if not wrote then
  warn(("Failed to write '%s': %s"):format(self.Name, tostring(err)))
  return false
 end

 self._dirty = false
 return true
end

function Store:Flush()
 if self._dirty and not self._destroyed then
  return self:Save()
 end
 return true
end

function Store:ScheduleSave(seconds)
 if self._pending then
  return
 end
 self._pending = true
 Delay(seconds, function()
  self._pending = false
  if self._destroyed or not self._dirty then
   self._retries = 0
   return
  end
  if self:Save() then
   self._retries = 0
  else
   self._retries += 1
   if self._retries <= MAX_RETRIES then
    self:ScheduleSave(math.max(self.AutosaveDelay, 1) * 2 ^ self._retries)
   else
    warn(("Giving up autosaving '%s' after %d attempts; call :Save() to retry.")
     :format(self.Name, MAX_RETRIES))
    self._retries = 0
   end
  end
 end)
end

function Store:QueueSave()
 self._dirty = true
 if self.Autosave then
  self:ScheduleSave(self.AutosaveDelay)
 end
end

function Store:Fire(key, new, old)
 local specific = ShallowClone(self._listeners[key] or {})
 local wildcard = ShallowClone(self._listeners["*"] or {})
 for _, callback in ipairs(specific) do
  Spawn(callback, DeepCopy(new), DeepCopy(old))
 end
 for _, callback in ipairs(wildcard) do
  Spawn(callback, key, DeepCopy(new), DeepCopy(old))
 end
end

function Store:OnChanged(key, callback)
 assert(type(callback) == "function", "OnChanged needs a function.")
 if key ~= "*" then
  key = NormalizeKey(key)
 end
 self._listeners[key] = self._listeners[key] or {}
 table.insert(self._listeners[key], callback)

 return function()
  local list = self._listeners[key]
  if list then
   local index = IndexOf(list, callback)
   if index then
    table.remove(list, index)
   end
  end
 end
end

function Store:_Stamp(key, userIds, metadata)
 self._seq += 1
 local prev = self.Info[key]
 local now = Now()
 self.Info[key] = {
  Version = tostring(self._seq),
  CreatedTime = prev and prev.CreatedTime or now,
  UpdatedTime = now,
  UserIds = userIds ~= nil and DeepCopy(userIds) or nil,
  Metadata = metadata ~= nil and DeepCopy(metadata) or nil,
 }
end

function Store:GetInfo(key)
 local rec = self.Info[NormalizeKey(key)]
 if not rec then
  return nil
 end
 return MakeKeyInfo(rec)
end

function Store:Get(key, fallback)
 local value = self.Data[NormalizeKey(key)]
 if value == nil then
  return fallback
 end
 return DeepCopy(value)
end

function Store:_Put(key, value, userIds, metadata)
 assert(not self._destroyed, "Store was closed or destroyed.")
 key = NormalizeKey(key)
 CheckValue(value, key)
 if userIds ~= nil then
  assert(type(userIds) == "table", "UserIds must be an array.")
  CheckValue(userIds, "UserIds")
 end
 if metadata ~= nil then
  assert(type(metadata) == "table", "Metadata must be a table.")
  CheckValue(metadata, "Metadata")
 end

 local old = self.Data[key]
 self.Data[key] = DeepCopy(value)
 self:_Stamp(key, userIds, metadata)
 self:QueueSave()
 self:Fire(key, value, old)
 return value
end

function Store:Set(key, value)
 return self:_Put(key, value)
end

function Store:Update(key, transform)
 assert(type(transform) == "function", "Update needs a function.")
 key = NormalizeKey(key)
 return self:Set(key, transform(self:Get(key)))
end

function Store:Has(key)
 return self.Data[NormalizeKey(key)] ~= nil
end

function Store:Remove(key)
 assert(not self._destroyed, "Store was closed or destroyed.")
 key = NormalizeKey(key)
 local old = self.Data[key]
 if old == nil then
  return
 end
 self.Data[key] = nil
 self.Info[key] = nil
 self:QueueSave()
 self:Fire(key, nil, old)
end

function Store:Reset()
 assert(not self._destroyed, "Store was closed or destroyed.")
 local old = self.Data
 self.Data = DeepCopy(self.Defaults)
 self.Info = {}
 for k in pairs(self.Data) do
  self:_Stamp(k)
 end
 self:QueueSave()

 local keys = {}
 for k in pairs(old) do
  keys[k] = true
 end
 for k in pairs(self.Data) do
  keys[k] = true
 end
 for k in pairs(keys) do
  if old[k] ~= self.Data[k] then
   self:Fire(k, self.Data[k], old[k])
  end
 end
end

function Store:GetAll()
 return DeepCopy(self.Data)
end

function Store:Close()
 if self._destroyed then
  return
 end
 self:Flush()
 self._destroyed = true
 self._listeners = {}
 if open[self.Path] == self then
  open[self.Path] = nil
 end
end

function Store:Destroy()
 self._destroyed = true
 if type(delfile) == "function" then
  for _, path in ipairs({ self.Path, self.TmpPath }) do
   if SafeIsFile(path) then
    local ok, err = pcall(delfile, path)
    if not ok then
     warn(("Failed to delete '%s': %s"):format(path, tostring(err)))
    end
   end
  end
 end
 self.Data = {}
 self.Info = {}
 self._listeners = {}
 if open[self.Path] == self then
  open[self.Path] = nil
 end
end

function DataStore:_Key(key)
 local k = NormalizeKey(key)
 assert(#k > 0, "Key name can't be empty.")
 return self._prefix .. k
end

function DataStore:_Result(k, value)
 if self._ordered then
  return value
 end
 return value, self._store:GetInfo(k)
end

function DataStore:GetAsync(key)
 local k = self:_Key(key)
 local value = self._store:Get(k)
 if value == nil then
  return nil
 end
 return self:_Result(k, value)
end

function DataStore:SetAsync(key, value, userIds, options)
 assert(value ~= nil, "Can't store nil; use RemoveAsync to delete a key.")
 local k = self:_Key(key)
 if self._ordered then
  AssertInteger(value)
 end
 self._store:_Put(k, value, userIds, ReadMetadata(options))
 return self._store:GetInfo(k).Version
end

function DataStore:UpdateAsync(key, transformFunction)
 assert(type(transformFunction) == "function", "UpdateAsync needs a function.")
 local k = self:_Key(key)
 local store = self._store
 local oldInfo = store:GetInfo(k)

 local new, userIds, metadata = transformFunction(store:Get(k), oldInfo)
 if new == nil then
  return nil
 end
 if self._ordered then
  AssertInteger(new)
 end
 if userIds == nil and oldInfo then
  userIds = oldInfo:GetUserIds()
 end
 if metadata == nil and oldInfo then
  metadata = oldInfo:GetMetadata()
 end

 store:_Put(k, new, userIds, metadata)
 return self:_Result(k, new)
end

function DataStore:IncrementAsync(key, delta, userIds, options)
 if delta == nil then
  delta = 1
 end
 assert(IsInteger(delta), "Delta must be an integer.")
 local k = self:_Key(key)
 local store = self._store

 local old = store:Get(k)
 if old == nil then
  old = 0
 else
  assert(IsInteger(old), "Can't increment a value that isn't an integer.")
 end

 local prev = store:GetInfo(k)
 local metadata = ReadMetadata(options)
 if userIds == nil and prev then
  userIds = prev:GetUserIds()
 end
 if metadata == nil and prev then
  metadata = prev:GetMetadata()
 end

 local new = old + delta
 store:_Put(k, new, userIds, metadata)
 return self:_Result(k, new)
end

function DataStore:RemoveAsync(key)
 local k = self:_Key(key)
 local store = self._store
 local value = store:Get(k)
 if value == nil then
  return nil
 end
 local info = store:GetInfo(k)
 store:Remove(k)
 if self._ordered then
  return value
 end
 return value, info
end

function DataStore:ListKeysAsync(prefix, pageSize, cursor, excludeDeleted)
 local full = self._prefix .. (prefix or "")
 local names = {}
 for k in pairs(self._store.Data) do
  if k:sub(1, #full) == full then
   table.insert(names, k)
  end
 end
 table.sort(names)

 local items = {}
 for i, k in ipairs(names) do
  items[i] = { KeyName = k:sub(#self._prefix + 1) }
 end
 return NewPages(items, pageSize, cursor)
end

function DataStore:OnUpdate(key, callback)
 assert(type(callback) == "function", "OnUpdate needs a function.")
 local disconnect = self._store:OnChanged(self:_Key(key), function(new)
  callback(new)
 end)
 return { Disconnect = disconnect }
end

function DataStore:Flush()
 return self._store:Flush()
end

function DataStore:Save()
 return self._store:Save()
end

function DataStore:Close()
 self._store:Close()
end

function DataStore:Destroy()
 self._store:Destroy()
end

function OrderedDataStore:GetSortedAsync(ascending, pageSize, minValue, maxValue)
 local prefixLen = #self._prefix
 local items = {}
 for key, value in pairs(self._store.Data) do
  if key:sub(1, prefixLen) == self._prefix
   and IsInteger(value)
   and (minValue == nil or value >= minValue)
   and (maxValue == nil or value <= maxValue) then
   table.insert(items, { key = key:sub(prefixLen + 1), value = value })
  end
 end

 table.sort(items, function(a, b)
  if a.value ~= b.value then
   if ascending then
    return a.value < b.value
   end
   return a.value > b.value
  end
  return a.key < b.key
 end)

 return NewPages(items, pageSize)
end

local function NewDataStore(name, scope, options, ordered)
 assert(type(name) == "string" and #name > 0,
  "DataStore name must be a non-empty string (call with ':', e.g. Service:GetDataStore(name)).")
 if scope == nil then
  scope = DEFAULT_SCOPE
 end
 assert(type(scope) == "string" and #scope > 0 and not scope:find("/", 1, true),
  "Scope must be a non-empty string without '/'.")

 if type(options) ~= "table" then
  options = {}
 end

 return setmetatable({
  _store = OpenStore(name, nil, options, ordered and ORDERED_FOLDER or nil),
  _scope = scope,
  _prefix = scope .. "/",
  _ordered = ordered,
 }, ordered and OrderedDataStore or DataStore)
end

function LocalDataStoreService:GetDataStore(name, scope, options)
 return NewDataStore(name, scope, options, false)
end

function LocalDataStoreService:GetGlobalDataStore()
 return NewDataStore("_Global", DEFAULT_SCOPE, nil, false)
end

function LocalDataStoreService:GetOrderedDataStore(name, scope, options)
 return NewDataStore(name, scope, options, true)
end

function LocalDataStoreService:GetRequestBudgetForRequestType()
 return math.huge
end

function LocalDataStoreService.ListStores(folder)
 folder = folder or LocalDataStoreService.RootFolder
 local names = {}
 if type(listfiles) ~= "function" or not SafeIsFolder(folder) then
  return names
 end

 local ok, files = pcall(listfiles, folder)
 if ok and type(files) == "table" then
  for _, path in ipairs(files) do
   local name = tostring(path):match("([^/\\]+)%.json$")
   if name then
    table.insert(names, name)
   end
  end
 end
 return names
end

function LocalDataStoreService:ListDataStoresAsync(prefix, pageSize, cursor)
 prefix = prefix or ""
 local names = {}
 for _, name in ipairs(LocalDataStoreService.ListStores()) do
  if name:sub(1, #prefix) == prefix then
   table.insert(names, name)
  end
 end
 table.sort(names)

 local items = {}
 for i, name in ipairs(names) do
  items[i] = { DataStoreName = name }
 end
 return NewPages(items, pageSize, cursor)
end

function LocalDataStoreService.new(name, defaults, options)
 return OpenStore(name, defaults, options)
end

local function FlushAll()
 for _, store in pairs(open) do
  store:Flush()
 end
end

pcall(function()
 game:BindToClose(FlushAll)
end)

pcall(function()
 local player = game:GetService("Players").LocalPlayer
 if player then
  player.OnTeleport:Connect(FlushAll)
 end
end)

LocalDataStoreService.Supported = HasFS()

return LocalDataStoreService
