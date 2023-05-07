RainbowPickDataHandler = {}

RainbowPickDataHandler.data = {}
RainbowPickDataHandler.m_nEndTime = 0
RainbowPickDataHandler.DATAPATH = Unity.Application.persistentDataPath .. "/RainbowPick.txt"
RainbowPickDataHandler.m_nUnlockLevel = GameConfig.PLATFORM_EDITOR and 1 or 5

function RainbowPickDataHandler:Init()
    if not GameConfig.RAINBOWPICK_FLAG then
        return
    end
    self.m_bInitData = true
    self:readFile()
    if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
        self:reset()
        self.data.endTime = ActiveManager.nActivityEndTime
    end
    EventHandler:AddListener(self, "onPurchaseDoneNotifycation")
    --self:Simulation()
    --self:Simulation2()
end

function RainbowPickDataHandler:reset()
    self.data = {}
    self.data.m_nEndTime = self.m_nEndTime
    self.data.fProgress = 0 --收集进度

    self.data.tableChest =  LuaHelper.GetTable(RainbowPickChest.None, RainbowPickConfig.N_MAX_CHEST)
    self.data.nAction = 5
    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 1 then
        self.data.nAction = RainbowPickConfig.N_MAX_ACTION - 2
    end
    self.data.tableNBoosterEndTime = {0, 0}
    self.data.nSuperPickCount = 0
    self.data.tableNChestLockTime =  LuaHelper.GetTable(0, RainbowPickConfig.N_MAX_CHEST) --箱子解锁的时间
    self.data.fFinalPrizeRatioMutiplier = 1
    self.data.bFirstIntroduction = true
    self:resetLevelData()
    self:resetGameData()
end

--完成一关后要重置的数据
function RainbowPickDataHandler:resetLevelData()
    self.data.nRatio = 0 --LevelPrize的额外倍率
    self.data.nNoRewardTime = 0 --玩家已经连续多少次没中奖了
end

--完成所有关卡后要重置的数据
function RainbowPickDataHandler:resetGameData()
    self.data.nLevel = 1
    if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 3 then 
        self.data.nLevel = 10 
    end
    self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[self.data.nLevel])
end

function RainbowPickDataHandler:getNetData()
    local netData = {}
    --netData.endTime = self.data.endTime
    netData.nAction = self.data.nAction
    --netData.nLevel = self.data.nLevel
    netData.tableNBoosterEndTime = self.data.tableNBoosterEndTime
    netData.nSuperPickCount = self.data.nSuperPickCount
    return netData
end

function RainbowPickDataHandler:synNetData(netData)
    --self.data.endTime = netData.endTime
    self.data.nAction = netData.nAction
    --self.data.nLevel = netData.nLevel
    self.data.tableNBoosterEndTime = netData.tableNBoosterEndTime
    self.data.nSuperPickCount = netData.nSuperPickCount
    -- if self.data.endTime ~= ActiveManager.nActivityEndTime then --新赛季重置数据
    --     self:reset()
    --     self.data.endTime = ActiveManager.nActivityEndTime
    -- end
    self:writeFile()
end

function RainbowPickDataHandler:writeFile()
    local strData = rapidjson.encode(self.data)
    CS.System.IO.File.WriteAllText(self.DATAPATH, strData)
end

function RainbowPickDataHandler:readFile()
    if not CS.System.IO.File.Exists(self.DATAPATH) then
        self:reset()
        return
    end
    local strData = CS.System.IO.File.ReadAllText(self.DATAPATH)
    self.data = rapidjson.decode(strData)
end

