require("Lua.Activity.SlotsCards2020.SlotsCardsConfig")
require("Lua.Activity.SlotsCards2020.SlotsCardsGetCardsPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsGetPackPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsAllProbTable")

require("Lua.Activity.SlotsCards2020.SlotsCardsGiftManager")
require("Lua.Activity.SlotsCards2020.SlotsCardsThemeEndPop")
require("Lua.Activity.SlotsCards2020.SlotsCardsAllThemeEndPop")

SlotsCardsHandler = {}
SlotsCardsHandler.DATAPATH = Unity.Application.persistentDataPath .. "/SlotsCardsHandler.txt"
SlotsCardsHandler.FREEPACKTIMEDIFF = 24 * 3600
SlotsCardsHandler.m_lastTimeMoreCoinsRatio = 1.5

if GameConfig.PLATFORM_EDITOR then
    SlotsCardsHandler.FREEPACKTIMEDIFF = 10
end

function SlotsCardsHandler:Init()
    if CS.System.IO.File.Exists(self.DATAPATH) then
        local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
        local data = rapidjson.decode(strData)
        self.data = data
    else
        self.data = self:GetDbInitData()
    end

    LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
    self:SaveDb()

    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
end

function SlotsCardsHandler:SaveDb()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function SlotsCardsHandler:GetDbInitData()
    local data = {}
    data.nActivityVersion = 0
    data.activityData = {}
    return data
end

function SlotsCardsHandler:GetActivityInitData()
    local data = {}
    data.nTatalStar = 0
    data.m_nGetFreePackTime = 0 --每24小时给玩家一个随机礼包
    data.m_nNextGetFreePackType = SlotsCardsAllProbTable.PackType.One --第一次给一星随机礼包
    data.m_nStampBonusCount = 0 --记录玩家拥有万能卡的个数

    data.m_nOneStarPackCount = 0 --记录玩家拥有一星卡包个数
    data.m_nTwoStarPackCount = 0 --记录玩家拥有二星卡包个数
    data.m_nThreeStarPackCount = 0 --记录玩家拥有三星卡包个数
    data.m_nFourStarPackCount = 0 --记录玩家拥有四星卡包个数
    data.m_nFiveStarPackCount = 0 --记录玩家拥有五星卡包个数

    local albumKey = SlotsCardsManager.album
    data[albumKey] = {}
    data[albumKey].bIsGetCompletedGift = false --记录总奖励是否领取
    data[albumKey].m_mapCardsInfo = {}
    data[albumKey].m_mapCardsStar = {}
    data[albumKey].m_nCompleteAllReward = 0
    data[albumKey].m_arraySetPrize = {}
    data[albumKey].dicThemeProgress = {}
    data[albumKey].m_bIsActiveTime = true

    for j = 1, #SlotsCardsConfig[albumKey] do
        local strThemeKey = SlotsCardsConfig[albumKey][j].ThemeKey
        data[strThemeKey] = {}
        local curThemeParam = data[strThemeKey]
        curThemeParam.nGoldSpinGameCount = 0
        curThemeParam.bIsCompleted = false
        curThemeParam.bHasNew = false
        for k = 1, #SlotsCardsConfig[albumKey][j].ThemeCards do
            local nID = SlotsCardsConfig[albumKey][j].ThemeCards[k].nID
            local strCardKey = strThemeKey..nID
            data[strCardKey] = {}
            data[strCardKey].count = 0
            data[strCardKey].bHasNew = false
        end
    end

    return data
end

function SlotsCardsHandler:InitActivityData()
    self:Init()
    if SlotsCardsManager:orActivityOpen() then
        LuaHelper.FixSimpleDbError(self.data, self:GetDbInitData())
        if self.data.nActivityVersion ~= SlotsCardsManager.m_nVersion then
            self.data.nActivityVersion = SlotsCardsManager.m_nVersion
            self.data.activityData = self:GetActivityInitData()
            self:SaveDb()
        end
        
        LuaHelper.FixSimpleDbError(self.data.activityData, self:GetActivityInitData())
        self:getAllCardsInfoFromConfig()
        self:updateThemeProgress()
        self:updateAllSetPrize()
    else
        self.data.activityData = {}
        self:SaveDb()
    end

