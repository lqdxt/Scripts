local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
 TOGGLE_KEY = Enum.KeyCode.V,
 SENSITIVITY = 1,
 MOBILE_SENS = 4.5,
 BASE_SPEED = 16,
 SHIFT_MULT = 3,
 CTRL_MULT = 0.25,
 MOBILE_BUTTON = true,
 MOBILE_BTN_POS = UDim2.new(1, -80, 0.5, -30),
 MOBILE_BTN_SIZE = UDim2.new(0, 60, 0, 60),
 MOBILE_BTN_COLOR = Color3.fromRGB(0, 170, 255),
 MOBILE_BTN_ON = Color3.fromRGB(0, 255, 100),

 SETTINGS_BTN_SIZE = UDim2.new(0, 26, 0, 26),
 SETTINGS_BTN_COLOR = Color3.fromRGB(45, 45, 45),
 SETTINGS_ICON_URL = "https://files.catbox.moe/bhwvfl.png",

 SPEED_MIN = 4,
 SPEED_MAX = 200,
 SENS_MIN = 0.1,
 SENS_MAX = 5,

 SPEED_UP_KEY = Enum.KeyCode.Equals,
 SPEED_DOWN_KEY = Enum.KeyCode.Minus,
 SENS_UP_KEY = Enum.KeyCode.RightBracket,
 SENS_DOWN_KEY = Enum.KeyCode.LeftBracket,
 SPEED_STEP = 5,
 SENS_STEP = 0.2,
}

local freecam = {
 enabled = false,
 toggling = false,
 touch = { lookTouch = nil },
 saved = {},
 pos = nil,
 velocity = Vector3.zero,
 pitch = 0,
 yaw = 0,
 targetRoll = 0,
 currentPitch = 0,
 currentYaw = 0,
 currentRoll = 0,
}

local keys = {
 W = false, A = false, S = false, D = false,
 Q = false, E = false,
 Shift = false, Ctrl = false,
}

local renderConnection = nil
local EnableFreecam, DisableFreecam, ToggleFreecam

local function getuiparent()
 local ok, gethui = pcall(function() return gethui end)
 if ok and gethui then
  local ok2, res = pcall(gethui)
  if ok2 and res then return res end
 end
 return CoreGui or LocalPlayer:FindFirstChild("PlayerGui")
end

local function loadIcon(url, filename)
 if not (writefile and getcustomasset) then return nil end

 local success, result = pcall(function()
  local content

  if game and game.HttpGet then
   local ok, data = pcall(function() return game:HttpGet(url) end)
   if ok and data and #data > 0 then content = data end
  end

  if not content and http_request then
   local ok, res = pcall(function() return http_request({ Url = url, Method = "GET" }) end)
   if ok and res and res.Body and #res.Body > 0 then content = res.Body end
  end

  if not content and request then
   local ok, res = pcall(function() return request({ Url = url, Method = "GET" }) end)
   if ok and res and res.Body and #res.Body > 0 then content = res.Body end
  end

  if not content then return nil end

  writefile(filename, content)
  return getcustomasset(filename)
 end)

 if success and result then return result end
 return nil
end

local hintGui = Instance.new("ScreenGui")
hintGui.ResetOnSpawn = false
hintGui.IgnoreGuiInset = true
hintGui.DisplayOrder = 2147483646
hintGui.Parent = getuiparent()

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(0, 220, 0, 40)
hintLabel.AnchorPoint = Vector2.new(0.5, 0)
hintLabel.Position = UDim2.new(0.5, 0, 0, 20)
hintLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hintLabel.BackgroundTransparency = 0.4
hintLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hintLabel.Font = Enum.Font.GothamBold
hintLabel.TextSize = 16
hintLabel.Text = ""
hintLabel.Visible = false
hintLabel.Parent = hintGui

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 8)
hintCorner.Parent = hintLabel

local hintStroke = Instance.new("UIStroke")
hintStroke.Thickness = 1
hintStroke.Color = Color3.fromRGB(80, 80, 80)
hintStroke.Parent = hintLabel

local hintTweenThread = nil
local function showHintMessage(text)
 hintLabel.Text = text
 hintLabel.Visible = true
 hintLabel.TextTransparency = 0
 hintLabel.BackgroundTransparency = 0.4

 if hintTweenThread then
  task.cancel(hintTweenThread)
 end

 hintTweenThread = task.spawn(function()
  task.wait(2)
  local duration = 0.5
  local elapsed = 0
  while elapsed < duration do
   local dt = task.wait()
   elapsed = elapsed + dt
   local alpha = elapsed / duration
   hintLabel.TextTransparency = alpha
   hintLabel.BackgroundTransparency = 0.4 + (0.6 * alpha)
  end
  hintLabel.Visible = false
  hintLabel.TextTransparency = 0
  hintLabel.BackgroundTransparency = 0.4
 end)
