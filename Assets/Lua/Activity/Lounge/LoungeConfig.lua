LoungeConfig = {}
LoungeConfig.nLegendDepotExp = 1000000 
LoungeConfig.listChestPoints = {100, 1000, 10000, 500000}
LoungeConfig.N_MEMBER_NEED_POINTS = 15000
LoungeConfig.N_MEMBER_DAY_COUNT = 10

LoungeConfig.enumCHESTTYPE = {
    Common = 1, Rare = 2, Epic = 3, Legendary = 4,
}

LoungeConfig.fTotalPrize = 1500 -- 8个都升级到5星获得的奖励 
-- 等级所需经验以及对应金币奖励 金币奖励是1美元的倍数
LoungeConfig.listPlatinumParam = {{exp = 10, prize = 1.0}, {exp = 1000, prize = 3.0},
                                    {exp = 10000, prize = 15.0}, {exp = 50000, prize = 50.0},
                                    {exp = 200000, prize = 100.0} }
                                    
LoungeConfig.listRoyalParam = {{exp = 20, prize = 2.0}, {exp = 2000, prize = 6.0},
                                {exp = 30000, prize = 30.0}, {exp = 200000, prize = 80.0},
                                {exp = 500000, prize = 150.0} }

LoungeConfig.listMasterParam = {{exp = 100, prize = 3.0}, {exp = 5000, prize = 9.0},
                                {exp = 50000, prize = 50.0}, {exp = 500000, prize = 100.0},
                                {exp = 1000000, prize = 200.0} }


LoungeConfig.listName = {"MermaidMischief", "HotChilli", "SnowWhite", "GrannyWolf",
                "StoryOfMedusa", "LegendOfCleopatra", "CaiShen", "MonkeyKing"}
                
                
LoungeConfig.m_nOneDaySecond = 24 * 3600
LoungeConfig.FREECHESTTIME = 12*3600
LoungeConfig.FREEBONUSTIME = 18*3600

if GameConfig.PLATFORM_EDITOR then
    LoungeConfig.FREECHESTTIME = 30
    LoungeConfig.FREEBONUSTIME = 120
    LoungeConfig.N_MEMBER_DAY_COUNT = 1
end

LoungeConfig.m_lsitSkuChestInfo = {}
for i = 1, #AllBuyCFG do
    local enumType = nil
    if i < 5 then
        enumType = LoungeConfig.enumCHESTTYPE.Common
    elseif i < 10 then
        enumType = LoungeConfig.enumCHESTTYPE.Rare
    elseif i < 15 then
        enumType = LoungeConfig.enumCHESTTYPE.Epic
    else
        enumType = LoungeConfig.enumCHESTTYPE.Legendary
    end
    
    local nLoungePoint = FormulaHelper:GetAddLoungePointBySpendDollar(AllBuyCFG[i].nDollar)
    local info = {productId = AllBuyCFG[i].productId, enumType = enumType, nCount = math.random(1, 5), nLoungePoint = nLoungePoint}
    table.insert(LoungeConfig.m_lsitSkuChestInfo, info)
end

function LoungeConfig:getOneDollarCoins()
    local nCoins = FormulaHelper:GetAddMoneyBySpendDollar(1)
    return nCoins
end

function LoungeConfig:isTriggerChest(nTotalBet)
    if not LoungeHandler:isLoungeMember() then
        return false
    end
    
    local nBaseCoin = self:getOneDollarCoins()
    local fTriggerRate = 0.01
    local fcoef = nTotalBet / nBaseCoin
    fcoef = LuaHelper.Clamp(fcoef, 0.3, 8)
    fTriggerRate = fTriggerRate * fcoef

    local listChestTypeProb = {100000, 10000, 1000, 10}
    local bTrigger = math.random() < fTriggerRate
    local nChestType = LuaHelper.GetIndexByRate(listChestTypeProb)
    return bTrigger, nChestType
end

