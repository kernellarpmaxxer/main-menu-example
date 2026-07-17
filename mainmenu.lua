--Connected Discord-GitHub credits judy_1467 on roblox and kernel.larpmaxxer on discord 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

Lighting.ClockTime = 0
Lighting.Brightness = 0.35
Lighting.Ambient = Color3.fromRGB(18, 14, 30)
Lighting.OutdoorAmbient = Color3.fromRGB(22, 16, 36)
Lighting.ColorShift_Top = Color3.fromRGB(20, 10, 35)
Lighting.ColorShift_Bottom = Color3.fromRGB(10, 6, 20)
Lighting.GlobalShadows = true
Lighting.FogColor = Color3.fromRGB(12, 8, 22)
Lighting.FogEnd = 900
Lighting.FogStart = 200

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local SPARKLE_TEX = "rbxasset://textures/particles/sparkles_main.dds"

local CYAN = Color3.fromRGB(205, 130, 215)
local DEEP = Color3.fromRGB(135, 100, 124)
local PALE = Color3.fromRGB(238, 210, 242)
local RED = Color3.fromRGB(255, 170, 255)
local DARKRED = Color3.fromRGB(140, 96, 136)
local BEIGE = Color3.fromRGB(240, 214, 175)

local rng = Random.new(7)

player:SetAttribute("InMenu", true)

local ORIGIN = CFrame.new(0, 260, 0)

local scene = Instance.new("Folder")
scene.Name = "MenuCircle"
scene.Parent = workspace

local menuActive = true
local transitioning = false
local transitionStart = 0
local startCamCF = nil
local flashed = false
local speedMult = 1

local layers = {}

local function newLayer(speed, base, bob)
	local model = Instance.new("Model")
	local pivot = Instance.new("Part")
	pivot.Anchored = true
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CanTouch = false
	pivot.Transparency = 1
	pivot.Size = Vector3.new(0.2, 0.2, 0.2)
	pivot.CFrame = ORIGIN * (base or CFrame.new())
	pivot.Parent = model
	model.PrimaryPart = pivot
	model.Parent = scene
	local layer = {model = model, speed = speed, ang = 0, base = base or CFrame.new(), bob = bob}
	table.insert(layers, layer)
	return model
end

local function lPart(model, offsetCF, size, color, transparency)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = ORIGIN * offsetCF
	p.Color = color
	p.Material = Enum.Material.Neon
	p.Transparency = transparency or 0
	p.Parent = model
	return p
end

local function addRing(model, radius, segs, thickness, height, color, transparency)
	local segLen = 2 * math.pi * radius / segs + 0.06
	for i = 1, segs do
		local a = i / segs * math.pi * 2
		local offset = CFrame.Angles(0, a, 0) * CFrame.new(radius, height, 0) * CFrame.Angles(0, math.rad(90), 0)
		lPart(model, offset, Vector3.new(segLen, 0.12, thickness), color, transparency)
	end
end

local function addLine(model, fromV, toV, thickness, height, color, transparency)
	local mid = (fromV + toV) / 2
	local len = (toV - fromV).Magnitude
	local look = CFrame.lookAt(Vector3.new(fromV.X, 0, fromV.Z), Vector3.new(toV.X, 0, toV.Z))
	local offset = CFrame.new(mid.X, height, mid.Z) * (look - look.Position)
	lPart(model, offset, Vector3.new(thickness, 0.12, len), color, transparency)
end

local function polyPoints(n, radius, rot)
	local pts = {}
	for i = 1, n do
		local a = rot + i / n * math.pi * 2
		pts[i] = Vector3.new(math.cos(a) * radius, 0, math.sin(a) * radius)
	end
	return pts
end

