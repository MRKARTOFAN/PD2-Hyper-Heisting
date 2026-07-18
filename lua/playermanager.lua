PlayerManager._style_data = {}
PlayerManager._style_points = 0
PlayerManager._style_tier = 0
PlayerManager._style_pause = nil

local world_g = World
local mvec3_norm = mvector3.normalize
local fray_nss_result
local fray_nss_weapon_scan_done
local fray_nss_sent
local fray_nss_level_data
local lvm
local lvm_sent
local lvm_level

local function fray_reset_nss_state()
	local level_data = Global.level_data

	if level_data == fray_nss_level_data then
		return
	end

	fray_nss_level_data = level_data
	fray_nss_result = nil
	fray_nss_weapon_scan_done = nil
	fray_nss_sent = nil

	if _G.PD2FRAY_NSS_LEVEL ~= level_data then
		_G.PD2FRAY_NSS = nil
	end
end

local function fray_mark_nss()
	fray_nss_result = true
	_G.PD2FRAY_NSS = true
	_G.PD2FRAY_NSS_LEVEL = Global.level_data

	if Network:is_client() and not fray_nss_sent then
		local session = managers.network and managers.network:session()
		if session then
			session:send_to_host("fray_nss")
			fray_nss_sent = true
		end
	end
end

local function fray_probe_shaker(camera, effect, offset)
	local ok, result = pcall(camera.play_shaker, camera, effect, 0, 1, offset)

	if ok and result and result ~= 0 and camera.stop_shaker then
		pcall(camera.stop_shaker, camera, result)
	end

	return ok, result
end

function PD2FRAY_CHECK_NSS()
	fray_reset_nss_state()

	if _G.PD2FRAY_NSS and _G.PD2FRAY_NSS_LEVEL == Global.level_data then
		return true
	end

	if fray_nss_result ~= nil then
		return fray_nss_result
	end

	if _G.IS_VR then
		fray_nss_result = false
		return false
	end

	if not fray_nss_weapon_scan_done then
		if not tweak_data.weapon then
			return
		end

		local has_weapon_shake = false
		local all_weapon_shake_disabled = true

		for _, weapon_data in pairs(tweak_data.weapon) do
			local shake = weapon_data.shake

			if shake and shake.fire_multiplier ~= nil and shake.fire_steelsight_multiplier ~= nil then
				has_weapon_shake = true

				if shake.fire_multiplier ~= 0 or shake.fire_steelsight_multiplier ~= 0 then
					all_weapon_shake_disabled = false
					break
				end
			end
		end

		fray_nss_weapon_scan_done = true

		if has_weapon_shake and all_weapon_shake_disabled then
			fray_mark_nss()

			return true
		end
	end

	local player_unit = managers.player and managers.player:player_unit()
	local camera = alive(player_unit) and player_unit:camera()

	if not camera or not camera.play_shaker then
		return
	end

	local rot_ok, rot_result = fray_probe_shaker(camera, "fire_weapon_rot", 0)
	local kick_ok, kick_result = fray_probe_shaker(camera, "fire_weapon_kick", 0.15)

	if not rot_ok or not kick_ok then
		return
	end

	if (not rot_result or rot_result == 0) and (not kick_result or kick_result == 0) then
		fray_mark_nss()

		return true
	end

	fray_nss_result = false

	return false
end

local function fray_mark_lvm()
	lvm = true
	_G.PD2FRAY_LVM = true
	_G.PD2FRAY_LVM_LEVEL = Global.level_data

	if Network:is_client() and not lvm_sent then
		local session = managers.network and managers.network:session()
		if session then
			session:send_to_host("fray_lvm")
			lvm_sent = true
		end
	end
end

function PD2FRAY_CHECK_LVM()
	local level_data = Global.level_data

	if lvm_level ~= level_data then
		lvm_level = level_data
		lvm = nil
		lvm_sent = nil

		if _G.PD2FRAY_LVM_LEVEL ~= level_data then
			_G.PD2FRAY_LVM = nil
		end
	end

	if _G.PD2FRAY_LVM and _G.PD2FRAY_LVM_LEVEL == level_data then
		return true
	end

	if lvm ~= nil then
		return lvm
	end

	local enemy = managers.enemy
	local gameplay = managers.game_play_central

	if not enemy or not gameplay then
		return
	end

	lvm = enemy:corpse_limit() == 0
		and enemy:shield_limit() == 0
		and enemy._shield_disposal_lifetime == 0
		and gameplay._block_bullet_decals == true
		and gameplay._block_blood_decals == true

	if lvm then
		fray_mark_lvm()
	end

	return lvm
end

