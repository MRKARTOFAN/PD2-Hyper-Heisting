_G.PD2FRAY = PD2FRAY or {}

PD2FRAY._mod_path = ModPath
PD2FRAY._options_path = ModPath .. "menu/options.txt"
PD2FRAY._save_path = SavePath .. "fray_settings.txt"
PD2FRAY._enemy_asset_mod_names = {
	["Hyper ZEAL"] = true,
	["Hyper ZEAL Punks and Ninjas"] = true,
	["Resmod ZEAL"] = true
}

function PD2FRAY:IsEnemyAssetModEnabled(name)
	if not self._enemy_asset_mod_names[name] or not BLT or not BLT.Mods then
		return false
	end

	local enemy_asset_mod = BLT.Mods:GetModByName(name)
	return enemy_asset_mod and enemy_asset_mod:IsEnabled() or false
end

PD2FRAY.settings = {
	toggle_hhassault = false,
	toggle_hhskulldiff = false,
	toggle_suppression = true,
	toggle_health_effect = true,
	toggle_blurzonereduction = true,
	toggle_noweirddof = false,
	screenshakemult = 1,
	first_launch = true
}

PD2FRAY.session_settings = {}

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

	if file then
		local contents = file:read("*all")
		file:close()

		local success, settings = pcall(json.decode, contents)
		if not success or type(settings) ~= "table" then
			return
		end

		for k, v in pairs(settings) do
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
