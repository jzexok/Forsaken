local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().cyberline_esp_boxes then
	for _, data in pairs(getgenv().cyberline_esp_boxes) do
		pcall(function() data.box:Remove() end)
		pcall(function() data.outline:Remove() end)
	end
end

getgenv().cyberline_esp_boxes = {}

local function create_box(color)
	local outline = Drawing.new("Square")
	outline.Color = Color3.new(0, 0, 0)
	outline.Thickness = 1
	outline.Filled = false
	outline.Transparency = 1
	outline.Visible = false

	local box = Drawing.new("Square")
	box.Color = color
	box.Thickness = 1
	box.Filled = false
	box.Transparency = 1
	box.Visible = false

	return { box = box, outline = outline }
end

local function get_body_bounds(character)
	local parts = {
		character:FindFirstChild("Head"),
		character:FindFirstChild("HumanoidRootPart"),
		character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
		character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
		character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
		character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
	}
	local min = Vector3.new(math.huge, math.huge, math.huge)
	local max = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, part in ipairs(parts) do
		if part then
			local pos = part.Position
			min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
			max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
		end
	end
	return min, max
end

run_service.RenderStepped:Connect(function()
	local active_players = {}

	for _, group in pairs({
		{ folder = workspace.Players.Killers, color = Color3.fromRGB(255, 0, 0) },
		{ folder = workspace.Players.Survivors, color = Color3.fromRGB(255, 255, 255) },
	}) do
		for _, character in ipairs(group.folder:GetChildren()) do
			local player = players:GetPlayerFromCharacter(character)
			local root_part = character:FindFirstChild("HumanoidRootPart")

			if player and player ~= local_player and root_part then
				active_players[player] = true

				local min, max = get_body_bounds(character)
				local top = Vector3.new((min.X + max.X) / 2, max.Y, (min.Z + max.Z) / 2)
				local bottom = Vector3.new((min.X + max.X) / 2, min.Y, (min.Z + max.Z) / 2)
				local top_screen, top_on_screen = camera:WorldToViewportPoint(top)
				local bottom_screen, bottom_on_screen = camera:WorldToViewportPoint(bottom)
				local center_screen, center_on_screen = camera:WorldToViewportPoint(root_part.Position)

				local height = math.abs(top_screen.Y - bottom_screen.Y)
				local width = height / 2

				if top_on_screen and bottom_on_screen and center_on_screen then
					if not getgenv().cyberline_esp_boxes[player] then
						getgenv().cyberline_esp_boxes[player] = create_box(group.color)
					end

					local box = getgenv().cyberline_esp_boxes[player].box
					local outline = getgenv().cyberline_esp_boxes[player].outline

					local box_pos = Vector2.new(center_screen.X - width / 2, top_screen.Y)
					local box_size = Vector2.new(width, height)

					box.Position = box_pos
					box.Size = box_size
					box.Visible = true

					outline.Position = box_pos - Vector2.new(1, 1)
					outline.Size = box_size + Vector2.new(2, 2)
					outline.Visible = true
				else
					local data = getgenv().cyberline_esp_boxes[player]
					if data then
						data.box.Visible = false
						data.outline.Visible = false
					end
				end
			end
		end
	end

	-- REMOVE ESP IF PLAYER NO LONGER EXISTS IN KILLERS OR SURVIVORS
	for player, data in pairs(getgenv().cyberline_esp_boxes) do
		if not active_players[player] then
			if data.box then data.box:Remove() end
			if data.outline then data.outline:Remove() end
			getgenv().cyberline_esp_boxes[player] = nil
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local data = getgenv().cyberline_esp_boxes[player]
	if data then
		if data.box then data.box:Remove() end
		if data.outline then data.outline:Remove() end
		getgenv().cyberline_esp_boxes[player] = nil
	end
end)