function PlayerManager:clbk_copr_ability_ended()
	self:deactivate_temporary_upgrade("temporary", "copr_ability")

	local player_unit = self:local_player()
	local character_damage = alive(player_unit) and player_unit:character_damage()

	if character_damage then
		local out_of_health = character_damage:health_ratio() < self:upgrade_value("player", "copr_static_damage_ratio", 0)
		local risen_from_dead = self:get_property("copr_risen", false) == true

		character_damage:on_copr_ability_deactivated()

		if out_of_health or risen_from_dead then
			character_damage:force_into_bleedout(false, risen_from_dead)
		end
	end

	self:set_property("copr_risen", nil)
	
	managers.hud:set_copr_indicator(false)
end

function PlayerManager:on_enter_custody(_player, already_dead)
	local player = _player or self:player_unit()

	if not player then
		Application:error("[PlayerManager:on_enter_custody] Unable to get player")

		return
	end

	if player == self:player_unit() then
		local equipped_grenade = managers.blackmarket:equipped_grenade()

		if equipped_grenade and tweak_data.blackmarket.projectiles[equipped_grenade] and tweak_data.blackmarket.projectiles[equipped_grenade].ability then
			self:reset_ability_hud()
		end

		self:set_property("copr_risen_cooldown_added", nil)
		
		self._style_data = {}
		self._style_points = 0
		self._style_tier = 0
		self._style_pause = nil
	end

	managers.mission:call_global_event("player_in_custody")

	local peer_id = managers.network:session():local_peer():id()

	if self._super_syndrome_count and self._super_syndrome_count > 0 and not self._action_mgr:is_running("stockholm_syndrome_trade") then
		self._action_mgr:add_action("stockholm_syndrome_trade", StockholmSyndromeTradeAction:new(player:position(), peer_id))
	end

	self:force_drop_carry()
	managers.statistics:downed({
		death = true
	})

	if not already_dead then
		player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
		managers.groupai:state():on_player_criminal_death(peer_id)
	end

	self._listener_holder:call(self._custody_state, player)
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:base():_unregister()
	World:delete_unit(player)
	managers.hud:remove_interact()
end

function PlayerManager:_attempt_copr_ability()
	if self:has_activate_temporary_upgrade("temporary", "copr_ability") then
		return false
	end

	local character_damage = self:local_player():character_damage()
	local character_movement = self:local_player():movement()
	local current_state = character_movement:current_state()
	local duration = self:upgrade_value("temporary", "copr_ability")[2]
	local now = managers.game_play_central:get_heist_timer()

	managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)

	local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)

	self:set_property("copr_risen", is_downed)

	if is_downed then
		character_damage:revive(true)
		self:register_message("ability_activated", "copr_ability_downed_cooldown_add", callback(self, self, "add_cooldown_copr"))
	end
	
	if current_state._running then
		current_state:_interupt_action_running(self:player_timer():time())
	end
	
	character_movement:subtract_stamina(character_movement._stamina)
	self:activate_temporary_upgrade("temporary", "copr_ability")

	local expire_time = self:get_activate_temporary_expire_time("temporary", "copr_ability")

	managers.enemy:add_delayed_clbk("copr_ability_active", callback(self, self, "clbk_copr_ability_ended"), expire_time)
	managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, duration)

	local bonus_health = self:upgrade_value("player", "copr_activate_bonus_health_ratio", tweak_data.upgrades.values.player.copr_activate_bonus_health_ratio[1])

	character_damage:restore_health(bonus_health)
	character_damage:set_armor(0)
	character_damage:send_set_status()

	local speed_up_on_kill_time = self:upgrade_value("player", "copr_speed_up_on_kill", 0)

	if speed_up_on_kill_time > 0 then
		local function speed_up_on_kill_func()
			managers.player:speed_up_grenade_cooldown(speed_up_on_kill_time)
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_copr_ability", speed_up_on_kill_func)
	end

	character_damage:on_copr_ability_activated()

	self._copr_kill_life_leech_num = 0
	local static_damage_ratio = self:upgrade_value("player", "copr_static_damage_ratio", 0)

	managers.hud:set_copr_indicator(true, static_damage_ratio)
	
	return true
end

function PlayerManager:_chk_fellow_crimin_proximity(unit)
	local players_nearby = 0
		
	local enemies = world_g:find_units_quick(unit, "sphere", unit:position(), 1500, managers.slot:get_mask("criminals_no_deployables"))

	players_nearby = #enemies
		
	return players_nearby
end