end

local function CreateSlider(parent, yPos, label, min, max, default, decimals, onChange)
 local container = Instance.new("Frame")
 container.Size = UDim2.new(1, -16, 0, 44)
 container.Position = UDim2.new(0, 8, 0, yPos)
 container.BackgroundTransparency = 1
 container.Active = true
 container.ZIndex = 6
 container.Parent = parent

 local labelText = Instance.new("TextLabel")
 labelText.Size = UDim2.new(0.6, 0, 0, 16)
 labelText.BackgroundTransparency = 1
 labelText.Text = label
 labelText.TextColor3 = Color3.fromRGB(200, 200, 200)
 labelText.Font = Enum.Font.Gotham
 labelText.TextSize = 12
 labelText.TextXAlignment = Enum.TextXAlignment.Left
 labelText.ZIndex = 6
 labelText.Parent = container

 local valueLabel = Instance.new("TextLabel")
 valueLabel.Size = UDim2.new(0.4, 0, 0, 16)
 valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
 valueLabel.BackgroundTransparency = 1
 valueLabel.Text = string.format("%." .. decimals .. "f", default)
 valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
 valueLabel.Font = Enum.Font.GothamBold
 valueLabel.TextSize = 12
 valueLabel.TextXAlignment = Enum.TextXAlignment.Right
 valueLabel.ZIndex = 6
 valueLabel.Parent = container

 local track = Instance.new("Frame")
 track.Size = UDim2.new(1, 0, 0, 6)
 track.Position = UDim2.new(0, 0, 0, 24)
 track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
 track.BorderSizePixel = 0
 track.ZIndex = 6
 track.Parent = container

 local trackCorner = Instance.new("UICorner")
 trackCorner.CornerRadius = UDim.new(1, 0)
 trackCorner.Parent = track

 local fill = Instance.new("Frame")
 fill.BackgroundColor3 = CONFIG.MOBILE_BTN_COLOR
 fill.BorderSizePixel = 0
 fill.ZIndex = 7
 fill.Parent = track

 local fillCorner = Instance.new("UICorner")
 fillCorner.CornerRadius = UDim.new(1, 0)
 fillCorner.Parent = fill

 local initialAlpha = math.clamp((default - min) / (max - min), 0, 1)
 fill.Size = UDim2.new(initialAlpha, 0, 1, 0)

 local dragging = false
 local dragKind = nil
 local activeInput = nil

 local function updateFromInput(input)
  local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
  local value = min + (max - min) * alpha
  fill.Size = UDim2.new(alpha, 0, 1, 0)
  valueLabel.Text = string.format("%." .. decimals .. "f", value)
  onChange(value)
 end

 track.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then
   dragging = true
   dragKind = "Mouse"
   updateFromInput(input)
  elseif input.UserInputType == Enum.UserInputType.Touch then
   dragging = true
   dragKind = "Touch"
   activeInput = input
   updateFromInput(input)
  end
 end)

 UserInputService.InputEnded:Connect(function(input)
  if dragKind == "Mouse" and input.UserInputType == Enum.UserInputType.MouseButton1 then
   dragging = false
   dragKind = nil
  elseif dragKind == "Touch" and input == activeInput then
   dragging = false
   dragKind = nil
   activeInput = nil
  end
 end)

 UserInputService.InputChanged:Connect(function(input)
  if not dragging then return end
  if dragKind == "Mouse" and input.UserInputType == Enum.UserInputType.MouseMovement then
   updateFromInput(input)
  elseif dragKind == "Touch" and input == activeInput and input.UserInputType == Enum.UserInputType.Touch then
   updateFromInput(input)
  end
 end)

 return container
end

local function ThumbstickTouch(input)
 local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
 if not playerGui then return false end
 local touchGui = playerGui:FindFirstChild("TouchGui")
 local touchControlFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
 if not touchControlFrame then return false end

 local frames = {
  touchControlFrame:FindFirstChild("DynamicThumbstickFrame"),
  touchControlFrame:FindFirstChild("ThumbstickFrame"),
 }

 for _, frame in ipairs(frames) do
  if frame and frame.Visible then
   local pos = frame.AbsolutePosition
   local size = frame.AbsoluteSize
   local tp = input.Position
   if tp.X >= pos.X and tp.X <= pos.X + size.X
   and tp.Y >= pos.Y and tp.Y <= pos.Y + size.Y then
    return true
   end
  end
 end
 return false
