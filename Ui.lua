local apex = require(script.Parent.Gui_lib)

apex.categories.combat:CreateModule({
	Name = "Sprint",
	Callback = function(state)
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")

		local LocalPlayer = Players.LocalPlayer
		local autoSprintEnabled = state

		-- Wait until Knit & SprintController are available
		local Knit
		task.spawn(function()
			repeat
				pcall(function()
					Knit = debug.getupvalue(require(LocalPlayer.PlayerScripts.TS.knit).setup, 9)
				end)
				task.wait()
			until Knit and Knit.Controllers and Knit.Controllers.SprintController

			local SprintController = Knit.Controllers.SprintController

			-- Auto sprint loop
			local heartbeatConn
			heartbeatConn = RunService.Heartbeat:Connect(function()
				if autoSprintEnabled and SprintController then
					SprintController:startSprinting()
				end
			end)

			-- Handle respawn
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


apex.categories.blatant:CreateModule({
	Name = "Fly",
	Callback = function(state)
		print("Fly:", state)
	end
})

apex.categories.combat:CreateModule({
	Name = "???",
	Callback = function(state)
		print("???:", state)
	end
})


