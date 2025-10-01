-- Apex UI + Modules Combined Script

local gui_lib = {}
gui_lib.categories = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Container for categories
local CategoryHolderParent = Instance.new("Frame")
CategoryHolderParent.Name = "CategoryHolderParent"
CategoryHolderParent.Size = UDim2.new(0, 1000, 0, 400)
CategoryHolderParent.AnchorPoint = Vector2.new(0.5, 0.5)
CategoryHolderParent.Position = UDim2.new(0.5, 0, 0.2, 0)
CategoryHolderParent.BackgroundTransparency = 1
CategoryHolderParent.Parent = ScreenGui

-- UIListLayout for categories
local CategoryLayout = Instance.new("UIListLayout")
CategoryLayout.FillDirection = Enum.FillDirection.Horizontal
CategoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
CategoryLayout.Padding = UDim.new(0, 20)
CategoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CategoryLayout.Parent = CategoryHolderParent

-- Function to create a category
local function CreateCategory(name)
	local CategoryHolder = Instance.new("Frame")
	CategoryHolder.Name = name .. "Holder"
	CategoryHolder.Size = UDim2.new(0, 180, 1.5, 0)
	CategoryHolder.BackgroundTransparency = 1
	CategoryHolder.Parent = CategoryHolderParent
	CategoryHolder.Active = true

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, 0, 0, 30)
	Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.SourceSansBold
	Title.TextSize = 18
	Title.Text = name
	Title.Parent = CategoryHolder

	-- CategoryFrame holds the modules
	local CategoryFrame = Instance.new("Frame")
	CategoryFrame.Size = UDim2.new(1, 0, 1, -30)
	CategoryFrame.Position = UDim2.new(0, 0, 0, 30)
	CategoryFrame.BackgroundTransparency = 1
	CategoryFrame.Parent = CategoryHolder

	-- Right‑click toggle visibility for modules only
	Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CategoryFrame.Visible = not CategoryFrame.Visible
		end
	end)

	local ModuleHolder = Instance.new("Frame")
	ModuleHolder.Name = "Modules"
	ModuleHolder.Size = UDim2.new(1, 0, 1, 0)
	ModuleHolder.BackgroundTransparency = 1
	ModuleHolder.Parent = CategoryFrame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Padding = UDim.new(0, 0)
	ListLayout.Parent = ModuleHolder

	return {
		CreateModule = function(_, properties)
			local Button = Instance.new("TextButton")
			Button.Name = properties.Name or "Module"
			Button.Text = properties.Name or "Module"
			Button.Size = UDim2.new(1, 0, 0, 25)
			Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			Button.Font = Enum.Font.SourceSans
			Button.TextSize = 16
			Button.Parent = ModuleHolder

			-- Toggle behavior
			local enabled = false
			Button.MouseButton1Click:Connect(function()
				enabled = not enabled
				if enabled then
					Button.BackgroundColor3 = Color3.fromRGB(0, 100, 200) -- Blue when ON
				else
					Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Dark gray when OFF
				end
				if properties.Callback then
					properties.Callback(enabled)
				end
			end)
		end
	}
end

-- Register categories
for _, catName in ipairs({"Combat", "Blatant", "Render", "Utility", "World"}) do
	gui_lib.categories[string.lower(catName)] = CreateCategory(catName)
end


local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleUI"
ToggleButton.Size = UDim2.new(0, 45, 0, 45) -- bigger so easy to tap
ToggleButton.AnchorPoint = Vector2.new(0, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundTransparency = 1 -- make background invisible
ToggleButton.Image = "rbxassetid://17679728753"
ToggleButton.Parent = ScreenGui
ToggleButton.Active = true
ToggleButton.Draggable = true

local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(0, 5)
round.Parent = ToggleButton

-- Toggle logic
local uiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
	uiVisible = not uiVisible
	CategoryHolderParent.Visible = uiVisible
end)




local apex = gui_lib





--GUI library
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--main GUI





-- Sprint Module
local sprintEnabled = false
local SprintController

