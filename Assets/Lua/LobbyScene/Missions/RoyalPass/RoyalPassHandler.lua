require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassConfig")
require("Lua.LobbyScene.Missions.RoyalPass.RoyalPassDbHandler")

RoyalPassHandler = {}
RoyalPassHandler.nActivityFirstTime = CS.TimeUtility.GetTimeStampFromLocalTime(CS.System.DateTime(2022, 1, 1, 0, 0, 0))
RoyalPassHandler.m_nOneDaySecond = 3600 * 24
RoyalPassHandler.nActivityDayCount = 21

RoyalPassHandler.m_bChangeToNextSeason = true
RoyalPassHandler.m_nLevel = 0
RoyalPassHandler.m_nLastChestLevel = 0
RoyalPassHandler.m_bClaimLoungeDayPassFlag = false
RoyalPassHandler.m_LoungeDayPassParam = {nDayPass = 0, nPrizeCoin = 0}

if GameConfig.PLATFORM_EDITOR then
    RoyalPassHandler.nActivityDayCount = 1
end

function RoyalPassHandler:Init()
    RoyalPassConfig:Init()
    RoyalPassDbHandler:Init()

    self:CheckSeasonEnd()
    self:SetCurrentLevel()
end

function RoyalPassHandler:orUnLock()
    return PlayerHandler.nLevel >= RoyalPassConfig.N_UNLOCK_LEVEL
end

function RoyalPassHandler:GetSeason()
    local fromSecond = self.nActivityFirstTime
    local nowSecond = TimeHandler:GetServerTimeStamp()
    local season = (nowSecond - fromSecond) // (3600 * 24 * self.nActivityDayCount)
    return season
end

function RoyalPassHandler:CheckSeasonEnd()
    local season = self:GetSeason()
    if RoyalPassDbHandler.data.m_nSeason ~= season then
        self.m_bChangeToNextSeason = true

        if RoyalPassDbHandler.data.m_nSeason >= 0 then
            self:SentAllPrizeNotReceived()
        end

        self:setRoyalPassEndTime()
        RoyalPassDbHandler:SaveDb()
    else
        self.m_bChangeToNextSeason = false
    end
end

