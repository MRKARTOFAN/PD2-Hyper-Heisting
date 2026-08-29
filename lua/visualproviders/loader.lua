local asset_loader = ModInstance:GetSuperMod():GetAssetLoader()

local hyper_zeal_fray_units = {
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870_husk"] = true,
	["units/payday2/characters/ene_medic_m4/ene_medic_m4"] = true,
	["units/payday2/characters/ene_medic_m4/ene_medic_m4_husk"] = true
}

local hyper_zeal_punk_fray_units = {
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss_husk"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco"] = true,
	["units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco_husk"] = true
}

local function bind_provider_presentation(provider_asset_loader, aliases)
	if not provider_asset_loader then
		return 0
	end

	local object_count = 0

	for _, spec in ipairs(provider_asset_loader.asset_specs) do
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

local function release_fray_units(unit_paths)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return nil
	end

	for path in pairs(unit_paths) do
                local unit_path = Idstring(path)
                local unit_type = Idstring("unit")
		if DB:has(unit_type, unit_path) or file_manager:Has(unit_type, unit_path) then
			file_manager:UnloadAsset(unit_type, unit_path)
			file_manager:RemoveFile(unit_type, unit_path)
		end
	end
	return true
end

local function preload_fray_units(unit_paths)
	local file_manager = BeardLib and BeardLib.Managers and BeardLib.Managers.File
	if not file_manager then
		return
	end

	for path in pairs(unit_paths) do
		local unit_path = Idstring(path)
		local unit_type = Idstring("unit")
		if file_manager:Has(unit_type, unit_path) then
			file_manager:LoadAsset(unit_type, unit_path)
		end
	end
end

local function release_provider_units(provider_asset_loader, group_name, unit_paths)
	local group = provider_asset_loader and provider_asset_loader.script_loadable_packages[group_name]
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

local function load_hyper_zeal_medic_materials(provider_asset_loader, settings)
	if not provider_asset_loader then
		return
	end
	for _, group_name in ipairs({ "medic_dcpd", "medic_dcpd_blue", "medic_dcpd_red" }) do
		if provider_asset_loader.script_loadable_packages[group_name] then
			provider_asset_loader:FreeAssetGroup(group_name)
		end
	end

	local color_group = settings and settings.medic_rifle == 2 and "medic_dcpd_red" or "medic_dcpd_blue"
	local materials = {
		{
			name = "units/payday2/characters/ene_medic_m4/ene_medic_m4.material_config",
			path = "assets/" .. color_group .. "/units/payday2/characters/ene_medic_m4/ene_medic_m4.material_config"
		},
		{
			name = "units/payday2/characters/ene_medic_m4/ene_medic_m4_contour.material_config",
			path = "assets/" .. color_group .. "/units/payday2/characters/ene_medic_m4/ene_medic_m4_contour.material_config"
		},
		{
			name = "units/payday2/characters/ene_medic_r870/ene_medic_r870.material_config",
			path = "assets/medic_dcpd/units/payday2/characters/ene_medic_r870/ene_medic_r870.material_config"
		},
		{
			name = "units/payday2/characters/ene_medic_r870/ene_medic_r870_contour.material_config",
			path = "assets/medic_dcpd/units/payday2/characters/ene_medic_r870/ene_medic_r870_contour.material_config"
		}
	}

	for _, material in ipairs(materials) do
		provider_asset_loader:LoadAsset(material.name, material.path, {
			target = "immediate",
			dyn_package = "false"
		})
	end
end

local function load_hyper_zeal()
	local settings = rawget(_G, "HyperZEAL") and HyperZEAL.settings
	local medic_group = settings and settings.medic_rifle == 2 and "fray_visual_hyper_zeal_medic_red"
		or "fray_visual_hyper_zeal_medic_blue"
	local provider = BLT.Mods:GetModByName("Hyper ZEAL")
	local provider_supermod = provider and provider:GetSuperMod()
	local provider_asset_loader = provider_supermod and provider_supermod:GetAssetLoader()

	load_hyper_zeal_medic_materials(provider_asset_loader, settings)
        local object_count = bind_provider_presentation(provider_asset_loader, {
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_2/"] = "units/fray_visualproviders/hyper_zeal/ene_zeal_swat_2/",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_2/"] = "units/fray_visualproviders/hyper_zeal/ene_zeal_swat_heavy_2/"
        })
	if object_count >= 2 then
		release_provider_units(provider_asset_loader, "main", {
			["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870"] = true,
			["units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870_husk"] = true
		})
		local released = release_fray_units(hyper_zeal_fray_units)
		if released then
			asset_loader:LoadAssetGroup("fray_visual_hyper_zeal")
		else
			return false
		end
		else
			return false
	end
	asset_loader:LoadAssetGroup(medic_group)

	local shield_group = settings and settings.shield == 1 and "fray_visual_hyper_zeal_shield_light"
		or "fray_visual_hyper_zeal_shield_armored"
	asset_loader:LoadAssetGroup(shield_group)
	return true
end

local providers = {
	["Hyper ZEAL"] = load_hyper_zeal,
	["Hyper ZEAL Punks and Ninjas"] = function()
		Hooks:RemovePostHook("hyper_punk_init_unit_categories", GroupAITweakData)
		Hooks:RemovePreHook("hyper_punk_post_init", CopBase)

		local provider = BLT.Mods:GetModByName("Hyper ZEAL Punks and Ninjas")
		local provider_supermod = provider and provider:GetSuperMod()
		local provider_asset_loader = provider_supermod and provider_supermod:GetAssetLoader()

		local object_count = bind_provider_presentation(provider_asset_loader, {
			["units/payday2/characters/ene_cop_1/"] = "units/fray_visualproviders/hyper_zeal_punks_ninjas/ene_cop_1/",
			["units/payday2/characters/ene_cop_3/"] = "units/fray_visualproviders/hyper_zeal_punks_ninjas/ene_cop_3/",
			["units/payday2/characters/ene_cop_4/"] = "units/fray_visualproviders/hyper_zeal_punks_ninjas/ene_cop_4/"
                })
		if object_count >= 3 then
				local released = release_fray_units(hyper_zeal_punk_fray_units)
				if released then
					asset_loader:LoadAssetGroup("fray_visual_hyper_zeal_punks_ninjas")
					return true
				end
			else
			end
			return false
		end
}

DelayedCalls:Add("PD2FRAYLoadVisualProviders", 0, function()
	PD2FRAY._active_visual_providers = {}

	for name, load_provider in pairs(providers) do
		if PD2FRAY:IsVisualProviderEnabled(name) then
			PD2FRAY._active_visual_providers[name] = load_provider() == true
		end
	end

	if not PD2FRAY._active_visual_providers["Hyper ZEAL"] then
		preload_fray_units(hyper_zeal_fray_units)
	end
	if not PD2FRAY._active_visual_providers["Hyper ZEAL Punks and Ninjas"] then
		preload_fray_units(hyper_zeal_punk_fray_units)
	end
end)
