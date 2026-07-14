local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.tiny_font
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.tiny_font_size

local function is_steam_inventory(self)
	local tab = self._tabs and self._tabs[self._selected]
	local identifier = tab and tab._data and tab._data.identifier

	return self._data and self._data.create_steam_inventory_extra or identifier == self.identifiers.weapon_cosmetic or identifier == self.identifiers.inventory_tradable
end

local function get_damage_stat(stats_shown)
	for _, stat in ipairs(stats_shown or {}) do
		if stat.name == "damage" then
			return stat
		end
	end
end

local function is_shotgun_weapon(name)
	local weapon_tweak = name and tweak_data.weapon[name]

	return weapon_tweak and weapon_tweak.categories and table.contains(weapon_tweak.categories, "shotgun")
end

local function get_weapon_blueprint(name, category, slot, blueprint)
	if blueprint then
		return blueprint
	end

	if category and slot then
		return managers.blackmarket:get_weapon_blueprint(category, slot)
	end

	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)

	return factory_id and managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
end

local function get_weapon_rays(name, category, slot, blueprint)
	if not is_shotgun_weapon(name) then
		return
	end

	blueprint = get_weapon_blueprint(name, category, slot, blueprint)

	return WeaponDescription._get_custom_pellet_stats and WeaponDescription._get_custom_pellet_stats(name, category, slot, blueprint) or tweak_data.weapon[name].rays
end

local function get_total_damage(base_stats, mods_stats, skill_stats)
	return math.max(base_stats.damage.value + mods_stats.damage.value + skill_stats.damage.value, 0)
end

local function format_round(num, round_value)
	return round_value and tostring(math.round(num)) or string.format("%.1f", num):gsub("%.?0+$", "")
end

local function set_pellet_damage_text(text, value, stat, rays)
	if not text then
		return
	end

	if rays and rays > 1 then
		text:set_text(tostring(math.round(value / rays)) .. "x" .. tostring(rays))
	else
		text:set_text(format_round(value, stat and stat.round_value))
	end
end

local function update_pellet_damage_preview(self, damage_text, damage_stat)
	local name = self._slot_data.weapon_id

	if not is_shotgun_weapon(name) then
		return
	end

	local blueprint = self._slot_data.default_blueprint
	local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, nil, nil, blueprint)
	local rays = get_weapon_rays(name, nil, nil, blueprint)

	set_pellet_damage_text(damage_text.equip, get_total_damage(base_stats, mods_stats, skill_stats), damage_stat, rays)
	set_pellet_damage_text(damage_text.base, base_stats.damage.value, damage_stat, tweak_data.weapon[name].rays)
end

local function update_pellet_damage_inventory(self, damage_text, damage_stat)
	local category = self._slot_data.category
	local slot = self._slot_data.slot
	local weapon = managers.blackmarket:get_crafted_category_slot(category, slot)
	local name = weapon and weapon.weapon_id or self._slot_data.name
	local equipped_item = managers.blackmarket:equipped_item(category)
	local equipped_slot = self._slot_data.equipped_slot or managers.blackmarket:equipped_weapon_slot(category)
	local equipped_name = self._slot_data.equipped_name or equipped_item and equipped_item.weapon_id

	if self._slot_data.default_blueprint then
		equipped_slot = slot
		equipped_name = name
	end

	if not name or not equipped_name then
		return
	end

	local blueprint = self._slot_data.default_blueprint
	local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)

	if slot == equipped_slot then
		if not is_shotgun_weapon(name) then
			return
		end

		local rays = get_weapon_rays(name, category, slot, blueprint)

		set_pellet_damage_text(damage_text.equip, get_total_damage(base_stats, mods_stats, skill_stats), damage_stat, rays)
		set_pellet_damage_text(damage_text.base, base_stats.damage.value, damage_stat, tweak_data.weapon[name].rays)

		return
	end

	if is_shotgun_weapon(equipped_name) then
		local equipped_base_stats, equipped_mods_stats, equipped_skill_stats = WeaponDescription._get_stats(equipped_name, category, equipped_slot)
		local equipped_rays = get_weapon_rays(equipped_name, category, equipped_slot)

		set_pellet_damage_text(damage_text.equip, get_total_damage(equipped_base_stats, equipped_mods_stats, equipped_skill_stats), damage_stat, equipped_rays)
	end

	if is_shotgun_weapon(name) then
		local rays = get_weapon_rays(name, category, slot, blueprint)

		set_pellet_damage_text(damage_text.total, get_total_damage(base_stats, mods_stats, skill_stats), damage_stat, rays)
	end