function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = 1
	local armor_penalty = self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1))
	multiplier = multiplier + armor_penalty - 1

	if bonus_multiplier then
		multiplier = multiplier + bonus_multiplier - 1
	end

	if speed_state then
		multiplier = multiplier + self:upgrade_value("player", speed_state .. "_speed_multiplier", 1) - 1
		multiplier = multiplier + self:upgrade_value("player", "mrwi_" .. speed_state .. "_speed_multiplier", 1) - 1
	end
	
	if managers.player:has_category_upgrade("player", "perkdeck_movespeed_mult") then
		multiplier = multiplier * managers.player:upgrade_value("player", "perkdeck_movespeed_mult", 1)
	end
		
	if managers.player:has_category_upgrade("player", "criticalmode") then
		multiplier = multiplier * 1.25
	end

	multiplier = multiplier + self:get_hostage_bonus_multiplier("speed") - 1
	multiplier = multiplier + self:upgrade_value("player", "movement_speed_multiplier", 1) - 1

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_speed_multiplier", 1) - 1
	end

	if self:has_category_upgrade("player", "secured_bags_speed_multiplier") then
		local bags = 0
		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_speed_multiplier", 1) - 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") then
		multiplier = multiplier * (tweak_data.upgrades.berserker_movement_speed_multiplier or 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "movement_speed")
		multiplier = multiplier * (1 + managers.player:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	local damage_speed_multiplier = managers.player:temporary_upgrade_value("temporary", "damage_speed_multiplier", managers.player:temporary_upgrade_value("temporary", "team_damage_speed_multiplier_received", 1))
	multiplier = multiplier * damage_speed_multiplier

	if self:has_category_upgrade("player", "hh_armorer_movement") then
		local armor_movement = self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1))
		multiplier = multiplier + (1 - armor_movement) * 0.2
	end

	if self:has_category_upgrade("player", "hh_yakuza_speed") then
		local player_unit = self:player_unit()
		local damage_ext = alive(player_unit) and player_unit:character_damage()
		local bonus = damage_ext and damage_ext:armor_ratio() < 0.5 and 0.2 or 0.1
		multiplier = multiplier * (1 + bonus)
	end

	return multiplier
end

local fray_health_skill_addend = PlayerManager.health_skill_addend

function PlayerManager:health_skill_addend()
	return fray_health_skill_addend(self) + self:upgrade_value("player", "health_increase", 0)
end

local fray_max_health = PlayerManager.max_health

function PlayerManager:max_health()
	if self:has_category_upgrade("player", "hh_yakuza_base") then
		return 1 / (tweak_data.gui.stats_present_multiplier or 10)
	end

	local health = fray_max_health(self) * self:upgrade_value("player", "health_decrease_2_decrease_harder", 1)
	local bonus = 0

	if self:has_category_upgrade("player", "hh_muscle_health_1") then
		bonus = bonus + 0.3
	end

	if self:has_category_upgrade("player", "hh_muscle_health_2") then
		bonus = bonus + 0.3
	end

	if self:has_category_upgrade("player", "hh_grinder_health_1") then
		bonus = bonus + 0.3
	end

	if self:has_category_upgrade("player", "hh_grinder_health_2") then
		bonus = bonus + 0.3
	end

	return health * (1 + bonus)
end

local fray_body_armor_skill_addend = PlayerManager.body_armor_skill_addend

function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = fray_body_armor_skill_addend(self, override_armor)

	if self:has_category_upgrade("player", "armor_conversion") then
		local health_multiplier = self:health_skill_multiplier()
		local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend()) * health_multiplier
		addend = addend + max_health * self:upgrade_value("player", "armor_conversion", 0)
	end

	return addend
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "passive_dodge_chance", 0)
	chance = chance + self:upgrade_value("player", "mrwi_dodge_chance", 0)
	local dodge_shot_gain = self:_dodge_shot_gain()
	local player_unit = self:player_unit()

	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self:player_unit()) then
			if smoke_screen:mine() then
				chance = chance * self:upgrade_value("player", "sicario_multiplier", 1)
				dodge_shot_gain = dodge_shot_gain * self:upgrade_value("player", "sicario_multiplier", 1)
			else
				chance = chance + smoke_screen:dodge_bonus()
			end
		end
	end
	
	if player_unit then
		local wavedash_active = player_unit:movement():current_state()._wave_dash_t
		
		if wavedash_active and player_unit:movement():is_above_stamina_threshold() then
			chance = chance + 0.05
		end
	end
	
	if self:has_category_upgrade("player", "highvigour_aced") then
		chance = chance + 0.1
	end

	chance = chance + dodge_shot_gain
	chance = chance + self:upgrade_value("player", "tier_dodge_chance", 0)

	if running and player_unit and player_unit:movement():is_above_stamina_threshold() then
		chance = chance + self:upgrade_value("player", "run_dodge_chance", 0)
	end

	if crouching then
		chance = chance + self:upgrade_value("player", "crouch_dodge_chance", 0)
	end

	if on_zipline then
		chance = chance + self:upgrade_value("player", "on_zipline_dodge_chance", 0)
	end

	local detection_risk_add_dodge_chance = managers.player:upgrade_value("player", "detection_risk_add_dodge_chance")
	chance = chance + self:get_value_from_risk_upgrade(detection_risk_add_dodge_chance, detection_risk)
	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
	chance = chance + self:upgrade_value("team", "crew_add_dodge", 0)
	chance = chance + self:temporary_upgrade_value("temporary", "pocket_ecm_kill_dodge", 0)

	local damage_ext = alive(player_unit) and player_unit:character_damage()

	if damage_ext and self:has_category_upgrade("player", "hh_biker_health_dodge") then
		chance = chance + math.floor((1 - damage_ext:health_ratio()) * 10) * 0.01
	end

	if damage_ext and self:has_category_upgrade("player", "hh_biker_armor_dodge") then
		chance = chance + math.floor((1 - damage_ext:armor_ratio()) * 10) * 0.01
	end

	return chance