local function addPolygon(model, points, thickness, height, color, transparency)
	for i = 1, #points do
		addLine(model, points[i], points[(i % #points) + 1], thickness, height, color, transparency)
	end
end

local EMB = CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(90), 0, 0)

local function embRing(model, radius, segs, thickness, color, transparency, depth)
	local segLen = 2 * math.pi * radius / segs + 0.05
	for i = 1, segs do
		local a = i / segs * math.pi * 2
		lPart(model, EMB * CFrame.Angles(0, a, 0) * CFrame.new(radius, depth or 0, 0) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(segLen, 0.14, thickness), color, transparency)
	end
end

local function embPolygon(model, n, radius, rot, thickness, color, transparency)
	local pts = polyPoints(n, radius, rot)
	for i = 1, n do
		local a = pts[i]
		local b = pts[(i % n) + 1]
		local mid = (a + b) / 2
		local len = (b - a).Magnitude
		local look = CFrame.lookAt(Vector3.new(a.X, 0, a.Z), Vector3.new(b.X, 0, b.Z))
		lPart(model, EMB * CFrame.new(mid.X, 0, mid.Z) * (look - look.Position), Vector3.new(thickness, 0.14, len), color, transparency)
	end
end

local emblemA = newLayer(0.05, EMB)
embRing(emblemA, 10, 44, 0.3, CYAN, 0.25)
embRing(emblemA, 9.2, 40, 0.16, CYAN, 0.5)
for i = 1, 18 do
	local a = i / 18 * math.pi * 2
	local h = 0.42 + rng:NextNumber() * 0.32
	lPart(emblemA, EMB * CFrame.Angles(0, a, 0) * CFrame.new(9.6, 0.06, 0) * CFrame.Angles(0, math.rad(90), 0), Vector3.new(0.2, 0.1, h), PALE, 0.35 + rng:NextNumber() * 0.25)
end
for i = 1, 8 do
	local a = i / 8 * math.pi * 2
	local big = i % 2 == 1
	lPart(emblemA, EMB * CFrame.Angles(0, a, 0) * CFrame.new(10, 0.35, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0), big and Vector3.new(0.95, 0.95, 0.95) or Vector3.new(0.6, 0.6, 0.6), big and RED or CYAN, 0.05)
end

local emblemB = newLayer(-0.09, EMB)
embPolygon(emblemB, 4, 7.7, 0, 0.18, CYAN, 0.4)
embPolygon(emblemB, 4, 7.7, math.pi / 4, 0.18, CYAN, 0.4)

local emblemC = newLayer(0.14, EMB)
embRing(emblemC, 5.4, 32, 0.14, PALE, 0.45)
embRing(emblemC, 4.8, 28, 0.1, DEEP, 0.5)
for i = 1, 8 do
	local a = i / 8 * math.pi * 2 + math.pi / 8
	local dot = lPart(emblemC, EMB * CFrame.Angles(0, a, 0) * CFrame.new(5.4, 0.12, 0), Vector3.new(0.32, 0.32, 0.32), RED, 0.1)
	dot.Shape = Enum.PartType.Ball
end
embRing(emblemC, 3.6, 26, 0.16, RED, 0.35)

local glowPool = Instance.new("Part")
glowPool.Anchored = true
glowPool.CanCollide = false
glowPool.CanQuery = false
glowPool.CanTouch = false
glowPool.CastShadow = false
glowPool.Shape = Enum.PartType.Cylinder
glowPool.Size = Vector3.new(0.12, 23, 23)
glowPool.CFrame = ORIGIN * CFrame.new(0, 8, -0.6) * CFrame.Angles(0, math.rad(90), 0)
glowPool.Color = CYAN
glowPool.Material = Enum.Material.Neon
glowPool.Transparency = 0.88
glowPool.Parent = scene

local flames = {}

local dustPart = Instance.new("Part")
dustPart.Anchored = true
dustPart.CanCollide = false
dustPart.CanQuery = false
dustPart.CanTouch = false
dustPart.Transparency = 1
dustPart.Size = Vector3.new(0.2, 0.2, 0.2)
dustPart.CFrame = ORIGIN * CFrame.new(0, 16, -5)
dustPart.Parent = scene
local dustAtt = Instance.new("Attachment")
dustAtt.Parent = dustPart
local dust = Instance.new("ParticleEmitter")
dust.Texture = SPARKLE_TEX
dust.Color = ColorSequence.new(PALE, CYAN)
dust.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.3, 0.22), NumberSequenceKeypoint.new(1, 0)})
dust.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1)})
dust.Rate = 8
dust.Speed = NumberRange.new(0.4, 1)
dust.Lifetime = NumberRange.new(5, 7)
dust.SpreadAngle = Vector2.new(180, 180)
dust.Acceleration = Vector3.new(0, -1.2, 0)
dust.LightEmission = 0.8
dust.LightInfluence = 0
dust.Parent = dustAtt

