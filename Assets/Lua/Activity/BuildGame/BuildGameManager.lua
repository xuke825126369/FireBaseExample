BuildGameManager = {}

BuildGameManager.m_skuToBuildDepots = {
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Rare,    depotsCount = 5},--depotsType==0,1,2,3
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Rare,    depotsCount = 10},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Rare,    depotsCount = 15},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Rare,    depotsCount = 20},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 1},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 2},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 3},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 4},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 5},
    {productId = AllBuyCFG[1].productId,    depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 6},
    {productId = AllBuyCFG[1].productId,    depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 8},
    {productId = AllBuyCFG[1].productId,    depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 10},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 12},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 15},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 20},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 25},
    {productId = AllBuyCFG[1].productId,    depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 30},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 40},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 50},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 60},
    {productId = AllBuyCFG[1].productId,     depotsType = BuildGameAllProbTable.DepotsType.Epic,    depotsCount = 70},
    {productId = AllBuyCFG[1].productId,   depotsType = BuildGameAllProbTable.DepotsType.Legendary,    depotsCount = 1},
}

function BuildGameManager:init()
    if not GameConfig.BUILDGAME_FLAG then
        return
    end
    if not BuildGameDataHandler:checkIsActiveTime() then
        return
    end
    NotificationHandler:addObserver(self, "AddBaseSpin")
    -- NotificationHandler:addObserver(self, "BaseGameSpinEnd")
    NotificationHandler:addObserver(self, "onPurchaseDoneGiveBuildGameDepotsNotifycation")
end

function BuildGameManager:AddBaseSpin(data)
    if not GameConfig.BUILDGAME_FLAG then
        return
    end
    if not BuildGameDataHandler:checkIsActiveTime() then
        return
    end
    -- if not BuildGameUnloadedUI.m_bAssetReady then
    --     return
    -- end
    local userLevel = PlayerHandler.nLevel
    if userLevel < BuildGameDataHandler.m_nUnlockLevel then
        return
    end

    if BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_bIsGetCompletedGift then
        return
    end

    if not data.bFreeSpinFlag then
        local nTotalBet = data.nTotalBet
        local strSKuKey = AllBuyCFG[1].productId
        local skuInfo = GameHelper:GetSimpleSkuInfoById(strSKuKey)
        local nCoins1 = skuInfo.baseCoins -- 不X打折系数的。。
        local fcoef = nTotalBet / nCoins1
        if fcoef < 0.5 then
            fcoef = 0.5 -- 100/0.5 200次spin触发一次depot收集
        end
        if fcoef > 1 then
            fcoef = math.sqrt( fcoef )
        end
        if fcoef > 10 then -- 一次压超过400美元的情况
            fcoef = 10 -- 100/20 5次spin触发一次depot收集
        end

        local bIsGetDepots = self:randomIsGetDepots(fcoef)
    
        if not bIsGetDepots then
            return
        end

        --TODO 得到depots随机得到不同类型depots
        local index = self:randomGetDepots()
        BuildGameDataHandler:addDepotsCount(index, 1)
        
        --TODO 显示获得Depots动画
        BuildGameGetDepotsPop:createAndShow(index, true, 1)
    end
end

function BuildGameManager:onPurchaseDoneGiveBuildGameDepotsNotifycation(data)
    if not GameConfig.BUILDGAME_FLAG then
        return
    end
    if not BuildGameDataHandler:checkIsActiveTime() then
        return
    end
    if PlayerHandler.nLevel < BuildGameDataHandler.m_nUnlockLevel then
        return
    end
    local count = 1
    local depotsType = BuildGameAllProbTable.DepotsType.Epic
    for i=1, #self.m_skuToBuildDepots do
        if data.productId == self.m_skuToBuildDepots[i].productId then
            depotsType = self.m_skuToBuildDepots[i].depotsType
            count = self.m_skuToBuildDepots[i].depotsCount
            Debug.Log("FindDeepChild Depots")
            break
        end
    end
    BuildGameDataHandler:addDepotsCount(depotsType, count)
    --TODO 根据内购的价格不同来给不同的箱子
    BuildGameGetDepotsPop:createAndShow(depotsType, true, count)
end

function BuildGameManager:randomIsGetDepots(fcoef)
    if fcoef == nil then
        fcoef = 1
    end

    local probs = BuildGameAllProbTable.IsGetDepotsProb.probs
    probs = { math.floor( probs[1]/fcoef ), 1}

    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    if nRandomIndex == 1 then
        return false
    end

    return true
