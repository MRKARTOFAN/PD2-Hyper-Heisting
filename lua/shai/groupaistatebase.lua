-- Set up needed variables
Hooks:PostHook(GroupAIStateBase, "init", "sh_init", function(self)
	self._next_police_upd_task = 0
	self._next_group_spawn_t = {}
end)


-- Restore scripted cloaker spawn noise
local _process_recurring_grp_SO_original = GroupAIStateBase._process_recurring_grp_SO
function GroupAIStateBase:_process_recurring_grp_SO(...)
	if _process_recurring_grp_SO_original(self, ...) then
		managers.network:session():send_to_peers_synched("group_ai_event", self:get_sync_event_id("cloaker_spawned"), 0)
		managers.hud:post_event("cloaker_spawn")
		return true
	end
end


-- Make difficulty progress smoother
function GroupAIStateBase:_update_difficulty_value()
	if self._target_difficulty and self._t >= self._next_difficulty_step_t then
		self._difficulty_value = math.min(self._difficulty_value + self._difficulty_step, self._target_difficulty)
		if self._difficulty_value >= self._target_difficulty then
			self._target_difficulty = nil
		else
			self._next_difficulty_step_t = self._t + 15
		end
		self:_calculate_difficulty_ratio()
	end
end

local set_difficulty_original = GroupAIStateBase.set_difficulty
function GroupAIStateBase:set_difficulty(value, ...)
	if not managers.game_play_central or managers.game_play_central:get_heist_timer() < 1 or value < self._difficulty_value then
		self._target_difficulty = nil

		return set_difficulty_original(self, value, ...)
	end

	self._difficulty_step = 0.05
	self._target_difficulty = value
	self._next_difficulty_step_t = self._next_difficulty_step_t or self._t

	self:_update_difficulty_value()
end

Hooks:PostHook(GroupAIStateBase, "update", "sh_update", GroupAIStateBase._update_difficulty_value)


-- Delay spawn points when enemies die close to them
Hooks:PostHook(GroupAIStateBase, "on_enemy_unregistered", "sh_on_enemy_unregistered", function(self, unit)
	if Network:is_client() or not unit:character_damage():dead() then
		return
	end

	local e_data = self._police[unit:key()]
	if not e_data.group or not e_data.group.has_spawned or not e_data.spawn_group then
		return
	end

	local dis = mvector3.distance(e_data.spawn_group.pos, e_data.m_pos)
	local max_dis = tweak_data.group_ai.spawn_kill_max_dis
	if dis > max_dis then
		return
	end

	local delay_t = self._t + math.map_range(dis, 0, max_dis, tweak_data.group_ai.spawn_kill_cooldown, 0)
	e_data.spawn_group.delay_t = math.max(e_data.spawn_group.delay_t, delay_t)
end)


-- Fix this function doing nothing
function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local area, last_area
	while i_nav_seg > 0 and #coarse_path > 2 do
		area = self:get_area_from_nav_seg_id(coarse_path[i_nav_seg][1])
		if last_area and last_area == area then
			table.remove(coarse_path, i_nav_seg)
		else
			last_area = area
		end
		i_nav_seg = i_nav_seg - 1
	end
end


-- Ignore disabled criminals for area safety checks
function GroupAIStateBase:is_area_safe(area)
	for _, u_data in pairs(self._criminals) do
		if u_data.status ~= "disabled" and u_data.status ~= "dead" and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end
	return true
end

function GroupAIStateBase:is_area_safe_assault(area)
	for _, u_data in pairs(self._char_criminals) do
		if u_data.status ~= "disabled" and u_data.status ~= "dead" and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end
	return true
end

function GroupAIStateBase:is_nav_seg_safe(nav_seg)
	for _, u_data in pairs(self._criminals) do
		if u_data.status ~= "disabled" and u_data.status ~= "dead" and u_data.tracker:nav_segment() == nav_seg then
			return
		end
	end
	return true
end

function GroupAIStateBase:is_nav_seg_area_safe(skip_areas, nav_seg)
	for _, area in pairs(skip_areas) do
		if area.nav_segs[nav_seg] then
			return true
		end
	end
	return self:is_area_safe(self:get_area_from_nav_seg_id(nav_seg))
