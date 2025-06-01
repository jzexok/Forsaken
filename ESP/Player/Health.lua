local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera
local local_player = players.LocalPlayer

if getgenv().cyberline_health_bars then
	for _, data in pairs(getgenv().cyberline_health_bars) do
		pcall(function() data.bar:Remove() end)
		pcall(function() data.outline:Remove() end)
	end
end

getgenv().cyberline_health_bars = {}

local function create_bar()
	local outline = Drawing.new("Square")
	outline.Color = Color3.new(0, 0, 0)
	outline.Filled = true
	outline.Transparency = 1
	outline.Visible = false

	local bar = Drawing.new("Square")
	bar.Color = Color3.fromRGB(0, 255, 0)
	bar.Filled = true
	bar.Transparency = 1
	bar.Visible = false

	return { bar = bar, outline = outline }
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
	local active_players = {}

	for _, player in ipairs(players:GetPlayers()) do
		if player ~= local_player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
			if humanoid and humanoid.Health > 0 then
				active_players[player] = true

				local min, max = get_bounds(player.Character)
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

				if not getgenv().cyberline_health_bars[player] then
					getgenv().cyberline_health_bars[player] = create_bar()
				end

				local bar = getgenv().cyberline_health_bars[player].bar
				local outline = getgenv().cyberline_health_bars[player].outline

				if visible then
					local height = max2d.Y - min2d.Y
					local ratio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					local bar_height = height * ratio

					bar.Size = Vector2.new(2, bar_height)
					bar.Position = Vector2.new(min2d.X - 5, max2d.Y - bar_height)
					bar.Visible = true

					outline.Size = Vector2.new(4, height + 2)
					outline.Position = Vector2.new(min2d.X - 6, min2d.Y - 1)
					outline.Visible = true
				else
					bar.Visible = false
					outline.Visible = false
				end
			end
		end
	end

	for player, data in pairs(getgenv().cyberline_health_bars) do
		if not active_players[player] then
			data.bar.Visible = false
			data.outline.Visible = false
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local data = getgenv().cyberline_health_bars[player]
	if data then
		pcall(function() data.bar:Remove() end)
		pcall(function() data.outline:Remove() end)
		getgenv().cyberline_health_bars[player] = nil
	end
end)
