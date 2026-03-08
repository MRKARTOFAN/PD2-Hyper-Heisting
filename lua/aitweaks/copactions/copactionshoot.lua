local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_dis = mvector3.distance
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mvec3_step = mvector3.step
local mvec3_copy = mvector3.copy
local mvec3_spread = mvector3.spread

local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local temp_vec4 = Vector3()

local math_min = math.min
local math_lerp = math.lerp
local math_round = math.round
local math_random = math.random
local math_clamp = math.clamp
local math_up = math.UP

local mrot_axis_angle = mrotation.set_axis_angle
local temp_rot1 = Rotation()

local draw_target_vec_firing = nil
local draw_melee_sphere_rays = nil
local draw_aim_delay_vis_proc = nil
local draw_fire_line_ray = nil
local draw_focus_displacement = nil
local draw_focus_delay_vis_reset = nil

local idstr_func = Idstring
local world_g = World

function CopActionShoot:init(action_desc, common_data)
	local inventory_ext = common_data.ext_inventory
	local weapon_unit = inventory_ext:equipped_unit()

	if not weapon_unit then
		return false
	end

	self._weapon_unit = weapon_unit
	self._common_data = common_data
	self._ext_inventory = inventory_ext
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_brain = common_data.ext_brain
	self._ext_base = common_data.ext_base
	self._machine = common_data.machine
	self._unit = common_data.unit
	self._body_part = action_desc.body_part
	self._variant = action_desc.variant
	self._last_target_pos = action_desc.target_pos

	local weap_base = weapon_unit:base()
	self._weapon_base = weap_base

	local weap_tweak = weap_base:weapon_tweak_data()
	self._weap_tweak = weap_tweak

	local char_tweak = common_data.char_tweak
	local weapon_usage_tweak = char_tweak.weapon[weap_tweak.usage]
	self._miss_first_player_shot = char_tweak.misses_first_player_shot and not self._ext_movement.missed_first_shot
	
	self._glint_effect = weapon_unit:effect_spawner(Idstring("glint_scope"))

	if self._glint_effect then
		self._glint_effect:activate()
	end
	
	self._w_usage_tweak = weapon_usage_tweak

	self._spread_only = weapon_usage_tweak.spread_only and true
	self._aim_delay_minmax = weapon_usage_tweak.aim_delay or {0, 0}
	self._focus_delay = weapon_usage_tweak.focus_delay or 0
	self._focus_displacement = weapon_usage_tweak.focus_dis or 500
	self._spread = weapon_usage_tweak.spread or 20
	self._miss_dis = weapon_usage_tweak.miss_dis or 30
	self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true or nil
	self._tracking_speed = weapon_usage_tweak.tracking_speed or 3000
	self._falloff = weapon_usage_tweak.FALLOFF or {
		{
			dmg_mul = 1,
			r = 1500,
			acc = {
				0.2,
				0.6
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				3,
				3,
				1
			}
		}
	}

	self._shoot_t = 0
	self._melee_timeout_t = 0
	self._timer = TimerManager:game()
	self._last_upd_t = self._timer:time() - 0.001
	
	self._fireline_t = weapon_usage_tweak.fireline_t
	
	if not self._fireline_t then
		local suppressive = weap_base.suppression and weap_base.suppression >= 2 or nil
		self._fireline_t = suppressive and 7 or 2
	end

	if char_tweak.use_lotus_effect then
		self._use_mindcontrol = true

		self._mindcontrol_table = {
			effect = idstr_func("effects/pd2_mod_hh/particles/weapons/lotus_passive"),
			parent = self._unit:get_object(Idstring("RightForeArm"))
		}
	end

	local thhshin = PD2THHSHIN

	if thhshin and thhshin:GlintEnabled() then
		if weap_base._hivis then
			self._hivis = true
			self._hivis_table = {
				effect = idstr_func("effects/pd2_mod_hh/particles/character/prefire_glint"),
				parent = self._unit:get_object(Idstring("Head"))
			}
		end
	end

	self._doom_enemy = char_tweak.stop_firing_on_hurt
	self._is_shin_shootout = Global.game_settings.one_down and true or nil

	if managers.crime_spree and managers.crime_spree.current_mission then
		self._cs_acc_mul = managers.crime_spree:get_acc_mult()
	end

	self._shoot_from_pos = self._ext_movement:m_head_pos()

	local shield_unit = alive(self._ext_inventory._shield_unit) and self._ext_inventory._shield_unit or nil
	self._shield = shield_unit

	self._tank_animations = self._ext_movement._anim_global == "tank" and true or nil
	self._shield_slotmask = managers.slot:get_mask("enemy_shield_check")
	self._geometry_mask = managers.slot:get_mask("world_geometry", "vehicles")

	local is_team_ai, is_converted = nil

	if managers.groupai:state():is_unit_team_AI(self._unit) then
		is_team_ai = true
		self._is_team_ai = true
	elseif self._ext_brain.converted and self._ext_brain:converted() or managers.groupai:state():is_enemy_converted_to_criminal(self._unit) then
		is_converted = true
		self._is_converted = true
	end

	if not shield_unit then
		local melee_weapon = self._ext_base.melee_weapon and self._ext_base:melee_weapon()

		if melee_weapon then
			local slotmask, electrical, shield_knock, anim_param = nil
			local damage, dmg_mul, speed, range = 3, 1, 1, 150
			local retry_delay = {1, 1}
			local hit_player = true
			local anim_vars = {
				"var1",
				"var2"
			}

			if is_team_ai then
				damage = 45
				slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
				shield_knock = true
				hit_player = nil
			elseif is_converted then
				slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
				hit_player = nil
			end

			if not slotmask then
				slotmask = slotmask or managers.slot:get_mask("bullet_impact_targets_no_police") + 3
			end

			if weapon_usage_tweak.melee_retry_delay then
				retry_delay = weapon_usage_tweak.melee_retry_delay
			end

			if melee_weapon == "weapon" then
				if weapon_usage_tweak.melee_dmg then
					damage = weapon_usage_tweak.melee_dmg
				end

				if weapon_usage_tweak.melee_speed then
					speed = weapon_usage_tweak.melee_speed
				end
			else
				if char_tweak.melee_weapon_dmg_multiplier then
					dmg_mul = char_tweak.melee_weapon_dmg_multiplier
				end

				if char_tweak.melee_weapon_speed then
					speed = char_tweak.melee_weapon_speed
				end

				local melee_weapon_stats = tweak_data.weapon.npc_melee[melee_weapon]

				if melee_weapon_stats then
					if melee_weapon_stats.damage then
						damage = melee_weapon_stats.damage
					elseif weapon_usage_tweak.melee_dmg then
						damage = weapon_usage_tweak.melee_dmg
					end

					if melee_weapon_stats.range then
						range = melee_weapon_stats.range
					end

					if melee_weapon_stats.electrical then
						electrical = true
					end
					
					if melee_weapon_stats.animation_param then
						anim_param = melee_weapon_stats.animation_param
					end
				end

				if char_tweak.melee_anims then
					anim_vars = char_tweak.melee_anims
				end
			end

			self._melee_weapon_data = {
				melee_weapon = melee_weapon,
				damage = damage,
				dmg_mul = dmg_mul,
				speed = speed,
				retry_delay = retry_delay,
				range = range,
				slotmask = slotmask,
				hit_player = hit_player,
				electrical = electrical,
				shield_knock = shield_knock,
				anim_param = anim_param,
				anim_vars = anim_vars
			}
		end
	end

	if Network:is_server() then
		self._is_server = true

		self._ext_movement:set_stance_by_code(3)

		common_data.ext_network:send("action_aim_state", true)
	else
		--handle turning speed through the action itself
		self._turn_allowed = true
	end

	local preset_name = self._ext_anim.base_aim_ik or "spine"
	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data
	self[preset_data.start](self)

	self:on_attention(common_data.attention)

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self._skipped_frames = 1

	return true
