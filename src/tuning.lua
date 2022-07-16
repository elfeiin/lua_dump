local module = {}

module.Truck = {};
module.Truck.PositiveSteerAngle = 30;
module.Truck.NegativeSteerAngle = -30;
module.Truck.AccelerationMultiplier = 1.5;
module.Truck.WheelRadius = 2;
module.Truck.MaxSpeed = 45;
module.Truck.Torque = 8000000000;
module.Truck.TurnSpeed = 1;
module.Truck.Cargo = {};
module.Truck.Cargo.check = function(truck)
	local boxes = truck.Cargo.Boxes;
	if math.abs(-45 - boxes.Motors.HingeConstraint.CurrentAngle) <= .15 and boxes.Raising.Value and not boxes.CargoDropped.Value then
		boxes.CargoDropped.Value = true;
		boxes.Raising.Value = false;
		local items = truck.Cargo.Boxes.Items:GetChildren();
		if items ~= nil and #items > 0 then
			for _,v in ipairs(items) do
				v:Clone().Parent = workspace;
				module.make_transparent(v);
			end
		end
	elseif math.abs(0 - boxes.Motors.HingeConstraint.CurrentAngle) <= .15 and not boxes.Raising.Value then
		boxes.Raising.Value = true;
	end
end
module.Truck.Cargo.run = function(truck)
	local boxes = truck.Cargo.Boxes;
	if boxes.Raising.Value then
		boxes.Motors.HingeConstraint.TargetAngle = -45;
	else
		boxes.Motors.HingeConstraint.TargetAngle = 45;
	end
end
module.Truck.Cargo.stop = function(truck)
	local boxes = truck.Cargo.Boxes;
	boxes.Motors.HingeConstraint.TargetAngle = boxes.Motors.HingeConstraint.CurrentAngle;
end

return module
