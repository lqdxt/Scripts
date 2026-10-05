local Teleport = game:GetService("TeleportService")
local PlayerService = game:GetService("Players")
local InputService = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Http = game:GetService("HttpService")
local lp = PlayerService.LocalPlayer

local pc = pcall(function() return gethui() end) and gethui() or pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")
if pc:FindFirstChild("JBID") then pc.JBID:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "JBID"
sg.DisplayOrder = 2147483647
sg.ResetOnSpawn = false
sg.Parent = pc

local mf = Instance.new("Frame")
mf.Name = ""
mf.Size = UDim2.new(0, 310, 0, 180)
mf.Position = UDim2.new(0.5, -155, 0.4, -90)
mf.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
mf.BorderSizePixel = 0
mf.Active = true
mf.ClipsDescendants = true
mf.Parent = sg

Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(38, 38, 42)
ms.Thickness = 1
ms.Parent = mf

local msh = Instance.new("UIShadow")
msh.BlurRadius = UDim.new(0, 20)
msh.Color = Color3.fromRGB(0, 0, 0)
msh.Transparency = 0.5
msh.Offset = UDim2.new(0, 0, 0, 4)
msh.Parent = mf

local hd = Instance.new("Frame")
hd.Name = ""
hd.Size = UDim2.new(1, 0, 0, 38)
hd.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
hd.BorderSizePixel = 0
hd.Active = true
hd.Parent = mf

Instance.new("UICorner", hd).CornerRadius = UDim.new(0, 10)

local hm = Instance.new("Frame")
hm.Size = UDim2.new(1, 0, 0, 10)
hm.Position = UDim2.new(0, 0, 1, -10)
hm.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
hm.BorderSizePixel = 0
hm.Parent = hd

local tb = Instance.new("Frame")
tb.Size = UDim2.new(0, 36, 0, 4)
tb.Position = UDim2.new(0.5, -18, 0, 6)
tb.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
tb.BorderSizePixel = 0
tb.Parent = hd

Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

local tt = Instance.new("TextLabel")
tt.Size = UDim2.new(1, -50, 1, -10)
tt.Position = UDim2.new(0, 14, 0, 10)
tt.BackgroundTransparency = 1
tt.Text = "Job Joiner"
tt.TextColor3 = Color3.fromRGB(245, 245, 245)
tt.TextSize = 12
tt.Font = Enum.Font.GothamBold
tt.TextXAlignment = Enum.TextXAlignment.Left
tt.Parent = hd

local cb = Instance.new("TextButton")
cb.Size = UDim2.new(0, 22, 0, 22)
cb.Position = UDim2.new(1, -28, 0.5, -7)
cb.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
cb.Text = "X"
cb.TextColor3 = Color3.fromRGB(150, 150, 150)
cb.TextSize = 10
cb.Font = Enum.Font.GothamBold
cb.AutoButtonColor = false
cb.Parent = hd

Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)

local itf = Instance.new("Frame")
itf.Size = UDim2.new(1, -24, 0, 36)
itf.Position = UDim2.new(0, 12, 0, 48)
itf.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
itf.Parent = mf

Instance.new("UICorner", itf).CornerRadius = UDim.new(0, 8)

local is = Instance.new("UIStroke")
is.Color = Color3.fromRGB(38, 38, 42)
is.Thickness = 1
is.Parent = itf

local ji = Instance.new("TextBox")
ji.Size = UDim2.new(1, -16, 1, 0)
ji.Position = UDim2.new(0, 8, 0, 0)
ji.BackgroundTransparency = 1
ji.PlaceholderText = "Paste Job ID..."
ji.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
ji.Text = ""
ji.TextColor3 = Color3.fromRGB(240, 240, 240)
ji.TextSize = 11
ji.Font = Enum.Font.Code
ji.ClearTextOnFocus = false
ji.Parent = itf

local sf = Instance.new("Frame")
sf.Size = UDim2.new(1, -24, 0, 22)
sf.Position = UDim2.new(0, 12, 0, 90)
sf.BackgroundTransparency = 1
sf.Parent = mf

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, 0, 1, 0)
st.BackgroundTransparency = 1
st.Text = "PLAYERS: "..#PlayerService:GetPlayers().." / "..PlayerService.MaxPlayers
st.TextColor3 = Color3.fromRGB(0, 230, 120)
st.TextSize = 10
st.Font = Enum.Font.GothamBold
st.TextXAlignment = Enum.TextXAlignment.Left
st.Parent = sf

local ac = Instance.new("Frame")
ac.Size = UDim2.new(1, -24, 0, 36)
ac.Position = UDim2.new(0, 12, 0, 122)
ac.BackgroundTransparency = 1
ac.Parent = mf

