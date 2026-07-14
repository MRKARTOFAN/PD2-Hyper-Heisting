_G.PD2FRAY = PD2FRAY or {}

PD2FRAY.a = math.random() < 0.001

PD2FRAY._mod_path = ModPath
PD2FRAY._options_path = ModPath .. "menu/options.txt"
PD2FRAY._save_path = SavePath .. "fray_settings.txt"
PD2FRAY.settings = {
	toggle_overhaul_player = true,
	toggle_hhassault = false,
	toggle_hhskulldiff = false,
	toggle_suppression = true,
	toggle_health_effect = true,
	toggle_blurzonereduction = true,
	toggle_noweirddof = false,
	first_launch = true
}

PD2FRAY.session_settings = {} --leave empty; generated on load
PD2FRAY.show_popup = nil

function PD2FRAY:ChangeSetting(setting_name,value,apply_immediately)
	self.settings[setting_name] = value
	if apply_immediately then 
		self.session_settings[setting_name] = value
	end
end

function PD2FRAY:IsOverhaulEnabled()
	return true
end

function PD2FRAY:SkullDiffEnabled()
	return self:GetSessionSetting("toggle_hhskulldiff")
end

function PD2FRAY:DofEnabled()
	return self:GetSessionSetting("toggle_noweirddof")
end

function PD2FRAY:BlurzoneEnabled()
	return self:GetSessionSetting("toggle_blurzonereduction")
end

function PD2FRAY:SupEnabled()
	return self:GetSessionSetting("toggle_suppression")
end

function PD2FRAY:IsFlavorAssaultEnabled()
	return self:GetSessionSetting("toggle_hhassault")
end

function PD2FRAY:GetSessionSetting(setting_name,fallback_value)
	if self.session_settings[setting_name] == nil then 
		return fallback_value
	else
		return self.session_settings[setting_name]
	end
end

function PD2FRAY:GetSetting(setting_name,fallback_value)
	if self.settings[tostring(setting_name)] == nil then 
		return fallback_value
	else
		return self.settings[tostring(setting_name)]
	end
end

function PD2FRAY:LoadSettings()
	local file = io.open(self._save_path, "r")
	
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
			self.session_settings[k] = v
		end
	end
end

function PD2FRAY:SaveSettings(apply_immediately)
	local file = io.open(self._save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
	if apply_immediately then 
		for k,v in pairs(self.settings) do 
			self.session_settings[k] = v
		end
	end
end


PD2FRAY:LoadSettings()

if PD2FRAY.settings.first_launch then
	PD2FRAY.settings.first_launch = false
	PD2FRAY:SaveSettings(true)
end

--this file is the only time that settings should be loaded from the mod save file;
--any changes will not take place until Lua is reloaded (eg. load into new mission or on restart),
--UNLESS specifically requesting current setting:
--	PD2FRAY:GetSetting("setting_name_example")
--or if saving to apply immediately:
--	PD2FRAY:SaveSettings(true)
--	PD2FRAY:ChangeSetting("setting_name_example",12345,true)
--for anything that requires a restart, you should use 
--	PD2FRAY:GetSessionSetting("setting_name_example")

-- Voice Framework Setup
local C = blt_class()
VoicelineFramework = C
VoicelineFramework.BufferedSounds = {}

function C:register_unit(unit_name)
	--log("VF: Registering Unit, " .. unit_name)
	if _G.voiceline_framework then
		_G.voiceline_framework.BufferedSounds[unit_name] = {}
	end
end

function C:register_line_type(unit_name, line_type)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			--log("VF: Registering Type, " .. line_type .. " for Unit " .. unit_name)
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			fuck[line_type] = {}
		end
	end
end

function C:register_voiceline(unit_name, line_type, path)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			if fuck[line_type] then
				--log("VF: Registering Path, " .. path .. " for Unit " .. unit_name)
				table.insert(fuck[line_type], XAudio.Buffer:new(path))
			end
		end
	end
end

if not _G.voiceline_framework then
	blt.xaudio.setup()
	_G.voiceline_framework = VoicelineFramework:new()
end

Hooks:Add("NetworkReceivedData", "fray_receive_network_data", function(sender, message, data)

	if message == "fray_sync_post_assault_replenish" then
		local pm = managers.player
						
		if pm then
			if pm:player_unit() and alive(pm:player_unit()) then
				local player = pm:player_unit()
				local dmg_ext = player:character_damage()
				
				if not dmg_ext:dead() then
					if not dmg_ext:need_revive() then --if your team didnt revive you in the first place, go eat a medic bag
						dmg_ext:replenish() 
					end
				end
			end
		end
	end

	if managers and managers.groupai then	
		if message == "fray_sync_hud_assault_color" then 
			if sender == 1 then
				if data == "true" then
					managers.groupai:state()._activeassaultbreak = true
					managers.groupai:state():play_heat_bonus_dialog()
					managers.hud:show_heat_bonus_hints()
					
					local pm = managers.player
						
					if pm then
						if pm:player_unit() and alive(pm:player_unit()) then
							local player = pm:player_unit()
							local dmg_ext = player:character_damage()
							
							if not dmg_ext:dead() then
								if not dmg_ext:need_revive() and not dmg_ext:is_berserker() then
									dmg_ext:restore_health(0.5, nil, nil, true) --50% health restored on heat bonus
								end
								
								local inventory = player:inventory()
										
								if inventory then						
									for i, weapon in pairs(inventory:available_selections()) do
										weapon.unit:base():add_ratio_plus_ammo(0.5)
									end
								end
							end
						end
					end					
				elseif data == "nil" then 
				   managers.groupai:state()._activeassaultbreak = nil
				   managers.groupai:state()._said_heat_bonus_dialog = nil
				end
			end
		end
		
		if message == "fray_sync_speed_mul" then 
			if sender == 1 then
				if data then
					local number_data = tonumber(data)
					managers.groupai:state()._enemy_speed_mul = number_data
				end
			end
		end
	end
end)
