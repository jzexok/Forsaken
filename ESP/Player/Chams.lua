local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = players.LocalPlayer

if getgenv().cyberline_chams then
	for _, highlight in pairs(getgenv().cyberline_chams) do
		pcall(function() highlight:Destroy() end)
	end
end

getgenv().cyberline_chams = {}

run_service.RenderStepped:Connect(function()
	local survivors = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
	local killers = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
	local active_players = {}

	for _, folder_data in ipairs({
		{ folder = survivors, color = Color3.fromRGB(255, 255, 255) },
		{ folder = killers, color = Color3.fromRGB(255, 0, 0) }
	}) do
		local folder = folder_data.folder
		local fill_color = folder_data.color

		if folder then
			for _, char in ipairs(folder:GetChildren()) do
				local player = players:GetPlayerFromCharacter(char)
				if player and player ~= local_player then
					active_players[player] = true

					if not getgenv().cyberline_chams[player] then
						local highlight = Instance.new("Highlight")
						highlight.FillColor = fill_color
						highlight.OutlineColor = Color3.new(0, 0, 0)
						highlight.FillTransparency = 0.8
						highlight.OutlineTransparency = 1
						highlight.Adornee = char
						highlight.Parent = game.CoreGui
						getgenv().cyberline_chams[player] = highlight
					else
						local highlight = getgenv().cyberline_chams[player]
						if highlight and highlight.Parent then
							highlight.Adornee = char
							highlight.FillColor = fill_color
						end
					end
				end
			end
		end
	end

	-- REMOVE DEAD / LEFT / INVALID PLAYERS
	for player, highlight in pairs(getgenv().cyberline_chams) do
		if not active_players[player] then
			if highlight then highlight:Destroy() end
			getgenv().cyberline_chams[player] = nil
		end
	end
end)

players.PlayerRemoving:Connect(function(player)
	local highlight = getgenv().cyberline_chams[player]
	if highlight then
		highlight:Destroy()
		getgenv().cyberline_chams[player] = nil
	end
end)
