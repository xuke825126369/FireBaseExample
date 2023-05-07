ThemeSingleLevelDataHandler = {}

function ThemeSingleLevelDataHandler:Init()
	self.mDbName = ThemeHelper:GetThemeDbName(ThemeLoader.configItem)

	self.m_Data = ThemeAllDataHandler.data.mThemeAllData[self.mDbName]
	if self.m_Data == nil then
		self.m_Data = self:GetDbInitData()
	end

	LuaHelper.FixSimpleDbError(self.m_Data, self:GetDbInitData())
    self:persistentData()
	
	if self:orDifferentDay() then
		self.m_Data.fLastDayTimeStamp = TimeHandler:GetServerTimeStamp()
		self.m_Data.fLastDayUseCoins = 0
		self.m_Data.fLastDayWinCoins = 0
		self.m_Data.nLastDaySpinNum = 0
		self.m_Data.fLastDayReturnRate = 0.0
		self:persistentData()
	end	

	if self:orDifferentMonth() then
		self.m_Data.fLastMonthTimeStamp = TimeHandler:GetServerTimeStamp()
		self.m_Data.fLastMonthUseCoins = 0
		self.m_Data.fLastMonthWinCoins = 0
		self.m_Data.nLastMonthSpinNum = 0
		self.m_Data.fLastMonthReturnRate = 0.0

		if self.bFirstPlayThisTheme then
			self.m_Data.nInitReturnRateBeginSpinIndex = 0
			self.m_Data.nInitReturnRateSpinCount = math.random(1, 20) --每个月刚玩的关卡，返还率高一点
		else
			self.m_Data.nInitReturnRateBeginSpinIndex = math.random(1, 200) --每个月刚玩的关卡，返还率高一点
			self.m_Data.nInitReturnRateSpinCount = math.random(1, 20) --每个月刚玩的关卡，返还率高一点
		end
		self:persistentData()
	end	

	self:persistentData()
	self:SendFBEvent()
	self.nInitGoldMoneyCount = PlayerHandler.nGoldCount
end

function ThemeSingleLevelDataHandler:persistentData()
	ThemeAllDataHandler.data.mThemeAllData[self.mDbName] = self.m_Data
	LocalDbHandler:SaveDb()
end

function ThemeSingleLevelDataHandler:GetDbInitData()
	local m_Data = {}
	m_Data.mThemeData = {}

	m_Data.nReSpinNum = 0
	m_Data.nFreeSpinNum = 0
	m_Data.nTotalFreeSpin = 0
	m_Data.nFreeSpinTotalWin = 0
	
	m_Data.fLastMonthTimeStamp = 0
	m_Data.fLastMonthUseCoins = 0
	m_Data.fLastMonthWinCoins = 0
	m_Data.nLastMonthSpinNum = 0
	m_Data.fLastMonthReturnRate = 0.0
	m_Data.nInitReturnRateBeginSpinIndex = 0  --每个月刚玩的关卡，返还率高一点
	m_Data.nInitReturnRateSpinCount = 0  --每个月刚玩的关卡，返还率高一点

	m_Data.fLastDayTimeStamp = 0
	m_Data.fLastDayUseCoins = 0
	m_Data.fLastDayWinCoins = 0
	m_Data.nLastDaySpinNum = 0
	m_Data.fLastDayReturnRate = 0.0

	return m_Data
end

function ThemeSingleLevelDataHandler:orDifferentDay()
    local recordDateTime = CS.TimeUtility.GetLocalTimeFromTimeStamp(self.m_Data.fLastDayTimeStamp)
    local nowDateTime = TimeHandler:GetServerLocalDateTimeNow()
    if nowDateTime.Day ~= recordDateTime.Day or nowDateTime.Month ~= recordDateTime.Month or nowDateTime.Year ~= recordDateTime.Year then
        return true
    end
    return false
end

function ThemeSingleLevelDataHandler:orDifferentMonth()
    local recordDateTime = CS.TimeUtility.GetLocalTimeFromTimeStamp(self.m_Data.fLastMonthTimeStamp)
    local nowDateTime = TimeHandler:GetServerLocalDateTimeNow()
    if nowDateTime.Month ~= recordDateTime.Month or nowDateTime.Year ~= recordDateTime.Year then
        return true
    end
    return false
end

function ThemeSingleLevelDataHandler:SendFBEvent()
	local strEventName = self.mDbName
	local eventParams = {}
	eventParams.fWinCoins = self.m_Data.fLastMonthWinCoins
	eventParams.fUseCoins = self.m_Data.fLastMonthUseCoins
	eventParams.nSpinNum = self.m_Data.nLastMonthSpinNum
	if self.m_Data.fLastMonthUseCoins > 0 then
		eventParams.fReturnRate = math.floor(self.m_Data.fLastMonthWinCoins / self.m_Data.fLastMonthUseCoins * 100) / 100
	else
		eventParams.fReturnRate = -1.0
	end
	AppAdsEventHandler:SendCustomEvent(strEventName, eventParams)
end

function ThemeSingleLevelDataHandler:GetDayReturnRate()
	if self.m_Data.fLastDayUseCoins > 0.1 then
		return self.m_Data.fLastDayWinCoins / self.m_Data.fLastDayUseCoins
	else
		return -1.0
	end
end

function ThemeSingleLevelDataHandler:GetMonthReturnRate()
	if self.m_Data.fLastMonthUseCoins > 1 then
		return self.m_Data.fLastMonthWinCoins / self.m_Data.fLastMonthUseCoins
	else
		return -1.0
	end
