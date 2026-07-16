Hooks:PostHook(BlackMarketTweakData, "_init_melee_weapons", "_init_melee_weapons", function(self, tweak_data)
	for id, data in pairs(self.melee_weapons) do
		data.melee_charge_shaker = "" -- Hacky way to disable the shaker effect while charging a melee weapon
		-- [Karto] Thanks for the inspiration, Hitscanner.
	end
end)