end

function SlotsCardsHandler:CheckThemeHasNew(strThemeKey)
    if self.data.activityData[strThemeKey] == nil then
        return false
    end

    if self.data.activityData[strThemeKey].bHasNew ~= nil then
        return self.data.activityData[strThemeKey].bHasNew
    end
    return false
end

function SlotsCardsHandler:SetThemeHasNew(strThemeKey, bHasNew)
    if self.data.activityData[strThemeKey].bHasNew ~= bHasNew then
        self.data.activityData[strThemeKey].bHasNew = bHasNew
        self:SaveDb()
    end
end

function SlotsCardsHandler:CheckCardHasNew(strCardKey)
    if self.data.activityData[strCardKey] == nil then
        return false
    end
    if self.data.activityData[strCardKey].bHasNew ~= nil then
        return self.data.activityData[strCardKey].bHasNew
    end
    return false
end

function SlotsCardsHandler:SetCardHasNew(strCardKey, bHasNew)
    if self.data.activityData[strCardKey].bHasNew ~= bHasNew then
        self.data.activityData[strCardKey].bHasNew = bHasNew
        self:SaveDb()
    end
end

function SlotsCardsHandler:CheckHasCard(strCardKey)
    if self.data.activityData[strCardKey] then
        if self.data.activityData[strCardKey].count > 0 then
            return true
        end
    end
    return false
end

function SlotsCardsHandler:CheckStarCardCount(starCount)
    local curAlbumRunningData = self.data.activityData[SlotsCardsManager.album]
    local count = 0
    for k,v in pairs(curAlbumRunningData.m_mapCardsStar[starCount].Normal) do
        if self:CheckHasCard(v.strCardKey) then
            count = count + 1
        end
    end
    return count
end

