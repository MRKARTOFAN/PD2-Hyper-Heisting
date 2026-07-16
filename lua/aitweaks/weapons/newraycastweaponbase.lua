Hooks:PostHook(NewRaycastWeaponBase, "init", "fraypost_shieldknock", function(self, unit)
	self._shield_knock = managers.player:has_category_upgrade("player", "shield_knock_bullet")
end)

local fray_fire_rate_multiplier = NewRaycastWeaponBase.fire_rate_multiplier
local fray_recoil_multiplier = NewRaycastWeaponBase.recoil_multiplier

function NewRaycastWeaponBase:fire_rate_multiplier()
	local multiplier = fray_fire_rate_multiplier(self)

	if managers.player._magic_bullet_aced_t then
		multiplier = multiplier * 1.2
	end

	if managers.player._pop_pop_mul then
		multiplier = multiplier * (1 + math.abs(managers.player._pop_pop_mul))
	end

	return multiplier
end

function NewRaycastWeaponBase:recoil_multiplier()
	return fray_recoil_multiplier(self) * managers.player:upgrade_value("player", "muscle_memory_aced", 1)
end

local function FRAYClaimTheirBonesAmmoMultiplier()
	local level = managers.player:upgrade_level("player", "claim_their_bones_ammo_multiplier", 0)

	if level <= 0 then
		return 1
	end

	local values = tweak_data.upgrades.values.player.claim_their_bones_ammo_multiplier
	local multiplier = 1

	for i = 1, level do
		multiplier = multiplier * (values[i] or 1)
	end

	return multiplier
end

local function FRAYApplyClaimTheirBonesAmmoMultiplier(ammo_base)
	if not ammo_base or ammo_base.weapon_tweak_data and ammo_base:weapon_tweak_data().ignore_player_skills then
		return false
	end

	local multiplier = FRAYClaimTheirBonesAmmoMultiplier()

	if multiplier == 1 then
		return false
	end

	local weapon_tweak = ammo_base:weapon_tweak_data()
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)

	for _, category in ipairs(ammo_base:categories()) do
		ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value(category, "extra_ammo_multiplier", 1)
	end

	ammo_max_multiplier = ammo_max_multiplier + ammo_max_multiplier * (ammo_base._total_ammo_mod or 0)

	if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
		ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
	end

	ammo_max_multiplier = managers.modifiers:modify_value("WeaponBase:GetMaxAmmoMultiplier", ammo_max_multiplier)

	local ammo_max_per_clip = ammo_base.calculate_ammo_max_per_clip and ammo_base:calculate_ammo_max_per_clip() or ammo_base:get_ammo_max_per_clip()
	local ammo_max = (weapon_tweak.AMMO_MAX + managers.player:upgrade_value(ammo_base._name_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier
	ammo_max = math.round(ammo_max * multiplier)
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_total = math.min(ammo_base:get_ammo_total(), ammo_max)

	ammo_base:set_ammo_max(ammo_max)
	ammo_base:set_ammo_max_per_clip(ammo_max_per_clip)
	ammo_base:set_ammo_total(ammo_total)
	ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_remaining_in_clip(), ammo_max_per_clip))

	return true
end

Hooks:PostHook(NewRaycastWeaponBase, "replenish", "hh_claim_their_bones_newraycast_ammo_multiplier", function(self)
	if FRAYApplyClaimTheirBonesAmmoMultiplier(self) and managers.hud and self.selection_index then
		managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
	end
end)

function NewRaycastWeaponBase:get_damage_falloff(damage, col_ray, user_unit)
	local near_mul = self._near_multiplier or self._near_mul or 1
	local far_mul = self._far_multiplier or self._far_mul or 1

	if near_mul == 0 then
		return damage
	end

	local distance = col_ray.distance or mvector3.distance(col_ray.unit:position(), user_unit:position())
	local near_dist = self._near_falloff or 0
	local far_dist = self._far_falloff or 0
	local primary_category = self:weapon_tweak_data().categories and self:weapon_tweak_data().categories[1]
	local current_state = user_unit and user_unit:movement() and user_unit:movement()._current_state

	if current_state and current_state:in_steelsight() then
		local mul = managers.player:upgrade_value(primary_category, "steelsight_range_inc", 1)
		far_dist = far_dist * mul
	end

	local damage_mul = 1

	if near_dist > 0 and distance < near_dist then
		damage_mul = near_mul
	elseif far_dist > 0 and distance > far_dist then
		damage_mul = far_mul
	end

	return damage * damage_mul
