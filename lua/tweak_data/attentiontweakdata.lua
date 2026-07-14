local function hh_patch_attention(settings, setting_id, values)
	local setting = settings[setting_id]

	if not setting then
		return
	end

	for key, value in pairs(values) do
		setting[key] = value
	end
end

local hh_player_attention_patches = {
	pl_mask_on_foe_combatant_whisper_mode_stand = {
		max_range = 4000,
		notice_interval = 0.1,
		notice_delay_mul = 0.5,
		uncover_range = 100,
		verification_interval = 0.1,
		release_delay = 0.35
	},
	pl_mask_on_foe_non_combatant_whisper_mode_stand = {
		uncover_range = 100,
		notice_interval = 0.1,
		notice_delay_mul = 0.5,
		verification_interval = 0.1,
		release_delay = 0.35
	},
	pl_mask_on_foe_non_combatant_whisper_mode_crouch = {
		range_mul = 0.65,
		notice_interval = 0.1,
		notice_delay_mul = 1,
		uncover_range = 100,
		verification_interval = 0.1,
		release_delay = 0.35
	},
	pl_mask_on_foe_combatant_whisper_mode_crouch = {
		max_range = 4000,
		range_mul = 0.65,
		notice_interval = 0.1,
		notice_delay_mul = 1,
		uncover_range = 100,
		verification_interval = 0.1,
		release_delay = 0.35
	},
	pl_foe_combatant_cbt_crouch = {
		uncover_range = 500,
		notice_interval = 0.1,
		notice_delay_mul = 0.5,
		release_delay = 0.35,
		verification_interval = 0.1
	},
	pl_foe_combatant_cbt_stand = {
		notice_interval = 0.1,
		notice_delay_mul = 0.5,
		uncover_range = 500,
		verification_interval = 0.5,
		release_delay = 0.35
	}
}

local hh_prop_reaction_patches = {
	"prop_civ_ene_ntl", "prop_ene_ntl_edaycrate", "prop_ene_ntl",
	"broken_cam_ene_ntl", "no_staff_ene_ntl", "timelock_ene_ntl",
	"open_security_gate_ene_ntl", "open_vault_ene_ntl", "open_elevator_ene_ntl"
}

Hooks:PostHook(AttentionTweakData, "_init_player", "hh_attention_player_vanilla_first", function(self)
	for setting_id, values in pairs(hh_player_attention_patches) do
		hh_patch_attention(self.settings, setting_id, values)
	end
end)

Hooks:PostHook(AttentionTweakData, "_init_team_AI", "hh_attention_team_ai_vanilla_first", function(self)
	hh_patch_attention(self.settings, "team_enemy_cbt", {
		verification_interval = 1,
		weight_mul = 0.75
	})
end)

Hooks:PostHook(AttentionTweakData, "_init_custom", "hh_attention_custom_vanilla_first", function(self)
	hh_patch_attention(self.settings, "custom_enemy_suburbia_shootout", {
		reaction = "REACT_COMBAT",
		weight_mul = 1,
		verification_interval = 1
	})
end)

Hooks:PostHook(AttentionTweakData, "_init_sentry_gun", "hh_attention_sentry_vanilla_first", function(self)
	hh_patch_attention(self.settings, "sentry_gun_enemy_cbt_hacked", {
		weight_mul = 1.25,
		verification_interval = 1
	})
end)

Hooks:PostHook(AttentionTweakData, "_init_prop", "hh_attention_prop_vanilla_first", function(self)
	for _, setting_id in ipairs(hh_prop_reaction_patches) do
		hh_patch_attention(self.settings, setting_id, {
			reaction = "REACT_SCARED"
		})
	end
end)
