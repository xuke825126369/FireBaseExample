require("Lua.LobbyScene.Missions.DailyMission.DailyMissionConfig")

DailyMissionHandler = {}
DailyMissionHandler.DATAPATH = Unity.Application.persistentDataPath.."/DailyMissionHandler.txt"
DailyMissionHandler.m_nBaseTimeSecond = CS.TimeUtility.GetTimeStampFromLocalTime(CS.System.DateTime(2010, 1, 1, 0, 0, 0))
DailyMissionHandler.m_nOneDaySecond = 3600 * 24
DailyMissionHandler.nActivityDayCount = 7
DailyMissionHandler.m_nDailyMissionUnlockLevel = 2
DailyMissionHandler.bTest = false

function DailyMissionHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    else
        self.data = self:GetDbInitData()
    end

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
    
    if self:orStartNextActivity() then
        self:StartNextActivity()
    end

    if self:orStartNextDayTask() then
        self:StartNextDayTask()
    end

    EventHandler:AddListener("WinCoins", self)
    EventHandler:AddListener("UseCoins", self)
    EventHandler:AddListener("AddBigWinTime",self)
    EventHandler:AddListener("onLevelUp", self)

end

function DailyMissionHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function DailyMissionHandler:GetDbInitData()
    local data = {}
    data.m_nBetCoins = 0 -- 做任务压了多少 -- 这两个参数不重置 用于调节任务难度
    data.m_nSpinTimes = 0 -- 做任务spin了多少次
    data.nSeason = -1
    data.m_nMissionPoint = 0
    data.m_missionPointBonusFlag = {false, false}
    data.m_OneDollarCoins = 0 -- 每天刷新任务的时候初始化了记着
    data.m_nCurDayIndex = 0 -- m_nCurDayIndex: 0 1 2 3 4 5 6 
    data.m_curTaskIndex = 1
    data.m_MissionPlayerData = {}-- 玩家的完成进度数据 -- 里面存5个子表
    data.m_bAllCompleted = false
    return data
end

function DailyMissionHandler:GetSeason()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = nowSecond - self.m_nBaseTimeSecond
    local nSeason = timediff // (3600 * 24 * self.nActivityDayCount)
    return nSeason
end

function DailyMissionHandler:GetDayIndexInSeason()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local timediff = nowSecond - self.m_nBaseTimeSecond
    local nSumDays = timediff // (3600 * 24)
    local nDayIndex = nSumDays % self.nActivityDayCount
    return nDayIndex
end

function DailyMissionHandler:GetActivityEndTimeSeconds()
    local nNextSeason = self.data.nSeason + 1
    local nEndTime = self.m_nBaseTimeSecond + nNextSeason * (3600 * 24 * self.nActivityDayCount)
    return nEndTime
end

-- 当上一个活动结束后，重置下一个的活动
function DailyMissionHandler:StartTodayNextTask()
    local tasks = DailyMissionConfig:getDailyMissionIndexs(self.data.m_nCurDayIndex)
    self.data.m_curTaskIndex = self.data.m_curTaskIndex + 1
    if self.data.m_curTaskIndex > #tasks then
        self.data.m_bAllCompleted = true
    end
    self:SaveDb()
end

function DailyMissionHandler:orStartNextDayTask()
    return self.data.m_nCurDayIndex ~= self:GetDayIndexInSeason()
end

-- 当昨天活动结束后，重置下一天的活动
function DailyMissionHandler:StartNextDayTask()
    self.data.m_curTaskIndex = 1
    self.data.m_nCurDayIndex = self.data.m_nCurDayIndex + 1
    self.data.m_nCurDayIndex = self.data.m_nCurDayIndex % DailyMissionHandler.nActivityDayCount

    self.data.m_MissionPlayerData = {}
    local tasks = DailyMissionConfig:getDailyMissionIndexs(self.data.m_nCurDayIndex)
    local cnt = #tasks
    for i = 1, cnt do
        local data = {count = 0, isCompleted = false, isReward = false, spinTimes = 0}
        table.insert(self.data.m_MissionPlayerData, data)
    end
    self:SaveDb()
end

function DailyMissionHandler:orStartNextActivity()
    return self.data.nSeason ~= self:GetSeason()
end