for i = 1, 9 do
	local ang = i / 9 * math.pi * 2 + 0.5
	local spread = 15 + rng:NextNumber() * 14
	local mx = math.cos(ang) * spread
	local my = 8 + math.sin(ang) * (7 + rng:NextNumber() * 5)
	local mz = -8 - rng:NextNumber() * 18
	local d = 0.55 + rng:NextNumber() * 0.75
	local moon = Instance.new("Part")
	moon.Anchored = true
	moon.CanCollide = false
	moon.CanQuery = false
	moon.CanTouch = false
	moon.CastShadow = false
	moon.Shape = Enum.PartType.Ball
	moon.Size = Vector3.new(d, d, d)
	moon.CFrame = ORIGIN * CFrame.new(mx, my, mz)
	moon.Color = BEIGE
	moon.Material = Enum.Material.Neon
	moon.Transparency = 0.05
	moon.Parent = scene
	local cover = Instance.new("Part")
	cover.Anchored = true
	cover.CanCollide = false
	cover.CanQuery = false
	cover.CanTouch = false
	cover.CastShadow = false
	cover.Shape = Enum.PartType.Ball
	cover.Size = Vector3.new(d * 1.08, d * 1.08, d * 1.08)
	cover.CFrame = ORIGIN * CFrame.new(mx + d * (0.25 + (i % 4) * 0.3), my, mz + d * 0.18)
	cover.Color = Color3.fromRGB(26, 22, 34)
	cover.Material = Enum.Material.SmoothPlastic
	cover.Parent = scene
end

local stars = {}

for i = 1, 140 do
	local star = Instance.new("Part")
	star.Anchored = true
	star.CanCollide = false
	star.CanQuery = false
	star.CanTouch = false
	star.CastShadow = false
	star.Shape = Enum.PartType.Ball
	local s = 0.12 + rng:NextNumber() * 0.34
	star.Size = Vector3.new(s, s, s)
	star.CFrame = ORIGIN * CFrame.new(-60 + rng:NextNumber() * 120, -20 + rng:NextNumber() * 60, -14 - rng:NextNumber() * 70)
	star.Color = i % 3 == 0 and BEIGE or (i % 5 == 0 and RED or PALE)
	star.Material = Enum.Material.Neon
	local baseTrans = 0.1 + rng:NextNumber() * 0.35
	star.Transparency = baseTrans
	star.Parent = scene
	table.insert(stars, {part = star, base = baseTrans, phase = rng:NextNumber() * math.pi * 2, speed = 1.2 + rng:NextNumber() * 2.2})
end

local centerDisc = Instance.new("Part")
centerDisc.Anchored = true
centerDisc.CanCollide = false
centerDisc.CanQuery = false
centerDisc.CastShadow = false
centerDisc.Shape = Enum.PartType.Cylinder
centerDisc.Size = Vector3.new(0.2, 6.6, 6.6)
centerDisc.CFrame = ORIGIN * CFrame.new(0, 8, -0.25) * CFrame.Angles(0, math.rad(90), 0)
centerDisc.Color = Color3.fromRGB(52, 26, 62)
centerDisc.Material = Enum.Material.Neon
centerDisc.Transparency = 0.35
centerDisc.Parent = scene

local centerAtt = Instance.new("Attachment")
centerAtt.Parent = centerDisc

local centerLight = Instance.new("PointLight")
centerLight.Color = CYAN
centerLight.Range = 26
centerLight.Brightness = 1.1
centerLight.Parent = centerDisc

