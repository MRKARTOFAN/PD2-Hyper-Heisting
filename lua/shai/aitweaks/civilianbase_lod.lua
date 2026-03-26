-- Enable invisible LOD state for civilian units
-- Allows the LOD system to fully hide distant civilians for performance
-- REAI source: civilianbase.lua (decompiled)
Hooks:PostHook(CivilianBase, "post_init", "shai_civ_allow_invisible", function(self)
	self._allow_invisible = true
end)
