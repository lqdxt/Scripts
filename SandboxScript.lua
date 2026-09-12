--!strict

export type ScriptInstance = Instance | {
 ClassName: string,
 Name: string?,
 [any]: any,
}

type ScriptFunc = (...any) -> ...any

type CacheEntry = {
 success: boolean,
 result: any,
}

type LoadingState = {
 status: "Loading" | "Loaded" | "Error",
 thread: thread,
 result: any,
 waiting: { thread },
}

const ScriptRegistry: { [ScriptInstance]: ScriptFunc } = setmetatable({} :: any, { __mode = "k" })
const ModuleCache: { [ScriptInstance]: CacheEntry } = setmetatable({} :: any, { __mode = "k" })
const ThreadWaitingOnModule: { [thread]: ScriptInstance } = setmetatable({} :: any, { __mode = "k" })

const LoadingStates: { [ScriptInstance]: LoadingState } = {}

local function getproperty(target: unknown, property: string): (boolean, any)
 if typeof(target) == "Instance" or typeof(target) == "table" or typeof(target) == "userdata" then
  return pcall(function()
   return (target :: any)[property]
  end)
 end
 return false, nil
end

local function to_string(value: unknown): string
 const success, result = pcall(function()
  return tostring(value)
 end)
 return if success then result else "<unstringable object>"
end

local function ErrorHandler(err: unknown): string
 const errString = to_string(err)
 if string.find(errString, "Stack Begin") or string.find(errString, "stack traceback:") then
  return errString
 end
 const successTrace, trace = pcall(debug.traceback, errString, 2)
 if successTrace and typeof(trace) == "string" then
  return trace
 end
 return errString
end

local function getscriptname(module: unknown): string
 const success, name = getproperty(module, "Name")
 if success and typeof(name) == "string" and name ~= "" then
  return name
 end
 return "UnnamedModule"
end

local function WaitingOn(targetThread: thread, sourceThread: thread): boolean
 local visitedThreads: { [thread]: boolean } = {}
 local checkThread: thread? = targetThread

 while checkThread ~= nil do
  if checkThread == sourceThread then
   return true
  end
  if visitedThreads[checkThread] or coroutine.status(checkThread) == "dead" then
   break
  end
  visitedThreads[checkThread] = true

  const waitingModule = ThreadWaitingOnModule[checkThread]
  if waitingModule == nil then
   break
  end

  const loadingState = LoadingStates[waitingModule]
  if loadingState == nil then
   break
  end

  checkThread = loadingState.thread
 end

 return false
end