local rise = Instance.new("ParticleEmitter")
rise.Texture = SPARKLE_TEX
rise.Color = ColorSequence.new(CYAN, DEEP)
rise.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.5), NumberSequenceKeypoint.new(1, 0)})
rise.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
rise.Rate = 7
rise.Speed = NumberRange.new(2, 5)
rise.Lifetime = NumberRange.new(1.6, 2.6)
rise.SpreadAngle = Vector2.new(35, 35)
rise.Acceleration = Vector3.new(0, 4, 0)
rise.LightEmission = 0.9
rise.LightInfluence = 0
rise.Parent = centerAtt

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "MainMenu"
menuGui.ResetOnSpawn = false
menuGui.IgnoreGuiInset = true
menuGui.DisplayOrder = 120
menuGui.Parent = playerGui

local uiGroup = Instance.new("CanvasGroup")
uiGroup.BackgroundTransparency = 1
uiGroup.Size = UDim2.fromScale(1, 1)
uiGroup.Parent = menuGui

local playHolder = Instance.new("Frame")
playHolder.BackgroundTransparency = 1
playHolder.AnchorPoint = Vector2.new(0.5, 0.5)
playHolder.Position = UDim2.fromScale(0.5, 0.5)
playHolder.Size = UDim2.fromOffset(240, 240)
playHolder.Parent = uiGroup

local playGlow = Instance.new("ImageLabel")
playGlow.AnchorPoint = Vector2.new(0.5, 0.5)
playGlow.Position = UDim2.fromScale(0.5, 0.5)
playGlow.Size = UDim2.fromOffset(300, 300)
playGlow.BackgroundTransparency = 1
playGlow.Image = "rbxasset://textures/ui/Animation/radial_glow.png"
playGlow.ImageColor3 = Color3.fromRGB(115, 45, 140)
playGlow.ImageTransparency = 0.55
playGlow.ZIndex = 3
playGlow.Parent = playHolder
TweenService:Create(playGlow, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.fromOffset(340, 340), ImageTransparency = 0.75}):Play()

local playBtn = Instance.new("TextButton")
playBtn.AnchorPoint = Vector2.new(0.5, 0.5)
playBtn.Position = UDim2.fromScale(0.5, 0.5)
playBtn.Size = UDim2.fromOffset(210, 100)
playBtn.BackgroundTransparency = 1
playBtn.AutoButtonColor = false
playBtn.Font = Enum.Font.Arcade
playBtn.Text = "PLAY"
playBtn.TextScaled = true
playBtn.TextColor3 = Color3.new(1, 1, 1)
playBtn.TextTransparency = 1
playBtn.ZIndex = 5
local playStroke = Instance.new("UIStroke")
playStroke.Color = Color3.new(1, 1, 1)
playStroke.Thickness = 3.5
playStroke.Transparency = 0.05
playStroke.Parent = playBtn
local playStrokeOuter = Instance.new("UIStroke")
playStrokeOuter.Color = Color3.new(1, 1, 1)
playStrokeOuter.Thickness = 6
playStrokeOuter.Transparency = 0.5
playStrokeOuter.Parent = playBtn
TweenService:Create(playStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.5}):Play()
TweenService:Create(playStrokeOuter, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.85}):Play()
playBtn.Parent = playHolder

local playLabel = Instance.new("TextLabel")
playLabel.AnchorPoint = Vector2.new(0.5, 0.5)
playLabel.Position = UDim2.fromScale(0.5, 0.5)
playLabel.Size = UDim2.fromScale(1, 1)
playLabel.BackgroundTransparency = 1
playLabel.Font = Enum.Font.Arcade
playLabel.Text = "PLAY"
playLabel.TextScaled = true
playLabel.TextColor3 = Color3.fromRGB(115, 50, 140)
playLabel.TextStrokeTransparency = 1
playLabel.ZIndex = 6
local playGrad = Instance.new("UIGradient")
playGrad.Color = ColorSequence.new(Color3.fromRGB(165, 85, 190), Color3.fromRGB(90, 35, 110))
playGrad.Rotation = 90
playGrad.Parent = playLabel
playLabel.Parent = playBtn

