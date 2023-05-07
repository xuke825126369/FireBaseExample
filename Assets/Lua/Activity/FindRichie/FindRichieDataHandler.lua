FindRichieDataHandler = {}

FindRichieDataHandler.data = {}

FindRichieDataHandler.m_bInitData = false

FindRichieDataHandler.m_nEndTime = 0
FindRichieDataHandler.m_mapPrize = {}

FindRichieDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/FindRichieData.txt"

FindRichieDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 5

FindRichieDataHandler.ACTIVETIME = {
    {from = "2019-7-1T00:00:00+0000", to = "2020-10-15T00:00:00+0000"}
}

--这里配置每一关卡有几个选择
FindRichieDataHandler.m_mapLevelConfig = {
    Level1 = 15,
    Level2 = 20,
    Level3 = 27,
    Level4 = 41,
    Level5 = 45
}

FindRichieDataHandler.m_skuToFindRichiePick = {
    {productId = AllBuyCFG[1].productId,   pickCount = 3},
    {productId = AllBuyCFG[1].productId,   pickCount = 3},
    {productId = AllBuyCFG[1].productId,   pickCount = 3},
    {productId = AllBuyCFG[1].productId,   pickCount = 3},
    {productId = AllBuyCFG[1].productId,   pickCount = 5},
    {productId = AllBuyCFG[1].productId,   pickCount = 5},
    {productId = AllBuyCFG[1].productId,   pickCount = 5},
    {productId = AllBuyCFG[1].productId,   pickCount = 5},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 10},
    {productId = AllBuyCFG[1].productId,   pickCount = 15},
    {productId = AllBuyCFG[1].productId,   pickCount = 15},
    {productId = AllBuyCFG[1].productId,   pickCount = 15},
    {productId = AllBuyCFG[1].productId,   pickCount = 20},
    {productId = AllBuyCFG[1].productId,   pickCount = 20},
    {productId = AllBuyCFG[1].productId,   pickCount = 20},
    {productId = AllBuyCFG[1].productId,   pickCount = 25},
    {productId = AllBuyCFG[1].productId,   pickCount = 25},
    {productId = AllBuyCFG[1].productId,   pickCount = 30},
    {productId = AllBuyCFG[1].productId,   pickCount = 30},
    {productId = AllBuyCFG[1].productId,   pickCount = 35},
    {productId = AllBuyCFG[1].productId,   pickCount = 35},
    {productId = AllBuyCFG[1].productId,   pickCount = 50},
}

function FindRichieDataHandler:Init()
    if not GameConfig.FINDRICHIE_FLAG then
        return
    end
    self:checkIsActiveTime()

    if self.m_bInitData then
        return
    end

    self.bIsShowHint = true
    self.m_bInitData = true
    self:readFile()
    if self.data.m_nEndTime ~= self.m_nEndTime then
        self:reset()
    end
    self:updateLevelPrize()
end

function FindRichieDataHandler:updateLevelPrize()
    local ratioArray = {1.1, 1.2, 1.3, 1.4, 1.5, 2} --1-5关，还有一个总奖励
    local index = 1
    for i=1,5 do
        self.m_mapPrize["Level"..i] = self:getBasePrize()*50*ratioArray[i]
    end
    self.m_mapPrize["All"] = self:getBasePrize()*50*ratioArray[6]
end

function FindRichieDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function FindRichieDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end

    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

function FindRichieDataHandler:reset()
    self.data = {}
    self.data.m_nVersion = 1
    self.data.bIsGetCompletedGift = false
    self.data.nPickCount = 600
    self.data.fAddPickCountProgress = 0 --收集进度
    self.data.nLevel = 1 -- 第几关
    self.data.mapLevelInfo = {}
    self.data.m_nEndTime = self.m_nEndTime
    self:ResetLevelInfo()
end

