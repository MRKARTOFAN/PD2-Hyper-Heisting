Hooks:PostHook(NavigationManager, "_load_nav_data", "fray__load_nav_data", function(self)
	setmetatable(self._nav_segments, {
		__index = function(navSegments, navSegmentId)
			return type(navSegmentId) == "number" and rawget(navSegments, tostring(navSegmentId)) or nil
		end
	})
end)
