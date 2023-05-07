--箱子的种类
RainbowPickChest = {
    None = 0,
    Silver = 1,
    Gold = 2,
    Diamond = 3
}

RainbowPickBooster = {
    Pick = 1,
    Coin = 2
}

RainbowPickClickItem = {
    Clover = 1,
    Hat = 2,
    HorseShoe = 3,
    Pipe = 4
}

--物品的状态
RainbowPickItem = {
    Unrevealed = 0, --还没点开
    None = 1, --点开了，为空
    Pick = 2,
    SilverChest = 3,
    GoldChest = 4,
    DiamondChest = 5,
    SilverKey = 6,
    GoldKey = 7,
    DiamondKey = 8,
    More10 = 9,
    More15 = 10,
    More20 = 11,
    Rainbow = 12
}

--物品状态的键值对反转
RainbowPickItemKey = LuaHelper.GetKeyValueSwitchTable(RainbowPickItem)

RainbowPickConfig = {}
RainbowPickConfig.activeType = ActiveType.RainbowPick
RainbowPickConfig.N_MAX_CHEST = 5 --最多可以有几个箱子
RainbowPickConfig.N_MAX_LEVEL = 10
RainbowPickConfig.N_MAX_ACTION = 50 --最多可以有几个Pick

--箱子解锁的时间
RainbowPickConfig.tableChestUnlockTime = {
    [RainbowPickChest.Silver] = 1 * 60 * 60,
    [RainbowPickChest.Gold] = 2 * 60 * 60,
    [RainbowPickChest.Diamond] = 3 * 60 * 60,
}

if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 3 then
    RainbowPickConfig.tableChestUnlockTime = {
        [RainbowPickChest.Silver] = 5 ,
        [RainbowPickChest.Gold] = 5 ,
        [RainbowPickChest.Diamond] = 5 ,
    }
end

if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 20 then
    RainbowPickConfig.tableChestUnlockTime = {
        [RainbowPickChest.Silver] = 10,
        [RainbowPickChest.Gold] = 10,
        [RainbowPickChest.Diamond] = 10,
    }
end

--箱子解锁消耗的钻石
RainbowPickConfig.tableChestUnlockDiamond = {
    [RainbowPickChest.Silver] = 50,
    [RainbowPickChest.Gold] = 100,
    [RainbowPickChest.Diamond] = 150,
}

--每关有多少个物品
RainbowPickConfig.tableItemCount = {
    [1] = 12,
    [2] = 15,
    [3] = 18,
    [4] = 20,
    [5] = 22,
    [6] = 24,
    [7] = 27,
    [8] = 30,
    [9] = 32,
    [10] = 35,
}

RainbowPickConfig.tableMoreRatio = {
    [RainbowPickItem.More10] = 10,
    [RainbowPickItem.More15] = 15,
    [RainbowPickItem.More20] = 20,
}

--钥匙对应的箱子
RainbowPickConfig.tableKeyToChest = {
    [RainbowPickItem.SilverKey] = RainbowPickChest.Silver,
    [RainbowPickItem.GoldKey] = RainbowPickChest.Gold,
    [RainbowPickItem.DiamondKey] = RainbowPickChest.Diamond,
}

--Item对应的箱子
RainbowPickConfig.tableItemToChest = {
    [RainbowPickItem.SilverChest] = RainbowPickChest.Silver,
    [RainbowPickItem.GoldChest] = RainbowPickChest.Gold,
    [RainbowPickItem.DiamondChest] = RainbowPickChest.Diamond,
}

--进度条上的奖励
RainbowPickConfig.tableProgressBarGift = {
    [1] = nil,
    [2] = nil,
    [3] = {cardPack = {nCardPackType = SlotsCardsAllProbTable.PackType.Two, nCount = 1}},
    [4] = nil,
    [5] = {cardPack = {nCardPackType = SlotsCardsAllProbTable.PackType.Three, nCount = 1}},
    [6] = nil,
    [7] = {cardPack = {nCardPackType = SlotsCardsAllProbTable.PackType.Four, nCount = 1}},
    [8] = nil,
    [9] = nil,
    [10] = {cardPack = {nCardPackType = SlotsCardsAllProbTable.PackType.Five, nCount = 1}},
}