function RainbowPickDataHandler:onClickItem(nLevel, nItemIndex, goItem)
    ActivityHelper:AddMsgCountData("nAction", -1)

    local fDelayTime = 0
    fDelayTime = fDelayTime + 0.2 --点击物体的动画

    local v3StartPos = goItem.transform.position
    local nItem = RainbowPickConfig:getReward(nLevel)
    self.data.tableItem[nItemIndex] = nItem

    local strClickParticleName
    if nItem == RainbowPickItem.None then
        strClickParticleName = "ClickEmptyParticle"
        ActivityAudioHandler:PlaySound("rainbow_pick_no")
        fDelayTime = 0.1
    else
        strClickParticleName = "ClickRewardParticle"
        ActivityAudioHandler:PlaySound("rainbow_pick_yes")
    end
    local goClickParticle = ActivityBundleHandler:GetAnimationObject(strClickParticleName, RainbowPickMainUIPop.trPrefabPool)
    goClickParticle.transform.position = goItem.transform.position
    LeanTween.delayedCall(fDelayTime, function()
        goClickParticle:SetActive(true)
    end)
    LeanTween.delayedCall(fDelayTime + 1, function()
        ActivityBundleHandler:RecycleObjectToPool(goClickParticle)
    end)
    fDelayTime = fDelayTime + 0.4 --爆点

    if nItem == RainbowPickItem.None then --None
        LeanTween.delayedCall(1, function()
            RainbowPickMainUIPop.bCanClick = true        
        end)
    elseif nItem == RainbowPickItem.Pick then --Pick
        self.data.nAction = self.data.nAction + 1

        LeanTween.delayedCall(fDelayTime, function()
            RainbowPickMainUIPop:flyPick(v3StartPos)            
        end)
    elseif nItem == RainbowPickItem.SilverChest --Chest
        or nItem == RainbowPickItem.GoldChest
        or nItem == RainbowPickItem.DiamondChest then 
        local nChest = RainbowPickConfig.tableItemToChest[nItem]
        local nChestPosition = LuaHelper.indexOfTable(self.data.tableChest, RainbowPickChest.None)
        if nChestPosition then
            self.data.tableChest[nChestPosition] = nChest
            local time = RainbowPickConfig.tableChestUnlockTime[nChest]
            self.data.tableNChestLockTime[nChestPosition] = TimeHandler:GetServerTimeStamp() + time

            local v3EndPos = RainbowPickMainUIPop.tableGoChest[nChestPosition].transform.position
            local fDelayTime = RainbowPickMainUIPop:flyChest(v3StartPos, v3EndPos, nChest)
            local nChestPosition = LuaHelper.indexOfTable(self.data.tableChest, RainbowPickChest.None)
            if nChestPosition == nil then
                LeanTween.delayedCall(fDelayTime, function()
                    RainbowPickMainUIPop.bCanClick = false
                    RainbowPickMainUIPop.ChestSpotsFullSplashUI:Show()
                end)
            end
        else
            Debug.Log("ChestSpotsAlreadyFullSplashUI")
            local go = ActivityBundleHandler:GetAnimationObject("Chest"..nChest, RainbowPickMainUIPop.trPrefabPool)
            go.transform.position = v3StartPos
            go.transform.localScale = Unity.Vector3.zero
            local fTime = 0.2
            local seq = LeanTween.sequence()

            local l = LeanTween.delayedCall(0.6, function()
                go:SetActive(true)
            end)
            table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
            seq:append(l)
      
            local l = LeanTween.scale(go, Unity.Vector3.one * 1.6, fTime)
            table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
            seq:append(l)

            local l = LeanTween.delayedCall(1.8, function()
                RainbowPickMainUIPop.ChestSpotsAlreadyFullSplashUI:show(go)          
            end)
            table.insert(ActivityHelper.m_LeanTweenIDs, l.id)
            seq:append(l)
        end
    elseif nItem == RainbowPickItem.SilverKey --Key
        or nItem == RainbowPickItem.GoldKey
        or nItem == RainbowPickItem.DiamondKey then
        --钥匙会优先解锁剩余时间最长的箱子 
        local nChest = RainbowPickConfig.tableKeyToChest[nItem]
        local fUnlockTime = 0
        local nChestPosition = 0
        for i = 1, RainbowPickConfig.N_MAX_CHEST do
            if self.data.tableChest[i] == nChest then
                if self.data.tableNChestLockTime[i] > fUnlockTime then
                    nChestPosition = i
                end
            end
        end
        local v3EndPos = RainbowPickMainUIPop.tableGoChest[nChestPosition].transform.position
        LeanTween.delayedCall(fDelayTime, function()
            RainbowPickMainUIPop:flyKey(v3StartPos, v3EndPos, nItem, nChestPosition)      
        end)
    elseif nItem == RainbowPickItem.More10 --PrizeBigger
        or nItem == RainbowPickItem.More15
        or nItem == RainbowPickItem.More20 then
        local nRatio = RainbowPickConfig.tableMoreRatio[nItem]
        self.data.nRatio = self.data.nRatio + nRatio
        LeanTween.delayedCall(fDelayTime, function()
            RainbowPickMainUIPop:flyMore(v3StartPos, nItem, nRatio)    
        end)
    elseif nItem == RainbowPickItem.Rainbow then --Rainbow

        local fProgressStart = (nLevel - 1) / RainbowPickConfig.N_MAX_LEVEL
        local fProgressEnd = nLevel / RainbowPickConfig.N_MAX_LEVEL

        --LevelPrize
        local nLevelPrizeCoin, nRatio, gift = self:getLevelPrize(nLevel)
        local gift = RainbowPickConfig.tableProgressBarGift[nLevel]
        if gift then
            if gift.cardPack and SlotsCardsManager:orActivityOpen() then
                SlotsCardsGiftManager:getStampPackInActive(gift.cardPack.nCardPackType, gift.cardPack.nCount)
            end
        end
        PlayerHandler:AddCoin(nLevelPrizeCoin)
        local nPlayerCoin = PlayerHandler.nGoldCount
        self.data.nRatio = 0
        self.data.nLevel = LuaHelper.Loop(self.data.nLevel + 1, 1, RainbowPickConfig.N_MAX_LEVEL)
        self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[self.data.nLevel])

        local nFinalPrizeCoin
        local nFinalPrizePlayerCoin
        if self.data.nLevel == 1 then
            nFinalPrizeCoin = self:getFinalPrize()
            PlayerHandler:AddCoin(nFinalPrizeCoin)
            nFinalPrizePlayerCoin = PlayerHandler.nGoldCount
            if SlotsCardsManager:orActivityOpen() then
                SlotsCardsGiftManager:getStampPackInActive(RainbowPickConfig.FinalPrizeRewardCardPack.nCardPackType, RainbowPickConfig.FinalPrizeRewardCardPack.nCount)
            end
            if GameConfig.LOUNGE_FLAG then
                LoungeHandler:addChest(RainbowPickConfig.FinalPrizeRewardLoungeChest.nChestType, RainbowPickConfig.FinalPrizeRewardLoungeChest.nCount)
            end
        end
  
        if self.data.nLevel == 1 then
            self.data.fFinalPrizeRatioMutiplier = self.data.fFinalPrizeRatioMutiplier + 0.1
        end

        --Rainbow动画
        local go = ActivityBundleHandler:GetAnimationObject("Rainbow", RainbowPickMainUIPop.trPrefabPool)
        go.transform.position = goItem.transform.position
        LeanTween.delayedCall(0.5, function()
            go:SetActive(true)
        end)
        fDelayTime = fDelayTime + 0.5
        --进度条上升
        local fTime = 0.5
        local id = LeanTween.value(fProgressStart, fProgressEnd, fTime)
        :setOnUpdate(function(value)
            RainbowPickMainUIPop.imageProgressBar.fillAmount = value
        end)
        :setDelay(fDelayTime).id
        table.insert(ActivityHelper.m_LeanTweenIDs, id)
        fDelayTime = fDelayTime + fTime
        LeanTween.delayedCall(fDelayTime, function()
            ActivityBundleHandler:RecycleObjectToPool(go)
             --LevelPrize弹窗
             if gift and gift.cardPack and SlotsCardsManager:orActivityOpen() then
                RainbowPickMainUIPop.LevelPrizeHaveGiftSplashUI:show(nLevelPrizeCoin, nPlayerCoin, nRatio, gift.cardPack.nCardPackType, gift.cardPack.nCount)
            else
                RainbowPickMainUIPop.LevelPrizeSplashUI:show(nLevelPrizeCoin, nPlayerCoin, nRatio)
            end

            if self.data.nLevel == 1 then
                if SlotsCardsManager:orActivityOpen() then
                    RainbowPickMainUIPop.FinalPrizeSplashUI:show(nFinalPrizeCoin, nFinalPrizePlayerCoin, RainbowPickConfig.FinalPrizeRewardCardPack.nCardPackType, RainbowPickConfig.FinalPrizeRewardCardPack.nCount)
                else
                    RainbowPickMainUIPop.FinalPrizeSplashUI:show(nFinalPrizeCoin, nFinalPrizePlayerCoin)
                end
            end
 
            local nLevelPrizeCoin, nRatio, gift = self:getLevelPrize()

            LeanTween.delayedCall(0.5, function()
                RainbowPickMainUIPop:setLevelPrize(nLevelPrizeCoin, nRatio, gift)
                RainbowPickMainUIPop.textLevel.text = self.data.nLevel.."/"..RainbowPickConfig.N_MAX_LEVEL
                RainbowPickMainUIPop:setItem(self.data.nLevel)
            end)
               
            --重置进度条
            if self.data.nLevel == 1 then
                local fTime = 0.5
                local id = LeanTween.value(1, 0, fTime)
                :setOnUpdate(function(value)
                    RainbowPickMainUIPop.imageProgressBar.fillAmount = value
                end).id
                table.insert(ActivityHelper.m_LeanTweenIDs, id)
            end
        end)
    end
    
    self:writeFile()
