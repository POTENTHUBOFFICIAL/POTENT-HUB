-- Check for table that is shared between executions.
if not shared then
	return warn("No shared, no script.")
end

local function runHub()

-- ============================================================
-- POTENT HUB - MULTI GAME HUB (WindUI v2.1 Edition)
-- 1. Speed Monkey Escape (114697347887839 / 72858062353423)
-- 2. Murder Mystery 2 (142823291)
-- 3. Kitten Farm (77813828595591)
-- 4. Speed Keyboard Escape (118941584817777 / 93411036959889)
-- 5. One Tap (90568084448279)
-- 6. BlockSpin (104715542330896)
-- ============================================================

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

local SUPPORTED_PLACES = {
	[114697347887839] = true,
	[72858062353423]  = true,
	[142823291]       = true,
	[77813828595591]  = true,
	[118941584817777] = true,
	[93411036959889]  = true,
	[90568084448279]  = true,
	[104715542330896] = true, -- BlockSpin
}

local ONETAP_PLACE_ID = 90568084448279
local BLOCKSPIN_PLACE_ID = 104715542330896

-- BlockSpin may launch through a secondary place in the same experience.
-- Recognize the configured PlaceId, matching GameId, or the actual place name.
local function isBlockSpinExperience()
    if game.PlaceId == BLOCKSPIN_PLACE_ID or game.GameId == BLOCKSPIN_PLACE_ID then
        return true
    end
    local ok, info = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if ok and info and type(info.Name) == "string" then
        local normalizedName = string.lower(info.Name):gsub("[%s%p]", "")
        if normalizedName:find("blockspin", 1, true) then
            return true
        end
    end
    return false
end

local function isSupportedCurrentGame()
    return SUPPORTED_PLACES[game.PlaceId] == true
        or SUPPORTED_PLACES[game.GameId] == true
        or isBlockSpinExperience()
end

local DISCORD_URL = "https://discord.gg/X7Y4NzuC67"

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

local animGradients = {}
local visualApplied = false

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
	supportLabel.Text = "🟢 Support:\nSpeed Monkey Escape, Murder Mystery 2, Kitten Farm, Speed Keyboard Escape, One Tap"
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
	discordBtn.Text = "💬 JOIN POTENT HUB DISCORD"
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
	-- ROUTES WORLD 2 (COMPLETAS)
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
	-- ROUTES WORLD 3 (COMPLETAS)
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
-- BlockSpin game handler: PlaceId 104715542330896 (with secondary-place/name fallback)
-- Uses the main hub key system; no separate loading screen or key prompt.
-- ============================================================
local function runChinoinfierno()
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIGURACIÓN
--========================================================--

local DISCORD_LINK = "https://discord.gg/tH4j9wbArW"
local CFG_FILE = "potent_hub_settings.txt"
local HasEnteredPanel = false

--========================================================--
-- LIMPIEZA PREVIA
--========================================================--

pcall(function()
            if CoreGui:FindFirstChild("PotentHubOverlay") then CoreGui.PotentHubOverlay:Destroy() end
    if CoreGui:FindFirstChild("FloatingSnapGui") then CoreGui.FloatingSnapGui:Destroy() end
    if CoreGui:FindFirstChild("AstralProjectionGui") then CoreGui.AstralProjectionGui:Destroy() end
    if PlayerGui:FindFirstChild("PotentHubOverlay") then PlayerGui.PotentHubOverlay:Destroy() end
    if workspace:FindFirstChild("AK_SurfaceCamPart") then workspace.AK_SurfaceCamPart:Destroy() end
end)

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PotentHubOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

--========================================================--
-- ELEMENTOS VISUALES MIGRADOS
--========================================================--

local SettingsVisual = {
    Box = false,
    Lines = false,
    FOV = false,
    TargetLine = false,

    FOVRadius = 150,
    FOVMin = 145,
    FOVMax = 155,
    FOVSpeed = 2,

    LineOriginY = 1,
    LineTargetOffset = 0,

    TargetLineThickness = 1,
    TargetMarkerSize = 7
}

local CurrentTarget = nil
local FOVTime = 0

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(SettingsVisual.FOVRadius * 2, SettingsVisual.FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 50
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.15
FOVStroke.Color = Color3.fromRGB(135, 150, 255)
FOVStroke.Parent = FOVCircle

local TargetLine = Instance.new("Frame")
TargetLine.Name = "TargetLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetLine.BackgroundTransparency = 0.05
TargetLine.BorderSizePixel = 0
TargetLine.Size = UDim2.fromOffset(0, SettingsVisual.TargetLineThickness)
TargetLine.Visible = false
TargetLine.ZIndex = 20
TargetLine.Parent = ScreenGui

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.Size = UDim2.fromOffset(SettingsVisual.TargetMarkerSize, SettingsVisual.TargetMarkerSize)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetMarker.BorderSizePixel = 0
TargetMarker.Visible = false
TargetMarker.ZIndex = 30
TargetMarker.Parent = ScreenGui

local MarkerCorner = Instance.new("UICorner")
MarkerCorner.CornerRadius = UDim.new(1, 0)
MarkerCorner.Parent = TargetMarker

local MarkerStroke = Instance.new("UIStroke")
MarkerStroke.Thickness = 1
MarkerStroke.Color = Color3.fromRGB(255, 255, 255)
MarkerStroke.Parent = TargetMarker

local VisualPlayerObjects = {}

local function CreateVisualPlayerObjects(player)
    if player == LocalPlayer then return end
    local data = {}

    local box = Instance.new("SelectionBox")
    box.Name = "ESPBox"
    box.LineThickness = 0.015
    box.Color3 = Color3.fromRGB(135, 150, 255)
    box.SurfaceTransparency = 1
    box.Visible = false
    box.Parent = ScreenGui
    data.Box = box

    local line = Instance.new("Frame")
    line.Name = "ESPLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(135, 150, 255)
    line.BackgroundTransparency = 0.1
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(0, 1)
    line.Visible = false
    line.ZIndex = 10
    line.Parent = ScreenGui
    data.Line = line

    VisualPlayerObjects[player] = data
end

local function RemoveVisualPlayerObjects(player)
    if CurrentTarget == player then
        CurrentTarget = nil
        TargetLine.Visible = false
        TargetMarker.Visible = false
    end

    local data = VisualPlayerObjects[player]
    if not data then return end

    for _, object in pairs(data) do
        if object then object:Destroy() end
    end
    VisualPlayerObjects[player] = nil
end

for _, pl in ipairs(Players:GetPlayers()) do
    CreateVisualPlayerObjects(pl)
end
Players.PlayerAdded:Connect(CreateVisualPlayerObjects)
Players.PlayerRemoving:Connect(RemoveVisualPlayerObjects)

local function HasLineOfSight(targetCharacter, targetHead)
    local myCharacter = LocalPlayer.Character
    if not myCharacter then return false end

    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return false end

    local origin = myHead.Position
    local direction = targetHead.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myCharacter, targetCharacter}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetBestVisualTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestPlayer = nil
    local bestDistance = SettingsVisual.FOVRadius

    for player in pairs(VisualPlayerObjects) do
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

            if head then
                local position, visible = Camera:WorldToViewportPoint(head.Position)
                if visible and position.Z > 0 then
                    local screenPosition = Vector2.new(position.X, position.Y)
                    local distance = (screenPosition - center).Magnitude

                    if distance <= SettingsVisual.FOVRadius and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function UpdateTargetLine()
    if not SettingsVisual.TargetLine or not CurrentTarget then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myCharacter = LocalPlayer.Character
    local targetCharacter = CurrentTarget.Character
    if not myCharacter or not targetCharacter then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myHead = myCharacter:FindFirstChild("Head")
    local targetHead = targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso")
    if not myHead or not targetHead then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myPosition, myVisible = Camera:WorldToViewportPoint(myHead.Position)
    local targetPosition, targetVisible = Camera:WorldToViewportPoint(targetHead.Position)

    if not myVisible or not targetVisible or myPosition.Z <= 0 or targetPosition.Z <= 0 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local from = Vector2.new(myPosition.X, myPosition.Y)
    local target = Vector2.new(targetPosition.X, targetPosition.Y)
    local difference = target - from
    local length = difference.Magnitude

    if length <= 0 then return end

    local visible = HasLineOfSight(targetCharacter, targetHead)
    if visible then
        TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    else
        TargetLine.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
    end

    TargetLine.Position = UDim2.fromOffset((from.X + target.X) / 2, (from.Y + target.Y) / 2)
    TargetLine.Size = UDim2.fromOffset(length, SettingsVisual.TargetLineThickness)
    TargetLine.Rotation = math.deg(math.atan2(difference.Y, difference.X))
    TargetLine.Visible = true

    TargetMarker.Position = UDim2.fromOffset(target.X, target.Y)
    TargetMarker.Visible = true
end

--========================================================--
-- VARIABLES DE ESTADOS Y CONTROL
--========================================================--

local ThemeColor = Color3.fromRGB(135, 150, 255)
local DynamicColorElements = {}
local MainHubFrameRef = nil

local SilentAimEnabled = false
local TargetHitPart = "Neck"
local CurrentLockedTarget = nil
local WallbangEnabled = false

local P = {}

local InfiniteJumpEnabled = false
local JumpPowerBypassValue = 50
local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
local AutoSprintLoop = nil

local SpeedHackEnabled = false
local SpeedValue = 4
local HeadHidingAntiAim = false

local SkipCratesEnabled = false
local PotatoBoostEnabled = false
local OriginalCameraFOV = Camera.FieldOfView

local AutoSafeDamageEnabled = false
local AutoSafeActive = false
local AutoSafeDepth = 25
local SavedAutoSafeY = nil
local TargetAutoSafeY = nil
local FrozenCameraCFrame = nil

local PlayerESP_Name = false
local PlayerESP_Health = false
local PlayerESP_Dist = false
local PlayerESP_Highlight = false
local WeaponESPEnabled = false
local ItemESPEnabled = false

local GunModsActive = false
local FireRateVal = 1000
local AccuracyVal = 1
local RecoilVal = 0
local ReloadVal = 0.1
local AutomaticVal = true
local DurabilityVal = 999999999

local MeleeAuraEnabled = false
local AutoAttackEnabled = false
local SavedMeleeAttributes = {}

-- TUNING DE VEHÍCULOS
local VehAcceleration = 20
local VehBraking = 40
local VehDeceleration = 10
local VehForwardMaxSpeed = 120
local VehReverseMaxSpeed = 45
local VehSuspension = 2

