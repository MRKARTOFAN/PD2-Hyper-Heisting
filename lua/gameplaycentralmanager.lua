function GamePlayCentralManager:end_heist(num_winners)
	if not num_winners then
		num_winners = 1
	end
	
	if alive(managers.player:player_unit()) then
		if managers.player:player_unit():sound():speaking() then
			managers.enemy:add_delayed_clbk("fray_mission_ended", callback(self, self, "end_heist", num_winners), Application:time() + 1)
		else
			managers.network:session():send_to_peers("mission_ended", true, num_winners)
			game_state_machine:change_state_by_name("victoryscreen", {
				num_winners = num_winners,
				personal_win = alive(managers.player:player_unit())
			})
		end
	else
		managers.network:session():send_to_peers("mission_ended", true, num_winners)
		game_state_machine:change_state_by_name("victoryscreen", {
			num_winners = num_winners,
			personal_win = alive(managers.player:player_unit())
		})
	end
end

function GamePlayCentralManager:do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	if not alive(unit) or not hit_pos or not dir or type(distance) ~= "number" then
		return
	end

	local max_distance = 500
	local groupai_state = managers.groupai and managers.groupai:state()

	if attacker == managers.player:player_unit() or groupai_state and groupai_state:is_unit_team_AI(attacker) then
		max_distance = self:get_shotgun_push_range()
	end

	if distance < max_distance then
		local session = managers.network and managers.network:session()

		if session and unit:id() > 0 then
			session:send_to_peers_synched("sync_shotgun_push", unit, hit_pos, dir, distance, attacker)
		end

		self:_do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	end
end

function GamePlayCentralManager:_do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	if not alive(unit) or not hit_pos or not dir or type(distance) ~= "number" then
		return
	end

	local mov_ext = unit:movement()
	local full_body_action = mov_ext and mov_ext.get_action and mov_ext:get_action(1)

	if full_body_action and full_body_action.type and full_body_action:type() == "hurt" and full_body_action.force_ragdoll then
		full_body_action:force_ragdoll(true)
	end

	local scale = math.clamp(1 - distance / self:get_shotgun_push_range(), 0.5, 1)
	local height = mvector3.distance(hit_pos, unit:position()) - 100
	local twist_dir = math.random(2) == 1 and 1 or -1
	local rot_acc = (dir:cross(math.UP) + math.UP * 0.5 * twist_dir) * -1000 * math.sign(height)
	local rot_time = 1 + math.rand(2)
	local nr_u_bodies = unit:num_bodies()
	local i_u_body = 0

	while nr_u_bodies > i_u_body do
		local u_body = unit:body(i_u_body)

		if u_body and u_body:enabled() and u_body:dynamic() then
			local body_mass = u_body:mass()

			World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, Vector3(dir.x, dir.y, dir.z + 0.5) * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
		end

		i_u_body = i_u_body + 1
	end

	managers.mutators:notify(Message.OnShotgunPush, unit, hit_pos, dir, distance, attacker)
end
