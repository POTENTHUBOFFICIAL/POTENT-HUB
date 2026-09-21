-- ============================================================
-- POTENT HUB - MULTI GAME HUB
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
local debrisService = game:GetService("Debris")
local contextActionService = game:GetService("ContextActionService")
local statsService = game:GetService("Stats")

-- ========== PLACE IDS SOPORTADOS ==========
local SUPPORTED_PLACES = {
	[114697347887839] = true, -- Juego 1: +1 Speed Monkey Escape
	[104715542330896] = true, -- Juego 2: Block Spin 🔫
}

-- ========== CONFIGURACIÓN DE KEY ==========
local KEY_FILE = "potent_key.txt"
local KEY_DURATION = 24 * 60 * 60
local DISCORD_URL = "https://discord.gg/X7Y4NzuC67"
local VALID_KEY = "POTENTHUB372635263526"

-- ============================================================
-- ========== PANTALLA NO SOPORTADO ==========
-- ============================================================

local function showUnsupportedScreen()
	local guiParent = coreGui
	pcall(function()
		if gethui then guiParent = gethui() end
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PotentUnsupported"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 9999
	screenGui.IgnoreGuiInset = true

	local ok = pcall(function() screenGui.Parent = guiParent end)
	if not ok then
		screenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui")
	end

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BackgroundTransparency = 0
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
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.ZIndex = 3
	label.Parent = main

	local supportLabel = Instance.new("TextLabel")
	supportLabel.Size = UDim2.new(1, -40, 0, 60)
	supportLabel.Position = UDim2.new(0, 20, 0, 145)
	supportLabel.BackgroundTransparency = 1
	supportLabel.Text = "🟢 Support:\nSpeed Monkey Escape, Block Spin 🔫"
	supportLabel.TextColor3 = Color3.fromRGB(0, 200, 100)
	supportLabel.Font = Enum.Font.GothamBold
	supportLabel.TextSize = 16
	supportLabel.TextWrapped = true
	supportLabel.TextXAlignment = Enum.TextXAlignment.Center
	supportLabel.TextYAlignment = Enum.TextYAlignment.Center
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

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(45, 45, 55)
	stroke.Thickness = 1.5
	stroke.Parent = discordBtn

	discordBtn.MouseEnter:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
	end)
	discordBtn.MouseLeave:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
	end)

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
		if setclipboard then
			setclipboard(DISCORD_URL)
			status.Text = "✅ DISCORD LINK COPIED! JOIN AND GET YOUR KEY."
			status.TextColor3 = Color3.fromRGB(0, 200, 100)
		else
			status.Text = "⚠️ COPY THIS LINK: " .. DISCORD_URL
			status.TextColor3 = Color3.fromRGB(0, 200, 100)
		end
		task.delay(5, function()
			if status and status.Parent then
				status.Text = ""
			end
		end)
	end)

	task.delay(15, function()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)

	return screenGui
end

-- ============================================================
-- ========== SISTEMA DE KEY ==========
-- ============================================================

local function isKeyValidLocally()
	if not isfile or not readfile or not isfile(KEY_FILE) then
		return false
	end
	local success, content = pcall(readfile, KEY_FILE)
	if not success or not content or content == "" then
		return false
	end
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

local function isValidKey(key)
	return key == VALID_KEY
end

local function showKeySystem(onSuccess)
	local Theme = {
		Background = Color3.fromRGB(20, 20, 25),
		Border = Color3.fromRGB(45, 45, 55),
		Accent = Color3.fromRGB(88, 101, 242),
		AccentHover = Color3.fromRGB(114, 137, 218),
		Text = Color3.fromRGB(240, 240, 245),
		TextDim = Color3.fromRGB(150, 150, 160),
		InputBg = Color3.fromRGB(30, 30, 38),
		Success = Color3.fromRGB(0, 200, 100),
		Error = Color3.fromRGB(220, 50, 50),
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

	local guiParent = coreGui
	pcall(function()
		if gethui then guiParent = gethui() end
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PotentKeySystem"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.IgnoreGuiInset = true

	local ok = pcall(function() screenGui.Parent = guiParent end)
	if not ok then
		screenGui.Parent = playersService.LocalPlayer:WaitForChild("PlayerGui")
	end

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
	tweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.new(0, 380, 0, 260)
	}):Play()

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
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.AccentHover}):Play()
	end)
	discordBtn.MouseLeave:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
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
		tweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
	end)
	input.FocusLost:Connect(function()
		tweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = Theme.Border}):Play()
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
		if setclipboard then
			setclipboard(DISCORD_URL)
			status.Text = "✅ Discord link copied! Join and get your key."
			status.TextColor3 = Theme.Success
		else
			status.Text = "⚠️ Copy this link: " .. DISCORD_URL
			status.TextColor3 = Theme.Success
		end
		task.delay(5, function()
			if status and status.Parent then
				status.Text = ""
			end
		end)
	end)

	local function onVerify()
		local userKey = input.Text
		if not userKey or userKey == "" then
			status.Text = "❌ Please enter a key first!"
			status.TextColor3 = Theme.Error
			return
		end
		if not isValidKey(userKey) then
			status.Text = "❌ Invalid key! Get one from Discord."
			status.TextColor3 = Theme.Error
			return
		end
		status.Text = "⏳ Validating..."
		status.TextColor3 = Theme.TextDim
		task.wait(0.8)
		status.Text = "✅ Key valid! Loading script..."
		status.TextColor3 = Theme.Success
		saveKey(userKey)
		task.wait(1)
		tweenService:Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(0.35)
		screenGui:Destroy()
		if onSuccess then onSuccess() end
	end

	input.FocusLost:Connect(function(enter)
		if enter then onVerify() end
	end)
end

-- ============================================================
-- ========== JUEGO 1: SPEED MONKEY ESCAPE ==========
-- ============================================================

