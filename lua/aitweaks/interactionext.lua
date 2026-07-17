local function fray_equipment_blocks_interaction(player, blockers)
	if not blockers then
		return false
	end

	if type(blockers) == "string" then
		blockers = {
			blockers
		}
	end

	for _, blocker in pairs(blockers) do
		if managers.player:has_special_equipment(blocker) then
			local can_pickup = Global.game_settings and Global.game_settings.single_player
				and Network:is_server()
				and managers.player:player_unit() == player
				and managers.player:can_pickup_equipment(blocker)

			if not can_pickup then
				return true
			end
		end
	end

	return false
end

function BaseInteractionExt:can_interact(player)
	if self._host_only and not Network:is_server() then
		return false
	end

	if self._disabled then
		return false
	end

	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if fray_equipment_blocks_interaction(player, self._tweak_data.special_equipment_block) then
		return false
	end

	if not self._tweak_data.special_equipment or self._tweak_data.dont_need_equipment then
		return true
	end

	local special_equipment_data = managers.player:has_special_equipment(self._tweak_data.special_equipment)

	return special_equipment_data
end

function BaseInteractionExt:can_select(player, locator)
	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if fray_equipment_blocks_interaction(player, self._tweak_data.special_equipment_block) then
		return false
	end

	if self._tweak_data.verify_owner and not self:is_owner() then
		return false
	end

	return true
end

function MultipleChoiceInteractionExt:can_interact(player)
	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if fray_equipment_blocks_interaction(player, self._tweak_data.special_equipment_block) then
		return false
	end

	if not self._tweak_data.special_equipment or self._tweak_data.dont_need_equipment then
		return true
	end

	if managers.player:has_special_equipment(self._tweak_data.special_equipment) then
		return true
	end

	if self._tweak_data.possible_special_equipment then
		for _, special_equipment in ipairs(self._tweak_data.possible_special_equipment) do
			if managers.player:has_special_equipment(special_equipment) then
				return true
			end
		end
	end

	return false
end

local fray_get_timer = BaseInteractionExt._get_timer

function BaseInteractionExt:_get_timer()
	local timer = fray_get_timer(self)

	if self.tweak_data ~= "corpse_alarm_pager" and managers.player._syringe_t then
		timer = timer * 0.5
	end

	if self.tweak_data == "first_aid_kit" and managers.player:get_health_ratio_easy() <= 0.5 and managers.player:has_category_upgrade("player", "strong_spirit") then
		timer = timer * 0.5
	end

	return timer
end

local fray_doctor_bag_get_timer = DoctorBagBaseInteractionExt._get_timer

function DoctorBagBaseInteractionExt:_get_timer()
	local timer = fray_doctor_bag_get_timer(self)

	if managers.player:get_health_ratio_easy() <= 0.5 and managers.player:has_category_upgrade("player", "strong_spirit") then
		timer = timer * 0.5
	end

	return timer
end
