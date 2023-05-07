BoardQuestConfig = {}
BoardQuestConfig.N_MAX_ACTION = 30
BoardQuestConfig.N_MAX_LEVEL = 5

--格子上东西的种类
BoardQuestConfig.ITEM = {
    NONE = 0,
    CANNON = 1,
    CARD = 2,
    COIN = 3,
    MYSTERY_REWARD = 4,
    MORE_CANNON = 5,
}
BoardQuestConfig.ITEM_KEY = LuaHelper.GetKeyValueSwitchTable(BoardQuestConfig.ITEM)
--每关格子上的东西
BoardQuestConfig.ROAD = {
    [1] = {
        [1] = BoardQuestConfig.ITEM.NONE,
        [2] = BoardQuestConfig.ITEM.CANNON,
        [3] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [4] = BoardQuestConfig.ITEM.NONE,
        [5] = BoardQuestConfig.ITEM.CANNON,
        [6] = BoardQuestConfig.ITEM.MORE_CANNON,
        [7] = BoardQuestConfig.ITEM.COIN,
        [8] = BoardQuestConfig.ITEM.CANNON,
        [9] = BoardQuestConfig.ITEM.MORE_CANNON,
        [10] = BoardQuestConfig.ITEM.NONE,
        [11] = BoardQuestConfig.ITEM.COIN,
        [12] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
    },
    [2] = {
        [1] = BoardQuestConfig.ITEM.NONE,
        [2] = BoardQuestConfig.ITEM.CANNON,
        [3] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [4] = BoardQuestConfig.ITEM.MORE_CANNON,
        [5] = BoardQuestConfig.ITEM.COIN,
        [6] = BoardQuestConfig.ITEM.MORE_CANNON,
        [7] = BoardQuestConfig.ITEM.CANNON,
        [8] = BoardQuestConfig.ITEM.MORE_CANNON,
        [9] = BoardQuestConfig.ITEM.NONE,
        [10] = BoardQuestConfig.ITEM.COIN,
        [11] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [12] = BoardQuestConfig.ITEM.CANNON,
        [13] = BoardQuestConfig.ITEM.NONE,
        [14] = BoardQuestConfig.ITEM.COIN,
        [15] = BoardQuestConfig.ITEM.CANNON,
        [16] = BoardQuestConfig.ITEM.NONE,
    },
    [3] = {
        [1] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [2] = BoardQuestConfig.ITEM.COIN,
        [3] = BoardQuestConfig.ITEM.CANNON,
        [4] = BoardQuestConfig.ITEM.NONE,
        [5] = BoardQuestConfig.ITEM.MORE_CANNON,
        [6] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [7] = BoardQuestConfig.ITEM.NONE,
        [8] = BoardQuestConfig.ITEM.CANNON,
        [9] = BoardQuestConfig.ITEM.NONE,
        [10] = BoardQuestConfig.ITEM.COIN,
        [11] = BoardQuestConfig.ITEM.NONE,
        [12] = BoardQuestConfig.ITEM.CANNON,
        [13] = BoardQuestConfig.ITEM.MORE_CANNON,
        [14] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [15] = BoardQuestConfig.ITEM.CANNON,
        [16] = BoardQuestConfig.ITEM.NONE,
        [17] = BoardQuestConfig.ITEM.MORE_CANNON,
        [18] = BoardQuestConfig.ITEM.CANNON,
        [19] = BoardQuestConfig.ITEM.COIN,
        [20] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
    },
    [4] = {
        [1] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [2] = BoardQuestConfig.ITEM.COIN,
        [3] = BoardQuestConfig.ITEM.CANNON,
        [4] = BoardQuestConfig.ITEM.MORE_CANNON,
        [5] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [6] = BoardQuestConfig.ITEM.CANNON,
        [7] = BoardQuestConfig.ITEM.NONE,
        [8] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [9] = BoardQuestConfig.ITEM.CANNON,
        [10] = BoardQuestConfig.ITEM.MORE_CANNON,
        [11] = BoardQuestConfig.ITEM.COIN,
        [12] = BoardQuestConfig.ITEM.NONE,
        [13] = BoardQuestConfig.ITEM.NONE,
        [14] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [15] = BoardQuestConfig.ITEM.COIN,
        [16] = BoardQuestConfig.ITEM.CARD,
        [17] = BoardQuestConfig.ITEM.MORE_CANNON,
        [18] = BoardQuestConfig.ITEM.CANNON,
        [19] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [20] = BoardQuestConfig.ITEM.COIN,
        [21] = BoardQuestConfig.ITEM.CANNON,
        [22] = BoardQuestConfig.ITEM.MORE_CANNON,
        [23] = BoardQuestConfig.ITEM.COIN,
        [24] = BoardQuestConfig.ITEM.CANNON,
    },
    [5] = {
        [1] = BoardQuestConfig.ITEM.NONE,
        [2] = BoardQuestConfig.ITEM.CANNON,
        [3] = BoardQuestConfig.ITEM.COIN,
        [4] = BoardQuestConfig.ITEM.MORE_CANNON,
        [5] = BoardQuestConfig.ITEM.CANNON,
        [6] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [7] = BoardQuestConfig.ITEM.NONE,

        [8] = BoardQuestConfig.ITEM.COIN,
        [9] = BoardQuestConfig.ITEM.CANNON,
        [10] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [11] = BoardQuestConfig.ITEM.MORE_CANNON,
        [12] = BoardQuestConfig.ITEM.CANNON,
        [13] = BoardQuestConfig.ITEM.COIN,
        [14] = BoardQuestConfig.ITEM.MYSTERY_REWARD,

        [15] = BoardQuestConfig.ITEM.NONE,
        [16] = BoardQuestConfig.ITEM.CANNON,
        [17] = BoardQuestConfig.ITEM.MORE_CANNON,
        [18] = BoardQuestConfig.ITEM.COIN,
        [19] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
        [20] = BoardQuestConfig.ITEM.CANNON,
        [21] = BoardQuestConfig.ITEM.NONE,

        [22] = BoardQuestConfig.ITEM.COIN,
        [23] = BoardQuestConfig.ITEM.CANNON,
        [24] = BoardQuestConfig.ITEM.MORE_CANNON,
        [25] = BoardQuestConfig.ITEM.CARD,
        [26] = BoardQuestConfig.ITEM.COIN,
        [27] = BoardQuestConfig.ITEM.NONE,
        [28] = BoardQuestConfig.ITEM.MYSTERY_REWARD,
    },
}
--每关的格子数量
BoardQuestConfig.ROAD_ITEM_COUNT = {12, 16, 20, 24, 28}

