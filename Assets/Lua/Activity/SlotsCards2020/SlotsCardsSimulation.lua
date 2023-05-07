SlotsCardsSimulation = {}

local bonuStampCount = 0

function SlotsCardsSimulation:beginSimulation(simulationCount, getSettingPackCount)
    self:getCardStarCount()
    local averageSpinCount = 0
    -- local averageGoldCardCount = 0
    local averageoneStarCount,averagetwoStarCount,averagethreeStarCount,averagefourStarCount,averagefiveStarCount = 0,0,0,0,0

    for i=1,simulationCount do
        local nSpinCount = 0
        local bIsComplete = false
        for i=1,getSettingPackCount do
            local CardPackParam = {}
            CardPackParam.cardCount = 6
            CardPackParam.fiveStarMinCount = 3
            CardPackParam.fourStarMinCount = 1
            CardPackParam.threeStarMinCount = 1
            CardPackParam.twoStarMinCount = 1
            local data, gift, access = SlotsCardsGiftManager:getPackInPurchaseSimulation(CardPackParam)

            self:addCard(data, access)
            -- local fProb = math.random()
            -- if fProb < 0.3 then
            --     self:getSettingProbPack(6, 5, 2, "Purchuse")--6张卡，最少2张5星卡
            -- elseif fProb < 0.7 then
            --     self:getSettingProbPack(6, 4, 2, "Purchuse")
            -- else
            --     self:getSettingProbPack(6, 3, 2, "Purchuse")
            -- end
        end
        while (not bIsComplete) do
        -- while nSpinCount <= 10000 do
            self:simulateGetCard()
            nSpinCount = nSpinCount + 1
            self:checkIsThemeComplete(nSpinCount)
            bIsComplete = self:checkIsAllComplete()
        end
        -- averageGoldCardCount = averageGoldCardCount + self:getGoldCardsCount()
        averageSpinCount = averageSpinCount + nSpinCount
        local oneStarCount,twoStarCount,threeStarCount,fourStarCount,fiveStarCount = self:getStarCardsCount()
        averageoneStarCount = averageoneStarCount + oneStarCount
        averagetwoStarCount = averagetwoStarCount + twoStarCount
        averagethreeStarCount = averagethreeStarCount + threeStarCount
        averagefourStarCount = averagefourStarCount + fourStarCount
        averagefiveStarCount = averagefiveStarCount + fiveStarCount
        -- SlotsCardsHandler:reset()
    end

    -- averageGoldCardCount = averageGoldCardCount/simulationCount
    averageSpinCount = averageSpinCount/simulationCount

    averageoneStarCount = averageoneStarCount/simulationCount
    averagetwoStarCount = averagetwoStarCount/simulationCount
    averagethreeStarCount = averagethreeStarCount/simulationCount
    averagefourStarCount = averagefourStarCount/simulationCount
    averagefiveStarCount = averagefiveStarCount/simulationCount

    Debug.Log("SimulationSpinGetCards----------SimulationCount == "..averageSpinCount)
    -- Debug.Log("Simulation GoldCardCount == "..averageGoldCardCount)

    Debug.Log("Simulation oneCardCount == "..averageoneStarCount)
    Debug.Log("Simulation twoCardCount == "..averagetwoStarCount)
    Debug.Log("Simulation threeCardCount == "..averagethreeStarCount)
    Debug.Log("Simulation fourCardCount == "..averagefourStarCount)
    Debug.Log("Simulation fiveCardCount == "..averagefiveStarCount)
    Debug.Log("Simulation bonuStampCount == "..bonuStampCount)
end

function SlotsCardsSimulation:simulateGetCard()
    local isGetPack = SlotsCardsGiftManager:getRandomByRate(SlotsCardsAllProbTable.GetPackProb)
    if isGetPack == 1 then
        return
    end

    local access = "SPIN"
    local strGift = "STAMP PACK"
    local data = SlotsCardsGiftManager:getCardsData()
    self:addCard(data, access)
end

