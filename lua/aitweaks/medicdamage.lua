local math_random = math.random

function MedicDamage:heal_unit(unit, no_cooldown)
	--if not no_cooldown then
	--	local t = Application:time()
	--
	--	self._heal_cooldown_t = t
	--end

	if not self._unit:character_damage():dead() then
		self._unit:sound():say("heal")

		local contour_ext = self._unit:contour()

		if contour_ext then
			contour_ext:add("mark_enemy")
		end

		local base_ext = self._unit:base()
		local custom_vo = base_ext:char_tweak()["custom_voicework"]

		if custom_vo then
			local voicelines = _G.voiceline_framework.BufferedSounds[custom_vo]

			if voicelines and voicelines["heal"] then
				local line_to_use = voicelines.heal[math_random(#voicelines.heal)]

				base_ext:play_voiceline(line_to_use)
			end
		end

		local anim_data = self._unit:anim_data()
		local acting = anim_data and anim_data.act

		if not acting then
			local redir_res = self._unit:movement():play_redirect("cmd_get_up")

			if redir_res then
				self._unit:anim_state_machine():set_speed(redir_res, 0.5)
			end
		end
	end

	managers.network:session():send_to_peers_synched("sync_medic_heal", self._unit)
	MedicActionHeal:check_achievements()

	return true
end


-- (SHAI) Override MedicDamage.verify_heal_requesting_unit: after passing original checks, performs two raycasts (to head and to feet of the requester). If either is unobstructed the heal is allowed, handling allies peeking cover. Healing radius is boosted ×1.5 via get_healing_radius_sq to offset the stricter LOS requirement.
local _verify_heal_requesting_unit_original = MedicDamage.verify_heal_requesting_unit
function MedicDamage:verify_heal_requesting_unit(requesting_unit, ...)
	if not _verify_heal_requesting_unit_original(self, requesting_unit, ...) then
		return false
	end

	local medic_pos = self._unit:movement():m_head_pos()
	local slot_mask = managers.slot:get_mask("AI_visibility")

	if not World:raycast("ray", medic_pos, requesting_unit:movement():m_head_pos(), "slot_mask", slot_mask, "ray_type", "ai_vision", "report") then
		return true
	end

	if not World:raycast("ray", medic_pos, requesting_unit:movement():m_pos(), "slot_mask", slot_mask, "ray_type", "ai_vision", "report") then
		return true
	end

	return false
end

local _get_healing_radius_sq_original = MedicDamage.get_healing_radius_sq
function MedicDamage:get_healing_radius_sq(...)
	return _get_healing_radius_sq_original(self, ...) * 1.5 * 1.5
end


-- (SHAI) Override MedicDamage.is_available_for_healing: returns false while the medic's act slot is forbidden (playing an act animation such as cuffing, surrendering, or being staggered). Vanilla medics could emit heals while ragdolling, which looked wrong and wasted heal charges.
local _is_available_for_healing_original = MedicDamage.is_available_for_healing
function MedicDamage:is_available_for_healing(requesting_unit, ...)
	if self._unit:movement():chk_action_forbidden("act") then
		return false
	end
	return _is_available_for_healing_original(self, requesting_unit, ...)
end
