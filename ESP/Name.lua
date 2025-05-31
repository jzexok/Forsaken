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

local function create_name_label()
	local text = Drawing.new("Text")
	text.Size = 12
	text.Center = true
	text.Outline = true
	text.Font = 2 -- Inconsolata
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Visible = false
	return text
end

run_service.RenderStepped:Connect(function()
	for _, player in ipairs(players:GetPlayers()) do
		if player ~= local_player and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screen_pos, on_screen = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.8, 0))

			if not getgenv().cyberline_name_esp[player] then
				getgenv().cyberline_name_esp[player] = create_name_label()
			end

			local text = getgenv().cyberline_name_esp[player]

			if on_screen then
				text.Position = Vector2.new(screen_pos.X, screen_pos.Y)
				text.Text = player.Name
				text.Visible = true
			else
				text.Visible = false
			end
		elseif getgenv().cyberline_name_esp[player] then
			getgenv().cyberline_name_esp[player].Visible = false
		end
	end
end)
