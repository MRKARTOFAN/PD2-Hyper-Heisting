local function effects_enabled()
	local active_enemy_asset_mods = PD2FRAY and PD2FRAY._active_enemy_asset_mods
	local options = rawget(_G, "CruelTranceEnemies") and CruelTranceEnemies.Options
	return active_enemy_asset_mods and active_enemy_asset_mods["Cruel Trance Enemies"] and options
		and not options:GetValue("CTE_disable_effects")
end

local effects = {}
local function add_effect(path, effect)
	effects[Idstring(path):key()] = effect
	effects[Idstring(path .. "_husk"):key()] = effect
end

add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3", "halo_distorted")
add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4", "fire_head_red")
add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic", "symbol_x")
add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870", "symbol_x")
add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh", "zeal_smoke_puff")
add_effect("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870", "zeal_smoke_puff_one_side")
add_effect("units/pd2_dlc_drm/characters/ene_zeal_armored_light/ene_zeal_armored_light", "halo_distorted")
add_effect("units/pd2_dlc_drm/characters/ene_sniper_heavy/ene_sniper_heavy", "fire_head_blue")
add_effect("units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy", "meow_taser_lightnings")
add_effect("units/payday2/characters/ene_city_shield/ene_city_shield", "blood_head")
add_effect("units/pd2_dlc_drm/characters/ene_city_swat_saiga/ene_city_swat_saiga", "satellite_sparks_brown")
add_effect("units/pd2_dlc_drm/characters/ene_medic_carkdown/ene_medic_carkdown", "symbol_x")
add_effect("units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4", "symbol_x")
add_effect("units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870", "symbol_x")
add_effect("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic", "symbol_x")
add_effect("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870", "symbol_x")

local tasers = {}
local function add_taser(path)
	tasers[Idstring(path):key()] = true
	tasers[Idstring(path .. "_husk"):key()] = true
end

add_taser("units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy")

local function spawn_taser_burst(self)
	local unit = self._unit
	local key = unit and unit:name():key()
	if not tasers[key] then
		return
	end

	self._cruel_death_effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/CruelEffects/electric_explosion_purple"),
		parent = unit:get_object(Idstring("Spine2"))
	})
end

if CopBase then
	Hooks:RemovePreHook("PD2FRAYCruelTranceSpawnEffect", CopBase)
	Hooks:PreHook(CopBase, "_chk_spawn_gear", "PD2FRAYCruelTranceSpawnEffect", function(self)
		local effect = effects[self._unit:name():key()]
		if effect and effects_enabled() and self.enable_cruel_effect then
			self:enable_cruel_effect(effect)
		end
	end)
end

if CopDamage then
	Hooks:RemovePreHook("PD2FRAYCruelTranceDeathEffect", CopDamage)
	Hooks:PreHook(CopDamage, "die", "PD2FRAYCruelTranceDeathEffect", function(self)
		if effects_enabled() then
			spawn_taser_burst(self)
		end
	end)
end

if HuskCopDamage then
	Hooks:RemovePreHook("PD2FRAYCruelTranceHuskDeathEffect", HuskCopDamage)
	Hooks:PreHook(HuskCopDamage, "die", "PD2FRAYCruelTranceHuskDeathEffect", function(self)
		if effects_enabled() then
			spawn_taser_burst(self)
		end
	end)
end
