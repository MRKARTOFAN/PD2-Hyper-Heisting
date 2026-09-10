Hooks:PreHook(GroupAIStateBase, "add_special_objective", "fray_drill_sabotage_SO", function(self, id, objective_data)
	if type(id) ~= "string" or not id:match("^drill_sabotage") then
		return
	end

	objective_data.interval = 60
	objective_data.base_chance = 0.25
	objective_data.chance_inc = 0
	objective_data.search_dis_sq = nil
	objective_data.search_pos = nil
	objective_data.access = managers.navigation:convert_access_filter_to_number({
		"gangster",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"spooc",
		"tank",
		"taser"
	})
	objective_data.objective.interrupt_dis = nil
	objective_data.objective.interrupt_health = nil
	objective_data.objective.followup_objective = nil
end)

Hooks:PostHook(Drill, "on_sabotage_SO_administered", "fray_drill_sabotage_dialog", function(self)
	if math.random() < 0.2 then
		managers.dialog:queue_narrator_dialog("dd_01", {})
	end
end)
