-- ============================================================
-- POTENT HUB - MULTI GAME HUB (WindUI v2.1 Edition)
-- 1. Speed Monkey Escape (114697347887839 / 72858062353423)
-- 2. BloxSpin (104715542330896)
-- 3. Murder Mystery 2 (142823291)
-- 4. Kitten Farm (77813828595591)
-- 5. Speed Keyboard Escape (118941584817777 / 93411036959889)
-- 6. One Tap (90568084448279)
-- ============================================================

-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- Services.
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local workspaceService = game:GetService("Workspace")
local collectionService = game:GetService("CollectionService")
local virtualUser = game:GetService("VirtualUser")
local virtualInputManager = game:GetService("VirtualInputManager")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local guiService = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local debris = game:GetService("Debris")

-- Compatibility Layer.
local customRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local customGetHui = gethui or function() return coreGui end
local customSetClipboard = setclipboard or toclipboard or function(...) end
local customFireTouch = firetouchinterest or function() end
local customFireProximity = fireproximityprompt or function() end

local function customHttpGet(url)
	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and res and res ~= "" then
		return res
	end

	if customRequest then
		local response = customRequest({ Url = url, Method = "GET" })
		if response and response.Body then return response.Body end
	end
	return ""
end

local function customHttpPost(url, body, contentType)
	if customRequest then
		return customRequest({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = contentType or "application/json" },
			Body = body,
		})
	end
	return nil
end

-- Constants.
local SUPPORTED_PLACES = {
	[114697347887839] = true,
	[72858062353423]  = true,
	[104715542330896] = true,
	[142823291]       = true,
	[77813828595591]  = true,
	[118941584817777] = true,
	[93411036959889]  = true,
	[90568084448279]  = true,
}

local ONETAP_PLACE_ID = 90568084448279
local BLOXSPIN_PLACE_ID = 104715542330896

local KEY_FILE = "potent_key.txt"
local KEY_DURATION = 24 * 60 * 60
local DISCORD_URL = "https://discord.gg/X7Y4NzuC67"
local VALID_KEY = "POTENTHUB372635263526"

local Palette = {
	Gold   = Color3.fromRGB(255, 200, 50),
	Purple = Color3.fromRGB(168, 85, 247),
	Blue   = Color3.fromRGB(59, 130, 246),
	Dark   = Color3.fromRGB(14, 14, 18),
}

local BrandGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Palette.Gold),
	ColorSequenceKeypoint.new(0.5, Palette.Purple),
	ColorSequenceKeypoint.new(1.0, Palette.Blue),
})

local BACKGROUND_ID = "72427773287138"
local LOGO_ID = "117299981730743"

-- State.
local animGradients = {}
local visualApplied = false

-- ============================================================
-- ========== UI UTILITIES ==========
-- ============================================================
local function spinGradient(gradient, speed)
	table.insert(animGradients, { g = gradient, s = speed or 40 })
end

runService.RenderStepped:Connect(function(dt)
	for i = #animGradients, 1, -1 do
		local element = animGradients[i]
		if element.g and element.g.Parent then
			element.g.Rotation = (element.g.Rotation + element.s * dt) % 360
		else
			table.remove(animGradients, i)
		end
	end
end)

local function getGuiContainer()
	local ok, target = pcall(customGetHui)
	if ok and target then return target end
	local localPlayer = playersService.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	if playerGui then return playerGui end
	return coreGui
end

local function findHubGui()
	local pools = {}
	pcall(function() table.insert(pools, customGetHui()) end)
	pcall(function() table.insert(pools, coreGui) end)
	local localPlayer = playersService.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")
	if playerGui then table.insert(pools, playerGui) end

	for _, pool in ipairs(pools) do
		for _, gui in ipairs(pool:GetChildren()) do
			if gui:IsA("ScreenGui") then
				local guiName = gui.Name
				if guiName:find("WindUI") or guiName:find("POTENTHUB") or guiName:find("Footagesus") then
					return gui
				end
			end
		end
	end
end

local function findBackground(gui)
	for _, desc in ipairs(gui:GetDescendants()) do
		if desc:IsA("ImageLabel") and tostring(desc.Image):find(BACKGROUND_ID) then
			return desc
		end
	end
end

local function removeStrokes(root)
	if not root then return end
	for _, desc in ipairs(root:GetDescendants()) do
		if desc:IsA("UIStroke") then
			local parent = desc.Parent
			if parent and not parent.Name:find("Open") and not parent.Name:find("Float") then
				pcall(function() desc:Destroy() end)
			end
		elseif desc:IsA("Frame") and desc.Name:find("Outline") then
			pcall(function() desc:Destroy() end)
		elseif desc:IsA("ImageLabel") and (desc.Name:find("Outline") or desc.Name:find("Border")) then
			pcall(function() desc.Visible = false end)
		end
	end
end

local function applyVisuals()
	if visualApplied then return end
	local gui = findHubGui()
	if not gui then return end
	local bg = findBackground(gui)
	if not bg then return end
	visualApplied = true

	bg.ImageColor3 = Color3.fromRGB(120, 120, 140)
	bg.ImageTransparency = 0.35
	bg.ZIndex = 0

	local oldOverlay = bg:FindFirstChild("PotentDarkOverlay")
	if oldOverlay then oldOverlay:Destroy() end

	local overlay = Instance.new("Frame")
	overlay.Name = "PotentDarkOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 0
	overlay.Parent = bg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = overlay

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 0.35),
		NumberSequenceKeypoint.new(1.0, 0.05),
	})
	gradient.Rotation = 90
	gradient.Parent = overlay

	tweenService:Create(overlay, TweenInfo.new(0.6), { BackgroundTransparency = 0.25 }):Play()

	local container = bg.Parent or bg
	for _, desc in ipairs(container:GetDescendants()) do
		if desc ~= overlay and desc:IsA("GuiObject") and desc.ZIndex < 2 then
			pcall(function() desc.ZIndex = 2 end)
		end
	end

	container.DescendantAdded:Connect(function(desc)
		if desc:IsA("GuiObject") and desc ~= overlay and not desc:IsDescendantOf(overlay) then
			task.defer(function()
				if desc.Parent and desc.ZIndex < 2 then
					pcall(function() desc.ZIndex = 2 end)
				end
			end)
		end
	end)

	task.defer(function()
		removeStrokes(container)
	end)
end

local function setupMinimizeAnimation()
	local gui = findHubGui()
	if not gui then return end
	local bg = findBackground(gui)
	if not bg then return end
	local container = bg.Parent or bg
	if not container or not container:IsA("GuiObject") then return end

	local minimizeBtn = nil
	for _, desc in ipairs(container:GetDescendants()) do
		if desc:IsA("TextButton") or desc:IsA("ImageButton") then
			local txt = (desc:IsA("TextButton") and desc.Text) or ""
			local name = desc.Name:lower()
			if txt == "–" or txt == "-" or txt == "—" or name:find("minimize") or name:find("min") then
				minimizeBtn = desc
				break
			end
		end
	end

	local openBtn = nil
	for _, desc in ipairs(gui:GetDescendants()) do
		if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and desc.Name:find("Open") then
			openBtn = desc
			break
		end
	end

	local origPos = container.Position
	local origSize = container.Size

	local function minimize()
		local targetPos = UDim2.new(origPos.X.Scale, origPos.X.Offset, origPos.Y.Scale, origPos.Y.Offset + 40)
		tweenService:Create(container, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 60, 0, 60),
			Position = targetPos,
			BackgroundTransparency = 0.3,
		}):Play()
		task.wait(0.4)
		tweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 0, 0),
		}):Play()
		task.wait(0.3)
		container.Visible = false
	end

	local function restore()
		container.Visible = true
		container.Size = UDim2.new(0, 60, 0, 60)
		container.Position = origPos
		container.BackgroundTransparency = 0
		tweenService:Create(container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 100, 0, 100),
		}):Play()
		task.wait(0.15)
		tweenService:Create(container, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = origSize,
			Position = origPos,
		}):Play()
	end

	if minimizeBtn then
		pcall(function()
			minimizeBtn.MouseButton1Click:Connect(function() minimize() end)
		end)
	end

	if openBtn then
		pcall(function()
			openBtn.MouseButton1Click:Connect(function()
				task.wait(0.05)
				restore()
			end)
		end)
	end
end

local function getWindUILibrary()
	local rawCode = customHttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
	if rawCode == "" then
		rawCode = customHttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
	end
	local windUI = loadstring(rawCode)()

	pcall(function()
		windUI:AddTheme({
			Name        = "PotentGold",
			Accent      = Palette.Gold,
			Outline     = Color3.fromRGB(255, 180, 40),
			Text        = Color3.fromRGB(255, 255, 255),
			Placeholder = Color3.fromRGB(175, 175, 190),
			Background  = Palette.Dark,
			Button      = Color3.fromRGB(32, 32, 40),
			Icon        = Color3.fromRGB(255, 205, 70),
		})
		windUI:SetTheme("PotentGold")
	end)

	return windUI
end

local function createPotentWindow(windUI, folder, gameName)
	visualApplied = false

	local window = windUI:CreateWindow({
		Title = "⚡ POTENT HUB",
		Icon = "rbxassetid://" .. LOGO_ID,
		Author = gameName or "👑 MADE BY POTENT HUB",
		Folder = folder,
		Background = "rbxassetid://" .. BACKGROUND_ID,
		Size = UDim2.fromOffset(640, 490),
		MinSize = Vector2.new(440, 340),
		Resizable = true,
		Transparent = false,
		Theme = "PotentGold",
		User = { Enabled = true, Anonymous = false },
		OpenButton = {
			Title = "POTENT HUB",
			Icon = "rbxassetid://" .. LOGO_ID,
			CornerRadius = UDim.new(0, 16),
			StrokeThickness = 2,
			Color = BrandGradient,
			OnlyMobile = false,
			Enabled = true,
			Draggable = true,
		},
	})

	pcall(function()
		window:Tag({ Title = "v2.1", Icon = "terminal", Color = Palette.Gold })
	end)

	task.spawn(function()
		for _ = 1, 20 do
			pcall(applyVisuals)
			if visualApplied then
				task.wait(0.3)
				pcall(setupMinimizeAnimation)
				pcall(removeStrokes, findHubGui())
				break
			end
			task.wait(0.2)
		end
	end)

	task.spawn(function()
		task.wait(1)
		pcall(function()
			local gui = findHubGui()
			if not gui then return end
			for _, desc in ipairs(gui:GetDescendants()) do
				if desc:IsA("UIStroke") then
					local grad = desc:FindFirstChildOfClass("UIGradient")
					if grad then spinGradient(grad, 70) end
				end
			end
		end)
	end)

	return window
end

-- ============================================================
-- ========== UNSUPPORTED SCREEN ==========
-- ============================================================
local function showUnsupportedScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PotentUnsupported"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 9999
	screenGui.IgnoreGuiInset = true

	local ok = pcall(function() screenGui.Parent = getGuiContainer() end)
	if not ok then screenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui") end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BorderSizePixel = 0
	bg.ZIndex = 1
	bg.Parent = screenGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 520, 0, 320)
	main.Position = UDim2.new(0.5, -260, 0.5, -160)
	main.BackgroundTransparency = 1
	main.ZIndex = 2
	main.Parent = screenGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -40, 0, 140)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "THIS GAME IS NOT COMPATIBLE\nIF YOU WANT TO KNOW WHICH GAMES IT SUPPORTS, JOIN THE DISCORD SERVER"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 22
	label.TextWrapped = true
	label.ZIndex = 3
	label.Parent = main

	local supportLabel = Instance.new("TextLabel")
	supportLabel.Size = UDim2.new(1, -40, 0, 60)
	supportLabel.Position = UDim2.new(0, 20, 0, 145)
	supportLabel.BackgroundTransparency = 1
	supportLabel.Text = "🟢 Support:\nSpeed Monkey Escape, BloxSpin, Murder Mystery 2, Kitten Farm, Speed Keyboard Escape, One Tap"
	supportLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
	supportLabel.Font = Enum.Font.GothamBold
	supportLabel.TextSize = 13
	supportLabel.TextWrapped = true
	supportLabel.ZIndex = 3
	supportLabel.Parent = main

	local discordBtn = Instance.new("TextButton")
	discordBtn.Size = UDim2.new(0, 320, 0, 50)
	discordBtn.Position = UDim2.new(0.5, -160, 0, 215)
	discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordBtn.BorderSizePixel = 0
	discordBtn.Text = "💬 JOIN DISCORD FOR FREE KEY"
	discordBtn.TextColor3 = Color3.new(1, 1, 1)
	discordBtn.Font = Enum.Font.GothamBold
	discordBtn.TextSize = 14
	discordBtn.AutoButtonColor = false
	discordBtn.ZIndex = 3
	discordBtn.Parent = main

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = discordBtn

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -40, 0, 20)
	status.Position = UDim2.new(0, 20, 0, 275)
	status.BackgroundTransparency = 1
	status.Text = ""
	status.TextColor3 = Color3.fromRGB(0, 200, 100)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 12
	status.ZIndex = 3
	status.Parent = main

	discordBtn.MouseButton1Click:Connect(function()
		customSetClipboard(DISCORD_URL)
		status.Text = "✅ DISCORD LINK COPIED!"
		task.delay(5, function() if status and status.Parent then status.Text = "" end end)
	end)

	task.delay(15, function() if screenGui and screenGui.Parent then screenGui:Destroy() end end)
	return screenGui
end

-- ============================================================
-- ========== KEY SYSTEM ==========
-- ============================================================
local function isKeyValidLocally()
	if not isfile or not readfile or not isfile(KEY_FILE) then return false end
	local success, content = pcall(readfile, KEY_FILE)
	if not success or not content or content == "" then return false end
	local parts = string.split(content, "|")
	if #parts < 2 then return false end
	local savedKey = parts[1]
	local timestamp = tonumber(parts[2])
	if not timestamp then return false end
	if savedKey ~= VALID_KEY then return false end
	return (os.time() - timestamp) < KEY_DURATION
end

local function saveKey(key)
	if not writefile then return end
	pcall(writefile, KEY_FILE, key .. "|" .. tostring(os.time()))
end

local function isValidKey(key) return key == VALID_KEY end

local function showKeySystem(onSuccess)
	local Theme = {
		Background  = Color3.fromRGB(20, 20, 25),
		Border      = Color3.fromRGB(45, 45, 55),
		Accent      = Color3.fromRGB(88, 101, 242),
		AccentHover = Color3.fromRGB(114, 137, 218),
		Text        = Color3.fromRGB(240, 240, 245),
		TextDim     = Color3.fromRGB(150, 150, 160),
		InputBg     = Color3.fromRGB(30, 30, 38),
		Success     = Color3.fromRGB(0, 200, 100),
		Error       = Color3.fromRGB(220, 50, 50),
	}

	local function addCorner(i, r)
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, r)
		c.Parent = i
	end

	local function addStroke(i, color, t)
		local s = Instance.new("UIStroke")
		s.Color = color
		s.Thickness = t or 1.5
		s.Parent = i
		return s
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PotentKeySystem"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.IgnoreGuiInset = true

	local ok = pcall(function() screenGui.Parent = getGuiContainer() end)
	if not ok then screenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui") end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BackgroundTransparency = 0.5
	bg.BorderSizePixel = 0
	bg.ZIndex = 1
	bg.Parent = screenGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 380, 0, 260)
	main.Position = UDim2.new(0.5, -190, 0.5, -130)
	main.BackgroundColor3 = Theme.Background
	main.BorderSizePixel = 0
	main.ZIndex = 2
	main.Parent = screenGui
	addCorner(main, 12)
	addStroke(main, Theme.Border, 1.5)
	main.Size = UDim2.new(0, 0, 0, 0)
	tweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Size = UDim2.new(0, 380, 0, 260) }):Play()

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 0, 45)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "⚡ POTENT HUB"
	title.TextColor3 = Theme.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 3
	title.Parent = main

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -40, 0, 8)
	close.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	close.Text = "✕"
	close.TextColor3 = Theme.Text
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.AutoButtonColor = false
	close.ZIndex = 3
	close.Parent = main
	addCorner(close, 6)
	close.MouseButton1Click:Connect(function() screenGui:Destroy() end)

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.Position = UDim2.new(0, 20, 0, 45)
	divider.BackgroundColor3 = Theme.Border
	divider.BorderSizePixel = 0
	divider.ZIndex = 3
	divider.Parent = main

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -40, 0, 45)
	sub.Position = UDim2.new(0, 20, 0, 55)
	sub.BackgroundTransparency = 1
	sub.Text = "Join our Discord server to get your FREE key!\nKey expires after 24 hours."
	sub.TextColor3 = Theme.TextDim
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 12
	sub.TextWrapped = true
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 3
	sub.Parent = main

	local discordBtn = Instance.new("TextButton")
	discordBtn.Size = UDim2.new(1, -40, 0, 45)
	discordBtn.Position = UDim2.new(0, 20, 0, 105)
	discordBtn.BackgroundColor3 = Theme.Accent
	discordBtn.BorderSizePixel = 0
	discordBtn.Text = "💬 JOIN DISCORD FOR FREE KEY"
	discordBtn.TextColor3 = Color3.new(1, 1, 1)
	discordBtn.Font = Enum.Font.GothamBold
	discordBtn.TextSize = 13
	discordBtn.AutoButtonColor = false
	discordBtn.ZIndex = 3
	discordBtn.Parent = main
	addCorner(discordBtn, 8)

	discordBtn.MouseEnter:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.AccentHover }):Play()
	end)
	discordBtn.MouseLeave:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Accent }):Play()
	end)

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Size = UDim2.new(1, -40, 0, 20)
	keyLabel.Position = UDim2.new(0, 20, 0, 160)
	keyLabel.BackgroundTransparency = 1
	keyLabel.Text = "Paste your key from Discord below:"
	keyLabel.TextColor3 = Theme.TextDim
	keyLabel.Font = Enum.Font.Gotham
	keyLabel.TextSize = 11
	keyLabel.TextXAlignment = Enum.TextXAlignment.Left
	keyLabel.ZIndex = 3
	keyLabel.Parent = main

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(1, -40, 0, 38)
	input.Position = UDim2.new(0, 20, 0, 180)
	input.BackgroundColor3 = Theme.InputBg
	input.BorderSizePixel = 0
	input.Text = ""
	input.PlaceholderText = "POTENTHUB..."
	input.TextColor3 = Theme.Text
	input.PlaceholderColor3 = Theme.TextDim
	input.Font = Enum.Font.Gotham
	input.TextSize = 12
	input.ClearTextOnFocus = false
	input.ZIndex = 3
	input.Parent = main
	addCorner(input, 8)
	local inputStroke = addStroke(input, Theme.Border, 1.5)

	input.Focused:Connect(function()
		tweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = Theme.Accent }):Play()
	end)
	input.FocusLost:Connect(function()
		tweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = Theme.Border }):Play()
	end)

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -40, 0, 20)
	status.Position = UDim2.new(0, 20, 0, 222)
	status.BackgroundTransparency = 1
	status.Text = ""
	status.TextColor3 = Theme.Error
	status.Font = Enum.Font.GothamBold
	status.TextSize = 11
	status.ZIndex = 3
	status.Parent = main

	discordBtn.MouseButton1Click:Connect(function()
		customSetClipboard(DISCORD_URL)
		status.Text = "✅ Discord link copied!"
		status.TextColor3 = Theme.Success
		task.delay(5, function() if status and status.Parent then status.Text = "" end end)
	end)

	local function onVerify()
		local userKey = input.Text
		if not userKey or userKey == "" then
			status.Text = "❌ Please enter a key first!"
			status.TextColor3 = Theme.Error
			return
		end
		if not isValidKey(userKey) then
			status.Text = "❌ Invalid key!"
			status.TextColor3 = Theme.Error
			return
		end
		status.Text = "⏳ Validating..."
		status.TextColor3 = Theme.TextDim
		task.wait(0.4)
		status.Text = "✅ Key valid! Loading..."
		status.TextColor3 = Theme.Success
		saveKey(userKey)
		task.wait(0.4)
		tweenService:Create(main, TweenInfo.new(0.3), { Size = UDim2.new(0, 0, 0, 0) }):Play()
		task.wait(0.35)
		screenGui:Destroy()
		if onSuccess then onSuccess() end
	end

	input.FocusLost:Connect(function(enter) if enter then onVerify() end end)
end