local VehAcceleration_Enabled = false
local VehBraking_Enabled = false
local VehDeceleration_Enabled = false
local VehForwardMaxSpeed_Enabled = false
local VehReverseMaxSpeed_Enabled = false
local VehSuspension_Enabled = false

local AutoPickupEnabled = false
local AutoPickupRadius = 85
local AutoInteractEnabled = false
local HideNameEnabled = false

local HighlightCache = {}
local PlayerBillboards = {}
local WeaponBillboardCache = {}
local WeaponCacheTokens = {}
local ItemDrawingsCache = {}
local RegisteredWeaponDB = {}
local VelocityHistory = {}

local FloatingSnapActive = false
local FloatingSnapDepth = 15
local FloatingSavedSurfaceY = nil
local FloatingTargetY = nil

local AstralActive = false
local AstralOrb = nil
local AstralConnection = nil
local AstralSpeed = 40
local FrozenCharCF = nil

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SendRemote = RemotesFolder and RemotesFolder:FindFirstChild("Send")
local GetRemote = RemotesFolder and RemotesFolder:FindFirstChild("Get")
local DroppedItems = workspace:WaitForChild("DroppedItems", 10)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items", 10)
local GunsFolder = ItemsFolder and ItemsFolder:FindFirstChild("gun")
local MeleeFolder = ItemsFolder and ItemsFolder:FindFirstChild("melee")
local ThrowableFolder = ItemsFolder and ItemsFolder:FindFirstChild("throwable")

local RemoteCounter
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            RemoteCounter = obj
            break
        end
    end
end)

local RawCallCount = 0
local function FireServerHook(...)
    if not SendRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.event) == "number" then
        RemoteCounter.event = RemoteCounter.event + 1
        pcall(function() SendRemote:FireServer(RemoteCounter.event, unpack(args)) end)
    else
        RawCallCount = RawCallCount + 1
        pcall(function() SendRemote:FireServer(RawCallCount, unpack(args)) end)
    end
end

local function InvokeServerHook(...)
    if not GetRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.func) == "number" then
        RemoteCounter.func = RemoteCounter.func + 1
        local ok, res = pcall(function() return GetRemote:InvokeServer(RemoteCounter.func, unpack(args)) end)
        return res
    else
        local ok, res = pcall(function() return GetRemote:InvokeServer(unpack(args)) end)
        return res
    end
end

--========================================================--
-- SISTEMA DE NIEVE
--========================================================--

local ActiveSnowContainers = {}

local function AttachSnowEffect(parentFrame)
    local container = Instance.new("Frame")
    container.Name = "SnowContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    
    table.insert(ActiveSnowContainers, container)

    task.spawn(function()
        while container.Parent do
            task.wait(math.random(12, 22) / 100)
            if container.Parent and #container:GetChildren() < 28 then
            task.spawn(function()
                if not container.Parent then return end
                local startX = math.random()
                local size = math.random(2, 5)
                local flake = Instance.new("Frame", container)
                flake.Size = UDim2.new(0, size, 0, size)
                flake.Position = UDim2.new(startX, 0, -0.1, 0)
                flake.BackgroundColor3 = (math.random(1, 3) == 1 and Color3.fromRGB(255, 255, 255)) or ThemeColor
                flake.BackgroundTransparency = math.random(20, 50) / 100
                flake.BorderSizePixel = 0
                flake.ZIndex = 2
                Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)

                local fallTime = math.random(18, 35) / 10
                local tw = TweenService:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(startX + (math.random(-4, 4) / 100), 0, 1.1, 0),
                    BackgroundTransparency = 1
                })
                tw:Play()
                tw.Completed:Connect(function()
                    flake:Destroy()
                end)
            end)
            end
        end
    end)
end

--========================================================--
-- BASE DE DATOS Y ENGINES
--========================================================--

local RarityColors = {
    Common = Color3.fromRGB(255, 255, 255),
    Uncommon = Color3.fromRGB(99, 255, 52),
    Rare = Color3.fromRGB(51, 170, 255),
    Epic = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega = Color3.fromRGB(255, 20, 51)
}

local function registerFolderItems(folder)
    if not folder then return end
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local dName = item:GetAttribute("DisplayName") or item.Name
            local iId = item:GetAttribute("ItemId") or item:GetAttribute("Id") or item.Name
            local rarity = item:GetAttribute("RarityName") or "Common"
            local img = item:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and iId ~= "" and iId ~= item.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
            if not key then key = "NAME_" .. dName .. "_" .. item.Name .. "_RARITY_" .. rarity end
            RegisteredWeaponDB[key] = {Name = dName, Rarity = rarity, ImageId = img, ToolName = item.Name}
        end
    end
end

if ItemsFolder then
    for _, sub in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
        registerFolderItems(ItemsFolder:FindFirstChild(sub))
    end
end

local function getWeaponData(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local handle = tool:FindFirstChild("Handle")
    local dName = tool:GetAttribute("DisplayName") or tool.Name
    local iId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"
    local key
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if not key and iId ~= "" and iId ~= tool.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
    if not key then key = "NAME_" .. dName .. "_" .. tool.Name .. "_RARITY_" .. rarity end
    return RegisteredWeaponDB[key]
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return 0.08 end
    local netStats = pGui:FindFirstChild("NetworkStats")
    if not netStats then return 0.08 end
    local pingLabel = netStats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.08 end
    local text = pingLabel.Text
    if typeof(text) ~= "string" then return 0.08 end
    local ms = tonumber(text:match("%d+"))
    if not ms then return 0.08 end
    local s = ms / 1000
    if s < 0 or s > 1.5 then s = 0.08 end
    return s
end

--========================================================--
-- MOTOR DE SELECCIÓN Y PREDICCIÓN
--========================================================--

local function getBypassedTargetPart(character)
    if not character then return nil, Vector3.zero end
    local head = character:FindFirstChild("Head")
    local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local root = character:FindFirstChild("HumanoidRootPart")

    if TargetHitPart == "Head" then
        return (head or upperTorso or root), Vector3.zero
    elseif TargetHitPart == "Neck" then
        if head then
            return head, Vector3.new(0, -0.65, 0)
        elseif upperTorso then
            return upperTorso, Vector3.new(0, 0.3, 0)
        end
        return (head or upperTorso or root), Vector3.new(0, -0.4, 0)
    elseif TargetHitPart == "Chest" then
        return (upperTorso or root or head), Vector3.zero
    end
    return (head or upperTorso or root), Vector3.zero
end

local lastVelocityHistoryUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastVelocityHistoryUpdate < 0.1 then return end
    lastVelocityHistoryUpdate = now
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            if root then
                VelocityHistory[pl] = VelocityHistory[pl] or {}
                table.insert(VelocityHistory[pl], {time = os.clock(), pos = root.Position})
                if #VelocityHistory[pl] > 6 then
                    table.remove(VelocityHistory[pl], 1)
                end
            else
                VelocityHistory[pl] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(pl)
    VelocityHistory[pl] = nil
end)

local function calculateTargetVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end

    local history = VelocityHistory[pl]
    if not history or #history < 2 then return Vector3.zero end

    local totalVel = Vector3.zero
    local count = 0
    for i = 2, #history do
        local dt = history[i].time - history[i - 1].time
        if dt > 0 then
            totalVel = totalVel + (history[i].pos - history[i - 1].pos) / dt
            count = count + 1
        end
    end
    if count == 0 then return Vector3.zero end

    local avg = totalVel / count
    if avg.Y > 150 then
        return Vector3.new(avg.X * 1.15, math.clamp(avg.Y * 0.85, 0, 400), avg.Z * 1.15)
    end
    return avg
end

local function predictPosition(targetPart, customOffset, rootPart)
    if not targetPart then return Vector3.zero end
    local offset = customOffset or Vector3.zero
    local basePos = targetPart.Position + offset
    local pl = Players:GetPlayerFromCharacter(targetPart.Parent)
    if not pl then return basePos end

    local targetChar = targetPart.Parent
    local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local isDowned = hum and (hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead") or hum.Health <= 0)

    if isDowned then return basePos end

    local vel = calculateTargetVelocity(pl, rootPart) or Vector3.zero
    local ping = getPing()

    return basePos + (vel * ping * 1.2)
end

local function isShotgun()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local ammo = item:GetAttribute("AmmoType")
            if ammo == "shotgun" or ammo == "shootgun" then return true end
        end
    end
    return false
end

--========================================================--
-- MODAL DE ADVERTENCIA
--========================================================--

local function ShowWarningModal(titleText, bodyText, confirmText, onConfirm)
    local alertOverlay = Instance.new("Frame", ScreenGui)
    alertOverlay.Size = UDim2.new(1, 0, 1, 0)
    alertOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    alertOverlay.BackgroundTransparency = 0.55
    alertOverlay.BorderSizePixel = 0
    alertOverlay.ZIndex = 9999

    local alertBox = Instance.new("Frame", alertOverlay)
    alertBox.Size = UDim2.new(0, 320, 0, 160)
    alertBox.Position = UDim2.new(0.5, -160, 0.5, -80)
    alertBox.BackgroundColor3 = Color3.fromRGB(18, 15, 27)
    alertBox.BackgroundTransparency = 0.1
    alertBox.BorderSizePixel = 0
    alertBox.ZIndex = 10000
    Instance.new("UICorner", alertBox).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", alertBox)
    stroke.Color = ThemeColor
    stroke.Thickness = 1.4
    table.insert(DynamicColorElements, {Type = "Stroke", Element = stroke})

    local title = Instance.new("TextLabel", alertBox)
    title.Size = UDim2.new(1, -24, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ " .. titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 10001

    local desc = Instance.new("TextLabel", alertBox)
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Text = bodyText
    desc.TextColor3 = Color3.fromRGB(185, 190, 210)
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 10001

    local actionBtn = Instance.new("TextButton", alertBox)
    actionBtn.Size = UDim2.new(0.68, 0, 0, 30)
    actionBtn.Position = UDim2.new(0, 12, 1, -40)
    actionBtn.BackgroundColor3 = ThemeColor
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.BorderSizePixel = 0
    actionBtn.Text = confirmText or "ENTENDIDO"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 10
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.ZIndex = 10001
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)
    table.insert(DynamicColorElements, {Type = "Background", Element = actionBtn})

    local closeBtn = Instance.new("TextButton", alertBox)
    closeBtn.Size = UDim2.new(0.26, 0, 0, 30)
    closeBtn.Position = UDim2.new(1, -12 - (alertBox.AbsoluteSize.X * 0.26), 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CERRAR"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.ZIndex = 10001
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    actionBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
        if onConfirm then onConfirm() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
    end)
end

-- Security: remote interception / anti-cheat evasion hook intentionally not integrated.

--========================================================--
-- GUN MODS & MELEE AURA
--========================================================--

local function isMeleeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    if MeleeFolder and ThrowableFolder then
        if MeleeFolder:FindFirstChild(tool.Name) and not ThrowableFolder:FindFirstChild(tool.Name) then
            return true
        end
    end
    return false
end

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (GunsFolder and GunsFolder:FindFirstChild(tool.Name) ~= nil) or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", FireRateVal)
        tool:SetAttribute("accuracy", AccuracyVal)
        tool:SetAttribute("Recoil", RecoilVal)
        tool:SetAttribute("recoil", RecoilVal)
        tool:SetAttribute("reload_time", ReloadVal)
        tool:SetAttribute("Durability", DurabilityVal)
        tool:SetAttribute("automatic", AutomaticVal)
        tool:SetAttribute("Spread", 0)
        tool:SetAttribute("spread", 0)
    end)