--点开一个物品，给的奖励
function RainbowPickConfig:getReward(nLevel, bSimulation)
    --先判断是不是Rainbow
    local tableItem = RainbowPickDataHandler.data.tableItem
    local nUnrevealCount = LuaHelper.GetEqualElementCount(tableItem, RainbowPickItem.Unrevealed) - 1 --剩余多少个没点
    local nRevealCount = RainbowPickConfig.tableItemCount[nLevel] - nUnrevealCount
    local ratio = nRevealCount / RainbowPickConfig.tableItemCount[nLevel]
    local fRainbowRatio = LeanTween.easeInCubic(0, 1, ratio)
    fRainbowRatio = fRainbowRatio *0.39
    if nUnrevealCount == 0 then
        fRainbowRatio = 1
    end
    if math.random() < fRainbowRatio then
        RainbowPickDataHandler.data.nNoRewardTime = 0

        if RainbowPickDataHandler.data.nSuperPickCount > 0 then
             ActivityHelper:AddMsgCountData("nSuperPickCount", -1)
        end

        return RainbowPickItem.Rainbow
    end
    --判断是不是奖励
    local fRate = 0.5
    if nLevel == 1 then
        fRate = 0.6
    end
    local bRewardFlag = math.random() < fRate
    --保底机制，连续4次不中奖后，下次一定中奖
    if RainbowPickDataHandler.data.nNoRewardTime >= 3 then
        bRewardFlag = true
    end
    --SuperPick
    if RainbowPickDataHandler.data.nSuperPickCount > 0 then
        bRewardFlag = true
        ActivityHelper:AddMsgCountData("nSuperPickCount", -1)
    end

    if bRewardFlag then
        RainbowPickDataHandler.data.nNoRewardTime = 0
        --判断是不是钥匙
        --有没解锁的箱子才会出对应的钥匙。箱子越多，出钥匙的概率越高
        local tableRate = {}
        for i = 1, self.N_MAX_CHEST do
            local nChestType = RainbowPickDataHandler.data.tableChest[i]
            if nChestType == RainbowPickChest.None then
                table.insert(tableRate, 0)
            else
                if bSimulation or RainbowPickDataHandler:checkChestLockTime(i) then
                    if nChestType == RainbowPickChest.Silver then
                        table.insert(tableRate, 6)
                    elseif nChestType == RainbowPickChest.Gold then
                        table.insert(tableRate, 3)
                    elseif nChestType == RainbowPickChest.Diamond then
                        table.insert(tableRate, 1)
                    end
                else
                    table.insert(tableRate, 0)
                end
            end
        end
        table.insert(tableRate, 100 - LuaHelper.GetSum(tableRate))
        local nIndex = LuaHelper.GetIndexByRate(tableRate)
        if nIndex <= self.N_MAX_CHEST  then
            local nChestType = RainbowPickDataHandler.data.tableChest[nIndex]
            if nChestType == RainbowPickChest.Silver then
                return RainbowPickItem.SilverKey
            elseif nChestType == RainbowPickChest.Gold then
                return RainbowPickItem.GoldKey
            elseif nChestType == RainbowPickChest.Diamond then
                return RainbowPickItem.DiamondKey
            end
        end
        --判断是不是Pick,Bigger,Chest
        local tableRate = {
            [RainbowPickItem.Pick] = 10,
            [RainbowPickItem.SilverChest] = 18,
            [RainbowPickItem.GoldChest] = 15,
            [RainbowPickItem.DiamondChest] = 8,
            [RainbowPickItem.More10] = 3,
            [RainbowPickItem.More15] = 3,
            [RainbowPickItem.More20] = 3,
        }
        if nLevel == 1 then
            tableRate[RainbowPickItem.SilverChest] = 27
            tableRate[RainbowPickItem.GoldChest] = 22
            tableRate[RainbowPickItem.DiamondChest] = 12
        end
        local nItem = LuaHelper.GetIndexByRate2(tableRate)
        if nItem == -1 then
            nItem = RainbowPickItem.None
        end
        return nItem
    else
        RainbowPickDataHandler.data.nNoRewardTime = RainbowPickDataHandler.data.nNoRewardTime + 1
        return RainbowPickItem.None
    end
