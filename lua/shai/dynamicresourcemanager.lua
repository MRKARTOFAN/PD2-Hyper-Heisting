local unit_type = Idstring("unit")

local function preload_enemy_asset_mod_units(manager)
	local unit_paths = PD2FRAY and PD2FRAY._enemy_asset_mod_preload_units
	if not manager or not unit_paths then
		return
	end

	local dyn_package = manager.DYN_RESOURCES_PACKAGE
	for path in pairs(unit_paths) do
		local unit = Idstring(path)
		if PackageManager:has(unit_type, unit) and not manager:has_resource(unit_type, unit, dyn_package) then
			manager:load(unit_type, unit, dyn_package)
		end
	end
end

PD2FRAY._preload_enemy_asset_mod_units = preload_enemy_asset_mod_units

Hooks:PostHook(DynamicResourceManager, "preload_units", "fray_preload_enemy_asset_mod_units", function(self)
	preload_enemy_asset_mod_units(self)
end)