end

function BuildGameManager:randomGetDepots()
    local probs = BuildGameAllProbTable.GetDepotsProb.probs

    local nRandomIndex = LuaHelper.GetIndexByRate(probs)
    local index = BuildGameAllProbTable.GetDepotsProb.depotsType[nRandomIndex]
    return index
end

--每12小时，点击获取一个depots
function BuildGameManager:getFreeDepotsClicked()
    local lastTime = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nGetFreeDepotsTime
    local diff = TimeHandler:GetServerTimeStamp() - lastTime
    local offsetTime = BuildGameDataHandler.FREEDEPOTSTIMEDIFF
    if diff < offsetTime then
        return false
    end

    local index = self:randomGetDepots()
    BuildGameDataHandler:addDepotsCount(index, 1)
    BuildGameDataHandler:setFreeDepotsTime()
    BuildGameGetDepotsPop:createAndShow(index, true, 1)
    return true
end

--每一个建筑达到4级后，每24小时有一个Gift礼包，strType指的是建筑的类型（Silver1，Silver2，Silver3，Gold1，Gold2，Gold3...）
function BuildGameManager:getBuildLevelGiftClicked(buildObj)
    local addCoins, param = BuildGameDataHandler:setBuildGiftBoxTime(buildObj.strType)
    buildObj:setGiftBoxUI()

    local isActiveShow = false
    for i=1,#SlotsCardsHandler.m_albumTable do
        local status = SlotsCardsHandler:checkIsActiveTime(i)
        if not isActiveShow then
            isActiveShow = status
        end
    end
    if (not isActiveShow) then
        param = nil
    end
    BuildGameGiftBoxPop:createAndShow(addCoins, param)
end

function BuildGameManager:commonDepotsClicked()
    local count = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nCommonCount
    if count < 1 then
        return false
    end
    BuildGameDataHandler:addDepotsCount(BuildGameAllProbTable.DepotsType.Common, -count)
    local allPoints = 0
    for j=1,count do
        allPoints = allPoints + math.random(70,100) --随机多少个points
    end

    local addProgressInfo = self:randomDistributionBuild(allPoints)

    for i=1,#addProgressInfo do
        if addProgressInfo[i] ~= 0 then
            BuildGameDataHandler:addBuildProgress(i, addProgressInfo[i])
        end
    end
    return true, addProgressInfo, count
end

function BuildGameManager:rareDepotsClicked()
    local count = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nRareCount
    if count < 1 then
        return false
    end
    BuildGameDataHandler:addDepotsCount(BuildGameAllProbTable.DepotsType.Rare, -count)
    local allPoints = 0
    for j=1,count do
        allPoints = allPoints + math.random(350, 620)
    end

    local addProgressInfo = self:randomDistributionBuild(allPoints)

    for i=1,#addProgressInfo do
        if addProgressInfo[i] ~= 0 then
            BuildGameDataHandler:addBuildProgress(i, addProgressInfo[i])
        end
    end
    return true, addProgressInfo, count
end

function BuildGameManager:epicDepotsClicked()
    local count = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nEpicCount
    if count < 1 then
        return false
    end
    BuildGameDataHandler:addDepotsCount(BuildGameAllProbTable.DepotsType.Epic, -count)
    local allPoints = 0
    for j=1,count do
        allPoints = allPoints + math.random(9000, 11000)
    end

    local addProgressInfo = self:randomDistributionBuild(allPoints)

    for i=1,#addProgressInfo do
        if addProgressInfo[i] ~= 0 then
            BuildGameDataHandler:addBuildProgress(i, addProgressInfo[i])
        end
    end
    return true, addProgressInfo, count
end

function BuildGameManager:legendaryDepotsClicked()
    local count = BuildGameDataHandler.m_data[BuildGameDataHandler.m_curSeason].m_nLegendaryCount
    if count < 1 then
        return false
    end
    BuildGameDataHandler:addDepotsCount(BuildGameAllProbTable.DepotsType.Legendary, -count)
    local allPoints = 0
    for j=1,count do
        allPoints = allPoints + math.random(500000, 520000)
    end

    local addProgressInfo = self:randomDistributionBuild(allPoints)

    for i=1,#addProgressInfo do
        if addProgressInfo[i] ~= 0 then
            BuildGameDataHandler:addBuildProgress(i, addProgressInfo[i])
        end
    end
    return true, addProgressInfo, count
