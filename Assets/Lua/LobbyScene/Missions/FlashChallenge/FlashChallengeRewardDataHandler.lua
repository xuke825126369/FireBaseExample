FlashChallengeRewardDataHandler = {}
FlashChallengeRewardDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/FlashChallengeRewardDataHandler.txt"
FlashChallengeRewardDataHandler.m_nLevel = 0
FlashChallengeRewardDataHandler.m_nLastChestLevel = 0
FlashChallengeRewardDataHandler.N_INTERVAL_COINS = 5000 -- JackPot 张金币

function FlashChallengeRewardDataHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    else
        self.data = self:GetDbInitData()
    end
    
    Debug.Assert(self.data ~= nil, "FlashChallengeRewardDataHandler.data == nil")
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
end

function FlashChallengeRewardDataHandler:SaveDb()
    setmetatable(self.data.m_mapRewardsGet, {__jsontype = "array"})
    local strData = rapidjson.encode(self.data)
    strData = CS.JsonHelper.FormatJsonString(strData)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function FlashChallengeRewardDataHandler:GetDbInitData()
    local data = {}
    data.m_nSeason = -1
    data.nFiresCount = 0 --收集进度
    data.m_mapRewardsGet = {}
    data.nPickBonusCount = 0
    data.nPickBonusReduceCount = 0
    data.nBeginPlayJackPotTime = 0 -- 到达6级的时间戳
    data.bRecivedReward = false
    return data
end

function FlashChallengeRewardDataHandler:StartNextSeason()
    self:CheckSeasonEnd()

    local nLastSeasonLevel = self:GetCurrentLevel(true)
    local nInitFireCount = 0
    if nLastSeasonLevel > 0 then
        nInitFireCount = FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES[nLastSeasonLevel]
    end

    self.data = {}
    self.data.m_nSeason = FlashChallengeHandler:GetSeasonId()
    self.data.nFiresCount = nInitFireCount
    self.data.nPickBonusCount = 0
    self.data.nPickBonusReduceCount = 0
    self.data.nBeginPlayJackPotTime = 0 -- 到达6级的时间戳
    self.data.bRecivedReward = false

    self.data.m_mapRewardsGet = {}
    local nIndex = 1
    for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
        for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
            self.data.m_mapRewardsGet[nIndex] = false
            nIndex = nIndex + 1
        end
    end

    self:SaveDb()
    self.m_nLevel = self:GetCurrentLevel(true)
end

function FlashChallengeRewardDataHandler:CheckSeasonEnd()
    local m_nSeason = FlashChallengeHandler:GetSeasonId()
    if self.data.m_nSeason ~= m_nSeason then
        if not self.data.bRecivedReward then
            self:SentAllPrizeNotReceived()
            self.data.bRecivedReward = true
            self:SaveDb()
        end
    end
end

function FlashChallengeRewardDataHandler:SentAllPrizeNotReceived()
    local nPlayLevel = PlayerHandler.nLevel
    if nPlayLevel < FlashChallengeConfig.UNLOCKLEVEL then
        return
    end
    local mapInboxPrizeParams = {}
    local targetIndex = 0

    local nFiresCount = self.data.nFiresCount
    if nFiresCount >= FlashChallengeRewardConfig.m_mapAllRewards[1][1].nFireCount then
        for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
            local bInThisLevel = false
            for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
                if nFiresCount <= FlashChallengeRewardConfig.m_mapAllRewards[i][j].nFireCount then
                    bInThisLevel = true
                    break
                else
                    targetIndex = targetIndex + 1
                end
            end
            if bInThisLevel then
                break
            end
        end
    end
    if targetIndex > 0 then
        local nCoins = 0
        local BonusParam = {nType = FlashChallengeRewardConfig.PrizeType.Coins}
        for i = 1, targetIndex do
            local prize = FlashChallengeRewardConfig:GetRewardPrize(i)
            if not self.data.m_mapRewardsGet[i] then
                if prize.nType == FlashChallengeRewardConfig.PrizeType.Coins then
                    nCoins = nCoins + self:getBasePrize() * prize.nMultiplier
                end
            end
        end
        if nCoins > 0 then
            BonusParam.nCoins = nCoins
            table.insert(mapInboxPrizeParams, BonusParam)
            DBHandler:addFlashChallengeRewardToInbox(mapInboxPrizeParams)
        end
    end
end

function FlashChallengeRewardDataHandler:GetCurrentLevel(bForce)
    if bForce then
        local nCurrentLevel = 1
        local nFiresCount = self.data.nFiresCount
        local nLength = LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards)
        local nLength1 = LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[nLength])
        if nFiresCount >= FlashChallengeRewardConfig.m_mapAllRewards[nLength][nLength1].nFireCount then
            nCurrentLevel = 6
            return nCurrentLevel
        end

        for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
            local bInThisLevel = false
            for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
                if nFiresCount < FlashChallengeRewardConfig.m_mapAllRewards[i][j].nFireCount then
                    bInThisLevel = true
                    break
                end
            end
            if bInThisLevel then
                nCurrentLevel = i
                break
            end
        end
        return nCurrentLevel
    else
        return self.m_nLevel
    end
end

