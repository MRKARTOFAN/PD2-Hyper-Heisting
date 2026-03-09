function CriminalActionWalk:init(...)
	return CriminalActionWalk.super.init(self, ...)
end

function CriminalActionWalk:_get_max_walk_speed(...)
	return CriminalActionWalk.super._get_max_walk_speed(self, ...)
end

-- (SHAI) Always pass "fwd" direction to super: without this bots passed variadic args through (possibly nil), causing them to look up the wrong speed category and move too slowly.
function CriminalActionWalk:_get_current_max_walk_speed(...)
	return CriminalActionWalk.super._get_current_max_walk_speed(self, "fwd")
end