local function format_round(num, round_value)
	return round_value and tostring(math.round(num)) or string.format("%.1f", num):gsub("%.?0+$", "")
end

local function is_shotgun_weapon(name)
	local weapon_tweak = name and tweak_data.weapon[name]

	return weapon_tweak and weapon_tweak.categories and table.contains(weapon_tweak.categories, "shotgun")
end

local function get_weapon_rays(name, category, slot)
	if not is_shotgun_weapon(name) then
		return
	end

	return WeaponDescription._get_custom_pellet_stats and WeaponDescription._get_custom_pellet_stats(name, category, slot) or tweak_data.weapon[name].rays
end

local function format_pellet_damage(value, rays)
	if rays and rays > 1 then
		return tostring(math.round(value / rays)) .. "x" .. tostring(rays)
	end

	return format_round(value)
end

Hooks:PostHook(PlayerInventoryGui, "_update_stats", "hh_add_inventory_weapon_pickup_stat", function(self, name)
	if name ~= "primary" and name ~= "secondary" then
		return
	end

	self:set_weapon_stats(self._info_panel, {
		{ round_value = true, name = "magazine", stat_name = "extra_ammo" },
		{ round_value = true, name = "totalammo", stat_name = "total_ammo_mod" },
		{ name = "pickup" },
		{ round_value = true, name = "fire_rate" },
		{ name = "damage" },
		{ percent = true, name = "spread", offset = true, revert = true },
		{ percent = true, name = "recoil", offset = true, revert = true },
		{ index = true, name = "concealment" },
		{ percent = false, name = "suppression", offset = true },
		{ inverted = true, name = "reload" }
	})
	self:_update_info_weapon(name)
end)

Hooks:PostHook(PlayerInventoryGui, "_update_info_weapon", "hh_show_inventory_shotgun_pellet_damage", function(self, name)
	if not self._stats_texts or not self._stats_texts.damage then
		return
	end

	local category = name == "primary" and "primaries" or "secondaries"
	local equipped_item = managers.blackmarket:equipped_item(category)

	if not equipped_item or not is_shotgun_weapon(equipped_item.weapon_id) then
		return
	end

	local equipped_slot = managers.blackmarket:equipped_weapon_slot(category)
	local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(equipped_item.weapon_id, category, equipped_slot)
	local value = math.max(base_stats.damage.value + mods_stats.damage.value + skill_stats.damage.value, 0)
	local base = base_stats.damage.value
	local rays = get_weapon_rays(equipped_item.weapon_id, category, equipped_slot)
	local base_rays = tweak_data.weapon[equipped_item.weapon_id].rays

	self._stats_texts.damage.total:set_text(format_pellet_damage(value, rays))
	self._stats_texts.damage.base:set_text(format_pellet_damage(base, base_rays))
end)

local get_armor_stats_original = PlayerInventoryGui._get_armor_stats
function PlayerInventoryGui:_get_armor_stats(name)
	local base_stats, mods_stats, skill_stats = get_armor_stats_original(self, name)
	local upgrade_level = tweak_data.blackmarket.armors[name].upgrade_level
	local stats_multiplier = tweak_data.gui.stats_present_multiplier
	local health_base = tweak_data.player.damage.HEALTH_INIT
	local health_skill = managers.player:max_health() - health_base

	base_stats.health.value = health_base * stats_multiplier
	skill_stats.health.value = health_skill * stats_multiplier

	local movement_base = tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX * 1.1 / 100
	local movement_penalty = managers.player:body_armor_value("movement", upgrade_level)
	local base_movement = movement_penalty * movement_base
	local movement = Utl.round(movement_base * managers.player:movement_speed_multiplier("run", false, upgrade_level, 1), 2)
	base_movement = Utl.round(base_movement, 2)

	base_stats.movement.value = base_movement
	skill_stats.movement.value = movement - base_movement
	skill_stats.movement.skill_in_effect = skill_stats.movement.value > 0

	if managers.player:has_category_upgrade("player", "hh_armorer_armor") then
		local armor_total = base_stats.armor.value + skill_stats.armor.value
		skill_stats.armor.value = armor_total * 1.15 - base_stats.armor.value
		skill_stats.armor.skill_in_effect = true
	end

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_ratio = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		local armor_base = base_stats.armor.value
		local armor_skill = (armor_base + managers.player:body_armor_skill_addend(name) * stats_multiplier) * managers.player:body_armor_skill_multiplier(name) - armor_base
		local converted_armor = (armor_base + armor_skill) * conversion_ratio

		skill_stats.armor.value = -armor_base - armor_skill
		skill_stats.health.value = skill_stats.health.value + converted_armor
		skill_stats.armor.skill_in_effect = converted_armor ~= 0
		skill_stats.health.skill_in_effect = converted_armor ~= 0
	end

	if managers.player:has_category_upgrade("player", "hh_grinder_base") then
		skill_stats.armor.value = 1 - base_stats.armor.value
		skill_stats.armor.skill_in_effect = true
	end

	return base_stats, mods_stats, skill_stats
end

Hooks:PostHook(PlayerInventoryGui, "setup_player_stats", "hh_show_movement_as_ratio", function(self)
	for _, stat in ipairs(self._player_stats_shown) do
		if stat.name == "movement" then
			stat.procent = nil

			return
		end
	end
end)

Hooks:PostHook(PlayerInventoryGui, "_update_info_throwable", "hh_add_throwable_info", function(self)
	if not self:_should_show_description() then
		return
	end

	local throwable_id = managers.blackmarket:equipped_projectile()
	local projectile_data = throwable_id and tweak_data.blackmarket.projectiles[throwable_id]

	if not projectile_data then
		return
	end

	local extra_text = nil

	if projectile_data.base_cooldown then
		extra_text = "\nBase Cooldown: " .. tostring(projectile_data.base_cooldown) .. "s \n"
	elseif projectile_data.pickup_chance then
		extra_text = "\nPickup Chance per Box: " .. tostring(projectile_data.pickup_chance * 100) .. "% \n"
	end

	if extra_text then
		self:set_info_text(self._info_text:text() .. extra_text)
	end
end)