function FlashChallengeRewardDataHandler:addFiresCount(nCount)    
    self.data.nFiresCount = self.data.nFiresCount + nCount
    local lastLevel = self.m_nLevel
    local currentLevel = self:GetCurrentLevel(true)
    self.m_nLevel = currentLevel
    if currentLevel ~= lastLevel then
        if self.m_nLevel >= 6 then
            self.data.nBeginPlayJackPotTime = TimeHandler:GetServerTimeStamp()
        end
    end
    self:SaveDb()
end

function FlashChallengeRewardDataHandler:getPlayJackpotTime()
    return self.data.nPlayJackPotTime
end

function FlashChallengeRewardDataHandler:checkCouldPlayJackpotGame()
    return TimeHandler:GetServerTimeStamp() >= self.data.nPlayJackPotTime
end

function FlashChallengeRewardDataHandler:getLastNetPlayJackPotTime()
    if self.data.nLastNetPlayJackPotTime == nil then
        self.data.nLastNetPlayJackPotTime = 0
    end
    return self.data.nLastNetPlayJackPotTime
end

function FlashChallengeRewardDataHandler:setPlayJackpotTime(netTime)
    self.data.nPlayJackPotTime = TimeHandler:GetServerTimeStamp() + FlashChallengeRewardConfig.N_NEXT_PLAY_TIME
    self.data.nLastNetPlayJackPotTime = netTime
    self:SaveDb()
end

function FlashChallengeRewardDataHandler:getCurrentMultipiler()
    local nLevel = FlashChallengeRewardDataHandler.m_nLevel > 5 and 5 or self.m_nLevel
    local nLength = LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[nLevel])
    local nNeedFire = FlashChallengeRewardConfig.m_mapAllRewards[nLevel][nLength].nFireCount

    local remain = self.data.nFiresCount - nNeedFire
    local nMultipiler = 1
    while remain > 0 do
        remain = remain - FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(nMultipiler)
        if remain >= 0 then
            nMultipiler = nMultipiler + 1
        end
    end
    remain = remain + FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(nMultipiler)
    return nMultipiler, remain
end

function FlashChallengeRewardDataHandler:getNumberOfRewardsNotReceived()
    local nCount = 0
    Debug.Assert(self.data ~= nil, "FlashChallengeRewardDataHandler.data == nil")
    if self.data.bRecivedReward then
        return nCount
    end
    
    local nTargetIndex = FlashChallengeRewardConfig:GetCurrentRewardIndex()
    if nTargetIndex <= 0 then
        return nCount
    end
    local nIndex = 1
    for i = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards) do
        for j = 1, LuaHelper.tableSize(FlashChallengeRewardConfig.m_mapAllRewards[i]) do
            if not self.data.m_mapRewardsGet[nIndex] then
                nCount = nCount + 1
            end
            if nTargetIndex == nIndex then
                return nCount
            end
            nIndex = nIndex + 1
        end
    end
    return nCount
end

function FlashChallengeRewardDataHandler:getRewardGet(nIndex)
    return self.data.m_mapRewardsGet[nIndex]
end

-- m_mapRewardsGet 从 1 开始
function FlashChallengeRewardDataHandler:setRewardGet(nIndex)
    local prize = FlashChallengeRewardConfig:GetRewardPrize(nIndex)
    self:collectCorrespondingPrize(prize)
    
    self.data.m_mapRewardsGet[nIndex] = true
    self:SaveDb()
end

function FlashChallengeRewardDataHandler:collectCorrespondingPrize(prize)
    if prize.nType == FlashChallengeRewardConfig.PrizeType.Coins then
        PlayerHandler:AddCoin(self:getBasePrize() * prize.nMultiplier)
    elseif prize.nType == FlashChallengeRewardConfig.PrizeType.PickBonus then
        self:setPickBonusCount(prize.nPickCount, prize.nReduceCount)
    end
end

function FlashChallengeRewardDataHandler:checkHasPickBonusGame()
    return self.data.nPickBonusCount > 0
end

function FlashChallengeRewardDataHandler:setPickBonusCount(nAddCount, nReduceCount)
    if self.data.nPickBonusCount == nil then
        self.data.nPickBonusCount = 0
    end
    self.data.nPickBonusCount = nAddCount
    self.data.nPickBonusReduceCount = nReduceCount
    if self.data.nPickBonusCount < 0 then
        self.data.nPickBonusCount = 0
    end
    self:SaveDb()
end

function FlashChallengeRewardDataHandler:getEndTime()
    return self.m_nEndTime
end

--以1美金的十分之一为奖励
function FlashChallengeRewardDataHandler:getBasePrize()
    local basicSkuInfo = AllBuyCFG[1]
    local nBasePrize = FormulaHelper:GetAddMoneyBySpendDollar(basicSkuInfo.nDollar)
    return nBasePrize / 10
end

function FlashChallengeRewardDataHandler:getCurrentJackpotReward()
    local base = self:getBasePrize()
    local current = base * FlashChallengeRewardConfig.N_MIN_RATIO
    current = current + (TimeHandler:GetServerTimeStamp() - self.data.nBeginPlayJackPotTime) * self.N_INTERVAL_COINS -- 需要配置
    return current
end