function RoyalPassHandler:SentAllPrizeNotReceived()
    if not self:orUnLock() then
        return
    end

    self:SetCurrentLevel()
    local nLevel = self.m_nLevel + 1
    local nSeason = RoyalPassDbHandler.data.m_nSeason

    local mapInboxPrizeParams = {}
    for i = 1, nLevel do
        local prize = RoyalPassConfig:GetFreePassLevelPrize(i)
        for j = 1 , LuaHelper.tableSize(prize) do
            if not RoyalPassDbHandler.data.m_mapFreePassGet[i][j].bGet and (prize[j].nType ~= RoyalPassConfig.PrizeType.None) then
                local bSendReward = false
                if j == 2 then
                    if RoyalPassDbHandler.data.m_mapFreePassGet[i][j].bInLimitedEndFinish then
                        bSendReward = true
                    end
                else
                    bSendReward = true
                end

                if bSendReward then
                    if prize[j].nType == RoyalPassConfig.PrizeType.Coins then
                        local skuInfo = self:getBasePrize(prize[j].productId)
                        local nCoins = RoyalPassHandler:getCoinsTypeMoneyCount(prize[j].productId)
                        local BonusParam = {nRoyalPassType = 1, nType = RoyalPassConfig.PrizeType.Coins, nCoins = nCoins, strDollar = skuInfo.nDollar, nSeason = nSeason}
                        table.insert(mapInboxPrizeParams, BonusParam)
                    elseif prize[j].nType == RoyalPassConfig.PrizeType.Diamond then
                        local BonusParam = {nRoyalPassType = 1, nType = RoyalPassConfig.PrizeType.Diamond, nCount = prize[j].nCount, nSeason = nSeason}
                        table.insert(mapInboxPrizeParams, BonusParam)
                    elseif prize[j].nType == RoyalPassConfig.PrizeType.CoinsAndVip then
                        local skuInfo = self:getBasePrize(prize[j].productId)
                        local nCoins = RoyalPassHandler:getCoinsTypeMoneyCount(prize[j].productId)
                        local BonusParam = {nRoyalPassType = 1, nType = RoyalPassConfig.PrizeType.Coins, nCoins = nCoins, strDollar = skuInfo.nDollar, nSeason = nSeason}
                        table.insert(mapInboxPrizeParams, BonusParam)
                    end
                end
            end
        end
    end 

    if RoyalPassDbHandler.data.m_bIsPurchase then
        for i = 1, nLevel do
            local prize = RoyalPassConfig:GetRoyalPassLevelPrize(i)
            for j = 1 , LuaHelper.tableSize(prize) do
                if not RoyalPassDbHandler.data.m_mapRoyalPassGet[i][j].bGet and (prize[j].nType ~= RoyalPassConfig.PrizeType.None) then
                    local bSendReward = false
                    if j == 2 then
                        if RoyalPassDbHandler.data.m_mapRoyalPassGet[i][j].bInLimitedEndFinish then
                            bSendReward = true
                        end
                    else
                        bSendReward = true
                    end

                    if bSendReward then
                        if prize[j].nType == RoyalPassConfig.PrizeType.Coins then
                            local skuInfo = self:getBasePrize(prize[j].productId)
                            local nCoins = RoyalPassHandler:getCoinsTypeMoneyCount(prize[j].productId)
                            local BonusParam = {nRoyalPassType = 2, nType = RoyalPassConfig.PrizeType.Coins, nCoins = nCoins, strDollar = skuInfo.nDollar, nSeason = nSeason}
                            table.insert(mapInboxPrizeParams, BonusParam)
                        elseif prize[j].nType == RoyalPassConfig.PrizeType.Diamond then
                            local BonusParam = {nRoyalPassType = 2, nType = RoyalPassConfig.PrizeType.Diamond, nCount = prize[j].nCount, nSeason = nSeason}
                            table.insert(mapInboxPrizeParams, BonusParam)
                        elseif prize[j].nType == RoyalPassConfig.PrizeType.CoinsAndVip then
                            local skuInfo = self:getBasePrize(prize[j].productId)
                            local nCoins = RoyalPassHandler:getCoinsTypeMoneyCount(prize[j].productId)
                            local BonusParam = {nRoyalPassType = 2, nType = RoyalPassConfig.PrizeType.Coins, nCoins = nCoins, strDollar = skuInfo.nDollar, nSeason = nSeason}
                            table.insert(mapInboxPrizeParams, BonusParam)
                        end
                    end
                end
            end
        end

        if self.m_nLevel >= 100 and self.m_nLastChestLevel > 0 then
            local BonusParam = {nCoins = self:GetLastChestLevelRewards()}
            CommonDbHandler:AddRoyalTrophyRewardsToInbox({BonusParam})
        end
    end
    
    if LuaHelper.tableSize(mapInboxPrizeParams) > 0 then
        CommonDbHandler:AddRoyalPassRewardToInbox(mapInboxPrizeParams)
    end

    EventHandler:Brocast("onInboxMessageChangedNotifycation")
end

function RoyalPassHandler:SetCurrentLevel()
    local nTotalStar = RoyalPassDbHandler.data.nStars
    for i = 1, LuaHelper.tableSize(RoyalPassConfig.MAP_LEVEL_STAR) do
        if nTotalStar < RoyalPassConfig.MAP_LEVEL_STAR[i] then
            self.m_nLevel = i - 1
            break
        else
            nTotalStar = nTotalStar - RoyalPassConfig.MAP_LEVEL_STAR[i]
            if i == 100 then
                self.m_nLevel = 100
            end
        end
    end
    
    if self.m_nLevel == 100 then
        local nChestLevel = 0
        local nChestLevelUpgradeNeedStars = RoyalPassConfig.N_UPGRADE_LASTCHEST_STARS
        while nTotalStar > nChestLevelUpgradeNeedStars do
            nTotalStar = nTotalStar - nChestLevelUpgradeNeedStars
            nChestLevel = nChestLevel + 1
            if nChestLevel % 10 == 0 then
                nChestLevelUpgradeNeedStars = nChestLevelUpgradeNeedStars + 250
            end
        end
        self.m_nLastChestLevel = nChestLevel
    else
        self.m_nLastChestLevel = 0
    end

end