end

function PlayerManager:speak(message, arg1, arg2)
	if self:player_unit() and self:player_unit():sound() then
		self:player_unit():sound():say(message, arg1, arg2)
	end
end

function PlayerManager:get_health_ratio_easy()
	local player_unit = self:player_unit()
	local damage_ext = player_unit:character_damage()
	return damage_ext:health_ratio()
end

function PlayerManager:consume_bloodthirst_reload()	
	if self._melee_reload_speed_active then
		--log("*toilet flush noise*")
		self._enemies_killed_bloodthirst = nil
		self._melee_damage_mult = nil
		self._melee_reload_speed_active = nil
		self._reload_speed_bonus = nil
	end
end

local fray_damage_reduction_skill_multiplier = PlayerManager.damage_reduction_skill_multiplier

function PlayerManager:damage_reduction_skill_multiplier(damage_type, sneakier_activated)
	local multiplier = fray_damage_reduction_skill_multiplier(self, damage_type)
	multiplier = multiplier * self:upgrade_value("player", "claim_their_bones_damage_reduction", 1)

	if sneakier_activated then
		multiplier = multiplier * 0.75
	end

	local player_unit = self:player_unit()
	local damage_ext = alive(player_unit) and player_unit:character_damage()

	if alive(player_unit) and player_unit:movement()._current_state_name == "driving" then
		multiplier = multiplier * 0.33
	end

	if self:has_category_upgrade("player", "hh_yakuza_resistance") and damage_ext then
		multiplier = multiplier * (damage_ext:armor_ratio() < 0.5 and 0.7 or 0.85)
	end

	if self:has_category_upgrade("player", "hh_grinder_reduction") and damage_ext and damage_ext:hh_grinder_damage_reduction_active() then
		local armor_id = managers.blackmarket:equipped_armor(true, true)
		local armor_data = tweak_data.blackmarket.armors[armor_id]
		local tier = armor_data and armor_data.upgrade_level or 1
		multiplier = multiplier * (1 - math.max(0, tier - 1) * 0.05)
	end

	return multiplier
end

local fray_drop_carry = PlayerManager.drop_carry

function PlayerManager:drop_carry(zipline_unit)
	if not self:get_my_carry_data() then
		return
	end

	fray_drop_carry(self, zipline_unit)
	self._carry_blocked_cooldown_t = Application:time() + 0.2
end

local fray_on_killshot = PlayerManager.on_killshot

