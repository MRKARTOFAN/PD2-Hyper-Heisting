if PD2FRAY:IsVisualProviderEnabled("Hyper ZEAL Punks and Ninjas") then
	Hooks:RemovePreHook("hyper_punk_post_init", CopBase)
end

Hooks:PreHook(CopBase, "post_init", "fray_visual_provider_weapon_snapshot", function(self)
	if PD2FRAY:IsVisualProviderEnabled("Hyper ZEAL Punks and Ninjas") then
		self._fray_visual_provider_weapon_id = self._default_weapon_id
	end
end)

Hooks:PostHook(CopBase, "post_init", "fray_visual_provider_weapon_restore", function(self)
	if self._fray_visual_provider_weapon_id then
		self._default_weapon_id = self._fray_visual_provider_weapon_id
		self._fray_visual_provider_weapon_id = nil
	end
end)

-- Dynamically load throwable if we have one
local unit_ids = IDS_UNIT
Hooks:PostHook(CopBase, "init", "sh_init", function(self)
	local throwable = self._char_tweak.throwable
	if not throwable then
		return
	end

	local tweak_entry = tweak_data.blackmarket.projectiles[throwable]
	local unit_name = Idstring(Network:is_client() and tweak_entry.local_unit or tweak_entry.unit)
	local sprint_unit_name = tweak_entry.sprint_unit and Idstring(tweak_entry.sprint_unit)

	if not PackageManager:has(unit_ids, unit_name) then
		managers.dyn_resource:load(unit_ids, unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
	end

	if sprint_unit_name and not PackageManager:has(unit_ids, sprint_unit_name) then
		managers.dyn_resource:load(unit_ids, sprint_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
	end
end)


-- Check for weapon changes
CopBase.unit_weapon_mapping = nil
if not Network:is_client() then
	Hooks:PreHook(CopBase, "post_init", "sh_post_init", function(self)
		if not self.unit_weapon_mapping then return end
		local mapping = self.unit_weapon_mapping[self._unit:name():key()]
		local mapping_type = type(mapping)
		if mapping_type == "table" then
			local selector = WeightedSelector:new()
			for k, v in pairs(mapping) do
				if type(k) == "number" then
					selector:add(v, 1)
				else
					selector:add(k, v)
				end
			end
			self._default_weapon_id = selector:select() or self._default_weapon_id
		elseif mapping_type == "string" then
			self._default_weapon_id = mapping
		end
	end)
end