function SlotsCardsSimulation:checkIsThemeComplete(nSpinCount)
    local albumKey = SlotsCardsManager.album
    local curAlbumRunningData = SlotsCardsHandler.data.activityData[albumKey]
    local curAlbumData = SlotsCardsHandler.data.activityData[albumKey]

    for k,v in pairs(SlotsCardsConfig[albumKey]) do
        local themeKey = v.ThemeKey
        if not SlotsCardsHandler.data.activityData[themeKey].bIsCompleted and curAlbumRunningData.dicThemeProgress[themeKey] >= 10 then
            SlotsCardsHandler.data.activityData[themeKey].bIsCompleted = true
            Debug.Log(" SlotsCardsTheme ".. k .." is Completed!!!!! " .. " Use nSpinCount: ".. nSpinCount)
        end
    end
end

function SlotsCardsSimulation:checkIsAllComplete()
    local bAllCompleted = true
    for k,v in pairs(SlotsCardsConfig[SlotsCardsManager.album]) do
        local themeKey = v.ThemeKey
        if not SlotsCardsHandler.data.activityData[themeKey].bIsCompleted then
            bAllCompleted = false
            break
        end
    end
    return bAllCompleted
end

function SlotsCardsSimulation:addCard(data, access)
    for i=1,#data do
        local themeKey = data[i].themeKey
        local cardKey = data[i].cardKey
        local albumKey = SlotsCardsManager.album
        local card = SlotsCardsHandler.data.activityData[cardKey]
        card.count = card.count + data[i].count
        SlotsCardsHandler.data.activityData[albumKey].m_mapCardsInfo[cardKey].cardCount = card.count
        --TODO 如果获得了每个主题的最后一个卡牌，增加进入FrenzyGame的记录
        if SlotsCardsHandler.data.activityData[albumKey].m_mapCardsInfo[cardKey].bIsGoldCard then
            SlotsCardsHandler:addFrenzyGame(albumKey, themeKey)
            self:changeGoldCardToBonusStamp()
        end
    end
    SlotsCardsHandler:updateThemeProgress()
end

function SlotsCardsSimulation:changeGoldCardToBonusStamp()
    local index = FrenzySpinGamePop:GetJackPotRandomIndex()
    if index == 4 then
        local themeKey, cardKey = self:getNotOwnCard()
        if themeKey == nil or cardKey == nil then
            return
        end
        local data = {}
        data[1] = {}
        data[1].themeKey = themeKey
        data[1].cardKey = cardKey
        data[1].count = 1
        self:addCard(data,"FrenzySpin")
        bonuStampCount = bonuStampCount + 1
    end
end

function SlotsCardsSimulation:getNotOwnCard()
    local themeMap = SlotsCardsHandler.data.activityData[SlotsCardsManager.album].Theme
    for k,v in pairs(themeMap) do
        for i,z in pairs(v.Cards) do
            if z.count == 0 then
                return k, i
            end
        end
    end
end

function SlotsCardsSimulation:getStarCardsCount()
    local oneStarCount,twoStarCount,threeStarCount,fourStarCount,fiveStarCount = 0,0,0,0,0
    -- SlotsCardsHandler.data.activityData[albumKey].Theme[themeKey].Cards[cardKey].count
    for k,v in pairs(SlotsCardsHandler.data.activityData[SlotsCardsManager.album].Theme) do
        for i,z in pairs(v.Cards) do
            -- z.count
            local starCount = SlotsCardsHandler:getCardStarCount(SlotsCardsManager.album, i)
            if starCount == 1 then
                oneStarCount = oneStarCount + z.count
            elseif starCount == 2 then
                twoStarCount = twoStarCount + z.count
            elseif starCount == 3 then
                threeStarCount = threeStarCount + z.count
            elseif starCount == 4 then
                fourStarCount = fourStarCount + z.count
            elseif starCount == 5 then
                fiveStarCount = fiveStarCount + z.count
            end
        end
    end
    return oneStarCount,twoStarCount,threeStarCount,fourStarCount,fiveStarCount
end

