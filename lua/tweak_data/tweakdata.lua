if not tweak_data then
	return
end

local color_filters = { "rvsb" }

for _, filter in pairs(color_filters) do
	table.insert(tweak_data.color_grading, {
		value = "color_" .. filter,
		text_id = "menu_color_" .. filter
	})
end

tweak_data.style_meter_events = {
	kill = {
		amount = 0.2,
		stale_add = 1,
		stale_max = 2,
		stale_expire_t = 0.25,
		style_pause_t = 0.048
	},
	dodge = {
		amount = 0.1,
		stale_add = 1,
		stale_max = 8,
		stale_expire_t = 0.5
	},
	gate = {
		amount = 0.5,
		stale_add = 1,
		stale_max = 4,
		stale_expire_t = 4.6,
		style_pause_t = 0.2
	},
	exposure = {
		amount = 0.01,
		amount_min_mul = 0,
		stale_add = 1,
		stale_max = 4,
		stale_expire_t = 1
	}
}

tweak_data.projectiles.cs_grenade_quick = {
	radius = 300,
	radius_blurzone_multiplier = 0,
	damage_tick_period = 0.35,
	damage_per_tick = 1
}

--Why are projectile's damage stats handled here? I don't know! Fuck you Jules!
tweak_data.projectiles.wpn_prj_ace.damage = 10
tweak_data.projectiles.wpn_prj_jav.damage = 300
tweak_data.projectiles.wpn_prj_target.damage = 40
tweak_data.projectiles.wpn_prj_hur.damage = 60
tweak_data.projectiles.fir_com.fire_dot_data = {
	dot_trigger_chance = 100,
	dot_damage = 16,
	dot_length = 2.1,
	dot_trigger_max_distance = 3000,
	dot_tick_period = 0.5
}
tweak_data.projectiles.west_arrow.launch_speed = 1250 -- plainrider bow
tweak_data.projectiles.long_arrow.launch_speed = 1500 -- english longbow
tweak_data.projectiles.elastic_arrow.launch_speed = 1500 -- compound bow
tweak_data.projectiles.sticky_grenade.detonate_timer = 0 -- Instant detonation on impact for Adhesive grenade (Impact Grenade now)

local hh_difficulty_data = {
	normal = {
		civilians_killed = 35, total_level_objectives = 2000,
		total_criminals_finished = 50, total_objectives_finished = 1000
	},
	hard = {
		civilians_killed = 75, total_level_objectives = 2500,
		total_criminals_finished = 150, total_objectives_finished = 1500
	},
	overkill = {
		civilians_killed = 150, total_level_objectives = 5000,
		total_criminals_finished = 500, total_objectives_finished = 3000
	},
	overkill_145 = {
		civilians_killed = 550, total_level_objectives = 5000,
		total_criminals_finished = 2000, total_objectives_finished = 3000
	},
	easy_wish = {
		civilians_killed = 10000, total_level_objectives = 5000,
		total_criminals_finished = 2000, total_objectives_finished = 3000
	},
	overkill_290 = {
		civilians_killed = 10000, total_level_objectives = 5000,
		total_criminals_finished = 2000, total_objectives_finished = 3000
	},
	sm_wish = {
		civilians_killed = 10000, total_level_objectives = 5000,
		total_criminals_finished = 2000, total_objectives_finished = 3000
	}
}

local function hh_set_difficulty(self, difficulty)
	local method = "_set_" .. difficulty

	self.player[method](self.player)
	self.character[method](self.character)
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon[method](self.weapon)

	local data = hh_difficulty_data[difficulty]

	self.medic.radius = 600
	self.medic.cooldown = 0
	self.experience_manager.civilians_killed = data.civilians_killed
	self.difficulty_name_id = self.difficulty_name_ids[difficulty]
	self.experience_manager.total_level_objectives = data.total_level_objectives
	self.experience_manager.total_criminals_finished = data.total_criminals_finished
	self.experience_manager.total_objectives_finished = data.total_objectives_finished
end

for difficulty, _ in pairs(hh_difficulty_data) do
	local difficulty_id = difficulty

	TweakData["_" .. "set_" .. difficulty] = function(self)
		hh_set_difficulty(self, difficulty_id)
	end
end