local jbt = Instance.new("TextButton")
jbt.Size = UDim2.new(0.64, -4, 1, 0)
jbt.Position = UDim2.new(0, 0, 0, 0)
jbt.BackgroundColor3 = Color3.fromRGB(0, 150, 214)
jbt.Text = "Join Server"
jbt.TextColor3 = Color3.fromRGB(255, 255, 255)
jbt.TextSize = 11
jbt.Font = Enum.Font.GothamBold
jbt.AutoButtonColor = false
jbt.Parent = ac

Instance.new("UICorner", jbt).CornerRadius = UDim.new(0, 8)

local cpbt = Instance.new("TextButton")
cpbt.Size = UDim2.new(0.36, -4, 1, 0)
cpbt.Position = UDim2.new(0.64, 4, 0, 0)
cpbt.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
cpbt.Text = "Copy ID"
cpbt.TextColor3 = Color3.fromRGB(180, 180, 180)
cpbt.TextSize = 11
cpbt.Font = Enum.Font.GothamBold
cpbt.AutoButtonColor = false
cpbt.Parent = ac

Instance.new("UICorner", cpbt).CornerRadius = UDim.new(0, 8)

local cpst = Instance.new("UIStroke")
cpst.Color = Color3.fromRGB(38, 38, 42)
cpst.Thickness = 1
cpst.Parent = cpbt

local dgg = false
local di = nil
local ds = nil
local dgp = nil

hd.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  dgg = true
  di = input
  ds = input.Position
  dgp = mf.Position

  local con; con = input.Changed:Connect(function()
   if input.UserInputState == Enum.UserInputState.End then
    dgg = false
    di = nil
    con:Disconnect()
   end
  end)
 end
end)

InputService.InputChanged:Connect(function(input)
 if dgg and input == di then
  local delta = input.Position - ds
  mf.Position = UDim2.new(dgp.X.Scale,dgp.X.Offset+delta.X,dgp.Y.Scale,dgp.Y.Offset+delta.Y)
 end
end)

local count = 0
local updateplayercount = function(jobid)
 jobid = jobid:gsub("%s+","")
 count = count + 1
 local current = count

 if jobid == "" or jobid == game.JobId then
  st.Text = "PLAYERS: "..#PlayerService:GetPlayers().."/"..PlayerService.MaxPlayers
  st.TextColor3 = Color3.fromRGB(0, 230, 120)
  return
 end

 st.Text = "PLAYERS: Loading..."
 st.TextColor3 = Color3.fromRGB(140, 140, 140)

 task.spawn(function()
  local k, r = pcall(function()
   return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100")
  end)

  if count ~= current then return end

  if k and r then
   local kd, d = pcall(function() return Http:JSONDecode(r) end)
   if kd and d and d.data then
    for _, server in ipairs(d.data) do
     if server.id == jobid then
      st.Text = "PLAYERS: "..server.playing.."/"..server.maxPlayers
      st.TextColor3 = Color3.fromRGB(0, 230, 120)
      return
     end
    end
   end
  end

  st.Text = "PLAYERS: Unlisted/Private"
  st.TextColor3 = Color3.fromRGB(235, 55, 55)
 end)
end

ji:GetPropertyChangedSignal("Text"):Connect(function()
 updateplayercount(ji.Text)
end)

jbt.MouseEnter:Connect(function()
 Tween:Create(jbt, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0, 175, 245)}):Play()
end)

jbt.MouseLeave:Connect(function()
 Tween:Create(jbt, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(0, 150, 214)}):Play()
end)

cpbt.MouseEnter:Connect(function()
 Tween:Create(cpbt, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 32, 36)}):Play()
end)

cpbt.MouseLeave:Connect(function()
 Tween:Create(cpbt, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(24, 24, 27)}):Play()
end)

cb.MouseEnter:Connect(function()
 Tween:Create(cb, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(200, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)

cb.MouseLeave:Connect(function()
 Tween:Create(cb, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 32, 36), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
end)

ji.Focused:Connect(function()
 Tween:Create(is, TweenInfo.new(0.12), {Color = Color3.fromRGB(0, 150, 214)}):Play()
end)

ji.FocusLost:Connect(function()
 Tween:Create(is, TweenInfo.new(0.12), {Color = Color3.fromRGB(38, 38, 42)}):Play()
end)

cb.MouseButton1Click:Connect(function()
 sg:Destroy()
end)

jbt.MouseButton1Click:Connect(function()
 local tid = ji.Text:gsub("%s+", "")
 if tid ~= "" then
  jbt.Text = "Joining..."
  local k, _ = pcall(function()
   Teleport:TeleportToPlaceInstance(game.PlaceId, tid, lp)
  end)
  if not k then
   jbt.Text = "Failed"
   task.delay(1.5, function() jbt.Text = "Join Server" end)
  end
 end
end)

cpbt.MouseButton1Click:Connect(function()
 local copy = setclipboard or toclipboard or writeclipboard
 if copy then
  copy(game.JobId)
  cpbt.Text = "Copied"
 else
  ji.Text = game.JobId
  cpbt.Text = "Pasted"
 end
 task.delay(1.5, function() cpbt.Text = "Copy ID" end)
end)