--格子上的金币的数值
function BoardQuestConfig:getCoinReward()
    local listCoef = {0.05, 0.06, 0.07, 0.08, 0.09, 0.1}
    local listProb = {100, 100, 100, 100, 100, 100}
    local index = LuaHelper.GetIndexByRate(listProb)
    return listCoef[index]
end

--格子上的卡包的星级
BoardQuestConfig.ROAD_CARD_PACK_TYPE = {
    [1] = SlotsCardsAllProbTable.PackType.Two,
    [2] = SlotsCardsAllProbTable.PackType.Three,
    [3] = SlotsCardsAllProbTable.PackType.Four,
    [4] = SlotsCardsAllProbTable.PackType.Four,
    [5] = SlotsCardsAllProbTable.PackType.Five,
}
--炮弹种类
BoardQuestConfig.BOOMER = {GRAY = 1, BLUE = 2, RED = 3, PURPLE = 4}
--炮弹转盘上的炮弹种类
BoardQuestConfig.ATTACK_WHEEL = {
    [1] = BoardQuestConfig.BOOMER.PURPLE,
    [2] = BoardQuestConfig.BOOMER.GRAY,
    [3] = BoardQuestConfig.BOOMER.BLUE,
    [4] = BoardQuestConfig.BOOMER.GRAY,
    [5] = BoardQuestConfig.BOOMER.RED,
    [6] = BoardQuestConfig.BOOMER.GRAY,
    [7] = BoardQuestConfig.BOOMER.BLUE,
    [8] = BoardQuestConfig.BOOMER.GRAY,
}
--炮弹的威力
BoardQuestConfig.ATTACK_WHEEL_POWER = {
    [BoardQuestConfig.BOOMER.GRAY] = 1,
    [BoardQuestConfig.BOOMER.BLUE] = 2,
    [BoardQuestConfig.BOOMER.RED] = 4,
    [BoardQuestConfig.BOOMER.PURPLE] = 8,
}
--每关怪物的血量
BoardQuestConfig.MONSTER_HP = {8, 15, 25, 35, 50}

if GameConfig.PLATFORM_EDITOR and CS.BootBehaviour.instance.m_nActiveTestType == 1 then
    BoardQuestConfig.MONSTER_HP = {1,1,1,1,1}
end
--转盘转到哪里停的权重
BoardQuestConfig.ATTACK_WHEEL_STOP_RATE = {
    --Purple
    [1] = 12,
    --Red
    [5] = 35,
    --Blue
    [3] = 50, [7] = 50,
    --Gray
    [2] = 80, [4] = 80, [6] = 80, [8] = 80,
}
--转盘转到哪个地方停止
function BoardQuestConfig:GetAttackWheelNodeIndex()
    return LuaHelper.GetIndexByRate(self.ATTACK_WHEEL_STOP_RATE)
end

--MysteryReward 奖励的种类
BoardQuestConfig.MYSTERY_REWARD_ITEM = {
    COIN1 = 1,
    COIN2 = 2,
    COIN3 = 3,
    CANNON = 4,
    DICE = 5
}
--MysteryReward 奖励的数量
BoardQuestConfig.MYSTERY_REWARD_VALUE = {
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1] = 0.1, --相当于0.1美元的金币
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2] = 0.2,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3] = 0.5,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON] = 0,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE] = 5,
}
--MysteryReward 奖励的权重
BoardQuestConfig.MYSTERY_REWARD_RATE = {
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN1] = 5, 
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN2] = 5,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.COIN3] = 5,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.CANNON] = 8,
    [BoardQuestConfig.MYSTERY_REWARD_ITEM.DICE] = 5,
}

--过一关的金币奖励相当于几美元
BoardQuestConfig.LEVEL_PRIZE_RATIO = {5, 10, 15, 20, 25} 

--完成一关奖励的卡包
BoardQuestConfig.LEVEL_PRIZE_CARD_PACK = {
    [1] = {nPackType = SlotsCardsAllProbTable.PackType.Two, nCount = 2},
    [2] = {nPackType = SlotsCardsAllProbTable.PackType.Two, nCount = 3},
    [3] = {nPackType = SlotsCardsAllProbTable.PackType.Three, nCount = 2},
    [4] = {nPackType = SlotsCardsAllProbTable.PackType.Four, nCount = 2},
    [5] = {nPackType = SlotsCardsAllProbTable.PackType.Five, nCount = 2},
}

BoardQuestConfig.FINAL_PRIZE_RATIO = 100 --完成所有关卡的金币奖励
BoardQuestConfig.FINAL_PRIZE_CARD_PACK = {nPackType = SlotsCardsAllProbTable.PackType.Five, nCount = 2}
