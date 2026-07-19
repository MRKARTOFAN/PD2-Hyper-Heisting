AmmoClip = AmmoClip or class(Pickup)
AmmoClip.EVENT_IDS = {
	bonnie_share_ammo = 1,
	register_grenade = 16
}
local GAMBLER_EVENT_START = 2
local GAMBLER_EVENT_END = 13
local GAMBLER_TEAM_STRENGTHS = {0.5, 1, 1.5}
local CABLE_TIE_GET_CHANCE = 0.35
local CABLE_TIE_GET_AMOUNT = 1

local function apply_gambler_bonus(unit, bonus, multiplier)
	local damage_ext = unit:character_damage()

	if bonus.name == "health" then
		if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
			damage_ext:restore_health(bonus.amount * multiplier, true)
		end
	elseif bonus.name == "armor" then
		damage_ext:restore_armor(bonus.amount * multiplier)
	elseif bonus.name == "stamina" then
		unit:movement():add_stamina(bonus.amount * multiplier)
	elseif bonus.name == "dodge" then
		damage_ext:add_temporary_dodge(bonus.amount * multiplier, tweak_data.upgrades.hh_gambler_dodge_duration)
	end
end

local function gambler_event_id(bonus_index, multiplier)
	local strength_index = math.round(multiplier * 2)

	return GAMBLER_EVENT_START + (bonus_index - 1) * #GAMBLER_TEAM_STRENGTHS + strength_index - 1
end

local function gambler_event_data(event)
	local event_index = event - GAMBLER_EVENT_START
	local bonus_index = math.floor(event_index / #GAMBLER_TEAM_STRENGTHS) + 1
	local strength_index = event_index % #GAMBLER_TEAM_STRENGTHS + 1

	return bonus_index, GAMBLER_TEAM_STRENGTHS[strength_index]
end

local function play_gambler_sound(ammo_clip, unit)
	if not ammo_clip._hh_gambler_sound_played then
		ammo_clip._hh_gambler_sound_played = true
		unit:sound():play("pickup_ammo_health_boost", nil, true)
	end
end

local function trigger_gambler(ammo_clip, unit, player_manager)
	local bonuses = tweak_data.upgrades.hh_gambler_bonuses
	local multiplier = player_manager:has_category_upgrade("player", "hh_gambler_double") and 2 or 1
	local rolls = {}
	local bonus_index = math.random(#bonuses)

	rolls[bonus_index] = multiplier

	if player_manager:has_category_upgrade("player", "hh_gambler_second") then
		bonus_index = math.random(#bonuses)
		rolls[bonus_index] = (rolls[bonus_index] or 0) + multiplier * 0.5
	end

	for index, bonus in ipairs(bonuses) do
		local bonus_multiplier = rolls[index]

		if bonus_multiplier then
			apply_gambler_bonus(unit, bonus, bonus_multiplier)

			if player_manager:has_category_upgrade("player", "hh_gambler_share") then
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", ammo_clip._unit, "pickup", gambler_event_id(index, bonus_multiplier * 0.5))
			end
		end
	end

	play_gambler_sound(ammo_clip, unit)
end

function AmmoClip:_pickup(unit)
	if self._picked_up then
		return
	end

	local player_manager = managers.player
	local inventory = unit:inventory()

	if not unit:character_damage():dead() and inventory then
		local picked_up = false

		if self._projectile_id then
			if managers.blackmarket:equipped_projectile() == self._projectile_id and not player_manager:got_max_grenades() then
				player_manager:add_grenade_amount(self._ammo_count or 1)

				picked_up = true
			end
		else
			local available_selections = {}

			for i, weapon in pairs(inventory:available_selections()) do
				if inventory:is_equipped(i) then
					table.insert(available_selections, 1, weapon)
				else
					table.insert(available_selections, weapon)
				end
			end

			local success, add_amount = nil

			for _, weapon in ipairs(available_selections) do
				if not self._weapon_category or self._weapon_category == weapon.unit:base():weapon_tweak_data().categories[1] then
					success, add_amount = weapon.unit:base():add_ammo(1, self._ammo_count)
					picked_up = success or picked_up

					if self._ammo_count then
						self._ammo_count = math.max(math.floor(self._ammo_count - add_amount), 0)
					end

					if picked_up and tweak_data.achievement.pickup_sticks and self._weapon_category == tweak_data.achievement.pickup_sticks.weapon_category then
						managers.achievment:award_progress(tweak_data.achievement.pickup_sticks.stat)
					end
				end
			end
			
			if picked_up and managers.blackmarket:equipped_grenade() then
				local id = managers.blackmarket:equipped_grenade()
				
				if id then
					local chance = tweak_data:get_raw_value("blackmarket", "projectiles", id, "pickup_chance") or -1
					--log("chance is " .. tostring(chance) .. "")
					if player_manager:has_category_upgrade("player", "blood_boom") then
						chance = chance * 2
					end
					
					if not player_manager:got_max_grenades() and math.random() <= chance then
						managers.player:add_grenade_amount(1)
					end
				end
			end
			
		end

		if picked_up then
			self._picked_up = true	
			
			local rand = math.random()

			if rand <= CABLE_TIE_GET_CHANCE and self._ammo_box then
				managers.player:add_cable_ties(CABLE_TIE_GET_AMOUNT)
			end
			
			if not self._projectile_id and not self._weapon_category then
				if not unit:character_damage():is_downed() and player_manager:has_category_upgrade("temporary", "hh_gambler_bonus") and not player_manager:has_activate_temporary_upgrade("temporary", "hh_gambler_bonus") then
					player_manager:activate_temporary_upgrade("temporary", "hh_gambler_bonus")
					trigger_gambler(self, unit, player_manager)
				end

				if player_manager:has_category_upgrade("temporary", "loose_ammo_give_team") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_give_team") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_give_team")
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.bonnie_share_ammo)
				end
			elseif self._projectile_id then
				player_manager:register_grenade(managers.network:session():local_peer():id())
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.register_grenade)
			end

			if Network:is_client() then
				managers.network:session():send_to_host("sync_pickup", self._unit)
			end

			unit:sound():play(self._pickup_event or "pickup_ammo", nil, true)
			self:consume()

			if self._ammo_box then
				player_manager:send_message(Message.OnAmmoPickup, nil, unit)
			end

			return true
		end
	end

	return false
end

local hh_sync_net_event = AmmoClip.sync_net_event

function AmmoClip:sync_net_event(event, peer)
	if event == AmmoClip.EVENT_IDS.register_grenade then
		return hh_sync_net_event(self, event, peer)
	end

	local player = managers.player:local_player()

	if not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if event == AmmoClip.EVENT_IDS.bonnie_share_ammo then
		local inventory = player:inventory()

		if inventory then
			local picked_up = false

			for _, weapon in pairs(inventory:available_selections()) do
				picked_up = weapon.unit:base():add_ammo(tweak_data.upgrades.loose_ammo_give_team_ratio) or picked_up
			end

			if picked_up then
				player:sound():play(self._pickup_event or "pickup_ammo", nil, true)

				for id, weapon in pairs(inventory:available_selections()) do
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	elseif GAMBLER_EVENT_START <= event and event <= GAMBLER_EVENT_END then
		local bonus_index, multiplier = gambler_event_data(event)
		local bonus = tweak_data.upgrades.hh_gambler_bonuses[bonus_index]

		apply_gambler_bonus(player, bonus, multiplier)
		play_gambler_sound(self, player)
	end
end
