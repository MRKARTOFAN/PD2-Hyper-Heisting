Hooks:PostHook(GroupAITweakData, "_init_task_data", "shai_grenade_settings", function(self, difficulty_index)
	local f = math.max(0, difficulty_index - 2) / 6
	self.smoke_grenade_timeout = { 25, 35 }
	self.smoke_grenade_lifetime = math.lerp(9, 15, f)
	self.flash_grenade_timeout = { 15, 20 }
	self.flash_grenade.timer = math.lerp(2, 1, f)
	self.cs_grenade_timeout = { 60, 90 }
	self.cs_grenade_lifetime = math.lerp(20, 40, f)
	self.cs_grenade_chance_times = { 60, math.lerp(240, 180, f) }
	self.min_grenade_timeout = 15
	self.no_grenade_push_delay = 0
	self.spawn_cooldown_mul = math.lerp(2, 1, f)
	self.spawn_kill_cooldown = math.lerp(20, 10, f)
	self.spawn_kill_max_dis = 1500
	self.besiege.assault.fade = {
		enemies_defeated_percentage = 0.5,
		enemies_defeated_time = 30,
		engagement_percentage = 0.35,
		engagement_time = 20,
		drama_time = 5
	}

	self.besiege.reenforce.interval = { 60, 45, 30 }
	self.besiege.recon.force = { 1, 2, 2 }
	self.besiege.recon.interval = { 25, 30, 35 }
	self.besiege.recon.interval_variation = 15
	self.besiege.assault.force = { 10, 13, 16 }
	self.besiege.assault.force_pool = { 120, 150, 200 }
	self.besiege.assault.delay = { 20, 15, 10 }
	self.besiege.assault.sustain_duration_min = { math.lerp(60, 120, f), math.lerp(120, 180, f), math.lerp(180, 240, f) }
	self.besiege.assault.sustain_duration_max = self.besiege.assault.sustain_duration_min
	self.besiege.assault.hostage_hesitation_delay = { 15, 15, 15 }
	self.besiege.assault.force_balance_mul = { 1, 2, 3, 3.5 }
	self.besiege.assault.force_pool_balance_mul = { 1, 1.5, 2, 2.5 }
	self.besiege.assault.sustain_duration_balance_mul = { 1, 1, 1, 1 }

	local rifle_weight = 13.2
	local rifle_flank_weight = 13.2
	local shotgun_weight = 13.05
	local shotgun_flank_weight = 13.05
	local punk_weight = 5.25
	local special_weight = math.lerp(5, 6.5, f)
	local special_weight_tbl = { 0, special_weight * 0.75, special_weight }
	local rare_special_weight_tbl = { 0, special_weight * 0.35, special_weight * 0.6 }
	local no_spawn_weight_tbl = { 0, 0, 0 }

	self.besiege.assault.groups = {
		tac_swat_shotgun_rush = { shotgun_weight * 0.5, shotgun_weight * 0.75, shotgun_weight },
		tac_swat_shotgun_rush_no_medic = { shotgun_weight * 0.5, shotgun_weight * 0.25, 0 },
		tac_swat_shotgun_flank = { shotgun_flank_weight * 0.5, shotgun_flank_weight * 0.75, shotgun_flank_weight },
		tac_swat_shotgun_flank_no_medic = { shotgun_flank_weight * 0.5, shotgun_flank_weight * 0.25, 0 },
		tac_swat_rifle = { rifle_weight * 0.5, rifle_weight * 0.75, rifle_weight },
		tac_swat_rifle_no_medic = { rifle_weight * 0.5, rifle_weight * 0.25, 0 },
		tac_swat_rifle_flank = { rifle_flank_weight * 0.5, rifle_flank_weight * 0.75, rifle_flank_weight },
		tac_swat_rifle_flank_no_medic = { rifle_flank_weight * 0.5, rifle_flank_weight * 0.25, 0 },
		punks_A = { punk_weight * 0.5, punk_weight * 0.75, punk_weight },
		punks_B = { punk_weight * 0.5, punk_weight * 0.75, punk_weight },
		punks_C = { punk_weight * 0.25, punk_weight * 0.5, punk_weight * 0.75 },
		tac_shield_wall_ranged = special_weight_tbl,
		tac_shield_wall_charge = special_weight_tbl,
		tac_tazer_flanking = special_weight_tbl,
		tac_tazer_charge = special_weight_tbl,
		tac_bull_rush = special_weight_tbl,
		tac_bull_tazer_rush = rare_special_weight_tbl,
		FBI_spoocs = special_weight_tbl,
		tac_spooc_tazer = rare_special_weight_tbl,
		single_spooc = no_spawn_weight_tbl,
		Phalanx = no_spawn_weight_tbl,
		marshal_squad = no_spawn_weight_tbl,
		snowman_boss = no_spawn_weight_tbl,
		piggydozer = no_spawn_weight_tbl,
		custom = no_spawn_weight_tbl,
		custom_assault = no_spawn_weight_tbl
	}

	self.besiege.reenforce.groups = {
		reenforce_init = { 1, 0, 0 },
		reenforce_light = { 0, 1, 0 },
		reenforce_heavy = { 0, 0, 1 }
	}

	self.besiege.recon.groups = {
		hostage_rescue = { 0.1, 0.15, 0.2 },
		punks_A = { 0.5, 0.75, 1 },
		punks_B = { 0.25, 0.5, 0.75 },
		punks_C = { 0, 0.25, 0.5 },
		single_spooc = no_spawn_weight_tbl,
		Phalanx = no_spawn_weight_tbl,
		marshal_squad = no_spawn_weight_tbl,
		snowman_boss = no_spawn_weight_tbl,
		piggydozer = no_spawn_weight_tbl,
		custom = no_spawn_weight_tbl,
		custom_recon = no_spawn_weight_tbl
	}

	-- Regroup duration
	self.besiege.regroup.duration = { 30, 25, 20 }

	-- Scripted cloaker spawn interval
	self.besiege.recurring_group_SO.recurring_cloaker_spawn.interval = { math.lerp(60, 15, f), math.lerp(120, 30, f) }

	-- Copy besiege settings to street and safehouse
	self.street = deep_clone(self.besiege)
	self.safehouse = deep_clone(self.besiege)
	
	-- [Hater] No Winters
	self.phalanx.check_spawn_intervall = 999999
	self.phalanx.chance_increase_intervall = 999999

	self.phalanx.spawn_chance = {
		decrease = 0,
		start = 0,
		respawn_delay = 999999,
		increase = 0,
		max = 0
	}
end)