function FindRichieDataHandler:SetLevelInfo(nLevel, nIndex)
    self.data.mapLevelInfo[nIndex] = true
    self:writeFile()
end

function FindRichieDataHandler:ResetLevelInfo()
    self.data.nLevel = 1
    self.data.mapLevelInfo = {}
    for i = 1, self.m_mapLevelConfig["Level"..1] do
        self.data.mapLevelInfo[i] = false
    end
    self:writeFile()
end

function FindRichieDataHandler:toNextLevel()
    if self.data.bIsGetCompletedGift then
        return
    end
    
    if self.data.nLevel <= 5 then
        PlayerHandler:AddCoin(self.m_mapPrize["Level"..self.data.nLevel])
    end

    self.data.nLevel = self.data.nLevel + 1
    if self.data.nLevel > 5 then
        PlayerHandler:AddCoin(self.m_mapPrize["All"])
        self.data.bIsGetCompletedGift = true
    else
        self.data.mapLevelInfo = {}
        for i = 1, self.m_mapLevelConfig["Level"..self.data.nLevel] do
            self.data.mapLevelInfo[i] = false
        end
    end
    self:writeFile()
end

function FindRichieDataHandler:addPickCount(count)
    self.data.nPickCount = self.data.nPickCount + count
    self:writeFile()
end

function FindRichieDataHandler:checkIsActiveTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(self.ACTIVETIME) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                self.m_nEndTime = toSecond
                return true
            end
        end
    end
    return false
end

function FindRichieDataHandler:getEndTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()
    for i, v in ipairs(self.ACTIVETIME) do
        local fromStr = v.from
        local toStr = v.to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                return toSecond
            end
        end
    end
    return nil
end

--以1美金为奖励
function FindRichieDataHandler:getBasePrize()
    local nLevel = PlayerHandler.nLevel
    local nBaseLevel = 500
    if nLevel > 500 then
        nLevel = nLevel - 500
        nBaseLevel =  500 + 200 + math.floor( nLevel/200 ) * 200
    end

    local strSkuKey = AllBuyCFG[1].productId

    local levelMultiplier = 1 + math.floor(nBaseLevel / 100)

    local nBasePrize = 0
    for i, v in ipairs(DynamicConfig.coinSkuInfoArray) do
        if(strSkuKey == v.productId) then 
            nBasePrize = v.baseCoins * levelMultiplier
            break
        end
    end

    return nBasePrize
end

function FindRichieDataHandler:refreshAddSpinProgress(data)
    --根据押注大小增加进度

    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.FindRichie)
    
    self.data.fAddPickCountProgress = self.data.fAddPickCountProgress + value
    
    local isMax = self.data.fAddPickCountProgress >= 1

    if isMax then
        while self.data.fAddPickCountProgress >= 1 do
            self.data.fAddPickCountProgress = self.data.fAddPickCountProgress - 1
        end
        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.FindRichie)
        self:addPickCount(nAddCount)
    end
    self:writeFile()
    return isMax
end

function FindRichieDataHandler:getFindRichiePickCount(strSkuKey)
    local bFind = false
    local pickCount = 0
    for i=1,#self.m_skuToFindRichiePick do
        if self.m_skuToFindRichiePick[i].productId == strSkuKey then
            pickCount = self.m_skuToFindRichiePick[i].pickCount
            bFind = true
            break
        end
    end

    Debug.Assert(bFind, strSkuKey)
    return spinCount
end

function FindRichieDataHandler:onPurchaseDoneGiveFindRichieData(data)
    if not GameConfig.FINDRICHIE_FLAG then
        return
    end
    if not FindRichieUnloadedUI.m_bAssetReady then
        return
    end

    if not self:checkIsActiveTime() then
        return
    end

    local userLevel = PlayerHandler.nLevel
    if userLevel < self.m_nUnlockLevel then
        return
    end

    local pickCount = self:getFindRichiePickCount(data.productId)
    self:addPickCount(pickCount)
end