end

local function update_pellet_damage_attachment(self, damage_text, damage_stat)
	local category = self._slot_data.category
	local slot = self._slot_data.slot
	local weapon = managers.blackmarket:get_crafted_category_slot(category, slot)
	local name = weapon and weapon.weapon_id or self._slot_data.name

	if not weapon or not weapon.factory_id or not is_shotgun_weapon(name) then
		return
	end

	local blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)

	if not blueprint then
		return
	end

	blueprint = clone(blueprint)
	managers.weapon_factory:change_part_blueprint_only(weapon.factory_id, self._slot_data.name, blueprint, false)

	local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)
	local rays = get_weapon_rays(name, category, slot, blueprint)

	set_pellet_damage_text(damage_text.equip, get_total_damage(base_stats, mods_stats, skill_stats), damage_stat, rays)
end

Hooks:PostHook(BlackMarketGui, "_setup", "hh_add_weapon_pickup_stat", function(self)
	if is_steam_inventory(self) or not self._stats_shown or not self._stats_texts or self._stats_texts.pickup or not alive(self._rweapon_stats_panel) then
		return
	end

	local stat = {
		name = "pickup"
	}
	local columns = {
		{ size = 100, name = "name" },
		{ size = 45, name = "equip", align = "right", blend = "add", alpha = 0.75 },
		{ size = 45, name = "base", align = "right", blend = "add", alpha = 0.75 },
		{ size = 45, name = "mods", align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.stats_mods },
		{ size = 45, name = "removed", align = "right", blend = "add", alpha = 0.75, offset = -40, color = tweak_data.screen_colors.important_1, font_size = tiny_font_size },
		{ size = 45, name = "skill", align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.resource },
		{ size = 45, name = "total", align = "right" }
	}
	local index = 3

	for _, row in ipairs(self._rweapon_stats_panel:children()) do
		local old_index = math.round(row:y() / 20)

		if old_index >= index then
			local old_background = row:child(tostring(old_index))

			if alive(old_background) then
				row:remove(old_background)
			end

			local new_index = old_index + 1
			row:set_y(row:y() + 20)

			if math.mod(new_index, 2) == 0 then
				row:rect({
					name = tostring(new_index),
					color = Color.black:with_alpha(0.3)
				})
			end
		end
	end

	local panel = self._rweapon_stats_panel:panel({
		name = "weapon_stats",
		h = 20,
		layer = 1,
		y = index * 20,
		w = self._rweapon_stats_panel:w()
	})

	if math.mod(index, 2) == 0 then
		panel:rect({
			name = tostring(index),
			color = Color.black:with_alpha(0.3)
		})
	end

	table.insert(self._stats_shown, index, stat)
	self._stats_texts.pickup = {}

	local x = 2

	for _, column in ipairs(columns) do
		local text_panel = panel:panel({
			layer = 0,
			x = x + (column.offset or 0),
			w = column.size,
			h = panel:h()
		})

		self._stats_texts.pickup[column.name] = text_panel:text({
			layer = 1,
			font_size = column.font_size or small_font_size,
			font = small_font,
			align = column.align,
			alpha = column.alpha,
			blend_mode = column.blend,
			color = column.color or tweak_data.screen_colors.text,
			y = panel:h() - (column.font_size or small_font_size)
		})
		x = x + column.size + (column.offset or 0)

		if column.name == "total" then
			text_panel:set_x(190)
		end
	end

	self:show_stats()
	self:update_info_text()
end)

