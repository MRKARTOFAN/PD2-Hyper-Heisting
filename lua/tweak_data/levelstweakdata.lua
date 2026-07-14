LevelsTweakData.LevelType = LevelsTweakData.LevelType or {}
LevelsTweakData.LevelType.Shared = "shared"

local hh_level_packages = {
	mad = { "packages/akanassets", "packages/lvl_mad" },
	shoutout_raid = { "packages/murkyassets", "packages/vlad_shout" },
	pbr2 = { "packages/murkyassets", "packages/narr_jerry2" },
	pbr = { "packages/murkyassets", "packages/narr_jerry1" },
	dinner = { "packages/narr_dinner", "packages/murkyassets" },
	des = { "packages/murkyassets", "packages/job_des" },
	bph = { "packages/murkyassets", "packages/dlcs/bph/job_bph" },
	vit = { "packages/holyfuckingshitghosts", "packages/murkyassets", "packages/dlcs/vit/job_vit" },
	mex = { "packages/murkyassets", "packages/job_mex" },
	mex_cooking = { "packages/murkyassets", "packages/job_mex2" },
	kosugi = { "packages/murkyassets", "packages/kosugi" },
	bex = { "packages/mexicoassets", "packages/job_bex" },
	pex = { "packages/mexicoassets", "packages/job_pex" },
	fex = { "packages/mexicoassets", "packages/job_fex" },
	skm_bex = { "packages/mexicoassets", "packages/dlcs/skm/job_bex_skm" },
	haunted = { "packages/holyfuckingshitghosts", "packages/narr_haunted" },
	hvh = { "packages/zombieassets", "packages/narr_hvh" },
	short2_stage1 = { "packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds" },
	nightclub = { "packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds" },
	spa = { "packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds" },
	friend = { "levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend" },
	cane = { "packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds" }
}
-- [Karto] Return back here if the heist is demolishing heisters. Currently, meatgrinder flag does nothing. It supposed to reduce force and pool values.

local fray_meatgrinder_levels = {
	"jewelry_store", "ukrainian_job", "four_stores", "nightclub", "sah", "born", "chew", "pines",
	"help", "peta", "hox_1", "mad", "glace", "nail", "watchdogs_1", "watchdogs_1_night",
	"crojob3", "crojob3_night", "hvh", "run", "arm_cro", "arm_und", "arm_hcm", "arm_par",
	"arm_fac", "mia_2", "rvd1", "rvd2", "nmh", "des", "mex", "mex_cooking", "bph", "spa",
	"chill_combat", "dinner", "mallcrasher", "moon", "cane", "flat"
}

local fray_optional_meatgrinder_levels = {
	"physics_tower", "physics_core", "mia_2_new"
}

local fray_street_levels = {
	"hox_1", "run", "glace", "rvd2"
}

local fray_too_drama_levels = {
	"chill_combat", "hox_1", "run", "glace"
}

local function hh_rvd_teams()
	return {
		criminal1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		law1 = {
			foes = {
				converted_enemy = true,
				criminal1 = true,
				mobster1 = true
			},
			friends = {}
		},
		mobster1 = {
			foes = {
				converted_enemy = true,
				law1 = true,
				criminal1 = true
			},
			friends = {}
		},
		converted_enemy = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				criminal1 = true
			}
		},
		neutral1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		hacked_turret = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {}
		}
	}
end

Hooks:PostHook(LevelsTweakData, "init", "hh_level_tweak_init", function(self)
	local america = LevelsTweakData.LevelType.America
	local shared = LevelsTweakData.LevelType.Shared
	local russia = LevelsTweakData.LevelType.Russia
	local zombie = LevelsTweakData.LevelType.Zombie
	local murkywater = LevelsTweakData.LevelType.Murkywater
	local federales = LevelsTweakData.LevelType.Federales

	self.ai_groups = {
		default = america,
		america = america,
		shared = shared,
		russia = russia,
		zombie = zombie,
		murkywater = murkywater,
		federales = federales
	}

	self.chill_combat.group_ai_state = "besiege"
	self.rvd1.teams = hh_rvd_teams()
	self.rvd2.trigger_follower_behavior_element = {}
	self.rvd2.teams = hh_rvd_teams()

	for level_id, packages in pairs(hh_level_packages) do
		self[level_id].package = packages
	end

	self.shoutout_raid.ai_group_type = murkywater
	self.spa.ignored_so_elements = {
		[101834] = true,
		[135495] = true,
		[103318] = true
	}
	self.spa.trigger_follower_behavior_element = {
		[135558] = true
	}
	self.hox_2.ignored_so_elements = {
		[102290] = true
	}

	if not Global.crime_spree or not Global.crime_spree.current_mission then
		self.nail.package = {
			"packages/zombieassets",
			"packages/job_nail",
			"packages/narr_hvh",
			"levels/narratives/bain/hvh/world_sounds"
		}
		self.help.package = {
			"packages/zombieassets",
			"packages/lvl_help",
			"packages/narr_hvh",
			"levels/narratives/bain/hvh/world_sounds"
		}
		self.nail.ai_group_type = zombie
		self.help.ai_group_type = zombie
	end

	for _, level_id in ipairs(fray_meatgrinder_levels) do
		self[level_id].meatgrinder = true
	end

	for _, level_id in ipairs(fray_optional_meatgrinder_levels) do
		if self[level_id] then
			self[level_id].meatgrinder = true
		end
	end

	for _, level_id in ipairs(fray_street_levels) do
		self[level_id].street = true
	end

	for _, level_id in ipairs(fray_too_drama_levels) do
		self[level_id].too_drama = true
	end
end)

function LevelsTweakData:get_ai_group_type()
	local level_data = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]

	if level_data then
		local ai_group_type = level_data.ai_group_type

		if ai_group_type then
			local sm_wish = Global.game_settings and Global.game_settings.difficulty == "sm_wish"
			local normalized_ai_group_type = self.ai_groups[ai_group_type] or LevelsTweakData.LevelType[ai_group_type] or ai_group_type

			if ai_group_type == "bo" and sm_wish then
				return "america"
			elseif ai_group_type == "zombie" and Global.game_settings and Global.game_settings.incsmission then
				return "america"
			elseif ai_group_type == "shared" and Global.game_settings and Global.game_settings.incsmission then
				return "america"
			else
				return normalized_ai_group_type
			end
		end
	end

	return self.ai_groups.america
end

Hooks:PostHook(LevelsTweakData, "init", "init__levelstweakdata_disable_marshals", function(td)
	local level_id = Global.game_settings and Global.game_settings.level_id

	if type(td[level_id]) == "table" then
		td[level_id].ai_marshal_spawns_disabled = true
	end
end)
