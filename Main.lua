local gui_lib = {}
gui_lib.categories = {}


local mobil = Enum.Platform.IOS or Enum.Platform.Android

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local ContextActionService = game:GetService("ContextActionService")
local VirtualInputManager = game:GetService("VirtualInputManager")
-- Player variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Camera
local Camera = Workspace.CurrentCamera

-- Input
local Mouse = LocalPlayer:GetMouse()

-- Time & Utility
local tick = tick
local task = task
local math = math
local table = table
local string = string
local Vector3 = Vector3
local CFrame = CFrame
local Color3 = Color3

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApexUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Tooltip label
local tooltipLabel = Instance.new("TextLabel")
tooltipLabel.Name = "TooltipLabel"
tooltipLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tooltipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltipLabel.TextSize = 16
tooltipLabel.Font = Enum.Font.SourceSans
tooltipLabel.BackgroundTransparency = 0.2
tooltipLabel.Visible = false
tooltipLabel.ZIndex = 10
tooltipLabel.TextWrapped = true
tooltipLabel.TextXAlignment = Enum.TextXAlignment.Center
tooltipLabel.TextYAlignment = Enum.TextYAlignment.Center
tooltipLabel.Parent = ScreenGui

local tooltipUICorner = Instance.new("UICorner")
tooltipUICorner.CornerRadius = UDim.new(0, 4)
tooltipUICorner.Parent = tooltipLabel

-- Function to resize tooltip based on text
local function UpdateTooltipSize()
	local textSize = TextService:GetTextSize(
		tooltipLabel.Text,
		tooltipLabel.TextSize,
		tooltipLabel.Font,
		Vector2.new(9999, 9999)
	)
	tooltipLabel.Size = UDim2.fromOffset(textSize.X + 10, textSize.Y + 6)