playBtn.MouseEnter:Connect(function()
	TweenService:Create(playLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(175, 95, 200)}):Play()
	TweenService:Create(playHolder, TweenInfo.new(0.15), {Size = UDim2.fromOffset(272, 272)}):Play()
end)
playBtn.MouseLeave:Connect(function()
	TweenService:Create(playLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(115, 50, 140)}):Play()
	TweenService:Create(playHolder, TweenInfo.new(0.15), {Size = UDim2.fromOffset(258, 258)}):Play()
end)

TweenService:Create(playHolder, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.fromOffset(258, 258)}):Play()

local topShade = Instance.new("Frame")
topShade.BackgroundColor3 = Color3.new(0, 0, 0)
topShade.BackgroundTransparency = 0.25
topShade.BorderSizePixel = 0
topShade.Size = UDim2.fromScale(1, 0.22)
local topGrad = Instance.new("UIGradient")
topGrad.Rotation = 90
topGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
topGrad.Parent = topShade
topShade.Parent = uiGroup

local botShade = Instance.new("Frame")
botShade.BackgroundColor3 = Color3.new(0, 0, 0)
botShade.BackgroundTransparency = 0.2
botShade.BorderSizePixel = 0
botShade.AnchorPoint = Vector2.new(0, 1)
botShade.Position = UDim2.fromScale(0, 1)
botShade.Size = UDim2.fromScale(1, 0.22)
local botGrad = Instance.new("UIGradient")
botGrad.Rotation = -90
botGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
botGrad.Parent = botShade
botShade.Parent = uiGroup

local titleHolder = Instance.new("Frame")
titleHolder.BackgroundTransparency = 1
titleHolder.AnchorPoint = Vector2.new(0.5, 0)
titleHolder.Position = UDim2.fromScale(0.5, 0.05)
titleHolder.Size = UDim2.fromScale(0.56, 0.16)
titleHolder.ZIndex = 5
titleHolder.Parent = uiGroup

local titleGlow = Instance.new("ImageLabel")
titleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
titleGlow.Position = UDim2.fromScale(0.5, 0.55)
titleGlow.Size = UDim2.fromScale(1.15, 2.4)
titleGlow.BackgroundTransparency = 1
titleGlow.Image = "rbxasset://textures/ui/Animation/radial_glow.png"
titleGlow.ImageColor3 = Color3.fromRGB(150, 80, 170)
titleGlow.ImageTransparency = 0.6
titleGlow.ZIndex = 4
titleGlow.Parent = titleHolder

local TITLE_TEXT = "TITLE RNG"
local TITLE_FONT = Enum.Font.Arcade
local titleLetters = {}
local titleOutlineLabels = {}
local titleBoxes = {}
local count = #TITLE_TEXT
for i = 1, count do
	local frac = (i - 0.5) / count
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(frac, 0.58 - math.sin(frac * math.pi) * 0.16)
	box.Size = UDim2.fromScale(1 / count, 0.72)
	box.Rotation = (frac - 0.5) * 18
	box.ZIndex = 6
	box.Parent = titleHolder
	local outlineLabel = Instance.new("TextLabel")
	outlineLabel.BackgroundTransparency = 1
	outlineLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	outlineLabel.Position = UDim2.fromScale(0.5, 0.5)
	outlineLabel.Size = UDim2.fromScale(1, 1)
	outlineLabel.Font = TITLE_FONT
	outlineLabel.Text = TITLE_TEXT:sub(i, i)
	outlineLabel.TextScaled = true
	outlineLabel.TextColor3 = Color3.new(1, 1, 1)
	outlineLabel.TextTransparency = 1
	outlineLabel.TextStrokeTransparency = 1
	outlineLabel.ZIndex = 6
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 3
	stroke.Transparency = 0
	stroke.Parent = outlineLabel
	local strokeOuter = Instance.new("UIStroke")
	strokeOuter.Color = Color3.new(1, 1, 1)
	strokeOuter.Thickness = 5.5
	strokeOuter.Transparency = 0.35
	strokeOuter.Parent = outlineLabel
	outlineLabel.Parent = box
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Size = UDim2.fromScale(1, 1)
	label.Font = TITLE_FONT
	label.Text = TITLE_TEXT:sub(i, i)
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(90, 30, 110)
	label.TextStrokeTransparency = 1
	label.ZIndex = 7
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.fromRGB(140, 60, 165), Color3.fromRGB(60, 15, 80))
	grad.Rotation = 90
	grad.Parent = label
	label.Parent = box
	titleLetters[i] = label
	titleOutlineLabels[i] = outlineLabel
	titleBoxes[i] = box