-- ============================================================
-- ========== JUEGO 1: SPEED MONKEY ESCAPE ==========
-- ============================================================
local function runSpeedMonkeyEscape()
	local Remotes = replicatedStorage:WaitForChild("Remotes", 10)
	local LocalPlayer = playersService.LocalPlayer
	local Data = LocalPlayer:WaitForChild("Data", 10)
	local GameName = "+1 Speed Monkey Escape"
	pcall(function() GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)

	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_SPEED_MONKEY", GameName)

	local UpgradesCfg = {
		{WinsRequirement=0, Multi=1, Skin="Basic"},
		{Multi=2, Skin="Grey", WinsRequirement=3},
		{Multi=4, Skin="Tiger", WinsRequirement=15},
		{Multi=8, Skin="Curly", WinsRequirement=100},
		{Multi=16, Skin="Rainbow", WinsRequirement=500},
		{Multi=32, Skin="Golden", WinsRequirement=2500},
		{Multi=64, Skin="Magma", WinsRequirement=15000},
		{Multi=128, Skin="Frozen", WinsRequirement=50000},
		{Multi=256, Skin="Devil", WinsRequirement=250000},
		{Multi=512, Skin="Night", WinsRequirement=1000000},
		{Multi=1000, Skin="Inferno", WinsRequirement=1000000},
		{Multi=2000, Skin="Verdant", WinsRequirement=5000000},
		{Multi=4000, Skin="Abyss", WinsRequirement=25000000},
		{Multi=8000, Skin="Arcane", WinsRequirement=100000000},
		{Multi=16000, Skin="Divine", WinsRequirement=500000000},
		{Multi=32000, Skin="Crimson", WinsRequirement=3000000000},
	}
	local TreadmillCfg = {Multis = {Reward=1.5, Golden=3, Diamond=9, Galaxy=25, Emerald=100, Void=100, Celestial=1000, Sunken=2, Quantum=10, Basic=1}}
	local TeleportPositions = {
		World1 = {Normal = Vector3.new(-9458.70, 389.70, -256.30), VIP = Vector3.new(-9457.38, 388.69, -187.92)},
		World2 = {Normal = Vector3.new(-3607.87, 155.87, -9375.29), VIP = Vector3.new(-3672.35, 154.64, -9382.89)},
		World3 = {Normal = Vector3.new(-8080.83, 283.18, 2741.99), VIP = Vector3.new(-8102.40, 281.96, 2741.95)},
		World4 = {Normal = Vector3.new(-7759.89, 21.91, 5741.03), VIP = Vector3.new(-7778.27, 19.57, 5740.98)},
		World5 = {Normal = Vector3.new(-7599.19, 287.17, 8359.99), VIP = Vector3.new(-7616.64, 286.82, 8360.72)},
	}
	local Loops = {}
	local ActiveFarmWins = {}
	local function safeFire(remote, ...)
		if not remote then return false end
		local ok, err
		local cn = remote.ClassName
		if cn == "RemoteEvent" then ok, err = pcall(function(...) remote:FireServer(...) end, ...)
		elseif cn == "RemoteFunction" then ok, err = pcall(function(...) return remote:InvokeServer(...) end, ...)
		else ok, err = pcall(function(...) remote:FireServer(...) end, ...) end
		return ok
	end
	local function runLoop(id, isActive, fn, interval)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
		Loops[id] = task.spawn(function()
			while isActive() do
				pcall(fn)
				task.wait(interval or 0.5)
			end
			Loops[id] = nil
		end)
	end
	local function stopLoop(id) if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end end
	local function isTreadmillUnlocked(ttype)
		if not Data then return false end
		if ttype == "Sunken" then
			local s = Data:FindFirstChild("CollectedShards")
			if not s or #s:GetChildren() < 9 then return false end
		end
		if ttype == "Quantum" then return false end
		local paidList = {Golden=true, Diamond=true, Galaxy=true, Void=true, Celestial=true}
		if not paidList[ttype] then return true end
		local passes = Data:FindFirstChild("Passes")
		return passes and passes:FindFirstChild(ttype) ~= nil
	end
	local function getTreadmillPart(preferred)
		local best, bestMulti = nil, -1
		for _, part in collectionService:GetTagged("Treadmill") do
			if part:IsA("BasePart") and part:IsDescendantOf(workspaceService) then
				local ttype = part:GetAttribute("Type") or part.Name
				if not isTreadmillUnlocked(ttype) then continue end
				local multi = TreadmillCfg.Multis[ttype] or 0
				if preferred and ttype:lower() == preferred:lower() then return part end
				if not preferred and multi > bestMulti then bestMulti = multi best = part end
			end
		end
		if best then return best end
		for _, part in collectionService:GetTagged("Treadmill") do
			if part:IsA("BasePart") and part:IsDescendantOf(workspaceService) then
				local ttype = part:GetAttribute("Type") or part.Name
				if isTreadmillUnlocked(ttype) then return part end
			end
		end
		return nil
	end
	local function getBestAffordableLocked()
		if not Data then return nil end
		local BN = nil
		pcall(function() BN = require(replicatedStorage.Util.BigNum) end)
		if not BN then BN = {GreaterEqual = function(a, b) return (a and a.Value or 0) >= b end} end
		local best, bestReq = nil, -1
		local unlocked = Data:FindFirstChild("UnlockedUpgrades")
		local wins = Data:FindFirstChild("Wins")
		for idx, cfg in ipairs(UpgradesCfg) do
			local req = cfg and cfg.WinsRequirement
			if cfg and unlocked and not unlocked:FindFirstChild(tostring(idx)) and req then
				local affordable = false
				if BN.GreaterEqual and wins then affordable = BN.GreaterEqual(wins, req)
				else affordable = (wins and wins.Value or 0) >= req end
				if affordable and req > bestReq then bestReq = req best = idx end
			end
		end
		return best
	end
	local function getBestOwned()
		local maxIdx = 1
		local unlocked = Data and Data:FindFirstChild("UnlockedUpgrades")
		if unlocked then
			for _, v in unlocked:GetChildren() do
				local n = tonumber(v.Name)
				if n and n > maxIdx then maxIdx = n end
			end
		end
		return maxIdx
	end
	local function farmWinsFluid(id, isActive, pos, brickName)
		if Loops[id] then Loops[id]:Disconnect() Loops[id] = nil end
		local cachedButton, lastButtonSearch = nil, 0
		local function findButton()
			local now = tick()
			if cachedButton and cachedButton.Parent and (now - lastButtonSearch) < 5 then return cachedButton end
			lastButtonSearch = now
			local bestPart, bestDist = nil, 80
			for _, v in workspaceService:GetDescendants() do
				if v:IsA("BasePart") and v.Name == "Button" then
					local bc = v.BrickColor.Name
					if bc == brickName or (brickName == "Really Red" and (bc == "Really Red" or bc == "Bright red")) then
						local d = (v.Position - pos).Magnitude
						if d < bestDist then bestDist = d bestPart = v end
					end
				end
			end
			cachedButton = bestPart
			return bestPart
		end
		ActiveFarmWins[id] = true
		local time, renderConn = 0, nil
		renderConn = runService.RenderStepped:Connect(function(dt)
			if not isActive() then
				renderConn:Disconnect()
				ActiveFarmWins[id] = nil
				Loops[id] = nil
				return
			end
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			time = time + dt * 15
			local bounce = math.abs(math.sin(time)) * 6
			hrp.CFrame = CFrame.new(pos + Vector3.new(0, bounce, 0))
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			local button = findButton()
			if button then pcall(function() customFireTouch(hrp, button, 0) customFireTouch(hrp, button, 1) end) end
		end)
		Loops[id] = { Disconnect = function() if renderConn then renderConn:Disconnect() end ActiveFarmWins[id] = nil end }
	end
	local AntiAFKConn
	local function setAntiAFK(state)
		if state then
			if AntiAFKConn then AntiAFKConn:Disconnect() end
			AntiAFKConn = LocalPlayer.Idled:Connect(function()
				virtualUser:Button2Down(Vector2.new(0,0), workspaceService.CurrentCamera.CFrame)
				task.wait(1)
				virtualUser:Button2Up(Vector2.new(0,0), workspaceService.CurrentCamera.CFrame)
			end)
		elseif AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
	end
	task.spawn(function()
		while true do
			task.wait(1)
			local hasActiveFarm = false
			for _ in pairs(ActiveFarmWins) do hasActiveFarm = true break end
			for _, obj in workspaceService:GetDescendants() do
				if obj:IsA("SpawnLocation") then
					if hasActiveFarm then if obj.Enabled then obj.Enabled = false end
					elseif not obj.Enabled then obj.Enabled = true end
				end
			end
		end
	end)

	local mainTab = window:Tab({ Title = "🏠 Main", Icon = "house" })
	local farmingTab = window:Tab({ Title = "🚜 Farming", Icon = "tractor" })
	local inventoryTab = window:Tab({ Title = "🎒 Inventory", Icon = "backpack" })
	local rebirthTab = window:Tab({ Title = "🔄 Rebirth", Icon = "refresh-cw" })
	local settingsTab = window:Tab({ Title = "⚙️ Settings", Icon = "settings" })

	mainTab:Section({ Title = "ℹ️ Info" })
	mainTab:Paragraph({ Title = "Game", Desc = GameName })
	mainTab:Paragraph({ Title = "PlaceId", Desc = tostring(game.PlaceId) })
	mainTab:Button({
		Title = "📋 Copy Game Name",
		Callback = function()
			customSetClipboard(GameName)
			WindUI:Notify({Title = "Copied!", Content = GameName, Duration = 3})
		end
	})

	farmingTab:Section({ Title = "🏃 Train" })
	local selectedTreadmill = "Basic"
	farmingTab:Dropdown({
		Title = "Manual Treadmill",
		Values = {"Basic","Golden","Diamond","Galaxy","Void","Celestial","Sunken","Quantum","Reward","Emerald"},
		Value = "Basic",
		Callback = function(value) selectedTreadmill = value end
	})
	local autoTrainEnabled = false
	farmingTab:Toggle({
		Title = "Auto Train on Treadmill", Value = false,
		Callback = function(state)
			autoTrainEnabled = state
			if state then
				runLoop("AutoTrain", function() return autoTrainEnabled end, function()
					local part = getTreadmillPart(selectedTreadmill)
					if not part then return end
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then return end
					pcall(function() customFireTouch(hrp, part, 0) end)
					hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
					task.wait(0.15)
					pcall(function() customFireTouch(hrp, part, 1) end)
				end, 5)
			else stopLoop("AutoTrain") end
		end
	})

	farmingTab:Section({ Title = "🪙 Wins" })
	local worlds = {"World1", "World2", "World3", "World4", "World5"}
	for _, world in ipairs(worlds) do
		local normalActive = false
		local normalId = "AutoWins_" .. world
		farmingTab:Toggle({
			Title = world:gsub("World", "WORLD ") .. " - Normal", Value = false,
			Callback = function(state)
				normalActive = state
				if state then farmWinsFluid(normalId, function() return normalActive end, TeleportPositions[world].Normal, "New Yeller")
				elseif Loops[normalId] and type(Loops[normalId]) == "table" then Loops[normalId]:Disconnect() Loops[normalId] = nil
				else stopLoop(normalId) end
			end
		})
		local vipActive = false
		local vipId = "AutoFarmVip_" .. world
		farmingTab:Toggle({
			Title = world:gsub("World", "WORLD ") .. " - Farm Win VIP", Value = false,
			Callback = function(state)
				vipActive = state
				if state then farmWinsFluid(vipId, function() return vipActive end, TeleportPositions[world].VIP, "Really Red")
				elseif Loops[vipId] and type(Loops[vipId]) == "table" then Loops[vipId]:Disconnect() Loops[vipId] = nil
				else stopLoop(vipId) end
			end
		})
	end

	farmingTab:Section({ Title = "🪙 Wins Chapter2" })
	local normalActiveCh2 = false
	local normalIdCh2 = "AutoWinsCh2_World1"
	local Ch2NormalPos = Vector3.new(-3548.34, 112.44, -255.17)
	farmingTab:Toggle({
		Title = "WORLD 1 - Normal", Value = false,
		Callback = function(state)
			normalActiveCh2 = state
			if state then farmWinsFluid(normalIdCh2, function() return normalActiveCh2 end, Ch2NormalPos, "New Yeller")
			elseif Loops[normalIdCh2] and type(Loops[normalIdCh2]) == "table" then Loops[normalIdCh2]:Disconnect() Loops[normalIdCh2] = nil
			else stopLoop(normalIdCh2) end
		end
	})
	local vipActiveCh2 = false
	local vipIdCh2 = "AutoFarmVipCh2_World1"
	local Ch2VipPos = Vector3.new(-3566.30, 112.68, -254.38)
	farmingTab:Toggle({
		Title = "WORLD 1 - Farm Win VIP", Value = false,
		Callback = function(state)
			vipActiveCh2 = state
			if state then farmWinsFluid(vipIdCh2, function() return vipActiveCh2 end, Ch2VipPos, "Really Red")
			elseif Loops[vipIdCh2] and type(Loops[vipIdCh2]) == "table" then Loops[vipIdCh2]:Disconnect() Loops[vipIdCh2] = nil
			else stopLoop(vipIdCh2) end
		end
	})

	farmingTab:Section({ Title = "🍌 Collecting" })
	local autoBananas = false
	farmingTab:Toggle({
		Title = "Auto Collect Bananas", Value = false,
		Callback = function(state)
			autoBananas = state
			if state then
				runLoop("AutoCollectBananas", function() return autoBananas end, function()
					for _, v in workspaceService:GetDescendants() do
						if v.Name:lower():find("banana") and v:IsA("BasePart") and LocalPlayer.Character then
							local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then pcall(function() customFireTouch(hrp, v, 0) task.wait(0.05) customFireTouch(hrp, v, 1) end) end
						end
					end
					for _, p in workspaceService:GetDescendants() do
						if p:IsA("ProximityPrompt") and p.ObjectText:lower():find("banana") then
							pcall(function() customFireProximity(p) end)
						end
					end
				end, 0.5)
			else stopLoop("AutoCollectBananas") end
		end
	})
	local autoShards = false
	farmingTab:Toggle({
		Title = "Auto Collect Sunken Shards", Value = false,
		Callback = function(state)
			autoShards = state
			if state then
				runLoop("AutoCollectShards", function() return autoShards end, function()
					for i = 1, 9 do
						if Remotes and Remotes:FindFirstChild("CollectShard") then safeFire(Remotes.CollectShard, "Shard" .. i) end
					end
				end, 0.8)
			else stopLoop("AutoCollectShards") end
		end
	})

	farmingTab:Section({ Title = "🎁 Rewards" })
	local autoClaimFree = false
	farmingTab:Toggle({
		Title = "Auto Claim Free Reward", Value = false,
		Callback = function(state)
			autoClaimFree = state
			if state then runLoop("AutoClaimFreeReward", function() return autoClaimFree end, function()
				if Remotes and Remotes:FindFirstChild("ClaimFreeReward") then safeFire(Remotes.ClaimFreeReward) end
			end, 5) else stopLoop("AutoClaimFreeReward") end
		end
	})
	local autoClaimStreak = false
	farmingTab:Toggle({
		Title = "Auto Claim Streak Reward", Value = false,
		Callback = function(state)
			autoClaimStreak = state
			if state then runLoop("AutoClaimStreakReward", function() return autoClaimStreak end, function()
				if Remotes and Remotes:FindFirstChild("ClaimStreakReward") then safeFire(Remotes.ClaimStreakReward) end
			end, 5) else stopLoop("AutoClaimStreakReward") end
		end
	})
	local autoClaimOffline = false
	farmingTab:Toggle({
		Title = "Auto Claim Offline Earnings", Value = false,
		Callback = function(state)
			autoClaimOffline = state
			if state then runLoop("AutoClaimOfflineEarnings", function() return autoClaimOffline end, function()
				if Remotes and Remotes:FindFirstChild("ClaimOfflineEarnings") then safeFire(Remotes.ClaimOfflineEarnings) end
			end, 5) else stopLoop("AutoClaimOfflineEarnings") end
		end
	})
	local autoSpinWheel = false
	farmingTab:Toggle({
		Title = "Auto Spin Wheel", Value = false,
		Callback = function(state)
			autoSpinWheel = state
			if state then runLoop("AutoSpinWheel", function() return autoSpinWheel end, function()
				if Remotes and Remotes:FindFirstChild("SpawnWheel") then safeFire(Remotes.SpawnWheel) end
				if Remotes and Remotes:FindFirstChild("PlayLootBoxSpin") then safeFire(Remotes.PlayLootBoxSpin) end
			end, 3) else stopLoop("AutoSpinWheel") end
		end
	})

	inventoryTab:Section({ Title = "🐵 Tails" })
	local autoBuyTails = false
	inventoryTab:Toggle({
		Title = "Auto Buy Best Tail", Value = false,
		Callback = function(state)
			autoBuyTails = state
			if state then runLoop("AutoBuyTails", function() return autoBuyTails end, function()
				local best = getBestAffordableLocked()
				local selected = Data and Data:FindFirstChild("SelectedUpgrade")
				if best and selected and best ~= selected.Value and Remotes then safeFire(Remotes.SelectUpgrade, best) end
			end, 1) else stopLoop("AutoBuyTails") end
		end
	})
	local autoEquipTails = false
	inventoryTab:Toggle({
		Title = "Auto Equip Best Owned Tail", Value = false,
		Callback = function(state)
			autoEquipTails = state
			if state then runLoop("AutoEquipBestTails", function() return autoEquipTails end, function()
				local best = getBestOwned()
				local selected = Data and Data:FindFirstChild("SelectedUpgrade")
				if selected and best ~= selected.Value and Remotes then safeFire(Remotes.SelectUpgrade, best) end
			end, 1) else stopLoop("AutoEquipBestTails") end
		end
	})

	inventoryTab:Section({ Title = "✨ Trails" })
	local Trails = {"Red","Blue","Green","Rainbow","Galaxy","Divine","Fairy","Spectral","Yin Yang","Bloodmoon","Sakura","Flash","Void","Steampunk"}
	local autoBuyTrail = false
	inventoryTab:Toggle({
		Title = "Auto Buy Next Trail", Value = false,
		Callback = function(state)
			autoBuyTrail = state
			if state then runLoop("AutoBuyTrail", function() return autoBuyTrail end, function()
				local unlocked = Data and Data:FindFirstChild("UnlockedTrails")
				if not unlocked then return end
				for _, name in ipairs(Trails) do
					if not unlocked:FindFirstChild(name) then
						if Remotes and Remotes:FindFirstChild("BuyTrail") then safeFire(Remotes.BuyTrail, name) end
						break
					end
				end
			end, 1) else stopLoop("AutoBuyTrail") end
		end
	})
	local autoEquipTrail = false
	inventoryTab:Toggle({
		Title = "Auto Equip Best Trail", Value = false,
		Callback = function(state)
			autoEquipTrail = state
			if state then runLoop("AutoEquipBestTrail", function() return autoEquipTrail end, function()
				local unlocked = Data and Data:FindFirstChild("UnlockedTrails")
				if not unlocked then return end
				local best = nil
				for i = #Trails, 1, -1 do
					if unlocked:FindFirstChild(Trails[i]) then best = Trails[i] break end
				end
				if best and Remotes and Remotes:FindFirstChild("EquipTrail") then safeFire(Remotes.EquipTrail, best) end
			end, 1) else stopLoop("AutoEquipBestTrail") end
		end
	})

	inventoryTab:Section({ Title = "🌟 Auras" })
	local Auras = {"Amber","Ice Cold","Nature","Rainbow","Lunar","Sparkle","Fairy","Spectral","Yin Yang","Bloodmoon","Sakura","Electric","Void","Steampunk"}
	local autoBuyAura = false
	inventoryTab:Toggle({
		Title = "Auto Buy Next Aura", Value = false,
		Callback = function(state)
			autoBuyAura = state
			if state then runLoop("AutoBuyAura", function() return autoBuyAura end, function()
				local unlocked = Data and Data:FindFirstChild("UnlockedAuras")
				if not unlocked then return end
				for _, name in ipairs(Auras) do
					if not unlocked:FindFirstChild(name) then
						if Remotes and Remotes:FindFirstChild("BuyAura") then safeFire(Remotes.BuyAura, name) end
						break
					end
				end
			end, 1) else stopLoop("AutoBuyAura") end
		end
	})
	local autoEquipAura = false
	inventoryTab:Toggle({
		Title = "Auto Equip Best Aura", Value = false,
		Callback = function(state)
			autoEquipAura = state
			if state then runLoop("AutoEquipAura", function() return autoEquipAura end, function()
				local unlocked = Data and Data:FindFirstChild("UnlockedAuras")
				if not unlocked then return end
				local best = nil
				for i = #Auras, 1, -1 do
					if unlocked:FindFirstChild(Auras[i]) then best = Auras[i] break end
				end
				if best and Remotes and Remotes:FindFirstChild("EquipAura") then safeFire(Remotes.EquipAura, best) end
			end, 1) else stopLoop("AutoEquipAura") end
		end
	})

	inventoryTab:Section({ Title = "🔮 Charms" })
	local autoBuyAllCharms = false
	inventoryTab:Toggle({
		Title = "Auto Buy All Charms", Value = false,
		Callback = function(state)
			autoBuyAllCharms = state
			if state then runLoop("AutoBuyAllCharms", function() return autoBuyAllCharms end, function()
				local worldShop = Data and Data:FindFirstChild("CharmShop")
				local curWorld = Data and Data:FindFirstChild("World")
				if not worldShop or not curWorld then return end
				local worldFolder = worldShop:FindFirstChild("World" .. tostring(curWorld.Value))
				if not worldFolder then return end
				for i = 1, 3 do
					local slot = worldFolder:FindFirstChild("Slot" .. i)
					local bought = worldFolder:FindFirstChild("Bought" .. i)
					if slot and slot:IsA("StringValue") and bought and not bought.Value then
						if Remotes and Remotes:FindFirstChild("BuyCharm") then
							safeFire(Remotes.BuyCharm, i)
							task.wait(0.4)
						end
					end
				end
			end, 1) else stopLoop("AutoBuyAllCharms") end
		end
	})
	local autoEquipCharms = false
	inventoryTab:Toggle({
		Title = "Auto Equip Best Charms", Value = false,
		Callback = function(state)
			autoEquipCharms = state
			if state then runLoop("AutoEquipBestCharms", function() return autoEquipCharms end, function()
				if Remotes and Remotes:FindFirstChild("EquipBestCharms") then safeFire(Remotes.EquipBestCharms, "Wins") end
			end, 1) else stopLoop("AutoEquipBestCharms") end
		end
	})
	local autoFuseCharms = false
	inventoryTab:Toggle({
		Title = "Auto Fuse Charms", Value = false,
		Callback = function(state)
			autoFuseCharms = state
			if state then runLoop("AutoFuseCharms", function() return autoFuseCharms end, function()
				local charmsFolder = Data and Data:FindFirstChild("Charms")
				if not charmsFolder then return end
				local byKey = {}
				for _, c in ipairs(charmsFolder:GetChildren()) do
					local charmName = c:GetAttribute("CharmName") or c:GetAttribute("Name") or ""
					if charmName == "" then continue end
					if c:GetAttribute("Locked") then continue end
					local starVal = c:GetAttribute("Stars")
					if type(starVal) ~= "number" then starVal = 0 end
					if starVal >= 3 then continue end
					local k = charmName .. "_" .. tostring(starVal)
					byKey[k] = byKey[k] or {}
					table.insert(byKey[k], c.Name)
				end
				for k, ids in pairs(byKey) do
					if #ids >= 3 then
						local toFuse = {ids[1], ids[2], ids[3]}
						if Remotes and Remotes:FindFirstChild("FuseCharms") then safeFire(Remotes.FuseCharms, toFuse) end
						return
					end
				end
			end, 1) else stopLoop("AutoFuseCharms") end
		end
	})

	inventoryTab:Section({ Title = "🧪 Potions" })
	local Potions = {"Speed 10m","Speed 30m","Speed 1h","Wins 10m","Wins 30m","Wins 1h"}
	for _, potion in ipairs(Potions) do
		local id = "AutoUsePotion_" .. potion:gsub(" ", ""):gsub("10m", "10"):gsub("30m", "30"):gsub("1h", "60")
		local active = false
		inventoryTab:Toggle({
			Title = "Auto Use: " .. potion, Value = false,
			Callback = function(state)
				active = state
				if state then runLoop(id, function() return active end, function()
					if Remotes and Remotes:FindFirstChild("UsePotion") then safeFire(Remotes.UsePotion, potion) end
				end, 2) else stopLoop(id) end
			end
		})
	end

	rebirthTab:Section({ Title = "🔄 Auto Rebirth" })
	local autoRebirth = false
	rebirthTab:Toggle({
		Title = "Auto Rebirth", Value = false,
		Callback = function(state)
			autoRebirth = state
			if state then runLoop("AutoRebirth", function() return autoRebirth end, function()
				if Remotes and Remotes:FindFirstChild("Rebirth") then safeFire(Remotes.Rebirth) end
			end, 1) else stopLoop("AutoRebirth") end
		end
	})
	rebirthTab:Button({
		Title = "🔄 Rebirth Now",
		Callback = function() if Remotes and Remotes:FindFirstChild("Rebirth") then safeFire(Remotes.Rebirth) end end
	})
	rebirthTab:Section({ Title = "📊 Status" })
	local rebirthsVal = Data and Data:FindFirstChild("Rebirths")
	local levelVal = Data and Data:FindFirstChild("Level")
	rebirthTab:Paragraph({ Title = "Rebirths", Desc = tostring(rebirthsVal and rebirthsVal.Value or 0) })
	rebirthTab:Paragraph({ Title = "Level", Desc = tostring(levelVal and levelVal.Value or 1) })

	settingsTab:Section({ Title = "⚙️ System" })
	settingsTab:Toggle({
		Title = "Anti-AFK", Value = true,
		Callback = function(state) setAntiAFK(state) end
	})
	setAntiAFK(true)
	settingsTab:Button({
		Title = "🗑️ Unload GUI",
		Callback = function()
			for id, loop in pairs(Loops) do
				if type(loop) == "table" and loop.Disconnect then loop:Disconnect()
				elseif type(loop) == "thread" then task.cancel(loop) end
			end
			if AntiAFKConn then AntiAFKConn:Disconnect() end
			window:Destroy()
		end
	})
	WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ GUI loaded for " .. GameName, Duration = 4 })
