local asset_loader = ModInstance:GetSuperMod():GetAssetLoader()

local function add_unit_pair(unit_paths, path)
	unit_paths[path] = true
	unit_paths[path .. "_husk"] = true
end

local hyper_zeal_fray_units = {}
for _, path in ipairs({
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870",
	"units/payday2/characters/ene_medic_m4/ene_medic_m4",
	"units/payday2/characters/ene_medic_r870/ene_medic_r870",
	"units/pd2_dlc_drm/characters/ene_zeal_armored_light/ene_zeal_armored_light",
	"units/pd2_dlc_drm/characters/ene_sniper_heavy/ene_sniper_heavy",
	"units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy"
}) do
	add_unit_pair(hyper_zeal_fray_units, path)
end

local hyper_zeal_punk_fray_units = {}
for _, path in ipairs({
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco",
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5",
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss",
	"units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45",
	"units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45",
	"units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss",
	"units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco",
	"units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5",
	"units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss",
	"units/payday2/characters/ene_cop_3/ene_cop_3",
	"units/payday2/characters/ene_fbi_3/ene_fbi_3"
}) do
	add_unit_pair(hyper_zeal_punk_fray_units, path)
end

local hyper_zeal_shield_fray_units = {}
for _, path in ipairs({
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield",
	"units/pd2_dlc_drm/characters/ene_shield_heavy/ene_shield_heavy"
}) do
	add_unit_pair(hyper_zeal_shield_fray_units, path)
end

local cruel_trance_fray_units = {}
for _, path in ipairs({
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3",
	"units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870",
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco",
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5",
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss",
	"units/pd2_dlc_drm/characters/ene_zeal_armored_light/ene_zeal_armored_light",
	"units/pd2_dlc_drm/characters/ene_sniper_heavy/ene_sniper_heavy",
	"units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy"
}) do
	add_unit_pair(cruel_trance_fray_units, path)
end

local resmod_zeal_fray_units = {}
for _, path in ipairs({
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2",
	"units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic",
	"units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"
}) do
	add_unit_pair(resmod_zeal_fray_units, path)
end

local conditional_fray_units = {}
for path in pairs(cruel_trance_fray_units) do
	conditional_fray_units[path] = true
end
for path in pairs(hyper_zeal_fray_units) do
	conditional_fray_units[path] = true
end
for path in pairs(hyper_zeal_punk_fray_units) do
	conditional_fray_units[path] = true
end
for path in pairs(hyper_zeal_shield_fray_units) do
	conditional_fray_units[path] = true
end
for path in pairs(resmod_zeal_fray_units) do
	conditional_fray_units[path] = true
end

