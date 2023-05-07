LuckyEggHandler = {}
LuckyEggHandler.DATAPATH = Unity.Application.persistentDataPath.."/LuckyEggHandler.txt"
LuckyEggHandler.LUCKYEGGTIME = {from = "2021/04/28 00:00:00", period = 7}
LuckyEggHandler.N_UNLOCK_LEVEL = 2

LuckyEggHandler.N_SILVER_COUNT = 7
LuckyEggHandler.N_GOLD_COUNT = 7
LuckyEggHandler.N_SILVER_END_SEND_ROYALPASS = 200
LuckyEggHandler.N_GOLD_END_SEND_ROYALPASS = 400

LuckyEggHandler.N_SILVER_END_SEND_SLOTSCARDS = SlotsCardsAllProbTable.PackType.Four
LuckyEggHandler.N_GOLD_END_SEND_SLOTSCARDS = SlotsCardsAllProbTable.PackType.Five
LuckyEggHandler.N_GOLD_END_SEND_VIPPOINTS = 100
LuckyEggHandler.N_GOLD_END_SEND_DOUBLEEXP = 60 * 60 * 2

function LuckyEggHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    else
        self.data = self:GetDbInitData()
    end 
    
    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()
    self:CheckSeasonEnd()
end

function LuckyEggHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function LuckyEggHandler:GetDbInitData()
    local data = {}
    data.m_nSeason = LuckyEggHandler:GetSeasonId()

    data.bIsShowSmashDayPop = false -- 记录是否弹出过Smash Day提示
    data.bSilverEnd = false -- 银蛋是否完成
    data.mapSilverHammeredFlag = {} -- 记录银蛋是否被砸
    for i = 1, 7 do
        data.mapSilverHammeredFlag[i] = false
    end 

    data.nSilverCount = 0 --银锤子数量
    data.nSilverCollectMoney = 0

    data.bGoldEnd = false -- 金蛋是否完成
    data.mapGoldHammeredFlag = {} --记录金蛋是否被砸
    for i = 1, 7 do
        data.mapGoldHammeredFlag[i] = false
    end
    
    data.mapGoldFlag = {} --金锤子数量
    for i = 1, 7 do
        data.mapGoldFlag[i] = {}
        data.mapGoldFlag[i].bIsGet = false
    end

    data.nGoldCount = 0
    data.nGoldCollectMoney = 0
    data.bGoldOldPlayer = false
    data.bSilverOldPlayer = false
    return data
end

function LuckyEggHandler:orUnLock()
    return PlayerHandler.nLevel >= self.N_UNLOCK_LEVEL
end

function LuckyEggHandler:CheckCouldPlayLuckyEgg()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.LUCKYEGGTIME.from)
    if nowSecond < fromSecond then
        return false
    end
    
    local timediff = self:GetSeasonEndTime() - nowSecond
    local days = timediff // (3600 * 24)
    local hours = timediff // 3600 - 24 * days
    return days < 1 and hours <= 24
end

function LuckyEggHandler:GetSeasonId()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.LUCKYEGGTIME.from)
    local timediff = nowSecond - fromSecond
    local season = timediff // (3600 * 24 * self.LUCKYEGGTIME.period)
    return season
end

