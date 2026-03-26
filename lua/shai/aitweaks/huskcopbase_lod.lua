-- Enable invisible LOD state for networked enemy units
-- Without this, the LOD visibility system cannot fully hide distant husk cops
-- REAI source: huskcopbase.lua (decompiled)
Hooks:PostHook(HuskCopBase, "post_init", "shai_husk_allow_invisible", function(self)
	self._allow_invisible = true
end)