function LoungeConfig:getFreeBonusParam(nIndex)
    local nLevel, fProgress = self:getMedalLevelInfo(nIndex)
    Debug.Assert(nLevel >= 4)

    local fPrizeCoef = 1
    local cardPackCount = 1
    local packType = SlotsCardsAllProbTable.PackType.One
    
    local nLoungePoint = 0

    if nIndex <= 3 then
        nLoungePoint = 100
        fPrizeCoef = 1.0
        cardPackCount = 2
        packType = SlotsCardsAllProbTable.PackType.Two
        if nLevel == 5 then
            nLoungePoint = 200
            fPrizeCoef = 3.0
            cardPackCount = 3
            packType = SlotsCardsAllProbTable.PackType.Three
        end

    elseif nIndex <= 6 then
        nLoungePoint = 200
        fPrizeCoef = 2.0
        cardPackCount = 2
        packType = SlotsCardsAllProbTable.PackType.Three
        if nLevel == 5 then
            nLoungePoint = 300
            fPrizeCoef = 5.0
            cardPackCount = 3
            packType = SlotsCardsAllProbTable.PackType.Four
        end

    elseif nIndex <= 8 then
        nLoungePoint = 300
        fPrizeCoef = 3.0
        cardPackCount = 2
        packType = SlotsCardsAllProbTable.PackType.Four
        if nLevel == 5 then
            nLoungePoint = 400
            fPrizeCoef = 10.0
            cardPackCount = 3
            packType = SlotsCardsAllProbTable.PackType.Five
        end

    end

    local nBaseTB = self:getOneDollarCoins()
    local rewardCoins = math.floor( nBaseTB * fPrizeCoef )
    
    local param = {cardPackCount = cardPackCount, packType = packType}
    return nLoungePoint, rewardCoins, param
end

-- 返回指定徽章的当前等级升级所需要的经验值 （进度条的分母）
function LoungeConfig:getMedalExpByLevel(nIndex, nLevel)
    Debug.Assert(nLevel > 0, "-------nLevel > 0-------")
    
    local listParam = {}
    if nIndex <= 3 then
        listParam = self.listPlatinumParam
    elseif nIndex <= 6 then
        listParam = self.listRoyalParam
    else
        listParam = self.listMasterParam
    end

    local exp = listParam[nLevel].exp
    return exp
end

-- 返回指定徽章升级到5星还需要的经验值。。用于分配点数的时候不要分配超过5星的点数。。
-- 这是为了简化处理，否则超过5星的部分要用来升级一个传奇箱子太麻烦了。。
function LoungeConfig:getMedalLevelTo5NeedExp(nIndex)
    local listParam = {}
    if nIndex <= 3 then
        listParam = self.listPlatinumParam
    elseif nIndex <= 6 then
        listParam = self.listRoyalParam
    else
        listParam = self.listMasterParam
    end

    local listExp = {0, 0, 0, 0, 0}
    for i=1, 5 do
        local nSum = 0
        for j=1, i do
            nSum = nSum + listParam[j].exp
        end
        listExp[i] = nSum
    end

    
    local data = LoungeHandler.data.activityData.listMedalMasterData
    local fExp = data.listMedalExp[nIndex]
    local fNeedExp = listExp[5] - fExp
    return fNeedExp
end

function LoungeConfig:getMedalLevelInfoByExp(nIndex, fExp)
    local listParam = {}
    if nIndex <= 3 then
        listParam = self.listPlatinumParam
    elseif nIndex <= 6 then
        listParam = self.listRoyalParam
    else
        listParam = self.listMasterParam
    end

    local listExp = {0, 0, 0, 0, 0}
    for i=1, 5 do
        local nSum = 0
        for j=1, i do
            nSum = nSum + listParam[j].exp
        end
        listExp[i] = nSum
    end

    local nLevel = 0 -- 徽章等级 4级或5级的就每天能领取一个免费的礼包
    local fProgress = 0.0
    local nPlayerExp = 0
    local nCurLevelExp = 0

    if fExp >= listExp[5] then
        nLevel = 5
        fProgress = 1.0
        nPlayerExp = listParam[5].exp
        nCurLevelExp = listParam[5].exp
    else
        for i=1, 5 do
            if fExp < listExp[i] then
                nLevel = i-1

                if i == 1 then
                    fProgress = fExp / listExp[1]
                    nPlayerExp = math.floor(fExp)
                    nCurLevelExp = listParam[1].exp
                else
                    fProgress = (fExp - listExp[i-1]) / listParam[i].exp -- listExp[i]
                    nPlayerExp = math.floor(fExp - listExp[i-1])
                    nCurLevelExp = listParam[i].exp
                end

                break
            end
        end
    end

    return nLevel, fProgress, nPlayerExp, nCurLevelExp
