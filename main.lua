local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local aiming = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = gethui and gethui() or game.CoreGui
gui.Name = "MM2Shoot"

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,150,0,65)
frame.Position = UDim2.new(0,20,0,300)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke")
stroke.Parent = frame
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,22)
title.BackgroundColor3 = Color3.fromRGB(0,80,255)
title.Text = "MM2 Shoot"
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", title).CornerRadius = UDim.new(0,12)

local shoot = Instance.new("TextButton")
shoot.Parent = frame
shoot.Size = UDim2.new(0,120,0,26)
shoot.Position = UDim2.new(0,15,0,30)
shoot.Text = "Shoot"
shoot.TextScaled = true
shoot.BackgroundColor3 = Color3.fromRGB(0,170,255)
shoot.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", shoot).CornerRadius = UDim.new(0,8)

-- kéo GUI
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UIS.TouchMoved:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- tìm murder (kể cả trong túi)
local function getMurder()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local backpack = plr:FindFirstChild("Backpack")

			for _, item in pairs(plr.Character:GetChildren()) do
				if item:IsA("Tool") and item.Name:lower():find("knife") then
					return plr
				end
			end

			if backpack then
				for _, item in pairs(backpack:GetChildren()) do
					if item:IsA("Tool") and item.Name:lower():find("knife") then
						return plr
					end
				end
			end
		end
	end
	return nil
end

-- AIM MƯỢT + DỰ ĐOÁN
shoot.MouseButton1Click:Connect(function()
	if aiming then return end
	
	local murder = getMurder()
	if not murder then return end
	
	aiming = true
	local endTime = tick() + 10

	while tick() < endTime do
		if murder.Character and murder.Character:FindFirstChild("HumanoidRootPart") then
			local root = murder.Character.HumanoidRootPart
			
			-- dự đoán vị trí (giảm trượt)
			local predictedPos = root.Position + (root.Velocity * 0.12)

			camera.CFrame = CFrame.lookAt(
				camera.CFrame.Position,
				predictedPos
			)
		end
		
		RunService.RenderStepped:Wait()
	end

	aiming = false
end)
