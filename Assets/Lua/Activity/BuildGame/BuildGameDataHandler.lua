BuildGameDataHandler = {}

BuildGameDataHandler.m_runningData = {}
BuildGameDataHandler.m_data = {}
BuildGameDataHandler.m_data.m_nVersion = 1
BuildGameDataHandler.m_bInitDataFlag = false
--结构：
--BuildGameDataHandler.m_data = {}
--BuildGameDataHandler.m_data.m_nCompleteCount = 0 --记录完成的次数，完成一次重新开始，奖励和难度相应增加
--BuildGameDataHandler.m_data.m_nPlayerLevel = PlayerHandler.nLevel
--BuildGameDataHandler.m_data.Season1 = {}
--BuildGameDataHandler.m_data.Season1.m_bIsGetCompletedGift = false
--BuildGameDataHandler.m_data.Season1.m_nCommonCount = 0
--BuildGameDataHandler.m_data.Season1.m_nRareCount = 0
--BuildGameDataHandler.m_data.Season1.m_nEpicCount = 0
--BuildGameDataHandler.m_data.Season1.m_nLegendaryCount = 0
--BuildGameDataHandler.m_data.Season1.m_nGetFreeDepotsTime = 0     --记录获取freeDepots的时间
--BuildGameDataHandler.m_data.Season1.fullProgress = 0 --收集5星后，收集到的点数存在这里
--BuildGameDataHandler.m_data.Season1.Silver1 = {}
--BuildGameDataHandler.m_data.Season1.Silver1.progress = 0
--BuildGameDataHandler.m_data.Season1.Silver1.level = 0
--BuildGameDataHandler.m_data.Season1.Silver1.getGiftBoxTime = 0   --建筑收集满后每24小时给的奖励，记录时间
--以上类推其他建筑，其他赛季

BuildGameDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 50

BuildGameDataHandler.m_curSeason = "" --匹配活动时间必须对应的处于活动时间，把资源也要替换

BuildGameDataHandler.ACTIVETIME = {
    Season1 = {
        {from = "2019-9-1T00:00:00+0000", to = "2020-11-1T00:00:00+0000"}
    },
    -- Season2 = {
    --     {from = "2020-11-1T00:00:00+0000", to = "2021-11-1T00:00:00+0000"}
    -- }
}

BuildGameDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/BuildGameData.txt"
BuildGameDataHandler.FREEDEPOTSTIMEDIFF = GameConfig.PLATFORM_EDITOR and 60 or 12*3600
BuildGameDataHandler.BUILDGIFTBOXTIMEDIFF = GameConfig.PLATFORM_EDITOR and 60 or 24*3600

function BuildGameDataHandler:init()
    if not GameConfig.BUILDGAME_FLAG then
        return
    end
    self:readFile()
    self:initRunningData()
    self.m_bInitDataFlag = true
    -- self:changePointsToBuildProbs()
end

function BuildGameDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end

    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.m_data = rapidjson.decode(strData)
    if self.m_data.m_curSeason ~= self.m_curSeason then
        self:reset()
    end
end

function BuildGameDataHandler:synNetData(buildCityData)
    self.m_data = buildCityData
    if self.m_data.m_curSeason ~= self.m_curSeason then
        self:reset()
    end
    self:initRunningData()
    self.m_bInitDataFlag = true
    self:writeFile()
end