end

function RainbowPickDataHandler:getLevelPrize(nLevel)
    nLevel = nLevel or self.data.nLevel
    local nLevelPrizeCoin = math.floor(ActivityHelper:getBasePrize() * RainbowPickConfig.TABLE_LEVEL_PRIZE_RATIO[nLevel] * self.data.fFinalPrizeRatioMutiplier + 0.1)
    local nRatio = self.data.nRatio
    nLevelPrizeCoin = math.floor(nLevelPrizeCoin + nLevelPrizeCoin * nRatio / 100)
    if self:checkInBoosterTime(RainbowPickBooster.Coin) then
        nLevelPrizeCoin = nLevelPrizeCoin * 2
    end
    local gift = RainbowPickConfig.tableProgressBarGift[nLevel]
    return nLevelPrizeCoin, nRatio, gift
end

function RainbowPickDataHandler:getFinalPrize()
    return math.floor(ActivityHelper:getBasePrize() * RainbowPickConfig.F_FINAL_PRIZE_RATIO * self.data.fFinalPrizeRatioMutiplier + 0.1)
end

function RainbowPickDataHandler:checkChestLockTime(i)
    return self.data.tableNChestLockTime[i] > TimeHandler:GetServerTimeStamp()
end

function RainbowPickDataHandler:onPurchaseDoneNotifycation(data)
    if ActiveManager.activeType ~= ActiveType.RainbowPick then return end
    local skuInfo = data.skuInfo
    if skuInfo.nType == SkuInfoType.RainbowPick then
        --活动商店内购
        local activeInfo = skuInfo.activeInfo
        ActivityHelper:AddMsgCountData("nAction", activeInfo.nAction)
        if skuInfo.nActiveIAPType == RainbowPickIAPConfig.Type.PickBooster then
            self:AddBoosterEndTime(activeInfo.nTime, 1)
        elseif skuInfo.nActiveIAPType == RainbowPickIAPConfig.Type.CoinBooster then
            self:AddBoosterEndTime(activeInfo.nTime, 2)
        elseif skuInfo.nActiveIAPType == RainbowPickIAPConfig.Type.SuperPick then
            ActivityHelper:AddMsgCountData("nSuperPickCount", activeInfo.nSuperPickCount)
        end
    else
        --其它内购
        local nAction = RainbowPickIAPConfig.skuMapOther[data.productId]
        ActivityHelper:AddMsgCountData("nAction", nAction)
    end
    self:writeFile()