end

UserInputService.InputBegan:Connect(function(input, gpe)
 if gpe then return end
 local key = input.KeyCode
 if key == Enum.KeyCode.W then keys.W = true end
 if key == Enum.KeyCode.A then keys.A = true end
 if key == Enum.KeyCode.S then keys.S = true end
 if key == Enum.KeyCode.D then keys.D = true end
 if key == Enum.KeyCode.Q then keys.Q = true end
 if key == Enum.KeyCode.E then keys.E = true end
 if key == Enum.KeyCode.LeftShift then keys.Shift = true end
 if key == Enum.KeyCode.LeftControl then keys.Ctrl = true end

 if key == CONFIG.TOGGLE_KEY then
  ToggleFreecam(not freecam.enabled)
 end

 if key == CONFIG.SPEED_UP_KEY then
  CONFIG.BASE_SPEED = math.clamp(CONFIG.BASE_SPEED + CONFIG.SPEED_STEP, CONFIG.SPEED_MIN, CONFIG.SPEED_MAX)
  if not UserInputService.TouchEnabled then
   showHintMessage(string.format("Speed: %.0f", CONFIG.BASE_SPEED))
  end
 elseif key == CONFIG.SPEED_DOWN_KEY then
  CONFIG.BASE_SPEED = math.clamp(CONFIG.BASE_SPEED - CONFIG.SPEED_STEP, CONFIG.SPEED_MIN, CONFIG.SPEED_MAX)
  if not UserInputService.TouchEnabled then
   showHintMessage(string.format("Speed: %.0f", CONFIG.BASE_SPEED))
  end
 
 elseif key == CONFIG.SENS_UP_KEY then
  CONFIG.SENSITIVITY = math.clamp(CONFIG.SENSITIVITY + CONFIG.SENS_STEP, CONFIG.SENS_MIN, CONFIG.SENS_MAX)
  CONFIG.MOBILE_SENS = CONFIG.SENSITIVITY * 4.5
  if not UserInputService.TouchEnabled then
   showHintMessage(string.format("Sensitivity: %.2f", CONFIG.SENSITIVITY))
  end
 elseif key == CONFIG.SENS_DOWN_KEY then
  CONFIG.SENSITIVITY = math.clamp(CONFIG.SENSITIVITY - CONFIG.SENS_STEP, CONFIG.SENS_MIN, CONFIG.SENS_MAX)
  CONFIG.MOBILE_SENS = CONFIG.SENSITIVITY * 4.5
  if not UserInputService.TouchEnabled then
   showHintMessage(string.format("Sensitivity: %.2f", CONFIG.SENSITIVITY))
  end
 end
end)

UserInputService.InputEnded:Connect(function(input)
 local key = input.KeyCode
 if key == Enum.KeyCode.W then keys.W = false end
 if key == Enum.KeyCode.A then keys.A = false end
 if key == Enum.KeyCode.S then keys.S = false end
 if key == Enum.KeyCode.D then keys.D = false end
 if key == Enum.KeyCode.Q then keys.Q = false end
 if key == Enum.KeyCode.E then keys.E = false end
 if key == Enum.KeyCode.LeftShift then keys.Shift = false end
 if key == Enum.KeyCode.LeftControl then keys.Ctrl = false end
end)

UserInputService.TouchStarted:Connect(function(input, gpe)
 if not freecam.enabled then return end
 if gpe then return end
 if ThumbstickTouch(input) then return end
 if not freecam.touch.lookTouch then
  freecam.touch.lookTouch = input
 end
end)

UserInputService.TouchMoved:Connect(function(input, gpe)
 if not freecam.enabled then return end
 if input ~= freecam.touch.lookTouch then return end

 local delta = input.Delta
 if delta.Magnitude < 0.5 then return end

 freecam.yaw = freecam.yaw   - delta.X * CONFIG.MOBILE_SENS * 0.002
 freecam.pitch = freecam.pitch - delta.Y * CONFIG.MOBILE_SENS * 0.002
 freecam.pitch = math.clamp(freecam.pitch, math.rad(-80), math.rad(80))
 freecam.targetRoll = math.clamp(delta.X * 0.002, -0.05, 0.05)
end)