local function runSpeedMonkeyEscape()
	local Remotes = replicatedStorage:WaitForChild("Remotes")
	local LocalPlayer = playersService.LocalPlayer
	local Data = LocalPlayer:WaitForChild("Data")

	local GameName = "+1 Speed Monkey Escape"
	pcall(function() GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)

	local success, WindUI = pcall(function()
		return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
	end)
	if not success or not WindUI then
		warn("Failed to load WindUI: " .. tostring(WindUI))
		return
	end

	local window = WindUI.CreateWindow(WindUI, {
		Title = "⚡ POTENT HUB",
		Author = "👑 MADE BY POTENT HUB",
		Folder = "POTENTHUB_SPEED_MONKEY",
		Size = UDim2.fromOffset(580, 520),
		Transparent = true,
		Theme = "Dark"
	})

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
		if cn == "RemoteEvent" then
			ok, err = pcall(function(...) remote:FireServer(...) end, ...)
		elseif cn == "RemoteFunction" then
			ok, err = pcall(function(...) return remote:InvokeServer(...) end, ...)
		else
			ok, err = pcall(function(...) remote:FireServer(...) end, ...)
		end
		if not ok then warn("[FireFailed] " .. remote.Name .. ": " .. tostring(err)) end
		return ok
	end

	local function runLoop(id, isActive, fn, interval)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
		Loops[id] = task.spawn(function()
			while isActive() do
				local ok, err = pcall(fn)
				if not ok then warn("[" .. id .. "]", err) end
				task.wait(interval or 0.5)
			end
			Loops[id] = nil
		end)
	end

	local function stopLoop(id)
		if Loops[id] then task.cancel(Loops[id]) Loops[id] = nil end
	end

	local function isTreadmillUnlocked(ttype)
		if ttype == "Sunken" then
			local s = Data:FindFirstChild("CollectedShards")
			if not s or #s:GetChildren() < 9 then return false end
		end
		if ttype == "Quantum" then return false end
		local paidList = {Golden=true, Diamond=true, Galaxy=true, Void=true, Celestial=true}
		if not paidList[ttype] then return true end
		return Data.Passes:FindFirstChild(ttype) ~= nil
	end

	local function getTreadmillPart(preferred)
		local best = nil
		local bestMulti = -1
		for _, part in collectionService:GetTagged("Treadmill") do
			if part:IsA("BasePart") and part:IsDescendantOf(workspaceService) then
				local ttype = part:GetAttribute("Type") or part.Name
				if not isTreadmillUnlocked(ttype) then continue end
				local multi = TreadmillCfg.Multis[ttype] or 0
				if preferred and ttype:lower() == preferred:lower() then return part end
				if not preferred then
					if multi > bestMulti then bestMulti = multi best = part end
				end
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
		local BN = nil
		pcall(function() BN = require(replicatedStorage.Util.BigNum) end)
		if not BN then BN = {GreaterEqual = function(a, b) return (a.Value or 0) >= b end} end
		local best = nil
		local bestReq = -1
		for idx, cfg in ipairs(UpgradesCfg) do
			local req = cfg and cfg.WinsRequirement
			if cfg and not Data.UnlockedUpgrades:FindFirstChild(tostring(idx)) and req then
				local affordable = false
				if BN.GreaterEqual then
					affordable = BN.GreaterEqual(Data.Wins, req)
				else
					affordable = (Data.Wins.Value or 0) >= req
				end
				if affordable and req > bestReq then bestReq = req best = idx end
			end
		end
		return best
	end

	local function getBestOwned()
		local maxIdx = 1
		for _, v in Data.UnlockedUpgrades:GetChildren() do
			local n = tonumber(v.Name)
			if n and n > maxIdx then maxIdx = n end
		end
		return maxIdx
	end

	local function farmWinsFluid(id, isActive, pos, brickName)
		if Loops[id] then Loops[id]:Disconnect() Loops[id] = nil end

		local cachedButton = nil
		local lastButtonSearch = 0
		local function findButton()
			local now = tick()
			if cachedButton and cachedButton.Parent and (now - lastButtonSearch) < 5 then
				return cachedButton
			end
			lastButtonSearch = now
			local bestPart = nil
			local bestDist = 80
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

		local time = 0
		local renderConn
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
			if button then
				pcall(function()
					firetouchinterest(hrp, button, 0)
					firetouchinterest(hrp, button, 1)
				end)
			end
		end)

		Loops[id] = {
			Disconnect = function()
				if renderConn then renderConn:Disconnect() end
				ActiveFarmWins[id] = nil
			end
		}
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
		else
			if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
		end
	end

	task.spawn(function()
		while true do
			task.wait(1)
			local hasActiveFarm = false
			for _ in pairs(ActiveFarmWins) do hasActiveFarm = true break end

			for _, obj in workspaceService:GetDescendants() do
				if obj:IsA("SpawnLocation") then
					if hasActiveFarm then
						if obj.Enabled then obj.Enabled = false end
					else
						if not obj.Enabled then obj.Enabled = true end
					end
				end
			end
		end
	end)

	local mainTab = window:Tab({ Title = "🏠 Main", Icon = "house" })
	local farmingTab = window:Tab({ Title = "🚜 Farming", Icon = "tractor" })
	local inventoryTab = window:Tab({ Title = "🎒 Inventory", Icon = "backpack" })
	local rebirthTab = window:Tab({ Title = "🔄 Rebirth", Icon = "refresh-cw" })
	local settingsTab = window:Tab({ Title = "⚙️ Settings", Icon = "settings" })

	local mainInfoSection = mainTab:Section({ Title = "ℹ️ Info" })
	mainInfoSection:Paragraph({ Title = "Game", Desc = GameName })
	mainInfoSection:Paragraph({ Title = "PlaceId", Desc = tostring(game.PlaceId) })
	mainInfoSection:Button({
		Title = "📋 Copy Game Name",
		Callback = function()
			if setclipboard then setclipboard(GameName) end
			WindUI:Notify({Title = "Copied!", Content = GameName, Duration = 3})
		end
	})

	local farmingTrainSection = farmingTab:Section({ Title = "🏃 Train" })

	local selectedTreadmill = "Basic"
	farmingTrainSection:Dropdown({
		Title = "Manual Treadmill",
		Values = {"Basic","Golden","Diamond","Galaxy","Void","Celestial","Sunken","Quantum","Reward","Emerald"},
		Value = "Basic",
		Callback = function(value) selectedTreadmill = value end
	})

	local autoTrainEnabled = false
	farmingTrainSection:Toggle({
		Title = "Auto Train on Treadmill",
		Value = false,
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
			else
				stopLoop("AutoTrain")
			end
		end
	})

	local farmingWinsSection = farmingTab:Section({ Title = "🪙 Wins" })

	local worlds = {"World1", "World2", "World3", "World4", "World5"}

	for _, world in ipairs(worlds) do
		local normalActive = false
		local normalId = "AutoWins_" .. world

		farmingWinsSection:Toggle({
			Title = world:gsub("World", "WORLD ") .. " - Normal",
			Value = false,
			Callback = function(state)
				normalActive = state
				if state then
					farmWinsFluid(normalId, function() return normalActive end, TeleportPositions[world].Normal, "New Yeller")
				else
					if Loops[normalId] and type(Loops[normalId]) == "table" then
						Loops[normalId]:Disconnect()
						Loops[normalId] = nil
					else
						stopLoop(normalId)
					end
				end
			end
		})

		local vipActive = false
		local vipId = "AutoFarmVip_" .. world

		farmingWinsSection:Toggle({
			Title = world:gsub("World", "WORLD ") .. " - Farm Win VIP",
			Value = false,
			Callback = function(state)
				vipActive = state
				if state then
					farmWinsFluid(vipId, function() return vipActive end, TeleportPositions[world].VIP, "Really Red")
				else
					if Loops[vipId] and type(Loops[vipId]) == "table" then
						Loops[vipId]:Disconnect()
						Loops[vipId] = nil
					else
						stopLoop(vipId)
					end
				end
			end
		})
	end

	local farmingWinsChapter2Section = farmingTab:Section({ Title = "🪙 Wins Chapter2" })

	local normalActiveCh2 = false
	local normalIdCh2 = "AutoWinsCh2_World1"
	local Ch2NormalPos = Vector3.new(-3548.34, 112.44, -255.17)

	farmingWinsChapter2Section:Toggle({
		Title = "WORLD 1 - Normal",
		Value = false,
		Callback = function(state)
			normalActiveCh2 = state
			if state then
				farmWinsFluid(normalIdCh2, function() return normalActiveCh2 end, Ch2NormalPos, "New Yeller")
			else
				if Loops[normalIdCh2] and type(Loops[normalIdCh2]) == "table" then
					Loops[normalIdCh2]:Disconnect()
					Loops[normalIdCh2] = nil
				else
					stopLoop(normalIdCh2)
				end
			end
		end
	})

	local vipActiveCh2 = false
	local vipIdCh2 = "AutoFarmVipCh2_World1"
	local Ch2VipPos = Vector3.new(-3566.30, 112.68, -254.38)

	farmingWinsChapter2Section:Toggle({
		Title = "WORLD 1 - Farm Win VIP",
		Value = false,
		Callback = function(state)
			vipActiveCh2 = state
			if state then
				farmWinsFluid(vipIdCh2, function() return vipActiveCh2 end, Ch2VipPos, "Really Red")
			else
				if Loops[vipIdCh2] and type(Loops[vipIdCh2]) == "table" then
					Loops[vipIdCh2]:Disconnect()
					Loops[vipIdCh2] = nil
				else
					stopLoop(vipIdCh2)
				end
			end
		end
	})

	local farmingCollectSection = farmingTab:Section({ Title = "🍌 Collecting" })

	local autoBananas = false
	farmingCollectSection:Toggle({
		Title = "Auto Collect Bananas",
		Value = false,
		Callback = function(state)
			autoBananas = state
			if state then
				runLoop("AutoCollectBananas", function() return autoBananas end, function()
					for _, v in workspaceService:GetDescendants() do
						if v.Name:lower():find("banana") and v:IsA("BasePart") and LocalPlayer.Character then
							local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if hrp then
								pcall(function()
									firetouchinterest(hrp, v, 0)
									task.wait(0.05)
									firetouchinterest(hrp, v, 1)
								end)
							end
						end
					end
					for _, p in workspaceService:GetDescendants() do
						if p:IsA("ProximityPrompt") and p.ObjectText:lower():find("banana") then
							pcall(function() fireproximityprompt(p) end)
						end
					end
				end, 0.5)
			else
				stopLoop("AutoCollectBananas")
			end
		end
	})

	local autoShards = false
	farmingCollectSection:Toggle({
		Title = "Auto Collect Sunken Shards",
		Value = false,
		Callback = function(state)
			autoShards = state
			if state then
				runLoop("AutoCollectShards", function() return autoShards end, function()
					for i = 1, 9 do
						if Remotes:FindFirstChild("CollectShard") then
							safeFire(Remotes.CollectShard, "Shard" .. i)
						end
					end
				end, 0.8)
			else
				stopLoop("AutoCollectShards")
			end
		end
	})

	local farmingRewardsSection = farmingTab:Section({ Title = "🎁 Rewards" })

	local autoClaimFree = false
	farmingRewardsSection:Toggle({
		Title = "Auto Claim Free Reward",
		Value = false,
		Callback = function(state)
			autoClaimFree = state
			if state then
				runLoop("AutoClaimFreeReward", function() return autoClaimFree end, function()
					if Remotes:FindFirstChild("ClaimFreeReward") then safeFire(Remotes.ClaimFreeReward) end
				end, 5)
			else
				stopLoop("AutoClaimFreeReward")
			end
		end
	})

	local autoClaimStreak = false
	farmingRewardsSection:Toggle({
		Title = "Auto Claim Streak Reward",
		Value = false,
		Callback = function(state)
			autoClaimStreak = state
			if state then
				runLoop("AutoClaimStreakReward", function() return autoClaimStreak end, function()
					if Remotes:FindFirstChild("ClaimStreakReward") then safeFire(Remotes.ClaimStreakReward) end
				end, 5)
			else
				stopLoop("AutoClaimStreakReward")
			end
		end
	})

	local autoClaimOffline = false
	farmingRewardsSection:Toggle({
		Title = "Auto Claim Offline Earnings",
		Value = false,
		Callback = function(state)
			autoClaimOffline = state
			if state then
				runLoop("AutoClaimOfflineEarnings", function() return autoClaimOffline end, function()
					if Remotes:FindFirstChild("ClaimOfflineEarnings") then safeFire(Remotes.ClaimOfflineEarnings) end
				end, 5)
			else
				stopLoop("AutoClaimOfflineEarnings")
			end
		end
	})

	local autoSpinWheel = false
	farmingRewardsSection:Toggle({
		Title = "Auto Spin Wheel",
		Value = false,
		Callback = function(state)
			autoSpinWheel = state
			if state then
				runLoop("AutoSpinWheel", function() return autoSpinWheel end, function()
					if Remotes:FindFirstChild("SpawnWheel") then safeFire(Remotes.SpawnWheel) end
					if Remotes:FindFirstChild("PlayLootBoxSpin") then safeFire(Remotes.PlayLootBoxSpin) end
				end, 3)
			else
				stopLoop("AutoSpinWheel")
			end
		end
	})

	local invTailsSection = inventoryTab:Section({ Title = "🐵 Tails" })

	local autoBuyTails = false
	invTailsSection:Toggle({
		Title = "Auto Buy Best Tail",
		Value = false,
		Callback = function(state)
			autoBuyTails = state
			if state then
				runLoop("AutoBuyTails", function() return autoBuyTails end, function()
					local best = getBestAffordableLocked()
					if best and best ~= Data.SelectedUpgrade.Value then
						safeFire(Remotes.SelectUpgrade, best)
					end
				end, 1)
			else
				stopLoop("AutoBuyTails")
			end
		end
	})

	local autoEquipTails = false
	invTailsSection:Toggle({
		Title = "Auto Equip Best Owned Tail",
		Value = false,
		Callback = function(state)
			autoEquipTails = state
			if state then
				runLoop("AutoEquipBestTails", function() return autoEquipTails end, function()
					local best = getBestOwned()
					if best ~= Data.SelectedUpgrade.Value then
						safeFire(Remotes.SelectUpgrade, best)
					end
				end, 1)
			else
				stopLoop("AutoEquipBestTails")
			end
		end
	})

	local invTrailsSection = inventoryTab:Section({ Title = "✨ Trails" })
	local Trails = {"Red","Blue","Green","Rainbow","Galaxy","Divine","Fairy","Spectral","Yin Yang","Bloodmoon","Sakura","Flash","Void","Steampunk"}

	local autoBuyTrail = false
	invTrailsSection:Toggle({
		Title = "Auto Buy Next Trail",
		Value = false,
		Callback = function(state)
			autoBuyTrail = state
			if state then
				runLoop("AutoBuyTrail", function() return autoBuyTrail end, function()
					for _, name in ipairs(Trails) do
						if not Data.UnlockedTrails:FindFirstChild(name) then
							if Remotes:FindFirstChild("BuyTrail") then safeFire(Remotes.BuyTrail, name) end
							break
						end
					end
				end, 1)
			else
				stopLoop("AutoBuyTrail")
			end
		end
	})

	local autoEquipTrail = false
	invTrailsSection:Toggle({
		Title = "Auto Equip Best Trail",
		Value = false,
		Callback = function(state)
			autoEquipTrail = state
			if state then
				runLoop("AutoEquipBestTrail", function() return autoEquipTrail end, function()
					local best = nil
					for i = #Trails, 1, -1 do
						if Data.UnlockedTrails:FindFirstChild(Trails[i]) then best = Trails[i] break end
					end
					if best and Remotes:FindFirstChild("EquipTrail") then safeFire(Remotes.EquipTrail, best) end
				end, 1)
			else
				stopLoop("AutoEquipBestTrail")
			end
		end
	})

	local invAurasSection = inventoryTab:Section({ Title = "🌟 Auras" })
	local Auras = {"Amber","Ice Cold","Nature","Rainbow","Lunar","Sparkle","Fairy","Spectral","Yin Yang","Bloodmoon","Sakura","Electric","Void","Steampunk"}

	local autoBuyAura = false
	invAurasSection:Toggle({
		Title = "Auto Buy Next Aura",
		Value = false,
		Callback = function(state)
			autoBuyAura = state
			if state then
				runLoop("AutoBuyAura", function() return autoBuyAura end, function()
					for _, name in ipairs(Auras) do
						if not Data.UnlockedAuras:FindFirstChild(name) then
							if Remotes:FindFirstChild("BuyAura") then safeFire(Remotes.BuyAura, name) end
							break
						end
					end
				end, 1)
			else
				stopLoop("AutoBuyAura")
			end
		end
	})

	local autoEquipAura = false
	invAurasSection:Toggle({
		Title = "Auto Equip Best Aura",
		Value = false,
		Callback = function(state)
			autoEquipAura = state
			if state then
				runLoop("AutoEquipAura", function() return autoEquipAura end, function()
					local best = nil
					for i = #Auras, 1, -1 do
						if Data.UnlockedAuras:FindFirstChild(Auras[i]) then best = Auras[i] break end
					end
					if best and Remotes:FindFirstChild("EquipAura") then safeFire(Remotes.EquipAura, best) end
				end, 1)
			else
				stopLoop("AutoEquipAura")
			end
		end
	})

	local invCharmsSection = inventoryTab:Section({ Title = "🔮 Charms" })

	local autoBuyAllCharms = false
	invCharmsSection:Toggle({
		Title = "Auto Buy All Charms",
		Value = false,
		Callback = function(state)
			autoBuyAllCharms = state
			if state then
				runLoop("AutoBuyAllCharms", function() return autoBuyAllCharms end, function()
					local worldShop = Data:FindFirstChild("CharmShop")
					if not worldShop then return end
					local worldFolder = worldShop:FindFirstChild("World" .. tostring(Data.World.Value))
					if not worldFolder then return end

					for i = 1, 3 do
						local slot = worldFolder:FindFirstChild("Slot" .. i)
						local bought = worldFolder:FindFirstChild("Bought" .. i)
						if slot and slot:IsA("StringValue") and bought and not bought.Value then
							if Remotes:FindFirstChild("BuyCharm") then
								safeFire(Remotes.BuyCharm, i)
								task.wait(0.4)
							end
						end
					end
				end, 1)
			else
				stopLoop("AutoBuyAllCharms")
			end
		end
	})

	local autoEquipCharms = false
	invCharmsSection:Toggle({
		Title = "Auto Equip Best Charms",
		Value = false,
		Callback = function(state)
			autoEquipCharms = state
			if state then
				runLoop("AutoEquipBestCharms", function() return autoEquipCharms end, function()
					if Remotes:FindFirstChild("EquipBestCharms") then safeFire(Remotes.EquipBestCharms, "Wins") end
				end, 1)
			else
				stopLoop("AutoEquipBestCharms")
			end
		end
	})

	local autoFuseCharms = false
	invCharmsSection:Toggle({
		Title = "Auto Fuse Charms",
		Value = false,
		Callback = function(state)
			autoFuseCharms = state
			if state then
				runLoop("AutoFuseCharms", function() return autoFuseCharms end, function()
					local charmsFolder = Data:FindFirstChild("Charms")
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
							if Remotes:FindFirstChild("FuseCharms") then safeFire(Remotes.FuseCharms, toFuse) end
							return
						end
					end
				end, 1)
			else
				stopLoop("AutoFuseCharms")
			end
		end
	})

	local invPotionsSection = inventoryTab:Section({ Title = "🧪 Potions" })
	local Potions = {"Speed 10m","Speed 30m","Speed 1h","Wins 10m","Wins 30m","Wins 1h"}

	for _, potion in ipairs(Potions) do
		local id = "AutoUsePotion_" .. potion:gsub(" ", ""):gsub("10m", "10"):gsub("30m", "30"):gsub("1h", "60")
		local active = false
		invPotionsSection:Toggle({
			Title = "Auto Use: " .. potion,
			Value = false,
			Callback = function(state)
				active = state
				if state then
					runLoop(id, function() return active end, function()
						if Remotes:FindFirstChild("UsePotion") then safeFire(Remotes.UsePotion, potion) end
					end, 2)
				else
					stopLoop(id)
				end
			end
		})
	end

	local rebirthAutoSection = rebirthTab:Section({ Title = "🔄 Auto Rebirth" })

	local autoRebirth = false
	rebirthAutoSection:Toggle({
		Title = "Auto Rebirth",
		Value = false,
		Callback = function(state)
			autoRebirth = state
			if state then
				runLoop("AutoRebirth", function() return autoRebirth end, function()
					if Remotes:FindFirstChild("Rebirth") then safeFire(Remotes.Rebirth) end
				end, 1)
			else
				stopLoop("AutoRebirth")
			end
		end
	})

	rebirthAutoSection:Button({
		Title = "🔄 Rebirth Now",
		Callback = function()
			if Remotes:FindFirstChild("Rebirth") then safeFire(Remotes.Rebirth) end
		end
	})

	local rebirthInfoSection = rebirthTab:Section({ Title = "📊 Status" })
	rebirthInfoSection:Paragraph({ Title = "Rebirths", Desc = tostring(Data.Rebirths.Value) })
	rebirthInfoSection:Paragraph({ Title = "Level", Desc = tostring(Data.Level.Value) })

	local settingsSystemSection = settingsTab:Section({ Title = "⚙️ System" })

	settingsSystemSection:Toggle({
		Title = "Anti-AFK",
		Value = true,
		Callback = function(state) setAntiAFK(state) end
	})
	setAntiAFK(true)

	settingsSystemSection:Button({
		Title = "🗑️ Unload GUI",
		Callback = function()
			for id, loop in pairs(Loops) do
				if type(loop) == "table" and loop.Disconnect then
					loop:Disconnect()
				elseif type(loop) == "thread" then
					task.cancel(loop)
				end
			end
			if AntiAFKConn then AntiAFKConn:Disconnect() end
			window:Destroy()
		end
	})

	WindUI:Notify({
		Title = "⚡ POTENT HUB",
		Content = "✅ GUI loaded for " .. GameName,
		Duration = 4
	})