end

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

	-- Toggle visibility for modules
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
			local roncolor = 45
			local goncolor = 45
			local boncolor = 45
			local Button = Instance.new("TextButton")
			Button.Name = properties.Name or "Module"
			Button.Text = properties.Name or "Module"
			Button.Size = UDim2.new(1, 0, 0, 25)
			Button.BackgroundColor3 = Color3.fromRGB(roncolor, goncolor, boncolor)
			Button.TextColor3 = Color3.fromRGB(255, 255, 255)
			Button.Font = Enum.Font.SourceSans
			Button.TextSize = 16
			Button.Parent = ModuleHolder

			local enabled = false
			local waitingForKey = false
			local boundKey = nil

			-- Shared bind registry
			_G.ApexKeybinds = _G.ApexKeybinds or {}

			-------------------------------------------------------------------
			-- 🧩 Main Button Toggle
			-------------------------------------------------------------------
			Button.MouseButton1Click:Connect(function()
				enabled = not enabled
				Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(45, 45, 45)
				if properties.Callback then
					properties.Callback(enabled)
				end
			end)

			-------------------------------------------------------------------
			-- 💬 Tooltip Hover (unchanged)
			-------------------------------------------------------------------
			local hoverStart
			local hovering = false
			local touchConnection

			local function showTooltip()
				tooltipLabel.Text = properties.Tooltip or "No tooltip set"
				UpdateTooltipSize()
				tooltipLabel.Visible = true
				local mousePos = UserInputService:GetMouseLocation()
				tooltipLabel.Position = UDim2.fromOffset(mousePos.X + 10, mousePos.Y - 35)
			end

			local function hideTooltip()
				hovering = false
				tooltipLabel.Visible = false
				if touchConnection then
					touchConnection:Disconnect()
					touchConnection = nil
				end
			end

			Button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch then
					hoverStart = tick()
					hovering = true
					touchConnection = RunService.Heartbeat:Connect(function()
						if hovering and tick() - hoverStart >= 0.5 then
							showTooltip()
						end
					end)
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					hoverStart = tick()
					hovering = true
					task.spawn(function()
						while hovering and Button:IsDescendantOf(game) do
							if tick() - hoverStart >= 0.5 then
								showTooltip()
								break
							end
							task.wait(0.05)
						end
					end)
				end
			end)

			Button.InputEnded:Connect(function()
				hideTooltip()
			end)

			-------------------------------------------------------------------
			-- 🎮 Keybind System
			-------------------------------------------------------------------
			if properties.Bindable then
				local roncolor, goncolor, boncolor = 35, 35, 35

				local BindButton = Instance.new("TextButton")
				BindButton.Name = "BindButton"
				BindButton.Size = UDim2.new(0, 20, 0.8, 0) -- same size & position
				BindButton.AnchorPoint = Vector2.new(1, 0.5)
				BindButton.Position = UDim2.new(1, -5, 0.5, 0)
				BindButton.BackgroundColor3 = Color3.fromRGB(roncolor, goncolor, boncolor)
				BindButton.TextColor3 = Color3.new(1, 1, 1)
				BindButton.Font = Enum.Font.SourceSans
				BindButton.TextSize = 12
				BindButton.Text = "[...]"
				BindButton.Parent = Button
				BindButton.Transparency = 0.8
				BindButton.TextTransparency = 0.4

				local rounder121 = Instance.new("UICorner")
				rounder121.Parent = BindButton
				rounder121.CornerRadius = UDim.new(0, 3)

				-- Wait for a key press to bind/unbind
				BindButton.MouseButton1Click:Connect(function()
					if waitingForKey then return end
					waitingForKey = true
					BindButton.Text = "Press Key..."

					local conn
					conn = UserInputService.InputBegan:Connect(function(input, gp)
						if gp then return end
						if input.UserInputType == Enum.UserInputType.Keyboard then
							local key = input.KeyCode

							-- If pressing Delete, clear bind
							if key == Enum.KeyCode.Delete then
								boundKey = nil
								_G.ApexKeybinds[properties.Name] = nil
								BindButton.Text = "[...]"
								waitingForKey = false
								conn:Disconnect()
								return
							end

							-- If same key pressed again, unbind it
							if boundKey == key then
								boundKey = nil
								_G.ApexKeybinds[properties.Name] = nil
								BindButton.Text = "[...]"
								waitingForKey = false
								conn:Disconnect()
								return
							end

							-- Assign new key
							boundKey = key
							_G.ApexKeybinds[properties.Name] = key
							BindButton.Text = "[" .. key.Name .. "]"
							waitingForKey = false
							conn:Disconnect()
						end
					end)
				end)

				-- Listen globally for key press
				UserInputService.InputBegan:Connect(function(input, gp)
					if gp then return end
					local key = _G.ApexKeybinds[properties.Name]
					if key and input.KeyCode == key then
						enabled = not enabled
						Button.BackgroundColor3 = enabled and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(45, 45, 45)
						if properties.Callback then
							properties.Callback(enabled)
						end
					end
				end)
			end
		end
	}
end



-- Register categories
for _, catName in ipairs({"Combat", "Blatant", "Render", "Utility", "World"}) do
	gui_lib.categories[string.lower(catName)] = CreateCategory(catName)
end

-- Toggle UI button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleUI"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.AnchorPoint = Vector2.new(0, 0)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundTransparency = 1
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Insert then
		uiVisible = not uiVisible
		CategoryHolderParent.Visible = uiVisible
	end
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


local label = Instance.new('TextLabel')
label.Size = UDim2.fromOffset(100, 20)
label.Position = UDim2.new(0.5, 6, 0.5, 30)
label.BackgroundTransparency = 1
label.AnchorPoint = Vector2.new(0.5, 0)
label.TextSize = 18
label.Font = Enum.Font.Arial
label.Text = ""
label.Visible = false
label.Parent = LocalPlayer.PlayerGui:WaitForChild("ApexUI")

-- Keep a single update loop
local updateConnection