end

function NewRaycastWeaponBase:is_weak_hit(distance, user_unit, damage_dealt)
	if not damage_dealt then
		return 1
	end

	local regular_damage = self._damage
	local new_damage = damage_dealt
	local scale = nil

	scale = new_damage / regular_damage
	
	return scale
end

function NewRaycastWeaponBase:reload_speed_multiplier()
	--if self._current_reload_speed_multiplier then
		--return self._current_reload_speed_multiplier
	--end

	local multiplier = 1
	
	if managers.player._melee_reload_speed_active then
		multiplier = multiplier - managers.player._reload_speed_bonus
	end
	
	if managers.player._syringe_t then
		multiplier = multiplier - 0.5
	end
	
	local hq_aced = nil
	
	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
		
		if category == "shotgun" then
			if managers.player:has_category_upgrade("player", "hq_grease_aced") then
				hq_aced = true
			end
		end
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
	
	if self._setup and alive(self._setup.user_unit) and self._setup.user_unit:movement() then
		local morale_boost_bonus = self._setup.user_unit:movement():morale_boost()
		
		if hq_aced then
			local data = managers.player:upgrade_value("player", "hq_grease_aced", nil)
			
			if data then
				if self._setup.user_unit:movement():current_state()._running then
					multiplier = multiplier + 1 - data[1]
				else
					multiplier = multiplier + 1 - data[2]
				end
			end
		end		

		if morale_boost_bonus then
			multiplier = multiplier + 1 - morale_boost_bonus.reload_speed_bonus
		end

		if self._setup.user_unit:movement():next_reload_speed_multiplier() then
			multiplier = multiplier + 1 - self._setup.user_unit:movement():next_reload_speed_multiplier()
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "reload_weapon_faster") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "reload_weapon_faster", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "single_shot_fast_reload") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "single_shot_fast_reload", 1)
	end

	multiplier = multiplier + 1 - managers.player:get_property("shock_and_awe_reload_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:get_temporary_property("bloodthirst_reload_speed", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("team", "crew_faster_reload", 1)
	multiplier = self:_convert_add_to_mul(multiplier)
	multiplier = multiplier * self:reload_speed_stat()
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end

function NewRaycastWeaponBase:on_bull_event(aced)
	if self:ammo_full() then
		return
	end
	
	local is_player = self._setup.user_unit == managers.player:player_unit()
	local consume_ammo = not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player
	
	if consume_ammo and (is_player or Network:is_server()) then
		local ammo_base = self._reload_ammo_base or self:ammo_base()
		local ammo_total = ammo_base:get_ammo_total()
		local max_ammo_in_clip = ammo_base:get_ammo_max_per_clip()
		local ammo_in_clip = ammo_base:get_ammo_remaining_in_clip()
		local amount = ammo_in_clip + math.ceil(max_ammo_in_clip * 0.1)
		
		if aced then
			amount = amount + 1
		end

		if self._setup.expend_ammo then
			ammo_base:set_ammo_remaining_in_clip(math.min(math.min(ammo_total, max_ammo_in_clip), amount))
		end
	end
end

function NewRaycastWeaponBase:calculate_ammo_max_per_clip()
	local added = 0
	local weapon_tweak_data = self:weapon_tweak_data()

	if self:is_category("shotgun") then 
		if tweak_data.weapon[self._name_id].has_magazine then
			added = managers.player:upgrade_value("shotgun", "magazine_capacity_inc", 0)

			if self:is_category("akimbo") then
				added = added * 2
			end
		end
		
		local mag_mul = managers.player:upgrade_value("player", "cool_hunting_basic", 1)
		local to_add = weapon_tweak_data.CLIP_AMMO_MAX * mag_mul
		
		to_add = to_add - weapon_tweak_data.CLIP_AMMO_MAX 
		
		to_add = math.ceil(to_add)
		
		added = added + to_add
	elseif self:is_category("pistol") and managers.player:has_category_upgrade("pistol", "magazine_capacity_inc") then
		added = managers.player:upgrade_value("pistol", "magazine_capacity_inc", 0)

		if self:is_category("akimbo") then
			added = added * 2
		end
	elseif self:is_category("smg", "assault_rifle", "lmg") then
		local mag_mul = managers.player:upgrade_value("player", "lead_demi_basic", 1)
		local to_add = weapon_tweak_data.CLIP_AMMO_MAX * mag_mul
		
		to_add = to_add - weapon_tweak_data.CLIP_AMMO_MAX 
		
		to_add = math.ceil(to_add)
		
		added = added + to_add
	end
	
	local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + added
	ammo = ammo + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

	if not self:upgrade_blocked("weapon", "clip_ammo_increase") then
		ammo = ammo + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
	end

	for _, category in ipairs(tweak_data.weapon[self._name_id].categories) do
		if not self:upgrade_blocked(category, "clip_ammo_increase") then
			ammo = ammo + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
		end
	end

	ammo = ammo + (self._extra_ammo or 0)

	return ammo
end

local math_clamp = math.clamp
local math_lerp = math.lerp
local ids_single = Idstring("single")
local ids_auto = Idstring("auto")
local ids_burst = Idstring("burst")
local ids_volley = Idstring("volley")

function NewRaycastWeaponBase:_update_stats_values(disallow_replenish, ammo_data)
	self:_default_damage_falloff()
	self:_check_sound_switch()

	self._silencer = managers.weapon_factory:has_perk("silencer", self._factory_id, self._blueprint)
	local weapon_perks = managers.weapon_factory:get_perks(self._factory_id, self._blueprint) or {}

	if weapon_perks.fire_mode_auto then
		self._locked_fire_mode = ids_auto
	elseif weapon_perks.fire_mode_single then
		self._locked_fire_mode = ids_single
	elseif weapon_perks.fire_mode_burst then
		self._locked_fire_mode = ids_burst
	elseif weapon_perks.fire_mode_volley then
		self._locked_fire_mode = ids_volley
	else
		self._locked_fire_mode = nil
	end

	self._fire_mode = self._locked_fire_mode or self:get_recorded_fire_mode(self:_weapon_tweak_data_id()) or Idstring(self:weapon_tweak_data().FIRE_MODE or "single")
	self._ammo_data = ammo_data or managers.weapon_factory:get_ammo_data_from_weapon(self._factory_id, self._blueprint) or {}
	self._can_shoot_through_shield = tweak_data.weapon[self._name_id].can_shoot_through_shield
	self._can_shoot_through_enemy = tweak_data.weapon[self._name_id].can_shoot_through_enemy
	self._can_shoot_through_wall = tweak_data.weapon[self._name_id].can_shoot_through_wall
	self._armor_piercing_chance = self:weapon_tweak_data().armor_piercing_chance or 0
	local categories = self:categories()
	local primary_category = categories and categories[1]
	self._movement_penalty = tweak_data.upgrades.weapon_movement_penalty[primary_category] or 1
	self._burst_count = self:weapon_tweak_data().BURST_COUNT or 3
	local fire_mode_data = self:weapon_tweak_data().fire_mode_data or {}
	local volley_fire_mode = fire_mode_data.volley

	if volley_fire_mode then
		self._volley_spread_mul = volley_fire_mode.spread_mul or 1
		self._volley_damage_mul = volley_fire_mode.damage_mul or 1
		self._volley_ammo_usage = volley_fire_mode.ammo_usage or 1
		self._volley_rays = volley_fire_mode.rays or 1
	end

	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
	local part_data = nil
	local is_underbarrel = self.is_underbarrel and self:is_underbarrel()
	local weap_factory_parts = tweak_data.weapon.factory.parts

	for part_id, stats in pairs(custom_stats) do
		part_data = weap_factory_parts[part_id]
		local can_apply = true

		if part_data.type == "underbarrel_ammo" then
			can_apply = is_underbarrel
		elseif part_data.type == "ammo" then
			can_apply = not is_underbarrel
		end

		if can_apply then
			if stats.movement_speed then
				self._movement_penalty = self._movement_penalty * stats.movement_speed
			end

			if part_data.type ~= "ammo" and part_data.type ~= "underbarrel_ammo" then
				if stats.ammo_pickup_min_mul then
					self._ammo_data.ammo_pickup_min_mul = self._ammo_data.ammo_pickup_min_mul and self._ammo_data.ammo_pickup_min_mul * stats.ammo_pickup_min_mul or stats.ammo_pickup_min_mul
				end

				if stats.ammo_pickup_max_mul then
					self._ammo_data.ammo_pickup_max_mul = self._ammo_data.ammo_pickup_max_mul and self._ammo_data.ammo_pickup_max_mul * stats.ammo_pickup_max_mul or stats.ammo_pickup_max_mul
				end

				if stats.ammo_offset then
					self._ammo_data.ammo_offset = (self._ammo_data.ammo_offset or 0) + stats.ammo_offset
				end

				if stats.fire_rate_multiplier then
					self._ammo_data.fire_rate_multiplier = (self._ammo_data.fire_rate_multiplier or 0) + stats.fire_rate_multiplier - 1
				end
			end

			if stats.burst_count then
				self._burst_count = stats.burst_count
			end

			if stats.volley_spread_mul then
				self._volley_spread_mul = stats.volley_spread_mul
			end

			if stats.volley_damage_mul then
				self._volley_damage_mul = stats.volley_damage_mul
			end

			if stats.volley_ammo_usage then
				self._volley_ammo_usage = stats.volley_ammo_usage
			end

			if stats.volley_rays then
				self._volley_rays = stats.volley_rays
			end

			if stats.launch_speed_mul then
				self._launch_speed_mul = stats.launch_speed_mul
			end

			if stats.charge_speed_mul then
				self._charge_speed_mul = stats.charge_speed_mul
			end

			if stats.can_shoot_through_enemy ~= nil then
				self._can_shoot_through_enemy = stats.can_shoot_through_enemy
			end

			if stats.can_shoot_through_shield ~= nil then
				self._can_shoot_through_shield = stats.can_shoot_through_shield
			end

			if stats.can_shoot_through_wall ~= nil then
				self._can_shoot_through_wall = stats.can_shoot_through_wall
			end

			if stats.armor_piercing_add ~= nil then
				self._armor_piercing_chance = math.clamp(self._armor_piercing_chance + stats.armor_piercing_add, 0, 1)
			end

			if stats.armor_piercing_mul ~= nil then
				self._armor_piercing_chance = math.clamp(self._armor_piercing_chance * stats.armor_piercing_mul, 0, 1)
			end
		end
	end

	local damage_falloff = {
		optimal_distance = self._optimal_distance,
		optimal_range = self._optimal_range,
		near_falloff = self._near_falloff,
		far_falloff = self._far_falloff,
		near_multiplier = self._near_multiplier,
		far_multiplier = self._far_multiplier
	}

	managers.blackmarket:modify_damage_falloff(damage_falloff, custom_stats)

	self._optimal_distance = damage_falloff.optimal_distance
	self._optimal_range = damage_falloff.optimal_range
	self._near_falloff = damage_falloff.near_falloff
	self._far_falloff = damage_falloff.far_falloff
	self._near_multiplier = damage_falloff.near_multiplier
	self._far_multiplier = damage_falloff.far_multiplier

	if self._ammo_data then
		if self._ammo_data.can_shoot_through_shield ~= nil then
			self._can_shoot_through_shield = self._ammo_data.can_shoot_through_shield
		end

		if self._ammo_data.can_shoot_through_enemy ~= nil then
			self._can_shoot_through_enemy = self._ammo_data.can_shoot_through_enemy
		end

		if self._ammo_data.can_shoot_through_wall ~= nil then
			self._can_shoot_through_wall = self._ammo_data.can_shoot_through_wall
		end

		if self._ammo_data.bullet_class ~= nil then
			self._bullet_class = CoreSerialize.string_to_classtable(self._ammo_data.bullet_class)
			self._bullet_slotmask = self._bullet_class:bullet_slotmask()

			if self._setup and self._setup.user_unit == managers.player:player_unit() then
				self._bullet_slotmask = managers.mutators:modify_value("RaycastWeaponBase:modify_slot_mask", self._bullet_slotmask)
			end

			self._blank_slotmask = self._bullet_class:blank_slotmask()
		end

		if self._ammo_data.armor_piercing_add ~= nil then
			self._armor_piercing_chance = math.clamp(self._armor_piercing_chance + self._ammo_data.armor_piercing_add, 0, 1)
		end

		if self._ammo_data.armor_piercing_mul ~= nil then
			self._armor_piercing_chance = math.clamp(self._armor_piercing_chance * self._ammo_data.armor_piercing_mul, 0, 1)
		end
	end

	
	self._armor_piercing_chance = self._armor_piercing_chance + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
	
	if self:weapon_tweak_data().categories then
		for _, category in ipairs(self:weapon_tweak_data().categories) do
			self._armor_piercing_chance = self._armor_piercing_chance + managers.player:upgrade_value(category, "armor_piercing_chance", 0)
		end
	end
	
	self._armor_piercing_chance = math.clamp(self._armor_piercing_chance, 0, 1)

	if self._silencer then
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash_silenced or "effects/payday2/particles/weapons/9mm_auto_silence_fps")
	elseif self._ammo_data and self._ammo_data.muzzleflash ~= nil then
		self._muzzle_effect = Idstring(self._ammo_data.muzzleflash)
	else
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	end

	self._muzzle_effect_table = {
		effect = self._muzzle_effect,
		parent = self._obj_fire,
		force_synch = self._muzzle_effect_table.force_synch or false
	}

	if self._ammo_data and self._ammo_data.trail_effect ~= nil then
		self._trail_effect = Idstring(self._ammo_data.trail_effect)
	else
		self._trail_effect = self:weapon_tweak_data().trail_effect and Idstring(self:weapon_tweak_data().trail_effect) or self.TRAIL_EFFECT
	end

	self._trail_effect_table = {
		effect = self._trail_effect,
		position = Vector3(),
		normal = Vector3()
	}
	local base_stats = self:weapon_tweak_data().stats

	if not base_stats then
		return
	end

	local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
	local stats = deep_clone(base_stats)
	local stats_tweak_data = tweak_data.weapon.stats
	local modifier_stats = self:weapon_tweak_data().stats_modifiers
	local bonus_stats = self._cosmetics_bonus and self._cosmetics_data and self._cosmetics_data.bonus and tweak_data.economy.bonuses[self._cosmetics_data.bonus] and tweak_data.economy.bonuses[self._cosmetics_data.bonus].stats or {}

	if managers.job:is_current_job_competitive() or managers.weapon_factory:has_perk("bonus", self._factory_id, self._blueprint) then
		bonus_stats = {}
	end

	if self.modify_base_stats then
		self:modify_base_stats(stats)
	end

	if stats.zoom then
		stats.zoom = math.min(stats.zoom + managers.player:upgrade_value(primary_category, "zoom_increase", 0), #stats_tweak_data.zoom)
	end

	for stat, _ in pairs(stats) do
		if stats[stat] < 1 or stats[stat] > #stats_tweak_data[stat] then
			Application:error("[NewRaycastWeaponBase] Base weapon stat is out of bound!", "stat: " .. stat, "index: " .. stats[stat], "max_index: " .. #stats_tweak_data[stat], "This stat will be clamped!")
		end

		if parts_stats[stat] then
			stats[stat] = stats[stat] + parts_stats[stat]
		end

		if bonus_stats[stat] then
			stats[stat] = stats[stat] + bonus_stats[stat]
		end

		stats[stat] = math_clamp(stats[stat], 1, #stats_tweak_data[stat])
	end

	self._current_stats_indices = stats
	self._current_stats = {}

	for stat, i in pairs(stats) do
		self._current_stats[stat] = stats_tweak_data[stat] and stats_tweak_data[stat][i] or 1

		if modifier_stats and modifier_stats[stat] then
			self._current_stats[stat] = self._current_stats[stat] * modifier_stats[stat]
		end
	end

	self._current_stats.alert_size = stats_tweak_data.alert_size[math_clamp(stats.alert_size, 1, #stats_tweak_data.alert_size)]

	if modifier_stats and modifier_stats.alert_size then
		self._current_stats.alert_size = self._current_stats.alert_size * modifier_stats.alert_size
	end

	if stats.concealment then
		stats.suspicion = math.clamp(#stats_tweak_data.concealment - base_stats.concealment - (parts_stats.concealment or 0), 1, #stats_tweak_data.concealment)
		self._current_stats.suspicion = stats_tweak_data.concealment[stats.suspicion]
	end

	if parts_stats and parts_stats.spread_multi then
		self._current_stats.spread_multi = parts_stats.spread_multi
	end

	self._alert_size = self._current_stats.alert_size or self._alert_size
	self._suppression = self._current_stats.suppression or self._suppression
	self._zoom = self._current_stats.zoom or self._zoom
	self._spread = self._current_stats.spread or self._spread
	self._recoil = self._current_stats.recoil or self._recoil
	self._spread_moving = self._current_stats.spread_moving or self._spread_moving
	self._extra_ammo = self._current_stats.extra_ammo or self._extra_ammo
	self._total_ammo_mod = self._current_stats.total_ammo_mod or self._total_ammo_mod

	if self._ammo_data.ammo_offset then
		self._extra_ammo = self._extra_ammo + self._ammo_data.ammo_offset
	end

	self._reload = self._current_stats.reload or self._reload
	self._spread_multiplier = self._current_stats.spread_multi or self._spread_multiplier
	self._scopes = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("scope", self._factory_id, self._blueprint)
	self._has_range_distance_scope = self:_chk_has_range_distance_scope()
	self._unit_health_displays = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("display_unit_health", self._factory_id, self._blueprint)
	self._has_unit_health_display = self:_chk_has_unit_health_display()
	self._can_highlight_with_perk = managers.weapon_factory:has_perk("highlight", self._factory_id, self._blueprint)
	self._can_highlight_with_skill = managers.player:has_category_upgrade("weapon", "steelsight_highlight_specials")
	self._can_highlight = self._can_highlight_with_perk or self._can_highlight_with_skill

	self:_check_reticle_obj()

	if not disallow_replenish then
		self:replenish()
	end

	local user_unit = self._setup and self._setup.user_unit
	local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state
	self._fire_rate_multiplier = managers.blackmarket:fire_rate_multiplier(self._name_id, categories, self._silencer, nil, current_state, self._blueprint)

	if self._ammo_data.fire_rate_multiplier then
		self._fire_rate_multiplier = self._fire_rate_multiplier + self._ammo_data.fire_rate_multiplier
	end
end

-- Force the weapon to evaluate the Overkill AP Shotgun Skill natively on trigger pull
function NewRaycastWeaponBase:check_armor_piercing()
	self._use_armor_piercing = math.random() < self:armor_piercing_chance()
	
	if self:is_category("shotgun") and managers.player:has_category_upgrade("shotgun", "armor_piercing_chance") then
		local ap_chance = managers.player:upgrade_value("shotgun", "armor_piercing_chance", 0)
		
		if math.random() < ap_chance then
			self._use_armor_piercing = true
		end
	end
end
