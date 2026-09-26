-- Mission NPCs can use crew IDs even though their damage requires NPC weapon data.
Hooks:PreHook(NPCRaycastWeaponBase, "init", "fray_npc_weapon_tweak", function(self)
	local name_id = self.name_id
	if name_id and name_id:match("_crew$") then
		local npc_name_id = name_id:gsub("_crew$", "_npc")
		if tweak_data.weapon[npc_name_id] then
			self.name_id = npc_name_id
		end
	end
end)