end

function RainbowPickDataHandler:AddBoosterEndTime(nAddTime, i)
    if self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp() then
        self.data.tableNBoosterEndTime[i] = self.data.tableNBoosterEndTime[i] + nAddTime
    else
        self.data.tableNBoosterEndTime[i] = TimeHandler:GetServerTimeStamp() + nAddTime
    end
end

function RainbowPickDataHandler:refreshAddSpinProgress(data)
    --根据押注大小增加进度
    local value = ActivityHelper:getAddSpinProgressValue(data, ActiveType.RainbowPick)
    
    self.data.fProgress = self.data.fProgress + value
    
    local isMax = self.data.fProgress >= 1
    local isActionReachMax = false
    if isMax then
        while self.data.fProgress >= 1 do
            self.data.fProgress = self.data.fProgress - 1
        end

        local nAddCount = ActivityHelper:getProgressFullAddCount(ActiveType.RainbowPick)
        
        if self:checkInBoosterTime(1) then
            nAddCount = nAddCount * 2
        end
        --收集了，然后收集物数量到达了上限
        if self.data.nAction + nAddCount >= RainbowPickConfig.N_MAX_ACTION then
            isActionReachMax = true
            nAddCount = math.max(RainbowPickConfig.N_MAX_ACTION- self.data.nAction, 0)
        end
        self.data.nAction = self.data.nAction + nAddCount
    end
    self:writeFile()
    return isMax, isActionReachMax
end

function RainbowPickDataHandler:checkInBoosterTime(i)
    return self.data.tableNBoosterEndTime[i] > 0 and self.data.tableNBoosterEndTime[i] > TimeHandler:GetServerTimeStamp()
end