end

local burst1 = false
local burst2 = false

local function ringBurst(targetRadius, dur)
	local ring = Instance.new("Part")
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.CastShadow = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.25, 2, 2)
	ring.CFrame = ORIGIN * CFrame.new(0, 8, 0.35) * CFrame.Angles(0, math.rad(90), 0)
	ring.Color = BEIGE
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.15
	ring.Parent = scene
	TweenService:Create(ring, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.25, targetRadius * 2, targetRadius * 2),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ring, dur + 0.1)
end

local flash = Instance.new("Frame")
flash.BackgroundColor3 = Color3.fromRGB(238, 215, 245)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Size = UDim2.fromScale(1, 1)
flash.ZIndex = 50
flash.Parent = menuGui

local function finishMenu()
	if not menuActive then
		return
	end
	menuActive = false
	transitioning = false
	player:SetAttribute("InMenu", false)
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.Anchored = false
		local landRing = Instance.new("Part")
		landRing.Anchored = true
		landRing.CanCollide = false
		landRing.CanQuery = false
		landRing.CanTouch = false
		landRing.Shape = Enum.PartType.Cylinder
		landRing.Size = Vector3.new(0.2, 1.5, 1.5)
		landRing.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0) * CFrame.Angles(0, 0, math.rad(90))
		landRing.Color = CYAN
		landRing.Material = Enum.Material.Neon
		landRing.Transparency = 0.2
		landRing.Parent = workspace
		TweenService:Create(landRing, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.2, 16, 16),
			Transparency = 1,
		}):Play()
		Debris:AddItem(landRing, 0.9)
	end
	scene:Destroy()
	TweenService:Create(flash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
	task.delay(0.9, function()
		menuGui:Destroy()
	end)
end

local function spawnScreenSparkles(n, parent, fadeMult)
	fadeMult = fadeMult or 1
	for i = 1, n do
		local spark = Instance.new("ImageLabel")
		spark.BackgroundTransparency = 1
		spark.Image = SPARKLE_TEX
		spark.ImageColor3 = i % 3 == 0 and RED or (i % 2 == 0 and CYAN or PALE)
		spark.ImageTransparency = 0.15
		spark.AnchorPoint = Vector2.new(0.5, 0.5)
		spark.Position = UDim2.fromScale(rng:NextNumber(), rng:NextNumber())
		spark.Rotation = rng:NextNumber() * 360
		spark.Size = UDim2.fromOffset(0, 0)
		spark.ZIndex = 40
		spark.Parent = parent
		local targetSize = (12 + rng:NextNumber() * 26) * fadeMult
		TweenService:Create(spark, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(targetSize, targetSize), ImageTransparency = 0}):Play()
		task.delay(0.2 + rng:NextNumber() * 0.3, function()
			TweenService:Create(spark, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 1, Size = UDim2.fromOffset(targetSize * 1.5, targetSize * 1.5)}):Play()
		end)
		Debris:AddItem(spark, 1.6)
	end
end

