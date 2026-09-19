-- Tweak bag stealing conditions
function CarryData:clbk_pickup_SO_verification(unit)
	if not self._steal_SO_data or not self._steal_SO_data.SO_id then
		return false
	end

	if unit:movement():cool() then
		return false
	end

	if not unit:base():char_tweak().steal_loot then
		return false
	end

	local objective = unit:brain():objective()
	if not objective or objective.type == "free" or not objective.area then
		return true
	end

	if objective.grp_objective and objective.grp_objective.type == "reenforce_area" then
		return false
	end

	local nav_seg = unit:movement():nav_tracker():nav_segment()
	if objective.area == self._steal_SO_data.pickup_area or self._steal_SO_data.pickup_area.nav_segs[nav_seg] then
		return objective.area.nav_segs[nav_seg] or managers.groupai:state()._rescue_allowed
	end
end


-- Make enemies run with stolen bags instead of crouchwalking
Hooks:PostHook(CarryData, "_chk_register_steal_SO", "sh__chk_register_steal_SO", function (self)
	if self._steal_SO_data and self._steal_SO_data.pickup_objective and self._steal_SO_data.pickup_objective.followup_objective then
		self._steal_SO_data.pickup_objective.followup_objective.pose = "stand"
	end
end)

Hooks:PreHook(CarryData, "on_secure_SO_completed", "sh_on_secure_SO_completed", function(self, thief)
	local steal_data = self._steal_SO_data
	local movement = alive(thief) and thief:movement()
	local tracker = movement and movement:nav_tracker()
	local state = managers.groupai and managers.groupai:state()

	if not steal_data or thief ~= steal_data.thief or not tracker or not state then
		return
	end

	local area = state:get_area_from_nav_seg_id(tracker:nav_segment())
	if not area then
		return
	end

	self._loot_dropoff_area = area
	area.dropped_loot = area.dropped_loot or {}
	area.dropped_loot[self._unit:key()] = self._unit
	area.factors = area.factors or {}

	if not area.factors.force then
		state:set_area_min_police_force("loot_dropoff" .. tostring(area), 3, area.pos)
	end
end)

function CarryData:_remove_from_dropoff_area()
	local area = self._loot_dropoff_area
	if not area then
		return
	end

	self._loot_dropoff_area = nil
	if not area.dropped_loot then
		return
	end

	area.dropped_loot[self._unit:key()] = nil
	local state = managers.groupai and managers.groupai:state()
	if not next(area.dropped_loot) and state then
		state:set_area_min_police_force("loot_dropoff" .. tostring(area), nil)
	end
end

Hooks:PreHook(CarryData, "link_to", "sh_link_to", CarryData._remove_from_dropoff_area)
Hooks:PreHook(CarryData, CarryData.destroy and "destroy" or "pre_destroy", "sh_pre_destroy", CarryData._remove_from_dropoff_area)