-- 当7天活动结束后，重置整个活动
function DailyMissionHandler:StartNextActivity()
    self.data.m_curTaskIndex = 1
    self.data.m_bAllCompleted = false
    self.data.m_OneDollarCoins = DailyMissionConfig:getOneDollarCoins()
    self.data.m_nMissionPoint = 0

    self.data.nSeason = self:GetSeason()
    self.data.m_nCurDayIndex = self:GetDayIndexInSeason()

    self.data.m_missionPointBonusFlag = {false, false}
    self.data.m_MissionPlayerData = {}
    local tasks = DailyMissionConfig:getDailyMissionIndexs(self.data.m_nCurDayIndex)
    local cnt = #tasks
    for i = 1, cnt do
        local data = {count = 0, isCompleted = false, isReward = false, spinTimes = 0}
        table.insert(self.data.m_MissionPlayerData, data)
    end

    self:SaveDb()
end

function DailyMissionHandler:orUnLock()
    return PlayerHandler.nLevel >= self.m_nDailyMissionUnlockLevel
end

function DailyMissionHandler:GetCurrentMission()
    local m_nCurDayIndex = DailyMissionHandler.data.m_nCurDayIndex
    local nCurTaskIndex = DailyMissionHandler.data.m_curTaskIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(m_nCurDayIndex)
    local missionID = tasks[nCurTaskIndex]
    local Mission = DailyMissionConfig.m_Missions[missionID]
    return Mission
end

function DailyMissionHandler:orTaskFinish()
    local nCurTaskIndex = self.data.m_curTaskIndex
    local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
    return playerData.isCompleted, playerData.isReward
end

function DailyMissionHandler:getNumberOfRewardsNotReceived()
    local nCount = 0
    if not self:orTodayAllTaskFinish() then
        local nCurTaskIndex = self.data.m_curTaskIndex
        local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
        if  playerData.isCompleted and not playerData.isReward then
            nCount = nCount + 1 
        end
    end

    if self.data.m_nMissionPoint >= 500 then
        if not self.data.m_missionPointBonusFlag[1] then
            nCount = nCount + 1 
        end
    end 
    
    if self.data.m_nMissionPoint >= 1000 then
        if not self.data.m_missionPointBonusFlag[2] then
            nCount = nCount + 1 
        end
    end

    return nCount
end 

function DailyMissionHandler:orTodayAllTaskFinish()
    local m_nCurDayIndex = DailyMissionHandler.data.m_nCurDayIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(m_nCurDayIndex)
    return self.data.m_curTaskIndex > #tasks
end

function DailyMissionHandler:addMissionPoints(nValue)
    self.data.m_nMissionPoint = self.data.m_nMissionPoint + nValue
    if self.data.m_nMissionPoint > 1000 then
        self.data.m_nMissionPoint = 1000
    end
    self:SaveDb()
end

function DailyMissionHandler:handleTaskFail()
    --任务失败..
    -- 重新倒计数...
    -- 刷新UI显示
    MissionLevelEntry:TaskFailedTip()
end

function DailyMissionHandler:WinCoins(data)
    if not self:orUnLock() then
        return
    end

    if self.data.m_bAllCompleted then
        return
    end

    local nWinCoins = data.nWinCoins
    local nDayIndex = self.data.m_nCurDayIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(nDayIndex)

    local nCurTaskIndex = self.data.m_curTaskIndex
    if nCurTaskIndex > #tasks then
        nCurTaskIndex = #tasks
    end

    local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
    if playerData.isCompleted then
        return
    end

    local missionID = tasks[nCurTaskIndex]
    if missionID == 2 then -- win %d times in base game.
        if nWinCoins > 0 then
            playerData.count = playerData.count + 1
        end
    elseif missionID == 4 then -- win %s coins.
        playerData.count = playerData.count + nWinCoins
    elseif missionID == 6 then -- Win %s Coins in a single spin X5 times.
        local coef = DailyMissionConfig.m_Missions[missionID].count[nCurTaskIndex]

        local nMiniWinCoins = coef * self.data.m_OneDollarCoins
        if nWinCoins >= nMiniWinCoins then
            playerData.count = playerData.count + 1
            if playerData.count >= 5 then
                playerData.isCompleted = true
            end
        end
        
        if DailyMissionHandler.bTest then
            playerData.isCompleted = true
        end

    elseif missionID == 8 then -- Win %s Coins in 100 Spins.
        playerData.spinTimes = playerData.spinTimes + 1
        playerData.count = playerData.count + nWinCoins
        if playerData.spinTimes == nil then
            playerData.spinTimes = 0
        end

        if playerData.spinTimes > 100 then
            playerData.count = 0
            playerData.spinTimes = 0
            self:handleTaskFail()
        end
    else
        return
    end
    
    -- ID为6的情况 是否完成任务在上面处理了
    if missionID == 2 or missionID == 4 or missionID == 8 then
        local mission = DailyMissionConfig.m_Missions[missionID]
        local num = mission.count[nCurTaskIndex]

        local targetNum = 0
        if mission.isCoinCoef then
            targetNum = num * self.data.m_OneDollarCoins
        else
            targetNum = num
        end

        if playerData.count >= targetNum then
            playerData.isCompleted = true -- 进入等待领奖的界面
        end

        if DailyMissionHandler.bTest then
            playerData.isCompleted = true
        end
    end

    self:SaveDb()
