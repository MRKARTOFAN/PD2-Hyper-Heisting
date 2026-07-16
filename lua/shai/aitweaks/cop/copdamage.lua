-- Health granularity prevents linear damage interpolation of AI against other AI from working
-- correctly and notably rounds up damage against enemies with a high HP pool even for player weapons.
-- Increasing the health granularity makes damage dealt more accurate to the actual weapon damage stats
CopDamage._HEALTH_GRANULARITY = 8192

local idstr_gore = Idstring("effects/pd2_mod_hh/particles/character/gore_explosion")
local idstr_deathresist = Idstring("effects/pd2_mod_hh/particles/iconograph/deathresist")
local idstr_shieldbreak = Idstring("effects/pd2_mod_hh/particles/character/shield_break")
local hh_melee_headshot_mul = 2

function CopDamage:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	body_index = math.clamp(body_index, 0, 128)
	damage_percent = math.clamp(damage_percent, 0, self._HEALTH_GRANULARITY)
	damage_effect_percent = math.clamp(damage_effect_percent, 0, self._HEALTH_GRANULARITY)

	self._unit:network():send("damage_melee", attack_data.attacker_unit, damage_percent, damage_effect_percent, body_index, hit_offset_height, variant, self._dead and true or false)
end


-- Make head hitbox size consistent across enemies
Hooks:PostHook(CopDamage, "init", "sh_init", function(self)
	local head_body = self._unit:body(self._head_body_name or "head")
	if head_body then
		head_body:set_sphere_radius(18)
	end
	if self._head_body_name then
		self._ids_head_body_name = Idstring(self._head_body_name)
	end
end)


-- Make these functions check that the attacker unit is a player (to make sure NPC vs NPC melee doesn't crash)
local _dismember_condition_original = CopDamage._dismember_condition
function CopDamage:_dismember_condition(attack_data, ...)
	if alive(attack_data.attacker_unit) and attack_data.attacker_unit:base().is_local_player then
		return _dismember_condition_original(self, attack_data, ...)
	end
end

local _sync_dismember_original = CopDamage._sync_dismember
function CopDamage:_sync_dismember(attacker_unit, ...)
	if alive(attacker_unit) and attacker_unit:base().is_husk_player then
		return _sync_dismember_original(self, attacker_unit, ...)
	end
end


-- Additional suppression on hit
Hooks:PreHook(CopDamage, "_on_damage_received", "sh__on_damage_received", function(self, damage_info)
	self:build_suppression(4 * damage_info.damage / self._HEALTH_INIT, nil)
end)


-- Fixed critical hit multiplier
function CopDamage:roll_critical_hit(attack_data, damage)
	damage = damage or attack_data.damage

	if self:can_be_critical(attack_data) and math.random() < managers.player:critical_hit_chance() then
		return true, damage * 3
	end

	return false, damage
end


-- Make hurt type more dynamic by interpolating between hurt severity entries
Hooks:OverrideFunction(CopDamage, "get_damage_type", function(self, damage_percent, category)
	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	local dmg = damage_percent / self._HEALTH_GRANULARITY

	if hurt_table.health_reference == "current" then
		dmg = math.min(1, self._HEALTH_INIT * dmg / self._health)
	elseif hurt_table.health_reference ~= "full" then
		dmg = math.min(1, self._HEALTH_INIT * dmg / hurt_table.health_reference)
	end

	local prev_zone, zone
	for i, test_zone in ipairs(hurt_table.zones) do
		if i == #hurt_table.zones or dmg < test_zone.health_limit then
			zone = test_zone
			break
		end
		prev_zone = test_zone
	end

	local rand = math.random()
	local total_chance = 0
	local t = prev_zone and math.map_range_clamped(dmg, prev_zone.health_limit or 0, zone.health_limit or 1, 0, 1)
	for sev_name, hurt_type in pairs(self._hurt_severities) do
		local chance = prev_zone and math.lerp(prev_zone[sev_name] or 0, zone[sev_name] or 0, t) or zone[sev_name] or 0
		total_chance = total_chance + chance
		if rand < total_chance then
			return hurt_type or "dmg_rcv"
		end
	end

	return "dmg_rcv"
end)


-- Disable impact sounds and blood effects for stuns
local damage_explosion = CopDamage.damage_explosion
function CopDamage:damage_explosion(attack_data, ...)
	local no_blood = self._no_blood
	self._no_blood = attack_data.variant == "stun"

	local result = damage_explosion(self, attack_data, ...)

	self._no_blood = no_blood

	return result
end

local sync_damage_explosion = CopDamage.sync_damage_explosion
function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, ...)
	local no_blood = self._no_blood
	self._no_blood = CopDamage._ATTACK_VARIANTS[i_attack_variant] == "stun"

	local result = sync_damage_explosion(self, attacker_unit, damage_percent, i_attack_variant, ...)

	self._no_blood = no_blood

	return result
