local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().cyberline_distance_esp then
	for _, text in pairs(getgenv().cyberline_distance_esp) do
		pcall(function() text:Remove() end)
	end
end

getgenv().cyberline_distance_esp = {}

local function create_distance_label()
	local text = Drawing.new("Text")
	text.Size = 12
	text.Center = true
	text.Outline = true
	text.Font = 2
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Visible = false
	return text
end

run_service.RenderStepped:Connect(function()
	for _, player in ipairs(players:GetPlayers()) do
		if player ~= local_player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local screen_pos, on_screen = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))

			if not getgenv().cyberline_distance_esp[player] then
				getgenv().cyberline_distance_esp[player] = create_distance_label()
			end

			local text = getgenv().cyberline_distance_esp[player]

			if on_screen then
				local distance = math.floor((root.Position - camera.CFrame.Position).Magnitude)
				text.Position = Vector2.new(screen_pos.X, screen_pos.Y)
				text.Text = tostring(distance) .. "m"
				text.Visible = true
			else
				text.Visible = false
			end
		elseif getgenv().cyberline_distance_esp[player] then
			getgenv().cyberline_distance_esp[player].Visible = false
		end
	end
end)
