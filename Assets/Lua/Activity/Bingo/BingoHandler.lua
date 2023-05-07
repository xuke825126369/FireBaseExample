BingoHandler = {}
BingoHandler.DATAPATH = Unity.Application.persistentDataPath .. "/BingoHandler.txt"
BingoHandler.m_mapPrize = {}
BingoHandler.m_levelInfo = nil
BingoHandler.m_nBingoMaxCount = 75
BingoHandler.N_MAX_ACTION = 70

function BingoHandler:Init()
    self.data = {}
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        self.data = rapidjson.decode(strData)
    end
    
    if self.data.endTime ~= ActiveManager.nActivityEndTime then
        self:reset()
    end

    self:updateLevelPrize()
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
end

function BingoHandler:SaveDb()
    setmetatable(self.data.m_bingoMap, {__jsontype = "array"})
    setmetatable(self.data.m_bingoCurrentMapData, {__jsontype = "array"})
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function BingoHandler:updateLevelPrize()
    self.m_levelInfo = BingoConfig.TableLevelConfig["LevelInfo"..self.data.nLevel]
    self.m_nBingoMaxCount = self.m_levelInfo.bingoMaxCount

    self.m_mapPrize = {}
    local fFinalPrizeRatio = 10
    self.fFinalPrize = math.floor(ActivityHelper:getBasePrize() * fFinalPrizeRatio + 0.1)
    local ratioArray = {1, 2, 3, 4, 5} --1-5关
    for i = 1, LuaHelper.tableSize(BingoConfig.TableLevelConfig) do
        local nPrize = math.floor(ActivityHelper:getBasePrize() * ratioArray[i] + 0.1)
        self.m_mapPrize["Level"..i] = nPrize
    end
    
end

function BingoHandler:reset()
    self.data = {}
    self.data.endTime = ActiveManager.nActivityEndTime
    self.data.nAction = 5 -- Spin次数

    self.data.nSuperPickCount = 0 -- 内购中superPick的次数，（必定落棋盘上的数字）
    self.data.nWildCount = 0 -- 内购中wild的次数，（可以选择棋盘上没有的数字）
    self.data.m_nBingoBallBoosterEndTime = 0 -- 内购中相关，记录收集满加倍给pick数

    self.data.fCollectProgress = 0 --收集进度
    self.data.nLevel = 1 -- 第几关
    self.data.m_bingoMap = {} -- 当前牌面上的所有数字
    self.data.m_bingoCurrentMapData = {} -- 盘面上已经被占据的格子数字
    self.data.fFinalPrizeRatioMutiplier = 1
    self:InitMapData()
    self:SaveDb()

    Debug.LogWithColor("初始化BingoDataHandler: "..ActiveManager.nActivityEndTime)
end

function BingoHandler:GetItem(nCount)
    table.insert(self.data.m_bingoCurrentMapData, nCount)
    self:SaveDb()
end

function BingoHandler:ResetBingoData()
    self.data.nLevel = 1
    self.data.m_bingoCurrentMapData = {}
    self.data.m_bingoMap = {}
    self:InitMapData()
    self:SaveDb()
end

function BingoHandler:InitMapData()
    self.m_levelInfo = BingoConfig.TableLevelConfig["LevelInfo"..self.data.nLevel]
    self.m_nBingoMaxCount = self.m_levelInfo.bingoMaxCount
    
    local map = {}
    for i = 1, 25 do
        local nBingoDigit = math.random(1, self.m_nBingoMaxCount)
        while LuaHelper.tableContainsElement(map, nBingoDigit) do
            nBingoDigit = math.random(1, self.m_nBingoMaxCount)
        end
        table.insert(map, nBingoDigit)
    end
    self.data.m_bingoMap = map
    self:SaveDb()
end

function BingoHandler:GetRandomBingoDigit(bSuper)
    local bingoMap = {}
    for i = 1, #self.m_levelInfo.bingo do
        local nIndex = self.m_levelInfo.bingo[i]
        bingoMap[self.data.m_bingoMap[nIndex]] = true
    end
    
    local mapCurrentData = self.data.m_bingoCurrentMapData
    local mapRemainingData = {}
    for i = 1, self.m_nBingoMaxCount do
        if not LuaHelper.tableContainsElement(mapCurrentData, i) then
            table.insert(mapRemainingData, i)
        end
    end 

    local tableWeight = {}
    local nRateBingo = 1
    local nRateNormal = 5

    if self.data.nLevel == 1 then
        nRateBingo = 5
    elseif self.data.nLevel == 2 then
        nRateBingo = 2
    elseif self.data.nLevel == 3 then
        nRateBingo = 1.2
    else
        nRateBingo = 1
    end

    for i = 1, #mapRemainingData do
        if bingoMap[mapRemainingData[i]] then
            table.insert(tableWeight, nRateBingo)
        else
            table.insert(tableWeight, nRateNormal)
        end
    end

    local nIndex = LuaHelper.GetIndexByRate(tableWeight)
    local nCount = mapRemainingData[nIndex]

    if bSuper then
        local remainingInMap = {}
        for k, v in pairs(self.data.m_bingoMap) do
            if not LuaHelper.tableContainsElement(mapCurrentData, v) then
                table.insert(remainingInMap, v)
            end
        end

        local tableWeight = {}
        for i = 1, #remainingInMap do
            if bingoMap[remainingInMap[i]] then
                table.insert(tableWeight, nRateBingo)
            else
                table.insert(tableWeight, nRateNormal)
            end
        end
        local nIndex = LuaHelper.GetIndexByRate(tableWeight)
        nCount = remainingInMap[nIndex]
    end

    self:GetItem(nCount)
    return nCount