apex.categories.render:CreateModule({
	Name = "Health",
	Callback = function(state)
		label.Visible = state

		if state then
			if not updateConnection then
				updateConnection = RunService.RenderStepped:Connect(function()
					local char = LocalPlayer.Character
					local humanoid = char and char:FindFirstChildOfClass("Humanoid")

					if humanoid and humanoid.Health > 0 then
						local health = humanoid.Health
						local maxHealth = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100
						local ratio = health / maxHealth

						-- Hue goes from 0 (red) to 1/3 (green)
						local hue = ratio * (1/3) 
						label.TextColor3 = Color3.fromHSV(hue, 1, 1)

						label.Text = math.floor(health) .. " ❤️"
					else
						label.Text = "0 ❤️"
						label.TextColor3 = Color3.new(1, 0, 0) -- solid red when dead
					end
				end)
			end
		else
			if updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end,
	Tooltip = "Displays your health",
	Bindable = true
})



apex.categories.blatant:CreateModule({
	Name = "Speed",
	Callback = function(state)
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer

		local function SetSpeed(speed)
			local char = LocalPlayer.Character
			if char and char:FindFirstChildOfClass("Humanoid") then
				char:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
			end
		end

		if state then
			SetSpeed(23)

			-- Keep WalkSpeed locked at 50
			local conn
			conn = game:GetService("RunService").RenderStepped:Connect(function()
				local char = LocalPlayer.Character
				if char and char:FindFirstChildOfClass("Humanoid") then
					if char:FindFirstChildOfClass("Humanoid").WalkSpeed ~= 23 then
						char:FindFirstChildOfClass("Humanoid").WalkSpeed = 23
					end
				end
			end)

			-- Store connection so we can disconnect later
			apex.SpeedConnection = conn
		else
			-- Turn off: remove locking and set speed to 20
			if apex.SpeedConnection then
				apex.SpeedConnection:Disconnect()
				apex.SpeedConnection = nil
			end
			SetSpeed(16)
		end
	end,
	Tooltip = "signifacantly increses speed",
	Bindable = true
})





local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FOVRadius = 200
local ThirdPersonThreshold = 5

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 2
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Visible = false

local SilentAimEnabled = false

-- Helpers
local function isVisible(target)
	local character = target.Character
	if character and character:FindFirstChild("Head") then
		local ray = Ray.new(Camera.CFrame.Position, (character.Head.Position - Camera.CFrame.Position).Unit * 500)
		local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
		return hit and hit:IsDescendantOf(character)
	end
	return false
end

local function getNearestPlayer()
	local nearestPlayer = nil
	local shortestDistance = FOVRadius

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
			local character = player.Character
			local head = character and character:FindFirstChild("Head")

			if head then
				local headPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
				local mousePosition = UserInputService:GetMouseLocation()
				local distanceFromMouse = (Vector2.new(headPosition.X, headPosition.Y) - mousePosition).Magnitude

				if onScreen and distanceFromMouse < shortestDistance and isVisible(player) then
					nearestPlayer = player
					shortestDistance = distanceFromMouse
				end
			end
		end
	end

	return nearestPlayer
end

local function isThirdPerson()
	local character = LocalPlayer.Character
	if character and character:FindFirstChild("Head") then
		local distance = (Camera.CFrame.Position - character.Head.Position).Magnitude
		return distance > ThirdPersonThreshold
	end
	return false
end

local function updateFOVCircle()
	local mousePosition = UserInputService:GetMouseLocation()
	FOVCircle.Position = mousePosition
end

local function camlockAtTarget(target)
	if target and target.Character and target.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
	end
end

local function silentAimAtTarget(target)
	if target and target.Character and target.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
	end
end

-- Main loop
if not apex.SilentAimConnected then
	apex.SilentAimConnected = true

	RunService.RenderStepped:Connect(function()
		if not SilentAimEnabled then
			FOVCircle.Visible = false
			return
		end

		updateFOVCircle()
		local target = getNearestPlayer()

		FOVCircle.Visible = true

		if target then
			if isThirdPerson() then
				camlockAtTarget(target)
			else
				silentAimAtTarget(target)
			end
		end
	end)
end

