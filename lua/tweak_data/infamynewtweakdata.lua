-- Fuck off infamy skill cost reduction
Hooks:PostHook(InfamyTweakData, "init", "hh_init", function(self)
	self.items.infamy_root.upgrades.skilltree.multiplier = 1
end)