Hooks:PostHook(BlackMarketGui, "show_stats", "hh_show_shotgun_pellet_damage", function(self)
	if is_steam_inventory(self) or not self._slot_data or not self._stats_texts or not self._stats_texts.damage then
		return
	end

	local damage_stat = get_damage_stat(self._stats_shown)

	if not damage_stat then
		return
	end

	local damage_text = self._stats_texts.damage

	if self._slot_data.dont_compare_stats then
		update_pellet_damage_preview(self, damage_text, damage_stat)
	elseif tweak_data.weapon[self._slot_data.name] or self._slot_data.default_blueprint then
		update_pellet_damage_inventory(self, damage_text, damage_stat)
	elseif self._tabs and self._tabs[self._selected] and self._tabs[self._selected]._data.identifier == self.identifiers.weapon_mod then
		update_pellet_damage_attachment(self, damage_text, damage_stat)
	end
end)

local damage_falloff_to_string_original = BlackMarketGui.damage_falloff_to_string
function BlackMarketGui:damage_falloff_to_string(damage_falloff)
	if is_steam_inventory(self) or not damage_falloff or type(damage_falloff.display_range) ~= "number" or type(damage_falloff.far_multiplier) ~= "number" then
		return damage_falloff_to_string_original(self, damage_falloff)
	end

	local range_empty = managers.localization:get_default_macro("BTN_RANGE_EMPTY")
	local range_filled = managers.localization:get_default_macro("BTN_RANGE_FILLED")
	local range_bonus = managers.localization:get_default_macro("BTN_RANGE_BONUS")
	local display_range = damage_falloff.display_range
	local has_bonus = damage_falloff.far_multiplier > 1

	if display_range < 1 then
		return has_bonus and range_bonus .. range_empty .. range_empty or range_empty .. range_empty .. range_empty
	elseif display_range < 2 then
		return has_bonus and range_filled .. range_bonus .. range_bonus or range_filled .. range_empty .. range_empty
	elseif display_range < 3 then
		return has_bonus and range_filled .. range_filled .. range_bonus or range_filled .. range_filled .. range_empty
	elseif display_range == 3 then
		return has_bonus and range_filled .. range_filled .. range_filled .. range_bonus or range_filled .. range_filled .. range_filled
	end

	local chance = math.random(1, 42)

	if chance == 25 then
		return range_bonus .. range_bonus .. range_bonus .. range_bonus .. range_bonus
	end

	return managers.localization:to_upper_text("bm_menu_damage_falloff_lol_" .. tostring(chance))
end

local get_armor_stats_original = BlackMarketGui._get_armor_stats
function BlackMarketGui:_get_armor_stats(name)
	local base_stats, mods_stats, skill_stats = get_armor_stats_original(self, name)

	if managers.player:has_category_upgrade("player", "hh_grinder_base") and base_stats.armor and skill_stats.armor then
		skill_stats.armor.value = 1 - base_stats.armor.value
		skill_stats.armor.skill_in_effect = true
	end

	return base_stats, mods_stats, skill_stats
end

local set_info_text_original = BlackMarketGui.set_info_text
function BlackMarketGui:set_info_text(id, text, resource_color)
	local tab = self._tabs and self._tabs[self._selected]
	local is_grenade = not is_steam_inventory(self) and id == 4 and tab and tab._data.identifier == self.identifiers.grenade
	local projectile_data = is_grenade and self._slot_data and tweak_data.blackmarket.projectiles[self._slot_data.name]

	if projectile_data and projectile_data.base_cooldown then
		text = text .. "\n\nBase Cooldown: " .. tostring(projectile_data.base_cooldown) .. "s \n"
	elseif projectile_data and projectile_data.pickup_chance then
		text = text .. "\n\nPickup Chance per Box: " .. tostring(projectile_data.pickup_chance * 100) .. "% \n"
	end

	return set_info_text_original(self, id, text, resource_color)
end