-- Add to your GUI library
apex.categories.combat:CreateModule({
	Name = "Silent Aim",
	Callback = function(state)
		SilentAimEnabled = state
		FOVCircle.Visible = state
	end,
	Tooltip = "Aims at players when they come in your fov",
	Bindable = true
})

game.Players.LocalPlayer.OnTeleport:Connect(function()
	FOVCircle:Remove()
end)



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
	end,
	Tooltip = "Decreses your gravity",
	Bindable = true
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local beams = {}
local connections = {}

local function ClearBeams()
	for _, beamData in pairs(beams) do
		for _, obj in pairs(beamData) do
			if obj and obj.Destroy then
				obj:Destroy()
			end
		end
	end
	table.clear(beams)

	for _, conn in pairs(connections) do
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
	end
	table.clear(connections)
end

local function CreateTracer(target)
	if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
	if target == LocalPlayer then return end
	if LocalPlayer.Team and target.Team == LocalPlayer.Team then return end

	local hrp = target.Character.HumanoidRootPart
	if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
		and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude > 1200 then
		return -- Skip if target is further than 1200 studs
	end

	local beam = Instance.new("Beam")
	beam.Name = "ESPBeam"
	beam.FaceCamera = true
	beam.Width0 = 0.002  -- Much thinner
	beam.Width1 = 0.002
	beam.Transparency = NumberSequence.new(0)

	-- Use team color, fallback to white if no team
	local teamColor = target.Team and target.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
	beam.Color = ColorSequence.new(teamColor)

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "ScreenAttachment"
	attachment0.Parent = Camera

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "PlayerAttachment"
	attachment1.Parent = hrp

	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Parent = Camera

	beams[target] = { beam = beam, a0 = attachment0, a1 = attachment1 }

	local conn = RunService.RenderStepped:Connect(function()
		if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
			beam.Enabled = false
			return
		end

		local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
		if distance > 1200 then
			beam.Enabled = false
			return
		end

		local viewportSize = Camera.ViewportSize
		local centerScreen = Vector3.new(viewportSize.X / 2, viewportSize.Y / 2, 0)
		local worldPos = Camera:ViewportPointToRay(centerScreen.X, centerScreen.Y).Origin + Camera.CFrame.LookVector * 5
		attachment0.WorldPosition = worldPos
		attachment1.Parent = hrp
		beam.Enabled = true
	end)
	table.insert(connections, conn)
end

local function SetupTracers()
	ClearBeams()
	for _, player in ipairs(Players:GetPlayers()) do
		CreateTracer(player)
	end
end

local function RemoveTracer(target)
	if beams[target] then
		for _, obj in pairs(beams[target]) do
			if obj and obj.Destroy then
				obj:Destroy()
			end
		end
		beams[target] = nil
	end
end

apex.categories.render:CreateModule({
	Name = "ThinTracers",
	Callback = function(state)
		if state then
			SetupTracers()
			table.insert(connections, Players.PlayerAdded:Connect(function(player)
				player.CharacterAdded:Connect(function()
					task.wait(1)
					CreateTracer(player)
				end)
			end))
			table.insert(connections, Players.PlayerRemoving:Connect(RemoveTracer))
		else
			ClearBeams()
		end
	end,
	Tooltip = "Draws very thin tracers to enemies only (max 1200 studs).",
	Bindable = true
})



local SpiderEnabled = false

apex.categories.blatant:CreateModule({
	Name = "Spider",
	Callback = function(state)
		-- Services

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
	end,
	Tooltip = "Climb walls",
	Bindable = true
})



