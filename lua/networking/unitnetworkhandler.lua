Hooks:PostHook(UnitNetworkHandler, "set_health", "fray_set_health_ratio", function(self, unit, percent, max_mul, sender)
	if not alive(unit) or type(percent) ~= "number" or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local char_dmg_ext = unit:character_damage()

	if char_dmg_ext then
		char_dmg_ext._health_ratio = percent / 100
	end
end)

function UnitNetworkHandler:send_drama(drama, sender)
	if not Network:is_server() or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer or type(drama) ~= "number" or drama ~= drama or drama == math.huge or drama == -math.huge then
		return
	end

	local state = managers.groupai and managers.groupai:state()

	if state and state._add_drama then
		state:_add_drama(math.clamp(drama, -1, 1))
	end
end

function UnitNetworkHandler:fray_lvm(sender)
	if not Network:is_server() or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local level_data = Global and Global.level_data

	if not level_data then
		return
	end

	_G.PD2FRAY_LVM = true
	_G.PD2FRAY_LVM_LEVEL = level_data
end

function UnitNetworkHandler:action_spooc_start(unit, target_u_pos, flying_strike, action_id)
	if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local mov_ext = unit:movement()

	if not mov_ext or not mov_ext.action_request then
		return
	end

	local action_desc = {
		block_type = "walk",
		body_part = 1,
		path_index = 1,
		type = "spooc",
		nav_path = {
			unit:position()
		},
		target_u_pos = target_u_pos,
		flying_strike = flying_strike,
		action_id = action_id,
		blocks = {
			act = -1,
			idle = -1,
			turn = -1,
			walk = -1
		}
	}

	if flying_strike then
		action_desc.blocks.light_hurt = -1
		action_desc.blocks.hurt = -1
		action_desc.blocks.heavy_hurt = -1
		action_desc.blocks.expl_hurt = -1
		action_desc.blocks.fire_hurt = -1
		action_desc.blocks.taser_tased = -1
	end

	mov_ext:action_request(action_desc)
end

function UnitNetworkHandler:reload_weapon_cop(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character_and_sender(unit, sender) then
		return
	end

	local mov_ext = alive(unit) and unit:movement()
	local inventory = alive(unit) and unit:inventory()
	local weapon = inventory and inventory:equipped_unit()
	local weapon_base = alive(weapon) and weapon:base()
	local ammo_base = weapon_base and weapon_base.ammo_base and weapon_base:ammo_base()

	if not mov_ext or not ammo_base or not ammo_base.set_ammo_remaining_in_clip then
		return
	end

	local current_action = mov_ext.get_action and mov_ext:get_action(3)

	if current_action and current_action.type and current_action:type() == "shoot" then
		ammo_base:set_ammo_remaining_in_clip(0)
	elseif mov_ext.action_request then
		mov_ext:action_request({
			body_part = 3,
			type = "reload"
		})
	end
end
