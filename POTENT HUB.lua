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

	-- Closes automatically after 5 seconds.
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
	label.Text = "THIS GAME IS NOT YET SUPPORTED\nIF YOU WANT TO KNOW WHICH GAMES IT SUPPORTS, JOIN THE DISCORD SERVER"
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
	supportLabel.Text = "🟢 Support:\nSpeed Monkey Escape, Block Spin, Murder Mystery 2, Kitten Farm"
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
			if button then pcall(function() firetouchinterest(hrp, button, 0) firetouchinterest(hrp, button, 1) end) end
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
					pcall(function() firetouchinterest(hrp, part, 0) end)
					hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
					task.wait(0.15)
					pcall(function() firetouchinterest(hrp, part, 1) end)
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
				runLoop("AutoCollectBananas", function() return autoCollectBananas end, function()
					for _, v in workspaceService:GetDescendants() do
						if v.Name:lower():find("banana") and v:IsA("BasePart") and LocalPlayer.Character then
							local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then pcall(function() firetouchinterest(hrp, v, 0) task.wait(0.05) firetouchinterest(hrp, v, 1) end) end
						end
					end
					for _, p in workspaceService:GetDescendants() do
						if p:IsA("ProximityPrompt") and p.ObjectText:lower():find("banana") then
							pcall(function() fireproximityprompt(p) end)
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

local function runSpeedMonkeyEscape2()
	runSpeedMonkeyEscape()
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
			firetouchinterest(hrp, press, 1)
			task.wait(0.08)
			firetouchinterest(hrp, press, 0)
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
				for _, c in ipairs(getconnections(LocalPlayer.Idled)) do c:Disable() end
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

	serverTab:Section({ Title = "🔁 Auto Rejoin" })
	local autoRejoin = false
	serverTab:Toggle({
		Title = "Auto Rejoin on Kick / Disconnect", Value = false,
		Callback = function(state) autoRejoin = state end,
	})

	task.spawn(function()
		while true do
			task.wait(0.5)
			if autoRejoin then
				pcall(function()
					local errorGui = coreGui:FindFirstChild("RobloxPromptGui")
					if errorGui then
						local promptOverlay = errorGui:FindFirstChild("promptOverlay")
						if promptOverlay and #promptOverlay:GetChildren() > 0 then
							teleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, game.JobId, LocalPlayer)
						end
					end
				end)
			end
		end
	end)

	guiService.ErrorMessageChanged:Connect(function(msg)
		if autoRejoin and msg and msg ~= "" then
			pcall(function()
				task.wait(2)
				teleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, game.JobId, LocalPlayer)
			end)
		end
	end)

	serverTab:Button({
		Title = "🔁 Rejoin Server Now",
		Callback = function()
			WindUI:Notify({ Title = "Rejoin", Content = "🔁 Rejoining...", Duration = 2 })
			task.wait(0.5)
			pcall(function() teleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, game.JobId, LocalPlayer) end)
		end,
	})

	serverTab:Section({ Title = "🌐 Server Hop" })
	local minPlayers, maxPlayers = 1, 20
	serverTab:Slider({
		Title = "Min Players", Step = 1, Value = { Min = 1, Max = 30, Default = 1 },
		Callback = function(v) minPlayers = tonumber(v) or 1 end,
	})
	serverTab:Slider({
		Title = "Max Players", Step = 1, Value = { Min = 1, Max = 100, Default = 20 },
		Callback = function(v) maxPlayers = tonumber(v) or 20 end,
	})

	local function serverHop()
		local url = "https://games.roblox.com/v1/games/" .. TARGET_PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
		local ok, body = pcall(customHttpGet, url)
		if not ok or not body then
			WindUI:Notify({ Title = "Server Hop", Content = "❌ HTTP failed", Duration = 3 })
			return
		end
		local decoded
		pcall(function() decoded = httpService:JSONDecode(body) end)
		if not decoded or not decoded.data then
			WindUI:Notify({ Title = "Server Hop", Content = "❌ Bad response", Duration = 3 })
			return
		end
		local candidates = {}
		for _, srv in ipairs(decoded.data) do
			if srv.id ~= game.JobId and srv.playing >= minPlayers and srv.playing <= maxPlayers and srv.playing < srv.maxPlayers then
				table.insert(candidates, srv)
			end
		end
		if #candidates == 0 then
			WindUI:Notify({ Title = "Server Hop", Content = "❌ No servers found", Duration = 3 })
			return
		end
		local pick = candidates[math.random(1, #candidates)]
		WindUI:Notify({ Title = "Server Hop", Content = "🌐 Hopping to server (" .. pick.playing .. " players)", Duration = 2 })
		task.wait(0.5)
		pcall(function() teleportService:TeleportToPlaceInstance(TARGET_PLACE_ID, pick.id, LocalPlayer) end)
	end

	serverTab:Button({ Title = "🌐 Server Hop Now", Callback = serverHop })

	local autoServerHop = false
	local hopInterval = 300
	serverTab:Toggle({
		Title = "Auto Server Hop", Desc = "Hop to a new server periodically", Value = false,
		Callback = function(state)
			autoServerHop = state
			if state then
				runAutoLoop("AutoServerHop", function() return autoServerHop end, function() serverHop() end, hopInterval)
			else
				stopLoop("AutoServerHop")
			end
		end,
	})
	serverTab:Slider({
		Title = "Server Hop Interval (seconds)", Step = 30, Value = { Min = 60, Max = 1800, Default = 300 },
		Callback = function(v)
			hopInterval = tonumber(v) or 300
			if autoServerHop then
				stopLoop("AutoServerHop")
				runAutoLoop("AutoServerHop", function() return autoServerHop end, function() serverHop() end, hopInterval)
			end
		end,
	})

	webhookTab:Section({ Title = "🔔 Discord Webhook" })
	webhookTab:Input({
		Title = "Webhook URL", Value = "", Placeholder = "https://discord.com/api/webhooks/...",
		Callback = function(v) webhookUrl = v or "" end,
	})
	webhookTab:Button({
		Title = "📤 Send Test Message",
		Callback = function()
			if not webhookUrl or webhookUrl == "" then
				WindUI:Notify({ Title = "Webhook", Content = "❌ Set a URL first", Duration = 3 })
				return
			end
			sendWebhook(
				"🧪 Test Notification",
				string.format("Player: **%s**\nMoney: **%s**\nYarn: **%s**\nRebirths: **%s**",
					LocalPlayer.Name, tostring(getMoney()), tostring(getYarn()), tostring(getRebirths())),
				5814783
			)
			WindUI:Notify({ Title = "Webhook", Content = "✅ Test sent", Duration = 3 })
		end,
	})

	webhookTab:Section({ Title = "🎯 Notify Events" })
	local notifyRebirths = false
	webhookTab:Toggle({
		Title = "Notify Rebirths", Value = false,
		Callback = function(state) notifyRebirths = state end,
	})

	local notifyMoneyMilestone = false
	local moneyMilestoneStep = 1000000
	webhookTab:Toggle({
		Title = "Notify Money Milestones", Value = false,
		Callback = function(state) notifyMoneyMilestone = state end,
	})
	webhookTab:Slider({
		Title = "Money Milestone Step", Step = 100000, Value = { Min = 100000, Max = 100000000, Default = 1000000 },
		Callback = function(v) moneyMilestoneStep = tonumber(v) or 1000000 end,
	})

	local notifyYarnMilestone = false
	local yarnMilestoneStep = 10000
	webhookTab:Toggle({
		Title = "Notify Yarn Milestones", Value = false,
		Callback = function(state) notifyYarnMilestone = state end,
	})
	webhookTab:Slider({
		Title = "Yarn Milestone Step", Step = 1000, Value = { Min = 1000, Max = 1000000, Default = 10000 },
		Callback = function(v) yarnMilestoneStep = tonumber(v) or 10000 end,
	})

	task.spawn(function()
		local lastMoneyMilestone = 0
		local lastYarnMilestone = 0
		task.wait(3)
		lastMoneyMilestone = math.floor(getMoney() / moneyMilestoneStep)
		lastYarnMilestone = math.floor(getYarn() / yarnMilestoneStep)

		while true do
			task.wait(5)
			pcall(function()
				local curRebirths = getRebirths()
				if notifyRebirths and curRebirths > lastRebirthNotified then
					lastRebirthNotified = curRebirths
					sendWebhook(
						"🔄 Rebirth!",
						string.format("**%s** just rebirthed!\nTotal rebirths: **%d**", LocalPlayer.Name, curRebirths),
						16766720
					)
				end

				if notifyMoneyMilestone then
					local curMilestone = math.floor(getMoney() / moneyMilestoneStep)
					if curMilestone > lastMoneyMilestone then
						lastMoneyMilestone = curMilestone
						sendWebhook(
							"💰 Money Milestone!",
							string.format("**%s** reached **%s** money!", LocalPlayer.Name, tostring(curMilestone * moneyMilestoneStep)),
							5763719
						)
					end
				end

				if notifyYarnMilestone then
					local curMilestone = math.floor(getYarn() / yarnMilestoneStep)
					if curMilestone > lastYarnMilestone then
						lastYarnMilestone = curMilestone
						sendWebhook(
							"🧶 Yarn Milestone!",
							string.format("**%s** reached **%s** yarn!", LocalPlayer.Name, tostring(curMilestone * yarnMilestoneStep)),
							3447003
						)
					end
				end
			end)
		end
	end)

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
