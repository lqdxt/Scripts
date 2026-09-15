const RunService: RunService = game:GetService("RunService")
game:GetService("UserInputService")
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

const Draw: any = function(...): any
 return Drawing.new(...)
end
if not Draw then
 error("this environment does not support drawing api")
end

const fh: {number} = table.create(sample, 0)
local head: number = 1

const getfh = function(i: number): number
 return fh[((head + i - 2) % sample) + 1]
end

const setfh_newest = function(val: number): ()
 fh[head] = val
 head = (head % sample) + 1
end

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

const lines: {any} = table.create(sample - 1)
for i: number = 1, sample - 1 do
 const line: any = Draw "Line"
 line.Thickness = 1
 line.Color = Color3.fromRGB(0, 255, 0)
 line.Visible = true
 lines[i] = line
end

const k = function(b: boolean): ()
 bg.Visible = b
 border.Visible = b
end

const fps_to_y = function(fps: number): number
 const ratio: number = clamp(fps, 0, SETTINGS.MAX_FPS_SCALE) / SETTINGS.MAX_FPS_SCALE
 return SETTINGS.GRAPH.Y + SETTINGS.GRAPH.HEIGHT - (ratio * SETTINGS.GRAPH.HEIGHT)
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

local progress: number = 0
local smoothed: number = 0
const ALPHA: number = 0.1
const SAMPLES_PER_SEC: number = 25

const lerp = function(a: number, b: number, t: number): number
 return a + (b - a) * t
end

const getfh_smooth = function(i: number, t: number): number
 const v1: number = getfh(i)
 const v2: number = getfh(if i < sample then i + 1 else i)
 return lerp(v1, v2, t)
end

local con: RBXScriptConnection; con = RunService.RenderStepped:Connect(function(dt: number): ()
 k(true)
 const raw: number = if dt > 0 then 1 / dt else SETTINGS.MAX_FPS_SCALE
 smoothed = smoothed + ALPHA * (raw - smoothed)
 const fps: number = floor(smoothed)

 progress = progress + (dt * SAMPLES_PER_SEC)
 while progress >= 1 do
  progress = progress - 1
  setfh_newest(fps)
 end
 fh[head] = fps

 const gx: number = SETTINGS.GRAPH.X
 for i = 1, sample - 1 do
  const x1: number = gx + (i - 1)
  const x2: number = gx + i
  const val1: number = getfh_smooth(i, progress)
  const val2: number = getfh_smooth(i + 1, progress)
  const y1: number = fps_to_y(val1)
  const y2: number = fps_to_y(val2)

  const line: any = lines[i]
  line.From = Vector2.new(x1, y1)
  line.To = Vector2.new(x2, y2)
  line.Color = fps_to_color(val2)
 end

 fpstext.Text = "FPS: " .. fps
 fpstext.Color = fps_to_color(fps)
end)

const destroy = function()
 con:Disconnect()
 bg:Remove()
 border:Remove()
 fpstext:Remove()
 for _, line in ipairs(lines) do
  line:Remove()
 end
end

return destroy