apex.categories.render:CreateModule({
	Name = "ESP",
	Callback = function(state)

		local connections = {}
		local boxes = {}

		local function clearESP()
			for _, boxData in pairs(boxes) do
				if boxData.Box then
					boxData.Box:Remove()
				end
			end
			table.clear(boxes)
			for _, conn in pairs(connections) do
				conn:Disconnect()
			end
			table.clear(connections)
		end

		local function addESP(player)
			if boxes[player] then return end

			local box = Drawing.new("Square")
			box.Visible = false
			box.Thickness = 1
			box.Transparency = 1
			box.Filled = false

			boxes[player] = {Box = box}

			local conn = RunService.RenderStepped:Connect(function()
				if not player.Character then
					box.Visible = false
					return
				end

				local humanoid = player.Character:FindFirstChild("Humanoid")
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				local head = player.Character:FindFirstChild("Head")

				if not humanoid or not root or not head or humanoid.Health <= 0 then
					box.Visible = false
					return
				end

				-- Don't show ESP for teammates
				if LocalPlayer.Team and player.Team == LocalPlayer.Team then
					box.Visible = false
					return
				end

				-- Max distance check (1200 studs)
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
				if distance > 1200 then
					box.Visible = false
					return
				end

				local headPos, hOnScreen = Camera:WorldToViewportPoint(head.Position)
				local rootPos, rOnScreen = Camera:WorldToViewportPoint(root.Position)
				local legPos, lOnScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

				if hOnScreen and rOnScreen and lOnScreen and rootPos.Z > 0 then
					local height = headPos.Y - legPos.Y
					local width = height / 2

					box.Size = Vector2.new(width, height)
					box.Position = Vector2.new(rootPos.X - width / 2, legPos.Y)
					box.Visible = true

					local color
					if player.Team and player.TeamColor then
						color = player.TeamColor.Color
					else
						color = Color3.fromRGB(255, 255, 255) -- fallback white
					end
					box.Color = color
				else
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
				if boxes[p] and boxes[p].Box then
					boxes[p].Box:Remove()
					boxes[p] = nil
				end
			end))
		else
			clearESP()
		end
	end,
	Tooltip = "Draws boxes around enemies through walls (max 1200 studs).",
	Bindable = true
})



local LocalPlayer = Players.LocalPlayer
local InfiniteJumpEnabled = false

apex.categories.blatant:CreateModule({
	Name = "InfiniteJump",
	Callback = function(state)
		InfiniteJumpEnabled = state
	end,
	Tooltip = "Jump Forever",
	Bindable = true
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
	end,
	Tooltip = "See through the world",
	Bindable = true
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
	end,
	Tooltip = "You wont get AFK dissconnects",
	Bindable = true
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
	end,
	Tooltip = "You cant fall off"
})

local AntiVoidEnabled = false

apex.categories.blatant:CreateModule({
	Name = "AntiVoid",
	Tooltip = '(Vape inspired) allows you to walk on the void for 2.5s',
	Bindable = true,
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
	end,
})




apex.categories.utility:CreateModule({
	Name = "FOV",
	Tooltip = "Increases your Field of View to 130 when enabled",
	Bindable = false,
	Callback = (function()
		local RunService = game:GetService("RunService")
		local Workspace = game:GetService("Workspace")

		local Camera = Workspace.CurrentCamera
		local connection = nil
		local enabled = false
		local defaultFOV = 70
		local newFOV = 130

		return function(state)
			if state and not enabled then
				enabled = true

				-- Smoothly lerp to new FOV
				connection = RunService.RenderStepped:Connect(function(dt)
					if Camera then
						Camera.FieldOfView = Camera.FieldOfView + (newFOV - Camera.FieldOfView) * math.clamp(dt * 10, 0, 1)
					end
				end)

			elseif not state and enabled then
				enabled = false

				-- Smoothly return to default FOV
				if connection then
					connection:Disconnect()
					connection = nil
				end

				-- Return smoothly to 70 FOV after disabling
				task.spawn(function()
					while math.abs(Camera.FieldOfView - defaultFOV) > 0.5 do
						Camera.FieldOfView = Camera.FieldOfView + (defaultFOV - Camera.FieldOfView) * 0.2
						task.wait(0.016)
					end
					Camera.FieldOfView = defaultFOV
				end)
			end
		end
	end)()
})

