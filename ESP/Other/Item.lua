local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera

if getgenv().cyberline_tool_esp then
	for _, text in pairs(getgenv().cyberline_tool_esp) do
		pcall(function() text:Remove() end)
	end
end

getgenv().cyberline_tool_esp = {}

local function create_text(name)
	local text = Drawing.new("Text")
	text.Text = name
	text.Color = Color3.fromRGB(255, 140, 0) -- Orange
	text.Size = 12
	text.Font = 2
	text.Center = true
	text.Outline = true
	text.OutlineColor = Color3.new(0, 0, 0)
	text.Visible = false
	return text
end

local function get_primary_part(tool)
	if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then
		return tool.Handle
	end
	for _, v in pairs(tool:GetChildren()) do
		if v:IsA("BasePart") then return v end
	end
	return nil
end

run_service.RenderStepped:Connect(function()
	-- Clean up ESPs for tools that no longer exist
	for tool, label in pairs(getgenv().cyberline_tool_esp) do
		if not tool or not tool.Parent then
			pcall(function() label:Remove() end)
			getgenv().cyberline_tool_esp[tool] = nil
		end
	end

	-- Add or update ESPs
	for _, tool in ipairs(workspace:GetDescendants()) do
		if tool:IsA("Tool") then
			if not getgenv().cyberline_tool_esp[tool] then
				getgenv().cyberline_tool_esp[tool] = create_text(tool.Name)
			end

			local label = getgenv().cyberline_tool_esp[tool]
			local root = get_primary_part(tool)

			if root then
				local pos, visible = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 1.5, 0))
				if visible then
					label.Position = Vector2.new(pos.X, pos.Y)
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