apex.categories.combat:CreateModule({
	Name = "Sprint",
	Callback = function(state)
		sprintEnabled = state

		-- Get Knit & SprintController once
		if not SprintController then
			local function SetupController()
				local Knit
				repeat
					pcall(function()
						Knit = debug.getupvalue(require(game.Players.LocalPlayer.PlayerScripts.TS.knit).setup, 9)
					end)
					task.wait()
				until Knit and Knit.Controllers and Knit.Controllers.SprintController
				SprintController = Knit.Controllers.SprintController
			end
			task.spawn(SetupController)

			-- Re-setup on respawn
			game.Players.LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.1)
				SetupController()
			end)
		end

		-- Start or stop sprinting
		if SprintController then
			if sprintEnabled then
				task.spawn(function()
					while sprintEnabled and SprintController do
						SprintController:startSprinting()
						task.wait(0.1)
					end
				end)
			else
				SprintController:stopSprinting()
			end
		end
	end
})






-- Autoclicker Module
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local AutoClickerEnabled = false
local Mode = { Value = "Tool" } -- Default mode
local CPS = { GetRandomValue = function() return math.random(99999, 99999) end } -- Default CPS

AutoClicker = apex.categories.combat:CreateModule({
	Name = "AutoClicker",
	Callback = function(state)
		AutoClickerEnabled = state

		if AutoClickerEnabled then
			task.spawn(function()
				while AutoClickerEnabled do
					if Mode.Value == "Tool" then
						local character = LocalPlayer.Character
						if character then
							local tool = character:FindFirstChildOfClass("Tool")
							if tool and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
								tool:Activate()
							end
						end
					else
						if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							mouse1click()
						elseif UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
							mouse2click()
						end
					end

					task.wait(1 / CPS.GetRandomValue())
				end
			end)
		end
	end
})