end

-- ============================================================
-- ========== JUEGO 2: BLOXSPIN ==========
-- ============================================================
local function runBloxSpin()
	local LocalPlayer = playersService.LocalPlayer

	if not game:IsLoaded() then game.Loaded:Wait() end

	local PlayerGui
	repeat task.wait() PlayerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") until PlayerGui
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid", 10)
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
	local Backpack = LocalPlayer:WaitForChild("Backpack")
	local Camera = workspaceService.CurrentCamera

	-- Módulos del juego
	local Networking, Data, Sprint, Ragdoll, Crate, Vehicle, CharModule
	pcall(function()
		Networking = replicatedStorage:WaitForChild("Modules", 10):WaitForChild("Core", 10):WaitForChild("Net", 10)
	end)
	pcall(function() CharModule = require(replicatedStorage.Modules.Core.Char) end)
	pcall(function() Data = require(replicatedStorage.Modules.Core.Data) end)
	pcall(function() Sprint = require(replicatedStorage.Modules.Game.Sprint) end)
	pcall(function() Ragdoll = require(replicatedStorage.Modules.Game.Ragdoll) end)
	pcall(function() Crate = require(replicatedStorage.Modules.Game.CrateSystem.Crate) end)
	pcall(function() Vehicle = require(replicatedStorage.Modules.Game.VehicleSystem.Vehicle) end)

	local DroppedItems = workspaceService:FindFirstChild("DroppedItems")
	local Vehicles = workspaceService:FindFirstChild("Vehicles")

	-- State
	local Flags = {}
	local Loops = {}
	local Connections = {}

	local function startLoop(id, fn, interval)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
		Flags[id] = true
		Loops[id] = task.spawn(function()
			while Flags[id] do
				pcall(fn)
				task.wait(interval or 0.1)
			end
			Loops[id] = nil
		end)
	end

	local function stopLoop(id)
		Flags[id] = false
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
	end

	local function getCharacter()
		Character = LocalPlayer.Character
		if not Character then return nil end
		Humanoid = Character:FindFirstChildOfClass("Humanoid")
		HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		return Character
	end

	local function distanceTo(target)
		if not HumanoidRootPart then return math.huge end
		if typeof(target) == "Instance" then
			if target:IsA("BasePart") then
				return (target.Position - HumanoidRootPart.Position).Magnitude
			end
			if target:IsA("Model") then
				return (target:GetPivot().Position - HumanoidRootPart.Position).Magnitude
			end
		elseif typeof(target) == "Vector3" then
			return (target - HumanoidRootPart.Position).Magnitude
		end
		return math.huge
	end

	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_BLOXSPIN", "POTENT HUB - BloxSpin")

	local function notify(title, content, duration)
		pcall(function()
			WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 })
		end)
	end

	local generalTab = window:Tab({ Title = "🏠 General", Icon = "house" })
	local vehicleTab = window:Tab({ Title = "🚗 Vehicle", Icon = "car" })
	local visualTab = window:Tab({ Title = "👁️ Visual", Icon = "eye" })
	local pvpTab = window:Tab({ Title = "⚔️ PVP", Icon = "crosshair" })
	local miscTab = window:Tab({ Title = "⚙️ Misc", Icon = "box" })

	-- GENERAL TAB
	generalTab:Section({ Title = "ℹ️ Info" })
	generalTab:Paragraph({ Title = "Game", Desc = "BloxSpin" })
	generalTab:Paragraph({ Title = "PlaceId", Desc = tostring(game.PlaceId) })

	local bankPara = generalTab:Paragraph({ Title = "🏦 Bank", Desc = "$0" })
	local handPara = generalTab:Paragraph({ Title = "💵 Cash", Desc = "$0" })

	task.spawn(function()
		while true do
			task.wait(1)
			pcall(function()
				if Data and Data.money then
					bankPara:SetDesc("$" .. tostring(Data.money.bank or 0))
					handPara:SetDesc("$" .. tostring(Data.money.hand or 0))
				end
			end)
		end
	end)

	generalTab:Section({ Title = "🏃 Humanoid" })
	generalTab:Toggle({
		Title = "Speed Custom",
		Desc = "Custom walk speed",
		Value = false,
		Callback = function(state)
			Flags.WalkSpeedCustom = state
			Flags.WalkSpeedLoop = state
		end,
	})
	generalTab:Slider({
		Title = "Speed Value",
		Step = 0.1,
		Value = { Min = 1, Max = 3.5, Default = 1 },
		Callback = function(v) Flags.WalkSpeedValue = v end,
	})
	generalTab:Toggle({
		Title = "Jump Custom",
		Desc = "Custom jump power",
		Value = false,
		Callback = function(state) Flags.JumpPowerCustom = state end,
	})
	generalTab:Slider({
		Title = "Jump Value",
		Step = 1,
		Value = { Min = 1, Max = 25, Default = 10 },
		Callback = function(v) Flags.JumpPowerValue = v end,
	})

	generalTab:Section({ Title = "⛏️ Underground" })
	generalTab:Toggle({
		Title = "Snap Underground",
		Desc = "Enable underground snap",
		Value = false,
		Callback = function(state)
			Flags.Snap = state
			if state then startLoop("Snap", function()
				if getCharacter() and HumanoidRootPart then
					local snapY = Flags.SnapBaseY
					if not snapY then
						snapY = HumanoidRootPart.Position.Y
						Flags.SnapBaseY = snapY
					end
					local targetY = snapY - (Flags.SnapAmount or 10)
					local diff = targetY - HumanoidRootPart.Position.Y
					Character:PivotTo(HumanoidRootPart.CFrame * CFrame.new(0, diff, 0))
				end
			end, 0.05)
			else
				Flags.SnapBaseY = nil
				stopLoop("Snap")
			end
		end,
	})
	generalTab:Slider({
		Title = "Snap Amount",
		Step = 1,
		Value = { Min = 1, Max = 150, Default = 10 },
		Callback = function(v) Flags.SnapAmount = v end,
	})

	generalTab:Section({ Title = "📦 Item Grabber" })
	generalTab:Toggle({
		Title = "Item Dropped Grabber",
		Desc = "Auto grab dropped items",
		Value = false,
		Callback = function(state)
			Flags.ItemDroppedGraber = state
			if state then startLoop("ItemGrab", function()
				if not Networking or not DroppedItems then return end
				for _, item in ipairs(DroppedItems:GetChildren()) do
					if item:IsA("Model") and item:FindFirstChild("PickUpZone") and distanceTo(item) < 15 then
						pcall(function() Networking:Get("pickup_dropped_item", item) end)
					end
				end
			end, 0.3)
			else stopLoop("ItemGrab") end
		end,
	})

	generalTab:Section({ Title = "⚙️ Etc" })
	generalTab:Toggle({
		Title = "Infinite Stamina",
		Desc = "Unlimited stamina",
		Value = false,
		Callback = function(state) Flags.InfStamina = state end,
	})
	generalTab:Toggle({
		Title = "Auto Respawn",
		Desc = "Auto respawn on death",
		Value = false,
		Callback = function(state)
			Flags.AutoRespawn = state
			if state then startLoop("AutoRespawn", function()
				if not Networking then return end
				local ds = PlayerGui:FindFirstChild("DeathScreen")
				ds = ds and ds:FindFirstChild("DeathScreenHolder")
				if not ds or not ds.Visible then return end
				local frame = ds.Frame
				frame = frame and frame:FindFirstChild("RespawnButtonFrame")
				frame = frame and frame:FindFirstChild("RespawnButton")
				frame = frame and frame:FindFirstChild("TextLabel")
				if frame and frame.Text == "Respawn" then
					Networking:FireServer("death_screen_request_respawn")
				end
			end, 1)
			else stopLoop("AutoRespawn") end
		end,
	})
	generalTab:Toggle({
		Title = "Hide Name",
		Desc = "Hide your own name",
		Value = false,
		Callback = function(state)
			Flags.HideName = state
			if HumanoidRootPart then
				local bb = HumanoidRootPart:FindFirstChild("CharacterBillboardGui")
				if bb then bb.Enabled = not state end
			end
		end,
	})
	generalTab:Toggle({
		Title = "Anti Ragdoll",
		Desc = "Prevent ragdoll",
		Value = false,
		Callback = function(state) Flags.AntiRagdoll = state end,
	})
	generalTab:Toggle({
		Title = "Anti Aim Assist",
		Desc = "Prevent aim assist locks",
		Value = false,
		Callback = function(state)
			Flags.AntiAimAssiant = state
			if state then startLoop("AntiAim", function()
				if not CharModule then return end
				local hum = CharModule.get_hum()
				if hum and not hum:GetAttribute("HasBeenDowned") then
					local hrp = CharModule.get_hrp()
					if hrp then
						local v, av, aav = hrp.Velocity, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity
						hrp.Velocity = Vector3.new(math.random(-99999, 99999), math.random(-99999, 99999), math.random(-99999, 99999))
						hrp.AssemblyLinearVelocity = hrp.Velocity
						hrp.AssemblyAngularVelocity = hrp.Velocity
						runService.RenderStepped:Wait()
						hrp.Velocity, hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity = v, av, aav
					end
				end
			end, 0.05)
			else stopLoop("AntiAim") end
		end,
	})

	-- VEHICLE TAB
	vehicleTab:Section({ Title = "🚗 Vehicle Settings" })
	vehicleTab:Toggle({
		Title = "Speed Boost Vehicle",
		Desc = "Boost vehicle speed",
		Value = false,
		Callback = function(state)
			Flags.SpeedBostVehicle = state
			if state then startLoop("VehicleBoost", function()
				if not Vehicle then return end
				local car = Vehicle.get_car_player_is_in()
				if car and car.PrimaryPart then
					local vel = car.PrimaryPart.AssemblyLinearVelocity
					local look = car.PrimaryPart.CFrame.LookVector
					if vel.Magnitude > 0 then
						local boost = look * (Flags.VehicleSpeedBost or 45)
						car.PrimaryPart.AssemblyLinearVelocity = Vector3.new(boost.X, vel.Y, boost.Z)
					end
				end
			end, 0.05)
			else stopLoop("VehicleBoost") end
		end,
	})
	vehicleTab:Slider({
		Title = "Vehicle Speed",
		Step = 1,
		Value = { Min = 20, Max = 80, Default = 45 },
		Callback = function(v) Flags.VehicleSpeedBost = v end,
	})

	vehicleTab:Section({ Title = "🚙 Vehicle Actions" })
	vehicleTab:Button({
		Title = "Pull Your Vehicle",
		Desc = "Pull your vehicle to you",
		Callback = function()
			if not Vehicles then notify("Vehicle", "Vehicles not found", 3) return end
			for _, v in ipairs(Vehicles:GetChildren()) do
				if v:IsA("Model") and v:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
					v:PivotTo(HumanoidRootPart.CFrame * CFrame.new(0, 5, -5))
					notify("Vehicle", "Vehicle pulled", 2)
					return
				end
			end
			notify("Vehicle", "No vehicle found", 3)
		end,
	})
	vehicleTab:Button({
		Title = "Crash Current Vehicle",
		Desc = "Explode the vehicle you're in",
		Callback = function()
			if not Networking or not Vehicle then notify("Vehicle", "Not available", 3) return end
			local car = Vehicle.get_car_player_is_in()
			if not car then notify("Vehicle", "Not in a vehicle", 3) return end
			for i = 1, 15 do
				Networking:FireServer("crashed_car", car, 150)
			end
			notify("Vehicle", "Vehicle crashed", 2)
		end,
	})

	-- VISUAL TAB
	local ESPData = {}
	local function createDrawing(class, props)
		if not Drawing then return nil end
		local d = Drawing.new(class)
		for k, v in pairs(props or {}) do d[k] = v end
		return d
	end

	local function worldToViewport(pos)
		local v3 = typeof(pos) == "Vector3" and pos or pos.Position
		local sp, onScreen = Camera:WorldToViewportPoint(v3)
		return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
	end

	local function setupESPForPlayer(plr)
		if plr == LocalPlayer or ESPData[plr] then return end
		if not Drawing then return end
		ESPData[plr] = {
			Box = createDrawing("Square", { Visible = false, Color = Color3.fromRGB(201, 12, 204), Thickness = 1, Filled = false }),
			Name = createDrawing("Text", { Visible = false, Color = Color3.new(1,1,1), Size = 15, Center = true, Outline = true, Text = plr.Name }),
			Distance = createDrawing("Text", { Visible = false, Color = Color3.new(1,1,1), Size = 15, Center = true, Outline = true, Text = "" }),
			HPBar = createDrawing("Line", { Visible = false, Color = Color3.new(0,1,0), Thickness = 2 }),
		}
	end

	local function removeESPForPlayer(plr)
		if not ESPData[plr] then return end
		for _, d in pairs(ESPData[plr]) do
			pcall(function() d:Remove() end)
		end
		ESPData[plr] = nil
	end

	if Drawing then
		for _, plr in ipairs(playersService:GetPlayers()) do setupESPForPlayer(plr) end
		table.insert(Connections, playersService.PlayerAdded:Connect(setupESPForPlayer))
		table.insert(Connections, playersService.PlayerRemoving:Connect(removeESPForPlayer))

		startLoop("ESP", function()
			if not Camera then return end
			for plr, data in pairs(ESPData) do
				local char = plr.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local head = char and char:FindFirstChild("Head")
				if not (char and hum and hrp and head and hum.Health > 0) then
					for _, d in pairs(data) do d.Visible = false end
					continue
				end
				local sp, onScreen = worldToViewport(hrp.Position)
				if not onScreen then
					for _, d in pairs(data) do d.Visible = false end
					continue
				end
				local headSP = worldToViewport(head.Position + Vector3.new(0, 0.5, 0))
				local feetSP = worldToViewport(hrp.Position - Vector3.new(0, 3, 0))
				local boxH = headSP.Y - feetSP.Y
				local boxW = 1000 / sp.Z
				data.Box.Size = Vector2.new(boxW, boxH)
				data.Box.Position = Vector2.new(sp.X - boxW / 2, sp.Y - boxH / 2)
				data.Box.Visible = Flags.BoxPlayerVisual or false
				data.Name.Position = Vector2.new(headSP.X, headSP.Y - 20)
				data.Name.Visible = Flags.NamePlayerVisual or false
				data.Distance.Position = Vector2.new(headSP.X, feetSP.Y + 5)
				data.Distance.Text = "[" .. math.floor((hrp.Position - HumanoidRootPart.Position).Magnitude) .. "m]"
				data.Distance.Visible = Flags.DistancePlayerVisual or false
				local hpRatio = hum.Health / hum.MaxHealth
				data.HPBar.From = Vector2.new(data.Box.Position.X + boxW + 5, data.Box.Position.Y + boxH * (1 - hpRatio))
				data.HPBar.To = Vector2.new(data.Box.Position.X + boxW + 5, data.Box.Position.Y + boxH)
				data.HPBar.Color = Color3.new(1 - hpRatio, hpRatio, 0)
				data.HPBar.Visible = Flags.HealthPlayerVisual or false
			end
		end, 0.05)
	end

	visualTab:Section({ Title = "👁️ Player Visual" })
	visualTab:Toggle({ Title = "ESP Name", Desc = "Show player names", Value = false, Callback = function(s) Flags.NamePlayerVisual = s end })
	visualTab:Toggle({ Title = "ESP Box", Desc = "Show player boxes", Value = false, Callback = function(s) Flags.BoxPlayerVisual = s end })
	visualTab:Toggle({ Title = "ESP Health", Desc = "Show player health", Value = false, Callback = function(s) Flags.HealthPlayerVisual = s end })
	visualTab:Toggle({ Title = "ESP Distance", Desc = "Show player distance", Value = false, Callback = function(s) Flags.DistancePlayerVisual = s end })
	visualTab:Toggle({ Title = "ESP Inventory", Desc = "Show player inventory", Value = false, Callback = function(s) Flags.InventoryPlayerVisual = s end })

	visualTab:Section({ Title = "📦 Item Drop Visual" })
	visualTab:Toggle({ Title = "Show Item Drop", Desc = "Show dropped items", Value = false, Callback = function(s) Flags.ItemDropVisual = s end })
	visualTab:Dropdown({
		Title = "Blacklist Rarity",
		Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Omega"},
		Value = "Common",
		Callback = function(v) Flags.BlacklistRarity = v end,
	})

	visualTab:Section({ Title = "🚀 Performance" })
	visualTab:Button({
		Title = "Low Quality Mode",
		Desc = "Reduce visual quality for FPS",
		Callback = function()
			pcall(function()
				lighting.FogEnd = 10000000000
				lighting.FogStart = 10000000000
				lighting.Brightness = 1.2
				lighting.GlobalShadows = false
				lighting.EnvironmentDiffuseScale = 0.5
				lighting.EnvironmentSpecularScale = 0.3
				lighting.ShadowSoftness = 0
				for _, effect in ipairs(lighting:GetChildren()) do
					if effect:IsA("BloomEffect") then effect.Intensity = 0.2 end
					if effect:IsA("BlurEffect") then effect.Size = 0 end
					if effect:IsA("SunRaysEffect") then effect.Intensity = 0.1 end
					if effect:IsA("ColorCorrectionEffect") then effect.Saturation = 0.7 end
				end
				for _, part in ipairs(workspaceService:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Material = Enum.Material.SmoothPlastic
						part.CastShadow = false
						part.Reflectance = 0
					end
				end
				if setfpscap then pcall(setfpscap, 240) end
			end)
			notify("Performance", "Low quality mode enabled", 3)
		end,
	})

	-- PVP TAB
	local AimTarget = nil
	local PovCircle = Drawing and Drawing.new("Circle") or nil
	if PovCircle then
		PovCircle.Visible = false
		PovCircle.Color = Color3.new(1, 1, 1)
		PovCircle.Thickness = 1
		PovCircle.Filled = false
		PovCircle.NumSides = 64
	end

	local function findAimTarget()
		if not HumanoidRootPart or not Camera then return nil end
		local best, bestDist = nil, math.huge
		local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 then
					if not plr:GetAttribute("IsSafeZoneProtected") and not plr.Character:GetAttribute("IsSpawnProtected") then
						if not (Flags.FriendIngore and plr:IsFriendsWith(LocalPlayer.UserId)) then
							local sp, onScreen = worldToViewport(hrp.Position)
							if onScreen then
								local d = (sp - center).Magnitude
								if d <= (Flags.PovSize or 250) and d < bestDist then
									best, bestDist = plr, d
								end
							end
						end
					end
				end
			end
		end
		return best
	end

	if PovCircle then
		startLoop("AimAssist", function()
			if not Camera then return end
			PovCircle.Radius = Flags.PovSize or 250
			PovCircle.Visible = Flags.AimAssiant or false
			PovCircle.Color = Flags.RainbowPov and Color3.fromHSV(tick() % 5 / 5, 1, 1) or Color3.new(1, 1, 1)
			PovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
			if Flags.AimAssiant then
				AimTarget = findAimTarget()
			else
				AimTarget = nil
			end
		end, 0.05)
	end

	pvpTab:Section({ Title = "🎯 PVP Settings" })
	pvpTab:Toggle({ Title = "Aim Assist", Desc = "Aim assist lock", Value = false, Callback = function(s) Flags.AimAssiant = s end })
	pvpTab:Toggle({ Title = "Wall Bang", Desc = "Shoot through walls", Value = false, Callback = function(s) Flags.WallBang = s end })
	pvpTab:Toggle({ Title = "Multi Shoot", Desc = "Shoot x2 per bullet", Value = false, Callback = function(s) Flags.MultiShoot = s end })
	pvpTab:Toggle({ Title = "Ignore Friends", Desc = "Skip friends in aim assist", Value = false, Callback = function(s) Flags.FriendIngore = s end })
	pvpTab:Toggle({ Title = "Rainbow POV", Desc = "Rainbow circle", Value = false, Callback = function(s) Flags.RainbowPov = s end })
	pvpTab:Dropdown({
		Title = "Target Part",
		Values = {"Head", "HumanoidRootPart"},
		Value = "Head",
		Callback = function(v) Flags.PartTargetSelected = v end,
	})
	pvpTab:Slider({
		Title = "POV Size",
		Step = 1,
		Value = { Min = 150, Max = 800, Default = 250 },
		Callback = function(v) Flags.PovSize = v end,
	})

	pvpTab:Section({ Title = "🔫 Gun Customization" })
	pvpTab:Toggle({ Title = "Automatic Mode", Desc = "Auto fire mode", Value = false, Callback = function(s) Flags.AutomaticGun = s end })
	pvpTab:Slider({ Title = "Fire Rate", Step = 1, Value = { Min = 100, Max = 3000, Default = 1000 }, Callback = function(v) Flags.FireRateGun = v end })
	pvpTab:Slider({ Title = "Recoil", Step = 0.1, Value = { Min = 0, Max = 10, Default = 0 }, Callback = function(v) Flags.RecoilGun = v end })
	pvpTab:Slider({ Title = "Accuracy", Step = 0.01, Value = { Min = 0, Max = 1, Default = 1 }, Callback = function(v) Flags.AccuracyGun = v end })
	pvpTab:Slider({ Title = "Durability", Step = 1, Value = { Min = 100, Max = 3000, Default = 1000 }, Callback = function(v) Flags.DurabilityGun = v end })
	pvpTab:Button({
		Title = "Apply Gun Settings",
		Desc = "Apply to currently held gun",
		Callback = function()
			if not Character then return end
			local tool = Character:FindFirstChildWhichIsA("Tool")
			if not tool then notify("Gun", "No gun equipped", 3) return end
			pcall(function()
				local gunFolder = replicatedStorage:FindFirstChild("Items")
				gunFolder = gunFolder and gunFolder:FindFirstChild("gun")
				if not gunFolder then return end
				for _, gun in ipairs(gunFolder:GetChildren()) do
					if tool.Name == gun.Name then
						tool:SetAttribute("fire_rate", Flags.FireRateGun or tool:GetAttribute("fire_rate"))
						tool:SetAttribute("accuracy", Flags.AccuracyGun or tool:GetAttribute("accuracy"))
						tool:SetAttribute("Recoil", Flags.RecoilGun or tool:GetAttribute("Recoil"))
						tool:SetAttribute("Durability", Flags.DurabilityGun or tool:GetAttribute("Durability"))
						tool:SetAttribute("automatic", Flags.AutomaticGun or tool:GetAttribute("automatic"))
						notify("Gun", "Settings applied", 2)
					end
				end
			end)
		end,
	})

	-- MISC TAB
	miscTab:Section({ Title = "🎁 Crate & Quest" })
	miscTab:Button({
		Title = "Skip Crate Spin",
		Desc = "Skip crate spin animation",
		Callback = function()
			if not Crate then notify("Crate", "Not available", 3) return end
			pcall(function()
				if Crate.spinning and Crate.spinning.get() then return end
				Crate.skip_spin()
				notify("Crate", "Spin skipped", 2)
			end)
		end,
	})
	miscTab:Button({
		Title = "Claim All Quests",
		Desc = "Claim all quests at once",
		Callback = function()
			if not Networking then return end
			pcall(function()
				local quests = PlayerGui:FindFirstChild("Quests")
				if not quests then return end
				local holder = quests:FindFirstChild("QuestsHolder")
				if not holder then return end
				local frame = holder:FindFirstChild("QuestsScrollingFrame")
				if not frame then return end
				for _, v in ipairs(frame:GetChildren()) do
					if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("ImageButton") then
						Networking:Get("claim_quest", v.Name)
					end
				end
				notify("Quests", "All quests claimed", 2)
			end)
		end,
	})

	miscTab:Section({ Title = "🗑️ Unload" })
	miscTab:Button({
		Title = "Unload GUI",
		Desc = "Unload the script",
		Callback = function()
			for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
			for id in pairs(Loops) do stopLoop(id) end
			pcall(function() window:Destroy() end)
		end,
	})

	-- Anti Ragdoll hook
	if Ragdoll and Ragdoll.is_ragdolling and Ragdoll.is_ragdolling.get then
		local origGet = Ragdoll.is_ragdolling.get
		Ragdoll.is_ragdolling.get = function(...)
			local r = origGet(...)
			if r == true and Flags.AntiRagdoll and Networking then
				pcall(function()
					Ragdoll.is_ragdolling.set(false)
					Networking:FireServer("end_ragdoll_early")
					Networking:FireServer("clear_ragdoll")
				end)
			end
			return r
		end
	end

	-- Inf Stamina hook
	pcall(function()
		if Sprint and Sprint.consume_stamina then
			local bar = debug.getupvalue(Sprint.consume_stamina, 2).sprint_bar
			if bar and bar.update then
				local origUpdate = bar.update
				bar.update = function(...)
					if Flags.InfStamina then return function() return 1 end end
					return origUpdate(...)
				end
			end
		end
	end)

	-- Humanoid loop
	startLoop("Humanoid", function()
		getCharacter()
		if not Humanoid or not HumanoidRootPart then return end
		if Flags.JumpPowerCustom then
			Humanoid.JumpHeight = Flags.JumpPowerValue or 3.89
		else
			Humanoid.JumpHeight = 3.89
		end
		local moveDir = Humanoid.MoveDirection
		if moveDir.Magnitude > 0 and Flags.WalkSpeedCustom then
			pcall(function()
				if Networking then Networking:FireServer("set_sprinting_1", true) end
			end)
			if Humanoid:GetAttribute("TargetWalkSpeed") ~= 30 and Humanoid.WalkSpeed ~= 30 then
				Humanoid:SetAttribute("TargetWalkSpeed", 30)
				Humanoid.WalkSpeed = 30
			end
			HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + moveDir.Unit * ((Flags.WalkSpeedValue or 3) / 145.5)
		end
	end, 0.05)

	-- Hide name loop
	startLoop("HideName", function()
		if HumanoidRootPart then
			local bb = HumanoidRootPart:FindFirstChild("CharacterBillboardGui")
			if bb then bb.Enabled = not (Flags.HideName or false) end
		end
	end, 0.5)

	table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(1)
		Character = char
		Humanoid = char:WaitForChild("Humanoid", 10)
		HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
		Backpack = LocalPlayer:WaitForChild("Backpack")
	end))

	notify("⚡ POTENT HUB", "✅ BloxSpin cargado!", 4)
	print("[POTENT HUB] BloxSpin loaded")
