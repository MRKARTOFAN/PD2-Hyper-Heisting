-- Add chance to concussion effect to make it less obnoxious
local give_impact_damage_original = ConcussiveInstantBulletBase.give_impact_damage
function ConcussiveInstantBulletBase:give_impact_damage(col_ray, weapon_unit, ...)
	local conc_tweak = alive(weapon_unit) and weapon_unit:base().concussion_tweak and weapon_unit:base():concussion_tweak()
	if math.random() < (conc_tweak and conc_tweak.chance or 1) then
		return give_impact_damage_original(self, col_ray, weapon_unit, ...)
	else
		return self.super.give_impact_damage(self, col_ray, weapon_unit, ...)
	end
end

local function claim_their_bones_ammo_multiplier()
	local level = managers.player:upgrade_level("player", "claim_their_bones_ammo_multiplier", 0)

	if level <= 0 then
		return 1
	end

	local values = tweak_data.upgrades.values.player.claim_their_bones_ammo_multiplier
	local multiplier = 1

	for i = 1, level do
		multiplier = multiplier * (values[i] or 1)
	end

	return multiplier
end

local function apply_claim_their_bones_ammo_multiplier(ammo_base)
	if not ammo_base or ammo_base.weapon_tweak_data and ammo_base:weapon_tweak_data().ignore_player_skills then
		return
	end

	local multiplier = claim_their_bones_ammo_multiplier()

	if multiplier == 1 then
		return
	end

	local ammo_max_per_clip = ammo_base.calculate_ammo_max_per_clip and ammo_base:calculate_ammo_max_per_clip() or ammo_base:get_ammo_max_per_clip()
	local ammo_max = math.round(ammo_base:get_ammo_max() * multiplier)
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_total = math.min(ammo_base:get_ammo_total(), ammo_max)

	ammo_base:set_ammo_max(ammo_max)
	ammo_base:set_ammo_max_per_clip(ammo_max_per_clip)
	ammo_base:set_ammo_total(ammo_total)
	ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_remaining_in_clip(), ammo_max_per_clip))
end

Hooks:PostHook(RaycastWeaponBase, "replenish", "hh_claim_their_bones_raycast_ammo_multiplier", function(self)
	apply_claim_their_bones_ammo_multiplier(self)
end)

if WeaponAmmo then
	Hooks:PostHook(WeaponAmmo, "replenish", "hh_claim_their_bones_weapon_ammo_multiplier", function(self)
		apply_claim_their_bones_ammo_multiplier(self)
	end)
end
