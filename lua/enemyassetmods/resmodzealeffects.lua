local units = {
	[Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"):key()] = true,
	[Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870_husk"):key()] = true
}

Hooks:RemovePreHook("PD2FRAYResmodZealHeadgear", CopDamage)
Hooks:PreHook(CopDamage, "_spawn_head_gadget", "PD2FRAYResmodZealHeadgear", function(self)
	local active_enemy_asset_mods = PD2FRAY and PD2FRAY._active_enemy_asset_mods
	local unit = self._unit
	if not active_enemy_asset_mods or not active_enemy_asset_mods["Resmod ZEAL"] or not unit
		or not self._head_gear or not units[unit:name():key()] then
		return
	end

	local head = unit:get_object(Idstring("Head"))
	if not head then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/impacts/metal_impact_pd2"),
		parent = head
	})
	local sound = unit:sound()
	if sound then
		sound:play("swatturret_weakspot_hit", nil, nil)
	end
end)
