local apex = loadstring(game:HttpGet("https://raw.githubusercontent.com/0y0x/GUI_LIB/refs/heads/main/Main.lua", true))()

-- Sprint module
apex.categories.combat:CreateModule({
	Name = "Sprint",
	Callback = function(state)
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")

		local LocalPlayer = Players.LocalPlayer
		local autoSprintEnabled = state

		task.spawn(function()
			local Knit
			repeat
				pcall(function()
					Knit = debug.getupvalue(require(LocalPlayer.PlayerScripts.TS.knit).setup, 9)
				end)
				task.wait()
			until Knit and Knit.Controllers and Knit.Controllers.SprintController

			local SprintController = Knit.Controllers.SprintController

			local heartbeatConn
			heartbeatConn = RunService.Heartbeat:Connect(function()
				if autoSprintEnabled and SprintController then
					SprintController:startSprinting()
				end
			end)

			Players.LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.1)
				Knit = nil
				repeat
					pcall(function()
						Knit = debug.getupvalue(require(LocalPlayer.PlayerScripts.TS.knit).setup, 9)
					end)
					task.wait()
				until Knit and Knit.Controllers and Knit.Controllers.SprintController
				SprintController = Knit.Controllers.SprintController
			end)
		end)
	end
})

-- Autoclicker module
local autoclickerEnabled = false
apex.categories.combat:CreateModule({
	Name = "Autoclicker",
	Callback = function(state)
		autoclickerEnabled = state
		if autoclickerEnabled then
			task.spawn(function()
				local LocalPlayer = game.Players.LocalPlayer
				while autoclickerEnabled do
					local character = LocalPlayer.Character
					if character then
						local tool = character:FindFirstChildOfClass("Tool")
						if tool then
							tool:Activate()
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

-- Zoom Unlocker module
apex.categories.utility:CreateModule({
	Name = "ZoomUnlocker",
	Callback = function(state)
		local Camera = workspace.CurrentCamera
		if state then
			Camera.CameraMaxZoomDistance = 99999999
		else
			Camera.CameraMaxZoomDistance = 128
		end
	end
})
