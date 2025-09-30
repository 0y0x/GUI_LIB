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

		-- Get Knit & SprintController (only once)
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

			-- Persistent loop
			task.spawn(function()
				while true do
					if sprintEnabled and SprintController then
						SprintController:startSprinting()
					elseif not sprintEnabled and SprintController then
						SprintController:stopSprinting()
					end
					task.wait(0.1)
				end
			end)

			-- Re-setup on respawn
			game.Players.LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.1)
				SetupController()
			end)
		end
	end
})





-- Autoclicker Module
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local AutoClicker = {}
local Mode = { Value = "Tool" } -- Default mode
local CPS = { GetRandomValue = function() return math.random(20, 25) end } -- Default CPS

AutoClicker = apex.categories.combat:CreateModule({
	Name = "AutoClicker",
	Callback = function(state)
		if state then
			task.spawn(function()
				while state do
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
							-- Left click logic if needed
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

apex.categories.blatant:CreateModule({
	Name = "AntiVoid",
	Callback = function(state)
		local platform
		local countdownLabel
		local rgbBar
		local backgroundBar
		local TextStroke
		local timer = 2.5
		local touchingPlate = false
		local lastTouchedObject = nil
		local updateConnection

		local function createPlatform()
			if platform then platform:Destroy() end

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

		local function createTimerUI()
			if countdownLabel then return end

			-- Timer text
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

			-- Background bar
			backgroundBar = Instance.new("Frame")
			backgroundBar.Size = UDim2.new(1, 0, 1, 0)
			backgroundBar.AnchorPoint = Vector2.new(0.5, 0)
			backgroundBar.Position = UDim2.new(0.5, 0, 1, 5)
			backgroundBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			backgroundBar.BorderSizePixel = 0
			backgroundBar.Visible = false
			backgroundBar.Parent = countdownLabel
			backgroundBar.Transparency = 0.5

			-- RGB bar
			rgbBar = Instance.new("Frame")
			rgbBar.Size = UDim2.new(1, 0, 1, 0)
			rgbBar.AnchorPoint = Vector2.new(0, 0) -- left side anchor so it shrinks rightwards
			rgbBar.Position = UDim2.new(0, 0, 0, 0)
			rgbBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			rgbBar.BorderSizePixel = 0
			rgbBar.Visible = false
			rgbBar.Parent = backgroundBar
		end

		local function resetTimer()
			timer = 2.5
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
				LocalPlayer.Character.Humanoid.JumpPower = 150

				-- Shrink horizontally left → right
				rgbBar.Size = UDim2.new(timer / 5 * 2, 0, 1, 0)

				-- RGB cycling
				local t = tick() % 5
				rgbBar.BackgroundColor3 = Color3.fromHSV(t / 5, 1, 1)
			else
				if countdownLabel then countdownLabel.Visible = false end
				if backgroundBar then backgroundBar.Visible = false end
				if rgbBar then rgbBar.Visible = false end
				LocalPlayer.Character.Humanoid.JumpPower = 50
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

		if state == true then
			createPlatform()
			createTimerUI()
			updateConnection = RunService.RenderStepped:Connect(function()
				trackPlatformPosition()
				updateTimer()
			end)
		else
			if updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
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
})

apex.categories.blatant:CreateModule({
	Name = "Speed",
	Callback = function(state)
		if state == true then
			LocalPlayer.Character.Humanoid.WalkSpeed = 23
		else
			LocalPlayer.Character.Humanoid.WalkSpeed = 20
		end
	end
})

apex.categories.world:CreateModule({
	Name = "Gravity",
	Callback = function(state)
		if state == true then
			workspace.Gravity = 75
		else
			workspace.Gravity = 196.2
		end
	end
})

apex.categories.render:CreateModule({
	Name = "ESP",
	Callback = function(state)
		--// Services
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera
		local RunService = game:GetService("RunService")

		--// ESP Settings
		local BoxColor = Color3.fromRGB(0, 255, 0)
		local BoxThickness = 1.5
		local BoxTransparency = 1

		-- Store connections + boxes for cleanup
		local connections = {}
		local boxes = {}

		local function removeESP()
			for _, box in pairs(boxes) do
				if box then
					box:Remove()
				end
			end
			boxes = {}

			for _, conn in pairs(connections) do
				conn:Disconnect()
			end
			connections = {}
		end

		if state then
			-- Function to make a box for a player
			local function createBox(player)
				if player == LocalPlayer then return end
				local box = Drawing.new("Square")
				box.Color = BoxColor
				box.Thickness = BoxThickness
				box.Filled = false
				box.Transparency = BoxTransparency
				boxes[player] = box

				local conn = RunService.RenderStepped:Connect(function()
					if state and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
						local rootPart = player.Character.HumanoidRootPart
						local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

						if onScreen then
							local scale = (Camera.CFrame.Position - rootPart.Position).Magnitude
							local size = math.clamp(3000 / scale, 2, 300)
							box.Size = Vector2.new(size, size * 1.5)
							box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
							box.Visible = true
						else
							box.Visible = false
						end
					else
						box.Visible = false
					end
				end)

				table.insert(connections, conn)
			end

			-- Apply ESP to all current + new players
			for _, player in pairs(Players:GetPlayers()) do
				createBox(player)
			end

			local playerAddedConn = Players.PlayerAdded:Connect(function(player)
				createBox(player)
			end)
			table.insert(connections, playerAddedConn)

			local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
				if boxes[player] then
					boxes[player]:Remove()
					boxes[player] = nil
				end
			end)
			table.insert(connections, playerRemovingConn)

		else
			removeESP()
		end
	end
})

apex.categories.render:CreateModule({
	Name = "LineESP",
	Callback = function(state)
		--// Services
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera

		--// Line storage
		local lines = {}
		local conn

		-- Clear old lines
		local function clearLines()
			for _, line in ipairs(lines) do
				if line and line.Remove then
					line:Remove()
				end
			end
			table.clear(lines)
		end

		-- Drawing loop
		local function drawLines()
			conn = RunService.RenderStepped:Connect(function()
				clearLines()

				local myChar = LocalPlayer.Character
				local myHead = myChar and myChar:FindFirstChild("Head")
				if not myHead then return end

				local headScreenPos, onScreenHead = Camera:WorldToViewportPoint(myHead.Position)

				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local enemyHRP = player.Character.HumanoidRootPart
						local enemyScreenPos, enemyOnScreen = Camera:WorldToViewportPoint(enemyHRP.Position)

						if onScreenHead and enemyOnScreen then
							local line = Drawing.new("Line")
							line.From = Vector2.new(headScreenPos.X, headScreenPos.Y)
							line.To = Vector2.new(enemyScreenPos.X, enemyScreenPos.Y)
							line.Color = Color3.fromRGB(22, 144, 197)
							line.Thickness = 2
							line.Transparency = 1
							line.Visible = true
							table.insert(lines, line)
						end
					end
				end
			end)
		end

		-- Toggle ON
		if state == true then
			drawLines()
		else
			-- Toggle OFF
			if conn then
				conn:Disconnect()
				conn = nil
			end
			clearLines()
		end
	end
})
