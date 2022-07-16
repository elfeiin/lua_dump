local module = {}

module.instance = require(script.Instance);

function module.convert_object_to_code(root: Instance)
	local output = "local vars = {};\nvars.root = Instance.new(\""..root.ClassName.."\");\n";
	local descendants = root:GetDescendants();
	local list = {};
	list[root] = "root";
	for i,v in ipairs(descendants) do
		local var_nym = "var_" .. i;
		list[v] = var_nym;
		output = output.."vars."..var_nym.." = Instance.new(\""..v.ClassName.."\");\n"
		output = output.."vars."..var_nym..".Name = \""..v.Name.."\";\n";
		if list[v.Parent] ~= nil then
			output = output..var_nym..".Parent = vars."..list[v.Parent]..";\n";
		end
	end
	return output;
end

return module

--for k,v in part:GetAttributes() do
--	if typeof(v) == "string" then
--		v = "\"" .. v .. "\"";
--	end
--	output = output .. var_nym .. ":SetAttribute(\"" .. k .. "\", " .. v .. ";\n";
--end