end

function LoungeConfig:getMedalLevelInfo(nIndex)
    
    local data = LoungeHandler.data.activityData.listMedalMasterData
    local fExp = data.listMedalExp[nIndex]

    return self:getMedalLevelInfoByExp(nIndex, fExp)
end

function LoungeConfig:getLengendaryProgressByExp(nIndex, fExp)
    local listParam = {}
    if nIndex <= 3 then
        listParam = self.listPlatinumParam
    elseif nIndex <= 6 then
        listParam = self.listRoyalParam
    else
        listParam = self.listMasterParam
    end

    local listExp = {0, 0, 0, 0, 0}
    for i=1, 5 do
        local nSum = 0
        for j=1, i do
            nSum = nSum + listParam[j].exp
        end
        listExp[i] = nSum
    end

    Debug.Assert(fExp >= listExp[5])

    local bFull = false
    local fLengendaryProgress = 0.0
    local fDeltaExp = fExp - listExp[5]
    if fDeltaExp >= self.nLegendDepotExp then
        bFull = true
        fLengendaryProgress = 1.0
    else
        bFull = false
        fLengendaryProgress = fDeltaExp / self.nLegendDepotExp
    end

    return bFull, fLengendaryProgress
end

-- local bFull, fLengendaryProgress = 
function LoungeConfig:getLengendaryProgress(index)
    local fExp = self:getMedalLevelTo5NeedExp(index)
    Debug.Assert(fExp<=0, "----error! getLengendaryProgress-----")
    
    local bFull = false
    local fLengendaryProgress = 0.0
    if math.abs(fExp) >= self.nLegendDepotExp then
        bFull = true
        fLengendaryProgress = 1.0
    else
        bFull = false
        fLengendaryProgress = math.abs(fExp) / self.nLegendDepotExp
    end

    return bFull, fLengendaryProgress
end

function LoungeConfig:isAllMedalCompleted()
    -- 
    -- local data = LoungeHandler.data.activityData.listMedalMasterData
    for i=1, 8 do
        local nLevel, fProgress = self:getMedalLevelInfo(i)
        if nLevel < 5 then
            return false
        end
    end

    return true
end

function LoungeConfig:formatDiffTime(timediff)
    if timediff < 0 then
        timediff = 0
    end
    local days = timediff // (3600*24)
    local hours = timediff // 3600 - 24 * days
    local minutes = timediff // 60 - 24 * days * 60 - 60 * hours
    local seconds = timediff % 60
    
    local strTimeInfo = ""
    if days > 0 then
        strTimeInfo = string.format("%d DAYS LEFT", days + 1)
    else
        strTimeInfo = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    end

    return strTimeInfo
end

function LoungeConfig:getLoungePointToCoinValue(nLoungePoints)
    -- 获得两个皇冠的情况下 再收到的点数就兑换成金币
    local nBaseCoin = self:getOneDollarCoins() * 0.003
    local nCoins = nBaseCoin * nLoungePoints
    return nCoins
end

function LoungeConfig:getLoungeDayPassToCoin(nLoungeDayPass)
    -- 获得两个皇冠的情况下 再收到的点数就兑换成金币
    local nBaseCoin = self:getOneDollarCoins() * 10
    local nCoins = nBaseCoin * nLoungeDayPass
    return nCoins
