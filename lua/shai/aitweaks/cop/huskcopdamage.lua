Hooks:PreHook(HuskCopDamage, "die", "zeal_effect_removal_husk_die", function (self, attack_data)
	if self._unit:base() then
		self._unit:base():disable_zeal_effect()
	end
	
	local current_unit = self._unit:name()
	if self._unit:base()._tweak_table == "taser" and current_unit == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer") then
		self._cruel_death_effect = World:effect_manager():spawn({
			effect = Idstring("effects/particles/custom/taser_death_explosion"),
			parent = self._unit:get_object(Idstring("Spine2"))
		})
	end
end)