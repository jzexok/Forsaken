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

local function get_bounds(character)
	local min = Vector3.new(math.huge, math.huge, math.huge)
	local max = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, part in character:GetChildren() do
		if part:IsA("BasePart") then
			local pos = part.Position
			min = Vector3.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y), math.min(min.Z, pos.Z))
			max = Vector3.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y), math.max(max.Z, pos.Z))
		end
	end
	return min, max
end

run_service.RenderStepped:Connect(function()
	for _, group in pairs({
		{ folder = workspace.Players.Killers, color = Color3.fromRGB(255, 0, 0) },
		{ folder = workspace.Players.Survivors, color = Color3.fromRGB(255, 255, 255) },
	}) do
		for _, character in ipairs(group.folder:GetChildren()) do
			local player = players:GetPlayerFromCharacter(character)
			if player and player ~= local_player and character:FindFirstChild("HumanoidRootPart") then
				local min, max = get_bounds(character)
				local points = {
					Vector3.new(min.X, min.Y, min.Z),
					Vector3.new(min.X, max.Y, min.Z),
					Vector3.new(max.X, min.Y, min.Z),
					Vector3.new(max.X, max.Y, min.Z),
					Vector3.new(min.X, min.Y, max.Z),
					Vector3.new(min.X, max.Y, max.Z),
					Vector3.new(max.X, min.Y, max.Z),
					Vector3.new(max.X, max.Y, max.Z),
				}

				local min2d = Vector2.new(math.huge, math.huge)
				local max2d = Vector2.new(-math.huge, -math.huge)
				local visible = false

				for _, point in ipairs(points) do
					local screen, on_screen = camera:WorldToViewportPoint(point)
					if on_screen then
						visible = true
						local pos2d = Vector2.new(screen.X, screen.Y)
						min2d = Vector2.new(math.min(min2d.X, pos2d.X), math.min(min2d.Y, pos2d.Y))
						max2d = Vector2.new(math.max(max2d.X, pos2d.X), math.max(max2d.Y, pos2d.Y))
					end
				end

				if not getgenv().cyberline_esp_boxes[player] then
					getgenv().cyberline_esp_boxes[player] = create_box(group.color)
				end

				local box = getgenv().cyberline_esp_boxes[player].box
				local outline = getgenv().cyberline_esp_boxes[player].outline

				if visible then
					local size = max2d - min2d
					box.Position = min2d
					box.Size = size
					box.Visible = true

					outline.Position = min2d - Vector2.new(1, 1)
					outline.Size = size + Vector2.new(2, 2)
					outline.Visible = true
				else
					box.Visible = false
					outline.Visible = false
				end
			elseif player and getgenv().cyberline_esp_boxes[player] then
				getgenv().cyberline_esp_boxes[player].box.Visible = false
				getgenv().cyberline_esp_boxes[player].outline.Visible = false
			end
		end
	end
end)