function BuildGameDataHandler:reset()
    self.m_data = {}
    self.m_data.m_nVersion = 1
    self.m_data.m_curSeason = self.m_curSeason --记录现在是第几个赛季
    self.m_data.m_nCompleteCount = 0 --记录完成的次数，完成一次重新开始，奖励和难度相应增加
    self.m_data.m_nPlayerLevel = PlayerHandler.nLevel
    
    local strSeasonKey = self.m_data.m_curSeason
    self.m_data[strSeasonKey] = {}
    self.m_data[strSeasonKey].m_bIsGetCompletedGift = false
    self.m_data[strSeasonKey].m_nCommonCount = 5
    self.m_data[strSeasonKey].m_nRareCount = 2
    self.m_data[strSeasonKey].m_nEpicCount = 0
    self.m_data[strSeasonKey].m_nLegendaryCount = 0
    self.m_data[strSeasonKey].m_nGetFreeDepotsTime = 0   --记录获取freeDepots的时间，每12小时一个
    self.m_data[strSeasonKey].fullProgress = 0
    for k,v in pairs(BuildGameConfig.Build[strSeasonKey]) do
        self.m_data[strSeasonKey][k] = {}
        self.m_data[strSeasonKey][k].progress = 0
        self.m_data[strSeasonKey][k].level = 0
        self.m_data[strSeasonKey][k].getGiftBoxTime = 0   --建筑收集到5级后每24小时给的奖励，记录时间
    end
    self:writeFile()
end

function BuildGameDataHandler:setFreeDepotsTime()
    self.m_data[self.m_curSeason].m_nGetFreeDepotsTime = TimeHandler:GetServerTimeStamp()
    self:writeFile()
end

function BuildGameDataHandler:setBuildGiftBoxTime(strType)
    local addCoins, param = self:addBuildBoxGift(strType)
    self.m_data[self.m_curSeason][strType].getGiftBoxTime = TimeHandler:GetServerTimeStamp()  
    self:writeFile()
    return addCoins, param--用于UI显示
end

function BuildGameDataHandler:addBuildBoxGift(strType)
    local gift = 1
    local cardPackCount = 1
    local packType = SlotsCardsAllProbTable.PackType.One
    local levelCount = self.m_data[self.m_curSeason][strType].level
    if strType == "Silver1" or strType == "Silver2" or strType == "Silver3" then
        gift = 1
        cardPackCount = 1
        if levelCount == 5 then
            gift = 2
            cardPackCount = 2
        end
        packType = SlotsCardsAllProbTable.PackType.Two

    elseif strType == "Gold1" or strType == "Gold2" or strType == "Gold3" then
        gift = 2
        cardPackCount = 1
        if levelCount == 5 then
            gift = 4
            cardPackCount = 2
        end
        packType = SlotsCardsAllProbTable.PackType.Three

    elseif strType == "Diamond1" or strType == "Diamond2" then
        gift = 4
        cardPackCount = 1
        if levelCount == 5 then
            gift = 8
            cardPackCount = 2
        end

        packType = SlotsCardsAllProbTable.PackType.Four
    end

    local skuInfo = GameHelper:GetSimpleSkuInfoById(AllBuyCFG[1].productId)
    local nBaseTB = skuInfo.baseCoins
    local rewardCoins = nBaseTB * gift
    PlayerHandler:AddCoin(rewardCoins)
    local param = {}
    for i=1,cardPackCount do
        local data = SlotsCardsGiftManager:getPackInBuildGame(packType)
        if data ~= nil then
            table.insert( param, data )
        end
    end
    return rewardCoins, param
end

function BuildGameDataHandler:addDepotsCount(nDepotsType, count)
    if nDepotsType == BuildGameAllProbTable.DepotsType.Common then
        self.m_data[self.m_curSeason].m_nCommonCount = self.m_data[self.m_curSeason].m_nCommonCount + count
    elseif nDepotsType == BuildGameAllProbTable.DepotsType.Rare then
        self.m_data[self.m_curSeason].m_nRareCount = self.m_data[self.m_curSeason].m_nRareCount + count
    elseif nDepotsType == BuildGameAllProbTable.DepotsType.Epic then
        self.m_data[self.m_curSeason].m_nEpicCount = self.m_data[self.m_curSeason].m_nEpicCount + count
    elseif nDepotsType == BuildGameAllProbTable.DepotsType.Legendary then
        self.m_data[self.m_curSeason].m_nLegendaryCount = self.m_data[self.m_curSeason].m_nLegendaryCount + count
    end
    self:writeFile()
