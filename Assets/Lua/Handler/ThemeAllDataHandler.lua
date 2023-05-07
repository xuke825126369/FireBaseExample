ThemeAllDataHandler = {}

function ThemeAllDataHandler:Init()
	self.data = LocalDbHandler.data.mThemeAllDataHandlerData
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function ThemeAllDataHandler:SaveDb()
    LocalDbHandler.data.mThemeAllDataHandlerData = self.data
	LocalDbHandler:SaveDb()
end

function ThemeAllDataHandler:GetDbInitData()
    local data = {}
    data.mThemeAllData = {}
    return data
end

function ThemeAllDataHandler:GetThemeData(configItem)
	if not configItem then
		configItem = ThemeLoader.configItem
	end

	local mDbName =  ThemeHelper:GetThemeDbName(configItem)
	if CS.UnityEngine.PlayerPrefs.HasKey(mDbName) then
		local dbString = CS.UnityEngine.PlayerPrefs.GetString(mDbName)
		return mDbName, rapidjson.decode(dbString)
	end

	return nil
end

function ThemeAllDataHandler:GetAllThemeData()
	local tableAllData = {}
	for k, v in pairs(ThemeClassicConfig) do
		local configItem = v
		local dataKey, dataValue = self:GetThemeData(configItem)
		if dataKey and dataValue then
			self:FillLocaldataExtraInfo(dataValue)
			tableAllData[dataKey] = dataValue
		end
	end

	for k, v in pairs(ThemeVideoConfig) do
		local configItem = v
		local dataKey, dataValue = self:GetThemeData(configItem)
		if dataKey and dataValue then
			self:FillLocaldataExtraInfo(dataValue)
			tableAllData[dataKey] =  dataValue
		end
	end

	return tableAllData
end

function ThemeAllDataHandler:FillLocaldataExtraInfo(dataValue)
	if dataValue.fLastMonthUseCoins > 0.1 then
		dataValue.fLastMonthReturnRate = dataValue.fLastMonthWinCoins / dataValue.fLastMonthUseCoins
	else
		dataValue.fLastMonthReturnRate = -1
	end
	
	if dataValue.fLastDayUseCoins > 0.1 then
		dataValue.fLastDayReturnRate = dataValue.fLastDayWinCoins / dataValue.fLastDayUseCoins
	else
		dataValue.fLastDayReturnRate = -1
	end
end

