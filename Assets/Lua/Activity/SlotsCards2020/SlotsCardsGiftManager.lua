SlotsCardsGiftManager = {}

SlotsCardsGiftManager.GiftTable = {
    "STAMP CARD",
    "STAMP PACK"
}

SlotsCardsGiftManager.m_skuToSlotsCardsPack = {}
for i = 1, #AllBuyCFG do
    local info = {}
    info.packCount = i // 2 + 1
    if i < 10 then
        info.packType = SlotsCardsAllProbTable.PackType.Three
    elseif i < 15 then
        info.packType = SlotsCardsAllProbTable.PackType.Four
    else
        info.packType = SlotsCardsAllProbTable.PackType.Five
    end
        
    SlotsCardsGiftManager.m_skuToSlotsCardsPack[i] = {productId = AllBuyCFG[i].productId, info = info}
end

function SlotsCardsGiftManager:Init()
    EventHandler:AddListener("onLevelUp", self)
    EventHandler:AddListener("AddBaseSpin", self)
    
    EventHandler:AddListener("ShowBonusStampPop", self)
    EventHandler:AddListener("getSettingPack", self)
    EventHandler:AddListener("onPurchaseDoneNotifycation", self)
end

function SlotsCardsGiftManager:getPackInFrenzySpinGame()
    SlotsCardsHandler:addPackCount(SlotsCardsAllProbTable.PackType.Five, 1)
    return {packType = SlotsCardsAllProbTable.PackType.Five, packCount = 1}
end

function SlotsCardsGiftManager:getPackInLevelUp()
    if not SlotsCardsManager:orUnLock() then
        return
    end

    SlotsCardsHandler:addPackCount(SlotsCardsAllProbTable.PackType.Four, 1)
    LeanTween.delayedCall(2.5, function()
        SlotsCardsGetPackPop:Show(SlotsCardsAllProbTable.PackType.Four, true, 1)
    end)
    
end

function SlotsCardsGiftManager:getPackInBuildGame(packType)
    if not SlotsCardsManager:orActivityOpen() then
        return
    end

    SlotsCardsHandler:addPackCount(packType, 1)
    return {packType = packType, packCount = 1}
end

function SlotsCardsGiftManager:getPackInFriendGift()
    local access = "FRIEND'S GIFTS"
    local data = self:getCardsData()
    return data, access
end

--其他活动获得卡牌API
function SlotsCardsGiftManager:getStampPackInActive(nType, count)
    if not SlotsCardsManager:orActivityOpen() then
        return
    end

    SlotsCardsHandler:addPackCount(nType, count)
    EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
    return {packType = nType, packCount = count}
end

