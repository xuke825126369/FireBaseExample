AdsConfigHandler = {}

function AdsConfigHandler:Init()

end

function AdsConfigHandler:orInBlackList()
    return false
end

function AdsConfigHandler:GetAdsAwardMoneyCount()
    local TotalBetList = FormulaHelper:GetTotalBetList()
    return TotalBetList[#TotalBetList]
end

function AdsConfigHandler:orTriggerAdsInThemeSwitch()
    return RechargeHandler:orInLevelLimitRechargeRequestTime()
end

function AdsConfigHandler:orTriggerAdsInThemeLevelUp()
    if PlayerHandler.nLevel <= 5 then
        return false
    end

    if math.random() < 0.3 then
        return RechargeHandler:orInLevelLimitRechargeRequestTime()
    end
end

function AdsConfigHandler:orTriggerBannerAds()
    return false
end
