local module = {}

function module.part_to_code(part: Part, var_nym: string, parent_path: string)
	local output = "";
	output = output .. "local " .. var_nym .. " = Instance.new(\"Part\");\n";
	output = output .. var_nym .. ".BrickColor = " .. part.BrickColor .. ";\n";
	output = output .. var_nym .. ".CastShadow = " .. part.CastShadow .. ";\n";
	output = output .. var_nym .. ".Color = Color3.new(" .. part.Color .. ");\n";
	output = output .. var_nym .. ".Material = " .. part.Material .. ";\n";
	output = output .. var_nym .. ".MaterialVariant = " .. part.MaterialVariant .. ";\n";
	output = output .. var_nym .. ".Reflectance = " .. part.Reflectance .. ";\n";
	output = output .. var_nym .. ".Transparency = " .. part.Transparency .. ";\n";
	output = output .. var_nym .. ".Archivable = " .. part.Archivable .. ";\n";
	output = output .. var_nym .. ".Locked = " .. part.Locked .. ";\n";
	output = output .. var_nym .. ".Name = " .. part.Name .. ";\n";
	output = output .. var_nym .. ".Size = Vector3.new(" .. part.Size .. ");\n";
	output = output .. var_nym .. ".Position = Vector3.new(" .. part.Position .. ");\n";
	output = output .. var_nym .. ".Orientation = Vector3.new(" .. part.Orientation .. ");\n";
	output = output .. var_nym .. ".CanCollide = " .. part.CanCollide .. ";\n";
	output = output .. var_nym .. ".CanTouch = " .. part.CanTouch .. ";\n";
	output = output .. var_nym .. ".CollisionGroupId = " .. part.CollisionGroupId .. ";\n";
	output = output .. var_nym .. ".Anchored = " .. part.Anchored .. ";\n";
	if part.CustomPhysicalProperties then
		output = output ..
			var_nym
			.. ".CustomPhysicalProperties = PhysicalProperties.new("
			.. part.CustomPhysicalProperties.Density
			.. ", "
			.. part.CustomPhysicalProperties.Friction
			.. ", "
			.. part.CustomPhysicalProperties.Elasticity
			.. ", "
			.. part.CustomPhysicalProperties.FrictionWeight
			.. ", "
			.. part.CustomPhysicalProperties.ElasticityWeight
			.. ");\n";
	end
	output = output .. var_nym .. ".Massless = " .. part.Massless .. ";\n";
	output = output .. var_nym .. ".RootPriority = " .. part.RootPriority .. ";\n";
	output = output .. var_nym .. ".Shape = " .. part.Shape .. ";\n";
	if parent_path then
		output = output .. var_nym .. ".Parent = " .. parent_path .. ";\n";
	end
	return output;
end


function module.model_to_code(model: Model, var_nym: string, parent_path: string)
	local output = "";
	output = output .. "local " .. var_nym .. " = Instance.new(\"Model\");\n";
	output = output .. var_nym .. ".LevelOfDetail = " .. model.LevelOfDetail .. ";\n";
	output = output .. var_nym .. ".Archivable = " .. model.Archivable .. ";\n";
	output = output .. var_nym .. ".Name = " .. model.Name .. ";\n";
	if parent_path then
		output = output .. var_nym .. ".Parent = " .. parent_path .. ";\n";
	end
	return output;
end

return module