end


-- Don't count recon as assault force and vice versa
function GroupAIStateBase:_count_police_force(task_name)
	local amount = 0
	local objective_type = task_name .. "_area"
	for _, group in pairs(self._groups) do
		if group.objective.type == objective_type then
			amount = amount + (group.has_spawned and group.size or group.initial_size)
		end
	end
	return amount
end


-- Set accurate criminal position
Hooks:PostHook(GroupAIStateBase, "criminal_spotted", "sh_criminal_spotted", function(self, unit)
	local u_sighting = self._criminals[unit:key()]
	mvector3.set(u_sighting.pos, u_sighting.m_det_pos)
end)


-- Do not update detected position and time on nav segment change
-- Log time when criminals enter an area to use for the teargas check
Hooks:OverrideFunction(GroupAIStateBase, "on_criminal_nav_seg_change", function(self, unit, nav_seg_id)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]
	if not u_sighting then
		return
	end

	u_sighting.seg = nav_seg_id

	local prev_area = u_sighting.area
	local area = self:get_area_from_nav_seg_id(nav_seg_id)
	if prev_area ~= area then
		if prev_area and not u_sighting.ai then
			if table.count(prev_area.criminal.units, function(c_data) return not c_data.ai end) <= 1 then
				prev_area.criminal_left_t = self._t
				prev_area.old_criminal_entered_t = prev_area.criminal_entered_t
				prev_area.criminal_entered_t = nil
			end

			if not area.criminal_entered_t then
				if area.criminal_left_t and area.old_criminal_entered_t then
					area.criminal_entered_t = math.lerp(area.old_criminal_entered_t, self._t, math.min((self._t - area.criminal_left_t) / 20, 1))
				else
					area.criminal_entered_t = self._t
				end
			end
		end

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		u_sighting.area = area
		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil
		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end
end)


-- Make jokers follow their actual owner instead of the closest player
local _determine_objective_for_criminal_AI_original = GroupAIStateBase._determine_objective_for_criminal_AI
function GroupAIStateBase:_determine_objective_for_criminal_AI(unit, ...)
	local logic_data = unit:brain()._logic_data
	if logic_data.is_converted and alive(logic_data.minion_owner) then
		return {
			type = "follow",
			scan = true,
			follow_unit = logic_data.minion_owner
		}
	end

	return _determine_objective_for_criminal_AI_original(self, unit, ...)
end


-- Adjust objective data for rescue and steal SOs
Hooks:PreHook(GroupAIStateBase, "add_special_objective", "sh_add_special_objective", function(self, id, objective_data)
	if type(id) ~= "string" or not id:match("^carrysteal") and not id:match("^rescue") then
		return
	end

	objective_data.interval = 4
	objective_data.search_dis_sq = 4000000
	objective_data.objective.interrupt_dis = 800
	objective_data.objective.interrupt_health = 0.8
	objective_data.objective.pose = nil
end)


