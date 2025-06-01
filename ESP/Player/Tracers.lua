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
	for _, group in pairs({
		{ folder = workspace.Players.Killers, color = Color3.fromRGB(255, 0, 0) },
		{ folder = workspace.Players.Survivors, color = Color3.fromRGB(255, 255, 255) },
	}) do
		for _, char in ipairs(group.folder:GetChildren()) do
			local player = players:GetPlayerFromCharacter(char)
			if player and player ~= local_player and char:FindFirstChild("HumanoidRootPart") then
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
			elseif player and getgenv().cyberline_tracers[player] then
				getgenv().cyberline_tracers[player].Visible = false
			end
		end
	end
end)