playBtn.MouseButton1Click:Connect(function()
	if transitioning then
		return
	end
	transitioning = true
	transitionStart = os.clock()
	startCamCF = camera.CFrame
	local burst = rise:Clone()
	burst.Rate = 0
	burst.Speed = NumberRange.new(8, 16)
	burst.Parent = centerAtt
	burst:Emit(220)
	centerLight.Brightness = 6
	TweenService:Create(playBtn, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)}):Play()
	TweenService:Create(playGlow, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
	TweenService:Create(centerLight, TweenInfo.new(0.9), {Brightness = 6, Range = 40}):Play()
	TweenService:Create(centerDisc, TweenInfo.new(1.1), {Transparency = 0.05, Color = Color3.fromRGB(150, 80, 170)}):Play()
	TweenService:Create(glowPool, TweenInfo.new(0.9), {Transparency = 0.55}):Play()
	TweenService:Create(titleGlow, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
	for _, label in ipairs(titleLetters) do
		TweenService:Create(label, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	end
	for _, outlineLabel in ipairs(titleOutlineLabels) do
		for _, child in ipairs(outlineLabel:GetChildren()) do
			if child:IsA("UIStroke") then
				TweenService:Create(child, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
			end
		end
	end
	spawnScreenSparkles(60, menuGui)
	task.spawn(function()
		local elapsed = 0
		local span = 1.35
		while transitioning and elapsed < span do
			local fade = 1 - (elapsed / span)
			spawnScreenSparkles(math.max(1, math.floor(14 * fade)), menuGui, 0.4 + fade * 0.6)
			task.wait(0.12)
			elapsed = elapsed + 0.12
		end
	end)
	TweenService:Create(uiGroup, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {GroupTransparency = 1}):Play()
end)

task.spawn(function()
	while menuActive do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and not hrp.Anchored then
			hrp.Anchored = true
		end
		task.wait(0.4)
	end
end)

local conn
conn = RunService.RenderStepped:Connect(function(dt)
	if not menuActive then
		conn:Disconnect()
		return
	end
	local t = os.clock()
	for _, layer in ipairs(layers) do
		layer.ang = layer.ang + dt * layer.speed * speedMult
		local baseCF = ORIGIN * layer.base
		if layer.bob then
			baseCF = baseCF + Vector3.new(0, math.sin(t * 0.8) * 0.4, 0)
		end
		layer.model:SetPrimaryPartCFrame(baseCF * CFrame.Angles(0, layer.ang, 0))
	end
	centerLight.Brightness = transitioning and centerLight.Brightness or (1.1 + math.sin(t * 2.2) * 0.25)
	if not transitioning then
		centerDisc.Transparency = 0.35 + math.sin(t * 2.2) * 0.08
	end
	for _, s in ipairs(stars) do
		s.part.Transparency = s.base + math.sin(t * s.speed + s.phase) * 0.25
	end
	for _, f in ipairs(flames) do
		local n = math.noise(t * 5, f.seed)
		f.light.Brightness = (transitioning and 1.9 or 0.75) + n * 0.6
		f.part.Transparency = 0.05 + math.max(0, n) * 0.35
	end
	camera.CameraType = Enum.CameraType.Scriptable
	if transitioning then
		local alpha = math.min((t - transitionStart) / 1.35, 1)
		local e = alpha * alpha * (3 - 2 * alpha)
		speedMult = 1 + e * 14
		local lift = math.sin(math.min(alpha / 0.32, 1) * math.pi) * 6 * (1 - e)
		local targetCF = CFrame.lookAt((ORIGIN * CFrame.new(0, 8, 2.2)).Position, (ORIGIN * CFrame.new(0, 8, 0)).Position)
		camera.CFrame = startCamCF:Lerp(targetCF, e) + Vector3.new(0, lift, 0)
		camera.FieldOfView = 62 - math.sin(math.min(alpha / 0.32, 1) * math.pi) * 8 + e * 30
		if alpha > 0.4 and not burst1 then
			burst1 = true
			ringBurst(11, 0.6)
		end
		if alpha > 0.62 and not burst2 then
			burst2 = true
			ringBurst(17, 0.5)
		end
		if alpha >= 0.8 and not flashed then
			flashed = true
			TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
		end
		if alpha >= 1 then
			finishMenu()
		end
	else
		local p = (ORIGIN * CFrame.new(math.sin(t * 0.07) * 2.6, 8 + math.sin(t * 0.23) * 0.5, 26)).Position
		camera.CFrame = CFrame.lookAt(p, (ORIGIN * CFrame.new(0, 8, 0)).Position)
		camera.FieldOfView = 56 + math.sin(t * 0.17) * 1.5
	end
end)