function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id)
	fray_on_killshot(self, killed_unit, variant, headshot, weapon_id)

	if not alive(killed_unit) or not killed_unit:base() or CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local player_unit = self:player_unit()
	local damage_ext = alive(player_unit) and player_unit:character_damage()

	if not damage_ext then
		return
	end

	self:add_style("kill")

	local current_state = self:get_current_state()
	local equipped_unit = current_state and current_state._equipped_unit
	local equipped_base = alive(equipped_unit) and equipped_unit:base()
	local weapon_melee = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and true
	local effect_sync_index = nil

	if equipped_base and self:has_category_upgrade("player", "panic_suppression") then
		local suppression_amount = equipped_base._suppression or 0
		local pos = killed_unit:position()
		local enemies = world_g:find_units_quick(killed_unit, "sphere", pos, 600, 12, 21)

		for i = 1, #enemies do
			local unit = enemies[i]

			if unit:character_damage() and unit:character_damage().build_suppression then
				unit:character_damage():build_suppression(suppression_amount, -1, nil)
			end
		end
	end

	local bull = self:has_category_upgrade("player", "ridethebull_basic")
	local aced_bull = self:has_category_upgrade("player", "ridethebull_aced")
	local bull_melee_kill = variant == "melee" or weapon_melee

	if equipped_base and bull and equipped_base.on_bull_event and ((aced_bull and bull_melee_kill) or (not bull_melee_kill and equipped_base:fire_mode() == "auto")) then
		equipped_base:on_bull_event(aced_bull)
	end

	if headshot and (variant == "melee" or weapon_melee) then
		local pos = killed_unit:movement():m_head_pos()

		world_g:effect_manager():spawn({
			effect = Idstring("effects/pd2_mod_hh/particles/character/gore_explosion"),
			position = pos,
			normal = math.UP
		})

		player_unit:sound():play("expl_gen_head", nil, nil)
	end

	if headshot and equipped_base and self:has_category_upgrade("player", "fineredmist_basic") and equipped_base:fire_mode() == "single" then
		local pos = killed_unit:movement():m_head_pos()

		world_g:effect_manager():spawn({
			effect = Idstring("effects/pd2_mod_hh/particles/character/gore_explosion"),
			position = pos,
			normal = math.UP
		})

		player_unit:sound():play("expl_gen_head", nil, nil)

		local damage = 30
		local range = 200

		if self:has_category_upgrade("player", "fineredmist_aced") then
			range = 400
			effect_sync_index = 2

			player_unit:sound():play("split_gen_body", nil, nil)
		else
			effect_sync_index = 1
		end

		local enemies = world_g:find_units_quick(killed_unit, "sphere", pos, range, managers.slot:get_mask("enemies", "civilians"))
		local obstruction_slotmask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")

		for i = 1, #enemies do
			local enemy = enemies[i]
			local dmg_ext = enemy:character_damage()

			if dmg_ext and dmg_ext.damage_simple then
				local center_of_mass = enemy:movement():m_com()
				local obstructed = enemy:raycast("ray", pos, center_of_mass, "slot_mask", obstruction_slotmask, "report")

				if not obstructed then
					local attack_dir = center_of_mass - pos
					mvec3_norm(attack_dir)

					dmg_ext:damage_simple({
						damage = damage,
						attacker_unit = player_unit,
						guaranteed_stagger = true,
						pos = center_of_mass,
						attack_dir = attack_dir,
						weapon_unit = equipped_unit
					})
				end
			end
		end
	end

	if self:has_category_upgrade("player", "momentummaker_basic") then
		if variant == "melee" or weapon_melee then
			self._melee_damage_mult = nil

			if self._reload_speed_bonus then
				self._enemies_killed_bloodthirst = nil
				self._melee_reload_speed_active = true
			end
		elseif not self._melee_damage_mult or self._melee_damage_mult < 6 then
			if not self._enemies_killed_bloodthirst then
				self._enemies_killed_bloodthirst = 1
			else
				self._enemies_killed_bloodthirst = self._enemies_killed_bloodthirst + 1
			end

			if self._enemies_killed_bloodthirst > 1 then
				if not self._reload_speed_bonus or not self._melee_damage_mult then
					self._reload_speed_bonus = 0.05
					self._melee_damage_mult = 1
				else
					self._reload_speed_bonus = self._reload_speed_bonus + 0.05
					self._melee_damage_mult = self._melee_damage_mult + 1
				end

				self._enemies_killed_bloodthirst = nil
			end
		end
	end

	local t = Application:time()

	if variant ~= "melee" and equipped_base and self:has_category_upgrade("player", "cool_hunting_aced") and equipped_base:is_category("shotgun") then
		self._cool_chain_mul = self._cool_chain_mul and self._cool_chain_mul - 0.05 or 0.95
		self._cool_hunting_t = t + 2
	end

	if damage_ext._armor_grinding and self:has_category_upgrade("player", "armor_grinding_regen_t_on_kill") then
		local elapsed_divisor = self:upgrade_value("player", "armor_grinding_regen_t_on_kill", 1)
		damage_ext._armor_grinding.elapsed = damage_ext._armor_grinding.elapsed + damage_ext._armor_grinding.target_tick / elapsed_divisor
	end

	local grenade_data = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()]
	local grenade_cooldown = grenade_data and grenade_data.base_cooldown

	if grenade_cooldown and self:has_category_upgrade("player", "blood_boom") then
		self:speed_up_grenade_cooldown(grenade_cooldown * 0.02)
	end

	if self:has_category_upgrade("player", "vampirism_aced") or self:has_category_upgrade("player", "dark_metamorphosis_aced") then
		damage_ext:restore_health((variant == "melee" or weapon_melee) and 0.6 or 0.2, true)
	elseif (variant == "melee" or weapon_melee) and (self:has_category_upgrade("player", "vampirism_basic") or self:has_category_upgrade("player", "dark_metamorphosis_basic")) then
		damage_ext:restore_health(0.3, true)
	end

	if self:has_category_upgrade("player", "yield_my_flesh_melee_damage_taken_multiplier") then
		self:reset_yield_my_flesh_damage_ratio()
	end

	if self:has_category_upgrade("player", "hh_muscle_regen") then
		self._hh_muscle_regen_kills = (self._hh_muscle_regen_kills or 0) + 1
	end

	if self:has_category_upgrade("player", "hh_grinder_health_1") then
		damage_ext:add_hh_grinder_stack()
	end

	if self:has_category_upgrade("player", "hh_biker_base") and (not self._hh_biker_lockout_t or self._hh_biker_lockout_t <= t) then
		local reward = 5 / (tweak_data.gui.stats_present_multiplier or 10)
		damage_ext:restore_health(reward, true)
		damage_ext:restore_armor(reward)
		self._hh_biker_rewards = (self._hh_biker_rewards or 0) + 1

		if self._hh_biker_rewards >= 4 then
			local cooldown = 4

			if self:has_category_upgrade("player", "hh_biker_health_cooldown") then
				cooldown = cooldown - math.floor((1 - damage_ext:health_ratio()) * 10) * 0.1
			end

			if self:has_category_upgrade("player", "hh_biker_armor_cooldown") then
				cooldown = cooldown - math.floor((1 - damage_ext:armor_ratio()) * 10) * 0.1
			end

			self._hh_biker_lockout_t = t + math.max(2, cooldown)
			self._hh_biker_rewards = 0
		end
	end

	if self:has_category_upgrade("player", "hh_yakuza_cheat_death") and damage_ext._hh_yakuza_cheat_death_t then
		damage_ext._hh_yakuza_cheat_death_t = math.max(t, damage_ext._hh_yakuza_cheat_death_t - 1)
	end

	return effect_sync_index