end

local function modifyFists(tool, state)
    if not tool then return end
    local attrs = tool:GetAttributes()
    local keys = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    if #keys >= 7 then
        local k6, k7 = keys[6], keys[7]
        if state then
            if SavedMeleeAttributes[k6] == nil then SavedMeleeAttributes[k6] = tool:GetAttribute(k6) end
            if SavedMeleeAttributes[k7] == nil then SavedMeleeAttributes[k7] = tool:GetAttribute(k7) end
            tool:SetAttribute(k6, 360)
            tool:SetAttribute(k7, 20)
        else
            if SavedMeleeAttributes[k6] then tool:SetAttribute(k6, SavedMeleeAttributes[k6]) end
            if SavedMeleeAttributes[k7] then tool:SetAttribute(k7, SavedMeleeAttributes[k7]) end
        end
    end
end

local function updateMeleeTools()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, t in ipairs(char:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
    for _, t in ipairs(backpack:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
end

local lastToolModsUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastToolModsUpdate < 0.15 then return end
    lastToolModsUpdate = now
    if GunModsActive and LocalPlayer.Character then
        for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
            if isGunTool(t) then applyGodGun(t) end
        end
    end
    if MeleeAuraEnabled then
        updateMeleeTools()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.35)
        if AutoAttackEnabled and LocalPlayer.Character and SendRemote then
            local char = LocalPlayer.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local tool = char:FindFirstChildOfClass("Tool")
            if root and tool and isMeleeTool(tool) then
                local targets = {}
                local positions = {}
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local eHead = pl.Character:FindFirstChild("Head") or pl.Character:FindFirstChild("UpperTorso") or pl.Character:FindFirstChild("Torso")
                        local eRoot = pl.Character.HumanoidRootPart
                        if eHead and eRoot then
                            local dist = (eRoot.Position - root.Position).Magnitude
                            if dist <= 20 then
                                table.insert(targets, pl)
                                table.insert(positions, eHead.Position)
                            end
                        end
                    end
                end
                if #targets > 0 then
                    local lookCF = CFrame.lookAt(root.Position, positions[1])
                    FireServerHook("melee_attack", tool, targets, lookCF, 0.75)
                end
            end
        end
    end
end)

--========================================================--
-- VEHICLE MODS (CON FÍSICA REAL HASTA 5000)
--========================================================--

local function applyVehicleMods(model)
    if not model or not model:IsA("Model") then return end
    pcall(function()
        local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("VehicleSeat") or desc:IsA("Seat") then
                if VehForwardMaxSpeed_Enabled then
                    desc.MaxSpeed = VehForwardMaxSpeed
                    if desc.ThrottleFloat > 0 and primary then
                        primary.AssemblyLinearVelocity = primary.CFrame.LookVector * VehForwardMaxSpeed
                    elseif desc.ThrottleFloat < 0 and primary then
                        primary.AssemblyLinearVelocity = -primary.CFrame.LookVector * VehReverseMaxSpeed
                    end
                end
                desc.SteerFloat = 1
                desc.TurnSpeed = 2.2
                pcall(function()
                    desc.Torque = 999999999
                end)
            end
            if desc:IsA("SpringConstraint") or desc:IsA("CylindricalConstraint") then
                if VehSuspension_Enabled then desc.FreeLength = VehSuspension end
                desc.Stiffness = 15000
            end
        end
        if VehAcceleration_Enabled then model:SetAttribute("Motors acceleration", VehAcceleration) end
        if VehBraking_Enabled then model:SetAttribute("Motors braking", VehBraking) end
        if VehDeceleration_Enabled then model:SetAttribute("Motors deceleration", VehDeceleration) end
        if VehForwardMaxSpeed_Enabled then model:SetAttribute("Motors forwardMaxSpeed", VehForwardMaxSpeed) end
        if VehReverseMaxSpeed_Enabled then model:SetAttribute("Motors reverseMaxSpeed", VehReverseMaxSpeed) end
    end)
end

local lastVehicleModsUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastVehicleModsUpdate < 0.15 then return end
    lastVehicleModsUpdate = now
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local veh = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
        if veh then applyVehicleMods(veh) end
    end
end)

--========================================================--
-- SKIP CRATES & PROXIMITY PROMPTS
--========================================================--

task.spawn(function()
    local success, CrateController = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Game"):WaitForChild("CrateSystem"):WaitForChild("Crate"))
    end)
    
    if success and CrateController then
        while true do
            task.wait()
            if SkipCratesEnabled then
                pcall(function()
                    if CrateController.class and CrateController.class.objects then
                        for _, crate in pairs(CrateController.class.objects) do
                            if crate.states and crate.states.open and crate.states.open.set then
                                crate.states.open.set(true)
                            end
                            if CrateController.skipping and CrateController.skipping.set then
                                CrateController.skipping.set(true)
                            end
                        end
                    end
                    if CrateController.spinning and CrateController.skip_spin then
                        if not CrateController.spinning.get() then
                            CrateController.skip_spin()
                        end
                    end
                end)
            end
        end
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if AutoInteractEnabled and prompt and prompt.Enabled then
        task.spawn(function()
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration or 0)
                    prompt:InputHoldEnd()
                end
            end)
        end)
    end
end)

--========================================================--
-- STAMINA & JUMP
--========================================================--

