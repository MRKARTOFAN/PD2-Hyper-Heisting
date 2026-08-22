Hooks:OverrideFunction(MutatorsManager, "init", function(self)
	managers.mutators = self
	self._message_system = MessageSystem:new()
	self._lobby_delay = -1

	Global.mutators = Global.mutators or {
		mutator_values = {},
		active_on_load = {}
	}
	Global.mutators.active_on_load = {}

	self._mutators = {}
	self._active_mutators = {}
end)
