require("Lua/LobbyScene/Missions/FlashChallenge/FlashChallengeConfig")
require("Lua.LobbyScene.Missions.FlashChallenge.FlashChallengeRewardConfig")
require("Lua/LobbyScene/Missions/FlashChallenge/FlashChallengeRewardDataHandler")

FlashChallengeHandler = {}
FlashChallengeHandler.DATAPATH = Unity.Application.persistentDataPath.."/FlashChallengeHandler.txt"
FlashChallengeHandler.CHALLENGETIME = { from = "2022/10/28 00:00:00", period = 26 }
FlashChallengeHandler.m_nOneDaySecond = 24 * 3600

function FlashChallengeHandler:Init()
    FlashChallengeRewardDataHandler:Init()

    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    else
        self.data = self:GetDbInitData()
    end 

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
    
    if self:orDifferentDay() then
        self:ResetTodayTaskData()
    end

    if self:orDifferentSeason() then
        FlashChallengeRewardDataHandler:StartNextSeason()
    end

    EventHandler:AddListener("WinCoins", self)
    EventHandler:AddListener("UseCoins", self)
    EventHandler:AddListener("AddBigWinTime",self)
    EventHandler:AddListener("WatchAD",self)
    EventHandler:AddListener("PlayLuckyWheel", self)
    EventHandler:AddListener("PlayLuckyMegaball", self)
    EventHandler:AddListener("CollectSlotsCardsPacks", self)

end

function FlashChallengeHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function FlashChallengeHandler:GetDbInitData()
    local data = {}
    data.m_nSeason = -1
    data.m_nCurDayIndex = -1
    data.m_nSpinTimes = 0
    data.m_nBetCoins = 0
    data.m_ChallengePlayerData = {}
    data.m_ChallengeConfigParam = {}
    data.m_listThemeKeys = {}
    data.m_FlashTaskIndexs = {}
    return data
end

function FlashChallengeHandler:orUnLock()
    return PlayerHandler.nLevel >= FlashChallengeConfig.UNLOCKLEVEL
end

function FlashChallengeHandler:ResetTodayTaskData()
    self.data = {}
    self.data.m_nSeason = self:GetSeasonId()
    self.data.m_nCurDayIndex = self:GetDayIndex()

    self.data.m_FlashTaskIndexs = {1, 2, 3, 4, 0}
    self.data.m_nSpinTimes = 0
    self.data.m_nBetCoins = 0
    self.data.m_ChallengePlayerData = {}
    for i = 1, 5 do
        local data = {count = 0, isCompleted = false, nDoneTime = 0}
        table.insert( self.data.m_ChallengePlayerData, data)
    end

    self.data.m_ChallengeConfigParam = {}
    for i = 1, 5 do
        local data = FlashChallengeConfig:getFlashChallengeParams(i, 0)
        table.insert( self.data.m_ChallengeConfigParam, data)
    end 
    
    local tableTheme = LuaHelper.GetRandomTable(LuaHelper.DeepCloneTable(ThemeVideoConfig))
    self.data.m_listThemeKeys = {}
    for i = 1, 10 do
        table.insert(self.data.m_listThemeKeys, tableTheme[i].themeName)
    end  

    self:SaveDb()
end

function FlashChallengeHandler:CollectThisTaskAndToNextTask(nTaskIndex)
    local listPlayerData = self.data.m_ChallengePlayerData
    local playData = listPlayerData[nTaskIndex]
    playData.nDoneTime = playData.nDoneTime + 1
    playData.isCompleted = false
    playData.count = 0

    local listConfigParam = self.data.m_ChallengeConfigParam
    local nTaskID = listConfigParam[nTaskIndex].nTaskID
    listConfigParam[nTaskIndex] = FlashChallengeConfig:getFlashChallengeParams(nTaskIndex, playData.nDoneTime)
    self:SaveDb()
end

function FlashChallengeHandler:orActivityOpen()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.CHALLENGETIME.from)
    return nowSecond >= fromSecond
end

function FlashChallengeHandler:orDifferentDay()
    local season = self:GetSeasonId()
    local nIndex = self:GetDayIndex()
    return season ~= self.data.m_nSeason or nIndex ~= self.data.m_nCurDayIndex
end

function FlashChallengeHandler:orDifferentSeason()
    local season = self:GetSeasonId()
    return season ~= self.data.m_nSeason
end

function FlashChallengeHandler:orSeasonEnd()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    return nowSecond >= FlashChallengeHandler:GetSeasonEndTime()
end

function FlashChallengeHandler:GetSeasonId()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.CHALLENGETIME.from)
    local timediff = nowSecond - fromSecond
    local season = timediff // (3600 * 24 * self.CHALLENGETIME.period)
    return season
end