function SlotsCardsSimulation:getSettingProbPack(cardCount, cardStar, cardStarMin, access)
    local data = {}
    for i=1, cardCount do
        data[i] = {}
        local starCount = 1
        if i > cardStarMin then
            starCount = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetCardFromStar.probs)
        else
            starCount = cardStar
        end

        local isGetGoldCard = LuaHelper.GetIndexByRate(SlotsCardsAllProbTable.GetGoldCard.probs)
        
        -- 最后一个收集活动的key
        -- local strAlbumKey = SlotsCardsManager.album

        -- 最后一个收集相册的运行时数据
        local curAlbumRunningData = SlotsCardsHandler.data.activityData[SlotsCardsManager.album]
        -- 上面这个相册里指定星级的卡片集合
        local cards = curAlbumRunningData.m_mapCardsStar[starCount]
        -- 上面这些卡里的普通卡 和 金卡
        local normalCards = cards.Normal
        local goldenCards = cards.Golden

        local card = {}
        if isGetGoldCard == 1 then
            local index = math.random(1, #normalCards)
            card = normalCards[index]
        else
            local index = math.random(1, #goldenCards)
            card = goldenCards[index]
        end

        data[i].themeKey = card.strThemeKey
        data[i].cardKey = card.strCardKey
        data[i].count = 1
    end
    --添加数据
    self:addCard(data, access)
end

function SlotsCardsSimulation:getCardStarCount()
    local oneStarCardCount,twoStarCardCount,threeStarCardCount,fourStarCardCount,fiveStarCardCount,goldCardCount = 0,0,0,0,0,0
    
    -- 有几个收集卡包集合
    local nAlbumCount = #SlotsCardsHandler.m_albumTable
    -- 最后一个收集活动的key
    local strAlbumKey = SlotsCardsHandler.m_albumTable[nAlbumCount]

    -- 最后一个收集相册的运行时数据
    local curAlbumRunningData = SlotsCardsHandler.data.activityData[strAlbumKey]
    -- 上面这个相册里的所有卡片集合
    -- 按1 2 3 4 5星存的5个子表
    local allCards = curAlbumRunningData.m_mapCardsStar
    
    for i=1,#allCards do
        for j=1,#allCards[i].Normal do
            if i == 1 then
                oneStarCardCount = oneStarCardCount + 1
            elseif i == 2 then
                twoStarCardCount = twoStarCardCount + 1
            elseif i == 3 then
                threeStarCardCount = threeStarCardCount + 1
            elseif i == 4 then
                fourStarCardCount = fourStarCardCount + 1
            elseif i == 5 then
                fiveStarCardCount = fiveStarCardCount + 1
            end
        end
    end
    Debug.Log("1星卡有："..oneStarCardCount)
    Debug.Log("2星卡有："..twoStarCardCount)
    Debug.Log("3星卡有："..threeStarCardCount)
    Debug.Log("4星卡有："..fourStarCardCount)
    Debug.Log("5星卡有："..fiveStarCardCount)
end

-- test
function SlotsCardsSimulation:testCollectCardProb(nCardNum, fProb)
    local listCounts = {}
    -- local nCardNum = 50
    for i=1, nCardNum do
        listCounts[i] = 0
    end

    local nSimuNum = 0
    local listOldCard = {}
    -- 每次随机 fProb 的概率从已有卡牌里取 1-fProb 的概率正常随机
    while true do
        nSimuNum = nSimuNum + 1
        local nIndex = 1
        if nSimuNum > 1 and math.random() < fProb then
            local nOldCards = #listOldCard
            local nOffset = math.random(1, nOldCards)
            nIndex = listOldCard[nOffset]
        else
            nIndex = math.random(1, nCardNum)
            if listCounts[nIndex] == 0 then -- 取到新卡了
                table.insert(listOldCard, nIndex)
            end
        end
        listCounts[nIndex] = listCounts[nIndex] + 1

        local bFinish = true
        for i=1, nCardNum do
            if listCounts[i] == 0 then
                bFinish = false
                break
            end
        end
        if bFinish then
            break
        end
    end

    local nMax = 0
    for i=1, nCardNum do
        if listCounts[i] > nMax then
            nMax = listCounts[i]
        end
    end

    return nSimuNum, nMax
    -- Debug.Log("-------------nSimuNum: " .. nSimuNum)
    -- Debug.Log("-------------nMaxCard: " .. nMax)
end
