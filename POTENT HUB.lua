-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

-- ============================================================
-- POTENT HUB - MULTI GAME HUB (WindUI v1.1 Edition)
-- 1. Speed Monkey Escape (114697347887839 / 72858062353423)
-- 2. Block Spin (104715542330896) [UNDER MAINTENANCE]
-- 3. Murder Mystery 2 (142823291)
-- 4. Kitten Farm (77813828595591)
-- 5. Speed Keyboard Escape (118941584817777 / 93411036959889)
-- ============================================================

-- Services.
local playersService = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local workspaceService = game:GetService("Workspace")
local collectionService = game:GetService("CollectionService")
local virtualUser = game:GetService("VirtualUser")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local guiService = game:GetService("GuiService")

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
	[114697347887839] = true, -- Juego 1
	[72858062353423]  = true, -- Juego 1 alt
	[104715542330896] = true, -- Juego 2 (maintenance)
	[142823291]       = true, -- Juego 3 MM2
	[77813828595591]  = true, -- Juego 4 Kitten Farm
	[118941584817777] = true, -- JUEGO 5 - PLACE ID 1
	[93411036959889]  = true, -- JUEGO 5 - PLACE ID 2
}

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
		window:Tag({ Title = "v1.1", Icon = "terminal", Color = Palette.Gold })
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
-- ========== MAINTENANCE SCREEN (5 SECONDS) ==========
-- ============================================================
local function showMaintenanceScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PotentMaintenance"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 99999
	screenGui.IgnoreGuiInset = true

	local ok = pcall(function() screenGui.Parent = getGuiContainer() end)
	if not ok then screenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui") end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
	bg.BorderSizePixel = 0
	bg.ZIndex = 1
	bg.Parent = screenGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 520, 0, 300)
	main.Position = UDim2.new(0.5, -260, 0.5, -150)
	main.BackgroundTransparency = 1
	main.ZIndex = 2
	main.Parent = screenGui

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(1, 0, 0, 40)
	iconLabel.Position = UDim2.new(0, 0, 0, 10)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = "⚠️"
	iconLabel.TextSize = 36
	iconLabel.ZIndex = 3
	iconLabel.Parent = main

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 55)
	title.BackgroundTransparency = 1
	title.Text = "UNDER MAINTENANCE"
	title.TextColor3 = Palette.Gold
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.ZIndex = 3
	title.Parent = main

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -40, 0, 70)
	desc.Position = UDim2.new(0, 20, 0, 95)
	desc.BackgroundTransparency = 1
	desc.Text = "The script for this game is currently under maintenance.\nIf you want more information, please join our Discord server."
	desc.TextColor3 = Color3.fromRGB(230, 230, 240)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 15
	desc.TextWrapped = true
	desc.ZIndex = 3
	desc.Parent = main

	local discordBtn = Instance.new("TextButton")
	discordBtn.Size = UDim2.new(0, 300, 0, 48)
	discordBtn.Position = UDim2.new(0.5, -150, 0, 185)
	discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
	discordBtn.BorderSizePixel = 0
	discordBtn.Text = "💬 JOIN DISCORD"
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
	status.Position = UDim2.new(0, 20, 0, 245)
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
	end)

	task.delay(5, function()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)
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
	supportLabel.Text = "🟢 Support:\nSpeed Monkey Escape, Block Spin, Murder Mystery 2, Kitten Farm, Speed Keyboard Escape"
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
	-- ============================================================
	-- REMOVE OBSTACLES
	-- ============================================================
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

	-- ============================================================
	-- ROUTES WORLD 2
	-- ============================================================
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
		["1.5M"] = {
			-396.53, 506.15, -40.06,  -400.38, 505.02, 60.98,  -405.59, 505.25, 123.49,
			-396.93, 501.32, 191.84,  -397.04, 501.32, 435.37,  -349.90, 503.68, 487.02,
			-346.67, 528.25, 579.61,  -451.00, 528.25, 574.09,  -450.17, 555.25, 464.37,
			-348.02, 555.25, 468.05,  -351.86, 582.32, 580.75,  -456.47, 582.32, 578.57,
			-451.47, 609.32, 461.42,  -400.10, 609.32, 466.43,  -399.98, 609.11, 605.61,
			-400.85, 609.11, 672.28,  -381.99, 609.11, 708.88,  -381.63, 609.11, 735.49,
			-402.89, 609.11, 782.55,  -400.91, 608.67, 842.79,  -399.07, 652.07, 891.53,
			-396.95, 658.99, 1106.06, -402.38, 656.77, 1206.64, -401.64, 664.01, 1242.18,
			-400.91, 608.67, 1264.36, -417.18, 610.61, 1261.27,
		},
		["2.5M"] = {
			-398.80, 506.15, -40.85,  -404.38, 505.25, 122.56, -395.82, 501.32, 200.48,
			-397.37, 501.32, 436.04,  -349.33, 505.04, 491.33, -347.94, 528.25, 581.98,
			-452.57, 528.25, 577.30,  -454.68, 555.25, 463.47, -346.09, 555.25, 464.80,
			-347.40, 582.32, 579.84,  -452.08, 582.32, 576.42, -453.29, 609.32, 463.41,
			-401.98, 609.32, 467.31,  -398.54, 609.11, 612.87, -402.04, 608.67, 844.75,
			-394.25, 668.72, 906.62,  -398.43, 666.48, 1203.63,-398.78, 608.64, 1267.88,
			-401.98, 608.67, 1293.02, -400.94, 619.99, 1331.66,-402.64, 608.67, 1439.09,
			-366.04, 628.93, 1540.43, -364.37, 629.46, 1598.64,-360.39, 606.55, 1712.95,
			-364.49, 617.12, 1788.75, -398.10, 608.67, 1886.83,-404.40, 608.67, 2061.99,
			-398.28, 608.67, 2246.25, -400.31, 624.61, 2398.69,-400.78, 624.61, 2414.63,
			-417.00, 626.38, 2415.71,
		},
		["4M"] = {
			-396.34, 506.15, -41.57,  -401.28, 505.25, 58.81,  -397.87, 501.32, 195.77,
			-395.26, 501.32, 433.73,  -347.59, 505.53, 492.88, -348.63, 528.25, 583.82,
			-453.27, 528.25, 578.26,  -453.85, 555.25, 465.17, -346.82, 555.25, 465.54,
			-347.85, 582.32, 579.89,  -457.86, 582.32, 578.46, -454.50, 609.32, 463.49,
			-397.10, 609.32, 463.26,  -401.19, 609.11, 613.23, -402.02, 609.11, 800.85,
			-400.29, 608.67, 846.57,  -313.22, 608.67, 1000.25,-402.66, 609.53, 1226.30,
			-403.33, 608.67, 1269.90, -402.91, 618.68, 1327.69,-395.92, 608.67, 1448.47,
			-371.12, 629.26, 1541.48, -364.42, 606.55, 1719.86,-366.25, 616.48, 1786.80,
			-401.43, 608.67, 1898.83, -399.98, 608.67, 2064.30,-399.48, 619.71, 2137.65,
			-401.35, 608.67, 2256.11, -400.76, 620.29, 2316.98,-399.85, 624.61, 2411.24,
			-401.12, 624.56, 2653.54, -416.85, 626.56, 2650.08,
		},
		["6M"] = {
			-397.25, 506.15, -40.28,  -398.78, 505.25, 65.14,  -394.47, 501.32, 188.15,
			-396.21, 501.32, 433.42,  -351.76, 503.06, 485.05, -351.09, 528.25, 581.20,
			-458.46, 528.25, 578.68,  -456.19, 555.25, 462.29, -343.94, 555.25, 469.61,
			-349.88, 582.32, 577.78,  -452.74, 582.32, 578.78, -450.30, 609.32, 459.77,
			-401.90, 609.32, 471.41,  -401.06, 609.11, 611.22, -400.96, 609.11, 789.44,
			-400.59, 608.67, 850.24,  -290.45, 609.00, 998.96, -388.84, 609.19, 1256.77,
			-391.24, 608.67, 1450.20, -363.72, 629.46, 1562.38,-365.04, 606.55, 1728.39,
			-364.90, 615.76, 1784.63, -392.87, 608.67, 1904.14,-398.03, 619.19, 1955.17,
			-401.72, 608.67, 2073.83, -402.28, 619.56, 2137.17,-401.72, 608.67, 2261.35,
			-401.64, 620.69, 2318.43, -401.66, 624.61, 2410.60,-400.58, 624.56, 2647.28,
			-400.99, 624.59, 3160.69, -417.34, 626.38, 3158.17,
		},
		["10M"] = {
			-396.85, 506.15, -43.66,  -397.79, 501.32, 191.99, -395.31, 501.32, 438.44,
			-347.26, 507.10, 497.85,  -347.12, 528.25, 574.66, -452.43, 528.25, 573.53,
			-450.80, 555.25, 466.38,  -346.80, 555.25, 469.79, -348.17, 582.32, 575.06,
			-456.96, 582.32, 577.16,  -447.32, 609.32, 464.97, -391.00, 609.32, 474.67,
			-401.62, 609.11, 606.76,  -399.48, 608.67, 844.03, -400.50, 608.67, 1262.01,
			-399.16, 619.74, 1330.92, -395.81, 608.67, 1455.99,-360.86, 629.46, 1546.56,
			-360.52, 606.55, 1731.41, -369.57, 616.70, 1787.49,-397.07, 608.67, 1900.11,
			-399.26, 620.59, 1959.82, -399.84, 608.67, 2071.64,-405.92, 618.24, 2133.19,
			-400.81, 608.67, 2264.26, -401.46, 618.52, 2311.65,-400.35, 624.61, 2418.86,
			-400.52, 624.56, 2654.82, -399.89, 624.59, 3164.33,-397.51, 624.59, 3321.25,
			-178.01, 624.59, 3330.83, -169.29, 624.59, 3210.65,-102.24, 624.59, 3227.09,
			-122.66, 624.59, 3421.92, -258.82, 624.59, 3446.75,-266.19, 624.59, 3629.02,
			-549.61, 624.59, 3638.24, -546.54, 624.59, 3787.04,-123.01, 624.59, 3803.17,
			-130.94, 624.59, 3878.74, -63.36, 624.65, 3866.58, -60.23, 626.38, 3883.20,
		},
		["15M"] = {
			-395.96, 506.15, -36.15,  -399.63, 501.32, 197.37, -396.13, 501.32, 434.31,
			-338.06, 510.19, 507.66,  -346.45, 528.25, 578.81, -454.74, 528.25, 575.09,
			-453.27, 555.25, 462.82,  -349.37, 555.25, 464.85, -346.80, 582.32, 573.29,
			-456.64, 582.32, 568.00,  -452.93, 609.32, 460.80, -394.86, 609.32, 471.19,
			-401.80, 609.11, 607.74,  -401.49, 608.67, 849.94, -401.29, 608.67, 1255.58,
			-398.10, 619.35, 1329.72, -395.35, 608.67, 1453.82,-363.35, 629.46, 1544.08,
			-373.17, 608.43, 1762.46, -404.01, 608.67, 1903.99,-409.34, 608.67, 2074.07,
			-405.61, 618.22, 2133.13, -409.93, 620.49, 2317.59,-400.36, 624.61, 2403.06,
			-402.71, 624.56, 2653.96, -398.45, 624.59, 3159.32,-401.37, 624.59, 3333.39,
			-189.94, 624.59, 3329.75, -181.90, 624.59, 3235.26,-108.12, 624.59, 3242.44,
			-114.80, 624.59, 3417.17, -256.04, 624.59, 3486.37,-333.24, 624.59, 3631.83,
			-519.80, 624.59, 3664.53, -505.52, 624.59, 3807.56,-181.10, 624.59, 3819.08,
			-58.48, 624.65, 3866.03,  1185.86, 624.82, 3867.16, 1229.76, 626.74, 3909.11,
		},
		["25M"] = {
			-398.01, 506.15, -41.04,  -397.94, 501.32, 185.77, -394.87, 501.32, 432.87,
			-354.72, 503.40, 486.12,  -346.29, 528.25, 576.34, -452.48, 528.25, 575.63,
			-452.27, 555.25, 467.82,  -348.67, 556.49, 483.02, -361.25, 582.32, 576.54,
			-450.85, 582.92, 562.83,  -443.47, 609.32, 470.75, -390.94, 609.32, 473.53,
			-401.14, 609.11, 610.19,  -401.89, 608.67, 846.03, -400.50, 608.67, 1261.14,
			-399.32, 618.25, 1326.41, -400.79, 608.67, 1450.33,-365.48, 629.46, 1544.27,
			-362.42, 610.88, 1769.88, -368.92, 617.60, 1790.20,-403.24, 608.67, 1886.37,
			-402.33, 618.78, 1953.92, -403.73, 608.67, 2059.96,-400.77, 620.70, 2140.89,
			-401.36, 608.67, 2234.49, -398.58, 619.29, 2313.96,-401.07, 624.61, 2411.98,
			-400.53, 624.56, 2647.19, -401.39, 624.59, 3152.19,-402.73, 624.59, 3322.10,
			-202.84, 624.59, 3311.41, -113.28, 624.59, 3283.08,-125.15, 624.59, 3426.17,
			-268.75, 624.59, 3504.29, -314.82, 624.59, 3619.71,-527.62, 624.59, 3669.60,
			-498.88, 624.59, 3780.48, -71.59, 624.65, 3853.16, -51.52, 624.65, 3866.95,
			1210.88, 624.85, 3868.11, 1297.67, 624.89, 3866.78,1325.73, 614.96, 3865.35,
			1335.37, 667.93, 3862.09, 1547.01, 630.47, 3796.61,1750.39, 635.66, 3947.19,
			1953.63, 637.49, 3801.63, 2101.14, 638.53, 3964.90,2305.41, 630.33, 3866.94,
			2383.63, 628.86, 3872.10, 2396.52, 628.86, 3872.00,2400.81, 630.69, 3888.76,
		},
		["40M"] = {
			-396.08, 506.15, -36.82,  -396.12, 501.32, 191.72, -396.79, 501.32, 438.39,
			-351.09, 503.03, 484.96,  -346.18, 528.25, 565.52, -447.25, 528.25, 565.17,
			-444.12, 555.25, 469.77,  -337.13, 555.25, 464.23, -353.50, 582.32, 577.69,
			-449.50, 582.32, 576.16,  -451.15, 609.32, 459.82, -396.40, 609.32, 465.93,
			-401.26, 609.11, 612.24,  -399.69, 608.67, 855.20, -402.48, 608.67, 1274.66,
			-400.09, 618.58, 1327.41, -399.44, 608.67, 1449.65,-366.09, 629.46, 1543.85,
			-360.63, 607.68, 1760.19, -367.98, 618.30, 1792.33,-403.90, 608.67, 1898.76,
			-403.08, 619.63, 1956.48, -400.79, 608.67, 2086.75,-401.50, 619.88, 2138.15,
			-403.80, 618.00, 2310.07, -400.66, 624.61, 2415.07,-400.49, 624.56, 2651.30,
			-400.91, 624.59, 3155.08, -403.40, 624.59, 3339.57,-119.64, 624.59, 3284.05,
			-151.24, 624.59, 3458.09, -268.68, 624.59, 3487.22,-340.75, 624.59, 3660.40,
			-569.89, 624.59, 3668.16, -489.55, 624.59, 3799.60,-59.35, 625.56, 3850.75,
			1219.89, 624.85, 3866.75, 1284.32, 624.89, 3866.94,1286.06, 665.44, 3867.09,
			2292.79, 677.94, 3879.76, 2400.52, 628.86, 3868.66,2486.91, 639.53, 3869.72,
			2550.28, 640.78, 3869.41, 2681.08, 635.78, 3873.00,2739.68, 640.82, 3867.08,
			2739.68, 576.78, 3867.08, 2839.74, 577.89, 3870.93,2887.44, 595.52, 3869.69,
			2916.85, 605.82, 3871.14, 2978.85, 577.76, 3867.98,3048.89, 593.04, 3871.82,
			3182.50, 582.81, 3875.77, 3211.69, 593.44, 3871.68,3264.79, 593.78, 3871.91,
			3269.49, 595.78, 3888.77,
		},
		["60M"] = {
			-397.33, 506.15, -35.80,  -397.35, 501.32, 188.90, -397.08, 501.32, 429.52,
			-344.07, 509.28, 504.76,  -349.62, 528.25, 569.40, -463.72, 528.25, 568.95,
			-463.32, 555.25, 460.69,  -336.13, 555.25, 456.17, -337.20, 582.32, 585.60,
			-463.96, 582.32, 587.29,  -463.83, 609.32, 456.33, -389.89, 609.32, 456.22,
			-400.12, 609.11, 611.69,  -401.23, 608.67, 841.74, -400.22, 608.67, 1262.85,
			-401.34, 620.06, 1331.87, -401.77, 608.67, 1462.42,-363.49, 629.46, 1544.65,
			-362.30, 629.46, 1601.72, -358.97, 606.55, 1724.01,-362.12, 618.39, 1792.98,
			-399.98, 608.67, 1863.71, -401.84, 620.41, 1958.86,-401.36, 619.90, 2138.20,
			-400.57, 619.99, 2316.09, -399.49, 624.61, 2412.01,-401.65, 624.56, 2651.59,
			-399.46, 624.59, 3161.75, -403.65, 624.59, 3339.24,-95.43, 624.59, 3279.85,
			-167.38, 624.59, 3458.25, -257.94, 624.59, 3511.95,-380.92, 624.59, 3660.42,
			-545.07, 624.59, 3669.43, -495.24, 624.59, 3810.68,-63.71, 624.65, 3856.78,
			1217.90, 624.85, 3868.90, 1318.72, 622.75, 3865.82,1545.85, 631.10, 3797.11,
			1757.11, 638.47, 3948.35, 1947.14, 637.01, 3803.98,2104.09, 642.01, 3962.74,
			2298.19, 630.28, 3867.19, 2395.77, 628.86, 3870.35,2484.46, 638.72, 3870.29,
			2699.98, 635.78, 3871.53, 2739.82, 633.65, 3871.07,2739.82, 576.78, 3871.07,
			2846.61, 579.41, 3870.98, 2918.92, 606.44, 3870.91,2962.88, 577.76, 3872.23,
			3049.11, 593.12, 3870.46, 3189.61, 585.40, 3874.17,3268.12, 593.78, 3871.69,
			3290.56, 593.78, 3872.13, 3334.82, 705.95, 3843.62,3351.97, 706.48, 5159.45,
			4586.86, 706.48, 5144.25, 4646.06, 568.89, 5139.01,4634.53, 570.89, 5159.41,
		},
	}

	-- ============================================================
	-- ROUTES WORLD 3
	-- ============================================================
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
		["800M"] = {
			-1431.91, -158.92, -873.08, -1431.48, -155.53, -831.55, -1426.88, -124.41, -732.60,
			-1429.44, -91.57, -628.17,  -1427.49, -68.39, -531.84, -1454.33, -68.39, -490.71,
			-1453.24, -65.88, -428.40,  -1455.70, -56.88, -392.43, -1455.69, -55.89, -323.22,
			-1453.33, -56.14, -8.73,    -1454.43, -55.89, 83.49,   -1454.03, 90.70, 87.25,
			-1475.95, 91.11, 92.38,     -1474.50, 216.42, 96.89,   -1469.55, 224.45, 179.03,
			-1468.68, 224.76, 228.53,   -1467.31, 215.87, 335.16,  -1481.27, 217.75, 331.78,
		},
		["1.25B"] = {
			-1431.28, -159.52, -871.10, -1428.23, -155.12, -830.25, -1424.72, -122.48, -726.47,
			-1424.74, -87.52, -615.22,  -1424.48, -68.39, -534.38, -1453.99, -68.39, -492.30,
			-1453.82, -56.61, -391.32,  -1456.01, -55.89, -308.73, -1454.34, -56.14, -4.47,
			-1454.12, -53.46, 84.69,    -1453.73, 90.70, 87.30,   -1475.20, 216.23, 98.87,
			-1475.37, 224.47, 179.10,   -1464.36, 215.87, 351.88,  -1457.70, 215.84, 627.31,
			-1457.70, 369.89, 627.31,   -1453.66, 361.87, 583.43,  -1354.24, 360.67, 495.31,
			-1246.91, 335.51, 493.27,   -1240.09, 329.71, 660.76,  -1219.02, 347.41, 839.73,
			-1369.12, 365.36, 841.68,   -1403.13, 371.52, 753.85,  -1402.78, 374.86, 724.21,
			-1401.32, 546.36, 728.39,   -1430.47, 535.77, 759.87,
		},
		["2B"] = {
			-1431.49, -159.52, -870.66, -1426.25, -155.57, -831.70, -1426.50, -124.99, -734.44,
			-1427.32, -91.07, -626.58,  -1428.38, -68.39, -531.65, -1451.58, -68.39, -493.83,
			-1458.05, -57.60, -395.31,  -1454.06, -55.90, 84.25,   -1453.39, 216.11, 101.03,
			-1452.85, 224.06, 177.54,   -1454.76, 223.63, 232.80,  -1454.17, 215.87, 349.81,
			-1453.54, 215.80, 627.38,   -1456.03, 367.37, 627.45,  -1453.96, 361.87, 610.04,
			-1457.23, 361.87, 577.12,   -1457.51, 361.07, 498.31,  -1339.56, 361.69, 492.54,
			-1237.99, 329.71, 680.03,   -1218.08, 346.78, 833.47,  -1364.74, 364.94, 841.81,
			-1402.77, 374.52, 724.52,   -1402.77, 552.01, 724.52,  -1404.75, 533.88, 774.48,
			-1403.51, 533.88, 1333.85,  -1431.49, 535.76, 1329.84,
		},
		["3.5B"] = {
			-1432.42, -158.67, -873.54, -1425.42, -155.40, -831.15, -1423.45, -123.18, -729.52,
			-1424.09, -89.99, -623.98,  -1425.54, -68.39, -533.96, -1456.70, -57.79, -396.05,
			-1451.99, -55.89, -287.24,  -1454.36, -55.90, 83.96,   -1454.20, 216.11, 98.65,
			-1452.87, 224.14, 177.83,   -1453.40, 224.56, 229.27,  -1452.67, 215.87, 355.44,
			-1449.89, 215.81, 627.29,   -1450.14, 361.87, 608.74,  -1453.59, 361.07, 486.24,
			-1327.15, 363.83, 504.57,   -1239.51, 329.71, 668.51,  -1210.96, 347.49, 842.50,
			-1367.33, 365.19, 843.88,   -1406.65, 374.86, 726.22,  -1406.03, 553.15, 725.06,
			-1403.44, 533.88, 762.18,   -1403.28, 533.88, 1333.28, -1404.87, 533.87, 1443.51,
			-1442.29, 533.87, 1446.10,  -1454.47, 509.87, 1446.66, -2034.36, 509.87, 1446.50,
			-2063.52, 445.76, 1459.55,
		},
		["5.5B"] = {
			-1431.87, -158.67, -873.48, -1424.96, -152.82, -822.06, -1424.77, -121.32, -722.79,
			-1426.29, -88.58, -618.65,  -1427.16, -68.39, -536.15, -1461.72, -57.30, -394.10,
			-1453.87, -55.93, 84.82,    -1454.98, 216.11, 99.75,   -1453.68, 224.88, 180.66,
			-1456.63, 223.76, 232.30,   -1452.24, 215.87, 626.62,  -1452.46, 366.93, 627.78,
			-1452.92, 361.87, 579.11,   -1453.96, 361.07, 504.08,  -1331.20, 364.35, 514.36,
			-1241.33, 329.71, 677.98,   -1216.42, 347.54, 844.06,  -1368.92, 365.35, 836.69,
			-1402.75, 376.90, 724.85,   -1402.75, 539.30, 724.85,  -1405.38, 533.88, 1350.50,
			-1404.88, 533.87, 1445.64,  -1441.26, 533.87, 1445.75, -1446.52, 509.87, 1446.35,
			-2035.74, 509.87, 1446.68,  -2094.89, 443.87, 1481.56, -2165.62, 451.52, 1484.86,
			-2549.40, 466.44, 1490.01,  -2697.74, 443.87, 1489.95, -2729.62, 452.05, 1487.99,
			-2867.48, 468.49, 1486.04,  -2867.48, 521.11, 1486.04, -2928.40, 526.79, 1485.65,
			-2928.40, 595.25, 1485.65,  -2958.89, 609.93, 1485.07, -3008.75, 603.78, 1483.10,
			-3008.75, 668.29, 1483.10,  -3054.34, 673.39, 1488.47, -3212.13, 673.39, 1485.09,
			-3217.26, 675.27, 1459.30,
		},
		["8.5B"] = {
			-1433.02, -159.52, -869.67, -1428.59, -154.05, -826.85, -1427.78, -123.95, -731.15,
			-1428.42, -90.20, -623.81,  -1428.93, -67.41, -522.14, -1452.20, -68.80, -440.25,
			-1453.14, -57.08, -393.24,  -1454.25, -55.89, -267.37, -1454.18, -55.91, 84.47,
			-1454.45, 216.11, 100.26,   -1453.58, 223.98, 177.26,  -1454.73, 224.03, 231.27,
			-1453.55, 215.87, 626.52,   -1452.86, 365.71, 627.28,  -1454.23, 361.87, 579.40,
			-1456.08, 361.07, 498.32,   -1336.42, 363.37, 508.42,  -1238.99, 329.71, 685.68,
			-1218.30, 346.96, 834.93,   -1367.36, 365.20, 844.13,  -1403.20, 375.59, 724.21,
			-1403.19, 540.90, 724.99,   -1402.99, 533.88, 761.45,  -1405.64, 533.87, 1443.05,
			-1447.26, 509.87, 1445.79,  -2034.52, 509.87, 1446.22, -2085.23, 443.87, 1488.17,
			-2163.88, 451.06, 1486.92,  -2359.77, 448.87, 1488.98, -2548.55, 466.12, 1490.73,
			-2731.79, 452.62, 1489.71,  -2862.77, 452.32, 1485.76, -2933.65, 544.98, 1483.74,
			-2940.32, 599.28, 1484.15,  -3001.40, 604.86, 1486.42, -3001.40, 672.88, 1486.42,
			-3053.83, 673.39, 1487.86,  -3230.28, 673.39, 1484.38, -3654.96, 617.72, 1486.37,
			-3657.42, 619.61, 1458.92,
		},
		["16B"] = {
			-1431.72, -159.12, -872.69, -1428.06, -153.11, -824.02, -1426.08, -122.31, -725.91,
			-1427.13, -88.54, -618.53,  -1426.74, -68.39, -534.98, -1452.66, -56.84, -392.25,
			-1455.37, -55.88, 84.21,    -1453.53, 216.11, 99.57,   -1451.46, 224.36, 178.70,
			-1453.51, 224.55, 229.31,   -1453.04, 215.84, 627.21,  -1453.04, 367.44, 627.21,
			-1456.30, 361.87, 581.04,   -1455.61, 361.07, 492.69,  -1330.21, 364.43, 514.23,
			-1238.15, 329.71, 685.43,   -1219.41, 347.42, 840.05,  -1369.37, 365.39, 841.88,
			-1403.97, 377.39, 725.16,   -1402.54, 551.73, 724.95,  -1403.45, 533.88, 774.07,
			-1405.88, 533.88, 1337.24,  -1402.31, 533.87, 1444.93, -1461.29, 509.87, 1445.25,
			-2036.55, 509.87, 1445.69,  -2087.49, 443.87, 1486.65, -2165.76, 451.56, 1488.19,
			-2264.04, 439.87, 1489.49,  -2344.50, 448.87, 1487.88, -2413.29, 440.20, 1489.55,
			-2547.27, 465.65, 1490.39,  -2731.97, 452.62, 1487.08, -2850.23, 446.46, 1487.22,
			-2850.23, 523.62, 1487.22,  -2901.95, 520.39, 1487.17, -2934.32, 527.92, 1481.75,
			-2938.09, 595.92, 1481.87,  -2977.82, 596.39, 1482.81, -2997.56, 595.91, 1484.26,
			-2997.56, 675.90, 1484.26,  -3050.17, 673.39, 1486.26, -3236.83, 673.39, 1485.30,
			-3655.32, 617.72, 1486.84,  -4129.89, 617.72, 1485.43, -4130.41, 619.61, 1457.34,
		},
		["25B"] = {
			-1431.31, -159.32, -872.31, -1429.99, -153.83, -826.17, -1434.67, -68.34, -540.67,
			-1453.40, -57.19, -393.66,  -1455.61, -55.90, 84.65,   -1456.38, 216.12, 101.43,
			-1456.07, 224.37, 178.70,   -1455.89, 224.04, 231.25,  -1458.94, 216.12, 267.89,
			-1454.79, 215.67, 464.94,   -1454.44, 215.87, 627.58,  -1454.44, 371.15, 627.58,
			-1453.81, 361.87, 578.47,   -1454.58, 361.07, 497.03,  -1328.32, 364.85, 517.14,
			-1218.48, 347.46, 841.29,   -1365.69, 365.03, 842.21,  -1404.04, 374.89, 725.22,
			-1403.50, 540.36, 724.54,   -1404.01, 533.87, 1444.92, -1455.63, 509.87, 1446.72,
			-2035.57, 509.87, 1446.86,  -2080.43, 443.87, 1480.52, -2168.08, 452.17, 1486.14,
			-2357.67, 448.87, 1487.47,  -2550.53, 466.77, 1490.38, -2731.52, 452.55, 1486.04,
			-2863.78, 450.34, 1484.93,  -2863.78, 524.58, 1484.93, -2925.02, 529.89, 1485.10,
			-2925.02, 601.39, 1485.10,  -2999.70, 596.11, 1486.59, -2999.70, 672.74, 1486.59,
			-3053.52, 673.39, 1487.78,  -3235.87, 673.39, 1486.06, -3634.26, 617.72, 1486.90,
			-4154.83, 617.72, 1485.66,  -4171.81, 616.57, 1485.02, -4625.86, 617.56, 1444.29,
			-4971.36, 617.73, 1488.09,  -4968.73, 619.62, 1458.22,
		},
		["40B"] = {
			-1432.21, -158.67, -873.61, -1428.62, -153.51, -825.13, -1426.02, -122.02, -724.99,
			-1425.09, -88.67, -618.93,  -1424.79, -68.39, -536.73, -1452.83, -57.63, -395.43,
			-1452.72, -56.01, 84.52,    -1453.85, 216.11, 100.95,  -1453.13, 224.65, 179.77,
			-1457.74, 224.62, 229.05,   -1455.66, 215.87, 353.34,  -1454.41, 215.86, 626.87,
			-1454.41, 367.99, 626.87,   -1456.93, 361.87, 577.47,  -1327.27, 364.87, 516.38,
			-1241.65, 329.71, 685.19,   -1215.39, 347.40, 839.46,  -1371.24, 365.46, 837.88,
			-1404.74, 374.88, 724.18,   -1404.74, 542.18, 724.18,  -1403.99, 533.88, 781.93,
			-1404.26, 533.87, 1444.32,  -1449.70, 509.87, 1446.36, -2034.65, 509.87, 1446.48,
			-2084.12, 443.87, 1487.32,  -2167.33, 451.97, 1485.82, -2362.14, 448.87, 1488.96,
			-2547.68, 465.80, 1489.24,  -2731.44, 452.53, 1487.93, -2845.96, 448.50, 1485.86,
			-2938.11, 519.52, 1485.11,  -2938.11, 594.82, 1485.11, -2989.22, 679.22, 1483.49,
			-3219.92, 673.39, 1485.31,  -3660.67, 617.72, 1483.97, -4131.78, 617.72, 1485.15,
			-4172.54, 616.59, 1484.84,  -4615.42, 616.80, 1444.20, -4967.89, 617.73, 1484.25,
			-5073.06, 625.98, 1485.00,  -5173.10, 676.88, 1482.77, -5356.93, 735.73, 1483.69,
			-5535.50, 794.97, 1486.48,  -5717.14, 852.74, 1486.76, -5740.81, 854.63, 1459.78,
		},
		["65B"] = {
			-1431.96, -158.92, -873.16, -1426.15, -155.09, -830.16, -1429.48, -68.34, -540.94,
			-1451.93, -57.59, -395.26,  -1453.70, -55.89, -278.98, -1453.25, -55.91, 84.79,
			-1452.48, 216.11, 98.46,   -1452.48, 224.52, 179.30,  -1451.44, 224.41, 229.85,
			-1452.21, 215.87, 356.37,  -1454.23, 215.85, 627.62,  -1454.23, 367.26, 627.62,
			-1455.69, 361.87, 581.01,  -1446.29, 361.07, 485.03,  -1339.20, 363.47, 512.27,
			-1241.68, 329.71, 682.80,  -1216.63, 347.20, 837.34,  -1368.56, 365.31, 844.51,
			-1406.61, 374.72, 724.47,  -1406.04, 552.10, 725.04,  -1404.26, 533.88, 758.94,
			-1402.04, 533.87, 1444.76, -1450.33, 509.87, 1446.58, -2033.83, 509.87, 1447.41,
			-2084.75, 443.87, 1486.14, -2169.31, 452.50, 1490.18, -2546.41, 465.32, 1492.77,
			-2727.13, 451.39, 1485.06, -2864.75, 456.90, 1486.13, -2864.75, 525.85, 1486.13,
			-2929.10, 521.47, 1488.71, -2929.10, 597.79, 1488.71, -3011.30, 603.32, 1486.91,
			-3011.30, 675.99, 1486.91, -3055.52, 673.39, 1484.17, -3242.61, 673.39, 1486.13,
			-3656.64, 617.72, 1486.22, -4139.87, 617.72, 1484.30, -4607.34, 617.00, 1442.07,
			-4829.65, 616.95, 1553.17, -4967.82, 617.73, 1484.50, -5179.13, 676.73, 1485.06,
			-5256.07, 685.72, 1488.08, -5357.59, 735.73, 1486.86, -5434.85, 744.46, 1488.08,
			-5534.48, 795.23, 1484.71, -5612.79, 802.92, 1484.40, -5715.81, 853.06, 1486.45,
			-5760.78, 852.74, 1486.77, -5942.59, 851.48, 1439.41, -6076.44, 851.48, 1469.20,
			-6294.50, 851.48, 1525.87, -6370.42, 851.48, 1448.65, -6658.79, 852.75, 1484.75,
			-6662.08, 854.64, 1460.21,
		},
		["100B"] = {
			-1432.21, -158.67, -873.61, -1428.62, -153.51, -825.13, -1426.02, -122.02, -724.99,
			-1425.09, -88.67, -618.93,  -1424.79, -68.39, -536.73, -1452.83, -57.63, -395.43,
			-1452.72, -56.01, 84.52,    -1453.85, 216.11, 100.95,  -1453.13, 224.65, 179.77,
			-1457.74, 224.62, 229.05,   -1455.66, 215.87, 353.34,  -1454.41, 215.86, 626.87,
			-1454.41, 367.99, 626.87,   -1456.93, 361.87, 577.47,  -1327.27, 364.87, 516.38,
			-1241.65, 329.71, 685.19,   -1215.39, 347.40, 839.46,  -1371.24, 365.46, 837.88,
			-1404.74, 374.88, 724.18,   -1404.74, 542.18, 724.18,  -1403.99, 533.88, 781.93,
			-1404.26, 533.87, 1444.32,  -1449.70, 509.87, 1446.36, -2034.65, 509.87, 1446.48,
			-2084.12, 443.87, 1487.32,  -2167.33, 451.97, 1485.82, -2362.14, 448.87, 1488.96,
			-2547.68, 465.80, 1489.24,  -2731.44, 452.53, 1487.93, -2845.96, 448.50, 1485.86,
			-2938.11, 519.52, 1485.11,  -2938.11, 594.82, 1485.11, -2989.22, 679.22, 1483.49,
			-3219.92, 673.39, 1485.31,  -3660.67, 617.72, 1483.97, -4131.78, 617.72, 1485.15,
			-4172.54, 616.59, 1484.84,  -4615.42, 616.80, 1444.20, -4967.89, 617.73, 1484.25,
			-5073.06, 625.98, 1485.00,  -5173.10, 676.88, 1482.77, -5356.93, 735.73, 1483.69,
			-5535.50, 794.97, 1486.48,  -5717.14, 852.74, 1486.76, -5740.40, 852.74, 1485.79,
			-5862.51, 851.48, 1482.00,  -6069.16, 851.48, 1480.36, -6212.12, 851.48, 1604.95,
			-6429.98, 851.48, 1365.79,  -6547.52, 851.48, 1481.12, -6687.09, 852.75, 1487.40,
			-6691.49, 935.17, 1526.34,  -7278.52, 935.17, 1527.35, -7478.82, 934.84, 1615.06,
			-7544.61, 935.17, 1679.40,  -8043.85, 935.17, 1680.06, -8156.35, 935.17, 1682.50,
			-8315.41, 935.17, 1525.50,  -9296.99, 935.17, 1526.07, -9344.72, 852.75, 1508.12,
			-9513.96, 852.76, 1484.80,  -9515.00, 854.64, 1458.11,
		},
		["200B"] = {
			-1431.96, -158.92, -873.16, -1426.15, -155.09, -830.16, -1429.48, -68.34, -540.94,
			-1451.93, -57.59, -395.26,  -1453.70, -55.89, -278.98, -1453.25, -55.91, 84.79,
			-1452.48, 216.11, 98.46,   -1452.48, 224.52, 179.30,  -1451.44, 224.41, 229.85,
			-1452.21, 215.87, 356.37,  -1454.23, 215.85, 627.62,  -1454.23, 367.26, 627.62,
			-1455.69, 361.87, 581.01,  -1446.29, 361.07, 485.03,  -1339.20, 363.47, 512.27,
			-1241.68, 329.71, 682.80,  -1216.63, 347.20, 837.34,  -1368.56, 365.31, 844.51,
			-1406.61, 374.72, 724.47,  -1406.04, 552.10, 725.04,  -1404.26, 533.88, 758.94,
			-1402.04, 533.87, 1444.76, -1450.33, 509.87, 1446.58, -2033.83, 509.87, 1447.41,
			-2084.75, 443.87, 1486.14, -2169.31, 452.50, 1490.18, -2546.41, 465.32, 1492.77,
			-2727.13, 451.39, 1485.06, -2864.75, 456.90, 1486.13, -2864.75, 525.85, 1486.13,
			-2929.10, 521.47, 1488.71, -2929.10, 597.79, 1488.71, -3011.30, 603.32, 1486.91,
			-3011.30, 675.99, 1486.91, -3055.52, 673.39, 1484.17, -3242.61, 673.39, 1486.13,
			-3656.64, 617.72, 1486.22, -4139.87, 617.72, 1484.30, -4607.34, 617.00, 1442.07,
			-4829.65, 616.95, 1553.17, -4967.82, 617.73, 1484.50, -5179.13, 676.73, 1485.06,
			-5256.07, 685.72, 1488.08, -5357.59, 735.73, 1486.86, -5434.85, 744.46, 1488.08,
			-5534.48, 795.23, 1484.71, -5612.79, 802.92, 1484.40, -5715.81, 853.06, 1486.45,
			-5760.78, 852.74, 1486.77, -5942.59, 851.48, 1439.41, -6076.44, 851.48, 1469.20,
			-6294.50, 851.48, 1525.87, -6370.42, 851.48, 1448.65, -6658.79, 852.75, 1484.75,
			-6688.07, 852.90, 1522.44, -6693.09, 935.17, 1527.54, -7274.96, 935.17, 1526.68,
			-7463.34, 935.17, 1597.91, -7544.07, 935.17, 1679.60, -8044.28, 934.65, 1679.06,
			-8158.95, 935.17, 1680.90, -8315.85, 935.17, 1526.05, -9297.00, 935.17, 1525.68,
			-9383.17, 852.75, 1497.72, -9513.67, 852.76, 1484.61, -9616.35, 860.15, 1486.68,
			-9815.02, 861.33, 1486.92, -9956.88, 852.76, 1489.17, -10152.35, 852.76, 1478.86,
			-10207.42, 860.86, 1481.97, -10352.44, 852.76, 1488.02,-10402.05, 861.58, 1485.28,
			-10511.38, 852.76, 1489.48, -10704.16, 861.09, 1493.10,-10804.40, 852.75, 1484.35,
			-10806.13, 854.64, 1459.29,
		},
		["1T"] = {
			-1431.96, -158.92, -873.16, -1426.15, -155.09, -830.16, -1429.48, -68.34, -540.94,
			-1451.93, -57.59, -395.26,  -1453.70, -55.89, -278.98, -1453.25, -55.91, 84.79,
			-1452.48, 216.11, 98.46,   -1452.48, 224.52, 179.30,  -1451.44, 224.41, 229.85,
			-1452.21, 215.87, 356.37,  -1454.23, 215.85, 627.62,  -1454.23, 367.26, 627.62,
			-1455.69, 361.87, 581.01,  -1446.29, 361.07, 485.03,  -1339.20, 363.47, 512.27,
			-1241.68, 329.71, 682.80,  -1216.63, 347.20, 837.34,  -1368.56, 365.31, 844.51,
			-1406.61, 374.72, 724.47,  -1406.04, 552.10, 725.04,  -1404.26, 533.88, 758.94,
			-1402.04, 533.87, 1444.76, -1450.33, 509.87, 1446.58, -2033.83, 509.87, 1447.41,
			-2084.75, 443.87, 1486.14, -2169.31, 452.50, 1490.18, -2546.41, 465.32, 1492.77,
			-2727.13, 451.39, 1485.06, -2864.75, 456.90, 1486.13, -2864.75, 525.85, 1486.13,
			-2929.10, 521.47, 1488.71, -2929.10, 597.79, 1488.71, -3011.30, 603.32, 1486.91,
			-3011.30, 675.99, 1486.91, -3055.52, 673.39, 1484.17, -3242.61, 673.39, 1486.13,
			-3656.64, 617.72, 1486.22, -4139.87, 617.72, 1484.30, -4607.34, 617.00, 1442.07,
			-4829.65, 616.95, 1553.17, -4967.82, 617.73, 1484.50, -5179.13, 676.73, 1485.06,
			-5256.07, 685.72, 1488.08, -5357.59, 735.73, 1486.86, -5434.85, 744.46, 1488.08,
			-5534.48, 795.23, 1484.71, -5612.79, 802.92, 1484.40, -5715.81, 853.06, 1486.45,
			-5760.78, 852.74, 1486.77, -5942.59, 851.48, 1439.41, -6076.44, 851.48, 1469.20,
			-6294.50, 851.48, 1525.87, -6370.42, 851.48, 1448.65, -6658.79, 852.75, 1484.75,
			-6688.07, 852.90, 1522.44, -6693.09, 935.17, 1527.54, -7274.96, 935.17, 1526.68,
			-7463.34, 935.17, 1597.91, -7544.07, 935.17, 1679.60, -8044.28, 934.65, 1679.06,
			-8158.95, 935.17, 1680.90, -8315.85, 935.17, 1526.05, -9297.00, 935.17, 1525.68,
			-9383.17, 852.75, 1497.72, -9513.67, 852.76, 1484.61, -9616.35, 860.15, 1486.68,
			-9815.02, 861.33, 1486.92, -9956.88, 852.76, 1489.17, -10152.35, 852.76, 1478.86,
			-10207.42, 860.86, 1481.97, -10352.44, 852.76, 1488.02,-10402.05, 861.58, 1485.28,
			-10511.38, 852.76, 1489.48, -10704.16, 861.09, 1493.10,-10804.40, 852.75, 1484.35,
			-10807.14, 852.75, 1484.99, -10832.41, 852.75, 1521.11,-10832.41, 992.81, 1521.11,
			-10906.71, 850.74, 1484.42, -12578.12, 850.63, 1487.01,-12609.93, 850.63, 1449.07,
			-12875.68, 897.62, 1443.87,-13377.35, 987.81, 1445.84,-13683.93, 1027.44, 1449.26,
			-14334.57, 1029.46, 1458.59,-14508.47, 1041.37, 1486.16,-14878.42, 1042.12, 1503.89,
			-15250.37, 1043.28, 1486.07,-15409.18, 1029.46, 1485.63,-15845.32, 1015.44, 1486.26,
			-17176.03, 1015.45, 1493.41,-17416.55, 1015.43, 1734.10,-17869.25, 1015.43, 1261.14,
			-18345.84, 1015.43, 1744.44,-18793.70, 1015.43, 1268.23,-19052.30, 1015.45, 1518.14,
			-19214.49, 1015.45, 1517.26,-19546.52, 953.54, 1585.88,-19874.57, 898.67, 1413.42,
			-20207.19, 844.81, 1594.38,-20566.63, 782.59, 1428.02,-20952.81, 733.79, 1519.97,
			-21346.33, 735.41, 1515.16,-21548.93, 721.93, 1519.85,-22096.87, 672.25, 1518.28,
			-23275.21, 674.64, 1516.50,
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

	local ROUTE_ORDER_W2 = { "150K", "400K", "600K", "1M", "1.5M", "2.5M", "4M", "6M", "10M", "15M", "25M", "40M", "60M" }
	local ROUTE_ORDER_W3 = { "300M", "500M", "800M", "1.25B", "2B", "3.5B", "5.5B", "8.5B", "16B", "25B", "40B", "65B", "100B", "200B", "1T" }

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

	local farmW2 = makeFarmModule(ROUTES_W2, ROUTE_ORDER_W2[1])
	local farmW3 = makeFarmModule(ROUTES_W3, ROUTE_ORDER_W3[1])

	-- World 2
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
		Callback = function(value)
			farmW2.setRoute(value)
		end,
	})

	tabW2:Slider({
		Title = "Fly Speed",
		Desc = "Adjust the flight speed.",
		Step = 10,
		Value = { Min = 20, Max = 500, Default = 120 },
		Callback = function(value) farmW2.setSpeed(value) end,
	})

	-- World 3
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
		Callback = function(value)
			farmW3.setRoute(value)
		end,
	})

	tabW3:Slider({
		Title = "Fly Speed",
		Desc = "Adjust the flight speed.",
		Step = 10,
		Value = { Min = 20, Max = 500, Default = 120 },
		Callback = function(value) farmW3.setSpeed(value) end,
	})

	WindUI:Notify({ Title = "⚡ POTENT HUB", Content = "✅ +1 Speed Keyboard Escape loaded!", Duration = 4 })
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
	elseif game.PlaceId == 104715542330896 then
		showMaintenanceScreen()
	elseif game.PlaceId == 142823291 then
		runMM2()
	elseif game.PlaceId == 77813828595591 then
		runKittenFarm()
	elseif game.PlaceId == 118941584817777 or game.PlaceId == 93411036959889 then
		runSpeedKeyboardEscape()
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
