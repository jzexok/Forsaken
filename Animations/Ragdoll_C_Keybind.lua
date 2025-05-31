local user_input_service = game:GetService("UserInputService")
local players = game:GetService("Players")
local local_player = players.LocalPlayer
local ragdoll_module = require(game.ReplicatedStorage.Modules.Ragdolls)

local function force_ragdoll()
	local character = local_player.Character
	if not character or not character:FindFirstChild("Humanoid") then return end
	if not character:GetAttribute("Ragdolling") then
		ragdoll_module:Enable(character, false)
	end
end

user_input_service.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.C then
		force_ragdoll()
	end
end)