apex.categories.utility:CreateModule({
	Name = 'PlayerLevel',
	Bindable = false,
	Tooltip = 'Sets your player lvl to math.huge',
	Callback = (function()
		local PlayerLevel = {Value = math.huge}
		game.Players.LocalPlayer:SetAttribute("PlayerLevel", PlayerLevel.Value)
	end)
})
--[[
apex.categories.utility:CreateModule1({
	Name = "Panic",
	Bindable = true,
	Tooltip = "Disable all modules and destroy the UI (emergency)",
	Callback = function(state)
		if not state then return end
		if apex._panicMode then return end
		apex._panicMode = true

		-- 1) Disable all registered modules safely
		for _, mod in ipairs(apex._registeredModules or {}) do
			pcall(function()
				if mod and type(mod.Disable) == "function" then
					mod.Disable()
				end
			end)
		end

		-- 2) Disconnect orphan connections registered into apex._moduleConnections
		for _, c in ipairs(apex._moduleConnections or {}) do
			pcall(function()
				if c and type(c.Disconnect) == "function" then
					c:Disconnect()
				elseif c and type(c.disconnect) == "function" then
					c:disconnect()
				end
			end)
		end
		apex._moduleConnections = {}

		-- 3) Clear global keybind registry
		if type(_G) == "table" then
			_G.ApexKeybinds = {}
		end

		-- 4) Disconnect shared update loop(s)
		if updateConnection and type(updateConnection.Disconnect) == "function" then
			pcall(function() updateConnection:Disconnect() end)
			updateConnection = nil
		end

		-- 5) Destroy main UI ScreenGui (ApexUI) safely
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		if playerGui then
			local sg = playerGui:FindFirstChild("ApexUI")
			if sg and sg.Parent then
				pcall(function() sg:Destroy() end)
			end
		end

		-- 6) Attempt to remove any leftover toggle button / references
		if ToggleButton and ToggleButton.Parent then
			pcall(function() ToggleButton:Destroy() end)
		end

		-- 7) Clear registry
		apex._registeredModules = {}
		apex._panicMode = true

		-- Notify player
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = "Panic",
				Text = "All modules disabled and UI removed.",
				Duration = 3
			})
		end)
	end
})
--]]

