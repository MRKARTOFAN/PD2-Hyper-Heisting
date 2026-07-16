PlayerCarry.target_tilt = 0
PlayerCarry.throw_limit_t = 0.2

local _update_check_actions_original = PlayerCarry._update_check_actions
function PlayerCarry:_update_check_actions(t, dt)
	self:_update_hh_action_timers(t, dt)

	return _update_check_actions_original(self, t, dt)
end

function PlayerCarry:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_release and self._throw_time and t and t < self._throw_time

	if input.btn_use_item_press then
		self._throw_down = true
		self._second_press = false
		self._throw_time = t + PlayerCarry.throw_limit_t
	end

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:_is_throwing_projectile() or self:_on_zipline() or self._melee_stunned

		if not action_forbidden then
			managers.player:drop_carry()

			new_action = true
		end
	end

	if self._throw_down then
		if input.btn_use_item_release then
			self._throw_down = false
			self._second_press = false

			return PlayerCarry.super._check_use_item(self, t, input)
		elseif self._throw_time < t then
			if not self._second_press then
				input.btn_use_item_press = true
				self._second_press = true
			end

			return PlayerCarry.super._check_use_item(self, t, input)
		end
	end

	return new_action
end

if PD2FRAY and PD2FRAY:IsOverhaulEnabled() then
	local armor_init = tweak_data.player.damage.ARMOR_INIT
	function PlayerCarry:_get_max_walk_speed(...)
		local multiplier = tweak_data.carry.types[self._tweak_data_name].move_speed_modifier
		multiplier = math.clamp(multiplier * managers.player:upgrade_value("carry", "movement_speed_multiplier", 1), 0, 1)
		if managers.player:has_category_upgrade("player", "armor_carry_bonus") then
			local base_max_armor = armor_init + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
			local mul = managers.player:upgrade_value("player", "armor_carry_bonus", 1)

			for i = 1, base_max_armor, 1 do
				multiplier = multiplier * mul
			end

			multiplier = math.clamp(multiplier, 0, 1)
		end
			
		return PlayerCarry.super._get_max_walk_speed(self, ...) * multiplier
	end
end	
