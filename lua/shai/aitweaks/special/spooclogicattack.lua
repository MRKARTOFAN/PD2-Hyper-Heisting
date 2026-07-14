function SpoocLogicAttack._upd_spooc_attack(data, my_data)
	if my_data.spooc_attack or data.t <= data.spooc_attack_timeout_t or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local focus_enemy = data.attention_obj

	if not focus_enemy.nav_tracker or not focus_enemy.is_person then
		return
	end

	if not focus_enemy.criminal_record or focus_enemy.criminal_record.status and focus_enemy.criminal_record.status ~= "electrified" then
		return
	end

	local max_spooc_dis = (data.char_tweak.max_spooc_dis or 2000) * (my_data.want_to_take_cover and 0.5 or 1)

	if focus_enemy.reaction < AIAttentionObject.REACT_SHOOT or focus_enemy.dis > max_spooc_dis then
		return
	end

	if not focus_enemy.unit:movement():is_SPOOC_attack_allowed() or focus_enemy.unit:movement():zipline_unit() then
		return
	end

	if not my_data.spooc_attack_delay_t then
		my_data.spooc_attack_delay_t = data.t + math.map_range_clamped(focus_enemy.dis, 0, 500, 0.5, 0)

		return
	elseif my_data.spooc_attack_delay_t > data.t then
		return
	end

	local flying_strike
	if ActionSpooc.chk_can_start_flying_strike(data.unit, focus_enemy.unit) then
		flying_strike = true
	elseif not focus_enemy.verified
		or not ActionSpooc.chk_can_start_spooc_sprint(data.unit, focus_enemy.unit)
		or data.unit:raycast("ray", data.unit:movement():m_head_pos(), focus_enemy.m_head_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"), "ignore_unit", focus_enemy.unit, "report") then
		return
	end

	if my_data.attention_unit ~= focus_enemy.u_key then
		CopLogicBase._set_attention(data, focus_enemy)

		my_data.attention_unit = focus_enemy.u_key
	end

	local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data, flying_strike)

	if action then
		my_data.spooc_attack_delay_t = nil

		my_data.spooc_attack = {
			start_t = data.t,
			target_u_data = focus_enemy,
			action = action,
			flying_strike = flying_strike
		}

		return true
	end
end
Hooks:PostHook(SpoocLogicAttack, "enter", "sh_enter", function(data)
	data.brain:set_update_enabled_state(true)
end)

function SpoocLogicAttack.update(data)
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		return
	end

	local focus_enemy = data.attention_obj

	if my_data.spooc_attack then
		if my_data.spooc_attack.action:complete()
			and focus_enemy
			and focus_enemy.verified
			and (not focus_enemy.criminal_record or not focus_enemy.criminal_record.status)
			and focus_enemy.dis < my_data.weapon_range.close then
			SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
		end

		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	if my_data.wants_stop_old_walk_action then
		if not data.unit:anim_data().to_idle and not data.unit:movement():chk_action_forbidden("walk") then
			data.unit:movement():action_request({
				body_part = 2,
				type = "idle"
			})

			my_data.wants_stop_old_walk_action = nil
		end

		return
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if not focus_enemy or focus_enemy.reaction < AIAttentionObject.REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		return
	end

	if SpoocLogicAttack._upd_spooc_attack(data, my_data) then
		return
	end

	if focus_enemy.reaction >= AIAttentionObject.REACT_COMBAT then
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		CopLogicAttack._upd_combat_movement(data)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function SpoocLogicAttack.queued_update()
end

function SpoocLogicAttack.queue_update()
end

local sh_original_spooc_action_complete_clbk = SpoocLogicAttack.action_complete_clbk