apex.categories.render:CreateModule({
	Name = "GamingChair",
	Callback = function(state)
		local Players = game:GetService("Players")
		local UserInputService = game:GetService("UserInputService")
		local RunService = game:GetService("RunService")

		local player = Players.LocalPlayer
		local chair, chairArms, chairLegs, chairHighlight, chairanim, rolling, flying
		local trails = {}
		local heartbeatConnection -- store the loop here
		local wheelPositions = {
			Vector3.new(-0.8, -0.55, -0.18),
			Vector3.new(0.1, -0.55, -0.88),
			Vector3.new(0, -0.55, 0.7)
		}

		local function createChair()
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			local root = character:WaitForChild("HumanoidRootPart")

			chair = Instance.new("Part")
			chair.Name = "GamingChair"
			chair.Size = Vector3.new(1,1,1)
			chair.Color = Color3.fromRGB(21, 21, 21)
			chair.Anchored = false
			chair.CanCollide = false
			chair.Material = Enum.Material.SmoothPlastic
			chair.CFrame = root.CFrame * CFrame.new(0,0,0) * CFrame.Angles(0, math.rad(-90), 0)
			chair.Parent = workspace

			local mainMesh = Instance.new("SpecialMesh")
			mainMesh.MeshType = Enum.MeshType.FileMesh
			mainMesh.MeshId = "rbxassetid://12972961089"
			mainMesh.Scale = Vector3.new(2.16, 3.6, 2.3) / Vector3.new(12.37, 20.636, 13.071)
			mainMesh.Parent = chair

			chairHighlight = Instance.new("Highlight")
			chairHighlight.FillTransparency = 1
			chairHighlight.OutlineColor = Color3.fromRGB(0, 255, 0)
			chairHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
			chairHighlight.OutlineTransparency = 0.2
			chairHighlight.Parent = chair

			chairArms = Instance.new("Part")
			chairArms.Size = Vector3.new(1,1,1)
			chairArms.Color = chair.Color
			chairArms.CanCollide = false
			chairArms.Parent = workspace

			local armsMesh = Instance.new("SpecialMesh")
			armsMesh.MeshType = Enum.MeshType.FileMesh
			armsMesh.MeshId = "rbxassetid://12972673898"
			armsMesh.Scale = Vector3.new(1.39, 1.345, 2.75) / Vector3.new(97.13, 136.216, 234.031)
			armsMesh.Parent = chairArms

			chairArms.CFrame = chair.CFrame * CFrame.new(-0.169, -1.129, -0.013)
			local armsWeld = Instance.new("WeldConstraint")
			armsWeld.Part0 = chairArms
			armsWeld.Part1 = chair
			armsWeld.Parent = chairArms

			chairLegs = Instance.new("Part")
			chairLegs.Size = Vector3.new(1,1,1)
			chairLegs.Color = chair.Color
			chairLegs.CanCollide = false
			chairLegs.Parent = workspace

			local legsMesh = Instance.new("SpecialMesh")
			legsMesh.MeshType = Enum.MeshType.FileMesh
			legsMesh.MeshId = "rbxassetid://13003181606"
			legsMesh.Scale = Vector3.new(1.8, 1.2, 1.8) / Vector3.new(10.432, 8.105, 9.488)
			legsMesh.Parent = chairLegs

			chairLegs.CFrame = chair.CFrame * CFrame.new(0.047, -2.1, 0)
			local legsWeld = Instance.new("WeldConstraint")
			legsWeld.Part0 = chairLegs
			legsWeld.Part1 = chair
			legsWeld.Parent = chairLegs

			flying = Instance.new("Sound")
			flying.Parent = chair
			flying.SoundId = "rbxassetid://92065279013467"
			flying.Looped = true

			for _, pos in pairs(wheelPositions) do
				local attach0 = Instance.new("Attachment")
				attach0.Position = pos
				attach0.Parent = chairLegs

				local attach1 = Instance.new("Attachment")
				attach1.Position = pos + Vector3.new(0,0,0.18)
				attach1.Parent = chairLegs

				local trail = Instance.new("Trail")
				trail.Texture = "http://www.roblox.com/asset/?id=13005168530"
				trail.TextureMode = Enum.TextureMode.Static
				trail.Transparency = NumberSequence.new(0.5)
				trail.Color = ColorSequence.new(Color3.new(0.0823529, 0.0823529, 0.0823529))
				trail.Attachment0 = attach0
				trail.Attachment1 = attach1
				trail.Lifetime = 1
				trail.MaxLength = 60
				trail.MinLength = 0.1
				trail.Enabled = false
				trail.Parent = chairLegs
				table.insert(trails, trail)
			end

			local chairWeld = Instance.new("WeldConstraint")
			chairWeld.Part0 = chair
			chairWeld.Part1 = root
			chairWeld.Parent = chair

			local tempAnim = Instance.new("Animation")
			tempAnim.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15 and
				"http://www.roblox.com/asset/?id=2506281703" or
				"http://www.roblox.com/asset/?id=178130996"
			chairanim = humanoid:LoadAnimation(tempAnim)
			chairanim.Priority = Enum.AnimationPriority.Movement
			chairanim.Looped = true
			chairanim:Play()
			flying:Play()

			RunService.Heartbeat:Connect(function()
				if not humanoid or not humanoid.RootPart then return end

				local speed = humanoid.RootPart.Velocity.Magnitude
				local moving = speed > 2 and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall

				for _, trail in ipairs(trails) do
					wait(0.05)
					trail.Enabled = moving
				end

				if flying then
					if moving and not flying.IsPlaying then
						flying:Play()
					elseif not moving and flying.IsPlaying then
						flying:Stop()
					end
				end
			end)
		end

		if state == false then
			if chair then
				chair.Parent = ReplicatedStorage
				chair = nil
			end
			if chairanim then
				chairanim:Stop()
				chairanim.Looped = false
				chairanim = nil
			end
			trails = {}
		else
			createChair()
		end
	end,
	Tooltip = "(Vape inspired) spawn the best gaming chair to mankind.",
	Bindable = true
})


