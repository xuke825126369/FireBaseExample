SettingHandler = {}
SettingHandler.dbName = "local_setting_db"

function SettingHandler:Init()
    self.data = LocalDbHandler.data.mSettingHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function SettingHandler:SaveDb()
    LocalDbHandler.data.mSettingHandlerData = self.data
    LocalDbHandler:SaveDb()
end

function SettingHandler:GetDbInitData()
    local data = {}
    -- 1: 中文 2: 英语
    data.nLanguageType = 2
    data.bSoundOn = true
    return data
end

function SettingHandler:isMute()
    return not self.data.bSoundOn
end

function SettingHandler:setMute(isMute)
    self.data.bSoundOn = not isMute
    self:SaveDb()
    EventHandler:Brocast("onSoundSettingChanged")
end





