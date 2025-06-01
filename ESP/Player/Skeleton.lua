local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera
local local_player = players.LocalPlayer

if getgenv().cyberline_skeleton then
	for _, parts in pairs(getgenv().cyberline_skeleton) do
		for _, line in pairs(parts) do
			pcall(function() line:Remove() end)
		end
	end
end

getgenv().cyberline_skeleton = {}

local function create_line(color)
	local line = Drawing.new("Line")
	line.Color = color
	line.Thickness = 1
	line.Transparency = 1
	line.Visible = false
	return line
end

local function create_skeleton(color)
	return {
		head = create_line(color),
		torso = create_line(color),
		left_arm = create_line(color),
		right_arm = create_line(color),
		left_leg = create_line(color),
		right_leg = create_line(color)
	}
end

run_service.RenderStepped:Connect(function()
	local valid_players = {}

	for _, group in pairs({
		{ folder = workspace.Players:FindFirstChild("Killers"), color = Color3.fromRGB(255, 0, 0) },
		{ folder = workspace.Players:FindFirstChild("Survivors"), color = Color3.fromRGB(255, 255, 255) },
	}) do
		local folder = group.folder
		if folder then
			for _, char in ipairs(folder:GetChildren()) do
				local player = players:GetPlayerFromCharacter(char)
				if player and player ~= local_player then
					valid_players[player] = true

					local parts = {
						head = char:FindFirstChild("Head"),
						upper = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
						lower = char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart"),
						left_arm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
						right_arm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
						left_leg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
						right_leg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
					}

					if not getgenv().cyberline_skeleton[player] then
						getgenv().cyberline_skeleton[player] = create_skeleton(group.color)
					end

					local skeleton = getgenv().cyberline_skeleton[player]

					local function to_screen(part)
						local pos, on_screen = camera:WorldToViewportPoint(part.Position)
						return Vector2.new(pos.X, pos.Y), on_screen
					end

					local all_visible = true
					for _, part in pairs(parts) do
						if not part then
							all_visible = false
							break
						end
					end

					if all_visible then
						local head_pos = to_screen(parts.head)
						local upper_pos = to_screen(parts.upper)
						local lower_pos = to_screen(parts.lower)
						local larm_pos = to_screen(parts.left_arm)
						local rarm_pos = to_screen(parts.right_arm)
						local lleg_pos = to_screen(parts.left_leg)
						local rleg_pos = to_screen(parts.right_leg)

						skeleton.head.From = head_pos
						skeleton.head.To = upper_pos

						skeleton.torso.From = upper_pos
						skeleton.torso.To = lower_pos

						skeleton.left_arm.From = upper_pos
						skeleton.left_arm.To = larm_pos

						skeleton.right_arm.From = upper_pos
						skeleton.right_arm.To = rarm_pos

						skeleton.left_leg.From = lower_pos
						skeleton.left_leg.To = lleg_pos

						skeleton.right_leg.From = lower_pos
						skeleton.right_leg.To = rleg_pos

						for _, line in pairs(skeleton) do
							line.Visible = true
						end
					else
						for _, line in pairs(skeleton) do
							line.Visible = false
						end
					end
				end
			end
		end
	end

	for player, skeleton in pairs(getgenv().cyberline_skeleton) do
		if not valid_players[player] then
			for _, line in pairs(skeleton) do
				line:Remove()
			end
			getgenv().cyberline_skeleton[player] = nil
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local skeleton = getgenv().cyberline_skeleton[player]
	if skeleton then
		for _, line in pairs(skeleton) do
			line:Remove()
		end
		getgenv().cyberline_skeleton[player] = nil
	end
end)
