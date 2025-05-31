local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().cyberline_tracers then
	for _, line in pairs(getgenv().cyberline_tracers) do
		pcall(function() line:Remove() end)
	end
end

getgenv().cyberline_tracers = {}

local function create_tracer()
	local line = Drawing.new("Line")
	line.Color = Color3.fromRGB(255, 255, 255)
	line.Thickness = 1
	line.Transparency = 1
	line.Visible = false
	return line
end

run_service.RenderStepped:Connect(function()
	for _, player in ipairs(players:GetPlayers()) do
		if player ~= local_player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root_part = player.Character.HumanoidRootPart
			local screen_pos, on_screen = camera:WorldToViewportPoint(root_part.Position)

			if not getgenv().cyberline_tracers[player] then
				getgenv().cyberline_tracers[player] = create_tracer()
			end

			local tracer = getgenv().cyberline_tracers[player]

			if on_screen then
				tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
				tracer.To = Vector2.new(screen_pos.X, screen_pos.Y)
				tracer.Visible = true
			else
				tracer.Visible = false
			end
		elseif getgenv().cyberline_tracers[player] then
			getgenv().cyberline_tracers[player].Visible = false
		end
	end
end)
