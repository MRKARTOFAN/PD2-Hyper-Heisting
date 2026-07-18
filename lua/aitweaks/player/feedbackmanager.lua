local function fray_screenshake_multiplier()
	return tonumber(PD2FRAY and PD2FRAY:GetSetting("screenshakemult", 1)) or 1
end

FeedBackCameraShake._fray_set_param_original = FeedBackCameraShake._fray_set_param_original or FeedBackCameraShake.set_param
local set_param_original = FeedBackCameraShake._fray_set_param_original
function FeedBackCameraShake:set_param(name, value)
	if name == "amplitude" then
		value = value * fray_screenshake_multiplier()
	end

	return set_param_original(self, name, value)
end
