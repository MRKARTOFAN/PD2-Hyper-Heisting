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
	"units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"
}) do
	add_unit_pair(hyper_zeal_punk_fray_units, path)
end

local cruel_trance_fray_units = {}
for path in pairs(hyper_zeal_fray_units) do
	if not path:find("units/payday2/characters/ene_medic_m4/", 1, true) then
		cruel_trance_fray_units[path] = true
	end
end
for path in pairs(hyper_zeal_punk_fray_units) do
	cruel_trance_fray_units[path] = true
end
add_unit_pair(cruel_trance_fray_units, "units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4")

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

					-- A separate name prevents a graph cached before asset selection from winning.
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

local function release_fray_units(unit_paths)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return false
	end

	local unit_type = Idstring("unit")
	for path in pairs(unit_paths) do
		local unit_path = Idstring(path)
		if DB:has(unit_type, unit_path) or file_manager:Has(unit_type, unit_path) then
			-- Both registries retain unit graphs independently on x64.
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

local function load_hyper_zeal_medic_materials(mod_asset_loader, settings)
	if not mod_asset_loader then
		return
	end

	-- These body graphs predate x64, while their material files are safe to reuse.
	for _, group_name in ipairs({ "medic_dcpd", "medic_dcpd_blue", "medic_dcpd_red" }) do
		if mod_asset_loader.script_loadable_packages[group_name] then
			mod_asset_loader:FreeAssetGroup(group_name)
		end
	end

	local color_group = settings and settings.medic_rifle == 2 and "medic_dcpd_red" or "medic_dcpd_blue"
	for _, material in ipairs({
		{ name = "units/payday2/characters/ene_medic_m4/ene_medic_m4.material_config", path = "assets/" .. color_group .. "/units/payday2/characters/ene_medic_m4/ene_medic_m4.material_config" },
		{ name = "units/payday2/characters/ene_medic_m4/ene_medic_m4_contour.material_config", path = "assets/" .. color_group .. "/units/payday2/characters/ene_medic_m4/ene_medic_m4_contour.material_config" },
		{ name = "units/payday2/characters/ene_medic_r870/ene_medic_r870.material_config", path = "assets/medic_dcpd/units/payday2/characters/ene_medic_r870/ene_medic_r870.material_config" },
		{ name = "units/payday2/characters/ene_medic_r870/ene_medic_r870_contour.material_config", path = "assets/medic_dcpd/units/payday2/characters/ene_medic_r870/ene_medic_r870_contour.material_config" }
	}) do
		mod_asset_loader:LoadAsset(material.name, material.path, { target = "immediate", dyn_package = "false" })
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

	load_hyper_zeal_medic_materials(mod_asset_loader, settings)
	local object_count = bind_enemy_asset_mod_presentation(mod_asset_loader, {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/"] = "units/fray_enemyassetmods/hyper_zeal/ene_zeal_swat_2/",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/"] = "units/fray_enemyassetmods/hyper_zeal/ene_zeal_swat_heavy_2/"
	})
	if object_count < 2 then
		return false
	end

	-- SuperBLT can otherwise wait on the asset mod's unit while Fray reclaims the same database path.
	release_enemy_asset_mod_units(mod_asset_loader, "main", {
		["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870"] = true,
		["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870_husk"] = true
	})
	if not release_fray_units(hyper_zeal_fray_units) then
		return false
	end

	asset_loader:LoadAssetGroup("fray_enemyassetmods_hyper_zeal")
	local medic_group = settings and settings.medic_rifle == 2 and "fray_enemyassetmods_hyper_zeal_medic_red"
		or "fray_enemyassetmods_hyper_zeal_medic_blue"
	asset_loader:LoadAssetGroup(medic_group)
	local shield_group = settings and settings.shield == 1 and "fray_enemyassetmods_hyper_zeal_shield_light"
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
			local asset_path = Path:Combine(enemy_asset_mod:GetPath(), "assets")
			local valid = true
			for _, sentinel in ipairs(cruel_trance_sentinels) do
				if not FileIO:Exists(Path:Combine(asset_path, sentinel)) then
					valid = false
					break
				end
			end
			if valid then
				return enemy_asset_mod
			end
		end
	end
end

local function normalize_path(path)
	return tostring(path):gsub("\\", "/"):gsub("/+", "/")
end

local function collect_files(path, files)
	for _, file in pairs(FileIO:GetFiles(path)) do
		table.insert(files, Path:Combine(path, file))
	end
	for _, folder in pairs(FileIO:GetFolders(path)) do
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
					-- CT's presentation may stay registered, but its legacy extension graph may not.
					file_manager:UnloadAsset(unit_type, unit_path)
					file_manager:RemoveFile(unit_type, unit_path)
				end
			end
		end
	end
	return true
end

local function load_cruel_trance(enemy_asset_mod)
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
	if not release_cruel_trance_units(enemy_asset_mod) or not release_fray_units(cruel_trance_fray_units) then
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
		if PD2FRAY:IsEnemyAssetModEnabled("Hyper ZEAL") and load_hyper_zeal() then
			PD2FRAY._active_enemy_asset_mods["Hyper ZEAL"] = true
			claim_units(claimed_units, hyper_zeal_fray_units)
		end
		if PD2FRAY:IsEnemyAssetModEnabled("Hyper ZEAL Punks and Ninjas") and load_hyper_zeal_punks() then
			PD2FRAY._active_enemy_asset_mods["Hyper ZEAL Punks and Ninjas"] = true
			claim_units(claimed_units, hyper_zeal_punk_fray_units)
		end
	end

	preload_fray_units(conditional_fray_units, claimed_units)
end)