-- 更新所有的奖励
function SlotsCardsHandler:updateAllSetPrize()
    local nBasePrize = self:getBasePrize()
    local listPrizeCoefs = {0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.25, 0.275, 0.3,
                        0.325, 0.35, 0.375, 0.4, 0.425, 0.45, 0.475, 0.5, 0.525, 0.55,
                        0.575, 0.6, 0.625, 0.65, 0.675, 0.7}

    local strAlbumKey = SlotsCardsManager.album
    for i=1, #SlotsCardsConfig[strAlbumKey] do
        listPrizeCoefs[i] = 0.05 + 0.015*i
        local themeKey = SlotsCardsConfig[strAlbumKey][i].ThemeKey
        local prize = MoneyFormatHelper.normalizeCoinCount(nBasePrize * listPrizeCoefs[i])
        self.data.activityData[strAlbumKey].m_arraySetPrize[themeKey] = prize
    end
    local totalPrize = MoneyFormatHelper.normalizeCoinCount(nBasePrize * 2.5)
    local isActiveShow = self:checkIsActiveTime()
    local endTime = self:getEndTime()
    if endTime ~= nil and isActiveShow then
        if ((endTime - TimeHandler:GetServerTimeStamp()) // (3600*24)) < 30 then
            totalPrize = totalPrize * self.m_lastTimeMoreCoinsRatio
        end
    end
        
    if strAlbumKey == "Album2" then
        totalPrize = totalPrize * 3
    end
    self.data.activityData[strAlbumKey].m_nCompleteAllReward = totalPrize
    self:SaveDb()
end

-- 以500级时候的商店100美元金币为奖励参考
-- 不考虑vip奖励和商店打折奖励
function SlotsCardsHandler:getBasePrize()
    local basicSkuInfo = AllBuyCFG[1]
    local nBasePrize = FormulaHelper:GetAddMoneyBySpendDollar(basicSkuInfo.nDollar) * FormulaHelper:getVipAndLevelBonusMul()
    return nBasePrize
end

--读取配置表中的卡牌信息
function SlotsCardsHandler:getAllCardsInfoFromConfig()
    for i = 1, 5 do
        local curAlbumRunningData = self.data.activityData[SlotsCardsManager.album]
        curAlbumRunningData.m_mapCardsStar[i] = {}
        curAlbumRunningData.m_mapCardsStar[i].Normal = {}
        curAlbumRunningData.m_mapCardsStar[i].Golden = {}
    end

    local strAlbumKey = SlotsCardsManager.album
    for j=1, #SlotsCardsConfig[strAlbumKey] do
        local curThemeConfig = SlotsCardsConfig[strAlbumKey][j]
        for i=1, #curThemeConfig.ThemeCards do
            local starCount = curThemeConfig.ThemeCards[i].star
            local themeKey = curThemeConfig.ThemeKey
            local cardKey = themeKey .. curThemeConfig.ThemeCards[i].nID
            local cardName = curThemeConfig.ThemeCards[i].CardName

            local cardParam = {}
            cardParam.themeKey = themeKey
            cardParam.starCount = starCount
            cardParam.cardName = cardName
            cardParam.bIsGoldCard = i%(#curThemeConfig.ThemeCards)==0
            cardParam.cardCount = self.data.activityData[cardKey].count

            self.data.activityData[strAlbumKey].m_mapCardsInfo[cardKey] = cardParam
            
            if strAlbumKey == SlotsCardsManager.album then
                local info = {strThemeKey = themeKey, strCardKey = cardKey}
                -- 当前相册里指定星级的卡集合
                local cards = self.data.activityData[SlotsCardsManager.album].m_mapCardsStar[starCount]
                if i == #curThemeConfig.ThemeCards then
                    table.insert( cards.Golden, info)
                else
                    table.insert( cards.Normal, info)
                end
            end
        end
    end

    self:SaveDb()
end

function SlotsCardsHandler:addCard(data)
    for i=1,#data do
        local themeKey = data[i].themeKey
        local cardKey = data[i].cardKey
        local addCount = data[i].count

        local card = self.data.activityData[cardKey]--self.data.activityData[SlotsCardsManager.album].Theme[themeKey].Cards[cardKey]
        local nowCount = card.count
        if nowCount < 1 then
            self:SetCardHasNew(cardKey, true)
        end
        local changeToStarCardCount = 0 --记录多余卡牌的个数
        nowCount = nowCount + addCount
        if nowCount > 1 then
            changeToStarCardCount = addCount
        else
            self:SetThemeHasNew(themeKey, true)
            changeToStarCardCount = 0
        end
        
        card.count = nowCount
        local cardRunningInfo = self.data.activityData[SlotsCardsManager.album].m_mapCardsInfo[cardKey]

        if changeToStarCardCount > 0 then
            self:addTatalStarCount(changeToStarCardCount, cardRunningInfo.starCount, cardRunningInfo.bIsGoldCard)
        end

        if cardRunningInfo.bIsGoldCard then
            self:addFrenzyGame(SlotsCardsManager.album, themeKey)
        end
    end
        
    self:SaveDb()
end

function SlotsCardsHandler:setFreePackTime(nType)
    self.data.activityData.m_nGetFreePackTime = TimeHandler:GetServerTimeStamp()
    self.data.activityData.m_nNextGetFreePackType = nType
    self:SaveDb()
end

function SlotsCardsHandler:getFreePackTime()
    local fTime = self.data.activityData.m_nGetFreePackTime
    return fTime
end

function SlotsCardsHandler:getNextFreePackType()
    return self.data.activityData.m_nNextGetFreePackType
end

function SlotsCardsHandler:addFrenzyGame(albumKey, themeKey)
    local count = self.data.activityData[themeKey].nGoldSpinGameCount
    self.data.activityData[themeKey].nGoldSpinGameCount = count + 1
    self:SaveDb()
end

function SlotsCardsHandler:getTotalStarCount()
    return self.data.activityData.nTatalStar
end

function SlotsCardsHandler:getAllPackCount()
    return self.data.activityData.m_nFiveStarPackCount + self.data.activityData.m_nFourStarPackCount + self.data.activityData.m_nThreeStarPackCount + self.data.activityData.m_nTwoStarPackCount + self.data.activityData.m_nOneStarPackCount
end

function SlotsCardsHandler:addTatalStarCount(addCount, starCount, bIsGoldCard)
    local totalCount = self.data.activityData.nTatalStar
    totalCount = totalCount + addCount * starCount * (bIsGoldCard and 2 or 1)
    self.data.activityData.nTatalStar = totalCount
    self:SaveDb()
end

function SlotsCardsHandler:reduceStarCount(count)
    local totalCount = self.data.activityData.nTatalStar
    totalCount = totalCount - count
    self.data.activityData.nTatalStar = totalCount
    self:SaveDb()
end

function SlotsCardsHandler:getCardIsGoldCard(albumKey, cardKey)
    return self.data.activityData[albumKey].m_mapCardsInfo[cardKey].bIsGoldCard
end

function SlotsCardsHandler:GetThemeProgress(themeKey)
    local strAlbumKey = SlotsCardsManager.album
    local curAlbum = self.data.activityData[strAlbumKey]
    local nCount = 0
    for k,v in pairs(curAlbum.m_mapCardsInfo) do
        if v.cardCount > 0 then
            if v.themeKey == themeKey then
                nCount = nCount + 1
            end
        end
    end
    return nCount
end

function SlotsCardsHandler:updateThemeProgress()
    local strAlbumKey = SlotsCardsManager.album
    --先清空原有的数据
    local curAlbum = self.data.activityData[strAlbumKey]
    for i = 1, #SlotsCardsConfig[strAlbumKey] do
        local themeKey = SlotsCardsConfig[strAlbumKey][i].ThemeKey
        curAlbum.dicThemeProgress[themeKey] = self:GetThemeProgress(themeKey)
    end

    self:SaveDb()
end

function SlotsCardsHandler:updateCurrentThemeProgress(themeKey)
    local strAlbumKey = SlotsCardsManager.album
    local curAlbum = self.data.activityData[strAlbumKey]
    curAlbum.dicThemeProgress[themeKey] = self:GetThemeProgress(themeKey)
    self:SaveDb()
end

function SlotsCardsHandler:getCardStarCount(albumKey, cardKey)
    local starCount = self.data.activityData[albumKey].m_mapCardsInfo[cardKey].starCount
    return starCount
end

function SlotsCardsHandler:getCardName(albumKey, cardKey)
    return self.data.activityData[albumKey].m_mapCardsInfo[cardKey].cardName
end

function SlotsCardsHandler:getOwnCardCount(albumKey)
    if albumKey == nil then
        albumKey = SlotsCardsManager.album
    end
    local count = 0
    local cardsInfo = self.data.activityData[albumKey].m_mapCardsInfo
    for k,v in pairs(cardsInfo) do
        count = count + v.cardCount
    end
    return count
end

function SlotsCardsHandler:getOwnCard(albumKey, cardCount) --用来查询卡牌个数大于cardCount的卡牌数
    if albumKey == nil then
        albumKey = SlotsCardsManager.album
    end
    local count = 0
    local cardsInfo = self.data.activityData[albumKey].m_mapCardsInfo
    for k,v in pairs(cardsInfo) do
        if v.cardCount > cardCount then
            count = count + 1
        end
    end
    return count
end

function SlotsCardsHandler:getAllCardCount(albumKey)
    if albumKey == nil then
        albumKey = SlotsCardsManager.album
    end
    local count = 0
    local cardsInfo = self.data.activityData[albumKey].m_mapCardsInfo
    for k,v in pairs(cardsInfo) do
        count = count + 1
    end
    return count
end

function SlotsCardsHandler:getBaseTB(nLevel) -- 设置任务难度的一个参考
    local strSKuKey = AllBuyCFG[1].productId
	local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
    local nCoins = skuInfo.baseCoins -- 不X打折系数的。。
    return nCoins
end

function SlotsCardsHandler:checkIsActiveTime()
   return SlotsCardsManager:orActivityOpen()
end

function SlotsCardsHandler:getEndTime()
    return SlotsCardsManager.nActivityEndTime
end

function SlotsCardsHandler:checkThemeEnd()
    self:updateAllSetPrize()

    local album = SlotsCardsManager.album
    local bAllCompleted = true
    for k,v in pairs(SlotsCardsConfig[album]) do
        if not self.data.activityData[v.ThemeKey].bIsCompleted then
            bAllCompleted = false
            break
        end
    end

    if not self.data.activityData[album].bIsGetCompletedGift and bAllCompleted then
        local count = self.data.activityData[album].m_nCompleteAllReward
        PlayerHandler:AddCoin(count)
        self.data.activityData[album].bIsGetCompletedGift = true
        self:SaveDb()
        SlotsCardsGiftManager:LogEventThemeCompleted(0)
        LeanTween.delayedCall(0.6, function()
            SlotsCardsAllThemeEndPop:Show()
        end)
        return
    end

    for i = 1, #SlotsCardsConfig[album] do
        local themeKey = SlotsCardsConfig[album][i].ThemeKey
        local ThemeCards = SlotsCardsConfig[album][i].ThemeCards

        Debug.Log(#ThemeCards.." | "..self.data.activityData[album].dicThemeProgress[themeKey])
        if (not self.data.activityData[themeKey].bIsCompleted) and self.data.activityData[album].dicThemeProgress[themeKey] >= #ThemeCards then
            --先添加数据
            local count = self.data.activityData[album].m_arraySetPrize[themeKey]
            PlayerHandler:AddCoin(count)
            self.data.activityData[themeKey].bIsCompleted = true
            self:SaveDb()
            --再做展示
            SlotsCardsThemeEndPop:Show(i)
            return
        end
    end

end

function SlotsCardsHandler:getEndThemeCount()
    local endThemeCount = 0
    for i=1,#SlotsCardsConfig[SlotsCardsManager.album] do
        local themeKey = SlotsCardsConfig[SlotsCardsManager.album][i].ThemeKey
        if self.data.activityData[themeKey].bIsCompleted then
            endThemeCount = endThemeCount + 1
        end
    end
    return endThemeCount
end

function SlotsCardsHandler:addPackCount(nType, count)
    if nType == SlotsCardsAllProbTable.PackType.One then
        self.data.activityData.m_nOneStarPackCount = self.data.activityData.m_nOneStarPackCount + count
    elseif nType == SlotsCardsAllProbTable.PackType.Two then
        self.data.activityData.m_nTwoStarPackCount = self.data.activityData.m_nTwoStarPackCount + count
    elseif nType == SlotsCardsAllProbTable.PackType.Three then
        self.data.activityData.m_nThreeStarPackCount = self.data.activityData.m_nThreeStarPackCount + count
    elseif nType == SlotsCardsAllProbTable.PackType.Four then
        self.data.activityData.m_nFourStarPackCount = self.data.activityData.m_nFourStarPackCount + count
    elseif nType == SlotsCardsAllProbTable.PackType.Five then
        self.data.activityData.m_nFiveStarPackCount = self.data.activityData.m_nFiveStarPackCount + count
    end
    self:SaveDb()

    EventHandler:Brocast("CollectSlotsCardsPacks", {count = count})
end

function SlotsCardsHandler:addStampBonus(count)
    self.data.activityData.m_nStampBonusCount = self.data.activityData.m_nStampBonusCount + count
    self.data.m_nStampBonusRecordTime = TimeHandler:GetServerTimeStamp() + 60*60*2
    self:SaveDb()
end

function SlotsCardsHandler:onPurchaseDoneNotifycation(skuInfo)
    if not SlotsCardsManager:orActivityOpen() then
        return
    end
    
    for i = 1, #SlotsCardsGiftManager.m_skuToSlotsCardsPack do
        if SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].productId == skuInfo.productId then
            local info = SlotsCardsGiftManager.m_skuToSlotsCardsPack[i].info
            self:addPackCount(info.packType, info.packCount)
        end
    end
end