end

function BingoHandler:toNextLevel()
    self.data.nLevel = self.data.nLevel + 1
    if self.data.nLevel > LuaHelper.tableSize(BingoConfig.TableLevelConfig) then
        self:ResetBingoData()
        return true
    else
        self:InitMapData()
        self.data.m_bingoCurrentMapData = {}
        self:SaveDb()
        return false
    end
end

function BingoHandler:addPickCount(count)
    self.data.nAction = self.data.nAction + count
    self:SaveDb()
    EventHandler:Brocast("onActiveMsgCountChanged")
end

function BingoHandler:addSuperPickCount(count)
    self.data.nSuperPickCount = self.data.nSuperPickCount + count
    self:SaveDb()
end

function BingoHandler:addWildCount(count)
    self.data.nWildCount = self.data.nWildCount + count
    self:SaveDb()
end

function BingoHandler:CheckIsCoinsItem(nIndex)
    return LuaHelper.tableContainsElement(self.m_levelInfo.coins, nIndex)
end

function BingoHandler:CheckIsBingoItem(nIndex)
    return LuaHelper.tableContainsElement(self.m_levelInfo.bingo, nIndex)
end

function BingoHandler:CheckIsOneStarCardsItem(nIndex)
    return LuaHelper.tableContainsElement(self.m_levelInfo.oneStarCards, nIndex)
end
function BingoHandler:CheckIsTwoStarCardsItem(nIndex)
    return LuaHelper.tableContainsElement(self.m_levelInfo.twoStarCards, nIndex)
end

function BingoHandler:CheckIsThreeStarCardsItem(nIndex)
    return LuaHelper.tableContainsElement(self.m_levelInfo.threeStarCards, nIndex)
end

function BingoHandler:CheckHasItem(nCount)
    return LuaHelper.tableContainsElement(self.data.m_bingoCurrentMapData, nCount)
end

function BingoHandler:CheckIsEmpty(nIndex)
    return not self:CheckIsCoinsItem(nIndex) 
            and not self:CheckIsBingoItem(nIndex) 
            and not self:CheckIsOneStarCardsItem(nIndex) 
            and not self:CheckIsTwoStarCardsItem(nIndex)
            and not self:CheckIsThreeStarCardsItem(nIndex)
end

function BingoHandler:CheckIsBingo()
    local bIsBingo = true
    for i, j in pairs(self.m_levelInfo.bingo) do
        local bingoCount = self.data.m_bingoMap[j]
        if not LuaHelper.tableContainsElement(self.data.m_bingoCurrentMapData, bingoCount) then
            bIsBingo = false
            break
        end
    end
    return bIsBingo
end

function BingoHandler:RandomWinCoins()
    local tableRatio = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0}
    local tableRate = {1, 1, 1, 1, 1, 1, 1, 1}
    local fRatio = tableRatio[math.random(1, #tableRatio)]
    return ActivityHelper:getBasePrize() // 100 * fRatio
end

function BingoHandler:AddBoosterEndTime(nAddTime)
    if self.data.m_nBingoBallBoosterEndTime and self.data.m_nBingoBallBoosterEndTime > TimeHandler:GetServerTimeStamp() then
        self.data.m_nBingoBallBoosterEndTime = self.data.m_nBingoBallBoosterEndTime + nAddTime
    else
        self.data.m_nBingoBallBoosterEndTime = TimeHandler:GetServerTimeStamp() + nAddTime
    end
    self:SaveDb()
end

function BingoHandler:checkInBoosterTime()
    return self.data.m_nBingoBallBoosterEndTime and self.data.m_nBingoBallBoosterEndTime > TimeHandler:GetServerTimeStamp()
end

function BingoHandler:refreshAddSpinProgress(data)
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.Bingo)
    self.data.fCollectProgress = self.data.fCollectProgress + value
        
    local bTrigger = self.data.fCollectProgress >= 1
    local isActionReachMax = false
    if bTrigger then
        while self.data.fCollectProgress >= 1 do
            self.data.fCollectProgress = self.data.fCollectProgress - 1
        end

        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.Bingo)
        if self:checkInBoosterTime() then
            nAddCount = nAddCount * 2
        end

        --收集了，然后收集物数量到达了上限
        if self.data.nAction + nAddCount >= self.N_MAX_ACTION then
            isActionReachMax = true
            nAddCount = math.max(self.N_MAX_ACTION- self.data.nAction, 0)
        end
        self.data.nAction = self.data.nAction + nAddCount
    end
    self:SaveDb()

    return bTrigger, isActionReachMax
end

function BingoHandler:onPurchaseDoneNotifycation(skuInfo)
    if  ActiveManager.activeType ~= ActiveType.Bingo then return end
    if skuInfo.nType == SkuInfoType.Bingo then
        BingoHandler:addPickCount(skuInfo.activeInfo.nAction)
        
        if skuInfo.nActiveIAPType == BingoIAPConfig.Type.BingoBooster then
            self:AddBoosterEndTime(skuInfo.activeInfo.nBingoBoosterTime)
        elseif skuInfo.nActiveIAPType == BingoIAPConfig.Type.SuperBall then 
            self:addSuperPickCount(skuInfo.activeInfo.nSuperBallCount)
        elseif skuInfo.nActiveIAPType == BingoIAPConfig.Type.WildBall then 
            self:addWildCount(skuInfo.activeInfo.nWildBallCount)
        end
    else
        local pickCount = BingoIAPConfig.skuMapOther[skuInfo.productId]
        BingoHandler:addPickCount(pickCount)
    end
    self:updateLevelPrize()
    self:SaveDb()
end