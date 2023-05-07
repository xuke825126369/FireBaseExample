FlashChallengeRewardConfig = {}
FlashChallengeRewardConfig.N_MIN_RATIO = 1000
FlashChallengeRewardConfig.N_NEXT_PLAY_TIME = 60 * 60 * 8
FlashChallengeRewardConfig.TO_NEXT_SEASON_FIRES = {0, 0, 2000, 6000, 10000, 22000}
FlashChallengeRewardConfig.PrizeType = {
    Coins = 1, -- 以后会增加小游戏
    PickBonus = 2,
}

FlashChallengeRewardConfig.m_mapAllRewards = {
    { 
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 1, nFireCount = 200 }, -- nMultiplier 指 1美金的十分之一的倍数
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 1, nFireCount = 500 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 1, nFireCount = 1000},
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 2, nFireCount = 2000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 2, nFireCount = 3000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 2, nFireCount = 4000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 2, nFireCount = 5000},
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 2, nFireCount = 6000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 3, nFireCount = 7000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 3, nFireCount = 8000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 3, nFireCount = 9000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 3, nFireCount = 10000},
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 3, nFireCount = 12000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 5, nFireCount = 14000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 5, nFireCount = 16000},
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 5, nFireCount = 18000},
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 4, nFireCount = 20000},
    }, 

    { 
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 10, nFireCount = 22000 }, -- nMultiplier 指 1美金的十分之一的倍数
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 10, nFireCount = 24000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 4, nFireCount = 26000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 15, nFireCount = 28000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 15, nFireCount = 30000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 15, nFireCount = 35000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 15, nFireCount = 40000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 15, nFireCount = 45000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 4, nFireCount = 50000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 20, nFireCount = 55000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 20, nFireCount = 60000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 4, nFireCount = 65000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 25, nFireCount = 70000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 25, nFireCount = 75000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 25, nFireCount = 80000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 25, nFireCount = 90000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 5, nFireCount = 100000 },
    }, 

    { 
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 30, nFireCount = 110000 }, -- nMultiplier 指 1美金的十分之一的倍数
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 30, nFireCount = 120000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 30, nFireCount = 130000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 30, nFireCount = 140000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 5, nFireCount = 150000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 35, nFireCount = 160000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 35, nFireCount = 180000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 35, nFireCount = 200000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 35, nFireCount = 220000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 5, nFireCount = 240000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 40, nFireCount = 260000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 40, nFireCount = 280000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 40, nFireCount = 300000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 40, nFireCount = 350000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 6, nFireCount = 400000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 45, nFireCount = 450000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 45, nFireCount = 500000 },
    }, 
    
    { 
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 45, nFireCount = 550000 }, -- nMultiplier 指 1美金的十分之一的倍数
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 0, nPickCount = 6, nFireCount = 600000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 50, nFireCount = 650000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 50, nFireCount = 700000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 50, nFireCount = 750000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 1, nPickCount = 2, nFireCount = 800000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 55, nFireCount = 850000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 55, nFireCount = 900000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 55, nFireCount = 1000000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 55, nFireCount = 1100000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 1, nPickCount = 2, nFireCount = 1200000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 60, nFireCount = 1300000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 60, nFireCount = 1400000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 60, nFireCount = 1500000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 60, nFireCount = 1600000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 1, nPickCount = 3, nFireCount = 1800000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 70, nFireCount = 2000000 },
    }, 

    { 
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 70, nFireCount = 2100000 }, -- nMultiplier 指 1美金的十分之一的倍数
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 70, nFireCount = 2200000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 1, nPickCount = 3, nFireCount = 2300000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 90, nFireCount = 2400000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 90, nFireCount = 2500000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 90, nFireCount = 2600000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 1, nPickCount = 3, nFireCount = 2700000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 120, nFireCount = 2800000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 120, nFireCount = 2900000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 120, nFireCount = 3000000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 2, nPickCount = 2, nFireCount = 3200000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 150, nFireCount = 3400000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 150, nFireCount = 3600000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 150, nFireCount = 3800000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 2, nPickCount = 3, nFireCount = 4000000 },
        {nType = FlashChallengeRewardConfig.PrizeType.Coins, nMultiplier = 200, nFireCount = 4500000 },
        {nType = FlashChallengeRewardConfig.PrizeType.PickBonus, nReduceCount = 2, nPickCount = 4, nFireCount = 5000000 },
    }, 
}

function FlashChallengeRewardConfig:GetRewardPrize(targetIndex)
    local nIndex = 1
    for i = 1, LuaHelper.tableSize(self.m_mapAllRewards) do
        for j = 1, LuaHelper.tableSize(self.m_mapAllRewards[i]) do
            if targetIndex == nIndex then
                return self.m_mapAllRewards[i][j]
            end
            nIndex = nIndex + 1
        end
    end
end

function FlashChallengeRewardConfig:GetCurrentRewardIndex()
    local nFiresCount = FlashChallengeRewardDataHandler.data.nFiresCount
    local nIndex = 1
    for i = 1, LuaHelper.tableSize(self.m_mapAllRewards) do
        for j = 1, LuaHelper.tableSize(self.m_mapAllRewards[i]) do
            if nFiresCount < FlashChallengeRewardConfig.m_mapAllRewards[i][j].nFireCount then
                return nIndex - 1
            end
            nIndex = nIndex + 1
        end
    end
    return nIndex - 1
end

function FlashChallengeRewardConfig:GetFlashChallengeMultiplierLevelNeedFireCount(nIndex)
    local fireExp = {150000, 500000, 1500000, 5000000, 10000000}
    if nIndex <= #fireExp then
        return fireExp[nIndex]
    else
        local cnt = #fireExp
        local fireCount = fireExp[cnt]
        local fcoef = Unity.Mathf.Pow(1.5, nIndex-cnt)
        fireCount = math.floor( fireCount * fcoef )
        return fireCount
    end
end