function LuckyEggHandler:GetDayIndex()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.LUCKYEGGTIME.from)
    local timediff = nowSecond - fromSecond
    local index = (timediff // self.m_nOneDaySecond) % self.LUCKYEGGTIME.period
    return index
end

function LuckyEggHandler:GetSeasonEndTime()
    local fromSecond = TimeHandler:GetTimeStampFromDateString(self.LUCKYEGGTIME.from)
    local timedEnd = fromSecond + (self.data.m_nSeason + 1) * self.LUCKYEGGTIME.period * 3600 * 24
    return timedEnd
end

function LuckyEggHandler:CheckSeasonEnd()
    if self.data.m_nSeason ~= LuckyEggHandler:GetSeasonId() then
        self.data = self:GetDbInitData()
        self:SaveDb()
    end
end

function LuckyEggHandler:getShowSmashDayPop()
    return self.data.bIsShowSmashDayPop
end

function LuckyEggHandler:setShowSmashDayPop()
    self.data.bIsShowSmashDayPop = true
    self:SaveDb()
end

function LuckyEggHandler:setSilverEnd()
    self.data.bSilverEnd = true
    self:SaveDb()
end

function LuckyEggHandler:setGoldEnd()
    self.data.bGoldEnd = true
    PlayerHandler:AddVipPoint(LuckyEggHandler.N_GOLD_END_SEND_VIPPOINTS)
    self:SaveDb()
end

function LuckyEggHandler:getSilverEnd()
    return self.data.bSilverEnd
end

function LuckyEggHandler:getGoldEnd()
    return self.data.bGoldEnd
end

function LuckyEggHandler:setSilverEggHammered(nIndex)
    self.data.mapSilverHammeredFlag[nIndex] = true
    self:SaveDb()
end

function LuckyEggHandler:getSilverEggHammered(nIndex)
    return self.data.mapSilverHammeredFlag[nIndex]
end

function LuckyEggHandler:setGoldEggHammered(nIndex)
    self.data.mapGoldHammeredFlag[nIndex] = true
    self:SaveDb()
end

function LuckyEggHandler:getGoldEggHammered(nIndex)
    return self.data.mapGoldHammeredFlag[nIndex]
end

function LuckyEggHandler:getSilverHammerCount()
    return self.data.nSilverCount
end

function LuckyEggHandler:addSilverHammerCount(nAddCount)
    self.data.nSilverCount = self.data.nSilverCount + nAddCount
    self:SaveDb()
end

function LuckyEggHandler:addGoldHammerCount(nAddCount)
    self.data.nGoldCount = self.data.nGoldCount + nAddCount
    self:SaveDb()
end

function LuckyEggHandler:getGoldHammerCount()
    local nCount = self.data.nGoldCount
    return nCount
end

function LuckyEggHandler:setGetGoldHammer()
    self.data.nGoldCount = self.data.nGoldCount + 1
    local week = TimeHandler:GetServerLocalDateTimeNow().DayOfWeek
    local nIndex = 1
    if week == CS.System.DayOfWeek.Monday then
        nIndex = 1
    elseif week == CS.System.DayOfWeek.Tuesday then
        nIndex = 2
    elseif week == CS.System.DayOfWeek.Wednesday then
        nIndex = 3
    elseif week == CS.System.DayOfWeek.Thursday then
        nIndex = 4
    elseif week == CS.System.DayOfWeek.Friday then
        nIndex = 5
    elseif week == CS.System.DayOfWeek.Saturday then
        nIndex = 6
    elseif week == CS.System.DayOfWeek.Sunday then
        nIndex = 7
    end
    self.data.mapGoldFlag[nIndex].bIsGet = true
    self:SaveDb()
end

function LuckyEggHandler:addSilverCollectMoney(addMoney)
    self.data.nSilverCollectMoney = self.data.nSilverCollectMoney + addMoney
    self:SaveDb()
end

function LuckyEggHandler:addGoldCollectMoney(addMoney)
    self.data.nGoldCollectMoney = self.data.nGoldCollectMoney + addMoney
    self:SaveDb()
end

function LuckyEggHandler:RandomClickedSilverEgg()
    local rateTable = {1, 5, 1} -- 分别对应空、收集金币、结束金币
    local nIndex = 1
    local remainCount = 0
    for i = 1, LuaHelper.tableSize(self.data.mapSilverHammeredFlag) do
        if not self.data.mapSilverHammeredFlag[i] then
            remainCount = remainCount + 1
        end
    end
    if self.data.bSilverOldPlayer then
        nIndex = LuaHelper.GetIndexByRate(rateTable)
    else
        rateTable = {0, self.data.nSilverCount - 1, 1}
        nIndex = LuaHelper.GetIndexByRate(rateTable)
    end
    if nIndex < 0 then
        nIndex = 3
    end
    if remainCount <= 0 then
        -- 最后一个结果必然是结束
        nIndex = 3
    end
    if nIndex == 1 then -- 空奖励
        
    elseif nIndex == 2 then -- 收集金币奖励
        local addMoney = self:getBasePrize()
        addMoney = addMoney * 0.5
        self:addSilverCollectMoney(addMoney)
        return nIndex, addMoney
    elseif nIndex == 3 then -- 结束金币奖励
        self.data.bSilverOldPlayer = true
        self:SaveDb()
        local base = self:getBasePrize()

        local hammerRemainWin = self.data.nSilverCount * base * 0.5
        local bonusSavedWin = self.data.nSilverCollectMoney
        local endWin = base * 5

        local totalWin = hammerRemainWin + bonusSavedWin + endWin
        PlayerHandler:AddCoin(totalWin)
        return nIndex, hammerRemainWin, self.data.nSilverCount, bonusSavedWin, endWin, totalWin
    end
    return nIndex
end

function LuckyEggHandler:RandomClickedGoldEgg()
    local rateTable = {2, 5, 2} -- 分别对应空、收集金币、结束金币
    
    local remainCount = 0
    for i = 1, LuaHelper.tableSize(self.data.mapGoldHammeredFlag) do
        if not self.data.mapGoldHammeredFlag[i] then
            remainCount = remainCount + 1
        end
    end

    local nIndex = 1
    if self.data.bGoldOldPlayer then
        nIndex = LuaHelper.GetIndexByRate(rateTable)
    else
        local goldRemainCount = self:getGoldHammerCount()
        rateTable = {0, goldRemainCount - 1, 1}
        nIndex = LuaHelper.GetIndexByRate(rateTable)
    end
    if nIndex < 0 then
        nIndex = 3
    end
    if remainCount <= 0 then
        nIndex = 3
    end

    if nIndex == 1 then -- 空奖励
        
    elseif nIndex == 2 then -- 收集金币奖励
        local addMoney = self:getBasePrize()
        self:addGoldCollectMoney(addMoney)
        return nIndex, addMoney
    elseif nIndex == 3 then -- 结束金币奖励
        self.data.bGoldOldPlayer = true
        self:SaveDb()
        local base = self:getBasePrize()
        local goldRemainCount = self:getGoldHammerCount()
        local hammerRemainWin = goldRemainCount * base
        local bonusSavedWin = self.data.nGoldCollectMoney
        local endWin = base * 12

        local totalWin = hammerRemainWin + bonusSavedWin + endWin
        PlayerHandler:AddCoin(totalWin)
        return nIndex, hammerRemainWin, goldRemainCount, bonusSavedWin, endWin, totalWin
    end
    return nIndex
end

function LuckyEggHandler:getBasePrize()
    -- 取商店1美元的coins为参考依据
    local strSKuKey = AllBuyCFG[1].productId
    local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins = skuInfo.baseCoins -- 不乘打折系数的。。
    return nCoins
end