end

function BuildGameDataHandler:addBuildProgress(index, progress)
    local strType = ""
    if index == 1 then
        strType = "Silver1"
    elseif index == 2 then
        strType = "Silver2"
    elseif index == 3 then
        strType = "Silver3"
    elseif index == 4 then
        strType = "Gold1"
    elseif index == 5 then
        strType = "Gold2"
    elseif index == 6 then
        strType = "Gold3"
    elseif index == 7 then
        strType = "Diamond1"
    elseif index == 8 then
        strType = "Diamond2"
    end

    if strType == "" then
        return
    end

    local data = self.m_data[self.m_curSeason][strType]
    --TODO 判断该建筑是否收集满
    if data.level >= 5 then
        local point = BuildGameConfig.Build[self.m_curSeason][strType].levels["level5"]
        --用于UI显示，所以不能直接置为0，再次添加时判断是否收集满，满了就置为0
        if self.m_data[self.m_curSeason].fullProgress >= BuildGameConfig.nLegendDepotExp then
            self.m_data[self.m_curSeason].fullProgress = 0
        end

        self:addFullProgress(strType,progress)
        data.progress = point
        self:writeFile()
        return
    end
    data.progress = data.progress + progress
    self:checkIsGetLevelUp(strType, data.progress)

    self:writeFile()
end

function BuildGameDataHandler:checkIsGetLevelUp(strType, progress)
    local data = self.m_data[self.m_curSeason][strType]
    local level = "level"..(data.level+1)
    local point = BuildGameConfig.Build[self.m_curSeason][strType].levels["level5"]
    if data.level >= 5 then
        data.progress = point
        -- self:changePointsToBuildProbs()
        return
    end
    if BuildGameConfig.Build[self.m_curSeason][strType].levels[level] <= progress then
        -- send Reward to player
        PlayerHandler:AddCoin(self.m_runningData[self.m_curSeason].rewardList[strType][data.level+1])

        --升级
        data.progress = progress - BuildGameConfig.Build[self.m_curSeason][strType].levels[level]
        data.level = data.level + 1
        BuildGameManager:LogEventBuildCityCompleted(strType, data.level)
        if data.level >= 5 then
            --到达5级开始收集fullProgress，收集满了给LegendaryDepots
            self:addFullProgress(strType,data.progress)
            data.progress = point
            return
        end
        --再做检查
        self:checkIsGetLevelUp(strType, data.progress)
    end
end

function BuildGameDataHandler:checkIsAllBuildCompleted()
    if self.m_data[self.m_curSeason].m_bIsGetCompletedGift then
        return true, nil
    end
    local bIsAllCompleted = true
    for k,v in pairs(BuildGameConfig.Build[self.m_curSeason]) do
        if self.m_data[self.m_curSeason][k].level < 5 then
            bIsAllCompleted = false
            break
        end
    end
    
    if bIsAllCompleted then
        local reward = self.m_runningData[self.m_curSeason].m_nCompleteAllReward
        BuildGameManager:LogEventBuildCityCompleted(0)
        --TODO 清除数据
        -- self:resetDataAndAddCompleteCount()
        return true, reward
    end
    -- self:writeFile()
    return false
end