local function toggleInfStamina(enable)
    InfStaminaEnabled = enable
    pcall(function()
        local success, sprintModule = pcall(function()
            return require(ReplicatedStorage.Modules.Game.Sprint)
        end)
        if success and sprintModule then
            local consumeFunc = sprintModule.consume_stamina
            local upvalues = getupvalues(consumeFunc)
            local sprintBar
            for _, uv in ipairs(upvalues) do
                if type(uv) == "table" and rawget(uv, "sprint_bar") then
                    sprintBar = uv.sprint_bar
                    break
                end
            end
            
            if sprintBar then
                if enable then
                    local originalUpdate = sprintBar.update
                    sprintBar.update = function(...)
                        return originalUpdate(function() return 1 end)
                    end
                    OriginalSprintUpdate = originalUpdate
                    AutoSprintLoop = task.spawn(function()
                        while InfStaminaEnabled do
                            pcall(function()
                                FireServerHook("set_sprinting_1", true)
                                task.wait(0.5)
                                FireServerHook("set_sprinting_1", false)
                            end)
                            task.wait(0.1)
                        end
                        pcall(function() FireServerHook("set_sprinting_1", false) end)
                    end)
                else
                    if AutoSprintLoop then
                        task.cancel(AutoSprintLoop)
                        AutoSprintLoop = nil
                    end
                    pcall(function() FireServerHook("set_sprinting_1", false) end)
                    if OriginalSprintUpdate and sprintBar then
                        sprintBar.update = OriginalSprintUpdate
                        OriginalSprintUpdate = nil
                    end
                end
            end
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, JumpPowerBypassValue, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

--========================================================--
-- AUTO-PICKUP & ANTI-KILL
--========================================================--

local al_pickup_cache = {}
local lastAutoPickupScan = 0
RunService.RenderStepped:Connect(function()
    local now = os.clock()
    if now - lastAutoPickupScan < 0.15 then return end
    lastAutoPickupScan = now
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if AutoPickupEnabled and DroppedItems and myRoot then
        local currentTime = tick()
        for _, model in ipairs(DroppedItems:GetChildren()) do
            if model:IsA("Model") then
                local part = model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("PickUpZone")
                if part then
                    local dist = (part.Position - myRoot.Position).Magnitude
                    if dist <= AutoPickupRadius and (currentTime - (al_pickup_cache[model] or 0)) >= 0.20 then
                        al_pickup_cache[model] = currentTime
                        InvokeServerHook("pickup_dropped_item", model)
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if AutoSafeDamageEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if hum.Health > 0 then
                if hum.Health <= 30 and not AutoSafeActive then
                    AutoSafeActive = true
                    SavedAutoSafeY = root.Position.Y
                    TargetAutoSafeY = SavedAutoSafeY - AutoSafeDepth
                    FrozenCameraCFrame = Camera.CFrame
                end
                
                if AutoSafeActive then
                    if TargetAutoSafeY then
                        local offsetX = math.sin(os.clock() * 35) * 3.5
                        local offsetZ = math.cos(os.clock() * 35) * 3.5
                        root.CFrame = CFrame.new(root.Position.X + offsetX, TargetAutoSafeY, root.Position.Z + offsetZ)
                        root.Velocity = Vector3.zero
                    end
                    
                    if FrozenCameraCFrame then
                        Camera.CFrame = FrozenCameraCFrame
                    end
                    
                    if hum.Health >= 40 then
                        AutoSafeActive = false
                        if SavedAutoSafeY then
                            root.CFrame = CFrame.new(root.Position.X, SavedAutoSafeY + 1.5, root.Position.Z)
                        end
                        TargetAutoSafeY = nil
                        SavedAutoSafeY = nil
                        FrozenCameraCFrame = nil
                    end
                end
            else
                AutoSafeActive = false
                TargetAutoSafeY = nil
                SavedAutoSafeY = nil
                FrozenCameraCFrame = nil
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    AutoSafeActive = false
    TargetAutoSafeY = nil
    SavedAutoSafeY = nil
    FrozenCameraCFrame = nil
end)

--========================================================--
-- POTATO BOOST (200 FPS)
--========================================================--

local function togglePotatoGraphics(enable)
    PotatoBoostEnabled = enable
    pcall(function()
        if setfpscap then
            setfpscap(enable and 200 or 60)
        end
        if enable then
            Camera.FieldOfView = 96
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1.8

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end

            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("BasePart") and not desc.Parent:FindFirstChildOfClass("Humanoid") then
                    desc.Material = Enum.Material.SmoothPlastic
                    desc.Reflectance = 0
                elseif desc:IsA("Decal") or desc:IsA("Texture") then
                    desc.Transparency = 0.5
                elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") then
                    desc.Enabled = false
                end
            end
        else
            Camera.FieldOfView = OriginalCameraFOV or 70
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2.0

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then effect.Enabled = true end
            end
        end
    end)
end

--========================================================--
-- ESP MOTOR
--========================================================--

local function removePlayerESP(pl)
    if PlayerBillboards[pl] then
        if PlayerBillboards[pl].Billboard then pcall(function() PlayerBillboards[pl].Billboard:Destroy() end) end
        PlayerBillboards[pl] = nil
    end
    if HighlightCache[pl] then
        pcall(function() HighlightCache[pl]:Destroy() end)
        HighlightCache[pl] = nil
    end
    if WeaponBillboardCache[pl] then 
        pcall(function() WeaponBillboardCache[pl]:Destroy() end)
        WeaponBillboardCache[pl] = nil 
    end
    WeaponCacheTokens[pl] = nil
    RemoveVisualPlayerObjects(pl)
end
Players.PlayerRemoving:Connect(removePlayerESP)

local function ensurePlayerESP(pl)
    if pl == LocalPlayer then return end
    local char = pl.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not head or not root or not hum then return end

    if not PlayerBillboards[pl] or not PlayerBillboards[pl].Billboard or not PlayerBillboards[pl].Billboard.Parent or PlayerBillboards[pl].Billboard.Adornee ~= head then
        if PlayerBillboards[pl] and PlayerBillboards[pl].Billboard then
            pcall(function() PlayerBillboards[pl].Billboard:Destroy() end)
        end

        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_" .. pl.Name
        bb.Adornee = head
        bb.Size = UDim2.new(0, 160, 0, 60)
        bb.StudsOffset = Vector3.new(0, 2.2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = CoreGui

        local container = Instance.new("Frame", bb)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1

        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = pl.Name
        nameLabel.TextColor3 = ThemeColor
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamMedium

        local hpBg = Instance.new("Frame", container)
        hpBg.Size = UDim2.new(0, 75, 0, 4)
        hpBg.Position = UDim2.new(0.5, -37, 0, 18)
        hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        hpBg.BorderSizePixel = 0
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

        local hpFill = Instance.new("Frame", hpBg)
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = ThemeColor
        hpFill.BorderSizePixel = 0
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

        local distLabel = Instance.new("TextLabel", container)
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 0, 24)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        distLabel.TextSize = 11
        distLabel.Font = Enum.Font.GothamMedium

        PlayerBillboards[pl] = { Billboard = bb, Name = nameLabel, HpBg = hpBg, HpFill = hpFill, Dist = distLabel, Humanoid = hum, Root = root }
    end
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if WeaponESPEnabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local char = pl.Character
                    local root = char.HumanoidRootPart
                    local tools = {}
                    local token = ""
                    local bp = pl:FindFirstChild("Backpack")
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do 
                            if t:IsA("Tool") and t.Name ~= "Fists" then 
                                table.insert(tools, t) 
                                token = token .. t.Name .. "_"
                            end 
                        end
                    end
                    for _, t in ipairs(char:GetChildren()) do 
                        if t:IsA("Tool") and t.Name ~= "Fists" then 
                            table.insert(tools, t) 
                            token = token .. t.Name .. "_E_"
                        end 
                    end
                    
                    local bg = WeaponBillboardCache[pl]
                    if not bg or not bg.Parent or bg.Adornee ~= root then
                        if bg then pcall(function() bg:Destroy() end) end
                        bg = Instance.new("BillboardGui")
                        bg.Name = "WeaponESP_" .. pl.Name
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 140, 0, 24)
                        bg.StudsOffset = Vector3.new(0, -4, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = CoreGui
                        
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        WeaponBillboardCache[pl] = bg
                        WeaponCacheTokens[pl] = nil
                    end

                    if WeaponCacheTokens[pl] ~= token then
                        WeaponCacheTokens[pl] = token
                        bg:ClearAllChildren()
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        for _, t in ipairs(tools) do
                            local info = getWeaponData(t)
                            if info then
                                local icon = Instance.new("ImageLabel", bg)
                                icon.Size = UDim2.new(0, 22, 0, 22)
                                icon.BackgroundTransparency = 0.2
                                icon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                                icon.Image = info.ImageId
                                Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
                                local stroke = Instance.new("UIStroke", icon)
                                stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                stroke.Thickness = 1.5
                            end
                        end
                    end
                end
            end
        else
            for _, bg in pairs(WeaponBillboardCache) do bg:Destroy() end
            WeaponBillboardCache = {}
            WeaponCacheTokens = {}
        end
    end
end)