end

function PlayerManager:add_yield_my_flesh_health_damage(health_damage_ratio)
	self._yield_my_flesh_damage_ratio = math.min(1, (self._yield_my_flesh_damage_ratio or 0) + health_damage_ratio)
end

function PlayerManager:yield_my_flesh_damage_ratio()
	return self._yield_my_flesh_damage_ratio or 0
end

function PlayerManager:reset_yield_my_flesh_damage_ratio()
	self._yield_my_flesh_damage_ratio = nil
end

Hooks:PostHook(PlayerManager, "update", "fray_update", function(self, t, dt)
	local player_unit = self:player_unit()

	if alive(player_unit) then
		if not managers.groupai:state():whisper_mode() then
			self:upd_style(t, dt)
		end

		if self:has_category_upgrade("player", "pop_pop") then
			self:upd_pop_pop(t)
		end

		if self._magic_bullet_aced_t and self._magic_bullet_aced_t < t then
			self._magic_bullet_aced_t = nil
		end

		if self._syringe_t and self._syringe_t < t then
			self._syringe_stam = nil
			self._syringe_t = nil
		end

		if self._cool_hunting_t and self._cool_hunting_t < t then
			self._cool_chain_mul = nil
			self._cool_hunting_t = nil
		end

		if self._max_messiah_charges > 0 and self._messiah_charges < self._max_messiah_charges then
			if not self._messiah_recharge_t then
				self._messiah_recharge_t = t + 240
			elseif self._messiah_recharge_t < t then
				self:_on_messiah_recharge_event()
			end
		end
	end

	PD2FRAY_CHECK_NSS()
	PD2FRAY_CHECK_LVM()

	if not self:has_category_upgrade("player", "hh_muscle_regen") then
		return
	end

	self._hh_muscle_regen_t = self._hh_muscle_regen_t or t + 5

	if self._hh_muscle_regen_t > t then
		return
	end

	if alive(player_unit) then
		local bonus = (self._hh_muscle_regen_kills or 0) * 0.001
		player_unit:character_damage():restore_health(0.01 + bonus)
	end

	self._hh_muscle_regen_kills = nil
	self._hh_muscle_regen_t = t + 5
end)

function PlayerManager:upd_style(t, dt)
	if self._style_pause then
		self._style_pause = self._style_pause - dt
		
		if self._style_pause > 0 then
			return
		end
	end
	
	self._style_pause = nil

	if self._style_tier > 0 then
		local player_unit = self:player_unit()
		local player_mov_ext = player_unit:movement()
		local player_dmg_ext = player_unit:character_damage()
		
		local tier_mul = 0.5 + self._style_tier / 2
		local drain = 0.066
		
		if not player_mov_ext._attackers or not next(player_mov_ext._attackers) then
			drain = drain * 2
		end
		
		if player_dmg_ext._supperssion_data.value then
			drain = drain * 0.75
		end
		
		drain = drain * tier_mul
		
		self._style_points = self._style_points - drain * dt
		
		if self._style_points <= 0 then
			self._style_points = 0
			self._style_tier = 0
		else
			self._style_points = math.clamp(self._style_points, 0, 6.99)
			self._style_tier = math.ceil(self._style_points)
		end
	end
end

function PlayerManager:pause_style(time)
	if managers.groupai:state():whisper_mode() then
		return
	end

	if self._style_pause then
		self._style_pause = self._style_pause + time
	else
		self._style_pause = time
	end
end