-- Special unit spawn limits
Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "shai_special_limits", function(self, difficulty_index)
	local limits_shield = { 0, 2, 2, 3, 3, 4, 4, 5 }
	local limits_medic  = { 0, 0, 0, 0, 1, 2, 3, 4 }
	local limits_taser  = { 0, 0, 1, 1, 2, 2, 3, 3 }
	local limits_tank   = { 0, 0, 0, 1, 1, 2, 2, 2 } -- [Karto] Dozers are scary, if you don't have nuke setup for them.
	local limits_spooc  = { 0, 0, 0, 1, 1, 2, 2, 3 }
	self.special_unit_spawn_limits.shield = limits_shield[difficulty_index]
	self.special_unit_spawn_limits.medic = limits_medic[difficulty_index]
	self.special_unit_spawn_limits.taser = limits_taser[difficulty_index]
	self.special_unit_spawn_limits.tank = limits_tank[difficulty_index]
	self.special_unit_spawn_limits.spooc = limits_spooc[difficulty_index]
	local fbi_suits = self.unit_categories.FBI_suit_C45_M4.unit_types
	fbi_suits.federales = { Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"), Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2") }
	fbi_suits.murkywater = deep_clone(fbi_suits.federales)

	--fbiGODS (ninjas)
	local access_type_all = { acrobatic = true, walk = true }
	if difficulty_index < 6 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america    = { Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"), Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2") },
				bo_hh      = { Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"), Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4") },
				russia     = { Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"), Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45") },
				zombie     = { Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"), Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4") },
				murkywater = { Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4") },
				federales  = { Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"), Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45") },
				shared     = { Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"), Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4") }
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america    = { Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"), Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4") },
				bo_hh      = { Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"), Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4") },
				russia     = { Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"), Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45") },
				zombie     = { Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"), Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4") },
				murkywater = { Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4") },
				federales  = { Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"), Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45") },
				shared     = { Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"), Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4") }
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america    = { Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4"), Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45") },
				bo_hh      = { Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"), Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4") },
				russia     = { Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"), Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45") },
				zombie     = { Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"), Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4") },
				murkywater = { Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4") },
				federales  = { Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"), Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45") },
				shared     = { Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"), Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"), Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45"), Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4") }
			},
			access = access_type_all
		}
	end

	-- Light shotgun swats from HH
	if difficulty_index < 6 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	end

	-- Heavy shotgun swats from HH,
	if difficulty_index < 6 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index <= 7 then
		self.unit_categories.medic_M4 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
				}
			},
			access = access_type_all
		}
		self.unit_categories.medic_R870 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.medic_M4 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic")
				}
			},
			access = access_type_all
		}
		self.unit_categories.medic_R870 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index <= 3 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index <= 5 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index <= 7 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
				},
				bo_hh = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}
	end

	local medic_dozer_units = {}
	for _, unit_name in ipairs({
		"units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic",
		"units/pd2_dlc_drm/characters/ene_bulldozer_medic_classic/ene_bulldozer_medic_classic",
		"units/pd2_dlc_mad/characters/ene_akan_dozer_medic/ene_akan_dozer_medic",
		"units/pd2_dlc_mad/characters/ene_akan_fbi_tank_medic/ene_akan_fbi_tank_medic",
		"units/pd2_dlc_hvh/characters/ene_bulldozer_medic_hvh/ene_bulldozer_medic_hvh",
		"units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic",
		"units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic",
		"units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale"
	}) do
		medic_dozer_units[Idstring(unit_name):key()] = true
	end
	local tank_types = self.unit_categories.FBI_tank and self.unit_categories.FBI_tank.unit_types
	if tank_types then
		for _, units in pairs(tank_types) do
			for i = #units, 1, -1 do
				if medic_dozer_units[units[i]:key()] then
					table.remove(units, i)
				end
			end
		end
	end
