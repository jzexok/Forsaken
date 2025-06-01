local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = players.LocalPlayer
local camera = workspace.CurrentCamera

if getgenv().cyberline_name_esp then
	for _, text in pairs(getgenv().cyberline_name_esp) do
		pcall(function() text:Remove() end)
	end
end

getgenv().cyberline_name_esp = {}

local function create_name_label(color)
	local text = Drawing.new("Text")
	text.Size = 12
	text.Center = true
	text.Outline = true
	text.Font = 2
	text.Color = color
	text.Visible = false
	return text
end

run_service.RenderStepped:Connect(function()
	local active_players = {}

	for _, group in pairs({
		{ folder = workspace.Players.Killers, color = Color3.fromRGB(255, 0, 0) },
		{ folder = workspace.Players.Survivors, color = Color3.fromRGB(255, 255, 255) },
	}) do
		for _, character in ipairs(group.folder:GetChildren()) do
			local player = players:GetPlayerFromCharacter(character)
			if player and player ~= local_player and character:FindFirstChild("Head") then
				active_players[player] = true

				if not getgenv().cyberline_name_esp[player] then
					getgenv().cyberline_name_esp[player] = create_name_label(group.color)
				end

				local text = getgenv().cyberline_name_esp[player]
				local head = character.Head
				local screen_pos, on_screen = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.8, 0))

				if on_screen then
					text.Position = Vector2.new(screen_pos.X, screen_pos.Y)
					text.Text = player.Name
					text.Visible = true
				else
					text.Visible = false
				end
			end
		end
	end

	-- REMOVE DEAD / MISSING ESPS
	for player, text in pairs(getgenv().cyberline_name_esp) do
		if not active_players[player] then
			if text then text:Remove() end
			getgenv().cyberline_name_esp[player] = nil
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local text = getgenv().cyberline_name_esp[player]
	if text then
		text:Remove()
		getgenv().cyberline_name_esp[player] = nil
	end
end)