function SlotsCardsGiftManager:randomGetCards(fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
    local starCount = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetCardFromStar.probs)
    if fiveStarMinCount ~= nil and fiveStarMinCount > 0 then
        starCount = 5
    else
        if fourStarMinCount ~= nil and fourStarMinCount > 0 then
            starCount = 4
        else
            if threeStarMinCount ~= nil and threeStarMinCount > 0 then
                starCount = 3
            else
                if twoStarMinCount ~= nil and twoStarMinCount > 0 then
                    starCount = 2
                end
            end
        end
    end
    
    local themeKey,cardKey = "", ""
    local nGetGoldCardIndex = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetGoldCard.probs)
    local strAlbumKey = SlotsCardsManager.album
    -- 收集相册的运行时数据
    local curAlbumRunningData = SlotsCardsHandler.data.activityData[strAlbumKey]
    -- 上面这个相册里的所有卡片集合
    -- 按1 2 3 4 5星存的5个子表
    local allCards = curAlbumRunningData.m_mapCardsStar
    local cards = allCards[starCount]

    local card = {}
    if nGetGoldCardIndex == 1 then
        local fCoef = 0.5
        if SlotsCardsHandler:CheckStarCardCount(starCount) > 10 then
            fCoef = 0.5
        else
            fCoef = 0
        end

        if SlotsCardsStarShopPop.m_bTestAllCompletedFlag then
            fCoef = 0
        end

        if math.random() < fCoef then
            -- 从已有的卡里去取 todo
            local index = math.random(1, #cards.Normal)
            card = cards.Normal[index]
            -- card.strCardKey
            while not SlotsCardsHandler:CheckHasCard(card.strCardKey) do
                local index = math.random(1, #cards.Normal)
                card = cards.Normal[index]
            end
        else
            local index = math.random(1, #cards.Normal)
            card = cards.Normal[index]

            if SlotsCardsStarShopPop.m_bTestAllCompletedFlag then
                local nTemp = 1
                while SlotsCardsHandler:CheckHasCard(card.strCardKey) do
                    local index = math.random(1, #cards.Normal)
                    card = cards.Normal[index]
                    nTemp = nTemp + 1
                    if nTemp > 50 then
                        break
                    end
                end
            end
        end
    else
        local index = math.random(1, #cards.Golden)
        card = cards.Golden[index]
    end
    themeKey = card.strThemeKey
    cardKey = card.strCardKey

    return themeKey, cardKey , starCount
end

-- 商店里24小时奖励一个免费卡包
function SlotsCardsGiftManager:randomGetPack()
    local probs = SlotsCardsAllProbTable.GetPackTypeProb.probs
    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    return nRandomIndex
end

function SlotsCardsGiftManager:getCardsData(setCardCount, fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
    local cardCount = setCardCount
    local bHasGoldCard = false
    local nGoldCardIndex = 0

    local data = {}
    local i = 1
    while i <= cardCount do
        data[i] = {}
        local themeKey, cardKey, starCount = self:randomGetCards(fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
        local bHasSameCard = false

        local curAlbum = SlotsCardsHandler.data.activityData[SlotsCardsManager.album]
        local bIsGoldCard = curAlbum.m_mapCardsInfo[cardKey].bIsGoldCard
        --记录第一个获得的金卡在卡包内的索引
        if (not bHasGoldCard) and bIsGoldCard then
            bHasGoldCard = true
            nGoldCardIndex = i
        end
        data[i].themeKey = themeKey
        data[i].cardKey = cardKey
        data[i].count = 1
        for j=1, #data do
            if j ~= i then
                --判断是否有大于一张的金卡，如果有重新随机，直到随机到普通卡
                if bHasGoldCard and bIsGoldCard then
                    if nGoldCardIndex ~= i then
                        i = i - 1
                        bHasSameCard = true
                        break
                    end
                end
                --判断随机到的卡牌与前面的卡牌是否相同，如果相同重新随机
                if themeKey == data[j].themeKey and cardKey == data[j].cardKey then
                    i = i - 1
                    bHasSameCard = true
                    break
                end
            end
        end
        if not bHasSameCard then
            if fiveStarMinCount ~= nil and starCount == 5 then
                fiveStarMinCount = fiveStarMinCount - 1
            end
            if fourStarMinCount ~= nil and starCount == 4 then
                fourStarMinCount = fourStarMinCount - 1
            end
            if threeStarMinCount ~= nil and starCount == 3 then
                threeStarMinCount = threeStarMinCount - 1
            end
            if twoStarMinCount ~= nil and starCount == 2 then
                twoStarMinCount = twoStarMinCount - 1
            end
        end
        i = i + 1
    end
    return data
end

function SlotsCardsGiftManager:ShowBonusStampPop()
    if SlotsCardsManager:orActivityOpen() then
        return
    end
    
    if SlotsCardsHandler.data.activityData.m_nStampBonusCount <= 0 then
        return
    end

    if SlotsCardsHandler.data.activityData[SlotsCardsManager.album].bIsGetCompletedGift then
        return
    end

    local leftTime = SlotsCardsHandler.data.activityData.m_nStampBonusRecordTime - TimeHandler:GetServerTimeStamp()
    if leftTime < 0  then
        SlotsCardsHandler.data.activityData.m_nStampBonusCount = 0
        SlotsCardsHandler:SaveDb()
        return
    end
    
    SlotsCardsMainUIPop:ShowBonusStampUI()
end

-- 获得指定的卡牌包事件
function SlotsCardsGiftManager:getSettingPack(data)
    local cardData = data.cardData
    local strGift = data.strGift
    local access = data.access
    SlotsCardsGetCardsPop:Show(cardData)
end

function SlotsCardsGiftManager:AddBaseSpin(data)
    if not SlotsCardsManager:orUnLock() then
        return
    end

    local nTotalBet = data.nTotalBet
    local tableRate =  SlotsCardsAllProbTable.GetPackProb.probs
    local bHaveGift = LuaHelper.GetIndexByRate(tableRate) == 2
    if not bHaveGift then
        return
    end

    local fcoef = nTotalBet / FormulaHelper:GetAddMoneyBySpendDollar(1)
    fcoef = LuaHelper.Clamp(fcoef, 1, 10)
    local probs = {200 // fcoef, 90, 20, 5, 1}
    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    local index = nRandomIndex
    SlotsCardsHandler:addPackCount(index, 1)

    SceneSlotGame.m_bUIState = true
    LeanTween.delayedCall(0.1, function()
        SceneSlotGame.m_bUIState = false
        SlotsCardsGetPackPop:Show(index, true, 1)
    end)

end 

function SlotsCardsGiftManager:onLevelUp()
    if not SlotsCardsManager:orUnLock() then
        return
    end

    self:getPackInLevelUp()
end

--nType 为枚举类型 0-5
function SlotsCardsGiftManager:getCardPackParam(nType)
    local CardPackParam = {}
    local info = SlotsCardsAllProbTable.PackTypeToGift[nType]

    local cardCount = info.setCardCount
    local fiveStarMinCount = 0
    local fourStarMinCount = 0
    local threeStarMinCount = 0
    local twoStarMinCount = 0

    if info.starCount == 2 then
        twoStarMinCount = info.minCardCount
    elseif info.starCount == 3 then
        threeStarMinCount = info.minCardCount
    elseif info.starCount == 4 then
        fourStarMinCount = info.minCardCount
    elseif info.starCount == 5 then
        fiveStarMinCount = info.minCardCount
    end
    
    CardPackParam.cardCount = cardCount
    CardPackParam.fiveStarMinCount = fiveStarMinCount
    CardPackParam.fourStarMinCount = fourStarMinCount
    CardPackParam.threeStarMinCount = threeStarMinCount
    CardPackParam.twoStarMinCount = twoStarMinCount
    return CardPackParam
end

function SlotsCardsGiftManager:onPurchaseDoneNotifycation(data)
    if not SlotsCardsManager:orActivityOpen() then
        return
    end
    EventHandler:Brocast("OnSlotsCardsActivityStateChanged")
end

function SlotsCardsGiftManager:getCardsDataFormHadCards(setCardCount, fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
    local cardCount = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.PackCardsCount.probs)
    if setCardCount ~= nil then
        cardCount = setCardCount
    end

    local bHasGoldCard = false
    local nGoldCardIndex = 0

    local data = {}
    local i = 1
    while i <= cardCount do
        data[i] = {}
        local themeKey, cardKey, starCount = self:randomGetCardsFromHadCards(fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
        local bHasSameCard = false

        local curAlbum = SlotsCardsHandler.data.activityData[SlotsCardsManager.album]
        local bIsGoldCard = curAlbum.m_mapCardsInfo[cardKey].bIsGoldCard

        if (not bHasGoldCard) and bIsGoldCard then
            bHasGoldCard = true
            nGoldCardIndex = i
        end
        data[i].themeKey = themeKey
        data[i].cardKey = cardKey
        data[i].count = 1
        for j = 1, #data do
            if j ~= i then
                --判断是否有大于一张的金卡，如果有重新随机，直到随机到普通卡
                if bHasGoldCard and bIsGoldCard then
                    if nGoldCardIndex ~= i then
                        i = i - 1
                        bHasSameCard = true
                        break
                    end
                end
                --判断随机到的卡牌与前面的卡牌是否相同，如果相同重新随机
                if themeKey == data[j].themeKey and cardKey == data[j].cardKey then
                    i = i - 1
                    bHasSameCard = true
                    break
                end
            end
        end

        if not bHasSameCard then
            if fiveStarMinCount ~= nil and starCount == 5 then
                fiveStarMinCount = fiveStarMinCount - 1
            end

            if fourStarMinCount ~= nil and starCount == 4 then
                fourStarMinCount = fourStarMinCount - 1
            end

            if threeStarMinCount ~= nil and starCount == 3 then
                threeStarMinCount = threeStarMinCount - 1
            end

            if twoStarMinCount ~= nil and starCount == 2 then
                twoStarMinCount = twoStarMinCount - 1
            end
        end
        i = i + 1
    end

    return data
end

function SlotsCardsGiftManager:randomGetCardsFromHadCards(fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
    local starCount = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetCardFromStar.probs)
    if fiveStarMinCount ~= nil and fiveStarMinCount > 0 then
        starCount = 5
    else
        if fourStarMinCount ~= nil and fourStarMinCount > 0 then
            starCount = 4
        else
            if threeStarMinCount ~= nil and threeStarMinCount > 0 then
                starCount = 3
            else
                if twoStarMinCount ~= nil and twoStarMinCount > 0 then
                    starCount = 2
                end
            end
        end
    end
    
    local themeKey,cardKey = "", ""
    local nGetGoldCardIndex = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetGoldCard.probs)
    local strAlbumKey = SlotsCardsManager.album
    -- 收集相册的运行时数据
    local curAlbumRunningData = SlotsCardsHandler.data.activityData[strAlbumKey]
    -- 上面这个相册里的所有卡片集合
    -- 按1 2 3 4 5星存的5个子表
    local allCards = curAlbumRunningData.m_mapCardsStar
    local cards = allCards[starCount]

    local card = {}
    if nGetGoldCardIndex == 1 then
        while true do
            local index = math.random(1, #cards.Normal)
            card = cards.Normal[index]
            local cardsInfo = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].m_mapCardsInfo
            if cardsInfo[card.strCardKey].cardCount ~= 0 then
                --如果已经有了这张牌直接break
                break
            else
                --如果没有这张牌，50%概率留下 50%的概率继续随机
                local randomNum = math.random()
                if randomNum < 0.5 then
                    break
                end
            end
        end
    else
        local index = math.random(1, #cards.Golden)
        card = cards.Golden[index]
    end
    
    themeKey = card.strThemeKey
    cardKey = card.strCardKey
    
    return themeKey, cardKey , starCount
end

--这里已经添加进入数据库
function SlotsCardsGiftManager:OnPackClicked(nPackType)
    local count = 0
    if nPackType == SlotsCardsAllProbTable.PackType.One then
        count = SlotsCardsHandler.data.activityData.m_nOneStarPackCount
    elseif nPackType == SlotsCardsAllProbTable.PackType.Two then
        count = SlotsCardsHandler.data.activityData.m_nTwoStarPackCount
    elseif nPackType == SlotsCardsAllProbTable.PackType.Three then
        count = SlotsCardsHandler.data.activityData.m_nThreeStarPackCount
    elseif nPackType == SlotsCardsAllProbTable.PackType.Four then
        count = SlotsCardsHandler.data.activityData.m_nFourStarPackCount
    elseif nPackType == SlotsCardsAllProbTable.PackType.Five then
        count = SlotsCardsHandler.data.activityData.m_nFiveStarPackCount
    end
    
    if count < 1 then
        return false
    end
    SlotsCardsHandler:addPackCount(nPackType, -count)
    local allPackData = {}
    for i = 1, count do
        local cardParams = self:getCardPackParam(nPackType)
        local data = self:getCardsData(cardParams.cardCount, cardParams.fiveStarMinCount, cardParams.fourStarMinCount, cardParams.threeStarMinCount, cardParams.twoStarMinCount)
        SlotsCardsHandler:addCard(data)
        table.insert(allPackData, data)
    end
    
    return true, allPackData
end

-- Simulation
function SlotsCardsGiftManager:getPackInPurchaseSimulation(CardPackParam)
    local access = "PURCHASE"

    local cardCount = CardPackParam.cardCount
    local fiveStarMinCount = CardPackParam.fiveStarMinCount
    local fourStarMinCount = CardPackParam.fourStarMinCount
    local threeStarMinCount = CardPackParam.threeStarMinCount
    local twoStarMinCount = CardPackParam.twoStarMinCount
    local data = self:getCardsData(cardCount, fiveStarMinCount, fourStarMinCount, threeStarMinCount, twoStarMinCount)
    return data, self.GiftTable[2], access
end