end

-- ============================================================
-- ========== JUEGO 3: MURDER MYSTERY 2 ==========
-- ============================================================
local function runMM2()
	local CONFIG_FILE = "potent_hub_mm2_config.json"

	local function loadConfig()
		if not isfile or not readfile or not isfile(CONFIG_FILE) then return {} end
		local ok, data = pcall(function() return httpService:JSONDecode(readfile(CONFIG_FILE)) end)
		if ok and type(data) == "table" then
			local defaults = {
				espAll = false, espGun = false,
				killAura = false, killAuraRange = 15,
				autoShoot = false, autoGrabGun = false,
				autoKnifeThrow = false,
				notifyMurderer = false, notifySheriff = false,
				gunSilentAim = false,
				hitboxExpand = false, hitboxSize = 4, hitboxVisible = false,
				instantRole = false,
				antiSilentAim = false,
				autoFarmCoins = false,
				godmode = false,
				speedEnabled = false, speedValue = 20,
				jumpEnabled = false, jumpValue = 50,
				noclipEnabled = false,
			}
			for key, default in pairs(defaults) do
				if data[key] == nil then data[key] = default end
			end
			return data
		end
		return {}
	end
	local function saveConfig(tbl)
		if not writefile then return end
		pcall(function() writefile(CONFIG_FILE, httpService:JSONEncode(tbl)) end)
	end
	local savedConfig = loadConfig()

	local localPlayer = playersService.LocalPlayer
	local flags = {
		espAll = savedConfig.espAll == true,
		espGun = savedConfig.espGun == true,
		killAura = savedConfig.killAura == true,
		killAuraRange = savedConfig.killAuraRange or 15,
		autoShoot = savedConfig.autoShoot == true,
		autoGrabGun = savedConfig.autoGrabGun == true,
		autoKnifeThrow = savedConfig.autoKnifeThrow == true,
		notifyMurderer = savedConfig.notifyMurderer == true,
		notifySheriff = savedConfig.notifySheriff == true,
		gunSilentAim = savedConfig.gunSilentAim == true,
		hitboxExpand = savedConfig.hitboxExpand == true,
		hitboxSize = savedConfig.hitboxSize or 4,
		hitboxVisible = savedConfig.hitboxVisible == true,
		instantRole = savedConfig.instantRole == true,
		antiSilentAim = savedConfig.antiSilentAim == true,
		autoFarmCoins = savedConfig.autoFarmCoins == true,
		godmode = savedConfig.godmode == true,
		speedEnabled = savedConfig.speedEnabled == true,
		speedValue = savedConfig.speedValue or 20,
		jumpEnabled = savedConfig.jumpEnabled == true,
		jumpValue = savedConfig.jumpValue or 50,
		noclipEnabled = savedConfig.noclipEnabled == true,
	}
	local function saveAll()
		saveConfig({
			espAll = flags.espAll, espGun = flags.espGun,
			killAura = flags.killAura, killAuraRange = flags.killAuraRange,
			autoShoot = flags.autoShoot, autoGrabGun = flags.autoGrabGun,
			autoKnifeThrow = flags.autoKnifeThrow,
			notifyMurderer = flags.notifyMurderer, notifySheriff = flags.notifySheriff,
			gunSilentAim = flags.gunSilentAim,
			hitboxExpand = flags.hitboxExpand, hitboxSize = flags.hitboxSize,
			hitboxVisible = flags.hitboxVisible,
			instantRole = flags.instantRole,
			antiSilentAim = flags.antiSilentAim,
			autoFarmCoins = flags.autoFarmCoins,
			godmode = flags.godmode,
			speedEnabled = flags.speedEnabled, speedValue = flags.speedValue,
			jumpEnabled = flags.jumpEnabled, jumpValue = flags.jumpValue,
			noclipEnabled = flags.noclipEnabled,
		})
	end

	local highlights = {}
	local tagCache = {}
	local gunEsp = {}
	local autoFarmRunning, autoFarmThread = false, nil
	local hitboxOriginal = {}
	local godmodeConnection = nil

	localPlayer.Idled:Connect(function()
		virtualUser:CaptureController()
		virtualUser:ClickButton2(Vector2.new())
	end)

	local function getRoot(player)
		local char = player and player.Character
		return char and char:FindFirstChild("HumanoidRootPart")
	end
	local function getHumanoid(player)
		local char = player and player.Character
		return char and char:FindFirstChildOfClass("Humanoid")
	end
	local function hasTool(player, search)
		local char = player.Character
		if char then
			for _, v in ipairs(char:GetDescendants()) do
				if v:IsA("Tool") and string.find(string.lower(v.Name), search) then return true end
			end
		end
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, v in ipairs(backpack:GetChildren()) do
				if v:IsA("Tool") and string.find(string.lower(v.Name), search) then return true end
			end
		end
		return false
	end
	local function getPlayerRole(player)
		if not player.Character then return nil end
		if hasTool(player, "knife") then return "Murderer"
		elseif hasTool(player, "gun") or hasTool(player, "revolver") then return "Sheriff" end
		return "Innocent"
	end
	local function findMurderer()
		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= localPlayer then
				local bp = plr:FindFirstChild("Backpack")
				if bp and bp:FindFirstChild("Knife") then return plr end
				if plr.Character and plr.Character:FindFirstChild("Knife") then return plr end
			end
		end
		return nil
	end
	local function findSheriff()
		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= localPlayer then
				local bp = plr:FindFirstChild("Backpack")
				if bp and bp:FindFirstChild("Gun") then return plr end
				if plr.Character and plr.Character:FindFirstChild("Gun") then return plr end
			end
		end
		return nil
	end
	local function findMap()
		for _, o in ipairs(workspaceService:GetChildren()) do
			if o:FindFirstChild("CoinContainer") and o:FindFirstChild("Spawns") then return o end
		end
		return nil
	end
	local function removeHighlight(player)
		if highlights[player] then
			pcall(highlights[player].Destroy, highlights[player])
			highlights[player] = nil
		end
	end
	local function removeTag(player)
		if tagCache[player] then
			pcall(tagCache[player].Destroy, tagCache[player])
			tagCache[player] = nil
		end
	end
	local function createRoleTag(player, role)
		local char = player.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		removeTag(player)
		if role ~= "Murderer" and role ~= "Sheriff" then return end
		local colors = { Murderer = Color3.fromRGB(255, 0, 0), Sheriff = Color3.fromRGB(0, 100, 255) }
		local emojis = { Murderer = "🔪", Sheriff = "🔫" }
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "POTENT_ROLE_TAG"
		billboard.Size = UDim2.new(0, 180, 0, 35)
		billboard.StudsOffset = Vector3.new(0, 2.8, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head
		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		bg.BackgroundTransparency = 0.6
		bg.Parent = billboard
		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.Text = emojis[role] .. " " .. role
		text.TextColor3 = colors[role]
		text.TextScaled = true
		text.Font = Enum.Font.GothamBold
		text.Parent = bg
		tagCache[player] = billboard
	end
	local function updateESP()
		for player, _ in pairs(highlights) do
			if not player or not player.Parent then removeHighlight(player) removeTag(player) end
		end
		if not flags.espAll then
			for player, _ in pairs(highlights) do removeHighlight(player) removeTag(player) end
			return
		end
		for _, player in ipairs(playersService:GetPlayers()) do
			if player == localPlayer then removeHighlight(player) removeTag(player) continue end
			local role = getPlayerRole(player)
			local hl = highlights[player] or Instance.new("Highlight")
			hl.Name = "POTENT_ESP"
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.FillTransparency = 0.4
			hl.OutlineTransparency = 0
			if role == "Murderer" then
				hl.FillColor = Color3.fromRGB(255, 0, 0)
				hl.OutlineColor = Color3.fromRGB(255, 0, 0)
				hl.Adornee = player.Character
				hl.Parent = player.Character
				hl.Enabled = true
				highlights[player] = hl
				createRoleTag(player, "Murderer")
			elseif role == "Sheriff" then
				hl.FillColor = Color3.fromRGB(0, 100, 255)
				hl.OutlineColor = Color3.fromRGB(0, 100, 255)
				hl.Adornee = player.Character
				hl.Parent = player.Character
				hl.Enabled = true
				highlights[player] = hl
				createRoleTag(player, "Sheriff")
			elseif role == "Innocent" then
				hl.FillColor = Color3.fromRGB(0, 255, 0)
				hl.OutlineColor = Color3.fromRGB(0, 255, 0)
				hl.Adornee = player.Character
				hl.Parent = player.Character
				hl.Enabled = true
				highlights[player] = hl
				removeTag(player)
			else
				removeHighlight(player)
				removeTag(player)
			end
		end
	end
	local function updateGunESP()
		for obj, hl in pairs(gunEsp) do
			if not obj or not obj.Parent then pcall(hl.Destroy, hl) gunEsp[obj] = nil end
		end
		if not flags.espGun then
			for obj, hl in pairs(gunEsp) do pcall(hl.Destroy, hl) gunEsp[obj] = nil end
			return
		end
		for _, desc in ipairs(workspaceService:GetDescendants()) do
			if desc.Name == "GunDrop" and desc:IsA("BasePart") and not gunEsp[desc] then
				local hl = Instance.new("Highlight")
				hl.Name = "POTENT_GunHighlight"
				hl.Adornee = desc
				hl.FillColor = Color3.fromRGB(0, 255, 255)
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = desc
				gunEsp[desc] = hl
			end
		end
	end
	task.spawn(function() while true do pcall(updateESP) task.wait(0.2) end end)
	task.spawn(function() while true do pcall(updateGunESP) task.wait(0.5) end end)

	local function applyGodmode(state)
		if godmodeConnection then pcall(godmodeConnection.Disconnect, godmodeConnection) godmodeConnection = nil end
		if state then
			local function setupGodmode(character)
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					godmodeConnection = humanoid.HealthChanged:Connect(function(newHealth)
						if flags.godmode and newHealth < humanoid.MaxHealth then
							humanoid.Health = humanoid.MaxHealth
						end
					end)
				end
			end
			if localPlayer.Character then setupGodmode(localPlayer.Character) end
		end
	end
	local function coinsReach(state)
		for _, obj in pairs(workspaceService:GetDescendants()) do
			if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
				if not hitboxOriginal[obj] then hitboxOriginal[obj] = obj.Size end
				if state then obj.Size = hitboxOriginal[obj] * 4
				else obj.Size = hitboxOriginal[obj] end
			end
		end
	end
	local function findCoinContainer()
		local map = findMap()
		if map then return map:FindFirstChild("CoinContainer") or map:FindFirstChild("Coins") end
		return nil
	end
	local function getNearestCoin()
		local container = findCoinContainer()
		if not container then return nil end
		local root = getRoot(localPlayer)
		if not root then return nil end
		local nearest, nearestDist = nil, math.huge
		for _, coin in ipairs(container:GetChildren()) do
			if coin:IsA("BasePart") then
				local visual = coin:FindFirstChild("CoinVisual")
				if visual and not visual:GetAttribute("Collected") then
					local dist = (root.Position - coin.Position).Magnitude
					if dist < nearestDist then nearestDist = dist nearest = coin end
				end
			end
		end
		return nearest
	end
	local function autoFarmLoop()
		while flags.autoFarmCoins and autoFarmRunning do
			local root = getRoot(localPlayer)
			local humanoid = getHumanoid(localPlayer)
			if not root or not humanoid or humanoid.Health <= 0 then autoFarmRunning = false break end
			local coin = getNearestCoin()
			if coin then
				local dist = (root.Position - coin.Position).Magnitude
				local duration = dist / 30
				if duration > 0.05 then
					humanoid:ChangeState(Enum.HumanoidStateType.Physics)
					local tween = tweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = coin.CFrame})
					tween:Play()
					tween.Completed:Wait()
				else root.CFrame = coin.CFrame end
				task.wait(0.1)
			else task.wait(0.5) end
		end
	end
	local function startAutoFarm()
		if autoFarmRunning then return end
		autoFarmRunning = true
		autoFarmThread = task.spawn(autoFarmLoop)
	end
	local function stopAutoFarm()
		autoFarmRunning = false
		if autoFarmThread then task.cancel(autoFarmThread) autoFarmThread = nil end
	end
	local function getPredictedPosition(target)
		if not target or not target.Character then return Vector3.new(0,0,0) end
		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return Vector3.new(0,0,0) end
		local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new(0,0,0)
		return hrp.Position + vel * 0.028
	end
	local function gunSilentAim()
		local char = localPlayer.Character
		if not char then return end
		local target = findMurderer()
		if not target or not target.Character then return end
		local mHRP = target.Character:FindFirstChild("HumanoidRootPart")
		local lHRP = char:FindFirstChild("HumanoidRootPart")
		if not mHRP or not lHRP then return end
		if not char:FindFirstChild("Gun") then
			local backpack = localPlayer:FindFirstChild("Backpack")
			if backpack then
				local gun = backpack:FindFirstChild("Gun")
				if gun then
					local humanoid = getHumanoid(localPlayer)
					if humanoid then pcall(function() humanoid:EquipTool(gun) end) task.wait(0.1) end
				end
			end
		end
		local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
		if not gun then return end
		local predPos = getPredictedPosition(target)
		local args = { CFrame.new(lHRP.Position, predPos), CFrame.new(predPos) }
		if gun:FindFirstChild("Shoot") then pcall(function() gun.Shoot:FireServer(unpack(args)) end) end
	end
	local function grabGun()
		local root = getRoot(localPlayer)
		if not root then return end
		local map = findMap()
		if not map then return end
		local gunDrop = map:FindFirstChild("GunDrop")
		if gunDrop and gunDrop:IsA("BasePart") and firetouchinterest then
			pcall(function()
				firetouchinterest(gunDrop, root, 1)
				firetouchinterest(gunDrop, root, 0)
			end)
		end
	end
	local function executeThrowAtNearest()
		local char = localPlayer.Character
		local humanoid = getHumanoid(localPlayer)
		if not char or not humanoid then return end
		local knife = char:FindFirstChild("Knife")
		if not knife then
			local backpack = localPlayer:FindFirstChild("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				humanoid:EquipTool(backpack.Knife)
				task.wait(0.1)
				knife = char:FindFirstChild("Knife")
			end
		end
		if not knife or not knife:FindFirstChild("Throw") then return end
		local myRoot = getRoot(localPlayer)
		if not myRoot then return end
		local target, dist = nil, 1000
		for _, v in ipairs(playersService:GetPlayers()) do
			if v ~= localPlayer then
				local enemyRoot = getRoot(v)
				if enemyRoot then
					local h = getHumanoid(v)
					if h and h.Health > 0 then
						local mag = (myRoot.Position - enemyRoot.Position).Magnitude
						if mag < dist then dist = mag target = enemyRoot end
					end
				end
			end
		end
		if target then
			local prediction = target.Position + (target.AssemblyLinearVelocity * 0.05 * (dist / 100))
			local throwCFrame = CFrame.new(myRoot.Position, prediction)
			knife.Throw:FireServer(throwCFrame, prediction)
		end
	end
	local function killAll()
		local char = localPlayer.Character
		local humanoid = getHumanoid(localPlayer)
		if not char or not humanoid then return end
		local knife = char:FindFirstChild("Knife")
		if not knife then
			local backpack = localPlayer:FindFirstChild("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				humanoid:EquipTool(backpack.Knife)
				task.wait(0.1)
				knife = char:FindFirstChild("Knife")
			end
		end
		if not knife or not knife:IsA("Tool") then return end
		local handle = knife:FindFirstChild("Handle")
		local stab = knife:FindFirstChild("Stab")
		if not handle then return end
		for _, v in ipairs(playersService:GetPlayers()) do
			if v ~= localPlayer then
				local enemyRoot = getRoot(v)
				if enemyRoot then
					pcall(function()
						firetouchinterest(handle, enemyRoot, 1)
						firetouchinterest(handle, enemyRoot, 0)
						if stab then stab:FireServer(enemyRoot.Position) end
					end)
					task.wait(0.1)
				end
			end
		end
	end
	local function killAura()
		local root = getRoot(localPlayer)
		local char = localPlayer.Character
		if not root or not char then return end
		local knife = char:FindFirstChild("Knife")
		if not knife then
			local backpack = localPlayer:FindFirstChild("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				local humanoid = getHumanoid(localPlayer)
				if humanoid then humanoid:EquipTool(backpack.Knife) task.wait(0.1) knife = char:FindFirstChild("Knife") end
			end
		end
		if not knife or not knife:IsA("Tool") then return end
		local handle = knife:FindFirstChild("Handle")
		if not handle then return end
		local range = flags.killAuraRange or 15
		for _, player in ipairs(playersService:GetPlayers()) do
			if player ~= localPlayer then
				local targetRoot = getRoot(player)
				if targetRoot and (root.Position - targetRoot.Position).Magnitude <= range then
					pcall(function()
						knife:Activate()
						if firetouchinterest then
							firetouchinterest(handle, targetRoot, 1)
							firetouchinterest(targetRoot, handle, 0)
						end
					end)
				end
			end
		end
	end
	local function applyHitbox()
		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= localPlayer and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if root then
					if flags.hitboxExpand then
						root.Size = Vector3.new(flags.hitboxSize, flags.hitboxSize, flags.hitboxSize)
						root.Transparency = flags.hitboxVisible and 0.5 or 1
						root.CanCollide = false
					else
						root.Size = Vector3.new(2, 2, 1)
						root.Transparency = 1
						root.CanCollide = false
					end
				end
			end
		end
	end
	task.spawn(function()
		while true do
			if flags.hitboxExpand then pcall(applyHitbox) end
			task.wait(0.2)
		end
	end)
	local function applyMovement()
		local humanoid = getHumanoid(localPlayer)
		if not humanoid then return end
		pcall(function()
			if flags.speedEnabled then humanoid.WalkSpeed = math.max(16, math.min(50, flags.speedValue))
			else humanoid.WalkSpeed = 16 end
		end)
		pcall(function()
			if flags.jumpEnabled then humanoid.JumpPower = math.max(50, math.min(120, flags.jumpValue))
			else humanoid.JumpPower = 50 end
		end)
	end
	local noclipConnection
	local function toggleNoclip(state)
		if noclipConnection then pcall(noclipConnection.Disconnect, noclipConnection) noclipConnection = nil end
		if state then
			noclipConnection = runService.Stepped:Connect(function()
				local char = localPlayer.Character
				if char then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end)
		end
	end
	task.spawn(function()
		while true do
			if flags.killAura then pcall(killAura) end
			if flags.autoShoot then pcall(gunSilentAim) end
			if flags.autoGrabGun then pcall(grabGun) end
			if flags.autoKnifeThrow and getPlayerRole(localPlayer) == "Murderer" then pcall(executeThrowAtNearest) end
			pcall(applyMovement)
			task.wait(0.15)
		end
	end)
	localPlayer.CharacterAdded:Connect(function()
		task.wait(0.5)
		if flags.noclipEnabled then toggleNoclip(true) end
		if flags.godmode then applyGodmode(true) end
	end)
	playersService.PlayerRemoving:Connect(function(player)
		removeHighlight(player)
		removeTag(player)
	end)

	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_MM2", "Murder Mystery 2")

	local visualsTab = window:Tab({ Title = "👁️ Visuals", Icon = "eye" })
	local farmTab = window:Tab({ Title = "🪙 Farm", Icon = "coins" })
	local combatTab = window:Tab({ Title = "⚔️ Combat", Icon = "swords" })
	local teleportTab = window:Tab({ Title = "🌀 Teleports", Icon = "map-pin" })
	local playerTab = window:Tab({ Title = "👤 Player", Icon = "user" })
	local creditsTab = window:Tab({ Title = "📜 Credits", Icon = "info" })

	visualsTab:Section({ Title = "🎯 ESP" })
	visualsTab:Toggle({
		Title = "⚡ ESP ALL", Desc = "🔴 Murderer | 🔵 Sheriff | 🟢 Innocent",
		Value = flags.espAll,
		Callback = function(state)
			flags.espAll = state
			saveAll()
			if not state then
				for player, _ in pairs(highlights) do removeHighlight(player) removeTag(player) end
			end
		end
	})
	visualsTab:Toggle({
		Title = "🔫 Gun Drop ESP", Desc = "Resalta la pistola caída",
		Value = flags.espGun,
		Callback = function(state) flags.espGun = state saveAll() end
	})
	visualsTab:Section({ Title = "🔔 Notificaciones" })
	visualsTab:Toggle({
		Title = "🔪 Notify Murderer", Desc = "Notifica cuando aparece el asesino",
		Value = flags.notifyMurderer,
		Callback = function(state) flags.notifyMurderer = state saveAll() end
	})
	visualsTab:Toggle({
		Title = "🔫 Notify Sheriff", Desc = "Notifica cuando aparece el sheriff",
		Value = flags.notifySheriff,
		Callback = function(state) flags.notifySheriff = state saveAll() end
	})
	visualsTab:Toggle({
		Title = "🎭 Instant Role Reveal", Desc = "Muestra tu rol al inicio de la ronda",
		Value = flags.instantRole,
		Callback = function(state) flags.instantRole = state saveAll() end
	})

	farmTab:Section({ Title = "💰 Auto Farm" })
	farmTab:Toggle({
		Title = "🪙 Auto Farm Coins (Mejorado)", Desc = "Farmea monedas automáticamente",
		Value = flags.autoFarmCoins,
		Callback = function(state)
			flags.autoFarmCoins = state
			saveAll()
			if state then coinsReach(true) startAutoFarm()
			else stopAutoFarm() coinsReach(false) end
		end
	})

	combatTab:Section({ Title = "🔪 Murderer" })
	combatTab:Toggle({
		Title = "💀 Knife Kill Aura", Desc = "Ataca a jugadores cercanos",
		Value = flags.killAura,
		Callback = function(state) flags.killAura = state saveAll() end
	})
	local rangeLabel = combatTab:Paragraph({ Title = "📊 Kill Aura Range", Desc = "Current: " .. tostring(flags.killAuraRange) })
	combatTab:Button({ Title = "➕ Range", Callback = function()
		if flags.killAuraRange < 50 then flags.killAuraRange = flags.killAuraRange + 1 saveAll() rangeLabel:SetDesc("Current: " .. tostring(flags.killAuraRange)) end
	end })
	combatTab:Button({ Title = "➖ Range", Callback = function()
		if flags.killAuraRange > 5 then flags.killAuraRange = flags.killAuraRange - 1 saveAll() rangeLabel:SetDesc("Current: " .. tostring(flags.killAuraRange)) end
	end })
	combatTab:Button({ Title = "💀 Kill All", Callback = function() killAll() end })
	combatTab:Toggle({
		Title = "🔪 Auto Knife Throw", Desc = "Lanza el cuchillo al más cercano",
		Value = flags.autoKnifeThrow,
		Callback = function(state) flags.autoKnifeThrow = state saveAll() end
	})

	combatTab:Section({ Title = "🔫 Sheriff" })
	combatTab:Toggle({
		Title = "🎯 Gun Silent Aim", Desc = "Dispara al asesino sin mover la cámara",
		Value = flags.gunSilentAim,
		Callback = function(state) flags.gunSilentAim = state saveAll() end
	})
	combatTab:Toggle({
		Title = "🎯 Auto Shoot Murderer", Desc = "Dispara automáticamente al asesino",
		Value = flags.autoShoot,
		Callback = function(state) flags.autoShoot = state saveAll() end
	})
	combatTab:Toggle({
		Title = "🤚 Auto Grab Gun", Desc = "Recoge la pistola automáticamente",
		Value = flags.autoGrabGun,
		Callback = function(state) flags.autoGrabGun = state saveAll() end
	})

	combatTab:Section({ Title = "📦 Hitbox Expander" })
	combatTab:Toggle({
		Title = "📦 Hitbox Expand", Desc = "Expande el hitbox de los jugadores",
		Value = flags.hitboxExpand,
		Callback = function(state) flags.hitboxExpand = state saveAll() end
	})
	local hitboxLabel = combatTab:Paragraph({ Title = "📊 Hitbox Size", Desc = "Current: " .. tostring(flags.hitboxSize) })
	combatTab:Button({ Title = "➕ Hitbox Size", Callback = function()
		if flags.hitboxSize < 20 then flags.hitboxSize = flags.hitboxSize + 1 saveAll() hitboxLabel:SetDesc("Current: " .. tostring(flags.hitboxSize)) end
	end })
	combatTab:Button({ Title = "➖ Hitbox Size", Callback = function()
		if flags.hitboxSize > 1 then flags.hitboxSize = flags.hitboxSize - 1 saveAll() hitboxLabel:SetDesc("Current: " .. tostring(flags.hitboxSize)) end
	end })
	combatTab:Toggle({
		Title = "📦 Hitbox Visible", Desc = "Muestra el hitbox expandido",
		Value = flags.hitboxVisible,
		Callback = function(state) flags.hitboxVisible = state saveAll() end
	})

	teleportTab:Section({ Title = "🚀 Quick TP" })
	teleportTab:Button({ Title = "⬇️ Teleport to Gun Drop", Callback = function()
		local root = getRoot(localPlayer)
		if not root then return end
		for _, desc in ipairs(workspaceService:GetDescendants()) do
			if desc.Name == "GunDrop" and desc:IsA("BasePart") then
				root.CFrame = desc.CFrame + Vector3.new(0, 3, 0)
				WindUI:Notify({ Title = "Teleport", Content = "✅ Teleported to gun", Duration = 2 })
				return
			end
		end
		WindUI:Notify({ Title = "Teleport", Content = "❌ No gun drop", Duration = 2 })
	end })
	teleportTab:Button({ Title = "🔴 Teleport to Murderer", Callback = function()
		local target = findMurderer()
		local root = getRoot(localPlayer)
		local targetRoot = target and getRoot(target)
		if root and targetRoot then
			root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
			WindUI:Notify({ Title = "Teleport", Content = "✅ Teleported to murderer", Duration = 2 })
		else WindUI:Notify({ Title = "Teleport", Content = "❌ Murderer not found", Duration = 2 }) end
	end })
	teleportTab:Button({ Title = "🔵 Teleport to Sheriff", Callback = function()
		local target = findSheriff()
		local root = getRoot(localPlayer)
		local targetRoot = target and getRoot(target)
		if root and targetRoot then
			root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
			WindUI:Notify({ Title = "Teleport", Content = "✅ Teleported to sheriff", Duration = 2 })
		else WindUI:Notify({ Title = "Teleport", Content = "❌ Sheriff not found", Duration = 2 }) end
	end })

	playerTab:Section({ Title = "🏃 Movement" })
	playerTab:Toggle({
		Title = "⚡ Custom WalkSpeed (Max: 50)", Value = flags.speedEnabled,
		Callback = function(state) flags.speedEnabled = state saveAll() pcall(applyMovement) end
	})
	local speedLabel = playerTab:Paragraph({ Title = "📊 WalkSpeed Value", Desc = "Current: " .. tostring(flags.speedValue) })
	playerTab:Button({ Title = "➕ WalkSpeed", Callback = function()
		if flags.speedValue < 50 then flags.speedValue = flags.speedValue + 1 saveAll() speedLabel:SetDesc("Current: " .. tostring(flags.speedValue)) if flags.speedEnabled then pcall(applyMovement) end end
	end })
	playerTab:Button({ Title = "➖ WalkSpeed", Callback = function()
		if flags.speedValue > 16 then flags.speedValue = flags.speedValue - 1 saveAll() speedLabel:SetDesc("Current: " .. tostring(flags.speedValue)) if flags.speedEnabled then pcall(applyMovement) end end
	end })
	playerTab:Toggle({
		Title = "🚀 Custom JumpPower", Value = flags.jumpEnabled,
		Callback = function(state) flags.jumpEnabled = state saveAll() pcall(applyMovement) end
	})
	local jumpLabel = playerTab:Paragraph({ Title = "📊 JumpPower Value", Desc = "Current: " .. tostring(flags.jumpValue) })
	playerTab:Button({ Title = "➕ JumpPower", Callback = function()
		if flags.jumpValue < 120 then flags.jumpValue = flags.jumpValue + 1 saveAll() jumpLabel:SetDesc("Current: " .. tostring(flags.jumpValue)) if flags.jumpEnabled then pcall(applyMovement) end end
	end })
	playerTab:Button({ Title = "➖ JumpPower", Callback = function()
		if flags.jumpValue > 50 then flags.jumpValue = flags.jumpValue - 1 saveAll() jumpLabel:SetDesc("Current: " .. tostring(flags.jumpValue)) if flags.jumpEnabled then pcall(applyMovement) end end
	end })

	playerTab:Section({ Title = "👻 God Mode" })
	playerTab:Toggle({
		Title = "🌀 Noclip", Desc = "Atraviesa paredes",
		Value = flags.noclipEnabled,
		Callback = function(state) flags.noclipEnabled = state saveAll() toggleNoclip(state) end
	})
	playerTab:Toggle({
		Title = "❤️ Godmode", Desc = "Restaura tu vida automáticamente",
		Value = flags.godmode,
		Callback = function(state) flags.godmode = state saveAll() applyGodmode(state) end
	})
	playerTab:Section({ Title = "🛡️ Protección" })
	playerTab:Toggle({
		Title = "🛡️ Anti Silent Aim", Desc = "Protege contra silent aim",
		Value = flags.antiSilentAim,
		Callback = function(state) flags.antiSilentAim = state saveAll() end
	})

	creditsTab:Section({ Title = "⚡ POTENT HUB" })
	creditsTab:Paragraph({ Title = "👑 Owner", Desc = "POTENT HUB" })
	creditsTab:Paragraph({ Title = "🎮 Game", Desc = "Murder Mystery 2" })

	WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ Murder Mystery 2 loaded!", Duration = 4 })
end

-- ============================================================
-- ========== JUEGO 4: KITTEN FARM ==========
-- ============================================================
local function runKittenFarm()
	local LocalPlayer = playersService.LocalPlayer
	local TARGET_PLACE_ID = 77813828595591

	local Loops = {}
	local antiAfkConn = nil

	local sessionStart = tick()
	local sessionStartMoney = 0
	local sessionStartYarn = 0
	local lastRebirthNotified = -1
	local webhookUrl = ""

	local function getOwnPlot()
		local plots = workspaceService:FindFirstChild("Plots")
		if not plots then return nil end
		for _, p in ipairs(plots:GetChildren()) do
			if p:GetAttribute("Owner") == LocalPlayer.UserId then
				return p
			end
		end
		return nil
	end

	local function getHRP()
		local char = LocalPlayer.Character
		return char and char:FindFirstChild("HumanoidRootPart")
	end

	local function pressButton(name)
		local plot = getOwnPlot()
		if not plot then return false end
		local buttons = plot:FindFirstChild("Buttons")
		local btn = buttons and buttons:FindFirstChild(name)
		local press = btn and btn:FindFirstChild("Press")
		local hrp = getHRP()
		if not press or not hrp then return false end
		pcall(function()
			customFireTouch(hrp, press, 1)
			task.wait(0.08)
			customFireTouch(hrp, press, 0)
		end)
		return true
	end

	local function runAutoLoop(id, isActive, fn, interval)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
		Loops[id] = task.spawn(function()
			while isActive() do
				pcall(fn)
				task.wait(interval or 1)
			end
			Loops[id] = nil
		end)
	end

	local function stopLoop(id)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
	end

	local function setAntiAFK(state)
		if state then
			if antiAfkConn then antiAfkConn:Disconnect() end
			pcall(function()
				if getconnections then
					for _, c in ipairs(getconnections(LocalPlayer.Idled)) do c:Disable() end
				end
			end)
			antiAfkConn = LocalPlayer.Idled:Connect(function()
				pcall(function()
					virtualUser:CaptureController()
					virtualUser:ClickButton2(Vector2.new())
				end)
			end)
		else
			if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
		end
	end

	local function getMoney()
		local m = LocalPlayer:FindFirstChild("Money")
		return m and m.Value or 0
	end

	local function getYarn()
		local y = LocalPlayer:FindFirstChild("Yarn")
		return y and y.Value or 0
	end

	local function getRebirths()
		local r = LocalPlayer:FindFirstChild("Rebirths") or LocalPlayer:FindFirstChild("Prestige")
		return r and r.Value or 0
	end

	local function sendWebhook(title, description, color)
		if not webhookUrl or webhookUrl == "" then return end
		local payload = {
			username = "Potent Hub",
			embeds = {{
				title = title,
				description = description,
				color = color or 16766720,
				footer = { text = "Potent Hub | Kitten Farm" },
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			}},
		}
		pcall(function()
			customHttpPost(webhookUrl, httpService:JSONEncode(payload), "application/json")
		end)
	end

	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_KITTEN_FARM", "Kitten Farm")

	local mainTab = window:Tab({ Title = "🏠 Main", Icon = "house" })
	local farmingTab = window:Tab({ Title = "🚜 Farming", Icon = "tractor" })
	local inventoryTab = window:Tab({ Title = "🎒 Inventory", Icon = "backpack" })
	local rebirthTab = window:Tab({ Title = "🔄 Rebirth", Icon = "refresh-cw" })
	local serverTab = window:Tab({ Title = "🌐 Server", Icon = "globe" })
	local webhookTab = window:Tab({ Title = "🔔 Webhook", Icon = "bell" })
	local settingsTab = window:Tab({ Title = "⚙️ Settings", Icon = "settings" })

	mainTab:Section({ Title = "ℹ️ Game Info" })
	mainTab:Paragraph({ Title = "Game", Desc = "Kitten Farm" })
	mainTab:Paragraph({ Title = "PlaceId", Desc = tostring(TARGET_PLACE_ID) })

	local uptimeParagraph = mainTab:Paragraph({ Title = "⏱️ Uptime", Desc = "0s" })
	local statusParagraph = mainTab:Paragraph({ Title = "📊 Status", Desc = "Loading..." })

	mainTab:Section({ Title = "📈 Session Stats" })
	local moneyPerHourParagraph = mainTab:Paragraph({ Title = "💰 Money / Hour", Desc = "Calculating..." })
	local yarnPerHourParagraph = mainTab:Paragraph({ Title = "🧶 Yarn / Hour", Desc = "Calculating..." })
	local totalGainedParagraph = mainTab:Paragraph({ Title = "📊 Total Gained", Desc = "Money: 0 | Yarn: 0" })

	mainTab:Button({
		Title = "🔄 Reset Session Stats",
		Callback = function()
			sessionStart = tick()
			sessionStartMoney = getMoney()
			sessionStartYarn = getYarn()
			WindUI:Notify({ Title = "Stats Reset", Content = "Session stats reset", Duration = 2 })
		end,
	})

	task.spawn(function()
		task.wait(1.5)
		sessionStartMoney = getMoney()
		sessionStartYarn = getYarn()
		lastRebirthNotified = getRebirths()

		while true do
			task.wait(1)
			pcall(function()
				local elapsed = math.floor(tick() - sessionStart)
				uptimeParagraph:SetDesc(string.format("%dh %dm %ds",
					math.floor(elapsed / 3600),
					math.floor((elapsed % 3600) / 60),
					elapsed % 60
				))

				local plot = getOwnPlot()
				local curMoney = getMoney()
				local curYarn = getYarn()

				statusParagraph:SetDesc(string.format(
					"Plot: %s | Cash: %s | Yarn: %s",
					plot and plot.Name or "?",
					tostring(curMoney),
					tostring(curYarn)
				))

				local hoursElapsed = math.max((tick() - sessionStart) / 3600, 0.001)
				local moneyGained = curMoney - sessionStartMoney
				local yarnGained = curYarn - sessionStartYarn
				local moneyRate = math.floor(moneyGained / hoursElapsed)
				local yarnRate = math.floor(yarnGained / hoursElapsed)

				moneyPerHourParagraph:SetDesc(tostring(moneyRate) .. " /hr")
				yarnPerHourParagraph:SetDesc(tostring(yarnRate) .. " /hr")
				totalGainedParagraph:SetDesc(string.format("Money: %d | Yarn: %d", moneyGained, yarnGained))
			end)
		end
	end)

	farmingTab:Section({ Title = "🧶 Resource Collecting" })
	local autoCollectYarn = false
	farmingTab:Toggle({
		Title = "Auto Collect Yarn",
		Desc = "Fires Yarn.Collect remote for nearby yarn every 1s",
		Value = false,
		Callback = function(state)
			autoCollectYarn = state
			if state then
				runAutoLoop("AutoCollectYarn", function() return autoCollectYarn end, function()
					local folder = workspaceService:FindFirstChild("Yarn")
					local remotes = replicatedStorage:FindFirstChild("Remotes")
					local yarnRemote = remotes and remotes:FindFirstChild("Yarn")
					local collect = yarnRemote and yarnRemote:FindFirstChild("Collect")
					if not folder or not collect then return end
					for _, m in ipairs(folder:GetChildren()) do
						if not autoCollectYarn then break end
						pcall(function() collect:FireServer(m.Name) end)
					end
				end, 1)
			else
				stopLoop("AutoCollectYarn")
			end
		end,
	})

	local autoCollectMoney = false
	farmingTab:Toggle({
		Title = "Auto Collect Money",
		Desc = "Touches CollectCash button on your plot every 1s",
		Value = false,
		Callback = function(state)
			autoCollectMoney = state
			if state then
				runAutoLoop("AutoCollectMoney", function() return autoCollectMoney end, function()
					pressButton("CollectCash")
				end, 1)
			else
				stopLoop("AutoCollectMoney")
			end
		end,
	})

	farmingTab:Section({ Title = "💰 Selling" })
	local autoDepositYarn = false
	farmingTab:Toggle({
		Title = "Auto Deposit Yarn",
		Desc = "Touches DepositYarn button on your plot every 1s",
		Value = false,
		Callback = function(state)
			autoDepositYarn = state
			if state then
				runAutoLoop("AutoDepositYarn", function() return autoDepositYarn end, function()
					pressButton("DepositYarn")
				end, 1)
			else
				stopLoop("AutoDepositYarn")
			end
		end,
	})

	farmingTab:Section({ Title = "🎁 Daily Rewards" })
	local autoClaimDaily = false
	farmingTab:Toggle({
		Title = "Auto Claim Daily Rewards",
		Desc = "Attempts to claim any daily / streak / login reward",
		Value = false,
		Callback = function(state)
			autoClaimDaily = state
			if state then
				runAutoLoop("AutoClaimDaily", function() return autoClaimDaily end, function()
					local remotes = replicatedStorage:FindFirstChild("Remotes")
					if not remotes then return end
					local candidates = {
						"ClaimDaily", "ClaimDailyReward", "DailyReward",
						"ClaimStreak", "ClaimStreakReward",
						"ClaimLogin", "ClaimLoginReward",
						"ClaimFreeReward", "ClaimReward",
					}
					for _, remoteName in ipairs(candidates) do
						local remote = remotes:FindFirstChild(remoteName)
						if remote then
							pcall(function()
								if remote:IsA("RemoteEvent") then
									remote:FireServer()
								elseif remote:IsA("RemoteFunction") then
									remote:InvokeServer()
								end
							end)
						end
					end
				end, 60)
			else
				stopLoop("AutoClaimDaily")
			end
		end,
	})

	farmingTab:Button({
		Title = "🎁 Claim Daily Now",
		Callback = function()
			local remotes = replicatedStorage:FindFirstChild("Remotes")
			if not remotes then
				WindUI:Notify({ Title = "Daily", Content = "❌ Remotes folder not found", Duration = 3 })
				return
			end
			local claimed = 0
			local candidates = {
				"ClaimDaily", "ClaimDailyReward", "DailyReward",
				"ClaimStreak", "ClaimStreakReward",
				"ClaimLogin", "ClaimLoginReward",
				"ClaimFreeReward", "ClaimReward",
			}
			for _, remoteName in ipairs(candidates) do
				local remote = remotes:FindFirstChild(remoteName)
				if remote then
					local ok = pcall(function()
						if remote:IsA("RemoteEvent") then remote:FireServer()
						elseif remote:IsA("RemoteFunction") then remote:InvokeServer() end
					end)
					if ok then claimed = claimed + 1 end
				end
			end
			WindUI:Notify({
				Title = "Daily",
				Content = claimed > 0 and ("✅ Fired " .. claimed .. " reward remotes") or "⚠️ No known reward remotes",
				Duration = 3,
			})
		end,
	})

	inventoryTab:Section({ Title = "🐱 Kitten Purchasing" })
	local autoBuy1, autoBuy5, autoBuy25, autoBuy100 = false, false, false, false

	inventoryTab:Toggle({
		Title = "Auto Buy 1 Kitten", Value = false,
		Callback = function(state)
			autoBuy1 = state
			if state then runAutoLoop("AutoBuy1", function() return autoBuy1 end, function() pressButton("Buy1") end, 1)
			else stopLoop("AutoBuy1") end
		end,
	})

	inventoryTab:Toggle({
		Title = "Auto Buy 5 Kittens", Value = false,
		Callback = function(state)
			autoBuy5 = state
			if state then runAutoLoop("AutoBuy5", function() return autoBuy5 end, function() pressButton("Buy5") end, 1)
			else stopLoop("AutoBuy5") end
		end,
	})

	inventoryTab:Toggle({
		Title = "Auto Buy 25 Kittens", Value = false,
		Callback = function(state)
			autoBuy25 = state
			if state then runAutoLoop("AutoBuy25", function() return autoBuy25 end, function() pressButton("Buy25") end, 1)
			else stopLoop("AutoBuy25") end
		end,
	})

	inventoryTab:Toggle({
		Title = "Auto Buy 100 Kittens", Value = false,
		Callback = function(state)
			autoBuy100 = state
			if state then runAutoLoop("AutoBuy100", function() return autoBuy100 end, function() pressButton("Buy100") end, 1)
			else stopLoop("AutoBuy100") end
		end,
	})

	inventoryTab:Section({ Title = "📈 Stat Upgrades" })
	local autoUpgradeYarnRate = false
	inventoryTab:Toggle({
		Title = "Auto Upgrade Yarn Rate", Desc = "Touches UpgradeYarnRate button every 1s", Value = false,
		Callback = function(state)
			autoUpgradeYarnRate = state
			if state then runAutoLoop("AutoUpgradeYarnRate", function() return autoUpgradeYarnRate end, function() pressButton("UpgradeYarnRate") end, 1)
			else stopLoop("AutoUpgradeYarnRate") end
		end,
	})

	local autoUpgradeBuyTier = false
	inventoryTab:Toggle({
		Title = "Auto Upgrade Buy Tier", Desc = "Touches UpgradeBuyTier button every 1s", Value = false,
		Callback = function(state)
			autoUpgradeBuyTier = state
			if state then runAutoLoop("AutoUpgradeBuyTier", function() return autoUpgradeBuyTier end, function() pressButton("UpgradeBuyTier") end, 1)
			else stopLoop("AutoUpgradeBuyTier") end
		end,
	})

	inventoryTab:Section({ Title = "📦 Misc" })
	local autoMerge = false
	inventoryTab:Toggle({
		Title = "Auto Merge", Desc = "Touches Merge button on your plot every 1s", Value = false,
		Callback = function(state)
			autoMerge = state
			if state then runAutoLoop("AutoMerge", function() return autoMerge end, function() pressButton("Button") end, 1)
			else stopLoop("AutoMerge") end
		end,
	})

	rebirthTab:Section({ Title = "🔄 Auto Rebirth" })
	local autoRebirth = false
	rebirthTab:Toggle({
		Title = "Auto Rebirth", Desc = "Checks Prestige price, rebirths when affordable (1s)", Value = false,
		Callback = function(state)
			autoRebirth = state
			if state then
				runAutoLoop("AutoRebirth", function() return autoRebirth end, function()
					local remotes = replicatedStorage:FindFirstChild("Remotes")
					local prestige = remotes and remotes:FindFirstChild("Prestige")
					local money = LocalPlayer:FindFirstChild("Money")
					if not prestige or not money then return end

					local ok, data = pcall(function() return prestige:InvokeServer("GetData") end)
					if not ok or type(data) ~= "table" then return end
					if data.Maxed then return end
					if typeof(data.Price) == "number" and money.Value >= data.Price then
						pcall(function() prestige:InvokeServer("Prestige") end)
					end
				end, 1)
			else
				stopLoop("AutoRebirth")
			end
		end,
	})

	rebirthTab:Button({
		Title = "🔄 Rebirth Now",
		Callback = function()
			local remotes = replicatedStorage:FindFirstChild("Remotes")
			local prestige = remotes and remotes:FindFirstChild("Prestige")
			if prestige then
				local ok = pcall(function() prestige:InvokeServer("Prestige") end)
				WindUI:Notify({ Title = "Rebirth", Content = ok and "✅ Rebirth fired" or "❌ Failed", Duration = 3 })
			end
		end,
	})

	settingsTab:Section({ Title = "⚙️ System" })
	settingsTab:Toggle({
		Title = "Anti-AFK", Value = true,
		Callback = function(state) setAntiAFK(state) end
	})
	setAntiAFK(true)

	settingsTab:Button({
		Title = "🗑️ Unload GUI",
		Callback = function()
			for id, loop in pairs(Loops) do
				if type(loop) == "thread" then task.cancel(loop) end
			end
			table.clear(Loops)
			if antiAfkConn then antiAfkConn:Disconnect() end
			window:Destroy()
		end,
	})

	WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ Kitten Farm loaded!", Duration = 4 })
end

-- ============================================================
-- ========== JUEGO 5: SPEED KEYBOARD ESCAPE ==========
-- ============================================================
local function runSpeedKeyboardEscape()
	local EXACT_NAMES = {
		LavaBottom = true, LavaCollide = true, LavaPart = true, LavaTop = true,
		Decorations = true, Tsunami1 = true, Tsunami = true, TsunamiEnd = true,
		TsunamiSpawn = true, MovingWalls = true,
		MovingWall1 = true, MovingWall2 = true, MovingWall3 = true,
		MovingWall4 = true, MovingWall5 = true, MovingWall6 = true,
		Ball1 = true, Arrows = true, FanEffects = true,
		Lava_Stage3 = true, Trap_Stage13 = true, Lava = true, Wind = true,
		Twomps = true, Twomp = true, Cracks = true,
	}

	local WIN1_NAMES = {
		NPC_Zone5 = true, NPC5_AttackZone = true, Sol = true, SpawnNpc5 = true,
	}

	local function shouldRemove(name, selectedRoute)
		if EXACT_NAMES[name] then return true end
		if selectedRoute then
			local isWin1 = selectedRoute == "1.25B" or selectedRoute == "2B" or
				selectedRoute == "3.5B" or selectedRoute == "5.5B" or
				selectedRoute == "8.5B" or selectedRoute == "16B" or
				selectedRoute == "25B" or selectedRoute == "40B" or
				selectedRoute == "65B" or selectedRoute == "100B" or
				selectedRoute == "200B" or selectedRoute == "1T"
			if isWin1 and WIN1_NAMES[name] then return true end
		end
		return false
	end

	local function removeObstacles(selectedRoute)
		for _, d in ipairs(workspaceService:GetDescendants()) do
			if shouldRemove(d.Name, selectedRoute) then
				pcall(function() d:Destroy() end)
			end
		end
	end

	local RAW_W2 = {
		["150K"] = {
			-397.56, 506.15, -51.07,  -401.05, 505.25, 62.40,  -402.06, 505.25, 127.12,
			-398.16, 501.32, 186.94,  -413.71, 503.32, 189.34,
		},
		["400K"] = {
			-397.22, 506.15, -42.89,  -401.83, 505.25, 63.62,  -401.77, 504.97, 125.04,
			-397.71, 501.32, 187.41,  -397.13, 501.32, 434.70,  -415.54, 503.32, 432.77,
		},
		["600K"] = {
			-396.23, 506.15, -40.54,  -401.96, 505.25, 64.27,  -402.36, 505.06, 126.37,
			-396.47, 501.32, 193.79,  -395.29, 501.32, 433.07,  -348.99, 505.74, 493.54,
			-349.08, 528.25, 579.91,  -457.30, 528.25, 578.07,  -453.95, 555.25, 460.06,
			-349.19, 555.25, 465.78,  -347.64, 582.32, 577.99,  -455.45, 582.32, 574.65,
			-450.83, 609.32, 463.34,  -395.87, 609.32, 466.69,  -400.53, 609.11, 607.75,
			-418.13, 611.05, 607.19,
		},
		["1M"] = {
			-397.92, 506.15, -41.16,  -401.17, 505.25, 63.32,  -403.80, 505.25, 131.83,
			-397.73, 501.32, 189.43,  -395.36, 501.32, 433.75,  -350.04, 501.91, 481.39,
			-347.63, 528.25, 580.01,  -453.45, 528.25, 576.23,  -454.15, 555.25, 460.92,
			-345.26, 555.25, 465.84,  -348.25, 582.32, 574.76,  -453.42, 582.32, 574.23,
			-451.02, 609.32, 465.54,  -396.64, 609.32, 468.94,  -400.33, 609.11, 604.41,
			-400.65, 609.11, 677.73,  -382.37, 609.11, 707.32,  -381.79, 609.11, 739.28,
			-399.59, 609.11, 782.25,  -400.40, 608.67, 841.49,  -417.27, 610.61, 842.39,
		},
	}

	local RAW_W3 = {
		["300M"] = {
			-1433.89, -159.52, -871.89, -1426.37, -154.24, -827.45, -1423.97, -124.16, -732.65,
			-1423.64, -89.19, -621.45,  -1427.91, -67.75, -524.57, -1482.27, -66.50, -515.24,
		},
		["500M"] = {
			-1432.86, -159.32, -872.44, -1428.03, -157.01, -836.28, -1426.70, -124.44, -732.69,
			-1429.19, -91.26, -627.20,  -1430.14, -68.39, -532.61, -1453.68, -68.39, -492.80,
			-1455.52, -56.93, -392.63,  -1454.35, -56.14, -20.18,  -1480.98, -54.26, -15.66,
		},
	}

	local function buildRoutes(raw)
		local out = {}
		for name, flat in pairs(raw) do
			local list = {}
			for i = 1, #flat, 3 do
				table.insert(list, Vector3.new(flat[i], flat[i + 1], flat[i + 2]))
			end
			out[name] = list
		end
		return out
	end

	local ROUTES_W2 = buildRoutes(RAW_W2)
	local ROUTES_W3 = buildRoutes(RAW_W3)

	local ROUTE_ORDER_W2 = { "150K", "400K", "600K", "1M" }
	local ROUTE_ORDER_W3 = { "300M", "500M" }

	local function makeFarmModule(routes, defaultRoute)
		local state = {
			selectedRoute = defaultRoute,
			autoFarm = false,
			flySpeed = 120,
			flyConn = nil,
			removeConn = nil,
			noclipConn = nil,
		}

		local function stopFly()
			if state.flyConn then state.flyConn:Disconnect() state.flyConn = nil end
		end
		local function stopRemove()
			if state.removeConn then state.removeConn:Disconnect() state.removeConn = nil end
		end
		local function stopNoclip()
			if state.noclipConn then state.noclipConn:Disconnect() state.noclipConn = nil end
		end

		local function startNoclip()
			stopNoclip()
			state.noclipConn = runService.Stepped:Connect(function()
				local char = playersService.LocalPlayer.Character
				if not char then return end
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end)
		end

		local function startFly()
			stopFly()
			local waypoints = routes[state.selectedRoute]
			if not waypoints or #waypoints == 0 then return end

			local idx = 1
			state.flyConn = runService.Heartbeat:Connect(function(dt)
				if not state.autoFarm then return end
				local char = playersService.LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if not root then return end
				local target = waypoints[idx]
				if not target then idx = 1 target = waypoints[1] end
				if not target then return end

				local dist = (target - root.Position).Magnitude
				if dist < 0.5 then
					root.CFrame = CFrame.new(target)
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					idx = idx + 1
					if idx > #waypoints then idx = 1 end
					return
				end

				local step = math.min(state.flySpeed * dt, dist)
				local dir = (target - root.Position).Unit
				local newPos = root.Position + dir * step
				root.CFrame = CFrame.new(newPos, newPos + dir)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		state.toggle = function(on)
			state.autoFarm = on
			if on then
				removeObstacles(state.selectedRoute)
				state.removeConn = workspaceService.DescendantAdded:Connect(function(desc)
					if state.autoFarm and shouldRemove(desc.Name, state.selectedRoute) then
						task.defer(function() pcall(function() desc:Destroy() end) end)
					end
				end)
				startNoclip()
				startFly()
			else
				stopRemove()
				stopNoclip()
				stopFly()
			end
		end

		state.setRoute = function(name)
			state.selectedRoute = name
			if state.autoFarm then stopFly() startFly() end
		end

		state.setSpeed = function(v) state.flySpeed = v end

		state.stopAll = function()
			stopRemove()
			stopNoclip()
			stopFly()
		end

		state.getRouteListOrdered = function(order)
			local out = {}
			for _, name in ipairs(order) do
				if routes[name] then table.insert(out, name) end
			end
			return out
		end

		return state
	end

	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_KEYBOARD_ESCAPE", "+1 Speed Keyboard Escape")

	local tabW2 = window:Tab({ Title = "🌍 WORLD 2", Icon = "globe" })
	local tabW3 = window:Tab({ Title = "🌍 WORLD 3", Icon = "globe" })
	local tabExtra = window:Tab({ Title = "⚙️ Extra", Icon = "settings" })

	local farmW2 = makeFarmModule(ROUTES_W2, ROUTE_ORDER_W2[1])
	local farmW3 = makeFarmModule(ROUTES_W3, ROUTE_ORDER_W3[1])

	tabW2:Section({ Title = "🏆 AUTO FARM WIN" })
	tabW2:Toggle({
		Title = "Auto Farm Win",
		Desc = "Removes obstacles, enables noclip and flies through the route.",
		Value = false,
		Callback = function(state)
			if state and farmW2.selectedRoute == "" then
				WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "Select a Win first!", Duration = 2 })
				return
			end
			farmW2.toggle(state)
		end,
	})
	tabW2:Dropdown({
		Title = "Select Win",
		Desc = "Choose a win route to farm.",
		Values = farmW2.getRouteListOrdered(ROUTE_ORDER_W2),
		Value = ROUTE_ORDER_W2[1],
		Callback = function(value) farmW2.setRoute(value) end,
	})
	tabW2:Slider({
		Title = "Fly Speed",
		Desc = "Adjust the flight speed.",
		Step = 10,
		Value = { Min = 20, Max = 500, Default = 120 },
		Callback = function(value) farmW2.setSpeed(value) end,
	})

	tabW3:Section({ Title = "🏆 AUTO FARM WIN" })
	tabW3:Toggle({
		Title = "Auto Farm Win",
		Desc = "Removes obstacles, enables noclip and flies through the route.",
		Value = false,
		Callback = function(state)
			if state and farmW3.selectedRoute == "" then
				WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "Select a Win first!", Duration = 2 })
				return
			end
			farmW3.toggle(state)
		end,
	})
	tabW3:Dropdown({
		Title = "Select Win",
		Desc = "Choose a win route to farm.",
		Values = farmW3.getRouteListOrdered(ROUTE_ORDER_W3),
		Value = ROUTE_ORDER_W3[1],
		Callback = function(value) farmW3.setRoute(value) end,
	})
	tabW3:Slider({
		Title = "Fly Speed",
		Desc = "Adjust the flight speed.",
		Step = 10,
		Value = { Min = 20, Max = 500, Default = 120 },
		Callback = function(value) farmW3.setSpeed(value) end,
	})

	local SOUND_PACKS = {
		"Premium", "Water", "Bubble", "Christmas",
		"Lava", "Honey", "Snow", "Slime",
	}

	local CONFIG_FILE = "PotentHub/extra_config.json"
	local ExtraConfig = { SoundPack = "Lava" }

	local function saveExtraConfig()
		pcall(function()
			if not writefile then return end
			local HttpService = game:GetService("HttpService")
			local data = {}
			if isfile and isfile(CONFIG_FILE) then
				data = HttpService:JSONDecode(readfile(CONFIG_FILE)) or {}
			end
			if type(data) ~= "table" then data = {} end
			data.SoundPack = ExtraConfig.SoundPack
			if not isfolder or not isfolder("PotentHub") then
				if makefolder then pcall(makefolder, "PotentHub") end
			end
			writefile(CONFIG_FILE, HttpService:JSONEncode(data))
		end)
	end

	local function loadExtraConfig()
		pcall(function()
			if isfile and isfile(CONFIG_FILE) then
				local data = game:GetService("HttpService"):JSONDecode(readfile(CONFIG_FILE))
				if type(data) == "table" and type(data.SoundPack) == "string" then
					ExtraConfig.SoundPack = data.SoundPack
				end
			end
		end)
	end

	loadExtraConfig()

	tabExtra:Section({ Title = "🔓 Admin" })
	tabExtra:Toggle({
		Title = "Unlock Admin (Visual Only)",
		Desc = "Sets HasCmdr / HasAdminAccess attributes (no real admin)",
		Value = false,
		Callback = function(state)
			pcall(function()
				playersService.LocalPlayer:SetAttribute("HasCmdr", state)
				playersService.LocalPlayer:SetAttribute("HasAdminAccess", state)
			end)
		end,
	})

	tabExtra:Section({ Title = "🔊 Sound Changer" })
	tabExtra:Dropdown({
		Title = "Sound Changer",
		Desc = "Change the equipped sound pack",
		Values = SOUND_PACKS,
		Value = ExtraConfig.SoundPack,
		Callback = function(pack)
			ExtraConfig.SoundPack = pack
			saveExtraConfig()
			pcall(function()
				playersService.LocalPlayer:SetAttribute("EquippedSoundPack", pack)
			end)
		end,
	})

	pcall(function()
		playersService.LocalPlayer:SetAttribute("EquippedSoundPack", ExtraConfig.SoundPack)
	end)

	local OLD_SOUND = "rbxassetid://88881892060452"
	local NEW_SOUND = "rbxassetid://138132180123464"

	local function replacePiegesSound()
		pcall(function()
			local pieges = workspaceService:FindFirstChild("Pieges & Lava")
			local twomps = pieges and pieges:FindFirstChild("Twomps")
			if not twomps then return end
			for _, obj in ipairs(twomps:GetDescendants()) do
				if obj:IsA("Sound") and obj.SoundId == OLD_SOUND then
					obj.SoundId = NEW_SOUND
				end
			end
		end)
	end

	replacePiegesSound()

	tabExtra:Section({ Title = "🗝️ Key Finder" })

	local KEY_NAMES = {
		SpecialKey_Normal = true,
		SpecialKey_Secret = true,
	}

	local function findNearestSpecialKey(hrp)
		local roots = {}
		local folder = workspaceService:FindFirstChild("SpecialKeys")
		if folder then
			table.insert(roots, folder)
		else
			table.insert(roots, workspaceService)
		end

		local closest, dist = nil, math.huge
		for _, root in ipairs(roots) do
			for _, obj in ipairs(root:GetDescendants()) do
				if KEY_NAMES[obj.Name] then
					local part
					if obj:IsA("BasePart") then
						part = obj
					elseif obj:IsA("Model") then
						part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
					end
					if part then
						local d = (part.Position - hrp.Position).Magnitude
						if d < dist then
							closest, dist = part, d
						end
					end
				end
			end
		end
		return closest
	end

	local autoTP = false

	task.spawn(function()
		while true do
			if autoTP then
				pcall(function()
					local char = playersService.LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local target = findNearestSpecialKey(hrp)
						if target then
							hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
						end
					end
				end)
				task.wait(0.2)
			else
				task.wait(0.1)
			end
		end
	end)

	tabExtra:Toggle({
		Title = "Auto TP to Special/Secret Key",
		Desc = "Teleports to the nearest special or secret key",
		Value = false,
		Callback = function(state)
			autoTP = state
		end,
	})

	tabExtra:Section({ Title = "🪙 Coin Farm" })

	local coinFarm = false

	task.spawn(function()
		while true do
			if coinFarm then
				local char = playersService.LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local closest, dist = nil, math.huge
					for _, obj in ipairs(workspaceService:GetDescendants()) do
						if obj.Name == "SummerCoin" then
							local part
							if obj:IsA("BasePart") then
								part = obj
							elseif obj:IsA("Model") then
								part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
							end
							if part then
								local d = (part.Position - hrp.Position).Magnitude
								if d < dist then
									closest, dist = part, d
								end
							end
						end
					end
					if closest then
						hrp.CFrame = closest.CFrame + Vector3.new(0, 2, 0)
					end
				end
				task.wait(0.3)
			else
				task.wait(0.1)
			end
		end
	end)

	tabExtra:Toggle({
		Title = "Coin Farm",
		Desc = "Teleports to nearest SummerCoin",
		Value = false,
		Callback = function(state)
			coinFarm = state
		end,
	})

	tabExtra:Section({ Title = "ℹ️ Info" })
	tabExtra:Button({
		Title = "📋 Copy Discord Link",
		Callback = function()
			customSetClipboard(DISCORD_URL)
			WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ Discord link copied!", Duration = 2 })
		end,
	})

	WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ +1 Speed Keyboard Escape loaded!", Duration = 4 })