UserInputService.TouchEnded:Connect(function(input)
 if input == freecam.touch.lookTouch then
  freecam.touch.lookTouch = nil
 end
end)

local function UpdateFreecam(dt)
 if not freecam.enabled then return end

 local delta = Vector2.zero
 if not UserInputService.TouchEnabled then
  delta = UserInputService:GetMouseDelta()
 end

 freecam.targetRoll = math.clamp(-delta.X * 0.002, -0.05, 0.05)

 if not UserInputService.TouchEnabled then
  local sens = CONFIG.SENSITIVITY or 1
  freecam.yaw = freecam.yaw   + delta.X * sens * 0.002
  freecam.pitch = freecam.pitch + delta.Y * sens * 0.002
 end

 freecam.pitch = math.clamp(freecam.pitch, math.rad(-80), math.rad(80))

 local x, y, z = 0, 0, 0

 if UserInputService.TouchEnabled then
  local character = LocalPlayer.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if humanoid then
   local moveInput = humanoid.MoveDirection
   if moveInput.Magnitude > 0 then
    local camCF = CFrame.Angles(0, freecam.yaw, 0)
    local camRight = camCF.RightVector
    local camFwd = -camCF.LookVector
    x = moveInput:Dot(camRight)
    z = moveInput:Dot(camFwd)
   end
  end
 else
  x = (keys.D and 1 or 0) - (keys.A and 1 or 0)
  y = (keys.E and 1 or 0) - (keys.Q and 1 or 0)
  z = (keys.S and 1 or 0) - (keys.W and 1 or 0)
 end

 local move = Vector3.new(x, y, z)
 if move.Magnitude > 1 then
  move = move.Unit
 end

 local baseSpeed = CONFIG.BASE_SPEED or 16
 local speed = baseSpeed
 if keys.Shift then
  speed = baseSpeed * CONFIG.SHIFT_MULT
 elseif keys.Ctrl then
  speed = baseSpeed * CONFIG.CTRL_MULT
 end

 local smoothness = 1 - math.exp(-8 * dt)

 freecam.currentPitch = freecam.currentPitch + (freecam.pitch - freecam.currentPitch) * smoothness
 freecam.currentYaw = freecam.currentYaw   + (freecam.yaw   - freecam.currentYaw)   * smoothness
 freecam.currentRoll = freecam.currentRoll  + (freecam.targetRoll - freecam.currentRoll) * smoothness
 freecam.targetRoll = freecam.targetRoll * 0.8

 local rotVisual = CFrame.fromOrientation(freecam.currentPitch, freecam.currentYaw, freecam.currentRoll)
 local rotMove = CFrame.fromOrientation(freecam.pitch, freecam.yaw, 0)
 local targetVel = rotMove:VectorToWorldSpace(move * speed)

 freecam.velocity = freecam.velocity:Lerp(targetVel, smoothness)
 freecam.pos = freecam.pos + freecam.velocity * dt

 local cam = Workspace.CurrentCamera
 if cam then
  cam.CFrame = CFrame.new(freecam.pos) * rotVisual
 end
end

local function FreezePlayer()
 local character = LocalPlayer.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 if humanoid then
  humanoid.WalkSpeed = 0
  humanoid.JumpPower = 0
 end
end

EnableFreecam = function()
 if freecam.enabled or freecam.toggling then return end
 freecam.toggling = true
 freecam.enabled = true

 local cam = Workspace.CurrentCamera
 if not cam then
  freecam.toggling = false
  freecam.enabled = false
  return
 end

 freecam.saved.type = cam.CameraType
 freecam.saved.subject = cam.CameraSubject
 freecam.saved.cf = cam.CFrame

 local camCF = cam.CFrame
 freecam.pos = camCF.Position

 local rx, ry = camCF:ToOrientation()
 freecam.pitch = rx
 freecam.yaw = ry
 freecam.currentPitch = rx
 freecam.currentYaw = ry
 freecam.currentRoll = 0
 freecam.targetRoll = 0
 freecam.velocity = Vector3.zero

 local character = LocalPlayer.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 if humanoid then
  freecam.saved.walkSpeed = humanoid.WalkSpeed
  freecam.saved.jumpPower = humanoid.JumpPower
  freecam.saved.useJumpPower = humanoid.UseJumpPower
 end

 cam.CameraType = Enum.CameraType.Scriptable
 UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
 UserInputService.MouseIconEnabled = false

 renderConnection = RunService.RenderStepped:Connect(function(dt)
  FreezePlayer()
  UpdateFreecam(dt)
 end)

 task.delay(0.2, function()
  freecam.toggling = false
 end)
