local function is_weapon_category(weapon_tweak, ...)
	local arg = {
		...
	}
	local categories = weapon_tweak.categories

	for i = 1, #arg do
		if table.contains(categories, arg[i]) then
			return true
		end
	end

	return false
end

local has_pickup_stat = false

for _, stat in ipairs(WeaponDescription._stats_shown) do
	if stat.name == "pickup" then
		has_pickup_stat = true
		break
	end
end

if not has_pickup_stat then
	table.insert(WeaponDescription._stats_shown, {
		name = "pickup"
	})
end

local function get_weapon_pickup(name, blueprint)
	local weapon_tweak = tweak_data.weapon[name]

	if not weapon_tweak or not weapon_tweak.AMMO_PICKUP then
		return 0, 0
	end

	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local ammo_data = factory_id and managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint) or {}
	local min_pickup = weapon_tweak.AMMO_PICKUP[1] * (ammo_data.ammo_pickup_min_mul or 1)
	local max_pickup = weapon_tweak.AMMO_PICKUP[2] * (ammo_data.ammo_pickup_max_mul or 1)
	local custom_data = factory_id and managers.weapon_factory:get_custom_stats_from_weapon(factory_id, blueprint) or {}

	for _, stats in pairs(custom_data) do
		min_pickup = min_pickup * (stats.ammo_pickup_min_mul or 1)
		max_pickup = max_pickup * (stats.ammo_pickup_max_mul or 1)
	end

	return min_pickup, max_pickup
end

local get_weapon_stats_original = WeaponDescription._get_stats
function WeaponDescription._get_stats(name, category, slot, blueprint)
	local base_stats, mods_stats, skill_stats = get_weapon_stats_original(name, category, slot, blueprint)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local default_blueprint = factory_id and managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local base_min, base_max = get_weapon_pickup(name, default_blueprint)

	blueprint = blueprint or slot and managers.blackmarket:get_weapon_blueprint(category, slot) or default_blueprint

	local current_min, current_max = get_weapon_pickup(name, blueprint)
	local pickup_multiplier = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
	local base_pickup = (base_min + base_max) * 0.5
	local current_pickup = (current_min + current_max) * 0.5

	base_stats.pickup.value = base_pickup
	mods_stats.pickup.value = current_pickup - base_pickup
	skill_stats.pickup.value = current_pickup * pickup_multiplier - current_pickup
	skill_stats.pickup.skill_in_effect = pickup_multiplier ~= 1

	return base_stats, mods_stats, skill_stats
end

function WeaponDescription._get_custom_pellet_stats(name, category, slot, blueprint)
	local weapon_tweak = tweak_data.weapon[name]

	if not weapon_tweak then
		return
	end

	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	blueprint = blueprint or slot and managers.blackmarket:get_weapon_blueprint(category, slot) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

	if not blueprint then
		return weapon_tweak.rays
	end

	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

	for _, mod in ipairs(blueprint) do
		local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

		if part_data and part_data.custom_stats and part_data.custom_stats.rays then
			return part_data.custom_stats.rays
		end
	end

	return weapon_tweak.rays
end

local get_weapon_ammo_info_original = WeaponDescription.get_weapon_ammo_info
function WeaponDescription.get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod, ammo_max_mul_mod)
	local ammo_max_per_clip, ammo_max, ammo_data = get_weapon_ammo_info_original(weapon_id, extra_ammo, total_ammo_mod, ammo_max_mul_mod)
	local multiplier = managers.player:upgrade_value("player", "claim_their_bones_ammo_multiplier", 1)

	if multiplier ~= 1 then
		local skill_value = ammo_max * multiplier - ammo_max

		ammo_data.skill = ammo_data.skill + skill_value
		ammo_data.skill_in_effect = true
		ammo_max = math.max(ammo_max_per_clip, math.round(ammo_max * multiplier))
	end

	return ammo_max_per_clip, ammo_max, ammo_data
end

local get_skill_stats_original = WeaponDescription._get_skill_stats
function WeaponDescription._get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local skill_stats = get_skill_stats_original(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local weapon_tweak = tweak_data.weapon[name]
	local magazine_stats = skill_stats.magazine

	if not weapon_tweak or not magazine_stats then
		return skill_stats
	end

	local primary_category = weapon_tweak.categories[1]
	local has_hh_modifier = false
	local replaced_automatic_mag = false

	if is_weapon_category(weapon_tweak, "shotgun") then
		local multiplier = managers.player:upgrade_value("player", "cool_hunting_basic", 1)

		if multiplier > 1 then
			local bonus = math.ceil(weapon_tweak.CLIP_AMMO_MAX * (multiplier - 1))

			if bonus >= 1 then
				magazine_stats.value = magazine_stats.value + bonus
				has_hh_modifier = true
			end
		end
	elseif is_weapon_category(weapon_tweak, "pistol") and is_weapon_category(weapon_tweak, "revolver") and managers.player:has_category_upgrade("pistol", "magazine_capacity_inc") then
		local bonus = managers.player:upgrade_value("pistol", "magazine_capacity_inc", 0)

		if primary_category == "akimbo" then
			bonus = bonus * 2 + managers.player:upgrade_value(name, "clip_ammo_increase", 0)
		end

		magazine_stats.value = magazine_stats.value + bonus
		has_hh_modifier = true
	elseif is_weapon_category(weapon_tweak, "smg", "assault_rifle", "lmg") then
		local vanilla_bonus = managers.player:upgrade_value("player", "automatic_mag_increase", 0)

		if primary_category == "akimbo" then
			vanilla_bonus = vanilla_bonus * 2
		end

		if vanilla_bonus ~= 0 then
			magazine_stats.value = magazine_stats.value - vanilla_bonus
			replaced_automatic_mag = true
		end

		local multiplier = managers.player:upgrade_value("player", "lead_demi_basic", 1)

		if multiplier > 1 then
			local bonus = math.ceil(weapon_tweak.CLIP_AMMO_MAX * (multiplier - 1))

			if bonus >= 1 then
				magazine_stats.value = magazine_stats.value + bonus
				has_hh_modifier = true
			end
		end
	end

	if replaced_automatic_mag then
		magazine_stats.skill_in_effect = managers.player:has_category_upgrade(name, "clip_ammo_increase") or managers.player:has_category_upgrade("weapon", "clip_ammo_increase") or has_hh_modifier
	elseif has_hh_modifier then
		magazine_stats.skill_in_effect = true
	end

	return skill_stats
end