function RoyalPassHandler:GetLastChestCurrentRemainStar()
    local nTotalStar = RoyalPassDbHandler.data.nStars
    local nCurrentLevel = 0
    for i = 1, LuaHelper.tableSize(RoyalPassConfig.MAP_LEVEL_STAR) do
        if nTotalStar < RoyalPassConfig.MAP_LEVEL_STAR[i] then
            nCurrentLevel = i - 1
            break
        else
            nTotalStar = nTotalStar - RoyalPassConfig.MAP_LEVEL_STAR[i]
            if i == 100 then
                nCurrentLevel = 100
            end
        end
    end

    local nChestLevelUpgradeNeedStars = RoyalPassConfig.N_UPGRADE_LASTCHEST_STARS
    if nCurrentLevel == 100 then
        local nChestLevel = 0
        while nTotalStar > nChestLevelUpgradeNeedStars do
            nTotalStar = nTotalStar - nChestLevelUpgradeNeedStars
            nChestLevel = nChestLevel + 1
            if nChestLevel % 10 == 0 then
                nChestLevelUpgradeNeedStars = nChestLevelUpgradeNeedStars + 250
            end
        end
    end
    return nTotalStar, nChestLevelUpgradeNeedStars
end

function RoyalPassHandler:GetLastChestLevelRewards()
    self:SetCurrentLevel()
    local nCoins = RoyalPassConfig.N_MIN_CHEST_REWARD * self.m_nLastChestLevel * self:getBasePrize(AllBuyCFG[1].productId).baseCoins
    return nCoins
end

function RoyalPassHandler:getUpgradeNeedsStar(nUpgardeLevel)
    local nCurrentLevel = self.m_nLevel + 1
    local targetLevel = self.m_nLevel + nUpgardeLevel -- 比如30 升5级，只需要加30， 31， 32， 33，34所需要的star数就行
    if targetLevel > 100 then
        targetLevel = 100
    end
    local nNeedsStar = 0
    for i = nCurrentLevel, targetLevel do
        nNeedsStar = nNeedsStar + RoyalPassConfig.MAP_LEVEL_STAR[i]
    end
    return nNeedsStar
end

function RoyalPassHandler:addStars(nCount)
    if not self:orUnLock() then
        return false
    end

    local bIsUpgrade = false
    local bHasPrize = false
    RoyalPassDbHandler.data.nStars = RoyalPassDbHandler.data.nStars + nCount
    
    local lastLevel = self.m_nLevel
    self:SetCurrentLevel()
    if lastLevel ~= self.m_nLevel then
        if RoyalPassDbHandler.data.m_bIsPurchase then
            bHasPrize = true
        end
        bIsUpgrade = true
        local nLast = lastLevel + 1
        for i = nLast, self.m_nLevel do
            local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(i+1)
            for j = 1, LuaHelper.tableSize(prizeInfo) do
                if prizeInfo[j].nType ~= RoyalPassConfig.PrizeType.None then
                    bHasPrize = true
                end
            end
            if (i % 10) == 1 then
                local nLimitedIndex = (math.floor(i / 10) + 1) * 10 + 1
                local nCurrentTime = TimeHandler:GetServerTimeStamp()
                RoyalPassDbHandler.data.m_mapFreePassGet[nLimitedIndex][2].nLimitedEndTime = nCurrentTime + RoyalPassConfig.N_INTERVAL_LIMITED_TIME
                RoyalPassDbHandler.data.m_mapFreePassGet[nLimitedIndex][2].bInLimitedEndFinish = false
    
                RoyalPassDbHandler.data.m_mapRoyalPassGet[nLimitedIndex][2].nLimitedEndTime = nCurrentTime + RoyalPassConfig.N_INTERVAL_LIMITED_TIME
                RoyalPassDbHandler.data.m_mapRoyalPassGet[nLimitedIndex][2].bInLimitedEndFinish = false
            elseif (i % 10) == 0 then --说明这里有Limited Pass
                local nLimitedIndex = i + 1
                local nCurrentTime = TimeHandler:GetServerTimeStamp()
                if nCurrentTime <= RoyalPassDbHandler.data.m_mapFreePassGet[nLimitedIndex][2].nLimitedEndTime then
                    RoyalPassDbHandler.data.m_mapFreePassGet[nLimitedIndex][2].bInLimitedEndFinish = true
                end
                if nCurrentTime <= RoyalPassDbHandler.data.m_mapRoyalPassGet[nLimitedIndex][2].nLimitedEndTime then
                    RoyalPassDbHandler.data.m_mapRoyalPassGet[nLimitedIndex][2].bInLimitedEndFinish = true
                end
            end
        end
    end

    RoyalPassDbHandler:SaveDb()
    return bIsUpgrade, bHasPrize