apex.categories.utility:CreateModule({
	Name = "Phase",
	Tooltip = "Walk through walls (noclip, persists through death)",
	Bindable = false,
	Callback = function(state)
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local player = Players.LocalPlayer
		local noclipConnection -- store the running loop

		if state then
			-- Function that starts noclip for current character
			local function enableNoclip(character)
				if noclipConnection then
					noclipConnection:Disconnect()
				end
				noclipConnection = RunService.Stepped:Connect(function()
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end)
			end

			-- Enable noclip for current or future character
			if player.Character then
				enableNoclip(player.Character)
			end

			player.CharacterAdded:Connect(function(char)
				-- Wait for character to fully load before enabling again
				char:WaitForChild("HumanoidRootPart", 10)
				enableNoclip(char)
			end)

		else
			-- Turn noclip off
			if noclipConnection then
				noclipConnection:Disconnect()
				noclipConnection = nil
			end

			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local updateConnection
local FIRE_COOLDOWN = 0.1
local MAX_DISTANCE = 20

-- Swords priority
local swords = {
	"emerald_sword",
	"diamond_sword",
	"iron_sword",
	"stone_sword",
	"wood_sword"
}

apex.categories.blatant:CreateModule({
	Name = "KillAura",
	Tooltip = "Automatically attacks players and entityes within range",
	Bindable = true,
	Callback = function(state)
		if state then
			if not updateConnection then
				local lastFire = 0
				updateConnection = RunService.Heartbeat:Connect(function()
					local now = tick()
					if now - lastFire < FIRE_COOLDOWN then return end

					local character = LocalPlayer.Character
					local hrp = character and character:FindFirstChild("HumanoidRootPart")
					if not hrp then return end

					-- Get player's inventory
					local inventoriesFolder = ReplicatedStorage:WaitForChild("Inventories")
					local playerInventory = inventoriesFolder:WaitForChild(LocalPlayer.Name)

					-- Function to get active sword
					local function getActiveSword()
						for _, swordName in ipairs(swords) do
							local sword = playerInventory:FindFirstChild(swordName)
							if sword then return sword end
						end
						return nil
					end

					local sword = getActiveSword()
					if not sword then return end

					-- Get all targets (Titan + other players)
					local targets = {}

					local titan = workspace:FindFirstChild("Titan")
					if titan and titan.Parent then
						table.insert(targets, titan)
					end

					for _, plr in ipairs(Players:GetPlayers()) do
						if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
							table.insert(targets, plr.Character)
						end
					end

					-- Find nearest target within MAX_DISTANCE
					local nearest = nil
					local nearestDist = math.huge

					for _, t in ipairs(targets) do
						local targetPart = t.PrimaryPart or t:FindFirstChild("HumanoidRootPart") or t:FindFirstChildWhichIsA("BasePart")
						if targetPart then
							local dist = (targetPart.Position - hrp.Position).Magnitude
							if dist < nearestDist and dist <= MAX_DISTANCE then
								nearestDist = dist
								nearest = t
							end
						end
					end

					-- Fire remote if a valid target is found
					if nearest then
						local targetPart = nearest.PrimaryPart or nearest:FindFirstChild("HumanoidRootPart") or nearest:FindFirstChildWhichIsA("BasePart")
						if targetPart then
							local SwordHit = ReplicatedStorage.rbxts_include
								.node_modules["@rbxts"].net
								.out._NetManaged.SwordHit

							SwordHit:FireServer({
								entityInstance = nearest,
								chargedAttack = { chargeRatio = 0 },
								validate = {
									targetPosition = { value = targetPart.Position },
									selfPosition = { value = hrp.Position }
								},
								weapon = sword
							})

							lastFire = now
						end
					end
				end)
			end
		else
			if updateConnection then
				updateConnection:Disconnect()
				updateConnection = nil
			end
		end
	end
})
