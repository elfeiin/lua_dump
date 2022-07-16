local module = {};

local BULLET = Instance.new("Part");
BULLET.Size = Vector3.new(1,1,4);
BULLET.CanCollide = false;
BULLET.Massless = true;
BULLET.Color = Color3.new(1, 1, 0);
local bodyForce = Instance.new("BodyForce");
bodyForce.Force = Vector3.new(0, BULLET:GetMass() * workspace.Gravity, 0);
bodyForce.Parent = BULLET;
local vel_force = Instance.new("BodyForce");
vel_force.Name = "vel_force";
vel_force.Parent = BULLET;
BULLET.BottomSurface = "Smooth";
BULLET.TopSurface = "Smooth";

module.BULLET_SPEED = 1000;

module.gib_bullet_pls = function(ignore)
	local bullet = BULLET:Clone();
	local bounces = 0;

	local function bounce()
		local startCFrame  = bullet.CFrame -- Where we derive our position & normal
		local normal = startCFrame.lookVector
		local position = startCFrame.p
		local ray = Ray.new(position, normal * 500)
		local hit, position, surfaceNormal = game.Workspace:FindPartOnRay(ray, ignore) -- Cast ray
		if (hit) then
			--print(string.format("bouncy wouncies: %d", bounces));
			-- Get the reflected normal: (this is the formula applied)
			local reflectedNormal = (normal - (2 * normal:Dot(surfaceNormal) * surfaceNormal))
			-- Override our current normal with the reflected one:
			bullet.CFrame = CFrame.lookAt(position, position + reflectedNormal);
			bullet.vel_force.Force = reflectedNormal * bullet:GetMass() * module.BULLET_SPEED;
			bounces += 1;
		end
	end

	game:GetService("RunService").Heartbeat:Connect(function()
		bounce();
	end);
	return bullet;
end

module.make_transparent = function(vis)
	
	local function ghost(p)
		p.Transparency = 1;
		p.Invis:SetAttribute("massless", p.Massless);
		p.Massless = true;
		p.Invis:SetAttribute("collides", p.CanCollide);
		p.CanCollide= false;
	end
	
	local tag = Instance.new("Folder");
	tag.Name = "Invis";
	if vis:IsA("Model") then
		for _,v in ipairs(vis:GetDescendants()) do
			if v:IsA("BasePart") then
				if v:FindFirstChild("Invis") == nil then
					tag:Clone().Parent = v;
					ghost(v);
				end
			end
		end
	end
	if vis:IsA("BasePart") then
		tag:Clone().Parent = vis;
		ghost(vis);
	end
end

module.TUNING = require(script.Tuning);

function init_vehicle(drive_motors, steer_motors, primary_seat, tuning)
	if primary_seat ~= nil then
		primary_seat.MaxSpeed = tuning.MaxSpeed;
	end
	if drive_motors ~= nil and #drive_motors ~= 0 then
		for _,v in ipairs(drive_motors) do
			v.MotorMaxTorque = tuning.Torque;
			v.MotorMaxAcceleration = tuning.MaxSpeed * tuning.AccelerationMultiplier;
		end
	end
end

module.gib_truck_pls = function()
	local truck = game.ServerStorage.Truck:Clone();
	init_vehicle(
		truck.DriveSystem.Motors:GetChildren(),
		truck.DriveSystem.SteerMotors:GetChildren(),
		truck:FindFirstChild("PrimarySeat"),
		module.TUNING.Truck
	);
	return truck;
end

return module;