function BuildGameDataHandler:writeFile()
    local strData = rapidjson.encode(self.m_data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function BuildGameDataHandler:checkIsActiveTime()
    local nowSecond = TimeHandler:GetServerTimeStamp()

    for k,v in pairs(self.ACTIVETIME) do
        local fromStr = v[1].from
        local toStr = v[1].to
        local fromSecond = TimeHandler:GetTimeStampFromDateString(fromStr)
        local toSecond = TimeHandler:GetTimeStampFromDateString(toStr)
        if (nowSecond >= fromSecond) then
            if nowSecond < toSecond then
                self.m_curSeason = tostring(k)
                return true
            end
        end
    end
    return false
end

function BuildGameDataHandler:addFullProgress(strType, progress)
    local data = self.m_data[self.m_curSeason]
    local typeBuildData = self.m_runningData[self.m_curSeason].build[strType]

    data.fullProgress = data.fullProgress + progress
    if data.fullProgress >= BuildGameConfig.nLegendDepotExp then
        self:addDepotsCount(BuildGameAllProbTable.DepotsType.Legendary,1)
        typeBuildData.fullProgressCount = typeBuildData.fullProgressCount + 1
        progress = data.fullProgress - BuildGameConfig.nLegendDepotExp
        data.fullProgress = 0
        typeBuildData.targetFullProgress = data.fullProgress
        self:addFullProgress(strType, progress)
    else
        typeBuildData.targetFullProgress = data.fullProgress
    end
end

function BuildGameDataHandler:initRunningData()
    local levelMultiplier = 1
    local nPlayerLevel = PlayerHandler.nLevel
    local nBaseLevel = nPlayerLevel + 200

    levelMultiplier = 1 + math.floor(nBaseLevel / 20) / 10

    --每完成一次，奖励增加0.5倍
    local completeCountMultiplier = 1
    if self.m_data.m_nCompleteCount > 0 then
        completeCountMultiplier = completeCountMultiplier+self.m_data.m_nCompleteCount*0.5
    end

    local skuInfo = GameHelper:GetSimpleSkuInfoById(AllBuyCFG[1].productId)
    local nBaseValue = skuInfo.baseCoins * levelMultiplier * completeCountMultiplier

    local strSeasonKey = self.m_curSeason
    self.m_runningData[strSeasonKey] = {}
    self.m_runningData[strSeasonKey].build = {
        Silver1  = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Silver2  = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Silver3  = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Gold1    = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Gold2    = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Gold3    = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Diamond1 = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0},
        Diamond2 = {fullProgress = self.m_data[self.m_curSeason].fullProgress, targetFullProgress = 0, fullProgressCount = 0}
    }

    self.m_runningData[strSeasonKey].m_nCompleteAllReward = 35 * nBaseValue
    self.m_runningData[strSeasonKey].rewardList = {
        Silver1  = {0.005 * nBaseValue, 0.015 * nBaseValue, 0.1 * nBaseValue, 0.3 * nBaseValue, 0.5 * nBaseValue},
        Silver2  = {0.005 * nBaseValue, 0.015 * nBaseValue, 0.1 * nBaseValue, 0.3 * nBaseValue, 0.5 * nBaseValue},
        Silver3  = {0.005 * nBaseValue, 0.015 * nBaseValue, 0.1 * nBaseValue, 0.3 * nBaseValue, 0.5 * nBaseValue},
        Gold1    = {0.015 * nBaseValue, 0.035 * nBaseValue, 0.15 * nBaseValue, 0.5 * nBaseValue, 1.2 * nBaseValue},
        Gold2    = {0.015 * nBaseValue, 0.035 * nBaseValue, 0.15 * nBaseValue, 0.5 * nBaseValue, 1.2 * nBaseValue},
        Gold3    = {0.015 * nBaseValue, 0.035 * nBaseValue, 0.15 * nBaseValue, 0.5 * nBaseValue, 1.2 * nBaseValue},
        Diamond1 = {0.035 * nBaseValue, 0.1 * nBaseValue, 0.6 * nBaseValue, 1.25 * nBaseValue, 2.5* nBaseValue},
        Diamond2 = {0.035 * nBaseValue, 0.1 * nBaseValue, 0.6 * nBaseValue, 1.25 * nBaseValue, 2.5* nBaseValue},
    }
end

