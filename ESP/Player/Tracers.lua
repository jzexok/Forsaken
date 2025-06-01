local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera
local local_player = players.LocalPlayer

if getgenv().cyberline_tracers then
	for _, line in pairs(getgenv().cyberline_tracers) do
		pcall(function() line:Remove() end)
	end
end

getgenv().cyberline_tracers = {}

local function create_tracer(color)
	local line = Drawing.new("Line")
	line.Color = color
	line.Thickness = 1
	line.Transparency = 1
	line.Visible = false
	return line
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
				if player and player ~= local_player and char:FindFirstChild("HumanoidRootPart") then
					valid_players[player] = true

					local root = char.HumanoidRootPart
					local screen_pos, on_screen = camera:WorldToViewportPoint(root.Position)

					if not getgenv().cyberline_tracers[player] then
						getgenv().cyberline_tracers[player] = create_tracer(group.color)
					end

					local tracer = getgenv().cyberline_tracers[player]

					if on_screen then
						tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
						tracer.To = Vector2.new(screen_pos.X, screen_pos.Y)
						tracer.Visible = true
					else
						tracer.Visible = false
					end
				end
			end
		end
	end

	for player, tracer in pairs(getgenv().cyberline_tracers) do
		if not valid_players[player] then
			tracer:Remove()
			getgenv().cyberline_tracers[player] = nil
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local tracer = getgenv().cyberline_tracers[player]
	if tracer then
		tracer:Remove()
		getgenv().cyberline_tracers[player] = nil
	end
end)