end


-- Fix synced melee damage ignoring medic heal
local sync_damage_melee_original = CopDamage.sync_damage_melee
function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death, ...)
	if death or variant ~= 7 then
		return sync_damage_melee_original(self, attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death, ...)
	end

	local attack_data = {
		variant = "healed",
		attacker_unit = attacker_unit,
		damage = damage_percent * self._HEALTH_INIT_PRECENT,
		is_synced = true,
		pos = self._unit:position(),
		result = {
			variant = "melee",
			type = "healed"
		}
	}

	self:do_medic_heal()

	if attacker_unit then
		attack_data.attack_dir = self._unit:position() - attacker_unit:position()
		mvector3.normalize(attack_data.attack_dir)
		attack_data.name_id = attacker_unit:inventory() and attacker_unit:inventory():get_melee_weapon_id()
	else
		attack_data.attack_dir = -self._unit:rotation():y()
	end

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)

	if not self._no_blood then
		local from = Vector3(0, 0, hit_offset_height)
		mvector3.add(from, self._unit:movement():m_pos())
		managers.game_play_central:sync_play_impact_flesh(from, attack_data.attack_dir)
	end

	self:_send_sync_melee_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)
end


-- Revert headshot multipliers for fire damage
local damage_fire_original = CopDamage.damage_fire
function CopDamage:damage_fire(attack_data, ...)
	local head_body_name = self._head_body_name
	self._head_body_name = nil
	local result = damage_fire_original(self, attack_data, ...)
	self._head_body_name = head_body_name
	return result
end


-- Add temporary DR when healed by a medic
Hooks:PostHook(CopDamage, "do_medic_heal", "sh_do_medic_heal", function(self)
	self._last_medic_heal_t = TimerManager:game():time()
end)

local _hh_apply_bullet_death_resist
local _apply_damage_reduction_original = CopDamage._apply_damage_reduction
function CopDamage:_apply_damage_reduction(damage, attack_data, ...)
	attack_data = attack_data or self._hh_active_bullet_attack_data
	damage = _apply_damage_reduction_original(self, damage, attack_data, ...)

	if self._last_medic_heal_t and TimerManager:game():time() - self._last_medic_heal_t < 2 then
		damage = damage * 0.5
	end

	return _hh_apply_bullet_death_resist(self, attack_data, damage)
end

local function _hh_can_resist_bullet_death(self, attack_data, damage)
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	local rounded_damage = damage_percent * self._HEALTH_INIT_PRECENT

	if not attack_data
		or attack_data.variant ~= "bullet"
		or self._resisted_death
		or not self._char_tweak.resist_death
		or not self._char_tweak.resist_death.bullet
		or self._health <= 1
		or rounded_damage < self._health
	then
		return false
	end

	local weapon_base = alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()
	if weapon_base and (weapon_base.thrower_unit or weapon_base._can_shoot_through_shield) then
		return false
	end

	return true
end

function _hh_apply_bullet_death_resist(self, attack_data, damage)
	if attack_data
		and _hh_can_resist_bullet_death(self, attack_data, damage)
	then
		damage = self._health - 1
		self._resisted_death = true
		self._hh_bullet_resist_effect_to_sync = true

		local head = self._head_body_name
			and attack_data.col_ray
			and attack_data.col_ray.body
			and attack_data.col_ray.body:name() == self._ids_head_body_name

		if head then
			self:_spawn_head_gadget({
				position = attack_data.col_ray.body:position(),
				rotation = attack_data.col_ray.body:rotation(),
				dir = attack_data.col_ray.ray
			})
			self._hh_resist_head_gadget_spawned = true
		end

		local hit_pos = attack_data.col_ray and attack_data.col_ray.position or self._unit:position()
		World:effect_manager():spawn({
			effect = idstr_deathresist,
			position = hit_pos
		})

		if attack_data.attacker_unit == managers.player:player_unit() then
			World:effect_manager():spawn({
				effect = idstr_shieldbreak,
				position = hit_pos,
				normal = math.UP
			})
		end

		if not self._hh_resist_visor_sfx_played then
			self._unit:sound():play("bulldozer_visor_shatter")
			self._hh_resist_visor_sfx_played = true
		end
	end

	return damage
end

local damage_bullet_original = CopDamage.damage_bullet
function CopDamage:damage_bullet(attack_data, ...)
	if attack_data and not attack_data.variant then
		attack_data.variant = "bullet"
	end

	self._hh_active_bullet_attack_data = attack_data

	local result = damage_bullet_original(self, attack_data, ...)

	self._hh_active_bullet_attack_data = nil
	self._hh_bullet_resist_effect_to_sync = nil

	return result
end