function RainbowPickDataHandler:Simulation()
    Debug.Log("RainbowPickDataHandler:Simulation")
    --重置数值
    self.data.tableNBoosterEndTime = {0, 0}
    self.data.nSuperPickCount = 0
    self.data.tableNChestLockTime =  LuaHelper.GetTable(0, RainbowPickConfig.N_MAX_CHEST)
    --一轮的奖励
    --local nTotalLevelPrize = LuaHelper.GetSum(RainbowPickConfig.tableLevelPrizeRatio)
    local nTotalLevelPrize = 0
    --箱子奖励
    --仿真模拟，10次Pick解锁一个银箱子，20次Pick解锁一个金箱子
    --情况1，至少箱子有1个空位以后再继续pick
    --Spin收集速度
    --钻石奖励

    --平均要多少个Pick能通关一轮
    local nTotalTestTime = 100
    local nAction = 0
    local nRewardPickCount = 0
    local nMaxChestCount = 4
    local tableOpenChest =  LuaHelper.GetTable(0, 3) --开了多少个箱子
    local tableThrowChest =  LuaHelper.GetTable(0, 3) --丢弃了多少个箱子
    for nTestTime = 1, nTotalTestTime do
        self.data.tableChest =  LuaHelper.GetTable(RainbowPickChest.None, RainbowPickConfig.N_MAX_CHEST)
        self.data.nRatio = 0 --LevelPrize的额外倍率
        self.data.nNoRewardTime = 0 --玩家已经连续多少次没中奖了
        self.data.nLevel = 1
        self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[1])

        for nLevel = 1, RainbowPickConfig.N_MAX_LEVEL do
            self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[nLevel])
            self.data.nRatio = 0 --LevelPrize的额外倍率
            for i = 1, RainbowPickConfig.tableItemCount[nLevel] do
                local nItem = RainbowPickConfig:getReward(nLevel, true)
                self.data.tableItem[i] = nItem
                nAction = nAction + 1
                if nItem == RainbowPickItem.Pick then
                    nRewardPickCount = nRewardPickCount + 1
                elseif nItem == RainbowPickItem.SilverChest --Chest
                    or nItem == RainbowPickItem.GoldChest
                    or nItem == RainbowPickItem.DiamondChest then 
                    local nChest = RainbowPickConfig.tableItemToChest[nItem]
                    local nChestPosition = LuaHelper.indexOfTable(self.data.tableChest, RainbowPickChest.None)
                    if nChestPosition then
                        self.data.tableChest[nChestPosition] = nChest
                    else
                        tableThrowChest[nChest] = tableThrowChest[nChest] + 1
                    end
                elseif nItem == RainbowPickItem.SilverKey --Key
                    or nItem == RainbowPickItem.GoldKey
                    or nItem == RainbowPickItem.DiamondKey then
                    local nChest = RainbowPickConfig.tableKeyToChest[nItem]
                    local nChestPosition = 0
                    for i = 1, RainbowPickConfig.N_MAX_CHEST do
                        if self.data.tableChest[i] == nChest then
                            nChestPosition = i
                            break
                        end
                    end
                    tableOpenChest[nChest] = tableOpenChest[nChest] + 1
                    self.data.tableChest[i] = RainbowPickChest.None
                elseif nItem == RainbowPickItem.More10 --PrizeBigger
                    or nItem == RainbowPickItem.More15
                    or nItem == RainbowPickItem.More20 then
                    local nRatio = RainbowPickConfig.tableMoreRatio[nItem]
                    self.data.nRatio = self.data.nRatio + nRatio
                elseif nItem == RainbowPickItem.Rainbow then
                    nTotalLevelPrize = nTotalLevelPrize + RainbowPickConfig.TABLE_LEVEL_PRIZE_RATIO[nLevel] * (1 + self.data.nRatio/100)
                    break
                end
            end
        end
    end
    
    local strFile = "只能用钥匙解锁箱子的情况下\n"
    local nAverageTotalLevelPrize = nTotalLevelPrize/nTotalTestTime
    nAction = nAction / nTotalTestTime
    nRewardPickCount = nRewardPickCount / nTotalTestTime
    strFile = strFile.."完成一轮需要的Pick数量 "..nAction.."\n"
    strFile = strFile.."完成一轮奖励的Pick数量 "..nRewardPickCount.."\n"
    strFile = strFile.."完成一轮实际需要的Pick数量 "..nAction - nRewardPickCount.."\n"
    strFile = strFile.."\n"

    local strFile2 = ""
    --一个箱子相当于几美元
    local tableChestRewardDollar =  LuaHelper.GetTable(0, 3)
    local tableChestRewardCardPack =  LuaHelper.GetTable(0, 5)
    local tableChestName = {"银","金","钻石"}
    for nChestType = 1, 3 do
        local tableRewardTime =  LuaHelper.GetTable(0, 4)
        local tableReward =  LuaHelper.GetTable(0, 4)
        local nTotalTestTime = 100
        for nTestTime = 1, nTotalTestTime do
            local nRewardType = LuaHelper.GetIndexByRate(RainbowPickConfig.tableChestRewardTypeRate)
            tableRewardTime[nRewardType] = tableRewardTime[nRewardType] + 1
        end
        tableReward[RainbowPickConfig.ChestReward.Coin] = tableRewardTime[RainbowPickConfig.ChestReward.Coin] * RainbowPickConfig.tableChestRewardCoinRatio[nChestType]/nTotalTestTime
        tableReward[RainbowPickConfig.ChestReward.Diamond] = tableRewardTime[RainbowPickConfig.ChestReward.Diamond] * RainbowPickConfig.tableChestRewardDiamondRatio[nChestType]/nTotalTestTime

        --LuckyPick
        local fAverateMultiplier = 0
        local tableMultiplier = RainbowPickConfig.tableLuckyPickMultiplier[nChestType]
        local tableMultiplierRate = RainbowPickConfig.tableLuckyPickMultiplierRate[nChestType]
   
        for i = 1, #tableMultiplierRate do
            fAverateMultiplier = fAverateMultiplier + tableMultiplierRate[i] * tableMultiplier[i]
        end
        local nTotalRate = LuaHelper.GetSum(tableMultiplierRate)
        fAverateMultiplier = fAverateMultiplier / nTotalRate

        tableReward[RainbowPickConfig.ChestReward.LuckyPick] = tableRewardTime[RainbowPickConfig.ChestReward.LuckyPick] * fAverateMultiplier/nTotalTestTime * RainbowPickConfig.fLuckyPickBasePrizeRatio

        strFile2 = strFile2.."开一个"..tableChestName[nChestType].."箱子获得的平均奖励 ".."\n"

        local fCardPackRate = RainbowPickConfig.tableChestRewardTypeRate[RainbowPickConfig.ChestReward.CardPack]/LuaHelper.GetSum(RainbowPickConfig.tableChestRewardTypeRate)
        for i = 1, 5 do
            local fCardPackRate2 = RainbowPickConfig.tableChestRewardCardPackRate[nChestType][i]/LuaHelper.GetSum(RainbowPickConfig.tableChestRewardCardPackRate[nChestType])
            if fCardPackRate2 > 0 then
                strFile2 = strFile2..string.format("%s星卡包%0.3f个", i, fCardPackRate * fCardPackRate2).."\n"
                tableChestRewardCardPack[i] = tableChestRewardCardPack[i] + fCardPackRate2
            end
        end
        strFile2 = strFile2..string.format("相当于%0.2f美元的Coin", tableReward[RainbowPickConfig.ChestReward.Coin]).."\n"
        strFile2 = strFile2..string.format("相当于%0.2f美元的Diamond", tableReward[RainbowPickConfig.ChestReward.Diamond]).."\n"
        strFile2 = strFile2..string.format("相当于%0.2f美元的LuckyPick", tableReward[RainbowPickConfig.ChestReward.LuckyPick]).."\n"
        tableChestRewardDollar[nChestType] = tableReward[RainbowPickConfig.ChestReward.Coin] + tableReward[RainbowPickConfig.ChestReward.Diamond] + tableReward[RainbowPickConfig.ChestReward.LuckyPick]
        
        strFile2 = strFile2..string.format("总共相当于%0.2f美元", tableChestRewardDollar[nChestType]).."\n"

        strFile2 = strFile2.."\n"
    end

    local nTotalChestDollar = 0
    for nChestType = 1, 3 do
        local nAverageChestTime = tableOpenChest[nChestType] / nTotalTestTime
        local nDollar = tableChestRewardDollar[nChestType] * nAverageChestTime
        nTotalChestDollar = nTotalChestDollar + nDollar
        strFile2 = strFile2..string.format("完成一轮解锁的%s箱子数%0.2f", tableChestName[nChestType], nAverageChestTime).."\n"
        strFile2 = strFile2..string.format("完成一轮丢弃的%s箱子数%0.2f", tableChestName[nChestType], tableThrowChest[nChestType]/nTotalTestTime).."\n"
        strFile2 = strFile2..string.format("完成一轮解锁的%s箱子获得的钱 %0.2f", tableChestName[nChestType], nDollar).."\n\n"
    end
    strFile2 = strFile2.."\n"
    
    strFile2 = strFile2..string.format("完成一轮箱子获得的钱 相当于 %0.2f 美元", nTotalChestDollar).."\n"
    for i = 1, 5 do
        strFile2 = strFile2..string.format("完成一轮解锁箱子获得的%d星卡包%0.3f个", i, tableChestRewardCardPack[i]).."\n"
    end
    strFile2 = strFile2.."\n"

    strFile = strFile..string.format("完成一轮获得的所有的钱 %0.2f", nAverageTotalLevelPrize + nTotalChestDollar).."\n"

    for i = 1, RainbowPickConfig.N_MAX_LEVEL do
        if RainbowPickConfig.tableProgressBarGift[i] and RainbowPickConfig.tableProgressBarGift[i].cardPack then
            local nCardPackType = RainbowPickConfig.tableProgressBarGift[i].cardPack.nCardPackType + 1
            tableChestRewardCardPack[nCardPackType] = tableChestRewardCardPack[nCardPackType] + RainbowPickConfig.tableProgressBarGift[i].cardPack.nCount
        end
    end
    for i = 1, 5 do
        strFile = strFile..string.format("完成一轮获得的所有的%d星卡包%0.3f个", i, tableChestRewardCardPack[i]).."\n"
    end
    strFile = strFile.."\n"
    strFile = strFile..string.format("完成一轮 LevelPrize的钱%0.3f", nAverageTotalLevelPrize).."\n"
    strFile = strFile..string.format("完成一轮 箱子获得的钱 %0.2f", nTotalChestDollar).."\n"

    strFile = strFile.."\n"..strFile2

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir.."RainbowPick.txt"
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end

    self:reset()