end

function RoyalPassHandler:setPurchase()
    RoyalPassDbHandler.data.m_bIsPurchase = true
    RoyalPassDbHandler:SaveDb()
end

function RoyalPassHandler:getNumberOfRewardsNotReceived()
    if not RoyalPassHandler:orUnLock() then
        return 0
    end
    local nLevel = self.m_nLevel + 1
    local nCount = 0
    for i = 1, nLevel do
        local prize = RoyalPassConfig:GetFreePassLevelPrize(i)
        for j = 1 , LuaHelper.tableSize(prize) do
            if not RoyalPassDbHandler.data.m_mapFreePassGet[i][j].bGet and (prize[j].nType ~= RoyalPassConfig.PrizeType.None) then
                if j == 2 then
                    if RoyalPassDbHandler.data.m_mapFreePassGet[i][j].bInLimitedEndFinish then
                        nCount = nCount + 1
                    end
                else
                    nCount = nCount + 1
                end
            end
        end
    end
    if RoyalPassDbHandler.data.m_bIsPurchase then
        for i = 1, nLevel do
            local prize = RoyalPassConfig:GetRoyalPassLevelPrize(i)
            for j = 1 , LuaHelper.tableSize(prize) do
                if not RoyalPassDbHandler.data.m_mapRoyalPassGet[i][j].bGet and (prize[j].nType ~= RoyalPassConfig.PrizeType.None) then
                    if j == 2 then
                        if RoyalPassDbHandler.data.m_mapRoyalPassGet[i][j].bInLimitedEndFinish then
                            nCount = nCount + 1
                        end
                    else
                        nCount = nCount + 1
                    end
                end
            end
        end
    end
    return nCount
end

function RoyalPassHandler:getFreePassGet(nIndex, infoIndex)
    return RoyalPassDbHandler.data.m_mapFreePassGet[nIndex][infoIndex].bGet
end

function RoyalPassHandler:getFreePassLimitedInfo(nIndex)
    return RoyalPassDbHandler.data.m_mapFreePassGet[nIndex][2]
end

function RoyalPassHandler:setFreePassGet(nIndex, infoIndex)
    local prizeInfo = RoyalPassConfig:GetFreePassLevelPrize(nIndex)
    local prize = prizeInfo[infoIndex]
    self:collectCorrespondingPrize(prize)
    
    RoyalPassDbHandler.data.m_mapFreePassGet[nIndex][infoIndex].bGet = true
    RoyalPassDbHandler:SaveDb()
end

function RoyalPassHandler:setFreePassAllGet()
    for i = 0, self.m_nLevel do
        local prize = RoyalPassConfig:GetFreePassLevelPrize(i+1)
        for j = 1 , LuaHelper.tableSize(prize) do
            if not RoyalPassDbHandler.data.m_mapFreePassGet[i+1][j].bGet then
                if j == 2 then
                    if RoyalPassDbHandler.data.m_mapFreePassGet[i+1][j].bInLimitedEndFinish then
                        self:collectCorrespondingPrize(prize[j])
                        RoyalPassDbHandler.data.m_mapFreePassGet[i+1][j].bGet = true
                    end
                else
                    self:collectCorrespondingPrize(prize[j])
                    RoyalPassDbHandler.data.m_mapFreePassGet[i+1][j].bGet = true
                end
            end
        end
    end
    RoyalPassDbHandler:SaveDb()
end

function RoyalPassHandler:getRoyalPassGet(nIndex, infoIndex)
    return RoyalPassDbHandler.data.m_mapRoyalPassGet[nIndex][infoIndex].bGet
end

function RoyalPassHandler:getRoyalPassLimitedInfo(nIndex)
    return RoyalPassDbHandler.data.m_mapRoyalPassGet[nIndex][2]
end

function RoyalPassHandler:setRoyalPassGet(nIndex, infoIndex)
    local prizeInfo = RoyalPassConfig:GetRoyalPassLevelPrize(nIndex)
    local prize = prizeInfo[infoIndex]
    self:collectCorrespondingPrize(prize)

    RoyalPassDbHandler.data.m_mapRoyalPassGet[nIndex][infoIndex].bGet = true
    RoyalPassDbHandler:SaveDb()