function BuildGameDataHandler:resetDataAndAddCompleteCount()
    local data = {}
    data.m_nVersion = 1
    data.m_curSeason = self.m_curSeason --记录现在是第几个赛季
    data.m_nCompleteCount = self.m_data.m_nCompleteCount + 1 --记录完成的次数，完成一次重新开始，奖励和难度相应增加
    data.m_nPlayerLevel = PlayerHandler.nLevel
    local strSeasonKey = self.m_curSeason
    data[strSeasonKey] = {}
    data[strSeasonKey].m_bIsGetCompletedGift = false
    data[strSeasonKey].m_nCommonCount = self.m_data[strSeasonKey].m_nCommonCount
    data[strSeasonKey].m_nRareCount = self.m_data[strSeasonKey].m_nRareCount
    data[strSeasonKey].m_nEpicCount = self.m_data[strSeasonKey].m_nEpicCount
    data[strSeasonKey].m_nLegendaryCount = self.m_data[strSeasonKey].m_nLegendaryCount
    data[strSeasonKey].m_nGetFreeDepotsTime = self.m_data[strSeasonKey].m_nGetFreeDepotsTime
    data[strSeasonKey].fullProgress = 0
    for k,v in pairs(BuildGameConfig.Build[strSeasonKey]) do
        data[strSeasonKey][k] = {}
        data[strSeasonKey][k].progress = 0
        data[strSeasonKey][k].level = 0
        data[strSeasonKey][k].getGiftBoxTime = 0   --建筑收集到5级后每24小时给的奖励，记录时间
    end
    self.m_data = data
    data = nil
    self:writeFile()
    self:initRunningData()
end

function BuildGameDataHandler:sendMangDepots()
    self:addDepotsCount(BuildGameAllProbTable.DepotsType.Legendary,50)
end
---
-- 测试结果: 
-- 1. 每次一张5星卡 大约40到100次左右能凑齐18张
-- 2. 每次可能相同的两张5星卡 大约20到55次左右能凑齐18张
-- 3. 每次两张不同的5星卡 大约15到50次左右能凑齐18张
-- 以上测试没有考虑有3张低概率金卡。。

function BuildGameDataHandler:TestCardPack()
    -- 18张5星卡 
    local count = 0
    local listCards = {}
    
    while true do
        if count > 1000 then
            break
        end
        
        if #listCards == 18 then
            break -- 18张都收集齐了
        end

        count = count + 1

        local index1 = math.random(1, 18)
        local flag = LuaHelper.tableContainsElement(listCards, index1)
        if not flag then
            table.insert(listCards, index1)
        end

        local index2 = math.random(1, 18)
        while index2 == index1 do -- 两张卡不同
            index2 = math.random(1, 18)
        end

        local flag = LuaHelper.tableContainsElement(listCards, index2)
        if not flag then
            table.insert(listCards, index2)
        end

    end

    Debug.Log("--------TestCardPack: " .. count)
end

-- 把16 17 18当3张低概率金卡
-- 每次发两张不同的，大约50到300次左右收集齐。。

function BuildGameDataHandler:TestCardPack2()
    -- 18张5星卡 
    local count = 0
    local listCards = {}
    
    while true do
        if count > 1000 then
            break
        end

        if #listCards == 18 then
            break -- 18张都收集齐了
        end

        count = count + 1

        local index1 = math.random(1, 18)
        while true do
            if index1 > 15 then
                if math.random() < 0.04 then
                    break -- 金卡概率
                end
            else
                break
            end

            index1 = math.random(1, 18)
        end

        local flag = LuaHelper.tableContainsElement(listCards, index1)
        if not flag then
            table.insert(listCards, index1)
        end

        local index2 = math.random(1, 18)
        while index2 == index1 do -- 两张卡不同
            index2 = math.random(1, 18)
        end

        while true do
            if index2 > 15 then
                if math.random() < 0.04 then
                    break -- 金卡概率
                end
            else
                break
            end

            index2 = math.random(1, 18)
        end

        local flag = LuaHelper.tableContainsElement(listCards, index2)
        if not flag then
            table.insert(listCards, index2)
        end

    end

    Debug.Log("--------TestCardPack2: " .. count)
end