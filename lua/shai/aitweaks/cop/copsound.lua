-- Make CopSound return accurate speaking times
local FRAYCustomVoiceMap = {
	c01 = "contact",
	c01x = "contact",
	g90 = "contact",
	i01 = "contact",
	att = "contact",
	a08 = "contact",
	pus = "contact",
	mov = "contact",
	t01 = "contact",
	rdy = "contact",
	r01 = "contact",
	prm = "contact",
	pos = "contact",
	d01 = "contact",
	d02 = "contact",
	spawn = "contact",
	gr1a = "contact",
	gr1b = "contact",
	gr1c = "contact",
	gr1d = "contact",
	gr2a = "contact",
	gr2b = "contact",
	gr2c = "contact",
	gr2d = "contact",
	i03 = "kill",
	cloaker_taunt_after_assault = "kill",
	cloaker_taunt_during_assault = "kill",
	cpa_taunt_after_assault = "kill",
	cpa_taunt_during_assault = "kill",
	post_kill_taunt = "kill",
	lk3a = "buddy_died",
	lk3b = "buddy_died",
	med = "buddy_died",
	amm = "buddy_died",
	hlp = "buddy_died",
	x02a_any_3p = "death",
	x02a_any_3p_01 = "death",
	x02a_any_3p_02 = "death",
	clk_x02a_any_3p = "death",
	tsr_x02a_any_3p = "death"
}

local function HHStopCustomVoice(self)
	if self._hh_custom_voice and not self._hh_custom_voice:is_closed() then
		self._hh_custom_voice:stop()
		self._hh_custom_voice:close()
	end

	self._hh_custom_voice = nil
end

local function FRAYPlayCustomVoice(self, sound_name, important)
	local base_ext = self._unit:base()
	local char_tweak = base_ext and base_ext:char_tweak()
	local custom_voicework = char_tweak and char_tweak.custom_voicework
	local line_type = custom_voicework and FRAYCustomVoiceMap[sound_name]

	if not line_type then
		return false
	end

	local voicework = _G.voiceline_framework and _G.voiceline_framework.BufferedSounds[custom_voicework]
	local lines = voicework and voicework[line_type]

	if not lines or #lines == 0 then
		return false
	end

	if self._last_speech then
		self._last_speech:stop()
		self._last_speech = nil
	end

	local t = TimerManager:game():time()
	if self._hh_custom_voice and not self._hh_custom_voice:is_closed() then
		if self._speak_expire_t and self._speak_expire_t > t and not important then
			return true
		end

		HHStopCustomVoice(self)
	end

	local buffer = lines[math.random(#lines)]
	self._hh_custom_voice = XAudio.UnitSource:new(self._unit, buffer)
	self._speak_expire_t = t + buffer:get_length()

	return true
end

Hooks:PreHook(CopSound, "init", "sh_init", function (self)
	self._speak_done_callback = function ()
		self._speak_expire_t = 0
	end
end)

Hooks:OverrideFunction(CopSound, "say", function (self, sound_name, sync, skip_prefix, important)
	if FRAYPlayCustomVoice(self, sound_name, important) then
		return
	end

	if self._last_speech then
		self._last_speech:stop()
	end

	local event_id = nil
	local full_sound = skip_prefix and sound_name or self._prefix .. sound_name
	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)
		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id, nil, self._speak_done_callback)
	self._speak_expire_t = self._last_speech and TimerManager:game():time() + 10 or 0
end)