end

-- ============================================================
-- ========== JUEGO 2: BLOCK SPIN ==========
-- ============================================================

local function runBlockSpin()
	local Remotes = replicatedStorage:WaitForChild("Remotes")
	local Modules = replicatedStorage:WaitForChild("Modules")
	local Items = replicatedStorage:WaitForChild("Items")
	local MeleeFolder = Items:WaitForChild("melee")
	local Util = require(Modules.Core.Util)
	local BuyPromptUI = require(Modules.Game.UI.BuyPromptUI)
	local EmotesUI = require(Modules.Game.Emotes.EmotesUI)
	local EmotesList = require(Modules.Game.Emotes.EmotesList)
	local CoreUI = require(Modules.Core.UI)
	local Char = require(Modules.Core.Char)

	local LocalPlayer = playersService.LocalPlayer
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local Camera = workspaceService.CurrentCamera
	local Mouse = LocalPlayer:GetMouse()

	local CurrentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = CurrentCharacter:WaitForChild("Humanoid")
	local HRP = CurrentCharacter:WaitForChild("HumanoidRootPart")

	local DroppedItems = workspaceService:WaitForChild("DroppedItems")
	local SendRemote = Remotes:WaitForChild("Send", 5)

	local SilentAimEnabled = false
	local RedLineLockEnabled = false
	local FOVRadius = 120
	local CurrentTarget = nil
	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Thickness = 1
	FOVCircle.Color = Color3.fromRGB(255, 50, 50)
	FOVCircle.Transparency = 1
	FOVCircle.Visible = false

	local ESPTable = {}
	local NameESP = false
	local HealthESP = false
	local DistanceESP = false
	local SafeFriends = {}

	local WalkSpeedEnabled = false
	local SpeedMultiplier = 0.05
	local JumpPowerEnabled = false
	local JumpPowerValue = 40
	local AntiLockEnabled = false
	local AntiKillEnabled = false
	local SnapUnderMapEnabled = false
	local SnapHeight = 10
	local SnapOriginalY = nil
	local SnapActive = false
	local SnapConnection = nil

	local AutoAttackEnabled = false
	local AutoAttackDelay = 0.4

	local FastFinishEnabled = false
	local FastFinishHold = 1
	local FastFinishRange = 30
	local FastFinishDelay = 0.1

	local PickupItemsEnabled = false
	local PickupCooldowns = {}

	local SkipCrateEnabled = false
	local AntiAFKEnabled = false

	local GunMods = {
		FireRate = 1000,
		Accuracy = 1,
		Recoil = 0,
		Reload = 0.1,
		AutoApply = false,
		Auto = false
	}

	local MeleeAuraEnabled = false
	local MeleeOriginalAttrs = {}

	local InfiniteStaminaEnabled = false
	local InfiniteStaminaLoop = nil
	local OriginalSprintUpdate = nil

	local HighlightEnabled = false
	local Highlights = {}

	local WindUI
	pcall(function()
		WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
	end)
	if not WindUI then
		warn("❌ Failed to load WindUI")
		return
	end

	local Window = WindUI:CreateWindow({
		Title = "⚡ POTENT HUB",
		Author = "👑 MADE BY POTENT HUB",
		Folder = "POTENTHUB_BLOCKSPIN",
		Size = UDim2.fromOffset(650, 480),
		Theme = "Dark",
		Transparent = true,
		Resizable = true,
		KeyCode = Enum.KeyCode.G
	})

	Window:Tag({
		Title = "v1.0",
		Color = Color3.fromHex("#30ff6a"),
		Radius = 12
	})

	local ConfigManager = Window.ConfigManager
	local Config = ConfigManager:CreateConfig("PotentHubBlockSpin")

	local function getPing()
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if not pg then return 0.2 end
		local ns = pg:FindFirstChild("NetworkStats")
		if not ns then return 0.2 end
		local pl = ns:FindFirstChild("PingLabel")
		if not pl then return 0.2 end
		local txt = pl.Text
		if typeof(txt) ~= "string" then return 0.2 end
		local n = tonumber(txt:match("%d+"))
		if not n then return 0.2 end
		local ping = n / 1000
		if ping < 0 or ping > 2 then ping = 0.2 end
		return ping
	end

	local function isPlayerExcluded(name)
		for _, f in ipairs(SafeFriends) do
			if f ~= "" and string.find(string.lower(name), string.lower(f)) then
				return true
			end
		end
		return false
	end

	local function getClosestTarget()
		local closest = nil
		local closestDist = FOVRadius
		local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		for _, plr in ipairs(playersService:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local head = plr.Character:FindFirstChild("Head")
				local hum = plr.Character:FindFirstChild("Humanoid")
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if head and hum and hum.Health > 0 and root then
					local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local sp = Vector2.new(screenPos.X, screenPos.Y)
						local dist = (sp - center).Magnitude
						if dist <= FOVRadius and not isPlayerExcluded(plr.Name) then
							if dist < closestDist then
								closestDist = dist
								closest = plr
							end
						end
					end
				end
			end
		end
		return closest
	end

	local function predictPosition(part, root)
		if not part then return Vector3.zero end
		local ping = (getPing and getPing()) or (statsService.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000)
		if ping > 1 then ping = 0.2 end
		local vel = (root and root.AssemblyLinearVelocity) or Vector3.zero
		return part.Position + (vel * ping * 1.21)
	end

	local function isBehindWall(fromPos, toPos)
		if not fromPos or not toPos then return false end
		local dir = toPos - fromPos
		if dir.Magnitude < 1 then return false end
		local ignoreList = {}
		local char = LocalPlayer.Character
		if char then table.insert(ignoreList, char) end
		local tChar = CurrentTarget and CurrentTarget.Character
		if tChar then table.insert(ignoreList, tChar) end
		local result = workspaceService:Raycast(fromPos, dir, RaycastParams.new())
		if not result then return false end
		local inst = result.Instance
		return inst and not table.find(ignoreList, inst.Parent)
	end

	local function setupCharacter(char)
		CurrentCharacter = char
		Humanoid = char:WaitForChild("Humanoid")
		HRP = char:WaitForChild("HumanoidRootPart")
	end

	local function isDowned()
		local hum = Char.get_hum()
		if not hum then return false end
		if hum.Health <= 0 then return false end
		return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
	end

	local function getHRP()
		local char = Char.current_char.get()
		if not char then return nil end
		return char:FindFirstChild("HumanoidRootPart")
	end

	local function teleportUnderground()
		local hrp = getHRP()
		if not hrp then return end
		local cf = hrp.CFrame
		local newPos = cf + Vector3.new(0, -55, 0)
		hrp.CFrame = newPos
	end

	local NetGet
	do
		local counter
		pcall(function()
			for _, v in ipairs(getgc(true)) do
				if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then
					counter = v
					break
				end
			end
		end)
		NetGet = function(...)
			if not counter or not counter.func then return end
			local args = {...}
			for i, a in ipairs(args) do
				if typeof(a) == "Instance" then
					if a:IsA("Model") and #a:GetChildren() == 0 then
						local di = workspaceService:FindFirstChild("DroppedItems")
						if di then
							local m = di:FindFirstChildWhichIsA("Model")
							if m then args[i] = m else return end
						else return end
					end
				end
			end
			counter.func = (counter.func or 0) + 1
			local ok, res = pcall(function()
				local getRemote = replicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
				return getRemote:InvokeServer(counter.func, unpack(args))
			end)
			if not ok then warn("[NetGet Error]", res) end
			return res
		end
	end

	local function CheckAndPickup()
		if not PickupItemsEnabled then return end
		local di = workspaceService:FindFirstChild("DroppedItems")
		if not di then return end
		local now = tick()
		local toPickup = {}
		for _, item in ipairs(di:GetChildren()) do
			if item:IsA("Model") then
				local part = item:FindFirstChildWhichIsA("BasePart")
				if part then
					local dist = (HRP.Position - part.Position).Magnitude
					if dist <= 20 and (now - (PickupCooldowns[item] or 0)) >= 0 then
						table.insert(toPickup, item)
						PickupCooldowns[item] = now
					end
				end
			end
		end
		for _, item in ipairs(toPickup) do
			spawn(function()
				NetGet("pickup_dropped_item", item)
			end)
		end
	end

	local function SafeCall(fn, ...)
		local ok, err = pcall(fn, ...)
		return ok, err
	end

	local function CallRemote(remote, ...)
		if not remote then return end
		local args = {...}
		if remote.ClassName == "RemoteEvent" then
			SafeCall(function(...) remote:FireServer(...) end, unpack(args))
		elseif remote.ClassName == "RemoteFunction" then
			SafeCall(function(...) remote:InvokeServer(...) end, unpack(args))
		else
			SafeCall(function(...)
				if remote.FireServer then remote:FireServer(...)
				elseif remote.InvokeServer then remote:InvokeServer(...) end
			end, unpack(args))
		end
	end

	local function getPlayersInRange(range)
		local list = {}
		local char = LocalPlayer.Character
		if not char or not char.PrimaryPart then return list end
		local myPos = char.PrimaryPart.Position
		for _, plr in pairs(playersService:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character and plr.Character.PrimaryPart then
				local ok, dist = pcall(function()
					return (plr.Character.PrimaryPart.Position - myPos).Magnitude
				end)
				if ok and dist and dist <= range then
					table.insert(list, plr)
				end
			end
		end
		return list
	end

	local function getActiveTool()
		local char = LocalPlayer and LocalPlayer.Character
		if char then
			for _, t in ipairs(char:GetChildren()) do
				if pcall(function() return t:IsA("Tool") end) and t:IsA("Tool") then
					return t
				end
			end
		end
		local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if pcall(function() return t:IsA("Tool") end) and t:IsA("Tool") then
					return t
				end
			end
		end
		return nil
	end

	local function isMeleeTool(tool)
		if not tool then return false end
		if tool.Name == "Fists" then return true end
		local rs = game:GetService("ReplicatedStorage")
		local melee = rs:WaitForChild("Items"):WaitForChild("melee")
		local throwable = rs:WaitForChild("Items"):WaitForChild("throwable")
		if melee:FindFirstChild(tool.Name) and not throwable:FindFirstChild(tool.Name) then
			return true
		end
		return false
	end

	local function AttackNearby()
		if not SendRemote then return end
		local char = LocalPlayer.Character
		if not char or not char.PrimaryPart then return end
		local tool = getActiveTool()
		if not tool or not isMeleeTool(tool) then return end
		local ok, parent = pcall(function() return tool.Parent end)
		if not ok or parent ~= char then return end
		local players = getPlayersInRange(20)
		if #players == 0 then return end
		local ok2, myPos = pcall(function() return char.PrimaryPart.Position end)
		if not ok2 or not myPos then return end
		local targets = {}
		local positions = {}
		for _, plr in pairs(players) do
			if plr and plr.Character and plr.Character.PrimaryPart then
				local head = plr.Character:FindFirstChild("Head")
				local root = plr.Character.PrimaryPart
				if head and root then
					local predicted = predictPosition(head, root)
					table.insert(targets, plr)
					table.insert(positions, predicted)
				end
			end
		end
		if #targets == 0 then return end
		local firstTarget = positions[1]
		local lookCF = CFrame.lookAt(myPos, firstTarget)
		local args = {"melee_attack", tool, targets, lookCF, 0.75}
		pcall(function()
			CallRemote(SendRemote, unpack(args))
		end)
	end

	local function StartAutoAttack()
		task.spawn(function()
			while AutoAttackEnabled do
				task.wait(AutoAttackDelay)
				if AutoAttackEnabled and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
					pcall(AttackNearby)
				end
			end
		end)
	end

	local function performTeleport()
		if not HRP then return end
		local fromPos = HRP.Position
		local toPos = Vector3.new(fromPos.X, fromPos.Y - SnapHeight, fromPos.Z)
		HRP.CFrame = CFrame.new(toPos)
		SnapOriginalY = toPos.Y
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://95298029662868"
		s.Volume = 1
		s.PlayOnRemove = true
		s.Parent = HRP
		s:Destroy()
	end

	local function lockYPosition()
		if SnapConnection then
			pcall(function() SnapConnection:Disconnect() end)
		end
		SnapConnection = runService.Heartbeat:Connect(function()
			if SnapActive and SnapOriginalY and HRP then
				local pos = HRP.Position
				if math.abs(pos.Y - SnapOriginalY) > 0.1 then
					HRP.CFrame = CFrame.new(pos.X, SnapOriginalY, pos.Z)
				end
			end
		end)
	end

	local function registerItems(folder)
		for _, tool in ipairs(folder:GetChildren()) do
			if tool:IsA("Tool") then
				local handle = tool:FindFirstChild("Handle")
				local key
				local displayName = tool:GetAttribute("DisplayName") or tool.Name
				local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
				local rarity = tool:GetAttribute("RarityName") or "Common"
				local imageId = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
				if handle then
					local mesh = handle:FindFirstChildOfClass("SpecialMesh")
					if mesh and mesh.MeshId ~= "" then
						key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
					elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
						key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
					end
				end
				if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
					key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
				end
				if not key then
					key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
				end
				_G.PotentItemDB = _G.PotentItemDB or {}
				_G.PotentItemDB[key] = {
					Name = displayName,
					Rarity = rarity,
					ImageId = imageId,
					ToolName = tool.Name
				}
			end
		end
	end

	local function getItemKey(tool)
		local handle = tool:FindFirstChild("Handle")
		local displayName = tool:GetAttribute("DisplayName") or tool.Name
		local itemId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
		local rarity = tool:GetAttribute("RarityName") or "Common"
		if handle then
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if mesh and mesh.MeshId ~= "" then
				return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
			elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
				return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
			end
		end
		if itemId and itemId ~= "" and itemId ~= tool.Name then
			return "ITEMID_" .. itemId .. "_RARITY_" .. rarity
		end
		return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
	end

	local function getWeaponInfo(tool)
		if not tool or not tool:IsA("Tool") then return nil end
		local key = getItemKey(tool)
		return _G.PotentItemDB and _G.PotentItemDB[key]
	end

	local function setupFastFinishForPlayer(plr)
		if plr ~= LocalPlayer then
			plr.CharacterAdded:Connect(function(char)
				char.DescendantAdded:Connect(function(desc)
					if FastFinishEnabled and desc.Name == "FinishPrompt" and desc:IsA("ProximityPrompt") and desc.Parent and desc.Parent.Name == "HumanoidRootPart" then
						desc.HoldDuration = FastFinishHold
						desc.MaxActivationDistance = 20
					end
				end)
			end)
		end
	end

	local function findFinishPrompts()
		local prompts = {}
		for _, obj in pairs(workspaceService:GetChildren()) do
			local plr = playersService:GetPlayerFromCharacter(obj)
			if plr and not isPlayerExcluded(plr.Name) then
				local root = obj:FindFirstChild("HumanoidRootPart")
				if root then
					local prompt = root:FindFirstChild("FinishPrompt")
					if prompt then
						prompt.HoldDuration = FastFinishHold
						prompt.MaxActivationDistance = 20
						table.insert(prompts, prompt)
					end
				end
			end
		end
		return prompts
	end

	local function tryHoldPrompt(prompt, duration)
		if not prompt or prompt:GetAttribute("__AutoFinishBusy") then return end
		prompt:SetAttribute("__AutoFinishBusy", true)
		pcall(function() if prompt.InputHoldBegin then prompt:InputHoldBegin() end end)
		pcall(function() if prompt.HoldBegin then prompt:HoldBegin() end end)
		pcall(function() if prompt.Trigger then prompt:Trigger() end end)
		task.wait(duration)
		pcall(function() if prompt.InputHoldEnd then prompt:InputHoldEnd() end end)
		pcall(function() if prompt.HoldEnd then prompt:HoldEnd() end end)
		prompt:SetAttribute("__AutoFinishBusy", nil)
	end

	local function TrySkipCrate()
		local ok, Crate = pcall(function()
			return require(Modules.Game.CrateSystem.Crate)
		end)
		if not (ok and Crate) then return end
		task.spawn(function()
			local spinning = Crate.spinning
			if not spinning then return end
			local t = 0
			while not spinning.get() do
				if t > 3 then break end
				task.wait(0.05)
				t = t + 0.05
			end
			if spinning.get() then
				pcall(function() Crate.skip_spin() end)
			end
		end)
	end

	local function SetupAutoSkip()
		local remotes = replicatedStorage:WaitForChild("Remotes", 5)
		if not remotes then return end
		local send = remotes:WaitForChild("Send", 5)
		if not (send and send:IsA("RemoteEvent")) then return end
		send.OnClientEvent:Connect(function(...)
			if SkipCrateEnabled then
				TrySkipCrate()
			end
		end)
	end

	local ESPDrawings = {}

	local function createESP(plr)
		if ESPDrawings[plr] then return end
		local nameT = Drawing.new("Text")
		nameT.Size = 16
		nameT.Center = true
		nameT.Outline = true
		nameT.Color = Color3.fromRGB(255, 255, 255)
		nameT.Font = 4
		local distT = Drawing.new("Text")
		distT.Size = 14
		distT.Center = true
		distT.Outline = true
		distT.Color = Color3.fromRGB(255, 255, 255)
		distT.Font = 4
		local hpBg = Drawing.new("Square")
		hpBg.Filled = false
		hpBg.Thickness = 1
		hpBg.Color = Color3.fromRGB(0, 0, 0)
		hpBg.Transparency = 0.9
		hpBg.Visible = false
		local hpFill = Drawing.new("Square")
		hpFill.Filled = true
		hpFill.Transparency = 0.9
		hpFill.Visible = false
		local drawings = {nameT, distT, hpBg, hpFill}
		local conn = runService.RenderStepped:Connect(function()
			if not plr or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
				for _, d in pairs(drawings) do d.Visible = false end
				return
			end
			local root = plr.Character.HumanoidRootPart
			local hum = plr.Character:FindFirstChild("Humanoid")
			local dist = 0
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
			end
			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if not onScreen or pos.Z <= 0 then
				for _, d in pairs(drawings) do d.Visible = false end
				return
			end
			local x, y = pos.X, pos.Y - 15
			if HealthESP and hum and hum.Health > 0 then
				local pct = hum.Health / (hum.MaxHealth > 0 and hum.MaxHealth or 1)
				local w, h = 60, 4
				local bx = x - w/2
				hpBg.Position = Vector2.new(bx, y - h - 2)
				hpBg.Size = Vector2.new(w, h)
				hpBg.Visible = true
				hpFill.Position = Vector2.new(bx, y - h - 2)
				hpFill.Size = Vector2.new(w * pct, h)
				hpFill.Color = Color3.fromHSV(pct * 0.333, 0.8, 0.9)
				hpFill.Visible = true
				y = y - h - 6
			else
				hpBg.Visible = false
				hpFill.Visible = false
			end
			if NameESP then
				local minS, maxS = 14, 42
				local t = math.clamp(dist / 50, 0, 1)
				local size = maxS - (maxS - minS) * t
				nameT.Text = plr.Name
				nameT.Size = math.floor(size)
				nameT.Color = isPlayerExcluded(plr.Name) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
				nameT.Position = Vector2.new(x, y - 16)
				nameT.Visible = true
			else
				nameT.Visible = false
			end
			distT.Text = DistanceESP and string.format("%.0f studs", dist) or ""
			distT.Position = Vector2.new(x, pos.Y + 20)
			distT.Visible = DistanceESP
		end)
		ESPTable[plr] = {conn = conn, drawings = drawings}
	end

	local function loadESP()
		for _, plr in pairs(playersService:GetPlayers()) do
			if plr ~= LocalPlayer and not ESPTable[plr] then
				createESP(plr)
			end
		end
		playersService.PlayerAdded:Connect(function(plr)
			if plr ~= LocalPlayer then
				plr.CharacterAdded:Connect(function()
					task.wait(0.1)
					if not ESPTable[plr] then createESP(plr) end
				end)
				if plr.Character and not ESPTable[plr] then
					task.wait(0.1)
					createESP(plr)
				end
			end
		end)
		playersService.PlayerRemoving:Connect(function(plr)
			if ESPTable[plr] then
				for _, d in pairs(ESPTable[plr].drawings) do
					if d and d.Destroy then pcall(function() d:Destroy() end) end
				end
				if ESPTable[plr].conn then pcall(function() ESPTable[plr].conn:Disconnect() end) end
			end
		end)
	end

	local function updateHighlight(plr)
		if plr == LocalPlayer then return end
		if not plr.Character then return end
		local root = plr.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if Highlights[plr] then
			Highlights[plr]:Destroy()
			Highlights[plr] = nil
		end
		if HighlightEnabled then
			local hl = Instance.new("Highlight")
			hl.Name = "PotentHighlight"
			hl.Adornee = plr.Character
			hl.FillColor = Color3.fromRGB(0, 170, 255)
			hl.OutlineColor = Color3.fromRGB(0, 170, 255)
			hl.Parent = workspaceService
			Highlights[plr] = hl
		end
	end

	local isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled
	local FOVMobile
	if not isMobile then
		FOVCircle.Visible = false
	else
		local sg = Instance.new("ScreenGui")
		sg.Name = "PotentFOV"
		sg.Parent = PlayerGui
		FOVMobile = Instance.new("Frame")
		FOVMobile.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
		FOVMobile.AnchorPoint = Vector2.new(0.5, 0.5)
		FOVMobile.Position = UDim2.fromScale(0.5, 0.5)
		FOVMobile.BackgroundTransparency = 1
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = FOVMobile
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(255, 255, 255)
		s.Thickness = 2
		s.Transparency = 0.2
		s.Parent = FOVMobile
		FOVMobile.Parent = sg
	end

	if SendRemote and SendRemote.FireServer then
		pcall(function()
			local oldFire = hookfunction(SendRemote.FireServer, function(self, ...)
				if self ~= SendRemote then
					return oldFire(self, ...)
				end
				local args = {...}
				if SilentAimEnabled and args[2] == "shoot_gun" and CurrentTarget then
					local head = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head")
					local root = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
					local hum = CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Humanoid")
					if head and root and hum then
						local predicted = predictPosition(head, root)
						local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
						local myPos = myHead and myHead.Position or nil
						args[4] = CFrame.new(myPos, predicted)
						args[5] = {[1] = {[1] = {Instance = head, Normal = Vector3.new(0, 1, 0), Position = predicted}}}
					end
				end
				return oldFire(self, unpack(args))
			end)
		end)
	end

	runService.RenderStepped:Connect(function()
		pcall(function()
			CurrentTarget = (SilentAimEnabled or RedLineLockEnabled) and getClosestTarget() or nil
			if FOVCircle then
				FOVCircle.Visible = SilentAimEnabled
				if SilentAimEnabled then
					if isMobile then
						FOVMobile.Position = UDim2.fromScale(0.5, 0.5)
						FOVMobile.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
					else
						FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
						FOVCircle.Radius = FOVRadius
					end
				end
			end
			if JumpPowerEnabled and HRP then
				local v = HRP.Velocity
				HRP.Velocity = Vector3.new(v.X, JumpPowerValue, v.Z)
			end
			if SnapActive and SnapOriginalY and HRP then
				local pos = HRP.Position
				if math.abs(pos.Y - SnapOriginalY) > 0.1 then
					HRP.CFrame = CFrame.new(pos.X, SnapOriginalY, pos.Z)
				end
			end
		end)
	end)

	LocalPlayer.CharacterAdded:Connect(function(c)
		CurrentCharacter = c
	end)

	runService.Heartbeat:Connect(function()
		if AntiLockEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = LocalPlayer.Character.HumanoidRootPart
			local v = hrp.Velocity
			local a = math.rad(tick() * 1500 % 360)
			local x = math.cos(a) * 1500
			local z = math.sin(a) * 1500
			local y = math.random(280, 480)
			hrp.Velocity = Vector3.new(x, y, z)
			runService.RenderStepped:Wait()
			hrp.Velocity = v
		end
	end)

	runService.Heartbeat:Connect(function()
		if not AntiKillEnabled then return end
		if isDowned() then
			local hrp = getHRP()
			if hrp then
				hrp.CFrame = hrp.CFrame + Vector3.new(0, -55, 0)
			end
		end
	end)

	runService.Heartbeat:Connect(function()
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			CurrentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			HRP = CurrentCharacter:WaitForChild("HumanoidRootPart")
		end
		pcall(CheckAndPickup)
	end)

	contextActionService:BindAction("PotentFlyUp", function(_, state, input)
		if not JumpPowerEnabled then return Enum.ContextActionResult.Pass end
		local active = false
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then active = true end
		if input.UserInputType == Enum.UserInputType.Touch then active = true end
		if active then
			if state == Enum.UserInputState.Begin then
				if Humanoid then Humanoid.Jump = true end
				return Enum.ContextActionResult.Sink
			elseif state == Enum.UserInputState.End then
				return Enum.ContextActionResult.Sink
			end
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.Space)

	LocalPlayer.CharacterAdded:Connect(setupCharacter)
	if LocalPlayer.Character then
		setupCharacter(LocalPlayer.Character)
	end

	userInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Z and SnapUnderMapEnabled then
			SnapActive = not SnapActive
			if SnapActive then
				performTeleport()
			else
				SnapOriginalY = nil
			end
		end
	end)

	lockYPosition()

	for _, category in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
		local folder = Items:WaitForChild(category, 5)
		if folder then
			registerItems(folder)
		end
	end

	playersService.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			if HighlightEnabled then
				updateHighlight(plr)
			end
		end)
	end)

	playersService.PlayerRemoving:Connect(function(plr)
		if ESPTable[plr] then
			for _, d in pairs(ESPTable[plr].drawings) do
				if d and d.Destroy then pcall(function() d:Destroy() end) end
			end
			if ESPTable[plr].conn then pcall(function() ESPTable[plr].conn:Disconnect() end) end
			ESPTable[plr] = nil
		end
		if Highlights[plr] then
			Highlights[plr]:Destroy()
			Highlights[plr] = nil
		end
	end)

	for _, plr in ipairs(playersService:GetPlayers()) do
		setupFastFinishForPlayer(plr)
	end
	playersService.PlayerAdded:Connect(setupFastFinishForPlayer)

	task.spawn(function()
		while true do
			task.wait(FastFinishDelay)
			if FastFinishEnabled then
				for _, prompt in ipairs(findFinishPrompts()) do
					task.spawn(function()
						tryHoldPrompt(prompt, FastFinishHold)
					end)
				end
			end
		end
	end)

	SetupAutoSkip()
	replicatedStorage.ChildAdded:Connect(function(c)
		if c.Name == "Remotes" then
			SetupAutoSkip()
		end
	end)

	loadESP()

	-- UI TABS
	local CombatTab = Window:Tab({ Title = "🔫 Combat", Icon = "crosshair" })
	local GunSection = CombatTab:Section({ Title = "🔫 Gun" })

	local SilentAimToggle = GunSection:Toggle({
		Title = "Silent Aim",
		Default = false,
		Callback = function(state)
			SilentAimEnabled = state
			CurrentTarget = nil
		end
	})
	Config:Register("SilentAim", SilentAimToggle)

	local RedLineToggle = GunSection:Toggle({
		Title = "Red Line Lock",
		Default = false,
		Callback = function(state)
			RedLineLockEnabled = state
			CurrentTarget = nil
		end
	})
	Config:Register("RedLineLock", RedLineToggle)

	local FOVSlider = GunSection:Slider({
		Title = "FOV",
		Step = 1,
		Value = { Min = 20, Max = 800, Default = 120 },
		Callback = function(value)
			FOVRadius = tonumber(value) or 120
		end
	})
	Config:Register("FOV", FOVSlider)

	local SafeFriendInput = GunSection:Input({
		Title = "Safe Friend",
		Desc = "Names separated by spaces",
		Value = "",
		InputIcon = "shield-check",
		Type = "Input",
		Placeholder = "Player1 Player2",
		Callback = function(value)
			SafeFriends = {}
			for name in string.gmatch(value, "%S+") do
				table.insert(SafeFriends, name)
			end
		end
	})
	Config:Register("SafeFriends", SafeFriendInput)

	local WeaponTab = Window:Tab({ Title = "🔧 Weapon", Icon = "layers" })
	local ModsSection = WeaponTab:Section({ Title = "🔧 Mods" })

	local FireRateSlider = ModsSection:Slider({
		Title = "Fire Rate",
		Step = 10,
		Value = { Min = 100, Max = 3000, Default = 1000 },
		Callback = function(value) GunMods.FireRate = value end
	})
	Config:Register("FireRate", FireRateSlider)

	local AccuracySlider = ModsSection:Slider({
		Title = "Accuracy",
		Step = 0.01,
		Value = { Min = 0, Max = 1, Default = 1 },
		Callback = function(value) GunMods.Accuracy = value end
	})
	Config:Register("Accuracy", AccuracySlider)

	local RecoilSlider = ModsSection:Slider({
		Title = "Recoil",
		Step = 0.1,
		Value = { Min = 0, Max = 10, Default = 0 },
		Callback = function(value) GunMods.Recoil = value end
	})
	Config:Register("Recoil", RecoilSlider)

	local ReloadSlider = ModsSection:Slider({
		Title = "Reload Time",
		Step = 0.1,
		Value = { Min = 0.1, Max = 10, Default = 0.1 },
		Callback = function(value) GunMods.Reload = value end
	})
	Config:Register("Reload", ReloadSlider)

	local AutomaticToggle = ModsSection:Toggle({
		Title = "Automatic",
		Icon = "check",
		Type = "Checkbox",
		Value = false,
		Callback = function(state)
			GunMods.Auto = state
			GunMods.AutoApply = state
			if state then
				WindUI:Notify({ Title = "✅ Auto Modify Enabled", Duration = 2 })
			end
		end
	})
	Config:Register("Automatic", AutomaticToggle)

	local function isGunTool(tool)
		if not tool or not tool:IsA("Tool") then return false end
		local gunFolder = Items:WaitForChild("gun", 5)
		return (gunFolder and gunFolder:FindFirstChild(tool.Name) ~= nil) or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
	end

	local function applyGodGun(tool)
		if not tool or not isGunTool(tool) then return end
		pcall(function()
			tool:SetAttribute("fire_rate", GunMods.FireRate)
			tool:SetAttribute("accuracy", GunMods.Accuracy)
			tool:SetAttribute("Recoil", GunMods.Recoil)
			tool:SetAttribute("Durability", 999999999)
			tool:SetAttribute("automatic", GunMods.Auto)
		end)
	end

	runService.Heartbeat:Connect(function()
		if not GunMods.AutoApply then return end
		local char = LocalPlayer.Character
		if not char then return end
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") and isGunTool(tool) then
				pcall(applyGodGun, tool)
			end
		end
	end)

	local CombatSection = WeaponTab:Section({ Title = "⚔️ Combat" })

	local MeleeAuraToggle = CombatSection:Toggle({
		Title = "Melee Aura",
		Desc = "Wide Fists",
		Default = false,
		Callback = function(state)
			MeleeAuraEnabled = state
			local char = LocalPlayer.Character
			if not char then return end
			for _, tool in ipairs(char:GetChildren()) do
				if tool:IsA("Tool") and isMeleeTool(tool) then
					local attrs = tool:GetAttributes()
					local keys = {}
					for k in pairs(attrs) do table.insert(keys, k) end
					table.sort(keys)
					if #keys >= 7 then
						if state then
							tool:SetAttribute(keys[6], 360)
							tool:SetAttribute(keys[7], 20)
						end
					end
				end
			end
		end
	})
	Config:Register("MeleeAura", MeleeAuraToggle)

	local AutoAttackToggle = CombatSection:Toggle({
		Title = "Auto Attack",
		Default = false,
		Callback = function(state)
			AutoAttackEnabled = state
			if state then StartAutoAttack() end
		end
	})
	Config:Register("AutoAttack", AutoAttackToggle)

	local ESPTab = Window:Tab({ Title = "👁️ ESP", Icon = "eye" })
	local VisualSection = ESPTab:Section({ Title = "👁️ Visual" })

	local InventoryViewerToggle = VisualSection:Toggle({
		Title = "Inventory Viewer",
		Default = false,
		Callback = function(state)
			if state then
				WindUI:Notify({ Title = "✅ Inventory Viewer ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Inventory Viewer OFF", Duration = 3 })
			end
		end
	})
	Config:Register("InventoryViewer", InventoryViewerToggle)

	local NameToggle = VisualSection:Toggle({
		Title = "Name",
		Default = false,
		Callback = function(state) NameESP = state end
	})
	Config:Register("NameESP", NameToggle)

	local HealthToggle = VisualSection:Toggle({
		Title = "Health",
		Default = false,
		Callback = function(state) HealthESP = state end
	})
	Config:Register("HealthESP", HealthToggle)

	local DistanceToggle = VisualSection:Toggle({
		Title = "Distance",
		Default = false,
		Callback = function(state) DistanceESP = state end
	})
	Config:Register("DistanceESP", DistanceToggle)

	local HighlightToggle = VisualSection:Toggle({
		Title = "Highlight",
		Default = false,
		Callback = function(state)
			HighlightEnabled = state
			for _, plr in pairs(playersService:GetPlayers()) do
				updateHighlight(plr)
			end
		end
	})
	Config:Register("HighlightESP", HighlightToggle)

	local CharTab = Window:Tab({ Title = "👤 Character", Icon = "user" })
	local CharSection = CharTab:Section({ Title = "👤 Character" })

	local WalkSpeedToggle = CharSection:Toggle({
		Title = "Walk Speed",
		Default = false,
		Callback = function(state) WalkSpeedEnabled = state end
	})
	Config:Register("WalkSpeed", WalkSpeedToggle)

	local SpeedMultiSlider = CharSection:Slider({
		Title = "Speed Multiplier",
		Step = 0.5,
		Value = { Min = 1, Max = 5, Default = 2 },
		Callback = function(value) SpeedMultiplier = value * 0.05 end
	})
	Config:Register("SpeedMultiplier", SpeedMultiSlider)

	local JumpPowerToggle = CharSection:Toggle({
		Title = "Jump Power",
		Default = false,
		Callback = function(state) JumpPowerEnabled = state end
	})
	Config:Register("JumpPower", JumpPowerToggle)

	local InfStaminaToggle = CharSection:Toggle({
		Title = "Infinite Stamina",
		Default = false,
		Callback = function(state)
			InfiniteStaminaEnabled = state
			if state then
				WindUI:Notify({ Title = "✅ Infinite Stamina ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Infinite Stamina OFF", Duration = 3 })
			end
		end
	})
	Config:Register("InfiniteStamina", InfStaminaToggle)

	local AntiLockToggle = CharSection:Toggle({
		Title = "Anti Lock",
		Default = false,
		Callback = function(state) AntiLockEnabled = state end
	})
	Config:Register("AntiLock", AntiLockToggle)

	local AntiKillToggle = CharSection:Toggle({
		Title = "Anti Kill",
		Default = false,
		Callback = function(state)
			AntiKillEnabled = state
			if state then
				WindUI:Notify({ Title = "✅ Anti Kill ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Anti Kill OFF", Duration = 3 })
			end
		end
	})
	Config:Register("AntiKill", AntiKillToggle)

	local AttSection = CharTab:Section({ Title = "⚙️ Att" })

	local PickupToggle = AttSection:Toggle({
		Title = "Pickup Items",
		Default = false,
		Callback = function(state) PickupItemsEnabled = state end
	})
	Config:Register("PickupItems", PickupToggle)

	local AntiRagdollToggle = AttSection:Toggle({
		Title = "Anti Ragdoll",
		Default = false,
		Callback = function(state)
			if state then
				WindUI:Notify({ Title = "✅ Anti Ragdoll ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Anti Ragdoll OFF", Duration = 3 })
			end
		end
	})
	Config:Register("AntiRagdoll", AntiRagdollToggle)

	local HideNameToggle = AttSection:Toggle({
		Title = "Hide Name",
		Default = false,
		Callback = function(state)
			pcall(function()
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local root = char:WaitForChild("HumanoidRootPart")
				local bb = root:FindFirstChild("CharacterBillboardGui")
				if bb then
					local pn = bb:FindFirstChild("PlayerName")
					if pn and pn:IsA("TextLabel") then
						pn.Visible = not state
					end
				end
			end)
		end
	})
	Config:Register("HideName", HideNameToggle)

	local AutoRespawnToggle = AttSection:Toggle({
		Title = "Auto Respawn",
		Default = false,
		Callback = function(state)
			if state then
				WindUI:Notify({ Title = "✅ Auto Respawn ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Auto Respawn OFF", Duration = 3 })
			end
		end
	})
	Config:Register("AutoRespawn", AutoRespawnToggle)

	local SnapSection = CharTab:Section({ Title = "📌 PC Hold (Z)" })

	local SnapToggle = SnapSection:Toggle({
		Title = "Snap Under Map",
		Default = false,
		Callback = function(state)
			SnapUnderMapEnabled = state
			if state then
				SnapActive = true
				performTeleport()
			else
				SnapActive = false
				SnapOriginalY = nil
			end
		end
	})
	Config:Register("SnapUnderMap", SnapToggle)

	local SnapSlider = SnapSection:Slider({
		Title = "Snap Distance",
		Step = 1,
		Value = { Min = 1, Max = 50, Default = 10 },
		Callback = function(value) SnapHeight = value end
	})
	Config:Register("SnapHeight", SnapSlider)

	local PlayerTab = Window:Tab({ Title = "🧍 Player", Icon = "person-standing" })
	local PlayerSection = PlayerTab:Section({ Title = "🧍 Player" })

	local AutoFinishToggle = PlayerSection:Toggle({
		Title = "Auto Finnish",
		Default = false,
		Callback = function(state)
			FastFinishEnabled = state
			if state then
				WindUI:Notify({ Title = "✅ Auto Finish ON", Duration = 3 })
			else
				WindUI:Notify({ Title = "❌ Auto Finish OFF", Duration = 3 })
			end
		end
	})
	Config:Register("AutoFinish", AutoFinishToggle)

	local BuyTab = Window:Tab({ Title = "🏦 Buy", Icon = "landmark" })
	local BuySection = BuyTab:Section({ Title = "🏦 Buy" })

	local SkipCrateToggle = BuySection:Toggle({
		Title = "Skip Crate Spin",
		Desc = "Auto skip crate spin",
		Icon = "check",
		Type = "Checkbox",
		Default = false,
		Callback = function(state)
			SkipCrateEnabled = state
			if state then
				TrySkipCrate()
			end
		end
	})
	Config:Register("SkipCrate", SkipCrateToggle)

	local MiscTab = Window:Tab({ Title = "🏬 Misc", Icon = "warehouse" })

	MiscTab:Input({
		Title = "Server Hop by ID",
		Value = "",
		InputIcon = "send",
		Type = "Input",
		Placeholder = "Server ID here",
		Callback = function(value)
			if not value or value == "" then return end
			local ids = {}
			for id in string.gmatch(value, "[%w%-]+") do
				table.insert(ids, id)
			end
			if #ids == 0 then return end
			for _, id in ipairs(ids) do
				print("Joining server:", id)
				task.wait(0.5)
				pcall(function()
					teleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
				end)
			end
		end
	})

	MiscTab:Button({
		Title = "Server Rejoin",
		Desc = "Rejoin current server",
		Callback = function()
			teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
		end
	})

	MiscTab:Button({
		Title = "Server Hop",
		Desc = "Hop to a new server",
		Callback = function()
			local placeId = 104715542330896
			local ok, res = pcall(function()
				return httpService:JSONDecode(
					game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100")
				)
			end)
			if not ok or not res or not res.data then
				warn("Failed to get servers")
				return
			end
			local servers = {}
			for _, s in ipairs(res.data) do
				if s.playing < s.maxPlayers and s.id ~= game.JobId then
					table.insert(servers, s)
				end
			end
			if #servers == 0 then
				warn("No available servers")
				return
			end
			table.sort(servers, function(a, b) return a.playing > b.playing end)
			local target = servers[1]
			game.StarterGui:SetCore("SendNotification", {
				Title = "Server Hop",
				Text = "Joining new server...",
				Duration = 3
			})
			teleportService:TeleportToPlaceInstance(placeId, target.id, LocalPlayer)
		end
	})

	MiscTab:Divider()

	MiscTab:Button({
		Title = "Claim All Quest",
		Callback = function()
			task.spawn(function()
				local ok, err = pcall(function()
					local counter
					for _, v in ipairs(getgc and getgc(true) or {}) do
						if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then
							counter = v
							break
						end
					end
					if not counter then return end
					local function get(...)
						local args = {...}
						counter.func = (counter.func or 0) + 1
						local getRemote = Remotes:WaitForChild("Get")
						return getRemote:InvokeServer(counter.func, unpack(args))
					end
					local questsGui = PlayerGui:WaitForChild("Quests"):WaitForChild("QuestsHolder"):WaitForChild("QuestsScrollingFrame")
					for _, child in ipairs(questsGui:GetChildren()) do
						if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
							get("claim_quest", child.Name)
							task.wait(0.2)
						end
					end
				end)
				if ok then
					print("Claim All Quests Completed")
				else
					warn(err)
				end
			end)
		end
	})

	MiscTab:Section({ Title = "⚙️ Config Management" })

	MiscTab:Button({
		Title = "Save Config",
		Callback = function()
			if Config.Save then Config:Save() end
		end
	})

	MiscTab:Button({
		Title = "Delete Config",
		Callback = function()
			if Config.Delete then Config:Delete() end
		end
	})

	if Config.Load then
		Config:Load()
	end

	WindUI:Notify({
		Title = "⚡ POTENT HUB",
		Content = "✅ Block Spin script loaded!",
		Duration = 4
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
	if game.PlaceId == 114697347887839 then
		runSpeedMonkeyEscape()
	elseif game.PlaceId == 104715542330896 then
		runBlockSpin()
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
