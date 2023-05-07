FlashChallengeConfig = {}
FlashChallengeConfig.UNLOCKLEVEL = 40
if GameConfig.PLATFORM_EDITOR then
    FlashChallengeConfig.UNLOCKLEVEL = 2
end

FlashChallengeConfig.m_MissionsValue = {
    {
        rewards = {FlameCount = 600, missionStars = 75},
        gemValue = 30, -- 解锁需要的钻石
    },
    {
        rewards = {FlameCount = 2000, missionStars = 100},
        gemValue = 50,
    },
    {
        rewards = {FlameCount = 6000, missionStars = 150},
        gemValue = 100,
    },
    {
        rewards = {FlameCount = 20000, missionStars = 250},
        gemValue = 200,
    },
    {
        rewards = {FlameCount = 50000, missionStars = 350},
        gemValue = 500,
    },
    {
        rewards = {FlameCount = 100000, missionStars = 450},
        gemValue = 700,
    },
    {
        rewards = {FlameCount = 150000, missionStars = 550},
        gemValue = 1000,
    },
    {
        rewards = {FlameCount = 200000, missionStars = 750},
        gemValue = 1500,
    },
    {
        rewards = {FlameCount = 300000, missionStars = 750},
        gemValue = 2000,
    },
    {
        rewards = {FlameCount = 500000, missionStars = 750},
        gemValue = 3000,
    },
    {
        rewards = {FlameCount = 750000, missionStars = 750},
        gemValue = 5000,
    },
    -- 往后的奖励就不增加 gemValue按50%增加
}

FlashChallengeConfig.m_Missions = {
    {   -- 1 missionType
        descriptionFormat = "Spin %d times",
        count = {50, 100, 200, 500, 600, 700, 800, 1000, 1200, }
    },
    {   -- 2
        descriptionFormat = "Bet %s coins.",
        count = {15, 25, 35, 60, 120, 250, 800, }, -- OneDollarCoin (商店1美元的金币) 的倍数
        isCoinCoef = true,
    },
    {   -- 3
        descriptionFormat = "Win %s coins.",
        count = {10, 20, 30, 50, 100, 200, 500, 1000,},
        isCoinCoef = true,
    },
    {   -- 4
        descriptionFormat = "Get %d big wins.",
        count = {1, 2, 3, 5, 7, 9, 12, 15, }
    },
    {   -- 5 这个任务不要配在第一个
        descriptionFormat = "Play Lucky Wheel %d time.",
        count = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,},
    },
    {   -- 6 这个任务不要配在第一个
        descriptionFormat = "Play Mega Ball %d time.",
        count = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,},
    },
    {   -- 7
        descriptionFormat = "Watch AD %d times.",
        count = {2, 2, 2, 2, 3, 3, 3, 3, 3, 5, 5, 5,},
    },
    {   -- 8
        descriptionFormat = "Collect %d Slots Cards packs.",
        count = {5, 10, 20, 30, 50, 70, 100, 150, 200, 300, 500, 800, 1000, },
    },
}

function FlashChallengeConfig:getOneDollarCoins() -- 设置任务难度的一个参考
    local nCoins = FormulaHelper:GetAddMoneyBySpendDollar(1)
    local fCoef = 1.0 * PlayerHandler.nLevel / 200
    nCoins = nCoins * fCoef // 1000 * 1000
    return nCoins
end

function FlashChallengeConfig:getFlashChallengeParams(nTaskOrder, nDoneTimes)
    if nTaskOrder == 5 then
        local data = self:init5thSpecialMission(nDoneTimes)
        return data
    end
    
    local nMissionIndex = FlashChallengeHandler.data.m_FlashTaskIndexs[nTaskOrder]
    local nOneDollarCoins = self:getOneDollarCoins()
    local mission = self.m_Missions[nMissionIndex]
    local nCount = 0 -- 金币数或者完成次数
    if nDoneTimes < #mission.count then
        nCount = mission.count[nDoneTimes + 1]
    else
        nCount = mission.count[#mission.count]
    end

    if mission.isCoinCoef then
        nCount = nCount * nOneDollarCoins
        nCount = MoneyFormatHelper.normalizeCoinCount(nCount)
    end
    
    local nMiniBet = 0
    if mission.minBet ~= nil then
        nMiniBet = mission.minBet * nOneDollarCoins
        local nMinTotalBet = self:getNowMinTotalBet()
        local nMaxTotalBet = self:getNowMaxTotalBet()
        nMiniBet = math.max(nMiniBet, nMinTotalBet)
        nMiniBet = math.min(nMiniBet, nMaxTotalBet)
        nMiniBet = MoneyFormatHelper.normalizeCoinCount(nMiniBet)
    end

    local data = {nTaskID = nMissionIndex, count = nCount, miniBet = nMiniBet}
    return data
end

function FlashChallengeConfig:init5thSpecialMission(nDoneTimes)
    local tasks = {5, 6, 7, 8}
    local nMissionIndex = tasks[math.random(1, #tasks)]
    local mission = self.m_Missions[nMissionIndex]
    local nCount = 0 -- 完成次数
    if nDoneTimes < #mission.count then
        nCount = mission.count[nDoneTimes + 1]
    else
        nCount = math.floor(mission.count[#mission.count] * 2)
    end

    local data = {nTaskID = nMissionIndex, count = nCount, miniBet = 0}
    return data
end

function FlashChallengeConfig:getMissionValues(nDoneTime)
    local listMissionsValue = self.m_MissionsValue
    local values = {
        rewards = {FlameCount = 600, missionStars = 75},
        gemValue = 40, -- 解锁需要的钻石
    }

    local cnt = #listMissionsValue
    if nDoneTime < cnt then
        values.rewards = listMissionsValue[nDoneTime + 1].rewards
        values.gemValue = listMissionsValue[nDoneTime + 1].gemValue
    else
        local configParam = listMissionsValue[cnt]
        local num = nDoneTime - cnt + 1
        local fGemMulti = Unity.Mathf.Pow(1.5, num)

        values.rewards = configParam.rewards -- rewards 返还的是引用 外面也不允许修改了
        values.gemValue = math.floor(configParam.gemValue * fGemMulti)
    end
    
    return values
end

function FlashChallengeConfig:getNowMinTotalBet()
	local tableTotalBet = FormulaHelper:GetTotalBetList()
	return tableTotalBet[1]
end

function FlashChallengeConfig:getNowMaxTotalBet()
	local tableTotalBet = FormulaHelper:GetTotalBetList()
	return tableTotalBet[#tableTotalBet]
end
