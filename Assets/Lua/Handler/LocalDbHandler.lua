LocalDbHandler = {}
LocalDbHandler.dbName = "LocalDbHandler"

function LocalDbHandler:Init()
    if Unity.PlayerPrefs.HasKey(self.dbName) then
		local dbString = Unity.PlayerPrefs.GetString(self.dbName)
        dbString = CS.DbParser.Decode(dbString)
        self.data = rapidjson.decode(dbString)
    else
        self.data = self:GetDbInitData()
        self:SaveDb()
    end 

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb() 

    VipHandler:Init()
    AdsConfigHandler:Init()
    SettingHandler:Init()
        
    ThemeConfigModifyHandler:Init()
    ThemeAllDataHandler:Init()
    ThemeUnLockHandler:Init()
end

function LocalDbHandler:SaveDb()
    local dbString = rapidjson.encode(self.data)
    dbString = CS.DbParser.Encode(dbString)
    Unity.PlayerPrefs.SetString(self.dbName, dbString)
	Unity.PlayerPrefs.Save()
end

function LocalDbHandler:GetDbInitData()
    local data = {}
    data.mSettingHandlerData = {}
    data.mInBoxHandlerData = {}
    data.mThemeUnLockHandlerData = {}
    data.mThemeUpgradeFeatureHandlerData = {}
    data.mThemeAllDataHandlerData = {}
    data.mThemeReturnRateDyncmaicConfig1HandlerData = {}
    data.mThemeReturnRateDyncmaicConfig2HandlerData = {}
    data.mThemeReturnRateDyncmaicConfig3HandlerData = {}
    data.mFlashSaleHandlerData = {}
    return data
end
