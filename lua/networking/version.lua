local frayVersion = ModInstance:GetVersion()

Hooks:PostHook(_G, "pd2_version", "fray_pd2_version", function()
	return Hooks:GetReturn() .. "_fray_v" .. frayVersion
end)