local lastItemESPScan = 0
RunService.RenderStepped:Connect(function()
    local now = os.clock()
    if now - lastItemESPScan < 0.15 then return end
    lastItemESPScan = now
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if ItemESPEnabled and DroppedItems and myRoot then
        local closestPerName = {}
        for _, model in ipairs(DroppedItems:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("PickUpZone") then
                local zone = model.PickUpZone
                local dist = (zone.Position - myRoot.Position).Magnitude
                local itemName = model.Name
                if not closestPerName[itemName] or dist < closestPerName[itemName].dist then
                    closestPerName[itemName] = {model = model, dist = dist, zone = zone}
                end
            end
        end

        for _, data in pairs(ItemDrawingsCache) do
            if data.Billboard then data.Billboard.Enabled = false end
            if data.Highlight then data.Highlight.Enabled = false end
        end

        for name, info in pairs(closestPerName) do
            local model = info.model
            local zone = info.zone
            local dist = info.dist
            local itemData = ItemDrawingsCache[model]
            if not itemData then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ItemESP_" .. name
                bb.Adornee = zone
                bb.Size = UDim2.new(0, 120, 0, 35)
                bb.StudsOffset = Vector3.new(0, 1.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = CoreGui

                local label = Instance.new("TextLabel", bb)
                label.Size = UDim2.new(1, 0, 0, 18)
                label.BackgroundTransparency = 1
                label.Text = name
                label.TextColor3 = RarityColors[model:GetAttribute("RarityName")] or Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.2
                label.TextSize = 12
                label.Font = Enum.Font.GothamMedium

                local distLbl = Instance.new("TextLabel", bb)
                distLbl.Name = "DistLbl"
                distLbl.Size = UDim2.new(1, 0, 0, 16)
                distLbl.Position = UDim2.new(0, 0, 0, 16)
                distLbl.BackgroundTransparency = 1
                distLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
                distLbl.TextSize = 11
                distLbl.Font = Enum.Font.GothamMedium

                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.2
                hl.FillColor = label.TextColor3
                hl.Parent = CoreGui
                
                itemData = {Billboard = bb, DistLabel = distLbl, Highlight = hl}
                ItemDrawingsCache[model] = itemData
            end
            if dist <= 300 then
                itemData.Billboard.Enabled = true
                itemData.Highlight.Enabled = true
                if itemData.DistLabel then
                    itemData.DistLabel.Text = string.format("%.0f m", dist * 0.28)
                end
            end
        end
    else
        for _, v in pairs(ItemDrawingsCache) do
            if v.Billboard then v.Billboard.Enabled = false end
            if v.Highlight then v.Highlight.Enabled = false end
        end
    end
end)

local lastVisualPlayerUpdate = 0
RunService.RenderStepped:Connect(function(dt)
    local bestTarget = GetBestVisualTarget()
    CurrentLockedTarget = (SilentAimEnabled or SettingsVisual.TargetLine) and bestTarget or nil

    if SettingsVisual.TargetLine then
        CurrentTarget = bestTarget
    else
        CurrentTarget = nil
    end

    if SettingsVisual.FOV and HasEnteredPanel then
        FOVCircle.Visible = true
        FOVStroke.Color = ThemeColor
        FOVTime = FOVTime + dt * SettingsVisual.FOVSpeed
        local wave = (math.sin(FOVTime) + 1) / 2
        local radius = SettingsVisual.FOVMin + (SettingsVisual.FOVMax - SettingsVisual.FOVMin) * wave
        FOVCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
    else
        FOVCircle.Visible = false
    end

    UpdateTargetLine()

    if FloatingSnapActive and FloatingTargetY and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position.X, FloatingTargetY, root.Position.Z)
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if SpeedHackEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local move = hum.MoveDirection.Unit * ((SpeedValue / 20) * 26 * dt)
            root.CFrame = root.CFrame + Vector3.new(move.X, 0, move.Z)
        end
    end

    if HeadHidingAntiAim and LocalPlayer.Character then
        local neck = LocalPlayer.Character:FindFirstChild("Neck", true)
        if neck then neck.C0 = CFrame.new(0, -1.8, 0.2) * CFrame.Angles(math.rad(-85), 0, 0) end
    end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if os.clock() - lastVisualPlayerUpdate >= 0.1 then
        lastVisualPlayerUpdate = os.clock()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local char = pl.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if char and root and hum then
                ensurePlayerESP(pl)
                local data = PlayerBillboards[pl]

                if data and data.Billboard and data.Billboard.Parent then
                    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                    data.Name.Visible = PlayerESP_Name
                    data.Name.TextColor3 = ThemeColor

                    if PlayerESP_Health then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        data.HpBg.Visible = true
                        data.HpFill.Size = UDim2.new(pct, 0, 1, 0)
                        data.HpFill.BackgroundColor3 = ThemeColor
                    else
                        data.HpBg.Visible = false
                    end

                    data.Dist.Visible = PlayerESP_Dist
                    if PlayerESP_Dist then
                        data.Dist.Text = string.format("%.0f m", dist * 0.28)
                    end
                end

                if CurrentLockedTarget == pl then
                    local hl = HighlightCache[pl]
                    if not hl or not hl.Parent or hl.Adornee ~= char then
                        if hl then pcall(function() hl:Destroy() end) end
                        hl = Instance.new("Highlight")
                        hl.Name = "FOVDestroyerHighlight_" .. pl.Name
                        hl.Adornee = char
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0.1
                        hl.Parent = CoreGui
                        HighlightCache[pl] = hl
                    else
                        hl.Enabled = true
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                    end
                elseif HighlightCache[pl] then
                    HighlightCache[pl].Enabled = false
                end
            else
                if PlayerBillboards[pl] and PlayerBillboards[pl].Billboard then
                    PlayerBillboards[pl].Name.Visible = false
                    PlayerBillboards[pl].HpBg.Visible = false
                    PlayerBillboards[pl].Dist.Visible = false
                end
                if HighlightCache[pl] then HighlightCache[pl].Enabled = false end
            end
        end
    end

    for player, data in pairs(VisualPlayerObjects) do
        local character = player.Character
        if not character then
            data.Box.Visible = false
            data.Line.Visible = false
            continue
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if not root or not head then
            data.Box.Visible = false
            data.Line.Visible = false
            continue
        end

        data.Box.Adornee = character
        data.Box.Color3 = ThemeColor
        data.Box.Visible = SettingsVisual.Box

        if SettingsVisual.Lines then
            local headPosition, visible = Camera:WorldToViewportPoint(head.Position)
            if visible and headPosition.Z > 0 then
                local enemyHead = Vector2.new(headPosition.X, headPosition.Y)
                local lineStart = Vector2.new(Camera.ViewportSize.X / 2, SettingsVisual.LineOriginY)
                local lineTarget = Vector2.new(enemyHead.X, enemyHead.Y + SettingsVisual.LineTargetOffset)
                local difference = lineTarget - lineStart
                local length = difference.Magnitude

                if length > 0 then
                    data.Line.BackgroundColor3 = ThemeColor
                    data.Line.Position = UDim2.fromOffset((lineStart.X + lineTarget.X) / 2, (lineStart.Y + lineTarget.Y) / 2)
                    data.Line.Size = UDim2.fromOffset(length, 1)
                    data.Line.Rotation = math.deg(math.atan2(difference.Y, difference.X))
                    data.Line.Visible = true
                else
                    data.Line.Visible = false
                end
            else
                data.Line.Visible = false
            end
        else
            data.Line.Visible = false
        end
    end
    end
end)

local function UpdateSystemTheme(newColor)
    ThemeColor = newColor
    FOVStroke.Color = newColor

    for _, item in ipairs(DynamicColorElements) do
        if item.Type == "Stroke" then
            item.Element.Color = newColor
        elseif item.Type == "Background" then
            item.Element.BackgroundColor3 = newColor
        elseif item.Type == "Text" then
            item.Element.TextColor3 = newColor
        elseif item.Type == "Toggle" and item.State() then
            item.Element.BackgroundColor3 = newColor
        end
    end

    for _, obj in pairs(VisualPlayerObjects) do
        if obj.Box then obj.Box.Color3 = newColor end
        if obj.Line then obj.Line.BackgroundColor3 = newColor end
    end

    for _, orb in ipairs(RegisteredOrbs) do
        TweenService:Create(orb.Glow, TweenInfo.new(0.4), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(orb.Core, TweenInfo.new(0.4), {BackgroundColor3 = newColor}):Play()
    end

    if AstralOrb then AstralOrb.Color = newColor end
end

--========================================================--
-- PANEL TÁCTIL TP
--========================================================--

local FloatingSnapGui = Instance.new("ScreenGui")
FloatingSnapGui.Name = "FloatingSnapGui"
FloatingSnapGui.ResetOnSpawn = false
FloatingSnapGui.Enabled = false
FloatingSnapGui.Parent = CoreGui

local TouchSnapFrame = Instance.new("Frame", FloatingSnapGui)
TouchSnapFrame.Size = UDim2.new(0, 130, 0, 128)
TouchSnapFrame.Position = UDim2.new(0.04, 0, 0.45, 0)
TouchSnapFrame.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
TouchSnapFrame.BackgroundTransparency = 0.1
TouchSnapFrame.BorderSizePixel = 0
TouchSnapFrame.Active = true
TouchSnapFrame.Draggable = true
Instance.new("UICorner", TouchSnapFrame).CornerRadius = UDim.new(0, 16)
AttachSnowEffect(TouchSnapFrame)

local touchStroke = Instance.new("UIStroke", TouchSnapFrame)
touchStroke.Color = ThemeColor
touchStroke.Thickness = 1.3
table.insert(DynamicColorElements, {Type = "Stroke", Element = touchStroke})

local btnTouchTP = Instance.new("TextButton", TouchSnapFrame)
btnTouchTP.Size = UDim2.new(0, 78, 0, 26)
btnTouchTP.Position = UDim2.new(0, 8, 0, 8)
btnTouchTP.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
btnTouchTP.BackgroundTransparency = 0.2
btnTouchTP.BorderSizePixel = 0
btnTouchTP.Text = "TP"
btnTouchTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTouchTP.TextSize = 11
btnTouchTP.Font = Enum.Font.GothamMedium
btnTouchTP.ZIndex = 2
Instance.new("UICorner", btnTouchTP).CornerRadius = UDim.new(0, 6)

local btnLock = Instance.new("TextButton", TouchSnapFrame)
btnLock.Size = UDim2.new(0, 26, 0, 26)
btnLock.Position = UDim2.new(1, -34, 0, 8)
btnLock.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
btnLock.BorderSizePixel = 0
btnLock.Text = "🔓"
btnLock.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLock.TextSize = 11
btnLock.ZIndex = 2
Instance.new("UICorner", btnLock).CornerRadius = UDim.new(0, 6)

local isPanelLocked = false
btnLock.MouseButton1Click:Connect(function()
    isPanelLocked = not isPanelLocked
    TouchSnapFrame.Draggable = not isPanelLocked
    btnLock.Text = isPanelLocked and "🔒" or "🔓"
    btnLock.BackgroundColor3 = isPanelLocked and Color3.fromRGB(200, 20, 30) or Color3.fromRGB(28, 25, 38)
end)

local function triggerTouchTP()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not FloatingSnapActive then
        FloatingSavedSurfaceY = root.Position.Y
        FloatingTargetY = FloatingSavedSurfaceY - FloatingSnapDepth
        FloatingSnapActive = true
        root.CFrame = CFrame.new(root.Position.X, FloatingTargetY, root.Position.Z)
        btnTouchTP.Text = "SUBIR"
        btnTouchTP.BackgroundColor3 = Color3.fromRGB(200, 25, 45)
    else
        FloatingSnapActive = false
        if FloatingSavedSurfaceY then root.CFrame = CFrame.new(root.Position.X, FloatingSavedSurfaceY + 1.5, root.Position.Z) end
        FloatingTargetY = nil
        FloatingSavedSurfaceY = nil
        btnTouchTP.Text = "TP"
        btnTouchTP.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
    end
end
btnTouchTP.MouseButton1Click:Connect(triggerTouchTP)

local fsInput = Instance.new("TextBox", TouchSnapFrame)
fsInput.Size = UDim2.new(1, -16, 0, 20)
fsInput.Position = UDim2.new(0, 8, 0, 40)
fsInput.BackgroundTransparency = 0.5
fsInput.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎"
fsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
fsInput.TextSize = 11
fsInput.Font = Enum.Font.GothamMedium
fsInput.ZIndex = 2
Instance.new("UICorner", fsInput).CornerRadius = UDim.new(0, 6)

fsInput.Focused:Connect(function() fsInput.Text = "" end)

local fsBar = Instance.new("Frame", TouchSnapFrame)
fsBar.Size = UDim2.new(1, -16, 0, 10)
fsBar.Position = UDim2.new(0, 8, 0, 68)
fsBar.BackgroundColor3 = Color3.fromRGB(30, 28, 42)
fsBar.ZIndex = 2
Instance.new("UICorner", fsBar).CornerRadius = UDim.new(1, 0)

local fsFill = Instance.new("Frame", fsBar)
fsFill.Size = UDim2.new((FloatingSnapDepth - 5) / 95, 0, 1, 0)
fsFill.BackgroundColor3 = ThemeColor
fsFill.ZIndex = 2
Instance.new("UICorner", fsFill).CornerRadius = UDim.new(1, 0)
table.insert(DynamicColorElements, {Type = "Background", Element = fsFill})

local fsDot = Instance.new("Frame", fsFill)
fsDot.Size = UDim2.new(0, 18, 0, 18)
fsDot.Position = UDim2.new(1, -8, 0.5, -8)
fsDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fsDot.BorderSizePixel = 0
fsDot.ZIndex = 3
Instance.new("UICorner", fsDot).CornerRadius = UDim.new(1, 0)

local fsHitboxPadding = Instance.new("TextButton", fsDot)
fsHitboxPadding.Size = UDim2.new(0, 42, 0, 42)
fsHitboxPadding.Position = UDim2.new(0.5, -21, 0.5, -21)
fsHitboxPadding.BackgroundTransparency = 1
fsHitboxPadding.Text = ""
fsHitboxPadding.ZIndex = 4

local function setDepth(val)
    FloatingSnapDepth = math.clamp(val, 5, 100)
    fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎"
    fsFill.Size = UDim2.new((FloatingSnapDepth - 5) / 95, 0, 1, 0)
    if FloatingSnapActive and FloatingSavedSurfaceY then
        FloatingTargetY = FloatingSavedSurfaceY - FloatingSnapDepth
    end
end

fsInput.FocusLost:Connect(function()
    local num = tonumber(fsInput.Text:match("%d+"))
    if num then setDepth(num) else fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎" end
end)

local isDraggingDepth = false
local function handleDepthInput(input)
    local pos = math.clamp((input.Position.X - fsBar.AbsolutePosition.X) / fsBar.AbsoluteSize.X, 0, 1)
    setDepth(math.floor(5 + (95 * pos)))
end

fsBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = true
        handleDepthInput(input)
    end
end)

fsHitboxPadding.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = true
        handleDepthInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingDepth and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        handleDepthInput(input)
    end
end)

local tpKeyBox = Instance.new("TextBox", TouchSnapFrame)
tpKeyBox.Size = UDim2.new(1, -16, 0, 20)
tpKeyBox.Position = UDim2.new(0, 8, 1, -26)
tpKeyBox.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
tpKeyBox.BackgroundTransparency = 0.4
tpKeyBox.Text = "Key: E"
tpKeyBox.TextColor3 = Color3.fromRGB(180, 180, 200)
tpKeyBox.TextSize = 10
tpKeyBox.Font = Enum.Font.GothamMedium
tpKeyBox.ZIndex = 2
Instance.new("UICorner", tpKeyBox).CornerRadius = UDim.new(0, 6)

local selectedTPKey = Enum.KeyCode.E
tpKeyBox.Focused:Connect(function() tpKeyBox.Text = "..." end)
tpKeyBox.FocusLost:Connect(function() tpKeyBox.Text = "Key: " .. tostring(selectedTPKey.Name) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if tpKeyBox:IsFocused() and input.UserInputType == Enum.UserInputType.Keyboard then
        selectedTPKey = input.KeyCode
        tpKeyBox:ReleaseFocus()
    elseif not gp and input.KeyCode == selectedTPKey then
        triggerTouchTP()
    end
end)

--========================================================--
-- GHOST ASTRAL
--========================================================--

