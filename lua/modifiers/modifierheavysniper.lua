ModifierHeavySniper = ModifierHeavySniper or class(BaseModifier)
ModifierHeavySniper._type = "ModifierHeavySniper"
ModifierHeavySniper.name_id = "none"
ModifierHeavySniper.desc_id = "menu_cs_modifier_heavy_sniper"
ModifierHeavySniper.default_value = "spawn_chance"

function ModifierHeavySniper:init(data)
	ModifierHeavySniper.super.init(self, data)

	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_sniper/ene_bulldozer_sniper"))
		
end

function ModifierHeavySniper:modify_value(id, value)
	return value
end
