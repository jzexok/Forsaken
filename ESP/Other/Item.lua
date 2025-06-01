local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera

if getgenv().cyberline_tool_esp then
	for _, label in pairs(getgenv().cyberline_tool_esp) do
		pcall(function() label:Remove() end)
	end
end

getgenv().cyberline_tool_esp = {}

local function create_text(name)
	local text = Drawing.new("Text")
	text.Text = name
	text.Color = Color3.fromRGB(255, 140, 0)
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
	for _, part in ipairs(tool:GetChildren()) do
		if part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

run_service.RenderStepped:Connect(function()
	for tool, label in pairs(getgenv().cyberline_tool_esp) do
		if not tool or not tool:IsDescendantOf(workspace) then
			pcall(function() label:Remove() end)
			getgenv().cyberline_tool_esp[tool] = nil
		end
	end

	for _, tool in ipairs(workspace:GetDescendants()) do
		if tool:IsA("Tool") and not getgenv().cyberline_tool_esp[tool] then
			getgenv().cyberline_tool_esp[tool] = create_text(tool.Name)
		end
	end

	for tool, label in pairs(getgenv().cyberline_tool_esp) do
		local root = get_primary_part(tool)
		if root then
			local pos, on_screen = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 1.5, 0))
			if on_screen then
				label.Position = Vector2.new(pos.X, pos.Y)
				label.Visible = true
			else
				label.Visible = false
			end
		else
			label.Visible = false
		end
	end
end)