local function CustomRequire(module: ScriptInstance): any
 const moduleType: string = typeof(module)
 assert(
  moduleType == "Instance" or moduleType == "table" or moduleType == "userdata",
  string.format("bad argument #1 to 'require' (Instance or table expected, got %s)", moduleType)
 )

 const scClassName, className = getproperty(module, "ClassName")
 assert(
  scClassName and className == "ModuleScript",
  string.format("cannot require a %s, only ModuleScripts", if scClassName then to_string(className) else "invalid object")
 )

 const cachedEntry: CacheEntry? = ModuleCache[module]
 if cachedEntry ~= nil then
  if cachedEntry.success then
   return cachedEntry.result
  else
   error(cachedEntry.result, 0)
  end
 end

 const currentThread: thread = coroutine.running()
 local state: LoadingState? = LoadingStates[module]

 if state ~= nil and coroutine.status(state.thread) == "dead" then
  state.status = "Error"
  state.result = string.format("Thread loading ModuleScript '%s' was cancelled or terminated", getscriptname(module))
  LoadingStates[module] = nil
  for _, waitingThread in state.waiting do
   if coroutine.status(waitingThread) == "suspended" then
    task.spawn(waitingThread)
   end
  end
  state = nil
 end

 if state ~= nil then
  const moduleName: string = getscriptname(module)

  if state.thread == currentThread then
   error(
    string.format("Requested module '%s' was required while it was still loading (circular dependency)", moduleName),
    2
   )
  end

  if WaitingOn(state.thread, currentThread) then
   error(
    string.format("Requested module '%s' results in a cross-thread circular dependency", moduleName),
    2
   )
  end

  table.insert(state.waiting, currentThread)
  ThreadWaitingOnModule[currentThread] = module

  coroutine.yield()

  ThreadWaitingOnModule[currentThread] = nil

  if state.status == "Loaded" then
   return state.result
  else
   error(state.result, 0)
  end
 end

 const moduleFunc: ScriptFunc? = ScriptRegistry[module]
 assert(
  moduleFunc ~= nil,
  string.format("ModuleScript '%s' was never registered via SandboxScript", getscriptname(module))
 )

 const newState: LoadingState = {
  status = "Loading",
  thread = currentThread,
  result = nil,
  waiting = {},
 }
 LoadingStates[module] = newState

 local returnCount: number = 0
 local rawResult: any = nil

 local success: boolean, xpcallErr: any = xpcall(function()
  local function capture_returns(...: any)
   returnCount = select("#", ...)
   rawResult = ...
  end
  capture_returns(moduleFunc())
 end, ErrorHandler)

 local finalSuccess: boolean = success
 local finalResult: any = if success then rawResult else xpcallErr

 if finalSuccess then
  if returnCount ~= 1 or finalResult == nil then
   finalSuccess = false
   finalResult = string.format("ModuleScript '%s' did not return exactly one value", getscriptname(module))
  end
 end

 if finalSuccess then
  newState.status = "Loaded"
  newState.result = finalResult
  ModuleCache[module] = { success = true, result = finalResult }
 else
  newState.status = "Error"
  const errString: string = to_string(finalResult)

  const formattedErr: string = if string.find(errString, "did not return exactly one value") or string.find(errString, "Error while requiring ModuleScript") then
   errString
  else string.format("Error while requiring ModuleScript '%s':\n%s", getscriptname(module), errString)
  newState.result = formattedErr
  ModuleCache[module] = { success = false, result = formattedErr }
 end

 LoadingStates[module] = nil

 for _, waitingThread in newState.waiting do
  if coroutine.status(waitingThread) == "suspended" then
   task.spawn(waitingThread)
  end
 end

 if not finalSuccess then
  error(newState.result, 0)
 end

 return finalResult
end

export type SandboxOptions = {
 AutoRun: boolean?,
}

export type ScriptHandle = {
 run: (...any) -> thread,
 script: ScriptInstance,
}

local function SandboxScript(TargetScript: ScriptInstance, func: ScriptFunc, options: SandboxOptions?): ScriptHandle
 const targetType: string = typeof(TargetScript)
 assert(
  targetType == "Instance" or targetType == "table" or targetType == "userdata",
  "SandboxScript: TargetScript must be an Instance, table, or userdata"
 )
 assert(typeof(func) == "function", "SandboxScript: func must be a function")

 const scClassName, className = getproperty(TargetScript, "ClassName")
 assert(
  scClassName and typeof(className) == "string",
  "SandboxScript: TargetScript missing valid ClassName string"
 )

 const activeState = LoadingStates[TargetScript]
 assert(
  activeState == nil or activeState.status ~= "Loading",
  string.format("SandboxScript: cannot re-sandbox '%s' while it is loading", getscriptname(TargetScript))
 )

 ModuleCache[TargetScript] = nil
 LoadingStates[TargetScript] = nil

 local parentEnv: { [string]: any }
 const successEnv, funcEnv = pcall(getfenv, func)
 if successEnv and typeof(funcEnv) == "table" then
  parentEnv = funcEnv
 else
  const scCallerEnv, callerEnv = pcall(getfenv, 2)
  if scCallerEnv and typeof(callerEnv) == "table" then
   parentEnv = callerEnv
  else
   parentEnv = getfenv()
  end
 end

 const newEnv = setmetatable({
  script = TargetScript,
  require = CustomRequire,
 }, {
  __index = parentEnv,
 })

 const setEnvSc, setEnvErr = pcall(setfenv, func, newEnv)
 assert(
  setEnvSc,
  string.format("SandboxScript: failed to set environment for '%s': %s", getscriptname(TargetScript), to_string(setEnvErr))
 )

 ScriptRegistry[TargetScript] = func

 local runner = function(...: any): thread
  return task.spawn(func, ...)
 end

 const shouldAutoRun = if options and options.AutoRun ~= nil
  then options.AutoRun
  else (className == "LocalScript" or className == "Script")

 if shouldAutoRun then
  runner()
 end

 return {
  run = runner,
  script = TargetScript,
 }
end

return SandboxScript
