-- Share animation freeze support to TeamAI and HuskTeamAI units
-- Allows these units to freeze animations when distant, saving performance
-- REAI source: teamaibase.lua, huskteamaibase.lua (decompiled)
TeamAIBase.chk_freeze_anims = CopBase.chk_freeze_anims

Hooks:PostHook(HuskTeamAIBase, "post_init", "shai_husk_team_init", function(self)
	self._ext_movement = self._unit:movement()
end)
HuskTeamAIBase.chk_freeze_anims = CopBase.chk_freeze_anims
