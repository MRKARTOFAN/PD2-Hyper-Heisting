local world_g = World
local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add

function PlayerMovement:play_taser_boom(local_unit)
	local pos = Vector3()
	
	if local_unit then
		mvec3_set(pos, self._m_head_rot:y())
		mvec3_mul(pos, 20)
		mvec3_add(pos, self:m_head_pos())
	else
		mvec3_set(pos, self._unit:movement():m_pos())
	end

	local effect = world_g:effect_manager():spawn({
		effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/electric_explosion"),
		position = pos,
		normal = math.UP
	})

	if effect then
		world_g:effect_manager():fade_kill(effect)
	end

	self._unit:sound():play("c4_explode_metal")
end

local fray_subtract_stamina = PlayerMovement.subtract_stamina

function PlayerMovement:subtract_stamina(value)
	if managers.player._syringe_stam then
		return
	end

	return fray_subtract_stamina(self, value)
end

function PlayerMovement:is_above_stamina_threshold()
	if managers.player._syringe_stam then
		return true
	end

	local threshold = tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
	
	if managers.player:has_category_upgrade("player", "start_action_stam_drain_reduct") then
		threshold = threshold * 0.5
	end

	return threshold < self._stamina
end

local valid_spooc_states = {
	standard = true,
	carry = true,
	bipod = true,
	tased = true
}

function PlayerMovement:on_SPOOCed(enemy_unit)
	if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
		self._current_state:discharge_melee()

		return "countered"
	end

	if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
		return true
	end
	
	local push_mul = 2000
	local height_mul = 0.2
	
	if managers.modifiers and managers.modifiers:check_boolean("woahtheyjomp") then
		push_mul = 4000
		height_mul = 0.1
	end
	
	local push_vec = Vector3()
	mvector3.direction(push_vec, enemy_unit:movement():m_head_pos(), self._unit:movement():m_pos())
	mvector3.normalize(push_vec)
	mvector3.set_z(push_vec, height_mul)
	local attack_data = {
		attacker_unit = enemy_unit,
		is_cloaker_kick = true,
		melee_armor_piercing = true,
		damage = 23.75,
		push_vel = push_vec * push_mul
	}
	local successful = self._unit:character_damage():damage_melee(attack_data)
		
	if successful then
		self._spooked_t = TimerManager:game():time()
	end
	
	local state = managers.modifiers:modify_value("PlayerMovement:OnSpooked")
	
	if state then
		if valid_spooc_states[self._current_state_name] then
			managers.player:set_player_state(state)
		end
	end
		
	return successful
end
