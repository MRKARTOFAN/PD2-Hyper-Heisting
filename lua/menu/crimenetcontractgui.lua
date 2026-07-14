local function fray_enabled(value)
	return value == true or value == 1 or value == "on"
end

local function update_fray_warning(self, enabled)
	local data = self._hh_fray_warning
	if not data then
		return
	end

	local desired_offset = enabled and data.title:h() + data.description:h() or 0
	local move_y = desired_offset - data.current_offset

	if move_y ~= 0 then
		for _, child in ipairs(data.shifted_children) do
			child:move(0, move_y)
		end
		data.current_offset = desired_offset
	end

	data.title:set_visible(enabled)
	data.description:set_visible(enabled)
	if enabled then
		data.modifiers:show()
	end
end

Hooks:PostHook(CrimeNetContractGui, "init", "hh_fray_contract_description", function(self)
	local panel = self._contract_panel
	local node_data = self._node and self._node:parameters().menu_component_data
	local modifiers = panel and panel:child("modifiers_text")
	if not modifiers or not node_data or not node_data.job_id then
		return
	end

	local active = fray_enabled(node_data.one_down)
	local title = panel:child("one_down_warning_text")
	local title_existed = title ~= nil
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local text_width = tweak_data.gui.crime_net.contract_gui.text_width
	local font = tweak_data.menu.pd2_small_font
	local font_size = tweak_data.menu.pd2_small_font_size * 0.875

	if not title then
		title = panel:text({
			name = "one_down_warning_text",
			text = managers.localization:to_upper_text("menu_one_down"),
			font = font,
			font_size = font_size,
			color = tweak_data.screen_colors.one_down
		})
		self:make_fine_text(title)
		title:set_top(modifiers:bottom())
		title:set_left(padding * 2)
	end

	local description = panel:text({
		name = "hh_fray_warning_text",
		vertical = "top",
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "normal",
		text = managers.localization:to_upper_text("menu_fray_warning"),
		font = font,
		font_size = font_size,
		color = tweak_data.screen_colors.one_down,
		w = text_width
	})

	self:make_fine_text(description)
	description:set_left(padding * 2)
	description:set_top(title:bottom())

	local anchor = modifiers:bottom()
	local shifted_children = {}
	for _, child in ipairs(panel:children()) do
		if child ~= title and child ~= description and child:top() >= anchor then
			table.insert(shifted_children, child)
		end
	end

	self._hh_fray_warning = {
		modifiers = modifiers,
		title = title,
		description = description,
		shifted_children = shifted_children,
		current_offset = title_existed and active and title:h() or 0
	}

	update_fray_warning(self, active)
end)

Hooks:PostHook(CrimeNetContractGui, "set_one_down", "hh_fray_contract_description_toggle", function(self, one_down)
	update_fray_warning(self, fray_enabled(one_down))
end)
