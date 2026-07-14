local ids_unit = Idstring("unit")

local shai_custom_units = {
	"units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45",
	"units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh",
	"units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh",
	"units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh",
	"units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh",
	"units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45",
	"units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4",
	"units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45",
	"units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4",
	"units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh",
	"units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh",
	"units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass",
	"units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45",
	"units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh",
	"units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45",
	"units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss",
	"units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5",
	"units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45",
	"units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4",
	"units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870",
	"units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar",
	"units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870",
	"units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle",
	"units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump",
	"units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco",
	"units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss",
	"units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5",
	"units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic",
	"units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"
}

Hooks:PostHook(DynamicResourceManager, "preload_units", "shai_preload_custom_units", function(self)
	local dyn_package = self.DYN_RESOURCES_PACKAGE

	for _, path in ipairs(shai_custom_units) do
		local unit = Idstring(path)
		if PackageManager:has(ids_unit, unit) and not self:has_resource(ids_unit, unit, dyn_package) then
			self:load(ids_unit, unit, dyn_package)
		end

		local husk = Idstring(path .. "_husk")
		if PackageManager:has(ids_unit, husk) and not self:has_resource(ids_unit, husk, dyn_package) then
			self:load(ids_unit, husk, dyn_package)
		end
	end
end)