end

function DailyMissionHandler:UseCoins(data)
    local nPlayerLevel = PlayerHandler.nLevel
    if nPlayerLevel < self.m_nDailyMissionUnlockLevel then
        return
    end

    if self.data.m_bAllCompleted then
        return
    end     

    local nTotalBet = data.nTotalBet
    local nDayIndex = self.data.m_nCurDayIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(nDayIndex)

    local nCurTaskIndex =self.data.m_curTaskIndex
    if nCurTaskIndex > #tasks then
        nCurTaskIndex = #tasks
    end

    local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
    if playerData.isCompleted then
        return
    end

    local missionID = tasks[nCurTaskIndex]
    
    if missionID == 1 then -- Spin %d times.
        playerData.count = playerData.count + 1

    elseif missionID == 3 then -- Bet %s coins.
        playerData.count = playerData.count + nTotalBet
        
    else
        return
    end

    local mission = DailyMissionConfig.m_Missions[missionID]
    local num = mission.count[nCurTaskIndex]
    local targetNum = 0
    if mission.isCoinCoef then
        targetNum = num * self.data.m_OneDollarCoins
    else
        targetNum = num
    end

    if playerData.count >= targetNum then
        playerData.isCompleted = true -- 进入等待领奖的界面
    end

    if DailyMissionHandler.bTest then
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function DailyMissionHandler:AddBigWinTime()
    if not self:orUnLock() then
        return
    end
    
    local nDayIndex = self.data.m_nCurDayIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(nDayIndex)

    local nCurTaskIndex =self.data.m_curTaskIndex
    if nCurTaskIndex > #tasks then
        nCurTaskIndex = #tasks
    end

    local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
    if playerData.isCompleted then
        return
    end

    local missionID = tasks[nCurTaskIndex]
    if missionID == 5 then -- Get %d big wins.
        playerData.count = playerData.count + 1
    else
        return
    end

    local mission = DailyMissionConfig.m_Missions[missionID]
    local targetNum = mission.count[nCurTaskIndex]
    if playerData.count >= targetNum then
        playerData.isCompleted = true -- 进入等待领奖的界面
    end

    if DailyMissionHandler.bTest then
        playerData.isCompleted = true
    end

    self:SaveDb()
end

function DailyMissionHandler:onLevelUp()
    if not self:orUnLock() then
        return
    end 

    local nDayIndex = self.data.m_nCurDayIndex
    local nCurTaskIndex =self.data.m_curTaskIndex
    local tasks = DailyMissionConfig:getDailyMissionIndexs(nDayIndex)
    local missionID = tasks[nCurTaskIndex]
    if missionID ~= 7 then
        return
    end

    local playerData = self.data.m_MissionPlayerData[nCurTaskIndex]
    if playerData.isCompleted then
        return
    end

    local mission = DailyMissionConfig.m_Missions[missionID]
    local targetNum = mission.count[nCurTaskIndex]
    playerData.count = playerData.count + 1
    if playerData.count >= targetNum then
        playerData.isCompleted = true
    end

    if DailyMissionHandler.bTest then
        playerData.isCompleted = true
    end

    self:SaveDb()
end
