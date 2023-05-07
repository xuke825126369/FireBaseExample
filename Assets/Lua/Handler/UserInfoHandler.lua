UserInfoHandler = {}
UserInfoHandler.dbName = "web_db"

function UserInfoHandler:Init()
	if Unity.PlayerPrefs.HasKey(self.dbName) then
		local dbString = Unity.PlayerPrefs.GetString(self.dbName)
        dbString = CS.DbParser.Decode(dbString)
        self.data = rapidjson.decode(dbString)
        self:SaveDb()
    else
        self.data = self:GetDbInitData()
        self:SaveDb()
    end

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function UserInfoHandler:SaveDb()
    local dbString = rapidjson.encode(self.data)
    dbString = CS.DbParser.Encode(dbString)
    Unity.PlayerPrefs.SetString(self.dbName, dbString)
	Unity.PlayerPrefs.Save()
end

function UserInfoHandler:GetDbInitData()
    local data = {}
    data.mPlayerHandlerData = {} -- 游戏相关数据
    data.mGMGiftHandlerData = {} -- 比如赠送补偿金等
    return data
end