end

-- ============================================================
-- ========== JUEGO 6: ONE TAP ==========
-- ============================================================
local function runOneTap()
	local LocalPlayer = playersService.LocalPlayer

	--// Helpers
	local function deepCopy(value)
		if type(value) ~= "table" then return value end
		local result = {}
		for key, item in pairs(value) do
			result[deepCopy(key)] = deepCopy(item)
		end
		return result
	end

	local function currentCamera()
		return workspace.CurrentCamera
	end

	local function screenCenter()
		local camera = currentCamera()
		local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	end

	local function normalizeAutoShootButton(value)
		value = tostring(value or "RMB"):upper()
		return value == "LMB" and "LMB" or "RMB"
	end

	local DefaultConfig = {
		AimMode = "Custom",
		Aim = {
			Enabled = false,
			HoldRMB = true,
			AimPoint = "Head",
			AutoShoot = false,
			AutoShootButton = "RMB",
			AutoShootRadius = 8,
			AutoShootDelay = 0.00,
			FOV = 180,
			SmoothSpeed = 40,
			MaxDistance = 1500,
			StickyTarget = false,
			StickyMultiplier = 1.35,
			Prediction = false,
			BulletSpeed = 3850,
			PredictionExtra = 0.00,
			PredictionSmoothing = 0.72,
			MaxPredictionOffset = 18,
			AdaptiveSmoothing = false,
			MicroSnapRadius = 1.5,
			TargetPriority = "Hybrid",
			SwitchDelay = 0.05,
			SwitchThreshold = 0.10,
			LockGrace = 0.16,
			ShowFOV = false,
		},
		ESP = {
			Enabled = false,
			Boxes = false,
			Names = false,
			Health = false,
			Distance = false,
			Tracers = false,
			Chams = false,
			MaxDistance = 1500,
		},
	}

	local Config = deepCopy(DefaultConfig)

	--// Runtime Integration
	local NativeWeaponClient = nil
	local NativeWeaponStatus = "Not scanned"

	local function resolveNativeWeaponClient()
		NativeWeaponClient = nil
		NativeWeaponStatus = "Native WeaponClient unavailable • mouse fallback"

		local playerScripts = LocalPlayer and LocalPlayer:FindFirstChild("PlayerScripts")
		local startScript = playerScripts and playerScripts:FindFirstChild("Start")
		local gameFolder = startScript and startScript:FindFirstChild("Game")
		local module = gameFolder and gameFolder:FindFirstChild("WeaponClient")

		if not (module and module:IsA("ModuleScript")) then
			return false
		end

		local okRequire, result = pcall(require, module)
		if okRequire and type(result) == "table" and type(result.fire) == "function" then
			NativeWeaponClient = result
			NativeWeaponStatus = "Native WeaponClient.fire ready"
			return true
		end

		return false
	end

	resolveNativeWeaponClient()

	local function localCharacter()
		return LocalPlayer and LocalPlayer.Character or nil
	end

	local function localCombatReady()
		local character = localCharacter()
		if not character or not character.Parent then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		if character:GetAttribute("deployed") ~= true then
			return false
		end
		return true
	end

	local function isMouseHeld(button)
		local inputType = button == "LMB"
			and Enum.UserInputType.MouseButton1
			or Enum.UserInputType.MouseButton2
		local ok, held = pcall(function()
			return userInputService:IsMouseButtonPressed(inputType)
		end)
		return ok and held or false
	end

	local function aimActive()
		if not Config.Aim.Enabled or not localCombatReady() then
			return false
		end
		if Config.Aim.HoldRMB then
			return isMouseHeld("RMB")
		end
		return true
	end

	local function autoShootActive()
		if not Config.Aim.AutoShoot or not localCombatReady() then
			return false
		end
		return isMouseHeld(normalizeAutoShootButton(Config.Aim.AutoShootButton))
	end

	local function isEnemyCharacter(character)
		if not character or character == localCharacter() or not character.Parent then
			return false
		end
		if not collectionService:HasTag(character, "Character") then
			return false
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		if character:FindFirstChildOfClass("ForceField") then
			return false
		end
		return true
	end

	local function iterateEnemies(callback)
		for _, character in ipairs(collectionService:GetTagged("Character")) do
			if isEnemyCharacter(character) then
				callback(character)
			end
		end
	end

	local function getPlayerFromCharacter(character)
		local ok, player = pcall(playersService.GetPlayerFromCharacter, playersService, character)
		return ok and player or nil
	end

	local function getDisplayName(character)
		local player = getPlayerFromCharacter(character)
		if player then
			if player.DisplayName and player.DisplayName ~= "" then
				return player.DisplayName
			end
			return player.Name
		end
		return character and character.Name or "Enemy"
	end

	local function getHealth(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return 0, 100
		end
		return humanoid.Health, math.max(humanoid.MaxHealth, 1)
	end

	local function worldToScreen(position)
		local camera = currentCamera()
		if not camera then
			return Vector2.zero, false, -1
		end
		local point, onScreen = camera:WorldToViewportPoint(position)
		return Vector2.new(point.X, point.Y), onScreen and point.Z > 0, point.Z
	end

	local function getCandidateParts(character)
		local parts = {}
		local names = {
			"Head", "Hitbox_Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart",
		}
		local seen = {}
		for _, name in ipairs(names) do
			local part = character:FindFirstChild(name)
			if part and part:IsA("BasePart") and not seen[part] then
				seen[part] = true
				table.insert(parts, part)
			end
		end
		return parts
	end

	local function getAimPart(character)
		local mode = tostring(Config.Aim.AimPoint or "Head")

		if mode == "Head" then
			local part = character:FindFirstChild("Head") or character:FindFirstChild("Hitbox_Head")
			if part and part:IsA("BasePart") then
				return part
			end
		elseif mode == "Torso" then
			local part = character:FindFirstChild("Torso")
				or character:FindFirstChild("UpperTorso")
				or character:FindFirstChild("HumanoidRootPart")
			if part and part:IsA("BasePart") then
				return part
			end
		elseif mode == "Closest Part" then
			local center = screenCenter()
			local bestPart = nil
			local bestDistance = math.huge
			for _, part in ipairs(getCandidateParts(character)) do
				local screen, onScreen = worldToScreen(part.Position)
				if onScreen then
					local distance = (screen - center).Magnitude
					if distance < bestDistance then
						bestDistance = distance
						bestPart = part
					end
				end
			end
			if bestPart then
				return bestPart
			end
		end

		local fallback = character:FindFirstChild("Torso")
			or character:FindFirstChild("HumanoidRootPart")
			or character:FindFirstChild("Head")
		return fallback and fallback:IsA("BasePart") and fallback or nil
	end

	local velocityCache = setmetatable({}, {__mode = "k"})

	local function getSmoothedVelocity(character, part)
		local raw = part and part.AssemblyLinearVelocity or Vector3.zero
		local entry = velocityCache[character]
		local smoothing = math.clamp(tonumber(Config.Aim.PredictionSmoothing) or 0, 0, 0.98)
		if not entry then
			entry = {Velocity = raw}
			velocityCache[character] = entry
			return raw
		end
		entry.Velocity = entry.Velocity:Lerp(raw, 1 - smoothing)
		return entry.Velocity
	end

	local function predictPosition(character, part, rawPosition, worldDistance)
		if not Config.Aim.Prediction then
			return rawPosition
		end
		local bulletSpeed = math.max(tonumber(Config.Aim.BulletSpeed) or 3850, 100)
		local extra = math.clamp(tonumber(Config.Aim.PredictionExtra) or 0, 0, 0.25)
		local travelTime = math.clamp(worldDistance / bulletSpeed + extra, 0, 0.35)
		local velocity = getSmoothedVelocity(character, part)
		local offset = velocity * travelTime
		local maxOffset = math.max(tonumber(Config.Aim.MaxPredictionOffset) or 0, 0)
		if maxOffset > 0 and offset.Magnitude > maxOffset then
			offset = offset.Unit * maxOffset
		end
		return rawPosition + offset
	end

	local function isVisible(character, position)
		local camera = currentCamera()
		local localChar = localCharacter()
		if not camera or not localChar then
			return false
		end
		local ignore = {localChar, character}
		local effects = workspace:FindFirstChild("Effects")
		if effects then
			table.insert(ignore, effects)
		end
		local viewmodel = camera:FindFirstChildWhichIsA("Model")
		if viewmodel then
			table.insert(ignore, viewmodel)
		end
		local ok, obscuring = pcall(function()
			return camera:GetPartsObscuringTarget({position}, ignore)
		end)
		return ok and #obscuring == 0
	end

	local lockedTarget = nil
	local lockedTargetLastInfo = nil
	local lockedTargetLastValidAt = 0
	local lastTargetSwitchAt = 0

	local function scoreTarget(screenDistance, worldDistance, health, maxHealth)
		local fov = math.max(tonumber(Config.Aim.FOV) or 1, 1)
		local maxDistance = math.max(tonumber(Config.Aim.MaxDistance) or 1, 1)
		local screenNorm = math.clamp(screenDistance / fov, 0, 2)
		local worldNorm = math.clamp(worldDistance / maxDistance, 0, 2)
		local healthNorm = math.clamp(health / math.max(maxHealth, 1), 0, 1)
		local priority = tostring(Config.Aim.TargetPriority or "Hybrid")
		if priority == "Distance" then
			return worldNorm
		elseif priority == "Low Health" then
			return healthNorm + screenNorm * 0.15
		elseif priority == "Crosshair" then
			return screenNorm
		end
		return screenNorm * 0.72 + worldNorm * 0.18 + healthNorm * 0.10
	end

	local function targetInfo(character, fovMultiplier)
		if not isEnemyCharacter(character) then
			return nil
		end
		local camera = currentCamera()
		if not camera then
			return nil
		end
		local part = getAimPart(character)
		if not part then
			return nil
		end
		local rawPosition = part.Position
		local worldDistance = (rawPosition - camera.CFrame.Position).Magnitude
		if worldDistance > math.max(tonumber(Config.Aim.MaxDistance) or 0, 1) then
			return nil
		end
		local position = predictPosition(character, part, rawPosition, worldDistance)
		local screenPosition, onScreen = worldToScreen(position)
		if not onScreen then
			return nil
		end
		local screenDistance = (screenPosition - screenCenter()).Magnitude
		local allowedFOV = math.max(tonumber(Config.Aim.FOV) or 0, 1) * (fovMultiplier or 1)
		if screenDistance > allowedFOV then
			return nil
		end
		if not isVisible(character, position) then
			return nil
		end
		local health, maxHealth = getHealth(character)
		return {
			Entity = character,
			Part = part,
			RawPosition = rawPosition,
			Position = position,
			ScreenPosition = screenPosition,
			ScreenDistance = screenDistance,
			WorldDistance = worldDistance,
			Health = health,
			MaxHealth = maxHealth,
			Score = scoreTarget(screenDistance, worldDistance, health, maxHealth),
		}
	end

	local function clearTarget()
		lockedTarget = nil
		lockedTargetLastInfo = nil
		lockedTargetLastValidAt = 0
	end

	local function acquireTarget()
		local now = os.clock()
		local stickyScale = Config.Aim.StickyTarget
			and math.max(tonumber(Config.Aim.StickyMultiplier) or 1, 1)
			or 1

		local lockedInfo = nil
		if lockedTarget then
			lockedInfo = targetInfo(lockedTarget, stickyScale)
			if lockedInfo then
				lockedTargetLastInfo = lockedInfo
				lockedTargetLastValidAt = now
			end
		end

		local bestInfo = nil
		iterateEnemies(function(character)
			local info = targetInfo(character, 1)
			if info and (not bestInfo or info.Score < bestInfo.Score) then
				bestInfo = info
			end
		end)

		if not lockedTarget then
			if bestInfo then
				lockedTarget = bestInfo.Entity
				lockedTargetLastInfo = bestInfo
				lockedTargetLastValidAt = now
				lastTargetSwitchAt = now
			end
			return bestInfo
		end

		if lockedInfo then
			if not bestInfo or bestInfo.Entity == lockedTarget then
				return lockedInfo
			end

			if not Config.Aim.StickyTarget then
				lockedTarget = bestInfo.Entity
				lockedTargetLastInfo = bestInfo
				lockedTargetLastValidAt = now
				lastTargetSwitchAt = now
				return bestInfo
			end

			local switchDelay = math.max(tonumber(Config.Aim.SwitchDelay) or 0, 0)
			if now - lastTargetSwitchAt < switchDelay then
				return lockedInfo
			end

			local threshold = math.clamp(tonumber(Config.Aim.SwitchThreshold) or 0, 0, 0.95)
			local requiredScore = lockedInfo.Score * (1 - threshold)
			if bestInfo.Score < requiredScore then
				lockedTarget = bestInfo.Entity
				lockedTargetLastInfo = bestInfo
				lockedTargetLastValidAt = now
				lastTargetSwitchAt = now
				return bestInfo
			end

			return lockedInfo
		end

		local grace = math.max(tonumber(Config.Aim.LockGrace) or 0, 0)
		if lockedTargetLastInfo and isEnemyCharacter(lockedTarget)
			and now - lockedTargetLastValidAt <= grace
		then
			return lockedTargetLastInfo
		end

		if bestInfo then
			lockedTarget = bestInfo.Entity
			lockedTargetLastInfo = bestInfo
			lockedTargetLastValidAt = now
			lastTargetSwitchAt = now
			return bestInfo
		end

		clearTarget()
		return nil
	end

	local lastAutoShootTarget = nil
	local lastAutoShotAttemptAt = 0
	local lastAutoShotAt = 0

	local function fireNativeOrFallback()
		if not NativeWeaponClient then
			resolveNativeWeaponClient()
		end
		if NativeWeaponClient and type(NativeWeaponClient.fire) == "function" then
			local ok = pcall(NativeWeaponClient.fire)
			if ok then
				return true
			end
			NativeWeaponClient = nil
		end
		if type(mouse1click) == "function" then
			return pcall(mouse1click)
		end
		return false
	end

	local function tryAutoShoot(info)
		if not autoShootActive() or not info or not info.Entity then
			return
		end
		if lockedTarget ~= info.Entity or not isEnemyCharacter(info.Entity) then
			return
		end
		local fresh = targetInfo(info.Entity, math.max(tonumber(Config.Aim.StickyMultiplier) or 1, 1))
		if not fresh then
			return
		end
		local screenPosition, onScreen = worldToScreen(fresh.Position)
		if not onScreen then
			return
		end
		local errorPixels = (screenPosition - screenCenter()).Magnitude
		local radius = math.clamp(tonumber(Config.Aim.AutoShootRadius) or 8, 1, 50)
		if errorPixels > radius then
			return
		end
		local now = os.clock()
		local delay = math.max(tonumber(Config.Aim.AutoShootDelay) or 0, 0)
		if lastAutoShootTarget ~= info.Entity then
			lastAutoShootTarget = info.Entity
			lastAutoShotAttemptAt = 0
		end
		if now - lastAutoShotAttemptAt < math.max(delay, 0.02) then
			return
		end
		lastAutoShotAttemptAt = now
		if fireNativeOrFallback() then
			lastAutoShotAt = now
		end
	end

	local function applyAim(dt)
		local shouldAim = aimActive()
		local shouldShoot = autoShootActive()

		if not shouldAim and not shouldShoot then
			if not localCombatReady() or (not Config.Aim.Enabled and not Config.Aim.AutoShoot) then
				clearTarget()
			end
			return
		end

		local info = acquireTarget()
		if not info then
			return
		end

		local camera = currentCamera()
		if not camera then
			return
		end

		if shouldAim then
			local current = camera.CFrame
			local desired = CFrame.lookAt(current.Position, info.Position)
			local speed = math.max(tonumber(Config.Aim.SmoothSpeed) or 0.01, 0.01)

			if Config.Aim.AdaptiveSmoothing then
				local normalized = math.clamp(info.ScreenDistance / math.max(Config.Aim.FOV, 1), 0, 1)
				speed = speed * (0.58 + math.sqrt(normalized) * 1.42)
			end

			local snapRadius = math.max(tonumber(Config.Aim.MicroSnapRadius) or 0, 0)
			local alpha = 1 - math.exp(-speed * math.max(dt, 0))
			if snapRadius > 0 and info.ScreenDistance <= snapRadius then
				alpha = 1
			end

			camera.CFrame = current:Lerp(desired, math.clamp(alpha, 0, 1))
		end

		if shouldShoot then
			tryAutoShoot(info)
		end
	end

	--// ESP / Overlay
	local function getOverlayParent()
		if type(gethui) == "function" then
			local ok, parent = pcall(gethui)
			if ok and typeof(parent) == "Instance" then
				return parent
			end
		end
		local okCore = pcall(function() return coreGui.Name end)
		if okCore then
			return coreGui
		end
		return LocalPlayer:WaitForChild("PlayerGui")
	end

	local OverlayParent = getOverlayParent()
	local oldOverlay = OverlayParent:FindFirstChild("POTENT_Overlay")
	if oldOverlay then
		oldOverlay:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "POTENT_Overlay"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 999999
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = OverlayParent

	local OverlayFolder = Instance.new("Frame")
	OverlayFolder.Name = "ESP"
	OverlayFolder.Size = UDim2.fromScale(1, 1)
	OverlayFolder.BackgroundTransparency = 1
	OverlayFolder.BorderSizePixel = 0
	OverlayFolder.Parent = ScreenGui

	local espObjects = {}

	local function makeStroke(parent, thickness)
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = thickness or 1
		stroke.Color = Color3.fromRGB(255, 78, 78)
		stroke.Transparency = 0
		stroke.Parent = parent
		return stroke
	end

	local function makeText(parent)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamMedium
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.TextStrokeTransparency = 0.35
		label.TextSize = 13
		label.ZIndex = 10
		label.Parent = parent
		return label
	end

	local function createESP(character)
		if espObjects[character] then
			return espObjects[character]
		end

		local holder = Instance.new("Frame")
		holder.Name = "EntityESP"
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.Visible = false
		holder.ZIndex = 5
		holder.Parent = OverlayFolder

		local box = Instance.new("Frame")
		box.Name = "Box"
		box.BackgroundTransparency = 1
		box.BorderSizePixel = 0
		box.Size = UDim2.fromScale(1, 1)
		box.ZIndex = 5
		box.Parent = holder
		local boxStroke = makeStroke(box, 1.5)

		local nameLabel = makeText(holder)
		nameLabel.Name = "Name"
		nameLabel.AnchorPoint = Vector2.new(0.5, 1)
		nameLabel.Position = UDim2.new(0.5, 0, 0, -3)
		nameLabel.Size = UDim2.new(1.8, 0, 0, 18)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center

		local infoLabel = makeText(holder)
		infoLabel.Name = "Info"
		infoLabel.AnchorPoint = Vector2.new(0.5, 0)
		infoLabel.Position = UDim2.new(0.5, 0, 1, 3)
		infoLabel.Size = UDim2.new(1.9, 0, 0, 18)
		infoLabel.TextXAlignment = Enum.TextXAlignment.Center

		local hpBack = Instance.new("Frame")
		hpBack.Name = "HealthBack"
		hpBack.AnchorPoint = Vector2.new(1, 0)
		hpBack.Position = UDim2.new(0, -4, 0, 0)
		hpBack.Size = UDim2.new(0, 4, 1, 0)
		hpBack.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		hpBack.BorderSizePixel = 0
		hpBack.ZIndex = 6
		hpBack.Parent = holder

		local hpFill = Instance.new("Frame")
		hpFill.Name = "Health"
		hpFill.AnchorPoint = Vector2.new(0, 1)
		hpFill.Position = UDim2.new(0, 0, 1, 0)
		hpFill.Size = UDim2.fromScale(1, 1)
		hpFill.BackgroundColor3 = Color3.fromRGB(85, 255, 110)
		hpFill.BorderSizePixel = 0
		hpFill.ZIndex = 7
		hpFill.Parent = hpBack

		local tracer = Instance.new("Frame")
		tracer.Name = "Tracer"
		tracer.AnchorPoint = Vector2.new(0, 0.5)
		tracer.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
		tracer.BorderSizePixel = 0
		tracer.Size = UDim2.fromOffset(0, 1)
		tracer.Visible = false
		tracer.ZIndex = 3
		tracer.Parent = OverlayFolder

		local highlight = Instance.new("Highlight")
		highlight.Name = "POTENT_Highlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.fromRGB(255, 60, 60)
		highlight.FillTransparency = 0.82
		highlight.OutlineColor = Color3.fromRGB(255, 115, 115)
		highlight.OutlineTransparency = 0
		highlight.Enabled = false
		highlight.Parent = workspace

		local object = {
			Holder = holder,
			Box = box,
			BoxStroke = boxStroke,
			Name = nameLabel,
			Info = infoLabel,
			HealthBack = hpBack,
			HealthFill = hpFill,
			Tracer = tracer,
			Highlight = highlight,
		}

		espObjects[character] = object
		return object
	end

	local function hideESPObject(object)
		if not object then return end
		object.Holder.Visible = false
		object.Tracer.Visible = false
		object.Highlight.Enabled = false
	end

	local function removeESP(character)
		local object = espObjects[character]
		if not object then return end
		for _, instance in pairs(object) do
			if typeof(instance) == "Instance" then
				pcall(function() instance:Destroy() end)
			end
		end
		espObjects[character] = nil
	end

	local function getBounds(character)
		if not character or not character:IsA("Model") then
			return nil
		end
		local ok, cf, size = pcall(character.GetBoundingBox, character)
		if not ok or typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
			return nil
		end
		size = size + Vector3.new(0.25, 0.35, 0.25)
		local half = size * 0.5
		local corners = {
			Vector3.new(-half.X, -half.Y, -half.Z),
			Vector3.new(-half.X, -half.Y,  half.Z),
			Vector3.new(-half.X,  half.Y, -half.Z),
			Vector3.new(-half.X,  half.Y,  half.Z),
			Vector3.new( half.X, -half.Y, -half.Z),
			Vector3.new( half.X, -half.Y,  half.Z),
			Vector3.new( half.X,  half.Y, -half.Z),
			Vector3.new( half.X,  half.Y,  half.Z),
		}
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local anyInFront = false
		local camera = currentCamera()
		if not camera then
			return nil
		end
		for _, localCorner in ipairs(corners) do
			local worldCorner = cf:PointToWorldSpace(localCorner)
			local point = camera:WorldToViewportPoint(worldCorner)
			if point.Z > 0 then
				anyInFront = true
				minX = math.min(minX, point.X)
				minY = math.min(minY, point.Y)
				maxX = math.max(maxX, point.X)
				maxY = math.max(maxY, point.Y)
			end
		end
		if not anyInFront or minX == math.huge then
			return nil
		end
		local width = maxX - minX
		local height = maxY - minY
		if width < 2 or height < 2 then
			return nil
		end
		return minX, minY, width, height
	end

	local function updateTracer(frame, from, to)
		local delta = to - from
		frame.Position = UDim2.fromOffset(from.X, from.Y)
		frame.Size = UDim2.fromOffset(delta.Magnitude, 1)
		frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	end

	local function updateESP()
		if not Config.ESP.Enabled or not localCombatReady() then
			for _, object in pairs(espObjects) do
				hideESPObject(object)
			end
			return
		end
		local camera = currentCamera()
		if not camera then
			return
		end
		local seen = {}
		iterateEnemies(function(character)
			seen[character] = true
			local part = getAimPart(character)
				or character:FindFirstChild("HumanoidRootPart")
				or character:FindFirstChild("Torso")
				or character:FindFirstChild("Head")
			if not (part and part:IsA("BasePart")) then
				local old = espObjects[character]
				if old then hideESPObject(old) end
				return
			end
			local distance = (part.Position - camera.CFrame.Position).Magnitude
			if distance > math.max(tonumber(Config.ESP.MaxDistance) or 1, 1) then
				local old = espObjects[character]
				if old then hideESPObject(old) end
				return
			end
			local object = createESP(character)
			local minX, minY, width, height = getBounds(character)
			local locked = character == lockedTarget
			local mainColor = locked
				and Color3.fromRGB(100, 255, 125)
				or Color3.fromRGB(255, 78, 78)
			object.BoxStroke.Color = mainColor
			object.Tracer.BackgroundColor3 = mainColor
			object.Highlight.FillColor = mainColor
			object.Highlight.OutlineColor = mainColor
			object.Highlight.Adornee = character
			object.Highlight.Enabled = Config.ESP.Chams
			if minX then
				object.Holder.Visible = true
				object.Holder.Position = UDim2.fromOffset(minX, minY)
				object.Holder.Size = UDim2.fromOffset(width, height)
				object.Box.Visible = Config.ESP.Boxes
				object.Name.Visible = Config.ESP.Names
				object.Name.Text = getDisplayName(character)
				local health, maxHealth = getHealth(character)
				local ratio = math.clamp(health / math.max(maxHealth, 1), 0, 1)
				object.HealthBack.Visible = Config.ESP.Health
				object.HealthFill.Size = UDim2.fromScale(1, ratio)
				local info = {}
				if Config.ESP.Health then
					table.insert(info, ("%d HP"):format(math.max(0, math.floor(health + 0.5))))
				end
				if Config.ESP.Distance then
					table.insert(info, ("%d studs"):format(math.floor(distance + 0.5)))
				end
				object.Info.Visible = #info > 0
				object.Info.Text = table.concat(info, "  •  ")
				if Config.ESP.Tracers then
					local from = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y - 2)
					local to = Vector2.new(minX + width * 0.5, minY + height)
					updateTracer(object.Tracer, from, to)
					object.Tracer.Visible = true
				else
					object.Tracer.Visible = false
				end
			else
				object.Holder.Visible = false
				object.Tracer.Visible = false
			end
		end)
		for character in pairs(espObjects) do
			if not seen[character] or not isEnemyCharacter(character) then
				removeESP(character)
			end
		end
	end

	local FOVRing = Instance.new("Frame")
	FOVRing.Name = "FOV"
	FOVRing.AnchorPoint = Vector2.new(0.5, 0.5)
	FOVRing.BackgroundTransparency = 1
	FOVRing.BorderSizePixel = 0
	FOVRing.ZIndex = 2
	FOVRing.Parent = ScreenGui

	local FOVCorner = Instance.new("UICorner")
	FOVCorner.CornerRadius = UDim.new(1, 0)
	FOVCorner.Parent = FOVRing

	local FOVStroke = Instance.new("UIStroke")
	FOVStroke.Thickness = 1
	FOVStroke.Transparency = 0.25
	FOVStroke.Color = Color3.fromRGB(255, 255, 255)
	FOVStroke.Parent = FOVRing

	local function updateFOV()
		local center = screenCenter()
		local diameter = math.max(tonumber(Config.Aim.FOV) or 1, 1) * 2
		FOVRing.Position = UDim2.fromOffset(center.X, center.Y)
		FOVRing.Size = UDim2.fromOffset(diameter, diameter)
		FOVRing.Visible = Config.Aim.ShowFOV and Config.Aim.Enabled and localCombatReady()
		FOVStroke.Color = lockedTarget
			and Color3.fromRGB(100, 255, 125)
			or Color3.fromRGB(255, 255, 255)
	end

	--// UI
	local WindUI = getWindUILibrary()
	local window = createPotentWindow(WindUI, "POTENTHUB_ONETAP", "+1 One Tap")

	local combatTab = window:Tab({ Title = "⚔️ Combat", Icon = "swords" })
	local legitTab = window:Tab({ Title = "🎯 Legit", Icon = "crosshair" })
	local rageTab = window:Tab({ Title = "💀 Rage", Icon = "skull" })
	local visualTab = window:Tab({ Title = "👁️ Visuals", Icon = "eye" })
	local settingsTab = window:Tab({ Title = "⚙️ Settings", Icon = "settings" })

	local UIControls = {}
	local syncUIFromConfig
	local LegitModeLabel
	local RageModeLabel
	local BackendStatusLabel
	local cleanup
	local running = true

	local function backendStatusText()
		local tagged = #collectionService:GetTagged("Character")
		return ("Backend • Character tag: %d • %s"):format(tagged, NativeWeaponStatus)
	end

	combatTab:Section({ Title = "🔗 Game Integration" })
	BackendStatusLabel = combatTab:Paragraph({ Title = "Backend Status", Desc = backendStatusText() })
	combatTab:Paragraph({ Title = "Info", Desc = "Targets use Character tag + Head/Torso rigs. Aimbot only locks onto visible enemies." })

	combatTab:Section({ Title = "🎯 Auto Aim" })
	UIControls.AimEnabled = combatTab:Toggle({
		Title = "Enable Auto Aim",
		Value = Config.Aim.Enabled,
		Callback = function(value)
			Config.Aim.Enabled = value
			if not value then clearTarget() end
		end,
	})

	UIControls.AimActivation = combatTab:Dropdown({
		Title = "Aim Activation",
		Values = {"Hold RMB", "Always On"},
		Value = Config.Aim.HoldRMB and "Hold RMB" or "Always On",
		Callback = function(value)
			Config.Aim.HoldRMB = value ~= "Always On"
			Config.AimMode = "Custom"
			clearTarget()
		end,
	})

	combatTab:Section({ Title = "🔫 Auto Shoot" })
	UIControls.AutoShoot = combatTab:Toggle({
		Title = "Enable Auto Shoot",
		Value = Config.Aim.AutoShoot,
		Callback = function(value)
			Config.Aim.AutoShoot = value
			lastAutoShootTarget = nil
			lastAutoShotAttemptAt = 0
		end,
	})

	UIControls.AutoShootButton = combatTab:Dropdown({
		Title = "Auto Shoot Button",
		Values = {"RMB", "LMB"},
		Value = normalizeAutoShootButton(Config.Aim.AutoShootButton),
		Callback = function(value)
			Config.Aim.AutoShootButton = normalizeAutoShootButton(value)
			lastAutoShootTarget = nil
		end,
	})

	UIControls.AutoShootRadius = combatTab:Slider({
		Title = "Shoot Radius (px)",
		Step = 1,
		Value = { Min = 2, Max = 30, Default = Config.Aim.AutoShootRadius },
		Callback = function(value) Config.Aim.AutoShootRadius = value end,
	})

	UIControls.AutoShootDelay = combatTab:Slider({
		Title = "Extra Shot Delay (s)",
		Step = 0.01,
		Value = { Min = 0, Max = 0.50, Default = Config.Aim.AutoShootDelay },
		Callback = function(value) Config.Aim.AutoShootDelay = value end,
	})

	combatTab:Paragraph({ Title = "Auto Shoot", Desc = "Uses the native WeaponClient.fire when available." })

	combatTab:Section({ Title = "🎯 Aim Point / Lock" })
	UIControls.AimPoint = combatTab:Dropdown({
		Title = "Aim Point",
		Values = {"Head", "Torso", "Closest Part"},
		Value = Config.Aim.AimPoint,
		Callback = function(value)
			Config.Aim.AimPoint = value or "Head"
			Config.AimMode = "Custom"
			clearTarget()
		end,
	})

	UIControls.StickyTarget = combatTab:Toggle({
		Title = "Sticky Target",
		Value = Config.Aim.StickyTarget,
		Callback = function(value)
			Config.Aim.StickyTarget = value
			if not value then clearTarget() end
		end,
	})

	combatTab:Section({ Title = "🎯 FOV / Response" })
	UIControls.ShowFOV = combatTab:Toggle({
		Title = "Show FOV Circle",
		Value = Config.Aim.ShowFOV,
		Callback = function(value) Config.Aim.ShowFOV = value end,
	})

	UIControls.FOV = combatTab:Slider({
		Title = "FOV Radius (px)",
		Step = 5,
		Value = { Min = 40, Max = 700, Default = Config.Aim.FOV },
		Callback = function(value)
			Config.Aim.FOV = value
			Config.AimMode = "Custom"
		end,
	})

	UIControls.AimSpeed = combatTab:Slider({
		Title = "Aim Speed",
		Step = 1,
		Value = { Min = 4, Max = 140, Default = Config.Aim.SmoothSpeed },
		Callback = function(value)
			Config.Aim.SmoothSpeed = value
			Config.AimMode = "Custom"
		end,
	})

	UIControls.AimDistance = combatTab:Slider({
		Title = "Aim Max Distance (studs)",
		Step = 25,
		Value = { Min = 100, Max = 1500, Default = Config.Aim.MaxDistance },
		Callback = function(value)
			Config.Aim.MaxDistance = value
			clearTarget()
		end,
	})

	combatTab:Section({ Title = "🧠 Advanced Targeting" })
	UIControls.TargetPriority = combatTab:Dropdown({
		Title = "Target Priority",
		Values = {"Crosshair", "Distance", "Low Health", "Hybrid"},
		Value = Config.Aim.TargetPriority,
		Callback = function(value)
			Config.Aim.TargetPriority = value or "Hybrid"
			clearTarget()
		end,
	})

	UIControls.Prediction = combatTab:Toggle({
		Title = "Projectile Prediction",
		Value = Config.Aim.Prediction,
		Callback = function(value) Config.Aim.Prediction = value end,
	})

	UIControls.BulletSpeed = combatTab:Slider({
		Title = "Projectile Speed (studs/s)",
		Step = 50,
		Value = { Min = 500, Max = 6000, Default = Config.Aim.BulletSpeed },
		Callback = function(value) Config.Aim.BulletSpeed = value end,
	})

	UIControls.PredictionExtra = combatTab:Slider({
		Title = "Extra Prediction (s)",
		Step = 0.005,
		Value = { Min = 0, Max = 0.20, Default = Config.Aim.PredictionExtra },
		Callback = function(value) Config.Aim.PredictionExtra = value end,
	})

	UIControls.PredictionSmoothing = combatTab:Slider({
		Title = "Prediction Stability",
		Step = 0.01,
		Value = { Min = 0, Max = 0.95, Default = Config.Aim.PredictionSmoothing },
		Callback = function(value) Config.Aim.PredictionSmoothing = value end,
	})

	UIControls.MaxPredictionOffset = combatTab:Slider({
		Title = "Max Prediction Offset (studs)",
		Step = 1,
		Value = { Min = 0, Max = 30, Default = Config.Aim.MaxPredictionOffset },
		Callback = function(value) Config.Aim.MaxPredictionOffset = value end,
	})

	UIControls.AdaptiveSmoothing = combatTab:Toggle({
		Title = "Adaptive Smoothing",
		Value = Config.Aim.AdaptiveSmoothing,
		Callback = function(value) Config.Aim.AdaptiveSmoothing = value end,
	})

	UIControls.MicroSnap = combatTab:Slider({
		Title = "Micro Snap Radius (px)",
		Step = 0.5,
		Value = { Min = 0, Max = 10, Default = Config.Aim.MicroSnapRadius },
		Callback = function(value) Config.Aim.MicroSnapRadius = value end,
	})

	UIControls.SwitchDelay = combatTab:Slider({
		Title = "Target Switch Delay (s)",
		Step = 0.01,
		Value = { Min = 0, Max = 0.30, Default = Config.Aim.SwitchDelay },
		Callback = function(value) Config.Aim.SwitchDelay = value end,
	})

	UIControls.SwitchThreshold = combatTab:Slider({
		Title = "Switch Improvement Required",
		Step = 0.01,
		Value = { Min = 0, Max = 0.50, Default = Config.Aim.SwitchThreshold },
		Callback = function(value) Config.Aim.SwitchThreshold = value end,
	})

	UIControls.LockGrace = combatTab:Slider({
		Title = "Target Lock Grace (s)",
		Step = 0.01,
		Value = { Min = 0, Max = 0.50, Default = Config.Aim.LockGrace },
		Callback = function(value) Config.Aim.LockGrace = value end,
	})

	--// Legit
	local function updateAimModeLabels()
		local text = "Current mode • " .. tostring(Config.AimMode or "Custom")
		if LegitModeLabel and LegitModeLabel.SetDesc then LegitModeLabel:SetDesc(text) end
		if RageModeLabel and RageModeLabel.SetDesc then RageModeLabel:SetDesc(text) end
	end

	local function applyAimPreset(name, values, notification)
		Config.AimMode = name
		for key, value in pairs(values or {}) do
			if Config.Aim[key] ~= nil then
				Config.Aim[key] = value
			end
		end
		clearTarget()
		if syncUIFromConfig then syncUIFromConfig() end
		updateAimModeLabels()
		WindUI:Notify({ Title = name, Content = notification or (name .. " applied"), Duration = 2.2 })
	end

	legitTab:Section({ Title = "🎯 Legit Aim" })
	LegitModeLabel = legitTab:Paragraph({ Title = "Current Mode", Desc = "Current mode • " .. tostring(Config.AimMode) })

	legitTab:Button({
		Title = "Legit • Subtle",
		Callback = function()
			applyAimPreset("Legit • Subtle", {
				Enabled = true, HoldRMB = true, AimPoint = "Head",
				FOV = 75, SmoothSpeed = 12, StickyTarget = true, StickyMultiplier = 1.15,
				Prediction = true, BulletSpeed = 3850, PredictionExtra = 0,
				PredictionSmoothing = 0.84, MaxPredictionOffset = 10, AdaptiveSmoothing = true,
				MicroSnapRadius = 0.5, TargetPriority = "Hybrid",
				SwitchDelay = 0.12, SwitchThreshold = 0.22, LockGrace = 0.24, ShowFOV = false,
			}, "Hold RMB • 75px FOV • smooth visible-target aim")
		end,
	})

	legitTab:Button({
		Title = "Legit • Balanced",
		Callback = function()
			applyAimPreset("Legit • Balanced", {
				Enabled = true, HoldRMB = true, AimPoint = "Head",
				FOV = 120, SmoothSpeed = 22, StickyTarget = true, StickyMultiplier = 1.22,
				Prediction = true, BulletSpeed = 3850, PredictionExtra = 0,
				PredictionSmoothing = 0.78, MaxPredictionOffset = 14, AdaptiveSmoothing = true,
				MicroSnapRadius = 1, TargetPriority = "Hybrid",
				SwitchDelay = 0.08, SwitchThreshold = 0.18, LockGrace = 0.21, ShowFOV = true,
			}, "Hold RMB • 120px FOV • balanced response")
		end,
	})

	legitTab:Button({
		Title = "Legit • Strong",
		Callback = function()
			applyAimPreset("Legit • Strong", {
				Enabled = true, HoldRMB = true, AimPoint = "Head",
				FOV = 190, SmoothSpeed = 38, StickyTarget = true, StickyMultiplier = 1.30,
				Prediction = true, BulletSpeed = 3850, PredictionExtra = 0,
				PredictionSmoothing = 0.72, MaxPredictionOffset = 18, AdaptiveSmoothing = true,
				MicroSnapRadius = 1.5, TargetPriority = "Crosshair",
				SwitchDelay = 0.05, SwitchThreshold = 0.12, LockGrace = 0.17, ShowFOV = true,
			}, "Hold RMB • 190px FOV • fast visible-target response")
		end,
	})

	--// Rage
	rageTab:Section({ Title = "💀 Rage Aim" })
	RageModeLabel = rageTab:Paragraph({ Title = "Current Mode", Desc = "Current mode • " .. tostring(Config.AimMode) })

	rageTab:Button({
		Title = "Rage • Visible",
		Callback = function()
			applyAimPreset("Rage • Visible", {
				Enabled = true, HoldRMB = false, AimPoint = "Head",
				FOV = 520, SmoothSpeed = 100, StickyTarget = true, StickyMultiplier = 1.50,
				Prediction = true, BulletSpeed = 3850, PredictionExtra = 0,
				PredictionSmoothing = 0.60, MaxPredictionOffset = 22, AdaptiveSmoothing = false,
				MicroSnapRadius = 5, TargetPriority = "Crosshair",
				SwitchDelay = 0, SwitchThreshold = 0.06, LockGrace = 0.12, ShowFOV = true,
			}, "Always On • large FOV • fast • visible targets only")
		end,
	})

	rageTab:Button({
		Title = "Rage • Max",
		Callback = function()
			applyAimPreset("Rage • Max", {
				Enabled = true, HoldRMB = false, AimPoint = "Closest Part",
				FOV = 700, SmoothSpeed = 140, StickyTarget = true, StickyMultiplier = 1.65,
				Prediction = true, BulletSpeed = 3850, PredictionExtra = 0,
				PredictionSmoothing = 0.52, MaxPredictionOffset = 25, AdaptiveSmoothing = false,
				MicroSnapRadius = 10, TargetPriority = "Crosshair",
				SwitchDelay = 0, SwitchThreshold = 0.02, LockGrace = 0.10, ShowFOV = true,
			}, "Always On • max FOV / response • visible targets only")
		end,
	})

	rageTab:Section({ Title = "🛠️ Helpers" })
	rageTab:Button({
		Title = "Always On",
		Callback = function()
			Config.AimMode = "Rage • Custom"
			Config.Aim.Enabled = true
			Config.Aim.HoldRMB = false
			clearTarget()
			if syncUIFromConfig then syncUIFromConfig() end
		end,
	})

	rageTab:Button({
		Title = "Head Only",
		Callback = function()
			Config.AimMode = "Rage • Custom"
			Config.Aim.AimPoint = "Head"
			clearTarget()
			if syncUIFromConfig then syncUIFromConfig() end
		end,
	})

	--// Visuals
	visualTab:Section({ Title = "👁️ ESP" })
	UIControls.ESPEnabled = visualTab:Toggle({
		Title = "Enable ESP",
		Value = Config.ESP.Enabled,
		Callback = function(value)
			Config.ESP.Enabled = value
			if not value then
				for _, object in pairs(espObjects) do
					hideESPObject(object)
				end
			end
		end,
	})

	UIControls.Boxes = visualTab:Toggle({
		Title = "Boxes",
		Value = Config.ESP.Boxes,
		Callback = function(value) Config.ESP.Boxes = value end,
	})

	UIControls.Names = visualTab:Toggle({
		Title = "Names",
		Value = Config.ESP.Names,
		Callback = function(value) Config.ESP.Names = value end,
	})

	UIControls.Health = visualTab:Toggle({
		Title = "Health",
		Value = Config.ESP.Health,
		Callback = function(value) Config.ESP.Health = value end,
	})

	UIControls.Distance = visualTab:Toggle({
		Title = "Distance",
		Value = Config.ESP.Distance,
		Callback = function(value) Config.ESP.Distance = value end,
	})

	UIControls.Chams = visualTab:Toggle({
		Title = "Chams",
		Value = Config.ESP.Chams,
		Callback = function(value) Config.ESP.Chams = value end,
	})

	UIControls.Tracers = visualTab:Toggle({
		Title = "Tracers",
		Value = Config.ESP.Tracers,
		Callback = function(value) Config.ESP.Tracers = value end,
	})

	visualTab:Section({ Title = "📏 ESP Range" })
	UIControls.ESPDistance = visualTab:Slider({
		Title = "ESP Max Distance (studs)",
		Step = 50,
		Value = { Min = 100, Max = 3000, Default = Config.ESP.MaxDistance },
		Callback = function(value) Config.ESP.MaxDistance = value end,
	})

	visualTab:Paragraph({ Title = "Info", Desc = "The current aim target is highlighted green; other enemies stay red." })

	--// Sync
	syncUIFromConfig = function()
		local function safeSet(control, value)
			if control and control.Set then
				pcall(function() control:Set(value) end)
			end
		end

		safeSet(UIControls.AimEnabled, Config.Aim.Enabled)
		safeSet(UIControls.AimActivation, Config.Aim.HoldRMB and "Hold RMB" or "Always On")
		safeSet(UIControls.AutoShoot, Config.Aim.AutoShoot)
		safeSet(UIControls.AutoShootButton, normalizeAutoShootButton(Config.Aim.AutoShootButton))
		safeSet(UIControls.AutoShootRadius, Config.Aim.AutoShootRadius)
		safeSet(UIControls.AutoShootDelay, Config.Aim.AutoShootDelay)
		safeSet(UIControls.AimPoint, Config.Aim.AimPoint)
		safeSet(UIControls.StickyTarget, Config.Aim.StickyTarget)
		safeSet(UIControls.ShowFOV, Config.Aim.ShowFOV)
		safeSet(UIControls.FOV, Config.Aim.FOV)
		safeSet(UIControls.AimSpeed, Config.Aim.SmoothSpeed)
		safeSet(UIControls.AimDistance, Config.Aim.MaxDistance)
		safeSet(UIControls.TargetPriority, Config.Aim.TargetPriority)
		safeSet(UIControls.Prediction, Config.Aim.Prediction)
		safeSet(UIControls.BulletSpeed, Config.Aim.BulletSpeed)
		safeSet(UIControls.PredictionExtra, Config.Aim.PredictionExtra)
		safeSet(UIControls.PredictionSmoothing, Config.Aim.PredictionSmoothing)
		safeSet(UIControls.MaxPredictionOffset, Config.Aim.MaxPredictionOffset)
		safeSet(UIControls.AdaptiveSmoothing, Config.Aim.AdaptiveSmoothing)
		safeSet(UIControls.MicroSnap, Config.Aim.MicroSnapRadius)
		safeSet(UIControls.SwitchDelay, Config.Aim.SwitchDelay)
		safeSet(UIControls.SwitchThreshold, Config.Aim.SwitchThreshold)
		safeSet(UIControls.LockGrace, Config.Aim.LockGrace)
		safeSet(UIControls.ESPEnabled, Config.ESP.Enabled)
		safeSet(UIControls.Boxes, Config.ESP.Boxes)
		safeSet(UIControls.Names, Config.ESP.Names)
		safeSet(UIControls.Health, Config.ESP.Health)
		safeSet(UIControls.Distance, Config.ESP.Distance)
		safeSet(UIControls.Chams, Config.ESP.Chams)
		safeSet(UIControls.Tracers, Config.ESP.Tracers)
		safeSet(UIControls.ESPDistance, Config.ESP.MaxDistance)

		clearTarget()
		updateAimModeLabels()
	end

	--// Settings
	settingsTab:Section({ Title = "🎮 Info" })
	settingsTab:Paragraph({ Title = "Place ID", Desc = tostring(game.PlaceId) })

	settingsTab:Button({
		Title = "Re-scan Native Weapon Client",
		Callback = function()
			resolveNativeWeaponClient()
			if BackendStatusLabel and BackendStatusLabel.SetDesc then
				BackendStatusLabel:SetDesc(backendStatusText())
			end
			WindUI:Notify({ Title = "POTENT", Content = NativeWeaponStatus, Duration = 2 })
		end,
	})

	settingsTab:Button({
		Title = "Reset Aim + ESP Defaults",
		Callback = function()
			Config = deepCopy(DefaultConfig)
			clearTarget()
			velocityCache = setmetatable({}, {__mode = "k"})
			if syncUIFromConfig then syncUIFromConfig() end
			WindUI:Notify({ Title = "POTENT", Content = "Aim and ESP defaults restored", Duration = 2 })
		end,
	})

	settingsTab:Button({
		Title = "Unload Script",
		Callback = function()
			if cleanup then cleanup() end
		end,
	})

	syncUIFromConfig()

	--// Main loop
	local renderConnection
	local statusAccumulator = 0

	renderConnection = runService.RenderStepped:Connect(function(dt)
		if not running then return end
		applyAim(dt)
		updateESP()
		updateFOV()
		statusAccumulator = statusAccumulator + dt
		if statusAccumulator >= 1 then
			statusAccumulator = 0
			if BackendStatusLabel and BackendStatusLabel.SetDesc then
				BackendStatusLabel:SetDesc(backendStatusText())
			end
		end
	end)

	cleanup = function()
		if not running then return end
		running = false
		if renderConnection then
			pcall(function() renderConnection:Disconnect() end)
			renderConnection = nil
		end
		clearTarget()
		for character in pairs(espObjects) do
			removeESP(character)
		end
		if ScreenGui then pcall(function() ScreenGui:Destroy() end) end
		if window and type(window.Destroy) == "function" then
			pcall(function() window:Destroy() end)
		end
	end

	WindUI:Notify({
		Title = "⚡ POTENT HUB",
		Content = "One Tap loaded • enable options manually",
		Duration = 3,
	})
end

-- ============================================================
-- ========== EJECUCIÓN PRINCIPAL ==========
-- ============================================================
if not SUPPORTED_PLACES[game.PlaceId] then
	print("❌ This game is not supported yet. PlaceId: " .. tostring(game.PlaceId))
	showUnsupportedScreen()
	return
end

local function launchGame()
	if game.PlaceId == 114697347887839 or game.PlaceId == 72858062353423 then
		runSpeedMonkeyEscape()
	elseif game.PlaceId == BLOXSPIN_PLACE_ID then
		runBloxSpin()
	elseif game.PlaceId == 142823291 then
		runMM2()
	elseif game.PlaceId == 77813828595591 then
		runKittenFarm()
	elseif game.PlaceId == 118941584817777 or game.PlaceId == 93411036959889 then
		runSpeedKeyboardEscape()
	elseif game.PlaceId == ONETAP_PLACE_ID then
		runOneTap()
	end
end

if isKeyValidLocally() then
	print("✅ Valid key found, loading...")
	launchGame()
else
	print("🔑 Key required...")
	showKeySystem(function()
		launchGame()
	end)
end
