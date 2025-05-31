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
	for _, player in ipairs(players:GetPlayers()) do
		if player ~= local_player and player.Character then
			if not getgenv().cyberline_chams[player] then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
				highlight.FillTransparency = 0.8
				highlight.OutlineTransparency = 1
				highlight.Adornee = player.Character
				highlight.Parent = game.CoreGui
				getgenv().cyberline_chams[player] = highlight
			end
		end
	end
end)
