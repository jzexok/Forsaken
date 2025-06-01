local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera

if getgenv().cyberline_npc_esp then
	for _, label in pairs(getgenv().cyberline_npc_esp) do
		pcall(function() label:Remove() end)
	end
end

getgenv().cyberline_npc_esp = {}

local function create_text()
	local text = Drawing.new("Text")
	text.Color = Color3.fromRGB(255, 255, 0)
	text.Size = 12
	text.Font = 2
	text.Center = true
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Visible = false
	return text
end

local function get_model_part(model)
	if model:IsA("Model") and model.PrimaryPart then
		return model.PrimaryPart
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

run_service.RenderStepped:Connect(function()
	for model, label in pairs(getgenv().cyberline_npc_esp) do
		if not model or not model:IsDescendantOf(workspace) then
			pcall(function() label:Remove() end)
			getgenv().cyberline_npc_esp[model] = nil
		end
	end

	for _, npc in ipairs(workspace.Map.Lobby.NPCs:GetChildren()) do
		if npc:IsA("Model") then
			if not getgenv().cyberline_npc_esp[npc] then
				getgenv().cyberline_npc_esp[npc] = create_text()
			end

			local label = getgenv().cyberline_npc_esp[npc]
			local part = get_model_part(npc)

			if part then
				local screen_pos, visible = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0))
				if visible then
					label.Position = Vector2.new(screen_pos.X, screen_pos.Y)
					label.Text = npc.Name
					label.Visible = true
				else
					label.Visible = false
				end
			else
				label.Visible = false
			end
		end
	end
end)
