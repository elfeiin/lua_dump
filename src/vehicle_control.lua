local rep_stor = game:GetService("ReplicatedStorage");
local sss = game:GetService("ServerScriptService");
local common = require(sss.Common);

function drive(vehicle_name, seat_part, drive_motors, steer_motors)
	local tuning = common.TUNING[vehicle_name];
	for _,v in ipairs(drive_motors) do
		local side = 1;
		if v.Attachment0 ~= nil then
			if v.Attachment0.Position.X > 0 then
				side = -1;
			end
		end
		v.AngularVelocity = (tuning.MaxSpeed * seat_part.Throttle * side) / tuning.WheelRadius;
	end
	if #steer_motors == 0 then
		for _,v in ipairs(drive_motors) do
			v.AngularVelocity += (tuning.TurnSpeed * seat_part.Steer) / tuning.WheelRadius;
		end
	else
		for _,v in ipairs(steer_motors) do
			if seat_part.Throttle >= 0 then
				if seat_part.Steer < 0 then
					v.TargetAngle = tuning.NegativeSteerAngle;
				elseif seat_part.Steer > 0 then
					v.TargetAngle = tuning.PositiveSteerAngle;
				else
					v.TargetAngle = 0;
				end
			else
				if seat_part.Steer < 0 then
					v.TargetAngle = tuning.PositiveSteerAngle;
				elseif seat_part.Steer > 0 then
					v.TargetAngle = tuning.NegativeSteerAngle;
				else
					v.TargetAngle = 0;
				end
			end
		end
	end
end

-- TODO: Give player credit for kills
function aim_and_fire_50cal(fifty_cal, motors, target, player, ignore)
	if target ~= nil then
		if motors ~= nil then
			local yaw_servo = motors:FindFirstChild("Yaw");
			local pitch_servo = motors:FindFirstChild("Pitch");
			if yaw_servo ~= nil then
				local world_cf = CFrame.lookAt(
					fifty_cal.Base.Position,
					fifty_cal.Base.CFrame:PointToWorldSpace(fifty_cal.Base.CFrame:PointToObjectSpace(target) * Vector3.new(0,1,1)),
					fifty_cal.Base.CFrame.RightVector);
				local local_cf = fifty_cal.Base.CFrame:ToObjectSpace(world_cf);
				local a, b, c = local_cf:ToOrientation();
				yaw_servo.TargetAngle = yaw_servo.CurrentAngle - math.deg(a);
			end
			if pitch_servo ~= nil then
				local bullet = common.gib_bullet_pls(ignore);
				bullet.CFrame = CFrame.lookAt(
					fifty_cal.Chamber.CFrame:PointToWorldSpace(-Vector3.new(0, 0, fifty_cal.Chamber.Size.Z + bullet.Size.Z)/2),
					fifty_cal.Chamber.CFrame:PointToWorldSpace(
						(
							fifty_cal.Chamber.CFrame:PointToObjectSpace(target)
						)
					),
					fifty_cal.Chamber.CFrame.UpVector
				);
				bullet.vel_force.Force = bullet.CFrame.lookVector * bullet:GetMass() * common.BULLET_SPEED;
				bullet.Parent = workspace;
				--bullet:SetNetworkOwner(player);
				local world_cf = CFrame.lookAt(
					fifty_cal.Chamber.CFrame:PointToWorldSpace(Vector3.new(0, 0, fifty_cal.Chamber.Size.Z)/2),
					fifty_cal.Chamber.CFrame:PointToWorldSpace(
						(
							fifty_cal.Chamber.CFrame:PointToObjectSpace(target)
						)
					),
					fifty_cal.Chamber.CFrame.UpVector
				);
				local local_cf = fifty_cal.Chamber.CFrame:ToObjectSpace(world_cf);
				local a, b, c = local_cf:ToOrientation();
				pitch_servo.TargetAngle = pitch_servo.CurrentAngle + math.deg(a);
			end
		end
	end
end

local action = nil;

rep_stor.Remote.RE_Fire50Cal.OnServerEvent:Connect(function(plr, click_pos)
	plr:SetAttribute("fire_at", click_pos);
	plr:SetAttribute("fire_50cal", true);
end)

rep_stor.Remote.RE_RunRelease.OnServerEvent:Connect(function(plr)
	plr:SetAttribute("drop_cargo", 1);
end)

rep_stor.Remote.RE_StopRelease.OnServerEvent:Connect(function(plr)
	plr:SetAttribute("drop_cargo", 3);
end)

game.Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("fire_50cal", false);
	player:SetAttribute("fire_at", Vector3.new());
	player:SetAttribute("drop_cargo", 0);
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid");
		if hum ~= nil then
			hum.Seated:Connect(function(sitting, seat_part)
				if seat_part and seat_part.Parent:FindFirstChild("DriveSystem") ~= nil and seat_part:IsA("VehicleSeat") then
					local drive_System = seat_part.Parent:FindFirstChild("DriveSystem");
					-- Motors of the vehicle
					local drive_motors_folder = drive_System:FindFirstChild("Motors");
					local drive_motors = (drive_motors_folder or Instance.new("Accessory")):GetChildren();
					-- Whether or not this vehicle uses axle steering
					local steer_motors_folder = drive_System:FindFirstChild("SteerMotors");
					local steer_motors = (steer_motors_folder or Instance.new("Accessory")):GetChildren();
					local fifty_cal = seat_part.Parent:FindFirstChild("FiftyCal");
					local fifty_cal_motors_folder = (fifty_cal and fifty_cal:FindFirstChild("Motors")) or nil;
					action = game:GetService("RunService").Heartbeat:Connect(function()
						if seat_part == nil or seat_part.Parent == nil or drive_motors_folder == nil then
							action:Disconnect();
						end
						if #drive_motors ~= 0 then
							drive(seat_part.Parent.Name, seat_part, drive_motors_folder, drive_motors, steer_motors);
						end
						if player:GetAttribute("fire_50cal") then
							player:SetAttribute("fire_50cal", false);
							if fifty_cal_motors_folder ~= nil then
								aim_and_fire_50cal(fifty_cal, fifty_cal_motors_folder, player:GetAttribute("fire_at"), player, seat_part.Parent);
							end
						end
						if player:GetAttribute("drop_cargo") == 1 then
							player:SetAttribute("drop_cargo", 2);
							common.TUNING[seat_part.Parent.Name].Cargo.run(seat_part.Parent);
						end
						if player:GetAttribute("drop_cargo") == 2 then
							common.TUNING[seat_part.Parent.Name].Cargo.check(seat_part.Parent);
						end
						if player:GetAttribute("drop_cargo") == 3 then
							player:SetAttribute("drop_cargo", 0);
							common.TUNING[seat_part.Parent.Name].Cargo.stop(seat_part.Parent);
						end
					end);
				end
			end)
			hum.Died:Connect(function()
				if action ~= nil then
					action:Disconnect();
				end
			end);
		end
	end)
	player.Destroying:Connect(function()
		if action ~= nil then
			action:Disconnect();
		end
	end)
end)


