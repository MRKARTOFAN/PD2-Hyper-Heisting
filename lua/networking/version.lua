if not Distribution then
	return
end

Hooks:PostHook(_G, "pd2_version", "fray_pd2_version", function()
	return Hooks:GetReturn() .. "PD2FRAY"
end)