local AstralProjectionGui = Instance.new("ScreenGui")
AstralProjectionGui.Name = "AstralProjectionGui"
AstralProjectionGui.ResetOnSpawn = false
AstralProjectionGui.Enabled = false
AstralProjectionGui.Parent = CoreGui

local AstralSwitchCard = Instance.new("Frame", AstralProjectionGui)
AstralSwitchCard.Size = UDim2.new(0, 120, 0, 70)
AstralSwitchCard.Position = UDim2.new(0.04, 0, 0.62, 0)
AstralSwitchCard.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
AstralSwitchCard.BackgroundTransparency = 0.1
AstralSwitchCard.BorderSizePixel = 0
AstralSwitchCard.Active = true
AstralSwitchCard.Draggable = true
Instance.new("UICorner", AstralSwitchCard).CornerRadius = UDim.new(0, 16)
AttachSnowEffect(AstralSwitchCard)

local astralStroke = Instance.new("UIStroke", AstralSwitchCard)
astralStroke.Color = ThemeColor
astralStroke.Thickness = 1.3
table.insert(DynamicColorElements, {Type = "Stroke", Element = astralStroke})

local AstralLabel = Instance.new("TextLabel", AstralSwitchCard)
AstralLabel.Size = UDim2.new(1, -55, 0, 36)
AstralLabel.Position = UDim2.new(0, 10, 0, 2)
AstralLabel.BackgroundTransparency = 1
AstralLabel.Text = "Ghost"
AstralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AstralLabel.TextSize = 12
AstralLabel.Font = Enum.Font.GothamMedium
AstralLabel.TextXAlignment = Enum.TextXAlignment.Left
AstralLabel.ZIndex = 2

local SwitchBg = Instance.new("Frame", AstralSwitchCard)
SwitchBg.Size = UDim2.new(0, 36, 0, 20)
SwitchBg.Position = UDim2.new(1, -44, 0, 10)
SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
SwitchBg.ZIndex = 2
Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

local SwitchThumb = Instance.new("Frame", SwitchBg)
SwitchThumb.Size = UDim2.new(0, 16, 0, 16)
SwitchThumb.Position = UDim2.new(0, 2, 0.5, -8)
SwitchThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchThumb.ZIndex = 3
Instance.new("UICorner", SwitchThumb).CornerRadius = UDim.new(1, 0)

local SwitchBtn = Instance.new("TextButton", SwitchBg)
SwitchBtn.Size = UDim2.new(1, 0, 1, 0)
SwitchBtn.BackgroundTransparency = 1
SwitchBtn.Text = ""
SwitchBtn.ZIndex = 4

local ghostKeyBox = Instance.new("TextBox", AstralSwitchCard)
ghostKeyBox.Size = UDim2.new(1, -16, 0, 20)
ghostKeyBox.Position = UDim2.new(0, 8, 1, -26)
ghostKeyBox.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
ghostKeyBox.BackgroundTransparency = 0.4
ghostKeyBox.Text = "Key: Q"
ghostKeyBox.TextColor3 = Color3.fromRGB(180, 180, 200)
ghostKeyBox.TextSize = 10
ghostKeyBox.Font = Enum.Font.GothamMedium
ghostKeyBox.ZIndex = 2
Instance.new("UICorner", ghostKeyBox).CornerRadius = UDim.new(0, 6)

local selectedGhostKey = Enum.KeyCode.Q
ghostKeyBox.Focused:Connect(function() ghostKeyBox.Text = "..." end)
ghostKeyBox.FocusLost:Connect(function() ghostKeyBox.Text = "Key: " .. tostring(selectedGhostKey.Name) end)

local function toggleAstralProjection(enable)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    AstralActive = enable
    if enable then
        FrozenCharCF = root.CFrame
        root.Anchored = true

        AstralOrb = Instance.new("Part")
        AstralOrb.Name = "AstralOrb_Ghost"
        AstralOrb.Shape = Enum.PartType.Ball
        AstralOrb.Size = Vector3.new(1.8, 1.8, 1.8)
        AstralOrb.Material = Enum.Material.Neon
        AstralOrb.Color = ThemeColor
        AstralOrb.Transparency = 0.35
        AstralOrb.CanCollide = false
        AstralOrb.Anchored = true
        AstralOrb.CFrame = root.CFrame
        AstralOrb.Parent = workspace

        local orbHL = Instance.new("Highlight", AstralOrb)
        orbHL.FillColor = ThemeColor
        orbHL.OutlineColor = Color3.fromRGB(255, 255, 255)
        orbHL.FillTransparency = 0.4

        Camera.CameraSubject = AstralOrb

        AstralConnection = RunService.RenderStepped:Connect(function(dt)
            if AstralOrb and AstralActive then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.MoveDirection.Magnitude > 0 then
                    local move = hum.MoveDirection.Unit * (AstralSpeed * dt)
                    AstralOrb.CFrame = AstralOrb.CFrame + Vector3.new(move.X, 0, move.Z)
                end
            end
        end)
    else
        if AstralConnection then AstralConnection:Disconnect(); AstralConnection = nil end
        if AstralOrb then
            local finalPos = AstralOrb.Position
            root.Anchored = false
            root.CFrame = CFrame.new(finalPos) + Vector3.new(0, 2, 0)
            AstralOrb:Destroy()
            AstralOrb = nil
        else
            root.Anchored = false
        end
        if char:FindFirstChild("Humanoid") then
            Camera.CameraSubject = char.Humanoid
        end
    end
end