end

function CopActionShoot:on_exit()
	if self._is_server then
		if not self._exiting_to_reload then
			if not self._attention or not self._attention.reaction or self._attention.reaction < AIAttentionObject.REACT_AIM then
				self._ext_movement:set_stance_by_code(2)
			end
		end

		self._common_data.ext_network:send("action_aim_state", false)
	end

	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._mindcontrol_effect then
		world_g:effect_manager():kill(self._mindcontrol_effect)

		self._mindcontrol_effect = nil
	end
	
	if self._glint_effect then
		self._glint_effect:kill_effect()
	end

	if self._autofiring then
		self._weapon_base:stop_autofire()

		if self._ext_anim.recoil then
			self._ext_movement:play_redirect("up_idle")
		end
	end

	if self._shooting_player and alive(self._attention.unit) then
		self._attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end
end

function CopActionShoot:_get_static_target_pos(shoot_from_pos, attention)
	local target_pos, target_vec, target_dis, autotarget = nil

	if attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	return target_pos, target_vec, target_dis, autotarget
end

function CopActionShoot:_get_target_pos(shoot_from_pos, attention, t)
	local target_pos, target_vec, target_dis, autotarget = nil

	if attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = mvec3_copy(attention.pos)
	end
	
	target_dis = mvec3_dis(shoot_from_pos, target_pos)
	
	if not self._last_target_pos then
		self._last_target_pos = Vector3()
		mvec3_set(self._last_target_pos, self._common_data.look_vec)
		mvec3_mul(self._last_target_pos, target_dis)
		mvec3_add(self._last_target_pos, shoot_from_pos)
		mvec3_set_z(self._last_target_pos, target_pos.z)
	end
	
	if mvector3.equal(target_pos, self._last_target_pos) then
		target_vec = temp_vec3
		mvec3_dir(target_vec, shoot_from_pos, target_pos)
	else
		local dt = t - self._last_upd_t
		self._last_upd_t = self._timer:time()
		local wanted_target_pos = Vector3()
		
		mvec3_step(wanted_target_pos, self._last_target_pos, target_pos, self._tracking_speed * dt)
		--mvec3_set_z(wanted_target_pos, target_pos.z)
		
		target_pos = wanted_target_pos
		self._last_target_pos = target_pos
		
		target_vec = temp_vec3
		mvec3_dir(target_vec, shoot_from_pos, target_pos)
	end

	return target_pos, target_vec, target_dis, autotarget
end

-- SH: helper to cleanly stop the current burst
function CopActionShoot:_stop_firing()
	self._is_single_shot = nil
	if self._autofiring then
		self._autofiring = nil
		self._weapon_base:stop_autofire()
	end
end