function PlayerManager:add_style(event)
	if managers.groupai:state():whisper_mode() then
		return
	end

	local style_tweak = tweak_data.style_meter_events[event]
	
	if not style_tweak then
		return
	end
	
	local t = Application:time()
	local event_data = self._style_data[event]
	local amount = style_tweak.amount
	
	if event_data then
		if event_data.expire_t < t then
			event_data.stale_value = 1 
			event_data.expire_t = t
		end
	
		if style_tweak.amount_min_mul and event_data.stale_value == style_tweak.stale_max then
			amount = style_tweak.amount_min_mul
		else
			amount = amount / event_data.stale_value
			
			if style_tweak.style_pause_t then
				if self._style_pause then
					self._style_pause = self._style_pause + style_tweak.style_pause_t
				else
					self._style_pause = style_tweak.style_pause_t
				end
			end
		end
		
		local stale_factor = style_tweak.stale_add
		local stale_expire_t = style_tweak.stale_expire_t
		
		if event_data.stale_value < style_tweak.stale_max then
			event_data.stale_value = self._style_data[event].stale_value + stale_factor
		end
		
		event_data.expire_t = event_data.expire_t + stale_expire_t
	else
		local stale_factor = style_tweak.stale_add
		local stale_expire_t = style_tweak.stale_expire_t
		
		self._style_data[event] = {stale_value = stale_factor, expire_t = t + stale_expire_t}
	end

	self._style_points = self._style_points + amount
	self._style_tier = math.ceil(self._style_points)
end

function PlayerManager:activate_heal_upgrades(token, syringebasic, syringeaced)
	if token then
		local player_unit = self:player_unit()
		player_unit:character_damage():activate_jackpot_token()
	end
	
	if syringebasic then
		local t = Application:time()
		self._syringe_t = t + 15
		self._syringe_stam = syringeaced 
	end
end

function PlayerManager:upd_pop_pop(t)
	--log("hmm")
	local player_unit = self:player_unit()

	if not player_unit then
		--log("how")
		self._pop_pop_mul = nil
		return
	end
	
	if not player_unit:movement():current_state()._shooting_t_pop then
		--log("hmm")
		self._pop_pop_mul = nil
		return
	end
	
	local weapon_unit = self:equipped_weapon_unit()
	
	if not weapon_unit or weapon_unit:base():fire_mode() == "single" then
		--log("nani")
		return
	end
	
	local state = player_unit:movement():current_state()
	
	if state._shooting_t_pop then
		local pop_t = state._shooting_t_pop - t
		pop_t = math.max(pop_t, 0)
		--log("pop_t is " .. tostring(pop_t) .. "")
		local lerp_value = math.clamp(pop_t, 0, 3) / 3
		local pop_mul = math.lerp(0.25, 0, lerp_value)
		
		self._pop_pop_mul = 0 - pop_mul
		
		--log("pop is " .. tostring(self._pop_pop_mul) .. "")
	else
		--log("aargh")
		self._pop_pop_mul = nil
	end
		
end

function PlayerManager:on_headshot_dealt()
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	self._message_system:notify(Message.OnHeadShot, nil, nil)

	local t = Application:time()

	local damage_ext = player_unit:character_damage()
	local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)
	local regen_armor_t_chk = not self._on_headshot_dealt_t or self._on_headshot_dealt_t and self._on_headshot_dealt_t < t

	if damage_ext and regen_armor_bonus > 0 and regen_armor_t_chk then
		damage_ext:restore_armor(regen_armor_bonus)
		self._on_headshot_dealt_t = t + 10
	end

	local regen_health_bonus = self:upgrade_value("player", "headshot_regen_health_bonus", 0)
	local regen_health_t_chk = not self._fray_headshot_health_t or self._fray_headshot_health_t <= t

	if damage_ext and regen_health_bonus > 0 and regen_health_t_chk then
		damage_ext:restore_health(regen_health_bonus, true)
		self._fray_headshot_health_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
	end
	
	if damage_ext and self:has_category_upgrade("player", "jackpot_safety") and not damage_ext:has_jackpot_token() and player_unit:movement() then	
		local cur_state = player_unit:movement():current_state_name()
		local state_chk = cur_state == "standard" or cur_state == "carry" or cur_state == "bipod"
		
		if state_chk then
			if not self._safety_headshot_t or self._safety_headshot_t and self._safety_headshot_t < t then
				damage_ext:activate_jackpot_token()
				self._safety_headshot_t = t + 10
			end
		end
	end
	
	local weapon_unit = self:equipped_weapon_unit()
	
	if self:has_category_upgrade("player", "magic_bullet_basic") then
		if weapon_unit and weapon_unit:base():is_category("pistol", "smg", "assault_rifle", "snp") then
			self:on_ammo_increase(1)
		end
	end
	
	if self:has_category_upgrade("player", "magic_bullet_aced") then
		if weapon_unit and weapon_unit:base():is_category("pistol", "smg", "assault_rifle", "snp") then
			self._magic_bullet_aced_t = t + 5
		end
	end

	if self:has_category_upgrade("player", "hh_grinder_headshot") and (not self._hh_grinder_headshot_t or self._hh_grinder_headshot_t <= t) then
		damage_ext:add_hh_grinder_stack()
		self._hh_grinder_headshot_t = t + 3
	end