local _send_bullet_attack_result_original = CopDamage._send_bullet_attack_result
function CopDamage:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant, ...)
	if self._hh_bullet_resist_effect_to_sync then
		hit_offset_height = 3
	end

	return _send_bullet_attack_result_original(self, attack_data, attacker, damage_percent, body_index, hit_offset_height, variant, ...)
end

local sync_damage_bullet_original = CopDamage.sync_damage_bullet
function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death, ...)
	if hit_offset_height == 3 and not death and not self._hh_resist_visor_sfx_played then
		self._resisted_death = true
		self._hh_resist_visor_sfx_played = true

		local body = self._unit:body(i_body)
		local head = self._head_body_name and body and body:name() == self._ids_head_body_name
		local hit_pos = body and body:position() or self._unit:position()

		if head then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attacker_unit and self._unit:position() - attacker_unit:position() or self._unit:rotation():y()
			})
			self._hh_resist_head_gadget_spawned = true
		end

		World:effect_manager():spawn({
			effect = idstr_shieldbreak,
			position = hit_pos,
			normal = math.UP
		})

		self._unit:sound():play("bulldozer_visor_shatter", nil, nil)
	end

	return sync_damage_bullet_original(self, attacker_unit, damage_percent, i_body, hit_offset_height, variant, death, ...)
end

local _spawn_head_gadget_original = CopDamage._spawn_head_gadget
function CopDamage:_spawn_head_gadget(params, ...)
	if self._hh_resist_head_gadget_spawned then
		return
	end

	return _spawn_head_gadget_original(self, params, ...)
end


local function _spawn_melee_headshot_effect(self)
	local head_obj = self._unit:get_object(Idstring("Head"))
	local pos = head_obj and head_obj:position() or self._unit:position()

	World:effect_manager():spawn({
		effect = idstr_gore,
		position = pos,
		normal = math.UP
	})

	self._unit:sound():play("expl_gen_head", nil, nil)
end
-- [Karto] It's called thanks for inspiration.

Hooks:PreHook(CopDamage, "damage_melee", "hh_melee_headshot_damage", function(self, attack_data)
	local head = self._head_body_name
		and attack_data.col_ray
		and attack_data.col_ray.body
		and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data, damage)

		if critical_hit then
			managers.hud:on_crit_confirmed()
			damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		if head then
			managers.player:on_headshot_dealt()
		end

		if tweak_data.achievement.cavity.melee_type == attack_data.name_id and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local melee_headshot_mul = hh_melee_headshot_mul * (tweak_data.blackmarket.melee_weapons[melee_entry].stats.headshot_damage_mul or 1)

	if not (self._char_tweak.ignore_melee_headshot or self._char_tweak.ignore_headshot) and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * melee_headshot_mul
		else
			damage = self._health * 10
		end

		attack_data.headshot = true
	end

	attack_data.damage = damage
end)

-- Gore effect on lethal melee headshot (local player)
Hooks:PostHook(CopDamage, "damage_melee", "hh_melee_headshot_effect", function(self, attack_data)
	local player_unit = managers.player:player_unit()
	if not player_unit or attack_data.attacker_unit ~= player_unit then return end
	if not attack_data.headshot or not self._dead then return end

	_spawn_melee_headshot_effect(self)
end)

-- Gore effect on lethal melee headshot (peers via network sync)
Hooks:PostHook(CopDamage, "sync_damage_melee", "hh_melee_headshot_effect_sync", function(self, attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death)
	if not death or not self._dead then return end

	local body = self._unit:body(i_body)
	local head = self._head_body_name
		and not self._unit:in_slot(16)
		and not self._char_tweak.ignore_headshot
		and body
		and body:name() == self._ids_head_body_name

	if head then
		_spawn_melee_headshot_effect(self)
	end
end)

-- Zeal effect removal
Hooks:PreHook(CopDamage, "die", "zeal_effect_removal_die", function (self, attack_data)
	if self._unit:base() then
		self._unit:base():disable_zeal_effect()
	end
	
	local current_unit = self._unit:name()
	if self._unit:base()._tweak_table == "taser" and current_unit == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer") then
		self._cruel_death_effect = World:effect_manager():spawn({
			effect = Idstring("effects/particles/custom/taser_death_explosion"),
			parent = self._unit:get_object(Idstring("Spine2"))
		})
	end
end)

-- [Karto] HH drama stuff
Hooks:PostHook(CopDamage, "clbk_suppression_decay", "hh_fray_suppression_hardness", function(self)
	if Global.game_settings and Global.game_settings.one_down then
		self._suppression_hardness_t = TimerManager:game():time()
	end
end)

Hooks:PostHook(CopDamage, "die", "hh_report_drama_kill", function(self, attack_data)
	if Network:is_client() or not attack_data or not self._unit:base():has_tag("law") then
		return
	end

	managers.groupai:state():hh_enemy_killed(attack_data.attacker_unit)
end)
