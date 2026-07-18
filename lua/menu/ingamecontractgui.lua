local function find_child(parent, name)
	local object = parent:child(name)
	if object then
		return object
	end

	for _, child in ipairs(parent:children()) do
		if child.children then
			object = find_child(child, name)
			if object then
				return object
			end
		end
	end
end

Hooks:PostHook(IngameContractGui, "init", "hh_fray_ingame_contract_description", function(self)
	if not Global.game_settings or not Global.game_settings.one_down then
		return
	end

	local title = find_child(self._panel, "one_down_warning_text")
	local text_panel = title and title:parent()
	local modifiers = text_panel and text_panel:child("modifiers_text")

	if not title or not text_panel or not modifiers then
		return
	end

	local modifier_top = modifiers:top()
	local upper_bottom = 0
	for _, child in ipairs(text_panel:children()) do
		if child == modifiers then
			break
		end

		upper_bottom = math.max(upper_bottom, child:bottom())
	end

	local font_size = tweak_data.menu.pd2_small_font_size - 3
	local layout_top = text_panel:h() * 0.4 - font_size - modifiers:h()
	local layout_move_y = math.max(layout_top, upper_bottom + 5) - modifier_top
	for _, child in ipairs(text_panel:children()) do
		if child:top() >= modifier_top or child:name() == "rewards_panel" then
			child:move(0, layout_move_y)
		end
	end

	local description = text_panel:text({
		name = "hh_fray_warning_text",
		vertical = "top",
		h = 128,
		w = text_panel:w() - 10,
		word_wrap = true,
		wrap = true,
		align = "left",
		blend_mode = "normal",
		text = self:get_text("menu_fray_warning"),
		font = tweak_data.menu.pd2_small_font,
		font_size = font_size,
		color = tweak_data.screen_colors.one_down
	})

	managers.hud:make_fine_text(description)
	description:set_left(10)
	description:set_top(title:bottom())

	local anchor = title:bottom()
	for _, child in ipairs(text_panel:children()) do
		if child ~= title and child ~= description and (child:top() >= anchor or child:name() == "rewards_panel") then
			child:move(0, description:h())
		end
	end
end)
