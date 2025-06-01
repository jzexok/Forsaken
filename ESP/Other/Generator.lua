local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera

if getgenv().cyberline_generator_esp then
	for _, text in pairs(getgenv().cyberline_generator_esp) do
		pcall(function() text:Remove() end)
	end
end

getgenv().cyberline_generator_esp = {}

local function create_text()
	local text = Drawing.new("Text")
	text.Color = Color3.fromRGB(0, 255, 0)
	text.Size = 12
	text.Font = 2
	text.Center = true
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Visible = false
	return text
end

local function get_primary_part(model)
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
	for gen_model, label in pairs(getgenv().cyberline_generator_esp) do
		if not gen_model or not gen_model.Parent then
			pcall(function() label:Remove() end)
			getgenv().cyberline_generator_esp[gen_model] = nil
		end
	end

	for _, obj in ipairs(workspace.Map.Ingame.Map:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Generator" then
			if not getgenv().cyberline_generator_esp[obj] then
				getgenv().cyberline_generator_esp[obj] = create_text()
			end

			local label = getgenv().cyberline_generator_esp[obj]
			local root = get_primary_part(obj)
			local progress = obj:FindFirstChild("Progress")

			if root and progress and progress:IsA("NumberValue") then
				local screen_pos, on_screen = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
				if on_screen then
					label.Position = Vector2.new(screen_pos.X, screen_pos.Y)
					label.Text = "Generator: " .. math.floor(progress.Value) .. "%"
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