end


------------------------------------------------------------------------------------------
function ThemeSingleLevelDataHandler:setReSpinCount(strLevelName, nReSpin)
	self.m_Data.nReSpinNum = nReSpin
	self:persistentData()
end

function ThemeSingleLevelDataHandler:getReSpinCount(strLevelName)
	if self.m_Data.nReSpinNum == nil then
		return 0
	end

	return self.m_Data.nReSpinNum
end

function ThemeSingleLevelDataHandler:setFreeSpinCount(strLevelName, nFreeSpinNum)
	self.m_Data.nFreeSpinNum = nFreeSpinNum
	self:persistentData()
end

function ThemeSingleLevelDataHandler:getFreeSpinCount(strLevelName)
	if self.m_Data.nFreeSpinNum == nil then
		return 0
	end

	return self.m_Data.nFreeSpinNum 
end  

function ThemeSingleLevelDataHandler:addNewFreeSpinCount(strLevelName, nAddFreeSpinNum)
	local preValue = self:getFreeSpinCount(strLevelName)
	local curValue = preValue + nAddFreeSpinNum
	self:setFreeSpinCount(strLevelName, curValue)
end

function ThemeSingleLevelDataHandler:setTotalFreeSpinCount(strLevelName, nTotalFreeSpin)
	self.m_Data.nTotalFreeSpin = nTotalFreeSpin
	self:persistentData()
end  

function ThemeSingleLevelDataHandler:getTotalFreeSpinCount(strLevelName)
	if self.m_Data.nTotalFreeSpin == nil then
		return 0
	end

	return self.m_Data.nTotalFreeSpin
end  

function ThemeSingleLevelDataHandler:addTotalFreeSpinCount(strLevelName, nAddTotalFreeSpin)
	local oriNum = self:getTotalFreeSpinCount(strLevelName)
	self.m_Data.nTotalFreeSpin = oriNum + nAddTotalFreeSpin

	self:persistentData()
end  

function ThemeSingleLevelDataHandler:setFreeSpinTotalWin(strLevelName, nFreeSpinTotalWin)
	self.m_Data.nFreeSpinTotalWin = nFreeSpinTotalWin
	self:persistentData()
end

function ThemeSingleLevelDataHandler:addFreeSpinTotalWin(strLevelName, nAddTotalFreeSpin)
	local oriNum = self:getFreeSpinTotalWin(strLevelName)
	local SumNum = oriNum + nAddTotalFreeSpin

	self:setFreeSpinTotalWin(strLevelName,SumNum)
end 

function ThemeSingleLevelDataHandler:getFreeSpinTotalWin(strLevelName)
	if self.m_Data.nFreeSpinTotalWin == nil then
		return 0
	end

	return self.m_Data.nFreeSpinTotalWin
end

--------------------------------------------------------------------------------------------
function ThemeSingleLevelDataHandler:AddPlayerWinCoins(fWinCoins)
	self.m_Data.fLastMonthWinCoins = self.m_Data.fLastMonthWinCoins + fWinCoins
	self.m_Data.fLastDayWinCoins = self.m_Data.fLastDayWinCoins + fWinCoins
	self:persistentData()

	self:OnActivityTotalWinPerSpin(fWinCoins)
end

function ThemeSingleLevelDataHandler:AddPlayerUseCoins(fUseCoins)
	self.m_Data.fLastMonthUseCoins = self.m_Data.fLastMonthUseCoins + fUseCoins
	self.m_Data.fLastDayUseCoins = self.m_Data.fLastDayUseCoins + fUseCoins
	self:persistentData()

	self:OnActivityUsedTotalBetPerSpin(fUseCoins)
end

function ThemeSingleLevelDataHandler:AddTotalSpinNum()
	self.m_Data.nLastMonthSpinNum = self.m_Data.nLastMonthSpinNum + 1
	self.m_Data.nLastDaySpinNum = self.m_Data.nLastDaySpinNum + 1
	self:persistentData()

	self:OnActivityAddSpinCount()
end

function ThemeSingleLevelDataHandler:AddBaseSpinWinCoins(fUseCoins, fWinCoins)
	AppLocalEventHandler:AddBaseSpinWinCoins(fUseCoins, fWinCoins)
end

--------------------------------------活动或其他调用------------------------------------------------------
function ThemeSingleLevelDataHandler:OnActivityTotalWinPerSpin(fWinCoins)
	AppLocalEventHandler:AddThemeWinMoneyCount(fWinCoins)
end

function ThemeSingleLevelDataHandler:OnActivityUsedTotalBetPerSpin(fUseCoins)
	AppLocalEventHandler:AddThemeUsedMoneyCount(fUseCoins)
end

function ThemeSingleLevelDataHandler:OnActivityAddSpinCount()
	AppLocalEventHandler:AddThemeSpinCount()
end

--------------------------------------刚开始运行的时候尽量让玩家中大奖，看到各个关卡的精华之处------------------------------------------------------
function ThemeSingleLevelDataHandler:orInEveryMonthCashBackFeature()
	return self.m_Data.nLastMonthSpinNum >= self.m_Data.nInitReturnRateBeginSpinIndex and 
		self.m_Data.nLastMonthSpinNum <= self.m_Data.nInitReturnRateBeginSpinIndex + self.m_Data.nInitReturnRateSpinCount
end

return ThemeSingleLevelDataHandler