function CopActionShoot:on_attention(attention, old_attention)
	-- SH: stop burst when switching targets (unless weapon opts out)
	if not self._w_usage_tweak.no_autofire_stop then
		self:_stop_firing()
	end

	if self._shooting_player and old_attention and alive(old_attention.unit) then
		old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	if self._autofiring then
		self._weapon_base:stop_autofire()

		if self._ext_anim.recoil then
			self._ext_movement:play_redirect("up_idle")
		end

		self._autofiring = nil
		self._autoshots_fired = nil
	end

	self._shooting_player = nil
	self._shooting_husk_unit = nil
	self._next_vis_ray_t = nil
	self._can_melee = nil

	if attention then
		local t = self._timer:time()

		self[self._ik_preset.start](self)

		local vis_state = self._ext_base:lod_stage()

		self._aim_transition = nil

		-- SH: IK functions set this when needed; don't artificially delay enemies
		self._mod_enable_t = 0
		-- SH: reset vis ray timer and flag for aim focus delay on new target
		self._next_vis_ray_t = 0
		self._apply_aim_focus_delay = true
		local ding = nil
		local play_it_here = nil

		if attention.unit then
			local att_ext_base = attention.unit:base()

			if att_ext_base and att_ext_base.is_local_player then
				self._shooting_player = true

				attention.unit:movement():on_targetted_for_attack(true, self._unit)

				if self._melee_weapon_data then
					self._can_melee = true
				end

				if self._hivis and self._common_data.allow_fire then
					if not vis_state then
						self._play_hivis_glint = true
					else
						play_it_here = true
					end
				end
			elseif self._is_server then
				if att_ext_base and att_ext_base.is_husk_player then
					self._shooting_husk_unit = true
				elseif self._melee_weapon_data then
					self._can_melee = true
				end
			else
				self._shooting_husk_unit = true
			end

			local target_pos, _, target_dis = CopActionShoot._get_target_pos(self, self._shoot_from_pos, attention, t)
			local usage_tweak = self._w_usage_tweak
			local shoot_hist = self._shoot_history
			local aim_delay = 0
			local aim_delay_minmax = self._aim_delay_minmax

			if shoot_hist then
				local displacement = mvec3_dis(target_pos, shoot_hist.m_last_pos)

				if displacement > self._focus_displacement then
					if draw_focus_displacement then
						local line = Draw:brush(Color.blue:with_alpha(0.5), 2)
						line:cylinder(self._shoot_from_pos, shoot_hist.m_last_pos, 0.5)
						line:cylinder(self._shoot_from_pos, target_pos, 0.5)
						line:cylinder(target_pos, shoot_hist.m_last_pos, 0.5)
					end

					if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
						if aim_delay_minmax[1] == aim_delay_minmax[2] then
							aim_delay = aim_delay_minmax[1]
						else
							local lerp_dis = self._focus_displacement / displacement

							aim_delay = math_lerp(aim_delay_minmax[2], aim_delay_minmax[1], lerp_dis)
						end

						if self._common_data.is_suppressed and not self._is_shin_shootout then
							aim_delay = aim_delay * 1.5
						end
					end

					self._shoot_t = t + aim_delay

					if self._can_melee then
						local melee_delay = math_min(aim_delay, 0.35)
						self._melee_start_allowed_t = t + melee_delay
					end
				elseif self._can_melee and not self._melee_start_allowed_t then
					self._melee_start_allowed_t = t
				end

				shoot_hist.m_last_pos = mvec3_copy(target_pos)

				if play_it_here or self._play_hivis_glint then
					if target_dis <= 300 then
						ding = true
						play_it_here = true
						self._play_hivis_glint = nil
					end
				end

				if shoot_hist.u_key and shoot_hist.u_key ~= attention.unit:key() then
					self._played_hivis_glint = nil
					self._line_of_sight_t = nil

					shoot_hist.focus_start_t = t
					shoot_hist.focus_delay = self._focus_delay
				end

				shoot_hist.u_key = attention.unit:key()
			else
				if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
					if aim_delay_minmax[1] == aim_delay_minmax[2] then
						aim_delay = aim_delay_minmax[1]
					else
						local lerp_dis = math_min(1, target_dis / self._falloff[#self._falloff].r)

						aim_delay = math_lerp(aim_delay_minmax[1], aim_delay_minmax[2], lerp_dis)
					end

					if self._common_data.is_suppressed and not self._is_shin_shootout then
						aim_delay = aim_delay * 1.5
					end
				end

				self._shoot_t = t + aim_delay

				if self._can_melee then
					local melee_delay = math_min(aim_delay, 0.35)
					self._melee_start_allowed_t = t + melee_delay
				end

				shoot_hist = {
					focus_start_t = t,
					focus_delay = self._focus_delay,
					m_last_pos = mvec3_copy(target_pos),
					u_key = attention.unit:key()
				}
				self._shoot_history = shoot_hist

				if play_it_here or self._play_hivis_glint then
					if target_dis <= 300 then
						ding = true
						play_it_here = true
						self._play_hivis_glint = nil
					end
				end
			end
		end

		if self._use_mindcontrol and not self._mindcontrol_effect then
			self._mindcontrol_effect = world_g:effect_manager():spawn(self._mindcontrol_table)
		end

		if play_it_here then
			self:play_glint_effect(ding)
		end
	else
		self[self._ik_preset.stop](self)

		if self._mindcontrol_effect then
			world_g:effect_manager():kill(self._mindcontrol_effect)

			self._mindcontrol_effect = nil
		end

		self._apply_aim_focus_delay = false
	end

	-- SH: track husk player flag for aim focus delay
	self._shooting_husk_player = attention and attention.unit and attention.unit:base() and attention.unit:base().is_husk_player

	self._attention = attention
end

function CopActionShoot:play_glint_effect(ding)
	if self._played_hivis_glint then
		return
	end

	local done = world_g:effect_manager():spawn(self._hivis_table)

	if ding then
		self._unit:sound():play("bell_ring")
	end

	if done then
		self._played_hivis_glint = true
	end
end

function CopActionShoot:update(t)
	local vis_state = self._ext_base:lod_stage() or 4
	if vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1
			return
		else
			self._skipped_frames = 1
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_vec, target_dis, target_pos

	if self._attention then
		target_pos, target_vec, target_dis = self:_get_target_pos(shoot_from_pos, self._attention, t)
		local tar_vec_flat = temp_vec2
		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)
		local fwd = self._common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

		-- SH: fixed turn condition — enabled for host too (was client-only in vanilla)
		if self._turn_allowed then
			local active_actions = self._common_data.active_actions
			if not active_actions[2] or active_actions[2]:type() == "idle" then
				local queued_actions = self._common_data.queued_actions
				if not queued_actions or not queued_actions[1] and not queued_actions[2] then
					if not self._ext_movement:chk_action_forbidden("walk") then
						local spin = tar_vec_flat:to_polar_with_reference(fwd, math.UP).spin
						if math.abs(spin) > 25 then
							self._ext_movement:action_request({
								body_part = 2,
								type = "turn",
								angle = spin
							})
						end
					end
				end
			end
		end

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	if ext_anim.reload then
		if self._looped_expire_t and self._looped_expire_t < t then
			self._looped_expire_t = nil
			self._ext_movement:play_redirect("reload_looped_exit")
		end
		return
	elseif ext_anim.melee then
		self._shoot_t = t + 0.25
		return
	elseif ext_anim.equip then
		return
	end

	-- Reload
	if self._weapon_base:clip_empty() then
		self:_stop_firing()
		-- SH: use CopActionReload's play_reload helper
		if self._is_server and not ext_anim.recoil then
			CopActionReload._play_reload(self, t)
		end
		return
	end

	-- Stop shooting
	if not target_vec or not target_dis or not target_pos or not self._common_data.allow_fire then
		self:_stop_firing()
		return
	end

	-- Melee (HH: keep full melee pipeline with check_melee_start)
	local can_melee = self._can_melee and self._melee_start_allowed_t and self._melee_start_allowed_t < t
	if can_melee and self._melee_weapon_data and target_dis <= self._melee_weapon_data.range - 20 then
		if self:check_melee_start(t, self._attention.unit, target_dis, shoot_from_pos, self._shooting_player) then
			if self:_chk_start_melee(t) then
				self:_stop_firing()
				self._shoot_t = t + 1
				return
			end
		end
	end

	-- Shield flash
	if self._shield_use_cooldown and self._shield_use_cooldown < t and target_dis < self._shield_use_range then
		self._shield_use_cooldown = self._shield_base:request_use(t) or self._shield_use_cooldown
	end

	-- SH: autofiring — fire one shot per tick, decrement countdown
	if self._autofiring then
		local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
		local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
		local dmg_mul = dmg_buff * falloff.dmg_mul

		local miss_pos = self._shoot_history and self:_get_unit_shoot_pos(t, target_pos, target_dis, self._w_usage_tweak, falloff, i_range, self._shooting_player)
		if miss_pos then
			mvec3_dir(target_vec, shoot_from_pos, miss_pos)
		end

		local fire_func = self._is_single_shot and self._weapon_base.singleshot or self._weapon_base.trigger_held
		local fired = fire_func(self._weapon_base, shoot_from_pos, target_vec, dmg_mul, self._shooting_player, nil, nil, nil, self._attention.unit)
		if not fired then
			return
		end

		self._autofiring = self._autofiring - 1
		if self._autofiring <= 0 then
			self:_stop_firing()
			-- HH: punk effect halves delay
			local delay_mul = self._unit:character_damage()._punk_effect and 0.25 or 1
			self._shoot_t = t + (self._common_data.is_suppressed and 1.5 or 1) * delay_mul * math_lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom())
		end

		if vis_state == 1 and not ext_anim.base_no_recoil then
			-- HH: tank units skip recoil
			if not self._tank_animations then
				self._ext_movement:play_redirect("recoil_single")
			end
		end

		if fired.hit_enemy and fired.hit_enemy.type == "death" and self._unit:unit_data().mission_element then
			self._unit:unit_data().mission_element:event("killshot", self._unit)
		end

		return
	end

	-- SH: aim and focus delay on new target acquisition
	if self._apply_aim_focus_delay then
		if t < self._next_vis_ray_t then
			return
		elseif self._shooting_player and self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._verif_slotmask, "ray_type", "ai_vision", "report") then
			self._next_vis_ray_t = t + 0.05
			return
		end

		local aim_delay_minmax = self._w_usage_tweak.aim_delay
		local aim_delay = math.map_range_clamped(target_dis, 0, self._falloff[#self._falloff].r, aim_delay_minmax[1], aim_delay_minmax[2])

		self._shoot_t = math.max(self._shoot_t, t + aim_delay * (self._common_data.is_suppressed and 1.5 or 1))

		if self._shoot_history then
			self._shoot_history.focus_start_t = self._shoot_t
			self._shoot_history.focus_delay = self._w_usage_tweak.focus_delay
		end

		self._apply_aim_focus_delay = false
		return
	end

	-- Start burst
	if self._shoot_t < t and self._mod_enable_t < t then
		if self._common_data.char_tweak.no_move_and_shoot and ext_anim.move then
			self._shoot_t = t + (self._common_data.char_tweak.move_and_shoot_cooldown or 1)
			return
		end

		-- HH: hivis glint
		if self._play_hivis_glint then
			local ding = target_dis <= 300
			if ding or vis_state < 4 then
				self:play_glint_effect(ding)
			end
		end

		-- LOS check
		local shoot = nil
		local shooting_husk = self._shooting_husk_unit
		if self._attention.unit then
			if not shooting_husk or not self._next_vis_ray_t or self._next_vis_ray_t < t then
				if shooting_husk then
					self._next_vis_ray_t = t + 1
				end

				local fire_line_obstructed = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision")

				if fire_line_obstructed then
					if not self._line_of_sight_t or t - self._line_of_sight_t > self._fireline_t then
						local aim_delay_minmax = self._aim_delay_minmax
						local aim_delay = 0
						if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
							aim_delay = math_lerp(aim_delay_minmax[1], aim_delay_minmax[2], math_min(1, target_dis / self._falloff[#self._falloff].r))
							if self._common_data.is_suppressed and not self._is_shin_shootout then
								aim_delay = aim_delay * 1.5
							end
						end
						self._shoot_t = t + aim_delay
					elseif fire_line_obstructed.distance > 300 then
						shoot = true
					end
				else
					local shield_in_the_way = nil
					if not self._weapon_base._use_armor_piercing or self._shooting_player then
						if self._shield then
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._shield_slotmask, "ignore_unit", self._shield, "report")
						else
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._shield_slotmask, "report")
						end
					end

					if not shield_in_the_way then
						shoot = true
					end

					if not self._line_of_sight_t or t - self._line_of_sight_t > self._fireline_t then
						if self._shoot_history then
							self._shoot_history.focus_start_t = t
							self._shoot_history.focus_delay = self._focus_delay
							self._shoot_history.m_last_pos = mvec3_copy(target_pos)
						end
						self._line_of_sight_t = t
					end
				end

				self._last_vis_check_status = shoot
			else
				shoot = self._last_vis_check_status
			end
		else
			shoot = true
		end

		if shoot and self._shoot_t < t then
			-- SH: determine burst size using autofire_rounds from falloff or w_usage_tweak
			local num_rounds = 1
			if self._automatic_weap then
				local falloff = self:_get_shoot_falloff(target_dis, self._falloff)
				if falloff.autofire_rounds then
					num_rounds = self:_pseudorandom(falloff.autofire_rounds[1], falloff.autofire_rounds[2])
				elseif self._w_usage_tweak.autofire_rounds then
					local f = math.map_range(target_dis, self._falloff[1].r, self._falloff[#self._falloff].r, 0, 1)
					local ar = self._w_usage_tweak.autofire_rounds
					num_rounds = math.ceil(math.map_range_clamped(f - 0.15 + self:_pseudorandom() * 0.3, 0, 1, ar[2], ar[1]))
				end
			end

			self._is_single_shot = num_rounds == 1
			self._autofiring = num_rounds
			if num_rounds > 1 then
				self._weapon_base:start_autofire(num_rounds < 4 and num_rounds)
			end
		end
	end
end


function CopActionShoot:_get_modified_spread(t, falloff)
	local att_unit = self._attention.unit
	local shoot_hist = self._shoot_history
	local focus_prog = nil

	if shoot_hist and shoot_hist.focus_delay then
		local focus_delay = shoot_hist.focus_delay
		local att_dmg_ext = att_unit:character_damage()

		if att_dmg_ext and att_dmg_ext.focus_delay_mul then
			focus_delay = att_dmg_ext:focus_delay_mul() * focus_delay
		end

		if focus_delay > 0 then
			local time_passed = t - shoot_hist.focus_start_t
			focus_prog = time_passed / focus_delay
		end

		if not focus_prog or focus_prog >= 1 then
			shoot_hist.focus_delay = nil
			focus_prog = 1
		end
	else
		focus_prog = 1
	end

	local spread_values = falloff.acc
	local spread = math_lerp(spread_values[1], spread_values[2], focus_prog)
	local common_data = self._common_data

	 --spread isn't affected when suppressed, or dodging in shin mode
	if not self._is_shin_shootout then
		if common_data.is_suppressed then
			spread = spread / 0.8
		end

		local lower_body_action = common_data.active_actions[2]

		if lower_body_action and lower_body_action:type() == "dodge" then
			spread = spread / lower_body_action:accuracy_multiplier()
		end
	end

	local att_mov_ext = att_unit:movement()
	
	if shooting_local_player then
		if not att_mov_ext:running() then
			spread = spread / 1.2
		end
	else
		local att_anim_data = att_unit:anim_data()

		if att_anim_data then
			if att_anim_data.dodge then
				spread = spread * 10
			elseif not att_anim_data.run then
				spread = spread / 1.2
			end
		end
	end

	local cs_acc_mul = self._cs_acc_mul

	if cs_acc_mul then
		spread = spread / cs_acc_mul
	end

	local dmg_ext = self._unit:character_damage()

	if dmg_ext.accuracy_multiplier then
		spread = spread / dmg_ext:accuracy_multiplier()
	end

	if dmg_ext._punk_effect then
		spread = spread / 3
	end

	spread = math_clamp(spread, 0, 400)

	return spread
end

-- SH: interpolate between falloff entries for smooth damage/accuracy transitions
function CopActionShoot:_get_shoot_falloff(target_dis, falloff)
	local i = #falloff
	local data = falloff[i]
	for i_range, range_data in ipairs(falloff) do
		if target_dis < range_data.r then
			i = i_range
			data = range_data
			break
		end
	end
	if i == 1 or target_dis > data.r then
		return data, i
	else
		local prev_data = falloff[i - 1]
		local lerp_t = (target_dis - prev_data.r) / (data.r - prev_data.r)
		local n_data = {
			r = target_dis,
			dmg_mul = math_lerp(prev_data.dmg_mul, data.dmg_mul, lerp_t),
			acc = {
				math_lerp(prev_data.acc[1], data.acc[1], lerp_t),
				math_lerp(prev_data.acc[2], data.acc[2], lerp_t)
			},
			recoil = {
				math_lerp(prev_data.recoil[1], data.recoil[1], lerp_t),
				math_lerp(prev_data.recoil[2], data.recoil[2], lerp_t)
			},
			autofire_rounds = prev_data.autofire_rounds and data.autofire_rounds and {
				math_lerp(prev_data.autofire_rounds[1], data.autofire_rounds[1], lerp_t),
				math_lerp(prev_data.autofire_rounds[2], data.autofire_rounds[2], lerp_t)
			},
			mode = data.mode
		}
		return n_data, i
	end
end

function CopActionShoot:_get_unit_shoot_pos(t, pos, dis, w_tweak, falloff, i_range, shooting_local_player)
	local shoot_hist = self._shoot_history
	local focus_delay, focus_prog

	if shoot_hist and shoot_hist.focus_delay then
		focus_delay = (shooting_local_player and self._attention.unit:character_damage():focus_delay_mul() or 1) * shoot_hist.focus_delay
		focus_prog = focus_delay > 0 and (t - shoot_hist.focus_start_t) / focus_delay
		if not focus_prog or focus_prog >= 1 then
			shoot_hist.focus_delay = nil
			focus_prog = 1
		end
	else
		focus_prog = 1
	end

	local hit_chance = math_lerp(falloff.acc[1], falloff.acc[2], focus_prog) * self._unit:character_damage():accuracy_multiplier()

	if self._common_data.is_suppressed and not self._is_shin_shootout then
		hit_chance = hit_chance * 0.5
	end

	-- SH: self dodge reduces accuracy
	if self._common_data.active_actions[2] and self._common_data.active_actions[2]:type() == "dodge" then
		hit_chance = hit_chance * self._common_data.active_actions[2]:accuracy_multiplier()
	end

	-- HH: target movement affects accuracy
	local att_unit = self._attention.unit
	if att_unit then
		if shooting_local_player then
			if not att_unit:movement():running() then
				hit_chance = hit_chance * 1.2
			end
		else
			local att_anim = att_unit:anim_data()
			if att_anim then
				if att_anim.dodge then
					hit_chance = 0  -- 0% vs dodging NPCs
				elseif not att_anim.run then
					hit_chance = hit_chance * 1.2
				end
			end
		end
	end

	-- HH: custom suppression accuracy multiplier
	if self._cs_acc_mul then
		hit_chance = hit_chance * self._cs_acc_mul
	end

	-- HH: punk effect triples accuracy
	if self._unit:character_damage()._punk_effect then
		hit_chance = hit_chance * 3
	end

	if self._miss_first_player_shot and (shooting_local_player or self._shooting_husk_player) then
		self._miss_first_player_shot = nil
		self._ext_movement.missed_first_shot = true
		hit_chance = 0
	end

	local hit = math_random() < hit_chance

	mvec3_set(temp_vec1, pos)
	mvec3_sub(temp_vec1, self._shoot_from_pos)

	mvec3_cross(temp_vec2, temp_vec1, math.UP)
	mrot_axis_angle(temp_rot1, temp_vec1, math_random(360))
	mvec3_rot(temp_vec2, temp_rot1)

	-- SH: error formula — miss grows with distance from ideal and with unfocused aim
	local miss_min_dis = shooting_local_player and 31 or 150
	local hit_max_dis = shooting_local_player and 25 or 7
	local error_vec_len = hit and hit_max_dis * math_random() or miss_min_dis + 100 * (1 - hit_chance) * (2 - focus_prog) * math_random()

	mvec3_set_l(temp_vec2, error_vec_len)
	mvec3_add(temp_vec2, pos)

	return temp_vec2
end


function CopActionShoot:check_melee_start(t, att_unit, target_dis, melee_from_pos, target_is_local_player)
	if self._melee_timeout_t >= t then
		return
	end

	local countered_t = self._common_data.melee_countered_t

	if countered_t and t <= countered_t then
		return
	end

	local att_base_ext, att_dmg_ext, is_sentry = nil

	if not target_is_local_player then
		att_base_ext = att_unit:base()

		if not att_base_ext or att_base_ext.is_husk_player then
			return
		end

		att_dmg_ext = att_unit:character_damage()

		--we can use bullet damage against turrets/sentries, but check for damage_melee against anything else
		if att_base_ext.sentry_gun then
			is_sentry = true
		elseif not att_dmg_ext.damage_melee then
			return
		end

		if att_dmg_ext.dead and att_dmg_ext:dead() then
			return
		end
	end

	mvec3_set(temp_vec3, self._ext_movement:m_head_rot():z())
	mvec3_mul(temp_vec3, target_dis)
	mvec3_add(temp_vec3, melee_from_pos)

	local obstructed_by_geometry = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 10, "slot_mask", self._geometry_mask, "ray_type", "body melee", "report")

	if obstructed_by_geometry then
		return
	end

	local function chk_covered_by_shield()
		local hit_shield = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 25, "slot_mask", self._shield_slotmask, "ray_type", "body melee", "report")

		if hit_shield then
			return true
		end
	end

	if target_is_local_player then
		if not self._melee_weapon_data.electrical or not att_unit:movement():tased() then
			if not chk_covered_by_shield() then
				return true
			end
		end
	elseif is_sentry then
		if not self._melee_weapon_data.electrical and not chk_covered_by_shield() then
			return true
		end
	elseif chk_covered_by_shield() then
		local att_inv_ext = att_unit:inventory()

		if att_inv_ext and alive(att_inv_ext._shield_unit) then
			local can_be_knocked = self._melee_weapon_data.shield_knock and not att_base_ext.is_phalanx and att_base_ext:char_tweak().damage.shield_knocked and not att_dmg_ext:is_immune_to_shield_knockback()

			if can_be_knocked and not att_unit:movement():chk_action_forbidden("hurt") then
				return true
			end
		end
	elseif self._melee_weapon_data.electrical then
		local char_tweak = att_base_ext:char_tweak()
		local can_be_tased = char_tweak.can_be_tased and true or char_tweak.can_be_tased == nil

		if can_be_tased and not att_unit:movement():chk_action_forbidden("hurt") then
			return true
		end
	else
		return true
	end
end

function CopActionShoot:_chk_start_melee(t)
	local melee_weap_data = self._melee_weapon_data
	local melee_weapon = melee_weap_data.melee_weapon
	local is_weapon = melee_weapon == "weapon"
	local redir_name = is_weapon and "melee" or "melee_item"
	local tank_melee = nil

	if is_weapon then
		if self._weap_tweak.usage == "mini" then
			redir_name = "melee_bayonet" --bash with the front of the minigun's barrel like in first person
		end
	elseif melee_weapon == "fists" and self._tank_animations then
		redir_name = "melee" --use tank_melee unique punching animation as originally intended
		tank_melee = true
	end

	local melee_res = self._ext_movement:play_redirect(redir_name)

	if not melee_res then
		return
	end

	if melee_weap_data.speed ~= 1 then
		self._common_data.machine:set_speed(melee_res, melee_weap_data.speed)
	end

	if not is_weapon and not tank_melee then
		if #melee_weap_data.anim_vars == 1 then
			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_vars[1], 1)
		else
			local melee_var = self:_pseudorandom(#melee_weap_data.anim_vars)

			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_vars[melee_var], 1)
		end

		if melee_weap_data.anim_param then
			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_param, 1)
		end
	end

	--let other players see when NPCs attempt a melee attack instead of nothing (not actually cosmetic as melee attacks are tied to the animation, but the necessary checks to prevent issues with that are there)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, redir_name)

	if melee_weap_data.retry_delay[1] == melee_weap_data.retry_delay[2] then
		self._melee_timeout_t = t + melee_weap_data.retry_delay[1]
	else
		self._melee_timeout_t = t + math_lerp(melee_weap_data.retry_delay[1], melee_weap_data.retry_delay[2], self:_pseudorandom())
	end

	return true