function FlashChallengeHandler:GetDayIndex()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.CHALLENGETIME.from)
    local timediff = nowSecond - fromSecond
    local nIndex = (timediff // self.m_nOneDaySecond) % self.CHALLENGETIME.period
    return nIndex
end

function FlashChallengeHandler:GetSeasonEndTime()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.CHALLENGETIME.from)
    local timedEnd = fromSecond + (self.data.m_nSeason + 1) * self.CHALLENGETIME.period * 3600 * 24
    return timedEnd
end

function FlashChallengeHandler:GetTaskIndex()
    local strThemeKey = ThemeLoader.themeKey
    local nIndex = LuaHelper.indexOfTable(self.data.m_listThemeKeys, strThemeKey)
    if nIndex >= 1 and nIndex <= 4 then
        return nIndex
    else
        return -1 
    end
end

function FlashChallengeHandler:GetCurrentTaskThemeKey(nTaskIndex)
    if nTaskIndex >= 1 and nTaskIndex <= 4 then
        return self.data.m_listThemeKeys[nTaskIndex]
    else
        Debug.Assert(false)
    end
end

function FlashChallengeHandler:IsFlashChallengeTheme()
    local nIndex = self:GetTaskIndex()
    return nIndex > 0
end

function FlashChallengeHandler:orTaskFinish()
    if not self:IsFlashChallengeTheme() then
        return false
    end
    
    local nIndex = self:GetTaskIndex()
    local playerData = self.data.m_ChallengePlayerData[nIndex]
    return playerData.isCompleted
end

-------------------------------------------------------------------------------

function FlashChallengeHandler:WinCoins(data)
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    if not self:IsFlashChallengeTheme() then
        return
    end

    local nWinCoins = data.nWinCoins
    local nIndex = self:GetTaskIndex()
    local playerData = self.data.m_ChallengePlayerData[nIndex]
    if playerData.isCompleted then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[nIndex]
    if configData.nTaskID == 3 then
        playerData.count = playerData.count + nWinCoins
    else
        return
    end  

    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function FlashChallengeHandler:UseCoins(data)
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    if not self:IsFlashChallengeTheme() then
        return
    end

    local nTotalBet = data.nTotalBet
    self.data.m_nBetCoins = self.data.m_nBetCoins + nTotalBet
    self.data.m_nSpinTimes = self.data.m_nSpinTimes + 1

    local nIndex = self:GetTaskIndex()
    local playerData = self.data.m_ChallengePlayerData[nIndex]
    if playerData.isCompleted then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[nIndex]
    if configData.nTaskID == 1 then 
        playerData.count = playerData.count + 1
    elseif configData.nTaskID == 2 then -- bet coins
        playerData.count = playerData.count + nTotalBet
    else
        return
    end

    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function FlashChallengeHandler:AddBigWinTime()
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    if not self:IsFlashChallengeTheme() then
        return
    end

    local nIndex = self:GetTaskIndex()
    local playerData = self.data.m_ChallengePlayerData[nIndex]
    if playerData.isCompleted then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[nIndex]
    if configData.nTaskID == 4 then 
        playerData.count = playerData.count + 1
    else
        return
    end

    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true 
    end

    self:SaveDb()
end

function FlashChallengeHandler:PlayLuckyWheel() -- 15
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[5]
    if configData.nTaskID ~= 5 then
        return
    end 

    local playerData = self.data.m_ChallengePlayerData[5]
    if playerData.isCompleted then
        return
    end

    playerData.count = playerData.count + 1
    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function FlashChallengeHandler:PlayLuckyMegaball() -- 15
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[5]
    if configData.nTaskID ~= 6 then
        return
    end
    
    local playerData = self.data.m_ChallengePlayerData[5]
    if playerData.isCompleted then
        return
    end
    
    playerData.count = playerData.count + 1
    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end

-- WatchAD
function FlashChallengeHandler:WatchAD()
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    local configData = self.data.m_ChallengeConfigParam[5]
    if configData.nTaskID ~= 7 then
        return
    end 

    local playerData = self.data.m_ChallengePlayerData[5]
    if playerData.isCompleted then
        return
    end

    playerData.count = playerData.count + 1
    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function FlashChallengeHandler:CollectSlotsCardsPacks(data)
    if not FlashChallengeHandler:orUnLock() then
        return
    end

    local nPackCount = data.count
    local configData = self.data.m_ChallengeConfigParam[5]
    if configData.nTaskID ~= 8 then
        return
    end 

    local playerData = self.data.m_ChallengePlayerData[5]
    if playerData.isCompleted then
        return
    end
    
    playerData.count = playerData.count + nPackCount
    if playerData.count >= configData.count then
        playerData.count = configData.count
        playerData.isCompleted = true
    end

    self:SaveDb()
end
