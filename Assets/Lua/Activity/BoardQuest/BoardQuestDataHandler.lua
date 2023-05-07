BoardQuestDataHandler = {}

BoardQuestDataHandler.data = {}
BoardQuestDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/BoardQuest.txt"
BoardQuestDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 5
BoardQuestDataHandler.m_mapPrize = {} --LevelFinal的金币奖励
BoardQuestDataHandler.m_mapDishPrize = {} --每道菜的金币奖励

function BoardQuestDataHandler:Init()
    if not GameConfig.BOARDQUEST_FLAG then
        return
    end
    self:readFile()
    if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
        self:reset()
        self.data.endTime = ActiveManager.nActivityEndTime
    end
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    --self:Simulation()
end

function BoardQuestDataHandler:reset()
    self.data = {}
    self.data.nAction = 5
    self.data.fProgress = 0 --收集进度

    self.data.tableNBoosterEndTime =  LuaHelper.GetTable(0, 3)
    self.data.fFinalPrizeRatioMutiplier = 1
    self:resetGameData()

    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 1 then
        self.data.nAction = BoardQuestConfig.N_MAX_ACTION - 2
        self.data.nLevel = 5
    end
end

function BoardQuestDataHandler:getNetData()
    local netData = {}
    --netData.endTime = self.data.endTime
    netData.nAction = self.data.nAction
    --netData.nLevel = self.data.nLevel
    netData.tableNBoosterEndTime = self.data.tableNBoosterEndTime
    return netData
end

function BoardQuestDataHandler:synNetData(netData)
    --self.data.endTime = netData.endTime
    self.data.nAction = netData.nAction
    --self.data.nLevel = netData.nLevel
    self.data.tableNBoosterEndTime = netData.tableNBoosterEndTime
    -- if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
    --     self:reset()
    --     self.data.endTime = ActiveManager.nActivityEndTime
    -- end
    self:writeFile()
end

function BoardQuestDataHandler:resetGameData()
    self.data.nLevel = 1
    self.data.nPosition = 1
    self.data.nMonsterHp = BoardQuestConfig.MONSTER_HP[1] --怪物的血量
end

function BoardQuestDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function BoardQuestDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end
    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

function BoardQuestDataHandler:AddBoosterEndTime(nAddTime, i)
    if self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp() then
        self.data.tableNBoosterEndTime[i] = self.data.tableNBoosterEndTime[i] + nAddTime
    else
        self.data.tableNBoosterEndTime[i] = TimeHandler:GetServerTimeStamp() + nAddTime
    end
end

function BoardQuestDataHandler:checkInBoosterTime(i)
    return self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp()
end

function BoardQuestDataHandler:refreshAddSpinProgress(data)
    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.BoardQuest)
    self.data.fProgress = self.data.fProgress + value
    
    local bProgressReachMax = self.data.fProgress >= 1
    local bActionReachMax = false
    if bProgressReachMax then
        while self.data.fProgress >= 1 do
            self.data.fProgress = self.data.fProgress - 1
        end
        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.BoardQuest)
        if self:checkInBoosterTime(BoardQuestIAPConfig.TYPE.DICE_BOOSTER) then
            nAddCount = nAddCount * 2
        end
        if self.data.nAction + nAddCount >= BoardQuestConfig.N_MAX_ACTION then
            bActionReachMax = true
            nAddCount = math.max(BoardQuestConfig.N_MAX_ACTION - self.data.nAction, 0)
        end
        self.data.nAction = self.data.nAction + nAddCount
    end
    self:writeFile()
    return bProgressReachMax, bActionReachMax
end

function BoardQuestDataHandler:onPurchaseDoneNotifycation(data)
    if ActiveManager.activeType ~= ActiveType.BoardQuest then return end
    local skuInfo = data.skuInfo
    if skuInfo.nType == SkuInfoType.BoardQuest then
        --BoardQuest里的商店内购
        local skuMap = BoardQuestIAPConfig.skuMap[skuInfo.nActiveIAPType]
        local info = skuMap[data.productId]
        ActivityHelper:AddMsgCountData("nAction", info.nAction)
        self:AddBoosterEndTime(info.nTime, skuInfo.nActiveIAPType)
    else
        --BoardQuest以外的内购给Action
        local nAction = BoardQuestIAPConfig.skuMapOther[data.productId]
        ActivityHelper:AddMsgCountData("nAction", nAction)
    end
    self:writeFile()