SwitchBtn.MouseButton1Click:Connect(function()
    local newState = not AstralActive
    TweenService:Create(SwitchBg, TweenInfo.new(0.2), {
        BackgroundColor3 = newState and ThemeColor or Color3.fromRGB(35, 32, 45)
    }):Play()
    TweenService:Create(SwitchThumb, TweenInfo.new(0.2), {
        Position = newState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    }):Play()
    toggleAstralProjection(newState)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if ghostKeyBox:IsFocused() and input.UserInputType == Enum.UserInputType.Keyboard then
        selectedGhostKey = input.KeyCode
        ghostKeyBox:ReleaseFocus()
    elseif not gp and input.KeyCode == selectedGhostKey then
        local newState = not AstralActive
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {
            BackgroundColor3 = newState and ThemeColor or Color3.fromRGB(35, 32, 45)
        }):Play()
        TweenService:Create(SwitchThumb, TweenInfo.new(0.2), {
            Position = newState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        toggleAstralProjection(newState)
    end
end)

--========================================================--
-- PERSISTENCIA
--========================================================--

local function SaveConfigurationSafe()
    if not writefile then return false end
    local buffer = {
        "FOV=" .. (SettingsVisual.FOV and "1" or "0"),
        "Silent=" .. (SilentAimEnabled and "1" or "0"),
        "Jump=" .. (InfiniteJumpEnabled and "1" or "0"),
        "Stamina=" .. (InfStaminaEnabled and "1" or "0"),
        "Speed=" .. (SpeedHackEnabled and "1" or "0"),
        "SpeedVal=" .. tostring(SpeedValue),
        "Potato=" .. (PotatoBoostEnabled and "1" or "0"),
        "Crates=" .. (SkipCratesEnabled and "1" or "0"),
        "AutoKill=" .. (AutoSafeDamageEnabled and "1" or "0"),
        "ESP_Box=" .. (SettingsVisual.Box and "1" or "0"),
        "ESP_Line=" .. (SettingsVisual.Lines and "1" or "0"),
        "ESP_Name=" .. (PlayerESP_Name and "1" or "0"),
        "ESP_HP=" .. (PlayerESP_Health and "1" or "0"),
        "ESP_Dist=" .. (PlayerESP_Dist and "1" or "0"),
        "ESP_Wep=" .. (WeaponESPEnabled and "1" or "0"),
        "ESP_Item=" .. (ItemESPEnabled and "1" or "0"),
        "GunMods=" .. (GunModsActive and "1" or "0"),
        "Melee=" .. (MeleeAuraEnabled and "1" or "0"),
        "Pickup=" .. (AutoPickupEnabled and "1" or "0"),
        "Interact=" .. (AutoInteractEnabled and "1" or "0"),
        "V_Acc=" .. tostring(VehAcceleration),
        "V_Brk=" .. tostring(VehBraking),
        "V_Dec=" .. tostring(VehDeceleration),
        "V_Fwd=" .. tostring(VehForwardMaxSpeed),
        "V_Rev=" .. tostring(VehReverseMaxSpeed),
        "V_Sus=" .. tostring(VehSuspension),
        "V_Acc_E=" .. (VehAcceleration_Enabled and "1" or "0"),
        "V_Brk_E=" .. (VehBraking_Enabled and "1" or "0"),
        "V_Dec_E=" .. (VehDeceleration_Enabled and "1" or "0"),
        "V_Fwd_E=" .. (VehForwardMaxSpeed_Enabled and "1" or "0"),
        "V_Rev_E=" .. (VehReverseMaxSpeed_Enabled and "1" or "0"),
        "V_Sus_E=" .. (VehSuspension_Enabled and "1" or "0")
    }
    local content = table.concat(buffer, "\n")
    pcall(function() writefile(CFG_FILE, content) end)
    return true
end

local function LoadConfigurationSafe()
    if not (isfile and readfile) then return end
    local exists = false
    pcall(function() exists = isfile(CFG_FILE) end)
    if not exists then return end

    pcall(function()
        local content = readfile(CFG_FILE)
        for line in string.gmatch(content, "[^\r\n]+") do
            local key, val = string.match(line, "([^=]+)=(.*)")
            if key and val then
                if key == "FOV" then SettingsVisual.FOV = (val == "1")
                elseif key == "Silent" then SilentAimEnabled = (val == "1")
                elseif key == "Jump" then InfiniteJumpEnabled = (val == "1")
                elseif key == "Stamina" then if val == "1" then toggleInfStamina(true) end
                elseif key == "Speed" then SpeedHackEnabled = (val == "1")
                elseif key == "SpeedVal" then SpeedValue = tonumber(val) or SpeedValue
                elseif key == "Potato" then if val == "1" then togglePotatoGraphics(true) end
                elseif key == "Crates" then SkipCratesEnabled = (val == "1")
                elseif key == "AutoKill" then AutoSafeDamageEnabled = (val == "1")
                elseif key == "ESP_Box" then SettingsVisual.Box = (val == "1")
                elseif key == "ESP_Line" then SettingsVisual.Lines = (val == "1")
                elseif key == "ESP_Name" then PlayerESP_Name = (val == "1")
                elseif key == "ESP_HP" then PlayerESP_Health = (val == "1")
                elseif key == "ESP_Dist" then PlayerESP_Dist = (val == "1")
                elseif key == "ESP_Wep" then WeaponESPEnabled = (val == "1")
                elseif key == "ESP_Item" then ItemESPEnabled = (val == "1")
                elseif key == "GunMods" then GunModsActive = (val == "1")
                elseif key == "Melee" then MeleeAuraEnabled = (val == "1")
                elseif key == "Pickup" then AutoPickupEnabled = (val == "1")
                elseif key == "Interact" then AutoInteractEnabled = (val == "1")
                elseif key == "V_Acc" then VehAcceleration = tonumber(val) or VehAcceleration
                elseif key == "V_Brk" then VehBraking = tonumber(val) or VehBraking
                elseif key == "V_Dec" then VehDeceleration = tonumber(val) or VehDeceleration
                elseif key == "V_Fwd" then VehForwardMaxSpeed = tonumber(val) or VehForwardMaxSpeed
                elseif key == "V_Rev" then VehReverseMaxSpeed = tonumber(val) or VehReverseMaxSpeed
                elseif key == "V_Sus" then VehSuspension = tonumber(val) or VehSuspension
                elseif key == "V_Acc_E" then VehAcceleration_Enabled = (val == "1")
                elseif key == "V_Brk_E" then VehBraking_Enabled = (val == "1")
                elseif key == "V_Dec_E" then VehDeceleration_Enabled = (val == "1")
                elseif key == "V_Fwd_E" then VehForwardMaxSpeed_Enabled = (val == "1")
                elseif key == "V_Rev_E" then VehReverseMaxSpeed_Enabled = (val == "1")
                elseif key == "V_Sus_E" then VehSuspension_Enabled = (val == "1")
                end
            end
        end
    end)
end

-- No cargamos estados guardados al iniciar: todas las opciones empiezan desactivadas.

--========================================================--
-- MAIN HUB
--========================================================--

local function OpenMainHub()
    HasEnteredPanel = true

    -- La pantalla de carga original fue eliminada. ScreenGui solo conserva los overlays visuales.

    local function fetchWindUI(url)
        local ok, result = pcall(function() return game:HttpGet(url) end)
        if ok and type(result) == "string" and #result > 100 then return result end
        return ""
    end

    local windSource = fetchWindUI("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
    if windSource == "" then
        windSource = fetchWindUI("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
    end
    if windSource == "" then
        warn("POTENT HUB: no se pudo cargar WindUI. Revisa la conexión e inténtalo de nuevo.")
        return
    end

    local WindUI
    local loaded, loadError = pcall(function() WindUI = loadstring(windSource)() end)
    if not loaded or not WindUI then
        warn("POTENT HUB: error cargando WindUI: " .. tostring(loadError))
        return
    end

    pcall(function()
        WindUI:AddTheme({
            Name = "PotentGold",
            Accent = Color3.fromRGB(255, 200, 50),
            Outline = Color3.fromRGB(255, 180, 40),
            Text = Color3.fromRGB(255, 255, 255),
            Placeholder = Color3.fromRGB(175, 175, 190),
            Background = Color3.fromRGB(14, 14, 18),
            Button = Color3.fromRGB(32, 32, 40),
            Icon = Color3.fromRGB(255, 205, 70),
        })
        WindUI:SetTheme("PotentGold")
    end)

    local Window = WindUI:CreateWindow({
        Title = "⚡ POTENT HUB",
        Icon = "rbxassetid://117299981730743",
        Author = "POTENT HUB",
        Folder = "POTENTHUB_POTENT HUB",
        Background = "rbxassetid://72427773287138",
        Size = UDim2.fromOffset(640, 490),
        MinSize = Vector2.new(440, 340),
        Resizable = true,
        Transparent = false,
        Theme = "PotentGold",
        User = { Enabled = true, Anonymous = false },
        OpenButton = {
            Title = "POTENT HUB",
            Icon = "rbxassetid://117299981730743",
            CornerRadius = UDim.new(0, 16),
            StrokeThickness = 2,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(168, 85, 247)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(59, 130, 246)),
            }),
            OnlyMobile = false,
            Enabled = true,
            Draggable = true,
        },
    })

    pcall(function() Window:Tag({ Title = "POTENT HUB", Icon = "terminal", Color = Color3.fromRGB(255, 200, 50) }) end)

    local aimTab = Window:Tab({ Title = "🎯 Aim", Icon = "crosshair" })
    local espTab = Window:Tab({ Title = "👁️ ESP", Icon = "eye" })
    local playerTab = Window:Tab({ Title = "👤 Player", Icon = "user" })
    local vehicleTab = Window:Tab({ Title = "🚗 Vehicle", Icon = "car" })
    local miscTab = Window:Tab({ Title = "✨ Misc", Icon = "sparkles" })
    local configTab = Window:Tab({ Title = "⚙️ Config", Icon = "settings" })

    aimTab:Section({ Title = "🎯 Visual Settings" })
    aimTab:Paragraph({ Title = "POTENT HUB", Desc = "Interfaz POTENT HUB. Las opciones se activan manualmente y comienzan desactivadas." })
    aimTab:Toggle({
        Title = "Target Line",
        Value = SettingsVisual.TargetLine,
        Callback = function(state)
            SettingsVisual.TargetLine = state
            if not state then
                CurrentTarget = nil
                pcall(function() TargetLine.Visible = false end)
                pcall(function() TargetMarker.Visible = false end)
            end
        end,
    })
    aimTab:Toggle({ Title = "Mostrar FOV visual", Value = SettingsVisual.FOV, Callback = function(state) SettingsVisual.FOV = state end })
    aimTab:Slider({
        Title = "Radio FOV",
        Value = { Min = 20, Max = 800, Default = SettingsVisual.FOVRadius },
        Step = 5,
        Callback = function(value)
            SettingsVisual.FOVRadius = value
            SettingsVisual.FOVMin = value - 5
            SettingsVisual.FOVMax = value + 5
            pcall(function() FOVCircle.Size = UDim2.fromOffset(value * 2, value * 2) end)
        end,
    })

    espTab:Section({ Title = "👁️ Player ESP" })
    espTab:Toggle({ Title = "ESP Box", Value = SettingsVisual.Box, Callback = function(state) SettingsVisual.Box = state end })
    espTab:Toggle({ Title = "ESP Lines", Value = SettingsVisual.Lines, Callback = function(state) SettingsVisual.Lines = state end })
    espTab:Toggle({ Title = "ESP Highlight", Value = PlayerESP_Highlight, Callback = function(state) PlayerESP_Highlight = state end })
    espTab:Toggle({ Title = "ESP Names", Value = PlayerESP_Name, Callback = function(state) PlayerESP_Name = state end })
    espTab:Toggle({ Title = "ESP Health", Value = PlayerESP_Health, Callback = function(state) PlayerESP_Health = state end })
    espTab:Toggle({ Title = "ESP Distance", Value = PlayerESP_Dist, Callback = function(state) PlayerESP_Dist = state end })
    espTab:Toggle({
        Title = "Weapon ESP",
        Value = WeaponESPEnabled,
        Callback = function(state)
            WeaponESPEnabled = state
            if not state then
                for _, billboard in pairs(WeaponBillboardCache) do pcall(function() billboard:Destroy() end) end
                WeaponBillboardCache = {}
                WeaponCacheTokens = {}
            end
        end,
    })
    espTab:Toggle({ Title = "Item ESP", Value = ItemESPEnabled, Callback = function(state) ItemESPEnabled = state end })

    playerTab:Section({ Title = "👤 Movement" })
    playerTab:Toggle({ Title = "Infinite Jump", Value = InfiniteJumpEnabled, Callback = function(state) InfiniteJumpEnabled = state end })
    playerTab:Slider({
        Title = "Jump Power",
        Value = { Min = 40, Max = 150, Default = JumpPowerBypassValue },
        Step = 1,
        Callback = function(value) JumpPowerBypassValue = value end,
    })
    playerTab:Toggle({ Title = "Infinite Stamina", Value = InfStaminaEnabled, Callback = function(state) InfStaminaEnabled = state; pcall(function() toggleInfStamina(state) end) end })
    playerTab:Toggle({ Title = "Speed Control", Value = SpeedHackEnabled, Callback = function(state) SpeedHackEnabled = state end })
    playerTab:Slider({
        Title = "Speed Value",
        Value = { Min = 1, Max = 20, Default = SpeedValue },
        Step = 1,
        Callback = function(value) SpeedValue = value end,
    })

    vehicleTab:Section({ Title = "🚗 Vehicle Tuning" })
    local function vehicleSlider(title, value, callback)
        vehicleTab:Slider({
            Title = title,
            Value = { Min = 0, Max = 5000, Default = math.clamp(value, 0, 5000) },
            Step = 1,
            Callback = callback,
        })
    end
    vehicleTab:Toggle({ Title = "Enable Acceleration", Value = VehAcceleration_Enabled, Callback = function(state) VehAcceleration_Enabled = state end })
    vehicleSlider("Acceleration", VehAcceleration, function(value) VehAcceleration = value end)
    vehicleTab:Toggle({ Title = "Enable Braking", Value = VehBraking_Enabled, Callback = function(state) VehBraking_Enabled = state end })
    vehicleSlider("Braking", VehBraking, function(value) VehBraking = value end)
    vehicleTab:Toggle({ Title = "Enable Deceleration", Value = VehDeceleration_Enabled, Callback = function(state) VehDeceleration_Enabled = state end })
    vehicleSlider("Deceleration", VehDeceleration, function(value) VehDeceleration = value end)
    vehicleTab:Toggle({ Title = "Enable Forward Max Speed", Value = VehForwardMaxSpeed_Enabled, Callback = function(state) VehForwardMaxSpeed_Enabled = state end })
    vehicleSlider("Forward Max Speed", VehForwardMaxSpeed, function(value) VehForwardMaxSpeed = value end)
    vehicleTab:Toggle({ Title = "Enable Reverse Max Speed", Value = VehReverseMaxSpeed_Enabled, Callback = function(state) VehReverseMaxSpeed_Enabled = state end })
    vehicleSlider("Reverse Max Speed", VehReverseMaxSpeed, function(value) VehReverseMaxSpeed = value end)
    vehicleTab:Toggle({ Title = "Enable Suspension", Value = VehSuspension_Enabled, Callback = function(state) VehSuspension_Enabled = state end })
    vehicleSlider("Suspension", VehSuspension, function(value) VehSuspension = value end)
    vehicleTab:Button({ Title = "Preset: Normal", Callback = function()
        VehAcceleration = 30; VehBraking = 50; VehDeceleration = 15; VehForwardMaxSpeed = 140; VehReverseMaxSpeed = 50; VehSuspension = 2
        WindUI:Notify({ Title = "POTENT HUB", Content = "Normal preset values applied.", Duration = 3 })
    end })
    vehicleTab:Button({ Title = "Preset: Professional", Callback = function()
        VehAcceleration = 75; VehBraking = 120; VehDeceleration = 35; VehForwardMaxSpeed = 320; VehReverseMaxSpeed = 90; VehSuspension = 2.4
        WindUI:Notify({ Title = "POTENT HUB", Content = "Professional preset values applied.", Duration = 3 })
    end })
    vehicleTab:Button({ Title = "Preset: Expert", Callback = function()
        VehAcceleration = 140; VehBraking = 380; VehDeceleration = 130; VehForwardMaxSpeed = 650; VehReverseMaxSpeed = 170; VehSuspension = 1.5
        WindUI:Notify({ Title = "POTENT HUB", Content = "Expert preset values applied.", Duration = 3 })
    end })

    miscTab:Section({ Title = "✨ Utilities" })
    miscTab:Toggle({ Title = "Optimize FPS", Value = PotatoBoostEnabled, Callback = function(state) PotatoBoostEnabled = state; pcall(function() togglePotatoGraphics(state) end) end })
    miscTab:Toggle({ Title = "Skip Crates", Value = SkipCratesEnabled, Callback = function(state) SkipCratesEnabled = state end })
    miscTab:Toggle({ Title = "Auto Pickup", Value = AutoPickupEnabled, Callback = function(state) AutoPickupEnabled = state end })
    miscTab:Slider({ Title = "Pickup Radius", Value = { Min = 20, Max = 500, Default = AutoPickupRadius }, Step = 5, Callback = function(value) AutoPickupRadius = value end })
    miscTab:Toggle({ Title = "Auto Interact", Value = AutoInteractEnabled, Callback = function(state) AutoInteractEnabled = state end })
    miscTab:Toggle({ Title = "Floating TP Panel", Value = false, Callback = function(state) pcall(function() FloatingSnapGui.Enabled = state end) end })
    miscTab:Toggle({ Title = "Ghost Astral Panel", Value = false, Callback = function(state) pcall(function() AstralProjectionGui.Enabled = state end) end })

    configTab:Section({ Title = "⚙️ Configuration" })
    configTab:Paragraph({ Title = "Game", Desc = "POTENT HUB" })
    configTab:Paragraph({ Title = "Place ID", Desc = tostring(game.PlaceId) })
    configTab:Button({ Title = "Save Configuration", Callback = function()
        local ok = false
        pcall(function() ok = SaveConfigurationSafe() end)
        WindUI:Notify({ Title = "POTENT HUB", Content = ok and "Configuration saved." or "Could not save configuration.", Duration = 3 })
    end })
    configTab:Button({ Title = "Copy Discord Link", Callback = function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/tH4j9wbArW")
            elseif toclipboard then toclipboard("https://discord.gg/tH4j9wbArW") end
        end)
        WindUI:Notify({ Title = "POTENT HUB", Content = "Discord link: https://discord.gg/tH4j9wbArW", Duration = 4 })
    end })