end

function CopActionShoot:anim_clbk_melee_strike()
	local melee_weap_data = self._melee_weapon_data

	if not melee_weap_data then
		return
	end

	local melee_from_pos = self._shoot_from_pos
	local my_fwd = self._ext_movement:m_head_rot():z()

	mvec3_set(temp_vec3, my_fwd)
	mvec3_mul(temp_vec3, melee_weap_data.range)
	mvec3_add(temp_vec3, melee_from_pos)

	local melee_slotmask = melee_weap_data.slotmask
	local attention = self._attention

	if attention and attention.unit then
		local enemies_slot_mask = managers.slot:get_mask("enemies")

		if attention.unit:in_slot(enemies_slot_mask) and self._unit:in_slot(enemies_slot_mask) then
			melee_slotmask = managers.slot:get_mask("bullet_impact_targets")
		end
	end

	--similar to player melee attacks, use a sphere ray instead of just a normal plain ray
	local col_ray = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 20, "slot_mask", melee_slotmask, "ray_type", "body melee")

	if draw_melee_sphere_rays then
		local draw_duration = 3
		local new_brush = col_ray and Draw:brush(Color.red:with_alpha(0.5), draw_duration) or Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		local sphere_draw_pos = col_ray and col_ray.position or temp_vec3
		local sphere_draw_size = col_ray and 5 or 20
		new_brush:sphere(sphere_draw_pos, sphere_draw_size)
	end

	local local_player = nil

	--a more clean method of determining if the local player should get hit or not, without cancelling the attack if the player can't get hit, like it did before
	--sadly, no raycasts I tried so far (even with target_unit/target_body) seem to be able to hit the local player
	if melee_weap_data.hit_player then	
		local_player = managers.player:player_unit()

		if local_player and not self._unit:character_damage():is_friendly_fire(local_player) then
			local player_head_pos = local_player:movement():m_head_pos()
			local attack_dir = player_head_pos - melee_from_pos
			local player_distance = attack_dir:length()

			if player_distance <= melee_weap_data.range then
				if not col_ray or col_ray.distance > player_distance or not self._unit:raycast("ray", melee_from_pos, player_head_pos, "sphere_cast_radius", 5, "slot_mask", melee_slotmask, "ray_type", "body melee", "report") then
					mvec3_set(temp_vec4, attack_dir)
					mvec3_set_z(temp_vec4, 0)
					mvec3_norm(temp_vec4)
					mvec3_norm(attack_dir)

					local min_dot = math_lerp(0, 0.4, player_distance / melee_weap_data.range)
					local fwd_dot = mvec3_dot(my_fwd, temp_vec4)

					if fwd_dot >= min_dot then
						col_ray = {
							unit = local_player,
							position = mvec3_copy(player_head_pos),
							ray = attack_dir
						}

						if draw_melee_sphere_rays then
							local draw_duration = 3
							local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
							local sphere_draw_pos = player_head_pos
							local sphere_draw_size = 5
							new_brush:sphere(sphere_draw_pos, sphere_draw_size)
						end
					end
				end
			end
		end
	end

	if not col_ray or not alive(col_ray.unit) then
		return
	end

	local is_server = self._is_server
	local melee_weapon = melee_weap_data.melee_weapon
	local damage = melee_weap_data.damage
	local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
	damage = damage * melee_weap_data.dmg_mul * dmg_buff

	managers.game_play_central:physics_push(col_ray) --the function already has sanity checks so it's fine to just use it like this

	local hit_unit = col_ray.unit
	local character_unit, shield_knock, defense_data = nil

	if is_server and melee_weap_data.shield_knock and hit_unit:in_slot(self._shield_slotmask) then
		local parent = hit_unit:parent()

		if alive(parent) then
			local parent_base_ext = parent:base()
			local can_be_knocked = parent_base_ext and not parent_base_ext.is_phalanx and parent_base_ext:char_tweak().damage.shield_knocked and not parent:character_damage():is_immune_to_shield_knockback()

			if can_be_knocked then
				shield_knock = true
				character_unit = parent
			end
		end
	end

	character_unit = character_unit or hit_unit

	local unit_dmg_ext = character_unit:character_damage()
	local unit_base_ext = character_unit:base()

	if local_player and character_unit == local_player then
		local action_data = {
			variant = "melee",
			damage = damage,
			weapon_unit = self._weapon_unit,
			attacker_unit = self._unit,
			melee_weapon = melee_weapon,
			push_vel = mvec3_copy(col_ray.ray:with_z(0.1)) * 600,
			tase_player = melee_weap_data.electrical and true or nil,
			col_ray = col_ray
		}

		defense_data = unit_dmg_ext:damage_melee(action_data)
	elseif is_server then --only allow melee damage against NPCs for the host (used in case an enemy targets a client locally but hits something else instead)
		if unit_dmg_ext then
			if unit_base_ext and unit_base_ext.sentry_gun then
				local action_data = {
					variant = "bullet",
					damage = damage,
					weapon_unit = self._weapon_unit,
					attacker_unit = self._unit,
					origin = mvec3_copy(melee_from_pos),
					col_ray = col_ray
				}

				defense_data = unit_dmg_ext:damage_bullet(action_data) --sentries/turrets lack a melee damage function
			elseif unit_dmg_ext.damage_melee then
				if not unit_base_ext or not unit_base_ext.is_husk_player then --ignore player husks as the damage CAN be synced and dealt to them
					local variant = shield_knock and "melee" or melee_weap_data.electrical and "taser_tased" or "melee"
					local action_data = {
						variant = variant,
						damage = shield_knock and 0 or damage,
						damage_effect = damage * 2,
						weapon_unit = melee_weapon == "weapon" and self._weapon_unit or nil,
						attacker_unit = self._unit,
						name_id = melee_weapon,
						shield_knock = shield_knock,
						col_ray = col_ray
					}

					defense_data = unit_dmg_ext:damage_melee(action_data)
				end
			end
		end

		if character_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then --damage objects with body extensions (like glass), just like players are able to
			damage = math_clamp(damage, 0, 63)

			col_ray.body:extension().damage:damage_melee(self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
			managers.network:session():send_to_peers_synched("sync_body_damage_melee", col_ray.body, self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		end
	end

	if not defense_data or defense_data == "friendly_fire" then
		return
	end

	if defense_data == "countered" then
		self._common_data.melee_countered_t = self._timer:time() + 15

		local my_com = self._ext_movement:m_com()
		local attack_dir = my_com - character_unit:movement():m_head_pos()
		mvec3_norm(attack_dir)

		local counter_data = {
			damage = 0,
			damage_effect = 1,
			variant = "counter_spooc",
			attacker_unit = character_unit,
			attack_dir = attack_dir,
			col_ray = {
				position = mvec3_copy(my_com),
				body = self._unit:body("body"),
				ray = attack_dir
			},
			name_id = character_unit == local_player and managers.blackmarket:equipped_melee_weapon() or character_unit:base():melee_weapon()
		}

		self._unit:character_damage():damage_melee(counter_data)
	elseif not shield_knock and character_unit ~= local_player and unit_dmg_ext and not unit_dmg_ext._no_blood then
		if not unit_base_ext or unit_base_ext.sentry_gun then
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				col_ray = col_ray
			})
		else
			managers.game_play_central:sync_play_impact_flesh(col_ray.position, col_ray.ray)
		end
	end
end