end

function PlayerManager:do_comeback_blast()
	local player_unit = self:player_unit()
	
	if not player_unit then
		return
	end
	
	local pos = player_unit:movement():m_head_pos()
	
	local enemies = world_g:find_units_quick(player_unit, "sphere", pos, 400, managers.slot:get_mask("enemies"))
	
	for _, enemy in ipairs(enemies) do
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_simple then
			local center_of_mass = enemy:movement():m_com()
			local obstructed = enemy:raycast("ray", pos, center_of_mass, "slot_mask", obstruction_slotmask, "report")

			if not obstructed then
				local attack_dir = center_of_mass - pos
				mvec3_norm(attack_dir)

				local attack_data = {
					damage = 0,
					attacker_unit = player_unit,
					guaranteed_knockdown = true,
					pos = center_of_mass,
					attack_dir = attack_dir
				}

				dmg_ext:damage_simple(attack_data)
			end
		end
	end
	
end

local _hh_on_damage_dealt_original = PlayerManager.on_damage_dealt
function PlayerManager:on_damage_dealt(unit, damage_info)
	_hh_on_damage_dealt_original(self, unit, damage_info)

	if not self:has_category_upgrade("player", "hh_grinder_base") then
		return
	end

	local player_unit = self:player_unit()
	if not alive(player_unit) or not damage_info or damage_info.attacker_unit ~= player_unit or not alive(unit) or not unit:base() then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	player_unit:character_damage():add_hh_grinder_stack()
end

function PlayerManager:hh_maniac_damage()
	if not self:has_category_upgrade("player", "hh_maniac_base") then
		return
	end

	local delay = self:has_category_upgrade("player", "hh_maniac_delay") and 0.5 or 0
	if self:has_category_upgrade("player", "hh_maniac_target_delay") then
		local player_unit = self:player_unit()
		if alive(player_unit) then
			for _, enemy_data in pairs(managers.enemy:all_enemies()) do
				local enemy = enemy_data.unit
				local movement = alive(enemy) and enemy:movement()
				local attention = movement and movement:attention()
				if attention and attention.unit == player_unit then
					delay = delay + 0.1
				end
			end
		end
	end

	self._hh_maniac_decay_t = Application:time() + delay
end

local _hh_update_damage_dealt_original = PlayerManager._update_damage_dealt
function PlayerManager:_update_damage_dealt(t, dt)
	if not self:has_category_upgrade("player", "hh_maniac_base") then
		return _hh_update_damage_dealt_original(self, t, dt)
	end

	local session = managers.network:session()
	local local_peer_id = session and session:local_peer():id()
	if not local_peer_id then
		return
	end

	self._damage_dealt_to_cops_t = self._damage_dealt_to_cops_t or t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
	local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
	local amount = cocaine_stack and cocaine_stack.amount or 0
	local new_amount = amount

	if self._damage_dealt_to_cops_t <= t then
		self._damage_dealt_to_cops_t = t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
		local gained = (self._damage_dealt_to_cops or 0) * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
		self._damage_dealt_to_cops = 0
		new_amount = new_amount + math.min(gained, tweak_data.upgrades.max_cocaine_stacks_per_tick or 20)
	end

	if self._hh_maniac_decay_t and self._hh_maniac_decay_t <= t then
		if amount > 0 then
			local decay = amount * (tweak_data.upgrades.cocaine_stacks_decay_percentage_per_tick or 0)
			decay = decay + (tweak_data.upgrades.cocaine_stacks_decay_amount_per_tick or 20) * self:upgrade_value("player", "cocaine_stacks_decay_multiplier", 1)
			new_amount = new_amount - decay
		end

		self._hh_maniac_decay_t = nil
	end

	new_amount = math.clamp(math.floor(new_amount), 0, tweak_data.upgrades.max_total_cocaine_stacks or 600)
	if new_amount ~= amount then
		self:update_synced_cocaine_stacks_to_peers(new_amount, self:upgrade_value("player", "sync_cocaine_upgrade_level", 1), self:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0))
	end
end

-- Tag Team: tagged player will hear activation sound
Hooks:PostHook(PlayerManager, "sync_tag_team", "sync_tag_team_sound_effect", function(self, tagged, owner, end_time)
	if tagged == self:local_player() then
		self:local_player():sound():play(tweak_data.blackmarket.projectiles.tag_team.sounds.activate)
	end
end)