end)

Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "shai_spawn_groups", function(self, difficulty_index)
	local f = math.max(0, difficulty_index - 2) / 6

	-- Tactics used by spawn groups
	self._tactics.swat_shotgun_rush = { "charge", "deathguard", "harass", "smoke_grenade", "flash_grenade" }
	self._tactics.swat_shotgun_flank = { "charge", "flank", "deathguard", "harass", "flash_grenade" }
	self._tactics.swat_rifle = { "charge", "harass", "smoke_grenade", "flash_grenade" }
	self._tactics.swat_rifle_flank = { "charge", "flank", "deathguard", "harass", "flash_grenade" }
	self._tactics.shield_wall_ranged = { "shield", "charge", "deathguard" }
	self._tactics.shield_wall_charge = { "shield", "charge", "deathguard" }
	self._tactics.tank_rush = { "shield", "charge", "deathguard", "harass", "smoke_grenade", "murder" }
	self._tactics.tazer_charge = { "charge", "deathguard", "harass", "smoke_grenade", "murder" }
	self._tactics.tazer_flanking = { "flank", "harass", "flash_grenade", "murder" }
	self._tactics.spooc = { "flank", "harass", "smoke_grenade", "unit_cover" }
	self._tactics.support_ranged = { "unit_cover", "charge", "deathguard" }
	self._tactics.support_charge = { "unit_cover", "charge", "deathguard" }

	local shield_support_ranged = self._tactics.shield_support_ranged or self._tactics.support_ranged
	local shield_support_charge = self._tactics.shield_support_charge or self._tactics.support_charge

	self.enemy_spawn_groups.tac_swat_shotgun_rush = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_rush },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_rush },
			{ freq = difficulty_index / 16, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.support_charge }
		}
	}
	self.enemy_spawn_groups.tac_swat_shotgun_rush_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_shotgun_rush)
	table.remove(self.enemy_spawn_groups.tac_swat_shotgun_rush_no_medic.spawn)

	self.enemy_spawn_groups.tac_swat_shotgun_flank = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_flank },
			{ freq = math.lerp(0, 0.75, f), rank = 2, unit = "FBI_suit_M4_MP5", tactics = self._tactics.swat_shotgun_flank },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.support_charge }
		}
	}
	self.enemy_spawn_groups.tac_swat_shotgun_flank_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_shotgun_flank)
	table.remove(self.enemy_spawn_groups.tac_swat_shotgun_flank_no_medic.spawn)

	self.enemy_spawn_groups.tac_swat_rifle = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ freq = 1, rank = 2, amount_max = 2, amount_min = 1, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle },
			{ freq = difficulty_index / 16, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.support_ranged }
		}
	}
	self.enemy_spawn_groups.tac_swat_rifle_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_rifle)
	table.remove(self.enemy_spawn_groups.tac_swat_rifle_no_medic.spawn)

	self.enemy_spawn_groups.tac_swat_rifle_flank = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, rank = 2, amount_max = 2, amount_min = 1, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle_flank },
			{ freq = math.lerp(0, 0.75, f), rank = 2, unit = "FBI_suit_M4_MP5", tactics = self._tactics.swat_rifle_flank },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.support_ranged }
		}
	}
	self.enemy_spawn_groups.tac_swat_rifle_flank_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_rifle_flank)
	table.remove(self.enemy_spawn_groups.tac_swat_rifle_flank_no_medic.spawn)

	self.enemy_spawn_groups.tac_shield_wall_ranged = {
		amount = { 4, 4 },
		spawn = {
			{ freq = difficulty_index / 16, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_shield", tactics = self._tactics.shield_wall_ranged },
			{ freq = 0.25, rank = 2, unit = "FBI_swat_M4", tactics = shield_support_ranged },
			{ freq = 1, rank = 2, unit = "FBI_heavy_G36", tactics = shield_support_ranged },
			{ freq = 0.30, amount_max = 2, rank = 2, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle },
			{ freq = 0.5, rank = 2, unit = "FBI_heavy_R870", tactics = shield_support_ranged },
			{ freq = difficulty_index / 32, amount_max = 1, rank = 1, unit = "medic_M4", tactics = shield_support_ranged }
		}
	}
	self.enemy_spawn_groups.tac_shield_wall = self.enemy_spawn_groups.tac_shield_wall_ranged

	self.enemy_spawn_groups.tac_shield_wall_charge = {
		amount = { 4, 4 },
		spawn = {
			{ freq = difficulty_index / 16, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_shield", tactics = self._tactics.shield_wall_charge },
			{ freq = 0.25, rank = 2, unit = "FBI_swat_R870", tactics = shield_support_charge },
			{ freq = 1, rank = 2, unit = "FBI_heavy_R870", tactics = shield_support_charge },
			{ freq = difficulty_index / 32, amount_max = 1, rank = 1, unit = "medic_R870", tactics = shield_support_charge }
		}
	}

	self.enemy_spawn_groups.tac_bull_rush = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
			{ freq = 1, rank = 1, unit = "FBI_heavy_R870", tactics = shield_support_charge },
			{ freq = 1, rank = 1, unit = "FBI_heavy_G36", tactics = shield_support_charge },
			{ freq = difficulty_index / 64, amount_max = 1, rank = 1, unit = "medic_R870", tactics = shield_support_charge }
		}
	}

	self.enemy_spawn_groups.tac_bull_tazer_rush = {
		amount = { 2, 2 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 1, unit = "CS_tazer", tactics = shield_support_charge }
		}
	}

	-- Taser groups
	self.enemy_spawn_groups.tac_tazer_flanking = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
			{ freq = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.tazer_flanking },
			{ freq = 1, rank = 1, unit = "FBI_LHmix", tactics = self._tactics.tazer_flanking }
		}
	}

	self.enemy_spawn_groups.tac_tazer_charge = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
			{ freq = 1, rank = 1, unit = "FBI_swat_R870", tactics = self._tactics.tazer_charge }
		}
	}

	-- Cloaker groups
	self.enemy_spawn_groups.tac_spooc_tazer = {
		amount = { 2, 2 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 1, unit = "spooc", tactics = self._tactics.spooc },
			{ freq = 1, amount_min = 1, amount_max = 1, rank = 1, unit = "CS_tazer", tactics = self._tactics.tazer_flanking }
		}
	}
	--punks
	self.enemy_spawn_groups.punks_A = {
		amount = { 3, 5 },
		spawn = {
			{ freq = 1.5, amount_min = 2, amount_max = 2, rank = 2, unit = "punk_group", tactics = self._tactics.swat_rifle_flank },
			{ freq = 0.75, amount_max = 2, rank = 2, unit = "FBI_swat_M4", tactics = shield_support_ranged },
			{ freq = 0.75, amount_max = 2, rank = 2, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 2, unit = "medic_M4", tactics = shield_support_ranged },
			{ freq = difficulty_index / 12, amount_max = 2, rank = 3, unit = "FBI_shield", tactics = self._tactics.shield_wall_ranged }
		}
	}

	self.enemy_spawn_groups.punks_B = {
		amount = { 4, 5 },
		spawn = {
			{ freq = 0.5, amount_max = 1, rank = 2, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_rush },
			{ freq = 2, amount_min = 1, amount_max = 1, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ freq = 2.25, amount_min = 2, amount_max = 3, rank = 1, unit = "punk_group", tactics = self._tactics.swat_shotgun_rush },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 3, unit = "medic_M4", tactics = self._tactics.support_ranged }
		}
	}

	self.enemy_spawn_groups.punks_C = {
		amount = { 3, 5 },
		spawn = {
			{ freq = 1, amount_max = 2, rank = 2, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
			{ freq = math.max(0, difficulty_index - 3) / 12, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
			{ freq = difficulty_index / 24, amount_max = 1, rank = 2, unit = "medic_R870", tactics = self._tactics.support_charge },
			{ freq = 1, amount_min = 2, amount_max = 2, rank = 1, unit = "punk_group", tactics = self._tactics.swat_shotgun_rush }
		}
	}

	-- Hostage rescue (recon)
	self.enemy_spawn_groups.hostage_rescue = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 0.35, amount_max = 1, rank = 2, unit = "FBI_suit_C45_M4", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, rank = 1, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle_flank }
		}
	}

	-- Reenforce groups
	self.enemy_spawn_groups.reenforce_init = {
		amount = { 2, 2 },
		spawn = {
			{ freq = 1, amount_min = 1, rank = 1, unit = "FBI_suit_C45_M4", tactics = self._tactics.swat_rifle }
		}
	}

	self.enemy_spawn_groups.reenforce_light = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 1, amount_min = 1, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ freq = 1, rank = 2, unit = "FBI_LHmix", tactics = self._tactics.swat_rifle },
			{ freq = 0.5, rank = 1, unit = "FBI_suit_C45_M4", tactics = self._tactics.swat_rifle }
		}
	}

	self.enemy_spawn_groups.reenforce_heavy = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 1, amount_min = 1, rank = 2, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle },
			{ freq = 0.5, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle }
		}
	}
