DailyMissionConfig = {}
DailyMissionConfig.m_MissionsValue = {
    {
        rewards = {CoinCoef = 0.25, missionStars = 150, missionPoints = 35},
        gemValue = 50, -- 解锁需要的钻石
    },
    {
        rewards = {CoinCoef = 0.5, missionStars = 300, missionPoints = 45},
        gemValue = 75,
    },
    {
        rewards = {CoinCoef = 0.75, missionStars = 450, missionPoints = 60},
        gemValue = 100,
    },
    {
        rewards = {CoinCoef = 1.0, missionStars = 600, missionPoints = 70},
        gemValue = 150,
    },
    {
        rewards = {CoinCoef = 1.5, missionStars = 750, missionPoints = 80},
        gemValue = 250,
    },
    {
        rewards = {CoinCoef = 2.0, missionStars = 900, missionPoints = 100},
        gemValue = 500,
    },
}

-- count 如果是金币数的 根据玩家等级修改 
-- 以下任务不能调顺序, 要加新任务就往后加。在表中的顺序就是任务ID
DailyMissionConfig.m_Missions = {
    -- 每天任务就下面这些可能
    {   -- 1 missionType
        descriptionFormat = "Spin %d times in game.",
        count = {50, 100, 200, 500, 600, 700, }
    },
    {   -- 2 missionType
        descriptionFormat = "Win %d times in game.",
        count = {20, 50, 100, 200, 300, 500, }
    },
    {   -- 3
        descriptionFormat = "Bet %s coins.",
        count = {25, 35, 60, 120, 250, 500}, -- OneDollarCoin (商店1美元的金币) 的倍数
        isCoinCoef = true,
    },
    {   -- 4
        descriptionFormat = "Win %s coins.",
        count = {20, 50, 100, 200, 350, 500},
        isCoinCoef = true,
    },
    {   -- 5
        descriptionFormat = "Get %d big wins.",
        count = {3, 5, 7, 9, 11, 13}
    },
    {   -- 6
        descriptionFormat = "Win %s Coins in a single spin X5 times.",
        count = {5, 10, 15, 20, 25, 30},
        isCoinCoef = true,
    },
    {   -- 7
        descriptionFormat = "Level up %d times.",
        count = {1, 1, 2, 2, 3, 3},
    },
    {   -- 8
        descriptionFormat = "Win %s Coins in 100 spins.",
        count = {20, 30, 50, 80, 120, 200, },
        isCoinCoef = true,
    },
}

-- 1到7天的 每天任务
DailyMissionConfig.m_MissionConfig = {
    -- 1
    {
        tasks = {1, 5, 6, }
        -- 对应 DailyMissionConfig.m_Missions 数组的key
    },

    -- 2
    {
        tasks = {4, 6, 8, }
    },

    -- 3
    {
        tasks = {3, 7, 8, }
    },

    -- 4
    {
        tasks = {2, 5, 6, 7, }
    },

    -- 5
    {
        tasks = {1, 5, 7, }
    },

    -- 6
    {
        tasks = {3, 6, 8,}
    },

    -- 7
    {
        tasks = {2, 3, 5, 7, 8, 6, }
    },
}

function DailyMissionConfig:getOneDollarCoins() -- 设置任务难度的一个参考
    local listTotalBet = FormulaHelper:GetTotalBetList()
    local nCoins = listTotalBet[#listTotalBet] * 5
    return nCoins
end

function DailyMissionConfig:getDailyMissionIndexs(nDailyIndex) -- 0-6
    return self.m_MissionConfig[nDailyIndex + 1].tasks
end