end

OpenMainHub()
end

-- ============================================================
-- ========== EJECUCIÓN PRINCIPAL ==========
-- ============================================================
if not isSupportedCurrentGame() then
    print("❌ This game is not supported yet. PlaceId: " .. tostring(game.PlaceId)
        .. " | GameId: " .. tostring(game.GameId))
    showUnsupportedScreen()
    return
end

local function launchGame()
	if game.PlaceId == 114697347887839 or game.PlaceId == 72858062353423 then
		runSpeedMonkeyEscape()
	elseif game.PlaceId == 142823291 then
		runMM2()
	elseif game.PlaceId == 77813828595591 then
		runKittenFarm()
	elseif game.PlaceId == 118941584817777 or game.PlaceId == 93411036959889 then
		runSpeedKeyboardEscape()
	elseif game.PlaceId == ONETAP_PLACE_ID then
		runOneTap()
	elseif isBlockSpinExperience() then
		runChinoinfierno()
	end
end

launchGame()

end -- runHub

-- ============================================================
-- POTENT HUB - KEY SYSTEM
-- Each Roblox account receives its own 24-hour access window.
-- Note: local executor file storage is convenience, not tamper-proof security.
-- ============================================================
local KEY_SYSTEM_KEY = "POTENT-ACCESS-7K9Q-2026"
local KEY_DISCORD_URL = "https://discord.gg/tH4j9wbArW"
local KEY_DURATION = 24 * 60 * 60
local keyPlayers = game:GetService("Players")
local keyCoreGui = game:GetService("CoreGui")
local keyPlayer = keyPlayers.LocalPlayer
local keyParent = keyCoreGui
if typeof(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then keyParent = hui end
end

local function expiryFileName()
    local userId = keyPlayer and keyPlayer.UserId or 0
    return "potent_hub_key_expiry_" .. tostring(userId) .. ".txt"
end

local function readExpiry()
    local filename = expiryFileName()
    if type(isfile) == "function" and type(readfile) == "function" then
        local ok, value = pcall(function()
            if isfile(filename) then return tonumber(readfile(filename)) end
        end)
        if ok and value then return value end
    end
    if shared and type(shared.PotentHubKeyExpiry) == "number" then
        return shared.PotentHubKeyExpiry
    end
    return 0
end

local function saveExpiry(expiry)
    if shared then shared.PotentHubKeyExpiry = expiry end
    local filename = expiryFileName()
    if type(writefile) == "function" then
        pcall(function() writefile(filename, tostring(expiry)) end)
    end
end

-- If this account already verified within the last 24 hours, open the hub directly.
if readExpiry() > os.time() then
    runHub()
    return
end

local oldKeyGui = keyParent:FindFirstChild("PotentHubKeySystem")
if oldKeyGui then oldKeyGui:Destroy() end

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "PotentHubKeySystem"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
keyGui.Parent = keyParent

local keyFrame = Instance.new("Frame")
keyFrame.Name = "Main"
keyFrame.Size = UDim2.new(0, 360, 0, 300)
keyFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
keyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = keyGui
local keyFrameCorner = Instance.new("UICorner")
keyFrameCorner.CornerRadius = UDim.new(0, 14)
keyFrameCorner.Parent = keyFrame
local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(168, 85, 247)
keyStroke.Thickness = 1.5
keyStroke.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, -24, 0, 38)
keyTitle.Position = UDim2.new(0, 12, 0, 12)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "⚡ POTENT HUB"
keyTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 23
keyTitle.Parent = keyFrame

local keySubtitle = Instance.new("TextLabel")
keySubtitle.Size = UDim2.new(1, -28, 0, 28)
keySubtitle.Position = UDim2.new(0, 14, 0, 50)
keySubtitle.BackgroundTransparency = 1
keySubtitle.Text = "Enter your access key to continue"
keySubtitle.TextColor3 = Color3.fromRGB(205, 205, 215)
keySubtitle.Font = Enum.Font.Gotham
keySubtitle.TextSize = 13
keySubtitle.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Name = "KeyInput"
keyBox.Size = UDim2.new(1, -36, 0, 42)
keyBox.Position = UDim2.new(0, 18, 0, 84)
keyBox.BackgroundColor3 = Color3.fromRGB(29, 29, 38)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Enter POTENT key..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 145)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.Parent = keyFrame
local keyBoxCorner = Instance.new("UICorner")
keyBoxCorner.CornerRadius = UDim.new(0, 8)
keyBoxCorner.Parent = keyBox

local keyButton = Instance.new("TextButton")
keyButton.Name = "VerifyKey"
keyButton.Size = UDim2.new(1, -36, 0, 40)
keyButton.Position = UDim2.new(0, 18, 0, 136)
keyButton.BackgroundColor3 = Color3.fromRGB(119, 70, 220)
keyButton.BorderSizePixel = 0
keyButton.Text = "VERIFY KEY"
keyButton.TextColor3 = Color3.new(1, 1, 1)
keyButton.Font = Enum.Font.GothamBold
keyButton.TextSize = 14
keyButton.Parent = keyFrame
local keyButtonCorner = Instance.new("UICorner")
keyButtonCorner.CornerRadius = UDim.new(0, 8)
keyButtonCorner.Parent = keyButton

local discordKeyButton = Instance.new("TextButton")
discordKeyButton.Name = "GetKeyDiscord"
discordKeyButton.Size = UDim2.new(1, -36, 0, 40)
discordKeyButton.Position = UDim2.new(0, 18, 0, 184)
discordKeyButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordKeyButton.BorderSizePixel = 0
discordKeyButton.Text = "GET KEY ON DISCORD"
discordKeyButton.TextColor3 = Color3.new(1, 1, 1)
discordKeyButton.Font = Enum.Font.GothamBold
discordKeyButton.TextSize = 13
discordKeyButton.Parent = keyFrame
local discordKeyCorner = Instance.new("UICorner")
discordKeyCorner.CornerRadius = UDim.new(0, 8)
discordKeyCorner.Parent = discordKeyButton

local keyStatus
discordKeyButton.MouseButton1Click:Connect(function()
    local copied = false
    local clipboard = setclipboard or toclipboard
    if type(clipboard) == "function" then
        copied = pcall(clipboard, KEY_DISCORD_URL)
    end
    if copied then
        keyStatus.Text = "✅ Discord link copied!"
        keyStatus.TextColor3 = Color3.fromRGB(70, 220, 130)
    else
        keyStatus.Text = "Copy unavailable — link: discord.gg/tH4j9wbArW"
        keyStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
    end
end)

keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -24, 0, 28)
keyStatus.Position = UDim2.new(0, 12, 0, 234)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = "🔒 Access locked · Key lasts 24 hours"
keyStatus.TextColor3 = Color3.fromRGB(220, 180, 80)
keyStatus.Font = Enum.Font.GothamBold
keyStatus.TextSize = 11
keyStatus.TextWrapped = true
keyStatus.Parent = keyFrame

local keyBusy = false
local function verifyPotentKey()
    if keyBusy then return end
    if keyBox.Text == KEY_SYSTEM_KEY then
        keyBusy = true
        saveExpiry(os.time() + KEY_DURATION)
        keyStatus.Text = "✅ KEY ACCEPTED — VALID FOR 24 HOURS"
        keyStatus.TextColor3 = Color3.fromRGB(70, 220, 130)
        keyButton.Text = "ACCESS GRANTED"
        task.wait(0.35)
        keyGui:Destroy()
        runHub()
    else
        keyStatus.Text = "❌ Invalid key. Try again."
        keyStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        keyBox.Text = ""
    end
end
keyButton.MouseButton1Click:Connect(verifyPotentKey)
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then verifyPotentKey() end
end)
