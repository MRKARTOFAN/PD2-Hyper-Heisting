local tmp_vec = Vector3()

local _play_sound_and_effects_original = QuickSmokeGrenade._play_sound_and_effects
local _activate_original = QuickSmokeGrenade._activate
local _activate_normal_original = QuickSmokeGrenade.activate
local _activate_immediately_original = QuickSmokeGrenade.activate_immediately

local function shai_hh_smoke_effect()
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	return diff_index <= 7 and "effects/pd2_mod_hh/particles/weapons/explosion/smoke_hh_complex" or "effects/pd2_mod_hh/particles/weapons/explosion/smoke_hh_anarchy"
end

local function shai_ground_smoke_unit(unit, preferred_pos)
	if not alive(unit) then
		return
	end

	local pos = preferred_pos or unit:position()

	local ground_ray = World:raycast(
		"ray",
		pos + math.UP * 300,
		pos - math.UP * 5000,
		"slot_mask",
		managers.slot:get_mask("AI_graph_obstacle_check")
	)

	if not ground_ray then
		ground_ray = World:raycast(
			"ray",
			pos + math.UP * 300,
			pos - math.UP * 5000,
			"slot_mask",
			managers.slot:get_mask("world_geometry")
		)
	end

	if ground_ray then
		unit:set_position(ground_ray.position + math.UP * 2)

		local body = unit:body(0)

		if body then
			body:set_enabled(false)
		end
	end
end

function QuickSmokeGrenade:activate(position, duration)
	shai_ground_smoke_unit(self._unit, position)

	local result = _activate_normal_original(self, position, duration)

	shai_ground_smoke_unit(self._unit, position)

	return result
end

function QuickSmokeGrenade:activate_immediately(position, duration)
	shai_ground_smoke_unit(self._unit, position)

	local result = _activate_immediately_original(self, position, duration)

	shai_ground_smoke_unit(self._unit, position)

	return result
end

function QuickSmokeGrenade:_activate(state, timer, position, duration)
	shai_ground_smoke_unit(self._unit, position)

	local result = _activate_original(self, state, timer, position, duration)

	shai_ground_smoke_unit(self._unit, position)

	return result
end

function QuickSmokeGrenade:_play_sound_and_effects(...)
	local body = self._unit:body(0)

	if not body then
		return _play_sound_and_effects_original(self, ...)
	end

	if self._state == 1 then
		shai_ground_smoke_unit(self._unit, self._shoot_position)

		if self._shoot_position then
			local sound_source = SoundDevice:create_source("grenade_fire_source")

			sound_source:set_position(self._shoot_position)
			sound_source:post_event("grenade_gas_npc_fire")
		end
	elseif self._state == 2 then
		shai_ground_smoke_unit(self._unit, self._unit:position())

		if self._shoot_position then
			self._unit:m_position(tmp_vec)
			mvector3.lerp(tmp_vec, self._shoot_position, tmp_vec, 0.65)

			local sound_source = SoundDevice:create_source("grenade_bounce_source")

			sound_source:set_position(tmp_vec)
			sound_source:post_event(
				"grenade_gas_bounce",
				callback(self, self, "sound_playback_complete_clbk"),
				sound_source,
				"end_of_event"
			)
		else
			self._unit:sound_source():post_event("grenade_gas_bounce")
		end
	elseif self._state == 3 then
		shai_ground_smoke_unit(self._unit, self._unit:position())
		self._unit:set_visible(true)
	elseif self._state == 4 then
		shai_ground_smoke_unit(self._unit, self._unit:position())

		World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
			position = self._unit:position(),
			normal = self._unit:rotation():y()
		})

		self._smoke_effect = World:effect_manager():spawn({
			effect = Idstring(shai_hh_smoke_effect()),
			parent = self._unit:orientation_object()
		})

		self._unit:sound_source():post_event("grenade_gas_explode")
	end
end