end

function BoardQuestDataHandler:Simulation()
    Debug.Log("BoardQuestDataHandler:Simulation()")
    --重置数值
    self.data.tableNBoosterEndTime =  LuaHelper.GetTable(0, 3)
    self:resetGameData()

    local nTotalTestTime = 10
    local nTotalActionCount = 0
    self.nSimuTotalWinCoin = 0
    self.nSimuFinishedCount = 0
    self.bSimuFinishedGame = false
    self.nSimuRewardActionCount = 0

    self.tableSimuItemCount = LuaHelper.ShiftIndex( LuaHelper.GetTable(0, 6))
    self.tableSimuActionCount =  LuaHelper.GetTable(0, 5)
    self.tableSimuRewardActionCount =  LuaHelper.GetTable(0, 5)

    for nTestTime = 1, nTotalTestTime do
        self.bSimuFinishedGame = false
        for i = 1, 1000 do
            nTotalActionCount = nTotalActionCount + 1
            self.tableSimuActionCount[BoardQuestDataHandler.data.nLevel] = self.tableSimuActionCount[BoardQuestDataHandler.data.nLevel] + 1
            local nDice1 = math.random(1, 6)
            local nDice2 = math.random(1, 6)
            local nMoveCount = nDice1 + nDice2   
            self:SimuMove(nMoveCount) 
            if self.bSimuFinishedGame then break end
        end
        self:resetGameData()
    end

    local strFile = ""
    strFile = strFile.."nSimuFinishedCount "..self.nSimuFinishedCount.."\n"
    strFile = strFile.."\n"
    --local nAverageTotalLevelPrize = nTotalLevelPrize/nTotalTestTime
    local nAverageActionCount = nTotalActionCount / nTotalTestTime
    local nAverageRewardAction = self.nSimuRewardActionCount / nTotalTestTime
    local nAverageWinCoin = self.nSimuTotalWinCoin / nTotalTestTime


    strFile = strFile..string.format("消耗 %s 个骰子 （要用 %s 个 奖励 %s 个）\n", nAverageActionCount - nAverageRewardAction, nAverageActionCount, nAverageRewardAction)

    strFile = strFile.."金币奖励 "..nAverageWinCoin.."\n"
    strFile = strFile.."\n"
    for i = 0, 5 do
        local nAverageSimuItemCount = self.tableSimuItemCount[i] / nTotalTestTime
        strFile = strFile..string.format("踩中了 %s %s 次\n", BoardQuestConfig.ITEM_KEY[i], nAverageSimuItemCount)
    end

    strFile = strFile.."\n"
    for i = 1, 5 do
        local nAverageActionCount = self.tableSimuActionCount[i] / nTotalTestTime
        local nAverageRewardActionCount = self.tableSimuRewardActionCount[i] / nTotalTestTime
        strFile = strFile..string.format("第 %s 关 平均消耗 %s 个骰子 （要用 %s 个 奖励 %s 个）\n", i, nAverageActionCount - nAverageRewardActionCount, nAverageActionCount, nAverageRewardActionCount)
    end

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir.."BoardQuest.txt"
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end

