-- Dynamically load throwable if we have one
local unit_ids = Idstring("unit")
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

-- Effects for zeals setup
local zeal_effects_table = {
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic"),"symbol_x"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic_husk"),"symbol_x"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870"),"symbol_x"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870_husk"),"symbol_x"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer"),"meow_taser_lightnings"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer_husk"),"meow_taser_lightnings"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"),"zeal_smoke_puff_one_side"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870_husk"),"zeal_smoke_puff_one_side"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),"zeal_smoke_puff"},
	{Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy_husk"),"zeal_smoke_puff"},
}

Hooks:PreHook(CopBase, "_chk_spawn_gear", "_chk_spawn_gear_add_effect", function (self)
	local current_unit = self._unit

	for i, _ in ipairs(zeal_effects_table) do
		if zeal_effects_table[i][1] == current_unit:name() then
			local effect_name = zeal_effects_table[i][2]
			self._unit:base():enable_zeal_effect(effect_name)
		end
	end
end)

function CopBase:enable_zeal_effect(effect_name)
	if self._zeal_effect then
		return
	end

	local align_obj_name = Idstring("Head")
	local align_obj = self._unit:get_object(align_obj_name)

	if string.match(effect_name, "symbol_x") then
		align_obj = self._unit:get_object(Idstring("Spine1"))
	end


	self._zeal_effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/custom/"..effect_name),
		parent = align_obj,
	})
end

function CopBase:disable_zeal_effect()
	if self._zeal_effect then
		World:effect_manager():fade_kill(self._zeal_effect)
	end
end
