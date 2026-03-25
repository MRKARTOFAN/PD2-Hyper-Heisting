-- SHAI: Cherry-picked tweak settings from Streamlined Heisting
-- Only adds missing values that SHAI requires, doesn't override HH's balance

-- Set AI tick rate (faster AI updates)
Hooks:PostHook(GroupAITweakData, "init", "tick_rate", function(self)
	self.ai_tick_rate = 0.008333333333333333
end)

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

	-- Reinforce interval (Vanilla: {10, 20, 30} | SH: {60, 45, 30})
	self.besiege.reenforce.interval = { 10, 20, 30 }

	-- Recon settings
	self.besiege.recon.force = { 2, 4, 6 }
	self.besiege.recon.interval_variation = 30

	-- Assault force settings (Vanilla DS8: {14,16,17} | SH DS8: {8,11,14})
	self.besiege.assault.force = { 14, 16, 17 }

	-- Assault force pool (Vanilla DS8: {150,175,225} | SH DS8: {60,70,80})
	self.besiege.assault.force_pool = { 150, 175, 225 }

	-- Assault delay (Vanilla DS8: {20,15,10} | SH DS8: {30,20,15})
	self.besiege.assault.delay = { 20, 15, 10 }

	-- Assault sustain duration (Vanilla: 0 | SH: {180,240,300})
	self.besiege.assault.sustain_duration_min = { 180, 240, 300 }
	self.besiege.assault.sustain_duration_max = { 180, 240, 300 }

	-- Hostage hesitation delay (Vanilla: none | SH: {10,7.5,5})
	self.besiege.assault.hostage_hesitation_delay = { 15, 15, 15 }
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