end

DisableFreecam = function()
 if not freecam.enabled or freecam.toggling then return end
 freecam.toggling = true
 freecam.enabled = false

 if renderConnection then
  renderConnection:Disconnect()
  renderConnection = nil
 end

 local character = LocalPlayer.Character
 local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 if humanoid and freecam.saved.walkSpeed then
  humanoid.WalkSpeed = freecam.saved.walkSpeed
  humanoid.JumpPower = freecam.saved.jumpPower
  humanoid.UseJumpPower = freecam.saved.useJumpPower
 end

 local cam = Workspace.CurrentCamera
 if cam then
  cam.CameraType = freecam.saved.type or Enum.CameraType.Custom
  cam.CameraSubject = freecam.saved.subject
  cam.CFrame = freecam.saved.cf
 end

 UserInputService.MouseBehavior = Enum.MouseBehavior.Default
 UserInputService.MouseIconEnabled = true

 freecam.toggling = false
end

ToggleFreecam = function(state)
 if state == nil then state = not freecam.enabled end
 if state then
  EnableFreecam()
 else
  DisableFreecam()
 end
end

if CONFIG.MOBILE_BUTTON and UserInputService.TouchEnabled then
 local gui = Instance.new("ScreenGui")
 gui.ResetOnSpawn = false
 gui.IgnoreGuiInset = true
 gui.DisplayOrder = 2147483647
 gui.Parent = getuiparent()

 local button = Instance.new("TextButton")
 button.Size = CONFIG.MOBILE_BTN_SIZE
 button.Position = CONFIG.MOBILE_BTN_POS
 button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
 button.BackgroundTransparency = 0.3
 button.Text = "OFF"
 button.TextColor3 = Color3.fromRGB(255, 255, 255)
 button.TextSize = 18
 button.Font = Enum.Font.GothamBold
 button.BorderSizePixel = 0
 button.Active = true
 button.Parent = gui

 local corner = Instance.new("UICorner")
 corner.CornerRadius = UDim.new(0, 12)
 corner.Parent = button

 local stroke = Instance.new("UIStroke")
 stroke.Thickness = 2
 stroke.Color = CONFIG.MOBILE_BTN_COLOR
 stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 stroke.Parent = button

 local repositionSatellites

 local dragging = false
 local dragKind = nil
 local activeInput = nil
 local dragStart = Vector2.zero
 local startPos = button.Position
 local moved = false
 local DRAG_THRESHOLD = 6

 local function updateDrag(input)
  local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
  if delta.Magnitude > DRAG_THRESHOLD then moved = true end
  button.Position = UDim2.new(
   startPos.X.Scale, startPos.X.Offset + delta.X,
   startPos.Y.Scale, startPos.Y.Offset + delta.Y
  )
  if repositionSatellites then repositionSatellites() end
 end

 button.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then
   dragging = true
   dragKind = "Mouse"
   moved = false
   dragStart = Vector2.new(input.Position.X, input.Position.Y)
   startPos = button.Position
  elseif input.UserInputType == Enum.UserInputType.Touch then
   dragging = true
   dragKind = "Touch"
   activeInput = input
   moved = false
   dragStart = Vector2.new(input.Position.X, input.Position.Y)
   startPos = button.Position
  end
 end)

 button.InputEnded:Connect(function(input)
  if dragKind == "Mouse" and input.UserInputType == Enum.UserInputType.MouseButton1 then
   dragging = false
   dragKind = nil
  elseif dragKind == "Touch" and input == activeInput then
   dragging = false
   dragKind = nil
   activeInput = nil
  end
 end)

 UserInputService.InputChanged:Connect(function(input)
  if not dragging then return end
  if dragKind == "Mouse" and input.UserInputType == Enum.UserInputType.MouseMovement then
   updateDrag(input)
  elseif dragKind == "Touch" and input == activeInput and input.UserInputType == Enum.UserInputType.Touch then
   updateDrag(input)
  end
 end)

 button.MouseButton1Click:Connect(function()
  if moved then return end
  ToggleFreecam()
 end)

 local settingsButton = Instance.new("TextButton")
 settingsButton.Size = CONFIG.SETTINGS_BTN_SIZE
 settingsButton.AnchorPoint = Vector2.new(0.5, 0.5)
 settingsButton.Position = UDim2.new(
  button.Position.X.Scale, button.Position.X.Offset + button.Size.X.Offset,
  button.Position.Y.Scale, button.Position.Y.Offset
 )
 settingsButton.BackgroundColor3 = CONFIG.SETTINGS_BTN_COLOR
 settingsButton.BackgroundTransparency = 0.1
 settingsButton.AutoButtonColor = false
 settingsButton.Active = true
 settingsButton.Text = ""
 settingsButton.BorderSizePixel = 0
 settingsButton.ZIndex = 3
 settingsButton.Parent = gui

 local settingsCorner = Instance.new("UICorner")
 settingsCorner.CornerRadius = UDim.new(1, 0)
 settingsCorner.Parent = settingsButton

 local settingsStroke = Instance.new("UIStroke")
 settingsStroke.Thickness = 1
 settingsStroke.Color = Color3.fromRGB(90, 90, 90)
 settingsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 settingsStroke.Parent = settingsButton

 local settingsIconId = loadIcon(CONFIG.SETTINGS_ICON_URL, "freecam_settings_icon.png")
 if settingsIconId then
  local icon = Instance.new("ImageLabel")
  icon.Size = UDim2.new(0.6, 0, 0.6, 0)
  icon.AnchorPoint = Vector2.new(0.5, 0.5)
  icon.Position = UDim2.new(0.5, 0, 0.5, 0)
  icon.BackgroundTransparency = 1
  icon.Image = settingsIconId
  icon.ZIndex = 4
  icon.Parent = settingsButton
 end

 local panel = Instance.new("Frame")
 panel.Size = UDim2.new(0, 190, 0, 136)
 panel.AnchorPoint = Vector2.new(1, 0.5)
 panel.Position = UDim2.new(
  settingsButton.Position.X.Scale, settingsButton.Position.X.Offset - 16,
  settingsButton.Position.Y.Scale, settingsButton.Position.Y.Offset
 )
 panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
 panel.BackgroundTransparency = 0.1
 panel.Visible = false
 panel.Active = true
 panel.BorderSizePixel = 0
 panel.ZIndex = 5
 panel.Parent = gui

 local panelCorner = Instance.new("UICorner")
 panelCorner.CornerRadius = UDim.new(0, 10)
 panelCorner.Parent = panel

 local panelStroke = Instance.new("UIStroke")
 panelStroke.Thickness = 1
 panelStroke.Color = Color3.fromRGB(70, 70, 70)
 panelStroke.Parent = panel

 repositionSatellites = function()
  settingsButton.Position = UDim2.new(
   button.Position.X.Scale, button.Position.X.Offset + button.Size.X.Offset,
   button.Position.Y.Scale, button.Position.Y.Offset
  )
  panel.Position = UDim2.new(
   settingsButton.Position.X.Scale, settingsButton.Position.X.Offset - 16,
   settingsButton.Position.Y.Scale, settingsButton.Position.Y.Offset
  )
 end

 local title = Instance.new("TextLabel")
 title.Size = UDim2.new(1, -16, 0, 24)
 title.Position = UDim2.new(0, 8, 0, 4)
 title.BackgroundTransparency = 1
 title.Text = "Freecam Settings"
 title.TextColor3 = Color3.fromRGB(255, 255, 255)
 title.Font = Enum.Font.GothamBold
 title.TextSize = 14
 title.TextXAlignment = Enum.TextXAlignment.Left
 title.ZIndex = 6
 title.Parent = panel

 CreateSlider(panel, 34, "Speed", CONFIG.SPEED_MIN, CONFIG.SPEED_MAX, CONFIG.BASE_SPEED, 0, function(v)
  CONFIG.BASE_SPEED = v
  showHintMessage(string.format("Speed: %.0f", v))
 end)

 CreateSlider(panel, 86, "Sensitivity", CONFIG.SENS_MIN, CONFIG.SENS_MAX, CONFIG.SENSITIVITY, 2, function(v)
  CONFIG.SENSITIVITY = v
  CONFIG.MOBILE_SENS = v * 4.5
  showHintMessage(string.format("Sensitivity: %.2f", v))
 end)

 settingsButton.MouseButton1Click:Connect(function()
  panel.Visible = not panel.Visible
 end)

 local lastState = false
 RunService.Heartbeat:Connect(function()
  if freecam.enabled ~= lastState then
   lastState = freecam.enabled
   if lastState then
    stroke.Color = CONFIG.MOBILE_BTN_ON
    button.Text = "ON"
    button.TextSize = 14
   else
    stroke.Color = CONFIG.MOBILE_BTN_COLOR
    button.Text = "OFF"
    button.TextSize = 18
   end
  end
 end)
end
