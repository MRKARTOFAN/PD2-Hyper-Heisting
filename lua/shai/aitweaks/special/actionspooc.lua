function ActionSpooc:_chk_target_invalid()
	if not self._target_unit then
		return true
	end

	if self._target_unit:base().is_local_player and not self._target_unit:movement():is_SPOOC_attack_allowed() then
		return true
	end

	if self._target_unit:movement():zipline_unit() then
		return true
	end

	local record = managers.groupai:state():criminal_record(self._target_unit:key())
	return not record or record.status == "disabled" or record.status == "dead"
end
local shai_hh_original_actionspooc_anim_act_clbk = ActionSpooc.anim_act_clbk

function ActionSpooc:_shai_hh_apply_non_lethal_kick(target_unit)
	local my_unit = self._unit
	local common_data = self._common_data

	if not alive(my_unit) or not alive(target_unit) or not common_data then
		return
	end

	local char_tweak = common_data.char_tweak or {}
	local damage = char_tweak.non_lethal_kick_damage

	if not damage then
		return
	end

	local my_mov_ext = my_unit:movement()
	local target_mov_ext = target_unit:movement()
	local target_dmg_ext = target_unit:character_damage()

	if not my_mov_ext or not target_mov_ext or not target_dmg_ext then
		return
	end

	local from_pos = my_mov_ext:m_pos()
	local to_pos = target_mov_ext:m_pos()
	local attack_dir = to_pos - from_pos

	if attack_dir:length() < 1 then
		attack_dir = my_mov_ext:m_rot():y()
	else
		attack_dir = attack_dir:normalized()
	end

	local push_mul = char_tweak.non_lethal_kick_push or 600
	local push_vec = attack_dir:with_z(0.1) * push_mul
	local hit_pos = target_mov_ext.m_head_pos and target_mov_ext:m_head_pos() or target_mov_ext:m_pos()

	local attack_data = {
		variant = "melee",
		damage = damage,
		damage_effect = char_tweak.non_lethal_kick_damage_effect or damage,
		attacker_unit = my_unit,
		attack_dir = attack_dir,
		name_id = "spooc",
		push_vel = push_vec,
		col_ray = {
			position = hit_pos,
			ray = attack_dir,
			unit = target_unit
		}
	}
	if target_dmg_ext.damage_melee then
		target_dmg_ext:damage_melee(attack_data)
	elseif target_dmg_ext.damage_mission then
		target_dmg_ext:damage_mission({
			damage = damage,
			col_ray = attack_data.col_ray,
			attacker_unit = my_unit
		})
	end

	if target_mov_ext.push then
		target_mov_ext:push(push_vec)
	elseif target_mov_ext.set_velocity then
		target_mov_ext:set_velocity(push_vec)
	end

	if managers.mutators then
		managers.mutators:_run_func("OnPlayerCloakerKicked", my_unit)
	end

	if managers.modifiers then
		managers.modifiers:run_func("OnPlayerCloakerKicked", my_unit)
	end

	return true
end

--[[function ActionSpooc:anim_act_clbk(unit, action_type) [Karto] Breaks intended half HP damage of cloaker. Back to be evil.
	local common_data = self._common_data 
	local char_tweak = common_data and common_data.char_tweak or nil
	if not char_tweak or not char_tweak.non_lethal_kick_damage then
		return shai_hh_original_actionspooc_anim_act_clbk(self, unit, action_type)
	end
	local target_unit = self._strike_unit or self._target_unit

	if self._hit or not alive(target_unit) then
		return shai_hh_original_actionspooc_anim_act_clbk(self, unit, action_type)
	end

	local did_hh_kick = self:_shai_hh_apply_non_lethal_kick(target_unit)

	if not did_hh_kick then
		return shai_hh_original_actionspooc_anim_act_clbk(self, unit, action_type)
	end

	self._hit = true
	self._action_completed = true

	if self._ext_movement then
		self._ext_movement:drop_held_items()
	end

	if self._expire then
		self:_expire()
	end
end
--]] 