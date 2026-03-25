-- Add grenade settings after HH's _init_task_data runs
Hooks:PostHook(GroupAITweakData, "_init_task_data", "shai_grenade_settings", function(self, difficulty_index)
	local f = math.max(0, difficulty_index - 2) / 6

	-- Grenade settings (SHAI needs these)
	self.smoke_grenade_timeout = { 25, 35 }
	self.smoke_grenade_lifetime = math.lerp(9, 15, f)
	self.flash_grenade_timeout = { 15, 20 }
	self.flash_grenade_timer = math.lerp(2, 1, f)
	self.cs_grenade_timeout = { 60, 90 }
	self.cs_grenade_lifetime = math.lerp(20, 40, f)
	self.cs_grenade_chance_times = { 60, math.lerp(240, 180, f) }
	self.min_grenade_timeout = 15
	self.no_grenade_push_delay = 8

	-- Spawn cooldown settings
	self.spawn_cooldown_mul = math.lerp(2, 1, f)
	self.spawn_kill_cooldown = math.lerp(20, 10, f)
	self.spawn_kill_max_dis = 1500

	-- CRITICAL: Assault fade settings (SHAI crashes without this)
	self.besiege.assault.fade = {
		enemies_defeated_percentage = 0.5,
		enemies_defeated_time = 30,
		engagement_percentage = 0.35,
		engagement_time = 20,
		drama_time = 5
	}

	-- Reinforce interval - FASTER for more tension (Vanilla: {10, 20, 30})
	self.besiege.reenforce.interval = { 5, 10, 15 }

	-- Recon settings
	self.besiege.recon.force = { 2, 4, 6 }
	self.besiege.recon.interval_variation = 30

	-- Assault force settings - target ~35 active cops solo at DS8
	self.besiege.assault.force = { 24, 29, 35 }

	-- Assault force pool (Vanilla DS8: {150,175,225})
	self.besiege.assault.force_pool = { 150, 175, 225 }

	-- Assault delay (Vanilla DS8: {20,15,10})
	self.besiege.assault.delay = { 20, 15, 10 }

	-- Assault sustain duration - SH-style lerp scaling by difficulty
	self.besiege.assault.sustain_duration_min = { math.lerp(60, 120, f), math.lerp(120, 180, f), math.lerp(180, 240, f) }
	self.besiege.assault.sustain_duration_max = self.besiege.assault.sustain_duration_min

	-- Hostage hesitation delay (Vanilla: none | SH: {10,7.5,5})
	self.besiege.assault.hostage_hesitation_delay = { 15, 15, 15 }

	-- Balance multipliers: scale force/pool with player count (1-4 players)
	self.besiege.assault.force_balance_mul = { 1, 1.5, 2, 2.5 }
	self.besiege.assault.force_pool_balance_mul = { 1, 1.5, 2, 2.5 }
	self.besiege.assault.sustain_duration_balance_mul = { 1, 1, 1, 1 }

	-- Spawn group weights: which group types to spawn and how heavily - AGGRESSIVE WEIGHTS
	local rifle_weight = 10
	local rifle_flank_weight = 12
	local shotgun_weight = 6
	local shotgun_flank_weight = 4
	local special_weight = math.lerp(4, 6, f)
	local special_weight_tbl = { 0, special_weight * 0.75, special_weight }
	local rare_special_weight_tbl = { 0, special_weight * 0.25, special_weight * 0.5 }
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

	-- Reenforce group weights
	self.besiege.reenforce.groups = {
		reenforce_init = { 1, 0, 0 },
		reenforce_light = { 0, 1, 0 },
		reenforce_heavy = { 0, 0, 1 }
	}

	-- Recon group weights
	self.besiege.recon.groups = {
		hostage_rescue = { 1, 1, 1 },
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
end)

-- Define SH-style spawn groups with tactics (required by SHAI besiege group weight tables)
Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "shai_spawn_groups", function(self, difficulty_index)
	local f = math.max(0, difficulty_index - 2) / 6

	-- Tactics used by spawn groups - AGGRESSIVE (charge instead of ranged_fire)
	self._tactics.swat_shotgun_rush = { "charge", "deathguard", "smoke_grenade", "flash_grenade" }
	self._tactics.swat_shotgun_flank = { "charge", "flank", "deathguard", "flash_grenade" }
	self._tactics.swat_rifle = { "charge", "smoke_grenade", "flash_grenade" }
	self._tactics.swat_rifle_flank = { "charge", "flank", "deathguard", "flash_grenade" }
	self._tactics.shield_wall_ranged = { "shield", "ranged_fire" }
	self._tactics.shield_wall_charge = { "shield", "charge" }
	self._tactics.tank_rush = { "shield", "charge", "smoke_grenade", "murder" }
	self._tactics.tazer_charge = { "charge", "smoke_grenade", "murder" }
	self._tactics.tazer_flanking = { "flank", "flash_grenade", "murder" }
	self._tactics.spooc = { "flank", "smoke_grenade", "unit_cover" }
	self._tactics.support_ranged = { "unit_cover", "ranged_fire" }
	self._tactics.support_charge = { "unit_cover", "charge" }

	-- Use SH tactics for shield support if shield_cover tactic exists in SH logicbase
	local shield_support_ranged = self._tactics.shield_support_ranged or self._tactics.support_ranged
	local shield_support_charge = self._tactics.shield_support_charge or self._tactics.support_charge

	-- Shotgun rush groups - ADD DS VARIANTS (use existing FBI units)
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

	-- Shotgun flank groups - ADD DS VARIANTS (use existing FBI units)
	self.enemy_spawn_groups.tac_swat_shotgun_flank = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_flank },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.support_charge }
		}
	}
	self.enemy_spawn_groups.tac_swat_shotgun_flank_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_shotgun_flank)
	table.remove(self.enemy_spawn_groups.tac_swat_shotgun_flank_no_medic.spawn)

	-- Rifle groups - ADD DS SHOTGUN VARIANTS (use existing FBI units)
	self.enemy_spawn_groups.tac_swat_rifle = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ freq = difficulty_index / 16, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.support_ranged }
		}
	}
	self.enemy_spawn_groups.tac_swat_rifle_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_rifle)
	table.remove(self.enemy_spawn_groups.tac_swat_rifle_no_medic.spawn)

	-- Rifle flank groups - ADD DS SHOTGUN VARIANTS (use existing FBI units)
	self.enemy_spawn_groups.tac_swat_rifle_flank = {
		amount = { 3, 4 },
		spawn = {
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, amount_min = 1, amount_max = 2, rank = 2, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ freq = difficulty_index / 20, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.support_ranged }
		}
	}
	self.enemy_spawn_groups.tac_swat_rifle_flank_no_medic = deep_clone(self.enemy_spawn_groups.tac_swat_rifle_flank)
	table.remove(self.enemy_spawn_groups.tac_swat_rifle_flank_no_medic.spawn)

	-- Shield groups - ADD DS SHOTGUN VARIANTS (use existing FBI units)
	self.enemy_spawn_groups.tac_shield_wall_ranged = {
		amount = { 4, 4 },
		spawn = {
			{ freq = difficulty_index / 16, amount_min = 1, amount_max = 2, rank = 3, unit = "FBI_shield", tactics = self._tactics.shield_wall_ranged },
			{ freq = 0.25, rank = 2, unit = "FBI_swat_M4", tactics = shield_support_ranged },
			{ freq = 1, rank = 2, unit = "FBI_heavy_G36", tactics = shield_support_ranged },
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

	-- Dozer groups - ADD DS SHOTGUN VARIANTS (use existing FBI units)
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
			{ freq = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.tazer_flanking }
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

	-- Hostage rescue (recon)
	self.enemy_spawn_groups.hostage_rescue = {
		amount = { 2, 3 },
		spawn = {
			{ freq = 0.35, amount_max = 1, rank = 2, unit = "FBI_suit_C45_M4", tactics = self._tactics.swat_rifle_flank },
			{ freq = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank }
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

-- Add missing enemy chatter queues after HH's _init_chatter_data runs
Hooks:PostHook(GroupAITweakData, "_init_chatter_data", "shai_chatter_settings", function(self, difficulty_index)
	-- Add chatter queues that SHAI references
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