end

function RoyalPassHandler:collectCorrespondingPrize(prize)
    if prize.nType == RoyalPassConfig.PrizeType.Coins then
        local nMoneyCount = self:getCoinsTypeMoneyCount(prize.productId)
        PlayerHandler:AddCoin(nMoneyCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.SlotsCards then
        SlotsCardsGiftManager:getStampPackInActive(prize.nSlotsType, prize.nCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.VipPoint then
        PlayerHandler:AddVipPoint(prize.nPointCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.Activty then
        if ActiveManager.activeType == ActiveType.Bingo then
            local nCount = BingoIAPConfig.skuMapOther[prize.productId]
            BingoHandler:addPickCount(nCount)
        else
            Debug.LogError("活动不存在")
        end
    elseif prize.nType == RoyalPassConfig.PrizeType.Diamond then
        PlayerHandler:AddSapphire(prize.nCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.LoungePoint then
        LoungeHandler:addLoungePoints(prize.nCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.LoungeDayPass then
        self.m_bClaimLoungeDayPassFlag = true
        self.m_LoungeDayPassParam.nDayPass = self.m_LoungeDayPassParam.nDayPass + prize.nCount
        local bMemberFlag = LoungeHandler:isLoungeMember()
        if bMemberFlag then
            local nCoins = LoungeConfig:getLoungeDayPassToCoin(prize.nCount)
            PlayerHandler:AddCoin(nCoins)
            self.m_LoungeDayPassParam.nPrizeCoin = self.m_LoungeDayPassParam.nPrizeCoin + nCoins
        else
            LoungeHandler:setLoungeDayPass(prize.nCount)
        end
    elseif prize.nType == RoyalPassConfig.PrizeType.LoungeChest then
        LoungeHandler:addChest(prize.nChestType, prize.nCount)
    elseif prize.nType == RoyalPassConfig.PrizeType.Coupon then
        CommonDbHandler:AddInboxCoinCouponInfo(prize.nTime, prize.fRatio)
    elseif prize.nType == RoyalPassConfig.PrizeType.DiamondCoupon then
        CommonDbHandler:AddInboxDiamondCouponInfo(prize.nTime, prize.fRatio)
    elseif prize.nType == RoyalPassConfig.PrizeType.MissionStarBooster then
        CommonDbHandler:setMissionStarBooster(prize.nTime)
    elseif prize.nType == RoyalPassConfig.PrizeType.FlashBooster then
        CommonDbHandler:setFlashBooster(prize.nTime)
    elseif prize.nType == RoyalPassConfig.PrizeType.CoinsAndVip then
        local nMoneyCount = self:getCoinsTypeMoneyCount(prize.productId)
        PlayerHandler:AddCoin(nMoneyCount)
        PlayerHandler:AddVipPoint(prize.nPointCount)
    end

end

function RoyalPassHandler:setRoyalPassAllGet()
    for i = 0, self.m_nLevel do
        local prize = RoyalPassConfig:GetRoyalPassLevelPrize(i+1)
        for j = 1 , LuaHelper.tableSize(prize) do
            if not RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bGet then
                if j == 2 then
                    if RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bInLimitedEndFinish then
                        self:collectCorrespondingPrize(prize[j])
                        RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bGet = true
                    end
                else
                    self:collectCorrespondingPrize(prize[j])
                    RoyalPassDbHandler.data.m_mapRoyalPassGet[i+1][j].bGet = true
                end
            end
        end
    end
    RoyalPassDbHandler:SaveDb()
end

function RoyalPassHandler:setRoyalPassEndTime()
    local fromSecond = self.nActivityFirstTime
    local season = self:GetSeason()
        
    RoyalPassDbHandler.data = RoyalPassDbHandler:GetDbInitData()
    RoyalPassDbHandler.data.m_nSeason = season
    RoyalPassDbHandler.data.m_nEndTime = fromSecond + (season + 1) * self.nActivityDayCount * self.m_nOneDaySecond
    RoyalPassDbHandler:SaveDb()
end

--以1美金为奖励
function RoyalPassHandler:getBasePrize(productId)
    return GameHelper:GetSimpleSkuInfoById(productId)
end

--以1美金为奖励
function RoyalPassHandler:getCoinsTypeMoneyCount(productId)
    return GameHelper:GetSimpleSkuInfoById(productId).finalCoins
end
