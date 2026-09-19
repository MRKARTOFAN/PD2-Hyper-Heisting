Hooks:PreHook(CopSound, "init", "sh_init", function (self)
	self._speak_done_callback = function ()
		self._speak_expire_t = 0
	end
end)

Hooks:OverrideFunction(CopSound, "say", function (self, sound_name, sync, skip_prefix, important, callback)
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

	local doneCallback = self._speak_done_callback
	if callback then
		doneCallback = function(...)
			self._speak_done_callback(...)
			return callback(...)
		end
	end

	self._last_speech = self:_play(full_sound or event_id, nil, doneCallback)
	self._speak_expire_t = self._last_speech and TimerManager:game():time() + 10 or 0
end)
