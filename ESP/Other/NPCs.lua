local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera

if getgenv().cyberline_npc_esp then
	for _, text in pairs(getgenv().cyberline_npc_esp) do
		pcall(function() text:Remove() end)
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
	if model.PrimaryPart then return model.PrimaryPart end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

run_service.RenderStepped:Connect(function()
	for npc_model, label in pairs(getgenv().cyberline_npc_esp) do
		if not npc_model or not npc_model.Parent then
			pcall(function() label:Remove() end)
			getgenv().cyberline_npc_esp[npc_model] = nil
		end
	end

	for _, model in ipairs(workspace.Map.Lobby.NPCs:GetChildren()) do
		if model:IsA("Model") then
			if not getgenv().cyberline_npc_esp[model] then
				getgenv().cyberline_npc_esp[model] = create_text()
			end

			local label = getgenv().cyberline_npc_esp[model]
			local part = get_model_part(model)

			if part then
				local screen_pos, on_screen = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 3, 0))
				if on_screen then
					label.Position = Vector2.new(screen_pos.X, screen_pos.Y)
					label.Text = model.Name
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
