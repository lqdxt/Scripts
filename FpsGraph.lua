const RunService = game:GetService("RunService")
const env: any = type(getgenv) == "function" and getgenv() or type(getfenv) == "function" and getfenv() or _G
const SETTINGS: {
 GRAPH: {
  WIDTH: number,
  HEIGHT: number,
  X: number,
  Y: number
 },
 MAX_FPS_SCALE: number
} = {
 GRAPH = {
  WIDTH = 200,
  HEIGHT = 80,
  X = 20,
  Y = 20
 },
 MAX_FPS_SCALE = 144
}
const sample: number = SETTINGS.GRAPH.WIDTH
const clamp: any = math.clamp
const floor: any = math.floor

const Draw: any = Drawing.new
if not Draw then
 local exc: string, ver: string = "", ""
 exc, ver = identifyexecutor()
 error(`your {exc} {ver} executor does not support drawing api`)
end

const fpsHistory: {number} = {}
for i = 1, sample do
 fpsHistory[i] = 0
end

local last_time: number = tick()
local framecount: number = 0
local currentfps: number = 0

const bg: any = Draw "Square"
bg.Size = Vector2.new(SETTINGS.GRAPH.WIDTH, SETTINGS.GRAPH.HEIGHT)
bg.Position = Vector2.new(SETTINGS.GRAPH.X, SETTINGS.GRAPH.Y)
bg.Color = Color3.fromRGB(0, 0, 0)
bg.Transparency = 0.5
bg.Filled = true
bg.Visible = true

const border: any = Draw "Square"
border.Size = Vector2.new(SETTINGS.GRAPH.WIDTH, SETTINGS.GRAPH.HEIGHT)
border.Position = Vector2.new(SETTINGS.GRAPH.X, SETTINGS.GRAPH.Y)
border.Color = Color3.fromRGB(255, 255, 255)
border.Thickness = 1
border.Filled = false
border.Visible = true

const fpstext: any = Draw "Text"
fpstext.Size = 16
fpstext.Center = false
fpstext.Outline = true
fpstext.Color = Color3.fromRGB(0, 255, 0)
fpstext.Position = Vector2.new(SETTINGS.GRAPH.X, SETTINGS.GRAPH.Y - 20)
fpstext.Text = "FPS: 0"
fpstext.Visible = true

const lines: {any} = {}
for i = 1, sample - 1 do
 const line: any = Draw "Line"
 line.Thickness = 1
 line.Color = Color3.fromRGB(0, 255, 0)
 line.Visible = true
 lines[i] = line
end
--[[
 convert an fps value into a Y pixel position inside the graph
 higher fps > lower on screen (near bottom)
 lower fps > higher on screen (near top)
]]
const fps_to_y = function(fps: number): number
 const clamped: any = clamp(fps, 0, SETTINGS.MAX_FPS_SCALE)
 const ratio: any = clamped / SETTINGS.MAX_FPS_SCALE -- 0..1
 -- invert so low fps = high line (small Y), high fps = low line (big Y)
 const y: number = SETTINGS.GRAPH.Y + SETTINGS.GRAPH.HEIGHT - (ratio * SETTINGS.GRAPH.HEIGHT)
 return y
end

const fps_to_color = function(fps: number): Color3
 if fps >= 50 then
  return Color3.fromRGB(0, 255, 0)
 elseif fps >= 30 then
  return Color3.fromRGB(255, 255, 0)
 else
  return Color3.fromRGB(255, 0, 0)
 end
end

const updategraph = function(): ()
 for i = 1, sample - 1 do
  const x1: number = SETTINGS.GRAPH.X + (i - 1)
  const x2: number = SETTINGS.GRAPH.X + i
  const y1: number = fps_to_y(fpsHistory[i])
  const y2: number = fps_to_y(fpsHistory[i + 1])

  const line: any = lines[i]
  line.From = Vector2.new(x1, y1)
  line.To = Vector2.new(x2, y2)
  line.Color = fps_to_color(fpsHistory[i + 1])
 end
end

local con; con = RunService.RenderStepped:Connect(function(dt)
 framecount = framecount + 1
 const now: number = tick()

 if now - last_time >= 0.1 then
  currentfps = floor(framecount / (now - last_time))
  framecount = 0
  last_time = now
  -- push new sample at the end
  table.remove(fpsHistory, 1)
  table.insert(fpsHistory, currentfps)

  fpstext.Text = "FPS: " .. currentfps
  fpstext.Color = fps_to_color(currentfps)

  updategraph()
 end
end)

const destroy = function(): ()
 con:Disconnect()
 bg:Remove()
 border:Remove()
 fpstext:Remove()
 for _, line in ipairs(lines) do
  line:Remove()
 end
end
env.DestroyFpsGraph = destroy