-- Fully count all criminals for the balancing multiplier
function GroupAIStateBase:_get_balancing_multiplier(balance_multipliers)
	return balance_multipliers[math.clamp(table.size(self._char_criminals), 1, #balance_multipliers)]
end


-- Disable drama zones to prevent skipping of anticipation, build and regroup phases
-- The zones are only used for that, which makes the phases inconsistent for no real reason
function GroupAIStateBase:_add_drama(amount)
	self._drama_data.amount = math.clamp(self._drama_data.amount + amount, 0, 1)
	self._drama_data.zone = nil
end


-- Set a minimum gunshot and bullet impact alert range in loud
Hooks:PreHook(GroupAIStateBase, "propagate_alert", "sh_propagate_alert", function(self, alert_data)
	if alert_data[1] == "bullet" and alert_data[3] and self:enemy_weapons_hot() then
		alert_data[3] = math.max(alert_data[3], 800)
	end
end)


-- Spawn events are probably not used anywhere, but for the sake of correctness, fix this function
-- All the functions that call this expect it to return true when it's used
function GroupAIStateBase:_try_use_task_spawn_event(t, target_area, task_type, target_pos, force)
	target_pos = target_pos or target_area.pos

	local max_dis_sq = 3000 ^ 2
	for _, event_data in pairs(self._spawn_events) do
		if (event_data.task_type == task_type or event_data.task_type == "any") and mvector3.distance_sq(target_pos, event_data.pos) < max_dis_sq then
			if force or math.random() < event_data.chance then
				self._anticipated_police_force = self._anticipated_police_force + event_data.amount
				self._police_force = self._police_force + event_data.amount
				self:_use_spawn_event(event_data)
				return true
			else
				event_data.chance = math.min(1, event_data.chance + event_data.chance_inc)
			end
		end
	end
end


-- Make this function properly set rescue state again for checking if recon tasks are allowed
Hooks:OverrideFunction(GroupAIStateBase, "_set_rescue_state", function(self, state)
	self._rescue_allowed = state
end)

-- [Karto] HH drama stuff
local function fray_update_drama_zone(self)
	local drama_data = self._drama_data
	local assault_number = self._assault_number or 1
	local high_threshold = assault_number >= 3 and tweak_data.drama.high_3rd or assault_number == 2 and tweak_data.drama.high_2nd or tweak_data.drama.peak

	if drama_data.amount >= high_threshold then
		drama_data.hh_zone = "high"
	elseif drama_data.amount <= tweak_data.drama.low then
		drama_data.hh_zone = "low"
	else
		drama_data.hh_zone = nil
	end

	drama_data.hh_high_p = high_threshold
end

Hooks:PostHook(GroupAIStateBase, "init", "fray_init_drama", function(self)
	local level_id = Global.level_data and Global.level_data.level_id
	local level_data = level_id and tweak_data.levels[level_id]

	self._drama_data.pulse = true
	self._last_killed_cop_t = 0
	self._too_drama = level_data and level_data.too_drama
	fray_update_drama_zone(self)
end)

local hh_add_drama_original = GroupAIStateBase._add_drama
function GroupAIStateBase:_add_drama(amount)
	hh_add_drama_original(self, amount)
	fray_update_drama_zone(self)
end

function GroupAIStateBase:_claculate_drama_value()
	local drama_data = self._drama_data
	local t = self._t
	local dt = t - drama_data.last_calculate_t
	local assault = self._task_data and self._task_data.assault
	local recent_kill = self._last_killed_cop_t and t - self._last_killed_cop_t < 5
	local should_decay = not assault or not assault.active or assault.phase == "fade" or self._activeassaultbreak or recent_kill and not self._danger_state
	local adjustment

	if should_decay then
		drama_data.pulse = true

		local player_count = table.size(self._player_criminals)
		local decay_mul = player_count <= 1 and 2 or 2 - player_count * 0.25
		adjustment = -dt / (drama_data.decay_period / decay_mul)
	elseif not self._too_drama then
		drama_data.pulse = false

		local gain_mul = self._danger_state and 1 or 1.5
		adjustment = dt / (drama_data.decay_period * gain_mul)
	end

	drama_data.last_calculate_t = t

	if adjustment then
		self:_add_drama(adjustment)
	else
		fray_update_drama_zone(self)
	end
end

function GroupAIStateBase:hh_enemy_killed(attacker_unit)
	if not alive(attacker_unit) then
		return
	end

	local attacker_base = attacker_unit:base()
	if attacker_base and attacker_base.thrower_unit then
		attacker_unit = attacker_base:thrower_unit()
	end

	if not alive(attacker_unit) or not self._criminals[attacker_unit:key()] then
		return
	end

	local player_count = table.size(self._player_criminals)
	local drama_reduction = self._drama_data.actions.enemy_dead * (5 - player_count)

	self:_add_drama(-drama_reduction)
	self._last_killed_cop_t = self._t
end

local hh_get_anticipation_duration_original = GroupAIStateBase._get_anticipation_duration
function GroupAIStateBase:_get_anticipation_duration(anticipation_duration_table, is_first)
	local level_id = Global.game_settings and Global.game_settings.level_id or Global.level_data and Global.level_data.level_id

	if level_id == "pbr" and is_first then
		return 15
	end

	return hh_get_anticipation_duration_original(self, anticipation_duration_table, is_first)
end