end

RainbowPickConfig.ChestReward = {
    CardPack = 1,
    Coin = 2,
    Diamond = 3,
    LuckyPick = 4
}

--箱子开出的奖励类型的权重
RainbowPickConfig.tableChestRewardTypeRate = {
    [RainbowPickConfig.ChestReward.CardPack] = 20,
    [RainbowPickConfig.ChestReward.Coin] = 100,
    [RainbowPickConfig.ChestReward.Diamond] = 50,
    [RainbowPickConfig.ChestReward.LuckyPick] = 50,
}

--箱子奖励的卡包的类型的权重
RainbowPickConfig.tableChestRewardCardPackRate = {
    [RainbowPickChest.Silver] = {0, 2, 0, 0, 0},
    [RainbowPickChest.Gold] = {0, 0, 0, 2, 0},
    [RainbowPickChest.Diamond] = {0, 0, 0, 0, 2},
}

--箱子奖励的金币相当于几美元
RainbowPickConfig.tableChestRewardCoinRatio = {
    [RainbowPickChest.Silver] = 0.1,
    [RainbowPickChest.Gold] = 3,
    [RainbowPickChest.Diamond] = 10,
}

--箱子奖励的钻石相当于几美元
RainbowPickConfig.tableChestRewardDiamondRatio = {
    [RainbowPickChest.Silver] = 0.2,
    [RainbowPickChest.Gold] = 1,
    [RainbowPickChest.Diamond] = 3,
}

--点开一个箱子给的奖励
function RainbowPickConfig:getChestReward(nChestType)
    local nRewardType = LuaHelper.GetIndexByRate(self.tableChestRewardTypeRate)
    if not SlotsCardsManager:orActivityOpen() then
        --卡包关闭的话就不给卡包
        while nRewardType == self.ChestReward.CardPack do
            nRewardType = LuaHelper.GetIndexByRate(self.tableChestRewardTypeRate)
        end
    end
    local info = {nRewardType = nRewardType}
    if nRewardType == self.ChestReward.CardPack then
        --卡包的类型是从0到4的,所以要-1
        info.nCardPackType = LuaHelper.GetIndexByRate(self.tableChestRewardCardPackRate[nChestType]) - 1
        info.nCount = 1
    elseif nRewardType == self.ChestReward.Coin then
        info.nCount = ActivityHelper:getBasePrize() * self.tableChestRewardCoinRatio[nChestType]
    elseif nRewardType == self.ChestReward.Diamond then
        info.nCount = ActivityHelper:getBasePrizeDiamond() * self.tableChestRewardDiamondRatio[nChestType]
    elseif nRewardType == self.ChestReward.LuckyPick then

    end
    return info
end

--LuckyPick的基础奖励相当于多少美元
RainbowPickConfig.fLuckyPickBasePrizeRatio = 0.1
--LuckyPick的倍率
RainbowPickConfig.tableLuckyPickMultiplier = {
    {5, 10, 15},
    {30, 60, 80},
    {150, 200, 300}
}
--倍率的权重
RainbowPickConfig.tableLuckyPickMultiplierRate = {
    {3, 5, 1},
    {3, 5, 1},
    {3, 5, 1}
}

RainbowPickConfig.TABLE_LEVEL_PRIZE_RATIO = {5, 6, 7, 8, 9, 10, 12, 15, 17, 20} --1-10关,每关的基础金币奖励相当于几美元
RainbowPickConfig.F_FINAL_PRIZE_RATIO = 50
RainbowPickConfig.FinalPrizeRewardCardPack = {nCardPackType = SlotsCardsAllProbTable.PackType.Five, nCount = 2}
RainbowPickConfig.FinalPrizeRewardLoungeChest = {nChestType = LoungeConfig.enumCHESTTYPE.Epic, nCount = 20}