end

--获得箱子后立刻解锁
function RainbowPickDataHandler:Simulation2()
    Debug.Log("RainbowPickDataHandler:Simulation2")
    --重置数值
    self.data.tableNBoosterEndTime = {0, 0}
    self.data.nSuperPickCount = 0
    self.data.tableNChestLockTime =  LuaHelper.GetTable(0, RainbowPickConfig.N_MAX_CHEST)
    local nTotalLevelPrize = 0
    --平均要多少个Pick能通关一轮
    local nTotalTestTime = 100
    local nAction = 0
    local nRewardPickCount = 0
    local nMaxChestCount = 4
    local tableOpenChest =  LuaHelper.GetTable(0, 3) --开了多少个箱子
    for nTestTime = 1, nTotalTestTime do
        self.data.tableChest =  LuaHelper.GetTable(RainbowPickChest.None, RainbowPickConfig.N_MAX_CHEST)
        self.data.nRatio = 0 --LevelPrize的额外倍率
        self.data.nNoRewardTime = 0 --玩家已经连续多少次没中奖了
        self.data.nLevel = 1
        self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[1])

        for nLevel = 1, RainbowPickConfig.N_MAX_LEVEL do
            self.data.tableItem =  LuaHelper.GetTable(RainbowPickItem.Unrevealed, RainbowPickConfig.tableItemCount[nLevel])
            self.data.nRatio = 0 --LevelPrize的额外倍率
            for i = 1, RainbowPickConfig.tableItemCount[nLevel] do
                local nItem = RainbowPickConfig:getReward(nLevel, true)
                self.data.tableItem[i] = nItem
                nAction = nAction + 1
                if nItem == RainbowPickItem.Pick then
                    nRewardPickCount = nRewardPickCount + 1
                elseif nItem == RainbowPickItem.SilverChest --Chest
                    or nItem == RainbowPickItem.GoldChest
                    or nItem == RainbowPickItem.DiamondChest then 
                    local nChest = RainbowPickConfig.tableItemToChest[nItem]
                    tableOpenChest[nChest] = tableOpenChest[nChest] + 1
                    -- local nChestPosition = LuaHelper.indexOfTable(self.data.tableChest, RainbowPickChest.None)
                    -- if nChestPosition then
                    --     self.data.tableChest[nChestPosition] = nChest
                    -- end
                elseif nItem == RainbowPickItem.SilverKey --Key
                    or nItem == RainbowPickItem.GoldKey
                    or nItem == RainbowPickItem.DiamondKey then
                    local nChest = RainbowPickConfig.tableKeyToChest[nItem]
                    local nChestPosition = 0
                    for i = 1, RainbowPickConfig.N_MAX_CHEST do
                        if self.data.tableChest[i] == nChest then
                            nChestPosition = i
                            break
                        end
                    end
                    tableOpenChest[nChest] = tableOpenChest[nChest] + 1
                    self.data.tableChest[i] = RainbowPickChest.None
                elseif nItem == RainbowPickItem.More10 --PrizeBigger
                    or nItem == RainbowPickItem.More15
                    or nItem == RainbowPickItem.More20 then
                    local nRatio = RainbowPickConfig.tableMoreRatio[nItem]
                    self.data.nRatio = self.data.nRatio + nRatio
                elseif nItem == RainbowPickItem.Rainbow then
                    nTotalLevelPrize = nTotalLevelPrize + RainbowPickConfig.TABLE_LEVEL_PRIZE_RATIO[nLevel] * (1 + self.data.nRatio/100)
                    break
                end
            end
        end
    end
    
    local strFile = "获得箱子后立刻解锁\n"
    local nAverageTotalLevelPrize = nTotalLevelPrize/nTotalTestTime
    nAction = nAction / nTotalTestTime
    nRewardPickCount = nRewardPickCount / nTotalTestTime
    strFile = strFile.."完成一轮需要的Pick数量 "..nAction.."\n"
    strFile = strFile.."完成一轮奖励的Pick数量 "..nRewardPickCount.."\n"
    strFile = strFile.."完成一轮实际需要的Pick数量 "..nAction - nRewardPickCount.."\n"
    strFile = strFile.."\n"

    local strFile2 = ""
    --一个箱子相当于几美元
    local tableChestRewardDollar =  LuaHelper.GetTable(0, 3)
    local tableChestRewardCardPack =  LuaHelper.GetTable(0, 5)
    local tableChestName = {"银","金","钻石"}
    for nChestType = 1, 3 do
        local tableRewardTime =  LuaHelper.GetTable(0, 4)
        local tableReward =  LuaHelper.GetTable(0, 4)
        local nTotalTestTime = 100
        for nTestTime = 1, nTotalTestTime do
            local nRewardType = LuaHelper.GetIndexByRate(RainbowPickConfig.tableChestRewardTypeRate)
            tableRewardTime[nRewardType] = tableRewardTime[nRewardType] + 1
        end
        tableReward[RainbowPickConfig.ChestReward.Coin] = tableRewardTime[RainbowPickConfig.ChestReward.Coin] * RainbowPickConfig.tableChestRewardCoinRatio[nChestType]/nTotalTestTime
        tableReward[RainbowPickConfig.ChestReward.Diamond] = tableRewardTime[RainbowPickConfig.ChestReward.Diamond] * RainbowPickConfig.tableChestRewardDiamondRatio[nChestType]/nTotalTestTime

        --LuckyPick
        local fAverateMultiplier = 0
        local tableMultiplier = RainbowPickConfig.tableLuckyPickMultiplier[nChestType]
        local tableMultiplierRate = RainbowPickConfig.tableLuckyPickMultiplierRate[nChestType]
   
        for i = 1, #tableMultiplierRate do
            fAverateMultiplier = fAverateMultiplier + tableMultiplierRate[i] * tableMultiplier[i]
        end
        local nTotalRate = LuaHelper.GetSum(tableMultiplierRate)
        fAverateMultiplier = fAverateMultiplier / nTotalRate

        tableReward[RainbowPickConfig.ChestReward.LuckyPick] = tableRewardTime[RainbowPickConfig.ChestReward.LuckyPick] * fAverateMultiplier/nTotalTestTime * RainbowPickConfig.fLuckyPickBasePrizeRatio

        strFile2 = strFile2.."开一个"..tableChestName[nChestType].."箱子获得的平均奖励 ".."\n"

        local fCardPackRate = RainbowPickConfig.tableChestRewardTypeRate[RainbowPickConfig.ChestReward.CardPack]/LuaHelper.GetSum(RainbowPickConfig.tableChestRewardTypeRate)
        for i = 1, 5 do
            local fCardPackRate2 = RainbowPickConfig.tableChestRewardCardPackRate[nChestType][i]/LuaHelper.GetSum(RainbowPickConfig.tableChestRewardCardPackRate[nChestType])
            if fCardPackRate2 > 0 then
                strFile2 = strFile2..string.format("%s星卡包%0.3f个", i, fCardPackRate * fCardPackRate2).."\n"
                tableChestRewardCardPack[i] = tableChestRewardCardPack[i] + fCardPackRate2
            end
        end
        strFile2 = strFile2..string.format("相当于%0.2f美元的Coin", tableReward[RainbowPickConfig.ChestReward.Coin]).."\n"
        strFile2 = strFile2..string.format("相当于%0.2f美元的Diamond", tableReward[RainbowPickConfig.ChestReward.Diamond]).."\n"
        strFile2 = strFile2..string.format("相当于%0.2f美元的LuckyPick", tableReward[RainbowPickConfig.ChestReward.LuckyPick]).."\n"
        tableChestRewardDollar[nChestType] = tableReward[RainbowPickConfig.ChestReward.Coin] + tableReward[RainbowPickConfig.ChestReward.Diamond] + tableReward[RainbowPickConfig.ChestReward.LuckyPick]
        
        strFile2 = strFile2..string.format("总共相当于%0.2f美元", tableChestRewardDollar[nChestType]).."\n"

        strFile2 = strFile2.."\n"
    end

    local nTotalChestDollar = 0
    for nChestType = 1, 3 do
        local nAverageChestTime = tableOpenChest[nChestType] / nTotalTestTime
        local nDollar = tableChestRewardDollar[nChestType] * nAverageChestTime
        nTotalChestDollar = nTotalChestDollar + nDollar
        strFile2 = strFile2..string.format("完成一轮解锁的%s箱子数%0.2f", tableChestName[nChestType], nAverageChestTime).."\n"
        strFile2 = strFile2..string.format("完成一轮解锁的%s箱子获得的钱 %0.2f", tableChestName[nChestType], nDollar).."\n\n"
    end
    strFile2 = strFile2.."\n"

    strFile2 = strFile2..string.format("完成一轮箱子获得的钱 相当于 %0.2f 美元", nTotalChestDollar).."\n"
    for i = 1, 5 do
        strFile2 = strFile2..string.format("完成一轮解锁箱子获得的%d星卡包%0.3f个", i, tableChestRewardCardPack[i]).."\n"
    end
    strFile2 = strFile2.."\n"

    strFile = strFile..string.format("完成一轮获得的所有的钱 %0.2f", nAverageTotalLevelPrize + nTotalChestDollar).."\n"

    for i = 1, RainbowPickConfig.N_MAX_LEVEL do
        if RainbowPickConfig.tableProgressBarGift[i] and RainbowPickConfig.tableProgressBarGift[i].cardPack then
            local nCardPackType = RainbowPickConfig.tableProgressBarGift[i].cardPack.nCardPackType + 1
            tableChestRewardCardPack[nCardPackType] = tableChestRewardCardPack[nCardPackType] + RainbowPickConfig.tableProgressBarGift[i].cardPack.nCount
        end
    end
    for i = 1, 5 do
        strFile = strFile..string.format("完成一轮获得的所有的%d星卡包%0.3f个", i, tableChestRewardCardPack[i]).."\n"
    end
    strFile = strFile.."\n"
    strFile = strFile..string.format("完成一轮 LevelPrize的钱%0.3f", nAverageTotalLevelPrize).."\n"
    strFile = strFile..string.format("完成一轮 箱子获得的钱 %0.2f", nTotalChestDollar).."\n"

    strFile = strFile.."\n"..strFile2

    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir.."RainbowPick2.txt"
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end

    self:reset()
end