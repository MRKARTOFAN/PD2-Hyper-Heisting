local function fray_screenshake_multiplier()
	return tonumber(PD2FRAY and PD2FRAY:GetSetting("screenshakemult", 1)) or 1
end

PlayerCamera._fray_play_shaker_original = PlayerCamera._fray_play_shaker_original or PlayerCamera.play_shaker
local play_shaker_original = PlayerCamera._fray_play_shaker_original
function PlayerCamera:play_shaker(effect, amplitude, ...)
	return play_shaker_original(self, effect, (amplitude or 1) * fray_screenshake_multiplier(), ...)
end

PlayerCamera._fray_set_shaker_parameter_original = PlayerCamera._fray_set_shaker_parameter_original or PlayerCamera.set_shaker_parameter
local set_shaker_parameter_original = PlayerCamera._fray_set_shaker_parameter_original
function PlayerCamera:set_shaker_parameter(effect, parameter, value)
	if parameter == "amplitude" then
		value = value * fray_screenshake_multiplier()
	end

	return set_shaker_parameter_original(self, effect, parameter, value)
end
