local hh_suppression = {
	receive_mul = 2,
	decay_start_delay = 1.5,
	spread_mul = 3,
	tolerance = 0,
	max_value = 100,
	autohit_chance_mul = 1
}

local hh_difficulty_patches = {
	normal = {
		automatic_respawn_time = 120,
		min_damage_interval = 0.35,
		revive_health_steps = { 0.8 },
		suspicion = { range_mul = 0.2, max_value = 8, buildup_mul = 0.2 },
		tased_time = 11,
		lives_init = 2,
		bleed_out_health_init = 69
	},
	hard = {
		automatic_respawn_time = 120,
		downed_time_dec = 7,
		downed_time_min = 5,
		min_damage_interval = 0.35,
		revive_health_steps = { 0.8 },
		suspicion = { range_mul = 0.2, max_value = 8, buildup_mul = 0.2 },
		tased_time = 11,
		lives_init = 2,
		bleed_out_health_init = 69
	},
	overkill = {
		automatic_respawn_time = 240,
		downed_time_dec = 10,
		downed_time_min = 5,
		min_damage_interval = 0.3,
		revive_health_steps = { 0.6 },
		suspicion = { range_mul = 0.5, max_value = 8, buildup_mul = 0.5 },
		tased_time = 11,
		lives_init = 2,
		bleed_out_health_init = 69
	},
	overkill_145 = {
		automatic_respawn_time = 240,
		downed_time_dec = 15,
		downed_time_min = 1,
		min_damage_interval = 0.25,
		revive_health_steps = { 0.6 },
		suspicion = { range_mul = 0.5, max_value = 8, buildup_mul = 0.5 },
		tased_time = 11,
		lives_init = 2,
		bleed_out_health_init = 69
	},
	easy_wish = {
		automatic_respawn_time = 240,
		downed_time_dec = 20,
		downed_time_min = 1,
		bleed_ot_time = 10,
		min_damage_interval = 0.2,
		revive_health_steps = { 0.5 },
		suspicion = { range_mul = 0.8, max_value = 8, buildup_mul = 0.8 },
		tased_time = 11,
		bleed_out_health_init = 69,
		lives_init = 2,
		incapacitated_time = 25,
		downed_time = 25
	},
	overkill_290 = {
		automatic_respawn_time = 360,
		downed_time_dec = 20,
		downed_time_min = 1,
		bleed_ot_time = 10,
		min_damage_interval = 0.2,
		revive_health_steps = { 0.5 },
		suspicion = { range_mul = 0.8, max_value = 8, buildup_mul = 0.8 },
		tased_time = 11,
		bleed_out_health_init = 69,
		lives_init = 2,
		incapacitated_time = 25,
		downed_time = 25
	},
	sm_wish = {
		automatic_respawn_time = 360,
		downed_time_dec = 20,
		downed_time_min = 1,
		bleed_ot_time = 10,
		min_damage_interval = 0.2,
		revive_health_steps = { 0.5 },
		suspicion = { range_mul = 1, max_value = 8, buildup_mul = 1 },
		tased_time = 11,
		bleed_out_health_init = 69,
		lives_init = 2,
		incapacitated_time = 20,
		downed_time = 20
	}
}

local function hh_apply_difficulty_patch(self, patch)
	self.damage.automatic_respawn_time = patch.automatic_respawn_time
	self.damage.MIN_DAMAGE_INTERVAL = patch.min_damage_interval - (Global.game_settings and Global.game_settings.one_down and 0.05 or 0)
	self.damage.REVIVE_HEALTH_STEPS = patch.revive_health_steps
	self.suppression = deep_clone(hh_suppression)
	self.suspicion = deep_clone(patch.suspicion)
	self.damage.TASED_TIME = patch.tased_time
	self.damage.LIVES_INIT = patch.lives_init
	self.damage.BLEED_OUT_HEALTH_INIT = patch.bleed_out_health_init

	if patch.downed_time_dec then
		self.damage.DOWNED_TIME_DEC = patch.downed_time_dec
	end

	if patch.downed_time_min then
		self.damage.DOWNED_TIME_MIN = patch.downed_time_min
	end

	if patch.bleed_ot_time then
		self.damage.BLEED_OT_TIME = patch.bleed_ot_time
	end

	if patch.incapacitated_time then
		self.damage.INCAPACITATED_TIME = patch.incapacitated_time
	end

	if patch.downed_time then
		self.damage.DOWNED_TIME = patch.downed_time
	end
end

Hooks:PostHook(PlayerTweakData, "_set_easy", "hh_player_tweak_easy_grace", function(self)
	self.damage.MIN_DAMAGE_INTERVAL = Global.game_settings and Global.game_settings.one_down and 0.3 or 0.35
end)

Hooks:PostHook(PlayerTweakData, "init", "hh_player_tweak_init", function(self, tweak_data)
	self.damage.HEALTH_INIT = 34.5
	self.damage.ARMOR_INIT = 3
	self.put_on_mask_time = 1
	self.movement_state.stamina.STAMINA_REGEN_RATE = 6
	self.movement_state.stamina.JUMP_STAMINA_DRAIN = 5
	self.movement_state.stamina.MIN_STAMINA_THRESHOLD = 5
	self.movement_state.standard.movement.speed.RUNNING_MAX = 862.50
	self.movement_state.standard.movement.jump_velocity.xy.walk = self.movement_state.standard.movement.speed.STANDARD_MAX
	self.movement_state.standard.gravity = 982
	self.movement_state.standard.terminal_velocity = 5500
	
	self.damage.respawn_time_penalty = 0 -- No civ kill trade penalty

	self.style_multipliers = { 1, 1.08, 1.166, 1.333, 1.5, 1.833, 2 }

	self.alarm_pager = {
		first_call_delay = { 2, 4 },
		call_duration = { { 6, 6 }, { 6, 6 } },
		nr_of_calls = { 2, 2 },
		bluff_success_chance = { 1, 1, 1, 0, 0 },
		bluff_success_chance_w_skill = { 1, 1, 1, 0, 0 }
	}
end)

for difficulty, patch in pairs(hh_difficulty_patches) do
	local difficulty_patch = patch

	Hooks:PostHook(PlayerTweakData, "_set_" .. difficulty, "hh_player_tweak_" .. difficulty, function(self)
		hh_apply_difficulty_patch(self, difficulty_patch)
	end)
end

function PlayerTweakData:_set_singleplayer()
end