end

-- 使用Chest的时候如何把点数分配给各个Medal
function LoungeConfig:DistributeLoungePoint(nTotalLoungePoint)
    local listLoungePoints = {0, 0, 0, 0, 0, 0, 0, 0}
    
    local listProb = {10, 10, 10, 10, 10, 10, 10, 10} -- 选中哪个的概率
    local listSelMedalIndex = {}
    
    if nTotalLoungePoint < 50 then --只给1个加点
        -- local index = math.random(1, 3)
        -- listLoungePoints[index] = nTotalLoungePoint
        listProb = {10, 10, 10, 0, 0, 0, 0, 0}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 1)
        
    elseif nTotalLoungePoint < 200 then --只给2个加点
        listProb = {10, 10, 10, 10, 10, 10, 0, 0}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 2)
        
    elseif nTotalLoungePoint < 800 then --只给3个加点
        listProb = {10, 10, 10, 10, 10, 10, 0, 0}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 3)

    elseif nTotalLoungePoint < 1500 then --4
        listProb = {10, 10, 10, 10, 10, 10, 0, 0}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 4)

    elseif nTotalLoungePoint < 2500 then --5
        listProb = {10, 10, 10, 10, 10, 10, 10, 10}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 5)

    elseif nTotalLoungePoint < 3500 then --6
        listProb = {10, 10, 10, 10, 10, 10, 10, 10}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 6)

    elseif nTotalLoungePoint < 5000 then --7
        listProb = {10, 10, 10, 10, 10, 10, 10, 10}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 7)

    else 
        listProb = {10, 10, 10, 10, 10, 10, 10, 10}
        listSelMedalIndex = LuaUtil.PickByWeight(listProb, 8)

    end

    local nTotal = #listSelMedalIndex
    local fAvg = 1 / nTotal -- 每个建筑都分这么多份。。

    for i=1, #listSelMedalIndex do
        local nIndex = listSelMedalIndex[i]
        local fcoef = fAvg * (1 + (math.random() - 0.5) *1.3 )
        -- 每个Medal分的比例是 fAvg的0.35到1.65倍

        local nAddPoint = math.floor( fcoef * nTotalLoungePoint )

        local fNeedExp = self:getMedalLevelTo5NeedExp(nIndex)

        if fNeedExp > 0 and nAddPoint > fNeedExp then
            nAddPoint = fNeedExp
        end

        listLoungePoints[nIndex] = nAddPoint
    end

    return listLoungePoints
end

-- 返回8个medal在使用了这些分配点数之后获得的奖励
-- loungePoint 以及能获得的升级奖励 都在这个方法里给玩家加了。
function LoungeConfig:getLevelUpRewardCoins(listLoungePoints)
    local listLevelUpRewardCoins = {0, 0, 0, 0, 0, 0, 0, 0}
    local data = LoungeHandler.data.activityData.listMedalMasterData
    local nBaseCoins = self:getOneDollarCoins()
    
    for i = 1, 8 do
        local nPrize = 0
        local nPoint = listLoungePoints[i]
        if nPoint > 0 then
            local listParam = {}
            if i <= 3 then
                listParam = self.listPlatinumParam
            elseif i <= 6 then
                listParam = self.listRoyalParam
            else
                listParam = self.listMasterParam
            end

            local nStar1 = self:getMedalLevelInfo(i)
            data.listMedalExp[i] = data.listMedalExp[i] + nPoint -- 这里已经加给玩家了。。

            local nStar2 = self:getMedalLevelInfo(i)
            
            if nStar2 > nStar1 then
                for nStar = nStar1+1, nStar2 do
                    nPrize = nPrize + nBaseCoins * listParam[nStar].prize
                end
            end
        end
        
        if nPrize > 0 then
            PlayerHandler:AddCoin(nPrize) -- 加金币
        end

        listLevelUpRewardCoins[i] = nPrize
    end
    
    LoungeHandler:SaveDb()
    return listLevelUpRewardCoins
end