end)
Hooks:PostHook(GroupAITweakData, "_init_chatter_data", "shai_chatter_settings", function(self, difficulty_index)
	if self.enemy_chatter.go_go then
		self.enemy_chatter.push = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.push.queue = "pus"
		
		self.enemy_chatter.flank = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.flank.queue = "t01"
		
		self.enemy_chatter.open_fire = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.open_fire.queue = "att"
		
		self.enemy_chatter.get_hostages = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.get_hostages.queue = "civ"
		
		self.enemy_chatter.get_loot = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.get_loot.queue = "l01"
		
		self.enemy_chatter.watch_background = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.watch_background.queue = "bak"
		self.enemy_chatter.watch_background.duration = { 10, 20 }
		
		self.enemy_chatter.hostage_delay_1 = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.hostage_delay_1.queue = "p01"
		self.enemy_chatter.hostage_delay_1.duration = { 20, 40 }
		self.enemy_chatter.hostage_delay_1.radius = 1500
		
		self.enemy_chatter.hostage_delay_2 = clone(self.enemy_chatter.hostage_delay_1)
		self.enemy_chatter.hostage_delay_2.queue = "p02"
		
		self.enemy_chatter.suppress = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.suppress.queue = "hlp"
		
		self.enemy_chatter.stand_by = clone(self.enemy_chatter.go_go)
		self.enemy_chatter.stand_by.queue = "prm"
		
		self.enemy_chatter.group_death = clone(self.enemy_chatter.watch_background)
		self.enemy_chatter.group_death.queue = "lk3a"
		
		self.enemy_chatter.trip_mine = clone(self.enemy_chatter.contact)
		self.enemy_chatter.trip_mine.queue = "ch1"
		self.enemy_chatter.trip_mine.duration = { 20, 40 }
		self.enemy_chatter.trip_mine.radius = 2000
		
		self.enemy_chatter.sentry_gun = clone(self.enemy_chatter.trip_mine)
		self.enemy_chatter.sentry_gun.queue = "ch2"
		
		self.enemy_chatter.jammer = clone(self.enemy_chatter.aggressive)
		self.enemy_chatter.jammer.queue = "ch3"
		self.enemy_chatter.jammer.radius = 1500
		
		self.enemy_chatter.saw = clone(self.enemy_chatter.sentry_gun)
		self.enemy_chatter.saw.queue = "ch4"
		
		self.enemy_chatter.detect = clone(self.enemy_chatter.contact)
		self.enemy_chatter.detect.queue = "a01"
		self.enemy_chatter.detect.radius = 1000
		self.enemy_chatter.detect.duration = { 5, 10 }
	end
end)