local function bind_enemy_asset_mod_presentation(mod_asset_loader, aliases)
	if not mod_asset_loader then
		return 0
	end

	local object_count = 0
	for _, spec in ipairs(mod_asset_loader.asset_specs) do
		if spec.extension ~= "unit" then
			for source_root, alias_root in pairs(aliases) do
				if spec.dbpath:sub(1, #source_root) == source_root then
					local extension = Idstring(spec.extension)
					local source_dbpath = Idstring(spec.dbpath)
					local alias_dbpath = Idstring(alias_root .. spec.dbpath:sub(#source_root + 1))

					if spec._entry_created then
						DB:remove_entry(extension, source_dbpath)
					end
					blt.ignoretweak(source_dbpath, extension)
					BLT.AssetManager:CreateEntry(source_dbpath, extension, spec.file)
					spec._entry_created = true
					blt.ignoretweak(alias_dbpath, extension)
					BLT.AssetManager:CreateEntry(alias_dbpath, extension, spec.file)
					object_count = object_count + (spec.extension == "object" and 1 or 0)
					break
				end
			end
		end
	end
	return object_count
end

local function bind_enemy_asset_mod_specs(specs, aliases)
	local asset_count = 0
	for _, spec in ipairs(specs or {}) do
		if spec.extension == "model" or spec.extension == "material_config" or spec.extension == "cooked_physics" then
			for source_root, alias_root in pairs(aliases) do
				if spec.dbpath:sub(1, #source_root) == source_root then
					if alias_root then
						local extension = Idstring(spec.extension)
						local alias_dbpath = Idstring(alias_root .. spec.dbpath:sub(#source_root + 1))
						blt.ignoretweak(alias_dbpath, extension)
						BLT.AssetManager:CreateEntry(alias_dbpath, extension, spec.file)
					end
					asset_count = asset_count + 1
					break
				end
			end
		end
	end
	return asset_count
end

local function bind_enemy_asset_mod_group(mod_asset_loader, group_name, aliases)
	local group = mod_asset_loader and mod_asset_loader.script_loadable_packages[group_name]
	return group and bind_enemy_asset_mod_specs(group.assets, aliases) or 0
end

local function has_enemy_asset_mod_resources(specs, resources)
	local available = {}
	for _, spec in ipairs(specs or {}) do
		available[spec.extension .. ":" .. spec.dbpath] = true
	end

	for _, resource in ipairs(resources) do
		if not available[resource[1] .. ":" .. resource[2]] then
			return false
		end
	end
	return true
end

local function has_enemy_asset_mod_group_resources(mod_asset_loader, group_name, resources)
	local group = mod_asset_loader and mod_asset_loader.script_loadable_packages[group_name]
	return group and has_enemy_asset_mod_resources(group.assets, resources) or false
end

local function release_fray_units(unit_paths)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return false
	end

	local unit_type = Idstring("unit")
	for path in pairs(unit_paths) do
		local unit_path = Idstring(path)
		if DB:has(unit_type, unit_path) or file_manager:Has(unit_type, unit_path) then
			file_manager:UnloadAsset(unit_type, unit_path)
			file_manager:RemoveFile(unit_type, unit_path)
		end
	end
	return true
end

local function preload_fray_units(unit_paths, claimed_units)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return
	end

	local unit_type = Idstring("unit")
	for path in pairs(unit_paths) do
		if not claimed_units[path] then
			local unit_path = Idstring(path)
			if file_manager:Has(unit_type, unit_path) then
				file_manager:LoadAsset(unit_type, unit_path)
			end
		end
	end
end

local function claim_units(claimed_units, unit_paths)
	for path in pairs(unit_paths) do
		claimed_units[path] = true
	end
end

local function release_enemy_asset_mod_units(mod_asset_loader, group_name, unit_paths)
	local group = mod_asset_loader and mod_asset_loader.script_loadable_packages[group_name]
	if not group then
		return
	end

	for _, spec in ipairs(group.assets) do
		if spec.extension == "unit" and unit_paths[spec.dbpath] then
			if spec._entry_created then
				spec._entry_created = false
				DB:remove_entry(Idstring(spec.extension), Idstring(spec.dbpath))
			end
			if spec._targeted_package then
				managers.dyn_resource:unload(Idstring(spec.extension), Idstring(spec.dbpath), spec._targeted_package, false)
				spec._targeted_package = nil
			end
		end
	end
end

local function load_hyper_zeal()
	local settings = rawget(_G, "HyperZEAL") and HyperZEAL.settings
	local enemy_asset_mod = BLT.Mods:GetModByName("Hyper ZEAL")
	local enemy_asset_supermod = enemy_asset_mod and enemy_asset_mod:GetSuperMod()
	local mod_asset_loader = enemy_asset_supermod and enemy_asset_supermod:GetAssetLoader()
	if not mod_asset_loader then
		return false
	end

	local medic_color_group = settings and settings.medic_rifle == 2 and "medic_dcpd_red" or "medic_dcpd_blue"
	local shield_setting = settings and settings.shield or 2
	local shield_source_group = shield_setting == 1 and "shield_light"
		or shield_setting == 3 and "shield_orange"
		or "shield_armored"
	release_enemy_asset_mod_units(mod_asset_loader, "main", hyper_zeal_fray_units)
	release_enemy_asset_mod_units(mod_asset_loader, "medic_dcpd", hyper_zeal_fray_units)
	release_enemy_asset_mod_units(mod_asset_loader, medic_color_group, hyper_zeal_fray_units)
	release_enemy_asset_mod_units(mod_asset_loader, shield_source_group, hyper_zeal_shield_fray_units)

	local main_wrappers = asset_loader.script_loadable_packages["fray_enemyassetmods_hyper_zeal"]
	local medic_blue_wrappers = asset_loader.script_loadable_packages["fray_enemyassetmods_hyper_zeal_medic_blue"]
	local medic_red_wrappers = asset_loader.script_loadable_packages["fray_enemyassetmods_hyper_zeal_medic_red"]
	if not main_wrappers or #main_wrappers.assets ~= 22
		or not medic_blue_wrappers or #medic_blue_wrappers.assets ~= 4
		or not medic_red_wrappers or #medic_red_wrappers.assets ~= 4 then
		return false
	end

	local medic_r870_resources = {
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870_contour" }
	}
	local medic_m4_resources = {
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4_contour" }
	}
	local medic_helmet_resources = {
		{ "unit", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "unit", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_r870_helmet/ene_acc_zeal_medic_r870_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_r870_helmet/ene_acc_zeal_medic_r870_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_r870_helmet/ene_acc_zeal_medic_r870_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_r870_helmet/ene_acc_zeal_medic_r870_helmet" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_r870_helmet/ene_acc_zeal_medic_r870_helmet" }
	}
	if not has_enemy_asset_mod_group_resources(mod_asset_loader, "main", medic_r870_resources)
		or not has_enemy_asset_mod_resources(mod_asset_loader.asset_specs, medic_helmet_resources)
		or (not settings or settings.medic_rifle ~= 2)
			and not has_enemy_asset_mod_group_resources(mod_asset_loader, "medic_rifle_blue", medic_m4_resources) then
		return false
	end

	local object_count = bind_enemy_asset_mod_presentation(mod_asset_loader, {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/"] = "units/fray_enemyassetmods/hyper_zeal/ene_zeal_swat_2/",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/"] = "units/fray_enemyassetmods/hyper_zeal/ene_zeal_swat_heavy_2/"
	})
	if object_count < 2 then
		return false
	end

	if not release_fray_units(hyper_zeal_fray_units) or not release_fray_units(hyper_zeal_shield_fray_units) then
		return false
	end

	asset_loader:LoadAssetGroup("fray_enemyassetmods_hyper_zeal")
	local medic_group = settings and settings.medic_rifle == 2 and "fray_enemyassetmods_hyper_zeal_medic_red"
		or "fray_enemyassetmods_hyper_zeal_medic_blue"
	asset_loader:LoadAssetGroup(medic_group)
	local shield_group = shield_setting == 1 and "fray_enemyassetmods_hyper_zeal_shield_light"
		or "fray_enemyassetmods_hyper_zeal_shield_armored"
	asset_loader:LoadAssetGroup(shield_group)
	return true
end

local function load_hyper_zeal_punks()
	Hooks:RemovePostHook("hyper_punk_init_unit_categories", GroupAITweakData)
	Hooks:RemovePreHook("hyper_punk_post_init", CopBase)

	local enemy_asset_mod = BLT.Mods:GetModByName("Hyper ZEAL Punks and Ninjas")
	local enemy_asset_supermod = enemy_asset_mod and enemy_asset_mod:GetSuperMod()
	local mod_asset_loader = enemy_asset_supermod and enemy_asset_supermod:GetAssetLoader()
	local wrapper_group = asset_loader.script_loadable_packages["fray_enemyassetmods_hyper_zeal_punks_ninjas"]
	if not wrapper_group or #wrapper_group.assets ~= 28 then
		return false
	end
	local object_count = bind_enemy_asset_mod_presentation(mod_asset_loader, {
		["units/payday2/characters/ene_cop_1/"] = "units/fray_enemyassetmods/hyper_zeal_punks_ninjas/ene_cop_1/",
		["units/payday2/characters/ene_cop_3/"] = "units/fray_enemyassetmods/hyper_zeal_punks_ninjas/ene_cop_3/",
		["units/payday2/characters/ene_cop_4/"] = "units/fray_enemyassetmods/hyper_zeal_punks_ninjas/ene_cop_4/"
	})
	if object_count < 3 or not release_fray_units(hyper_zeal_punk_fray_units) then
		return false
	end

	asset_loader:LoadAssetGroup("fray_enemyassetmods_hyper_zeal_punks_ninjas")
	return true
end

local function load_resmod_zeal()
	local enemy_asset_mod = BLT.Mods:GetModByName("Resmod ZEAL")
	local enemy_asset_supermod = enemy_asset_mod and enemy_asset_mod:GetSuperMod()
	local mod_asset_loader = enemy_asset_supermod and enemy_asset_supermod:GetAssetLoader()
	if not mod_asset_loader then
		return false
	end

	local taser_headgear_group = asset_loader.script_loadable_packages["fray_enemyassetmods_resmod_zeal_taser_headgear"]
	local taser_headgear_resources = {
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_tazer_helmet/ene_acc_zeal_tazer_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_tazer_helmet/ene_acc_zeal_tazer_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_tazer_helmet/ene_acc_zeal_tazer_helmet" }
	}
	if not taser_headgear_group or #taser_headgear_group.assets ~= 1
		or not has_enemy_asset_mod_group_resources(mod_asset_loader, "main", taser_headgear_resources) then
		return false
	end
	asset_loader:LoadAssetGroup("fray_enemyassetmods_resmod_zeal_taser_headgear")

	release_enemy_asset_mod_units(mod_asset_loader, "main", resmod_zeal_fray_units)

	local common_wrappers = asset_loader.script_loadable_packages["fray_enemyassetmods_resmod_zeal_common"]
	local city_wrappers = asset_loader.script_loadable_packages["fray_enemyassetmods_resmod_zeal_cities"]
	if not common_wrappers or #common_wrappers.assets ~= 9 or not city_wrappers or #city_wrappers.assets ~= 13 then
		return false
	end

	local main_resources = {
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy_contour" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/ene_zeal_swat_heavy_2" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/ene_zeal_swat_heavy_2" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/ene_zeal_swat_heavy_2" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/ene_zeal_swat_heavy_2_contour" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_heavy_helmet/ene_acc_zeal_swat_heavy_helmet" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_heavy_helmet/ene_acc_zeal_swat_heavy_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_medic_m4/ene_zeal_medic_m4_contour" }
	}
	local medic_helmet_resources = {
		{ "unit", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_medic_helmet/ene_acc_zeal_medic_helmet" }
	}
	local modern_resources = {
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat_contour" },
		{ "unit", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/ene_zeal_swat_2" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/ene_zeal_swat_2" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/ene_zeal_swat_2" }
	}
	local classic_resources = {
		{ "object", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat" },
		{ "material_config", "units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat_contour" },
		{ "unit", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "object", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "model", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" },
		{ "cooked_physics", "units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/ene_acc_zeal_swat_helmet" }
	}
	if not has_enemy_asset_mod_group_resources(mod_asset_loader, "main", main_resources)
		or not has_enemy_asset_mod_resources(mod_asset_loader.asset_specs, medic_helmet_resources)
		or not has_enemy_asset_mod_group_resources(mod_asset_loader, "light_modern", modern_resources)
		or not has_enemy_asset_mod_group_resources(mod_asset_loader, "light_classic", classic_resources) then
		return false
	end

	local modern_count = bind_enemy_asset_mod_group(mod_asset_loader, "light_modern", {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat/"] = "units/fray_enemyassetmods/resmod_zeal/city_1/ene_zeal_swat/",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/"] = "units/fray_enemyassetmods/resmod_zeal/city_2/ene_zeal_swat_2/",
		["units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/"] = "units/fray_enemyassetmods/resmod_zeal/city_1/ene_acc_zeal_swat_helmet/"
	})
	local classic_count = bind_enemy_asset_mod_group(mod_asset_loader, "light_classic", {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat/"] = "units/fray_enemyassetmods/resmod_zeal/city_3/ene_zeal_swat/",
		["units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_helmet/"] = "units/fray_enemyassetmods/resmod_zeal/city_3/ene_acc_zeal_swat_helmet/"
	})
	local main_count = bind_enemy_asset_mod_group(mod_asset_loader, "main", {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/"] = false,
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/"] = "units/fray_enemyassetmods/resmod_zeal/common/ene_zeal_swat_heavy_2/",
		["units/pd2_dlc_gitgud/characters/ene_acc_zeal_swat_heavy_helmet/"] = false
	})
	if modern_count < 8 or classic_count < 6 or main_count < 9 then
		return false
	end

	if not release_fray_units(resmod_zeal_fray_units) then
		return false
	end

	asset_loader:LoadAssetGroup("fray_enemyassetmods_resmod_zeal_common")
	asset_loader:LoadAssetGroup("fray_enemyassetmods_resmod_zeal_cities")
	return true
end

local cruel_trance_sentinels = {
	"effects/particles/CruelEffects/halo_distorted.effect",
	"units/payday2/characters/ene_spook_1/ene_spook_1.sequence_manager",
	"units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1.object"
}

local function find_cruel_trance()
	local framework = BeardLib and BeardLib.Frameworks and BeardLib.Frameworks.Base
	if not framework or not framework._loaded_mods then
		return nil
	end

	for _, enemy_asset_mod in pairs(framework._loaded_mods) do
		if enemy_asset_mod:GetName() == "Cruel Trance Enemies" and enemy_asset_mod:IsEnabled() then
			return enemy_asset_mod
		end
	end
end

local function normalize_path(path)
	return tostring(path):gsub("\\", "/"):gsub("/+", "/")
end

local function collect_files(path, files)
	for _, file in pairs(FileIO:GetFiles(path) or {}) do
		table.insert(files, Path:Combine(path, file))
	end
	for _, folder in pairs(FileIO:GetFolders(path) or {}) do
		collect_files(Path:Combine(path, folder), files)
	end
end

local cruel_trance_presentations = {
	"units/payday2/characters/ene_fbi_2/ene_fbi_2.object",
	"units/payday2/characters/ene_fbi_3/ene_fbi_3.object",
	"units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1.model",
	"units/payday2/characters/ene_medic_m4/ene_medic_m4.object",
	"units/payday2/characters/ene_medic_r870/ene_medic_r870.object",
	"units/payday2/characters/ene_cop_2/ene_cop_2.object",
	"units/payday2/characters/ene_cop_3/ene_cop_3.object",
	"units/payday2/characters/ene_cop_4/ene_cop_4.object",
	"units/payday2/characters/ene_sniper_1/ene_sniper_1.object",
	"units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2.object",
	"units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2.model",
	"units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2.material_config",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat.model",
	"units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer.model",
	"units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy.object",
	"units/pd2_dlc_drm/characters/ene_zeal_swat_heavy_sniper/ene_zeal_swat_heavy_sniper.object"
}

local function validate_cruel_trance_presentations(enemy_asset_mod)
	local asset_root = Path:Combine(enemy_asset_mod:GetPath(), "assets")
	for _, path in ipairs(cruel_trance_sentinels) do
		if not FileIO:Exists(Path:Combine(asset_root, path)) then
			return false
		end
	end
	for _, path in ipairs(cruel_trance_presentations) do
		if not FileIO:Exists(Path:Combine(asset_root, path)) then
			return false
		end
	end
	return true
end

local function release_cruel_trance_units(enemy_asset_mod)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return false
	end

	local asset_root = normalize_path(Path:Combine(enemy_asset_mod:GetPath(), "assets"))
	local files = {}
	collect_files(Path:Combine(asset_root, "units"), files)
	local unit_type = Idstring("unit")

	for _, physical_path in ipairs(files) do
		local physical = normalize_path(physical_path)
		if physical:sub(-5) == ".unit" then
			local dbpath = physical:sub(#asset_root + 2, -6)
			local enemy_unit = dbpath:find("/characters/ene_", 1, true)
				and not dbpath:find("/characters/ene_acc_", 1, true)
			if enemy_unit or dbpath:find("/weapons/", 1, true) then
				local unit_path = Idstring(dbpath)
				local entry = file_manager:Get(unit_type, unit_path)
				if entry and normalize_path(entry.file):lower() == physical:lower() then
					file_manager:UnloadAsset(unit_type, unit_path)
					file_manager:RemoveFile(unit_type, unit_path)
				end
			end
		end
	end
	return true
end

local function load_cruel_trance(enemy_asset_mod)
	if not release_cruel_trance_units(enemy_asset_mod) then
		return false
	end
	local options = rawget(_G, "CruelTranceEnemies") and CruelTranceEnemies.Options
	if not options then
		return false
	end
	local wrapper_group = asset_loader.script_loadable_packages["fray_enemyassetmods_cruel_trance"]
	if not wrapper_group or #wrapper_group.assets ~= 30 then
		return false
	end
	if not validate_cruel_trance_presentations(enemy_asset_mod) then
		return false
	end
	if not release_fray_units(cruel_trance_fray_units) then
		return false
	end

	asset_loader:LoadAssetGroup("fray_enemyassetmods_cruel_trance")
	return true
end

DelayedCalls:Add("PD2FRAYLoadEnemyAssetMods", 0, function()
	local claimed_units = {}
	PD2FRAY._active_enemy_asset_mods = {}

	local cruel_trance = find_cruel_trance()
	local cruel_trance_loaded = cruel_trance and load_cruel_trance(cruel_trance) or false
	PD2FRAY._active_enemy_asset_mods["Cruel Trance Enemies"] = cruel_trance_loaded
	if cruel_trance_loaded then
		claim_units(claimed_units, cruel_trance_fray_units)
	else
		local resmod_zeal_loaded = PD2FRAY:IsEnemyAssetModEnabled("Resmod ZEAL") and load_resmod_zeal() or false
		PD2FRAY._active_enemy_asset_mods["Resmod ZEAL"] = resmod_zeal_loaded
		if resmod_zeal_loaded then
			claim_units(claimed_units, resmod_zeal_fray_units)
		else
			if PD2FRAY:IsEnemyAssetModEnabled("Hyper ZEAL") and load_hyper_zeal() then
				PD2FRAY._active_enemy_asset_mods["Hyper ZEAL"] = true
				claim_units(claimed_units, hyper_zeal_fray_units)
				claim_units(claimed_units, hyper_zeal_shield_fray_units)
			end
			if PD2FRAY:IsEnemyAssetModEnabled("Hyper ZEAL Punks and Ninjas") and load_hyper_zeal_punks() then
				PD2FRAY._active_enemy_asset_mods["Hyper ZEAL Punks and Ninjas"] = true
				claim_units(claimed_units, hyper_zeal_punk_fray_units)
			end
		end
	end

	preload_fray_units(conditional_fray_units, claimed_units)
end)