-- Zoom Unlocker Module
apex.categories.utility:CreateModule({
	Name = "ZoomUnlocker",
	Callback = function(state)
		local localp = game.Players.LocalPlayer
		if state then
			localp.CameraMaxZoomDistance = 99999999
		else
			localp.CameraMaxZoomDistance = 14
		end
	end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create health label
local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(0, 150, 0, 50)
healthLabel.AnchorPoint = Vector2.new(0.5, 1)
healthLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
healthLabel.BackgroundTransparency = 0.5
healthLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
healthLabel.TextColor3 = Color3.fromRGB(46, 255, 23)
healthLabel.Font = Enum.Font.SourceSansBold
healthLabel.TextSize = 20
healthLabel.Text = "Health: 100 ♥️"
healthLabel.Parent = LocalPlayer.PlayerGui:WaitForChild("ApexUI")
healthLabel.Visible = false

-- Keep a single update loop
local updateConnection

apex.categories.render:CreateModule({
	Name = "Health",
	Callback = function(state)
		healthLabel.Visible = state

		if state then
			-- Start updating health
			if not updateConnection then
				updateConnection = RunService.RenderStepped:Connect(function()
					local char = LocalPlayer.Character
					local humanoid = char and char:FindFirstChildOfClass("Humanoid")
					if humanoid then
						healthLabel.Text = "Health: "..math.floor(humanoid.Health) .. " ♥️"
					end
				end)
			end
		else
			-- Stop updating health when disabled
			if updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AntiVoidEnabled = false

apex.categories.blatant:CreateModule({
	Name = "AntiVoid",
	Callback = function(state)
		AntiVoidEnabled = state

		local platform
		local countdownLabel
		local rgbBar
		local backgroundBar
		local TextStroke
		local timer = 2.5
		local touchingPlate = false
		local lastTouchedObject = nil

		local function createPlatform()
			if not platform or not platform.Parent then
				platform = Instance.new("Part")
				platform.Size = Vector3.new(100000, 0.1, 100000)
				platform.Anchored = true
				platform.Material = Enum.Material.Ice
				platform.Transparency = 0.9
				platform.Color = Color3.fromRGB(255, 255, 255)
				platform.TopSurface = Enum.SurfaceType.Smooth
				platform.BottomSurface = Enum.SurfaceType.Smooth
				platform.Position = Vector3.new(0, 0, 0)
				platform.Name = "AntiVoidPlatform"
				platform.Parent = workspace
			end
		end

		local function createTimerUI()
			if countdownLabel then return end

			countdownLabel = Instance.new("TextLabel")
			countdownLabel.Size = UDim2.new(0, 250, 0, 20)
			countdownLabel.AnchorPoint = Vector2.new(0.5, 0)
			countdownLabel.Position = UDim2.new(0.5, 0, 0.75, 0)
			countdownLabel.BackgroundTransparency = 1
			countdownLabel.TextScaled = true
			countdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			countdownLabel.Font = Enum.Font.SourceSansBold
			countdownLabel.Text = "2.5s"
			countdownLabel.Visible = false
			countdownLabel.Parent = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ApexUI")

			TextStroke = Instance.new("UIStroke")
			TextStroke.Parent = countdownLabel

			backgroundBar = Instance.new("Frame")
			backgroundBar.Size = UDim2.new(1, 0, 1, 0)
			backgroundBar.AnchorPoint = Vector2.new(0.5, 0)
			backgroundBar.Position = UDim2.new(0.5, 0, 1, 5)
			backgroundBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			backgroundBar.BorderSizePixel = 0
			backgroundBar.Visible = false
			backgroundBar.Parent = countdownLabel
			backgroundBar.Transparency = 0.5

			rgbBar = Instance.new("Frame")
			rgbBar.Size = UDim2.new(1, 0, 1, 0)
			rgbBar.AnchorPoint = Vector2.new(0, 0)
			rgbBar.Position = UDim2.new(0, 0, 0, 0)
			rgbBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			rgbBar.BorderSizePixel = 0
			rgbBar.Visible = false
			rgbBar.Parent = backgroundBar
		end

		local function resetTimer()
			timer = 2.5
		end

		local function setJumpPower(value)
			local char = LocalPlayer.Character
			if not char then return end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid then return end
			humanoid.UseJumpPower = true
			humanoid.JumpPower = value
		end

		local function updateTimer()
			if touchingPlate then
				timer = timer - RunService.RenderStepped:Wait()
				if timer < 0 then timer = 0 end
			end
			if countdownLabel and touchingPlate then
				countdownLabel.Text = string.format("%.1f s", timer)
				countdownLabel.Visible = true
				backgroundBar.Visible = true
				rgbBar.Visible = true
				rgbBar.Size = UDim2.new(timer / 5 * 2, 0, 1, 0)
				local t = tick() % 5
				rgbBar.BackgroundColor3 = Color3.fromHSV(t / 5, 1, 1)
			else
				if countdownLabel then countdownLabel.Visible = false end
				if backgroundBar then backgroundBar.Visible = false end
				if rgbBar then rgbBar.Visible = false end
			end
		end

		local function trackPlatformPosition()
			local character = LocalPlayer.Character
			if not character then return end
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then return end

			local rayOrigin = rootPart.Position
			local rayDirection = Vector3.new(0, -50, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {character, platform}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

			if raycastResult and raycastResult.Instance and raycastResult.Instance.CanCollide then
				local hitObject = raycastResult.Instance
				if hitObject ~= platform then
					lastTouchedObject = hitObject
					resetTimer()
				end

				platform.Position = Vector3.new(0, hitObject.Position.Y - 0.1, 0)
				touchingPlate = false
			else
				touchingPlate = true
			end
		end

		if not apex.AntiVoidLoop then
			apex.AntiVoidLoop = true
			task.spawn(function()
				while true do
					task.wait()
					if AntiVoidEnabled then
						createPlatform()
						createTimerUI()
						trackPlatformPosition()
						updateTimer()
					else
						if platform then
							platform:Destroy()
							platform = nil
						end
						if countdownLabel then
							countdownLabel:Destroy()
							countdownLabel = nil
						end
						if backgroundBar then
							backgroundBar:Destroy()
							backgroundBar = nil
						end
						if rgbBar then
							rgbBar:Destroy()
							rgbBar = nil
						end
					end
				end
			end)
		end
	end
})

local speedEnabled = false

apex.categories.blatant:CreateModule({
	Name = "Speed",
	Callback = function(state)
		speedEnabled = state

		if state then
			task.spawn(function()
				while speedEnabled do
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
						LocalPlayer.Character.Humanoid.WalkSpeed = 23
					end
					task.wait(0.1) -- slight delay so we don't freeze
				end
				-- Reset speed when disabled
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
					LocalPlayer.Character.Humanoid.WalkSpeed = 20
				end
			end)
		else
			speedEnabled = false
		end
	end
})





local gravityenabled = false
apex.categories.world:CreateModule({
	Name = "Gravity",
	Callback = function(state)
		gravityenabled = state

		if state then
			task.spawn(function()
				while gravityenabled do
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
						workspace.Gravity = 75
					end
					task.wait(0.1) -- slight delay so we don't freeze
				end
				-- Reset speed when disabled
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
					workspace.Gravity = 192.8
				end
			end)
		else
			gravityenabled = false
		end
	end
})


apex.categories.render:CreateModule({
	Name = "LineESP",
	Callback = function(state)
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera

		local lines = {}
		local running = false

		local function clearLines()
			for _, line in ipairs(lines) do
				if line and line.Remove then
					line:Remove()
				end
			end
			table.clear(lines)
		end

		local function drawLines()
			local viewportSize = Camera.ViewportSize
			local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

			clearLines()

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local enemyHRP = player.Character.HumanoidRootPart
					local enemyScreenPos, enemyOnScreen = Camera:WorldToViewportPoint(enemyHRP.Position)

					if enemyOnScreen then
						local line = Drawing.new("Line")
						line.From = screenCenter
						line.To = Vector2.new(enemyScreenPos.X, enemyScreenPos.Y)
						line.Color = Color3.fromRGB(22, 144, 197)
						line.Thickness = 2
						line.Transparency = 1
						line.Visible = true
						table.insert(lines, line)
					end
				end
			end
		end

		if state then
			running = true
			spawn(function()
				while running do
					drawLines()
					RunService.RenderStepped:Wait()
				end
			end)
		else
			running = false
			clearLines()
		end
	end
})



local SpiderEnabled = false

apex.categories.blatant:CreateModule({
	Name = "Spider",
	Callback = function(state)
		-- Services
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local LocalPlayer = Players.LocalPlayer

		SpiderEnabled = state

		-- Main loop (runs once)
		if not apex.SpiderLoop then
			apex.SpiderLoop = true
			task.spawn(function()
				while apex.SpiderLoop do
					task.wait()

					if SpiderEnabled then
						local char = LocalPlayer.Character
						local humanoid = char and char:FindFirstChildOfClass("Humanoid")
						local root = char and char:FindFirstChild("HumanoidRootPart")
						if not (char and humanoid and root) then continue end

						-- Raycast forward from HumanoidRootPart
						local params = RaycastParams.new()
						params.FilterDescendantsInstances = {char}
						params.FilterType = Enum.RaycastFilterType.Blacklist

						local result = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, params)

						-- If walking into a wall, push upwards
						if result and humanoid.MoveDirection.Magnitude > 0 then
							root.Velocity = Vector3.new(root.Velocity.X, 40, root.Velocity.Z)
						end
					end
				end
			end)
		end
	end
})



apex.categories.render:CreateModule({
	Name = "ESP",
	Callback = function(state)
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera

		local connections = {}
		local boxes = {}

		local function clearESP()
			for _, boxData in pairs(boxes) do
				if boxData.Box then boxData.Box:Remove() end
				if boxData.Outline then boxData.Outline:Remove() end
			end
			table.clear(boxes)
			for _, conn in pairs(connections) do
				conn:Disconnect()
			end
			table.clear(connections)
		end

		local function addESP(player)
			if boxes[player] then return end -- avoid duplicates

			local outline = Drawing.new("Square")
			outline.Visible = false
			outline.Color = Color3.new(0, 0, 0)
			outline.Thickness = 2
			outline.Transparency = 1
			outline.Filled = false

			local box = Drawing.new("Square")
			box.Visible = false
			box.Color = Color3.new(1, 1, 1)
			box.Thickness = 1
			box.Transparency = 1
			box.Filled = false

			boxes[player] = {Box = box, Outline = outline}

			local conn = RunService.RenderStepped:Connect(function()
				if not player.Character then
					outline.Visible = false
					box.Visible = false
					return
				end

				local humanoid = player.Character:FindFirstChild("Humanoid")
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				local head = player.Character:FindFirstChild("Head")
				if not humanoid or not root or not head or humanoid.Health <= 0 then
					outline.Visible = false
					box.Visible = false
					return
				end

				local headPos, hOnScreen = Camera:WorldToViewportPoint(head.Position)
				local rootPos, rOnScreen = Camera:WorldToViewportPoint(root.Position)
				local legPos, lOnScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

				if hOnScreen and rOnScreen and lOnScreen and rootPos.Z > 0 then
					local height = headPos.Y - legPos.Y
					local width = height / 2

					outline.Size = Vector2.new(width, height)
					outline.Position = Vector2.new(rootPos.X - width / 2, legPos.Y)
					outline.Visible = true

					box.Size = Vector2.new(width, height)
					box.Position = Vector2.new(rootPos.X - width / 2, legPos.Y)
					box.Visible = true

					if player.TeamColor == LocalPlayer.TeamColor then
						box.Color = Color3.fromRGB(0, 255, 0) -- green teammates
					else
						box.Color = Color3.fromRGB(255, 0, 0) -- red enemies
					end
				else
					outline.Visible = false
					box.Visible = false
				end
			end)

			table.insert(connections, conn)
		end

		if state then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					addESP(p)
				end
			end

			table.insert(connections, Players.PlayerAdded:Connect(addESP))
			table.insert(connections, Players.PlayerRemoving:Connect(function(p)
				if boxes[p] then
					if boxes[p].Box then boxes[p].Box:Remove() end
					if boxes[p].Outline then boxes[p].Outline:Remove() end
					boxes[p] = nil
				end
			end))
		else
			clearESP()
		end
	end
})



local NoFallEnabled = false
local NoFallLoopActive = false

apex.categories.utility:CreateModule({
	Name = "NoFall",
	Callback = function(state)
		NoFallEnabled = state

		if state and not NoFallLoopActive then
			NoFallLoopActive = true

			task.spawn(function()
				while NoFallEnabled do
					task.wait()

					local char = game.Players.LocalPlayer.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					if char and root then
						if root.Velocity.Y < -5 then
							local params = RaycastParams.new()
							params.FilterDescendantsInstances = {char}
							params.FilterType = Enum.RaycastFilterType.Blacklist

							local result = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), params)
							if result then
								local fallDist = (root.Position.Y - result.Position.Y)

								if fallDist >= 1 then
									root.Velocity = Vector3.new(root.Velocity.X, -60, root.Velocity.Z) -- KEEP original value
								end
							end
						end
					end
				end

				NoFallLoopActive = false -- stops loop when turned off
			end)
		elseif not state then
			NoFallEnabled = false
		end
	end
})



local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local InfiniteJumpEnabled = false

apex.categories.blatant:CreateModule({
	Name = "InfiniteJump",
	Callback = function(state)
		InfiniteJumpEnabled = state
	end
})

-- Connect once outside the toggle
if not apex.InfiniteJumpConnected then
	apex.InfiniteJumpConnected = true

	UserInputService.JumpRequest:Connect(function()
		if InfiniteJumpEnabled then
			local char = LocalPlayer.Character
			if not char then return end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end


apex.categories.world:CreateModule({
	Name = "SafeWalk",
	Callback = function(state)
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera

		if not apex._SafeWalkModule then
			apex._SafeWalkModule = {}
			apex._SafeWalkOldMove = nil
		end

		if state then
			-- Enable SafeWalk
			if not apex._SafeWalkModule.enabled then
				local suc, module = pcall(function()
					return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")).controls
				end)

				if suc and module then
					apex._SafeWalkOldMove = module.moveFunction

					module.moveFunction = function(self, vec, face)
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							local rayCheck = RaycastParams.new()
							rayCheck.RespectCanCollide = true
							rayCheck.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

							local root = LocalPlayer.Character.HumanoidRootPart
							local movedir = root.Position + vec
							local ray = workspace:Raycast(movedir, Vector3.new(0, -15, 0), rayCheck)

							if not ray then
								local check = workspace:Blockcast(root.CFrame, Vector3.new(3, 1, 3), Vector3.new(0, -(LocalPlayer.Character.Humanoid.HipHeight + 1), 0), rayCheck)
								if check then
									vec = (check.Instance:GetClosestPointOnSurface(movedir) - root.Position) * Vector3.new(1, 0, 1)
								end
							end
						end

						return apex._SafeWalkOldMove(self, vec, face)
					end

					apex._SafeWalkModule.enabled = true
				end
			end
		else
			-- Disable SafeWalk
			if apex._SafeWalkModule.enabled and apex._SafeWalkOldMove then
				local suc, module = pcall(function()
					return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")).controls
				end)

				if suc and module then
					module.moveFunction = apex._SafeWalkOldMove
				end

				apex._SafeWalkModule.enabled = false
				apex._SafeWalkOldMove = nil
			end
		end
	end
})



apex.categories.world:CreateModule({
	Name = "Xray",
	Callback = function(state)
		local Workspace = game:GetService("Workspace")

		if not apex._XrayState then
			apex._XrayState = false
			apex._XrayModifiedParts = {}
		end

		apex._XrayState = state

		if apex._XrayState then
			-- Apply to all current parts immediately
			for _, part in ipairs(Workspace:GetDescendants()) do
				if part:IsA("BasePart") and not apex._XrayModifiedParts[part] then
					apex._XrayModifiedParts[part] = part.LocalTransparencyModifier
					part.LocalTransparencyModifier = 0.5
				end
			end
		else
			-- Restore transparency when turning off
			for part, original in pairs(apex._XrayModifiedParts) do
				if part and part:IsA("BasePart") then
					part.LocalTransparencyModifier = original or 0
				end
			end
			table.clear(apex._XrayModifiedParts)
		end

		-- Frame loop to apply effect to new parts when active
		if not apex._XrayLoop then
			apex._XrayLoop = true
			task.spawn(function()
				while true do
					task.wait(0.1) -- check every frame / adjust speed

					if apex._XrayState then
						for _, part in ipairs(Workspace:GetDescendants()) do
							if part:IsA("BasePart") and not apex._XrayModifiedParts[part] then
								apex._XrayModifiedParts[part] = part.LocalTransparencyModifier
								part.LocalTransparencyModifier = 0.5
							end
						end
					else
						task.wait() -- skip loop if off
					end
				end
			end)
		end
	end
})

local connections = {}

apex.categories.utility:CreateModule({
	Name = "AntiAFK",
	Callback = function(state)
		if state then
			for _, v in ipairs(getconnections(game.Players.LocalPlayer.Idled)) do
				table.insert(connections, v)
				v:Disable()
			end
		else
			for _, v in ipairs(connections) do
				v:Enable()
			end
			table.clear(connections)
		end
	end
})

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local AutoLockEnabled = false

local function getNearestPlayer(maxDist)
	local nearest, dist = nil, maxDist
	local myChar = LocalPlayer.Character
	local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local mag = (myHRP.Position - hrp.Position).Magnitude
			if mag < dist then
				nearest, dist = player, mag
			end
		end
	end
	return nearest
end

apex.categories.combat:CreateModule({
	Name = "AutoLock",
	Callback = function(state)
		AutoLockEnabled = state

		-- Only start loop once per enable
		if AutoLockEnabled and not apex._AutoLockLoop then
			apex._AutoLockLoop = true
			task.spawn(function()
				while AutoLockEnabled do
					-- safety: ensure character exists
					local char = LocalPlayer.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local humanoid = char and char:FindFirstChildOfClass("Humanoid")
					if root and humanoid and humanoid.Health > 0 then
						local target = getNearestPlayer(20)
						if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
							local targetRoot = target.Character.HumanoidRootPart

							-- Face target (only yaw)
							local dir = (targetRoot.Position - root.Position)
							local look = Vector3.new(dir.X, 0, dir.Z)
							if look.Magnitude > 0 then
								root.CFrame = CFrame.new(root.Position, root.Position + look.Unit)
							end

							-- Spam left click via VirtualUser (mobile-safe)
							-- do 5 clicks per 0.1s => 50 clicks/sec
							for i = 1, 5 do
								-- Use a neutral screen position (0,0) so no cursor movement
								VirtualUser:Button1Down(Vector2.new(0, 0))
								VirtualUser:Button1Up(Vector2.new(0, 0))
							end
						end
					end

					task.wait(0.1)
				end

				-- loop finished; clear loop flag so it can be started again later
				apex._AutoLockLoop = nil
			end)
		end
	end
})

