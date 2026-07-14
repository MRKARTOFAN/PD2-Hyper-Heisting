local hitDirection = Vector3()
local shieldSlotMask = World:make_slot_mask(8)
local criminalNames = table.list_to_set(CriminalsManager.character_names())

Hooks:OverrideFunction(ExplosionManager, "_damage_characters", function(self, detectResults, params, variant, damageFuncName)
	local userUnit = params.user
	local owner = params.owner
	local damage = params.damage
	local hitPosition = params.hit_pos
	local colRay = params.col_ray
	local range = params.range
	local curvePower = params.curve_pow
	local verifyCallback = params.verify_callback
	local igniteCharacter = params.ignite_character

	damageFuncName = damageFuncName or "damage_explosion"

	local counts = {
		cops = {
			kills = 0,
			hits = 0
		},
		gangsters = {
			kills = 0,
			hits = 0
		},
		civilians = {
			kills = 0,
			hits = 0
		},
		criminals = {
			kills = 0,
			hits = 0
		}
	}

	local function GetFirstBodyHit(bodiesHit)
		for _, hitBody in ipairs(bodiesHit or {}) do
			if alive(hitBody) then
				return hitBody
			end
		end
	end

	local charactersHit = {}

	for key, unit in pairs(detectResults.characters_hit) do
		table.insert(charactersHit, {
			key = key,
			unit = unit
		})
	end

	table.sort(charactersHit, function(a, b)
		local baseA = a.unit:base()
		local baseB = b.unit:base()

		if not baseA or not baseB then
			return false
		end

		local priorityA = baseA._char_tweak and baseA._char_tweak.target_priority or 0
		local priorityB = baseB._char_tweak and baseB._char_tweak.target_priority or 0

		return priorityA > priorityB
	end)

	local doSelfDamage = not alive(userUnit) or not userUnit:base() or not userUnit:base()._tweak_table

	for _, data in pairs(charactersHit) do
		local unit = data.unit
		local key = data.key
		local hitBody = GetFirstBodyHit(detectResults.bodies_hit[key])
		local hitBodyPosition = hitBody and hitBody:center_of_mass() or alive(unit) and unit:position()
		local distance = mvector3.direction(hitDirection, hitPosition, hitBodyPosition)
		local canDamage = (doSelfDamage or userUnit ~= unit) and (not verifyCallback or verifyCallback(unit))

		if alive(unit) and canDamage and unit:character_damage()[damageFuncName] then
			local actionData = {
				attacker_unit = userUnit,
				col_ray = colRay or {
					position = hitBodyPosition,
					ray = hitDirection
				},
				ignite_character = igniteCharacter,
				variant = variant or "explosion",
				weapon_unit = owner
			}

			if damage > 0 then
				actionData.damage = math.max(damage * math.clamp(1 - distance / range, 0, 1) ^ curvePower, 1)

				local shieldBlock = World:raycast("ray", hitPosition, hitBodyPosition, "slot_mask", shieldSlotMask)
				local shieldUnit = shieldBlock and shieldBlock.unit

				if alive(shieldUnit) and alive(shieldUnit:parent()) and mvector3.dot(shieldUnit:rotation():y(), hitDirection) < -0.5 then
					actionData.damage = actionData.damage * 0.5
				end
			else
				actionData.damage = 0
			end

			unit:character_damage()[damageFuncName](unit:character_damage(), actionData)
		end

		local tweakTable = alive(unit) and unit:base() and unit:base()._tweak_table

		if tweakTable then
			local count

			if criminalNames[CriminalsManager.convert_new_to_old_character_workname(tweakTable)] then
				count = counts.criminals
			elseif CopDamage.is_civilian(tweakTable) then
				count = counts.civilians
			elseif CopDamage.is_gangster(tweakTable) then
				count = counts.gangsters
			else
				count = counts.cops
			end

			count.hits = count.hits + 1

			if unit:character_damage():dead() then
				count.kills = count.kills + 1
			end
		end
	end

	return {
		count_cops = counts.cops.hits,
		count_gangsters = counts.gangsters.hits,
		count_civilians = counts.civilians.hits,
		count_criminals = counts.criminals.hits,
		count_cop_kills = counts.cops.kills,
		count_gangster_kills = counts.gangsters.kills,
		count_civilian_kills = counts.civilians.kills,
		count_criminal_kills = counts.criminals.kills
	}
end)
