core:import("CoreElementArea")
local ElementAreaReportTrigger = CoreElementArea.ElementAreaReportTrigger

local tmp_vec1 = Vector3()

local t_cont = table.contains
local t_del = table.delete

local fall_dmg_event_names = {
	trigger_area_report_001 = true,
	trigger_area_report_002 = true,
	trigger_area_report_003 = true
}

function ElementAreaReportTrigger:init(...)
	ElementAreaReportTrigger.super.init(self, ...)

	if Network:is_client() and Global.game_settings.level_id == "nail" and fall_dmg_event_names[self._editor_name] then
		self._toggle_fall_dmg_on_local_player = true
	end
end

function ElementAreaReportTrigger:_client_check_state(unit)
	local rule_ok = self:_check_instigator_rules(unit)
	local inside = nil

	if unit:movement() then
		inside = self:_is_inside(unit:movement():m_pos())
	else
		unit:m_position(tmp_vec1)

		inside = self:_is_inside(tmp_vec1)
	end

	if inside and not rule_ok and self:_has_on_executed_alternative("rule_failed") then
		managers.network:session():send_to_host("to_server_area_event", 4, self._id, unit)
		self:_chk_local_client_execute(unit, "rule_failed")
	end

	if t_cont(self._inside, unit) then
		if inside and rule_ok then
			if self:_has_on_executed_alternative("while_inside") then
				managers.network:session():send_to_host("to_server_area_event", 3, self._id, unit)
				self:_chk_local_client_execute(unit, "while_inside")
			end
		else
			t_del(self._inside, unit)
			managers.network:session():send_to_host("to_server_area_event", 2, self._id, unit)
			self:_chk_local_client_execute(unit, "leave")

			if self._toggle_fall_dmg_on_local_player then
				local base_ext = unit:base()

				if base_ext and base_ext.is_local_player then
					unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", false)
				end
			end
		end
	elseif inside and rule_ok then
		self._inside[#self._inside + 1] = unit
		managers.network:session():send_to_host("to_server_area_event", 1, self._id, unit)

		local alternative = self:_has_on_executed_alternative("while_inside") and "while_inside" or "enter"

		self:_chk_local_client_execute(unit, alternative)

		if self._toggle_fall_dmg_on_local_player then
			local base_ext = unit:base()

			if base_ext and base_ext.is_local_player then
				unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", true)
			end
		end
	end
end
