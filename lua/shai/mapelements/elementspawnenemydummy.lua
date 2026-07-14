Hooks:PreHook(ElementSpawnEnemyDummy, "init", "hh_capture", function(self, mission_script, data)
	self._hh_pbr2_enemy_name = data and data.values and data.values.enemy
end)

Hooks:PostHook(ElementSpawnEnemyDummy, "init", "hh_replace", function(self)
	if Global.game_settings and Global.game_settings.level_id == "pbr2"
		and self._hh_pbr2_enemy_name == "units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4" then
		self._enemy_name = Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4")
	end

	local enemy_name = self._hh_pbr2_enemy_name
	if Global.game_settings and Global.game_settings.difficulty == "sm_wish"
		and tweak_data.levels:get_ai_group_type() == "america"
		and (enemy_name == "units/payday2/characters/ene_sniper_1/ene_sniper_1"
			or enemy_name == "units/payday2/characters/ene_sniper_2/ene_sniper_2") then
		self._enemy_name = Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_sniper/ene_zeal_sniper")
	end
end)
-- [Karto] A fucked up way to fix a crash of scripted dozer on BoS (and might only not). I'm sure there is a better way to do it, is it?