function BoardQuestDataHandler:SimuMove(nTotalMoveCount)
    local nLevel = BoardQuestDataHandler.data.nLevel
    local nTarget = LuaHelper.Loop(BoardQuestDataHandler.data.nPosition + nTotalMoveCount, 1, BoardQuestConfig.ROAD_ITEM_COUNT[nLevel])
    BoardQuestDataHandler.data.nPosition = nTarget
    local nItem = BoardQuestConfig.ROAD[nLevel][nTarget]

    if nItem == BoardQuestConfig.ITEM.MORE_CANNON then
        nItem = BoardQuestConfig.ITEM.NONE
        -- if BoardQuestDataHandler:checkInBoosterTime(BoardQuestIAPConfig.TYPE.MORE_CANNON) then
        --     nItem = BoardQuestConfig.ITEM.CANNON
        -- else
        --     nItem = BoardQuestConfig.ITEM.NONE
        -- end
    end

    self.tableSimuItemCount[nItem] = self.tableSimuItemCount[nItem] + 1

    if nItem == BoardQuestConfig.ITEM.CANNON then
        local nTargetIndex = LuaHelper.GetIndexByRate(BoardQuestConfig.ATTACK_WHEEL_STOP_RATE)
        local nType = BoardQuestConfig.ATTACK_WHEEL[nTargetIndex]
        local nValue = BoardQuestConfig.ATTACK_WHEEL_POWER[nType]
        BoardQuestDataHandler.data.nMonsterHp = BoardQuestDataHandler.data.nMonsterHp - nValue
        if BoardQuestDataHandler.data.nMonsterHp <= 0 then
            local nCoin = BoardQuestConfig.LEVEL_PRIZE_RATIO[BoardQuestDataHandler.data.nLevel]
            self.nSimuTotalWinCoin = self.nSimuTotalWinCoin + nCoin

            BoardQuestDataHandler.data.nLevel = LuaHelper.Loop(BoardQuestDataHandler.data.nLevel + 1, 1, BoardQuestConfig.N_MAX_LEVEL)
            BoardQuestDataHandler.data.nPosition = 1
            BoardQuestDataHandler.data.nMonsterHp = BoardQuestConfig.MONSTER_HP[BoardQuestDataHandler.data.nLevel]

            if BoardQuestDataHandler.data.nLevel == 1 then
                local nCoin = BoardQuestConfig.FINAL_PRIZE_RATIO
                self.nSimuTotalWinCoin = self.nSimuTotalWinCoin + nCoin
                self.nSimuFinishedCount = self.nSimuFinishedCount + 1
                self.bSimuFinishedGame = true
            end
        end
    elseif nItem == BoardQuestConfig.ITEM.MYSTERY_REWARD then
        local nRewardType = LuaHelper.GetIndexByRate(BoardQuestConfig.MYSTERY_REWARD_RATE)
        local nValue = BoardQuestConfig.MYSTERY_REWARD_VALUE[nRewardType]

        if nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1 
        or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2 
        or nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3 then
            self.nSimuTotalWinCoin = self.nSimuTotalWinCoin + nValue
        elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON then
            local nTarget = BoardQuestDataHandler.data.nPosition
            local nTotal = 0
            local nItem = BoardQuestConfig.ROAD[BoardQuestDataHandler.data.nLevel][nTarget]
            for i = 1, 100 do
                if nItem ~= BoardQuestConfig.ITEM.CANNON then
                    nTotal = nTotal + 1
                    nTarget = LuaHelper.Loop(nTarget + 1, 1, BoardQuestConfig.ROAD_ITEM_COUNT[BoardQuestDataHandler.data.nLevel])
                    nItem = BoardQuestConfig.ROAD[BoardQuestDataHandler.data.nLevel][nTarget]
                else
                    break
                end
            end
            if nTotal > 0 then
                self:SimuMove(nTotal)
            end
        elseif nRewardType == BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE then
            self.nSimuRewardActionCount = self.nSimuRewardActionCount + nValue
            self.tableSimuRewardActionCount[BoardQuestDataHandler.data.nLevel] = self.tableSimuRewardActionCount[BoardQuestDataHandler.data.nLevel] + 1
        end
    elseif nItem == BoardQuestConfig.ITEM.COIN then
        local nAction = BoardQuestConfig:getCoinReward()
        self.nSimuTotalWinCoin = self.nSimuTotalWinCoin + nAction
    elseif nItem == BoardQuestConfig.ITEM.CARD then
        -- local nPackType = BoardQuestConfig.ROAD_CARD_PACK_TYPE[BoardQuestDataHandler.data.nLevel]
        -- SlotsCardsGiftManager:getStampPackInActive(nPackType, 1)
    end
end

function BoardQuestDataHandler:getLevelPrize(nLevel)
    return math.floor(ActivityHelper:getBasePrize() * BoardQuestConfig.LEVEL_PRIZE_RATIO[nLevel] * self.data.fFinalPrizeRatioMutiplier + 0.1)
end

function BoardQuestDataHandler:getFinalPrizePrize()
    return math.floor(ActivityHelper:getBasePrize() * BoardQuestConfig.FINAL_PRIZE_RATIO * self.data.fFinalPrizeRatioMutiplier + 0.1)
end




