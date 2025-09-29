-- gui_lib (ModuleScript)
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
	Title.Active = true
	Title.Draggable = true

	-- CategoryFrame holds the modules
	local CategoryFrame = Instance.new("Frame")
	CategoryFrame.Size = UDim2.new(1, 0, 1, -30)
	CategoryFrame.Position = UDim2.new(0, 0, 0, 30)
	CategoryFrame.BackgroundTransparency = 1
	CategoryFrame.Parent = CategoryHolder

	-- Right‑click toggle visibility for modules only
	Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
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

return gui_lib
