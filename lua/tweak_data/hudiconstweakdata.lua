local hh_crime_spree_modifier_icons = {
	cs_modifier_bronconinja = "modifier_bronconinja",
	cs_modifier_ftsudozer = "modifier_ftsudozer",
	cs_modifier_difficultyspike = "modifier_difficultyspike",
	cs_modifier_magnetstorm = "modifier_magnetstorm",
	cs_modifier_themegas = "modifier_themegas",
	cs_modifier_saigasec = "modifier_saigasec",
	cs_modifier_shoryu = "modifier_shoryu",
	cs_modifier_telespooc = "modifier_telespooc",
	cs_modifier_aggro = "modifier_aggro",
	cs_modifier_zealot = "modifier_zealot",
	cs_modifier_bouncer = "modifier_bouncer"
}

Hooks:PostHook(HudIconsTweakData, "init", "hh_icons", function(self)
	local image_size = 128

	for icon_id, texture_name in pairs(hh_crime_spree_modifier_icons) do
		self[icon_id] = {
			texture = "guis/dlcs/drm/textures/pd2/crime_spree/" .. texture_name,
			texture_rect = { 0, 0, image_size, image_size }
		}
	end
end)