function SpoocLogicAttack._sh_try_request_spooc_warp(data, my_data, action)
	if not Network:is_server() then
		return
	end

	if data.spooc_warped then
		return
	end

	if not action or action:type() ~= "spooc" or not action:complete() then
		return
	end

	local spooc_attack = my_data and my_data.spooc_attack

	if not spooc_attack or not spooc_attack.flying_strike then
		return
	end

	local unit = data.unit

	if not alive(unit) then
		return
	end

	local mov_ext = unit:movement()

	if not mov_ext then
		return
	end

	local focus_enemy = spooc_attack.target_u_data
	local target_pos = focus_enemy and focus_enemy.m_pos or nil
	local from_pos = data.m_pos or mov_ext:m_pos()

	if not target_pos then
		target_pos = from_pos
	end

	local warp_dis = data.char_tweak.spooc_warp_dis or 550
	local warp_pos = target_pos + mov_ext:m_rot():y() * -warp_dis

	local ray_params = {
		allow_entry = false,
		trace = true,
		pos_from = from_pos,
		pos_to = warp_pos
	}

	if managers.navigation:raycast(ray_params) then
		warp_pos = ray_params.trace[1]
	end

	local ground_ray = unit:raycast(
		"ray",
		warp_pos + math.UP * 100,
		warp_pos - math.UP * 500,
		"slot_mask",
		managers.slot:get_mask("AI_graph_obstacle_check"),
		"ray_type",
		"body mover"
	)

	if ground_ray then
		warp_pos = ground_ray.position
	end

	local face_vec = target_pos - warp_pos
	local warp_rot = Rotation(face_vec:to_polar().spin, 0, 0)

	local warp_action = {
		type = "warp",
		body_part = 1,
		position = warp_pos,
		rotation = warp_rot,
		blocks = {
			act = -1,
			walk = -1,
			idle = -1,
			turn = -1,
			light_hurt = -1,
			heavy_hurt = -1,
			hurt = -1,
			expl_hurt = -1,
			fire_hurt = -1,
			taser_tased = -1
		}
	}

	if mov_ext:action_request(warp_action) then
		data.spooc_warped = true

		return true
	end
end

function SpoocLogicAttack._sh_ground_smoke_pos(unit, pos)
	if not alive(unit) or not pos then
		return pos
	end

	local ray = unit:raycast(
		"ray",
		pos + math.UP * 300,
		pos - math.UP * 4000,
		"slot_mask",
		managers.slot:get_mask("AI_graph_obstacle_check"),
		"ray_type",
		"body mover"
	)

	if ray then
		return ray.position
	end

	ray = World:raycast(
		"ray",
		pos + math.UP * 300,
		pos - math.UP * 4000,
		"slot_mask",
		managers.slot:get_mask("world_geometry")
	)

	return ray and ray.position or pos
end

function SpoocLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action and action:type()
	local should_spawn_sh_smoke = false
	local smoke_pos
	local old_smoke_chance

	if action_type == "spooc" then
		data.spooc_warped = nil

		if SpoocLogicAttack._sh_try_request_spooc_warp then
			SpoocLogicAttack._sh_try_request_spooc_warp(data, my_data, action)
		end
		if action:complete()
			and data.char_tweak.spooc_attack_use_smoke_chance
			and data.char_tweak.spooc_attack_use_smoke_chance > 0
			and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance
			and managers.groupai:state():is_smoke_grenade_active() then
			local mov_ext = data.unit:movement()
			local base_pos = mov_ext and mov_ext:m_pos() or data.m_pos

			smoke_pos = SpoocLogicAttack._sh_ground_smoke_pos(data.unit, base_pos)
			should_spawn_sh_smoke = smoke_pos ~= nil
		end

		old_smoke_chance = data.char_tweak.spooc_attack_use_smoke_chance
		data.char_tweak.spooc_attack_use_smoke_chance = 0
	end

	local result

	if sh_original_spooc_action_complete_clbk then
		result = sh_original_spooc_action_complete_clbk(data, action)
	end

	if action_type == "spooc" then
		data.char_tweak.spooc_attack_use_smoke_chance = old_smoke_chance

		if should_spawn_sh_smoke then
			managers.groupai:state():detonate_smoke_grenade(
				smoke_pos + math.UP * 10,
				data.unit:movement():m_head_pos(),
				math.lerp(15, 30, math.random()),
				false
			)
		end

		data.spooc_warped = nil
	end

	return result
end
