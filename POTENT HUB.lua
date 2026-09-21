-- ============================================================
-- POTENT HUB - KEY SYSTEM + SPEED MONKEY ESCAPE SCRIPT
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

-- ========== PLACE IDS SOPORTADOS ==========
local SUPPORTED_PLACES = {
	[114697347887839] = true, -- Speed Monkey Escape
}

-- ========== CONFIGURACIÓN DE KEY ==========
local KEY_FILE = "potent_key.txt"
local KEY_DURATION = 24 * 60 * 60  -- 24 horas en segundos
local DISCORD_URL = "https://discord.gg/X7Y4NzuC67"
local VALID_KEY = "POTENTHUB372635263526"  -- 🔑 KEY FIJA

-- ============================================================
-- ========== DETECCIÓN DE PLACE ID ==========
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

	-- Fondo negro a pantalla completa.
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0, 0, 0)
	bg.BackgroundTransparency = 0
	bg.BorderSizePixel = 0
	bg.ZIndex = 1
	bg.Parent = screenGui

	-- Contenedor central.
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 520, 0, 260)
	main.Position = UDim2.new(0.5, -260, 0.5, -130)
	main.BackgroundTransparency = 1
	main.ZIndex = 2
	main.Parent = screenGui

	-- Texto principal.
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

	-- Botón estilo Discord (mismo estilo del Key System).
	local discordBtn = Instance.new("TextButton")
	discordBtn.Size = UDim2.new(0, 320, 0, 50)
	discordBtn.Position = UDim2.new(0.5, -160, 0, 170)
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

	-- Hover.
	discordBtn.MouseEnter:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(114, 137, 218)}):Play()
	end)
	discordBtn.MouseLeave:Connect(function()
		tweenService:Create(discordBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(88, 101, 242)}):Play()
	end)

	-- Texto de estado (feedback al copiar).
	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -40, 0, 20)
	status.Position = UDim2.new(0, 20, 0, 228)
	status.BackgroundTransparency = 1
	status.Text = ""
	status.TextColor3 = Color3.fromRGB(0, 200, 100)
	status.Font = Enum.Font.GothamBold
	status.TextSize = 12
	status.ZIndex = 3
	status.Parent = main

	-- Click: copiar link del Discord.
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

	-- Auto-cerrar después de 15 segundos.
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
	-- Verifica que la key guardada sea la correcta Y que no haya expirado
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
-- ========== SCRIPT PRINCIPAL ==========
-- ============================================================

local function runMainScript()
	-- References.
	local Remotes = replicatedStorage:WaitForChild("Remotes")
	local LocalPlayer = playersService.LocalPlayer
	local Data = LocalPlayer:WaitForChild("Data")

	local GameName = "+1 Speed Monkey Escape"
	pcall(function() GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)

	-- Cargar WindUI.
	local success, WindUI = pcall(function()
		return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
	end)
	if not success or not WindUI then
		warn("Failed to load WindUI: " .. tostring(WindUI))
		return
	end

	-- Create UI.
	local window = WindUI.CreateWindow(WindUI, {
		Title = "⚡ POTENT HUB",
		Author = "👑 MADE BY POTENT HUB",
		Folder = "POTENTHUB_SPEED_MONKEY",
		Size = UDim2.fromOffset(580, 520),
		Transparent = true,
		Theme = "Dark"
	})

	-- Configs.
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

	-- Posiciones.
	local TeleportPositions = {
		World1 = {Normal = Vector3.new(-9458.70, 389.70, -256.30), VIP = Vector3.new(-9457.38, 388.69, -187.92)},
		World2 = {Normal = Vector3.new(-3607.87, 155.87, -9375.29), VIP = Vector3.new(-3672.35, 154.64, -9382.89)},
		World3 = {Normal = Vector3.new(-8080.83, 283.18, 2741.99), VIP = Vector3.new(-8102.40, 281.96, 2741.95)},
		World4 = {Normal = Vector3.new(-7759.89, 21.91, 5741.03), VIP = Vector3.new(-7778.27, 19.57, 5740.98)},
		World5 = {Normal = Vector3.new(-7599.19, 287.17, 8359.99), VIP = Vector3.new(-7616.64, 286.82, 8360.72)},
	}

	-- Helpers.
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

	-- Tabs.
	local mainTab = window:Tab({ Title = "🏠 Main", Icon = "house" })
	local farmingTab = window:Tab({ Title = "🚜 Farming", Icon = "tractor" })
	local inventoryTab = window:Tab({ Title = "🎒 Inventory", Icon = "backpack" })
	local rebirthTab = window:Tab({ Title = "🔄 Rebirth", Icon = "refresh-cw" })
	local settingsTab = window:Tab({ Title = "⚙️ Settings", Icon = "settings" })

	-- MAIN TAB
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

	-- FARMING TAB
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

	-- INVENTORY TAB
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

	-- REBIRTH TAB
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

	-- SETTINGS TAB
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

	-- Notify.
	WindUI:Notify({
		Title = "⚡ POTENT HUB",
		Content = "✅ GUI loaded for " .. GameName,
		Duration = 4
	})
end

-- ============================================================
-- ========== EJECUCIÓN PRINCIPAL ==========
-- ============================================================

-- 1) Verificar si el PlaceId está soportado.
if not SUPPORTED_PLACES[game.PlaceId] then
	print("❌ This game is not supported yet. PlaceId: " .. tostring(game.PlaceId))
	showUnsupportedScreen()
	return
end

-- 2) Si está soportado, correr el sistema de key + script.
if isKeyValidLocally() then
	print("✅ Valid key found, loading...")
	runMainScript()
else
	print("🔑 Key required...")
	showKeySystem(function()
		runMainScript()
	end)
end