end

function BuildGameManager:randomDistributionBuild(allPoints)
    -- local probs = BuildGameAllProbTable.DepotsForBuild.probs
    local addProgressInfo = {}
    local paramBuildType = {} --存储建筑类型

    if allPoints < 10 then --只给1个建筑加点
        paramBuildType = self:getParamBuildType(1)
    elseif allPoints < 100 then --只给2个建筑加点
        paramBuildType = self:getParamBuildType(2)
    elseif allPoints < 500 then --只给3个建筑加点
        paramBuildType = self:getParamBuildType(3)
    elseif allPoints < 1000 then --只给4个建筑加点
        paramBuildType = self:getParamBuildType(4)
    elseif allPoints < 1500 then --只给5个建筑加点
        paramBuildType = self:getParamBuildType(5)
    elseif allPoints < 2000 then --只给6个建筑加点
        paramBuildType = self:getParamBuildType(6)
    elseif allPoints < 2500 then --只给7个建筑加点
        paramBuildType = self:getParamBuildType(7)
    else  --allPoints >= 10000 给8个建筑加点
        paramBuildType = {"Silver1","Silver2","Silver3","Gold1","Gold2","Gold3","Diamond1","Diamond2"}
    end

    -- 2019-10-29
    local nTotal = #paramBuildType
    local fAvg = 1 / nTotal -- 每个建筑都分这么多份。。

    for i=1,8 do
        local buildType = BuildGameMainUIPop:getStrTypeFromIndex(i)
        if addProgressInfo[i] == nil then
            addProgressInfo[i] = 0
        end

        if LuaHelper.tableContainsElement(paramBuildType, buildType) then
            local fcoef = fAvg * (1 + (math.random() - 0.5) *1.3 )
            -- 每个建筑分的比例是 fAvg的0.35到1.65倍
            local nAddValue = math.floor( fcoef * allPoints )
            addProgressInfo[i] = nAddValue
        end
    end

    return addProgressInfo

    --不根据配置概率走，暂时注掉

    -- local denominator = 0 --分母根据paramBuildType个数来累加
    -- for i=1,#paramBuildType do
    --     -- Debug.Log("随机到加点的建筑是："..paramBuildType[i])
    --     denominator = denominator + probs[BuildGameMainUIPop:getIndexFromStrType(paramBuildType[i])]
    -- end
    
    -- for i=1,8 do
    --     local buildType = BuildGameMainUIPop:getStrTypeFromIndex(i)
    --     if addProgressInfo[i] == nil then
    --         addProgressInfo[i] = 0
    --     end
    --     if LuaHelper.tableContainsElement(paramBuildType, buildType) then
    --         local numerator = probs[i] --分子
    --         addProgressInfo[i] = math.floor( allPoints*(numerator/denominator) )
    --     end
    -- end

    -- return addProgressInfo
end

function BuildGameManager:getParamBuildType(count)
    local paramBuildType = {}
    local probs = BuildGameAllProbTable.DepotsForBuild.probs

    --如果有建筑已经升级满了，就不给该建筑点数了，避免进入死循环
    local probsCount = 0
    for i=1,#probs do
        if probs[i] ~= 0 then
            probsCount = probsCount + 1
        end
    end
    if probsCount < count then
        count = probsCount
    end

    while #paramBuildType < count do
        local index = LuaHelper.GetIndexByRate(probs)
        local strBuildType = BuildGameAllProbTable.DepotsForBuild.BuildsType[index]
        if not LuaHelper.tableContainsElement(paramBuildType, strBuildType) then
            table.insert( paramBuildType, strBuildType )
        end
    end
    return paramBuildType
end

function BuildGameManager:LogEventBuildCityCompleted(strThemeKey,level)
	local eventParams = CS.System.Collections.Generic["Dictionary`2[System.String,System.Object]"]()
    local strEventKey = ""
    if strThemeKey == 0 then
        strEventKey = "BuildCityAllCompleted"
    else
        strEventKey = "BuildCityType_" .. strThemeKey.."------星级:"..level
    end
	if GameConfig.RELEASE_VERSION and (not GameConfig.IS_TESTER) then
        FBHandler:FBEvent(strEventKey, eventParams)
    else
        Debug.Log("-------BuildCityEvents-------: " .. strEventKey)
    end
end